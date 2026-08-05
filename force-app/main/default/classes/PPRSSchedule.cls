/**
 * Created by kirillreutski on 3.09.24.
 */

public without sharing class PPRSSchedule implements Schedulable {
    public void execute(SchedulableContext param1) {
        // get scheduled settings
        List<PPRS_SObject_Setting__mdt> settingsToHandle = getSettingsToHandle();

        throw new PPRSException('Not implemented yet');
    }

    public static List<PPRS_SObject_Setting__mdt> getSettingsToHandle() {
        String currentDayOfWeekS = Datetime.now().format('u');
        Integer currentDayOfWeek = Integer.valueOf(currentDayOfWeekS);
        Integer currentDayOfMonth = Datetime.now().day();
        List<PPRS_SObject_Setting__mdt> settingsToHandle = new List<PPRS_SObject_Setting__mdt>();

        for (PPRS_SObject_Setting__mdt setting : PPRSSettings.settingsMdt) {
            if (setting.Schedulable__c) {
                if (setting.Schedulable_Period__c == 'daily') settingsToHandle.add(setting);
                else if (setting.Schedulable_Period__c == 'monthly') {
                    if (currentDayOfMonth == setting.Schedulable_Day__c) settingsToHandle.add(setting);
                }
                else if (setting.Schedulable_Period__c == 'weekly') {
                    if (currentDayOfWeek == setting.Schedulable_Day__c) settingsToHandle.add(setting);
                }
            }
        }

        return settingsToHandle;
    }
}