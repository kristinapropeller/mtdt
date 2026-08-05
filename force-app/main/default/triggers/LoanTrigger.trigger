/**
 * Created by kirillreutski on 5.12.24.
 */

trigger LoanTrigger on Loan__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            PPRS.getInstance().syncQueue(Trigger.new);
        }
    }
}