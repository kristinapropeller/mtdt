/**
 * Created by artsiomartsiomenka on 27/03/2024.
 */

@IsTest
private class ClickUpAPIService_Test {
    static final String CLICK_UP_TASK_ID = 'tid123';
    static final String CLICK_UP_TIME_ID = 'ttid123';

    @TestSetup
    static void setup(){
        Account acc = new Account();
        acc.Name = 'Propeller Plan';
        insert acc;

        Id contactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Contact ct = new Contact();
        ct.LastName = (String)pp_T.create('Name');
        ct.Email = 'test@pp.test';
        ct.AccountId = acc.Id;
        ct.RecordTypeId = contactRTId;
        insert ct;

        Project__c proj = (Project__c)pp_T.createSObject('Project__c', new Map<String, Object>{ 'fields' => new List<String>{
                'Name', 'Rate__c', 'Tax_Rate__c', 'Commission_Rate__c'
        }});
        proj.Account__c = acc.Id;
        proj.ClickUp_Folder_Id__c = 'fid123';
        insert proj;

        Case cs = (Case)pp_T.createSObject('Case', new Map<String, Object>{ 'fields' => new List<String>{ 'Description' }});
        cs.Project__c = proj.Id;
        cs.ContactId = ct.Id;
        cs.External_System_ID__c = CLICK_UP_TASK_ID;
        cs.ClickUp_Task_Id__c = CLICK_UP_TASK_ID;
        insert cs;

        Timecard__c timecard = new Timecard__c();
        timecard.Person__c = ct.Id;
        timecard.Case__c = cs.Id;
        timecard.ClickUp_Time_Id__c = CLICK_UP_TIME_ID;
        insert timecard;

        ClickUp__c clickUpSettings = new ClickUp__c();
        clickUpSettings.Endpoint__c = 'https://api.clickup.com/api/v2/';
        clickUpSettings.API_Key__c = '123test';
        insert clickUpSettings;
    }

    @IsTest
    static void upsertTimeTrackedTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/clickup/webhook/task';
        req.resourcePath = '/services/apexrest/clickup/webhook/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"event":"taskTimeTrackedUpdated","task_id":"'+CLICK_UP_TASK_ID+'",' +
                '"data":{"description":"Time Tracking Edited"}}');

        RestContext.request = req;
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new ClickUpAPIServiceMock());
        Test.startTest();
        ClickUpREST.handlePost();
        Test.stopTest();

        Timecard__c timecard = (Timecard__c) new pp_Query('Timecard__c')
                .selectAllFields()
                .addConditionEq('ClickUp_Time_Id__c', CLICK_UP_TIME_ID)
                .fetch();

        pp_T.expect(timecard.Description__c).never.toBeNull();
    }

    @IsTest
    static void deleteTimeTrackedTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/clickup/webhook/task';
        req.resourcePath = '/services/apexrest/clickup/webhook/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"event":"taskTimeTrackedUpdated","task_id":"'+CLICK_UP_TASK_ID+'",' +
                '"data":{"description":"Time Tracking Deleted", "interval_id":"'+CLICK_UP_TIME_ID+'"}}');

        RestContext.request = req;
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new ClickUpAPIServiceMock());
        Test.startTest();
        ClickUpREST.handlePost();
        Test.stopTest();

        List<Timecard__c> timecards = new pp_Query('Timecard__c')
                .selectAllFields()
                .addConditionEq('ClickUp_Time_Id__c', CLICK_UP_TIME_ID)
                .run();

        pp_T.expect(timecards.isEmpty()).toBeTrue();
    }

    @IsTest
    static void handleTaskCreatedTest() {
        List<Case> cases = [SELECT Id, ClickUp_Task_Id__c FROM Case WHERE ClickUp_Task_Id__c <> NULL];
        if (!cases.isEmpty()) delete cases;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/clickup/webhook/task';
        req.resourcePath = '/services/apexrest/clickup/webhook/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"event":"taskCreated","task_id":"'+CLICK_UP_TASK_ID+'","data":{}}');

        RestContext.request = req;
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new ClickUpAPIServiceMock());
        Test.startTest();
        ClickUpREST.handlePost();
        Test.stopTest();

        List<Case> newCases = new pp_Query('Case')
                .selectAllFields()
                .addConditionEq('ClickUp_Task_Id__c', CLICK_UP_TASK_ID)
                .run();

        pp_T.expect(newCases.isEmpty()).toBeFalse();
    }

    @IsTest
    static void handleTaskUpdatedTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/clickup/webhook/task';
        req.resourcePath = '/services/apexrest/clickup/webhook/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"event":"taskUpdated","task_id":"'+CLICK_UP_TASK_ID+'","data":{}}');

        RestContext.request = req;
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new ClickUpAPIServiceMock());
        Test.startTest();
        ClickUpREST.handlePost();
        Test.stopTest();

        List<Case> newCases = new pp_Query('Case')
                .selectAllFields()
                .addConditionEq('ClickUp_Task_Id__c', CLICK_UP_TASK_ID)
                .run();

        pp_T.expect(newCases.isEmpty()).toBeFalse();
    }

    @IsTest
    static void handleTaskDeletedTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/clickup/webhook/task';
        req.resourcePath = '/services/apexrest/clickup/webhook/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"event":"taskDeleted","task_id":"'+CLICK_UP_TASK_ID+'","data":{}}');

        RestContext.request = req;
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new ClickUpAPIServiceMock());
        Test.startTest();
        ClickUpREST.handlePost();
        Test.stopTest();

        List<Case> newCases = new pp_Query('Case')
                .selectAllFields()
                .addConditionEq('ClickUp_Task_Id__c', CLICK_UP_TASK_ID)
                .run();

        pp_T.expect(newCases.isEmpty()).toBeTrue();
    }

    @isTest
    static void logInfoAndFlushLogsTest() {
        // Call the logInfo method with sample data
        String testMessage = 'This is a test message.';
        String testError = 'This is a test error.';
        ClickUpAPIService.logInfo(testMessage, testError);

        System.assertEquals(1, ClickUpAPIService.loggerRecords.size(), 'The loggerRecords list should have 1 log.');

        Log__c log = ClickUpAPIService.loggerRecords[0];
        System.assertEquals(testMessage, log.Request__c, 'The Request__c should match the message.');
        System.assertEquals(testError, log.Error__c, 'The Error__c should match the error.');

        Test.startTest();
        ClickUpAPIService.flushLogs();
        Test.stopTest();

        List<Log__c> insertedLogs = [SELECT Request__c, Error__c FROM Log__c];
        System.assertEquals(1, insertedLogs.size(), 'There should be 1 log inserted into the database.');
        System.assertEquals(testMessage, insertedLogs[0].Request__c, 'Inserted Request__c should match the message.');
        System.assertEquals(testError, insertedLogs[0].Error__c, 'Inserted Error__c should match the error.');
        
        System.assertEquals(0, ClickUpAPIService.loggerRecords.size(), 'The loggerRecords list should be empty after flushLogs.');
    }
}