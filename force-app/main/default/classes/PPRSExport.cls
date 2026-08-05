/**
 * Created by kirillreutski on 2.09.24.
 */

public without sharing virtual class PPRSExport implements IPPRSExport, Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    // method initiates batch
    public static void export(SObjectType sObjectType, Set<String> columns, String postfix) {
        String query =
                'SELECT ' +
                String.join(new List<String>(columns), ', ') +
                ' FROM ' +
                sObjectType.toString() + ' ' + postfix;

        PPRS.getInstance().debug('Export started: ' + query);
        Type t = Type.forName(PPRSSettings.exportClass);
        PPRSExport handler = (PPRSExport) t.newInstance();
        handler.setQuery(query);
        handler.setHeaders(columns);
        Database.executeBatch(handler);
    }

    // method called in the end of the batch
    // this method should be overridden to implement csv upload to any other destination
    public virtual void upload(String exportData, String filename) {
        PPRS.getInstance().debug('Upload called: \n' + exportData);
    }

    // method called in the end of each chunk
    // returns true if upload should be started in the middle of the whole process,
    // e.g. check for heap or data size
    public virtual Boolean chunkShouldBeUploaded(){
        return false;
    }

    private String query = '';
    private Set<String> headers = null;
    public PPRSExport(){ }

    public void setQuery(String dbQuery) {
        query = dbQuery;
    }

    public void setHeaders(Set<String> headers) {
        this.headers = headers;
    }

    public PPRSExport(String dbQuery) {
        query = dbQuery;
    }

    public String commonResult = '';
    public Integer chunkNumber = 1;
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(query);
    }

    public String getFileName(){
        return '' +
                System.today().year() + System.today().month() + System.today().day() + '_' +
                System.now().hour() + System.now().minute() +
                (chunkNumber > 1 ? ('_' + chunkNumber) : '')
                ;
    }

    public void execute(Database.BatchableContext param1, List<SObject> records) {
        PPRS.getInstance().debug('execute called: \n' + records.size());
        String chunk = PPRS.getCsvGenerator().generate(records, headers, null);
        if (String.isEmpty(commonResult)) commonResult = chunk;
        else commonResult += '\n' + chunk;

        if (chunkShouldBeUploaded()) {
            upload(commonResult, getFileName());
            commonResult = '';
            chunkNumber ++;
        }
    }

    public static void handlePart(List<SObject> records) {

    }

    public void finish(Database.BatchableContext param1) {
        PPRS.getInstance().debug('Batchable finish: ' + commonResult);

        upload(commonResult, getFileName());
    }

}