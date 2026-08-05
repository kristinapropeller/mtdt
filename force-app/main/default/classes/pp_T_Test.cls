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
private class pp_T_Test {
    @IsTest
    static void toBeTest() {
        pp_T.expect(true).toBe(true);
        pp_T.expect(false).never.toBe(true);
    }

    @IsTest
    static void toEqualTest() {
        pp_T.expect(true).toEqual(true);
        pp_T.expect(false).never.toEqual(true);
    }

    @IsTest
    static void toMatchTest() {
        pp_T.expect('cat').toMatch('cat');
        pp_T.expect('dog').never.toMatch('cat');
    }

    @IsTest
    static void toBeNullTest() {
        pp_T.expect(null).toBeNull();
        pp_T.expect('abc').never.toBeNull();
    }

    @IsTest
    static void toBeTrueTest() {
        pp_T.expect(true).toBeTrue();
        pp_T.expect(false).never.toBeTrue();
    }

    @IsTest
    static void toBeFalseTest() {
        pp_T.expect(false).toBeFalse();
        pp_T.expect(true).never.toBeFalse();
    }

    @IsTest
    static void toContainTest() {
        pp_T.expect(new List<String>{
                'a', 'b'
        }).toContain('b');
        pp_T.expect(new List<String>{
                'a', 'b'
        }).never.toContain('c');
    }

    @IsTest
    static void toBeLessThanTest() {
        pp_T.expect(1).toBeLessThan(2);
        pp_T.expect(3).never.toBeLessThan(2);
    }

    @IsTest
    static void toBeGreaterThanTest() {
        pp_T.expect(3).toBeGreaterThan(2);
        pp_T.expect(1).never.toBeGreaterThan(2);
    }

    @IsTest
    static void defaultMockTest() {
        pp_Func f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.expect(f).never.toBeNull();

        Object val = f.run();
        pp_T.expect(val).toBeNull();
    }

