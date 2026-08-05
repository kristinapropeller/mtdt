public with sharing class TransactionHandler {
    public static void updateBankAccount(List<Transaction__c> tList, Map<Id, Transaction__c> tOldMap, Boolean isDelete) {
        Map<Id, Decimal> balanceIncomeMap = new Map<Id, Decimal>();
        Map<Id, Decimal> balanceOutcomeMap = new Map<Id, Decimal>();
        tList = isDelete ? tOldMap.values() : tList;

        for (Transaction__c tr : tList) {
            if (tOldMap == null || isDelete) {
                Decimal income = isDelete ? (tr.Income__c != null ? -tr.Income__c : null) : tr.Income__c;
                Decimal outcome = isDelete ? tr.Outcome__c : (tr.Outcome__c != null ? -tr.Outcome__c : null);

                updateMap(balanceIncomeMap, tr.Income_Bank_Account__c, income);
                updateMap(balanceOutcomeMap, tr.Outcome_Bank_Account__c, outcome);
            } else {
                updateExistingMap(balanceIncomeMap, tr.Income_Bank_Account__c, tOldMap.get(tr.Id).Income_Bank_Account__c, tr.Income__c, tOldMap.get(tr.Id).Income__c);
                updateExistingMap(balanceOutcomeMap, tr.Outcome_Bank_Account__c, tOldMap.get(tr.Id).Outcome_Bank_Account__c, tr.Outcome__c != null ? -tr.Outcome__c : null, tOldMap.get(tr.Id).Outcome__c != null ? -tOldMap.get(tr.Id).Outcome__c : null);
            }
        }

        updateBankAccount(balanceIncomeMap, balanceOutcomeMap);
    }

    private static void updateExistingMap(Map<Id, Decimal> trMap, Id key, Id oldKey, Decimal value, Decimal oldValue) {
        if (value != null && key != null) {
            if (key != oldKey) {
                updateMap(trMap, key, value);
                if (oldKey != null) {
                    updateMap(trMap, oldKey, -value);
                }
            } else if (value != oldValue) {
                Decimal difference = oldValue != null ? value - oldValue : value;
                updateMap(trMap, key, difference);
            }
        } else if (key == null && oldKey != null) {
            updateMap(trMap, oldKey, -value);
        } else if (value == null && oldValue != null) {
            updateMap(trMap, key, -oldValue);
        }
    }

    private static void updateMap(Map<Id, Decimal> trMap, Id key, Decimal value) {
        if (key != null && value != null) {
            if (! trMap.containsKey(key)) {
                trMap.put(key, 0);
            }
            trMap.put(key, trMap.get(key) + value);
        }
    }

    public static void updateBankAccount(Map<Id, Decimal> balanceIncomeMap, Map<Id, Decimal> balanceOutcomeMap) {
        Map<Id, Bank_Account__c> bankAccountMap = new Map<Id, Bank_Account__c>([SELECT Id, Balance__c FROM Bank_Account__c WHERE Id IN: balanceIncomeMap.keySet() OR Id IN: balanceOutcomeMap.keySet()]);
        List<Bank_Account__c> updateBankAccountList = new List<Bank_Account__c>();

        for (Id bankAccountId : bankAccountMap.keySet()) {
            Bank_Account__c bankAccount = bankAccountMap.get(bankAccountId);
            bankAccount.Balance__c = bankAccount.Balance__c != null ? bankAccount.Balance__c : 0;
            if (balanceIncomeMap.containsKey(bankAccountId)) bankAccount.Balance__c = bankAccount.Balance__c + balanceIncomeMap.get(bankAccountId);
            if (balanceOutcomeMap.containsKey(bankAccountId)) bankAccount.Balance__c = bankAccount.Balance__c + balanceOutcomeMap.get(bankAccountId);
            updateBankAccountList.add(bankAccount);
        }
        update updateBankAccountList;
    }
}