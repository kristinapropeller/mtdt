public class NewTimecardController {
	@AuraEnabled
	public static Timecard__c getInstance() {
		return new Timecard__c(Work_Date__c = System.today());
	}

	@AuraEnabled
	public static Timecard__c saveTimecard(Timecard__c newTimecard) {
		insert newTimecard;
		return (Timecard__c) new pp_Query('Timecard__c').selectAllFields().byId(newTimecard.Id).fetch();
	}
}