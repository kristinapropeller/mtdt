/**
 * Created by kirillreutski on 29.08.24.
 */

public interface IPPRSHttpPost {
    HttpResponse doPost(String url, Map<String, String> headers, Object body);
    HttpResponse doPut(String url, Map<String, String> headers, Object body);
}