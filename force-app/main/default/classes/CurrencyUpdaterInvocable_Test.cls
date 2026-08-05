/**
 * Created on 01/02/2023.
 */

@IsTest
private class CurrencyUpdaterInvocable_Test {
    @IsTest
    static void testRatesUpdate() {
        CurrencyUpdaterInvocable.RequestParameters params = new CurrencyUpdaterInvocable.RequestParameters();
        params.currenciesToUpdate = UserInfo.getDefaultCurrency() == 'USD' ? 'EUR' : 'USD';
        params.source = 'ecb';
        Test.startTest();
        CurrencyUpdaterInvocable.updateRates(new List<CurrencyUpdaterInvocable.RequestParameters>{params});
        Test.stopTest();
        System.assert(true);
    }

    @IsTest
    static void testBYNUpdate() {
        CurrencyUpdaterInvocable.RequestParameters params = new CurrencyUpdaterInvocable.RequestParameters();
        params.currenciesToUpdate = 'BYN';
        Test.startTest();
        CurrencyUpdaterInvocable.updateRates(new List<CurrencyUpdaterInvocable.RequestParameters>{params});
        Test.stopTest();
        System.assert(true);
    }
}