@IsTest
private class DynamoDBSyncBatchTest {
    @IsTest
    static void behaviour(){
        Test.startTest();
        DynamoDBSyncBatch.schedule(Transaction__c.SObjectType);
        Test.stopTest(); 
    }
}