/**
 * Created by kirillreutski on 20.09.24.
 */

public interface IPPRSLogger {
    void log(String level, String module, String marker, Object anyData);
    void store();
}