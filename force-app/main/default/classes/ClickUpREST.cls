/**
 * Created by artsiomartsiomenka on 10/02/2024.
 */

@RestResource(UrlMapping='/clickup/webhook/*')
global without sharing class ClickUpREST {

    private static void handleRequest(){
        ClickUpWebhookRoute router = new ClickUpWebhookRoute();
        router.execute();
    }

    @HttpPost
    global static void handlePost() {
        handleRequest();
    }
}