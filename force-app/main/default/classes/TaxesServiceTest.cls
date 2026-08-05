/**
 * Created by kirillreutski on 18.01.24.
 */

@IsTest
private class TaxesServiceTest {
    @IsTest
    static void testBehavior() {
        Account account1 = new Account(Taxation__c = 'Poland Spolka', Name = 'Propeller Plan', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId());
        Account account2 = new Account(Taxation__c = 'Poland IB', Name = 'Propeller Plan IB', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId());
        Account account3 = new Account(Taxation__c = 'Belarus Company', Name = 'Propeller Plan IB', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId());
        insert new List<Account>{account3, account2, account1};

        Bank__c bank1 = new Bank__c(Account__c = account1.Id, Name = 'asd1');
        Bank__c bank2 = new Bank__c(Account__c = account2.Id, Name = 'asd2');
        Bank__c bank3 = new Bank__c(Account__c = account3.Id, Name = 'asd3');
        insert new List<Bank__c>{bank1, bank2, bank3};
        Bank_Account__c ba1 = new Bank_Account__c(Bank__c = bank1.Id);
        Bank_Account__c ba2 = new Bank_Account__c(Bank__c = bank2.Id);
        Bank_Account__c ba3 = new Bank_Account__c(Bank__c = bank3.Id);
        insert new List<Bank_Account__c>{ba1, ba2, ba3};

        Contact testContact = (Contact)pp_T.createSObject('Contact', new Map<String, Object>{ 'fields' => new List<String>{ 'Email', 'LastName' } });
        insert testContact;
        Account customer = (Account)pp_T.createSObject('Account', new Map<String, Object>{ 'fields' => new List<String>{ 'Name' } });
        insert customer;

        List<Invoice__c> invoices = new List<Invoice__c>();
        invoices.add(new Invoice__c(
                Account__c = customer.Id,
                Invoice_Number__c = 'FV/' + System.today().month(),

                Working_Period_End__c = System.today(),
                Billed_To__c = testContact.Id,
                Payee_Bank_Account__c = ba1.Id,
                Actual_Income__c = 100,
                Status__c = 'Paid'

        ));

        invoices.add(new Invoice__c(
                Account__c = customer.Id,
                Invoice_Number__c = 'FV/' + System.today().month(),

                Working_Period_End__c = System.today(),
                Billed_To__c = testContact.Id,
                Payee_Bank_Account__c = ba2.Id,
                Actual_Income__c = 100,
                Status__c = 'Paid'

        ));

        invoices.add(new Invoice__c(
                Account__c = customer.Id,
                Invoice_Number__c = 'FV/' + System.today().month(),

                Working_Period_End__c = System.today(),
                Billed_To__c = testContact.Id,
                Payee_Bank_Account__c = ba3.Id,
                Actual_Income__c = 100,
                Status__c = 'Paid'

        ));
        insert invoices;

        Transaction__c tr1 = new Transaction__c(
                Person__c = testContact.Id,
                Outcome__c = 50,
                Income_Bank_Account__c = ba1.Id,
                Description__c = 'TEST TEST',
                Outcome_Category__c = 'Tax',
                Date__c = Date.today(),
                Outcome_Bank_Account__c = ba1.Id
        );
        Transaction__c tr4 = new Transaction__c(
                Person__c = testContact.Id,
                Outcome__c = 50,
//                Income_Bank_Account__c = ba1.Id,
                Description__c = 'TEST TEST',
                Outcome_Category__c = 'Tax',
                Date__c = Date.today(),
                Outcome_Bank_Account__c = ba1.Id
        );
        Transaction__c tr2 = new Transaction__c(
                Person__c = testContact.Id,
                Outcome__c = 50,
                Income_Bank_Account__c = ba1.Id,
                Description__c = 'TEST TEST',
                Outcome_Category__c = 'Tax',
                Tax_Category__c = 'Income',
                Date__c = Date.today(),
                Outcome_Bank_Account__c = ba2.Id
        );

        Transaction__c tr3 = new Transaction__c(
                Person__c = testContact.Id,
                Outcome__c = 50,
                Income_Bank_Account__c = ba2.Id,
                Description__c = 'TEST TEST',
                Outcome_Category__c = 'Tax',
                Tax_Category__c = 'Income',
                Date__c = Date.today(),
                Outcome_Bank_Account__c = ba3.Id
        );
        insert new List<Transaction__c>{tr1, tr2, tr3, tr4};

        //TaxesService.populateTaxData(System.today().year());
        Test.startTest();
        EntityEffectivenessService.schedule();
        //(new EntityEffectivenessService()).execute(null);
        Test.stopTest();
    }
}