    @IsTest
    static void thenReturnTest() {
        pp_Func f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(0)).thenReturn(0);
        pp_T.expect(f.run(0)).toBe(0);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run('input')).thenReturn('abc');
        pp_T.expect(f.run('input')).toBe('abc');
        pp_T.expect(f.run('wrong')).never.toBe('abc');
    }

    @IsTest
    static void matcherTest() {
        pp_Func f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.any(pp_R.isNotNull))).thenReturn(0);

        pp_T.expect(f.run(0)).toBe(0);
        pp_T.expect(f.run(null)).toBe(null);
    }

    @IsTest
    static void matchersTest() {
        pp_Func f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyBoolean())).thenReturn(0);
        pp_T.expect(f.run(true)).toBe(0);
        pp_T.expect(f.run(1)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyInteger())).thenReturn(0);
        pp_T.expect(f.run(1)).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyLong())).thenReturn(0);
        pp_T.expect(f.run((Long) 1)).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyDecimal())).thenReturn(0);
        pp_T.expect(f.run((Decimal) 1)).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyDouble())).thenReturn(0);
        pp_T.expect(f.run((Double) 1)).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyString())).thenReturn(0);
        pp_T.expect(f.run('abc')).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyList())).thenReturn(0);
        pp_T.expect(f.run(new List<String>())).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anySet())).thenReturn(0);
        pp_T.expect(f.run(new Set<String>())).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyMap())).thenReturn(0);
        pp_T.expect(f.run(new Map<String, Object>())).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anySObject())).thenReturn(0);
        pp_T.expect(f.run(new Account())).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyDate())).thenReturn(0);
        pp_T.expect(f.run(Date.newInstance(2018, 1, 1))).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyTime())).thenReturn(0);
        pp_T.expect(f.run(Time.newInstance(10, 0, 0, 0))).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);

        f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyDatetime())).thenReturn(0);
        pp_T.expect(f.run(Datetime.now())).toBe(0);
        pp_T.expect(f.run(true)).toBe(null);
    }

    @IsTest
    static void thenThrowTest() {
        pp_Func f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(0)).thenThrow(new pp_T.TestException('test'));

        try {
            f.run(0);

            pp_T.fail('Should fail here');
        } catch (Exception e) {
            pp_T.expect(true).toBe(true);
        }
    }

    @IsTest
    static void thenAnswerTest() {
        pp_Func f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(pp_T.anyDecimal())).thenAnswer(pp_R.multiply.apply(2));

        pp_T.expect(f.run((Decimal) 2)).toBe(4);
    }

    @IsTest
    static void verifyTest() {
        pp_Func f = (pp_Func) pp_T.mock(pp_Func.class);
        pp_T.when(f.run(0)).thenReturn(0);

        f.run(0);

        pp_T.verify(f, 'run').toHaveBeenCalled();
        pp_T.verify(f, 'run').toHaveBeenCalledTimes(1);
        pp_T.verify(f, 'run').toHaveBeenCalledWith(new List<Object>{
                0
        });
    }

    @IsTest
    static void anyMatcherTest() {
        pp_T.expect(true).toEqual(pp_T.objectOfAny(Boolean.class));
    }

    @IsTest
    static void anythingMatcherTest() {
        pp_T.expect(true).toEqual(pp_T.objectOfAnything());
    }

    @IsTest
    static void mapContainingTest() {
        pp_T.expect(new Map<String, Object>{
                'name' => 'test'
        }).toEqual(pp_T.mapContaining(new Map<String, Object>{
                'name' => 'test'
        }));
    }

    @IsTest
    static void listContainingTest() {
        pp_T.expect(new List<Object>{
                1, 2
        }).toEqual(pp_T.listContaining(new List<Object>{
                1
        }));
    }

    @IsTest
    static void randomBooleanTest() {
        Boolean result = (Boolean) pp_Random.anyBoolean.run(50);
        pp_T.expect(true).toBe(true);
    }

    @IsTest
    static void randomIntegerTest() {
        Integer result = (Integer) pp_Random.anyInteger.run(10, 20);
        pp_T.expect(result).toBeGreaterThan(9);
        pp_T.expect(result).toBeLessThan(20);
    }

    @IsTest
    static void randomLongTest() {
        Long result = (Long) pp_Random.anyLong.run(10, 20);
        pp_T.expect(result).toBeGreaterThan(9);
        pp_T.expect(result).toBeLessThan(20);
    }

    @IsTest
    static void randomDoubleTest() {
        Double result = (Double) pp_Random.anyDouble.run(10, 20);
        pp_T.expect(result).toBeGreaterThan(9);
        pp_T.expect(result).toBeLessThan(20);
    }

    @IsTest
    static void randomDecimalTest() {
        Decimal result = (Decimal) pp_Random.anyDecimal.run(10, 20);
        pp_T.expect(result).toBeGreaterThan(9);
        pp_T.expect(result).toBeLessThan(20);
    }

    @IsTest
    static void randomCharTest() {
        String ch = (String) pp_Random.anyChar.run();
        pp_T.expect(ch).never.toBeNull();
    }

    @IsTest
    static void randomStringTest() {
        String str = (String) pp_Random.anyString.run();
        pp_T.expect(str).never.toBeNull();
    }

    @IsTest
    static void randomTest() {
        Object val = pp_Random.anyObject.run();
        pp_T.expect(val).toBeNull();

        val = pp_Random.anyObject.run(new Map<String, Object>{
                'type' => 'Account'
        });
        pp_T.expect(val).never.toBeNull();
    }

    @IsTest
    static void randomListTest() {
        List<Object> mList = (List<Object>) pp_Random.anyList.run(new Map<String, Object>{
                'min' => 1,
                'type' => 'String'
        });

        pp_T.expect(mList.get(0) instanceof String).toBe(true);
    }

    @IsTest
    static void randomSetTest() {
        Set<String> mSet = (Set<String>) pp_Random.anySet.run(new Map<String, Object>{
                'min' => 1
        });

        for (String s : mSet) {
            pp_T.expect(s).never.toBeNull();
        }
    }

    @IsTest
    static void randomMapTest() {
        Map<String, Object> mMap = (Map<String, Object>) pp_Random.anyMap.run(new Map<String, Object>{
                'pool' => new Map<String, Object>{
                        'name' => 'test'
                },
                'min' => 1
        });

        pp_T.expect(mMap.size()).toBe(1);
    }

    @IsTest
    static void randomDateTest() {
        Date d = (Date) pp_Random.anyDate.run();

        pp_T.expect(d).never.toBeNull();
    }

    @IsTest
    static void randomTimeTest() {
        Time d = (Time) pp_Random.anyTime.run();

        pp_T.expect(d).never.toBeNull();
    }

    @IsTest
    static void randomDatetimeTest() {
        Datetime d = (Datetime) pp_Random.anyDatetime.run();

        pp_T.expect(d).never.toBeNull();
    }

    @IsTest
    static void randomSyllableTest() {
        String s = (String) pp_Random.anySyllable.run();

        pp_T.expect(s).never.toBeNull();
    }

    @IsTest
    static void randomWordTest() {
        String s = (String) pp_Random.anyWord.run();

        pp_T.expect(s).never.toBeNull();
    }

    @IsTest
    static void randomSentenceTest() {
        String s = (String) pp_Random.anySentence.run();

        pp_T.expect(s).never.toBeNull();
        pp_T.expect(s).toMatch('.*\\.$');
    }

    @IsTest
    static void randomParagraphTest() {
        String s = (String) pp_Random.anyParagraph.run();

        pp_T.expect(s).never.toBeNull();
    }

    @IsTest
    static void randomGenderTest() {
        String s = (String) pp_Random.anyGender.run();

        pp_T.expect(new List<String>{
                'Male', 'Female'
        }).toContain(s);
    }

    @IsTest
    static void randomFirstnameTest() {
        String s = (String) pp_Random.anyFirstname.run();

        pp_T.expect(s).never.toBeNull();
    }

    @IsTest
    static void randomLastnameTest() {
        String s = (String) pp_Random.anyLastname.run();

        pp_T.expect(s).never.toBeNull();
    }

    @IsTest
    static void randomPrefixTest() {
        String s = (String) pp_Random.anyPrefix.run();

        pp_T.expect(s).never.toBeNull();
    }

    @IsTest
    static void randomSuffixTest() {
        String s = (String) pp_Random.anySuffix.run();

        pp_T.expect(s).never.toBeNull();
    }

    @IsTest
    static void randomNameTest() {
        String s = (String) pp_Random.anyName.run();

        pp_T.expect(s).never.toBeNull();
    }

    @IsTest
    static void randomEmailTest() {
        String s = (String) pp_Random.anyEmail.run();

        pp_T.expect(s).never.toBeNull();
        pp_T.expect(s).toMatch('.*@.*');
    }

    @IsTest
    static void randomSObjectTest() {
        SObject obj = (SObject) pp_Random.anySObject.run(new Map<String, Object>{
                'type' => 'Account'
        });

        pp_T.expect(obj).never.toBeNull();
    }

    @IsTest
    static void createObjectTest() {
        Object obj = pp_T.create('Account');

        pp_T.expect(obj).never.toBeNull();
    }

    @IsTest
    static void fieldOverrideTest() {
        Object obj = pp_T.createSObject('Account', new Map<String, Object>{
                'fields' => new List<String>{
                        'Description'
                }
        });

        pp_T.expect(obj).never.toBeNull();

        obj = pp_T.createSObject('Account', new Map<String, Object>{
                'fields' => new Map<String, Object>{
                        'Description' => 'Test desc'
                }
        });

        pp_T.expect(obj).never.toBeNull();
    }
}