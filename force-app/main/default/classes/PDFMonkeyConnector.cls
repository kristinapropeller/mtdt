/**
 * Created on 28/07/2023.
 */

global without sharing class PDFMonkeyConnector {
    private static final String BASE_URL = 'https://api.pdfmonkey.io/api/v1';
    private static final String DOCUMENT_ENDPOINT = '/documents';

    global static ResponseDocument createDocument(String documentTemplateId, String fileName, String recordId, Map<String, Object> payload) {
        return createDocument(documentTemplateId, new Map<String, String>{
                '_filename' => fileName,
                'record_id' => recordId
        }, payload);
    }
    global static ResponseDocument createDocument(String documentTemplateId, Map<String, String> meta, Map<String, Object> payload) {
        RequestDocument doc = new RequestDocument(documentTemplateId, meta, payload);
        return createDocument(doc);
    }
    global static ResponseDocument createDocument(RequestDocument doc) {
        return createDocument(new Request(doc));
    }
    private static ResponseDocument createDocument(Request req) {
        String resStr = new pp_RestExplorer(BASE_URL + DOCUMENT_ENDPOINT)
                .doPost()
                .setHeader('Authorization', 'Bearer ' + PDFMonkeyIntegration__c.getOrgDefaults().API_Key__c)
                .setBody(JSON.serialize(req, true))
                .getResult();
        Response res = (Response)JSON.deserialize(resStr, Response.class);
        return res.document;
    }

    public static Map<String, Map<String, Map<String, String>>> getTranslations() {
        String translationsStr = PDFMonkeyIntegration__c.getOrgDefaults().Translations__c;
        if (String.isEmpty(translationsStr)) return  new Map<String, Map<String, Map<String, String>>>();
        return (Map<String, Map<String, Map<String, String>>>)JSON.deserialize(translationsStr, Map<String, Map<String, Map<String, String>>>.class);
    }


    private class Request {
        public RequestDocument document {get;set;}

        public Request() {}
        public Request(RequestDocument document) {
            this.document = document;
        }
    }
    global class Response {
        global ResponseDocument document {get;set;}
    }
    global class RequestDocument {
        global String document_template_id {get;set;}
        global String status {get;set;}
        global Map<String, Object> payload {get;set;}
        global Map<String, String> meta {get;set;}

        global RequestDocument() {}
        global RequestDocument(String documentTemplateId, Map<String, String> meta, Map<String, Object> payload) {
            this.document_template_id = documentTemplateId;
            this.meta = meta;
            this.payload = payload;
            this.status = 'pending';
        }
    }
    global class ResponseDocument {
        global String id {get;set;}
        global Datetime created_at {get;set;}
        global String document_template_id {get;set;}
        global String meta {get;set;}
        global String status {get;set;}
        global Datetime updated_at {get;set;}
        global String app_id {get;set;}
        global String download_url {get;set;}
        global String checksum {get;set;}
        global String failure_cause {get;set;}
        global String filename {get;set;}
        global String preview_url {get;set;}
        global String public_share_link {get;set;}
    }
}