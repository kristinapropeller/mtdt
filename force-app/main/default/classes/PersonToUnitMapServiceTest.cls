/**
 * Created by kirillreutski on 24.03.24.
 */

@IsTest
private class PersonToUnitMapServiceTest {
    @IsTest
    static void testBehavior() {
        Account internalAccountRecord = new Account(
                Name = 'Propeller Plan',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId(),
                Taxation__c = 'Poland IB'
        );
        insert internalAccountRecord;
        Contact internalContactRecord = new Contact(
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId(),
                LastName = 'Tester',
                Inactive__c = false,
                AccountId = internalAccountRecord.Id,
                Unit__c = internalAccountRecord.Id
        );

        insert internalContactRecord;
        Account internalLegalEntityPLRecord = new Account(
                Name = 'Propeller Plan PL',
                Account_Legal_Name__c = 'Propeller Plan Sp. z o.o.',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId()
        );
        insert internalLegalEntityPLRecord;

        PersonToUnitMapService.createSnapshot(System.today().year(), null);
        System.assert([SELECT Id FROM Person_to_Unit_Mapping_History__c].size() > 0);
        System.assert(PersonToUnitMapService.getAccountId(internalContactRecord.Id, System.today().year(), System.today().month()) == internalAccountRecord.Id);
        System.assert(PersonToUnitMapService.getPersonsInUnit(internalAccountRecord.Id, System.today().year(), System.today().month()) == 1);
        System.assert(PersonToUnitMapService.getPersonsByUnit(System.today().year(), System.today().month()).size() > 0);
        System.assert(PersonToUnitMapService.personsAmount(System.today().year(), System.today().month()) > 0);
    }
}