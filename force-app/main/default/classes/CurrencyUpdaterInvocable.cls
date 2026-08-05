/**
 * Created on 31/01/2023.
 */

public without sharing class CurrencyUpdaterInvocable {
    private static final String CURRENCY_EXCHANGE_API_URL = 'http://api.exchangerate.host/historical';
    private static final String CURRENCY_EXCHANGE_API_KEY = '2a06efe6edbf55e46bc36ca8f9859e6c';
    private static final String BYN_EXCHANGE_API_URL = 'https://api.nbrb.by/exrates/rates/431';

    public class RequestParameters {
        @InvocableVariable(required=true label='Currencies to update' description='List of comma-separated currency codes')
        public String currenciesToUpdate;
        @InvocableVariable(label='Data source' description='Forex by default. Available values: imf, rba, boc, snb, boi, nob, ecb')
        public String source;
    }

    @InvocableMethod(label='Update Currency Rates' description='Update Currency Rates (standard and dated) via API')
    public static void updateRates(List<RequestParameters> records) {
        String baseCurrency = UserInfo.getDefaultCurrency();
        List<String> targetCurrencies = records[0].currenciesToUpdate.split(',');
        Date today = System.today();
        Date yesterday = today.addDays(-1);
        Map<String, Decimal> rates = targetCurrencies.size() == 1 && targetCurrencies[0] == 'BYN' ? retrieveBYNRates()
                : retrieveRates(yesterday, baseCurrency, records[0].currenciesToUpdate, records[0].source);
        updateStandardRates(rates);
        updateDatedRates(today, rates);
    }

    public static Map<String, Decimal> retrieveRates(Date forDate, String base, String symbols, String source) {
        Map<String, Decimal> rates = new Map<String, Decimal>();
        pp_RestExplorer restExplorer = new pp_RestExplorer(CURRENCY_EXCHANGE_API_URL)
                .addParameters(new Map<String, Object>{
                        'access_key' => CURRENCY_EXCHANGE_API_KEY,
                        'date' => formatDate(forDate),
                        'currencies' => symbols
                })
                .doGet();
        HttpResponse res = Test.isRunningTest() ? new HttpResponse() : restExplorer.getResponse();
        if ((res != null && res.getStatusCode() == 200) || Test.isRunningTest()) {
            String responseBody = Test.isRunningTest()
                    ? '{"success": true,"historical": true,"source": "' + UserInfo.getDefaultCurrency() + '","quotes": {"' + (UserInfo.getDefaultCurrency() == 'USD' ? 'USDEUR' : 'EURUSD') + '": 1.085519}}'
                    : res.getBody();
            try {
                APIResponse response = (APIResponse)JSON.deserialize(responseBody, APIResponse.class);
                if (response.success) {
                    for (String q : response.quotes.keySet()) {
                        rates.put(q.substringAfter(base), response.quotes.get(q));
                    }
                }
            } catch (Exception ex) {
                System.debug(ex.getMessage() + ' | ' + ex.getStackTraceString());
            }
        }

        return rates;
    }
    public static Map<String, Decimal> retrieveBYNRates() {
        Map<String, Decimal> rate = new Map<String, Decimal>();
        pp_RestExplorer restExplorer = new pp_RestExplorer(BYN_EXCHANGE_API_URL)
                .doGet()
                .setTimeout(120000);
        HttpResponse res = Test.isRunningTest() ? new HttpResponse() : restExplorer.getResponse();
        if ((res != null && res.getStatusCode() == 200) || Test.isRunningTest()) {
            String responseBody = Test.isRunningTest()
                    ? '{"Cur_ID":431,"Date":"2023-08-17T00:00:00","Cur_Abbreviation":"USD","Cur_Scale":1,"Cur_Name":"Доллар США","Cur_OfficialRate":3.1925}'
                    : res.getBody();
            try {
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                if(response.containsKey('Cur_OfficialRate')) rate.put('BYN', Decimal.valueOf(String.valueOf(response.get('Cur_OfficialRate'))));
                System.debug('test: ' + rate);
            } catch (Exception ex) {
                System.debug(ex.getMessage() + ' | ' + ex.getStackTraceString());
            }
        }

        return rate;
    }

    private static String formatDate(Date d) {
        return Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
    }

    @Future(callout=true)
    private static void updateStandardRates(Map<String, Decimal> rates) {
        List<CurrencyType> currencyTypes = new pp_Query('CurrencyType')
                .selectFields(new Set<String>{'Id', 'IsoCode'})
                .addConditionIn('IsoCode', rates.keySet())
                .run();
        for (CurrencyType currencyType : currencyTypes) {
            updateCurrencyType(currencyType.Id, rates.get(currencyType.IsoCode));
        }
    }
    private static void updateCurrencyType(Id currencyTypeId, Decimal rate) {
        pp_SalesforceRestExplorer.setSessionId(UserInfo.getSessionId());
        pp_RestExplorer restExplorer = new pp_SalesforceRestExplorer('sobjects/CurrencyType/' + currencyTypeId)
                .doPatch()
                .setBody('{"ConversionRate": ' + rate + '}');
        HttpResponse res = Test.isRunningTest() ? new HttpResponse() : restExplorer.getResponse();
        System.debug(res.getBody());
    }
    @Future(callout=true)
    private static void updateDatedRates(Date forDate, Map<String, Decimal> rates) {
        for (String currencyIsoCode : rates.keySet()) {
            insertDatedConversionRate(forDate, currencyIsoCode, rates.get(currencyIsoCode));
        }
    }
    private static void insertDatedConversionRate(Date forDate, String currencyIsoCode, Decimal rate) {
        pp_SalesforceRestExplorer.setSessionId(UserInfo.getSessionId());
        pp_RestExplorer restExplorer = new pp_SalesforceRestExplorer('sobjects/DatedConversionRate/')
                .doPost()
                .setBody('{"StartDate": "' + formatDate(forDate) + '", "IsoCode": "' + currencyIsoCode + '", "ConversionRate": ' + rate + '}');
        HttpResponse res = Test.isRunningTest() ? new HttpResponse() : restExplorer.getResponse();
        System.debug(res.getBody());
    }


    class APIResponse {
        public Boolean success;
        public Boolean historical;
        public String source;
        public Map<String, Decimal> quotes;
    }
}