/**
 * Created by kirillreutski on 23.03.24.
 */

public without sharing class PersonEffectivenessStatService implements Schedulable{

    public static final Set<String> notPersonalTransactionCategories = new Set<String> {
            'Birthday',
            'Transfer',
            'Investment',
            'Legal and Accounting',
            'Sales',
            'Dividends',
            'Commission',
            'Office',
            'Loan',
            'Tax' // Налоги убираем отсюда, т.к. Ярик вносит один большой налог за весь Минск. Надо брать налог при расчёте Entity

    };

    public static void schedule() {
        System.schedule('Person Effectiveness Stats', '0 0 0 1 1/1 ? *', new PersonEffectivenessStatService());
    }

    public void execute(SchedulableContext param1) {
        try {
            updateRecords(null, null);
        } catch (Exception e) {
            debug('Got exception: ' + e.getStackTraceString() + '; ' + e.getMessage());
        } finally {

        }

    }

    public static List<String> logRecords = new List<String>();
    
    public static void debug(String str) {
        System.debug('LOG:: ' + str);
        logRecords.add(str);
    }

    
    public static Map<Integer, Decimal> getInitialData() {
        return new Map<Integer, Decimal>{
                1 => 0,
                2 => 0,
                3 => 0,
                4 => 0,
                5 => 0,
                6 => 0,
                7 => 0,
                8 => 0,
                9 => 0,
                10 => 0,
                11 => 0,
                12 => 0
        };
    }

    public static StatLine getFinalStatLine(Contact contact, Integer month) {
        return new StatLine(contact, month);
    }

    public static Map<Integer, Integer> amountWorkingDaysByMonthPL {
        get {
            if (amountWorkingDaysByMonthPL == null) {
                amountWorkingDaysByMonthPL = new Map<Integer, Integer>();
                for (String monthString : CountingExtraHoursScheduler.amountWorkingDaysByMonthPL.keySet()) {
                    amountWorkingDaysByMonthPL.put(
                            getMonthIndex(monthString),
                            CountingExtraHoursScheduler.amountWorkingDaysByMonthPL.get(monthString)
                    );
                }
            }
            return amountWorkingDaysByMonthPL;
        }
        private set;
    }

    public static Map<Integer, Integer> amountWorkingDaysByMonthBY {
        get {
            if (amountWorkingDaysByMonthBY == null) {
                amountWorkingDaysByMonthBY = new Map<Integer, Integer>();
                for (String monthString : CountingExtraHoursScheduler.amountWorkingDaysByMonthBY.keySet()) {
                    amountWorkingDaysByMonthBY.put(
                            getMonthIndex(monthString),
                            CountingExtraHoursScheduler.amountWorkingDaysByMonthBY.get(monthString)
                    );
                }
            }
            return amountWorkingDaysByMonthBY;
        }
        private set;
    }

    public static Integer getMonthIndex(String monthName) {
        if (monthName.containsIgnoreCase('jan')) return 1;
        if (monthName.containsIgnoreCase('feb')) return 2;
        if (monthName.containsIgnoreCase('mar')) return 3;
        if (monthName.containsIgnoreCase('apr')) return 4;
        if (monthName.containsIgnoreCase('may')) return 5;
        if (monthName.containsIgnoreCase('jun')) return 6;
        if (monthName.containsIgnoreCase('jul')) return 7;
        if (monthName.containsIgnoreCase('aug')) return 8;
        if (monthName.containsIgnoreCase('sep')) return 9;
        if (monthName.containsIgnoreCase('oct')) return 10;
        if (monthName.containsIgnoreCase('nov')) return 11;
        return 12;
    }

    public static Integer getContactTargetWorkingHours(String countryCode, Integer month) {
        debug('getContactTargetWorkingHours: ' + countryCode);
        Integer resultDays = (countryCode == 'PL' ? amountWorkingDaysByMonthPL.get(month) : amountWorkingDaysByMonthBY.get(month)) ;
        resultDays = resultDays == null ? 21 : resultDays;
        return resultDays * 8;
    }

    public static void updateRecords(Set<Id> contactIds, Integer targetYear) {
        pp_Query contactQuery = new pp_Query(Contact.SObjectType).selectAllFields().selectField('convertCurrency(Salary__c) salaryUsd').selectField('Employer__r.Billing_Country_Code__c');
        if (contactIds != null) contactQuery = contactQuery.addConditionIn(Contact.Id, contactIds);
        else {
            contactQuery = contactQuery.addConditionEq(Contact.Inactive__c, false).addConditionEq('RecordType.Name', 'Internal');
        }
        List<Contact> contacts = contactQuery.run();
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);
        Integer year = targetYear == null ? System.today().year() : targetYear;

        Map<Id, Map<Integer, Decimal>> sumOfSalaryAndTaxPerMonthPerPersonMap = new Map<Id, Map<Integer, Decimal>>();
        Map<Id, Map<Integer, Decimal>> spentPerMonthPerPersonMap = new Map<Id, Map<Integer, Decimal>>();
        Map<Id, Map<Integer, Decimal>> earnedPerMonthPerPersonMap = new Map<Id, Map<Integer, Decimal>>();
        Map<Id, Map<Integer, Decimal>> potentiallyEarnedPerMonthPerPersonMap = new Map<Id, Map<Integer, Decimal>>();
        Map<Id, Map<Integer, Boolean>> hasSalaryPerMonthPerPersonMap = new Map<Id, Map<Integer, Boolean>>();

        Map<Id, Map<Integer, StatLine>> finalStatsMap = new Map<Id, Map<Integer, StatLine>>();
        
        for (Contact cnt : contacts) {
            sumOfSalaryAndTaxPerMonthPerPersonMap.put(cnt.Id, getInitialData());
            spentPerMonthPerPersonMap.put(cnt.Id, getInitialData());
            earnedPerMonthPerPersonMap.put(cnt.Id, getInitialData());
            potentiallyEarnedPerMonthPerPersonMap.put(cnt.Id, getInitialData());

            hasSalaryPerMonthPerPersonMap.put(cnt.Id, new Map<Integer, Boolean>{
                    1 => false, 2 => false, 3 => false, 4 => false,
                    5 => false, 6 => false, 7 => false, 8 => false,
                    9 => false, 10 => false, 11 => false, 12 => false
            });

            finalStatsMap.put(cnt.Id, new Map<Integer, StatLine>{
                    1 => getFinalStatLine(cnt, 1),
                    2 => getFinalStatLine(cnt, 2),
                    3 => getFinalStatLine(cnt, 3),
                    4 => getFinalStatLine(cnt, 4),
                    5 => getFinalStatLine(cnt, 5),
                    6 => getFinalStatLine(cnt, 6),
                    7 => getFinalStatLine(cnt, 7),
                    8 => getFinalStatLine(cnt, 8),
                    9 => getFinalStatLine(cnt, 9),
                    10 => getFinalStatLine(cnt, 10),
                    11 => getFinalStatLine(cnt, 11),
                    12 => getFinalStatLine(cnt, 12)
            });
        }

        List<Compensation__c> compensations = [SELECT Id, Total__c, Closed__c, CreatedDate, Category__c, Person__c, Person__r.Name, Description__c, (SELECT Id, CreatedDate, Date__c, Effective_Date__c, Outcome_USD__c, Description__c, Outcome_Category__c, Compensation__r.Date__c FROM Transactions__r) FROM Compensation__c WHERE Person__c =: contacts AND CALENDAR_YEAR(CreatedDate) =: year];
        List<Transaction__c> transactions = [SELECT Id, Date__c, Person__c, CreatedDate, Outcome_USD__c, Outcome_Category__c, Tax_Category__c, Effective_Date__c, Description__c FROM Transaction__c WHERE Person__c =: contacts AND (CALENDAR_YEAR(CreatedDate) =: year OR CALENDAR_YEAR(Effective_Date__c) =: year) AND Outcome_USD__c != null AND Compensation__c = null AND Outcome_Category__c != 'Transfer'];
        
        debug('Compensations: ');
        for (Compensation__c compensation : compensations) {
            debug(compensation.Person__r.Name + ': ' + compensation.CreatedDate.month() + '/' + year + ': ' + compensation.Category__c + ', '+ compensation.Total__c );
            if (compensation.Category__c != 'Other') {
                Integer month = compensation.CreatedDate.month();
                // если у компенсации нет транзакций — учитываем по дате ее создания
                // если есть — то лупимся по транзакциям
                if (compensation.Transactions__r.size() == 0) {
                    finalStatsMap.get(compensation.Person__c).get(month).spentCompensations += compensation.Total__c;
                    finalStatsMap.get(compensation.Person__c).get(month).compensations.add(compensation);
                }
                else {
                    for (Transaction__c t : compensation.Transactions__r) {
                        Integer transactionMonth = (t.Effective_Date__c == null ? (t.Date__c == null ? t.CreatedDate : t.Date__c) : t.Effective_Date__c).month();

                        if (compensation.Transactions__r.size() == 1 && compensation.Closed__c == true && t.Effective_Date__c == null) {
                            transactionMonth = month;
                        }
                        finalStatsMap.get(compensation.Person__c).get(transactionMonth).spentCompensations += t.Outcome_USD__c;
                        finalStatsMap.get(compensation.Person__c).get(transactionMonth).transactionsSpent.add(t);

                        // fake compensation to render part
                        Compensation__c fake = compensation.clone();
                        fake.Total__c = t.Outcome_USD__c;
                        fake.Description__c = 'FAKE: ' + t.Id + ', ' + fake.Description__c;
                        finalStatsMap.get(compensation.Person__c).get(transactionMonth).compensations.add(fake);

                    }
                }

            }
        }

        for (Transaction__c tr : transactions){
            if (tr.Tax_Category__c == 'Income') continue;
            if (notPersonalTransactionCategories.contains(tr.Outcome_Category__c) && tr.Outcome_Category__c != 'Dividends') continue;

            Date effectiveDate = tr.Effective_Date__c == null ? (
                    tr.Date__c == null ? tr.CreatedDate.date() : tr.Date__c
            ) : tr.Effective_Date__c;

            Boolean shiftBack = tr.Effective_Date__c == null && effectiveDate.day() < 10;
            System.debug('');
            if (effectiveDate.year() != year) continue;

            Integer month = effectiveDate.month();

            Integer transactionMonth = effectiveDate.month();

            debug(tr.Id + ', ' + month + '/' + year + ': ' + tr.Outcome_Category__c + '(' + tr.Tax_Category__c + '), ' + tr.Outcome_USD__c);


            if (tr.Outcome_Category__c == 'Dividends'){
                finalStatsMap.get(tr.Person__c).get(month).spentDividends += tr.Outcome_USD__c;
            } else {
                Integer thisMonth = month;
                if (tr.Outcome_Category__c == 'Salary') {
                    thisMonth = transactionMonth;
                    if (shiftBack) thisMonth -= 1 ;
                    if (thisMonth < 1) continue;
                }
                debug('Adding spentRest, month: ' + thisMonth + '. ' + tr.Description__c + ', ' + tr.Outcome_USD__c);
                finalStatsMap.get(tr.Person__c).get(thisMonth).spentRest += tr.Outcome_USD__c;
                finalStatsMap.get(tr.Person__c).get(thisMonth).transactionsSpent.add(tr);
            }
            // Налоги убираем отсюда, т.к. Ярик вносит один большой налог за весь Минск
            if (tr.Outcome_Category__c == 'Salary') {//tr.Outcome_Category__c == 'Tax' ||
                Integer thisMonth = transactionMonth;
                if (shiftBack) thisMonth -= 1 ;

                if (thisMonth < 1) continue;
                Decimal currentValue = sumOfSalaryAndTaxPerMonthPerPersonMap.get(tr.Person__c).get(thisMonth);
                sumOfSalaryAndTaxPerMonthPerPersonMap.get(tr.Person__c).put(thisMonth, currentValue + tr.Outcome_USD__c);

                hasSalaryPerMonthPerPersonMap.get(tr.Person__c).put(thisMonth, true);
//                if (tr.Outcome_Category__c == 'Salary') {
//                    hasSalaryPerMonthPerPersonMap.get(tr.Person__c).put(effectiveDate.month(), true);
//                }

                finalStatsMap.get(tr.Person__c).get(thisMonth).transactions.add(tr);
            }
        }
        debug('spentPerMonthPerPersonMap: ' + spentPerMonthPerPersonMap);
        debug('sumOfSalaryAndTaxPerMonthPerPersonMap: ' + sumOfSalaryAndTaxPerMonthPerPersonMap);
        debug('hasSalaryPerMonthPerPersonMap: ' + hasSalaryPerMonthPerPersonMap);



        List<Timecard__c> cards = [SELECT Id, Effort__c, Effort_with_Coefficient__c, CreatedDate, Invoice_Line_Item__c, Invoice_Line_Item__r.Invoice__c, Invoice_Line_Item__r.Invoice__r.Hour_Cost_after_Tax__c, Person__c, Project_Rate__c FROM Timecard__c WHERE Person__c =: contacts AND CALENDAR_YEAR(CreatedDate) =: year];

        for (Timecard__c tc : cards) {
            Id cntId = tc.Person__c;
            Integer month = tc.CreatedDate.month();

            Decimal effort = tc.Effort_with_Coefficient__c == null  ? tc.Effort__c : tc.Effort_with_Coefficient__c;
            System.debug('effort: ' + effort + '(' + tc.Effort_with_Coefficient__c + ', ' + tc.Effort__c + ')' + 'Id: ' + tc.Id);
            if (effort == null) continue;

            if (tc.Invoice_Line_Item__c == null) {
                debug('Skipping ' + tc.Effort__c + ', ' + tc.Effort_with_Coefficient__c + ', ' + '(' + tc.CreatedDate + '), ' + tc.Id);
                finalStatsMap.get(cntId).get(month).hoursSkipped += effort;

                // TODO: dumb way; need to count towards potential tax percentage  for this month
                finalStatsMap.get(cntId).get(month).potentiallyEarned += tc.Project_Rate__c * effort;//tc.Effort__c;
                finalStatsMap.get(tc.Person__c).get(month).timecardsSkipped.add(tc);

                continue;
            }
            finalStatsMap.get(cntId).get(month).hoursCalculated += effort;//tc.Effort__c;
            System.debug('timeCard: ' + tc.Invoice_Line_Item__c + ', ' + tc.Invoice_Line_Item__r?.Invoice__c + ', ' + tc.Invoice_Line_Item__r?.Invoice__r?.Hour_Cost_after_Tax__c);
            finalStatsMap.get(cntId).get(month).earned += effort * tc.Invoice_Line_Item__r.Invoice__r.Hour_Cost_after_Tax__c;
            finalStatsMap.get(cntId).get(month).earnedBrutto += effort * tc.Project_Rate__c;
            finalStatsMap.get(tc.Person__c).get(month).timecardsPaid.add(tc);
        }

        Integer currentMonth = System.today().month();
        Integer currentDay = System.today().day();
        Integer numberOfDays = Date.daysInMonth(System.today().year(), currentMonth);



        debug('finalStatsMap: ');
        for (Id cntId : finalStatsMap.keySet()) {
            debug('Person: ' + contactMap.get(cntId).Name);
            for (Integer month : finalStatsMap.get(cntId).keySet()) {
                if ((finalStatsMap.get(cntId).get(month).hoursCalculated == 0 && finalStatsMap.get(cntId).get(month).hoursSkipped == 0) && month != currentMonth) {
                    System.debug('hoursCalculated and hoursSkipped are 0 for month ' + month + ', skipping.' + finalStatsMap.get(cntId).get(month));
                    continue;
                }

                if (month == currentMonth) {
                    Decimal salary = (Decimal) contactMap.get(cntId).get('salaryUsd');//.Salary__c;
                    salary = salary == null ? 0 : salary;
                    finalStatsMap.get(cntId).get(month).potentiallySpent = salary / numberOfDays * currentDay;
                    finalStatsMap.get(cntId).get(month).debugData.put('potentiallySpent', '' + finalStatsMap.get(cntId).get(month).potentiallySpent);
                    finalStatsMap.get(cntId).get(month).debugData.put('potentiallySpent_trace', '' + salary + ' / ' + numberOfDays + ' * ' + currentDay);
                }
                Decimal avg = finalStatsMap.get(cntId).get(month).hoursCalculated == 0 ? 0 : (finalStatsMap.get(cntId).get(month).earned / finalStatsMap.get(cntId).get(month).hoursCalculated);
                Decimal pEarned = avg * finalStatsMap.get(cntId).get(month).hoursSkipped;
                pEarned = pEarned == 0 ? finalStatsMap.get(cntId).get(month).potentiallyEarned : pEarned;

                Decimal totalHours = finalStatsMap.get(cntId).get(month).hoursCalculated + finalStatsMap.get(cntId).get(month).hoursSkipped;
                Decimal targetHours = finalStatsMap.get(cntId).get(month).targetHours;

                debug('Month: ' + month);
                debug('Load: ' + (totalHours / targetHours * 100).setScale(2) + '%, ' + totalHours + ' of ' + targetHours);
                debug('spentRest: ' + finalStatsMap.get(cntId).get(month).spentRest);
                debug('spentDividends: ' + finalStatsMap.get(cntId).get(month).spentDividends);
                debug('spentCompensations: ' + finalStatsMap.get(cntId).get(month).spentCompensations);
                debug('pSpent: ' + finalStatsMap.get(cntId).get(month).potentiallySpent.setScale(2));
                debug('earned: ' + finalStatsMap.get(cntId).get(month).earned);
                debug('Average: ' + avg.setScale(2) + ' per hour');
                debug('Hours not invoiced: ' + finalStatsMap.get(cntId).get(month).hoursSkipped);
                debug('pEarned: ' + pEarned.setScale(2));
                debug('pEarned (project rate): ' + finalStatsMap.get(cntId).get(month).potentiallyEarned);
            }
        }

        storeStatLines(finalStatsMap, year);
    }

    public static void storeStatLines(Map<Id, Map<Integer, StatLine>> collectedDataMap, Integer year) {
        Map<Id, Map<Integer, Person_Effectiveness_Stat__c>> existingStatsMap = new Map<Id, Map<Integer, Person_Effectiveness_Stat__c>>();
        // TODO: adjust filtering
        List<Person_Effectiveness_Stat__c> lines = new pp_Query(Person_Effectiveness_Stat__c.SObjectType).selectAllFields().addConditionString('CALENDAR_YEAR(Working_Period_Start__c) = ' + year).run();
        for (Person_Effectiveness_Stat__c l : lines) {
            if (!existingStatsMap.containsKey(l.Person__c)) existingStatsMap.put(l.Person__c, new Map<Integer, Person_Effectiveness_Stat__c>());
            if (!existingStatsMap.get(l.Person__c).containsKey(l.Working_Period_Start__c.month())) existingStatsMap.get(l.Person__c).put(l.Working_Period_Start__c.month(), l);
        }

        List<Entity_Revenue_Stat__c> entityRevenueStats = [SELECT Id, Account__c, Working_Period_Start__c FROM Entity_Revenue_Stat__c WHERE CALENDAR_YEAR(Working_Period_Start__c) =: year];
        Map<Id, Map<Integer, Entity_Revenue_Stat__c>> statByMonthByEntityMap = new Map<Id, Map<Integer, Entity_Revenue_Stat__c>>();
        for (Entity_Revenue_Stat__c stat : entityRevenueStats) {
            Integer month = stat.Working_Period_Start__c.month();
            if (!statByMonthByEntityMap.containsKey(stat.Account__c)) statByMonthByEntityMap.put(stat.Account__c, new Map<Integer, Entity_Revenue_Stat__c>());
            statByMonthByEntityMap.get(stat.Account__c).put(month, stat);
        }

        List<Person_Effectiveness_Stat__c> toUpsert = new List<Person_Effectiveness_Stat__c>();
        for (Id contactId : collectedDataMap.keySet()) {
            for (Integer month : collectedDataMap.get(contactId).keySet()) {
                Person_Effectiveness_Stat__c line = generateLine(
                        collectedDataMap.get(contactId).get(month),
                        year,
                        existingStatsMap?.get(contactId)?.get(month)?.Id
                );
                Id accId = PersonToUnitMapService.getAccountId(contactId, year, month);
                line.Entity_Revenue_Stat__c = statByMonthByEntityMap.get(accId)?.get(month)?.Id;
                line.Common_Entity_Revenue_Stat__c = statByMonthByEntityMap.get(null)?.get(month)?.Id;
                toUpsert.add(line);
            }
        }

        upsert toUpsert;
    }

    static List<String> getTransactionList(List<Transaction__c> transactions) {
        List<String> output = new List<String>();
        for (Transaction__c t : transactions) {
            String line= t.Id + ': ' + t.Outcome_Category__c + ', ' + t.Description__c + ': ' + t.Outcome_USD__c;
            output.add(line);
        }

        return output;
    }

    static List<String> getCompensationList(List<Compensation__c> compensations) {
        List<String> output = new List<String>();
        for (Compensation__c t : compensations) {
            String line= t.Id + ': ' + t.Category__c + ', ' + t.Description__c + ': ' + t.Total__c;
            output.add(line);
        }

        return output;
    }

    public static Person_Effectiveness_Stat__c generateLine(StatLine line, Integer year, Id existingId) {
        String debugString = 'Counted timecards paid: \n' + String.join(new List<Id>((new Map<Id, Timecard__c>(line.timecardsPaid)).keySet()), '\n');
        debugString += '\n Counted timecards skipped: \n' + String.join(new List<Id>((new Map<Id, Timecard__c>(line.timecardsSkipped)).keySet()), '\n');
        debugString += '\n Spent Rest Transactions: \n' + String.join(getTransactionList(line.transactionsSpent),'\n');
        debugString += '\n Spent Compensations: \n' + String.join(getCompensationList(line.compensations), '\n');
        debugString += '\n, debugData: ' + JSON.serialize(line.debugData);
        return new Person_Effectiveness_Stat__c(
                Id = existingId,
                Working_Period_Start__c = Date.newInstance(year, line.month, 1),
                Person__c = line.contactId,
                Earned__c = line.earned,
                Earned_Brutto_USD__c = line.earnedBrutto,
                Spent_USD__c = line.spentRest,
                Spent_Dividends_USD__c = line.spentDividends,
                Spent_Compensations_USD__c = line.spentCompensations,
                Hours_Invoiced__c = line.hoursCalculated,
                Hours_not_Invoiced__c = line.hoursSkipped,
                Potentially_Earned_USD__c = line.potentiallyEarned,
                Potentially_Spent_USD__c = line.potentiallySpent,
                Debug__c = debugString
        );
    }

    public class StatLine {
        public Decimal earned = 0;
        public Decimal earnedBrutto = 0;
        public Decimal hoursSkipped = 0;
        public Decimal hoursCalculated = 0;
        public Decimal potentiallyEarned = 0;
        public Decimal potentiallySpent = 0;
        public Decimal spentRest = 0;
        public Decimal spentDividends = 0;
        public Decimal spentCompensations = 0;

        public Map<String, Object> debugData = new Map<String, Object>();

        public Integer targetHours = 0;

        public List<Compensation__c> compensations = new List<Compensation__c>(); // all compensations counted as spent
        public List<Transaction__c> transactions = new List<Transaction__c>();
        public List<Timecard__c> timecardsPaid = new List<Timecard__c>();
        public List<Timecard__c> timecardsSkipped = new List<Timecard__c>();
        public List<Transaction__c> transactionsSpent = new List<Transaction__c>();
//        public List<Transaction__c> compensationsSpent = new List<Transaction__c>();

        public Id contactId = null;
        public Integer month = 1;

        public StatLine(Contact contact, Integer month) {
            this.contactId = contact.Id;
            this.month = month;
            targetHours = getContactTargetWorkingHours(contact.Employer__r?.Billing_Country_Code__c, month);
        }

        public Decimal getSpentTotal(){
            return spentCompensations + spentDividends + spentRest;
        }
    }

}