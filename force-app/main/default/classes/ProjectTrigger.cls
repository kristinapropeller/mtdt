/**
 * Created on 03/01/2023.
 */

public with sharing class ProjectTrigger extends pp_Trap.TriggerHandler {
    public override void setUpAfterUpdate(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('after update'))
                .tap(bulkObj.data('projectIds', pp_R.toIdSet.apply(new Set<Id>())))
                .filter((pp_Func)pp_R.allPass.run(
                        pp_R.propSatisfies.apply('Project_Key__c', pp_R.isNotEmpty),
                        pp_Trap.F.changed.apply('Project_Key__c')
                ))
                .subscribe(bulkObj.provide('projectIds', new CollectProjectIdsFunc()), null, bulkObj.provide('projectIds', new UpdateCasesFunc()));
    }



    class CollectProjectIdsFunc extends pp_Func {
        public CollectProjectIdsFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Set<Id> projectIds = (Set<Id>)arg1;
            projectIds.add(((Project__c)arg2).Id);
            return projectIds;
        }
    }
    class UpdateCasesFunc extends pp_Func {
        public UpdateCasesFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Set<Id> projectIds = (Set<Id>)arg;
            pp_Trap.getInstance().disable('Project__c');
            update new pp_Query('Case')
                    .addConditionIn('Project__c', projectIds)
                    .addConditionNull('Internal_System_ID__c')
                    .orderBy('CreatedDate', 'ASC')
                    .setLimit(10000)
                    .run();
            pp_Trap.getInstance().enable('Project__c');
            return null;
        }
    }
}