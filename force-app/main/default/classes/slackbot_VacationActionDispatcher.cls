/**
 * Created on 05/07/2024.
 */

public class slackbot_VacationActionDispatcher extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        if (parameters.get('recordId') != null && parameters.get('isDelete') != null) {
            return Slack.ActionHandler.ack(new DeleteHandler(parameters, context));
        } else if (parameters.get('recordId') != null) {
            return Slack.ActionHandler.modal(new EditHandler(parameters, context), 'Update Vacation');
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
            Slack.ViewReference viewReference = Slack.View.vacation_form.get();
            viewReference.setParameter('channel', context.getChannelId());
            if (parameters.get('recordId') != null) {
                Vacation__c vacation = (Vacation__c) new pp_Query('Vacation__c')
                        .selectAllFields()
                        .byId((String) parameters.get('recordId'))
                        .fetch();
                viewReference.setParameter('recordId', vacation.Id);
                viewReference.setParameter('startDate', new pp_Moment(vacation.Vacation_Start_Date__c).format('yyyy-MM-dd'));
                viewReference.setParameter('endDate', new pp_Moment(vacation.Vacation_End_Date__c).format('yyyy-MM-dd'));
                viewReference.setParameter('type', vacation.Vacation_Type__c);
                viewReference.setParameter('status', vacation.Status__c);
                viewReference.setParameter('title', 'Update Vacation');
            } else {
                viewReference.setParameter('type', 'Day Off');
                viewReference.setParameter('status', 'Planned');
                viewReference.setParameter('title', 'Add Vacation');
            }
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
            delete new Vacation__c(Id = (String) parameters.get('recordId'));
            postMessage(context.getTeamId(), context.getChannelId(), '_The vacation has been deleted._');
        }
    }
}