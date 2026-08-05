/**
 * Created on 28.03.23.
 */

@IsTest
private class CountingExtraHoursSchedulerTest {

    @TestSetup
    static void setup() {
        Account account = new Account(Name = 'Propeller Plan', Billing_Country_Code__c = 'PL');
        insert account;

        Contact contact = new Contact(LastName = 'Test1', Inactive__c = false, AccountId = account.Id, Employer__c = account.Id);
        Contact contact2 = new Contact(LastName = 'Test2', Inactive__c = false, AccountId = account.Id);
        Contact contact3 = new Contact(LastName = 'Test3', Inactive__c = false, AccountId = account.Id, Workload__c = 'Part-time');
        insert new List<Contact> {contact, contact2, contact3};

        Vacation__c vac1 = new Vacation__c(
                Vacation_Start_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(2),
                Vacation_End_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(4),
                Vacation_Type__c = 'Personal Vacation',
                Status__c = 'Past',
                Employee__c = contact.Id
        );
        Vacation__c vac2 = new Vacation__c(
                Vacation_Start_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(5),
                Vacation_End_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(6),
                Vacation_Type__c = 'Holiday Season',
                Status__c = 'Past',
                Employee__c = contact.Id
        );
        Vacation__c vac3 = new Vacation__c(
                Vacation_Start_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(8),
                Vacation_End_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(8),
                Vacation_Type__c = 'Personal Vacation',
                Status__c = 'Planned',
                Employee__c = contact.Id
        );
        Vacation__c vac4 = new Vacation__c(
                Vacation_Start_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(10),
                Vacation_End_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(11),
                Vacation_Type__c = 'Personal Vacation',
                Status__c = 'Past',
                Employee__c = contact.Id
        );
        insert new List<Vacation__c> {vac1, vac2, vac3, vac4};

        Case testCase = new Case();
        insert testCase;

        Timecard__c timecard = new Timecard__c(Person__c = contact.Id, Effort__c = 180, Work_Date__c = System.today().addMonths(-1).toStartOfMonth(), Case__c = testCase.Id);
        Timecard__c timecard2 = new Timecard__c(Person__c = contact2.Id, Effort__c = 250, Work_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(1), Case__c = testCase.Id);
        Timecard__c timecard3 = new Timecard__c(Person__c = contact2.Id, Effort__c = 400, Work_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(2), Case__c = testCase.Id);
        Timecard__c timecard4 = new Timecard__c(Person__c = contact2.Id, Effort__c = 60, Work_Date__c = System.today().addMonths(-1).toStartOfMonth(), Case__c = testCase.Id);
        Timecard__c timecard5 = new Timecard__c(Person__c = contact3.Id, Effort__c = 120, Work_Date__c = System.today().addMonths(-1).toStartOfMonth(), Case__c = testCase.Id);
        insert new List<Timecard__c> {timecard, timecard2, timecard3, timecard4, timecard5};
    }

    @IsTest
    static void testCountingExtraHours() {
        new CountingExtraHoursScheduler().execute(null);
//        pp_T.expect(new pp_Query('Compensation__c').countQuery()).toBe(3);
    }
}