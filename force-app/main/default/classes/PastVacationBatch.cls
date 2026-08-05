global class PastVacationBatch implements Database.Batchable<sObject> {
    public static final String VACATION_PAST_STATUS = 'Past';
    public String query;

    global PastVacationBatch() {
        this.query = 'SELECT Id, Status__c FROM Vacation__c WHERE Status__c != :VACATION_PAST_STATUS AND Vacation_End_Date__c < TODAY';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Vacation__c> scope) {
        for (Vacation__c vac : scope) {
            vac.Status__c = VACATION_PAST_STATUS;
        }
        Database.update(scope, false);
    }

    global void finish(Database.BatchableContext BC) {

    }
}