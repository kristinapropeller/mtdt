/**
 * Created on 30/07/2023.
 */

public with sharing class PDFMonkeyMock implements HttpCalloutMock {
    public System.HttpResponse respond(System.HttpRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{\n' +
                '  "document": {\n' +
                '    "app_id": "91a7114e-55e3-4110-9441-a05b121d8045",\n' +
                '    "created_at": "2023-07-30T10:41:10.339+02:00",\n' +
                '    "document_template_id": "8e339346-f647-4fe3-a986-7fad1bd71f37",\n' +
                '    "document_template_identifier": "Invoice PL",\n' +
                '    "download_url": "https://pdfmonkey-store.s3.eu-west-3.amazonaws.com/production/backend/document/a8136a75-506f-4096-b953-f71aa396f6bf/FV-23_01_1.pdf?response-content-disposition=attachment&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA2DEHCSJKRKT25747%2F20230730%2Feu-west-3%2Fs3%2Faws4_request&X-Amz-Date=20230730T084114Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=287294862b1db762b11f2a6b97a4ac371548cae2b2fe6192389ddef17667e748",\n' +
                '    "failure_cause": null,\n' +
                '    "filename": "FV-23_01_1.pdf",\n' +
                '    "id": "a8136a75-506f-4096-b953-f71aa396f6bf",\n' +
                '    "meta": "{\\"record_id\\":\\"TEST_RECORD_ID\\",\\"_filename\\":\\"FV-23_01_1.pdf\\"}",\n' +
                '    "public_share_link": null,\n' +
                '    "status": "success",\n' +
                '    "updated_at": "2023-07-30T10:41:14.358+02:00"\n' +
                '  }\n' +
                '}');
        return res;
    }
}