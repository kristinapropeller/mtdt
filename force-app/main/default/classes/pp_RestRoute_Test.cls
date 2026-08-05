@IsTest
private class pp_RestRoute_Test {
    static final String RESOURCE_URL = '/api/*';
    static final String RESOURCE_PATH = '/services/apexrest' + RESOURCE_URL;

    @IsTest
    static void testEntryRoute() {
        setupRestContext(RESOURCE_PATH, '/api/v1');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(400, resp.statusCode);
    }

    @IsTest
    static void testEntryRouteCollections() {
        setupRestContext(RESOURCE_PATH, '/api');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(400, resp.statusCode);
    }

    @IsTest
    static void testBaseRouteCollection() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies/');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);
        pp_RestRoute_TestMock.Company[] respData = (pp_RestRoute_TestMock.Company[]) JSON.deserialize(
                resp.responseBody.toString(),
                List<pp_RestRoute_TestMock.Company>.class
        );

        Assert.areEqual(2, respData.size());
    }

    @IsTest
    static void testNoResourceRoute() {
        setupRestContext(RESOURCE_PATH, '/api/v1/other/foo');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);

        Assert.areEqual('foo', resp.responseBody.toString());
    }

    @IsTest
    static void testBaseRouteCollection2() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);
        pp_RestRoute_TestMock.Company[] respData = (pp_RestRoute_TestMock.Company[]) JSON.deserialize(
                resp.responseBody.toString(),
                List<pp_RestRoute_TestMock.Company>.class
        );

        Assert.areEqual(2, respData.size());
    }

    @IsTest
    static void testBaseRouteSingle() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-1');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);
        pp_RestRoute_TestMock.Company respData = (pp_RestRoute_TestMock.Company) JSON.deserialize(
                resp.responseBody.toString(),
                pp_RestRoute_TestMock.Company.class
        );

        Assert.areEqual('c-1', respData.id);
    }

    @IsTest
    static void testSingleExpanded() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-1', new Map<String, String>{ 'expand' => '1' });
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);
        Assert.isFalse(String.isEmpty(resp.responseBody.toString()));
    }

    @IsTest
    static void testCollectionExpanded() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies', new Map<String, String>{ 'expand' => '1' });
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);
        Assert.isFalse(String.isEmpty(resp.responseBody.toString()));
    }

    @IsTest
    static void testNestedRouteCollection() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-2/locations');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);
        pp_RestRoute_TestMock.CompanyLocation[] respData = (pp_RestRoute_TestMock.CompanyLocation[]) JSON.deserialize(
                resp.responseBody.toString(),
                List<pp_RestRoute_TestMock.CompanyLocation>.class
        );

        Assert.areEqual(1, respData.size());
        Assert.areEqual('LA', respData[0].name);
    }

    @IsTest
    static void testAlternateRoute() {
        setupRestContext(RESOURCE_PATH, '/api/v1/employees', new Map<String, String>{ 'companyId' => 'c-2' });
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);
        pp_RestRoute_TestMock.CompanyEmployee[] respData = (pp_RestRoute_TestMock.CompanyEmployee[]) JSON.deserialize(
                resp.responseBody.toString(),
                List<pp_RestRoute_TestMock.CompanyEmployee>.class
        );

        Assert.areEqual(3, respData.size());
        Assert.areEqual('Iron Man', respData[0].name);
    }

    @IsTest
    static void testRouteCollectionFilter() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-2/employees', new Map<String, String>{ 'role' => 'CEO' });
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);
        pp_RestRoute_TestMock.CompanyEmployee[] respData = (pp_RestRoute_TestMock.CompanyEmployee[]) JSON.deserialize(
                resp.responseBody.toString(),
                List<pp_RestRoute_TestMock.CompanyEmployee>.class
        );

        Assert.areEqual(2, respData.size());
        Assert.areEqual('Iron Man', respData[0].name);
    }

    @IsTest
    static void testNestedRouteSingle() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-1/employees/e-2');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(200, resp.statusCode);
        pp_RestRoute_TestMock.CompanyEmployee respData = (pp_RestRoute_TestMock.CompanyEmployee) JSON.deserialize(
                resp.responseBody.toString(),
                pp_RestRoute_TestMock.CompanyEmployee.class
        );

        Assert.areEqual('e-2', respData.id);
    }

    @IsTest
    static void testNestedRouteSingleNotRelated() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-2/employees/e-2');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(404, resp.statusCode);
        pp_RestRoute.ErrorResponse[] respData = parseResponseErrors(resp);

        Assert.areEqual(1, respData.size());
        Assert.areEqual('NOT_FOUND', respData[0].errorCode);
    }

    @IsTest
    static void testNoRouteFound() {
        setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-2/asdf');
        RestResponse resp = RestContext.response;

        pp_RestRoute_TestMock.APIEntryRoute router = new pp_RestRoute_TestMock.APIEntryRoute();
        router.execute();

        Assert.areEqual(404, resp.statusCode);
        pp_RestRoute.ErrorResponse[] respData = parseResponseErrors(resp);

        Assert.areEqual(1, respData.size());
        Assert.areEqual('NOT_FOUND', respData[0].errorCode);
    }


    static void setupRestContext(String resourcePath, String requestUri) {
        setupRestContext(resourcePath, requestUri, 'GET', null, null);
    }

    //shorthand for GET + URL Params
    static void setupRestContext(String resourcePath, String requestUri, Map<String, String> query) {
        setupRestContext(resourcePath, requestUri, 'GET', query, null);
    }

    static void setupRestContext(String resourcePath, String requestUri, String httpMethod, Map<String, String> query, Blob body) {
        RestRequest req = new RestRequest();
        req.resourcePath = resourcePath;
        req.requestURI = requestUri;
        req.httpMethod = httpMethod;
        if (query != null) {
            req.params.putAll(query);
        }
        if (body != null) {
            req.requestBody = body;
        }

        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    static pp_RestRoute.ErrorResponse[] parseResponseErrors(RestResponse resp) {
        return (pp_RestRoute.ErrorResponse[]) JSON.deserialize(
                resp.responseBody.toString(),
                List<pp_RestRoute.ErrorResponse>.class
        );
    }
}