/**
 * Created by kirillreutski on 11.09.24.
 */

@IsTest
private class PPRS_Test {
    @IsTest
    static void instantiateTest() {
        IPPRS instance = PPRS.getInstance();
        System.assert(instance != null);
    }

    @IsTest
    static void instantiateHttpClient() {
        IPPRSHttpPost httpInstance = PPRS.getInstance().getClient();
        System.assert(httpInstance != null);
    }

    @IsTest
    static void instantiateCSVGenerator(){
        IPPRSCsvGenerator csvGenerator = PPRS.getCsvGenerator();
        System.assert(csvGenerator != null);
    }

    @IsTest
    static void AWS_dynamoDB_batch(){
        IPPRS dynamoDBInstance = new PPRS_DynamoDB();
        List<Contact> contacts = generateTestContacts(Integer.valueOf(PPRSSettings.batchSize));
        insert contacts;
        Test.startTest();
        PPRSSettings.sObjectSettingsMap.put(
                Contact.SObjectType,
                new PPRSSettings.SObjectSetting(
                        new PPRS_SObject_Setting__mdt(
                                SObjectType__c = 'Contact',
                                Id_Field__c = 'Synced_Id__c',
                                Last_Synced_Field__c = 'Last_Synced__c',
                                DynamoDB_Table_Name__c = 'backup',
                                DynamoDB_Partition_Key__c = 'partition_id'
                        )
                )
        );
//        PPRS_DynamoDB.alwaysBatch = true;
        //List<Contact> resultContacts = dynamoDBInstance.sync(contacts);
        PPRSSyncBatch.run(contacts);
        Test.stopTest();

    }

    @IsTest
    static void PPRSSyncBatch_dummy(){
        List<Contact> contacts = generateTestContacts(Integer.valueOf(PPRSSettings.batchSize));
        insert contacts;
        PPRSSettings.sObjectSettingsMap.put(
                Contact.SObjectType,
                new PPRSSettings.SObjectSetting(
                        new PPRS_SObject_Setting__mdt(
                                SObjectType__c = 'Contact',
                                Id_Field__c = 'Synced_Id__c',
                                Last_Synced_Field__c = 'Last_Synced__c',
                                DynamoDB_Table_Name__c = 'backup',
                                DynamoDB_Partition_Key__c = 'partition_id'
                        )
                )
        );

        Test.startTest();
        PPRSSyncBatch dynamoDBInstance = new PPRSSyncBatch(contacts);
        dynamoDBInstance.execute(null, contacts);
        dynamoDBInstance.execute(null);
        Test.stopTest();
    }

    @IsTest
    static void AWS_dynamoDB(){
        IPPRS dynamoDBInstance = new PPRS_DynamoDB();
        List<Contact> contacts = generateTestContacts(Integer.valueOf(PPRSSettings.batchSize));
        insert contacts;
        Test.startTest();
        PPRSSettings.sObjectSettingsMap.put(
                Contact.SObjectType,
                new PPRSSettings.SObjectSetting(
                        new PPRS_SObject_Setting__mdt(
                                SObjectType__c = 'Contact',
                                Id_Field__c = 'Synced_Id__c',
                                Last_Synced_Field__c = 'Last_Synced__c',
                                DynamoDB_Table_Name__c = 'backup',
                                DynamoDB_Partition_Key__c = 'partition_id'
                        )
                )
        );
        List<Contact> resultContacts = dynamoDBInstance.sync(contacts);
        Test.stopTest();

        System.assert(resultContacts != null);
    }

    @IsTest
    static void MongoDB(){
        IPPRS mongoDB = new PPRS_MongoDB();
        List<Contact> contacts = generateTestContacts(1);//Integer.valueOf(PPRSSettings.batchSize)
        insert contacts;
        Test.startTest();
        PPRSSettings.sObjectSettingsMap.put(
                Contact.SObjectType,
                new PPRSSettings.SObjectSetting(
                        new PPRS_SObject_Setting__mdt(
                                SObjectType__c = 'Contact',
                                Id_Field__c = 'LastName',
                                Last_Synced_Field__c = 'Last_Synced__c'
                        )
                )
        );
        List<Contact> resultContacts = mongoDB.sync(contacts);
        Test.stopTest();

        System.assert(resultContacts != null);
    }

