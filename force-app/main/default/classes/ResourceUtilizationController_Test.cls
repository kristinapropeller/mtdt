/**
 * Created on 27/03/2023.
 */

@IsTest
private class ResourceUtilizationController_Test {
    @IsTest
    static void testGettingUtilizationData() {
        Account acc = new Account(Name = 'Propeller Plan');
        insert acc;
        Contact con = new Contact(LastName = 'testLast', Email = 'qwerty@email.net', AccountId = acc.Id);
        insert con;

        Test.startTest();
        pp_T.expect(ResourceUtilizationController.getResourcesWithAssignments(System.today(), System.today().addDays(30))).never.toBeNull();
        Test.stopTest();
    }
}