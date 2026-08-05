/**
 * Created on 15/11/2023.
 */

@IsTest
public class pp_Trap_TestMock extends pp_Trap.TriggerHandler {
    public static pp_Func beforeInsertFunc;
    public static pp_Func beforeUpdateFunc;
    public static pp_Func beforeDeleteFunc;
    public static pp_Func afterInsertFunc;
    public static pp_Func afterUpdateFunc;
    public static pp_Func afterDeleteFunc;
    public static pp_Func afterUndeleteFunc;
    public static pp_Func allFunc;

    public static pp_Func dataFunc;
    public static pp_Func verifyFunc = pp_R.identity;

    public static Boolean isActive = true;

    public override void setUpBeforeInsert(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(bulkObj.data('data', dataFunc))
                .tap(verifyFunc.apply(bulkObj))
                .tap(pp_R.debug.apply('before insert'))
                .subscribe(pp_Trap_TestMock.beforeInsertFunc);
    }

    public override void setUpBeforeUpdate(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('before update'))
                .subscribe(pp_Trap_TestMock.beforeUpdateFunc);
    }

    public override void setUpBeforeDelete(pp_Trap.BulkObject bulkObj) {
        bulkObj.oldStream
                .tap(pp_R.debug.apply('before delete'))
                .subscribe(pp_Trap_TestMock.beforeDeleteFunc);
    }

    public override void setUpAfterInsert(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('after insert'))
                .subscribe(pp_Trap_TestMock.afterInsertFunc);
    }

    public override void setUpAfterUpdate(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('after update'))
                .subscribe(pp_Trap_TestMock.afterUpdateFunc);
    }

    public override void setUpAfterDelete(pp_Trap.BulkObject bulkObj) {
        bulkObj.oldStream
                .tap(pp_R.debug.apply('after delete'))
                .subscribe(pp_Trap_TestMock.afterDeleteFunc);
    }

    public override void setUpAfterUndelete(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .tap(pp_R.debug.apply('after undelete'))
                .subscribe(pp_Trap_TestMock.afterUndeleteFunc);
    }

    public override void setUp(pp_Trap.BulkObject bulkObj) {
        bulkObj.newStream
                .filter(pp_Trap.F.isBeforeInsert)
                .tap(pp_R.debug.apply('all filtered by before insert'))
                .subscribe(pp_Trap_TestMock.allFunc);
    }

    public override Boolean isActive() {
        return pp_Trap_TestMock.isActive;
    }
}