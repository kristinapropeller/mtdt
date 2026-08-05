/**
 * Created on 10/07/2024.
 */

@IsTest
private class slackbot_Compensations_Test {
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
        setting.Food_Compensation_Monthly__c = 100;
        setting.Sport_Compensation_Monthly__c = 100;
        setting.Health_Compensation_Yearly__c = 1000;
        upsert setting;
        insert new Contact(LastName = 'Test', Email = UserInfo.getUserEmail());
    }

    @IsTest
    static void testCreate() {
        Test.startTest();
        userSession.executeSlashCommand('/compensations', 'new', slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Add Compensation(s)', modal.getTitle());
        System.assertEquals(8, modal.getComponentCount());
        Test.stopTest();

        ((Slack.TestHarness.SelectInput) modal.getInputByLabel('Category').getComponent(Slack.TestHarness.SelectInput.class)).setValue('Food');
        ((Slack.TestHarness.TextInput) modal.getInputByLabel('Amount').getComponent(Slack.TestHarness.TextInput.class)).setValue('100');
        ((Slack.TestHarness.TextInput) modal.getInputByLabel('Description').getComponent(Slack.TestHarness.TextInput.class)).setValue('test 1');
        slackState.setBotClientMock(new BasicClientMock());
        modal.submit();
        slackState.clearBotClientMock();
        Assert.areEqual(1, [SELECT COUNT() FROM Compensation__c]);

        modal.getButtonByLabel('Add another compensation').click();
        modal = userSession.getTopModal();
        System.assertEquals(15, modal.getComponentCount());
    }

    @IsTest
    static void testUpdate() {
        Test.startTest();
        Compensation__c tesCompensation = new Compensation__c(
                Person__c = [SELECT Id FROM Contact LIMIT 1].Id,
                Date__c = Date.today(),
                Total__c = 100,
                Category__c = 'Food',
                Description__c = 'test'
        );
        insert tesCompensation;
        Test.stopTest();

        userSession.executeSlashCommand('/compensations', slackApp);
        System.assertEquals(1, userSession.getMessageCount());
        Slack.TestHarness.Message message = userSession.getMessages().get(0);
        System.assertEquals('Your recent unclosed compensations', message.getText());

        message.getButtonByLabel('Edit').click();
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Update Compensation', modal.getTitle());

        ((Slack.TestHarness.TextInput) modal.getInputByLabel('Amount').getComponent(Slack.TestHarness.TextInput.class)).setValue('200');
        slackState.setBotClientMock(new BasicClientMock());
        modal.submit();
        slackState.clearBotClientMock();
        Assert.areEqual(200, [SELECT Total__c FROM Compensation__c WHERE Id = :tesCompensation.Id].Total__c);
    }

    @IsTest
    static void testDelete() {
        Test.startTest();
        Compensation__c tesCompensation = new Compensation__c(
                Person__c = [SELECT Id FROM Contact LIMIT 1].Id,
                Date__c = Date.today(),
                Total__c = 100,
                Category__c = 'Food',
                Description__c = 'test'
        );
        insert tesCompensation;
        Test.stopTest();

        userSession.executeSlashCommand('/compensations', slackApp);
        System.assertEquals(1, userSession.getMessageCount());
        Slack.TestHarness.Message message = userSession.getMessages().get(0);
        System.assertEquals('Your recent unclosed compensations', message.getText());

        message.getButtonByLabel('Delete').click();
        Assert.areEqual(0, [SELECT COUNT() FROM Compensation__c]);

        message.getButtonByLabel('Add new compensation(s)').click();
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Add Compensation(s)', modal.getTitle());
    }


    class BasicClientMock extends Slack.BotClientMock {}
}