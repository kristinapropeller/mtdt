/**
 * Created by artsiomartsiomenka on 06/03/2024.
 * Instructions on how to add/update timeLogs from ClickUp to sf are located at the bottom of the class
 */

public without sharing class ClickUpAPIService {
    private static final String CASE_TYPE_TASK = 'Task';
    private static final String CASE_ORIGIN_WEB = 'Web';
    private static final Boolean IS_DEBUG_MODE = true;

    private static final String DATA_KEY = 'data';
    private static final String USER_KEY = 'user';
    private static final String EMAIL_KEY = 'email';
    private static final String INTERVALS_KEY = 'intervals';
    private static final String ID_KEY = 'id';
    private static final String START_KEY = 'start';
    private static final String END_KEY = 'end';
    private static final String TIME_KEY = 'time';
    private static final String DESCRIPTION_KEY = 'description';

    public static final String logPrefix = 'ClickUp: ';

    private static final Map<String, String> CASE_PRIORITY_MAP = new Map<String, String> {
            'urgent' => 'ASAP',
            'high' => 'High',
            'normal' => 'Medium',
            'low' => 'Low'
    };
    private static final Map<String, String> CASE_STATUS_MAP = new Map<String, String> {
            'to do' => 'New',
            'in progress' => 'In Progress',
            'roadblock' => 'Roadblock',
            'review' => 'Review',
            'done' => 'Done'
    };

    public class ClickUpServiceQueueable implements Queueable, Database.AllowsCallouts {
        String taskId = null;
        public ClickUpServiceQueueable(String taskId){
            this.taskId = taskId;
        }
        public void execute(QueueableContext param1) {
            try {
                upsertTimeTracked(taskId);

            } catch (Exception e){
                logInfo('Got exception: ' + e.getMessage() + ', ' + e.getStackTraceString(), logPrefix + 'upsertTimeTracked');
            } finally {
                flushLogs();
            }
        }
    }
    @Future(Callout=true)
    public static void upsertTaskAndTimeTracked(String taskId) {
        try {
            upsertTask(taskId);

        } catch (Exception e){
            logInfo('Got exception: ' + e.getMessage() + ', ' + e.getStackTraceString(), logPrefix + 'upsertTask');
        } finally {
            flushLogs();
        }
        System.enqueueJob(new ClickUpServiceQueueable(taskId));
    }

    public static void upsertTimeTracked(String taskId) {
        Case existedCase = ClickUpSelector.getCaseByClickUpTaskId(taskId);
        // TODO: if case do not exist - create case by project (create project if need to)
        if (existedCase == null) {
            System.debug('upsertTimeTracked: ' + taskId + ' not found');
            if (!System.isFuture()) upsertTaskAndTimeTracked(taskId);
            return ;
        }
        String caseId = existedCase.Id;

        // TODO: change to Named Credentials after sf release the update
        String resStr = new pp_RestExplorer(ClickUp__c.getOrgDefaults().Endpoint__c + 'task/'+taskId+'/time/')
                .doGet()
                .setHeader('Authorization', ClickUp__c.getOrgDefaults().API_Key__c)
                .getResult();

        System.debug('body: '+resStr);

        pp_Mapper.DTO timeLegacyDto = new pp_Mapper.DTO(resStr);

        if (!timeLegacyDto.containsPath(DATA_KEY)) {
            logInfo('Got exception: timeLegacyDto data not found', logPrefix + 'upsertTimeTracked');
            return ;
        }
        List<Object> data = timeLegacyDto.getList(DATA_KEY);

        Set<String> userEmailSet = new Set<String>();
        Set<String> timeCardsIds = new Set<String>();
        Map<String, Map<String, Object>> userEmailToDataMap = new Map<String, Map<String, Object>>();

        // Collect user emails and interval IDs
        for (Object obj : data) {
            Map<String, Object> objMap = (Map<String, Object>) obj;
            Map<String, Object> userData = (Map<String, Object>) objMap.get(USER_KEY);

            if (userData != null) {
                String userEmail = (String) userData.get(EMAIL_KEY);
                if (!String.isBlank(userEmail)) {
                    userEmailSet.add(userEmail);
                    userEmailToDataMap.put(userEmail, objMap);
                }
            }

            List<Object> intervals = (List<Object>) objMap.get(INTERVALS_KEY);
            if (intervals != null) {
                for (Object intervalObj : intervals) {
                    Map<String, Object> interval = (Map<String, Object>) intervalObj;
                    String intervalId = (String) interval.get(ID_KEY);
                    if (!String.isBlank(intervalId)) {
                        timeCardsIds.add(intervalId);
                    }
                }
            }
        }
        if (IS_DEBUG_MODE) System.debug('***userEmailSet size: ' + userEmailSet.size());
        if (IS_DEBUG_MODE) System.debug('***userEmailSet: ' + userEmailSet);
        if (userEmailSet.isEmpty()) {
            logInfo('Got exception: user Email not found', logPrefix + 'upsertTimeTracked');
            return;
        }

        Map<String, SObject> contactMap = ClickUpSelector.getContactsByEmailMap(userEmailSet);
        System.debug('***contactMap size: ' + contactMap.size());
        Map<String, SObject> timeCardByClickUpIdMap = ClickUpSelector.getTimeCardsByClickUpId(timeCardsIds);
        System.debug('***timeCardByClickUpIdMap size: ' + timeCardByClickUpIdMap.size());
        List<Timecard__c> timeCardsToUpsert = new List<Timecard__c>();

        // Create new intervals from the data found by the contact Email
        for (String userEmail : userEmailToDataMap.keySet()) {
            Map<String, Object> objMap = userEmailToDataMap.get(userEmail);
            String contactId = contactMap.get(userEmail)?.Id;
            if (String.isBlank(contactId)) continue;

            List<Object> intervals = (List<Object>) objMap.get(INTERVALS_KEY);
            if (intervals == null) continue;

            for (Object intervalObj : intervals) {
                Map<String, Object> interval = (Map<String, Object>) intervalObj;
                System.debug('***interval : ' + interval);
                Timecard__c timeCard = processInterval(interval, contactId, caseId, timeCardByClickUpIdMap);
                System.debug('***timeCard : ' + timeCard);
                if (timeCard != null) {
                    timeCardsToUpsert.add(timeCard);
                }
            }
        }
        if (IS_DEBUG_MODE) System.debug('***timeCards to upsert: ' + timeCardsToUpsert.size());
        if (!timeCardsToUpsert.isEmpty()) upsert timeCardsToUpsert;
    }

    private static Timecard__c processInterval(Map<String, Object> interval, String contactId, Id caseId, Map<String, SObject> timeCardByClickUpIdMap) {
        String intervalId = (String) interval.get(ID_KEY);
        if (String.isBlank(intervalId)) return null;

        String start_x = (String) interval.get(START_KEY);
        String end_x = (String) interval.get(END_KEY);
        String time_x = (String) interval.get(TIME_KEY);
        String description = (String) interval.get(DESCRIPTION_KEY);
        Decimal effort = convertMillisecondsToHours(time_x);
        Date workDate = convertTimestampToDate(end_x);
        if (workDate == null) workDate = convertTimestampToDate(start_x);
        workDate = (workDate != null) ? workDate : System.today();

        String tcId = timeCardByClickUpIdMap.get(intervalId)?.Id;

        if (String.isBlank(tcId)) {
            return createTimeCardRecord(null, caseId, contactId, effort, workDate, description, intervalId);
        } else {
            Timecard__c existedTimeCard = (Timecard__c) timeCardByClickUpIdMap.get(intervalId);

            Timecard__c clonedTimeCard = existedTimeCard.clone(true, true);
            clonedTimeCard.Person__c = contactId;
            clonedTimeCard.Effort__c = effort;
            clonedTimeCard.Work_Date__c = workDate;
            clonedTimeCard.Description__c = String.isBlank(description) ? existedTimeCard.Description__c : description;

            return isTimeCardChanged(existedTimeCard, clonedTimeCard) ? clonedTimeCard : null;
        }
    }

    private static Timecard__c createTimeCardRecord(String tcId, String caseId, String contactId, Decimal effort,
            Date workDate, String description, String intervalId) {
        Timecard__c timeCard = new Timecard__c();

        if(!String.isBlank(tcId)) timeCard.Id = tcId;
        if(!String.isBlank(caseId) && String.isBlank(tcId)) timeCard.Case__c = caseId;
        if(!String.isBlank(contactId)) timeCard.Person__c = contactId;
        if(effort != null) timeCard.Effort__c = effort;
        if(workDate != null) timeCard.Work_Date__c = workDate;
        if(!String.isBlank(description)) timeCard.Description__c = description;
        if(!String.isBlank(intervalId) && String.isBlank(tcId)) timeCard.ClickUp_Time_Id__c = intervalId;

        return timeCard;
    }

    private static Boolean isTimeCardChanged(Timecard__c existingTC, Timecard__c newTC) {
        if (existingTC.Person__c != newTC.Person__c) return true;
        if (existingTC.Effort__c != newTC.Effort__c) return true;
        if (existingTC.Work_Date__c != newTC.Work_Date__c) return true;
        if (existingTC.Description__c != newTC.Description__c) return true;
        return false;
    }

    public static void deleteTimeTracked(String intervalId) {
        Timecard__c timeCard = ClickUpSelector.getTimeCardByIntervalId(intervalId);
        if (timeCard == null) return ;

        delete timeCard;
    }

    public static void upsertTask(String taskId) {
        String response = ClickUpSelector.getClickUpTaskById(taskId);

        String userEmail;

        if(IS_DEBUG_MODE) System.debug('ClickUp Task response: ' + response);

        pp_Mapper.DTO taskDto = new pp_Mapper.DTO(response);

        String taskFolderId = taskDto.getString('folder.id'); // || project.id
        String taskListId = taskDto.getString('list.id');
        if (IS_DEBUG_MODE) System.debug('CLickUp taskFolderId:' +taskFolderId);
        List<Object> assignees = taskDto.getList('assignees');
        if (assignees != null && !assignees.isEmpty()) userEmail = (String)((Map<String, Object>)assignees[0]).get(EMAIL_KEY);

        Project__c prj = ClickUpSelector.getProjectByClickUpId(taskFolderId, taskListId);
        if (prj == null) {
            logInfo('Got exception: project not found.' + 'Folder: ' + taskFolderId + ', taskListId: ' + taskListId, logPrefix + 'upsertTask');
            return ;
        }

        Contact ct = ClickUpSelector.getContactByEmail(userEmail);

        Case existedCase = ClickUpSelector.getCaseByClickUpTaskId(taskId);
        if (IS_DEBUG_MODE) System.debug('existedCase by task id: ' + existedCase);

        Case newCase = createCaseRecord(taskDto, prj.Id, ct?.Id, existedCase?.Id);

        if (existedCase != null) {
            if (IS_DEBUG_MODE) System.debug('existedCase: ' + existedCase);
            newCase.Id = existedCase.Id;
            Boolean changed = isCaseChanged(existedCase, newCase);
            if (IS_DEBUG_MODE) System.debug('isCaseChanged: ' + changed);
            if (!changed) return ;
        }
        if (IS_DEBUG_MODE) System.debug('*****newCase: ' + newCase);

        try {
            upsert newCase ClickUp_Task_Id__c;

        } catch (DmlException e) {
            logInfo('Got exception: upsertTask FAILED ' + 'ClickUp_Task_Id: ' + newCase.ClickUp_Task_Id__c
                    + ', project: ' + prj.Id + ', contact: ' + ct?.Id + ', existed case: ' + existedCase?.Id,
                    logPrefix + 'upsertTask');
        }
        flushLogs();
    }

    private static Case createCaseRecord(pp_Mapper.DTO taskDto, String projectId, String contactId, String existedCaseId) {
        String clickUpTaskId = taskDto.getString('id');
        String taskName = taskDto.getString('name');
        String taskDescription = taskDto.getString('description');
        String taskStatus = taskDto.getString('status.status');
        String taskPriority = taskDto.getString('priority.priority');
        String taskDueDate = taskDto.getString('due_date');

        List<Object> customFields = taskDto.getList('custom_fields');
        Map<String, String> caseFieldByKey = getCaseFieldsMapFromClickUpCustomFields(customFields);

        String sfCaseId = caseFieldByKey.get('salesforceCaseId');
        //if no existing case is found by "clickUp task Id", try searching by the specified "salesforce ID" custom field
        if (String.isBlank(existedCaseId) && !String.isBlank(sfCaseId)) {
            if (IS_DEBUG_MODE) System.debug('sfCaseId: ' + sfCaseId);
            Case existedCase = ClickUpSelector.getCaseById(sfCaseId);
            if (IS_DEBUG_MODE) System.debug('existedCase by id: ' + existedCase);
            sfCaseId = existedCase?.Id;
        }
        System.debug('sfCaseId: ' + sfCaseId);
        Case cs = new Case();
        cs.Subject = taskName;
        cs.Description = taskDescription;
        cs.Project__c = projectId;
        if (IS_DEBUG_MODE) System.debug('contactId: ' + contactId);
        cs.ContactId = String.isBlank(contactId) ? null : contactId;
        cs.ClickUp_Task_Id__c = clickUpTaskId;
        cs.Status = CASE_STATUS_MAP.get(taskStatus);
        cs.Priority = CASE_PRIORITY_MAP.get(taskPriority);
        if (!String.isBlank(caseFieldByKey.get('type'))) cs.Type = caseFieldByKey.get('type');
        if (!String.isBlank(caseFieldByKey.get('externalId'))) cs.External_System_ID__c = caseFieldByKey.get('externalId');
        if (!String.isBlank(caseFieldByKey.get('externalURL'))) cs.External_System_URL__c = caseFieldByKey.get('externalURL');
        cs.Origin = CASE_ORIGIN_WEB;
        cs.Due_Date__c = convertTimestampToDate(taskDueDate);
        if (!String.isBlank(sfCaseId)) cs.Id = sfCaseId;

        return cs;

        //TODO: add fields mapping after questions
//        cs.ClickUp_Task_URL__c = //task.url
//        cs.Filtering_Period__c = ;
    }

    private static Boolean isCaseChanged(Case existingCase, Case newCase) {
        if (existingCase.Subject != newCase.Subject) return true;
        if (existingCase.Description != newCase.Description) return true;
        if (existingCase.Project__c != newCase.Project__c) return true;
        if (existingCase.ContactId != newCase.ContactId) return true;
        if (existingCase.ClickUp_Task_Id__c != newCase.ClickUp_Task_Id__c) return true;
        if (existingCase.Status != newCase.Status) return true;
        if (existingCase.Priority != newCase.Priority) return true;
        if (existingCase.Type != newCase.Type) return true;
        if (existingCase.External_System_ID__c != newCase.External_System_ID__c) return true;
        if (existingCase.External_System_URL__c != newCase.External_System_URL__c) return true;
        if (existingCase.Due_Date__c != newCase.Due_Date__c) return true;

        return false;
    }

    public static void handleTaskDeleted(String taskId){
        Case existedCase = ClickUpSelector.getCaseByClickUpTaskId(taskId);
        if (existedCase == null) return ;

        delete existedCase;
    }

    // This method converts milliseconds to hours with two decimal places
    private static Decimal convertMillisecondsToHours(String millisecondsStr) {
        Long milliseconds = Long.valueOf(millisecondsStr);
        Decimal HOURS_CONST = 3600000;
        Decimal hours = milliseconds / HOURS_CONST;

        hours = hours.setScale(2, System.RoundingMode.HALF_UP);

        return hours;
    }

    // This method converts milliseconds to hours with two decimal places
    private static Date convertTimestampToDate(String timestamp) {
        //todo: resolve timezone issue -1
        if (String.isBlank(timestamp)) return null;

        Long timestampLong = Long.valueOf(timestamp);

        Datetime gmtDatetime = Datetime.newInstance(timestampLong);

        Date dateValue = Date.valueOf(gmtDatetime);

        return dateValue;
    }

    // This method create map of case fields based in ClickUp custom fields
    private static Map<String, String> getCaseFieldsMapFromClickUpCustomFields(List<Object> customFields) {
        Map<String, String> caseFieldByKey = new Map<String, String>();
        String caseType = CASE_TYPE_TASK;
        String extId = '';
        String extURL = '';
        String sfCaseId = '';

        for (Object cf : customFields) {
            String customFieldName = (String)((Map<String, Object>)cf).get('name');
            if (IS_DEBUG_MODE) System.debug('customFieldName: ' + customFieldName);
            Map<String, Object> typeConfig = (Map<String, Object>)((Map<String, Object>)cf).get('type_config');
            if (IS_DEBUG_MODE) System.debug('typeConfig: ' + typeConfig);
            List<Object> typeConfigOptions = (List<Object>)typeConfig.get('options');
            if (IS_DEBUG_MODE) System.debug('typeConfigOptions: ' + typeConfigOptions);
            List<Object> customFieldValueList = new List<Object>();
            String customFieldValueStr = '';
            Integer customFieldValueInt;

            try {
                customFieldValueList = (List<Object>)((Map<String, Object>)cf).get('value');
                if (IS_DEBUG_MODE) System.debug('valueList: ' + customFieldValueList);
            } catch (Exception e) {
                try {
                    customFieldValueStr = (String)((Map<String, Object>)cf).get('value');
                } catch (Exception exc) {
                    customFieldValueInt = (Integer)((Map<String, Object>)cf).get('value');
                    customFieldValueStr = String.valueOf(customFieldValueInt);
                }

                if (IS_DEBUG_MODE) System.debug('customFieldValue: ' + customFieldValueStr);
            }

            switch on customFieldName {
                when 'Item Type' {
                    if (typeConfigOptions != null) {
                        for (Object opt : typeConfigOptions) {
                            Integer optionOrderIndex = (Integer)((Map<String, Object>)opt).get('orderindex');
                            if (IS_DEBUG_MODE) System.debug('optionOrderIndex: ' + optionOrderIndex);
                            String optionName = (String)((Map<String, Object>)opt).get('name');
                            if (IS_DEBUG_MODE) System.debug('optionName: ' + optionName);
                            if (String.valueOf(optionOrderIndex) == customFieldValueStr) caseType = optionName;
                        }
                    }
                }
                when 'External ID' {
                    extId = customFieldValueStr;
                }
                when 'External URL' {
                    extURL = customFieldValueStr;
                }
                when 'Salesforce ID' {
                    if (customFieldValueStr.startsWithIgnoreCase('http')) {
                        // Use regex to extract the case Id from the URL.
                        // The pattern expects a URL segment like "/r/Case/<id>/"
                        Pattern p = Pattern.compile('/r/Case/([^/]+)/');
                        Matcher m = p.matcher(customFieldValueStr);
                        if (m.find()) {
                            customFieldValueStr = m.group(1);
                        }
                    }
                    sfCaseId = customFieldValueStr;
                }
//                when 'Feature' {
//                    for (ClickUpStructs.Option opt : cf.type_config.options) {
//                        if (opt?.orderindex == cf?.value) caseType = opt?.label;
//                    }
//                }
            }
        }
        caseFieldByKey.put('type', caseType);
        caseFieldByKey.put('externalId', extId);
        caseFieldByKey.put('externalURL', extURL);
        caseFieldByKey.put('salesforceCaseId', sfCaseId);
        return caseFieldByKey;
    }

    /**
        LOGGER
     */
    public static List<Log__c> loggerRecords = new List<Log__c>();

    public static void logInfo(String message, String error) {
        message = message == null ? '' : message;
        error = error == null ? '' : error;
        Log__c log = new Log__c(Request__c = message, Error__c = error);
        if (log.Request__c.length() >= 131072) log.Request__c = log.Request__c.left(131072);
        if (log.Error__c.length() >= 255) log.Error__c = log.Error__c.left(255);
        if (IS_DEBUG_MODE) System.debug('LOG:::' + message);
        if (IS_DEBUG_MODE) System.debug('LOG:::' + error);
        loggerRecords.add(log);
    }
    public static void flushLogs(){
        if (loggerRecords.size() > 0) {
            insert loggerRecords;
            loggerRecords = new List<Log__c>();
        }
    }
}

