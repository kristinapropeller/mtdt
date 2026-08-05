/**
 * Created on 19.04.23.
 */

@IsTest
private class newCompensationsControllerTest {

    @IsTest
    static void doInitTest() {
        Map<String, String> options = newCompensationsController.getPicklistValues('Compensation__c', 'CurrencyIsoCode');
        System.assert(!options.isEmpty());
    }
}