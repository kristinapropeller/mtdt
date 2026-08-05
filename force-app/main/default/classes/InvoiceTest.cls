@IsTest
private class InvoiceTest {
    @IsTest
    static void invoiceTest() {
        Contact testContact = (Contact)pp_T.createSObject('Contact', new Map<String, Object>{ 'fields' => new List<String>{ 'Email', 'LastName' } });
        insert testContact;
        Account customer = (Account)pp_T.createSObject('Account', new Map<String, Object>{ 'fields' => new List<String>{ 'Name' } });
        insert customer;

        Bank__c testBank = (Bank__c)pp_T.createSObject('Bank__c', new Map<String, Object>{ 'fields' => new List<String>{ 'Name' } });
        insert testBank;
        Bank_Account__c testBAcc = new Bank_Account__c(Bank__c = testBank.Id);
        insert testBAcc;
        List<Invoice__c> invoices = new List<Invoice__c>();
        invoices.add(new Invoice__c());
        invoices.add(new Invoice__c(
                Account__c = customer.Id,
                Invoice_Number__c = 'test',
                Working_Period_End__c = System.today(),
        	    Billed_To__c = testContact.Id,
                Payee_Bank_Account__c = testBAcc.Id,
        	    Actual_Income__c = 100
        ));
        insert invoices;

        pp_T.expect(new pp_Query('Invoice__c').countQuery()).toEqual(2);
        List<Transaction__c> txList = new pp_Query('Transaction__c')
                .selectField('Income__c')
                .selectField('Description__c')
                .addConditionEq('Invoice__c', invoices[1].Id)
                .run();
        pp_T.expect(txList.size()).toEqual(1);
        pp_T.expect(txList[0].Income__c).toEqual(100);

        invoices[1].Actual_Income__c = 50;
        update invoices[1];
        txList = new pp_Query('Transaction__c')
                .selectField('Income__c')
                .addConditionEq('Invoice__c', invoices[1].Id)
                .run();
        pp_T.expect(txList.size()).toEqual(1);
        pp_T.expect(txList[0].Income__c).toEqual(50);

        delete invoices[1];
        pp_T.expect(new pp_Query('Transaction__c')
                .addConditionEq('Invoice__c', invoices[1].Id)
                .countQuery()).toEqual(0);
    }
}