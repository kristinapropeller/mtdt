global class TimeSpentThisMonthBatch implements Database.Batchable<sObject> {

	public String query;

	global TimeSpentThisMonthBatch(){
		this.query = 'SELECT Time_Spent_This_Month__c, Project__c, Project__r.Time_Spent_This_Month__c FROM Case ' +
				'WHERE Time_Spent_This_Month__c != null AND Time_Spent_This_Month__c > 0';
	}

	global System.Iterable<sObject> start(Database.BatchableContext jobId) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext jobId, List<sObject> recordList) {
		Set<Id> projectIds = new Set<Id>();
		for(Case caseObject: (List<Case>)recordList){
			caseObject.Time_Spent_This_Month__c = 0;
			if(caseObject.Project__r.Time_Spent_This_Month__c != null
					&& caseObject.Project__r.Time_Spent_This_Month__c > 0) projectIds.add(caseObject.Project__c);
		}
		Database.update(recordList, false);
		if(!projectIds.isEmpty()) updateRelatedProjects(projectIds);
	}

	private static void updateRelatedProjects(Set<Id> projectIds){
		List<Project__c> projects = new pp_Query('Project__c').selectAllFields().byId(projectIds).run();
		for(Project__c project: projects){
			project.Time_Spent_This_Month__c = 0;
		}
		Database.update(projects);
	}

	global void finish(Database.BatchableContext jobId) {}
}