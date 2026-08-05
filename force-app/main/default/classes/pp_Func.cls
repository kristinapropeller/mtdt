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
/**
 * Base class for pp_Func Object
 *
 * A pp_Func object represents a function, namely a block of business logic
 * Users can create new functions by composing smaller functions, or extend from this
 * class to create any custom functions
 *
 * Here is a sample custom function:
 *
 * ```
 * class CustomFunc extends pp_Func {
 *     public CustomFunc() {
 *         super(2);
 *     }
 *
 *     public override Object exec(Object arg1, Object arg2) {
 *         ...
 *         return null;
 *     }
 * }
 * ```
 *
 * In the constructor, we may specify the length of the pp_Func by calling 'super(2)',
 * or we can skip this to allow a variadic argument function
 *
 * There are a few 'exec' methods from pp_Func that we can override to provide our own
 * implementations
 *
 * Extend 'exec()' if our pp_Func does not accept any argument
 * Extend 'exec(Object)' if our pp_Func accepts one argument
 * Extend 'exec(Object, Object)' if our pp_Func accepts two arguments
 * Extend 'exec(Object, Object, Object)' if our pp_Func accepts three arguments
 * Extend 'execMore(List<Object>)' if our pp_Func accepts more than three arguments
 * Extend 'execN(List<Object>)' if our pp_Func accepts variadic arguments
 *
 * Here is the guide to help us decide which one is invoked
 *
 * If pp_Func length is not specified, the 'exec' method is invoked according to the
 * actual number of arguments
 *
 * If pp_Func length is 0, only the 'exec()' method is invoked
 *
 * If pp_Func length is 1, only the 'exec(Object)' method is invoked
 *
 * If pp_Func length is 2, only the 'exec(Object, Object)' method is invoked
 *
 * If pp_Func length is 3, only the 'exec(Object, Object, Object)' method is invoked
 *
 * If pp_Func length is more than 3, only the 'execMore(List<Object>)' method is invoked
 *
 * There are two stages when invoking a pp_Func:
 * a) Applying (optional)
 * Applying is the stage where the pp_Func receives some arguments and stores them for
 * invocation in the future
 *
 * Here is how we apply a pp_Func:
 *
 * ```
 * pp_Func f = R.equals.apply(1);
 * ```
 *
 * If we want to apply more than 3 arguments, we have to use:
 *
 * ```
 * pp_Func f = SomeFunc.applyN(a, b, c, d, ...);
 * ```
 *
 * Each applying will in fact create a new pp_Func, which means that the original pp_Func will
 * not get affected
 *
 * b) Running
 * Running is the stage where the pp_Func uses all the arguments it has collected and produces
 * the final result
 *
 * Here is how we run a pp_Func:
 *
 * ```
 * Object result = f.run(1);
 * ```
 *
 * If we want to run the func with more than 3 arguments, we have to use:
 *
 * ```
 * Object result = f.runN(a, b, c, d, ...);
 * ```
 *
 * Suppose pp_Func f takes three arguments, the following cases are equivalent:
 * ```
 * f.apply(a, b, c).run() ===
 * f.run(a, b, c) ===
 * f.apply(a).apply(b).apply(c).run() ===
 * f.apply(a).apply(b, c).run() ===
 * f.apply(a, b).apply(c)
 * ```
 */
