/**
 * Created by kirillreutski on 29.08.24.
 */
//TODO: think how to call filterRecordsToSync always
public without sharing virtual class PPRS implements IPPRS {//, Database.AllowsCallouts, Queueable

    public virtual SObjectField getIdField(SObjectType sObjectType) {
        return PPRSSettings.sObjectSettingsMap.containsKey(sObjectType) ? PPRSSettings.sObjectSettingsMap.get(sObjectType).idField : null;
    }

    public virtual SObjectField getLastSyncedField(SObjectType sObjectType) {
        return PPRSSettings.sObjectSettingsMap.containsKey(sObjectType) ? PPRSSettings.sObjectSettingsMap.get(sObjectType).lastSyncedField : null;
    }

    public SObject sync(SObject record) {
        return sync(record, true);
    }

    public SObject sync(SObject record, Boolean doUpdate) {
        return sync(new List<SObject> {record}, doUpdate)[0];
    }

    public List<SObject> sync(List<SObject> records) {
        return sync(records, true);
    }

    public void syncQueue(List<SObject> records) {
        System.enqueueJob(new PPRSSyncBatch(records));
    }

    @Future
    public static void markAsSynced(Set<Id> recordIds) {
        if (recordIds.size() == 0) return;
        List<SObject> records = new List<SObject>();
        for (Id recordId : recordIds) {
            SObjectField lastSyncedField = PPRSSettings.sObjectSettingsMap.get(recordId.getSobjectType()).lastSyncedField;
            if (lastSyncedField == null) continue;

            SObject record = recordId.getSobjectType().newSObject(recordId);
            record.put(lastSyncedField, Datetime.now());
            records.add(record);
        }

        if (records.size() > 0) {
            Database.update(records, false);
        }
    }

    public static List<SObject> filterRecordsToSync(List<SObject> records) {
        List<SObject> filtered = new List<SObject>();
        if (records.size() == 0) return filtered;
        SObjectField lastSyncedField = PPRSSettings.sObjectSettingsMap.get(records[0].getSObjectType()).lastSyncedField;
        if (lastSyncedField == null) return filtered;

        for (SObject record : records) {
            if (record.get(lastSyncedField) == null) {
                filtered.add(record);
            }
            else {
                Datetime lastSynced = (Datetime) record.get(lastSyncedField);
                Datetime lastModifiedDate = (Datetime) record.get('LastModifiedDate');
                if (lastSynced < lastModifiedDate) {
                    filtered.add(record);
                }
            }
        }
        return filtered;
    }

    public virtual List<SObject> sync(List<SObject> records, Boolean doUpdate) {
        throw new PPRSException('Not specified sync handler!');
    }

    // common constructor for any service
    public PPRS() {

    }

//    // Queue service
//    private PPRS_SObject_Setting__mdt settingToHandle = null;
//    public void SetSettingToHandle(PPRS_SObject_Setting__mdt setting) {
//        settingToHandle = setting;
//    }
//    public void execute(QueueableContext param1) {
//
//    }

    public static IPPRS getInstance() {
        return instance;
    }

    public IPPRSHttpPost getClient(){
        return client;
    }

    public static IPPRSCsvGenerator getCsvGenerator(){
        return csvGenerator;
    }

    private static IPPRSCsvGenerator csvGenerator {
        get {
            if (csvGenerator == null) {
                Type t = Type.forName(PPRSSettings.csvGeneratorClass);
                csvGenerator = (IPPRSCsvGenerator) t.newInstance();
            }
            return csvGenerator;
        } private set;
    }

    private static IPPRSHttpPost client {
        get {
            if (client == null) {
                Type t = Type.forName(PPRSSettings.requestClass);
                client = (IPPRSHttpPost) t.newInstance();
            }

            return client;
        } private set;
    }

    private static IPPRS instance {
        get {
            if (instance == null) {
                Type t = Type.forName(PPRSSettings.syncClass);
                instance = (IPPRS) t.newInstance();
            }

            return instance;
        } private set;
    }

    public void debug(Object message) {
        if (PPRSSettings.verbose) System.debug(message);
    }


}