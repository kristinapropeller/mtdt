/**
 * Created on 30.03.23.
 */

public class NewTransactionController {

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
    public static void createTransactions(List<Transaction__c> transactions) {
        insert transactions;
    }
}