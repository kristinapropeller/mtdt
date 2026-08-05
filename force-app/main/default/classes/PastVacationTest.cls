@isTest
private class PastVacationTest {
    static testMethod void pastVacationTest() {
        Test.startTest();

        Vacation__c vac = new Vacation__c(
        	Status__c = 'Confirmed',
        	Vacation_Start_Date__c = Date.today().addDays(-5),
        	Vacation_End_Date__c = Date.today().addDays(-2)
        );
        insert vac;

        PastVacationScheduler s = new PastVacationScheduler();
		s.execute(null);

        Test.stopTest();

        Vacation__c updateVac = (Vacation__c) new pp_Query('Vacation__c').selectField('Status__c').byId(vac.Id).fetch();
        System.assertEquals('Past', updateVac.Status__c);
    }
}