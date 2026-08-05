/**
 * Created by kirillreutski on 29.08.24.
 */

public without sharing class PPRSHttpPost implements IPPRSHttpPost{
    public HttpResponse doPost(String url, Map<String, String> headers, Object body) {
        return doRequest(url, 'POST', headers, body);
    }

    public HttpResponse doPut(String url, Map<String, String> headers, Object body) {
        return doRequest(url, 'PUT', headers, body);
    }

    public HttpResponse doRequest(String url, String method, Map<String, String> headers, Object body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        for (String h : headers.keySet()) {
            req.setHeader(h, headers.get(h));
        }
        Boolean isString = body instanceof String;
        req.setBody(isString ?  (String)body : JSON.serialize(body));
        Http http = new Http();
        HttpResponse response = null;
        if (Test.isRunningTest()) {
            response = new HttpResponse();
            response.setStatusCode(200);
        }
        else {
            response = http.send(req);
        }

        return response;
    }
}