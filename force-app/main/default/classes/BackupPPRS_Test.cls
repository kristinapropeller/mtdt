/**
 * Created by kirillreutski on 5.12.24.
 */

@IsTest
private class BackupPPRS_Test {
    @IsTest
    static void compensations() {

        PPRSSettings.settingsMdt.add(
                new PPRS_SObject_Setting__mdt(
                        DeveloperName = 'Transaction__c',
                        MasterLabel = 'Transaction__c',
                        SObjectType__c = 'Transaction__c',
                        DynamoDB_Table_Name__c = 'Transaction__c',
                        DynamoDB_Partition_Key__c = 'partition_id'
                )
        );
        PPRSSettings.settingsMdt.add(
                new PPRS_SObject_Setting__mdt(
                        DeveloperName = 'Compensation__c',
                        MasterLabel = 'Compensation__c',
                        SObjectType__c = 'Compensation__c',
                        DynamoDB_Table_Name__c = 'Compensation__c',
                        DynamoDB_Partition_Key__c = 'partition_id'
                )
        );
        PPRSSettings.settingsMdt.add(
                new PPRS_SObject_Setting__mdt(
                        DeveloperName = 'Loan__c',
                        MasterLabel = 'Loan__c',
                        SObjectType__c = 'Loan__c',
                        DynamoDB_Table_Name__c = 'Loan__c',
                        DynamoDB_Partition_Key__c = 'partition_id'
                )
        );


        Account accountRecord = new Account(Name = 'Propeller Plan');
        accountRecord.RecordTypeId =
                Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        insert accountRecord;

        Contact testContact = new Contact(
                LastName = 'Last Name',
                Email = 'last.name@email.com',
                AccountId = accountRecord.Id
        );
        insert testContact;

        Bank__c bank = new Bank__c(
                Account__c = accountRecord.Id,
                Name = 'Test Bank'
        );
        insert bank;

        Bank_Account__c bankAccount = new Bank_Account__c(
                Name = 'Test Bank USD',
                Bank__c = bank.Id
        );
        insert bankAccount;

        Transaction__c tr = new Transaction__c(
                Person__c = testContact.Id,
                Income__c = 100,
                Income_Bank_Account__c = bankAccount.Id,
                Description__c = 'TEST TEST',
                Date__c = Date.today()
        );
        insert tr;

        Compensation__c comp = new Compensation__c(
                Person__c = testContact.Id,
                Total__c = 100,
                Category__c = 'Tax',
                Description__c = 'TEST TEST',
                Date__c = Date.today()
        );
        insert comp;

        Loan__c loan = new Loan__c(
                Person__c = testContact.Id,
                Total__c = 100,
                Description__c = 'TEST TEST',
                Date__c = Date.today(),
                Bank_Account__c = bankAccount.Id,
                Billing_Person__c = testContact.Id
        );
        insert loan;
    }
}