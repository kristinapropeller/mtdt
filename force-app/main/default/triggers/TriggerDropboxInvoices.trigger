Trigger TriggerDropboxInvoices on Invoice__c (after update, after delete) {
    
        if(Trigger.isAfter && Trigger.isUpdate){
            Dropbox_for_SF.HandleRecordChange.OnRecordChange(Trigger.old, Trigger.new);
        }
    
        if(Trigger.isAfter && Trigger.isDelete){
            Dropbox_for_SF.HandleRecordChange.HandleMerge(Trigger.old);
        }
    
    }