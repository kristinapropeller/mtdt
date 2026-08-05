/**
 * Created on 30/07/2023.
 */

@RestResource(urlMapping='/v1/webhook/pdfmonkey/*')
global without sharing class PDFMonkeyWebhookHandler {
    private static void handleRequest(){
        PDFMonkeyDocumentRoute router = new PDFMonkeyDocumentRoute();
        router.execute();
    }

    @HttpPost
    global static void handlePost() {
        handleRequest();
    }
}