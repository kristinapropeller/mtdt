/**
 * MIT License
 *
 * Copyright (c) 2018 Click to Cloud Pty Ltd
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
 **/
@IsTest
private class pp_Trap_Test {
    @IsTest
    static void findTest() {
        pp_Trap.setMockHandler();
        pp_Trap.TriggerHandler handler = pp_Trap.getInstance().find('Case');
        Assert.isNotNull(handler);
    }

    @IsTest
    static void beforeInsertTest() {
        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.beforeInsertFunc = tf;
        pp_Trap.setMockHandler();

        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
                new Case()
        });

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void beforeUpdateTest() {
        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.beforeUpdateFunc = tf;
        pp_Trap.setMockHandler();

        Case c = new Case();
        insert c;

        c.Subject = 'test';
        pp_Trap.getInstance().start(pp_Trap.Event.BeforeUpdate, null, new List<SObject>{
                c
        });

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void beforeDeleteTest() {
        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.beforeDeleteFunc = tf;
        pp_Trap.setMockHandler();

        Case c = new Case();
        insert c;

        pp_Trap.getInstance().start(pp_Trap.Event.BeforeDelete, new List<SObject>{
                c
        }, null);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void afterInsertTest() {
        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.afterInsertFunc = tf;
        pp_Trap.setMockHandler();

        pp_Trap.getInstance().start(pp_Trap.Event.AfterInsert, null, new List<SObject>{
                new Case()
        });

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void afterUpdateTest() {
        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.afterUpdateFunc = tf;
        pp_Trap.setMockHandler();

        Case c = new Case();
        insert c;

        c.Subject = 'test';
        pp_Trap.getInstance().start(pp_Trap.Event.AfterUpdate, null, new List<SObject>{
                c
        });

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void afterDeleteTest() {
        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.afterDeleteFunc = tf;
        pp_Trap.setMockHandler();

        Case c = new Case();
        insert c;

        pp_Trap.getInstance().start(pp_Trap.Event.AfterDelete, new List<SObject>{
                c
        }, null);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void afterUndeleteTest() {
        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.afterUndeleteFunc = tf;
        pp_Trap.setMockHandler();

        Case c = new Case();
        insert c;
        delete c;

        pp_Trap.getInstance().start(pp_Trap.Event.AfterUndelete, null, new List<SObject>{
                c
        });

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void updateFieldTest() {
        pp_Trap_TestMock.beforeInsertFunc = pp_Trap.F.updateField.apply('Subject', 'test');
        pp_Trap.setMockHandler();

        Case c = new Case();
        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
                c
        });

        Assert.areEqual('test', c.Subject);
    }

    @IsTest
    static void addErrorTest() {
        pp_Trap_TestMock.beforeInsertFunc = pp_Trap.F.addError.apply('test error');
        pp_Trap.setMockHandler();

        Case c = new Case();
        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
               c
        });

        Assert.areEqual('test error', c.getErrors().get(0).getMessage());
    }

    @IsTest
    static void validateTest() {
        pp_Trap_TestMock.beforeInsertFunc = pp_Trap.F.validate.apply(pp_R.propSatisfies.apply('Subject', pp_R.isNotNull), 'validation failed');
        pp_Trap.setMockHandler();

        Case c = new Case();
        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
                c
        });

        Assert.areEqual('validation failed', c.getErrors().get(0).getMessage());
    }

    @IsTest
    static void getNewTest() {
        pp_Trap_TestMock.beforeUpdateFunc = (pp_Func) pp_R.pipe.run(
                pp_Trap.F.getNew,
                pp_R.isNotNull,
                pp_R.assert
        );
        pp_Trap.setMockHandler();

        Case c1 = new Case();
        insert c1;

        Case c2 = new Case(
                Id = c1.Id,
                Subject = 'new subject'
        );
        pp_Trap.getInstance().start(pp_Trap.Event.BeforeUpdate, new List<SObject>{
                c1
        }, new List<SObject>{
                c2
        });

        Assert.isTrue(true);
    }

    @IsTest
    static void getOldTest() {
        pp_Trap_TestMock.beforeUpdateFunc = (pp_Func) pp_R.pipe.run(
                pp_Trap.F.getOld,
                pp_R.isNotNull,
                pp_R.assert
        );
        pp_Trap.setMockHandler();

        Case c1 = new Case();
        insert c1;

        Case c2 = new Case(
                Id = c1.Id,
                Subject = 'new subject'
        );
        pp_Trap.getInstance().start(pp_Trap.Event.BeforeUpdate, new List<SObject>{
                c1
        }, new List<SObject>{
                c2
        });

        Assert.isTrue(true);
    }

    @IsTest
    static void changedTest() {
        pp_Trap_TestMock.beforeUpdateFunc = (pp_Func) pp_R.ifElse.run(
                pp_Trap.F.changed.apply('Subject'),
                pp_R.assert.apply(true),
                pp_R.assert.apply(false)
        );
        pp_Trap.setMockHandler();

        Case c1 = new Case();
        insert c1;

        Case c2 = new Case(
                Id = c1.Id,
                Subject = 'new subject'
        );
        pp_Trap.getInstance().start(pp_Trap.Event.BeforeUpdate, new List<SObject>{
                c1
        }, new List<SObject>{
                c2
        });

        Assert.isTrue(true);
    }

    @IsTest
    static void dataTest() {
        pp_Trap_TestMock.dataFunc = pp_R.constant.apply('test');
        pp_Trap_TestMock.verifyFunc = (pp_Func) pp_R.pipe.run(
                pp_Trap.F.data.apply(pp_R.placeholder, 'data'),
                pp_R.assertAreEqual.apply('test')
        );
        pp_Trap.setMockHandler();

        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
                new Case()
        });

        Assert.isTrue(true);
    }

    @IsTest
    static void enableTest() {
        pp_Trap.getInstance().disable('Case');

        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.beforeInsertFunc = tf;
        pp_Trap.setMockHandler();

        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
                new Case()
        });

        Assert.areEqual(0, tf.getCount());
    }

    @IsTest
    static void enableAllTest() {
        pp_Trap.getInstance().disableAll();

        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.beforeInsertFunc = tf;
        pp_Trap.setMockHandler();

        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
                new Case()
        });

        Assert.areEqual(0, tf.getCount());
    }

    @IsTest
    static void isActiveTest() {
        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.beforeInsertFunc = tf;
        pp_Trap_TestMock.isActive = false;
        pp_Trap.setMockHandler();

        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
                new Case()
        });

        Assert.areEqual(0, tf.getCount());
    }

    @IsTest
    static void setUpAllTest() {
        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.allFunc = tf;
        pp_Trap.setMockHandler();

        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
                new Case()
        });

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void recursionTest() {
        pp_Trap.getInstance().setMaxReEntry('Case', 3);
        pp_Trap_TestMock.afterInsertFunc = new InsertCaseFunc();
        pp_Trap.setMockHandler();

        try {
            pp_Trap.getInstance().start(pp_Trap.Event.AfterInsert, null, new List<SObject>{
                    new Case()
            });
            Assert.fail();
        } catch (pp_Trap.TrapException e) {
            Assert.isTrue(true);
        }
    }

    @IsTest
    static void newTransactionTest() {
        pp_Trap.getInstance().setUsingNewTransaction('Case', true);

        TraceFunc tf = new TraceFunc();
        pp_Trap_TestMock.beforeInsertFunc = tf;
        pp_Trap.setMockHandler();

        pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{
                new Case()
        });

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void provideTest() {
        pp_Trap.BulkObject bulkObj = new pp_Trap.BulkObject();
        bulkObj.newStream
                .tap(bulkObj.data('data', pp_R.constant.apply('test')))
                .subscribe(bulkObj.provide('data', pp_R.assertAreEqual.apply('test')));

        bulkObj.newStream.next(1);
    }

    class InsertCaseFunc extends pp_Func {
        public InsertCaseFunc() {
            super(0);
        }

        public override Object exec() {
            pp_Trap.getInstance().start(pp_Trap.Event.AfterInsert, null, new List<SObject>{
                    new Case()
            });

            return null;
        }
    }

    class TraceFunc extends pp_Func {
        private Integer count = 0;

        public Integer getCount() {
            return this.count;
        }

        public override Object execN(List<Object> args) {
            this.count += 1;

            return null;
        }
    }
}