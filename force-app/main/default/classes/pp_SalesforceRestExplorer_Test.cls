@IsTest
private class pp_SalesforceRestExplorer_Test {
    @IsTest
    static void testPostRequest() {
        pp_SalesforceRestExplorer.setSessionId(UserInfo.getSessionId());
        HttpRequest req = new pp_SalesforceRestExplorer('/tooling/sobjects/MetadataContainer')
                .doPost()
                .setBody(new Map<String, Object>{'Name' => 'TestContainer'})
                .getRequest();

        Assert.areEqual(req.getHeader('Content-Type'), 'application/json');
        Assert.areEqual(req.getBody(), '{"Name":"TestContainer"}');
        Assert.areEqual(req.getMethod(), 'POST');
        Assert.areEqual(req.getEndpoint(),
                Url.getOrgDomainUrl().toExternalForm() +
                        '/services/data/v59.0/tooling/sobjects/MetadataContainer');
    }

    @IsTest
    static void testGetRequest() {
        pp_SalesforceRestExplorer.setApiVersion('50.0');
        String query = 'SELECT Id,Name From MetadataContainer WHERE Name = \'MyMeta\'';
        HttpRequest req = new pp_SalesforceRestExplorer('/tooling/query')
                .doGet()
                .addParameter('q', query)
                .addParameters(new Map<String, Object>{'q' => query})
                .setTimeout(12000)
                .getRequest();

        Assert.areEqual(req.getHeader('Content-Type'), 'application/json');
        Assert.areEqual(req.getMethod(), 'GET');
        Assert.areEqual(req.getEndpoint(),
                Url.getOrgDomainUrl().toExternalForm() +
                        '/services/data/v50.0/tooling/query?' +
                        'q=SELECT+Id%2CName+From+MetadataContainer+WHERE+Name+%3D+%27MyMeta%27');
    }

    @IsTest
    static void testOtherRequests() {
        Test.setMock(HttpCalloutMock.class, new pp_RestExplorer.MockResponse('{"test":"test"}'));
        HttpRequest req = new pp_SalesforceRestExplorer('/tooling/sobjects/MetadataContainer')
                .doPut()
                .getRequest();
        Assert.areEqual(req.getMethod(), 'PUT');
        req = new pp_SalesforceRestExplorer('/tooling/sobjects/MetadataContainer')
                .doDelete()
                .getRequest();
        Assert.areEqual(req.getMethod(), 'DELETE');
        req = new pp_SalesforceRestExplorer('/tooling/sobjects/MetadataContainer')
                .doPatch()
                .getRequest();
        Assert.areEqual(req.getMethod(), 'POST');
        new pp_SalesforceRestExplorer('/tooling/sobjects/MetadataContainer')
                .doPut()
                .getResultAsJSON();
    }
}