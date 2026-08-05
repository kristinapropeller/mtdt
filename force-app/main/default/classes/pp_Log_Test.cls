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
public class pp_Log_Test {
    static pp_Log.Context context;

    @IsTest
    static void jsonTest() {
        String jsonStr =
                '[                                                                     ' +
                        '    {                                                                 ' +
                        '        "patterns": [ "test" ],                                        ' +
                        '        "level": "DEBUG",                                             ' +
                        '        "appenders": [                                                ' +
                        '             {                                                        ' +
                        '                 "name": "pp_Log.DefaultAppender"                        ' +
                        '             }                                                        ' +
                        '        ]                                                             ' +
                        '    }                                                                 ' +
                        ']                                                                     ';

        pp_Log.configureFromJSON(jsonStr);

        Assert.isFalse(pp_Log.rules.isEmpty());
    }

    @IsTest
    static void levelTest() {
        pp_Log.configure(new List<pp_Log.Rule>{
                new pp_Log.Rule(
                        new List<String>{
                                '.*'
                        },
                        pp_Log.LevelType.TRACE,
                        new List<pp_Log.AppenderConfig>{
                                new pp_Log.AppenderConfig(
                                        'pp_Log_Test.TestAppender',
                                        new Map<String, Object>{
                                                'prefixPattern' => 'prefix-'
                                        }
                                )
                        }
                )
        });

        pp_Log logger = pp_Log.getLogger('test');

        if (logger.isDebugEnabled()) {
            logger.debug('{0}', 'debug');
        }
        Assert.areEqual('debug', pp_Log_Test.context.message);

        if (logger.isTraceEnabled()) {
            logger.trace('{0}', 'trace');
        }
        Assert.areEqual('trace', pp_Log_Test.context.message);

        if (logger.isInfoEnabled()) {
            logger.info('{0}', 'info');
        }
        Assert.areEqual('info', pp_Log_Test.context.message);

        if (logger.isWarnEnabled()) {
            logger.warn('{0}', 'warn');
        }
        Assert.areEqual('warn', pp_Log_Test.context.message);

        if (logger.isErrorEnabled()) {
            logger.error('{0}', 'error', null);
        }
        Assert.areEqual('error', pp_Log_Test.context.message);
    }

    @IsTest
    static void asyncTest() {
        pp_Log.configure(new List<pp_Log.Rule>{
                new pp_Log.Rule(
                        new List<String>{
                                '.*'
                        },
                        pp_Log.LevelType.DEBUG,
                        new List<pp_Log.AppenderConfig>{
                                new pp_Log.AppenderConfig(
                                        'pp_Log_Test.TestAsyncAppender',
                                        new Map<String, Object>{
                                                'prefixPattern' => 'prefix-'
                                        }
                                )
                        }
                )
        });

        pp_Log logger = pp_Log.getLogger('test');

        Test.startTest();
        logger.debug('{0}', 'debug');
        pp_Log.flush();
        Test.stopTest();

        Assert.areEqual('debug', pp_Log_Test.context.message);
    }

    public class TestAppender extends pp_Log.DefaultAppender {
        public override void append(Context ctx) {
            super.append(ctx);

            pp_Log_Test.context = ctx;
        }
    }

    public class TestAsyncAppender extends pp_Log.DefaultAsyncAppender {
        public override void flush() {
            super.flush();

            pp_Log_Test.context = this.contexts[0];
        }
    }
}