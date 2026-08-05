/**
 * Created by kirillreutski on 2.09.24.
 */

public without sharing class PPRSExport_S3 extends PPRSExport {
    public final static String  S3_CALLOUT = 'callout:S3';
    public override void upload(String exportData, String filename) {
        Map<String, String> headers = new Map<String, String> {

                'Content-Encoding' => 'UTF-8',
                'Content-type' => 'txt/csv',
                'Connection' => 'keep-alive'
        };

        IPPRSHttpPost client = PPRS.getInstance().getClient();

        String responseBody = '';
        if (Test.isRunningTest()) {

        }
        else {
            HttpResponse response = client.doPut(S3_CALLOUT + '/' + filename, headers, exportData);
            System.debug('response: ' + response.getStatusCode());
            responseBody = response.getBody();
        }
    }

    public override Boolean chunkShouldBeUploaded(){
        return cpuHalfTime() || commonResult.length() > 3 * 1024 * 1024;
    }

    private static Boolean cpuHalfTime(){
        return Limits.getCpuTime() > Limits.getLimitCpuTime() / 2;
    }
}