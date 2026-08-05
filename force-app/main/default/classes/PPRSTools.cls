/**
 * Created by kirillreutski on 3.09.24.
 */

public with sharing class PPRSTools {
    private static final String pprsClassNameWithNS = 'PPRS';

    private static final String orgUrl = Url.getOrgDomainUrl().toExternalForm();
    private static final String sessionId = UserInfo.getSessionId();

    public static Integer TEST_responseStatusCode = null;

    public static String generateTriggerName(SObjectType sObjectType) {
        return pprsClassNameWithNS + '_' + sObjectType.toString() + 'Trigger';
    }
    public static Boolean upsertTrigger(SObjectType sObjectType) {
        Http httpReq = new Http();
        HttpResponse res = null;
        String triggerId = findExistingTrigger(sObjectType);
        try {
            if (Test.isRunningTest()) {
                res = new HttpResponse();
                res.setStatusCode(TEST_responseStatusCode == null ? 201 : TEST_responseStatusCode);
            } else {
                res = triggerId != null ?
                        updateTrigger(sObjectType, triggerId) :
                        httpReq.send(prepareRequest(sObjectType, 'POST', null));
            }
        } catch (Exception e) {
            PPRSLogger.instance.log(PPRSLogger.SEVERITY_ERROR, 'PPRSTools', 'createTrigger', e.getMessage());
            PPRSLogger.instance.store();
            return false;
        }

        if (res.getStatusCode() == 201) {
            PPRSLogger.instance.store();
            return true;
        } else {
            PPRSLogger.instance.log(PPRSLogger.SEVERITY_ERROR, 'PPRSTools', 'createTrigger', res.getBody());
            System.debug('Error: ' + res.getBody());
            PPRSLogger.instance.store();
            return false;
        }
    }
    public static Boolean deleteTrigger(SObjectType sObjectType){
        String triggerId = findExistingTrigger(sObjectType);
        return deleteTrigger(triggerId);
    }

    public static Boolean deleteTrigger(String triggerId){
        HttpRequest req = getRequestDraft();
        req.setEndpoint(orgUrl + '/services/data/v36.0/tooling/sobjects/ApexTrigger/' + triggerId);
        req.setMethod('DELETE');
        Http poll = new Http();
        HttpResponse response = null;
        if (Test.isRunningTest()) {
            response = new HttpResponse();
            response.setStatusCode(TEST_responseStatusCode == null ? 204 : TEST_responseStatusCode);
        }
        else {
            response = poll.send(req);
        }

        if (response.getStatusCode() != 204) {
            PPRSLogger.instance.log(PPRSLogger.SEVERITY_ERROR, 'PPRSTools', 'deleteTrigger', response.getBody());
            System.debug('Error: ' + response.getBody());
            PPRSLogger.instance.store();
        }
        return response.getStatusCode() == 204;
    }

    @TestVisible
    private static HttpResponse updateTrigger(SObjectType sObjectType, String triggerId){
        //Request
        HttpResponse containerResponse = getContainerResponse();

        System.debug('**** Metadata Container Response: ' + containerResponse.getBody());
        Object parsed = JSON.deserializeUntyped(containerResponse.getBody());
        Map<String, Object> container = (Map<String, Object>) parsed;

        HttpRequest apexClassRequest = getRequestDraft();
        apexClassRequest.setEndpoint(orgUrl + '/services/data/v36.0/tooling/sobjects/ApexTriggerMember/');
        apexClassRequest.setMethod('POST');
        String body = '{"ContentEntityId":"'+triggerId+'", "MetadataContainerId": "'+  container.get('id') +'", "Body" : "' + getTriggerBody(sObjectType) + '"}';
        apexClassRequest.setBody(body);

        Http poll = new Http();

        HttpResponse response = null;
        if (Test.isRunningTest()) {
            response = new HttpResponse();
            response.setStatusCode(TEST_responseStatusCode == null ? 201 : TEST_responseStatusCode);
        }
        else {
            response = poll.send(apexClassRequest);
        }

        return response;
    }

    private static String findExistingTrigger(SObjectType sObjectType) {
        String triggerName = generateTriggerName(sObjectType);
        String query = 'SELECT Id FROM ApexTrigger WHERE Name = \'' + triggerName + '\'';

        HttpRequest req = getRequestDraft();
        req.setEndpoint(orgUrl + '/services/data/v57.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

        Http http = new Http();
        HttpResponse res = null;
        if (Test.isRunningTest()) {
            res = new HttpResponse();
            res.setBody('{"records":[{"Id":"TestTrigger' + System.now() + '"}]}');
            res.setStatusCode(TEST_responseStatusCode == null ? 200 : TEST_responseStatusCode);
        }
        else {
            res = http.send(req);
        }

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) responseMap.get('records');
            if (!records.isEmpty()) {
                Map<String, Object> record = (Map<String, Object>) records[0];
                return (String) record.get('Id');
            }
        }
        return null;
    }

    public static String getTriggerBody(SObjectType sObjectType){
        String triggerName = generateTriggerName(sObjectType);
        String objectName = sObjectType.toString();

        return 'trigger ' + triggerName + ' on ' + objectName + ' (after insert, after update) {' +
                'if (Trigger.isAfter) {' +
                'if (Trigger.isInsert || Trigger.isUpdate){' +
                '' + pprsClassNameWithNS + '.getInstance().sync(Trigger.new);' +
                '}' +
                '}' +
                '}';

    }

    private static HttpRequest getRequestDraft(){
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + sessionId);

        return req;
    }

    public static HttpRequest prepareRequest(SObjectType sObjectType, String method, String existingTriggerId) {
        HttpRequest req = getRequestDraft();

        String triggerName = generateTriggerName(sObjectType);
        String objectName = sObjectType.toString();

        Map<String, String> reqBody = new Map<String, String>();
        reqBody.put('Name', triggerName);
        reqBody.put('TableEnumOrId', objectName);
        reqBody.put('Body', getTriggerBody(sObjectType));

        String endPoint = orgUrl + '/services/data/v57.0/tooling/sobjects/ApexTrigger';
        if (existingTriggerId != null) endPoint += '/' + existingTriggerId;
        req.setEndpoint(endPoint);
        req.setMethod(method);
        String body = JSON.serialize(reqBody);
        req.setBody(body);

        return req;
    }

    private static HttpResponse getContainerResponse() {
        HttpRequest containerRequest = getRequestDraft();
        containerRequest.setEndpoint(orgUrl + '/services/data/v36.0/tooling/sobjects/MetadataContainer/');
        containerRequest.setMethod('POST');
        containerRequest.setBody('{"Name":"TestContainer' + System.now() + '"}');

        Http poll = new Http();
        HttpResponse containerResponse = null;
        if (Test.isRunningTest()) {
            containerResponse = new HttpResponse();
            containerResponse.setBody('{"id":"TestContainer' + System.now() + '"}');
            containerResponse.setStatusCode(TEST_responseStatusCode == null ? 201 : TEST_responseStatusCode);
        }
        else {
            containerResponse = poll.send(containerRequest);
        }

        return containerResponse;
    }


    private static String baseUrl = orgUrl + '/services/data/v28.0/tooling/';

    public static void createClass() {
        // Note the escaping on newlines and quotes
        String classBody = 'public class MyNewClass {\\n'
                + ' public string SayHello() {\\n'
                + '  return \'Hello\';\\n'
                + ' }\\n'
                + '}';

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(baseUrl + 'sobjects/ApexClass');
        req.setMethod('POST');
        // OAuth header
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{'+
                '"Body" : "' + classBody +'"'+
                '}');

        Http h = new Http();
        HttpResponse res = h.send(req);
        // Response to a create should be 201
        if (res.getStatusCode() != 201) {
            System.debug(res.getBody());
            //throw new MyException(res.getStatus());
        }
    }

}