public virtual class pp_Func {
    // The length of the function
    private Integer length = -1;

    // The applied arguments
    private List<Object> args;

    protected pp_Func() {
        this(-1, new List<Object>());
    }

    protected pp_Func(Integer length) {
        this(length, new List<Object>());
    }

    protected pp_Func(List<Object> args) {
        this(-1, args);
    }

    protected pp_Func(Integer length, List<Object> args) {
        this.length = length;
        this.args = args;
    }

    private Object getNthArg(List<Object> args, Integer index) {
        return index < args.size() && index >= 0 ? args.get(index) : null;
    }

    private void setAppliedArguments(List<Object> args) {
        this.args = args;
    }

    public List<Object> getAppliedArguments() {
        return this.args;
    }

    /**
     *  Apply one argument
     */
    public pp_Func apply(Object arg1) {
        return this.applyN(new List<Object>{
                arg1
        });
    }

    /**
     * Apply two arguments
     */
    public pp_Func apply(Object arg1, Object arg2) {
        return this.applyN(new List<Object>{
                arg1, arg2
        });
    }

    /**
     * Apply three arguments
     */
    public pp_Func apply(Object arg1, Object arg2, Object arg3) {
        return this.applyN(new List<Object>{
                arg1, arg2, arg3
        });
    }

    private List<Object> concatArgs(List<Object> oldArgs, List<Object> newArgs) {
        List<Object> newList = new List<Object>();
        List<Object> newArgsCopy = new List<Object>(newArgs);

        for (Object oldArg : oldArgs) {
            if (oldArg == pp_R.placeholder && !newArgsCopy.isEmpty()) {
                newList.add(newArgsCopy.remove(0));
            } else {
                newList.add(oldArg);
            }
        }

        if (!newArgsCopy.isEmpty()) {
            newList.addAll(newArgsCopy);
        }

        return newList;
    }

    /**
     * Apply N arguments
     */
    public pp_Func applyN(List<Object> args) {
        List<Object> newList = this.concatArgs(this.args, args);

        pp_Func newFunc = this.clone();
        newFunc.setAppliedArguments(newList);
        return newFunc;
    }

    /**
     * Execute with no argument
     */
    protected virtual Object exec() {
        throw new pp_Func.FuncException('Function with no argument is not implemented');
    }

    /**
     * Execute with one argument
     */
    protected virtual Object exec(Object arg1) {
        throw new pp_Func.FuncException('Function with one argument is not implemented');
    }

    /**
     * Execute with two arguments
     */
    protected virtual Object exec(Object arg1, Object arg2) {
        throw new pp_Func.FuncException('Function with two arguments is not implemented');
    }

    /**
     * Execute with three arguments
     */
    protected virtual Object exec(Object arg1, Object arg2, Object arg3) {
        throw new pp_Func.FuncException('Function with three arguments is not implemented');
    }

    /**
     * Execute with more than three arguments
     */
    protected virtual Object execMore(List<Object> args) {
        throw new pp_Func.FuncException('Function with more than three arguments is not implemented');
    }

    /**
     * Execute with various arguments
     */
    protected virtual Object execN(List<Object> args) {
        if (args.size() == 0) {
            return this.exec();
        } else if (args.size() == 1) {
            return this.exec(args.get(0));
        } else if (args.size() == 2) {
            return this.exec(args.get(0), args.get(1));
        } else if (args.size() == 3) {
            return this.exec(args.get(0), args.get(1), args.get(2));
        } else {
            return this.execMore(args);
        }
    }

    public Object run(Object arg1) {
        return this.runN(new List<Object>{
                arg1
        });
    }

    public Object run(Object arg1, Object arg2) {
        return this.runN(new List<Object>{
                arg1, arg2
        });
    }

    public Object run(Object arg1, Object arg2, Object arg3) {
        return this.runN(new List<Object>{
                arg1, arg2, arg3
        });
    }

    public Object runN(List<Object> args) {
        List<Object> allArgs = this.concatArgs(this.args, args);
        if (this.length < 0) {
            return this.execN(allArgs);
        } else if (this.length == 0) {
            return this.exec();
        } else if (this.length == 1) {
            return this.exec(getNthArg(allArgs, 0));
        } else if (this.length == 2) {
            return this.exec(getNthArg(allArgs, 0), getNthArg(allArgs, 1));
        } else if (this.length == 3) {
            return this.exec(getNthArg(allArgs, 0), getNthArg(allArgs, 1), getNthArg(allArgs, 2));
        } else {
            return this.execMore(allArgs);
        }
    }

    public Object run() {
        return this.runN(new List<Object>());
    }

    public virtual override String toString() {
        String className = 'pp_Func';
        List<String> params = new List<String>();
        if (this.length < 0) {
            params.add('Object...');
        } else {
            for (Integer i = 0; i < this.length; i++) {
                params.add('Object');
            }
        }

        return className + ':: (' + String.join(params, ', ') + ') => Object';
    }

    public class FuncException extends Exception {
    }
}