/**
 * Created by artsiomartsiomenka on 03/04/2024.
 */

public without sharing class ClickUpTaskRoute extends pp_RestRoute{
    protected override Object doPost() {
        if (!String.isEmpty(this.resourceId)) {
            throw new pp_RestRoute.RestException('Create Operation does not support Identifier', 'NOT_SUPPORTED', 404);
        } else {
            return handleTask();
        }
    }

    private static Object handleTask() {
        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();
        System.debug('***requestBody: '+requestBody);

        pp_Mapper.DTO taskWhDto = new pp_Mapper.DTO(requestBody);

        Map<String,Object> data = new Map<String, String>();
        String description = '';
        String intervalId = '';
        String clickUpTaskId = (String) taskWhDto.getString('task_id');
        String clickUpEvent = (String) taskWhDto.getString('event');
        if (taskWhDto.containsPath('data')) {
            data = (Map<String,Object>) taskWhDto.getMap('data');
            description = (String) data.get('description');
            intervalId = (String) data.get('interval_id');
        }

        System.debug('***clickUpTaskId '+clickUpTaskId);
        System.debug('***clickUpEvent '+clickUpEvent);
        System.debug('***updateDescription: '+description);
        System.debug('***interval_id: '+intervalId);

        if (!String.isBlank(clickUpTaskId) && !String.isBlank(clickUpEvent)) {
            switch on clickUpEvent {
                when 'taskTimeTrackedUpdated' {
                    switch on description {
                        when 'Time Tracking Created', 'Time Tracking Edited' {
                            ClickUpAPIService.upsertTimeTracked(clickUpTaskId);
                        }
                        when 'Time Tracking Deleted' {
                            if (!String.isBlank(intervalId)) ClickUpAPIService.deleteTimeTracked(intervalId);
                        }
                    }
                }
                when 'taskCreated' {
                    ClickUpAPIService.upsertTask(clickUpTaskId);
                }
                when 'taskUpdated' {
                    if (String.isBlank(description)) ClickUpAPIService.upsertTask(clickUpTaskId);
                }
                when 'taskDeleted' {
                    ClickUpAPIService.handleTaskDeleted(clickUpTaskId);
                }
            }
        }
        return 'OK';
    }
}