trigger CaseTrigger on Case (after insert, before insert, after update, before update, after delete, before delete) {
	if (pp_AutomationBypass__c.getInstance().Enable_Trigger_Bypass__c != true) {
		pp_Trap.getInstance().start();
	}
}