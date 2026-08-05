/**
 * Created on 05/07/2024.
 */

public without sharing class slackbot_SaveVacationActionDispatcher extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        return Slack.ActionHandler.clearModal(new Handler(parameters, context));
    }

    @Future(Callout=true)
    public static void postSingleVacationMessage(String parametersJSON) {
        Map<String, Object> parameters = (Map<String, Object>) JSON.deserializeUntyped(parametersJSON);
        Slack.App app = Slack.App.PropellerPlanSlackApp.get();
        Slack.BotClient client = app.getBotClientForTeam((String) parameters.get('teamId'));
        Slack.ViewReference viewReference = Slack.View.vacation.get();
        viewReference.setParameter('header', 'Your vacation has been ' + (parameters.get('id') != null ? 'updated' : 'added'));
        viewReference.setParameter('vacation', (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(parameters.get('vacation'))));

        Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.Builder()
                .channel((String) parameters.get('channel'))
                .viewReference(viewReference)
                .build();

        Slack.ChatPostMessageResponse response = client.chatPostMessage(req);
        if (response.getError() != null) {
            if (!Test.isRunningTest()) System.debug(response.getResponseMetadata());
            System.debug(response.getError());
        } else {
            System.debug('success');
        }
    }

    public class Handler implements Slack.RunnableHandler {

        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler (Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public void run () {
            Map<String, Object> formData = context.getFormData();
            Vacation__c vacation = new Vacation__c(
                    Vacation_Type__c = String.valueOf(formData.get('type')),
                    Status__c = String.valueOf(formData.get('status')),
                    Vacation_Start_Date__c = new pp_Moment(String.valueOf(formData.get('startDate')), 'yyyy-MM-dd').toDate(),
                    Vacation_End_Date__c = new pp_Moment(String.valueOf(formData.get('endDate')), 'yyyy-MM-dd').toDate()
            );
            if (parameters.get('id') != null) {
                vacation.Id = String.valueOf(parameters.get('id'));
            } else {
                vacation.Employee__c = findContactByUserEmailOrOwner();
            }
            upsert vacation;
            postSingleVacationMessage(JSON.serialize(new Map<String, Object>{
                    'teamId' => context.getTeamId(),
                    'channel' => context.getChannelId() ?? String.valueOf(parameters.get('channel')),
                    'id' => parameters.get('id'),
                    'vacation' => new slackbot_VacationsCommandDispatcher.Vacation(vacation)
            }));
        }

        private Id findContactByUserEmailOrOwner() {
            Contact c = (Contact) new pp_Query('Contact')
                    .selectField('Id')
                    .addCondition(pp_Query.doOr(
                            pp_Query.conditionEq('Email', UserInfo.getUserEmail()),
                            pp_Query.conditionEq('OwnerId', UserInfo.getUserId())
                    ))
                    .addConditionEq('Inactive__c', false)
                    .fetch();
            return c != null ? c.Id : null;
        }
    }
}