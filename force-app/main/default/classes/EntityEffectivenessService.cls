/**
 * Created by kirillreutski on 27.03.24.
 */

public without sharing class EntityEffectivenessService implements Schedulable {
    public void execute(SchedulableContext param1) {
        TaxesService.populateTaxData(System.today().year());
    }

    public static void schedule() {
        //0 0 1 1/1 * ? *
        System.schedule('Entity Effectiveness Service Daily', '0 0 1 1/1 * ? *', new EntityEffectivenessService());
    }
}