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
private class pp_Atom_Test {
    @IsTest
    static void simpleStepTest() {
        Map<String, Object> data = new Map<String, Object>();
        pp_Atom a = new pp_Atom(data)
                .then(pp_Atom.F.compute.apply('val', pp_R.constant.apply('test')))
                .fork();

        Assert.areEqual('test', data.get('val'));
    }

    @IsTest
    static void interruptTest() {
        Map<String, Object> data = new Map<String, Object>();
        pp_Atom a = new pp_Atom(data)
                .then(pp_Atom.F.compute.apply(pp_R.T))
                .fork();

        Assert.areEqual(1, a.getState().getInterruptedTimes());
    }

    @IsTest
    static void nestedStepTest() {
        Map<String, Object> data = new Map<String, Object>{
                'count' => 0
        };
        pp_Atom a = new pp_Atom(data)
                .then(pp_Atom.F.compute.apply('count', pp_R.inc, 'count'))
                .then(new pp_Atom.CompositeStep()
                        .then(pp_Atom.F.compute.apply('count', pp_R.inc, 'count'))
                        .then(pp_Atom.F.compute.apply('count', pp_R.inc, 'count'))
                )
                .fork();

        Assert.areEqual(3, data.get('count'));
    }

    @IsTest
    static void forEachTest() {
        Map<String, Object> data = new Map<String, Object>{
                'count' => 0
        };
        pp_Atom a = new pp_Atom(data)
                .then(new pp_Atom.ForEachStep('n', new List<Integer>{
                        1, 2, 3
                }, pp_Atom.F.compute.applyN(new List<Object>{
                        'count', pp_R.add, 'count', 'n'
                })))
                .fork();

        Assert.areEqual(6, data.get('count'));
    }

    @IsTest
    static void rangeTest() {
        Map<String, Object> data = new Map<String, Object>{
                'count' => 0
        };
        pp_Atom a = new pp_Atom(data)
                .then(new pp_Atom.RangeStep('n', 1, 3, pp_Atom.F.compute.applyN(new List<Object>{
                        'count', pp_R.add, 'count', 'n'
                })))
                .fork();

        Assert.areEqual(6, data.get('count'));
    }

    @IsTest
    static void repeatTest() {
        Map<String, Object> data = new Map<String, Object>{
                'count' => 0
        };
        pp_Atom a = new pp_Atom(data)
                .then(new pp_Atom.RepeatStep(3, pp_Atom.F.compute.apply('count', pp_R.inc, 'count')))
                .fork();

        Assert.areEqual(3, data.get('count'));
    }

    @IsTest
    static void monitorTest() {
        pp_Atom.registerMonitor(new TestMonitor());

        pp_Atom a = new pp_Atom()
                .then(pp_Atom.F.compute.apply(pp_R.debug.apply('running')))
                .then(pp_Atom.F.compute.apply(pp_R.debug.apply('running')))
                .fork();

        Assert.areEqual(2, a.getState().getInterruptedTimes());
    }

    class TestMonitor implements pp_Atom.Monitor {

        public String getMessage() {
            return 'test monitor';
        }

        public Boolean isSafe(pp_Atom.State s) {
            return false;
        }
    }
}