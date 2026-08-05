/**
 * Created on 19.04.23.
 */

public class newCompensationsController {

    @AuraEnabled
    public static Map<String, String> getPicklistValues(String objectName, String fieldName) {
        Map<String, String> options = new Map<String, String>();
        DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : picklistValues) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

    @AuraEnabled
    public static void createCompensations(List<Compensation__c> compensations) {
        insert compensations;
    }
}