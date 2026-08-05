/**
 * Created by kirillreutski on 2.09.24.
 */

public without sharing class PPRSSettings {
    public static final Integer maxFileSizeInBytes = 1000;

    public static final String requestClass {
        get {return pprsGeneralSetting == null || String.isEmpty(pprsGeneralSetting.Request_Class__c) ? 'PPRSHttpPost' : pprsGeneralSetting.Request_Class__c;}
    }
    public static final String syncClass {
        get {return pprsGeneralSetting == null || String.isEmpty(pprsGeneralSetting.Sync_Class__c) ? 'PPRS_MongoDB' : pprsGeneralSetting.Sync_Class__c;}
    }
    public static final String csvGeneratorClass {
        get {return pprsGeneralSetting == null || String.isEmpty(pprsGeneralSetting.Csv_Generator_Class__c) ? 'PPRSCsvGenerator' : pprsGeneralSetting.Csv_Generator_Class__c;}
    }
    public static final String loggerClass {
        get {return pprsGeneralSetting == null || String.isEmpty(pprsGeneralSetting.Logger_Class__c) ? 'PPRSLogger' : pprsGeneralSetting.Logger_Class__c;}
    }
    public static final String exportClass {
        get {return 'PPRSExport_S3';
                //pprsGeneralSetting == null || String.isEmpty(pprsGeneralSetting.Sync_Class__c) ? 'PPRS_MongoDB' : pprsGeneralSetting.Sync_Class__c;
        }
    }

    public static final Decimal batchSize {
        get {
            Decimal result = pprsGeneralSetting?.Chunk_Size__c == null ? 25 : pprsGeneralSetting.Chunk_Size__c;
            return result;
        }
    }

//    public static void injectSettings(List<PPRS_SObject_Setting__mdt> settings) {
//        settingsMdt.add();
//    }

    public static List<PPRS_SObject_Setting__mdt> settingsMdt {
        get {
            if (settingsMdt == null) {

                String query = 'SELECT ' +
                        String.join(
                                new List<String>(
                                        PPRS_SObject_Setting__mdt.getSObjectType().getDescribe().fields.getMap().keySet()
                                ), ', ') +
                        ' FROM PPRS_SObject_Setting__mdt';

                settingsMdt = Database.query(query);
            }
            return settingsMdt;
        } private set;
    }

    public class SObjectSetting {
        public SObjectType sObjectType;
        public SObjectField idField;
        public SObjectField lastSyncedField;
        public String dynamoTableName;
        public String dynamoPartitionKey;

        public SObjectSetting(PPRS_SObject_Setting__mdt s) {
            Init(
                    s.SObjectType__c,
                    s.Id_Field__c,
                    s.Last_Synced_Field__c,
                    s.DynamoDB_Table_Name__c,
                    s.DynamoDB_Partition_Key__c
            );
        }
        private void Init(
                String sObjectName,
                String idFieldName,
                String lastSyncedFieldName,
                String dynamoDbTableName,
                String dynamoDbPartitionKey) {
            sObjectType = Schema.getGlobalDescribe().get(sObjectName);

            if (idFieldName != null) {
                if (sObjectType.getDescribe().fields.getMap().containsKey(idFieldName.toLowerCase())) {
                    idField = sObjectType.getDescribe().fields.getMap().get(idFieldName.toLowerCase());
                }
            }

            if (lastSyncedFieldName != null) {
                if (sObjectType.getDescribe().fields.getMap().containsKey(lastSyncedFieldName.toLowerCase())) {
                    lastSyncedField = sObjectType.getDescribe().fields.getMap().get(lastSyncedFieldName.toLowerCase());
                }
            }

            dynamoTableName = dynamoDbTableName;
            dynamoPartitionKey = dynamoDbPartitionKey;
        }
    }

    public static Boolean verbose {
        get {
            return true;
        }
    }

    public static PPRS_General_Settings__mdt pprsGeneralSetting {
        get {
            if (pprsGeneralSetting == null) {
                List<PPRS_General_Settings__mdt> settings = [SELECT Id, Request_Class__c, Sync_Class__c, Chunk_Size__c, Csv_Generator_Class__c, Logger_Class__c FROM PPRS_General_Settings__mdt WHERE Active__c = TRUE LIMIT 1];
                if (settings.size() == 1) pprsGeneralSetting = settings[0];
            }

            return pprsGeneralSetting;
        } private set;
    }

    public static Map<SObjectType, SObjectSetting> sObjectSettingsMap {
        get {
            if (sObjectSettingsMap == null) {
                sObjectSettingsMap = new Map<SObjectType, SObjectSetting>();
                for (PPRS_SObject_Setting__mdt s : settingsMdt) {
                    SObjectSetting setting = new SObjectSetting(s);
                    sObjectSettingsMap.put(setting.sObjectType, setting);
                }
            }

            return sObjectSettingsMap;
        } private set;
    }

}