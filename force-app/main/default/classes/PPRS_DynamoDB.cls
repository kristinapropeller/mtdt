/**
 * Created by kirillreutski on 31.08.24.
 */

public without sharing class PPRS_DynamoDB extends PPRS {
    //https://kb.sdocs.com/knowledge-base/sdocs/integrations/configure-aws-with-named-credentials/
    //https://trailhead.salesforce.com/trailblazer-community/feed/0D54V00007T4UQgSAN
    // grant access to user!

    public static Boolean alwaysBatch = false;
    private static String getPartitionKey(SObjectType sObjectType) {
        return PPRSSettings.sObjectSettingsMap.containsKey(sObjectType) ? PPRSSettings.sObjectSettingsMap.get(sObjectType).dynamoPartitionKey : null;
    }

    private static String getTableName(SObjectType sObjectType) {
        return PPRSSettings.sObjectSettingsMap.containsKey(sObjectType) ? PPRSSettings.sObjectSettingsMap.get(sObjectType).dynamoTableName : null;
    }

    private static SObjectField getLastSyncedField(SObjectType sObjectType){
        return PPRSSettings.sObjectSettingsMap.containsKey(sObjectType) ? PPRSSettings.sObjectSettingsMap.get(sObjectType).lastSyncedField : null;
    }

    public override List<SObject> sync(List<SObject> records, Boolean doUpdate) {

        if (records.size() == 0) return records;
        String tableName = getTableName(records[0].getSObjectType());
        if (tableName == null) {
            throw new PPRSException('Table name not specified!');
        }
        // chunks max by 25 records, move to settings
        if (alwaysBatch || records.size() > PPRSSettings.batchSize) {
            debug('Running in batch: ' + records.size() + ' vs limit=' + PPRSSettings.batchSize);
            PPRSSyncBatch.run(records);
            return null;
        }
        List<Map<String, Object>> casted = new List<Map<String, Object>>();
        debug('tableName: ' + tableName);
        for (SObject record : records) {
            Map<String, Object> line = prepareAsPutItem(record);
            if (line != null) casted.add(line);
        }
        Map<String, List<Object>> forTable = new Map<String, List<Object>>();
        forTable.put(tableName, casted);

        Map<String, Object> body = new Map<String, Object>();
        body.put('RequestItems', forTable);
        body.put('ReturnConsumedCapacity', 'TOTAL');

        try {
            doRequest(JSON.serialize(body), tableName);
            if (doUpdate) {
                Map<Id, SObject> recordsToStore = new Map<Id, SObject>(populateLastSyncedFields(records));

                if (recordsToStore.size() > 0) {
                    PPRS.markAsSynced(recordsToStore.keySet());
                }
            }
        } catch (PPRSException e) {
            debug('Error: ' + e.getMessage());
            throw e;
        }

        return records;
    }

    private static List<SObject> populateLastSyncedFields(List<SObject> records) {
        List<SObject> recordsToStore = new List<SObject>();

        if (records.size() == 0) return recordsToStore;
        SObjectField lastSyncedField = getLastSyncedField(records[0].getSObjectType());
        if (lastSyncedField == null) return recordsToStore;

        for (SObject record : records) {
            SObject c = record.getSObjectType().newSObject(record.Id);
            c.put(lastSyncedField, Datetime.now());
            recordsToStore.add(c);
        }
        return recordsToStore;
    }

    public static Map<String, Object> prepareAsPutItem(SObject record) {
        Map<String, Object> output = new Map<String, Object>();
        String partitionKey = getPartitionKey(record.getSObjectType());
        Map<String, Object> populatedFields = record.getPopulatedFieldsAsMap();
        for (String field : populatedFields.keySet()) {
            DisplayType t = record.getSObjectType().getDescribe().fields.getMap().get(field.toLowerCase()).getDescribe().type;
            String finalField = field.equalsIgnoreCase('id') ? partitionKey : field;
            Object fieldValue = getPreparedValueObject(populatedFields.get(field),t);
            if (fieldValue != null) output.put(finalField, fieldValue);
        }

        return output.size() > 0 ? new Map<String, Object>{'PutRequest' => new Map<String, Object>{'Item' => output}} : null;
    }

    public static Object getPreparedValueObject(Object val, DisplayType t) {
        Map<String, Object> output = new Map<String, Object>();
        if (isNumber(t)) output.put('N', String.valueOf(val));
        else output.put('S', String.valueOf(val));

        if (output.size() > 0) return output;
        return null;
    }

    private static Boolean isNumber(DisplayType dt) {
        return dt == DisplayType.LONG ||
                dt == DisplayType.INTEGER ||
                dt == DisplayType.CURRENCY;
    }

    private void doRequest(String body, String tableName){
        debug('doRequest: ' + body);
        IPPRSHttpPost client = getClient();
        String responseBody = '';
        if (Test.isRunningTest()) {
            responseBody = '{"UnprocessedItems": {}}';
        }
        else {
            HttpResponse response = client.doPost('callout:dynamoDB', new Map<String, String> {'Content-Type' => 'application/x-amz-json-1.0', 'X-Amz-Target' => 'DynamoDB_20120810.BatchWriteItem'}, body);
            responseBody = response.getBody();
        }

        Object result = JSON.deserializeUntyped(responseBody);
        Map<String, Object> parsed = (Map<String, Object>) result;
        Map<String, Object> unprocessedItems = (Map<String, Object>) parsed.get('UnprocessedItems');//new Map<String, Object>();

        if (unprocessedItems.containsKey(tableName)) {
            throw new PPRSException('There are unprocessed items for '+ tableName + ': ' + unprocessedItems);
        }
        debug('DynamoDBAnswer: ' + parsed);
    }

}