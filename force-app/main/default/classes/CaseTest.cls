@IsTest
private class CaseTest {

    @TestSetup
    public static void setup(){
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        Project__c project1 = new Project__c(Name = 'Test Project1', Account__c = acc.Id);
        Project__c project2 = new Project__c(Name = 'Test Project2', Account__c = acc.Id);
        insert new List<Project__c>{project1, project2};
        Case case1_p1 = new Case(Subject = 'Case1_p1', Project__c = project1.Id);
        Case case2_p1 = new Case(Subject = 'Case2_p1', Project__c = project1.Id);
        Case case1_p2 = new Case(Subject = 'Case1_p2', Project__c = project2.Id);
        Case case2_p2 = new Case(Subject = 'Case2_p2', Project__c = project2.Id);
        insert new List<Case>{case1_p1, case2_p1, case1_p2, case2_p2};
        Date lastMonth = Date.today().addMonths(-1);
        Timecard__c card1_lastMonth = new Timecard__c(Case__c = case1_p1.Id, Effort__c = 13, Work_Date__c = lastMonth);
        Timecard__c card2_lastMonth = new Timecard__c(Case__c = case1_p2.Id, Effort__c = 17, Work_Date__c = lastMonth);
        insert new List<Timecard__c>{card1_lastMonth, card2_lastMonth};
    }

    @IsTest
    private static void updateTest(){
        List<Case> casesToUpdate = new List<Case>();
        List<Case> p1_cases = new pp_Query('Case').addConditionEq('Project__r.Name', 'Test Project1').run();
        List<Case> p2_cases = new pp_Query('Case').addConditionEq('Project__r.Name', 'Test Project2').run();
        for (Case p1case: p1_cases){
            p1case.Time_Spent_This_Month__c = 12;
        }
        for (Case p2case: p2_cases){
            p2case.Time_Spent_This_Month__c = 3;
        }
        casesToUpdate.addAll(p1_cases);
        casesToUpdate.addAll(p2_cases);
        Test.startTest();
        update casesToUpdate;
        Test.stopTest();
        Project__c project1 = (Project__c)new pp_Query('Project__c')
                .selectFields(new Set<String>{'Time_Spent__c', 'Time_Spent_This_Month__c'})
                .addConditionEq('Name', 'Test Project1')
                .fetch();
        Project__c project2 = (Project__c)new pp_Query('Project__c')
                .selectFields(new Set<String>{'Time_Spent__c', 'Time_Spent_This_Month__c'})
                .addConditionEq('Name', 'Test Project2')
                .fetch();
        pp_T.expect(project1.Time_Spent__c).toEqual(13);
        pp_T.expect(project1.Time_Spent_This_Month__c).toEqual(24);
        pp_T.expect(project2.Time_Spent__c).toEqual(17);
        pp_T.expect(project2.Time_Spent_This_Month__c).toEqual(6);
    }

    @IsTest
    private static void deleteTest(){
        Test.startTest();
        delete [SELECT Id FROM Timecard__c];
        delete [SELECT Id FROM Case];
        Test.stopTest();
        List<Project__c> projects = new pp_Query('Project__c')
                .selectFields(new Set<String>{'Time_Spent__c', 'Time_Spent_This_Month__c'})
                .run();
        for (Project__c project: projects){
            pp_T.expect(project.Time_Spent__c).toEqual(0);
            pp_T.expect(project.Time_Spent_This_Month__c).toEqual(0);
        }
    }
}