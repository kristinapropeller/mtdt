/**
 * Created on 10.04.23.
 */

({
    addTransaction: function(component) {
        var newTransaction = {
            sobjectType: "Transaction__c",
            Date__c: new Date().toISOString(),
            CurrencyIsoCode: '',
            Income_Category__c: '',
            Outcome_Category__c: '',
            Income: 0.00,
            Outcome: 0.00
        };
        var transactions = component.get("v.transactions");
        transactions.push(newTransaction);
        component.set("v.transactions", transactions);
    },

    getOptions: function (component, type) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "objectName": "Transaction__c",
            "fieldName": type === 'Income' ? "Income_Category__c" : type === "Outcome" ? "Outcome_Category__c" : "CurrencyIsoCode"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                var fieldMap = [];
                fieldMap.push({label: 'None', value: ''});
                if(type === 'Currency') {
                    for(var key in options) {
                        fieldMap.push({label: key, value: key});
                    }
                    component.set("v.currencyOptions", fieldMap);
                } else {
                    for (var key in options) {
                        fieldMap.push({label: options[key], value: key});
                    }
                    component.set(type === 'Income' ? "v.incomeCategoryOptions" : "v.outcomeCategoryOptions", fieldMap);
                }
            }
        });
        $A.enqueueAction(action);
    },

    createTransactions: function (component, event, helper) {
        component.utils.callApexPromise(component.get("c.createTransactions"), {
            'transactions' : component.get("v.transactions")
        }).then($A.getCallback(function (response) {
            var params = {
                title : "Success",
                message: "Transactions were created",
                duration: "3000",
                type: "success"
            };
            component.utils.showToast(params);
            var utilityBar = component.find("utilitybar");
            utilityBar.minimizeUtility();
            component.set("v.transactions", []);
            helper.addTransaction(component);
        })).catch($A.getCallback(function (error) {
            component.utils.showError(component, error);
        })).finally(function () {
            component.utils.hideSpinner(component);
        });
    }
});