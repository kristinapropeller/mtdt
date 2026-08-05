/**
 * Created on 30/07/2023.
 */

@IsTest
private class PDFMonkeyConnector_Test {
    @IsTest
    static void testDocumentCreation() {
        Test.setMock(HttpCalloutMock.class, new PDFMonkeyMock());
        Test.startTest();
        PDFMonkeyConnector.ResponseDocument doc = PDFMonkeyConnector.createDocument('test', 'test.pdf', 'test', new Map<String, Object>());
        Test.stopTest();
        pp_T.expect(doc.id).never.toBeNull();
        pp_T.expect(doc.created_at).never.toBeNull();
        pp_T.expect(doc.document_template_id).never.toBeNull();
        pp_T.expect(doc.updated_at).never.toBeNull();
        pp_T.expect(doc.app_id).never.toBeNull();
        pp_T.expect(doc.checksum).toBeNull();
        pp_T.expect(doc.failure_cause).toBeNull();
        pp_T.expect(doc.public_share_link).toBeNull();
    }
}