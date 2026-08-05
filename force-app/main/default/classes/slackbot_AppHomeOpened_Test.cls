/**
 * Created on 10/07/2024.
 */

@IsTest
private class slackbot_AppHomeOpened_Test {
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

    @IsTest
    static void testOpenAppHome() {
        userSession.executeEvent((Slack.Event) new Slack.AppHomeOpenedEvent(), slackApp);

        Assert.areEqual(2, userSession.getAppHome().getComponentCount());
    }
}