    @IsTest
    static void markAsSynced(){
        PPRSSettings.sObjectSettingsMap.put(
                Contact.SObjectType,
                new PPRSSettings.SObjectSetting(
                        new PPRS_SObject_Setting__mdt(
                                SObjectType__c = 'Contact',
                                Id_Field__c = 'Synced_Id__c',
                                Last_Synced_Field__c = 'Last_Synced__c',
                                DynamoDB_Table_Name__c = 'backup',
                                DynamoDB_Partition_Key__c = 'partition_id'
                        )
                )
        );
        Contact contact = new Contact(LastName = 'Test Contact');
        insert contact;
        Test.startTest();
        try {
            PPRS.markAsSynced(new Set<Id>{contact.Id});
        }
        catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void filtering(){
        PPRSSettings.sObjectSettingsMap.put(
                Contact.SObjectType,
                new PPRSSettings.SObjectSetting(
                        new PPRS_SObject_Setting__mdt(
                                SObjectType__c = 'Contact',
                                Id_Field__c = 'Synced_Id__c',
                                Last_Synced_Field__c = 'LastModifiedDate',
                                DynamoDB_Table_Name__c = 'backup',
                                DynamoDB_Partition_Key__c = 'partition_id'
                        )
                )
        );
        Contact contact = new Contact(LastName = 'Test Contact');
        insert contact;
        List<Contact> contacts = [SELECT Id, LastModifiedDate FROM Contact];
        System.assert(PPRS.filterRecordsToSync(contacts).size() == 0);
    }



    @IsTest
    static void getIdField(){
        PPRS dynamoDBInstance = new PPRS_DynamoDB();
        PPRSSettings.sObjectSettingsMap.put(
                Contact.SObjectType,
                new PPRSSettings.SObjectSetting(
                        new PPRS_SObject_Setting__mdt(
                                SObjectType__c = 'Contact',
                                Id_Field__c = 'Synced_Id__c',
                                Last_Synced_Field__c = 'Last_Synced__c',
                                DynamoDB_Table_Name__c = 'backup',
                                DynamoDB_Partition_Key__c = 'partition_id'
                        )
                )
        );
        Boolean errorsCaught = false;
        try {
            dynamoDBInstance.getIdField(Contact.SObjectType);
            dynamoDBInstance.getLastSyncedField(Contact.SObjectType);
        } catch (Exception e) {
            errorsCaught = true;
        } finally {
            System.assert(!errorsCaught);
        }

    }

    private static List<Contact> generateTestContacts(Integer amount){
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i< amount; i ++) {
            contacts.add(new Contact(LastName = 'Test contact ' + i));
        }

        return contacts;
    }


    // chatGPT tests
    @IsTest
    static void testPrepareInsertBody() {
        List<SObject> records = new List<SObject>();
        records.add(new Contact(LastName = 'Test Contact'));
        Object result = PPRS_MongoDB.prepareInsertBody(records);
        System.assert(result != null);
        System.assert(result instanceof Map<String, Object>);
        Map<String, Object> resultMap = (Map<String, Object>) result;
        System.assert(resultMap.containsKey('collection'));
        System.assert(resultMap.containsKey('database'));
        System.assert(resultMap.containsKey('dataSource'));
        System.assert(resultMap.containsKey('documents'));
    }

    @IsTest
    static void testPrepareDeleteBody() {
        Set<String> ids = new Set<String>();
        ids.add('1234567890');
        Object result = PPRS_MongoDB.prepareDeleteBody(ids);
        System.assert(result != null);
        System.assert(result instanceof Map<String, Object>);
        Map<String, Object> resultMap = (Map<String, Object>) result;
        System.assert(resultMap.containsKey('collection'));
        System.assert(resultMap.containsKey('database'));
        System.assert(resultMap.containsKey('dataSource'));
        System.assert(resultMap.containsKey('filter'));
    }

