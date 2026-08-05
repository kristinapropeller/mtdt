/**
 * Created on 17/03/2023.
 */

public with sharing class ResourceUtilizationController {
    @AuraEnabled
    public static Map<String, Object> getResourcesWithAssignments(Date dateFrom, Date dateTo) {
        List<Contact> resources = getActiveInternalContacts();
        Set<Id> contactIds = new Map<Id, Contact>(resources).keySet();
        return new Map<String, Object>{
                'resources' => resources,
                'cases' => getCasesForRange(contactIds, new pp_Moment().toDate(), dateTo),
                'bookings' => getBookings(contactIds, dateFrom, dateTo),
                'vacations' => getVacations(contactIds, dateFrom, dateTo)
        };
    }

    private static List<Contact> getActiveInternalContacts() {
        return new pp_Query('Contact')
                .selectFields(new Set<String>{'Id', 'Name'})
                .addConditionEq('Inactive__c', false)
                .addConditionEq('Account.Name', 'Propeller Plan')
                .orderBy('Name')
                .run();
    }
    private static List<Case> getCasesForRange(Set<Id> contactIds, Date dateFrom, Date dateTo) {
        return new pp_Query('Case')
                .selectFields(new Set<String>{'Id', 'Subject', 'Project__c', 'Project__r.Name', 'Start_Date__c', 'Due_Date__c', 'ContactId', 'Estimated_Time__c'})
                .addConditionIn('ContactId', contactIds)
                .addConditionGt('Estimated_Time__c', 0)
                .addCondition(pp_Query.doOr(
                        pp_Query.doAnd(
                                pp_Query.conditionNull('Start_Date__c'),
                                pp_Query.conditionLe('Due_Date__c', dateTo),
                                pp_Query.conditionGe('Due_Date__c', dateFrom)
                        ),
                        pp_Query.doAnd(
                                pp_Query.conditionLe('Start_Date__c', dateTo),
                                pp_Query.conditionGe('Due_Date__c', dateFrom)
                        )
                ))
                .orderBy('Start_Date__c')
                .orderBy('Due_Date__c')
                .orderBy('Subject')
                .run();
    }
    private static List<Case> getBookings(Set<Id> contactIds, Date dateFrom, Date dateTo) {
        return new pp_Query('Booking__c')
                .selectFields(new Set<String>{'Id', 'Name', 'Project__c', 'Project__r.Name', 'Start_Date__c', 'End_Date__c', 'Contact__c', 'Planned_Time__c'})
                .addConditionIn('Contact__c', contactIds)
                .addConditionLe('Start_Date__c', dateTo)
                .addConditionGe('End_Date__c', dateFrom)
                .orderBy('Start_Date__c')
                .orderBy('End_Date__c')
                .orderBy('Name')
                .run();
    }
    private static List<Case> getVacations(Set<Id> contactIds, Date dateFrom, Date dateTo) {
        return new pp_Query('Vacation__c')
                .selectFields(new Set<String>{'Id', 'Vacation_Type__c', 'Vacation_Start_Date__c', 'Vacation_End_Date__c', 'Employee__c'})
                .addConditionIn('Employee__c', contactIds)
                .addConditionLe('Vacation_Start_Date__c', dateTo)
                .addConditionGe('Vacation_End_Date__c', dateFrom)
                .orderBy('Vacation_Start_Date__c')
                .orderBy('Vacation_End_Date__c')
                .run();
    }
}