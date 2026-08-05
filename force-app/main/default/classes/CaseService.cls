public without sharing class CaseService {
	public static void updateTimeSpentThisMonthOnCases(Map<Id, Decimal> caseId_time){
		List<Case> casesToUpdate = new pp_Query('Case')
				.selectField('Time_Spent_This_Month__c')
				.byId(caseId_time.keySet())
				.run();
		for (Case item : casesToUpdate) {
			item.Time_Spent_This_Month__c = caseId_time.get(item.Id);
		}
		Database.update(casesToUpdate);
	}
}