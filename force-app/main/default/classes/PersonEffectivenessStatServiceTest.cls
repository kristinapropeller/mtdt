/**
 * Created by kirillreutski on 24.03.24.
 */

@IsTest
private class PersonEffectivenessStatServiceTest {
    @IsTest
    static void testBehavior() {
        Account account1 = new Account(Taxation__c = 'Poland Spolka', Name = 'Propeller Plan', Billing_Country_Code__c = 'PL', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId());
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

        Contact testContact1 = (Contact)pp_T.createSObject('Contact', new Map<String, Object>{ 'fields' => new List<String>{ 'Email', 'LastName' } });
        testContact1.AccountId = account1.Id;
        testContact1.Inactive__c = false;
        testContact1.Employer__c = account1.Id;

        Contact testContact2 = (Contact)pp_T.createSObject('Contact', new Map<String, Object>{ 'fields' => new List<String>{ 'Email', 'LastName' } });
        testContact2.AccountId = account1.Id;
        testContact2.Inactive__c = false;
        testContact2.Employer__c = account3.Id;
        insert new List<Contact>{testContact1, testContact2};
        System.debug('Inactive__c check: ' + [SELECT Id, Inactive__c FROM Contact]);
        Account customer = (Account)pp_T.createSObject('Account', new Map<String, Object>{ 'fields' => new List<String>{ 'Name' } });
        insert customer;

        List<Invoice__c> invoices = new List<Invoice__c>();
        invoices.add(new Invoice__c(
                Account__c = customer.Id,
                Invoice_Number__c = 'FV/' + System.today().month(),

                Working_Period_End__c = System.today(),
                Billed_To__c = testContact1.Id,
                Payee_Bank_Account__c = ba1.Id,
                Actual_Income__c = 100,
                Status__c = 'Paid'

        ));

        invoices.add(new Invoice__c(
                Account__c = customer.Id,
                Invoice_Number__c = 'FV/' + System.today().month(),

                Working_Period_End__c = System.today(),
                Billed_To__c = testContact1.Id,
                Payee_Bank_Account__c = ba2.Id,
                Actual_Income__c = 100,
                Status__c = 'Paid'

        ));

        invoices.add(new Invoice__c(
                Account__c = customer.Id,
                Invoice_Number__c = 'FV/' + System.today().month(),

                Working_Period_End__c = System.today(),
                Billed_To__c = testContact1.Id,
                Payee_Bank_Account__c = ba3.Id,
                Actual_Income__c = 100,
                Status__c = 'Paid'

        ));
        insert invoices;

        Transaction__c tr1 = new Transaction__c(
                Person__c = testContact1.Id,
                Outcome__c = 50,
                Income_Bank_Account__c = ba1.Id,
                Description__c = 'TEST TEST',
                Outcome_Category__c = 'Tax',
                Date__c = Date.today(),
                Outcome_Bank_Account__c = ba1.Id
        );
        Transaction__c tr4 = new Transaction__c(
                Person__c = testContact1.Id,
                Outcome__c = 50,
//                Income_Bank_Account__c = ba1.Id,
                Description__c = 'TEST TEST',
                Outcome_Category__c = 'Tax',
                Date__c = Date.today(),
                Outcome_Bank_Account__c = ba1.Id
        );
        Transaction__c tr2 = new Transaction__c(
                Person__c = testContact1.Id,
                Outcome__c = 50,
                Income_Bank_Account__c = ba1.Id,
                Description__c = 'TEST TEST',
                Outcome_Category__c = 'Tax',
                Tax_Category__c = 'Income',
                Date__c = Date.today(),
                Outcome_Bank_Account__c = ba2.Id
        );

        Transaction__c tr3 = new Transaction__c(
                Person__c = testContact2.Id,
                Outcome__c = 50,
                Income_Bank_Account__c = ba2.Id,
                Description__c = 'TEST TEST',
                Outcome_Category__c = 'Tax',
                Tax_Category__c = 'Income',
                Date__c = Date.today(),
                Outcome_Bank_Account__c = ba3.Id
        );

        Transaction__c tr5 = new Transaction__c(
                Person__c = testContact2.Id,
                Outcome__c = 50,
                Income_Bank_Account__c = ba2.Id,
                Description__c = 'TEST TEST',
                Outcome_Category__c = 'Salary',
                Date__c = Date.today(),
                Outcome_Bank_Account__c = ba3.Id
        );
        insert new List<Transaction__c>{tr1, tr2, tr3, tr4, tr5};

        Project__c project = new Project__c();
        project.Name = 'Project';
        project.Account__c = account1.Id;
        project.Rate__c = 100;
        project.Commission_Rate__c = 1;
        insert project;
        Case newCase = new Case();
        newCase.Project__c = project.Id;
        newCase.Subject = 'Subject';
        newCase.ContactId = testContact1.Id;
        newCase.Estimated_Time__c = 10;
        insert newCase;

        Timecard__c timecard1 = new Timecard__c(
                Work_Date__c = Date.today(),
                Effort__c = 5.50,
                Case__c = newCase.Id,
                Person__c = testContact1.Id
        );

        Timecard__c timecard2 = new Timecard__c(
                Work_Date__c = Date.today(),
                Effort__c = 5.50,
                Case__c = newCase.Id,
                Person__c = testContact2.Id
        );
        insert timecard1;
        insert timecard2;
        //insert new List<Timecard__c>{timecard1, timecard2};


        Map<Id, Invoice__c> invoiceMap = new Map<Id, Invoice__c>([SELECT Id FROM Invoice__c WHERE CreatedDate = THIS_YEAR]);

        InvoiceService.linkTimeCardsToInvoiceLineItems(invoiceMap.keySet());
        PersonEffectivenessStatService.updateRecords(new Set<Id>{testContact1.Id, testContact2.Id}, null);
    }

    @IsTest
    static void getMonthIndex(){
        System.assert(PersonEffectivenessStatService.getMonthIndex('nope') == 12);
    }
}