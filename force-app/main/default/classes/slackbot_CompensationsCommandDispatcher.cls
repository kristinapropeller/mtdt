/**
 * Created on 04/07/2024.
 */

public class slackbot_CompensationsCommandDispatcher extends Slack.SlashCommandDispatcher {
    public override Slack.ActionHandler invoke(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {
        if (parameters.getText() == 'new') {
            return Slack.ActionHandler.modal(new NewHandler(parameters, context), 'Add Compensation');
        }
        return Slack.ActionHandler.ack(new ViewHandler(parameters, context));
    }

    public class ViewHandler implements Slack.RunnableHandler {
        Slack.SlashCommandParameters parameters;
        Slack.RequestContext context;

        public ViewHandler(Slack.SlashCommandParameters parameters, Slack.RequestContext context){
            this.parameters = parameters;
            this.context = context;
        }

        public void run () {
            Slack.App app = Slack.App.PropellerPlanSlackApp.get();
            Slack.BotClient client = app.getBotClientForTeam(context.getTeamId());
            Slack.ViewReference viewReference = Slack.View.compensation_list.get();
            String channel = context.getChannelId();
            Map<String, Object> compensationsAndTotalInUSD = getUnclosedCompensations();
            viewReference.setParameter('compensations', compensationsAndTotalInUSD.get('compensations'));
            viewReference.setParameter('unclosedTotal', compensationsAndTotalInUSD.get('total'));

            Map<String, Decimal> usedCompensations = calculateCompensationsByCategories();
            viewReference.setParameter('foodUsed', usedCompensations.get('food'));
            viewReference.setParameter('foodTotal', (Integer) Setting__c.getOrgDefaults().Food_Compensation_Monthly__c);
            viewReference.setParameter('sportUsed', usedCompensations.get('sport'));
            viewReference.setParameter('sportTotal', (Integer) Setting__c.getOrgDefaults().Sport_Compensation_Monthly__c);
            viewReference.setParameter('healthUsed', usedCompensations.get('health'));
            viewReference.setParameter('healthTotal', (Integer) Setting__c.getOrgDefaults().Health_Compensation_Yearly__c);

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

        private Map<String, Object> getUnclosedCompensations() {
            List<Compensation__c> compensations = (List<Compensation__c>) new pp_Query('Compensation__c')
                    .selectAllFields()
                    .selectField('convertCurrency(Total__c)', 'convertedAmount')
                    .addCondition(pp_Query.doAnd(
                            pp_Query.conditionEq('Closed__c', false),
                            pp_Query.doOr(
                                    pp_Query.conditionEq('CreatedById', UserInfo.getUserId()),
                                    pp_Query.conditionEq('Person__r.Email', UserInfo.getUserEmail()),
                                    pp_Query.conditionEq('Person__r.OwnerId', UserInfo.getUserId())
                            )
                    ))
                    .orderBy('Date__c')
                    .setLimit(10000)
                    .run();
            List<Compensation> compensationsToDisplay = new List<Compensation>();
            Decimal totalInUSD = 0;
            for (Integer i = 0; i < compensations.size(); i++) {
                if (compensations.size() - i <= 10) compensationsToDisplay.add(new Compensation(compensations[i]));
                totalInUSD += (Decimal) compensations[i].get('convertedAmount');
            }
            return new Map<String, Object>{
                    'compensations' => compensationsToDisplay,
                    'total' => totalInUSD
            };
        }

        private Map<String, Decimal> calculateCompensationsByCategories() {
            Decimal foodUsed = 0,
                    sportUsed = 0,
                    healthUsed = 0;
            for (Compensation__c c : (List<Compensation__c>) new pp_Query('Compensation__c')
                    .selectField('Category__c')
                    .selectField('convertCurrency(Total__c)', 'convertedAmount')
                    .addCondition(pp_Query.doAnd(
                            pp_Query.conditionEq('Date__c', pp_Query.THIS_MONTH),
                            pp_Query.conditionIn('Category__c', new Set<String>{'Food', 'Sport'}),
                            pp_Query.doOr(
                                    pp_Query.conditionEq('CreatedById', UserInfo.getUserId()),
                                    pp_Query.conditionEq('Person__r.Email', UserInfo.getUserEmail()),
                                    pp_Query.conditionEq('Person__r.OwnerId', UserInfo.getUserId())
                            )
                    ))
                    .setLimit(20000)
                    .run()) {
                if (c.Category__c == 'Food') foodUsed += (Decimal) c.get('convertedAmount');
                else if (c.Category__c == 'Sport') sportUsed += (Decimal) c.get('convertedAmount');
            }
            for (Compensation__c c : (List<Compensation__c>) new pp_Query('Compensation__c')
                    .selectField('Category__c')
                    .selectField('convertCurrency(Total__c)', 'convertedAmount')
                    .addCondition(pp_Query.doAnd(
                            pp_Query.conditionEq('Date__c', pp_Query.THIS_YEAR),
                            pp_Query.conditionIn('Category__c', new Set<String>{'Health'}),
                            pp_Query.doOr(
                                    pp_Query.conditionEq('CreatedById', UserInfo.getUserId()),
                                    pp_Query.conditionEq('Person__r.Email', UserInfo.getUserEmail()),
                                    pp_Query.conditionEq('Person__r.OwnerId', UserInfo.getUserId())
                            )
                    ))
                    .setLimit(20000)
                    .run()) {
                if (c.Category__c == 'Health') healthUsed += (Decimal) c.get('convertedAmount');
            }
            return new Map<String, Decimal>{
                    'food' => foodUsed,
                    'sport' => sportUsed,
                    'health' => healthUsed
            };
        }
    }

    public class NewHandler implements Slack.ModalHandler {

        Slack.SlashCommandParameters parameters;
        Slack.RequestContext context;

        public NewHandler(Slack.SlashCommandParameters parameters, Slack.RequestContext context){
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            Slack.ViewReference viewReference = Slack.View.compensation_form_bulk.get();
            viewReference.setParameter('channel', context.getChannelId());
            List<Compensation> compensations = new List<Compensation>{ new Compensation(1) };
            viewReference.setParameter('compensations', compensations);
            Slack.ModalView modalView = new Slack.ModalView.Builder()
                    .viewReference(viewReference)
                    .build();
            return modalView;
        }
    }

    public class Compensation {
        public String id {get;set;}
        public Integer num {get;set;}
        public String category {get;set;}
        public String description {get;set;}
        public String dateOf {get;set;}
        public String currencyCode {get;set;}
        public Decimal amount {get;set;}

        public Compensation(Integer num) {
            this.num = num;
            this.dateOf = new pp_Moment(Date.today()).format('yyyy-MM-dd');
            this.currencyCode = 'USD';
        }

        public Compensation(Compensation__c c) {
            this.id = c.Id;
            this.category = c.Category__c;
            this.description = c.Description__c;
            this.dateOf = new pp_Moment(c.Date__c).format('MMMM d, yyyy');
            this.currencyCode = c.CurrencyIsoCode;
            this.amount = c.Total__c;
        }
    }
}