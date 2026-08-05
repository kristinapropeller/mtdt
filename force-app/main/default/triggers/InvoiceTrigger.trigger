trigger InvoiceTrigger on Invoice__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (pp_AutomationBypass__c.getInstance().Enable_Trigger_Bypass__c != true) {
        pp_Trap.getInstance().start();
    }
}