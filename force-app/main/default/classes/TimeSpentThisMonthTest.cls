@IsTest
private class TimeSpentThisMonthTest {

	@IsTest
	static void timeSpentThisMonthTest() {
		Id contactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
		Test.startTest();
		Account account = new Account(Name = 'Propeller Plan');
		insert account;
		Project__c project = createProject(account.Id);
		insert project;
		Contact newContact = createContact(account.Id);
		newContact.RecordTypeId = contactRTId;
		insert newContact;
		Case newCase = createCase(newContact.Id, project.Id);
		insert newCase;
		Timecard__c timecard = new Timecard__c(
				Work_Date__c = Date.today(),
				Effort__c = 5.50,
				Case__c = newCase.Id,
				Person__c = newContact.Id,
				Description__c = 'Test Expense'
		);
		insert timecard;
		TimeSpentThisMonthResetScheduler sch = new TimeSpentThisMonthResetScheduler();
		sch.execute(null);
		Test.stopTest();
		List<Case> cases = new pp_Query('Case').selectField('Time_Spent_This_Month__c').byId(newCase.Id).run();
		System.assertEquals(0.00, cases[0].Time_Spent_This_Month__c);
	}

	static Contact createContact(Id accountId) {
		Contact contactVar = new Contact();
		contactVar.FirstName = 'TestFirstName';
		contactVar.LastName = 'TestLastName';
		contactVar.Email = 'TestFirstName_TestLastName' + System.now().getTime() + '@mailinator.com';
		contactVar.AccountId = accountId;
		return contactVar;
	}

	static Project__c createProject(Id accountId) {
		Project__c projectRecord = new Project__c();
		projectRecord.Name = 'Project';
		projectRecord.Account__c = accountId;
		projectRecord.Rate__c = 100;
		projectRecord.Commission_Rate__c = 1;
		return projectRecord;
	}

	static Case createCase(Id contactId, Id projectId) {
		Case caseRecord = new Case();
		caseRecord.Project__c = projectId;
		caseRecord.Subject = 'Subject';
		caseRecord.ContactId = contactId;
		caseRecord.Estimated_Time__c = 10;
		return caseRecord;
	}
}