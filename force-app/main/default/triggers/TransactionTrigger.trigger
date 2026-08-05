trigger TransactionTrigger on Transaction__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        TransactionHandler.updateBankAccount(Trigger.new, Trigger.oldMap, Trigger.isDelete);
        if (Trigger.isUpdate || Trigger.isInsert) {
            PPRS.getInstance().syncQueue(Trigger.new);
        }
    }
}