    @IsTest
    static void testGetMongoSettings() {
        PPRS_MongoDB_Setting__mdt mongoSettings = PPRS_MongoDB.mongoSettings;
        System.assert(mongoSettings != null);
        System.assert(mongoSettings.Api_Key__c != null);
        System.assert(mongoSettings.Collection__c != null);
        System.assert(mongoSettings.Database__c != null);
        System.assert(mongoSettings.Data_Source__c != null);
        System.assert(mongoSettings.URL__c != null);
    }

    @IsTest
    static void testGetSortedRecordsVO() {
        List<SObject> records = new List<SObject>();
        records.add(new Contact(LastName = 'Test Contact'));
        records.add(new Contact(LastName = 'Test Contact 2'));
        PPRS_MongoDB.SortedRecordsVO sortedRecords = new PPRS_MongoDB.SortedRecordsVO(records, Contact.Id);
        System.debug(sortedRecords.toInsert.size());
        System.debug(sortedRecords.toUpdate.size());
        System.assert(sortedRecords.toInsert.size() == 2);
        System.assert(sortedRecords.toUpdate.size() == 0);
    }

    // CSV Generator
    @IsTest
    static void testGenerateEmptyRecords() {
        IPPRSCsvGenerator csvGenerator = PPRS.getCsvGenerator();
        List<SObject> records = new List<SObject>();
        String result = csvGenerator.generate(records);
        System.assert(result == '');
    }

    @IsTest
    static void testGenerateSingleRecord() {
        List<SObject> records = new List<SObject>();
        records.add(new Contact(LastName = 'Test Contact'));
        IPPRSCsvGenerator csvGenerator = PPRS.getCsvGenerator();
        String result = csvGenerator.generate(records);
        System.debug('result: ' + result);
        System.assert(result != '');
        System.assert(result.containsIgnoreCase('LastName'));
        System.assert(result.contains('Test Contact'));
    }

    @IsTest
    static void testGenerateMultipleRecords() {
        List<SObject> records = new List<SObject>();
        records.add(new Contact(LastName = 'Test Contact 1'));
        records.add(new Contact(LastName = 'Test Contact 2'));
        IPPRSCsvGenerator csvGenerator = PPRS.getCsvGenerator();
        String result = csvGenerator.generate(records);
        System.assert(result != '');
        System.assert(result.containsIgnoreCase('LastName'));
        System.assert(result.contains('Test Contact 1'));
        System.assert(result.contains('Test Contact 2'));
    }


    @IsTest
    static void testGenerateWithSeparator() {
        List<SObject> records = new List<SObject>();
        records.add(new Contact(LastName = 'Test Contact'));
        String separator = '|';
        IPPRSCsvGenerator csvGenerator = PPRS.getCsvGenerator();
        String result = csvGenerator.generate(records, null, separator);
        System.assert(result != '');
        System.assert(result.contains('|'));
        System.assert(result.contains('Test Contact'));
    }

    @IsTest
    static void testGenerateWithAddHeader() {
        List<SObject> records = new List<SObject>();
        records.add(new Contact(LastName = 'Test Contact'));
        Boolean addHeader = false;
        IPPRSCsvGenerator csvGenerator = PPRS.getCsvGenerator();
        String result = csvGenerator.generate(records, null, null, addHeader);
        System.assert(result != '');
        System.assert(!result.contains('LastName'));
        System.assert(result.contains('Test Contact'));
    }


    // PPRSExport_S3
    @IsTest
    static void testExportRecords() {
        List<SObject> records = new List<SObject>();
        records.add(new Contact(LastName = 'Test Contact'));
        String exportType = 'CSV';
        Test.startTest();
        PPRSExport_S3.export(Contact.SObjectType, new Set<String>{'LastName'}, exportType);

        Test.stopTest();
    }

    @IsTest
    static void PPRSExportBatchTest(){
        PPRSExport e = new PPRSExport_S3();
        List<Contact> contacts = generateTestContacts(1);//Integer.valueOf(PPRSSettings.batchSize)
        insert contacts;
        Test.startTest();
        PPRSSettings.sObjectSettingsMap.put(
                Contact.SObjectType,
                new PPRSSettings.SObjectSetting(
                        new PPRS_SObject_Setting__mdt(
                                SObjectType__c = 'Contact',
                                Id_Field__c = 'LastName',
                                Last_Synced_Field__c = 'Last_Synced__c'
                        )
                )
        );

        e.execute(null, contacts);
    }


