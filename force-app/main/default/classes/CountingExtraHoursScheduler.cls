/**
 * Created on 27.03.23.
 */

global class CountingExtraHoursScheduler implements Schedulable {

    /**
        System.schedule('Counting Extra Hours Scheduler', '0 0 12 1 * ?', new CountingExtraHoursScheduler());
    */

    public static Map<String, Integer> amountWorkingDaysByMonthBY {
        get {
            if (amountWorkingDaysByMonthBY == null) {
                amountWorkingDaysByMonthBY = new Map<String, Integer>();
                Setting__c setting = Setting__c.getOrgDefaults();
                if (setting != null && String.isNotEmpty(setting.Working_Days__c)) {
                    for (String workingDay : setting.Working_Days__c.split(';')) {
                        amountWorkingDaysByMonthBY.put(workingDay.split('=')[0], Integer.valueOf(workingDay.split('=')[1]));
                    }
                }
            }
            return amountWorkingDaysByMonthBY;
        }
        private set;
    }

    public static Map<String, Integer> amountWorkingDaysByMonthPL {
        get {
            if (amountWorkingDaysByMonthPL == null) {
                amountWorkingDaysByMonthPL = new Map<String, Integer>();
                Setting__c setting = Setting__c.getOrgDefaults();
                if (setting != null && String.isNotEmpty(setting.Working_Days_PL__c)) {
                    for (String workingDay : setting.Working_Days_PL__c.split(';')) {
                        amountWorkingDaysByMonthPL.put(workingDay.split('=')[0], Integer.valueOf(workingDay.split('=')[1]));
                    }
                }
            }
            return amountWorkingDaysByMonthPL;
        }
        private set;
    }

    global void execute(SchedulableContext sc) {
        try {
            List<Compensation__c> compensationsToInsert = new List<Compensation__c>();
            String lastMonth = System.now().addMonths(-1).format('MMMM');

            List<AggregateResult> efforts = new pp_Query('Timecard__c')
                    .selectField('Person__c')
                    .sum('Effort__c', 'monthEffort')
                    .addConditionEq('Work_Date__c', pp_Query.LAST_MONTH)
                    .groupBy('Person__c')
                    .aggregate();
            Set<Id> contactIds = new Set<Id>();
            for (AggregateResult ar : efforts) {
                contactIds.add((Id) ar.get('Person__c'));
            }

            List<Contact> contacts = new pp_Query('Contact')
                    .selectFields(new Set<String>{'Id', 'Country_Code__c', 'Workload__c', 'Salary__c'})
                    .addSubquery(
                            pp_Query.subquery('Vacations__r')
                                    .selectFields(new Set<String> {'Id', 'Vacation_Start_Date__c', 'Vacation_End_Date__c'})
                                    .addCondition(
                                            pp_Query.doAnd(
                                                    pp_Query.conditionEq('Status__c', 'Past'),
                                                    pp_Query.doOr(
                                                            pp_Query.conditionEq('Vacation_Start_Date__c', pp_Query.LAST_MONTH),
                                                            pp_Query.conditionEq('Vacation_End_Date__c', pp_Query.LAST_MONTH)
                                                    )
                                            )
                                    )
                    )
                    .addConditionEq('Id', contactIds)
                    .run();
            Map<Id, Contact> contactsByIds = new Map<Id, Contact>(contacts);
            for (AggregateResult ar : efforts) {
                Decimal monthEffort = (Decimal) ar.get('monthEffort');
                Id personId = (Id) ar.get('Person__c');
                if(!contactsByIds.containsKey(personId)) continue;

                Decimal rate = contactsByIds.get(personId).Salary__c != null ? contactsByIds.get(personId).Salary__c / 160 : 12.5;

                Set<Integer> vacationDays = contactsByIds.get(personId).Vacations__r.size() != 0
                        ? collectVacationDays(contactsByIds.get(personId).Vacations__r)
                        : new Set<Integer>();

                Integer planEffort = getPlanEffortWithoutVacations(vacationDays);

                if(String.isNotEmpty(contactsByIds.get(personId).Workload__c) && contactsByIds.get(personId).Workload__c == 'Part-time') {
                    planEffort /= 2;
                    rate *= 2;
                }

                if (monthEffort > planEffort) {
                    Decimal difference = monthEffort - planEffort;
                    compensationsToInsert.add(
                            generateNewCompensation(
                                    (Id) ar.get('Person__c'),
                                    String.format('Extra hours for {0}, {1} hours at the rate {2}.', new List<String>{
                                            lastMonth,
                                            String.valueOf(difference),
                                            String.valueOf(rate.setScale(2, RoundingMode.HALF_UP))
                                    }),
                                    Math.round(difference * rate)
                            )
                    );
                }
            }
            if (!compensationsToInsert.isEmpty()) insert compensationsToInsert;
        } catch (Exception ex) {}
    }

    private static Set<Integer> collectVacationDays(List<Vacation__c> vacations) {
        Integer lastMonth = System.today().addMonths(-1).month();
        Set<Integer> vacationDays = new Set<Integer>();
        for(Vacation__c vacation : vacations) {
            for(Date d = vacation.Vacation_Start_Date__c; d <= vacation.Vacation_End_Date__c; d = d.addDays(1)) {
                if(d.month() == lastMonth && ((Datetime) d).format('EEEE') != 'Sunday' && ((Datetime) d).format('EEEE') != 'Saturday') {
                    vacationDays.add(d.day());
                }
            }
        }
        return vacationDays;
    }

    private static Integer getPlanEffortWithoutVacations(Set<Integer> vacationDays) {
        Date lastMonth = System.today().addMonths(-1);
        Integer planEffort = 0;
        for(Date d = lastMonth.toStartOfMonth(); d <= System.today().toStartOfMonth().addDays(-1); d = d.addDays(1)) {
            if(((Datetime) d).format('EEEE') != 'Sunday' && ((Datetime) d).format('EEEE') != 'Saturday' && !vacationDays.contains(d.day())) {
                planEffort += 8;
            }
        }
        return planEffort;
    }

    private static Compensation__c generateNewCompensation(Id person, String description, Decimal total) {
        return new Compensation__c(
                Person__c = person,
                Category__c = 'Salary',
                Description__c = description,
                Total__c = total,
                Date__c = System.today()
        );
    }
}