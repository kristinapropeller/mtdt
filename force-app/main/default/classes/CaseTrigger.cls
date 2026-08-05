/**
 * Created on 22/02/2023.
 */

public with sharing class CaseTrigger extends pp_Trap.TriggerHandler {
    public override void setUpBeforeInsert(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('before insert'))
                .tap(bulkObj.data('projects', new GetProjectsFunc()))
                .filter((pp_Func)pp_R.allPass.run(
                        pp_R.propSatisfies.apply('Project__c', pp_R.isNotNull),
                        pp_R.propSatisfies.apply('Internal_System_ID__c', pp_R.isEmpty)
                ))
                .subscribe(bulkObj.provide('projects', new SetInternalIDFunc()), null, bulkObj.provide('projects', new UpdateProjectsFunc()));
    }
    public override void setUpBeforeUpdate(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('before update'))
                .tap(bulkObj.data('projects', new GetProjectsFunc()))
                .filter((pp_Func)pp_R.propSatisfies.apply('Internal_System_ID__c', pp_R.isEmpty))
                .subscribe(bulkObj.provide('projects', new SetInternalIDFunc()), null, bulkObj.provide('projects', new UpdateProjectsFunc()));
    }
    public override void setUpAfterUpdate(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('after update'))
                .tap(bulkObj.data('projectIds', pp_R.toIdSet.apply(new Set<Id>())))
                .filter((pp_Func)pp_R.anyPass.run(
                        pp_Trap.F.changed.apply('Time_Spent__c'),
                        pp_Trap.F.changed.apply('Time_Spent_This_Month__c')
                ))
                .subscribe(bulkObj.provide('projectIds', new CollectProjectIdsFunc()), null, bulkObj.provide('projectIds', new UpdateProjectEffortsFunc()));
    }
    public override void setUpAfterDelete(pp_Trap.BulkObject bulkObj) {
        bulkObj.oldStream
                .tap(pp_R.debug.apply('after delete'))
                .tap(bulkObj.data('projectIds', pp_R.toIdSet.apply(new Set<Id>())))
                .subscribe(bulkObj.provide('projectIds', new CollectProjectIdsFunc()), null, bulkObj.provide('projectIds', new UpdateProjectEffortsFunc()));
    }



    class GetProjectsFunc extends pp_Func {
        public GetProjectsFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<SObject> newCases = ((Map<Id, SObject>)arg).values();
            return pp_R.of(new pp_Query('Project__c')
                    .selectFields(new Set<String>{'Id', 'Project_Key__c', 'sysCaseCounter__c'})
                    .addConditionNotNull('Project_Key__c')
                    .addConditionIn('Id', pp_R.of(newCases)
                            .indexBy(pp_R.prop.apply('Project__c'))
                            .toSObjectMap().keySet()
                    )
                    .run()).indexBy(pp_R.prop.apply('Id'))
                    .toSObjectMap();
        }
    }

    class SetInternalIDFunc extends pp_Func {
        public SetInternalIDFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Map<String, SObject> projects = (Map<String, SObject>)arg1;
//            R.debug.run('SetInternalIDFunc.projects', projects);
            Case c = (Case)pp_Trap.F.getNew.run(arg2);
            if (projects.containsKey(c.Project__c)) {
                Project__c p = (Project__c)projects.get(c.Project__c);
                p.sysCaseCounter__c = (p.sysCaseCounter__c != null ? p.sysCaseCounter__c : 0) + 1;

                if (String.isEmpty(c.Internal_System_ID__c)) {
                    pp_Trap.F.updateField.run('Internal_System_ID__c', p.Project_Key__c + '-' + p.sysCaseCounter__c, c);
//                    R.debug.run('c', c);
                }
                projects.put(c.Project__c, p);
            }
//            R.debug.run('SetInternalIDFunc.projects', projects);
            return projects;
        }
    }

    class UpdateProjectsFunc extends pp_Func {
        public UpdateProjectsFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, SObject> projects = (Map<String, SObject>)arg;
            pp_R.debug.run('UpdateProjectsFunc.projects', projects);
            if (!projects.isEmpty()) update projects.values();

            return null;
        }
    }

    class CollectProjectIdsFunc extends pp_Func {
        public CollectProjectIdsFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Set<Id> projectIds = (Set<Id>)arg1;
//            R.debug.run('CollectProjectIdsFunc.projectIds', projectIds);
            projectIds.add(((Case)arg2).Project__c);
            return projectIds;
        }
    }

    class UpdateProjectEffortsFunc extends pp_Func {
        public UpdateProjectEffortsFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Set<Id> projectIds = (Set<Id>)arg;
            pp_R.debug.run('UpdateProjectEffortsFunc.projectIds', projectIds);
            if (projectIds != null && !projectIds.isEmpty()) {
                Map<Id, Decimal> monthlyEfforts = this.getMonthlyEffortsByProjectId(projectIds);
                Map<Id, Decimal> totalEfforts = this.getTotalEffortsByProjectId(projectIds);
                List<Project__c> projects = new pp_Query('Project__c')
                        .selectFields(new Set<String>{'Id', 'Time_Spent__c', 'Time_Spent_This_Month__c'})
                        .byId(projectIds)
                        .run();
                for (Project__c project: projects){
                    project.put('Time_Spent__c', pp_R.defaultTo.run(0, totalEfforts.get(project.Id)));
                    project.put('Time_Spent_This_Month__c', pp_R.defaultTo.run(0, monthlyEfforts.get(project.Id)));
                }
                update projects;
            }
            return null;
        }

        private Map<Id, Decimal> getMonthlyEffortsByProjectId(Set<Id> projectIds) {
            List<AggregateResult> efforts = new pp_Query('Case')
                    .selectField('Project__c')
                    .sum('Time_Spent_This_Month__c', 'monthEffort')
                    .addConditionIn('Project__c', projectIds)
                    .groupBy('Project__c')
                    .aggregate();
            Map<Id, Decimal> projectId_timeMap = new Map<Id, Decimal>();
            for (AggregateResult e: efforts){
                projectId_timeMap.put((Id)e.get('Project__c'), (Decimal)pp_R.defaultTo.run(0, e.get('monthEffort')));
            }
            return projectId_timeMap;
        }

        private Map<Id, Decimal> getTotalEffortsByProjectId(Set<Id> projectIds) {
            List<AggregateResult> efforts = new pp_Query('Timecard__c')
                    .selectField('Case__r.Project__c', 'project')
                    .sum('Effort__c', 'effort')
                    .addConditionIn('Case__r.Project__c', projectIds)
                    .groupBy('Case__r.Project__c')
                    .aggregate();
            Map<Id, Decimal> projectId_timeMap = new Map<Id, Decimal>();
            for (AggregateResult e: efforts){
                projectId_timeMap.put((Id)e.get('project'), (Decimal)pp_R.defaultTo.run(0, e.get('effort')));
            }
            return projectId_timeMap;
        }
    }
}