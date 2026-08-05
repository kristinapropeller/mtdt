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
private class pp_Async_Test {
    static final pp_Func ASSERT_EQUALS_FUNC = new AssertEqualsFunc();
    static final pp_Func SUCCESS = ASSERT_EQUALS_FUNC.apply(true, true);
    static final pp_Func FAIL = ASSERT_EQUALS_FUNC.apply(true, false);

    @IsTest
    static void rejectTest() {
        Test.startTest();

        pp_Async.reject(1)
                .then(FAIL, SUCCESS)
                .fork();

        Test.stopTest();
    }

    @IsTest
    static void resolveTest() {
        Test.startTest();

        pp_Async.resolve(1).
                then(ASSERT_EQUALS_FUNC.apply(1)).
                fork();

        Test.stopTest();
    }

    @IsTest
    static void recoverTest() {
        Test.startTest();

        new pp_Async(pp_R.divide.apply(1, 0))
                .error((pp_Func) pp_R.always.run(new pp_Async(new TestAsyncExecutor('a'))))
                .then(ASSERT_EQUALS_FUNC.apply('a'))
                .fork();

        Test.stopTest();
    }

    @IsTest
    static void chainTest() {
        Test.startTest();

        new pp_Async(pp_R.add.apply(1, 1))
                .then(pp_R.add.apply(1))
                .then(pp_R.multiply.apply(2))
                .done(ASSERT_EQUALS_FUNC.apply(6))
                .fork();

        Test.stopTest();
    }

    @IsTest
    static void errorTest() {
        Test.startTest();

        new pp_Async(pp_R.divide.apply(1, 0))
                .then(FAIL, SUCCESS)
                .fork();

        Test.stopTest();
    }

    @IsTest
    static void funcInstanceTest() {
        Test.startTest();

        new pp_Async(pp_R.add.apply(1, 1))
                .then(ASSERT_EQUALS_FUNC.apply(2))
                .fork();

        Test.stopTest();
    }

    @IsTest
    static void executorInstanceTest() {
        Test.startTest();

        new pp_Async(new TestAsyncExecutor('test'))
                .then(ASSERT_EQUALS_FUNC.apply('test'))
                .fork();

        Test.stopTest();
    }


    class TestAsyncExecutor extends pp_Async.Executor {
        Object val;

        public TestAsyncExecutor(Object val) {
            this.val = val;
        }

        public override Object exec() {
            return this.val;
        }
    }

    class AssertEqualsFunc extends pp_Func {
        public AssertEqualsFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Assert.areEqual(a, b);

            return null;
        }
    }
}