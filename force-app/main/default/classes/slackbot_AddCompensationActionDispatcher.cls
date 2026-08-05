/**
 * Created on 04/07/2024.
 */

public class slackbot_AddCompensationActionDispatcher extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        return Slack.ActionHandler.clearModal(new Handler(parameters, context));
    }

    @Future(Callout=true)
    public static void postCompensationsMessage(String parametersJSON) {
        Map<String, Object> parameters = (Map<String, Object>) JSON.deserializeUntyped(parametersJSON);
        Slack.App app = Slack.App.PropellerPlanSlackApp.get();
        Slack.BotClient client = app.getBotClientForTeam((String) parameters.get('teamId'));
        Slack.ViewReference viewReference = Slack.View.compensation.get();
        viewReference.setParameter('header', 'Your compensation(s) has been ' + (parameters.get('id') != null ? 'updated' : 'added'));
        viewReference.setParameter('compensations', parameters.get('compensations'));

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
            List<Compensation__c> compensationsToUpsert = new List<Compensation__c>();
            Id contactId = findContactByUserEmailOrOwner();
            if (parameters.get('isBulk') == null) {
                Map<String, Object> formData = context.getFormData();
                Compensation__c compensation = new Compensation__c(
                        Person__c = contactId,
                        Category__c = formData.get('category') != null ? String.valueOf(formData.get('category')) : null,
                        CurrencyIsoCode = String.valueOf(formData.get('currencyCode')),
                        Total__c = Decimal.valueOf((String) formData.get('amount')),
                        Description__c = String.valueOf(formData.get('description')),
                        Date__c = new pp_Moment(String.valueOf(formData.get('dateOf')), 'yyyy-MM-dd').toDate()
                );
                if (parameters.get('id') != null) compensation.Id = String.valueOf(parameters.get('id'));
                compensationsToUpsert.add(compensation);
            } else {
                for (slackbot_CompensationsCommandDispatcher.Compensation compensation : slackbot_CompensationActionDispatcher.parseCompensationsFromRawData(context.getFormData())) {
                    compensationsToUpsert.add(new Compensation__c(
                            Person__c = contactId,
                            Category__c = compensation.category,
                            CurrencyIsoCode = compensation.currencyCode,
                            Total__c = compensation.amount,
                            Description__c = compensation.description,
                            Date__c = new pp_Moment(compensation.dateOf, 'yyyy-MM-dd').toDate()
                    ));
                }
            }
            upsert compensationsToUpsert;

            List<slackbot_CompensationsCommandDispatcher.Compensation> compensations = new List<slackbot_CompensationsCommandDispatcher.Compensation>();
            for (Compensation__c c : compensationsToUpsert) {
                compensations.add(new slackbot_CompensationsCommandDispatcher.Compensation(c));
            }
            postCompensationsMessage(JSON.serialize(new Map<String, Object>{
                    'teamId' => context.getTeamId(),
                    'channel' => context.getChannelId() ?? String.valueOf(parameters.get('channel')),
                    'id' => parameters.get('id'),
                    'compensations' => compensations
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