/**
 * Created on 30/07/2023.
 */

@IsTest
private class PDFMonkeyWebhookHandler_Test {
    @IsTest
    static void testDocumentParsing() {
        Account acc = new Account(Name = 'Test Name');
        insert acc;
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(new PDFMonkeyMock().respond(new HttpRequest()).getBody().replace('TEST_RECORD_ID', acc.Id));
        request.httpMethod = 'POST';
        request.resourcePath = '/services/apexrest/v1/webhook/pdfmonkey/*';
        request.requestURI = '/v1/webhook/pdfmonkey';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        PDFMonkeyWebhookHandler.handlePost();
        Test.stopTest();
        pp_T.expect(new pp_Query('ContentDocumentLink').addConditionEq('LinkedEntityId', acc.Id).countQuery()).toEqual(1);
    }
}