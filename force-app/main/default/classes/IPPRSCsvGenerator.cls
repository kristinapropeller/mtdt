/**
 * Created by kirillreutski on 2.09.24.
 */

public interface IPPRSCsvGenerator {
    String generate(List<SObject> records);
    String generate(List<SObject> records, Set<String> headers, String separator);
    String generate(List<SObject> records, Set<String> headers, String separator, Boolean addHeader);
}