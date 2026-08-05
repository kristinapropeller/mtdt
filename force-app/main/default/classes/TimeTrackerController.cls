/**
 * Created on 16/11/2022.
 */

public class TimeTrackerController {
    @AuraEnabled(cacheable=true scope='global')
    public static List<Map<String, Object>> getPersonOptions(String filters) {
        String query = 'SELECT Id, Name FROM Contact';
        if (String.isNotEmpty(filters)) query += ' WHERE ' + filters;
        query += ' ORDER BY Name';

        List<Map<String, Object>> result = new List<Map<String, Object>>();
        pp_Mapper m = new pp_Mapper()
                .mapField('value', 'Id')
                .mapField('label', 'Name')
                .toMap();
        for (Contact con : Database.query(query)) {
            result.add((Map<String, Object>)m.run(con));
        }
        return result;
    }

    @AuraEnabled
    public static List<Map<String, Object>> getLogsByTaskAndDate(String contactId, Date fromDate, Date toDate) {
        if (toDate == null) toDate = fromDate.addDays(6);
        fromDate = Date.newInstance(fromDate.year(), fromDate.month(), fromDate.day());
        toDate = Date.newInstance(toDate.year(), toDate.month(), toDate.day());

        Map<Id, Map<String, Object>> resultMap = new Map<Id, Map<String, Object>>();
        Map<Id, Map<Date, Map<String, Object>>> logsByTaskAndDay = new Map<Id, Map<Date, Map<String, Object>>>();
        pp_Mapper taskMapper = new pp_Mapper()
                .mapField('taskId', 'Case__c')
                .mapField('project', 'Case__r.Project__r.Name')
                .toMap();
        pp_Mapper logMapper = new pp_Mapper()
                .mapField('logId', 'Id')
                .mapField('duration', 'Effort__c')
                .mapField('date', 'Work_Date__c')
                .mapField('description', 'Description__c')
                .toMap();
        for (Timecard__c tc : (List<Timecard__c>)new pp_Query('Timecard__c')
                .selectFields(new Set<String>{'Id', 'Effort__c', 'Work_Date__c', 'Description__c', 'Case__c', 'Case__r.Case_ID__c', 'Case__r.Subject', 'Case__r.Project__r.Name'})
                .addConditionEq('Person__c', contactId)
                .addConditionGe('Work_Date__c', fromDate)
                .addConditionLe('Work_Date__c', toDate)
                .orderBy('Case__r.Project__r.Name', 'ASC')
                .orderBy('Case__r.Case_ID__c', 'ASC')
                .orderBy('Case__r.Subject', 'ASC')
                .orderBy('Work_Date__c', 'ASC')
                .run()) {
            if (!resultMap.containsKey(tc.Case__c)) {
                Map<String, Object> t = (Map<String, Object>)taskMapper.run(tc);
                t.put('subject', (tc.Case__r.Case_ID__c != null ? tc.Case__r.Case_ID__c + ': ' : '') + tc.Case__r.Subject);
                t.put('total', 0);
                resultMap.put(tc.Case__c, t);
                logsByTaskAndDay.put(tc.Case__c, new Map<Date, Map<String, Object>>());
            }
            resultMap.get(tc.Case__c).put('total', (Decimal)resultMap.get(tc.Case__c).get('total') + tc.Effort__c);
            logsByTaskAndDay.get(tc.Case__c).put(tc.Work_Date__c, (Map<String, Object>)logMapper.run(tc));
        }
        System.debug('logsByTaskAndDay ' + logsByTaskAndDay);
        for (Id taskId : resultMap.keySet()) {
            List<Map<String, Object>> logs = new List<Map<String, Object>>();
            for (Date d = fromDate; d <= toDate; d = d.addDays(1)) {
                if (logsByTaskAndDay.containsKey(taskId) && logsByTaskAndDay.get(taskId).containsKey(d)) logs.add(logsByTaskAndDay.get(taskId).get(d));
                else logs.add(new Map<String, Object>{ 'date' => d });
            }
            resultMap.get(taskId).put('logsByDay', logs);
        }
        return resultMap.values();
    }

    @AuraEnabled
    public static List<Timecard__c> upsertLogs(String logsJSON, String contactId) {
        List<Timecard__c> logsToUpsert = new List<Timecard__c>();
        List<Timecard__c> logsToDelete = new List<Timecard__c>();
        for (Timecard__c tc : (List<Timecard__c>)JSON.deserialize(logsJSON, List<Timecard__c>.class)) {
            if (tc.Effort__c != null && tc.Effort__c > 0) {
                if (String.isNotEmpty(contactId)) tc.Person__c = contactId;
                logsToUpsert.add(tc);
            } else if (tc.Id != null) {
                logsToDelete.add(tc);
            }
        }
        delete logsToDelete;
        upsert logsToUpsert;
        return logsToUpsert;
    }

    @AuraEnabled
    public static void deleteLogs(String contactId, String taskId, Date fromDate, Date toDate) {
        if (toDate == null) toDate = fromDate.addDays(6);
        fromDate = Date.newInstance(fromDate.year(), fromDate.month(), fromDate.day());
        toDate = Date.newInstance(toDate.year(), toDate.month(), toDate.day());

        delete new pp_Query('Timecard__c')
                .addConditionEq('Person__c', contactId)
                .addConditionEq('Case__c', taskId)
                .addConditionGe('Work_Date__c', fromDate)
                .addConditionLe('Work_Date__c', toDate)
                .run();
    }
}