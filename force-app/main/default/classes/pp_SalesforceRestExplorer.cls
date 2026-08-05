/**
 * pp_SalesforceRestExplorer extends pp_RestExplorer to make REST API calls to Salesforce.
 *
 * It provides the following functionality:
 *
 * - setSessionId(String id) - Sets the session ID to use for authentication
 *
 * - setApiVersion(String version) - Sets the API version to use in requests
 *
 * - setService(String service) - Sets the endpoint URL based on the service name and API version
 *
 * Typical usage:
 * ```
 * pp_RestExplorer explorer = new pp_SalesforceRestExplorer('/tooling/query')
 *       .doGet()
 *       .setHeaders(myHeadersMap)
 *       .addParameter('q', 'SELECT Id,Name From MetadataContainer WHERE Name = \'MyMeta\'');
 *
 * String response = explorer.getResult();
 * ```
 */
public class pp_SalesforceRestExplorer extends pp_RestExplorer {
    private static final String DEFAULT_API_VERSION = '59.0';

    private static String sessionId;
    private static String apiVersion;

    public pp_SalesforceRestExplorer(String service) {
        setService(service);
    }

    public static void setSessionId(String id) {
        sessionId = id;
    }
    public static void setApiVersion(String version) {
        apiVersion = version;
    }

    public pp_RestExplorer setService(String service) {
        setBaseURL(Url.getOrgDomainUrl().toExternalForm());
        setEndpoint('/services/data/v'
                + (pp_SalesforceRestExplorer.apiVersion != null ? pp_SalesforceRestExplorer.apiVersion : pp_SalesforceRestExplorer.DEFAULT_API_VERSION)
                + '/' + service.removeStart('/'));
        return this;
    }

    public override pp_RestExplorer doPatch() {
        // https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_update_fields.htm
        doPost();
        addParameter('_HttpMethod', 'PATCH');
        return this;
    }

    public override HttpRequest getRequest() {
        setHeader('Authorization', 'Bearer ' + (pp_SalesforceRestExplorer.sessionId != null ? pp_SalesforceRestExplorer.sessionId : pp_SalesforceRestExplorer.getSessionId()));
        return super.getRequest();
    }

    private static String getSessionId() {
        return Test.isRunningTest() ? UserInfo.getSessionId() : Page.pp_SessionId.getContent().toString().replace('\n', '');
    }
}