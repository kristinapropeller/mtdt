/**
 * Created by artsiomartsiomenka on 19/03/2024.
 */

public without sharing class ClickUpSelector {
    public static Contact getContactByEmail(String email) {
        return (Contact) new pp_Query('Contact')
                .selectAllFields()
                .addConditionNotNull('Email')
                .addCondition(
                        pp_Query.doAnd(
                                pp_Query.conditionEq(Contact.Email, email),
                                pp_Query.conditionEq(Contact.Inactive__c, false)
                        )
                )
                .fetch();
    }

    public static Map<String, SObject> getContactsByEmailMap(Set<String> emailSet) {
        Map<String, SObject> contactMap = new Map<String, SObject>();
        List<Contact> contacts = new List<Contact>();
        contacts = new pp_Query('Contact')
                .selectAllFields()
                .addConditionNotNull('Email')
                .addCondition(
                        pp_Query.doAnd(
                                pp_Query.conditionIn(Contact.Email, emailSet),
                                pp_Query.conditionEq(Contact.Inactive__c, false)
                        )
                )
                .run();

        if (contacts.isEmpty()) return contactMap;

        return (Map<String, SObject>) pp_R.of(contacts)
                .indexBy(pp_R.prop.apply('Email'))
                .toSObjectMap();
    }

    public static Case getCaseByClickUpTaskId(String clickUpTaskId) {
        return (Case) new pp_Query('Case')
                .selectAllFields()
                .selectFields('Contact.Email, Project__r.ClickUp_Folder_Id__c')
                .addConditionEq(Case.ClickUp_Task_Id__c, clickUpTaskId)
                .fetch();
    }

    public static Case getCaseById(String caseId) {
        return (Case) new pp_Query('Case')
                .selectAllFields()
                .selectFields('Contact.Email, Project__r.ClickUp_Folder_Id__c')
                .addConditionEq(Case.Id, caseId)
                .fetch();
    }

    public static Project__c getProjectByClickUpId(String projectId, String listId) {
        return (Project__c) new pp_Query('Project__c')
                .selectAllFields()
                .addConditionNotNull(Project__c.ClickUp_Folder_Id__c)
                .addCondition(
                    pp_Query.doOr(
                            pp_Query.conditionEq(Project__c.ClickUp_Folder_Id__c, projectId),
                            pp_Query.conditionEq(Project__c.ClickUp_Folder_Id__c, listId),
                            pp_Query.conditionLike(Project__c.ClickUp_Folder_Id__c, '%' + projectId + '%'),
                            pp_Query.conditionLike(Project__c.ClickUp_Folder_Id__c, '%' + listId + '%')
                    )
                )
                .fetch();
    }

    public static Timecard__c getTimeCardByIntervalId(String intervalId) {
        return (Timecard__c) new pp_Query('Timecard__c')
                .selectAllFields()
                .addConditionNotNull(Timecard__c.ClickUp_Time_Id__c)
                .addConditionEq(Timecard__c.ClickUp_Time_Id__c, intervalId)
                .fetch();
    }

    public static Map<String, SObject> getTimeCardsByClickUpId(Set<String> clickUpIds) {
        Map<String, Timecard__c> timeCardMap = new Map<String, Timecard__c>();
        List<Timecard__c> timeCards = new List<Timecard__c>();
        timeCards = new pp_Query('Timecard__c')
                .selectAllFields()
                .addConditionNotNull(Timecard__c.ClickUp_Time_Id__c)
                .addConditionEq(Timecard__c.ClickUp_Time_Id__c, clickUpIds)
                .run();

        if (timeCards.isEmpty()) return timeCardMap;

        return (Map<String, SObject>) pp_R.of(timeCards)
                .indexBy(pp_R.prop.apply('ClickUp_Time_Id__c'))
                .toSObjectMap();
    }

    public static String getClickUpTaskById(String taskId) {
        String resStr = new pp_RestExplorer(ClickUp__c.getOrgDefaults().Endpoint__c + 'task/'+taskId)
                .doGet()
                .setHeader('Authorization', ClickUp__c.getOrgDefaults().API_Key__c)
                .getResult();

        return resStr;
    }
}