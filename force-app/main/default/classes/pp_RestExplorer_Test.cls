@IsTest
private class pp_RestExplorer_Test {
    @IsTest
    static void testPostRequest() {
        HttpRequest req = new pp_RestExplorer('https://some-api.com', '/api/v1/test')
                .doPost()
                .setBody(new Map<String, Object>{'Name' => 'TestContainer'})
                .getRequest();

        Assert.areEqual(req.getHeader('Content-Type'), 'application/json');
        Assert.areEqual(req.getBody(), '{"Name":"TestContainer"}');
        Assert.areEqual(req.getMethod(), 'POST');
        Assert.areEqual(req.getEndpoint(), 'https://some-api.com/api/v1/test');
    }

    @IsTest
    static void testGetRequest() {
        HttpRequest req = new pp_RestExplorer()
                .doGet()
                .setEndpoint('https://some-api.com')
                .addParameter('q', 'test test')
                .addParameters(new Map<String, Object>{'q' => 'test test'})
                .setTimeout(12000)
                .getRequest();

        Assert.areEqual(req.getHeader('Content-Type'), 'application/json');
        Assert.areEqual(req.getMethod(), 'GET');
        Assert.areEqual(req.getEndpoint(), 'https://some-api.com?q=test+test');
    }

    @IsTest
    static void testOtherRequests() {
        Test.setMock(HttpCalloutMock.class, new pp_RestExplorer.MockResponse('{"test":"test"}'));
        HttpRequest req = new pp_RestExplorer('https://some-api.com/others')
                .doPut()
                .getRequest();
        Assert.areEqual(req.getMethod(), 'PUT');
        req = new pp_RestExplorer('https://some-api.com/others')
                .doDelete()
                .getRequest();
        Assert.areEqual(req.getMethod(), 'DELETE');
        req = new pp_RestExplorer('https://some-api.com/others')
                .doPatch()
                .getRequest();
        Assert.areEqual(req.getMethod(), 'PATCH');
        new pp_RestExplorer('https://some-api.com/others')
                .doPut()
                .getResultAsJSON();
    }
}