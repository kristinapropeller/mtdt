/**
 * Created by kirillreutski on 20.09.24.
 */

public without sharing class PPRSLogger implements IPPRSLogger {
    public static final String SEVERITY_EXCEPTION = 'exception';
    public static final String SEVERITY_ERROR = 'error';
    public static final String SEVERITY_WARNING = 'warning';
    public static final String SEVERITY_INFO = 'info';
    public static final String SEVERITY_DEBUG = 'debug';

    private static List<Map<String, Object>> currentLogs = new List<Map<String, Object>>();
    public void log(String level, String module, String marker, Object anyData) {
        currentLogs.add(prepareRecord(level, module, marker, anyData));
    }

    public void store(){
        //insert currentLogs;
        currentLogs.clear();
    }

    public Integer getLogsCount() {
        return currentLogs.size();
    }

    private static Map<String, Object> prepareRecord(String level, String module, String marker, Object anyData) {
        return new Map<String, Object>{
                'severity' => getSeverityLevel(level),
                'timestamp' => Datetime.now(),
                'module' => module,
                'marker' => marker,
                'data' => String.valueOf(anyData).left(131072)
        };
    }

    private static Integer getSeverityLevel(String level) {
        if (level == SEVERITY_DEBUG) return 4;
        if (level == SEVERITY_INFO) return 3;
        if (level == SEVERITY_WARNING) return 2;
        if (level == SEVERITY_ERROR) return 1;
        if (level == SEVERITY_EXCEPTION) return 0;

        return 0;
    }

    public static IPPRSLogger instance {
        get {
            if (instance == null) {
                Type t = Type.forName(PPRSSettings.loggerClass);
                instance = (IPPRSLogger) t.newInstance();
            }

            return instance;
        } private set;
    }
}