/**
 * Created by kirillreutski on 2.09.24.
 */

public with sharing class PPRSCsvGenerator implements IPPRSCsvGenerator {
    private static final String defaultSeparator = ',';



    public String generate(List<SObject> records) {
        return generate(records, null, null,true);
    }
    public String generate(List<SObject> records, Set<String> headers, String separator) {
        return generate(records, headers, separator, true);
    }
    public String generate(List<SObject> records, Set<String> headers, String separator, Boolean addHeader) {
        if (records.size() == 0) return '';
        separator = separator == null ? defaultSeparator : separator;
        PPRS.getInstance().debug('generate: ' + records.size() + ', >' + separator + '<, ' + addHeader);
        Map<String, SObjectField> headerMap = records[0].getSObjectType().getDescribe().fields.getMap();

        if (headers == null) {

            headers = new Set<String>(headerMap.keySet());
        }

        List<String> rows = new List<String>();
        if (addHeader) rows.add(String.join(new List<String>(headers), separator));

        for (SObject so : records) {
            List<String> fieldValues = new List<String>();
            Set<String> populatedFieldsSet = new Set<String>(so.getPopulatedFieldsAsMap().keySet());

            for (String s : populatedFieldsSet) {
                populatedFieldsSet.add(s.toLowerCase());
            }
            for (String header : headers) {
                SObjectField headerField = headerMap.get(header);
                String finalValue;
                if (populatedFieldsSet.contains(header)) {
                    Object val = so.get(headerField);

                    if (val instanceof String) {
                        finalValue = '"' + String.valueOf(val) + '"';
                    }
                    else {
                        finalValue = String.valueOf(val);
                    }
                }
                else {
                    finalValue = '';
                }
                fieldValues.add(finalValue);
            }
            rows.add(String.join(fieldValues, separator));
        }
        return String.join(rows, '\n');
    }



}