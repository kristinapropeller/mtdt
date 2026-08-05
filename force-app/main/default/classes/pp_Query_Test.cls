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
private class pp_Query_Test {
    @IsTest
    static void simpleTest() {
        createData();
        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query(Account.getSObjectType())
                .selectAllFields()
                .run();

        assertAccount(accounts.get(0));
    }

    @IsTest
    static void selectReadableFieldsTest() {
        createData();
        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectReadableFields()
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query(Account.getSObjectType())
                .selectEditableFields()
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query(Account.getSObjectType())
                .selectCreatableFields()
                .run();

        assertAccount(accounts.get(0));
    }

    @IsTest
    static void selectAllFieldsTest() {
        createData();
        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query(Account.getSObjectType())
                .selectEditableFields()
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query(Account.getSObjectType())
                .selectCreatableFields()
                .run();

        assertAccount(accounts.get(0));
    }

    @IsTest
    static void getSObjectTypeTest() {
        Assert.areEqual(
                new pp_Query('Account').getSObjectType(),
                Account.getSObjectType()
        );
    }

    @IsTest
    static void fetchTest() {
        Account acc0 = new Account(Name = 'Account 0');
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');

        insert new List<Account>{
                acc0, acc1, acc2
        };

        List<Account> accounts = new pp_Query('Account')
                .selectAllFields()
                .fetch(1, 3);

        Assert.areEqual(accounts.size(), 2);
        Assert.areEqual(accounts.get(0).Name, 'Account 1');
        Assert.areEqual(accounts.get(1).Name, 'Account 2');

        Account account;

        List<Account> accountsList = new pp_Query('Account')
                .selectAllFields()
                .fetch(2);
        Assert.areEqual(accountsList.get(0).Name, 'Account 0');
        Assert.areEqual(accountsList.get(1).Name, 'Account 1');
        Assert.areEqual(accountsList.size(), 2);

        account = (Account) new pp_Query('Account')
                .selectAllFields()
                .fetch();
        Assert.areEqual(account.Name, 'Account 0');

    }

    @IsTest
    static void toIdListTest() {
        createData();

        List<Id> idList = new pp_Query('Account').toIdList();

        Assert.areEqual(idList.size(), 1);
    }

    @IsTest
    static void OptionalClauseTest() {
        createData();

        List<Account> accountsForView = new pp_Query('Account').forView().run();
        List<Account> accountsForUpdate = new pp_Query('Account').forUpdate().run();
        List<Account> accountsForReference = new pp_Query('Account').forReference().run();

    }

    @IsTest
    static void runPreservingIdOrderTest() {
        Account acc0 = new Account(Name = 'Account 0');
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');

        insert acc1;
        insert acc0;
        insert acc2;

        List<Id> idList = new List<Id>{
                acc0.Id, acc1.Id, acc2.Id, acc0.Id
        };

        List<Account> accounts = new pp_Query('Account').runPreservingIdOrder(idList);

        Assert.areEqual(accounts.get(0).Id, acc0.Id);
        Assert.areEqual(accounts.get(1).Id, acc1.Id);
        Assert.areEqual(accounts.get(2).Id, acc2.Id);
        Assert.areEqual(accounts.get(3).Id, acc0.Id);
    }

    @IsTest
    static void fieldsTest() {
        createData();

        List<Account> accounts = new pp_Query('Account')
                .selectField('Id')
                .selectFields('Name')
                .selectFields('Phone, Sic')
                .selectFields(new List<String>{
                        'NumberOfEmployees', 'Website'
                })
                .selectFields(new Set<String>{
                        'Fax', 'Site'
                })
                .selectAllFields()
                .run();

        assertAccount(accounts.get(0));
    }

