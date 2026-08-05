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
private class pp_R_Test {
    @IsTest
    static void padLeftTest() {
        Assert.areEqual(
                '001',
                pp_R.of('1')
                        .padLeft(3, '0')
                        .toString()
        );
    }

    @IsTest
    static void capitalizeTest() {
        Assert.areEqual(
                'Abc',
                pp_R.of('abc')
                        .capitalize()
                        .toString()
        );
    }

    @IsTest
    static void shuffleTest() {
        Assert.areEqual(
                3,
                pp_R.with(1, 2, 3)
                        .shuffle()
                        .size()
                        .toInteger()
        );
    }

    @IsTest
    static void compactTest() {
        Assert.areEqual(
                new List<Object>{
                        1, 2
                },
                pp_R.with(1, 2, null)
                        .compact()
                        .toList()
        );
    }

    @IsTest
    static void zipObjTest() {
        Map<String, Object> testM = pp_R.with(1, 2)
                .zipObj(new List<Object>{
                        'a', 'b'
                })
                .toMap();
        Assert.areEqual(testM.get('a'), 1);
    }

    @IsTest
    static void zipTest() {
        List<pp_R.Pair> pairs = pp_R.with(1, 2)
                .zip(new List<Object>{
                        'a', 'b'
                })
                .toPairList();
        Assert.areEqual(pairs.get(0).fst, 'a');
    }

    @IsTest
    static void updateTest() {
        Assert.areEqual(
                'abd',
                pp_R.of('abc')
                        .doUpdate(2, 'd')
                        .toString()
        );
    }

    @IsTest
    static void trimTest() {
        Assert.areEqual(
                'abc',
                pp_R.of(' abc ')
                        .trim()
                        .toString()
        );
    }

    @IsTest
    static void toLowerTest() {
        Assert.areEqual(
                'abc',
                pp_R.of('ABC')
                        .toLower()
                        .toString()
        );
    }

    @IsTest
    static void toUpperTest() {
        Assert.areEqual(
                'ABC',
                pp_R.of('abc')
                        .toUpper()
                        .toString()
        );
    }

    @IsTest
    static void testTest() {
        Assert.isTrue(
                pp_R.of('cat')
                        .test('.*a.*')
                        .toBoolean()
        );
    }

    @IsTest
    static void splitTest() {
        Assert.areEqual(
                new List<String>{
                        'a', 'b'
                },
                pp_R.of('a-b')
                        .split('-')
                        .toList()
        );
    }

    @IsTest
    static void replaceAllTest() {
        Assert.areEqual(
                'dog dog',
                pp_R.of('cat cat')
                        .replaceAll('cat', 'dog')
                        .toString()
        );
    }

    @IsTest
    static void replaceTest() {
        Assert.areEqual(
                'dog',
                pp_R.of('cat')
                        .replace('cat', 'dog')
                        .toString()
        );
    }

    @IsTest
    static void timesTest() {
        Assert.areEqual(
                new List<Integer>{
                        0, 1, 2, 3, 4, 5
                },
                pp_R.times.run(6, pp_R.identity)
        );
    }

    @IsTest
    static void repeatTest() {
        Assert.areEqual(
                'aaa',
                pp_R.of('a')
                        .repeat(3)
                        .doJoin('')
                        .toString()
        );
    }

    @IsTest
    static void removeTest() {
        Assert.areEqual(
                'adef',
                pp_R.of('abcdef')
                        .remove(1, 2)
                        .toString()
        );
    }

    @IsTest
    static void rejectTest() {
        Assert.areEqual(
                'bc',
                pp_R.of('abc')
                        .reject(pp_R.equals.apply('a'))
                        .toString()
        );
    }

    @IsTest
    static void rangeTest() {
        Assert.areEqual(
                6,
                pp_R.range(1, 4)
                        .sum()
                        .toInteger()
        );
    }

    @IsTest
    static void projectTest() {
        Assert.areEqual(
                new List<Object>{
                        new Map<String, Object>{
                                'a' => 1
                        }
                },
                pp_R.of(new List<Object>{
                        new Map<String, Object>{
                                'a' => 1, 'b' => 2
                        }
                })
                        .project(new List<String>{
                                'a'
                        })
                        .toList()
        );
    }

    @IsTest
    static void productTest() {
        Assert.areEqual(6, pp_R.product.run(1, 2, 3));
    }

    @IsTest
    static void partitionTest() {
        pp_R.Pair pair = pp_R.of('aba')
                .partition(pp_R.equals.apply('a'))
                .toPair();
        Assert.areEqual('aa', pair.fst);
    }

    @IsTest
    static void propSatisfiesTest() {
        Assert.isTrue(
                (Boolean) pp_R.propSatisfies.run('name', pp_R.isNotNull, new Map<String, Object>{
                        'name' => 1
                })
        );
    }

    @IsTest
    static void propOrTest() {
        Assert.areEqual(
                'abc',
                pp_R.propOr.run('name', 'abc', new Map<String, Object>())
        );
    }

    @IsTest
    static void omitTest() {
        Assert.areEqual(
                new Map<String, Object>{
                        'b' => 2
                },
                pp_R.of(new Map<String, Object>{
                        'a' => 1, 'b' => 2
                })
                        .omit(new List<String>{
                                'a'
                        })
                        .toMap()
        );
    }

    @IsTest
    static void pickTest() {
        Assert.areEqual(
                new Map<String, Object>{
                        'a' => 1
                },
                pp_R.of(new Map<String, Object>{
                        'a' => 1, 'b' => 2
                })
                        .pick(new List<String>{
                                'a'
                        })
                        .toMap()
        );
    }

    @IsTest
    static void nthTest() {
        Assert.areEqual(
                2,
                pp_R.with(1, 2, 3)
                        .nth(1)
                        .toInteger()
        );
    }

    @IsTest
    static void mergeTest() {
        Assert.areEqual(
                new Map<String, Object>{
                        'a' => 2
                },
                pp_R.of(new Map<String, Object>{
                        'a' => 1
                })
                        .doMerge(new Map<String, Object>{
                                'a' => 2
                        })
                        .toMap()
        );
    }

