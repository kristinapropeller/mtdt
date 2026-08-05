/**
 * Created on 21/02/2023.
 */

public with sharing class InvoiceTrigger extends pp_Trap.TriggerHandler {

    public override void setUpBeforeUpdate(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('before update'))
                .filter(pp_Trap.F.changed.apply('Total__c'))
                .subscribe(new UpdateTotalInWordsFunc());
    }
    public override void setUpAfterInsert(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('after insert'))
                .tap(bulkObj.data('invoiceDataMap', pp_R.toMap.apply(new Map<String, Map<String, Object>>())))
                .filter((pp_Func)pp_R.allPass.run(
                        pp_R.propSatisfies.apply('Payee_Bank_Account__c', pp_R.isNotNull),
                        pp_R.propSatisfies.apply('Actual_Income__c', pp_R.isNotNull)
                ))
                .subscribe(bulkObj.provide('invoiceDataMap', new CollectIncomesFunc()), null, bulkObj.provide('invoiceDataMap', new ActualizeTransactionsFunc()));

        bulkObj.newStream
                .tap(pp_R.debug.apply('after insert'))
                .tap(bulkObj.data('invoiceIdSet', pp_R.toIdSet.apply(new Set<Id>())))
                .subscribe(bulkObj.provide('invoiceIdSet', new PopulateInvoiceIdSetFunc()), null, bulkObj.provide('invoiceIdSet', new AssignTimeCardsToInvoiceFunc()));
    }
    public override void setUpAfterUpdate(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('after update'))
                .tap(bulkObj.data('invoiceDataMap', pp_R.toMap.apply(new Map<String, Map<String, Object>>())))
                .filter((pp_Func)pp_R.allPass.run(
                        pp_R.propSatisfies.apply('Payee_Bank_Account__c', pp_R.isNotNull),
                        pp_R.propSatisfies.apply('Actual_Income__c', pp_R.isNotNull),
                        pp_R.anyPass.run(
                                pp_Trap.F.changed.apply('Payee_Bank_Account__c'),
                                pp_Trap.F.changed.apply('Actual_Income__c')
                        )
                ))
                .subscribe(bulkObj.provide('invoiceDataMap', new CollectIncomesFunc()), null, bulkObj.provide('invoiceDataMap', new ActualizeTransactionsFunc()));
    }
    public override void setUpAfterDelete(pp_Trap.BulkObject bulkObj) {
        bulkObj.oldStream
                .tap(pp_R.debug.apply('after delete'))
                .tap(bulkObj.data('invoiceDataMap', pp_R.toMap.apply(new Map<String, Map<String, Object>>())))
                .filter((pp_Func)pp_R.allPass.run(
                        pp_R.propSatisfies.apply('Payee_Bank_Account__c', pp_R.isNotNull),
                        pp_R.propSatisfies.apply('Actual_Income__c', pp_R.isNotNull)
                ))
                .subscribe(bulkObj.provide('invoiceDataMap', new CollectIncomesFunc()), null, bulkObj.provide('invoiceDataMap', new ActualizeTransactionsFunc()));
    }

    class PopulateInvoiceIdSetFunc extends  pp_Func {
        public PopulateInvoiceIdSetFunc() {
            super(2);
        }
        public override Object exec(Object arg1, Object arg2) {
            Set<Id> invoiceIdSet = (Set<Id>)arg1;
            SObject inv = pp_R.of(arg2).toSObject();
            invoiceIdSet.add(inv.Id);
            return invoiceIdSet;
        }
    }

    class AssignTimeCardsToInvoiceFunc extends pp_Func {
        public AssignTimeCardsToInvoiceFunc() {
            super(1);
        }
        public override Object exec(Object arg) {
            Set<Id> invoiceIdSet = (Set<Id>)arg;
            InvoiceService.linkTimeCardsToInvoiceLineItems(invoiceIdSet);
            return null;
        }
    }

    class UpdateTotalInWordsFunc extends pp_Func {
        public UpdateTotalInWordsFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Invoice__c inv = (Invoice__c)arg;
            inv.Total_In_Words__c = InvoiceService.convertAmountToWords(inv.Total__c, 'EN') + ' ' + inv.CurrencyIsoCode;
            if (inv.Payee_Country_Code__c == 'PL') inv.Total_In_Words__c += '\n' + InvoiceService.convertAmountToWords(inv.Total__c, 'PL') + ' ' + inv.CurrencyIsoCode;
            return inv;
        }
    }


    class CollectIncomesFunc extends pp_Func {
        public CollectIncomesFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Map<String, Map<String, Object>> invoiceDataMap = (Map<String, Map<String, Object>>)arg1;
            Boolean isDelete = (Boolean)pp_Trap.F.isAfterDelete.run();
            SObject inv = isDelete ? null : pp_R.of(arg2).toSObject();
            SObject oldInv = isDelete ? pp_R.of(arg2).toSObject() : (SObject)pp_Trap.F.getOld.run(inv);
            invoiceDataMap.put(inv != null ? inv.Id : oldInv.Id, inv == null && oldInv != null ? null : (Map<String, Object>)new pp_Mapper()
                    .mapField('person', 'Billed_To__c')
                    .mapField('bankAccount', 'Payee_Bank_Account__c')
                    .mapField('income', 'Actual_Income__c')
                    .mapField('currency', 'CurrencyIsoCode')
                    .mapField('name', 'Name', pp_R.append.apply(' ('))
                    .mapField('number', 'Invoice_Number__c', pp_R.append.apply('): '))
                    .mapField('account', 'Account_Name__c', pp_R.append.apply(', '))
                    .mapField('date', 'Working_Period_End__c')
                    .toMap()
                    .run(inv != null ? inv : oldInv));
            return invoiceDataMap;
        }
    }

    class ActualizeTransactionsFunc extends pp_Func {
        public ActualizeTransactionsFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Map<String, Object>> invoiceDataMap = (Map<String, Map<String, Object>>)arg;
            Map<String, SObject> existedTransaction = pp_R.of(new pp_Query('Transaction__c')
                            .selectFields(new Set<String>{'Id', 'Invoice__c'})
                            .addConditionIn('Invoice__c', invoiceDataMap.keySet())
                            .run())
                    .indexBy(pp_R.prop.apply('Invoice__c'))
                    .toSObjectMap();
            List<pp_MObject> txToUpsert = new List<pp_MObject>();
            List<SObject> txToDelete = new List<SObject>();
            for (String invId : invoiceDataMap.keySet()) {
                if (invoiceDataMap.get(invId) == null && existedTransaction.containsKey(invId)) {
                    txToDelete.add(existedTransaction.get(invId));
                } else if (invoiceDataMap.get(invId) != null) {
                    pp_MObject mo = pp_MObject.create(new Transaction__c(Invoice__c = invId));
                    mo.put('Income__c', invoiceDataMap.get(invId).get('income'));
                    mo.put('CurrencyIsoCode', invoiceDataMap.get(invId).get('currency'));
                    mo.put('Income_Bank_Account__c', invoiceDataMap.get(invId).get('bankAccount'));
                    if (existedTransaction.containsKey(invId)) {
                        mo.put('Id', existedTransaction.get(invId).Id);
                    } else {
                        mo.put('Person__c', invoiceDataMap.get(invId).get('person'));
                        mo.put('Date__c', System.today());
                        mo.put('Income_Category__c', 'Invoice');
                        mo.put('Description__c', String.valueOf(invoiceDataMap.get(invId).get('name')) + String.valueOf(invoiceDataMap.get(invId).get('number'))
                                + String.valueOf(invoiceDataMap.get(invId).get('account')) + String.valueOf(invoiceDataMap.get(invId).get('date')).substring(0, 7));
                    }
                    txToUpsert.add(mo);
                }
            }
            if (!txToDelete.isEmpty()) delete txToDelete;
            if (!txToUpsert.isEmpty()) pp_MObject.persist(txToUpsert);

            return null;
        }
    }
}