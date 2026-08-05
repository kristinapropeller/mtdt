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
private class pp_Mapper_Test {
    @IsTest
    static void instanceTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        Assert.isNotNull(d.data);

        d = new pp_Mapper.DTO(new pp_Mapper.DTO());
        Assert.isNotNull(d.data);
    }

    @IsTest
    static void mapConversionTest() {
        Map<String, Object> data = new Map<String, Object>{
                'name' => 'value'
        };
        pp_Mapper.DTO d = new pp_Mapper.DTO(data);
        Map<String, Object> newData = d.toMap();

        Assert.areEqual(newData, data);
    }

    @IsTest
    static void sObjectConversionTest() {
        Account data = new Account(Description = 'desc');
        pp_Mapper.DTO d = new pp_Mapper.DTO(data);
        Account newData = (Account) d.toSObject(Account.class);

        Assert.areEqual(newData, data);
    }

    @IsTest
    static void objectConversionTest() {
        TestObject data = new TestObject('name', 'value');
        pp_Mapper.DTO d = new pp_Mapper.DTO(data);
        TestObject newData = (TestObject) d.toObject(TestObject.class);

        Assert.areEqual(newData, data);
    }

    @IsTest
    static void setAndgetObjectTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setObject('a.b.c', 'value');

        Assert.isNotNull(d.getObject('a'));
        Assert.isNull(d.getObject('b'));
        Assert.isNotNull(d.getObject('a.b'));
        Assert.isNull(d.getObject('a.c'));
        Assert.areEqual('value', d.getObject('a.b.c'));
        Assert.isNull(d.getObject('a.b.c.d'));
    }

    @IsTest
    static void setAndGetBooleanTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setBoolean('a.b.c', true);

        Assert.isTrue(d.getBoolean('a.b.c'));
    }

    @IsTest
    static void setAndGetIntegerTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setInteger('a.b.c', 2);

        Assert.areEqual(2, d.getInteger('a.b.c'));
    }

    @IsTest
    static void setAndGetLongTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setLong('a.b.c', 2);

        Assert.areEqual(2, d.getLong('a.b.c'));
    }

    @IsTest
    static void setAndGetDoubleTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setDouble('a.b.c', 2);

        Assert.areEqual(2, d.getDouble('a.b.c'));
    }

    @IsTest
    static void setAndGetDecimalTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setDecimal('a.b.c', 2);

        Assert.areEqual(2, d.getDecimal('a.b.c'));
    }

    @IsTest
    static void setAndGetStringTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setString('a.b.c', 'test');

        Assert.areEqual('test', d.getString('a.b.c'));
    }

    @IsTest
    static void setAndGetListTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setList('a.b.c', new List<String>{
                'test'
        });

        Assert.areEqual(new List<String>{
                'test'
        }, d.getList('a.b.c'));
    }

    @IsTest
    static void setAndGetSetTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setSet('a.b.c', new Set<String>{
                'test'
        });

        Assert.areEqual(new Set<String>{
                'test'
        }, d.getSet('a.b.c'));
    }

    @IsTest
    static void setAndGetMapTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setMap('a.b.c', new Map<String, Object>{
                'name' => 'value'
        });

        Assert.areEqual(new Map<String, Object>{
                'name' => 'value'
        }, d.getMap('a.b.c'));
    }

    @IsTest
    static void setAndGetSObjectTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setSObject('a.b.c', new Account(Description = 'desc'));

        Assert.areEqual(new Account(Description = 'desc'), d.getSObject('a.b.c'));
    }

    @IsTest
    static void setAndGetDateTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setDate('a.b.c', Date.newInstance(2018, 1, 1));

        Assert.areEqual(Date.newInstance(2018, 1, 1), d.getDate('a.b.c'));
    }

    @IsTest
    static void setAndGetTimeTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setTime('a.b.c', Time.newInstance(10, 0, 0, 0));

        Assert.areEqual(Time.newInstance(10, 0, 0, 0), d.getTime('a.b.c'));
    }

    @IsTest
    static void setAndGetDatetimeTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setDatetime('a.b.c', Datetime.newInstance(2018, 10, 1, 0, 0, 0));

        Assert.areEqual(Datetime.newInstance(2018, 10, 1, 0, 0, 0), d.getDatetime('a.b.c'));
    }

    @IsTest
    static void setAndGetFuncTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setFunc('a.b.c', pp_R.identity);

        Assert.areEqual(pp_R.identity, d.getFunc('a.b.c'));
    }

    @IsTest
    static void defaultMapperTest() {
        pp_Mapper m = new pp_Mapper();
        pp_Mapper.DTO d = (pp_Mapper.DTO) m.run(new Account());
        Assert.isTrue(d.keySet().isEmpty());
    }

    @IsTest
    static void containsPathTest() {
        pp_Mapper.DTO d = new pp_Mapper.DTO();
        d.setObject('a.b.c', 12);
        Assert.isTrue(d.containsPath('a.b'));
        Assert.isFalse(d.containsPath('a.d'));
    }

    @IsTest
    static void simpleMappingTest() {
        Map<String, Object> src = new Map<String, Object>{
                'name' => 'value'
        };
        pp_Mapper m = new pp_Mapper().mapField('key', 'name').toMap();
        Assert.areEqual(new Map<String, Object>{
                'key' => 'value'
        }, m.run(src));
    }

    @IsTest
    static void ignoreNullMappingTest() {
        Map<String, Object> src = new Map<String, Object>{
                'name1' => 'value1', 'name2' => null
        };
        pp_Mapper m = new pp_Mapper(pp_Mapper.IGNORE_NULLS)
                .mapField('key1', 'name1')
                .mapField('key2', 'name2')
                .mapField('key3', 'name3')
                .toMap();

        Assert.areEqual(new Map<String, Object>{
                'key1' => 'value1', 'key2' => null
        }, m.run(src));
    }

    @IsTest
    static void conversionMappingTest() {
        Map<String, Object> src = new Map<String, Object>{
                'name' => 'value'
        };
        pp_Mapper m = new pp_Mapper().mapField('key', 'name', pp_R.append.apply('$')).toMap();
        Assert.areEqual(new Map<String, Object>{
                'key' => 'value$'
        }, m.run(src));
    }

    @IsTest
    static void multipleMappingTest() {
        Map<String, Object> src1 = new Map<String, Object>{
                'a' => 'c'
        };
        Map<String, Object> src2 = new Map<String, Object>{
                'b' => 'd'
        };
        pp_Mapper m = new pp_Mapper().inputAs('src1', 'src2').mapField('x', 'src1.a').mapField('y', 'src2.b').toMap();
        Assert.areEqual(new Map<String, Object>{
                'x' => 'c', 'y' => 'd'
        }, m.run(src1, src2));
    }

    @IsTest
    static void nestedMappingTest() {
        Map<String, Object> src = new Map<String, Object>{
                'name' => 'value'
        };
        pp_Mapper m = new pp_Mapper().mapField('a.b', 'name');
        pp_Mapper.DTO d = (pp_Mapper.DTO) m.run(src);
        Assert.areEqual('value', d.getString('a.b'));
    }

    @IsTest
    static void batchMappingTest() {
        Map<String, Object> src = new Map<String, Object>{
                'a' => 1,
                'b' => 2,
                'c' => 3
        };

        pp_Mapper m = new pp_Mapper().mapFields(new Map<String, Object>{
                'x' => new pp_Mapper.FieldMapper('a', pp_R.identity),
                'y' => 'b',
                'c' => pp_R.inc
        }).toMap();

        Assert.areEqual(new Map<String, Object>{
                'x' => 1,
                'y' => 2,
                'c' => (Decimal) 4
        }, m.run(src));
    }

    @IsTest
    static void reverseToTest() {
        Map<String, Object> src = new Map<String, Object>{
                'a' => 1,
                'b' => 2
        };

        pp_Mapper m = new pp_Mapper()
                .mapField('x', 'a')
                .mapField('y', 'b')
                .toMap();

        Map<String, Object> dest = (Map<String, Object>) m.run(src);

        pp_Mapper reversed = m.reverseToMap();
        Map<String, Object> src1 = (Map<String, Object>) reversed.run(dest);

        Assert.areEqual(src, src1);
    }

    class TestObject {
        public String name;
        public String value;

        public TestObject(String name, String value) {
            this.name = name;
            this.value = value;
        }

        public Integer hashCode() {
            return (name == null ? 0 : name.hashCode()) + (value == null ? 0 : value.hashCode());
        }

        public Boolean equals(Object other) {
            return other instanceof TestObject && ((TestObject) other).name == this.name &&
                    ((TestObject) other).value == this.value;
        }
    }
}