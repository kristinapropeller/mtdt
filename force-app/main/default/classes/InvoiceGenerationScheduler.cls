public class InvoiceGenerationScheduler implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {
	private Set<Id> invoiceIds;

	public InvoiceGenerationScheduler(Set<Id> invoiceIds) {
		this.invoiceIds = invoiceIds;
	}

	public void execute(System.SchedulableContext context) {
		InvoiceService.prepareInvoices();
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(new pp_Query('Invoice__c')
				.selectAllFields()
				.selectAllFields('Account__r')
				.selectAllFields('Billed_To__r')
				.selectAllFields('Billed_By__r')
				.selectAllFields('Payee_Bank_Account__r')
				.selectAllFields('Payee_Bank_Account__r.Bank__r')
				.selectAllFields('Payee_Bank_Account__r.Bank__r.Account__r')
				.addSubquery(
						pp_Query.subquery('Invoice_Line_Items__r')
								.selectAllFields()
				)
				.byId(invoiceIds)
				.toQueryString()
				.replace(' billed_to__r.individualid,', '').replace(' billed_by__r.individualid,', '')					// Workaround for individualid
				.replace(' billed_to__r.pronouns,', '').replace(' billed_by__r.pronouns,', '')							// Workaround for pronouns
				.replace(' billed_to__r.genderidentity,', '').replace(' billed_by__r.genderidentity,', '')				// Workaround for genderidentity
				.replace(' billed_to__r.ispriorityrecord,', '').replace(' billed_by__r.ispriorityrecord,', '')			// Workaround for ispriorityrecord
				.replace(' account__r.tier,', '').replace(' payee_bank_account__r.bank__r.account__r.tier,', ''));		// Workaround for tier
	}

	public void execute(Database.BatchableContext BC, List<SObject> scope) {
		Map<Id, ContentVersion> contentVersionByInvoice = new Map<Id, ContentVersion>();

		for (Invoice__c inv: (List<Invoice__c>) scope) {
			try {
				if (!Test.isRunningTest()) PDFMonkeyConnector.ResponseDocument result = PDFMonkeyConnector.createDocument('8E339346-F647-4FE3-A986-7FAD1BD71F37', inv.Invoice_Number__c.replaceAll('/', '_') + '.pdf', inv.Id, InvoiceService.prepareMapping(inv));
			} catch (pp_RestExplorer.ErrorResponseException ex) {
				pp_R.debug.run(ex.getMessage());
			}

			if (String.isEmpty(inv.Account__r.Monthly_Report_ID__c)) continue;

			Blob invoiceReport = null;
			ContentVersion contentVersionRecord = new ContentVersion();
			if (Test.isRunningTest()) {
				invoiceReport = Blob.valueOf('0');
			} else {
				invoiceReport = new pp_SalesforceRestExplorer('analytics/reports/' + inv.Account__r.Monthly_Report_ID__c)
						.doGet()
						.setHeader('Accept', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
						.getBlobResult();
			}
			contentVersionRecord.Title = inv.Account__r.Name + ' - Propeller Plan - ' + new pp_Moment(inv.Working_Period_End__c).format('MMyyyy');
			if (invoiceReport != null) {
				contentVersionRecord.VersionData = invoiceReport;
				contentVersionRecord.PathOnClient = '/' + contentVersionRecord.Title + '.xlsx';
				contentVersionRecord.IsMajorVersion = true;
				contentVersionByInvoice.put(inv.Id, contentVersionRecord);
			}
		}
		insert contentVersionByInvoice.values();
		Map<Id, ContentVersion> selectedContentVersions = new Map<Id, ContentVersion>(
				(List<ContentVersion>)new pp_Query('ContentVersion')
						.selectFields(new Set<String>{'Id', 'ContentDocumentId'})
						.byId(new Map<Id, ContentVersion>(contentVersionByInvoice.values()).keySet())
						.run()
		);

		List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
		for (Id invoiceId: contentVersionByInvoice.keySet()) {
			if (!selectedContentVersions.containsKey(contentVersionByInvoice.get(invoiceId).Id)) {
				continue;
			}
			ContentVersion contentVersionRecord = selectedContentVersions.get(contentVersionByInvoice.get(invoiceId).Id);
			ContentDocumentLink contentDocumentLinkRecord = new ContentDocumentLink();
			contentDocumentLinkRecord.LinkedEntityId = invoiceId;
			contentDocumentLinkRecord.ShareType = 'V';
			contentDocumentLinkRecord.ContentDocumentId = contentVersionRecord.ContentDocumentId;
			contentDocumentLinks.add(contentDocumentLinkRecord);
		}
		insert contentDocumentLinks;
	}

	public void finish(Database.BatchableContext BC) {
	}
}