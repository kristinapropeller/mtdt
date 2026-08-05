@IsTest
private class InvoiceGenerationSchedulerTest {
	@TestSetup
	static void setup() {
		Account internalAccountRecord = new Account(
				Name = 'Propeller Plan',
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId()
		);
		insert internalAccountRecord;
		Contact internalContactRecord = (Contact)pp_T.createSObject('Contact', new Map<String, Object>{ 'fields' => new List<String>{ 'FirstName', 'LastName' } });
		internalContactRecord.AccountId = internalAccountRecord.Id;
		internalContactRecord.Inactive__c = false;
		insert internalContactRecord;
		Account internalLegalEntityPLRecord = new Account(
				Name = 'Propeller Plan PL',
				Account_Legal_Name__c = 'Propeller Plan Sp. z o.o.',
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId()
		);
		insert internalLegalEntityPLRecord;
		Contact billingContact = (Contact)pp_T.createSObject('Contact', new Map<String, Object>{ 'fields' => new List<String>{ 'FirstName', 'LastName' } });
		billingContact.AccountId = internalLegalEntityPLRecord.Id;
		billingContact.Inactive__c = false;
		insert billingContact;
		Contact internalContactRecord2 = (Contact)pp_T.createSObject('Contact', new Map<String, Object>{ 'fields' => new List<String>{ 'FirstName', 'LastName' } });
		internalContactRecord2.AccountId = internalAccountRecord.Id;
		internalContactRecord2.Inactive__c = false;
		insert internalContactRecord2;
		Project__c internalProject = (Project__c)pp_T.createSObject('Project__c', new Map<String, Object>{ 'fields' => new List<String>{ 'Name' } });
		internalProject.Account__c = internalAccountRecord.Id;
		insert internalProject;
		Case internalCaseRecord = (Case)pp_T.createSObject('Case', new Map<String, Object>{ 'fields' => new List<String>{ 'Subject', 'Status' } });
		internalCaseRecord.Project__c = internalProject.Id;
		insert internalCaseRecord;
		Timecard__c internalTimecard = (Timecard__c)pp_T.createSObject('Timecard__c', new Map<String, Object>{ 'fields' => new List<String>{ 'Effort__c', 'Work_Date__c' } });
		internalTimecard.Person__c = internalContactRecord.Id;
		internalTimecard.Case__c = internalCaseRecord.Id;
		insert internalTimecard;

		Account accountRecord = (Account)pp_T.createSObject('Account', new Map<String, Object>{ 'fields' => new List<String>{ 'Name' } });
		insert accountRecord;
		Contact contactRecord = (Contact)pp_T.createSObject('Contact', new Map<String, Object>{ 'fields' => new List<String>{ 'FirstName', 'LastName' } });
		contactRecord.AccountId = accountRecord.Id;
		insert contactRecord;
		Project__c project = (Project__c)pp_T.createSObject('Project__c', new Map<String, Object>{ 'fields' => new List<String>{ 'Name', 'Rate__c' } });
		project.Account__c = accountRecord.Id;
		insert project;
		Case caseRecord = (Case)pp_T.createSObject('Case', new Map<String, Object>{ 'fields' => new List<String>{ 'Subject', 'Status' } });
		caseRecord.Project__c = project.Id;
		insert caseRecord;
		Timecard__c timecard = new Timecard__c(
				Person__c = internalContactRecord.Id,
				Case__c = caseRecord.Id,
				Effort__c = 1,
				Work_Date__c = Date.today().toStartOfMonth().addDays(-1)
		);
		insert timecard;

		Account accountRecord2 = (Account)pp_T.createSObject('Account', new Map<String, Object>{ 'fields' => new List<String>{ 'Name' } });
		insert accountRecord2;
		Contact contactRecord2 = (Contact)pp_T.createSObject('Contact', new Map<String, Object>{ 'fields' => new List<String>{ 'FirstName', 'LastName' } });
		contactRecord2.AccountId = accountRecord2.Id;
		insert contactRecord2;
		accountRecord2.Billing_Contact__c = contactRecord2.Id;
		accountRecord2.Contractor__c = billingContact.Id;
		update accountRecord2;
		Project__c project2 = (Project__c)pp_T.createSObject('Project__c', new Map<String, Object>{ 'fields' => new List<String>{ 'Name', 'Rate__c' } });
		project2.Account__c = accountRecord2.Id;
		project2.Project_Owner__c = internalContactRecord2.Id;
		insert project2;
		Case caseRecord2 = (Case)pp_T.createSObject('Case', new Map<String, Object>{ 'fields' => new List<String>{ 'Subject', 'Status' } });
		caseRecord2.Project__c = project2.Id;
		insert caseRecord2;
		Timecard__c timecard2 = new Timecard__c(
				Person__c = internalContactRecord2.Id,
				Case__c = caseRecord2.Id,
				Effort__c = 1,
				Work_Date__c = Date.today().toStartOfMonth().addDays(-1)
		);
		insert timecard2;
	}

	@IsTest
	static void scheduler_Should_NotGenerateInvoices_When_PrepareInvoices() {
		Test.startTest();
			InvoiceService.prepareInvoices();

		Test.stopTest();
		List<Invoice__c> invoices = new pp_Query('Invoice__c').selectAllFields().run();
		Map<Id, Invoice__c> invoiceMap = new Map<Id, Invoice__c>(invoices);
		InvoiceService.linkTimeCardsToInvoiceLineItems(invoiceMap.keySet());
		pp_T.expect(new pp_Query('Invoice__c').countQuery()).toEqual(2);
		pp_T.expect(new pp_Query('Invoice_Line_Item__c').countQuery()).toEqual(2);

		// dumb
		InvoiceService.generateInvoicesPDF(invoiceMap.keySet());
		InvoiceService.prepareMapping(invoices[0]);
	}

}