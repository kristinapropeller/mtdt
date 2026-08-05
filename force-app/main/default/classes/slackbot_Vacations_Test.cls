/**
 * Created on 10/07/2024.
 */

@IsTest
private class slackbot_Vacations_Test {
    private static Slack.App slackApp;
    private static Slack.TestHarness testHarness;
    private static Slack.TestHarness.State slackState;
    private static Slack.TestHarness.UserSession userSession;

    static {
        // Set up test harness and user session
        slackApp = Slack.App.PropellerPlanSlackApp.get();
        testHarness = new Slack.TestHarness();
        slackState = testHarness.getNewSlackState();
        userSession = slackState.createUserSession();
    }

    @TestSetup
    static void setupTestData() {
        Setting__c setting = Setting__c.getOrgDefaults();
        setting.Personal_Vacations_Limit__c = 22;
        setting.Days_Off_Limit__c = 5;
        upsert setting;
        insert new Contact(LastName = 'Test', Email = UserInfo.getUserEmail());
    }

    @IsTest
    static void testCreate() {
        Test.startTest();
        userSession.executeSlashCommand('/vacations', 'new', slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Add Vacation', modal.getTitle());
        Test.stopTest();

        ((Slack.TestHarness.SelectInput) modal.getInputByLabel('Type').getComponent(Slack.TestHarness.SelectInput.class)).setValue('Personal Vacation');
        ((Slack.TestHarness.DatePicker) modal.getInputByLabel('Start Date').getComponent(Slack.TestHarness.DatePicker.class)).setValue(new pp_Moment(Date.today().addMonths(1)).format('yyyy-MM-dd'));
        ((Slack.TestHarness.DatePicker) modal.getInputByLabel('End Date').getComponent(Slack.TestHarness.DatePicker.class)).setValue(new pp_Moment(Date.today().addMonths(2)).format('yyyy-MM-dd'));
        slackState.setBotClientMock(new BasicClientMock());
        modal.submit();
        slackState.clearBotClientMock();
        Assert.areEqual(1, [SELECT COUNT() FROM Vacation__c]);
    }

    @IsTest
    static void testUpdate() {
        Test.startTest();
        Vacation__c tesVacation = new Vacation__c(
                Employee__c = [SELECT Id FROM Contact LIMIT 1].Id,
                Vacation_Start_Date__c = Date.today().addMonths(1),
                Vacation_End_Date__c = Date.today().addMonths(2),
                Vacation_Type__c = 'Personal Vacation'
        );
        insert tesVacation;
        Test.stopTest();

        userSession.executeSlashCommand('/vacations', slackApp);
        System.assertEquals(1, userSession.getMessageCount());
        Slack.TestHarness.Message message = userSession.getMessages().get(0);
        System.assertEquals('Your upcoming vacations', message.getText());

        message.getButtonByLabel('Edit').click();
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Update Vacation', modal.getTitle());

        ((Slack.TestHarness.SelectInput) modal.getInputByLabel('Status').getComponent(Slack.TestHarness.SelectInput.class)).setValue('Confirmed');
        slackState.setBotClientMock(new BasicClientMock());
        modal.submit();
        slackState.clearBotClientMock();
        Assert.areEqual('Confirmed', [SELECT Status__c FROM Vacation__c WHERE Id = :tesVacation.Id].Status__c);
    }

    @IsTest
    static void testDelete() {
        Test.startTest();
        Vacation__c tesVacation = new Vacation__c(
                Employee__c = [SELECT Id FROM Contact LIMIT 1].Id,
                Vacation_Start_Date__c = Date.today().addMonths(1),
                Vacation_End_Date__c = Date.today().addMonths(2),
                Vacation_Type__c = 'Personal Vacation'
        );
        insert tesVacation;
        Test.stopTest();

        userSession.executeSlashCommand('/vacations', slackApp);
        System.assertEquals(1, userSession.getMessageCount());
        Slack.TestHarness.Message message = userSession.getMessages().get(0);
        System.assertEquals('Your upcoming vacations', message.getText());

        message.getButtonByLabel('Delete').click();
        Assert.areEqual(0, [SELECT COUNT() FROM Vacation__c]);

        message.getButtonByLabel('Add new vacation').click();
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Add Vacation', modal.getTitle());
    }


    class BasicClientMock extends Slack.BotClientMock {}
}