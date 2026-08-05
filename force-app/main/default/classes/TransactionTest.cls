/**
 * Created by yarikmeshcheryakov on 20.02.23.
 */

@IsTest
private class TransactionTest {
    static testMethod void transactionTest() {
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

        PPRSSettings.settingsMdt.add(
            new PPRS_SObject_Setting__mdt(
                DeveloperName = 'Transaction__c',
                MasterLabel = 'Transaction__c',
                SObjectType__c = 'Transaction__c',
                DynamoDB_Table_Name__c = 'Transaction__c',
                DynamoDB_Partition_Key__c = 'partition_id'
            )
        );
        Transaction__c tr = new Transaction__c(
            Person__c = testContact.Id,
            Income__c = 100,
            Income_Bank_Account__c = bankAccount.Id,
            Description__c = 'TEST TEST',
            Date__c = Date.today()
        );
        insert tr;

        System.assertEquals(100, [SELECT Balance__c FROM Bank_Account__c WHERE Id =: bankAccount.Id].Balance__c);

        tr.Outcome__c = 50;
        tr.Outcome_Bank_Account__c = bankAccount.Id;
        update tr;
        System.assertEquals(50, [SELECT Balance__c FROM Bank_Account__c WHERE Id =: bankAccount.Id].Balance__c);

        delete tr;
        System.assertEquals(0, [SELECT Balance__c FROM Bank_Account__c WHERE Id =: bankAccount.Id].Balance__c);
    }
}