/*
==============================
Instruction: How to Add/Update Hours from ClickUp to Salesforce
==============================
1. Log in as the Integration User.
2. Grant the Integration User access to the dashboard - timelog (admin).
3. Select the required User and Date Range, click ... -> export.
4. In the exported CSV, remove duplicate task IDs
  (it's easier to do this by saving the file in Excel format, selecting the Task ID column -> Data -> Delete duplicates).
5. Add the resulting list of IDs to the Set<String> taskIds in the script.
6. Execute the script:
Set<String> taskIds = new Set<String>{
        //clickUp task ids here
};
Set<string> handledIds = new Set<String>();
try {
    for (String taskId : taskIds) {
        ClickUpAPIService.upsertTaskAndTimeTracked(id);
        handledIds.add(id);
    }
} catch (Exception e) {
    ClickUpAPIService.logInfo('Got exception: ' + e.getMessage() + ', ' + e.getStackTraceString(), 'ClickUp: ' + 'upsertTaskAndTimeTracked');
}
finally {
    ClickUpAPIService.logInfo('Handled ids: ' + handledIds, 'ClickUp: ' + 'upsertTaskAndTimeTracked handled ids: '+ handledIds.size());
    ClickUpAPIService.flushLogs();
}
7. Verify that everything was successful by matching the hours in the reports and(or) SOQL query:
   SELECT Id, Request__c, Error__c, CreatedDate
   FROM Log__c
   ORDER BY CreatedDate DESC
*/