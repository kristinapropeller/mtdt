/*
 * MIT License
 *
 * Copyright (c) 2018 - 2020 Click to Cloud Pty Ltd, Propic Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
@IsTest
private class pp_QuerySearch_Test {
    @IsTest
    static void simpleTest() {
        pp_QuerySearch qs = new pp_QuerySearch()
                .find('ABC')
                .inNameFields()
                .inEmailFields()
                .inPhoneFields()
                .inSidebarFields()
                .returning('Account')
                .selectFields('Name, Phone');

        String str = qs.toSearchString();

        Assert.areEqual(getFindClause(str), '"ABC"');

        Account acc = new Account(Name = 'ABC Ltd',
                Phone = '+61 410 000 000');
        insert acc;

        Test.setFixedSearchResults(new List<Id>{
                acc.Id
        });

        List<Account> accounts = qs.run()[0];

        Assert.isFalse(accounts.isEmpty());
        Assert.areEqual(accounts[0].Id, acc.Id);
        Assert.areEqual(accounts[0].Name, 'ABC Ltd');
        Assert.areEqual(accounts[0].Phone, '+61 410 000 000');
    }
    @IsTest
    static void conditionsTest() {
        pp_QuerySearch qs = new pp_QuerySearch()
                .find(pp_QuerySearch.doOr(pp_QuerySearch.doOr('ABC', 'BCA'), pp_QuerySearch.doOr('CBA', 'ACB')))
                .inNameFields()
                .returning('Account')
                .addConditionEq('Phone', '+61 410 000 000')
                .addConditionNotEq('Phone', null)
                .addConditionLike('Phone', '+61%')
                .addConditionIn('Name', new Set<String>{'ABC Ltd'})
                .addConditionNotIn('Name', new Set<String>{'CBA Ltd'})
                .addConditionLt('Phone', '+61 410 999 999')
                .addConditionGt('Phone', '+61 409 999 999')
                .addConditionGe('Name', 'ABC Ltd')
                .addConditionLe('Name', 'ABC Ltd')
                .selectFields('Name, Phone');

        String str = qs.toSearchString();

        Assert.areEqual(getFindClause(str), '(("ABC") OR ("BCA")) OR (("CBA") OR ("ACB"))');

        Account acc = new Account(Name = 'ABC Ltd',
                Phone = '+61 410 000 000');
        insert acc;

        Test.setFixedSearchResults(new List<Id>{
                acc.Id
        });

        List<Account> accounts = qs.run()[0];

        Assert.isFalse(accounts.isEmpty());
        Assert.areEqual(accounts[0].Id, acc.Id);
        Assert.areEqual(accounts[0].Name, 'ABC Ltd');
        Assert.areEqual(accounts[0].Phone, '+61 410 000 000');
    }
    @IsTest
    static void anotherConditionsTest() {
        pp_QuerySearch qs = new pp_QuerySearch()
                .find(pp_QuerySearch.doOr(pp_QuerySearch.doOr('ABC', 'BCA'), pp_QuerySearch.doOr('CBA', 'ACB')))
                .inNameFields()
                .returning('Account')
                .addConditionEq(Account.Phone, '+61 410 000 000')
                .addConditionNotEq(Account.Phone, null)
                .addConditionLike(Account.Phone, '+61%')
                .addConditionIn(Account.Name, new Set<String>{'ABC Ltd'})
                .addConditionNotIn(Account.Name, new Set<String>{'CBA Ltd'})
                .addConditionLt(Account.Phone, '+61 410 999 999')
                .addConditionGt(Account.Phone, '+61 409 999 999')
                .addConditionGe(Account.Name, 'ABC Ltd')
                .addConditionLe(Account.Name, 'ABC Ltd')
                .selectFields(new List<String>{'Name', 'Phone'});

        String str = qs.toSearchString();

        Assert.areEqual(getFindClause(str), '(("ABC") OR ("BCA")) OR (("CBA") OR ("ACB"))');

        Account acc = new Account(Name = 'ABC Ltd',
                Phone = '+61 410 000 000');
        insert acc;

        Test.setFixedSearchResults(new List<Id>{
                acc.Id
        });

        List<Account> accounts = qs.run()[0];

        Assert.isFalse(accounts.isEmpty());
        Assert.areEqual(accounts[0].Id, acc.Id);
        Assert.areEqual(accounts[0].Name, 'ABC Ltd');
        Assert.areEqual(accounts[0].Phone, '+61 410 000 000');
    }
    @IsTest
    static void limitTest() {
        Account acc0 = new Account(Name = 'Account 0', Phone = '+61 410 000 000');
        Account acc1 = new Account(Name = 'Account 0', Phone = '+61 410 000 000');
        Account acc2 = new Account(Name = 'Account 0', Phone = '+61 410 000 000');

        insert new List<Account>{
                acc0, acc1, acc2
        };
        pp_QuerySearch qs = new pp_QuerySearch()
                .find('Account')
                .inAllFields()
                .returning('Account')
                .selectFields('Name, Phone')
                .setLimit(2);

        String str = qs.toSearchString();
        Test.setFixedSearchResults(new List<Id>{
                acc0.Id, acc1.Id, acc2.Id
        });
        List<Account> accounts = qs.run()[0];
        Assert.areEqual(accounts.size(), 2);
    }

    @IsTest
    static void runIdOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '5');

        insert new List<Account>{
                acc1, acc2, acc3
        };

        List<Account> accounts;
        Test.setFixedSearchResults(new List<Id>{
                acc1.Id, acc2.Id, acc3.Id
        });

        accounts = new pp_QuerySearch()
                .find('Account')
                .inNameFields()
                .returning('Account')
                .selectFields('Name, Rating')
                .orderBy('Rating', 'DESC')
                .run()[0];

        Assert.areEqual(accounts.get(0).Name, 'Account 2');
        Assert.areEqual(accounts.get(1).Name, 'Account 3');
        Assert.areEqual(accounts.get(2).Name, 'Account 1');
    }

    @IsTest
    static void findClauseTest() {
        String str;

        str = new pp_QuerySearch()
                .find('ABC')
                .find('CBA')
                .toSearchString();

        Assert.areEqual(getFindClause(str), '("ABC") AND ("CBA")');

        str = new pp_QuerySearch()
                .find(pp_QuerySearch.doAnd('ABC', 'CBA'))
                .toSearchString();

        Assert.areEqual(getFindClause(str), '("ABC") AND ("CBA")');

        str = new pp_QuerySearch()
                .find(pp_QuerySearch.doOr('ABC', 'CBA'))
                .toSearchString();

        Assert.areEqual(getFindClause(str), '("ABC") OR ("CBA")');

        str = new pp_QuerySearch()
                .find(pp_QuerySearch.doOr(pp_QuerySearch.doAnd('ABC', 'BCA'), 'CBA'))
                .toSearchString();

        Assert.areEqual(getFindClause(str), '(("ABC") AND ("BCA")) OR ("CBA")');
    }

    /*
     * The FIND clause is irrelevant to the SOSL result in APEX test code, so we
     * need an extra step to test the FIND clause.
     * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_SOSL.htm
     */
    static String getFindClause(String searchString) {
        Matcher m = Pattern.compile('FIND \\{(.*)\\}.*').matcher(searchString);
        Assert.isTrue(m.matches());
        return m.group(1);
    }
}