    @IsTest
    static void minTest() {
        Assert.areEqual(
                1,
                pp_R.min.run(1, 2)
        );
    }

    @IsTest
    static void maxTest() {
        Assert.areEqual(
                2,
                pp_R.max.run(1, 2)
        );
    }

    @IsTest
    static void matchTest() {
        Assert.areEqual(
                2,
                pp_R.of('abc')
                        .match('(a)bc')
                        .size()
                        .toInteger()
        );
    }

    @IsTest
    static void valuesTest() {
        Assert.areEqual(
                new List<Object>{
                        1, 2
                },
                pp_R.of(new Map<String, Object>{
                        'a' => 1, 'b' => 2
                })
                        .values()
                        .toList()
        );
    }

    @IsTest
    static void keysTest() {
        Assert.areEqual(
                new Set<String>{
                        'a', 'b'
                },
                pp_R.of(new Map<String, Object>{
                        'a' => 1, 'b' => 2
                })
                        .keys()
                        .toSet()
        );
    }

    @IsTest
    static void typeCheckTest() {
        Assert.isTrue(pp_R.with(1, 2, 3).isList());

        Assert.isTrue(pp_R.of(new Set<String>{
                'a'
        }).isSet());

        Assert.isTrue(pp_R.withObj('a', 'b').isMap());
    }

    @IsTest
    static void emptyTest() {
        Assert.areEqual(
                new List<Object>(),
                pp_R.emptyList().debug().toList()
        );

        Assert.areEqual(
                new Set<String>(),
                pp_R.emptySet().toSet()
        );

        Assert.areEqual(
                new Map<String, Object>(),
                pp_R.emptyMap().toMap()
        );

        Assert.areEqual(
                '',
                pp_R.emptyString().toString()
        );
    }

    @IsTest
    static void withObjTest() {
        Assert.areEqual(
                new Map<String, Object>{
                        'a' => 'b'
                },
                pp_R.withObj('a', 'b').toMap()
        );
    }

    @IsTest
    static void toTest() {
        Long l = 1;
        Assert.areEqual(l, pp_R.of('1').toLong());

        Decimal dec = 1;
        Assert.areEqual(dec, pp_R.of('1').toDecimal());

        Double d = 1;
        Assert.areEqual(d, pp_R.of('1').toDouble());

        Date mDate = Date.newInstance(2018, 1, 1);
        Assert.areEqual(mDate, pp_R.of('2018-01-01').toDate());

        Time mTime = Time.newInstance(10, 0, 0, 0);
        Assert.areEqual(mTime, pp_R.of(mTime).toTime());

        Datetime mDatetime = Datetime.newInstance(2018, 1, 1);
        Assert.areEqual(mDatetime, pp_R.of(mDatetime).toDatetime());

        Assert.areEqual(mDatetime, pp_R.of(mDate).toDatetime());

        pp_Func f = pp_R.equals;
        Assert.isTrue(f.toString().startsWithIgnoreCase('pp_Func'));
        Assert.areEqual(f, pp_R.of(f).toFunc());
    }

    @IsTest
    static void toListTest() {
        List<Long> listLong = new List<Long>{
                1
        };
        Assert.areEqual(listLong, pp_R.of(listLong).toLongList());

        List<Decimal> listDecimal = new List<Decimal>{
                1
        };
        Assert.areEqual(listDecimal, pp_R.of(listDecimal).toDecimalList());

        List<Double> listDouble = new List<Double>{
                1
        };
        Assert.areEqual(listDouble, pp_R.of(listDouble).toDoubleList());

        List<Boolean> listBoolean = new List<Boolean>{
                true
        };
        Assert.areEqual(listBoolean, pp_R.of(listBoolean).toBooleanList());

        List<Date> listDate = new List<Date>{
                Date.newInstance(2018, 1, 1)
        };
        Assert.areEqual(listDate, pp_R.of(listDate).toDateList());

        List<Time> listTime = new List<Time>{
                Time.newInstance(10, 0, 0, 0)
        };
        Assert.areEqual(listTime, pp_R.of(listTime).toTimeList());

        List<Datetime> listDatetime = new List<Datetime>{
                Datetime.newInstance(2018, 1, 1)
        };
        Assert.areEqual(listDatetime, pp_R.of(listDatetime).toDatetimeList());

        List<pp_Func> listFunc = new List<pp_Func>{
                pp_R.equals
        };
        Assert.areEqual(listFunc, pp_R.of(listFunc).toFuncList());
    }

    @IsTest
    static void toSetTest() {
        Set<String> sString = new Set<String>{
                'a', 'b'
        };
        Assert.areEqual(sString, pp_R.of(sSTring).toSet());

        Set<Id> sId = new Set<Id>{
                '001000000000000000', '001000000000000001'
        };
        Assert.areEqual(sId, pp_R.of(sId).toIdSet());
    }

    @IsTest
    static void toMapTest() {
        Map<String, SObject> mSObject = new Map<String, SObject>{
                'a' => new Account()
        };
        Assert.areEqual(mSObject, pp_R.of(mSObject).toSObjectMap());

        Map<String, Long> mLong = new Map<String, Long>{
                'a' => 1
        };
        Assert.areEqual(mLong, pp_R.of(mLong).toLongMap());

        Map<String, Decimal> mDecimal = new Map<String, Decimal>{
                'a' => 1
        };
        Assert.areEqual(mDecimal, pp_R.of(mDecimal).toDecimalMap());

        Map<String, Double> mDouble = new Map<String, Double>{
                'a' => 1
        };
        Assert.areEqual(mDouble, pp_R.of(mDouble).toDoubleMap());

        Map<String, String> mString = new Map<String, String>{
                'a' => '1'
        };
        Assert.areEqual(mString, pp_R.of(mString).toStringMap());

        Map<String, Boolean> mBoolean = new Map<String, Boolean>{
                'a' => true
        };
        Assert.areEqual(mBoolean, pp_R.of(mBoolean).toBooleanMap());

        Map<String, Date> mDate = new Map<String, Date>{
                'a' => Date.newInstance(2018, 0, 0)
        };
        Assert.areEqual(mDate, pp_R.of(mDate).toDateMap());

        Map<String, Time> mTime = new Map<String, Time>{
                'a' => Time.newInstance(10, 0, 0, 0)
        };
        Assert.areEqual(mTime, pp_R.of(mTime).toTimeMap());

        Map<String, Datetime> mDatetime = new Map<String, Datetime>{
                'a' => Datetime.newInstance(2018, 0, 0)
        };
        Assert.areEqual(mDatetime, pp_R.of(mDatetime).toDatetimeMap());

        Map<String, pp_Func> mFunc = new Map<String, pp_Func>{
                'a' => pp_R.equals
        };
        Assert.areEqual(mFunc, pp_R.of(mFunc).toFuncMap());
    }

