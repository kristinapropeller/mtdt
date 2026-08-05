/**
 * Created on 30/11/2022.
 */

@IsTest
private class ProjectTrigger_Test {
    @TestSetup
    static void testData() {
        Project__c project = (Project__c)pp_T.createSObject('Project__c', new Map<String, Object>{ 'fields' => new List<String>{ 'Name' } });
        insert project;
    }

    @IsTest
    static void testAddingProjectKeyOnInsert() {
        Project__c project = (Project__c)new pp_Query('Project__c').fetch();

        project.Project_Key__c = 'TST';
        project.sysCaseCounter__c = 1;
        update project;

        Test.startTest();
        Case case1 = (Case)pp_T.createSObject('Case', new Map<String, Object>{ 'fields' => new List<String>{ 'Subject' } });
        case1.Project__c = project.Id;
        insert case1;
        Test.stopTest();

        pp_T.expect([SELECT sysCaseCounter__c FROM Project__c WHERE Id = :project.Id].sysCaseCounter__c).toEqual(2);
        pp_T.expect([SELECT Internal_System_ID__c FROM Case WHERE Id = :case1.Id].Internal_System_ID__c).never.toBeNull();
    }

    @IsTest
    static void testAddingProjectKeyOnUpdate() {
        Project__c project = (Project__c)new pp_Query('Project__c').fetch();
        Case case1 = (Case)pp_T.createSObject('Case', new Map<String, Object>{ 'fields' => new List<String>{ 'Subject' } });
        case1.Project__c = project.Id;
        insert case1;
        Case case2 = (Case)pp_T.createSObject('Case', new Map<String, Object>{ 'fields' => new List<String>{ 'Subject' } });
        case2.Project__c = project.Id;
        insert case2;

        Test.startTest();
        project.Project_Key__c = 'TST';
        update project;

        pp_T.expect([SELECT sysCaseCounter__c FROM Project__c WHERE Id = :project.Id].sysCaseCounter__c).toEqual(2);
        pp_T.expect([SELECT Internal_System_ID__c FROM Case WHERE Id = :case1.Id].Internal_System_ID__c).never.toBeNull();
        pp_T.expect([SELECT Internal_System_ID__c FROM Case WHERE Id = :case2.Id].Internal_System_ID__c).never.toBeNull();
        Test.stopTest();
    }
}