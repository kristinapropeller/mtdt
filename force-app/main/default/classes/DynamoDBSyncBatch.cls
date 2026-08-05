public class DynamoDBSyncBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    public static void schedule(SObjectType sObjectType) {
        DynamoDBSyncBatch handler = new DynamoDBSyncBatch(sObjectType);
        Database.executeBatch(handler, (Integer) PPRSSettings.batchSize);
    }
    
    private SObjectType sObjectTypeToHandle = null; 
    public DynamoDBSyncBatch(SObjectType sObjectType) {
        sObjectTypeToHandle = sObjectType;    
    }
    
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return new pp_Query(sObjectTypeToHandle)
            .selectAllFields()
            .addConditionEq('Sync_Needed__c', true)
            .getQueryLocator();
    }

    public void execute(Database.BatchableContext param1, List<SObject> param2) {
        PPRS.getInstance().sync(param2, true);
    }

    public void finish(Database.BatchableContext param1) {

    }
}