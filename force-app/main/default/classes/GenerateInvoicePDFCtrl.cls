public class GenerateInvoicePDFCtrl {
	@AuraEnabled
	public static void generatePDF(Id invoiceId) {
		if (invoiceId == null) {
			throw new AuraHandledException('Unable to generate PDF');
		}
		InvoiceService.generateInvoicesPDF(new Set<Id>{invoiceId});
	}
}