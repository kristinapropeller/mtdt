/**
 * Created on 30.03.23.
 */

({
    doInit: function(component, event, helper) {
        helper.getOptions(component,'Currency');
        helper.getOptions(component,'Income');
        helper.getOptions(component,'Outcome');
        helper.addTransaction(component);
    },

    addTransaction: function(component, event, helper) {
        helper.addTransaction(component);
    },

    cloneTransaction: function(component, event, helper) {
        var index = event.getSource().get("v.value");
        var transactions = component.get("v.transactions");
        var cloneTransaction = Object.assign({}, transactions[index]);
        transactions.push(cloneTransaction);
        component.set("v.transactions", transactions);
    },

    deleteTransaction: function(component, event, helper) {
        var index = event.getSource().get("v.value");
        var transactions = component.get("v.transactions");
        transactions.splice(index, 1);
        component.set("v.transactions", transactions);
    },

    handleSave: function (component, event, helper){
        var isValid = true;
        var inputsDescription = component.find("inputDescription");
        if(!Array.isArray(inputsDescription)) inputsDescription = [inputsDescription];
        inputsDescription.forEach(function (input) {
            if(!input.reportValidity()) isValid = false;
        });
        var inputsDate = component.find("inputDate");
        if(!Array.isArray(inputsDate)) inputsDate = [inputsDate];
        inputsDate.forEach(function (input) {
            if(!input.reportValidity()) isValid = false;
        });
        var inputsLookup = component.find("inputLookup");
        if(!Array.isArray(inputsLookup)) inputsLookup = [inputsLookup];
        inputsLookup.forEach(function (input) {
            if(input.get("v.value") === undefined || input.get("v.value") === '') {
                input.showError("Complete this field.");
                isValid = false;
            } else {
                input.hideError();
            }
        });
        if(isValid) {
            helper.createTransactions(component, event, helper);
        }
    }
});