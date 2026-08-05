/**
 * Created by kirillreutski on 2.09.24.
 */

public interface IPPRSExport {
    void upload(String exportData, String filename);
    Boolean chunkShouldBeUploaded();
}