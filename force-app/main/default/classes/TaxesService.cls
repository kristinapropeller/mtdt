/**
 * Created by kirillreutski on 18.01.24.
 */

public without sharing class TaxesService implements Schedulable{
    public static void schedule(){
        System.schedule('Taxes Service', '0 1 0 1 1/1 ? *', new TaxesService());
    }

    private static final String CURRENCY_EXCHANGE_API_URL = 'http://api.exchangerate.host/timeframe';
    private static final String CURRENCY_EXCHANGE_API_KEY = '2a06efe6edbf55e46bc36ca8f9859e6c';
    private static final String CURRENCY_EXCHANGE_BYN_API_URL = 'https://api.nbrb.by/exrates/rates/dynamics/431?';//startdate=2024-01-01&enddate=2024-12-31';

    public static Integer debugMonth = -1;

    public static Map<Date, Map<String, Decimal>> currencies {
        get {
            if (currencies == null) currencies = getCurrencyRatesAround(System.today().year());
            return currencies;
        } set;
    }

    public static Decimal convertToPLN(Date dt, String base, Decimal amount) {
        System.debug('convertToPLN called: ' + dt + ' ' + base + ' ' + amount);
        Map<String, Decimal> rateMap = currencies.get(dt);
        if (Test.isRunningTest()) return amount;
        Decimal rate = rateMap.get('PLN' + base);
        return amount / rate;
    }

    public static Decimal convertUSDToBYN(Date dt, Decimal amount) {
        Map<String, Decimal> rateMap = currencies.get(dt);
        if (Test.isRunningTest()) return amount;
        Decimal rate = rateMap.get('BYNUSD');
        return amount * rate;
    }

    public static Decimal convertEURToUSD(Date dt, Decimal amount) {
        Map<String, Decimal> rateMap = currencies.get(dt);
        if (Test.isRunningTest()) return amount;
        Decimal rate = rateMap.get('USDEUR');
        return amount / rate;
    }

    public void execute(SchedulableContext param1) {
        populateTaxData(System.today().year());
    }

    public static Map<Date, Map<String, Decimal>> getCurrencyRatesAround(Integer year){
        // pln
        Map<Date, Map<String, Decimal>> plnResult = getCurrencyRates(year, 'PLN');
        Map<Date, Map<String, Decimal>> plnPrevResult = getCurrencyRates(year-1, 'PLN');
        Map<Date, Map<String, Decimal>> plnNextResult = getCurrencyRates(year+1, 'PLN');


        // byn

        Map<Date, Map<String, Decimal>> bynResult = getBynCurrencyRates(year);
        Map<Date, Map<String, Decimal>> bynPrevResult = getBynCurrencyRates(year-1);
        Map<Date, Map<String, Decimal>> bynNextResult = getBynCurrencyRates(year+1);

        for (Date dt : plnPrevResult.keySet())  plnResult.put(dt, plnPrevResult.get(dt));
        for (Date dt : plnNextResult.keySet())  plnResult.put(dt, plnNextResult.get(dt));

        for (Date dt : bynResult.keySet()) {
            if (plnResult.containsKey(dt)) {
                for (String pair : bynResult.get(dt).keySet()) {
                    plnResult.get(dt).put(pair, bynResult.get(dt).get(pair));
                }
            } else {
                plnResult.put(dt, bynResult.get(dt));
            }
        }

        for (Date dt : bynPrevResult.keySet()) {
            if (plnResult.containsKey(dt)) {
                for (String pair : bynPrevResult.get(dt).keySet()) {
                    plnResult.get(dt).put(pair, bynPrevResult.get(dt).get(pair));
                }
            } else {
                plnResult.put(dt, bynPrevResult.get(dt));
            }
        }

        for (Date dt : bynNextResult.keySet()) {
            if (plnResult.containsKey(dt)) {
                for (String pair : bynNextResult.get(dt).keySet()) {
                    plnResult.get(dt).put(pair, bynNextResult.get(dt).get(pair));
                }
            } else {
                plnResult.put(dt, bynNextResult.get(dt));
            }
        }

        return plnResult;
    }

    private static pp_RestExplorer explorerInstance {
        get {
            if (explorerInstance == null) {
                explorerInstance = new pp_RestExplorer(CURRENCY_EXCHANGE_API_URL);
            }
            return explorerInstance;
        } private set;
    }

    public static Map<Date, Map<String, Decimal>> getBynCurrencyRates(Integer year) {
        Map<Date, Map<String, Decimal>> rates = new Map<Date, Map<String, Decimal>>();
        String monthAndDay =  '-12-31';
        String month = '12';
        String day = '31';

        if (year == System.today().year()) {
            Integer monthInt = System.today().month();
            Integer dayInt = System.today().day();
            month = '' + (monthInt > 9 ? ('' + monthInt) : ('0' + monthInt));
            day = '' + (dayInt > 9 ? ('' + dayInt) : ('0' + dayInt));
            monthAndDay = '-' + month + '-' + day;
        }

        pp_RestExplorer restExplorer = new pp_RestExplorer(
                CURRENCY_EXCHANGE_BYN_API_URL +
                        'startdate=' + year + '-01-01&' +
                        'enddate=' + year + monthAndDay)
                .doGet();

        HttpResponse res = Test.isRunningTest() ? new HttpResponse() : restExplorer.getResponse();
        if ((res != null && res.getStatusCode() == 200) || Test.isRunningTest()) {
            String responseBody = Test.isRunningTest()
                    ? '[{"Cur_ID":431,"Date":"2023-01-01T00:00:00","Cur_OfficialRate":2.7364},{"Cur_ID":431,"Date":"2023-01-02T00:00:00","Cur_OfficialRate":2.7364},{"Cur_ID":431,"Date":"2023-01-03T00:00:00","Cur_OfficialRate":2.7364},{"Cur_ID":431,"Date":"2023-01-04T00:00:00","Cur_OfficialRate":2.7088}]'
                    : res.getBody();

            List<Object> results = (List<Object>) JSON.deserializeUntyped(responseBody);
            for (Object result : results) {
                Map<String, Object> parsed = (Map<String, Object>) result;
                String dateString = String.valueOf(parsed.get('Date'));

                List<String> parts = dateString.split('T')[0].split('-');
                Date d = Date.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), Integer.valueOf(parts[2]));
                rates.put(d, new Map<String, Decimal>{'BYNUSD' => (Decimal)parsed.get('Cur_OfficialRate')});
            }
        }

        return rates;
    }

        public static Map<Date, Map<String, Decimal>> getCurrencyRates(Integer year, String base) {
        Map<Date, Map<String, Decimal>> rates = new Map<Date, Map<String, Decimal>>();
        String monthAndDay =  '-12-31';
        String month = '12';
        String day = '31';

        if (year == System.today().year()) {
            Integer monthInt = System.today().month();
            Integer dayInt = System.today().day();
            month = '' + (monthInt > 9 ? ('' + monthInt) : ('0' + monthInt));
            day = '' + (dayInt > 9 ? ('' + dayInt) : ('0' + dayInt));
            monthAndDay = '-' + month + '-' + day;
        }
        pp_RestExplorer restExplorer = explorerInstance// new pp_RestExplorer(CURRENCY_EXCHANGE_API_URL)

                .addParameters(new Map<String, Object>{
                        'access_key' => CURRENCY_EXCHANGE_API_KEY,
                        'start_date' => year + '-01-01',
                        'end_date' => year + monthAndDay,
                        'source' => base,
                        'currencies' => 'USD,EUR,PLN'
                })
                .doGet();
        HttpResponse res = Test.isRunningTest() ? new HttpResponse() : restExplorer.getResponse();
        if ((res != null && res.getStatusCode() == 200) || Test.isRunningTest()) {
            String responseBody = Test.isRunningTest()
                    ? '{"success": true,"historical": true,"source": "' + UserInfo.getDefaultCurrency() + '","quotes": {"' + (UserInfo.getDefaultCurrency() == 'USD' ? 'USDEUR' : 'EURUSD') + '": 1.085519}}'
                    : res.getBody();
            try {
                responseBody = responseBody.replaceAll('Didn\'t get redis data','');
                APIResponse response = (APIResponse) JSON.deserialize(responseBody, APIResponse.class);
                if (response.success) {
                    for (String q : response.quotes.keySet()) {
                        List<String> parts = q.split('-');
                        Date d = Date.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), Integer.valueOf(parts[2]));

                        rates.put(d, response.quotes.get(q));
                        Decimal usdeur = response.quotes.get(q).get('PLNEUR') * 100 / response.quotes.get(q).get('PLNUSD');
                        rates.get(d).put('USDEUR', (usdeur / 100).setScale(5, RoundingMode.UP));//
                    }
                }
            } catch (Exception ex) {
                System.debug(ex.getMessage() + ' | ' + ex.getStackTraceString());
            }

        }

        return rates;
    }

    public static void populateTaxData(Integer year){
        currencies = getCurrencyRatesAround(year);
        List<Account> internalAccounts = [SELECT Id, Taxation__c FROM Account WHERE RecordType.Name = 'Internal' AND Taxation__c IN ('Poland IB', 'Poland Spolka', 'Belarus Company')];

        //List<Map<Integer, Map<String, List<Transaction__c>>>> allMaintenances = new List<Map<Integer, Map<String, List<Transaction__c>>>>();
        List<Map<Integer, EntityMonthlyMaintenance>> allMaintenances = new List<Map<Integer, TaxesService.EntityMonthlyMaintenance>>();
        for (Account account : internalAccounts) {
            if      (account.Taxation__c == 'Poland IB')        allMaintenances.add(populateTaxDataIBPL(account.Id, year, 0.12));
            else if (account.Taxation__c == 'Poland Spolka')    allMaintenances.add(populateTaxDataSpolka(account.Id, year, 0.09));
            else if (account.Taxation__c == 'Belarus Company')  allMaintenances.add(populateTaxDataBelarusCompany(account.Id, year, 0.01, true));
        }

        // надо теперь собрать общий мейнтенанс; там отражаются например расходы на софт
        // по хорошему, надо затраты на всех людей вынести в непроизводственные расходы
        System.debug('All maintenances: ' + allMaintenances.size());

        Map<Integer, Decimal> commonSpendingPerMonth = new Map<Integer, Decimal>{
                1=>0, 2=>0,3=>0,4=>0,5=>0,6=>0,
                7=>0, 8=>0,9=>0,10=>0,11=>0,12=>0
        };
        for (Integer month = 1; month < 13; month ++) {
            for (Map<Integer, EntityMonthlyMaintenance> maintenance : allMaintenances) {
                List<Transaction__c> spendings = maintenance.get(month)?.maintenanceTransactions.get('All');
                if (spendings == null) continue;
                for (Transaction__c tr : spendings) commonSpendingPerMonth.put(month, commonSpendingPerMonth.get(month) + tr.Outcome_USD__c );
            }
        }

        Map<Date, Entity_Revenue_Stat__c> revenueMap = new Map<Date, Entity_Revenue_Stat__c>();
        List<Entity_Revenue_Stat__c> existingRevenueStats = [SELECT Id, Account__c, Working_Period_Start__c, Outcome_USD__c, Outcome__c, CurrencyIsoCode FROM Entity_Revenue_Stat__c WHERE Account__c = NULL AND CALENDAR_YEAR(Working_Period_Start__c) =: year];

        for (Entity_Revenue_Stat__c entityRevenueStat : existingRevenueStats) {
            revenueMap.put(entityRevenueStat.Working_Period_Start__c, entityRevenueStat);
        }

        System.debug('revenueMap: ' + revenueMap.keySet());
        for (Integer month : commonSpendingPerMonth.keySet()) {

            Date dt = Date.newInstance(year, month, 1);
            Integer persons = PersonToUnitMapService.personsAmount(year, month);
            if (persons == null) persons = 0;
            System.debug('month: ' + month + ', persons: ' + persons + ': ' + revenueMap.containsKey(dt));
            if (revenueMap.containsKey(dt)) {

                revenueMap.get(dt).Spent_All_USD__c = commonSpendingPerMonth.get(month);
                revenueMap.get(dt).Persons__c = persons;

            } else {
                revenueMap.put(dt, new Entity_Revenue_Stat__c(
                        Spent_All_USD__c = commonSpendingPerMonth.get(month),
                        Persons__c = persons,
                        Working_Period_Start__c = dt
                ));
            }
        }
        System.debug('revenueMap: ' + revenueMap.keySet());

        upsert revenueMap.values();
    }

    public static Set<Id> getBankIds(Id accountId){
        Set<Id> bankIdsSet = new Set<Id>();
        List<Bank__c> banks = [SELECT Id FROM Bank__c WHERE Account__c =: accountId];

        List<Bank_Account__c> bankAccounts = [SELECT Id FROM Bank_Account__c WHERE Bank__c =: banks];
        for (Bank_Account__c ba : bankAccounts) {
            bankIdsSet.add(ba.Id);
        }

        return bankIdsSet;
    }

    public static List<Invoice__c> getAllInvoices(Set<Id> bankIdsSet, Integer year) {
        return [
                SELECT
                        Id, Name, CurrencyIsoCode, Total__c, Final_Total__c, Actual_Income__c, Actual_Outcome__c,
                        Working_Period_End__c, Invoice_Number__c, (SELECT Id, CreatedDate, Effective_Date__c FROM Transactions__r)
                FROM Invoice__c
                WHERE
                        Payee_Bank_Account__c =: bankIdsSet AND
                        CALENDAR_YEAR(Working_Period_End__c) =: year AND
                        Status__c != 'Draft'
        ];
    }

    public static List<Transaction__c> getOutcomeTransactions(Set<Id> bankIdsSet, Integer year){
        return [
                SELECT
                        Id, Compensation__c, Tax_Category__c, Description__c, Date__c,
                        Outcome_USD__c, Outcome__c, Outcome_Bank_Account__c,
                        Expense_Region__c, Outcome_Category__c, Effective_Date__c, Apply_To__c,
                        Effective_Distribution__c, CreatedDate, Income_Bank_Account__c,
                        Person__c, Entity_Revenue_Stat_Spending__c, Entity_Revenue_Stat_Income__c
                FROM Transaction__c
                WHERE
                        Outcome_Bank_Account__c =: bankIdsSet AND
                        (
                                CALENDAR_YEAR(CreatedDate) =: year OR
                                CALENDAR_YEAR(Effective_Date__c) =: year
                        )
        ];
    }

    private static void storeRevenue(
            String baseCurrency,
            Map<Integer, Decimal> outcomeTaxesDonePLNByMonth,
            Map<Integer, Decimal> outcomeTaxesDoneByMonth,
            Map<Integer, Decimal> forTaxesPLNByMonth,
            Map<Integer, Decimal> forTaxesByMonth,
            Id accountId,
            Decimal taxPercent,
            Integer year,
            Map<Integer, List<Invoice__c>> invoicesByMonth,
            Map<Integer, EntityMonthlyMaintenance> maintenanceTransactions
            ){
        Map<Integer, Decimal> taxesByMonthPln = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> taxesByMonthUsd = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};

        System.debug('accountId: ' + accountId);
        for (Integer i = 1; i < 13; i ++) {

            System.debug('Month: ' + i + ' - ' + outcomeTaxesDonePLNByMonth.get(i));
            System.debug('Month: ' + i + ' - ' + forTaxesPLNByMonth.get(i) * taxPercent);

            // align values
            if (forTaxesPLNByMonth.get(i) < 0) forTaxesPLNByMonth.put(i, 0);
            if (forTaxesByMonth.get(i) < 0) forTaxesByMonth.put(i, 0);

            System.debug('Invoices: ');
            if (invoicesByMonth.get(i) == null) {
                System.debug('--- NONE ---');
            } else {
                for (Invoice__c invoice : invoicesByMonth.get(i)) {
                    System.debug(invoice.Invoice_Number__c + ': ' + invoice.Actual_Income__c + ', ' + invoice.Total__c);
                }
            }

            if (outcomeTaxesDonePLNByMonth.get(i) != null && outcomeTaxesDonePLNByMonth.get(i) != 0) {//
                taxesByMonthPln.put(i, outcomeTaxesDonePLNByMonth.get(i));
                taxesByMonthUsd.put(i, outcomeTaxesDoneByMonth.get(i));
            } else {
                taxesByMonthPln.put(i, forTaxesPLNByMonth.get(i) * taxPercent);
                taxesByMonthUsd.put(i, forTaxesByMonth.get(i)    * taxPercent);
            }

            if (taxesByMonthUsd.get(i) < 0) taxesByMonthUsd.put(i, 0);
            if (taxesByMonthPln.get(i) < 0) taxesByMonthPln.put(i, 0);
        }

        Map<Date, Entity_Revenue_Stat__c> revenueMap = new Map<Date, Entity_Revenue_Stat__c>();
        List<Entity_Revenue_Stat__c> existingRevenueStats = [SELECT Id, Account__c, Working_Period_Start__c, Outcome_USD__c, Outcome__c, CurrencyIsoCode FROM Entity_Revenue_Stat__c WHERE Account__c =: accountId];

        for (Entity_Revenue_Stat__c entityRevenueStat : existingRevenueStats) {
            revenueMap.put(entityRevenueStat.Working_Period_Start__c, entityRevenueStat);
        }

        Map<Integer, Date> monthToDt = new Map<Integer, Date>();

        for (Integer month = 1; month < 13; month ++) {

            Date dt = Date.newInstance(year, month, 1);
            monthToDt.put(month, dt);

            Decimal spentAllUSD = 0;
            Decimal spentUnitUSD = 0;
            Integer persons = PersonToUnitMapService.getPersonsInUnit(accountId, year, month);

            EntityMonthlyMaintenance maintenanceTransactionsThisMonth = maintenanceTransactions.get(month);
            if (maintenanceTransactionsThisMonth != null) {
                if (maintenanceTransactionsThisMonth.maintenanceTransactions.get('All') != null) {
                    for (Transaction__c t : maintenanceTransactionsThisMonth.maintenanceTransactions.get('All')) {
                        spentAllUSD += t.Outcome_USD__c;
                        maintenanceTransactionsThisMonth.addAllTransaction(t);
                    }
                }

                if (maintenanceTransactionsThisMonth.maintenanceTransactions.get('Unit') != null) {
                    for (Transaction__c t : maintenanceTransactionsThisMonth.maintenanceTransactions.get('Unit')) {
                        spentUnitUSD += t.Outcome_USD__c;
                        maintenanceTransactionsThisMonth.addUnitTransaction(t);
                    }
                }
            }

            List<String> transactions = new List<String>();
            List<String> transactionsSpentUnit = new List<String>();
            List<String> transactionsSpentAll = new List<String>();
            Decimal totalUSD = 0;
            Decimal transactionsSpentUnitUSD = 0;
            Decimal transactionsSpentAllUSD = 0;


            if (maintenanceTransactionsThisMonth != null) {
                for (Transaction__c tr : maintenanceTransactionsThisMonth.outcomeTransactions) {
                    transactions.add(tr.Id + ': ' + tr.Outcome_Category__c + ', ' + tr.Apply_To__c + ', ' + tr.Outcome_USD__c);
                    totalUSD += tr.Outcome_USD__c;
                }
                for (Transaction__c tr : maintenanceTransactionsThisMonth.getSpentAllTransactions()) {
                    transactionsSpentAll.add(tr.Id + ': ' + tr.Outcome_Category__c + ', ' + tr.Apply_To__c + ', ' + tr.Outcome_USD__c);
                    transactionsSpentAllUSD += tr.Outcome_USD__c;
                }
                for (Transaction__c tr : maintenanceTransactionsThisMonth.getSpentUnitTransactions()) {
                    transactionsSpentUnit.add(tr.Id + ': ' + tr.Outcome_Category__c + ', ' + tr.Apply_To__c + ', ' + tr.Outcome_USD__c);
                    transactionsSpentUnitUSD += tr.Outcome_USD__c;
                }
            }

            String debugString = 'All outcome transactions: \n' + String.join(transactions, '\n') + '\nTotal: ' + totalUSD + '\n\n';
            debugString += 'Spent Unit: \n' + String.join(transactionsSpentUnit, '\n') + '\nTotal: ' + transactionsSpentUnitUSD + '\n\n';
            debugString += 'Spent All: \n' + String.join(transactionsSpentAll, '\n') + '\nTotal: ' + transactionsSpentAllUSD + '\n\n';

            if (revenueMap.containsKey(dt)) {
                revenueMap.get(dt).Outcome_Tax_USD__c = taxesByMonthUsd.get(month);
                revenueMap.get(dt).Outcome_Tax__c = taxesByMonthPln.get(month);
                revenueMap.get(dt).Income__c = forTaxesPLNByMonth.get(month);
                revenueMap.get(dt).Income_USD__c = forTaxesByMonth.get(month);
                revenueMap.get(dt).Spent_All_USD__c = spentAllUSD;
                revenueMap.get(dt).Spent_Unit_USD__c = spentUnitUSD;
                revenueMap.get(dt).Persons__c = persons;
                revenueMap.get(dt).Debug__c = debugString;

            } else {
                revenueMap.put(dt, new Entity_Revenue_Stat__c(
                        Account__c = accountId,
                        Working_Period_Start__c = dt,
                        Outcome_Tax_USD__c = taxesByMonthUsd.get(month),
                        Outcome_Tax__c = taxesByMonthPln.get(month),
                        CurrencyIsoCode = baseCurrency,//'PLN'
                        Income__c = forTaxesPLNByMonth.get(month),
                        Income_USD__c = forTaxesByMonth.get(month),
                        Spent_Unit_USD__c = spentUnitUSD,
                        Spent_All_USD__c = spentAllUSD,
                        Persons__c = persons,
                        Debug__c = debugString
                ));
            }
        }
        Database.upsert(revenueMap.values());

        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Integer month : invoicesByMonth.keySet()) {
            List<Invoice__c> invoicesThisMonth = invoicesByMonth.get(month);
            for (Invoice__c invoice : invoicesThisMonth) {
                Date dt = monthToDt.get(month);
                invoice.Entity_Revenue_Stat__c = revenueMap.get(dt).Id;
                invoices.add(invoice);
            }
        }

        update invoices;

        List<Transaction__c> transactionsToUpdate = new List<Schema.Transaction__c>();
        for (Integer month = 1; month < 13; month ++) {
            Date dt = Date.newInstance(year, month, 1);
            if (maintenanceTransactions.get(month) != null)
            for (String applyTo : maintenanceTransactions.get(month).maintenanceTransactions.keySet()){
                Id revenueId = revenueMap.get(dt)?.Id;
                if (revenueId == null) {
                    System.debug('Cannot find revenue for ' + dt + ', ' + revenueMap.keySet());
                    continue;
                }

                for (Transaction__c tr : maintenanceTransactions.get(month).maintenanceTransactions.get(applyTo)) {
                    if (tr.Entity_Revenue_Stat_Spending__c == null) {
                        tr.Entity_Revenue_Stat_Spending__c = revenueId;
                        transactionsToUpdate.add(tr);
                    }
                }
            }
        }

        if (transactionsToUpdate.size() > 0) update transactionsToUpdate;
    }

    public static Map<Integer, EntityMonthlyMaintenance> populateTaxDataIBPL(Id accountId, Integer year, Decimal taxPercent) {
        return populateTaxDataIBPL(accountId, year, taxPercent, true);
    }

    public static Map<Integer, EntityMonthlyMaintenance> populateTaxDataBelarusCompany(Id accountId, Integer year, Decimal taxPercent, Boolean store){
        /*
            Все расходы, где Apply To = Unit, делятся на всех в юните
            Все расходы, где Apply To = All, делятся на всех в компании
            Все приходы составляют налоговую базу
        */

        Set<Id> bankIdsSet = getBankIds(accountId);
        List<Invoice__c> allInvoices = getAllInvoices(bankIdsSet, year);

        Map<Integer, Decimal> incomeBYNByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> forTaxesByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> forTaxesBYNByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> outcomeTaxesDoneByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> outcomeTaxesDoneBYNByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};

        Map<Integer, List<Transaction__c>> spendingTransactionsByMonth = new Map<Integer, List<Transaction__c>>{
                1 => new List<Transaction__c>(), 2 => new List<Transaction__c>(), 3 => new List<Transaction__c>(),
                4 => new List<Transaction__c>(), 5 => new List<Transaction__c>(), 6 => new List<Transaction__c>(),
                7 => new List<Transaction__c>(), 8 => new List<Transaction__c>(), 9 => new List<Transaction__c>(),
                10 => new List<Transaction__c>(), 11 => new List<Transaction__c>(), 12 => new List<Transaction__c>()
        };
        Map<Integer, Decimal> spendingsByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};


        Map<Integer, List<Invoice__c>> invoicesByMonth = new Map<Integer, List<Invoice__c>>();

        // check income invoices
        for (Invoice__c invoice : allInvoices) {
            List<String> parts = invoice.Invoice_Number__c == null ? new List<String>() : invoice.Invoice_Number__c.split('/');
            Decimal amount = invoice.Total__c;
            String curr = (String) invoice.CurrencyIsoCode;

            Date transactionCreated = invoiceTransactionDate(invoice);

            Integer month = transactionCreated.month();
            if (parts.size() > 1) {
                try {
                    Integer monthFromInvoiceNumber = Integer.valueOf(parts[1]);
                    month = monthFromInvoiceNumber;
                } catch (Exception e) {
                    System.debug('Failed to get month from invoice number, rollback to transaction/created date');
                }
            }

            Decimal finalAmount = 0;
            if (curr == 'EUR') finalAmount = convertEURToUSD(transactionCreated, amount);
            else finalAmount = invoice.Total__c;

            Decimal inByn = convertUSDToBYN(transactionCreated, amount);
            incomeBYNByMonth.put(month, incomeBYNByMonth.get(month)     + inByn);
            forTaxesBYNByMonth.put(month, forTaxesBYNByMonth.get(month) + inByn);
            forTaxesByMonth.put(month, forTaxesByMonth.get(month)   + finalAmount);

            if (invoicesByMonth.containsKey(month) == false) invoicesByMonth.put(month, new List<Invoice__c>());
            invoicesByMonth.get(month).add(invoice);
        }

        // find real taxes paid
        List<Transaction__c> outcomeTransactions = getOutcomeTransactions(bankIdsSet, year);

        for (Transaction__c outcomeTransaction : outcomeTransactions) {
            if (outcomeTransaction.Effective_Date__c == null) {
                outcomeTransaction.Effective_Date__c = outcomeTransaction.Date__c == null ? outcomeTransaction.CreatedDate.date() : outcomeTransaction.Date__c;
            }

            Integer month = outcomeTransaction.Effective_Date__c.month();
            System.debug('Transaction of ' + month + ': ' + outcomeTransaction.Id + ', ' + outcomeTransaction.Outcome_Category__c + ', ' + outcomeTransaction.Tax_Category__c + ': ' + outcomeTransaction.Outcome_USD__c + ' (' + outcomeTransaction.Outcome__c + '). ' + outcomeTransaction.Apply_To__c);

            if (outcomeTransaction.Outcome_Category__c == 'Tax') {
                if (outcomeTransaction.Tax_Category__c == 'Income') {
                    outcomeTaxesDoneByMonth.put(
                            month,
                            outcomeTaxesDoneByMonth.get(month) +
                                    outcomeTransaction.Outcome_USD__c
                    );

                    outcomeTaxesDoneBYNByMonth.put(
                            month,
                            outcomeTaxesDoneBYNByMonth.get(month) +
                                    outcomeTransaction.Outcome__c
                    );
                }
            }

            if (outcomeTransaction.Outcome_Category__c != 'Salary') {
                if (outcomeTransaction.Income_Bank_Account__c == null) {
                    System.debug(outcomeTransaction.Id + ': Adding to spendings:' + outcomeTransaction.Outcome_Category__c + ', ' + outcomeTransaction.Apply_To__c + ', ' + outcomeTransaction.Description__c);
                    spendingsByMonth.put(month, spendingsByMonth.get(month) + outcomeTransaction.Outcome_USD__c);
                    spendingTransactionsByMonth.get(month).add(outcomeTransaction);
                }
            }
        }

        //
        System.debug('spendingTransactionsByMonth start: ');
        for (Integer m : spendingTransactionsByMonth.keySet()) {
            System.debug('Month: ' + m);
            Decimal s = 0;
            for (Transaction__c outcomeTransaction : spendingTransactionsByMonth.get(m)) {
                System.debug(outcomeTransaction.Id + ', ' + outcomeTransaction.Outcome_Category__c + ', ' + outcomeTransaction.Tax_Category__c + ': ' + outcomeTransaction.Outcome_USD__c + ' (' + outcomeTransaction.Outcome__c + '). ' + outcomeTransaction.Apply_To__c);
                s += outcomeTransaction.Outcome_USD__c;
            }
            System.debug('Total: ' + s);
        }

        // rebuild by quaters
        System.debug('Splitting by quaters: ');
        System.debug('outcomeTaxesDoneByMonth: ' + outcomeTaxesDoneByMonth);
        System.debug('outcomeTaxesDoneBYNByMonth: ' + outcomeTaxesDoneBYNByMonth);
        System.debug('spendingsByMonth: ' + spendingsByMonth);
        for (Integer quater = 1; quater <= 4; quater ++){

            Integer month = quater * 3;
            System.debug('quater=' + quater + ', month=' + month + '. taxesDone: ' + outcomeTaxesDoneBYNByMonth.get(month) + ', forTaxesByMonth: ' + forTaxesByMonth.get(month));
            if (outcomeTaxesDoneBYNByMonth.get(month) > 0) {
                Decimal bynTax = outcomeTaxesDoneBYNByMonth.get(month);
                Decimal usdTax = outcomeTaxesDoneByMonth.get(month);
                Decimal realIncomeThisQuater = 0;
                Decimal realBynIncomeThisQuater = 0;
                for (Integer i = (quater - 1) * 3 + 1; i < (quater) * 3 + 1; i ++) {
                    realIncomeThisQuater += forTaxesByMonth.get(i) * taxPercent;
                    realBynIncomeThisQuater += forTaxesBYNByMonth.get(i) * taxPercent;
                }

                for (Integer i = (quater - 1) * 3 + 1; i < (quater) * 3 + 1; i ++) {
                    Decimal taxBynPart = realBynIncomeThisQuater == 0 ? 0 : forTaxesBYNByMonth.get(i) * taxPercent / realBynIncomeThisQuater * bynTax;
                    Decimal taxUsdPart = realIncomeThisQuater == 0 ? 0 : forTaxesByMonth.get(i) * taxPercent / realIncomeThisQuater * usdTax;
                    System.debug('month: ' + i + ' ' + taxBynPart + '/' + bynTax + ', ' + taxUsdPart + '/' + usdTax);

                    outcomeTaxesDoneBYNByMonth.put(i, taxBynPart);
                    outcomeTaxesDoneByMonth.put(i, taxUsdPart);
                }
            }
        }
        Map<Integer, EntityMonthlyMaintenance> maintenanceMap = getMaintenanceTransactions2(outcomeTransactions, bankIdsSet);
        //Map<Integer, Map<String, List<Transaction__c>>> maintenance = getMaintenanceTransactions(outcomeTransactions, bankIdsSet);
        System.debug('Maintenancies: ');
        for (Integer m : maintenanceMap.keySet()) {
            EntityMonthlyMaintenance e = maintenanceMap.get(m);
            System.debug('Transactions spent All: ');
            Decimal t = 0;
            for (Transaction__c tr : e.getSpentAllTransactions()) {
                System.debug(tr.Id + ': ' + tr.Outcome_USD__c + ' (' + tr.Outcome_Category__c + ')');
                t += tr.Outcome_USD__c;
            }
            System.debug('Total: ' + t);


            System.debug('Transactions spent Unit: ');
            t = 0;
            for (Transaction__c tr : e.getSpentUnitTransactions()) {
                System.debug(tr.Id + ': ' + tr.Outcome_USD__c + ' (' + tr.Outcome_Category__c + ')');
                t += tr.Outcome_USD__c;
            }
            System.debug('Total: ' + t);

            System.debug('Transactions all: ');
            t = 0;
            for (Transaction__c tr : e.outcomeTransactions) {
                System.debug(tr.Id + ': ' + tr.Outcome_USD__c + ' (' + tr.Outcome_Category__c + ')');
                t += tr.Outcome_USD__c;
            }
            System.debug('Total: ' + t);


//            System.debug('Month: ' + m + ': ' +e.transactionsSpentAll);
        }

        if (store)  {
            storeRevenue('BYN', outcomeTaxesDoneBYNByMonth, outcomeTaxesDoneByMonth, forTaxesBYNByMonth, forTaxesByMonth, accountId, taxPercent, year, invoicesByMonth, maintenanceMap);
        }
        else {
            System.debug('Not storing: ');
            for (Integer month = 1; month < 13; month ++) {
                System.debug('Month ' + month);
                System.debug('outcomeTaxesDoneBYNByMonth: ' + outcomeTaxesDoneBYNByMonth.get(month));
                System.debug('outcomeTaxesDoneByMonth: ' + outcomeTaxesDoneByMonth.get(month));
                System.debug('forTaxesBYNByMonth: ' + forTaxesBYNByMonth.get(month));
                System.debug('forTaxesBYNByMonth (1%): ' + forTaxesBYNByMonth.get(month) / 100);
                System.debug('forTaxesByMonth (1%): ' + forTaxesByMonth.get(month) / 100);
            }
        }

        return maintenanceMap;
    }

    public static Map<Integer, EntityMonthlyMaintenance> populateTaxDataIBPL(Id accountId, Integer year, Decimal taxPercent, Boolean store){
        Set<Id> bankIdsSet = getBankIds(accountId);
        List<Invoice__c> allInvoices = getAllInvoices(bankIdsSet, year);

        Map<Integer, Decimal> incomePLNByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> forTaxesByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> forTaxesPLNByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> outcomeTaxesDoneByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> outcomeTaxesDonePLNByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};


        Map<Integer, List<Invoice__c>> invoicesByMonth = new Map<Integer, List<Invoice__c>>();

        // check income invoices
        for (Invoice__c invoice : allInvoices) {
            List<String> parts = invoice.Invoice_Number__c == null ? new List<String>() : invoice.Invoice_Number__c.split('/');
            Decimal amount = invoice.Total__c;
            String curr = (String) invoice.CurrencyIsoCode;

            Date transactionCreated = invoiceTransactionDate(invoice);

            Integer month = transactionCreated.month();
            if (parts.size() > 1) {

                try {
                    Integer monthFromInvoiceNumber = Integer.valueOf(parts[1]);
                    month = monthFromInvoiceNumber;
                } catch (Exception e) {
                    System.debug('Failed to get month from invoice number, rollback to transaction/created date');
                }
            }

            Decimal finalAmount = 0;
            if (curr == 'EUR') finalAmount = convertEURToUSD(transactionCreated, amount);
            else finalAmount = invoice.Total__c;

            Decimal inPln = convertToPLN(transactionCreated, curr, amount);
            incomePLNByMonth.put(month, incomePLNByMonth.get(month)     + inPln);
            forTaxesPLNByMonth.put(month, forTaxesPLNByMonth.get(month) + inPln);
            forTaxesByMonth.put(month, forTaxesByMonth.get(month)   + finalAmount);

            if (invoicesByMonth.containsKey(month) == false) invoicesByMonth.put(month, new List<Invoice__c>());
            invoicesByMonth.get(month).add(invoice);
        }

        // find real taxes paid
        List<Transaction__c> outcomeTransactions = getOutcomeTransactions(bankIdsSet, year);

        for (Transaction__c outcomeTransaction : outcomeTransactions) {
            if (outcomeTransaction.Effective_Date__c == null) {
                outcomeTransaction.Effective_Date__c = outcomeTransaction.Date__c == null ? outcomeTransaction.CreatedDate.date() : outcomeTransaction.Date__c;
            }

            Integer month = outcomeTransaction.Effective_Date__c.month();

            if (outcomeTransaction.Outcome_Category__c == 'Tax') {
                if (outcomeTransaction.Tax_Category__c == 'Income') {
                    outcomeTaxesDoneByMonth.put(
                            month,
                            outcomeTaxesDoneByMonth.get(month) +
                                    outcomeTransaction.Outcome_USD__c
                    );

                    outcomeTaxesDonePLNByMonth.put(
                            month,
                            outcomeTaxesDonePLNByMonth.get(month) +
                                    outcomeTransaction.Outcome__c
                    );
                }
            }
        }
        Map<Integer, EntityMonthlyMaintenance> maintenanceMap = getMaintenanceTransactions2(outcomeTransactions, bankIdsSet);
        //Map<Integer, Map<String, List<Transaction__c>>> maintenance = getMaintenanceTransactions(outcomeTransactions, bankIdsSet);

        if (store)  {
            storeRevenue('PLN', outcomeTaxesDonePLNByMonth, outcomeTaxesDoneByMonth, forTaxesPLNByMonth, forTaxesByMonth, accountId, taxPercent, year, invoicesByMonth, maintenanceMap);
        }
        else {
            System.debug('Not storing: ');
            for (Integer month = 1; month < 13; month ++) {
                System.debug('Month ' + month);
                System.debug('outcomeTaxesDonePLNByMonth: ' + outcomeTaxesDonePLNByMonth.get(month));
                System.debug('outcomeTaxesDoneByMonth: ' + outcomeTaxesDoneByMonth.get(month));
                System.debug('forTaxesPLNByMonth: ' + forTaxesPLNByMonth.get(month));
                System.debug('forTaxesByMonth: ' + forTaxesByMonth.get(month));
            }


        }

        return maintenanceMap;
    }

    public static Map<Integer, EntityMonthlyMaintenance> populateTaxDataSpolka(Id accountId, Integer year, Decimal taxPercent) {
        return populateTaxDataSpolka(accountId, year, taxPercent, true);
    }

    public static Map<Integer, EntityMonthlyMaintenance> populateTaxDataSpolka(Id accountId, Integer year, Decimal taxPercent, Boolean store) {

        Set<Id> bankIdsSet = getBankIds(accountId);
        Map<Integer, Decimal> incomePLNByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> forTaxesByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> forTaxesPLNByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> outcomeTaxesDoneByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};
        Map<Integer, Decimal> outcomeTaxesDonePLNByMonth = new Map<Integer, Decimal>{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0};

        List<Invoice__c> allInvoices = getAllInvoices(bankIdsSet, year);
        Map<Integer, List<Invoice__c>> invoicesByMonth = new Map<Integer, List<Invoice__c>>();

        for (Invoice__c invoice : allInvoices) {
            List<String> parts = invoice.Invoice_Number__c == null ? new List<String>() : invoice.Invoice_Number__c.split('/');
            Decimal amount = invoice.Total__c;
            String curr = (String) invoice.CurrencyIsoCode;

            Date transactionCreated = invoiceTransactionDate(invoice);

            Integer month = transactionCreated.month();
            if (parts.size() > 1) {

                try {
                    Integer monthFromInvoiceNumber = Integer.valueOf(parts[1]);
                    month = monthFromInvoiceNumber;
                } catch (Exception e) {
                    System.debug('Failed to get month from invoice number, rollback to transaction/created date');
                }
            }

            Decimal finalAmount = 0;
            if (curr == 'EUR') finalAmount = convertEURToUSD(transactionCreated, amount);
            else finalAmount = invoice.Total__c;

            Decimal inPln = convertToPLN(transactionCreated, curr, amount);
            incomePLNByMonth.put(month, incomePLNByMonth.get(month)     + inPln);
            forTaxesPLNByMonth.put(month, forTaxesPLNByMonth.get(month) + inPln);
            forTaxesByMonth.put(month, forTaxesByMonth.get(month)   + finalAmount);

            if (invoicesByMonth.containsKey(month) == false) invoicesByMonth.put(month, new List<Invoice__c>());
            invoicesByMonth.get(month).add(invoice);

            System.debug('Month: ' + month + ', counted invoice: ' + invoice.Invoice_Number__c + ', ' + invoice.Total__c + ', ' + inPln + ' PLN');
        }


        List<Transaction__c> outcomeTransactions = getOutcomeTransactions(bankIdsSet, year);


        for (Transaction__c outcomeTransaction : outcomeTransactions) {
            Boolean skip = false;
            if (outcomeTransaction.Effective_Date__c == null) {
                outcomeTransaction.Effective_Date__c = outcomeTransaction.Date__c == null ? outcomeTransaction.CreatedDate.date() : outcomeTransaction.Date__c;
            }

            Integer month = outcomeTransaction.Effective_Date__c.month();

            if (outcomeTransaction.Compensation__c != null) skip = true;
            if (outcomeTransaction.Outcome_Category__c == 'Dividends')  skip = true;
            if (bankIdsSet.contains(outcomeTransaction.Income_Bank_Account__c))  skip = true;

            if (outcomeTransaction.Outcome_Category__c == 'Tax') {
                if (outcomeTransaction.Tax_Category__c == 'Income') {
                    outcomeTaxesDoneByMonth.put(
                            month,
                            outcomeTaxesDoneByMonth.get(month) +
                                    outcomeTransaction.Outcome_USD__c
                    );

                    outcomeTaxesDonePLNByMonth.put(
                            month,
                            outcomeTaxesDonePLNByMonth.get(month) +
                                    outcomeTransaction.Outcome__c
                    );
                    skip = true;
                }

                System.debug('Not a tax transaction: ' + outcomeTransaction.Id + ', ' + outcomeTransaction.Outcome_Category__c + ': ' + outcomeTransaction.Outcome_USD__c);
            }

            if (skip) {
                if (month == debugMonth) System.debug('Skipping: ' + outcomeTransaction.Outcome_USD__c + ', ' + outcomeTransaction.Outcome_Category__c + ' ' + outcomeTransaction.Compensation__c + '  ' + outcomeTransaction.Expense_Region__c + ' ' + outcomeTransaction.Description__c + ' ' + outcomeTransaction.Id);
                continue;
            } else {
                if (month == debugMonth) {
                    System.debug('Not Skipping: ' + outcomeTransaction.Outcome_USD__c + ', ' + outcomeTransaction.Outcome_Category__c + ' ' + outcomeTransaction.Compensation__c + '  ' + outcomeTransaction.Expense_Region__c + ' ' + outcomeTransaction.Description__c + ' ' + outcomeTransaction.Id);
                }
            }

            System.debug('outcomeTransaction: ' + outcomeTransaction.Outcome_USD__c);
            forTaxesByMonth.put(month, forTaxesByMonth.get(month) - outcomeTransaction.Outcome_USD__c);
            System.debug('forTaxesByMonth: ' + forTaxesByMonth.get(month));
            Decimal inPln = convertToPLN(
                    outcomeTransaction.Effective_Date__c == null ?
                            outcomeTransaction.CreatedDate.date() :
                            outcomeTransaction.Effective_Date__c,
                    'USD',
                    outcomeTransaction.Outcome_USD__c
            );
            System.debug('Same transaction in PLN: ' + inPln);
            forTaxesPLNByMonth.put(month, forTaxesPLNByMonth.get(month) - inPln);
            System.debug('forTaxesPLNByMonth: ' + forTaxesPLNByMonth.get(month));

        }
        Map<Integer, EntityMonthlyMaintenance> maintenanceMap = getMaintenanceTransactions2(outcomeTransactions, bankIdsSet);
        //Map<Integer, Map<String, List<Transaction__c>>> maintenance = getMaintenanceTransactions(outcomeTransactions, bankIdsSet);

        if (store)  {
            storeRevenue('PLN', outcomeTaxesDonePLNByMonth, outcomeTaxesDoneByMonth, forTaxesPLNByMonth, forTaxesByMonth, accountId, taxPercent, year, invoicesByMonth, maintenanceMap);
        }
        else {
            System.debug('Not storing: ');
            for (Integer month = 1; month < 13; month ++) {
                System.debug('Month ' + month);
                System.debug('outcomeTaxesDonePLNByMonth: ' + outcomeTaxesDonePLNByMonth.get(month));
                System.debug('outcomeTaxesDoneByMonth: ' + outcomeTaxesDoneByMonth.get(month));
                System.debug('forTaxesPLNByMonth: ' + forTaxesPLNByMonth.get(month));
                System.debug('forTaxesByMonth: ' + forTaxesByMonth.get(month));
            }
        }

        return maintenanceMap;
        //storeRevenue('PLN', outcomeTaxesDonePLNByMonth, outcomeTaxesDoneByMonth, forTaxesPLNByMonth, forTaxesByMonth, accountId, taxPercent, year, invoicesByMonth);
    }

    private static Date invoiceTransactionDate(Invoice__c invoice){
        Date transactionCreated = System.today();
        for (Transaction__c invoiceTransaction : invoice.Transactions__r) {
            Date transactionDate = invoiceTransaction.Effective_Date__c == null ? invoiceTransaction.CreatedDate.date() : invoiceTransaction.Effective_Date__c;

            if (transactionDate < transactionCreated) transactionCreated = transactionDate;

        }

        return transactionCreated;
    }

    private static final Map<String, String> defaultApplyToByCategoryMapping = new Map<String, String>{
            'Legal and Accounting' => 'Unit',
            'Software' => 'All',
            'Tax' => 'Unit',
            'Office' => 'Unit'
    };

    public static String getOutcomeTransactionApplyTo(Transaction__c outcomeTransaction, String defaultValue) {
        if (String.isNotEmpty(outcomeTransaction.Apply_To__c)) return outcomeTransaction.Apply_To__c;
        if (defaultApplyToByCategoryMapping.containsKey(outcomeTransaction.Outcome_Category__c)) return defaultApplyToByCategoryMapping.get(outcomeTransaction.Outcome_Category__c);
        return defaultValue;
    }

    public static Map<Integer, EntityMonthlyMaintenance> getMaintenanceTransactions2(List<Transaction__c> outcomeTransactions, Set<Id> bankIdsSet) {
        Set<String> skipCategories = new Set<String>{'Salary', 'Transfer'};
        Map<Integer, EntityMonthlyMaintenance> output = new Map<Integer, EntityMonthlyMaintenance>();

        Map<Integer, Map<String, List<Transaction__c>>> entityMaintenanceTransactions = new Map<Integer, Map<String, List<Transaction__c>>>();
        for (Transaction__c outcomeTransaction : outcomeTransactions) {
            if (outcomeTransaction.Effective_Date__c == null) {
                outcomeTransaction.Effective_Date__c = outcomeTransaction.Date__c == null ? outcomeTransaction.CreatedDate.date() : outcomeTransaction.Date__c;
            }

            Integer month = outcomeTransaction.Effective_Date__c.month();
            if (outcomeTransaction.Compensation__c != null) continue;
            if (bankIdsSet.contains(outcomeTransaction.Income_Bank_Account__c)) continue;
            if (outcomeTransaction.Outcome_Category__c == 'Tax' && outcomeTransaction.Tax_Category__c == 'Income') continue;
            if (skipCategories.contains(outcomeTransaction.Outcome_Category__c)) continue;

            System.debug(outcomeTransaction.Id + ', ' + outcomeTransaction.Outcome_Category__c + ', ' + outcomeTransaction.Description__c + ' (' + outcomeTransaction.Effective_Distribution__c + ' for ' + outcomeTransaction.Expense_Region__c + '): ' + outcomeTransaction.Outcome_USD__c);

            outcomeTransaction.Apply_To__c = getOutcomeTransactionApplyTo(outcomeTransaction, 'Unit');

            if (!entityMaintenanceTransactions.containsKey(month)) entityMaintenanceTransactions.put(month, new Map<String, List<Transaction__c>>());
            if (!entityMaintenanceTransactions.get(month).containsKey(outcomeTransaction.Apply_To__c)) entityMaintenanceTransactions.get(month).put(outcomeTransaction.Apply_To__c, new List<Transaction__c>());
            entityMaintenanceTransactions.get(month).get(outcomeTransaction.Apply_To__c).add(outcomeTransaction);

        }


//        Map<Integer, Map<String, List<Transaction__c>>> oldData = entityMaintenanceTransactions;//getMaintenanceTransactions(outcomeTransactions, bankIdsSet);


        for (Integer m : entityMaintenanceTransactions.keySet()) {
            output.put(m, new EntityMonthlyMaintenance(m, entityMaintenanceTransactions.get(m)));
        }

        for (Transaction__c outcomeTransaction : outcomeTransactions) {
            System.debug('outcomeTransaction: ' + outcomeTransaction.Id + ', ' + outcomeTransaction.Outcome_Category__c + ', ' + outcomeTransaction.Outcome_Bank_Account__c + ', ' + outcomeTransaction.Compensation__c);
            if (outcomeTransaction.Outcome_Category__c == 'Salary') continue;
            if (outcomeTransaction.Income_Bank_Account__c != null) continue; // перевод самим себе куда-то
            if (outcomeTransaction.Compensation__c != null) continue; // не общие расходы; учтутся в эффективности сотрудника
            if (outcomeTransaction.Effective_Date__c == null) {
                outcomeTransaction.Effective_Date__c = outcomeTransaction.Date__c == null ? outcomeTransaction.CreatedDate.date() : outcomeTransaction.Date__c;
            }

            System.debug('added');

            Integer month = outcomeTransaction.Effective_Date__c.month();
            if (output.containsKey(month)) {
                output.get(month).outcomeTransactions.add(outcomeTransaction);
                if (outcomeTransaction.Apply_To__c == 'Unit') output.get(month).addUnitTransaction(outcomeTransaction);
                else if (outcomeTransaction.Apply_To__c == 'All') output.get(month).addAllTransaction(outcomeTransaction);
                else {
                    System.debug('Apply to is not defined; assuming Unit');
                    output.get(month).addAllTransaction(outcomeTransaction);
                }

            }

        }

        return output;
    }

    // month → applyTo → transaction[]
    public static Map<Integer, Map<String, List<Transaction__c>>> getMaintenanceTransactions(List<Transaction__c> outcomeTransactions, Set<Id> bankIdsSet){
        Set<String> skipCategories = new Set<String>{'Salary', 'Transfer'};

        Map<Integer, Map<String, List<Transaction__c>>> entityMaintenanceTransactions = new Map<Integer, Map<String, List<Transaction__c>>>();
        for (Transaction__c outcomeTransaction : outcomeTransactions) {
            if (outcomeTransaction.Effective_Date__c == null) {
                outcomeTransaction.Effective_Date__c = outcomeTransaction.Date__c == null ? outcomeTransaction.CreatedDate.date() : outcomeTransaction.Date__c;
            }

            Integer month = outcomeTransaction.Effective_Date__c.month();
            if (outcomeTransaction.Compensation__c != null) continue;
            if (bankIdsSet.contains(outcomeTransaction.Income_Bank_Account__c)) continue;
            if (outcomeTransaction.Outcome_Category__c == 'Tax' && outcomeTransaction.Tax_Category__c == 'Income') continue;
            if (skipCategories.contains(outcomeTransaction.Outcome_Category__c)) continue;

            System.debug(outcomeTransaction.Id + ', ' + outcomeTransaction.Outcome_Category__c + ', ' + outcomeTransaction.Description__c + ' (' + outcomeTransaction.Effective_Distribution__c + ' for ' + outcomeTransaction.Expense_Region__c + '): ' + outcomeTransaction.Outcome_USD__c);

            outcomeTransaction.Apply_To__c = getOutcomeTransactionApplyTo(outcomeTransaction, 'Unit');

            if (!entityMaintenanceTransactions.containsKey(month)) entityMaintenanceTransactions.put(month, new Map<String, List<Transaction__c>>());
            if (!entityMaintenanceTransactions.get(month).containsKey(outcomeTransaction.Apply_To__c)) entityMaintenanceTransactions.get(month).put(outcomeTransaction.Apply_To__c, new List<Transaction__c>());
            entityMaintenanceTransactions.get(month).get(outcomeTransaction.Apply_To__c).add(outcomeTransaction);

        }

        return entityMaintenanceTransactions;
    }

    class APIResponse {
        public Boolean success;
        public Boolean historical;
        public String source;
        public Map<String, Map<String, Decimal>> quotes;
    }

    public class EntityMonthlyMaintenance {
        public List<Transaction__c> outcomeTransactions = new List<Transaction__c>();
        public Map<String, List<Transaction__c>> maintenanceTransactions = new Map<String, List<Transaction__c>>();
        public Integer month = 0;

//        public List<Transaction__c> transactionsSpentUnit = new List<Transaction__c>();
//        public List<Transaction__c> transactionsSpentAll = new List<Transaction__c>();

        Map<Id, Transaction__c> transactionsSpentAllMap = new Map<Id, Transaction__c>();
        Map<Id, Transaction__c> transactionsSpentUnitMap = new Map<Id, Transaction__c>();

        public List<Transaction__c> getSpentUnitTransactions(){ return transactionsSpentUnitMap.values();}
        public List<Transaction__c> getSpentAllTransactions(){ return transactionsSpentAllMap.values();}

        public EntityMonthlyMaintenance addUnitTransaction(Transaction__c tr){
            transactionsSpentUnitMap.put(tr.Id, tr);
            return this;
        }

        public EntityMonthlyMaintenance addAllTransaction(Transaction__c tr){
            transactionsSpentAllMap.put(tr.Id, tr);
            return this;
        }

        public EntityMonthlyMaintenance(Integer month, Map<String, List<Transaction__c>> maintenanceTransactions){
            this.month = month;
            this.maintenanceTransactions = maintenanceTransactions;
        }
    }
}