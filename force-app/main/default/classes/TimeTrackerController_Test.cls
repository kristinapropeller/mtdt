/**
 * Created on 02/01/2023.
 */

@IsTest
private class TimeTrackerController_Test {
    @TestSetup
    static void testData() {
        Account acc = new Account(Name = 'Propeller Plan');
        insert acc;
        Contact con = new Contact(
                LastName = (String)pp_T.create('Name'),
                AccountId = acc.Id
        );
        insert con;
        Project__c proj = (Project__c)pp_T.createSObject('Project__c', new Map<String, Object>{ 'fields' => new List<String>{ 'Name', 'Account__c' }});
        insert proj;
        Case c1 = (Case)pp_T.createSObject('Case', new Map<String, Object>{ 'fields' => new List<String>{ 'Description', 'Project__c', 'ContactId' }});
        c1.Subject = 'Foo Bar';
        insert c1;
        System.debug(c1);
        Case c2 = (Case)pp_T.createSObject('Case', new Map<String, Object>{ 'fields' => new List<String>{ 'Description', 'Project__c', 'ContactId' }});
        insert c2;
    }

    @IsTest
    static void testWorkingWithLogs() {
        List<LookupSearchResult> cases = CaseLookupSearch.getRecentlyViewed();
        cases = CaseLookupSearch.search('foo', null);
        if (cases.isEmpty()) cases.add(new LookupSearchResult(new pp_Query('Case').setLimit(1).run().get(0).Id, 'Case', '', '', ''));
        pp_T.expect(cases.size()).toBeGreaterThan(0);

        List<Map<String, Object>> personOptions = TimeTrackerController.getPersonOptions(null);
        pp_T.expect(personOptions.size()).toEqual(1);
        Test.startTest();
        Timecard__c tc1 = (Timecard__c)pp_T.createSObject('Timecard__c', new Map<String, Object>{ 'fields' => new List<String>{ 'Description__c' }});
        tc1.Case__c = cases[0].getId();
        tc1.Work_Date__c = System.today();
        tc1.Effort__c = 8;
        Timecard__c tc2 = (Timecard__c)pp_T.createSObject('Timecard__c', new Map<String, Object>{ 'fields' => new List<String>{ 'Description__c' }});
        tc2.Case__c = cases[0].getId();
        tc2.Work_Date__c = System.today().addDays(1);
        tc2.Effort__c = 8;
        List<Timecard__c> timecards = TimeTrackerController.upsertLogs(
                JSON.serialize(new List<Timecard__c>{ tc1, tc2 }),
                (String)personOptions[0].get('value')
        );
        pp_T.expect(timecards[0].Id).never.toBeNull();

        List<Map<String, Object>> logs = TimeTrackerController.getLogsByTaskAndDate((String)personOptions[0].get('value'), timecards[0].Work_Date__c, null);
        pp_T.expect(logs.size()).toEqual(1);

        timecards[0].Effort__c = 0;
        timecards = TimeTrackerController.upsertLogs(
                JSON.serialize(timecards),
                (String)personOptions[0].get('value')
        );
        pp_T.expect(timecards.size()).toEqual(1);

        TimeTrackerController.deleteLogs((String)personOptions[0].get('value'), cases[0].getId(), timecards[0].Work_Date__c, null);
        pp_T.expect([SELECT COUNT() FROM Timecard__c]).toEqual(0);
        Test.stopTest();
    }
}