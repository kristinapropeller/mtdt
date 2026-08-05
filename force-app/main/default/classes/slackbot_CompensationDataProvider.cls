/**
 * Created on 10/07/2024.
 */

public class slackbot_CompensationDataProvider {
    public static List<Slack.Option> getCategories() {
        List<Slack.Option> options = new List<Slack.Option>();
        for (PicklistEntry pe : Compensation__c.SObjectType.fields.Category__c.getDescribe().getPicklistValues()) {
            if (pe.isActive()) {
                options.add(new Slack.Option(pe.getLabel(), pe.getValue()));
            }
        }
        return options;
    }
}