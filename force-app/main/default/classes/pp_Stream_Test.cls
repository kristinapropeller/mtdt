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
private class pp_Stream_Test {
    static pp_Func assertContains = (pp_Func) pp_R.pipe.run(
            (pp_Func) pp_R.flip.run(pp_R.contains),
            pp_R.assert
    );

    class TraceFunc extends pp_Func {
        private pp_Func f;
        private Integer count = 0;

        public TraceFunc(pp_Func f) {
            super(-1);
            this.f = f;
        }

        public Integer getCount() {
            return this.count;
        }

        public override Object execN(List<Object> args) {
            this.count += 1;

            return f.runN(args);
        }
    }

    static TraceFunc trace(pp_Func f) {
        return new TraceFunc(f);
    }

    @IsTest
    static void valueSourceTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(1));

        pp_Stream.of(1)
                .subscribe(tf, pp_R.assert.apply(false), pp_R.assert.apply(true));

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void errorSourceTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply('error'));

        pp_Stream.throwError('error')
                .subscribe(pp_R.assert.apply(false), tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void emptySourceTest() {
        TraceFunc tf = trace(pp_R.assert.apply(false));

        pp_Stream.empty()
                .subscribe(tf, pp_R.assert.apply(false), pp_R.assert.apply(true));

        Assert.areEqual(0, tf.getCount());
    }

    @IsTest
    static void neverSourceTest() {
        TraceFunc tf = trace(pp_R.assert.apply(false));

        pp_Stream.never()
                .subscribe(pp_R.assert.apply(false), pp_R.assert.apply(false), tf);

        Assert.areEqual(0, tf.getCount());
    }

    @IsTest
    static void fromDataSourceTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(1));

        pp_Stream.fromData(new List<Object>{
                1
        })
                .subscribe(tf, pp_R.assert.apply(false));

        Assert.areEqual(1, tf.getCount());

        pp_Stream.fromData(new Set<String>{
                'a'
        })
                .subscribe(pp_R.assertAreEqual.apply('a'), pp_R.assert.apply(false));

        pp_Stream.fromData(new Map<String, Object>{
                'key' => 'value'
        })
                .subscribe(pp_R.assertAreEqual.apply(new pp_R.Pair('key', 'value')), pp_R.assert.apply(false));
    }

    @IsTest
    static void rangeSourceTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(1));

        pp_Stream.range(1, 1)
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void withSourceTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                1, 2, 3
        }));

        pp_Stream.with(1, 2, 3)
                .subscribe(tf);

        Assert.areEqual(3, tf.getCount());
    }

    @IsTest
    static void generateSourceTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                1, 2, 3
        }));

        pp_Stream.generate(1, pp_R.lt.apply(pp_R.placeholder, 4), pp_R.inc)
                .subscribe(tf);

        Assert.areEqual(3, tf.getCount());
    }

    @IsTest
    static void concatSourceTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                1, 2, 3, 4, 5, 6
        }));

        pp_Stream.concat(pp_Stream.with(1, 2, 3), pp_Stream.with(4, 5, 6))
                .subscribe(tf);

        Assert.areEqual(6, tf.getCount());
    }

    @IsTest
    static void mapTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                2, 3, 4
        }));

        pp_Stream.with(1, 2, 3)
                .mapBy(pp_R.inc)
                .subscribe(tf);

        Assert.areEqual(3, tf.getCount());
    }

    @IsTest
    static void filterTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(2));

        pp_Stream.with(1, 2, 3)
                .filter(pp_R.equals.apply(2))
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void scanTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                1, 3, 6
        }));

        pp_Stream.with(1, 2, 3)
                .scan(pp_R.add, 0)
                .subscribe(tf);

        Assert.areEqual(3, tf.getCount());
    }

    @IsTest
    static void reduceTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                6
        }));

        pp_Stream.with(1, 2, 3)
                .reduce(pp_R.add, 0)
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void catchErrorTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply('success'));

        pp_Stream.throwError('error')
                .catchError(pp_R.constant.apply('success'))
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void countTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(1));

        pp_Stream.with(1, 2, 3)
                .count(pp_R.equals.apply(2))
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void defaultIfEmptyTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply('a'));

        pp_Stream.empty()
                .defaultIfEmpty('a')
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void distinctTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                1, 2
        }));

        pp_Stream.with(1, 2, 2)
                .distinct()
                .subscribe(tf);

        Assert.areEqual(2, tf.getCount());
    }

    @IsTest
    static void distinctUntilKeyChangedTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(new Map<String, Object>{
                'name' => 'a'
        }));

        pp_Stream.with(new Map<String, Object>{
                'name' => 'a'
        }, new Map<String, Object>{
                'name' => 'a'
        })
                .distinctUntilKeyChanged('name')
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void elementAtTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(2));

        pp_Stream.with(1, 2, 3)
                .elementAt(1)
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void everyTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(true));

        pp_Stream.with(1, 2, 3)
                .every(pp_R.gt.apply(pp_R.placeholder, 0))
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void joinTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                1, 2, 3
        }));

        pp_Stream.with(1, pp_Stream.with(2), 3)
                .join()
                .subscribe(tf);

        Assert.areEqual(3, tf.getCount());
    }

    @IsTest
    static void finalizeTest() {
        TraceFunc tf = trace(pp_R.debug.apply('finalize'));

        pp_Stream.with(1, 2, 3)
                .finalize(tf)
                .subscribe(pp_R.debug);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void findTest() {
        TraceFunc tf = trace(pp_R.equals.apply(2));

        pp_Stream.with(1, 2, 3)
                .find(pp_R.equals.apply(2))
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void findIndexTest() {
        TraceFunc tf = trace(pp_R.equals.apply(1));

        pp_Stream.with(1, 2, 3)
                .findIndex(pp_R.equals.apply(2))
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void firstTest() {
        TraceFunc tf = trace(pp_R.equals.apply(4));

        pp_Stream.with(1, 2, 3)
                .first(pp_R.equals.apply(4), 4)
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void lastTest() {
        TraceFunc tf = trace(pp_R.equals.apply(4));

        pp_Stream.with(1, 2, 3)
                .last(pp_R.equals.apply(4), 4)
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void subjectTest() {
        TraceFunc tf = trace(pp_R.equals.apply(1));

        pp_Stream.Subject s = new pp_Stream.Subject();
        s.subscribe(tf);

        s.next(1);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void groupByTest() {
        TraceFunc tf = trace(pp_R.debug);

        pp_Stream.with(1, 2, 3)
                .groupBy(pp_R.identity)
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void ignoreElementsTest() {
        TraceFunc tf = trace(pp_R.debug);

        pp_Stream.with(1, 2, 3)
                .ignoreElements()
                .subscribe(tf);

        Assert.areEqual(0, tf.getCount());
    }

    @IsTest
    static void isEmptyTest() {
        TraceFunc tf = trace(pp_R.assert);

        pp_Stream.empty()
                .isEmpty()
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void maxTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(3));

        pp_Stream.with(1, 2, 3)
                .max()
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void minTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(1));

        pp_Stream.with(1, 2, 3)
                .min()
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void onErrorResumeNextTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply('success'));

        pp_Stream.throwError('error')
                .onErrorResumeNext(new List<pp_Stream>{
                        pp_Stream.of('success')
                })
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void pairwiseTest() {
        TraceFunc tf = trace(pp_R.debug);

        pp_Stream.with(1, 2, 3)
                .pairwise()
                .subscribe(tf);

        Assert.areEqual(2, tf.getCount());
    }

    @IsTest
    static void repeatTest() {
        TraceFunc tf = trace(pp_R.debug);

        pp_Stream.with(1, 2, 3)
                .repeat(2)
                .subscribe(tf);

        Assert.areEqual(6, tf.getCount());
    }

    @IsTest
    static void skipTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                2, 3
        }));

        pp_Stream.with(1, 2, 3)
                .skip(1)
                .subscribe(tf);

        Assert.areEqual(2, tf.getCount());
    }

    @IsTest
    static void skipLastTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                1, 2
        }));

        pp_Stream.with(1, 2, 3)
                .skipLast(1)
                .subscribe(tf);

        Assert.areEqual(2, tf.getCount());
    }

    @IsTest
    static void skipWhileTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                3
        }));

        pp_Stream.with(1, 2, 3)
                .skipWhile(pp_R.lt.apply(pp_R.placeholder, 3))
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void takeTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                1
        }));

        pp_Stream.with(1, 2, 3)
                .take(1)
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void takeLastTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                3
        }));

        pp_Stream.with(1, 2, 3)
                .takeLast(1)
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }

    @IsTest
    static void takeWhileTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                1, 2
        }));

        pp_Stream.with(1, 2, 3)
                .takeWhile(pp_R.lt.apply(pp_R.placeholder, 3))
                .subscribe(tf);

        Assert.areEqual(2, tf.getCount());
    }

    @IsTest
    static void startWithTest() {
        TraceFunc tf = trace(assertContains.apply(new List<Object>{
                0, 1, 2, 3
        }));

        pp_Stream.with(1, 2, 3)
                .startWith(pp_Stream.of(0))
                .subscribe(tf);

        Assert.areEqual(4, tf.getCount());
    }

    @IsTest
    static void tapTest() {
        TraceFunc tf = trace(pp_R.debug);

        pp_Stream.with(1, 2, 3)
                .tap(tf)
                .subscribe(tf);

        Assert.areEqual(6, tf.getCount());
    }

    @IsTest
    static void toArrayTest() {
        TraceFunc tf = trace(pp_R.assertAreEqual.apply(new List<Object>{
                1, 2, 3
        }));

        pp_Stream.with(1, 2, 3)
                .toArray()
                .subscribe(tf);

        Assert.areEqual(1, tf.getCount());
    }
}