    @IsTest
    static void withTest() {
        Assert.areEqual(
                'a b c',
                pp_R.with('a', 'b', 'c')
                        .doJoin(' ')
                        .toString()
        );

        Assert.areEqual(
                'a',
                pp_R.with('a')
                        .doJoin(' ')
                        .toString()
        );
    }

    @IsTest
    static void joinTest() {
        Assert.areEqual(
                'a b c',
                pp_R.of('abc')
                        .doJoin(' ')
                        .toString()
        );
    }

    @IsTest
    static void invertTest() {
        Assert.areEqual(
                new Map<String, Object>{
                        'a' => new List<Object>{
                                'b'
                        }
                },
                pp_R.of(new Map<String, Object>{
                        'b' => 'a'
                })
                        .invert()
                        .toMap()
        );
    }

    @IsTest
    static void invertObjTest() {
        Assert.areEqual(
                new Map<String, Object>{
                        'a' => 'b'
                },
                pp_R.of(new Map<String, Object>{
                        'b' => 'a'
                })
                        .invertObj()
                        .toMap()
        );
    }

    @IsTest
    static void insertAllTest() {
        String msg = 'aba';

        Assert.areEqual(
                'abcda',
                pp_R.of(msg)
                        .doInsertAll(2, 'cd')
                        .toString()
        );
    }

    @IsTest
    static void insertTest() {
        String msg = 'aba';

        Assert.areEqual(
                'abca',
                pp_R.of(msg)
                        .doInsert(2, 'c')
                        .toString()
        );
    }

    @IsTest
    static void containsByTest() {
        String msg = 'aba';

        Assert.isTrue(
                pp_R.of(msg)
                        .containsBy(pp_R.equals, 'a')
                        .toBoolean()
        );
    }

    @IsTest
    static void lastIndexOfTest() {
        String msg = 'aba';

        Assert.areEqual(1, pp_R.of(msg).lastIndexOf('b').toInteger());
    }

    @IsTest
    static void indexOfTest() {
        String msg = 'aba';

        Assert.areEqual(1, pp_R.of(msg).indexOf('b').toInteger());
    }

    @IsTest
    static void indexByTest() {
        String msg = 'aba';

        Map<String, Object> indexMap
                = pp_R.of(msg)
                        .indexBy(pp_R.identity)
                        .toMap();

        Assert.areEqual(
                'a',
                indexMap.get('a')
        );
    }

    @IsTest
    static void tailTest() {
        String msg = 'aba';

        Assert.areEqual('ba', pp_R.of(msg).tail().toString());
    }

    @IsTest
    static void initTest() {
        String msg = 'aba';

        Assert.areEqual('ab', pp_R.of(msg).init().toString());
    }

    @IsTest
    static void lastTest() {
        String msg = 'aba';

        Assert.areEqual('a', pp_R.of(msg).last().toString());
    }

    @IsTest
    static void firstTest() {
        String msg = 'aba';

        Assert.areEqual('a', pp_R.of(msg).first().toString());
    }

    @IsTest
    static void groupByTest() {
        String msg = 'aba';

        Map<String, Object> groupMap
                = pp_R.of(msg)
                        .groupBy(pp_R.identity)
                        .toMap();

        List<Object> mList = (List<Object>) groupMap.get('a');

        Assert.areEqual(
                new List<Object>{
                        'a', 'a'
                },
                mList
        );
    }

    @IsTest
    static void toPairsTest() {
        Map<String, Object> source = new Map<String, Object>{
                'name' => 'abc'
        };
        List<pp_R.Pair> pairs =
                pp_R.of(source)
                        .toPairs()
                        .toPairList();
        Assert.areEqual('abc', pairs.get(0).snd);
    }

    @IsTest
    static void fromPairsTest() {
        List<Object> source = new List<Object>{
                new pp_R.Pair('name', 'wilson'),
                new pp_R.Pair('test', 'aa')
        };
        Map<String, Object> newMap =
                pp_R.of(source)
                        .fromPairs()
                        .toMap();
        Assert.areEqual('wilson', newMap.get('name'));
    }

    @IsTest
    static void pairTest() {
        pp_R.Pair testP = (pp_R.Pair) pp_R.pair.run(1, 2);
        Assert.areEqual(1, testP.fst);
    }

    @IsTest
    static void flattenTest() {
        List<Object> mList = new List<Object>{
                1, 2
        };
        mList.add(new List<Object>{
                3, new List<Object>{
                        4
                }
        });
        Assert.areEqual(
                new List<Object>{
                        1, 2, 3, 4
                },
                pp_R.of(mList)
                        .flatten()
                        .toList()
        );
    }

    @IsTest
    static void unnestTest() {
        List<Object> mList = new List<Object>{
                1, 2
        };
        mList.add(new List<Object>{
                3
        });
        Assert.areEqual(
                new List<Object>{
                        1, 2, 3
                },
                pp_R.of(mList)
                        .unnest()
                        .toList()
        );
    }

