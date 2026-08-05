/**
 * Created by kirillreutski on 29.08.24.
 */

public without sharing class PPRS_MongoDB extends PPRS {
    private final static String url { get {return mongoSettings.URL__c;} }
    private final static String insertUrl { get {return url + 'action/insertMany';} }
    private final static String deleteUrl { get {return url + 'action/deleteMany';} }
    private final static String apiKey {get {return mongoSettings.Api_Key__c;}}
    private final static String collection {get {return mongoSettings.Collection__c;}}
    private final static String mongo_database {get {return mongoSettings.Database__c;}}
    private final static String dataSource {get {return mongoSettings.Data_Source__c;}}

    @TestVisible
    private static PPRS_MongoDB_Setting__mdt mongoSettings {
        get {
            if (mongoSettings == null) {
                List<PPRS_MongoDB_Setting__mdt> settings = [SELECT Id,Api_Key__c, Collection__c, Database__c, Data_Source__c, URL__c FROM PPRS_MongoDB_Setting__mdt WHERE Active__c = TRUE LIMIT 1];
                if (settings.size() == 1) mongoSettings = settings[0];
                else {
                    if (Test.isRunningTest()) {
                        mongoSettings = new PPRS_MongoDB_Setting__mdt(
                                Api_Key__c = 'random-api-key',
                                Collection__c = 'logs',
                                Database__c = 'testDB',
                                Data_Source__c = 'Cluster0',
                                URL__c = 'https://data.mongodb-api.com/app/data-somewhere/endpoint/data/v1/'
                        );
                    }
                }
            }

            return mongoSettings;
        } private set;
    }

    public override List<SObject> sync(List<SObject> records,Boolean doUpdate) {
        if (records.size() == 0) new List<SObject>();
        SObjectField idField = getIdField(records[0].getSObjectType());
        SObjectField lastSyncedField = getLastSyncedField(records[0].getSObjectType());
        SortedRecordsVO sorted = new SortedRecordsVO(records, idField);

        if (sorted.toUpdate.size() > 0) {
            PPRSHttpPost client = new PPRSHttpPost();
            Object deleteObject = prepareDeleteBody(sorted.toUpdate.keySet());
            String responseBody = '';

            if (Test.isRunningTest()) {
                responseBody = '{"deletedCount": 1, "error": ""}';
            }
            else {
                HttpResponse result = getClient().doPost(
                        deleteUrl,
                        new Map<String, String> {'api-key' => apiKey, 'Content-Type' => 'application/json'},
                        deleteObject
                );
                responseBody = result.getBody();
            }

            mongoDBDeleteResponse response = (mongoDBDeleteResponse) JSON.deserialize(responseBody, mongoDBDeleteResponse.class);
            System.debug('mongoDBDeleteResponse: ' + response);
            if (response.deletedCount != null && response.deletedCount > 0) {
                sorted.toInsert.addAll(sorted.toUpdate.values());
            }
        }

        if (sorted.toInsert.size() > 0) {
            PPRSHttpPost client = new PPRSHttpPost();
            Object insertObject = prepareInsertBody(sorted.toInsert);
            String responseBody = '';
            if (Test.isRunningTest()) {
                responseBody = '{"error":"","insertedIds":["test_id"]}';
            }
            else {
                HttpResponse result = client.doPost(
                        insertUrl,
                        new Map<String, String> {'api-key' => apiKey, 'Content-Type' => 'application/json'},
                        insertObject
                );
                responseBody = result.getBody();
            }

            mongoDBInsertResponse response = (mongoDBInsertResponse) JSON.deserialize(responseBody, mongoDBInsertResponse.class);
            System.debug('mongoDBInsertResponse: ' + response);
            System.debug('sorted.toInsert: ' + sorted.toInsert.size());
            if (idField != null) {
                for (Integer i = 0; i < sorted.toInsert.size(); i ++) {
                    sorted.toInsert[i].put(idField, response.insertedIds[i]);
                    if (lastSyncedField != null) {
                        sorted.toInsert[i].put(lastSyncedField, System.now());
                    }
                }
                if (doUpdate) {
                    Database.update(sorted.toInsert, false);
                }
            }
        }


        return records;
    }

    public class SortedRecordsVO {
        public List<SObject> toInsert = new List<SObject>();
        public Map<String, SObject> toUpdate = new Map<String, SObject>();

        public SortedRecordsVO(List<SObject> records, SObjectField idField) {
            if (idField == null) {
                toInsert = records;
            }
            else {
                for (SObject so : records) {
                    if (so.get(idField) == null) toInsert.add(so);
                    else toUpdate.put(String.valueOf(so.get(idField)), so);
                }
            }
        }
    }

    @TestVisible
    private static Object prepareInsertBody(List<SObject> records) {
        List<Object> documents = new List<Object>();
        for (SObject so : records) {
            documents.add(so.getPopulatedFieldsAsMap());
        }
        Map<String, Object> result = new Map<String, Object> {
                'collection'    => collection,
                'database'      => mongo_database,
                'dataSource'    => dataSource,
                'documents'     => documents
        };
        return result;
    }

    @TestVisible
    private static Object prepareDeleteBody(Set<String> ids) {
        List<Object> criteria = new List<Object>();
        for (String id : ids) {
            criteria.add(new Map<String, String>{'$oid' => id});
        }
        Map<String, Object> result = new Map<String, Object> {
                'collection'    => collection,
                'database'      => mongo_database,
                'dataSource'    => dataSource,
                'filter' => new Map<String, Object>{
                        '_id' => new Map<String, Object>{
                                '$in' => criteria
                        }
                }
        };
        return result;
    }

    public class mongoDBInsertResponse {
        public List<String> insertedIds {get;set;}
        public String error {get;set;}
    }
    public class mongoDBDeleteResponse {
        public Integer deletedCount {get;set;}
        public String error {get;set;}
    }
}