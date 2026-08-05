/**
 * pp_RestExplorer is a class for making REST API calls.
 *
 * @param baseURL The base URL for the API.
 * @param endpoint The endpoint for the API call.
 * @param headers Map of request headers to set. Default is {'Content-Type' => 'application/json'}.
 * @param parameters Map of query parameters to add to the request.
 * @param method The HTTP method for the request (GET, POST, PUT, PATCH, DELETE). Default is GET.
 * @param body The request body for POST, PUT, PATCH requests.
 * @param timeout Timeout in milliseconds for the call.
 *
 * Typical usage:
 * ```
 * pp_RestExplorer explorer = new pp_RestExplorer('https://api.example.com', 'v1/resources')
 *       .doPost()
 *       .setHeaders(myHeadersMap)
 *       .addParameter('limit', 100)
 *       .setBody(myJsonBody);
 *
 * String response = explorer.getResult();
 * ```
 */
public virtual class pp_RestExplorer {
    private String baseURL;
    private String endpoint;
    private Map<String, Object> headers = new Map<String, Object>{'Content-Type' => 'application/json'};
    private Map<String, Object> parameters = new Map<String, Object>();
    private String method = 'GET';
    private String body;
    private Integer timeout;

    public pp_RestExplorer() {}

    public pp_RestExplorer(String baseURL) {
        setBaseURL(baseURL);
    }
    public pp_RestExplorer(String baseURL, String endpoint) {
        setBaseURL(baseURL);
        setEndpoint(endpoint);
    }

    public pp_RestExplorer setBaseURL(String baseURL) {
        this.baseURL = baseURL;
        return this;
    }

    public pp_RestExplorer setEndpoint(String endpoint) {
        this.endpoint = endpoint;
        return this;
    }

    public pp_RestExplorer doGet() {
        this.method = 'GET';
        return this;
    }

    public pp_RestExplorer doPost() {
        this.method = 'POST';
        return this;
    }

    public pp_RestExplorer doPut() {
        this.method = 'PUT';
        return this;
    }

    public virtual pp_RestExplorer doPatch() {
        this.method = 'PATCH';
        return this;
    }

    public pp_RestExplorer doDelete() {
        this.method = 'DELETE';
        return this;
    }

    public pp_RestExplorer setHeader(String key, Object value) {
        this.headers.put(key, value);
        return this;
    }

    public pp_RestExplorer setHeaders(Map<String, Object> headers) {
        this.headers.putAll(headers);
        return this;
    }

    public pp_RestExplorer addParameter(String key, Object value) {
        this.parameters.put(key, value);
        return this;
    }

    public pp_RestExplorer addParameters(Map<String, Object> parameters) {
        this.parameters.putAll(parameters);
        return this;
    }

    public pp_RestExplorer setBody(String body) {
        this.body = body;
        return this;
    }

    public pp_RestExplorer setBody(Object body) {
        this.body = JSON.serialize(body);
        return this;
    }

    public pp_RestExplorer setTimeout(Integer timeout) {
        this.timeout = timeout;
        return this;
    }

    public virtual HttpRequest getRequest() {
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        for (String key : headers.keySet()) {
            req.setHeader(key, String.valueOf(this.headers.get(key)));
        }
        req.setEndpoint((baseURL != null ? baseURL : '') + (endpoint != null ? endpoint : '') + encodeParameters());
        if (body != null) req.setBody(body);
        if (timeout != null) req.setTimeout(timeout);

        return req;
    }

    public HttpResponse getResponse() {
        return new Http().send(getRequest());
    }

    public Object getBody(Boolean asBlob) {
        HttpResponse res = getResponse();
        Integer statusCode = res.getStatusCode();
        String result = res.getBody();

        if (statusCode >= 200 && statusCode < 300) {
            if (asBlob) return res.getBodyAsBlob();
            return result;
        } else {
            throw new ErrorResponseException(statusCode + ': ' + result, statusCode, result);
        }
    }
    public String getResult() {
        return (String) getBody(false);
    }

    public Object getResultAsJSON() {
        return JSON.deserializeUntyped(getResult());
    }

    public Blob getBlobResult() {
        return (Blob) getBody(true);
    }

    private String encodeParameters() {
        if (this.parameters.isEmpty()) return '';

        String result = '?';

        for (String key : this.parameters.keySet()) {
            result += EncodingUtil.urlEncode(key, 'UTF-8') + '=' +
                    EncodingUtil.urlEncode(String.valueOf(this.parameters.get(key)), 'UTF-8') + '&';
        }

        return result.removeEnd('&');
    }

    public static MockResponse mock(String body) {
        return new MockResponse(body);
    }


    public class MockResponse implements HttpCalloutMock {
        private String body;

        public MockResponse(String body) {
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(body);

            return res;
        }
    }


    public class ErrorResponseException extends Exception {
        private Integer statusCode {get; private set;}
        private String responseBody {get; private set;}

        public ErrorResponseException(String message, Integer statusCode, String responseBody) {
            this(message);
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
    }
}