    @IsTest
    static void findIndexTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                2,
                pp_R.of(ints)
                        .findIndex(pp_R.gt.apply(pp_R.placeholder, 2))
                        .toInteger()
        );
    }

    @IsTest
    static void findLastTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                3,
                pp_R.of(ints)
                        .findLast(pp_R.gt.apply(pp_R.placeholder, 2))
                        .toInteger()
        );
    }

    @IsTest
    static void findTest() {
        Map<String, Object> data = new Map<String, Object>{
                'name' => 'wilson'
        };
        pp_R.Pair pair = (pp_R.Pair) pp_R.of(data)
                .find((pp_Func) pp_R.unary.run(pp_R.equals.apply('wilson')))
                .toObject();
        Assert.areEqual('name', pair.fst);
    }

    @IsTest
    static void evolveTest() {
        Map<String, Object> data
                = pp_R.of(new Map<String, Object>{
                        'name' => 'wilson'
                })
                        .evolve(new Map<String, Object>{
                                'name' => pp_R.always.run('adam')
                        })
                        .toMap();
        Assert.areEqual('adam', data.get('name'));
    }

    @IsTest
    static void endsWithTest() {
        Assert.isTrue(
                pp_R.of(new List<Integer>{
                        1, 2, 3
                })
                        .endsWith(new List<Integer>{
                                2, 3
                        })
                        .toBoolean()
        );
    }

    @IsTest
    static void startsWithTest() {
        Assert.isTrue(
                pp_R.of(new List<Integer>{
                        1, 2, 3
                })
                        .startsWith(new List<Integer>{
                                1, 2
                        })
                        .toBoolean()
        );
    }

    @IsTest
    static void dissocTest() {
        Map<String, Object> testM = new Map<String, Object>{
                'name' => 'wilson'
        };
        Assert.areEqual(
                new Map<String, Object>(),
                pp_R.of(testM)
                        .dissoc('name')
                        .toMap()
        );
    }

    @IsTest
    static void defaultToTest() {
        Assert.areEqual(
                3,
                pp_R.of(null)
                        .defaultTo(3)
                        .toInteger()
        );
    }

    @IsTest
    static void countByTest() {
        String msg = 'aba';

        Map<String, Integer> countMap
                = pp_R.of(msg)
                        .countBy(pp_R.identity)
                        .toIntegerMap();

        Assert.areEqual(2, countMap.get('a'));
    }

    @IsTest
    static void concatTest() {
        Assert.areEqual(
                'abcd',
                pp_R.of('ab')
                        .concat('cd')
                        .toString()
        );
    }

    @IsTest
    static void cloneTest() {
        Assert.areEqual(
                'abc',
                pp_R.of('abc')
                        .doClone()
                        .toString()
        );
    }

    @IsTest
    static void clampTest() {
        Assert.areEqual(
                3,
                pp_R.of(1)
                        .clamp(3, 5)
                        .toInteger()
        );
    }

    @IsTest
    static void assocTest() {
        Map<String, Object> testM = new Map<String, Object>{
                'name' => 'wilson'
        };
        Assert.areEqual(
                new Map<String, Object>{
                        'name' => 'adam'
                },
                pp_R.of(testM)
                        .assoc('name', 'adam')
                        .toMap()
        );

        Account acc = new Account();
        acc.Description = 'test';
        Assert.areEqual(
                'abc',
                pp_R.of(acc)
                        .assoc('Description', 'abc')
                        .toSObject()
                        .get('Description')
        );
    }

    @IsTest
    static void transformTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                3,
                pp_R.of(ints)
                        .transform(pp_R.size)
                        .toInteger()
        );

        Assert.areEqual(
                'abc',
                pp_R.of('bc')
                        .prepend('a')
                        .toString()
        );
    }

    @IsTest
    static void appendTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        1, 2, 3, 4
                },
                pp_R.of(ints)
                        .append(4)
                        .toIntegerList()
        );

        Assert.areEqual(
                'abc',
                pp_R.of('ab')
                        .append('c')
                        .toString()
        );
    }

    @IsTest
    static void prependTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        4, 1, 2, 3
                },
                pp_R.of(ints)
                        .prepend(4)
                        .toIntegerList()
        );
    }

    @IsTest
    static void someTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.isTrue(
                pp_R.of(ints)
                        .some(pp_R.gt.apply(pp_R.placeholder, 2))
                        .toBoolean()
        );

        Assert.isTrue(
                pp_R.of('abc')
                        .some(pp_R.equals.apply('b'))
                        .toBoolean()
        );
    }

    @IsTest
    static void noneTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.isTrue(
                pp_R.of(ints)
                        .none(pp_R.gt.apply(pp_R.placeholder, 4))
                        .toBoolean()
        );

        Assert.isTrue(
                pp_R.of('abc')
                        .none(pp_R.equals.apply('d'))
                        .toBoolean()
        );
    }

    @IsTest
    static void allTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.isTrue(
                pp_R.of(ints)
                        .all(pp_R.gt.apply(pp_R.placeholder, 0))
                        .toBoolean()
        );

        Assert.isTrue(
                pp_R.of('abc')
                        .all((pp_Func) pp_R.complement.run(pp_R.isNil))
                        .toBoolean()
        );
    }

    @IsTest
    static void adjustTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        1, 12, 3
                },
                pp_R.of(ints)
                        .adjust(pp_R.add.apply(10), 1)
                        .toIntegerList()
        );

        Assert.areEqual(
                'abd',
                pp_R.of('abc')
                        .adjust((pp_Func) pp_R.always.run('d'), 2)
                        .toString()
        );
    }

    @IsTest
    static void unionTest() {
        List<Integer> ints1 = new List<Integer>{
                1, 2, 3
        };
        List<Integer> ints2 = new List<Integer>{
                2, 3, 4
        };
        Assert.areEqual(
                new List<Integer>{
                        1, 2, 3, 4
                },
                pp_R.of(ints1)
                        .union(ints2)
                        .toIntegerList()
        );

        String s1 = 'abc';
        String s2 = 'cde';
        Assert.areEqual(
                'abcde',
                pp_R.of(s1)
                        .union(s2)
                        .toString()
        );
    }

    @IsTest
    static void intersectionTest() {
        List<Integer> ints1 = new List<Integer>{
                1, 2, 3
        };
        List<Integer> ints2 = new List<Integer>{
                2, 3, 4
        };
        Assert.areEqual(
                new List<Integer>{
                        2, 3
                },
                pp_R.of(ints1)
                        .intersection(ints2)
                        .toIntegerList()
        );

        String s1 = 'abc';
        String s2 = 'cde';
        Assert.areEqual(
                'c',
                pp_R.of(s1)
                        .intersection(s2)
                        .toString()
        );
    }

    @IsTest
    static void xorTest() {
        List<Integer> ints1 = new List<Integer>{
                1, 2, 3
        };
        List<Integer> ints2 = new List<Integer>{
                2, 3, 4
        };
        Assert.areEqual(
                new List<Integer>{
                        1, 4
                },
                pp_R.of(ints1)
                        .xor(ints2)
                        .toIntegerList()
        );

        String s1 = 'abc';
        String s2 = 'cde';
        Assert.areEqual(
                'abde',
                pp_R.of(s1)
                        .xor(s2)
                        .toString()
        );
    }

    @IsTest
    static void differenceTest() {
        List<Integer> ints1 = new List<Integer>{
                1, 2, 3
        };
        List<Integer> ints2 = new List<Integer>{
                2, 3, 4
        };
        Assert.areEqual(
                new List<Integer>{
                        1
                },
                pp_R.of(ints1)
                        .difference(ints2)
                        .toIntegerList()
        );

        String s1 = 'abc';
        String s2 = 'cde';
        Assert.areEqual(
                'ab',
                pp_R.of(s1)
                        .difference(s2)
                        .toString()
        );
    }

    @IsTest
    static void uniqTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3, 2
        };
        Assert.areEqual(
                new List<Integer>{
                        1, 2, 3
                },
                pp_R.of(ints)
                        .uniq()
                        .toIntegerList()
        );
    }

    @IsTest
    static void containsTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.isTrue(
                pp_R.of(ints)
                        .contains(2)
                        .toBoolean()
        );

        String msg = 'abc';
        Assert.isTrue(
                pp_R.of(msg)
                        .contains('b')
                        .toBoolean()
        );
    }

    @IsTest
    static void containsKeyTest() {
        Map<String, Object> testM = new Map<String, Object>{
                'name' => 'wilson'
        };
        Assert.isTrue(
                pp_R.of(testM)
                        .containsKey('name')
                        .toBoolean()
        );
    }

    @IsTest
    static void cascadeTest() {
        List<Account> accList = getAccountList3();
        List<Account> newList = (List<Account>) pp_R.of(accList)
                .sortBy((pp_Func) pp_R.cascade.run(
                        (pp_Func) pp_R.ascend.run(pp_R.prop.apply('Name')),
                        (pp_Func) pp_R.ascend.run(pp_R.prop.apply('Description'))
                ))
                .toSObjectList();
        Assert.areEqual('a', newList.get(0).Name);
        Assert.areEqual('a', newList.get(0).Description);
    }

    @IsTest
    static void ascendTest() {
        List<Account> accList = getAccountList2();
        List<Account> newList = (List<Account>) pp_R.of(accList)
                .sortBy((pp_Func) pp_R.ascend.run(pp_R.prop.apply('Description')))
                .toSObjectList();
        Assert.areEqual('a', newList.get(0).Description);
    }

    @IsTest
    static void descendTest() {
        List<Account> accList = getAccountList2();
        List<Account> newList = (List<Account>) pp_R.of(accList)
                .sortBy((pp_Func) pp_R.descend.run(pp_R.prop.apply('Description')))
                .toSObjectList();
        Assert.areEqual('b', newList.get(0).Description);
    }

    @IsTest
    static void sortAndReverseTest() {
        List<Integer> ints = new List<Integer>{
                2, 1, 3
        };
        Assert.areEqual(
                pp_R.of(ints)
                        .sortDefault()
                        .reverse(),
                pp_R.of(ints)
                        .sortBy((pp_Func) pp_R.flip.run(pp_R.subtract))
        );
    }

    @IsTest
    static void sortDefaultTest() {
        List<Integer> ints = new List<Integer>{
                3, 2, 1
        };
        Assert.areEqual(
                new List<Integer>{
                        1, 2, 3
                },
                pp_R.of(ints)
                        .sortDefault()
                        .toIntegerList()
        );

        Assert.areEqual(
                'abc',
                pp_R.of('cba')
                        .sortDefault()
                        .toString()
        );
    }

    @IsTest
    static void sortTest() {
        List<Integer> ints = new List<Integer>{
                3, 2, 1
        };
        Assert.areEqual(
                new List<Integer>{
                        1, 2, 3
                },
                pp_R.of(ints)
                        .sortBy(new TestComparator1())
                        .toIntegerList()
        );
    }

    class TestComparator1 extends pp_Func {
        public override Object exec(Object arg1, Object arg2) {
            return (Integer) arg1 - (Integer) arg2;
        }
    }

    @IsTest
    static void reverseTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        3, 2, 1
                },
                pp_R.of(ints)
                        .reverse()
                        .toIntegerList()
        );

        Assert.areEqual(
                'cba',
                pp_R.of('abc')
                        .reverse()
                        .toString()
        );
    }

    @IsTest
    static void dropTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        3
                },
                pp_R.of(ints)
                        .drop(2)
                        .toIntegerList()
        );
    }

    @IsTest
    static void dropRightTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        1
                },
                pp_R.of(ints)
                        .dropRight(2)
                        .toIntegerList()
        );
    }

    @IsTest
    static void dropWhileTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        3
                },
                pp_R.of(ints)
                        .dropWhile(pp_R.lt.apply(pp_R.placeholder, 3))
                        .toIntegerList()
        );
    }

    @IsTest
    static void dropRightWhileTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        1
                },
                pp_R.of(ints)
                        .dropRightWhile(pp_R.gt.apply(pp_R.placeholder, 1))
                        .toIntegerList()
        );
    }

    @IsTest
    static void takeTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        1, 2
                },
                pp_R.of(ints)
                        .take(2)
                        .toIntegerList()
        );

        Assert.areEqual(
                'ab',
                pp_R.of('abc')
                        .take(2)
                        .toString()
        );
    }

    @IsTest
    static void takeRightTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        2, 3
                },
                pp_R.of(ints)
                        .takeRight(2)
                        .toIntegerList()
        );

        Assert.areEqual(
                'bc',
                pp_R.of('abc')
                        .takeRight(2)
                        .toString()
        );
    }

    @IsTest
    static void takeWhileTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        1, 2
                },
                pp_R.of(ints)
                        .takeWhile(pp_R.lt.apply(pp_R.placeholder, 3))
                        .toIntegerList()
        );

        Assert.areEqual(
                'a',
                pp_R.of('abc')
                        .takeWhile(pp_R.equals.apply('a'))
                        .toString()
        );
    }

    @IsTest
    static void takeRightWhileTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        2, 3
                },
                pp_R.of(ints)
                        .takeRightWhile(pp_R.gt.apply(pp_R.placeholder, 1))
                        .toIntegerList()
        );

        Assert.areEqual(
                '',
                pp_R.of('abc')
                        .takeRightWhile(pp_R.equals.apply('a'))
                        .toString()
        );
    }

    @IsTest
    static void sliceTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        2
                },
                pp_R.of(ints)
                        .slice(1, 2)
                        .toIntegerList()
        );

        Assert.areEqual(
                'b',
                pp_R.of('abc')
                        .slice(1, 2)
                        .toString()
        );
    }

    @IsTest
    static void sumTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                6,
                pp_R.of(ints)
                        .sum()
                        .toInteger()
        );
    }

    @IsTest
    static void isEmptyTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                false,
                pp_R.of(ints)
                        .isEmpty()
                        .toBoolean()
        );
    }

    @IsTest
    static void isNotEmptyTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                true,
                pp_R.of(ints)
                        .isNotEmpty()
                        .toBoolean()
        );
    }

    @IsTest
    static void lengthTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                3,
                pp_R.of(ints)
                        .length()
                        .toInteger()
        );
    }

    @IsTest
    static void reduceTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                6,
                pp_R.of(ints)
                        .reduce(pp_R.add, 0)
                        .toInteger()
        );

        String msg = 'abc';
        Assert.areEqual(
                'a',
                pp_R.of(msg)
                        .reduce((pp_Func) pp_R.always.run('a'), null)
                        .toString()
        );
    }

    @IsTest
    static void pluckTest() {
        List<Account> accList = getAccountList();
        Assert.areEqual(
                new List<String>{
                        'desc'
                },
                pp_R.of(accList)
                        .pluck('Description')
                        .toStringList()
        );
    }

    @IsTest
    static void doMapTest() {
        List<Account> accList = getAccountList();
        Assert.areEqual(
                new List<String>{
                        'desc'
                },
                pp_R.of(accList)
                        .doMap(pp_R.prop.apply('Description'))
                        .toStringList()
        );
    }

    @IsTest
    static void filterFieldsTest() {
        List<Account> accList = getAccountList();
        Assert.areEqual(
                1,
                pp_R.of(accList)
                        .filter(new Map<String, Object>{
                                'Description' => 'desc'
                        })
                        .toSObjectList()
                        .size()
        );
    }

    @IsTest
    static void filterFieldValueTest() {
        List<Account> accList = getAccountList();
        Assert.areEqual(
                1,
                pp_R.of(accList)
                        .filter('Description', 'desc')
                        .toSObjectList()
                        .size()
        );
    }

    @IsTest
    static void filterFieldTest() {
        List<Account> accList = getAccountList();
        Assert.areEqual(
                1,
                pp_R.of(accList)
                        .filter('Description')
                        .toSObjectList()
                        .size()
        );
    }

    @IsTest
    static void filterPredTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        Assert.areEqual(
                new List<Integer>{
                        1
                },
                pp_R.of(ints).filter(
                        (pp_Func) pp_R.lt.apply(pp_R.placeholder, 2)
                ).toIntegerList()
        );
    }

    @IsTest
    static void toArrayTest() {
        List<Integer> ints = new List<Integer>{
                1, 2, 3
        };
        pp_R.of(ints).forEach(pp_R.debug);
        Assert.areEqual(ints, pp_R.of(ints).toIntegerList());
    }

    static List<Account> getAccountList() {
        Account acc = new Account();
        acc.Description = 'desc';
        List<Account> accList = new List<Account>{
                acc
        };
        return accList;
    }

    static List<Account> getAccountList2() {
        Account acc1 = new Account();
        acc1.Description = 'a';
        Account acc2 = new Account();
        acc2.Description = 'b';
        List<Account> accList = new List<Account>{
                acc1, acc2
        };
        return accList;
    }

    static List<Account> getAccountList3() {
        Account acc1 = new Account();
        acc1.Name = 'b';
        acc1.Description = 'b';
        Account acc2 = new Account();
        acc2.Name = 'a';
        acc2.Description = 'b';
        Account acc3 = new Account();
        acc3.Name = 'a';
        acc3.Description = 'a';
        List<Account> accList = new List<Account>{
                acc1, acc2, acc3
        };
        return accList;
    }

    @IsTest
    static void juxtTest() {
        List<pp_Func> fns = new List<pp_Func>{
                pp_R.add, pp_R.subtract
        };
        List<Object> data = (List<Object>) pp_R.juxt.run(fns, 1, 2);
        Assert.areEqual(3, data.get(0));
        Assert.areEqual(-1, data.get(1));
    }

    @IsTest
    static void applySpecTest() {
        Map<String, Object> spec = new Map<String, Object>{
                'add' => pp_R.add,
                'subtract' => pp_R.subtract
        };

        Map<String, Object> data = (Map<String, Object>) pp_R.applySpec.run(spec, 1, 2);
        Assert.areEqual(3, data.get('add'));
        Assert.areEqual(-1, data.get('subtract'));
    }

    @IsTest
    static void bimapTest() {
        Map<String, Object> m1 = new Map<String, Object>{
                'name' => 2
        };
        Assert.areEqual(
                new Map<String, Object>{
                        'new_name' => 3
                },
                (Map<String, Object>) pp_R.bimap.run(pp_R.always.run('new_name'), pp_R.nAry.run(
                        1,
                        pp_R.pipe.run(
                                pp_R.inc,
                                pp_R.toInteger
                        )
                ), m1)
        );
    }

    @IsTest
    static void compareTest() {
        Assert.isTrue((Integer) pp_R.compare.run(1, 2) < 0);
    }

    @IsTest
    static void comparatorTest() {
        pp_Func testF = (pp_Func) pp_R.comparator.run(new TestComparator2());
        Assert.areEqual(1, testF.run(2, 1));
    }

    class TestComparator2 extends pp_Func {
        public override Object exec(Object arg1, Object arg2) {
            Integer num1 = (Integer) arg1;
            Integer num2 = (Integer) arg2;
            return num1 < num2;
        }
    }

    @IsTest
    static void whereSatisfiesTest() {
        Account acc = new Account();
        acc.Description = 'desc';
        Assert.isTrue((Boolean) pp_R.whereSatisfies.run(
                new Map<String, pp_Func>{
                        'Description' => (pp_Func) pp_R.complement.run(pp_R.isNil)
                },
                acc
        ));
    }

    @IsTest
    static void whereEqTest() {
        Account acc = new Account();
        acc.Description = 'desc';
        Assert.isTrue((Boolean) pp_R.whereEq.run(
                new Map<String, Object>{
                        'Description' => 'desc'
                },
                acc
        ));
    }

    @IsTest
    static void propEqTest() {
        Account acc = new Account();
        acc.Description = 'desc';
        Assert.isTrue((Boolean) pp_R.propEq.run('Description', 'desc', acc));
    }

    @IsTest
    static void propTest() {
        Account acc = new Account();
        acc.Description = 'desc';
        Assert.areEqual('desc', pp_R.prop.run('Description', acc));
    }

    @IsTest
    static void pathTest() {
        Account acc = new Account();
        acc.Name = 'Name';
        acc.Description = 'desc';
        insert acc;

        acc = [SELECT Id, Owner.Id FROM Account WHERE Id = :acc.Id];
        Assert.isNotNull(pp_R.path.run('Owner.Id', acc));
    }

    @IsTest
    static void hasTest() {
        Account acc = new Account();
        acc.Description = 'desc';
        Assert.isTrue((Boolean) pp_R.has.run('Description', acc));
    }

    @IsTest
    static void memoizeTest() {
        pp_Func testF = (pp_Func) pp_R.memoize.run(
                pp_R.add.apply(1),
                'testF',
                pp_R.toString
        );

        Assert.areEqual(2, testF.run(1));
        Assert.areEqual(2, testF.run(1));
    }

    @IsTest
    static void onceTest() {
        pp_Func testF = (pp_Func) pp_R.once.run(pp_R.add.apply(1), 'testF');

        Assert.areEqual(2, testF.run(1));
        Assert.areEqual(2, testF.run(3));
    }

    @IsTest
    static void useWithTest() {
        pp_Func testF = (pp_Func) pp_R.useWith.run(
                pp_R.multiply,
                pp_R.add.apply(1),
                pp_R.subtract.apply(1)
        );

        Assert.areEqual(-4, testF.run(1, 3));
    }

    @IsTest
    static void convergeTest() {
        pp_Func testF = (pp_Func) pp_R.converge.run(
                pp_R.multiply,
                pp_R.add,
                pp_R.subtract
        );

        Assert.areEqual(-8, testF.run(1, 3));
    }

    @IsTest
    static void flipTest() {
        pp_Func testF = (pp_Func) pp_R.flip.run(pp_R.divide);
        Assert.areEqual(2, testF.run(2, 4));
    }

    @IsTest
    static void unlessTest() {
        pp_Func testF = (pp_Func) pp_R.unless.run(
                pp_R.lt.apply(0),
                pp_R.always.run(0)
        );
        Assert.areEqual(0, testF.run(-3));
        Assert.areEqual(new List<Object>{
                3
        }, testF.run(3));
    }

    @IsTest
    static void doWhenTest() {
        pp_Func testF = (pp_Func) pp_R.doWhen.run(
                pp_R.lt.apply(0),
                pp_R.always.run(1)
        );
        Assert.areEqual(1, testF.run(3));
        Assert.areEqual(new List<Object>{
                -3
        }, testF.run(-3));
    }

    @IsTest
    static void ifElseTest() {
        pp_Func testF = (pp_Func) pp_R.ifElse.run(
                pp_R.lt.apply(0),
                pp_R.always.run(1),
                pp_R.always.run(0)
        );
        Assert.areEqual(1, testF.run(3));
        Assert.areEqual(0, testF.run(-3));
        Assert.areEqual(0, testF.run(0));
    }

    @IsTest
    static void condTest() {
        pp_Func testF = (pp_Func) pp_R.cond.runN(new List<Object>{
                pp_R.lt.apply(0), pp_R.always.run(1),
                pp_R.gt.apply(0), pp_R.always.run(-1),
                pp_R.equals.apply(0), pp_R.always.run(0)
        });
        Assert.areEqual(1, testF.run(3));
        Assert.areEqual(-1, testF.run(-3));
        Assert.areEqual(0, testF.run(0));
    }

    @IsTest
    static void placeholderTest() {
        pp_Func divideBy2 = pp_R.divide.apply(pp_R.placeholder, 2);
        Assert.areEqual(3, divideBy2.run(6));
    }

    @IsTest
    static void identityTest() {
        Assert.areEqual(1, pp_R.identity.run(1));
    }

    @IsTest
    static void noopTest() {
        Assert.isNull(pp_R.noop.run(1));
    }

    @IsTest
    static void gtTest() {
        Assert.isTrue((Boolean) pp_R.gt.run(
                3,
                2
        ));
    }

    @IsTest
    static void gteTest() {
        Assert.isTrue((Boolean) pp_R.gte.run(
                3,
                2
        ));
    }

    @IsTest
    static void lteTest() {
        Assert.isTrue((Boolean) pp_R.lt.run(
                1,
                2
        ));
    }

    @IsTest
    static void ltTest() {
        Assert.isTrue((Boolean) pp_R.lt.run(
                1,
                2
        ));
    }

    @IsTest
    static void equalsTest() {
        Assert.isTrue((Boolean) pp_R.equals.run(
                'abc',
                'abc'
        ));
    }

    @IsTest
    static void andTest() {
        Assert.isTrue((Boolean) pp_R.doAnd.run(
                true,
                true,
                true
        ));
    }

    @IsTest
    static void orTest() {
        Assert.isTrue((Boolean) pp_R.doOr.run(
                false,
                false,
                true
        ));
    }

    @IsTest
    static void notTest() {
        Assert.isTrue((Boolean) pp_R.doNot.run(
                false
        ));
    }

    @IsTest
    static void complementTest() {
        pp_Func cf = (pp_Func) pp_R.complement.run(
                pp_R.isNil
        );
        Assert.isTrue((Boolean) cf.run(1));
    }

    @IsTest
    static void anyPassTest() {
        pp_Func anyF = (pp_Func) pp_R.anyPass.run(
                pp_R.isNil,
                pp_R.isNil
        );
        Assert.isTrue((Boolean) anyF.run(null));
    }

    @IsTest
    static void allPassTest() {
        pp_Func allF = (pp_Func) pp_R.allPass.run(
                pp_R.isNil,
                pp_R.isNil
        );
        Assert.isTrue((Boolean) allF.run(null));
    }

    @IsTest
    static void isNilTest() {
        Assert.isTrue((Boolean) pp_R.isNil.run(null));
    }

    @IsTest
    static void composeTest() {
        pp_Func myF = (pp_Func) pp_R.compose.run(
                pp_R.multiply.apply(2),
                pp_R.add.apply(1),
                pp_R.multiply.apply(3)
        );
        pp_R.debug.run('test debug');
        Assert.areEqual(8, myF.run(1));
    }

    @IsTest
    static void pipeTest() {
        pp_Func myF = (pp_Func) pp_R.pipe.run(
                pp_R.multiply.apply(2),
                pp_R.add.apply(1),
                pp_R.multiply.apply(3)
        );
        Assert.areEqual(9, myF.run(1));
    }

    @IsTest
    static void addTest() {
        Assert.areEqual(3, pp_R.add.run(1, 2));
    }

    @IsTest
    static void subtractTest() {
        Assert.areEqual(-1, pp_R.subtract.run(1, 2));
    }

    @IsTest
    static void multiplyTest() {
        Assert.areEqual(2, pp_R.multiply.run(1, 2));
    }

    @IsTest
    static void divideTest() {
        Assert.areEqual(0.5, pp_R.divide.run(1, 2));
    }

    @IsTest
    static void modTest() {
        Assert.areEqual(1, pp_R.mod.run(1, 2));
    }

    @IsTest
    static void okTest() {
        pp_Func increment = pp_R.add.apply(1);

        Object ret = increment.apply(2).run();

        Assert.areEqual(3, ret);
    }

    @IsTest
    static void constantTest() {
        pp_Func f = pp_R.constant.apply(1);
        Assert.areEqual(1, f.run(2));
    }

    @IsTest
    static void throwExceptionTest() {
        try {
            pp_R.throwException.run(new pp_Func.FuncException('test'));
            Assert.fail();
        } catch (Exception e) {
            Assert.isTrue(true);
        }
    }

    @IsTest
    static void dbQueryTest() {
        pp_R.dbInsert.run(new Account(Name = 'test'));

        List<SObject> result = (List<SObject>) pp_R.dbQuery.run('SELECT Id FROM Account WHERE Name = \'test\'');

        Assert.isTrue(result != null && !result.isEmpty());
    }

    @IsTest
    static void dbInsertTest() {
        pp_R.dbInsert.run(new Account(Name = 'test'));

        Account acc = [SELECT Id FROM Account WHERE Name = 'test'];

        Assert.isNotNull(acc);
    }

    @IsTest
    static void dbUpdateTest() {
        pp_R.dbInsert.run(new Account(Name = 'test'));

        Account acc = [SELECT Id FROM Account WHERE Name = 'test'];

        acc.Description = 'test';

        pp_R.dbUpdate.run(acc);

        acc = [SELECT Id, Description FROM Account WHERE Name = 'test'];

        Assert.areEqual('test', acc.Description);
    }

    @IsTest
    static void dbDeleteTest() {
        pp_R.dbInsert.run(new Account(Name = 'test'));

        Account acc = [SELECT Id FROM Account WHERE Name = 'test'];

        Assert.isNotNull(acc);

        pp_R.dbDelete.run(acc);

        List<Account> accList = [SELECT Id FROM Account WHERE Name = 'test'];

        Assert.isTrue(accList.isEmpty());
    }

    @IsTest
    static void sampleSizeTest() {
        String sample = (String)pp_R.sampleSize.run(2, 'abcdef');
        Assert.areEqual(2, sample.length());
    }

    @IsTest
    static void assertsTest() {
        pp_R.assert.run(true);
        pp_R.assert.run(true, 'test');
        pp_R.assertAreEqual.run('str', 'str');
        pp_R.assertAreEqual.run('str', 'str', 'test');
        pp_R.assertAreNotEqual.run('str1', 'str2');
        pp_R.assertAreNotEqual.run('str1', 'str2', 'test');
        Assert.isTrue(true);
    }
}