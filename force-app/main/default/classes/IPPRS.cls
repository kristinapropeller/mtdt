/**
 * Created by kirillreutski on 29.08.24.
 */

public interface IPPRS {
    SObject sync(SObject record);
    SObject sync(SObject record, Boolean doUpdate);
    List<SObject> sync(List<SObject> records);
    List<SObject> sync(List<SObject> records, Boolean doUpdate);
    void syncQueue(List<SObject> records);
    IPPRSHttpPost getClient();

    void debug(Object message);
    SObjectField getIdField(SObjectType sObjectType);
}