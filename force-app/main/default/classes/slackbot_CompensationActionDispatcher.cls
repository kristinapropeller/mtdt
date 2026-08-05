/**
 * Created on 08/07/2024.
 */

public class slackbot_CompensationActionDispatcher extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        if (parameters.get('recordId') != null && parameters.get('isDelete') != null) {
            return Slack.ActionHandler.ack(new DeleteHandler(parameters, context));
        } else if (parameters.get('recordId') != null) {
            return Slack.ActionHandler.modal(new EditHandler(parameters, context), 'Update Compensation');
        } else if (parameters.get('addMore') != null) {
            return Slack.ActionHandler.updateModal(new AddMoreHandler(parameters, context));
        }
        return Slack.ActionHandler.modal(new EditHandler(parameters, context));
    }

    @Future(Callout=true)
    public static void postMessage(String teamId, String channel, String message) {
        Slack.App app = Slack.App.PropellerPlanSlackApp.get();
        Slack.BotClient client = app.getBotClientForTeam(teamId);
        Slack.ViewReference viewReference = Slack.View.message.get();
        viewReference.setParameter('message', message);

        Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.Builder()
                .channel(channel)
                .viewReference(viewReference)
                .build();

        Slack.ChatPostMessageResponse response = client.chatPostMessage(req);
        if (response.getError() != null) {
            System.debug(response.getError());
        } else {
            System.debug('success');
        }
    }

    public class EditHandler implements Slack.ModalHandler {

        Map<String, Object> parameters;
        Slack.RequestContext context;

        public EditHandler(Map<String, Object> parameters, Slack.RequestContext context){
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            Slack.ViewReference viewReference;
            if (parameters.get('recordId') != null) {
                viewReference = Slack.View.compensation_form.get();
                Compensation__c compensation = (Compensation__c) new pp_Query('Compensation__c')
                        .selectAllFields()
                        .byId((String) parameters.get('recordId'))
                        .fetch();
                viewReference.setParameter('recordId', compensation.Id);
                viewReference.setParameter('dateOf', new pp_Moment(compensation.Date__c).format('yyyy-MM-dd'));
                viewReference.setParameter('category', compensation.Category__c);
                viewReference.setParameter('currencyCode', compensation.CurrencyIsoCode);
                viewReference.setParameter('description', compensation.Description__c);
                viewReference.setParameter('amount', compensation.Total__c);
                viewReference.setParameter('title', 'Update Compensation');
            } else {
                viewReference = Slack.View.compensation_form_bulk.get();
                List<slackbot_CompensationsCommandDispatcher.Compensation> compensations = new List<slackbot_CompensationsCommandDispatcher.Compensation>{ new slackbot_CompensationsCommandDispatcher.Compensation(1) };
                viewReference.setParameter('compensations', compensations);
            }
            viewReference.setParameter('channel', context.getChannelId());
            Slack.ModalView modalView = new Slack.ModalView.Builder()
                    .viewReference(viewReference)
                    .build();
            return modalView;
        }
    }

    public class DeleteHandler implements Slack.RunnableHandler {

        Map<String, Object> parameters;
        Slack.RequestContext context;

        public DeleteHandler(Map<String, Object> parameters, Slack.RequestContext context){
            this.parameters = parameters;
            this.context = context;
        }

        public void run () {
            delete new Compensation__c(Id = (String) parameters.get('recordId'));
            postMessage(context.getTeamId(), context.getChannelId(), '_The compensation has been deleted._');
        }
    }

    public class AddMoreHandler implements Slack.ModalHandler {

        Map<String, Object> parameters;
        Slack.RequestContext context;

        public AddMoreHandler (Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call () {
            List<slackbot_CompensationsCommandDispatcher.Compensation> compensations = parseCompensationsFromRawData(context.getFormData());
            compensations.add(new slackbot_CompensationsCommandDispatcher.Compensation(compensations.size() + 1));
            Slack.ViewReference viewReference = Slack.View.compensation_form_bulk.get();
            viewReference.setParameter('channel', parameters.get('channel'));
            viewReference.setParameter('compensations', compensations);
            Slack.ModalView modalView = new Slack.ModalView.Builder()
                    .viewReference(viewReference)
                    .build();
            return modalView;
        }
    }

    public static List<slackbot_CompensationsCommandDispatcher.Compensation> parseCompensationsFromRawData(Map<String, Object> formData) {
        List<slackbot_CompensationsCommandDispatcher.Compensation> compensations = new List<slackbot_CompensationsCommandDispatcher.Compensation>();
        for (Integer i = 1; i <= 100; i++) {
            if (formData.get('dateOf_' + i) == null) break;

            slackbot_CompensationsCommandDispatcher.Compensation c = new slackbot_CompensationsCommandDispatcher.Compensation(i);
            c.dateOf = (String) formData.get('dateOf_' + i);
            c.category = formData.get('category_' + i) != null ? (String) formData.get('category_' + i) : null;
            c.currencyCode = (String) formData.get('currencyCode_' + i);
            c.amount = formData.get('amount_' + i) != null ? Decimal.valueOf((String) formData.get('amount_' + i)) : null;
            c.description = (String) formData.get('description_' + i);
            compensations.add(c);
        }
        return compensations;
    }
}