    @IsTest
    static void PPRSHttpPost(){
        PPRSHttpPost client = new PPRSHttpPost();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        HttpResponse response = client.doPost('https://httpbin.org/anything',  headers, '{"test": "test"}');
        System.assert(response.getStatusCode() == 200);
    }

    @IsTest
    static void logger(){
        PPRSLogger logger = new PPRSLogger();
        logger.log(PPRSLogger.SEVERITY_WARNING, 'test', 'test', 'test');
        logger.log(PPRSLogger.SEVERITY_ERROR, 'test', 'test', 'test');
        logger.log(PPRSLogger.SEVERITY_EXCEPTION, 'test', 'test', 'test');
        logger.log(PPRSLogger.SEVERITY_INFO, 'test', 'test', 'test');
        logger.log(PPRSLogger.SEVERITY_DEBUG, 'test', 'test', 'test');
        System.assert(logger.getLogsCount() == 5);
        logger.store();

        System.assert(logger.getLogsCount() == 0);
    }

    @IsTest
    static void scheduler(){
        PPRSSettings.settingsMdt.add(new PPRS_SObject_Setting__mdt(
                SObjectType__c = 'Contact',
                Id_Field__c = 'LastName',
                Last_Synced_Field__c = 'Last_Synced__c',
                Schedulable__c = true,
                Schedulable_Period__c = 'daily'
        ));

        Integer currentDayOfMonth = Datetime.now().day();
        String currentDayOfWeekS = Datetime.now().format('u');
        Integer currentDayOfWeek = Integer.valueOf(currentDayOfWeekS);

        PPRSSettings.settingsMdt.add(new PPRS_SObject_Setting__mdt(
                SObjectType__c = 'Contact',
                Id_Field__c = 'LastName',
                Last_Synced_Field__c = 'Last_Synced__c',
                Schedulable__c = true,
                Schedulable_Period__c = 'monthly',
                Schedulable_Day__c = currentDayOfMonth
        ));
        PPRSSettings.settingsMdt.add(new PPRS_SObject_Setting__mdt(
                SObjectType__c = 'Contact',
                Id_Field__c = 'LastName',
                Last_Synced_Field__c = 'Last_Synced__c',
                Schedulable__c = true,
                Schedulable_Period__c = 'weekly',
                Schedulable_Day__c = currentDayOfWeek
        ));
        System.assert(PPRSSchedule.getSettingsToHandle().size() == 3);

    }




    @IsTest
    static void exception(){
        try {
            throw new PPRSException('test');
        } catch (PPRSException e) {
            System.assert(e.getMessage().contains('test'));
        }
    }

    @IsTest
    static void PPRSTools_prepareRequest(){
        HttpRequest request = PPRSTools.prepareRequest(Contact.SObjectType, 'POST', null);
        System.assert(request != null);
        System.assert(request.getMethod() == 'POST');
        System.debug('Request body: ' + request.getBody());
        System.assert(request.getBody().contains('PPRS_' + Contact.SObjectType.toString() + 'Trigger'));
        System.assert(request.getBody().contains('(after insert, after update)'));
    }

    @IsTest
    static void PPRSTools_upsertTrigger(){
        System.assert(PPRSTools.upsertTrigger(Contact.SObjectType) == true);
    }

    @IsTest
    static void PPRSTools_deleteTrigger(){
        System.assert(PPRSTools.deleteTrigger(Contact.SObjectType) == true);
    }
    @IsTest
    static void PPRSTools_deleteTriggerFail(){
        PPRSTools.TEST_responseStatusCode = 404;
        System.assert(PPRSTools.deleteTrigger(Contact.SObjectType) == false);
    }
    @IsTest
    static void PPRSTools_updateTrigger(){
        System.assert(PPRSTools.updateTrigger(Contact.SObjectType, 'test').getStatusCode() == 201);
    }

}