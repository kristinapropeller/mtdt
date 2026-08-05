/**
 * Created on 30/07/2023.
 */

public without sharing class PDFMonkeyDocumentRoute extends pp_RestRoute {
    protected override Object doPost() {
        if (!String.isEmpty(this.resourceId)) {
            throw new pp_RestRoute.RestException('Create Operation does not support PDFMonkey Document Identifier', 'NOT_SUPPORTED', 404);
        } else {
            return parseDocument();
        }
    }


    private Object parseDocument() {
        PDFMonkeyConnector.Response response = (PDFMonkeyConnector.Response)JSON.deserialize(this.request.requestBody.toString(), PDFMonkeyConnector.Response.class);
        pp_R.debug.run(response.document);
        if (String.isNotEmpty(response.document.meta) && String.isNotEmpty(response.document.download_url)) {
            Map<String, Object> meta = (Map<String, Object>)JSON.deserializeUntyped(response.document.meta);
            if (meta.containsKey('record_id')) new pp_Async(new DownloadDocumentFunc().apply(response.document.download_url, response.document.filename, meta.get('record_id'))).fork();
        }
        return 'OK';
    }



    public class DownloadDocumentFunc extends pp_Func {
        public DownloadDocumentFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            String downloadUrl = (String)arg1;
            String filename = (String)arg2;
            String recordId = (String)arg3;
            pp_RestExplorer restExplorer = new pp_RestExplorer(downloadUrl)
                    .doGet()
                    .setTimeout(120000);
            Blob pdf = Test.isRunningTest() ? Blob.valueOf('0') : restExplorer.getBlobResult();
            ContentVersion cv = new ContentVersion();
            if (pdf != null) {
                cv = new ContentVersion(
                        Title = filename,
                        PathOnClient = filename,
                        VersionData = pdf,
                        FirstPublishLocationId = recordId,
                        IsMajorVersion = true
                );
                insert cv;
            }
            return cv.Id;
        }
    }
}