/**
 * Created by kirillreutski on 2.09.24.
 */

public without sharing class PPRSSyncBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Queueable {
    private List<SObject> recordsInBatch = null;

    public static void run(List<SObject> records) {
        PPRSSyncBatch handler = new PPRSSyncBatch(records);
        Database.executeBatch(handler, (Integer) PPRSSettings.batchSize);
    }

    public PPRSSyncBatch(List<SObject> records) {
        recordsInBatch = PPRS.filterRecordsToSync(records);
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        return recordsInBatch;
    }

    public void execute(Database.BatchableContext param1, List<SObject> param2) {
        PPRS.getInstance().sync(param2, true);
    }

    public void execute(QueueableContext param1) {
        PPRS.getInstance().sync(recordsInBatch, true);
    }

    public void finish(Database.BatchableContext param1) {

    }
}