    @IsTest
    static void readableParentFieldsTest() {
        createData();

        List<Opportunity> opportunities;

        opportunities = new pp_Query('Opportunity')
                .selectReadableFields()
                .selectReadableFields('CreatedBy')
                .selectReadableFields('Account.LastModifiedBy')
                .selectFields('Account.CreatedBy.FirstName')
                .selectFields('LastModifiedBy.FirstName, LastModifiedBy.LastName')
                .selectFields(new List<String>{
                        'Owner.FirstName', 'Owner.LastName'
                })
                .run();

        assertOpportunity(opportunities.get(0));

        Assert.areNotEqual(opportunities.get(0).CreatedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Account.CreatedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Account.LastModifiedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).LastModifiedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).LastModifiedBy.LastName, null);
        Assert.areNotEqual(opportunities.get(0).Owner.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Owner.LastName, null);
    }

    @IsTest
    static void allParentFieldsTest() {
        createData();

        List<Opportunity> opportunities;

        opportunities = new pp_Query('Opportunity')
                .selectAllFields()
                .selectAllFields('CreatedBy')
                .selectAllFields('Account.LastModifiedBy')
                .selectFields('Account.CreatedBy.FirstName')
                .selectFields('LastModifiedBy.FirstName, LastModifiedBy.LastName')
                .selectFields(new List<String>{
                        'Owner.FirstName', 'Owner.LastName'
                })
                .run();

        assertOpportunity(opportunities.get(0));

        Assert.areNotEqual(opportunities.get(0).CreatedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Account.CreatedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Account.LastModifiedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).LastModifiedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).LastModifiedBy.LastName, null);
        Assert.areNotEqual(opportunities.get(0).Owner.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Owner.LastName, null);
    }

    @IsTest
    static void idTest() {
        createData();

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .byId(accId)
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .byId(new Set<Id>{
                        accId
                })
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .byId(new List<Id>{
                        accId
                })
                .run();

        assertAccount(accounts.get(0));

        // negative cases
        final Id wrongId = 'a0EO000000DjJeJMAV';
        accounts = new pp_Query('Account')
                .selectAllFields()
                .byId(wrongId)
                .run();

        Assert.isTrue(accounts.isEmpty());
    }

    @IsTest
    static void lookupTest() {
        createData();

        Account account = [SELECT Id FROM Account LIMIT 1];

        List<Opportunity> opportunities;

        opportunities =
                new pp_Query('Opportunity')
                        .selectAllFields()
                        .lookup('AccountId', account.Id)
                        .run();

        assertOpportunity(opportunities.get(0));

        opportunities =
                new pp_Query('Opportunity')
                        .selectAllFields()
                        .lookup('AccountId', new List<Id>{
                                account.Id
                        })
                        .run();

        assertOpportunity(opportunities.get(0));

        opportunities =
                new pp_Query('Opportunity')
                        .selectAllFields()
                        .lookup('AccountId', account)
                        .run();

        assertOpportunity(opportunities.get(0));
    }

    @IsTest
    static void simpleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionEq('Name', 'ABC Ltd')
                .addConditionNull('AccountNumber')
                .run();

        assertAccount(accounts.get(0));

        // negative cases
        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionNotNull('Name')
                .addConditionEq('Phone', '+61 410 111 111')
                .run();

        Assert.isTrue(accounts.isEmpty());
    }

    @IsTest
    static void singleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionEq('Name', 'ABC Ltd')
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionNotEq('Name', 'CDE Ltd')
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionIn('Name', new Set<String>{
                        'ABC Ltd'
                })
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionNotIn('Name', new Set<String>{
                        'CDE Ltd'
                })
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionLt('NumberOfEmployees', 15)
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionLe('NumberOfEmployees', 10)
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionGt('NumberOfEmployees', 5)
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionGe('NumberOfEmployees', 10)
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionLike('Name', '%ABC%')
                .run();

        assertAccount(accounts.get(0));

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addConditionNotLike('Name', '%CBA%')
                .run();

        assertAccount(accounts.get(0));
    }

    @IsTest
    static void disjunctionConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .switchToDisjunction()
                .addConditionEq('Name', 'ABC Ltd')
                .addConditionEq('Phone', '+61 410 111 111')
                .run();

        assertAccount(accounts.get(0));

        // negative cases

        accounts = new pp_Query('Account')
                .selectAllFields()
                .switchToDisjunction()
                .addConditionEq('Name', 'ABC Ltd')
                .addConditionEq('Phone', '+61 410 111 111')
                .switchToConjunction()
                .run();

        Assert.isTrue(accounts.isEmpty());
    }

    @IsTest
    static void conditionTypeSimpleTest() {
        createData();

        List<Account> accounts = new pp_Query('Account')
                .selectAllFields()
                .addCondition(pp_Query.conditionEq('Name', 'ABC Ltd'))
                .run();

        assertAccount(accounts.get(0));
    }

    @IsTest
    static void conditionIncludeTest() {
        QuickText text = new QuickText(
                Name = 'MyQuickText',
                Message = 'MyMessage',
                Channel = 'Channel1;Channel2'
        );
        insert text;

        List<QuickText> result = new pp_Query('QuickText')
                .selectFields('Name, Message, Channel')
                .addConditionIncludes('Channel', 'Channel1')
                .run();

        Assert.areEqual(result.size(), 1);
        Assert.areEqual(result[0].Name, 'MyQuickText');

    }

    @IsTest
    static void conditionExcludesTest() {
        QuickText text1 = new QuickText(
                Name = 'MyQuickText1',
                Message = 'MyMessage1',
                Channel = 'Channel1;Channel2'
        );

        QuickText text2 = new QuickText(
                Name = 'MyQuickText2',
                Message = 'MyMessage2',
                Channel = 'Channel3;Channel4'
        );

        insert new List<QuickText>{
                text1, text2
        };

        List<QuickText> result = new pp_Query('QuickText')
                .selectFields('Name, Message, Channel')
                .addConditionExcludes('Channel', 'Channel2')
                .run();

        Assert.areEqual(result.size(), 1);
        Assert.areEqual(result[0].Name, 'MyQuickText2');

    }

    @IsTest
    static void complexConditionTest() {
        createData();

        String accName = 'ABC Ltd';
        List<String> accPhone = new List<String>{
                '+61 410 000 000'
        };
        final Id wrongId = 'a0EO000000DjJeJMAV';

        List<Account> accounts =
                new pp_Query('Account')
                        .selectAllFields()
                        .addCondition(
                                pp_Query.doAnd(
                                        pp_Query.doOr(
                                                pp_Query.conditionEq('Name', accName),
                                                pp_Query.conditionEq('Id', wrongId)
                                        ),
                                        pp_Query.conditionIn('Phone', accPhone),
                                        pp_Query.doNot(
                                                pp_Query.doOr(
                                                        pp_Query.conditionNotEq('Website', 'https://www.samplewebsite.com'),
                                                        pp_Query.conditionGt('NumberOfEmployees', 15)
                                                )
                                        ),
                                        pp_Query.doOr(
                                                pp_Query.conditionNull('AccountNumber'),
                                                pp_Query.conditionNotNull('Sic')
                                        )
                                )
                        )
                        .run();

        assertAccount(accounts.get(0));
    }

    @IsTest
    static void limitTest() {
        createData();
        createData();
        createData();

        List<Account> accounts = new pp_Query('Account')
                .selectAllFields()
                .setLimit(1)
                .run();

        Assert.areEqual(accounts.size(), 1);
        assertAccount(accounts.get(0));
    }

    @IsTest
    static void offsetTest() {
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');
        Account acc3 = new Account(Name = 'Account 3');
        Account acc4 = new Account(Name = 'Account 4');

        insert new List<Account>{
                acc1, acc2, acc3, acc4
        };

        List<Account> accounts;
        accounts = new pp_Query('Account')
                .selectAllFields()
                .setOffset(2)
                .run();

        Assert.areEqual(accounts.size(), 2);
        Assert.areEqual(accounts.get(0).Name, 'Account 3');
    }

    @IsTest
    static void orderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '5');

        insert new List<Account>{
                acc1, acc2, acc3
        };

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .orderBy('Rating', 'DESC')
                .run();

        Assert.areEqual(accounts.get(0).Name, 'Account 2');
        Assert.areEqual(accounts.get(1).Name, 'Account 3');
        Assert.areEqual(accounts.get(2).Name, 'Account 1');

    }

    @IsTest
    static void multipleOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', Phone = '110');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', Phone = '120');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', Phone = '130');

        insert new List<Account>{
                acc1, acc2, acc3
        };

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .orderBy('Rating', 'DESC')
                .orderBy('Phone', 'ASC')
                .run();

        Assert.areEqual(accounts.get(0).Name, 'Account 2');
        Assert.areEqual(accounts.get(1).Name, 'Account 1');
        Assert.areEqual(accounts.get(2).Name, 'Account 3');
    }

    @IsTest
    static void multipleNullsOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', Phone = '110');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', Phone = '120');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', Phone = '130');
        Account acc4 = new Account(Name = 'Account 4', Rating = '1', Phone = null);
        Account acc5 = new Account(Name = 'Account 5', Rating = null, Phone = '110');
        Account acc6 = new Account(Name = 'Account 6', Rating = '9', Phone = null);

        insert new List<Account>{
                acc1, acc2, acc3, acc4, acc5, acc6
        };

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .orderBy('Rating', 'DESC', pp_Query.NULLS_LAST)
                .orderBy('Phone', 'ASC', pp_Query.NULLS_FIRST)
                .run();

        Assert.areEqual(accounts.get(0).Name, 'Account 6');
        Assert.areEqual(accounts.get(1).Name, 'Account 2');
        Assert.areEqual(accounts.get(2).Name, 'Account 4');
        Assert.areEqual(accounts.get(3).Name, 'Account 1');
        Assert.areEqual(accounts.get(4).Name, 'Account 3');
        Assert.areEqual(accounts.get(5).Name, 'Account 5');
    }

    @IsTest
    static void descendAndNullsFirstOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1');
        Account acc4 = new Account(Name = 'Account 4', Rating = null);

        insert new List<Account>{
                acc1, acc2, acc3, acc4
        };

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .orderBy('Rating')
                .descend()
                .orderNullsFirst()
                .run();

        /*
        Assert.areEqual(accounts.get(0).Name, 'Account 4');
        Assert.areEqual(accounts.get(1).Name, 'Account 2');
        Assert.areEqual(accounts.get(2).Name, 'Account 1');
        Assert.areEqual(accounts.get(3).Name, 'Account 3');
        */
    }

    @IsTest
    static void ascendAndNullsLastOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1');
        Account acc4 = new Account(Name = 'Account 4', Rating = null);

        insert new List<Account>{
                acc1, acc2, acc3, acc4
        };

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .orderBy('Rating')
                .ascend()
                .orderNullsLast()
                .run();

        /*
        Assert.areEqual(accounts.get(0).Name, 'Account 1');
        Assert.areEqual(accounts.get(1).Name, 'Account 3');
        Assert.areEqual(accounts.get(2).Name, 'Account 2');
        Assert.areEqual(accounts.get(3).Name, 'Account 4');
        */
    }

    @IsTest
    static void simpleSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addSubquery('Opportunities')
                .run();

        assertAccount(accounts.get(0));
        Assert.isNotNull(accounts.get(0).Opportunities.get(0).Id);

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addSubquery(pp_Query.subquery('Opportunities').selectAllFields())
                .run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
    }

    @IsTest
    static void conditionalSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addSubquery(
                        pp_Query.subquery('Opportunities')
                                .selectAllFields()
                                .addConditionEq('TotalOpportunityQuantity', 10)
                )
                .addSubquery(
                        pp_Query.subquery('Tasks')
                                .selectAllFields()
                                .addConditionEq('Subject', 'New Task')
                )
                .run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
        assertTask(accounts.get(0).Tasks.get(0));

    }

    @IsTest
    static void complexConditionalSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new pp_Query('Account')
                .selectAllFields()
                .addCondition(
                        pp_Query.doOr(
                                pp_Query.conditionIn('Name', new Set<String>{
                                        'ABC Ltd'
                                }),
                                pp_Query.conditionEq('Phone', 'N/A')
                        )
                )
                .addSubquery(
                        pp_Query.subquery('Opportunities')
                                .selectFields('Name, CloseDate, TotalOpportunityQuantity')
                                .addCondition(
                                        pp_Query.doOr(
                                                pp_Query.conditionIn('TotalOpportunityQuantity',
                                                        new Set<Integer>{
                                                                10
                                                        }),
                                                pp_Query.conditionEq('Name', 'N/A'),
                                                pp_Query.doAnd(
                                                        pp_Query.conditionEq('CloseDate', Date.today().addDays(1)),
                                                        pp_Query.conditionEq('Name', 'N/A'),
                                                        pp_Query.conditionEq('Name', 'N/A')
                                                ),
                                                pp_Query.doOr(
                                                        pp_Query.conditionEq('CloseDate', Date.today().addDays(1)),
                                                        pp_Query.conditionEq('Name', 'N/A'),
                                                        pp_Query.conditionEq('Name', 'N/A')
                                                )
                                        )
                                )
                )
                .run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));

    }

    @IsTest
    static void toQueryStringTest() {
        createData();

        String queryString = new pp_Query('Account')
                .selectAllFields()
                .addCondition(
                        pp_Query.doOr(
                                pp_Query.conditionIn('Name', new Set<String>{
                                        'ABC Ltd'
                                }),
                                pp_Query.conditionEq('Phone', 'N/A')
                        )
                )
                .addSubquery(
                        pp_Query.subquery('Opportunities')
                                .selectFields('Name, CloseDate, TotalOpportunityQuantity')
                                .addCondition(
                                        pp_Query.doOr(
                                                pp_Query.conditionIn('TotalOpportunityQuantity',
                                                        new Set<Integer>{
                                                                10
                                                        }),
                                                pp_Query.conditionEq('Name', 'N/A'),
                                                pp_Query.doAnd(
                                                        pp_Query.conditionEq('CloseDate', Date.today().addDays(1)),
                                                        pp_Query.conditionEq('Name', 'N/A'),
                                                        pp_Query.conditionEq('Name', 'N/A')
                                                ),
                                                pp_Query.doOr(
                                                        pp_Query.conditionEq('CloseDate', pp_Query.TODAY),
                                                        pp_Query.conditionEq('Name', 'N/A'),
                                                        pp_Query.conditionEq('Name', 'N/A')
                                                )
                                        )
                                )
                )
                .toQueryString();

        List<Account> accounts = Database.query(queryString);

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));

    }

    @IsTest
    static void conditionWithConstArgumentTest() {
        createData();

        Account account;
        Opportunity opp;

        account = (Account) new pp_Query('Account')
                .selectAllFields()
                .addConditionEq('AnnualRevenue', null)
                .fetch();

        assertAccount(account);

        account = (Account) new pp_Query('Account')
                .selectAllFields()
                .addConditionNotEq('Name', null)
                .fetch();

        assertAccount(account);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionEq('IsPrivate', false)
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionNotEq('IsPrivate', true)
                .fetch();

        assertOpportunity(opp);
    }

    @IsTest
    static void conditionFromStringTest() {
        createData();

        Account account;

        account = (Account) new pp_Query('Account')
                .selectAllFields()
                .addConditionString('AnnualRevenue = NULL')
                .fetch();
        assertAccount(account);

        account = (Account) new pp_Query('Account')
                .selectAllFields()
                .addConditionString('Sic = \'D001\'')
                .fetch();
        assertAccount(account);

        account = (Account) new pp_Query('Account')
                .selectAllFields()
                .addConditionString('(AnnualRevenue = NULL AND (Sic IN (\'D001\', \'(D002)\')))')
                .fetch();
        assertAccount(account);

        pp_Query.QueryConditionException thrownException;
        try {
            new pp_Query('Account')
                    .selectAllFields()
                    .addConditionString('= null) OR (Id !=null');
        } catch (pp_Query.QueryConditionException e) {
            thrownException = e;
        }
        Assert.isNotNull(thrownException);


        thrownException = null;
        try {
            new pp_Query('Account')
                    .selectAllFields()
                    .addConditionString('Id = \'asdf');
        } catch (pp_Query.QueryConditionException e) {
            thrownException = e;
        }
        Assert.isNotNull(thrownException);
    }

    @IsTest
    static void dateLiteralTest() {
        createData();

        Opportunity opp;

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionGe('CloseDate', pp_Query.TODAY)
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionGe('CloseDate', pp_Query.YESTERDAY)
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionEq('CloseDate', pp_Query.NEXT_N_DAYS(4))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionGe('CloseDate', pp_Query.LAST_N_DAYS(10))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionLe('CreatedDate', pp_Query.NEXT_N_WEEKS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionGe('CreatedDate', pp_Query.LAST_N_WEEKS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionLe('CreatedDate', pp_Query.NEXT_N_MONTHS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionGe('CreatedDate', pp_Query.LAST_N_MONTHS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionLe('CreatedDate', pp_Query.NEXT_N_QUARTERS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionGe('CreatedDate', pp_Query.LAST_N_QUARTERS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionLe('CreatedDate', pp_Query.NEXT_N_YEARS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionGe('CreatedDate', pp_Query.LAST_N_YEARS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionLe('CreatedDate', pp_Query.NEXT_N_FISCAL_QUARTERS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionGe('CreatedDate', pp_Query.LAST_N_FISCAL_QUARTERS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionLe('CreatedDate', pp_Query.NEXT_N_FISCAL_YEARS(2))
                .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new pp_Query('Opportunity')
                .selectAllFields()
                .addConditionGe('CreatedDate', pp_Query.LAST_N_FISCAL_YEARS(2))
                .fetch();

        assertOpportunity(opp);
    }

    @IsTest
    static void aggregateTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{
                acc1, acc2, acc3, acc4
        };

        AggregateResult result =
                new pp_Query('Account')
                        .count('Name')
                        .count('Name', 'countName')
                        .countDistinct('Rating')
                        .countDistinct('Rating', 'countRating')
                        .max('NumberOfEmployees')
                        .max('NumberOfEmployees', 'maxEmployee')
                        .min('NumberOfEmployees')
                        .min('NumberOfEmployees', 'minEmployee')
                        .avg('NumberOfEmployees')
                        .avg('NumberOfEmployees', 'avgEmployee')
                        .sum('NumberOfEmployees')
                        .sum('NumberOfEmployees', 'sumEmployee')
                        .aggregate()[0];

        Assert.areEqual(result.get('countName'), 4);
        Assert.areEqual(result.get('expr0'), 4);
        Assert.areEqual(result.get('countRating'), 2);
        Assert.areEqual(result.get('expr1'), 2);
        Assert.areEqual(result.get('maxEmployee'), 7);
        Assert.areEqual(result.get('expr2'), 7);
        Assert.areEqual(result.get('minEmployee'), 1);
        Assert.areEqual(result.get('expr3'), 1);
        Assert.areEqual(result.get('avgEmployee'), 4);
        Assert.areEqual(result.get('expr4'), 4);
        Assert.areEqual(result.get('sumEmployee'), 16);
        Assert.areEqual(result.get('expr5'), 16);
    }

    @IsTest
    static void toLabelTest() {
        Account acc = new Account(Name = 'New Account 1');

        insert acc;

        Opportunity opp = new Opportunity(
                AccountId = acc.Id,
                Name = 'New Opportunity',
                CloseDate = Date.today().addDays(3),
                TotalOpportunityQuantity = 10,
                StageName = 'New');
        insert opp;

        SObject opportunitiesOne = new pp_Query('Opportunity')
                .selectField('Id')
                .toLabel('StageName')
                .byId(opp.Id)
                .fetch();
        Assert.areEqual(opportunitiesOne.get('StageName'), 'New');

        SObject opportunitiesTwo = new pp_Query('Opportunity')
                .toLabel('StageName', 'myStageName')
                .byId(opp.Id)
                .fetch();
        Assert.areEqual(opportunitiesTwo.get('myStageName'), 'New');
    }

    @IsTest
    static void countQueryTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{
                acc1, acc2, acc3, acc4
        };

        Assert.areEqual(4, new pp_Query('Account').countQuery());
        Assert.areEqual(2, new pp_Query('Account').addConditionEq('Rating', '1').countQuery());
    }

    @IsTest
    static void groupByTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{
                acc1, acc2, acc3, acc4
        };

        List<AggregateResult> results = new pp_Query('Account')
                .selectField('Rating', 'rate')
                .count('Name', 'countName')
                .max('NumberOfEmployees', 'maxEmployee')
                .min('NumberOfEmployees', 'minEmployee')
                .avg('NumberOfEmployees', 'avgEmployee')
                .sum('NumberOfEmployees', 'sumEmployee')
                .groupBy('Rating')
                .aggregate();

        Map<String, AggregateResult> resultMap = new Map<String, AggregateResult>();

        for (AggregateResult result : results) {
            resultMap.put((String) result.get('rate'), result);
        }

        Assert.areEqual(resultMap.get('1').get('countName'), 2);
        Assert.areEqual(resultMap.get('1').get('maxEmployee'), 5);
        Assert.areEqual(resultMap.get('1').get('minEmployee'), 1);
        Assert.areEqual(resultMap.get('1').get('avgEmployee'), 3);
        Assert.areEqual(resultMap.get('1').get('sumEmployee'), 6);
        Assert.areEqual(resultMap.get('9').get('countName'), 1);
        Assert.areEqual(resultMap.get('9').get('maxEmployee'), 3);
        Assert.areEqual(resultMap.get('9').get('minEmployee'), 3);
        Assert.areEqual(resultMap.get('9').get('avgEmployee'), 3);
        Assert.areEqual(resultMap.get('9').get('sumEmployee'), 3);
    }

    @IsTest
    static void groupByWithHavingTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{
                acc1, acc2, acc3, acc4
        };

        List<AggregateResult> results =
                new pp_Query('Account')
                        .selectField('Rating')
                        .count('Name', 'countName')
                        .addConditionGe('NumberOfEmployees', 1)
                        .groupBy('Rating')
                        .addHaving(pp_Query.doAnd(
                                pp_Query.conditionGe('Count(Name)', 2),
                                pp_Query.conditionNotEq('Rating', null)
                        ))
                        .aggregate();

        Map<String, AggregateResult> resultMap = new Map<String, AggregateResult>();

        for (AggregateResult result : results) {
            resultMap.put((String) result.get('Rating'), result);
        }

        Assert.areEqual(resultMap.get('1').get('countName'), 2);
        Assert.areEqual(resultMap.get('9'), null);
    }

    @IsTest
    static void allRowsTest() {
        Account acc = new Account(Name = 'Account');
        insert acc;

        Task task1 = new Task(Subject = 'Task1', WhatId = acc.Id);
        Task task2 = new Task(Subject = 'Task2', WhatId = acc.Id);
        Task task3 = new Task(Subject = 'Task3', WhatId = acc.Id);
        insert new List<Task>{
                task1, task2, task3
        };

        List<Task> allTasks = new pp_Query('Task')
                .selectFields('Id')
                .allRows()
                .run();

        Assert.areEqual(3, allTasks.size());
    }

    @IsTest
    static void semiJoinTest() {
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Opportunity opp = new Opportunity(
                AccountId = acc.Id,
                Name = 'New Opportunity',
                CloseDate = Date.today().addDays(3),
                TotalOpportunityQuantity = 10,
                StageName = 'New',
                IsPrivate = false);
        insert opp;

        Account acc2 = (Account) new pp_Query('Account')
                .addConditionIn('Id', new pp_Query('Opportunity')
                        .selectField('AccountId')
                        .byId(opp.Id))
                .fetch();

        Assert.areEqual(acc.Id, acc2.Id);

        Account acc3 = (Account) new pp_Query('Account')
                .lookup('Id', new pp_Query('Opportunity')
                        .selectField('AccountId')
                        .addConditionEq('StageName', 'New')
                        .byId(opp.Id))
                .addConditionEq('Name', 'New Account')
                .fetch();

        Assert.areEqual(acc.Id, acc3.Id);

        Opportunity opp2 = (Opportunity) new pp_Query('Opportunity')
                .lookup('AccountId', new pp_Query('Account')
                        .selectField('Id')
                        .byId(acc.Id))
                .fetch();

        Assert.areEqual(opp.Id, opp2.Id);
    }

    @IsTest
    static void antiJoinTest() {
        Account acc1 = new Account(Name = 'New Account 1');
        insert acc1;
        Account acc2 = new Account(Name = 'New Account 2');
        insert acc2;

        Opportunity opp = new Opportunity(
                AccountId = acc1.Id,
                Name = 'New Opportunity',
                CloseDate = Date.today().addDays(3),
                TotalOpportunityQuantity = 10,
                StageName = 'New',
                IsPrivate = false);
        insert opp;

        Account acc3 = (Account) new pp_Query('Account')
                .addConditionNotIn('Id', new pp_Query('Opportunity')
                        .selectField('AccountId')
                        .byId(opp.Id))
                .fetch();

        Assert.areEqual(acc2.Id, acc3.Id);
    }
    @IsTest
    static void fieldSettingTest() {
        Account account = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        insert account;
        pp_Query.FieldSetting setting = new pp_Query.FieldSetting();
        setting.isAccessible = true;
        setting.isNameField = true;

        Account acc = (Account) new pp_Query('Account').selectAllFields(setting).byId(account.Id).fetch();
        Assert.areEqual(acc.Name, 'Account 1');

        pp_Query.FieldSetting settingOne = new pp_Query.FieldSetting();
        settingOne.isAccessible = true;
        setting.isCalculated = true;
        Account acc1 = (Account) new pp_Query('Account').selectAllFields(settingOne).byId(account.Id).fetch();
        Assert.areEqual(acc1.Rating, '1');
    }
    @IsTest
    static void debugTest() {
        Id id = '001O000000qkv3KIAQ';
        List<Id> idList = new List<Id>{
                id
        };
        Set<Id> idSet = new Set<Id>{
                id
        };
        List<String> stringList = new List<String>();
        Set<String> stringSet = new Set<String>();
        List<Decimal> decimalList = new List<Decimal>{
                1.234
        };
        Set<Decimal> decimalSet = new Set<Decimal>{
                1.234
        };
        List<Integer> integerList = new List<Integer>{
                1
        };
        Set<Integer> integerSet = new Set<Integer>{
                1
        };

        pp_Query query = new pp_Query('Account')
                .addConditionEq('RecordTypeId', id)
                .addConditionEq('OwnerId', id)
                .addConditionEq('CreatedBy', id)
                .addConditionEq('LastModifiedBy', id)
                .addConditionEq('Owner', id)
                .addConditionEq('RecordTypeId', idList)
                .addConditionEq('OwnerId', idList)
                .addConditionEq('CreatedBy', idList)
                .addConditionEq('RecordTypeId', idSet)
                .addConditionEq('OwnerId', idSet)
                .addConditionEq('CreatedBy', idSet)
                .addConditionIn('LastModifiedBy', stringList)
                .addConditionIn('Owner', stringList)
                .addConditionIn('LastModifiedBy', stringSet)
                .addConditionIn('Owner', stringSet)
                .addConditionIn('AnnualRevenue', decimalList)
                .addConditionIn('AnnualRevenue', decimalSet)
                .addConditionIn('NumberOfEmployees', integerList)
                .addConditionIn('NumberOfEmployees', integerSet)
                .addConditionEq('NumberOfEmployees', 1)
                .debug();

        Assert.isNotNull(query);
    }

    static void createData() {
        Account acc = new Account();
        acc.Name = 'ABC Ltd';
        acc.Phone = '+61 410 000 000';
        acc.Sic = 'D001';
        acc.NumberOfEmployees = 10;
        acc.Website = 'https://www.samplewebsite.com';
        acc.Fax = '+61 2 0000 0000';
        acc.Site = 'Sydney';

        insert acc;

        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'New Opportunity';
        opp.CloseDate = Date.today().addDays(3);
        opp.TotalOpportunityQuantity = 10;
        opp.StageName = 'New';
        opp.IsPrivate = false;

        insert opp;

        Task task = new Task();
        task.WhatId = acc.Id;
        task.Subject = 'New Task';

        insert task;

    }

    static void assertAccount(Account acc) {
        Assert.areEqual(acc.Name, 'ABC Ltd');
        Assert.areEqual(acc.Phone, '+61 410 000 000');
        Assert.areEqual(acc.Sic, 'D001');
        Assert.areEqual(acc.NumberOfEmployees, 10);
        Assert.areEqual(acc.Website, 'https://www.samplewebsite.com');
        Assert.areEqual(acc.Fax, '+61 2 0000 0000');
        Assert.areEqual(acc.Site, 'Sydney');
    }

    static void assertOpportunity(Opportunity opp) {
        Assert.areEqual(opp.Name, 'New Opportunity');
        Assert.areEqual(opp.CloseDate, Date.today().addDays(3));
        Assert.areEqual(opp.TotalOpportunityQuantity, 10);
    }

    static void assertTask(Task task) {
        Assert.areEqual(task.Subject, 'New Task');
    }

}