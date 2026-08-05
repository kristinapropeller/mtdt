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
 * Functional Library for Apex
 *
 * Apex is a pure OOP, and there is no way to make it a FP, because we cannot use functions
 * as the First Class Citizens
 *
 * The goal of this library is to make it possible to mimic the functional features as much
 * as possible
 *
 * pp_Func Objects
 *
 * We do not have first class functions, but we can create pp_Func objects to simulate function behaviors
 * Refer to pp_Func.cls for detailed information
 *
 * Favors in two styles of composition
 *
 * a) Functional Composition
 * Example:
 * ```
 * // f(x) = 2 * (1 + x)
 * // f :: Number -> Number
 * pp_Func f = (pp_Func)pp_R.pipe.run(
 *     pp_R.add.apply(1),
 *     pp_R.multiply.apply(2)
 * );
 * Decimal result = (Decimal)f.run(1); // 4
 * ```
 *
 * b) Functional Chaining
 * Example:
 * ```
 * pp_R.of(new List<Integer>{ 1, 2 })
 *     .doMap(pp_R.multiply.apply(2))
 *     .sum()
 *     .debug(); // 6
 * ```
 *
 * Functions in pp_R do not mutate the wrapped values
 *
 * Some function names are reserved keywords in Apex, so they are prefixed with 'do'
 *
 * For example, 'map' is changed to 'doMap', and 'join' to 'doJoin'
 */
public class pp_R {
    /**
     * Value contained in instance of pp_R
     * Preferred to be List<Object>, Set<String>, Map<String, Object> and String.
     */
    private Object val;

    /**
     * Construct instance of pp_R
     */
    private pp_R(Object val) {
        this.val = val;
    }

    /**
     * This is only for reflection
     * Please do not use this
     */
    public pp_R() {
        this(null);
    }

    /**
     * Factory function to create instance of pp_R
     *
     * Example:
     * ```
     * pp_R.of('message').size().debug(); // 7
     * ```
     *
     * @param val The raw value to be wrapped
     * @return pp_R
     */
    public static pp_R of(Object val) {
        return new pp_R(val);
    }

    /**
     * Factory function to create instance of pp_R(List)
     *
     * Example:
     * ```
     * pp_R.with(1).size().debug(); // 1
     * ```
     *
     * @param arg The first element
     * @return pp_R
     */
    public static pp_R with(Object arg) {
        return pp_R.of(new List<Object>{
                arg
        });
    }

    /**
     * Factory function to create instance of pp_R(List)
     *
     * Example:
     * ```
     * pp_R.with(1, 2).size().debug(); // 2
     * ```
     *
     * @param arg1 The first element
     * @param arg2 The second element
     * @return pp_R
     */
    public static pp_R with(Object arg1, Object arg2) {
        return pp_R.of(new List<Object>{
                arg1, arg2
        });
    }

    /**
     * Factory function to create instance of pp_R(List)
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).size().debug(); // 3
     * ```
     *
     * @param arg1 The first element
     * @param arg2 The second element
     * @param arg3 The third element
     * @return pp_R
     */
    public static pp_R with(Object arg1, Object arg2, Object arg3) {
        return pp_R.of(new List<Object>{
                arg1, arg2, arg3
        });
    }

    /**
     * Factory function to create instance of pp_R(Map)
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').size().debug(); // 1
     * ```
     *
     * @param arg1 The key
     * @param arg2 The value
     * @return pp_R
     */
    public static pp_R withObj(Object arg1, Object arg2) {
        return pp_R.of(new Map<String, Object>{
                toString(arg1) => arg2
        });
    }

    /**
     * Factory function to create instance of pp_R(empty list)
     *
     * Example:
     * ```
     * pp_R.emptyList().size().debug(); // 0
     * ```
     *
     * @return pp_R
     */
    public static pp_R emptyList() {
        return pp_R.of(EMPTY_LIST);
    }

    /**
     * Factory function to create instance of pp_R(empty set)
     *
     * Example:
     * ```
     * pp_R.emptySet().size().debug(); // 0
     * ```
     *
     * @return pp_R
     */
    public static pp_R emptySet() {
        return pp_R.of(EMPTY_SET);
    }

    /**
     * Factory function to create instance of pp_R(empty set)
     *
     * Example:
     * ```
     * pp_R.emptySet().size().debug(); // 0
     * ```
     *
     * @return pp_R
     */
    public static pp_R emptyMap() {
        return pp_R.of(EMPTY_MAP);
    }

    /**
     * Factory function to create instance of pp_R(empty string)
     *
     * Example:
     * ```
     * pp_R.emptyString().size().debug(); // 0
     * ```
     *
     * @return pp_R
     */
    public static pp_R emptyString() {
        return pp_R.of(EMPTY_STRING);
    }

    /**
     * Factory function to create instance of pp_R(list of decimals in range)
     *
     * Example:
     * ```
     * pp_R.range(1, 3).debug(); // (1, 2)
     * ```
     *
     * @param first The starting decimal(inclusive)
     * @param last The ending decimal(exclusive)
     * @return pp_R
     */
    public static pp_R range(Decimal first, Decimal last) {
        return pp_R.of(pp_R.range.run(first, last));
    }

    /**
     * Extract wrapped value
     *
     * Example:
     * ```
     * pp_R.of('abc').toObject(); // 'abc'
     * ```
     *
     * @return pp_R
     */
    public Object toObject() {
        return this.val;
    }

    /**
     * Check if the wrapped value is an instance of List<Object>
     *
     * Example:
     * ```
     * pp_R.emptyList().isList(); // true
     * ```
     *
     * @return True if the wrapped value is an instance of List<Object>, otherwise false
     */
    public Boolean isList() {
        return this.val instanceof List<Object>;
    }

    /**
     * Convert the wrapped value to List<Object>
     *
     * Example:
     * ```
     * pp_R.emptyList().toList(); // ()
     * ```
     *
     * @return wrapped List<Object>
     */
    public List<Object> toList() {
        return (List<Object>) this.val;
    }

    /**
     * Check if wrapped value is an instance of Set<String>
     *
     * Example:
     * ```
     * pp_R.emptySet().isSet(); // true
     * ```
     *
     * @return True if the wrapped value is an instance of Set<String>, otherwise false
     */
    public Boolean isSet() {
        return this.val instanceof Set<String>;
    }

    /**
     * Convert the wrapped value to Set<String>
     *
     * Example:
     * ```
     * pp_R.emptySet().toSet(); // {}
     * ```
     *
     * @return instance of Set<String>
     */
    public Set<String> toSet() {
        return (Set<String>) toSet.run(this.val);
    }

    /**
     * Convert the wrapped value to Set<Id>
     *
     * Example:
     * ```
     * pp_R.emptySet().toIdSet(); // {}
     * ```
     *
     * @return instance of Set<Id>
     */
    public Set<Id> toIdSet() {
        return (Set<Id>) toIdSet.run(this.val);
    }

    /**
     * Check if the wrapped value is an instance of Map<String, Object>
     *
     * Example:
     * ```
     * pp_R.emptyMap().isMap(); // true
     * ```
     *
     * @return True if the wrapped value is an instance of Map<String, Object>, otherwise false
     */
    public Boolean isMap() {
        return this.val instanceof Map<String, Object>;
    }

    /**
     * Convert wrapped value to instance of Map<String, Object>
     *
     * Example:
     * ```
     * pp_R.emptyMap().toMap(); // {}
     * ```
     *
     * @return instance of Map<String, Object>
     */
    public Map<String, Object> toMap() {
        return (Map<String, Object>) this.val;

    }

    /**
     * Convert wrapped value to List<Map<String, Object>>
     *
     * @return List<Map<String, Object>>
     */
    public List<Map<String, Object>> toMapList() {
        return (List<Map<String, Object>>) pp_R.toMapList.run(this.val);
    }

    /**
     * Print debug information
     *
     * Example:
     * ```
     * pp_R.with(1, 2).debug(); // (1, 2)
     * ```
     *
     * @return same instance of pp_R
     */
    public pp_R debug() {
        pp_R.debug.run(this.val);
        return this;
    }

    /**
     * Check if the wrapped values are equal
     *
     * Example:
     * ```
     * pp_R.emptyList().equals(pp_R.emptyList()); // true
     * ```
     *
     * @param other The other object
     * @return True only when the two pp_R contain wrapped values that are equal
     */
    public Boolean equals(Object other) {
        return other instanceof pp_R && (Boolean) pp_R.equals.run(this.val, ((pp_R) other).val);
    }

    /**
     * Get the hash code
     *
     * Example:
     * ```
     * pp_R.emptyList().hashCode(); // 1
     * ```
     *
     * @return The hash code of the wrapped value
     */
    public Integer hashCode() {
        return this.val.hashCode();
    }

    /**
     * Convert the wrapped value to List<SObject>
     *
     * Example:
     * ```
     * pp_R.with(new Account()).toSObjectList(); // (Account:{})
     * ```
     *
     * @return List of SObject
     */
    public List<SObject> toSObjectList() {
        return (List<SObject>) pp_R.toSObjectList.run(this.val);
    }

    /**
     * Convert the wrapped value to Map<String, SObject>
     *
     * Example:
     * ```
     * pp_R.withObj('acc', new Account()).toSObjectMap(); // {acc=Account:{}}
     * ```
     *
     * @return Map of String SObject
     */
    public Map<String, SObject> toSObjectMap() {
        return (Map<String, SObject>) pp_R.toSObjectMap.run(this.val);
    }

    /**
     * Convert the wrapped value to SObject
     *
     * Example:
     * ```
     * pp_R.of(new Account()).toSObject(); // Account:{}
     * ```
     *
     * @return SObject
     */
    public SObject toSObject() {
        return (SObject) pp_R.toSObject.run(this.val);
    }

    /**
     * Convert wrapped value to List<Integer>
     *
     * Example:
     * ```
     * pp_R.with(1, 2).toIntegerList(); // (1, 2)
     * ```
     *
     * @return Integer list
     */
    public List<Integer> toIntegerList() {
        return (List<Integer>) pp_R.toIntegerList.run(this.val);
    }

    /**
     * Convert wrapped value to Map<String, Integer>
     *
     * Example:
     * ```
     * pp_R.withObj('name', 3).toIntegerMap(); // {name=3}
     * ```
     *
     * @return Map of string integer
     */
    public Map<String, Integer> toIntegerMap() {
        return (Map<String, Integer>) pp_R.toIntegerMap.run(this.val);
    }

    /**
     * Convert wrapped value to integer
     *
     * Example:
     * ```
     * pp_R.of(3).toInteger(); // 3
     * ```
     *
     * @return integer
     */
    public Integer toInteger() {
        return (Integer) pp_R.toInteger.run(this.val);
    }

    /**
     * Convert wrapped value to long list
     *
     * Example:
     * ```
     * pp_R.with(1, 2).toLongList(); // (1, 2)
     * ```
     *
     * @return list of Long
     */
    public List<Long> toLongList() {
        return (List<Long>) pp_R.toLongList.run(this.val);
    }

    /**
     * Convert wrapped value to Map<String, Long>
     *
     * Example:
     * ```
     * pp_R.withObj('name', 2).toLongMap(); // {name=2}
     * ```
     *
     * @return Map<String, Long>
     */
    public Map<String, Long> toLongMap() {
        return (Map<String, Long>) pp_R.toLongMap.run(this.val);
    }

    /**
     * Convert wrapped value to long
     *
     * Example:
     * ```
     * pp_R.of(3).toLong(); // 3
     * ```
     *
     * @return Long
     */
    public Long toLong() {
        return (Long) pp_R.toLong.run(this.val);
    }

    /**
     * Convert wrapped value to List<Decimal>
     *
     * Example:
     * ```
     * pp_R.with(1.5, 3).toDecimalList(); // (1.5, 3)
     * ```
     *
     * @return List<Decimal>
     */
    public List<Decimal> toDecimalList() {
        return (List<Decimal>) pp_R.toDecimalList.run(this.val);
    }

    /**
     * Convert wrapped value to Map<String, Decimal>
     *
     * Example:
     * ```
     * pp_R.withObj('name', 3).toDecimalMap(); // {name=3}
     * ```
     *
     * @return Map<String, Decimal>
     */
    public Map<String, Decimal> toDecimalMap() {
        return (Map<String, Decimal>) pp_R.toDecimalMap.run(this.val);
    }

    /**
     * Convert wrapped value to Decimal
     *
     * Example:
     * ```
     * pp_R.of(3).toDecimal(); // 3
     * ```
     *
     * @return Decimal
     */
    public Decimal toDecimal() {
        return (Decimal) pp_R.toDecimal.run(this.val);
    }

    /**
     * Convert wrapped value to List<Double>
     *
     * Example:
     * ```
     * pp_R.with(1.1, 1.2).toDoubleList(); // (1.1, 1.2)
     * ```
     *
     * @return List<Double>
     */
    public List<Double> toDoubleList() {
        return (List<Double>) pp_R.toDoubleList.run(this.val);
    }

    /**
     * Convert wrapped valut to Map<String, Double>
     *
     * Example:
     * ```
     * pp_R.withObj('weight', 3.2).toDoubleMap(); // {weight=3.2}
     * ```
     *
     * @return Map<String, Double>
     */
    public Map<String, Double> toDoubleMap() {
        return (Map<String, Double>) pp_R.toDoubleMap.run(this.val);
    }

    /**
     * Convert wrapped value to Double
     *
     * Example:
     * ```
     * pp_R.of(1.5).toDouble(); // 1.5
     * ```
     *
     * @return Double
     */
    public Double toDouble() {
        return (Double) pp_R.toDouble.run(this.val);
    }

    /**
     * Convert wrapped value to List<String>
     *
     * Example:
     * ```
     * pp_R.with('a', 'b').toStringList(); // (a, b)
     * ```
     *
     * @return List<String>
     */
    public List<String> toStringList() {
        return (List<String>) pp_R.toStringList.run(this.val);
    }

    /**
     * Convert wrapped value to Map<String, String>
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').toStringMap(); // {name=test}
     * ```
     *
     * @return Map<String, String>
     */
    public Map<String, String> toStringMap() {
        return (Map<String, String>) pp_R.toStringMap.run(this.val);
    }

    /**
     * Check if the wrapped value is string
     *
     * Example:
     * ```
     * pp_R.of('abc').isString(); // true
     * ```
     *
     * @return True if the wrapped value is string
     */
    public Boolean isString() {
        return this.val instanceof String;
    }

    /**
     * Convert wrapped value to string
     *
     * Example:
     * ```
     * pp_R.of('abc').toString(); // abc
     * ```
     *
     * @return String representation
     */
    public override String toString() {
        return String.valueOf(this.val);
    }

    /**
     * Convert wrapped value to List<Boolean>
     *
     * Example:
     * ```
     * pp_R.with(true, false).toBooleanList(); // (true, false)
     * ```
     *
     * @return List<Boolean>
     */
    public List<Boolean> toBooleanList() {
        return (List<Boolean>) pp_R.toBooleanList.run(this.val);
    }

    /**
     * Convert wrapped value of Map<String, Boolean>
     *
     * Example:
     * ```
     * pp_R.withObj('disabled', false).toBooleanMap(); // {disabled=false}
     * ```
     *
     * @return Map<String, Boolean>
     */
    public Map<String, Boolean> toBooleanMap() {
        return (Map<String, Boolean>) pp_R.toBooleanMap.run(this.val);
    }

    /**
     * Convert wrapped value to Boolean
     *
     * Example:
     * ```
     * pp_R.of(true).toBoolean(); // true
     * ```
     *
     * @return Boolean
     */
    public Boolean toBoolean() {
        return (Boolean) pp_R.toBoolean.run(this.val);
    }

    /**
     * Convert wrapped value to List<Date>
     *
     * Example:
     * ```
     * pp_R.with(Date.newInstance(2018, 1, 1)).toDateList(); // (2018-01-01 00:00:00)
     * ```
     *
     * @return List<Date>
     */
    public List<Date> toDateList() {
        return (List<Date>) pp_R.toDateList.run(this.val);
    }

    /**
     * Convert wrapped value to Map<String, Date>
     *
     * Example:
     * ```
     * pp_R.withObj('created', Date.newInstance(2018, 1, 1)).toDateMap(); // {created=2018-01-01 00:00:00}
     * ```
     *
     * @return Map<String, Date>
     */
    public Map<String, Date> toDateMap() {
        return (Map<String, Date>) pp_R.toDateMap.run(this.val);
    }

    /**
     * Convert wrapped value to Date
     *
     * Example:
     * ```
     * pp_R.of(Date.newInstance(2018, 1, 1)).toDate(); // 2018-01-01 00:00:00
     * ```
     *
     * @return Date
     */
    public Date toDate() {
        return (Date) pp_R.toDate.run(this.val);
    }

    /**
     * Convert wrapped value to List<Time>
     *
     * Example:
     * ```
     * pp_R.with(Time.newInstance(8, 0, 0, 0)).toTimeList(); // (08:00:00.000Z)
     * ```
     *
     * @return List<Time>
     */
    public List<Time> toTimeList() {
        return (List<Time>) pp_R.toTimeList.run(this.val);
    }

    /**
     * Convert wrapped value to Time
     *
     * Example:
     * ```
     * pp_R.of(Time.newInstance(8, 0, 0, 0)).toTime(); // 08:00:00.000Z
     * ```
     *
     * @return Time
     */
    public Time toTime() {
        return (Time) pp_R.toTime.run(this.val);
    }

    /**
     * Convert wrapped value to Map<String, Time>
     *
     * Example:
     * ```
     * pp_R.withObj('time', Time.newInstance(8, 0, 0, 0)).toTimeMap(); // {time=08:00:00.000Z}
     * ```
     *
     * @return Map<String, Time>
     */
    public Map<String, Time> toTimeMap() {
        return (Map<String, Time>) pp_R.toTimeMap.run(this.val);
    }

    /**
     * Convert wrapped value to List<Datetime>
     *
     * Example:
     * ```
     * pp_R.with(Datetime.now()).toDatetimeList(); // (2018-04-25 04:43:37)
     * ```
     *
     * @return List<Datetime>
     */
    public List<Datetime> toDatetimeList() {
        return (List<Datetime>) pp_R.toDatetimeList.run(this.val);
    }

    /**
     * Convert wrapped value to Map<String, Datetime>
     *
     * Example:
     * ```
     * pp_R.withObj('timestamp', Datetime.now()).toDatetimeMap(); // {timestamp=2018-04-25 04:44:24}
     * ```
     *
     * @return Map<String, Datetime>
     */
    public Map<String, Datetime> toDatetimeMap() {
        return (Map<String, Datetime>) pp_R.toDatetimeMap.run(this.val);
    }

    /**
     * Convert wrapped value to Datetime
     *
     * Example:
     * ```
     * pp_R.of(Datetime.now()).toDatetime(); // 2018-04-25 04:45:28
     * ```
     *
     * @return Datetime
     */
    public Datetime toDatetime() {
        return (Datetime) pp_R.toDatetime.run(this.val);
    }

    /**
     * Convert wrapped value to List<pp_Func>
     *
     * Example:
     * ```
     * pp_R.with(pp_R.identity).toFuncList(); // (IdentityFunc:[Func.args=(), pp_Func.length=-1])
     * ```
     *
     * @return List<pp_Func>
     */
    public List<pp_Func> toFuncList() {
        return (List<pp_Func>) pp_R.toFuncList.run(this.val);
    }

    /**
     * Convert wrapped value to Map<String, pp_Func>
     *
     * Example:
     * ```
     * pp_R.withObj('id', pp_R.identity).toFuncMap(); // {id=IdentityFunc:[Func.args=(), pp_Func.length=-1]}
     * ```
     *
     * @return Map<String, pp_Func>
     */
    public Map<String, pp_Func> toFuncMap() {
        return (Map<String, pp_Func>) pp_R.toFuncMap.run(this.val);
    }

    /**
     * Convert wrapped value to Func
     *
     * Example:
     * ```
     * pp_R.of(pp_R.identity).toFunc(); // IdentityFunc:[Func.args=(), pp_Func.length=-1]
     * ```
     *
     * @return Func
     */
    public pp_Func toFunc() {
        return (pp_Func) pp_R.toFunc.run(this.val);
    }

    /**
     * Convert wrapped value to List<pp_R.Pair>
     *
     * Example:
     * ```
     * pp_R.with(new pp_R.Pair(1, 2)).toPairList(); // (Pair:[fst=1, snd=2])
     * ```
     *
     * @return List<pp_R.Pair>
     */
    public List<Pair> toPairList() {
        return (List<Pair>) pp_R.toPairList.run(this.val);
    }

    /**
     * Convert wrapped value to Map<String, pp_R.Pair>
     *
     * Example:
     * ```
     * pp_R.withObj('pair', new pp_R.Pair(1, 2)).toPairMap(); // {pair=Pair:[fst=1, snd=2]}
     * ```
     *
     * @return Map<String, pp_R.Pair>
     */
    public Map<String, pp_R.Pair> toPairMap() {
        return (Map<String, pp_R.Pair>) pp_R.toPairMap.run(this.val);
    }

    /**
     * Convert wrapped value to Pair
     *
     * Example:
     * ```
     * pp_R.of(new pp_R.Pair(1, 2)).toPair(); // Pair:[fst=1, snd=2]
     * ```
     *
     * @return Pair
     */
    public Pair toPair() {
        return (Pair) pp_R.toPair.run(this.val);
    }

    /**
     * Call the function to each element of instance R
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).forEach(pp_R.debug);
     * // 1
     * // 2
     * // 3
     *
     * pp_R.withObj('name', 'test').forEach(pp_R.debug);
     * // (test, name)
     * ```
     *
     * @param fn The function to invoke on each element
     * @return pp_R
     */
    public pp_R forEach(pp_Func fn) {
        return pp_R.of(pp_R.forEach.run(fn, this.val));
    }

    /**
     * Call the function to filter the elements of instance R
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).filter(pp_R.equals.apply(2)).debug(); // (2)
     * ```
     *
     * @param pred The predicate: a -> Boolean
     * @return pp_R
     */
    public pp_R filter(pp_Func pred) {
        return pp_R.of(pp_R.filter.run(pred, this.val));
    }

    /**
     * Filter the list by checking that each element of the list has a non null value of this field
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description = 'desc'), new Account()).filter('Description').debug(); // (Account:{Description=desc})
     * ```
     *
     * @param field The field name of the element to be filtered
     * @return pp_R
     */
    public pp_R filter(String field) {
        return pp_R.of(pp_R.filter.run(field, this.val));
    }

    /**
     * Filter the list by checking that each element has the value matched by the field
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description = 'desc'), new Account()).filter('Description', 'desc').debug(); // (Account:{Description=desc})
     * ```
     *
     * @param field The field name of the element to be filtered
     * @param value The field value of the element to be filtered
     * @return pp_R
     */
    public pp_R filter(String field, Object value) {
        return pp_R.of(pp_R.filter.run(field, value, this.val));
    }

    /**
     * Filter the list by checking that each element matches the field-value specified in the data
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description = 'desc'), new Account()).filter(new Map<String, Object>{ 'Description' => 'desc' }).debug();
     * // (Account:{Description=desc})
     * ```
     *
     * @param data The field-value criteria
     * @return pp_R
     */
    public pp_R filter(Map<String, Object> data) {
        return pp_R.of(pp_R.filter.run(data, this.val));
    }

    /**
     * Reject the elements by checking with the predicate
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description = 'desc'), new Account()).reject((pp_Func)pp_R.complement.run(pp_R.has.apply('Description'))).debug();
     * // (Account:{Description=desc})
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R reject(pp_Func pred) {
        return pp_R.of(pp_R.reject.run(pred, this.val));
    }

    /**
     * Reject the elements that has the specified field
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description = 'desc'), new Account()).reject('Description').debug();
     * // (Account:{})
     * ```
     *
     * @param field The field name to reject
     * @return pp_R
     */
    public pp_R reject(String field) {
        return pp_R.of(pp_R.reject.run(field, this.val));
    }

    /**
     * Reject elements that equal with the value specified by the field
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description = 'desc'), new Account()).reject('Description', 'desc').debug();
     * // (Account:{})
     * ```
     *
     * @param field The name of the field
     * @param value The value of the field
     * @return pp_R
     */
    public pp_R reject(String field, Object value) {
        return pp_R.of(pp_R.reject.run(field, value, this.val));
    }

    /**
     * Reject elements that match the criteria data of field-value mappings
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description = 'desc'), new Account()).reject(new Map<String, Object>{ 'Description' => 'desc' }).debug();
     * // (Account:{})
     * ```
     *
     * @param data The field-value mapping criteria
     * @return pp_R
     */
    public pp_R reject(Map<String, Object> data) {
        return pp_R.of(pp_R.reject.run(data, this.val));
    }

    /**
     * Map a function over the elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).doMap(pp_R.add.apply(1)).debug(); // (2, 3, 4)
     * ```
     *
     * @param fn The function to be used in the map
     * @return pp_R
     */
    public pp_R doMap(pp_Func fn) {
        return pp_R.of(pp_R.doMap.run(fn, this.val));
    }

    /**
     * Extract the field out of the object to a new list
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description='desc')).pluck('Description').debug();
     * // (desc)
     * ```
     *
     * @param field The field to be plucked
     * @return pp_R
     */
    public pp_R pluck(String field) {
        return pp_R.of(pp_R.pluck.run(field, this.val));
    }

    /**
     * Reduce over the elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).reduce(pp_R.add, 0).debug(); // 6
     * ```
     *
     * @param reducer The reducing function which accepts two arguments
     * @param initialValue The initialValue in the reduction
     * @return pp_R
     */
    public pp_R reduce(pp_Func reducer, Object initialValue) {
        return pp_R.of(pp_R.reduce.run(reducer, initialValue, this.val));
    }

    /**
     * Get the length, same as size()
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).length().debug(); // 3
     * ```
     *
     * @return pp_R
     */
    public pp_R length() {
        return pp_R.of(((Decimal) pp_R.length.run(this.val)).intValue());
    }

    /**
     * Get the size, same as length()
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).size().debug(); // 3
     * ```
     *
     * @return pp_R
     */
    public pp_R size() {
        return pp_R.of(((Decimal) pp_R.size.run(this.val)).intValue());
    }

    /**
     * Check if it is empty
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).isEmpty().debug(); // false
     * ```
     *
     * @return pp_R
     */
    public pp_R isEmpty() {
        return pp_R.of((Boolean) pp_R.isEmpty.run(this.val));
    }

    /**
     * Check if it is empty
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).isNotEmpty().debug(); // true
     * ```
     *
     * @return pp_R
     */
    public pp_R isNotEmpty() {
        return pp_R.of((Boolean) pp_R.isNotEmpty.run(this.val));
    }

    /**
     * Get the sum
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).sum().debug(); // 6
     * ```
     *
     * @return pp_R
     */
    public pp_R sum() {
        return pp_R.of((Decimal) pp_R.sum.run(this.val));
    }

    /**
     * Get a slice of the elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).slice(1, 2).debug(); // (2)
     * ```
     *
     * @param first The first index(inclusive)
     * @param last The last index(exclusive)
     * @return pp_R
     */
    public pp_R slice(Integer first, Integer last) {
        return pp_R.of(pp_R.slice.run(first, last, this.val));
    }

    /**
     * Take the first N elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).take(2).debug(); // (1, 2)
     * ```
     *
     * @param num The number of elements to take
     * @return pp_R
     */
    public pp_R take(Integer num) {
        return pp_R.of(pp_R.take.run(num, this.val));
    }

    /**
     * Take the first N elements from right
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).takeRight(2).debug(); // (2, 3)
     * ```
     *
     * @param num The number of elements to take
     * @return pp_R
     */
    public pp_R takeRight(Integer num) {
        return pp_R.of(pp_R.takeRight.run(num, this.val));
    }

    /**
     * Take elements until the predicate is not satisfied
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).takeWhile(pp_R.equals.apply(1)).debug(); // (1)
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R takeWhile(pp_Func pred) {
        return pp_R.of(pp_R.takeWhile.run(pred, this.val));
    }

    /**
     * Take elements from right until the predicate is not satisfied
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).takeRightWhile(pp_R.equals.apply(1)).debug(); // ()
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R takeRightWhile(pp_Func pred) {
        return pp_R.of(pp_R.takeRightWhile.run(pred, this.val));
    }

    /**
     * Drop the first N elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).drop(2).debug(); // (3)
     * ```
     *
     * @param num The number of elements to drop
     * @return pp_R
     */
    public pp_R drop(Integer num) {
        return pp_R.of(pp_R.drop.run(num, this.val));
    }

    /**
     * Drop the first N elements from right
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).dropRight(2).debug(); // (1)
     * ```
     *
     * @param num The number of elements to drop
     * @return pp_R
     */
    public pp_R dropRight(Integer num) {
        return pp_R.of(pp_R.dropRight.run(num, this.val));
    }

    /**
     * Drop until the predicate is not satisfied
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).dropWhile(pp_R.equals.apply(1)).debug(); // (2, 3)
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R dropWhile(pp_Func pred) {
        return pp_R.of(pp_R.dropWhile.run(pred, this.val));
    }

    /**
     * Drop from right until the predicate is not satisfied
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).dropRightWhile(pp_R.equals.apply(1)).debug(); // (1, 2, 3)
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R dropRightWhile(pp_Func pred) {
        return pp_R.of(pp_R.dropRightWhile.run(pred, this.val));
    }

    /**
     * Reverse the elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).reverse().debug(); // (3, 2, 1)
     * ```
     *
     * @return pp_R
     */
    public pp_R reverse() {
        return pp_R.of(pp_R.reverse.run(this.val));
    }

    /**
     * Sort the elements by the comparator
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description='abc'), new Account(Description='def')).sortBy((pp_Func)pp_R.descend.run(pp_R.prop.apply('Description'))).debug();
     * // (Account:{Description=def}, Account:{Description=abc})
     * ```
     *
     * @param comparator The comparator function that takes two arguments and return a number
     * @return pp_R
     */
    public pp_R sortBy(pp_Func comparator) {
        return pp_R.of(pp_R.sortBy.run(comparator, this.val));
    }

    /**
     * Sort the elements by default
     *
     * Example:
     * ```
     * pp_R.with(3, 2, 1).sortDefault().debug(); // (1, 2, 3)
     * ```
     *
     * @return pp_R
     */
    public pp_R sortDefault() {
        return pp_R.of(pp_R.sortDefault.run(this.val));
    }

    /**
     * Check if the target is contained
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).contains(2).debug(); // true
     * ```
     *
     * @param target The target object
     * @return pp_R
     */
    public pp_R contains(Object target) {
        return pp_R.of((Boolean) pp_R.contains.run(target, this.val));
    }

    /**
     * Check if the target is contained by the predicate
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).containsBy(pp_R.equals, 2).debug(); // true
     * ```
     *
     * @param pred The predicate that takes two arguments and return boolean
     * @param target The target object
     * @return pp_R
     */
    public pp_R containsBy(pp_Func pred, Object target) {
        return pp_R.of((Boolean) pp_R.containsBy.run(pred, target, this.val));
    }

    /**
     * Check if the key is contained
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').containsKey('name').debug(); // true
     * ```
     *
     * @param key The key
     * @return pp_R
     */
    public pp_R containsKey(String key) {
        return pp_R.of((Boolean) pp_R.containsKey.run(key, this.val));
    }

    /**
     * Return unique elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 2).uniq().debug(); // (1, 2)
     * ```
     *
     * @return pp_R
     */
    public pp_R uniq() {
        return pp_R.of(pp_R.uniq.run(this.val));
    }

    /**
     * Do a union with the other object
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).union(pp_R.with(2, 3, 4)).debug(); // (1, 2, 3, 4)
     * ```
     *
     * @param other The other object
     * @return pp_R
     */
    public pp_R union(Object other) {
        return pp_R.of(pp_R.union.run(other, this.val));
    }

    /**
     * Do an intersection with the other object
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).intersection(pp_R.with(2, 3, 4)).debug(); // (2, 3)
     * ```
     *
     * @param other The other object
     * @return pp_R
     */
    public pp_R intersection(Object other) {
        return pp_R.of(pp_R.intersection.run(other, this.val));
    }

    /**
     * Do an xor with the other object
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).xor(pp_R.with(2, 3, 4)).debug(); // (1, 4)
     * ```
     *
     * @param other The other object
     * @return pp_R
     */
    public pp_R xor(Object other) {
        return pp_R.of(pp_R.xor.run(other, this.val));
    }

    /**
     * Do a difference with the other object
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).difference(pp_R.with(2, 3, 4)).debug(); // (1)
     * ```
     *
     * @param other The other object
     * @return pp_R
     */
    public pp_R difference(Object other) {
        return pp_R.of(pp_R.difference.run(other, this.val));
    }

    /**
     * Same as difference
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).without(pp_R.with(2, 3, 4)).debug(); // (1)
     * ```
     *
     * @param other The other object
     * @return pp_R
     */
    public pp_R without(Object other) {
        return pp_R.of(pp_R.without.run(other, this.val));
    }

    /**
     * Update the element at index with the function
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).adjust(pp_R.add.apply(1), 1).debug(); // (1, 3, 3)
     * ```
     *
     * @param fn The function to work on the element
     * @param index The index of the element
     * @return pp_R
     */
    public pp_R adjust(pp_Func fn, Integer index) {
        return pp_R.of(pp_R.adjust.run(fn, index, this.val));
    }

    /**
     * Check if all elements match the predicate
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).all(pp_R.equals.apply(1)).debug(); // false
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R all(pp_Func pred) {
        return pp_R.of((Boolean) pp_R.all.run(pred, this.val));
    }

    /**
     * Check if every element matches the predicate
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).every(pp_R.equals.apply(1)).debug(); // false
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R every(pp_Func pred) {
        return pp_R.of((Boolean) pp_R.every.run(pred, this.val));
    }

    /**
     * Check if some elements match the predicate
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).some(pp_R.equals.apply(1)).debug(); // true
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R some(pp_Func pred) {
        return pp_R.of((Boolean) pp_R.some.run(pred, this.val));
    }

    /**
     * Check if none of the elements matches the predicate
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).none(pp_R.equals.apply(1)).debug(); // false
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R none(pp_Func pred) {
        return pp_R.of((Boolean) pp_R.none.run(pred, this.val));
    }

    /**
     * Append the element to the elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).append(4).debug(); // (1, 2, 3, 4)
     * ```
     *
     * @param element The element
     * @return pp_R
     */
    public pp_R append(Object element) {
        return pp_R.of(pp_R.append.run(element, this.val));
    }

    /**
     * Prepend the element to the elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).prepend(4).debug(); // (4, 1, 2, 3)
     * ```
     *
     * @param element The element
     * @return pp_R
     */
    public pp_R prepend(Object element) {
        return pp_R.of(pp_R.prepend.run(element, this.val));
    }

    /**
     * Transform the wrapped value using the function
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).transform(pp_R.size).debug(); // 3
     * ```
     *
     * @param fn The transforming function
     * @return pp_R
     */
    public pp_R transform(pp_Func fn) {
        return pp_R.of(pp_R.transform.run(fn, this.val));
    }

    /**
     * Associate the value to the key
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'value').assoc('name', 'newValue').debug(); // {name=newValue}
     * ```
     *
     * @param field The field name
     * @param value The field value
     * @return pp_R
     */
    public pp_R assoc(Object field, Object value) {
        return pp_R.of(pp_R.assoc.run(field, value, this.val));
    }

    /**
     * Remove the value mapped by the key
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'value').dissoc('name').debug(); // {}
     * ```
     *
     * @param field The field name
     * @return pp_R
     */
    public pp_R dissoc(Object field) {
        return pp_R.of(pp_R.dissoc.run(field, this.val));
    }

    /**
     * Return a value that is limited between the min and the max
     *
     * Example:
     * ```
     * pp_R.of(4).clamp(1, 3).debug(); // 3
     * ```
     *
     * @param min The min value
     * @param max The max value
     * @return pp_R
     */
    public pp_R clamp(Object min, Object max) {
        return pp_R.of(pp_R.clamp.run(min, max, this.val));
    }

    /**
     * Get a clone
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).doClone().debug(); // (1, 2, 3)
     * ```
     *
     * @return pp_R
     */
    public pp_R doClone() {
        return pp_R.of(pp_R.doClone.run(this.val));
    }

    /**
     * Concatenate the other
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).concat(pp_R.with(4, 5, 6)).debug();
     * // (1, 2, 3, 4, 5, 6)
     * ```
     *
     * @param other The other
     * @return pp_R
     */
    public pp_R concat(Object other) {
        return pp_R.of(pp_R.concat.run(other, this.val));
    }

    /**
     * Get a result of count mapped by the key
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 2).countBy(pp_R.identity).debug();
     * // {1=1, 2=2}
     * ```
     *
     * @param fn The function to calculate the key
     * @return pp_R
     */
    public pp_R countBy(pp_Func fn) {
        return pp_R.of(pp_R.countBy.run(fn, this.val));
    }

    /**
     * Get groups mapped by the key
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 2).groupBy(pp_R.identity).debug();
     * // {1=(1), 2=(2, 2)}
     * ```
     *
     * @param fn The function to calculate the key
     * @return pp_R
     */
    public pp_R groupBy(pp_Func fn) {
        return pp_R.of(pp_R.groupBy.run(fn, this.val));
    }

    /**
     * Get object indexed by the key
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 2).indexBy(pp_R.identity).debug();
     * // {1=1, 2=2}
     * ```
     *
     * @param fn The function to calculate the key
     * @return pp_R
     */
    public pp_R indexBy(pp_Func fn) {
        return pp_R.of(pp_R.indexBy.run(fn, this.val));
    }

    /**
     * Get the default value
     *
     * Example:
     * ```
     * pp_R.of(null).defaultTo(3).debug(); // 3
     * ```
     *
     * @param val The default value
     * @return pp_R
     */
    public pp_R defaultTo(Object val) {
        return pp_R.of(pp_R.defaultTo.run(val, this.val));
    }

    /**
     * Check if the elements start with the value
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).startsWith(new List<Integer>{ 1, 2 }).debug(); // true
     * ```
     *
     * @param val The value
     * @return pp_R
     */
    public pp_R startsWith(Object val) {
        return pp_R.of(pp_R.startsWith.run(val, this.val));
    }

    /**
     * Check if the elements end with the value
     *
     * Example:
     * ```
     * pp_R.of('abc').endsWith('bc').debug(); // true
     * ```
     *
     * @param val The value
     * @return pp_R
     */
    public pp_R endsWith(Object val) {
        return pp_R.of(pp_R.endsWith.run(val, this.val));
    }

    /**
     * Apply the function to the value mapped by the same key and calculate the evolved object
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').evolve(new Map<String, Object>{ 'name' => pp_R.append.apply('more') }).debug();
     * // {name=testmore}
     * ```
     *
     * @param spec The map of functions(may nest other spec object) mapped by the key
     * @return pp_R
     */
    public pp_R evolve(Map<String, Object> spec) {
        return pp_R.of(pp_R.evolve.run(spec, this.val));
    }

    /**
     * Find the first element that satisfies the predicate
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).find(pp_R.equals.apply(2)).debug(); // 2
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R find(pp_Func pred) {
        return pp_R.of(pp_R.find.run(pred, this.val));
    }

    /**
     * Find the first element that satisfies the predicate from last
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).findLast(pp_R.equals.apply(2)).debug(); // 2
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R findLast(pp_Func pred) {
        return pp_R.of(pp_R.findLast.run(pred, this.val));
    }

    /**
     * Find the index of the first element that matches the predicate
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).findIndex(pp_R.equals.apply(2)).debug(); // 1
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R findIndex(pp_Func pred) {
        return pp_R.of(pp_R.findIndex.run(pred, this.val));
    }

    /**
     * Find the index of the first element that matches the predicate from last
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).findLastIndex(pp_R.equals.apply(2)).debug(); // 1
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R findLastIndex(pp_Func pred) {
        return pp_R.of(pp_R.findLastIndex.run(pred, this.val));
    }

    /**
     * Flatten the elements by one level
     *
     * Example:
     * ```
     * pp_R.with(1, new List<Object>{ 2, 3 }, 4).unnest().debug();
     * // (1, 2, 3, 4)
     * ```
     *
     * @return pp_R
     */
    public pp_R unnest() {
        return pp_R.of(pp_R.unnest.run(this.val));
    }

    /**
     * Flatten the elements recursively
     *
     * Example:
     * ```
     * pp_R.with(1, new List<Object>{ 2, new List<Object>{ 3 } }, 4).flatten().debug();
     * // (1, 2, 3, 4)
     * ```
     *
     * @return pp_R
     */
    public pp_R flatten() {
        return pp_R.of(pp_R.flatten.run(this.val));
    }

    /**
     * Convert from a list of pairs to a map
     *
     * Example:
     * ```
     * pp_R.with(new pp_R.Pair('name', 'test')).fromPairs().debug();
     * // {name=test}
     * ```
     *
     * @return pp_R
     */
    public pp_R fromPairs() {
        return pp_R.of(pp_R.fromPairs.run(this.val));
    }

    /**
     * Convert a map to a list of pairs
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').toPairs().debug();
     * // (Pair:[fst=name, snd=test])
     * ```
     *
     * @return pp_R
     */
    public pp_R toPairs() {
        return pp_R.of(pp_R.toPairs.run(this.val));
    }

    /**
     * Get the first element
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).first().debug(); // 1
     * ```
     *
     * @return pp_R
     */
    public pp_R first() {
        return pp_R.of(pp_R.first.run(this.val));
    }

    /**
     * Get the first element
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).head().debug(); // 1
     * ```
     *
     * @return pp_R
     */
    public pp_R head() {
        return pp_R.of(pp_R.head.run(this.val));
    }

    /**
     * Get the last element
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).last().debug(); // 3
     * ```
     *
     * @return pp_R
     */
    public pp_R last() {
        return pp_R.of(pp_R.last.run(this.val));
    }

    /**
     * Get the elements except the last
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).init().debug(); // (1, 2)
     * ```
     *
     * @return pp_R
     */
    public pp_R init() {
        return pp_R.of(pp_R.init.run(this.val));
    }

    /**
     * Get the elements except the first
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).tail().debug(); // (2, 3)
     * ```
     *
     * @return pp_R
     */
    public pp_R tail() {
        return pp_R.of(pp_R.tail.run(this.val));
    }

    /**
     * Get the index of the target
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).indexOf(2).debug(); // 1
     * ```
     *
     * @param target The target
     * @return pp_R
     */
    public pp_R indexOf(Object target) {
        return pp_R.of(pp_R.indexOf.run(target, this.val));
    }

    /**
     * Get the index of the target from the last
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).lastIndexOf(2).debug(); // 1
     * ```
     *
     * @param target The target
     * @return pp_R
     */
    public pp_R lastIndexOf(Object target) {
        return pp_R.of(pp_R.lastIndexOf.run(target, this.val));
    }

    /**
     * Insert the element at the index
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).doInsert(1, 'x').debug(); // (1, x, 2, 3)
     * ```
     *
     * @param index The index to be inserted at
     * @param target The target
     * @return pp_R
     */
    public pp_R doInsert(Integer index, Object target) {
        return pp_R.of(pp_R.doInsert.run(index, target, this.val));
    }

    /**
     * Insert all the elements at the index
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).doInsertAll(1, pp_R.with('x', 'y')).debug(); // (1, x, y, 2, 3)
     * ```
     *
     * @param index The index to be inserted on
     * @param target The target
     * @return pp_R
     */
    public pp_R doInsertAll(Integer index, Object target) {
        return pp_R.of(pp_R.doInsertAll.run(index, target, this.val));
    }

    /**
     * Get an inverted map, values mapped by duplicate keys are put in a list
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').invert().debug();
     * // {test=(name)}
     * ```
     *
     * @return pp_R
     */
    public pp_R invert() {
        return pp_R.of(pp_R.invert.run(this.val));
    }

    /**
     * Get an inverted map
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').invertObj().debug();
     * // {test=name}
     * ```
     *
     * @return pp_R
     */
    public pp_R invertObj() {
        return pp_R.of(pp_R.invertObj.run(this.val));
    }

    /**
     * Join the elements with the separator
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).doJoin('-').debug(); // 1-2-3
     * ```
     *
     * @param separator The separator string
     * @return pp_R
     */
    public pp_R doJoin(String separator) {
        return pp_R.of(pp_R.doJoin.run(separator, this.val));
    }

    /**
     * Get the keys of the wrapped map
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').keys().debug();
     * // {name}
     * ```
     *
     * @return pp_R
     */
    public pp_R keys() {
        return pp_R.of(pp_R.keys.run(this.val));
    }

    /**
     * Get the values of the wrapped map
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').values().debug();
     * // (test)
     * ```
     *
     * @return pp_R
     */
    public pp_R values() {
        return pp_R.of(pp_R.values.run(this.val));
    }

    /**
     * Get a list of matched groups after doing a regex match
     *
     * Example:
     * ```
     * pp_R.of('abc').match('.*(a).*').debug();
     * // (abc, a)
     * ```
     *
     * @param regex The regular expression
     * @return pp_R
     */
    public pp_R match(String regex) {
        return pp_R.of(pp_R.match.run(regex, this.val));
    }

    /**
     * Merge the source
     *
     * Example:
     * ```
     * pp_R.withObj('name', 'test').doMerge(pp_R.withObj('name', 'newTest')).debug();
     * // {name=newTest}
     * ```
     *
     * @param other The other
     * @return pp_R
     */
    public pp_R doMerge(Object other) {
        return pp_R.of(pp_R.doMerge.run(other, this.val));
    }

    /**
     * Get the nth element
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).nth(1).debug(); // 2
     * ```
     *
     * @param index The index
     * @return pp_R
     */
    public pp_R nth(Integer index) {
        return pp_R.of(pp_R.nth.run(index, this.val));
    }

    /**
     * Pick the values specified by the list of keys
     *
     * Example:
     * ```
     * pp_R.of(new Account(FirstName='test', Description='desc')).pick(new List<String>{ 'Description' }).debug();
     * // {Description=desc}
     * ```
     *
     * @param keys The list of keys
     * @return pp_R
     */
    public pp_R pick(Object keys) {
        return pp_R.of(pp_R.pick.run(keys, this.val));
    }

    /**
     * Omit the values specified by the list of keys
     *
     * Example:
     * ```
     * pp_R.of(new Account(FirstName='test', Description='desc')).omit(new List<String>{ 'Description' }).debug();
     * // {FirstName=test}
     * ```
     *
     * @param keys The list of keys
     * @return pp_R
     */
    public pp_R omit(Object keys) {
        return pp_R.of(pp_R.omit.run(keys, this.val));
    }

    /**
     * Create a paritioned pair using the predicate
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).partition(pp_R.equals.apply(1)).debug();
     * // Pair:[fst=(1), snd=(2, 3)]
     * ```
     *
     * @param pred The predicate
     * @return pp_R
     */
    public pp_R partition(pp_Func pred) {
        return pp_R.of(pp_R.partition.run(pred, this.val));
    }

    /**
     * Project a list of objects using the list of fields
     *
     * Example:
     * ```
     * pp_R.with(new Account(Description='desc', FirstName='test')).project(new List<String>{ 'Description' }).debug();
     * // ({Description=desc})
     * ```
     *
     * @param fields
     * @return pp_R
     */
    public pp_R project(Object fields) {
        return pp_R.of(pp_R.project.run(fields, this.val));
    }

    /**
     * Remove elements starting at the index and specified by the count
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).remove(1, 3).debug();
     * // (1)
     * ```
     *
     * @param first The index of the first element to be removed
     * @param count The count of the elements to be removed
     * @return pp_R
     */
    public pp_R remove(Integer first, Integer count) {
        return pp_R.of(pp_R.remove.run(first, count, this.val));
    }

    /**
     * Create a list of elements by repeating the element
     *
     * Example:
     * ```
     * pp_R.of('a').repeat(3).debug(); // (a, a, a)
     * ```
     *
     * @param count The count to repeat
     * @return pp_R
     */
    public pp_R repeat(Integer count) {
        return pp_R.of(pp_R.repeat.run(count, this.val));
    }

    /**
     * Replace the string according to the pattern and replacement
     *
     * Example:
     * ```
     * pp_R.of('I love cats').replace('cat', 'dog').debug();
     * // I love dogs
     * ```
     *
     * @param pattern The pattern
     * @param replacement The replacement string
     * @return pp_R
     */
    public pp_R replace(String pattern, String replacement) {
        return pp_R.of(pp_R.replace.run(pattern, replacement, this.val));
    }

    /**
     * Replace all the strings according to the pattern and replacement
     *
     * Example:
     * ```
     * pp_R.of('I love cats').replaceAll('cat', 'dog').debug();
     * // I love dogs
     * ```
     *
     * @param pattern The pattern
     * @param replacement The replacement string
     * @return pp_R
     */
    public pp_R replaceAll(String pattern, String replacement) {
        return pp_R.of(pp_R.replaceAll.run(pattern, replacement, this.val));
    }

    /**
     * Split the string by the separator
     *
     * Example:
     * ```
     * pp_R.of('a/b/c').split('/').debug();
     * // (a, b, c)
     * ```
     *
     * @param separator The separator string
     * @return pp_R
     */
    public pp_R split(String separator) {
        return pp_R.of(pp_R.split.run(separator, this.val));
    }

    /**
     * Test the string according to the pattern
     *
     * Example:
     * ```
     * pp_R.of('cat').test('.*b.*').debug(); // false
     * ```
     *
     * @param pattern The pattern string
     * @return pp_R
     */
    public pp_R test(String pattern) {
        return pp_R.of(pp_R.test.run(pattern, this.val));
    }

    /**
     * Convert the string to uppercase
     *
     * Example:
     * ```
     * pp_R.of('cat').toUpper().debug(); // CAT
     * ```
     *
     * @return pp_R
     */
    public pp_R toUpper() {
        return pp_R.of(pp_R.toUpper.run(this.val));
    }

    /**
     * Convert the string to lowercase
     *
     * Example:
     * ```
     * pp_R.of('Cat').toLower().debug(); // cat
     * ```
     *
     * @return pp_R
     */
    public pp_R toLower() {
        return pp_R.of(pp_R.toLower.run(this.val));
    }

    /**
     * Trim the string
     *
     * Example:
     * ```
     * pp_R.of('  a  ').trim().debug(); // a
     * ```
     *
     * @return pp_R
     */
    public pp_R trim() {
        return pp_R.of(pp_R.trim.run(this.val));
    }

    /**
     * Update the element at the specified index
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).doUpdate(1, 3).debug(); // (1, 3, 3)
     * ```
     *
     * @param index The index of the element to be updated
     * @param val The new value
     * @return pp_R
     */
    public pp_R doUpdate(Integer index, Object val) {
        return pp_R.of(pp_R.doUpdate.run(index, val, this.val));
    }

    /**
     * Create a zipped list of pairs according to the mList
     *
     * Example:
     * ```
     * pp_R.with('a', 'b').zip(new List<Object>{ 1, 2 }).debug();
     * // (Pair:[fst=1, snd=a], Pair:[fst=2, snd=b])
     * ```
     *
     * @param mList The other list
     * @return pp_R
     */
    public pp_R zip(Object mList) {
        return pp_R.of(pp_R.zip.run(mList, this.val));
    }

    /**
     * Create a zipped map according to the mList
     *
     * Example:
     * ```
     * pp_R.with('a', 'b').zipObj(new List<Object>{ 1, 2 }).debug();
     * // {1=a, 2=b}
     * ```
     *
     * @param mList The other list
     * @return pp_R
     */
    public pp_R zipObj(Object mList) {
        return pp_R.of(pp_R.zipObj.run(mList, this.val));
    }

    /**
     * Remove null values from the elements
     *
     * Example:
     * ```
     * pp_R.with('a', null, 0).compact().debug();
     * // (a, 0)
     * ```
     *
     * @return pp_R
     */
    public pp_R compact() {
        return pp_R.of(pp_R.compact.run(this.val));
    }

    /**
     * Create a shuffled list of elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).shuffle().debug(); // (3, 1, 2)
     * ```
     *
     * @return pp_R
     */
    public pp_R shuffle() {
        return pp_R.of(pp_R.shuffle.run(this.val));
    }

    /**
     * Get a random element
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).sample().debug(); // 3
     * ```
     *
     * @return pp_R
     */
    public pp_R sample() {
        return pp_R.of(pp_R.sample.run(this.val));
    }

    /**
     * Get a list of random elements
     *
     * Example:
     * ```
     * pp_R.with(1, 2, 3).sampleSize(2).debug(); // (3, 1)
     * ```
     *
     * @param size The size of the random elements
     * @return pp_R
     */
    public pp_R sampleSize(Integer size) {
        return pp_R.of(pp_R.sampleSize.run(size, this.val));
    }

    /**
     * Return a new string with the first letter in uppercase
     *
     * Example:
     * ```
     * pp_R.of('cat').capitalize().debug(); // Cat
     * ```
     *
     * @return pp_R
     */
    public pp_R capitalize() {
        return pp_R.of(pp_R.capitalize.run(this.val));
    }

    /**
     * Pad the string to the length
     *
     * Example:
     * ```
     * pp_R.of('cat').pad(5, '*').debug(); // *cat*
     * ```
     *
     * @param length The target length
     * @param fill The string used to fill
     * @return pp_R
     */
    public pp_R pad(Integer length, String fill) {
        return pp_R.of(pp_R.pad.run(length, fill, this.val));
    }

    /**
     * Pad the string to the length from the left
     *
     * Example:
     * ```
     * pp_R.of('cat').padLeft(5, '*').debug(); // **cat
     * ```
     *
     * @param length The target length
     * @param fill The string used to fill
     * @return pp_R
     */
    public pp_R padLeft(Integer length, String fill) {
        return pp_R.of(pp_R.padLeft.run(length, fill, this.val));
    }

    /**
     * Pad the string to the length from the right
     *
     * Example:
     * ```
     * pp_R.of('cat').padRight(5, '*').debug(); // cat**
     * ```
     *
     * @param length The target length
     * @param fill The string used to fill
     * @return pp_R
     */
    public pp_R padRight(Integer length, String fill) {
        return pp_R.of(pp_R.padRight.run(length, fill, this.val));
    }

    // EOR(End of pp_R)


    // ----------------------------------------------------------------------------
    // --   Conversion                                                           --
    // ----------------------------------------------------------------------------

    // Boolean

    /**
     * Convert to Boolean
     *
     * Example:
     * ```
     * pp_R.toBoolean.run('abc')
     * // false
     * ```
     *
     * @param arg The target object
     * @return Object(Boolean)
     */
    public static pp_Func toBoolean = new ToBooleanFunc();

    /**
     * Convert to Boolean List
     *
     * Example:
     * ```
     * pp_R.toBooleanList.run(new List<Object>{ true, false })
     * // (true, false)
     * ```
     *
     * @param arg The target object
     * @return Object(List<Boolean>)
     */
    public static pp_Func toBooleanList = new ToBooleanListFunc();

    /**
     * Convert to Boolean Map
     *
     * Example:
     * ```
     * pp_R.toBooleanMap.run(new Map<String, Object>{ 'name' => true })
     * // {name=true}
     * ```
     *
     * @param arg The target object
     * @return Object(Map<String, Boolean>)
     */
    public static pp_Func toBooleanMap = new ToBooleanMapFunc();

    // Integer

    /**
     * Convert to Integer
     *
     * Example:
     * ```
     * pp_R.toInteger.run('1')
     * // 1
     * ```
     *
     * @param arg The raw object
     * @return Object(Integer)
     */
    public static pp_Func toInteger = new ToIntegerFunc();

    /**
     * Convert to Integer List
     *
     * Example:
     * ```
     * pp_R.toIntegerList.run(new List<Object>{ '1' })
     * // (1)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<Integer>)
     */
    public static pp_Func toIntegerList = new ToIntegerListFunc();

    /**
     * Convert to Integer Map
     *
     * Example:
     * ```
     * pp_R.toIntegerMap.run(new Map<String, Object>{ 'name' => '2' })
     * // {name=2}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, Integer>)
     */
    public static pp_Func toIntegerMap = new ToIntegerMapFunc();

    // Long

    /**
     * Convert to Long
     *
     * Example:
     * ```
     * pp_R.toLong.run('1')
     * // 1
     * ```
     *
     * @param arg The raw object
     * @return Object(Long)
     */
    public static pp_Func toLong = new ToLongFunc();

    /**
     * Convert to Long List
     *
     * Example:
     * ```
     * pp_R.toLongList.run(new List<Object>{ '1' })
     * // (1)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<Long>)
     */
    public static pp_Func toLongList = new ToLongListFunc();

    /**
     * Convert to Long Map
     *
     * Example:
     * ```
     * pp_R.toLongMap.run(new Map<String, Object>{ 'name' => '2' })
     * // {name=2}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, Long>)
     */
    public static pp_Func toLongMap = new ToLongMapFunc();

    // Double

    /**
     * Convert to Double
     *
     * Example:
     * ```
     * pp_R.toDouble.run('1.5')
     * // 1.5
     * ```
     *
     * @param arg The raw object
     * @return Object(Double)
     */
    public static pp_Func toDouble = new ToDoubleFunc();

    /**
     * Convert to Double List
     *
     * Example:
     * ```
     * pp_R.toDoubleList.run(new List<Object>{ '1.5' })
     * // (1.5)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<Double>)
     */
    public static pp_Func toDoubleList = new ToDoubleListFunc();

    /**
     * Convert to Double Map
     *
     * Example:
     * ```
     * pp_R.toDoubleMap.run(new Map<String, Object>{ 'name' => '1.5' })
     * // {name=1.5}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, Double>)
     */
    public static pp_Func toDoubleMap = new ToDoubleMapFunc();

    // Decimal

    /**
     * Convert to Decimal
     *
     * Example:
     * ```
     * pp_R.toDecimal.run(2)
     * // 2
     * ```
     *
     * @param arg The raw object
     * @return Object(Decimal)
     */
    public static pp_Func toDecimal = new ToDecimalFunc();

    /**
     * Convert to Decimal List
     *
     * Example:
     * ```
     * pp_R.toDecimalList.run(new List<Object> { 2 })
     * // (2)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<Decimal>)
     */
    public static pp_Func toDecimalList = new ToDecimalListFunc();

    /**
     * Convert to Decimal Map
     *
     * Example:
     * ```
     * pp_R.toDecimalMap.run(new Map<String, Object>{ 'name' => 3 })
     * // {name=3}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, Decimal>)
     */
    public static pp_Func toDecimalMap = new ToDecimalMapFunc();

    // String

    /**
     * Convert to String
     *
     * Example:
     * ```
     * pp_R.toString.run('abc')
     * // abc
     * ```
     *
     * @param arg The raw object
     * @return Object(String)
     */
    public static pp_Func toString = new ToStringFunc();

    /**
     * Check if it can be converted to String
     *
     * Example:
     * ```
     * pp_R.isStringLike.run('abc')
     * // true
     * ```
     *
     * @param arg The raw object
     * @return Object(Boolean)
     */
    public static pp_Func isStringLike = new IsStringLikeFunc();

    /**
     * Convert to String List
     *
     * Example:
     * ```
     * pp_R.toStringList.run(new List<Object>{ 1, 2 })
     * // (1, 2)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<String>)
     */
    public static pp_Func toStringList = new ToStringListFunc();

    /**
     * Convert to String Map
     *
     * Example:
     * ```
     * pp_R.toStringMap.run(new Map<String, Object>{ 'name' => 2 })
     * // {name=2}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, String>)
     */
    public static pp_Func toStringMap = new ToStringMapFunc();

    /**
     * Convert to List of Chars
     *
     * Example:
     * ```
     * pp_R.toCharList.run('abc')
     * // (a, b, c)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<String>)
     */
    public static pp_Func toCharList = new ToCharListFunc();

    // Date & Time

    /**
     * Convert to Date
     *
     * Example:
     * ```
     * pp_R.toDate.run(Date.newInstance(2018, 1, 1))
     * // 2018-01-01 00:00:00
     * ```
     *
     * @param arg The raw object
     * @return Object(Date)
     */
    public static pp_Func toDate = new ToDateFunc();

    /**
     * Convert to Date List
     *
     * Example:
     * ```
     * pp_R.toDateList.run(new List<Object>{ Date.newInstance(2018, 1, 1)})
     * // (2018-01-01 00:00:00)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<Date>)
     */
    public static pp_Func toDateList = new ToDateListFunc();

    /**
     * Convert to Date Map
     *
     * Example:
     * ```
     * pp_R.toDateMap.run(new Map<String, Object>{ 'date' => Date.newInstance(2018, 1, 1)})
     * // {date=2018-01-01 00:00:00}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, Date>)
     */
    public static pp_Func toDateMap = new ToDateMapFunc();

    /**
     * Convert to Time
     *
     * Example:
     * ```
     * pp_R.toTime.run(Time.newInstance(8, 0, 0, 0))
     * // 08:00:00.000Z
     * ```
     *
     * @param arg The raw object
     * @return Object(Time)
     */
    public static pp_Func toTime = new ToTimeFunc();

    /**
     * Convert to Time List
     *
     * Example:
     * ```
     * pp_R.toTimeList.run(new List<Object>{ Time.newInstance(8, 0, 0, 0) })
     * // (08:00:00.000Z)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<Time>)
     */
    public static pp_Func toTimeList = new ToTimeListFunc();

    /**
     * Convert to Time Map
     *
     * Example:
     * ```
     * pp_R.toTimeMap.run(new Map<String, Object>{ 'time' => Time.newInstance(8, 0, 0, 0) })
     * // {time=08:00:00.000Z}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, Time>)
     */
    public static pp_Func toTimeMap = new ToTimeMapFunc();

    /**
     * Convert to Datetime
     *
     * Example:
     * ```
     * pp_R.toDatetime.run(Datetime.now())
     * // 2018-04-25 23:29:43
     * ```
     *
     * @param arg The raw object
     * @return Object(Datetime)
     */
    public static pp_Func toDatetime = new ToDatetimeFunc();

    /**
     * Convert to Datetime List
     *
     * Example:
     * ```
     * pp_R.toDatetimeList.run(new List<Object>{ Datetime.now() })
     * // (2018-04-25 23:30:24)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<Datetime>)
     */
    public static pp_Func toDatetimeList = new ToDatetimeListFunc();

    /**
     * Convert to Datetime Map
     *
     * Example:
     * ```
     * pp_R.toDatetimeMap.run(new Map<String, Object>{ 'datetime' => Datetime.now() })
     * // {datetime=2018-04-25 23:35:27}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, Datetime>)
     */
    public static pp_Func toDatetimeMap = new ToDatetimeMapFunc();

    // Func

    /**
     * Convert to Func
     *
     * Example:
     * ```
     * pp_R.toFunc.run(pp_R.identity)
     * // IdentityFunc:[Func.args=(), pp_Func.length=-1]
     * ```
     *
     * @param arg The raw object
     * @return Object(pp_Func)
     */
    public static pp_Func toFunc = new ToFuncFunc();

    /**
     * Check if it can be converted to Func
     *
     * Example:
     * ```
     * pp_R.isFuncLike.run(pp_R.identity)
     * // true
     * ```
     *
     * @param arg The raw object
     * @return Object(Boolean)
     */
    public static pp_Func isFuncLike = new IsFuncLikeFunc();

    /**
     * Convert to pp_Func List
     *
     * Example:
     * ```
     * pp_R.toFuncList.run(new List<Object>{ pp_R.identity })
     * // (IdentityFunc:[Func.args=(), pp_Func.length=-1])
     * ```
     *
     * @param arg The raw object
     * @return Object(List<pp_Func>)
     */
    public static pp_Func toFuncList = new ToFuncListFunc();

    /**
     * Convert to pp_Func Map
     *
     * Example:
     * ```
     * pp_R.toFuncMap.run(new Map<String, Object>{ 'func' => pp_R.identity })
     * // {func=IdentityFunc:[Func.args=(), pp_Func.length=-1]}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, pp_Func>)
     */
    public static pp_Func toFuncMap = new ToFuncMapFunc();

    // List

    /**
     * Convert to List
     *
     * Example:
     * ```
     * pp_R.toList.run(pp_R.with(1, 2, 3))
     * // (1, 2, 3)
     * ```
     *
     * @param arg The raw object
     * @return Object(List<Object>)
     */
    public static pp_Func toList = new ToListFunc();

    /**
     * Check if it can be converted to List
     *
     * Example:
     * ```
     * pp_R.isListLike.run(pp_R.with(1, 2, 3))
     * // true
     * ```
     *
     * @param arg The raw object
     * @return Object(Boolean)
     */
    public static pp_Func isListLike = new IsListLikeFunc();

    // Set

    /**
     * Convert to Set
     *
     * Example:
     * ```
     * pp_R.toSet.run(new Set<String>{ 'a' })
     * // {a}
     * ```
     *
     * @param arg The raw object
     * @return Object(Set<String>)
     */
    public static pp_Func toSet = new ToSetFunc();

    /**
     * Convert to Set
     *
     * Example:
     * ```
     * pp_R.toIdSet.run(new Set<Id>{ 'a' })
     * // {a}
     * ```
     *
     * @param arg The raw object
     * @return Object(Set<Id>)
     */
    public static pp_Func toIdSet = new ToIdSetFunc();

    /**
     * Check if it can be converted to Set
     *
     * Example:
     * ```
     * pp_R.isSetLike.run(new Set<String>{ 'a' })
     * // true
     * ```
     *
     * @param arg The raw object
     * @return Object(Boolean)
     */
    public static pp_Func isSetLike = new IsSetLikeFunc();

    // Map

    /**
     * Convert to Map
     *
     * Example:
     * ```
     * pp_R.toMap.run(pp_R.withObj('name', 'test'))
     * // {name=test}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, Object>)
     */
    public static pp_Func toMap = new ToMapFunc();

    /**
     * Check if it can be converted to Map
     *
     * Example:
     * ```
     * pp_R.isMapLike.run(pp_R.withObj('name', 'test'))
     * // true
     * ```
     *
     * @param arg The raw object
     * @return Object(Boolean)
     */
    public static pp_Func isMapLike = new IsMapLikeFunc();

    /**
     * Convert to Map List
     *
     * @param arg The raw object
     * @return Object(List<Map<String, Object>>)
     */
    public static pp_Func toMapList = new ToMapListFunc();

    /**
     * Convert to Pair
     *
     * Example:
     * ```
     * pp_R.toPair.run(pp_R.with(1, 2))
     * // Pair:[fst=1, snd=2]
     * ```
     *
     * @param arg The raw object
     * @return Object(pp_R.Pair)
     */
    public static pp_Func toPair = new ToPairFunc();

    /**
     * Check if it can be converted to Pair
     *
     * Example:
     * ```
     * pp_R.isPairLike.run(new pp_R.Pair(1, 2))
     * // true
     * ```
     *
     * @param arg The raw object
     * @return Object(Boolean)
     */
    public static pp_Func isPairLike = new IsPairLikeFunc();

    /**
     * Convert to Pair List
     *
     * Example:
     * ```
     * pp_R.toPairList.run(new List<Object>{ pp_R.with(1, 2) })
     * // (Pair:[fst=1, snd=2])
     * ```
     *
     * @param arg The raw object
     * @return Object(List<pp_R.Pair>)
     */
    public static pp_Func toPairList = new ToPairListFunc();

    /**
     * Convert to Pair Map
     *
     * Example:
     * ```
     * pp_R.toPairMap.run(new Map<String, Object>{ 'pair' => pp_R.with(1, 2) })
     * // {pair=Pair:[fst=1, snd=2]}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, pp_R.Pair>)
     */
    public static pp_Func toPairMap = new ToPairMapFunc();

    // SObject

    /**
     * Convert to SObject
     *
     * Example:
     * ```
     * pp_R.toSObject.run(new Account())
     * // Account:{}
     * ```
     *
     * @param arg The raw object
     * @return Object(SObject)
     */
    public static pp_Func toSObject = new ToSObjectFunc();

    /**
     * Check if it can be convertd to SObject
     *
     * Example:
     * ```
     * pp_R.isSObjectLike.run(new Account())
     * // true
     * ```
     *
     * @param arg The raw object
     * @return Object(Boolean)
     */
    public static pp_Func isSObjectLike = new IsSObjectLikeFunc();

    /**
     * Convert to SObject List
     *
     * Example:
     * ```
     * pp_R.toSObjectList.run(new List<Object>{ new Account() })
     * // (Account:{})
     * ```
     *
     * @param arg The raw object
     * @return Object(List<SObject>)
     */
    public static pp_Func toSObjectList = new ToSObjectListFunc();

    /**
     * Convert to SObject Map
     *
     * Example:
     * ```
     * pp_R.toSObjectMap.run(new Map<String, Object>{ 'acc' => new Account() })
     * // {acc=Account:{}}
     * ```
     *
     * @param arg The raw object
     * @return Object(Map<String, SObject>)
     */
    public static pp_Func toSObjectMap = new ToSObjectMapFunc();

    // ----------------------------------------------------------------------------
    // --   Arithmetic                                                           --
    // ----------------------------------------------------------------------------
    /**
     * Add two numbers
     *
     * Example:
     * ```
     * pp_R.add.run(1, 2)
     * // 3
     * ```
     *
     * @param arg1 The first number
     * @param arg2 The second number
     * @return Object(Decimal)
     */
    public static pp_Func add = new AddFunc();

    /**
     * Subtract two numbers
     *
     * Example:
     * ```
     * pp_R.subtract.run(1, 2)
     * // -1
     * ```
     *
     * @param arg1 The first number
     * @param arg2 The second number
     * @return Object(Decimal)
     */
    public static pp_Func subtract = new SubtractFunc();

    /**
     * Multiply two numbers
     *
     * Example:
     * ```
     * pp_R.multiply.run(1, 2)
     * // 2
     * ```
     *
     * @param arg1 The first number
     * @param arg2 The second number
     * @return Object(Decimal)
     */
    public static pp_Func multiply = new MultiplyFunc();

    /**
     * Divide two numbers
     *
     * Example:
     * ```
     * pp_R.divide.run(1, 2)
     * // 0.5
     * ```
     *
     * @param arg1 The first number
     * @param arg2 The second number
     * @return Object(Decimal)
     */
    public static pp_Func divide = new DivideFunc();

    /**
     * Mod two numbers
     *
     * Example:
     * ```
     * pp_R.mod.run(1, 2)
     * // 1
     * ```
     *
     * @param arg1 The first number
     * @param arg2 The second number
     * @return Object(Decimal)
     */
    public static pp_Func mod = new ModFunc();

    /**
     * Increment the number
     *
     * Example:
     * ```
     * pp_R.inc.run(1)
     * // 2
     * ```
     *
     * @param arg The number
     * @return Object(Decimal)
     */
    public static pp_Func inc = add.apply(1);

    /**
     * Decrement the number
     *
     * Example:
     * ```
     * pp_R.dec.run(1)
     * // 0
     * ```
     *
     * @param arg The number
     * @return Object(Decimal)
     */
    public static pp_Func dec = add.apply(-1);

    /**
     * Negate the number
     *
     * Example:
     * ```
     * pp_R.negate.run(1)
     * // -1
     * ```
     *
     * @param arg The number
     * @return Object(Decimal)
     */
    public static pp_Func negate = subtract.apply(0);

    /**
     * Multiply all the numbers
     *
     * Example:
     * ```
     * pp_R.product.run(1, 2, 3)
     * // 6
     * ```
     *
     * @param <args> Dynamic arguments
     * @return Object(Decimal)
     */
    public static pp_Func product = new ProductFunc();

    // ----------------------------------------------------------------------------
    // --   Logic                                                                --
    // ----------------------------------------------------------------------------

    /**
     * Create a function that combines all predicates with 'and'
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.allPass.run(
     *     pp_R.startsWith.apply('c'),
     *     pp_R.endsWith.apply('t')
     * );
     * System.debug(f.run('cat'));
     * // true
     * ```
     *
     * @param <args> Dynamic arguments of Func
     * @return Object(pp_Func)
     */
    public static pp_Func allPass = new AllPassFunc();

    /**
     * Create a function that combines all predicates with 'or'
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.anyPass.run(
     *     pp_R.startsWith.apply('c'),
     *     pp_R.endsWith.apply('t')
     * );
     * System.debug(f.run('cc'));
     * // true
     * ```
     *
     * @param <args> Dynamic arguments of Func
     * @return Object(pp_Func)
     */
    public static pp_Func anyPass = new AnyPassFunc();

    /**
     * Create a function that negate the predicate
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.complement.run(pp_R.equals.apply('cat'));
     * System.debug(f.run('cat'));
     * // false
     * ```
     *
     * @param arg The predicate
     * @return Object(pp_Func)
     */
    public static pp_Func complement = new ComplementFunc();

    /**
     * Test logic 'and'
     *
     * Example:
     * ```
     * pp_R.doAnd.run(true, false)
     * // false
     * ```
     *
     * @param <args> Dynamic arguments of Boolean
     * @return Object(Boolean)
     */
    public static pp_Func doAnd = new AndFunc();

    /**
     * Test logic 'or'
     *
     * Example:
     * ```
     * pp_R.doOr.run(true, false)
     * // true
     * ```
     *
     * @param <args> Dynamic arguments of Boolean
     * @return Object(Boolean)
     */
    public static pp_Func doOr = new OrFunc();

    /**
     * Test logic 'not'
     *
     * Example:
     * ```
     * pp_R.doNot.run(false)
     * // true
     * ```
     *
     * @param arg Boolean value
     * @return Object(Boolean)
     */
    public static pp_Func doNot = new NotFunc();

    // ----------------------------------------------------------------------------
    // --   Relation                                                             --
    // ----------------------------------------------------------------------------

    /**
     * Check if two values are equal
     *
     * Example:
     * ```
     * pp_R.equals.run(1, 1)
     * // true
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object(Boolean)
     */
    public static pp_Func equals = new EqualsFunc();

    /**
     * Check for 'less than'
     *
     * Example:
     * ```
     * pp_R.lt.run(1, 2)
     * // true
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object(Boolean)
     */
    public static pp_Func lt = new LtFunc();

    /**
     * Check for 'less than or equal'
     *
     * Example:
     * ```
     * pp_R.lte.run(1, 2)
     * // true
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object(Boolean)
     */
    public static pp_Func lte = new LteFunc();

    /**
     * Check for 'greater than'
     *
     * Example:
     * ```
     * pp_R.gt.run(3, 2)
     * // true
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object(Boolean)
     */
    public static pp_Func gt = new GtFunc();

    /**
     * Check for 'greater than or equal'
     *
     * Example:
     * ```
     * pp_R.gte.run(3, 2)
     * // true
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object(Boolean)
     */
    public static pp_Func gte = new GteFunc();

    /**
     * Check for the max value between the two
     *
     * Example:
     * ```
     * pp_R.max.run(1, 2)
     * // 2
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object
     */
    public static pp_Func max = new MaxFunc();

    /**
     * Check for the min value between the two
     *
     * Example:
     * ```
     * pp_R.min.run(1, 2)
     * // 1
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object
     */
    public static pp_Func min = new MinFunc();

    // ----------------------------------------------------------------------------
    // --   Function                                                             --
    // ----------------------------------------------------------------------------

    /**
     * A placeholder in the applied arguments
     *
     * Example:
     * ```
     * pp_R.subtract.apply(pp_R.placeholder, 2).run(1)
     * // -1
     * ```
     *
     * @param <args> Should not pass in any arguments
     * @return null Should not use the return value
     */
    public static pp_Func placeholder = new PlaceholderFunc();

    /**
     * Compose the functions in a piping style
     * Composed functions are executed from left to right
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.pipe.run(
     *     pp_R.add.apply(1),
     *     pp_R.multiply.apply(2)
     * );
     * System.debug(f.run(1));
     * // 4
     * ```
     *
     * @param <args> Dynamic arguments of Func
     * @return Object(pp_Func)
     */
    public static pp_Func pipe = new PipeFunc();

    /**
     * Compose the functions in a composing style
     * Composed functions are executed from right to left
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.pipe.run(
     *     pp_R.add.apply(1),
     *     pp_R.multiply.apply(2)
     * );
     * System.debug(f.run(1));
     * // 3
     * ```
     *
     * @param <args> Dynamic arguments of Func
     * @return Object(pp_Func)
     */
    public static pp_Func compose = new ComposeFunc();

    /**
     * Flip the first two arguments of a function
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.flip.run(pp_R.subtract);
     * System.debug(f.run(1, 2));
     * // 1
     * ```
     *
     * @param arg The function
     * @return Object(pp_Func)
     */
    public static pp_Func flip = new FlipFunc();

    /**
     * Accepts a converging function and branching functions and returns a new function
     * When invoked, this new function is applied to some arguments, each branching function is applied to those same arguments
     * The results of each branching function are passed as arguments to the converging function to produce the return value
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.converge.run(
     *     pp_R.multiply,
     *     pp_R.add,
     *     pp_R.subtract
     * );
     * System.debug(f.run(1, 2));
     * // -3
     * ```
     *
     * @param fn The converging function
     * @param <args> The branching functions
     * @return Object(pp_Func)
     */
    public static pp_Func converge = new ConvergeFunc();

    /**
     * Accepts a function fn and other functions and returns a new function
     * When the new function is invoked, it calls the function fn with parameters consisting of the result
     * of calling each supplied handler on successive arguments to the new function
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.useWith.run(
     *     pp_R.multiply,
     *     pp_R.add.apply(1),
     *     pp_R.subtract.apply(1)
     * );
     * System.debug(f.run(1, 2));
     * // -2
     * ```
     *
     * @param fn The main function
     * @param <args> The other functions
     * @return Object(pp_Func)
     */
    public static pp_Func useWith = new UseWithFunc();

    /**
     * Return whatever is passed in
     *
     * Example:
     * ```
     * pp_R.identity.run('abc')
     * // abc
     * ```
     *
     * @param arg The passed in object
     * @return Object
     */
    public static pp_Func identity = new IdentityFunc();

    /**
     * Return a function which returns the value whenever called
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.always.run(1);
     * System.debug(f.run(2));
     * // 1
     * ```
     *
     * @param val The applied value
     * @return Object(pp_Func)
     */
    public static pp_Func always = new AlwaysFunc();

    /**
     * Return a function which returns the value whenever called
     *
     * Example:
     * ```
     * pp_Func f = pp_R.constant.apply(1);
     * System.debug(f.run(2));
     * // 1
     * ```
     *
     * @param val The applied value
     * @return Object
     */
    public static pp_Func constant = new ConstantFunc();

    /**
     * Throw an exception
     *
     * Example:
     * ```
     * pp_R.throwException.run(new pp_Func.FuncException('test'));
     * // throw exception
     * ```
     *
     * @param e The exception
     * @return Object
     */
    public static pp_Func throwException = new ThrowExcpetionFunc();

    /**
     * Wrap the function to make it call only by once
     *
     * Example:
     * ```
     * pp_Func testF = (pp_Func)pp_R.once.run(pp_R.add.apply(1), 'testF');
     * testF.run(1) // 2
     * testF.run(2) // 2
     * ```
     *
     * @param fn The raw function
     * @param key The unique key for this function
     * @return Object(pp_Func)
     */
    public static pp_Func once = new OnceFunc();

    /**
     * Wrap the function to make it memoizable
     *
     * Example:
     * ```
     * pp_Func testF = (pp_Func)pp_R.memoize.run(
     *    pp_R.add.apply(1),
     *    'testF',
     *    pp_R.toString
     * );
     * ```
     *
     * @param fn The raw function
     * @param key The unique key for this function
     * @param keyFn The function to generate the memoizing key
     * @return Object(pp_Func)
     */
    public static pp_Func memoize = new MemoizeFunc();

    /**
     * Wrap the function to make it accept only N arguments
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.nAry.run(2, pp_R.product);
     * System.debug(f.run(1, 2, 3));
     * // 2
     * ```
     *
     * @param arity The size of arguments allowed
     * @param fn The function to be wrapped
     * @return Object(pp_Func)
     */
    public static pp_Func nAry = new NAryFunc();

    /**
     * Make the function accept only one argument
     *
     * @see nAry
     */
    public static pp_Func unary = nAry.apply(1);

    /**
     * Make the function accept only two arguments
     *
     * @see nAry
     */
    public static pp_Func binary = nAry.apply(2);

    /**
     * Apply the function to the target
     *
     * Example:
     * ```
     * pp_R.transform.run(pp_R.inc, 1)
     * // 2
     * ```
     *
     * @param fn The transforming function
     * @param target The target object
     * @return Object
     */
    public static pp_Func transform = new TransformFunc();

    /**
     * Given a spec object recursively mapping properties to functions, creates a function producing an object of the same structure,
     * by mapping each property to the result of calling its associated function with the supplied arguments
     *
     * Example:
     * ```
     * Map<String, Object> spec = new Map<String, Object>{
     *     'add' => pp_R.add,
     *     'subtract' => pp_R.subtract
     * };
     * System.debug(pp_R.applySpec.run(spec, 1, 2));
     * // {add=3, subtract=-1}
     * ```
     *
     * @param spec Map of function specs
     * @param <args> Other arguments
     * @return Object
     */
    public static pp_Func applySpec = new ApplySpecFunc();

    /**
     * Applies a list of functions to a list of values
     *
     * Example:
     * ```
     * List<pp_Func> fns = new List<pp_Func>{ pp_R.add, pp_R.subtract };
     * System.debug(pp_R.juxt.run(fns, 1, 2));
     * // (3, -1)
     * ```
     *
     * @param juxt List of functions
     * @param <args> Other arguments
     * @return Object
     */
    public static pp_Func juxt = new JuxtFunc();

    /**
     * Creates a new object by recursively evolving a copy of object, according to the transformation functions
     *
     * Example:
     * ```
     * pp_R.evolve.run(new Map<String, Object>{ 'name' => pp_R.append.apply('$') }, new Map<String, Object>{ 'name' => 'test' })
     * // {name=test$}
     * ```
     *
     * @param spec Map of spec functions
     * @param target The target object
     * @return Object
     */
    public static pp_Func evolve = new EvolveFunc();

    // ----------------------------------------------------------------------------
    // --   Comparator                                                           --
    // ----------------------------------------------------------------------------

    /**
     * Convert a Boolean-returning comparator to an Integer-returning comparator
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.comparator.run(pp_R.lt);
     * System.debug(f.run(1, 2));
     * // -1
     * ```
     *
     * @param comparator The Boolean-returning function that takes two arguments
     * @return Object(pp_Func)
     */
    public static pp_Func comparator = new ComparatorFunc();

    /**
     * Compare two objects
     *
     * Example:
     * ```
     * pp_R.compare.run(1, 2)
     * // -1
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object(Integer)
     */
    public static pp_Func compare = new CompareFunc();

    /**
     * Convert a function into an ascending comparator
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.ascend.run(pp_R.identity);
     * System.debug(f.run(1, 2));
     * // -1
     * ```
     *
     * @param fn The function that takes one argument and returns one
     * @return Object(pp_Func)
     */
    public static pp_Func ascend = new AscendFunc();

    /**
     * Convert a function into an descending comparator
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.descend.run(pp_R.identity);
     * System.debug(f.run(1, 2));
     * // 1
     * ```
     *
     * @param fn The function that takes one argument and returns one
     * @return Object(pp_Func)
     */
    public static pp_Func descend = new DescendFunc();

    /**
     * Combine the comparator functions into one
     *
     * Example:
     * ```
     * pp_Func f = (pp_Func)pp_R.cascade.run(
     *     (pp_Func)pp_R.ascend.run(pp_R.prop.apply('FirstName')),
     *     (pp_Func)pp_R.ascend.run(pp_R.prop.apply('Description'))
     * );
     * ```
     *
     * @param <args> List of comparator functions
     * @return Object(pp_Func)
     */
    public static pp_Func cascade = new CascadeFunc();

    /**
     * Limit the value between the min and the max
     *
     * Example:
     * ```
     * pp_R.clamp.run(1, 3, 5)
     * // 3
     * ```
     *
     * @param min The min value
     * @param max The max value
     * @param target The target value
     * @return Object
     */
    public static pp_Func clamp = new ClampFunc();

    // ----------------------------------------------------------------------------
    // --   Condition                                                            --
    // ----------------------------------------------------------------------------

    /**
     * Returns a function, fn, which encapsulates if/else, if/else, logic
     * It takes a list of functions, alternated by predicate and transformer
     * All of the arguments to fn are applied to each of the predicates in turn until one returns a "truthy" value,
     * at which point fn returns the result of applying its arguments to the corresponding transformer
     *
     * Example:
     * ```
     * pp_Func testF = (pp_Func)pp_R.cond.runN(new List<Object>{
     *     pp_R.lt.apply(0), pp_R.always.run(1),
     *     pp_R.gt.apply(0), pp_R.always.run(-1),
     *     pp_R.equals.apply(0), pp_R.always.run(0)
     * });
     * testF.run(3); // 1
     * ```
     *
     * @param <args> List of functions, alternated by predicate and transformer
     * @return Object(pp_Func)
     */
    public static pp_Func cond = new CondFunc();

    /**
     * Creates a function that will process either the onTrue or the onFalse function depending upon the result of the condition predicate
     *
     * Example:
     * ```
     * pp_Func testF = (pp_Func)pp_R.ifElse.run(
     *     pp_R.lt.apply(0),
     *     pp_R.always.run(1),
     *     pp_R.always.run(0)
     * );
     * testF.run(3); // 1
     * ```
     *
     * @param predicate The condition
     * @param onTrue The function on true condition
     * @param onFalse The function on false condition
     * @return Object(pp_Func)
     */
    public static pp_Func ifElse = new IfElseFunc();

    /**
     * Tests the final argument by passing it to the given predicate function
     * If the predicate is satisfied, the function will return the result of calling the whenTrueFn function with the same argument
     * If the predicate is not satisfied, the argument is returned as a wrapping list
     *
     * Example:
     * ```
     * pp_Func testF = (pp_Func)pp_R.doWhen.run(
     *     pp_R.lt.apply(0),
     *     pp_R.always.run(1)
     * );
     * testF.run(3); // 1
     * ```
     *
     * @param predicate The condition
     * @param whenTrueFn The function on true
     * @return Object(pp_Func)
     */
    public static pp_Func doWhen = new WhenFunc();

    /**
     * Tests the final argument by passing it to the given predicate function
     * If the predicate is not satisfied, the function will return the result of calling the whenFalseFn function with the same argument
     * If the predicate is satisfied, the argument is returned as a wrapping list
     *
     * Example:
     * ```
     * pp_Func testF = (pp_Func)pp_R.unless.run(
     *     pp_R.lt.apply(0),
     *     pp_R.always.run(0)
     * );
     * testF.run(-3); // 0
     * ```
     *
     * @param predicate The condition
     * @param whenFalseFn The function on false
     * @return Object(pp_Func)
     */
    public static pp_Func unless = new UnlessFunc();

    // ----------------------------------------------------------------------------
    // --   List                                                                 --
    // ----------------------------------------------------------------------------

    /**
     * Do for-each on the elements
     *
     * Example:
     * ```
     * pp_R.forEach.run(pp_R.debug, pp_R.with(1, 2, 3));
     * // 1
     * // 2
     * // 3
     * ```
     *
     * @param fn The iterating function
     * @param target The target object
     * @return Object
     */
    public static pp_Func forEach = new ForEachFunc();

    /**
     * Filter on the elements
     *
     * Example:
     * ```
     * pp_R.filter.run(pp_R.isNotNull, pp_R.with('a', null, 'b'))
     * // (a, b)
     * ```
     *
     * @param fn The filter function
     * @param target The target object
     * @return Object
     */
    public static pp_Func filter = new FilterFunc(false);

    /**
     * Reject on the elements
     *
     * Example:
     * ```
     * pp_R.reject.run(pp_R.isNull, pp_R.with('a', null, 'b'))
     * // (a, b)
     * ```
     *
     * @param fn The reject function
     * @param target The target object
     * @return Object
     */
    public static pp_Func reject = new FilterFunc(true);

    /**
     * Map over the elements
     *
     * Example:
     * ```
     * pp_R.doMap.run(pp_R.inc, pp_R.with(1, 2, 3))
     * // (2, 3, 4)
     * ```
     *
     * @param fn The mapping function
     * @param target The target object
     * @return Object
     */
    public static pp_Func doMap = new MapFunc();

    /**
     * Map over both the keys and values
     *
     * Example:
     * ```
     * pp_R.bimap.run(pp_R.append.apply('_key'), pp_R.append.apply('_value'), pp_R.withObj('name', 'test'))
     * // {test_key=test_value}
     * ```
     *
     * @param keyFn The function to map to generate keys
     * @param valueFn The function to map to generate values
     * @return Object(Map<String, Object>)
     */
    public static pp_Func biMap = new BimapFunc();

    /**
     * Pluck the fields out of elements
     *
     * Example:
     * ```
     * pp_R.pluck.run('Description', pp_R.with(new Account(Description='desc')))
     * // (desc)
     * ```
     *
     * @param field The field name to pluck
     * @param target The target object
     * @return Object(List<Object>)
     */
    public static pp_Func pluck = new PluckFunc();

    /**
     * Reduce over the elements
     *
     * Example:
     * ```
     * pp_R.reduce.run(pp_R.add, 0, pp_R.with(1, 2, 3))
     * // 6
     * ```
     *
     * @param reducerFn The reducing function
     * @param initialValue The initial value
     * @param target The target object
     * @return Object
     */
    public static pp_Func reduce = new ReduceFunc();

    /**
     * Get the length
     *
     * Example:
     * ```
     * pp_R.length.run(pp_R.with(1, 2, 3))
     * // 3
     * ```
     *
     * @param target The target object
     * @return Object(Integer)
     */
    public static pp_Func length = pp_R.reduce.apply(
            pp_R.nAry.run(1, pp_R.add.apply(1)),
            0
    );

    /**
     * Get the size
     *
     * @see length
     */
    public static pp_Func size = pp_R.length;

    /**
     * Check if it is empty
     *
     * Example:
     * ```
     * pp_R.isEmpty.run(pp_R.with(1, 2, 3))
     * // false
     * ```
     *
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func isEmpty = (pp_Func) pp_R.pipe.run(
            pp_R.length,
            pp_R.equals.apply(0)
    );

    /**
     * Check if it is not empty
     *
     * Example:
     * ```
     * pp_R.isNotEmpty.run(pp_R.with(1, 2, 3))
     * // true
     * ```
     *
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func isNotEmpty = (pp_Func) pp_R.complement.run(pp_R.isEmpty);

    /**
     * Get the sum
     *
     * Example:
     * ```
     * pp_R.sum.run(pp_R.with(1, 2, 3))
     * // 6
     * ```
     *
     * @param target The target object
     * @return Object(Decimal)
     */
    public static pp_Func sum = pp_R.reduce.apply(pp_R.add, 0);

    /**
     * Get a slice of the elements
     *
     * Example:
     * ```
     * pp_R.slice.run(0, 1, pp_R.with(1, 2, 3))
     * // (1)
     * ```
     *
     * @param first The first index(inclusive)
     * @param last The last index(exclusive)
     * @param target The target object
     * @return Object
     */
    public static pp_Func slice = new SliceFunc();

    /**
     * Take the first N elements
     *
     * Example:
     * ```
     * pp_R.take.run(1, 'abc')
     * // a
     * ```
     *
     * @param count The count of elements to take
     * @param target The target object
     * @return Object
     */
    public static pp_Func take = new TakeFunc().apply(false);

    /**
     * Take the first N elements from right
     *
     * Example:
     * ```
     * pp_R.takeRight.run(1, 'abc')
     * // c
     * ```
     *
     * @param count The count of elements to take
     * @param target The target object
     * @return Object
     */
    public static pp_Func takeRight = new TakeFunc().apply(true);

    /**
     * Take elements until not satisfied
     *
     * Example:
     * ```
     * pp_R.takeWhile.run(pp_R.equals.apply('a'), 'abc')
     * // a
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object
     */
    public static pp_Func takeWhile = take;

    /**
     * Take elements from right until not satisfied
     *
     * Example
     * ```
     * pp_R.takeRightWhile.run(pp_R.equals.apply('a'), 'abc')
     * //
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object
     */
    public static pp_Func takeRightWhile = takeRight;

    /**
     * Drop first N elements
     *
     * Example:
     * ```
     * pp_R.drop.run(1, 'abc')
     * // bc
     * ```
     *
     * @param count The count of elements to drop
     * @param target The target object
     * @return Object
     */
    public static pp_Func drop = new DropFunc().apply(false);

    /**
     * Drop first N elements from right
     *
     * Example:
     * ```
     * pp_R.dropRight.run(1, 'abc')
     * // ab
     * ```
     *
     * @param count The count of elements to drop
     * @param target The target object
     * @return Object
     */
    public static pp_Func dropRight = new DropFunc().apply(true);

    /**
     * Drop elements until not satisfied
     *
     * Example:
     * ```
     * pp_R.dropWhile.run(pp_R.equals.apply('a'), 'abc')
     * // bc
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object
     */
    public static pp_Func dropWhile = drop;

    /**
     * Drop elements from right until not satisfied
     *
     * Example:
     * ```
     * pp_R.dropRightWhile.run(pp_R.equals.apply('a'), 'abc')
     * // abc
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object
     */
    public static pp_Func dropRightWhile = dropRight;

    /**
     * Reverse the elements
     *
     * Example:
     * ```
     * pp_R.reverse.run('abc')
     * // cba
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func reverse = new ReverseFunc();

    /**
     * Sort by the comparator
     *
     * Example:
     * ```
     * pp_R.sortBy.run(pp_R.compare, pp_R.with(3, 2, 1))
     * // (1, 2, 3)
     * ```
     *
     * @param comparator The comparator function that returns integer
     * @param target The target object
     * @return Object
     */
    public static pp_Func sortBy = new SortFunc();

    /**
     * Sort by default
     *
     * Example:
     * ```
     * pp_R.sortDefault.run(pp_R.with(3, 2, 1))
     * // (1, 2, 3)
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func sortDefault = new SortDefaultFunc();

    /**
     * Check if the element is contained
     *
     * Example:
     * ```
     * pp_R.contains.run(1, pp_R.with(1, 2, 3))
     * // true
     * ```
     *
     * @param element The element to check
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func contains = new ContainsFunc();

    /**
     * Check if the element is contained by the comparator returning boolean
     *
     * Example:
     * ```
     * pp_R.containsBy.run(pp_R.equals, 1, pp_R.with(1, 2, 3))
     * // true
     * ```
     *
     * @param comparator The comparator function returning boolean
     * @param element The element to check
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func containsBy = new ContainsByFunc();

    /**
     * Check if the key is contained
     *
     * Example:
     * ```
     * pp_R.containsKey.run('name', new Map<String, Object>{ 'name' => 'test' })
     * // true
     * ```
     *
     * @param key The key to check
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func containsKey = new ContainsKeyFunc();

    /**
     * Get a unique collection of the elements
     *
     * Example:
     * ```
     * pp_R.uniq.run(pp_R.with(1, 2, 2))
     * // (1, 2)
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func uniq = new UniqFunc();

    /**
     * Make a union of the two objects
     *
     * Example:
     * ```
     * pp_R.union.run(pp_R.with(1, 2, 3), pp_R.with(2, 3, 4))
     * // (2, 3, 4, 1)
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object
     */
    public static pp_Func union = new UnionFunc();

    /**
     * Make an intersection of the two objects
     *
     * Example:
     * ```
     * pp_R.intersection.run(pp_R.with(1, 2, 3), pp_R.with(2, 3, 4))
     * // (2, 3)
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object
     */
    public static pp_Func intersection = new IntersectionFunc();

    /**
     * Make an xor of the two objects
     *
     * Example:
     * ```
     * pp_R.xor.run(pp_R.with(1, 2, 3), pp_R.with(2, 3, 4))
     * // (4, 1)
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object
     */
    public static pp_Func xor = new XorFunc();

    /**
     * Make a difference of the two objects
     *
     * Example:
     * ```
     * pp_R.difference.run(pp_R.with(1, 2, 3), pp_R.with(2, 3, 4))
     * // (4)
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object
     */
    public static pp_Func difference = new DifferenceFunc();

    /**
     * Same as difference
     *
     * @see difference
     */
    public static pp_Func without = pp_R.difference;

    /**
     * Adjust the element using the function
     *
     * Example:
     * ```
     * pp_R.adjust.run(pp_R.inc, 1, pp_R.with(1, 2, 3))
     * // (1, 3, 3)
     * ```
     *
     * @param fn The function to update the element
     * @param index The index of the element
     * @param target The target object
     * @return Object
     */
    public static pp_Func adjust = new AdjustFunc();

    /**
     * Check if all elements match the predicate
     *
     * Example:
     * ```
     * pp_R.all.run(pp_R.isNotNull, pp_R.with(1, 2, 3))
     * // true
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func all = new AllFunc();

    /**
     * Same as all
     *
     * @see all
     */
    public static pp_Func every = pp_R.all;

    /**
     * Check if some elements match the predicate
     *
     * Example:
     *
     * pp_R.some.run(pp_R.isNotNull, pp_R.with(1, 2, 3))
     * // false
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func some = new AnyFunc();

    /**
     * Check if none of the elements match the predicate
     *
     * Example:
     * ```
     * pp_R.none.run(pp_R.isNotNull, pp_R.with(1, 2, 3))
     * // true
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func none = new NoneFunc();

    /**
     * Append an element to the elements
     *
     * Example:
     * ```
     * pp_R.append.run(1, pp_R.with(1, 2, 3))
     * // (1, 2, 3, 1)
     * ```
     *
     * @param element The element to append
     * @param target The target object
     * @return Object
     */
    public static pp_Func append = new AppendFunc();

    /**
     * Prepend an element to the elements
     *
     * Example:
     * ```
     * pp_R.prepend.run(1, pp_R.with(1, 2, 3))
     * // (1, 1, 2, 3)
     * ```
     *
     * @param element The element to prepend
     * @param target The target object
     * @return Object
     */
    public static pp_Func prepend = new PrependFunc();

    /**
     * Set the key value
     *
     * Example:
     * ```
     * pp_R.assoc.run('name', 'test', new Map<String, Object>())
     * // {name=test}
     * ```
     *
     * @param key The key field
     * @param value The value of the key field
     * @param target The target object
     * @return Object
     */
    public static pp_Func assoc = new AssocFunc();

    /**
     * Remove the key value
     *
     * Example:
     * ```
     * pp_R.dissoc.run('name', new Map<String, Object>{ 'name' => 'test' })
     * // {}
     * ```
     *
     * @param key The key field
     * @param target The target object
     * @return Object
     */
    public static pp_Func dissoc = new DissocFunc();

    /**
     * Concatenate two objects
     *
     * Example:
     * ```
     * pp_R.concat.run(pp_R.with(1, 2, 3), pp_R.with(4, 5, 6))
     * // (4, 5, 6, 1, 2, 3)
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Object
     */
    public static pp_Func concat = new ConcatFunc();

    /**
     * Get counts by the key
     *
     * Example:
     * ```
     * pp_R.countBy.run(pp_R.identity, pp_R.with(1, 2, 2))
     * // {1=1, 2=2}
     * ```
     *
     * @param fn The key generating function
     * @param target The target object
     * @return Object
     */
    public static pp_Func countBy = new CountByFunc();

    /**
     * Get groups by the key
     *
     * Example:
     * ```
     * pp_R.groupBy.run(pp_R.identity, pp_R.with(1, 2, 2))
     * // {1=(1), 2=(2, 2)}
     * ```
     *
     * @param fn The key generating function
     * @param target The target object
     * @return Object
     */
    public static pp_Func groupBy = new GroupByFunc();

    /**
     * Get indexes by the key
     *
     * Example:
     * ```
     * pp_R.indexBy.run(pp_R.identity, pp_R.with(1, 2, 2))
     * // {1=1, 2=2}
     * ```
     *
     * @param fn The key generating function
     * @param target The target object
     * @return Object
     */
    public static pp_Func indexBy = new IndexByFunc();

    /**
     * Check starting with
     *
     * Example:
     * ```
     * pp_R.startsWith('a', 'abc')
     * // true
     * ```
     *
     * @param pattern The pattern to check
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func startsWith = new StartsWithFunc();

    /**
     * Check ending with
     *
     * Example:
     * ```
     * pp_R.endsWith('a', 'abc')
     * // false
     * ```
     *
     * @param pattern The pattern to check
     * @param target The target object
     * @return Object(Boolean)
     */
    public static pp_Func endsWith = new EndsWithFunc();

    /**
     * Find the first element that matches the predicate
     *
     * Example:
     * ```
     * pp_R.find.run(pp_R.equals.apply('a'), pp_R.with('a', 'b'))
     * // a
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object
     */
    public static pp_Func find = new FindFunc(false);

    /**
     * Find the first element from last that matches the predicate
     *
     * Example:
     * ```
     * pp_R.findLast.run(pp_R.equals.apply('a'), pp_R.with('a', 'b'))
     * // a
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object
     */
    public static pp_Func findLast = new FindFunc(true);

    /**
     * Find the index of the first element that matches the predicate
     *
     * Example:
     * ```
     * pp_R.findIndex.run(pp_R.equals.apply('a'), pp_R.with('a', 'b'))
     * // 0
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object(Integer)
     */
    public static pp_Func findIndex = new FindIndexFunc(false);

    /**
     * Find the index of the first element from last that matches the predicate
     *
     * Example:
     * ```
     * pp_R.findLastIndex.run(pp_R.equals.apply('a'), pp_R.with('a', 'b'))
     * // 0
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return Object(Integer)
     */
    public static pp_Func findLastIndex = new FindIndexFunc(true);

    /**
     * Flatten the elements by one level
     *
     * Example:
     * ```
     * pp_R.unnest.run(pp_R.with(1, pp_R.with(2, 3)))
     * // (1, 2, 3)
     * ```
     *
     * @param target The target object
     * @return Object(List<Object>)
     */
    public static pp_Func unnest = new UnnestFunc();

    /**
     * Flatten the elements recursively
     *
     * Example:
     * ```
     * pp_R.flatten.run(pp_R.with(1, pp_R.with(2, pp_R.with(3))))
     * // (1, 2, 3)
     * ```
     *
     * @param target The target object
     * @return Object(List<Object>)
     */
    public static pp_Func flatten = new FlattenFunc();

    /**
     * Create a pair
     *
     * Example:
     * ```
     * pp_R.pair.run(1, 2)
     * // Pair:[fst=1, snd=2]
     * ```
     *
     * @param fst The first object
     * @param snd The second object
     * @return pp_R.Pair
     */
    public static pp_Func pair = new PairFunc();

    /**
     * Convert a list of pairs to map
     *
     * Example:
     * ```
     * pp_R.fromPairs.run(pp_R.with(new pp_R.Pair('a', 1)))
     * // {a=1}
     * ```
     *
     * @param pairs The list of pairs
     * @return Map<String, Object>
     */
    public static pp_Func fromPairs = new FromPairsFunc();

    /**
     * Convert a map to a list of pairs
     *
     * Example:
     * ```
     * pp_R.toPairs.run(new Map<String, Object>{ 'name' => 'test' })
     * // (Pair:[fst=name, snd=test])
     * ```
     *
     * @param target The map
     * @return List<pp_R.Pair>
     */
    public static pp_Func toPairs = new ToPairsFunc();

    /**
     * Get the first element
     *
     * Example:
     * ```
     * pp_R.first.run(pp_R.with(1, 2, 3))
     * // 1
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func first = new FirstFunc();

    /**
     * Same as first
     *
     * @see first
     */
    public static pp_Func head = first;

    /**
     * Get the last element
     *
     * Example:
     * ```
     * pp_R.last.run(pp_R.with(1, 2, 3))
     * // 3
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func last = new LastFunc();

    /**
     * Get the elements except the last
     *
     * Example:
     * ```
     * pp_R.init.run(pp_R.with(1, 2, 3))
     * // (1, 2)
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func init = new InitFunc();

    /**
     * Get the elements except the first
     *
     * Example:
     * ```
     * pp_R.tail.run(pp_R.with(1, 2, 3))
     * // (2, 3)
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func tail = new TailFunc();

    /**
     * Get the index of the first element found
     *
     * Example:
     * ```
     * pp_R.indexOf.run(1, pp_R.with(1, 2, 3))
     * // 0
     * ```
     *
     * @param element The element
     * @param target The target object
     * @return Integer
     */
    public static pp_Func indexOf = new IndexOfFunc(false);

    /**
     * Get the index of the first element found from the last
     *
     * Example:
     * ```
     * pp_R.lastIndexOf.run(1, pp_R.with(1, 2, 3))
     * // 0
     * ```
     *
     * @param element The element
     * @param target The target object
     * @return Integer
     */
    public static pp_Func lastIndexOf = new IndexOfFunc(true);

    /**
     * Insert element at the index
     *
     * Example:
     * ```
     * pp_R.doInsert.run(1, 'x', pp_R.with(1, 2, 3))
     * // (1, x, 2, 3)
     * ```
     *
     * @param index The index to insert
     * @param element The element to insert
     * @param target The target object
     * @return Object
     */
    public static pp_Func doInsert = new InsertFunc();

    /**
     * Insert elements at the index
     *
     * Example:
     * ```
     * pp_R.doInsertAll.run(1, pp_R.with('x', 'y'), pp_R.with(1, 2, 3))
     * // (1, x, y, 2, 3)
     * ```
     *
     * @param index The index to insert
     * @param elements The elements to insert
     * @param target The target object
     * @return Object
     */
    public static pp_Func doInsertAll = new InsertAllFunc();

    /**
     * Join the elements by the separator
     *
     * Example:
     * ```
     * pp_R.doJoin.run('-', pp_R.with(1, 2, 3))
     * // 1-2-3
     * ```
     *
     * @param separator The separator string
     * @param target The target object
     * @return String
     */
    public static pp_Func doJoin = new JoinFunc();

    /**
     * Get the nth element
     *
     * Example:
     * ```
     * pp_R.nth.run(1, pp_R.with(1, 2, 3))
     * // 2
     * ```
     *
     * @param index The index of the element
     * @param target The target object
     * @return Object
     */
    public static pp_Func nth = new NthFunc();

    /**
     * Create a partitioned pair using the predicate
     *
     * Example:
     * ```
     * pp_R.partition.run(pp_R.equals.apply('a'), pp_R.with('a', 'b', 'c'))
     * // Pair:[fst=(a), snd=(b, c)]
     * ```
     *
     * @param pred The predicate
     * @param target The target object
     * @return pp_R.Pair
     */
    public static pp_Func partition = new PartitionFunc();

    /**
     * Project elements into other elements according to the fields
     *
     * Example:
     * ```
     * pp_R.project.run(pp_R.with('Description'), pp_R.with(new Account(Description='desc')))
     * // ({Description=desc})
     * ```
     *
     * @param fields The list of fields
     * @param target The target object(List)
     * @return List<Object>
     */
    public static pp_Func project = new ProjectFunc();

    /**
     * Generate a range of decimals
     *
     * Example:
     * ```
     * pp_R.range.run(1, 3)
     * // (1, 2)
     * ```
     *
     * @param first The first number(inclusive)
     * @param last The last number(exclusive)
     * @return List<Decimal>
     */
    public static pp_Func range = new RangeFunc();

    /**
     * Remove elements
     *
     * Example:
     * ```
     * pp_R.remove.run(1, 2, pp_R.with(1, 2, 3))
     * // (1)
     * ```
     *
     * @param first The index of the first object
     * @param count The number of elements to remove
     * @param target The target object
     * @return Object
     */
    public static pp_Func remove = new RemoveFunc();

    /**
     * Repeat the target to generate elements
     *
     * Example:
     * ```
     * pp_R.repeat.run(5, 'a')
     * // (a, a, a, a, a)
     * ```
     *
     * @param count The number of repetition
     * @param target The target object to be repeated
     * @return List<Object>
     */
    public static pp_Func repeat = new RepeatFunc();

    /**
     * Invoke a function for N times
     *
     * Example:
     * ```
     * pp_R.times.run(3, pp_R.identity)
     * // (0, 1, 2)
     * ```
     *
     * @param count The number of repetition
     * @param fn The function to be invoked
     * @return List<Object>
     */
    public static pp_Func times = new TimesFunc();

    /**
     * Update an element of the elements
     *
     * Example:
     * ```
     * pp_R.doUpdate.run(1, 3, pp_R.with(1, 2, 3))
     * // (1, 3, 3)
     * ```
     *
     * @param index The index of the element to be updated
     * @param val The new value of the element
     * @param target The target object
     * @return Object
     */
    public static pp_Func doUpdate = new UpdateFunc();

    /**
     * Zip two collections to create a list of pairs
     *
     * Example:
     * ```
     * pp_R.zip.run(pp_R.with('a', 'b'), pp_R.with(1, 2))
     * // (Pair:[fst=a, snd=1], Pair:[fst=b, snd=2])
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return List<pp_R.Pair>
     */
    public static pp_Func zip = new ZipFunc(false);

    /**
     * Zip two collections to create a map
     *
     * Example:
     * ```
     * pp_R.zipObj.run(pp_R.with('a', 'b'), pp_R.with(1, 2))
     * // {a=1, b=2}
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Map<String, Object>
     */
    public static pp_Func zipObj = new ZipFunc(true);

    /**
     * Create a shuffled collection
     *
     * Example:
     * ```
     * pp_R.shuffle.run('abcdef')
     * // fdeabc
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func shuffle = new ShuffleFunc();

    /**
     * Get a list of random elements
     *
     * Example:
     * ```
     * pp_R.sampleSize.run(2, 'abcdef')
     * // df
     * ```
     *
     * @param size The size of the result list
     * @param target The target object
     * @return List<Object>
     */
    public static pp_Func sampleSize = new SampleFunc();

    /**
     * Get a random element
     *
     * Example:
     * ```
     * pp_R.sample.run('abcdef')
     * // e
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func sample = (pp_Func) pp_R.pipe.run(
            pp_R.sampleSize.apply(1),
            pp_R.first
    );

    // ----------------------------------------------------------------------------
    // --   String                                                               --
    // ----------------------------------------------------------------------------

    /**
     * Check regex match
     *
     * Example:
     * ```
     * pp_R.match.run('.*(a).*', 'cat')
     * // (cat, a)
     * ```
     *
     * @param pattern The regular expression pattern
     * @param target The target object
     * @return List<String> The matched groups
     */
    public static pp_Func match = new MatchFunc();

    /**
     * Replace the string with replacement, only for the first occurrence of the matching
     *
     * Example:
     * ```
     * pp_R.replace.run('cat', 'dog', 'I love cats')
     * // I love dogs
     * ```
     *
     * @param pattern The pattern to search for
     * @param replacement The replacement string
     * @param target The target object
     * @return String
     */
    public static pp_Func replace = new ReplaceFunc(false);

    /**
     * Replace the string with replacement, for all occurrences of the matching
     *
     * Example:
     * ```
     * pp_R.replaceAll.run('cat', 'dog', 'I love cats')
     * // I love dogs
     * ```
     *
     * @param pattern The pattern to search for
     * @param replacement The replacement string
     * @param target The target object
     * @return String
     */
    public static pp_Func replaceAll = new ReplaceFunc(true);

    /**
     * Split the string into a list
     *
     * Example:
     * ```
     * pp_R.split.run(' ', 'a b c')
     * // (a, b, c)
     * ```
     *
     * @param separator The separator string
     * @param target The target object
     * @return List<String>
     */
    public static pp_Func split = new SplitFunc();

    /**
     * Test for the string matching
     *
     * Example:
     * ```
     * pp_R.test.run('.*a.*', 'cat')
     * // true
     * ```
     *
     * @param pattern The regex pattern
     * @param target The target object
     * @return Boolean
     */
    public static pp_Func test = new TestFunc();

    /**
     * Convert the string into uppercase
     *
     * Example:
     * ```
     * pp_R.toUpper.run('abc')
     * // ABC
     * ```
     *
     * @param target The target object
     * @return String
     */
    public static pp_Func toUpper = new ToUpperFunc();

    /**
     * Convert the string into lowercase
     *
     * Example:
     * ```
     * pp_R.toLower.run('ABC')
     * // abc
     * ```
     *
     * @param target The target object
     * @return String
     */
    public static pp_Func toLower = new ToLowerFunc();

    /**
     * Trim the string
     *
     * Example:
     * ```
     * pp_R.trim.run(' abc ')
     * // abc
     * ```
     *
     * @param target The target object
     * @return String
     */
    public static pp_Func trim = new TrimFunc();

    /**
     * Capitalize the string
     *
     * Example:
     * ```
     * pp_R.capitalize.run('cat')
     * // Cat
     * ```
     *
     * @param target The target object
     * @return String
     */
    public static pp_Func capitalize = new CapitalizeFunc();

    /**
     * Pad the string to the length, with given padding
     *
     * Example:
     * ```
     * pp_R.pad.run(5, '*', 'cat')
     * // *cat*
     * ```
     *
     * @param length The target length
     * @param padding The padding string
     * @param target The target object
     * @return String
     */
    public static pp_Func pad = new PadFunc(Padding.Both);

    /**
     * Pad the string to the left to the length, with given padding
     *
     * Example:
     * ```
     * pp_R.pad.run(5, '*', 'cat')
     * // **cat
     * ```
     *
     * @param length The target length
     * @param padding The padding string
     * @param target The target object
     * @return String
     */
    public static pp_Func padLeft = new PadFunc(Padding.Left);

    /**
     * Pad the string to the right to the length, with given padding
     *
     * Example:
     * ```
     * pp_R.pad.run(5, '*', 'cat')
     * // cat**
     * ```
     *
     * @param length The target length
     * @param padding The padding string
     * @param target The target object
     * @return String
     */
    public static pp_Func padRight = new PadFunc(Padding.Right);

    // ----------------------------------------------------------------------------
    // --   SObject && Map                                                       --
    // ----------------------------------------------------------------------------

    /**
     * Check if the wrapped object has a non-null value of the field
     *
     * Example:
     * ```
     * pp_R.has.run('Description', new Account())
     * // false
     * ```
     *
     * @param field The name of the field
     * @param target The target object
     * @return Boolean
     */
    public static pp_Func has = new HasFunc();

    /**
     * Get the property value
     *
     * Example:
     * ```
     * pp_R.prop.run('Description', new Account(Description='desc'))
     * // desc
     * ```
     *
     * @param field The name of the field
     * @param target The target object
     * @return Object
     */
    public static pp_Func prop = new PropFunc();

    /**
     * Get the property value
     *
     * Example:
     * ```
     * pp_R.path.run('Owner.Name', acc)
     * // desc
     * ```
     *
     * @param field The fields, separated by '.'
     * @param target The target object
     * @return Object
     */
    public static pp_Func path = new PathFunc();

    /**
     * Get the property value by 'getSObject'
     *
     * @param field The name of the field
     * @param target The target object(SObject)
     * @return Object
     */
    public static pp_Func propSObject = new PropSObjectFunc();

    /**
     * Get the property value by 'getSObjects'
     *
     * @param field The name of the field
     * @param target The target object(SObject)
     * @return List<Object>
     */
    public static pp_Func propSObjects = new PropSObjectsFunc();

    /**
     * Check that its property value equals given value
     *
     * Example:
     * ```
     * pp_R.propEq.run('Description', 'desc', new Account(Description='desc'))
     * // true
     * ```
     *
     * @param field The name of the field
     * @param value The value to be compared
     * @param target The target object
     * @return Boolean
     */
    public static pp_Func propEq = new PropEqFunc();

    /**
     * Get the property value, or return the default value if it is null
     *
     * Example:
     * ```
     * pp_R.propOr.run('Description', 'desc', new Account())
     * // desc
     * ```
     *
     * @param field The name of the field
     * @param value The default value
     * @param target The target object
     * @return Object
     */
    public static pp_Func propOr = new PropOrFunc();

    /**
     * Check if the property value satisfies the predicate
     *
     * Example:
     * ```
     * pp_R.propSatisfies.run('Description', pp_R.isNotNull, new Account())
     * // false
     * ```
     *
     * @param field The name of the field
     * @param pred The predicate
     * @param target The target object
     * @return Boolean
     */
    public static pp_Func propSatisfies = new PropSatisfiesFunc();

    /**
     * Check if matching the key-values
     *
     * Example:
     * ```
     * pp_R.whereEq.run(pp_R.withObj('Description', 'desc'), new Account(Description='desc'))
     * // true
     * ```
     *
     * @param data The key-values to compare against
     * @param target The target object
     * @return Boolean
     */
    public static pp_Func whereEq = new WhereEqFunc();

    /**
     * Check if matching the key-predicates
     *
     * Example:
     * ```
     * pp_R.whereSatisfies.run(pp_R.withObj('Description', pp_R.isNotNull), new Account(Description='desc'))
     * // true
     * ```
     *
     * @param specs The key-predicates
     * @param target The target object
     * @return Boolean
     */
    public static pp_Func whereSatisfies = new WhereSatisfiesFunc();

    /**
     * Invert the wrapped object, with values mapped by the same key added to a list
     *
     * Example:
     * ```
     * pp_R.invert.run(pp_R.withObj('name', 'test'))
     * // {name=test}
     * ```
     *
     * @param target The target object
     * @return Map<String, Object>
     */
    public static pp_Func invert = new InvertFunc(false);

    /**
     * Invert the wrapped object
     *
     * Example:
     * ```
     * pp_R.invertObj.run(pp_R.withObj('name', 'test'))
     * // {name=test}
     * ```
     *
     * @param target The target object
     * @return Map<String, Object>
     */
    public static pp_Func invertObj = new InvertFunc(true);

    /**
     * Get the keys
     *
     * Example:
     * ```
     * pp_R.keys.run(pp_R.withObj('name', 'test'))
     * // {name}
     * ```
     *
     * @param target The target object
     * @return Set<String>
     */
    public static pp_Func keys = new KeysFunc();

    /**
     * Get the values
     *
     * Example:
     * ```
     * pp_R.values.run(pp_R.withObj('name', 'test'))
     * // (test)
     * ```
     *
     * @param target The target object
     * @return List<Object>
     */
    public static pp_Func values = new ValuesFunc();

    /**
     * Merge the two objects
     *
     * Example:
     * ```
     * pp_R.doMerge.run(pp_R.withObj('name', 'b'), pp_R.withObj('name', 'a'))
     * // {name=b}
     * ```
     *
     * @param arg1 The first object
     * @param arg2 The second object
     * @return Map<String, Object>
     */
    public static pp_Func doMerge = new MergeFunc();

    /**
     * Pick the fields into a map
     *
     * Example:
     * ```
     * pp_R.pick.run(pp_R.with('Description'), new Account(Description='desc', FirstName='name'))
     * // {Description=desc}
     * ```
     *
     * @param fields The fields to pick
     * @param target The target object
     * @return Map<String, Object>
     */
    public static pp_Func pick = new PickFunc();

    /**
     * Omit the fields and pick remaining fields into a map
     *
     * Example:
     * ```
     * pp_R.omit.run(pp_R.with('Description'), new Account(Description='desc', FirstName='name'))
     * // {FirstName=name}
     * ```
     *
     * @param fields The fields to pick
     * @param target The target object
     * @return Map<String, Object>
     */
    public static pp_Func omit = new OmitFunc();

    // ----------------------------------------------------------------------------
    // --   Utility                                                              --
    // ----------------------------------------------------------------------------

    /**
     * Check if it is null
     *
     * Example:
     * ```
     * pp_R.isNil.run(null)
     * // true
     * ```
     *
     * @param target The target object
     * @return Boolean
     */
    public static pp_Func isNil = new IsNilFunc();

    /**
     * Same as isNil
     *
     * @see isNill
     */
    public static pp_Func isNull = isNil;

    /**
     * Check if it is not null
     *
     * Example:
     * ```
     * pp_R.isNotNil.run(null)
     * // false
     * ```
     *
     * @param target The target object
     * @return Boolean
     */
    public static pp_Func isNotNil = (pp_Func) pp_R.complement.run(pp_R.isNil);

    /**
     * Same as isNotNil
     *
     * @see isNotNil
     */
    public static pp_Func isNotNull = isNotNil;

    /**
     * Check if it is number
     *
     * Example:
     * ```
     * pp_R.isNumber.run(1)
     * // true
     * ```
     *
     * @param target The target object
     * @return Boolean
     */
    public static pp_Func isNumber = new IsNumberFunc();

    /**
     * No op function
     *
     * Example:
     * ```
     * pp_R.noop.run()
     * // null
     * ```
     *
     * @param <args> No argument will be used
     * @return null Meaningless null is returned
     */
    public static pp_Func noop = pp_R.placeholder;

    /**
     * Default to a value
     *
     * Example:
     * ```
     * pp_R.defaultTo.run(5, null)
     * // 5
     * ```
     *
     * @param defaultValue The default value
     * @param target The target object
     * @return Object
     */
    public static pp_Func defaultTo = new DefaultToFunc();

    /**
     * Get the clone
     *
     * Example:
     * ```
     * pp_R.doClone.run(new Account())
     * // Account:{}
     * ```
     *
     * @param target The target object
     * @return Object
     */
    public static pp_Func doClone = new CloneFunc();

    /**
     * Print the debug log
     *
     * Example:
     * ```
     * pp_R.debug.run(1)
     * // 1
     * ```
     *
     * @param <args> Arguments to debug
     * @return Object
     */
    public static pp_Func debug = new DebugFunc();

    /**
     * A function that always returns true
     *
     * Example:
     * ```
     * pp_R.T.run()
     * // true
     * ```
     *
     * @return true
     */
    public static pp_Func T = (pp_Func) pp_R.always.run(true);

    /**
     * A function that always returns false
     *
     * Example:
     * ```
     * pp_R.F.run()
     * // false
     * ```
     *
     * @return false
     */
    public static pp_Func F = (pp_Func) pp_R.always.run(false);

    /**
     * Remove any null value from the elements
     *
     * Example:
     * ```
     * pp_R.compact.run(pp_R.with(1, null, 2))
     * // (1, 2)
     * ```
     *
     * @param target The target object
     * @return List<Object>
     */
    public static pp_Func compact = pp_R.filter.apply(pp_R.isNotNil);

    /**
     * Do assert condition
     *
     * Example:
     * ```
     * pp_R.assert.run(1 == 1, 'should equal');
     * ```
     *
     * @param condition The condition
     * @param msg The optional message
     * @return null
     */
    public static pp_Func assert = new AssertFunc();

    /**
     * Do assert equals
     *
     * Example:
     * ```
     * pp_R.assertAreEqual.run(1, 1, 'should equal');
     * ```
     *
     * @param expected The expected value
     * @param actual The actual value
     * @param msg The optional message
     * @return null
     */
    public static pp_Func assertAreEqual = new AssertAreEqualFunc();

    /**
     * Do assert not equals
     *
     * Example:
     * ```
     * pp_R.assertAreNotEqual.run(1, 2, 'should not equal');
     * ```
     *
     * @param expected The expected value
     * @param actual The actual value
     * @param msg The optional message
     * @return null
     */
    public static pp_Func assertAreNotEqual = new AssertAreNotEqualFunc();

    // ----------------------------------------------------------------------------
    // --   DML                                                                  --
    // ----------------------------------------------------------------------------

    /**
     * Query SObject(s) from database
     *
     * Example:
     * ```
     * pp_R.dbQuery.run('SELECT Id FROM Account');
     * ```
     *
     * @param query The query string
     * @return Object
     */
    public static pp_Func dbQuery = new DbQueryFunc();

    /**
     * Insert SObject(s) to database
     *
     * Example:
     * ```
     * pp_R.dbInsert.run(new Account());
     * ```
     *
     * @param obj The SObject(s)
     * @return Object
     */
    public static pp_Func dbInsert = new DbInsertFunc();

    /**
     * Update SObject(s) to database
     *
     * Example:
     * ```
     * pp_R.dbUpdate.run(acc);
     * ```
     *
     * @param obj The SObject(s)
     * @return Object
     */
    public static pp_Func dbUpdate = new DbUpdateFunc();

    /**
     * Delete SObject(s) to database
     *
     * Example:
     * ```
     * pp_R.dbDelete.run(acc);
     * ```
     *
     * @param obj The SObject(s)
     * @return Object
     */
    public static pp_Func dbDelete = new DbDeleteFunc();

    // EOF(End of Function List)

    public static final Map<String, pp_Func> API = new Map<String, pp_Func>{
            'toBoolean' => toBoolean,
            'toBooleanList' => toBooleanList,
            'toBooleanMap' => toBooleanMap,
            'toInteger' => toInteger,
            'toIntegerList' => toIntegerList,
            'toIntegerMap' => toIntegerMap,
            'toLong' => toLong,
            'toLongList' => toLongList,
            'toLongMap' => toLongMap,
            'toDouble' => toDouble,
            'toDoubleList' => toDoubleList,
            'toDoubleMap' => toDoubleMap,
            'toDecimal' => toDecimal,
            'toDecimalList' => toDecimalList,
            'toDecimalMap' => toDecimalMap,
            'toString' => toString,
            'isStringLike' => isStringLike,
            'toStringList' => toStringList,
            'toStringMap' => toStringMap,
            'toCharList' => toCharList,
            'toDate' => toDate,
            'toDateList' => toDateList,
            'toDateMap' => toDateMap,
            'toTime' => toTime,
            'toTimeList' => toTimeList,
            'toTimeMap' => toTimeMap,
            'toDatetime' => toDatetime,
            'toDatetimeList' => toDatetimeList,
            'toDatetimeMap' => toDatetimeMap,
            'toFunc' => toFunc,
            'isFuncLike' => isFuncLike,
            'toFuncList' => toFuncList,
            'toFuncMap' => toFuncMap,
            'toList' => toList,
            'isListLike' => isListLike,
            'toSet' => toSet,
            'toIdSet' => toIdSet,
            'isSetLike' => isSetLike,
            'toMap' => toMap,
            'isMapLike' => isMapLike,
            'toMapList' => toMapList,
            'toPair' => toPair,
            'isPairLike' => isPairLike,
            'toPairList' => toPairList,
            'toPairMap' => toPairMap,
            'toSObject' => toSObject,
            'isSObjectLike' => isSObjectLike,
            'toSObjectList' => toSObjectList,
            'toSObjectMap' => toSObjectMap,
            'add' => add,
            'subtract' => subtract,
            'multiply' => multiply,
            'divide' => divide,
            'mod' => mod,
            'inc' => inc,
            'dec' => dec,
            'negate' => negate,
            'product' => product,
            'allPass' => allPass,
            'anyPass' => anyPass,
            'complement' => complement,
            'doAnd' => doAnd,
            'doOr' => doOr,
            'doNot' => doNot,
            'equals' => equals,
            'lt' => lt,
            'lte' => lte,
            'gt' => gt,
            'gte' => gte,
            'min' => min,
            'max' => max,
            'placeholder' => placeholder,
            'pipe' => pipe,
            'compose' => compose,
            'flip' => flip,
            'converge' => converge,
            'useWith' => useWith,
            'identity' => identity,
            'always' => always,
            'constant' => constant,
            'throwException' => throwException,
            'once' => once,
            'memoize' => memoize,
            'nAry' => nAry,
            'unary' => unary,
            'binary' => binary,
            'transform' => transform,
            'applySpec' => applySpec,
            'juxt' => juxt,
            'evolve' => evolve,
            'comparator' => comparator,
            'compare' => compare,
            'ascend' => ascend,
            'descend' => descend,
            'cascade' => cascade,
            'clamp' => clamp,
            'cond' => cond,
            'ifElse' => ifElse,
            'doWhen' => doWhen,
            'unless' => unless,
            'forEach' => forEach,
            'filter' => filter,
            'reject' => reject,
            'doMap' => doMap,
            'biMap' => biMap,
            'pluck' => pluck,
            'reduce' => reduce,
            'length' => length,
            'size' => size,
            'isEmpty' => isEmpty,
            'isNotEmpty' => isNotEmpty,
            'sum' => sum,
            'slice' => slice,
            'take' => take,
            'takeRight' => takeRight,
            'takeWhile' => takeWhile,
            'takeRightWhile' => takeRightWhile,
            'drop' => drop,
            'dropRight' => dropRight,
            'dropWhile' => dropWhile,
            'dropRightWhile' => dropRightWhile,
            'reverse' => reverse,
            'sortBy' => sortBy,
            'sortDefault' => sortDefault,
            'contains' => contains,
            'containsBy' => containsBy,
            'containsKey' => containsKey,
            'uniq' => uniq,
            'union' => union,
            'intersection' => intersection,
            'xor' => xor,
            'difference' => difference,
            'without' => without,
            'adjust' => adjust,
            'all' => all,
            'every' => every,
            'some' => some,
            'none' => none,
            'append' => append,
            'prepend' => prepend,
            'assoc' => assoc,
            'dissoc' => dissoc,
            'concat' => concat,
            'countBy' => countBy,
            'groupBy' => groupBy,
            'indexBy' => indexBy,
            'startsWith' => startsWith,
            'endsWith' => endsWith,
            'find' => find,
            'findLast' => findLast,
            'findIndex' => findIndex,
            'findLastIndex' => findLastIndex,
            'unnest' => unnest,
            'flatten' => flatten,
            'pair' => pair,
            'fromPairs' => fromPairs,
            'toPairs' => toPairs,
            'first' => first,
            'head' => head,
            'last' => last,
            'init' => init,
            'tail' => tail,
            'indexOf' => indexOf,
            'lastIndexOf' => lastIndexOf,
            'doInsert' => doInsert,
            'doInsertAll' => doInsertAll,
            'doJoin' => doJoin,
            'nth' => nth,
            'partition' => partition,
            'project' => project,
            'range' => range,
            'remove' => remove,
            'repeat' => repeat,
            'times' => times,
            'doUpdate' => doUpdate,
            'zip' => zip,
            'zipObj' => zipObj,
            'shuffle' => shuffle,
            'sampleSize' => sampleSize,
            'sample' => sample,
            'match' => match,
            'replace' => replace,
            'replaceAll' => replaceAll,
            'split' => split,
            'test' => test,
            'toUpper' => toUpper,
            'toLower' => toLower,
            'trim' => trim,
            'capitalize' => capitalize,
            'pad' => pad,
            'padLeft' => padLeft,
            'padRight' => padRight,
            'has' => has,
            'prop' => prop,
            'propSObject' => propSObject,
            'propSObjects' => propSObjects,
            'propEq' => propEq,
            'propOr' => propOr,
            'propSatisfies' => propSatisfies,
            'whereEq' => whereEq,
            'whereSatisfies' => whereSatisfies,
            'invert' => invert,
            'invertObj' => invertObj,
            'keys' => keys,
            'values' => values,
            'doMerge' => doMerge,
            'pick' => pick,
            'omit' => omit,
            'isNil' => isNil,
            'isNull' => isNull,
            'isNotNil' => isNotNil,
            'isNotNull' => isNotNull,
            'isNumber' => isNumber,
            'noop' => noop,
            'defaultTo' => defaultTo,
            'doClone' => doClone,
            'debug' => debug,
            'T' => T,
            'F' => F,
            'compact' => compact,
            'assert' => assert,
            'assertAreEqual' => assertAreEqual,
            'assertAreNotEqual' => assertAreNotEqual,
            'dbInsert' => dbInsert,
            'dbUpdate' => dbUpdate,
            'dbDelete' => dbDelete,
            'path' => path
    };


    // ----------------------------------------------------------------------------
    // --   Local Common Functions                                               --
    // ----------------------------------------------------------------------------
    private static Map<String, Object> functionalCache = new Map<String, Object>();
    private static Map<String, Pattern> patternCache = new Map<String, Pattern>();
    private static List<Object> EMPTY_LIST = new List<Object>();
    private static Set<String> EMPTY_SET = new Set<String>();
    private static Map<String, Object> EMPTY_MAP = new Map<String, Object>();
    private static String EMPTY_STRING = '';

    private static Object doClone(Object source) {
        return pp_R.doClone.run(source);
    }

    private static List<pp_Func> toFuncList(Object arg) {
        return toFuncList(arg, false);
    }

    private static List<pp_Func> toFuncList(Object arg, Boolean reverse) {
        if (!reverse) {
            return (List<pp_Func>) pp_R.toFuncList.run(arg);
        } else {
            return (List<pp_Func>) pp_R.toFuncList.run(pp_R.reverse.run(arg));
        }
    }

    private static Integer getIndexInRange(Integer index, Integer size) {
        return index < 0 ? size + index : index;
    }

    private static Boolean isNumber(Object target) {
        return (Boolean) pp_R.isNumber.run(target);
    }

    private static Boolean toBoolean(Object arg) {
        return (Boolean) pp_R.toBoolean.run(arg);
    }

    private static Integer toInteger(Object arg) {
        return (Integer) pp_R.toInteger.run(arg);
    }

    private static Long toLong(Object arg) {
        return (Long) pp_R.toLong.run(arg);
    }

    private static Decimal toDecimal(Object arg) {
        return (Decimal) pp_R.toDecimal.run(arg);
    }

    private static List<Decimal> toDecimalList(Object arg) {
        return (List<Decimal>) pp_R.toDecimalList.run(arg);
    }

    private static Double toDouble(Object arg) {
        return (Double) pp_R.toDouble.run(arg);
    }

    private static String toString(Object arg) {
        return (String) pp_R.toString.run(arg);
    }

    private static List<String> toCharList(Object arg) {
        return (List<String>) pp_R.toCharList.run(arg);
    }

    private static Boolean isStringLike(Object arg) {
        return (Boolean) pp_R.isStringLike.run(arg);
    }

    private static Date toDate(Object arg) {
        return (Date) pp_R.toDate.run(arg);
    }

    private static Time toTime(Object arg) {
        return (Time) pp_R.toTime.run(arg);
    }

    private static Datetime toDatetime(Object arg) {
        return (Datetime) pp_R.toDatetime.run(arg);
    }

    private static pp_Func toFunc(Object arg) {
        return (pp_Func) pp_R.toFunc.run(arg);
    }

    private static Boolean isSObjectLike(Object arg) {
        return (Boolean) pp_R.isSObjectLike.run(arg);
    }

    private static SObject toSObject(Object arg) {
        return (SObject) pp_R.toSObject.run(arg);
    }

    private static List<Object> toList(Object arg) {
        return (List<Object>) pp_R.toList.run(arg);
    }

    private static List<Integer> toIntegerList(Object arg) {
        return (List<Integer>) pp_R.toIntegerList.run(arg);
    }

    private static List<String> toStringList(Object arg) {
        return (List<String>) pp_R.toStringList.run(arg);
    }

    private static Boolean isListLike(Object arg) {
        return (Boolean) pp_R.isListLike.run(arg);
    }

    private static Set<String> toSet(Object arg) {
        return (Set<String>) pp_R.toSet.run(arg);
    }

    private static Boolean isSetLike(Object arg) {
        return (Boolean) pp_R.isSetLike.run(arg);
    }

    private static Map<String, Object> toMap(Object arg) {
        return (Map<String, Object>) pp_R.toMap.run(arg);
    }

    private static Boolean isMapLike(Object arg) {
        return (Boolean) pp_R.isMapLike.run(arg);
    }

    private static List<Map<String, Object>> toMapList(Object arg) {
        return (List<Map<String, Object>>) pp_R.toMapList.run(arg);
    }

    private static Pair toPair(Object arg) {
        return (Pair) pp_R.toPair.run(arg);
    }

    private static Boolean isPairLike(Object arg) {
        return (Boolean) pp_R.isPairLike.run(arg);
    }

    private static List<Pair> toPairList(Object arg) {
        return (List<Pair>) pp_R.toPairList.run(arg);
    }

    private static Map<String, Pair> toPairMap(Object arg) {
        return (Map<String, Pair>) pp_R.toPairMap.run(arg);
    }

    private static Map<String, pp_Func> toFuncMap(Object arg) {
        return (Map<String, pp_Func>) pp_R.toFuncMap.run(arg);
    }

    private static Boolean isFuncLike(Object arg) {
        return (Boolean) pp_R.isFuncLike.run(arg);
    }

    private static List<Object> slice(Integer first, Integer last, List<Object> mList) {
        return (List<Object>) pp_R.slice.run(first, last, mList);
    }

    private static List<Object> slice(Integer first, List<Object> mList) {
        return slice(first, mList.size(), mList);
    }

    private static Integer compare(Object a, Object b) {
        return (Integer) pp_R.compare.run(a, b);
    }

    private static Boolean equals(Object a, Object b) {
        return (Boolean) pp_R.equals.run(a, b);
    }

    private static Object getNthElement(Integer index, List<Object> args) {
        return pp_R.nth.run(index, args);
    }

    // ----------------------------------------------------------------------------
    // --   Helper classes                                                       --
    // ----------------------------------------------------------------------------
    private class ComparableWrapper implements Comparable {
        private Object val;
        private pp_Func comparator;

        public ComparableWrapper(Object val, pp_Func comparator) {
            this.val = val;
            this.comparator = comparator;
        }

        public Object getVal() {
            return this.val;
        }

        public Integer compareTo(Object other) {
            Object otherVal = ((ComparableWrapper) other).val;

            return toInteger(this.comparator.run(this.val, otherVal));
        }
    }

    public class Pair {
        public Object fst;
        public Object snd;

        public Pair(Object fst, Object snd) {
            this.fst = fst;
            this.snd = snd;
        }

        public Boolean equals(Object other) {
            if (other instanceof Pair) {
                Pair otherPair = (Pair) other;

                return this.fst == otherPair.fst && this.snd == otherPair.snd;
            }

            return false;
        }

        public Integer hashCode() {
            return (this.fst == null ? 0 : this.fst.hashCode()) + (this.snd == null ? 0 : this.snd.hashCode());
        }
    }

    public enum Padding {
        Left,
        Right,
        Both
    }


    // ----------------------------------------------------------------------------
    // --   Intermediate Helper Function Classes                                 --
    // ----------------------------------------------------------------------------
    private class FuncList extends pp_Func {
        private List<pp_Func> funcs;

        public FuncList(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object execN(List<Object> args) {
            Object ret = this.funcs.get(0).runN(args);

            for (Integer i = 1; i < this.funcs.size(); i++) {
                ret = this.funcs.get(i).run(ret);
            }

            return ret;
        }
    }

    private class FuncAll extends pp_Func {
        private List<pp_Func> funcs;

        public FuncAll(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object execN(List<Object> args) {
            for (pp_Func func : this.funcs) {
                Boolean pass = toBoolean(func.runN(args));
                if (!pass) {
                    return false;
                }
            }

            return true;
        }
    }

    private class FuncAny extends pp_Func {
        private List<pp_Func> funcs;

        public FuncAny(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object execN(List<Object> args) {
            for (pp_Func func : this.funcs) {
                Boolean pass = toBoolean(func.runN(args));
                if (pass) {
                    return true;
                }
            }

            return false;
        }
    }

    private class FuncComplement extends pp_Func {
        private pp_Func target;

        public FuncComplement(pp_Func target) {
            this.target = target;
        }

        public override Object execN(List<Object> args) {
            Boolean pass = toBoolean(this.target.runN(args));
            return !pass;
        }
    }

    private class FuncCond extends pp_Func {
        private List<pp_Func> funcs;

        public FuncCond(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object execN(List<Object> args) {
            for (Integer i = 0; i < this.funcs.size() - 1; i += 2) {
                pp_Func pred = this.funcs.get(i);
                Boolean pass = toBoolean(pred.runN(args));
                if (pass) {
                    pp_Func next = this.funcs.get(i + 1);
                    return next.runN(args);
                }
            }

            throw new pp_Func.FuncException('Case left unhandled');
        }
    }

    private class FuncIfElse extends pp_Func {
        private List<pp_Func> funcs;

        public FuncIfElse(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object execN(List<Object> args) {
            if (this.funcs.size() >= 3) {
                pp_Func pred = this.funcs.get(0);
                pp_Func next = this.funcs.get(1);
                pp_Func otherwise = this.funcs.get(2);
                Boolean pass = toBoolean(pred.runN(args));
                if (pass) {
                    return next.runN(args);
                } else {
                    return otherwise.runN(args);
                }
            }

            throw new pp_Func.FuncException('at least 3 function objects are needed');
        }
    }

    private class FuncWhen extends pp_Func {
        private List<pp_Func> funcs;

        public FuncWhen(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object execN(List<Object> args) {
            if (this.funcs.size() >= 2) {
                pp_Func pred = this.funcs.get(0);
                pp_Func next = this.funcs.get(1);
                Boolean pass = toBoolean(pred.runN(args));
                if (pass) {
                    return next.runN(args);
                }
            }

            return args;
        }
    }

    private class FuncUnless extends pp_Func {
        private List<pp_Func> funcs;

        public FuncUnless(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object execN(List<Object> args) {
            if (this.funcs.size() >= 2) {
                pp_Func pred = this.funcs.get(0);
                pp_Func next = this.funcs.get(1);
                Boolean pass = toBoolean(pred.runN(args));
                if (!pass) {
                    return next.runN(args);
                }
            }

            return args;
        }
    }

    private class FuncAlways extends pp_Func {
        private Object val;

        public FuncAlways(Object val) {
            this.val = val;
        }

        public override Object execN(List<Object> args) {
            return this.val;
        }
    }

    private class FuncFlip extends pp_Func {
        private pp_Func targetF;

        public FuncFlip(pp_Func targetF) {
            this.targetF = targetF;
        }

        public override Object execN(List<Object> args) {
            if (args.size() >= 2) {
                Object arg1 = args.get(0);
                Object arg2 = args.get(1);
                args.set(0, arg2);
                args.set(1, arg1);
            }

            return this.targetF.runN(args);
        }
    }

    private class FuncConverge extends pp_Func {
        private List<pp_Func> funcs;

        public FuncConverge(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object execN(List<Object> args) {
            pp_Func targetF = this.funcs.get(0);
            List<Object> newArgs = new List<Object>();
            for (Integer i = 1; i < this.funcs.size(); i++) {
                newArgs.add(this.funcs.get(i).runN(args));
            }

            return targetF.runN(newArgs);
        }
    }

    private class FuncUseWith extends pp_Func {
        private List<pp_Func> funcs;

        public FuncUseWith(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object execN(List<Object> args) {
            pp_Func targetF = this.funcs.get(0);
            List<Object> newArgs = new List<Object>();
            for (Integer i = 1; i < this.funcs.size(); i++) {
                Object newArg = null;
                if (i - 1 < args.size()) {
                    newArg = args.get(i - 1);
                }
                newArgs.add(this.funcs.get(i).run(newArg));
            }

            return targetF.runN(newArgs);
        }
    }

    private class FuncOnce extends pp_Func {
        private pp_Func targetF;
        private String name;

        public FuncOnce(pp_Func targetF, String name) {
            this.targetF = targetF;
            this.name = name;
        }

        public override Object execN(List<Object> args) {
            Boolean invoked = functionalCache.containsKey(this.name);
            if (!invoked) {
                functionalCache.put(this.name, this.targetF.runN(args));
            }

            return functionalCache.get(this.name);
        }
    }

    private class FuncMemoize extends pp_Func {
        private pp_Func targetF;
        private String name;
        private pp_Func fn;

        public FuncMemoize(pp_Func targetF, String name, pp_Func fn) {
            this.targetF = targetF;
            this.name = name;
            this.fn = fn;
        }

        public override Object execN(List<Object> args) {
            String key = this.name + '_' + toString(fn.runN(args));
            if (!functionalCache.containsKey(key)) {
                functionalCache.put(key, this.targetF.runN(args));
            }

            return functionalCache.get(key);
        }
    }

    private class FuncNAry extends pp_Func {
        private Integer arity;
        private pp_Func fn;

        public FuncNAry(Integer arity, pp_Func fn) {
            this.arity = arity;
            this.fn = fn;
        }

        public override Object execN(List<Object> args) {
            List<Object> newArgs = new List<Object>();
            for (Integer i = 0; i < this.arity; i++) {
                if (i < args.size()) {
                    newArgs.add(args.get(i));
                } else {
                    newArgs.add(null);
                }
            }

            return this.fn.runN(newArgs);
        }
    }

    private class FuncComparator extends pp_Func {
        private pp_Func fn;

        public FuncComparator(pp_Func fn) {
            this.fn = fn;
        }

        public override Object exec(Object arg1, Object arg2) {
            Boolean ret = toBoolean(this.fn.run(arg1, arg2));

            return ret ? -1 : 1;
        }
    }

    private class FuncSortDirection extends pp_Func {
        private pp_Func fn;
        private Boolean isAscend;

        public FuncSortDirection(pp_Func fn, Boolean isAscend) {
            this.fn = fn;
            this.isAscend = isAscend;
        }

        public override Object exec(Object arg1, Object arg2) {
            Object val1 = this.fn.run(arg1);
            Object val2 = this.fn.run(arg2);
            Integer ret = toInteger(pp_R.compare.run(val1, val2));
            return this.isAscend ? ret : -ret;
        }
    }

    private class FuncCascade extends pp_Func {
        private List<pp_Func> funcs;

        public FuncCascade(List<pp_Func> funcs) {
            this.funcs = funcs;
        }

        public override Object exec(Object arg1, Object arg2) {
            for (pp_Func fn : this.funcs) {
                Integer ret = toInteger(fn.run(arg1, arg2));
                if (ret != 0) {
                    return ret;
                }
            }

            return 0;
        }
    }

    private class FuncComparable extends pp_Func {
        private Comparable comp;

        public FuncComparable(Comparable comp) {
            this.comp = comp;
        }

        public override Object exec(Object arg) {
            return this.comp.compareTo(arg);
        }
    }


    // ----------------------------------------------------------------------------
    // --   Function Classes                                                     --
    // ----------------------------------------------------------------------------
    private class ToBooleanFunc extends pp_Func {
        public ToBooleanFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return false;
            } else if (arg instanceof Boolean) {
                return (Boolean) arg;
            } else if (arg instanceof Integer) {
                return (Integer) arg != 0;
            } else if (arg instanceof Long) {
                return (Long) arg != 0;
            } else if (arg instanceof Double) {
                return (Double) arg != 0;
            } else if (arg instanceof Decimal) {
                return (Decimal) arg != 0;
            } else if (arg instanceof String) {
                return Boolean.valueOf((String) arg);
            } else {
                return true;
            }
        }
    }

    private class ToBooleanListFunc extends pp_Func {
        public ToBooleanListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Boolean> newList = new List<Boolean>();

            for (Object obj : mList) {
                newList.add(toBoolean(obj));
            }

            return newList;
        }
    }

    private class ToBooleanMapFunc extends pp_Func {
        public ToBooleanMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, Boolean> newMap = new Map<String, Boolean>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toBoolean(val));
            }

            return newMap;
        }
    }

    private class ToIntegerFunc extends pp_Func {
        public ToIntegerFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return null;
            } else if (arg instanceof Integer) {
                return (Integer) arg;
            } else if (arg instanceof Long) {
                return ((Long) arg).intValue();
            } else if (arg instanceof Double) {
                return ((Double) arg).intValue();
            } else if (arg instanceof Decimal) {
                return ((Decimal) arg).intValue();
            } else if (arg instanceof String) {
                return Integer.valueOf((String) arg);
            }

            throw new pp_Func.FuncException('Cannot convert arg to Integer');
        }
    }

    private class ToIntegerListFunc extends pp_Func {
        public ToIntegerListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Integer> newList = new List<Integer>();

            for (Object obj : mList) {
                newList.add(toInteger(obj));
            }

            return newList;
        }
    }

    private class ToIntegerMapFunc extends pp_Func {
        public ToIntegerMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, Integer> newMap = new Map<String, Integer>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toInteger(val));
            }

            return newMap;
        }
    }

    private class ToLongFunc extends pp_Func {
        public ToLongFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return null;
            } else if (arg instanceof Long) {
                return (Long) arg;
            } else if (arg instanceof Integer) {
                return (Integer) arg;
            } else if (arg instanceof Decimal) {
                return ((Decimal) arg).longValue();
            } else if (arg instanceof Double) {
                return ((Double) arg).longValue();
            } else if (arg instanceof String) {
                return Long.valueOf((String) arg);
            }

            throw new pp_Func.FuncException('Cannot convert arg to Long');
        }
    }

    private class ToLongListFunc extends pp_Func {
        public ToLongListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Long> newList = new List<Long>();

            for (Object obj : mList) {
                newList.add(toLong(obj));
            }

            return newList;
        }
    }

    private class ToLongMapFunc extends pp_Func {
        public ToLongMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, Long> newMap = new Map<String, Long>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toLong(val));
            }

            return newMap;
        }
    }

    private class ToDoubleFunc extends pp_Func {
        public ToDoubleFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return null;
            } else if (arg instanceof Double) {
                return (Double) arg;
            } else if (arg instanceof Integer) {
                return (Integer) arg;
            } else if (arg instanceof Long) {
                return (Long) arg;
            } else if (arg instanceof Decimal) {
                return ((Decimal) arg).doubleValue();
            } else if (arg instanceof String) {
                return Double.valueOf((String) arg);
            }

            throw new pp_Func.FuncException('Cannot convert arg to Double');
        }
    }

    private class ToDoubleListFunc extends pp_Func {
        public ToDoubleListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Double> newList = new List<Double>();

            for (Object obj : mList) {
                newList.add(toDouble(obj));
            }

            return newList;
        }
    }

    private class ToDoubleMapFunc extends pp_Func {
        public ToDoubleMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, Double> newMap = new Map<String, Double>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toDouble(val));
            }

            return newMap;
        }
    }

    private class ToDecimalFunc extends pp_Func {
        public ToDecimalFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return null;
            } else if (arg instanceof Decimal) {
                return (Decimal) arg;
            } else if (arg instanceof Double) {
                return Decimal.valueOf((Double) arg);
            } else if (arg instanceof Integer) {
                return Decimal.valueOf((Integer) arg);
            } else if (arg instanceof Long) {
                return Decimal.valueOf((Long) arg);
            } else if (arg instanceof String) {
                return Decimal.valueOf((String) arg);
            }

            throw new pp_Func.FuncException('Cannot convert arg to Decimal');
        }
    }

    private class ToDecimalListFunc extends pp_Func {
        public ToDecimalListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Decimal> newList = new List<Decimal>();

            for (Object obj : mList) {
                newList.add(toDecimal(obj));
            }

            return newList;
        }
    }

    private class ToDecimalMapFunc extends pp_Func {
        public ToDecimalMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, Decimal> newMap = new Map<String, Decimal>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toDecimal(val));
            }

            return newMap;
        }
    }

    private class ToStringFunc extends pp_Func {
        public ToStringFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return null;
            } else if (arg instanceof pp_R && ((pp_R) arg).isString()) {
                return ((pp_R) arg).toString();
            } else if (arg instanceof Datetime) {
                return JSON.serialize(arg).replaceAll('"', '');
            } else if (arg instanceof Map<String, Object>) {
                return JSON.serialize(arg);
            } else if (arg instanceof List<Object>) {
                return JSON.serialize(arg);
            } else {
                return String.valueOf(arg);
            }
        }
    }

    private class IsStringLikeFunc extends pp_Func {
        public IsStringLikeFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return arg != null && arg instanceof String;
        }
    }

    private class ToStringListFunc extends pp_Func {
        public ToStringListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<String> newList = new List<String>();

            for (Object obj : mList) {
                newList.add(toString(obj));
            }

            return newList;
        }
    }

    private class ToStringMapFunc extends pp_Func {
        public ToStringMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, String> newMap = new Map<String, String>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toString(val));
            }

            return newMap;
        }
    }

    private class ToCharListFunc extends pp_Func {
        public ToCharListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            String str = toString(arg);
            List<String> newList = null;

            if (str == null || str == '') {
                newList = new List<String>();
            } else {
                newList = str.split('');
            }

            return newList;
        }
    }

    private class ToDateFunc extends pp_Func {
        public ToDateFunc() {
            super(1);
        }

        private Date getDate(Long millis) {
            return Datetime.newInstance(millis).date();
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return null;
            } else if (arg instanceof Date) {
                return (Date) arg;
            } else if (arg instanceof Datetime) {
                return ((Datetime) arg).date();
            } else if (arg instanceof Integer) {
                Long millis = (Long) arg;
                return getDate(millis);
            } else if (arg instanceof Long) {
                Long millis = (Long) arg;
                return getDate(millis);
            } else if (arg instanceof Double) {
                Long millis = ((Double) arg).longValue();
                return getDate(millis);
            } else if (arg instanceof Decimal) {
                Long millis = ((Decimal) arg).longValue();
                return getDate(millis);
            } else if (arg instanceof String) {
                try {
                    return Date.valueOf((String) arg);
                } catch (Exception e1) {
                    try {
                        if (String.isBlank((String) arg)) {
                            System.debug(LoggingLevel.Error, 'Cannot convert this value to Date:' + arg);
                            return null;
                        }
                        return JSON.deserialize('"' + arg + '"', Date.class);
                    } catch (Exception e2) {
                        System.debug(LoggingLevel.Error, e2);
                        return null;
                    }
                }
            }

            throw new pp_Func.FuncException('Cannot convert arg to Date');
        }
    }

    private class ToDateListFunc extends pp_Func {
        public ToDateListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Date> newList = new List<Date>();

            for (Object obj : mList) {
                newList.add(toDate(obj));
            }

            return newList;
        }
    }

    private class ToDateMapFunc extends pp_Func {
        public ToDateMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, Date> newMap = new Map<String, Date>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toDate(val));
            }

            return newMap;
        }
    }

    private class ToTimeFunc extends pp_Func {
        public ToTimeFunc() {
            super(1);
        }

        private Time getTime(Long millis) {
            return Datetime.newInstance(millis).time();
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return null;
            } else if (arg instanceof Time) {
                return (Time) arg;
            } else if (arg instanceof Integer) {
                Long millis = (Long) arg;
                return getTime(millis);
            } else if (arg instanceof Long) {
                Long millis = (Long) arg;
                return getTime(millis);
            } else if (arg instanceof Double) {
                Long millis = ((Double) arg).longValue();
                return getTime(millis);
            } else if (arg instanceof Decimal) {
                Long millis = ((Decimal) arg).longValue();
                return getTime(millis);
            }

            throw new pp_Func.FuncException('Cannot convert arg to Time');
        }
    }

    private class ToTimeListFunc extends pp_Func {
        public ToTimeListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Time> newList = new List<Time>();

            for (Object obj : mList) {
                newList.add(toTime(obj));
            }

            return newList;
        }
    }

    private class ToTimeMapFunc extends pp_Func {
        public ToTimeMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, Time> newMap = new Map<String, Time>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toTime(val));
            }

            return newMap;
        }
    }

    private class ToDatetimeFunc extends pp_Func {
        public ToDatetimeFunc() {
            super(1);
        }

        private Datetime getDatetime(Long millis) {
            return Datetime.newInstance(millis);
        }

        private Datetime getDatetime(Date d) {
            return Datetime.newInstance(d.year(), d.month(), d.day());
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return null;
            } else if (arg instanceof Date) {
                return getDatetime((Date) arg);
            } else if (arg instanceof Datetime) {
                return (Datetime) arg;
            } else if (arg instanceof Integer) {
                Long millis = (Long) arg;
                return getDatetime(millis);
            } else if (arg instanceof Long) {
                Long millis = (Long) arg;
                return getDatetime(millis);
            } else if (arg instanceof Double) {
                Long millis = ((Double) arg).longValue();
                return getDatetime(millis);
            } else if (arg instanceof Decimal) {
                Long millis = ((Decimal) arg).longValue();
                return getDatetime(millis);
            } else if (arg instanceof String) {
                try {
                    return Datetime.valueOf((String) arg);
                } catch (Exception e1) {
                    try {
                        if (String.isBlank((String) arg)) {
                            System.debug(LoggingLevel.Error, 'Cannot convert this value to Datetime:' + arg);
                            return null;
                        }
                        return JSON.deserialize('"' + arg + '"', Datetime.class);
                    } catch (Exception e2) {
                        System.debug(LoggingLevel.Error, e2);
                        return null;
                    }
                }
            }

            throw new pp_Func.FuncException('Cannot convert arg to Datetime');
        }
    }

    private class ToDatetimeListFunc extends pp_Func {
        public ToDatetimeListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Datetime> newList = new List<Datetime>();

            for (Object obj : mList) {
                newList.add(toDatetime(obj));
            }

            return newList;
        }
    }

    private class ToDatetimeMapFunc extends pp_Func {
        public ToDatetimeMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, Datetime> newMap = new Map<String, Datetime>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toDatetime(val));
            }

            return newMap;
        }
    }

    private class IsFuncLikeFunc extends pp_Func {
        public IsFuncLikeFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return arg != null && (arg instanceof pp_Func || arg instanceof Comparable);
        }
    }

    private class ToFuncFunc extends pp_Func {
        public ToFuncFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return pp_R.identity;
            } else if (arg instanceof pp_Func) {
                return (pp_Func) arg;
            } else if (arg instanceof Comparable) {
                return new FuncComparable((Comparable) arg);
            }

            throw new pp_Func.FuncException('Cannot convert arg to Func');
        }
    }

    private class ToFuncListFunc extends pp_Func {
        public ToFuncListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<pp_Func> newList = new List<pp_Func>();

            for (Object obj : mList) {
                newList.add(toFunc(obj));
            }

            return newList;
        }
    }

    private class ToFuncMapFunc extends pp_Func {
        public ToFuncMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, pp_Func> newMap = new Map<String, pp_Func>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toFunc(val));
            }

            return newMap;
        }
    }

    private class IsSObjectLikeFunc extends pp_Func {
        public IsSObjectLikeFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return arg != null && arg instanceof SObject;
        }
    }

    private class ToSObjectFunc extends pp_Func {
        public ToSObjectFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg == null) {
                return null;
            } else if (arg instanceof SObject) {
                return (SObject) arg;
            } else if (arg instanceof pp_R && ((pp_R) arg).toObject() instanceof SObject) {
                return ((SObject) ((pp_R) arg).toObject());
            }

            throw new pp_Func.FuncException('Cannot convert arg to SObject');
        }
    }

    private class ToSObjectListFunc extends pp_Func {
        public ToSObjectListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<SObject> newList = new List<SObject>();

            for (Object obj : mList) {
                newList.add(toSObject(obj));
            }

            return newList;
        }
    }

    private class ToSObjectMapFunc extends pp_Func {
        public ToSObjectMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, SObject> newMap = new Map<String, SObject>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toSObject(val));
            }

            return newMap;
        }
    }

    private class ToListFunc extends pp_Func {
        public ToListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> newList = null;
            if (arg == null) {
                newList = new List<Object>();
            } else if (arg instanceof List<Object>) {
                newList = (List<Object>) arg;
            } else if (arg instanceof pp_R && ((pp_R) arg).isList()) {
                newList = ((pp_R) arg).toList();
            } else if (arg instanceof Pair) {
                Pair mPair = (Pair) arg;
                newList = new List<Object>{
                        mPair.fst, mPair.snd
                };
            } else if (arg instanceof String) {
                try {
                    newList = (List<Object>) JSON.deserializeUntyped((String) arg);
                } catch (Exception e) {
                    System.debug(LoggingLevel.Error, 'ERROR (toList): ' + e);
                }
            } else {
                newList = new List<Object>();
            }

            return newList;
        }
    }

    private class IsListLikeFunc extends pp_Func {
        public IsListLikeFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return arg != null && (
                    arg instanceof List<Object> ||
                            (arg instanceof pp_R && ((pp_R) arg).isList()) ||
                            arg instanceof Pair
            );
        }
    }

    private class ToSetFunc extends pp_Func {
        public ToSetFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Set<String> newSet = new Set<String>();
            if (arg == null) {
            } else if (arg instanceof Set<String>) {
                newSet = (Set<String>) arg;
            } else if (arg instanceof Set<Id>) {
                for (Id id : (Set<Id>) arg) {
                    newSet.add(id);
                }
            } else if (arg instanceof List<Object>) {
                for (Object obj : (List<Object>) arg) {
                    newSet.add((String) obj);
                }
            } else if (arg instanceof pp_R && (((pp_R) arg).isSet() || ((pp_R) arg).isList())) {
                newSet = ((pp_R) arg).toSet();
            }

            return newSet;
        }
    }

    private class ToIdSetFunc extends pp_Func {
        public ToIdSetFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Set<Id> newSet = new Set<Id>();
            if (arg == null) {
            } else if (arg instanceof Set<Id>) {
                newSet = (Set<Id>) arg;
            } else if (arg instanceof Set<String>) {
                for (String str : (Set<String>) arg) {
                    newSet.add(str);
                }
            } else if (arg instanceof List<Object>) {
                for (Object obj : (List<Object>) arg) {
                    newSet.add((Id) obj);
                }
            } else if (arg instanceof pp_R && (((pp_R) arg).isSet() || ((pp_R) arg).isList())) {
                newSet = ((pp_R) arg).toIdSet();
            }

            return newSet;
        }
    }

    private class IsSetLikeFunc extends pp_Func {
        public IsSetLikeFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return arg != null && (
                    arg instanceof Set<String> ||
                            (arg instanceof pp_R && ((pp_R) arg).isSet())
            );
        }
    }

    private class ToMapFunc extends pp_Func {
        public ToMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> newMap = null;
            if (arg == null) {
                newMap = new Map<String, Object>();
            } else if (arg instanceof Map<String, Object>) {
                newMap = (Map<String, Object>) arg;
            } else if (arg instanceof SObject) {
                newMap = ((SObject) arg).getPopulatedFieldsAsMap();
            } else if (arg instanceof pp_R && ((pp_R) arg).isMap()) {
                newMap = ((pp_R) arg).toMap();
            } else if (arg instanceof Map<Object, Object>) {
                newMap = new Map<String, Object>();
                Map<Object, Object> srcMap = (Map<Object, Object>) arg;
                for (Object key : srcMap.keySet()) {
                    Object value = srcMap.get(key);
                    newMap.put(toString(key), value);
                }
            } else if (arg instanceof String) {
                try {
                    newMap = (Map<String, Object>) JSON.deserializeUntyped((String) arg);
                } catch (Exception e) {
                    System.debug(LoggingLevel.Error, 'ERROR (toMap): ' + e);
                }
            } else {
                try {
                    newMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(arg));
                } catch (Exception e) {
                    System.debug(LoggingLevel.Error, 'ERROR (toMap): ' + e);
                }
            }

            return newMap;
        }
    }

    private class IsMapLikeFunc extends pp_Func {
        public IsMapLikeFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return arg != null && (
                    arg instanceof Map<String, Object> ||
                            (arg instanceof pp_R && ((pp_R) arg).isMap()) ||
                            arg instanceof SObject
            );
        }
    }

    private class ToMapListFunc extends pp_Func {
        public ToMapListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Map<String, Object>> newList = new List<Map<String, Object>>();

            for (Object obj : mList) {
                newList.add(toMap(obj));
            }

            return newList;
        }
    }

    private class ToPairFunc extends pp_Func {
        public ToPairFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Pair newPair = null;
            if (arg == null) {
                newPair = new Pair(null, null);
            } else if (arg instanceof Pair) {
                newPair = (Pair) arg;
            } else if (isListLike(arg)) {
                List<Object> mList = toList(arg);
                newPair = new Pair(getNthElement(0, mList), getNthElement(1, mList));
            } else {
                newPair = new Pair(arg, arg);
            }

            return newPair;
        }
    }

    private class IsPairLikeFunc extends pp_Func {
        public IsPairLikeFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return arg != null && (arg instanceof Pair);
        }
    }

    private class ToPairListFunc extends pp_Func {
        public ToPairListFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Pair> newList = new List<Pair>();

            for (Object obj : mList) {
                newList.add(toPair(obj));
            }

            return newList;
        }
    }

    private class ToPairMapFunc extends pp_Func {
        public ToPairMapFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            Map<String, Pair> newMap = new Map<String, Pair>();

            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newMap.put(key, toPair(val));
            }

            return newMap;
        }
    }

    private class AddFunc extends pp_Func {
        public AddFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Decimal d1 = toDecimal(a);
            Decimal d2 = toDecimal(b);
            if (d1 == null) d1 = 0;
            if (d2 == null) d2 = 0;
            return d1 + d2;
        }
    }

    private class SubtractFunc extends pp_Func {
        public SubtractFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Decimal d1 = toDecimal(a);
            Decimal d2 = toDecimal(b);
            if (d1 == null) d1 = 0;
            if (d2 == null) d2 = 0;
            return d1 - d2;
        }
    }

    private class MultiplyFunc extends pp_Func {
        public MultiplyFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Decimal d1 = toDecimal(a);
            Decimal d2 = toDecimal(b);
            if (d1 == null) d1 = 0;
            if (d2 == null) d2 = 0;
            return d1 * d2;
        }
    }

    private class DivideFunc extends pp_Func {
        public DivideFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Decimal d1 = toDecimal(a);
            Decimal d2 = toDecimal(b);
            if (d1 == null) d1 = 0;
            if (d2 == null) d2 = 0;
            return d1 / d2;
        }
    }

    private class ModFunc extends pp_Func {
        public ModFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Long d1 = toLong(a);
            Long d2 = toLong(b);
            if (d1 == null) d1 = 0;
            if (d2 == null) d2 = 0;
            return Math.mod(d1, d2);
        }
    }

    private class PipeFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncList(toFuncList(args));
        }
    }

    private class ComposeFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncList(toFuncList(args, true));
        }
    }

    private class DebugFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            if (args.size() == 1) {
                System.debug(args.get(0));
            } else {
                System.debug(args);
            }
            return args;
        }
    }

    private class IsNilFunc extends pp_Func {
        public IsNilFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return arg == null;
        }
    }

    private class IsNumberFunc extends pp_Func {
        public IsNumberFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return arg instanceof Integer ||
                    arg instanceof Long ||
                    arg instanceof Double ||
                    arg instanceof Decimal;
        }
    }

    private class AllPassFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncAll(toFuncList(args));
        }
    }

    private class AnyPassFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncAny(toFuncList(args));
        }
    }

    private class ComplementFunc extends pp_Func {
        public ComplementFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return new FuncComplement(toFunc(arg));
        }
    }

    private class AndFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            for (Object arg : args) {
                Boolean b = toBoolean(arg);
                if (!b) {
                    return false;
                }
            }

            return true;
        }
    }

    private class OrFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            for (Object arg : args) {
                Boolean b = toBoolean(arg);
                if (b) {
                    return true;
                }
            }

            return false;
        }
    }

    private class NotFunc extends pp_Func {
        public NotFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Boolean b = toBoolean(arg);
            return !b;
        }
    }

    private class EqualsFunc extends pp_Func {
        public EqualsFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            return (a == null && b == null) ||
                    (a != null && a.equals(b));
        }
    }

    private class LtFunc extends pp_Func {
        public LtFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Decimal d1 = toDecimal(a);
            Decimal d2 = toDecimal(b);
            return d1 < d2;
        }
    }

    private class LteFunc extends pp_Func {
        public LteFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Decimal d1 = toDecimal(a);
            Decimal d2 = toDecimal(b);
            return d1 <= d2;
        }
    }

    private class GtFunc extends pp_Func {
        public GtFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Decimal d1 = toDecimal(a);
            Decimal d2 = toDecimal(b);
            return d1 > d2;
        }
    }

    private class GteFunc extends pp_Func {
        public GteFunc() {
            super(2);
        }

        public override Object exec(Object a, Object b) {
            Decimal d1 = toDecimal(a);
            Decimal d2 = toDecimal(b);
            return d1 >= d2;
        }
    }

    private class PlaceholderFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return null;
        }
    }

    private class IdentityFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return args.isEmpty() ? null : args.get(0);
        }
    }

    private class CondFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncCond(toFuncList(args));
        }
    }

    private class IfElseFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncIfElse(toFuncList(args));
        }
    }

    private class WhenFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncWhen(toFuncList(args));
        }
    }

    private class UnlessFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncUnless(toFuncList(args));
        }
    }

    private class AlwaysFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            Object arg = args.isEmpty() ? null : args.get(0);
            return new FuncAlways(arg);
        }
    }

    private class ConstantFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            Object arg = args.isEmpty() ? null : args.get(0);
            return arg;
        }
    }

    private class ThrowExcpetionFunc extends pp_Func {
        public ThrowExcpetionFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg instanceof Exception) {
                throw (Exception) arg;
            }

            return arg;
        }
    }

    private class FlipFunc extends pp_Func {
        public FlipFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            return new FuncFlip(toFunc(arg));
        }
    }

    private class ConvergeFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncConverge(toFuncList(args));
        }
    }

    private class UseWithFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncUseWith(toFuncList(args));
        }
    }

    private class OnceFunc extends pp_Func {
        public OnceFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            return new FuncOnce(toFunc(arg1), toString(arg2));
        }
    }

    private class MemoizeFunc extends pp_Func {
        public MemoizeFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            return new FuncMemoize(toFunc(arg1), toString(arg2), toFunc(arg3));
        }
    }

    private class HasFunc extends pp_Func {
        public HasFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            String field = toString(arg1);
            Map<String, Object> data = toMap(arg2);
            return data.containsKey(field);
        }
    }

    private class PropFunc extends pp_Func {
        public PropFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            String field = toString(arg1);
            Map<String, Object> data = toMap(arg2);
            return data.get(field);
        }
    }

    private class PathFunc extends pp_Func {
        public PathFunc() {
            super(2);
        }

        private Object getValue(Map<String, Object> mMap, List<String> items) {
            String field = items.get(0);
            Object value = mMap.get(field);

            if (isMapLike(value) && items.size() > 1) {
                Map<String, Object> subMap = toMap(value);
                items.remove(0);
                return this.getValue(subMap, items);
            } else {
                return value;
            }
        }

        public override Object exec(Object arg1, Object arg2) {
            String field = toString(arg1);
            Map<String, Object> mMap = toMap(arg2);

            List<String> items = field.split('\\.');

            return this.getValue(mMap, items);
        }
    }

    private class PropEqFunc extends pp_Func {
        public PropEqFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            String field = toString(arg1);
            Object val = arg2;
            Map<String, Object> data = toMap(arg3);
            return equals(val, data.get(field));
        }
    }

    private class PropOrFunc extends pp_Func {
        public PropOrFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            String field = toString(arg1);
            Object defaultVal = arg2;
            Map<String, Object> data = toMap(arg3);
            Object val = data.get(field);
            return val == null ? defaultVal : val;
        }
    }

    private class PropSatisfiesFunc extends pp_Func {
        public PropSatisfiesFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            String field = toString(arg1);
            pp_Func pred = toFunc(arg2);
            Map<String, Object> data = toMap(arg3);
            Object val = data.get(field);
            return pred.run(val);
        }
    }

    private class WhereEqFunc extends pp_Func {
        public WhereEqFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Map<String, Object> data = toMap(arg1);
            for (String key : data.keySet()) {
                Object val = data.get(key);
                Map<String, Object> m = toMap(arg2);
                Boolean pass = toBoolean(equals(m.get(key), val));
                if (!pass) {
                    return false;
                }
            }

            return true;
        }
    }

    private class WhereSatisfiesFunc extends pp_Func {
        public WhereSatisfiesFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Map<String, pp_Func> data = toFuncMap(arg1);
            for (String key : data.keySet()) {
                pp_Func pred = data.get(key);
                Map<String, Object> m = toMap(arg2);
                Object val = m.get(key);
                Boolean pass = toBoolean(pred.run(val));
                if (!pass) {
                    return false;
                }
            }

            return true;
        }
    }

    private class PropSObjectFunc extends pp_Func {
        public PropSObjectFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            String field = toString(arg1);
            SObject sObj = toSObject(arg2);
            return sObj.getSObject(field);
        }
    }

    private class PropSObjectsFunc extends pp_Func {
        public PropSObjectsFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            String field = toString(arg1);
            SObject sObj = toSObject(arg2);
            return sObj.getSObjects(field);
        }
    }

    private class NAryFunc extends pp_Func {
        public NAryFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Integer arity = toInteger(arg1);
            pp_Func fn = toFunc(arg2);

            return new FuncNAry(arity, fn);
        }
    }

    private class ComparatorFunc extends pp_Func {
        public ComparatorFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            pp_Func fn = toFunc(arg);

            return new FuncComparator(fn);
        }
    }

    private class CompareFunc extends pp_Func {
        public CompareFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (arg1 == null || arg2 == null) {
                return 0;
            } else if (isNumber(arg1) && isNumber(arg2)) {
                return (Integer) (toInteger(arg1) - toInteger(arg2));
            } else if (arg1 instanceof String && arg2 instanceof String) {
                return ((String) arg1).compareTo((String) arg2);
            } else if (arg1 instanceof Date && arg2 instanceof Date) {
                return (Date) arg1 < (Date) arg2 ? -1 : 1;
            } else if (arg1 instanceof Time && arg2 instanceof Time) {
                return (Time) arg1 < (Time) arg2 ? -1 : 1;
            } else if (arg1 instanceof DateTime && arg2 instanceof DateTime) {
                return (DateTime) arg1 < (DateTime) arg2 ? -1 : 1;
            } else if (arg1 instanceof Comparable && arg2 instanceof Comparable) {
                return ((Comparable) arg1).compareTo(arg2);
            } else {
                return 0;
            }
        }
    }

    private class AscendFunc extends pp_Func {
        public AscendFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            pp_Func fn = toFunc(arg);

            return new FuncSortDirection(fn, true);
        }
    }

    private class DescendFunc extends pp_Func {
        public DescendFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            pp_Func fn = toFunc(arg);

            return new FuncSortDirection(fn, false);
        }
    }

    private class CascadeFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            return new FuncCascade(toFuncList(args));
        }
    }

    private class ForEachFunc extends pp_Func {
        public ForEachFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func fn = toFunc(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                for (Object obj : mList) {
                    fn.run(obj);
                }
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                for (String obj : mSet) {
                    fn.run(obj);
                }
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    fn.run(val, key);
                }
            } else if (isStringLike(arg2)) {
                List<String> mList = toCharList(arg2);
                for (String obj : mList) {
                    fn.run(obj);
                }
            }
            return arg2;
        }
    }

    private class FilterFunc extends pp_Func {
        private Boolean reverse;

        public FilterFunc(Boolean reverse) {
            this.reverse = reverse;
        }

        private Boolean accept(Boolean pass) {
            return (pass && !reverse) || (!pass && reverse);
        }

        private Object filter(pp_Func pred, Object target) {
            if (isListLike(target)) {
                List<Object> mList = toList(target);
                List<Object> newList = new List<Object>();
                for (Object obj : mList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (accept(pass)) {
                        newList.add(obj);
                    }
                }
                return newList;
            } else if (isSetLike(target)) {
                Set<String> mSet = toSet(target);
                Set<String> newSet = new Set<String>();
                for (String obj : mSet) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (accept(pass)) {
                        newSet.add(obj);
                    }
                }
                return newSet;
            } else if (isMapLike(target)) {
                Map<String, Object> mMap = toMap(target);
                Map<String, Object> newMap = new Map<String, Object>();
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    Boolean pass = toBoolean(pred.run(val, key));
                    if (accept(pass)) {
                        newMap.put(key, val);
                    }
                }
                return newMap;
            } else if (isStringLike(target)) {
                List<String> mList = toCharList(target);
                List<String> newList = new List<String>();
                for (String obj : mList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (accept(pass)) {
                        newList.add(obj);
                    }
                }
                return String.join(newList, '');
            } else {
                return target;
            }
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isStringLike(arg1)) {
                String field = toString(arg1);
                return filter(
                        pp_R.has.apply(field),
                        arg2
                );
            } else if (isFuncLike(arg1)) {
                pp_Func pred = toFunc(arg1);
                return filter(
                        pred,
                        arg2
                );
            } else if (isMapLike(arg1)) {
                Map<String, Object> data = toMap(arg1);
                return filter(
                        pp_R.whereEq.apply(data),
                        arg2
                );
            }

            throw new pp_Func.FuncException('Invalid usage of filter');
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            String field = toString(arg1);
            Object val = arg2;
            return filter(
                    pp_R.propEq.apply(field, val),
                    arg3
            );
        }
    }

    private class MapFunc extends pp_Func {
        public MapFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func fn = toFunc(arg1);

            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                List<Object> newList = new List<Object>();
                for (Object obj : mList) {
                    newList.add(fn.run(obj));
                }
                return newList;
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                Set<String> newSet = new Set<String>();
                for (String obj : mSet) {
                    newSet.add(toString(fn.run(obj)));
                }
                return newSet;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                Map<String, Object> newMap = new Map<String, Object>();
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    newMap.put(key, fn.run(val, key));
                }
                return newMap;
            } else if (isStringLike(arg2)) {
                List<String> mList = toCharList(arg2);
                List<String> newList = new List<String>();
                for (String obj : mList) {
                    newList.add(toString(fn.run(obj)));
                }
                return String.join(newList, '');
            } else {
                return arg2;
            }
        }
    }

    private class BimapFunc extends pp_Func {
        public override Object exec(Object arg1, Object arg2) {
            pp_Func fnKey = toFunc(arg1);
            Map<String, Object> mMap = toMap(arg2);
            Map<String, Object> newMap = new Map<String, Object>();
            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                String newKey = toString(fnKey.run(val, key));
                newMap.put(newKey, val);
            }

            return newMap;
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            pp_Func fnKey = toFunc(arg1);
            pp_Func fnValue = toFunc(arg2);
            Map<String, Object> mMap = toMap(arg3);
            Map<String, Object> newMap = new Map<String, Object>();
            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                String newKey = toString(fnKey.run(val, key));
                Object newValue = fnValue.run(val, key);
                newMap.put(newKey, newValue);
            }

            return newMap;
        }
    }

    private class PluckFunc extends pp_Func {
        public PluckFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            String field = toString(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                List<Object> newList = new List<Object>();
                for (Object obj : mList) {
                    newList.add(pp_R.path.run(field, obj));
                }
                return newList;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                Map<String, Object> newMap = new Map<String, Object>();
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    newMap.put(key, pp_R.path.run(field, val, key));
                }
                return newMap;
            } else {
                return arg2;
            }
        }
    }

    private class ReduceFunc extends pp_Func {
        public ReduceFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            pp_Func reducer = toFunc(arg1);
            Object acc = arg2;
            if (isListLike(arg3)) {
                List<Object> mList = toList(arg3);
                for (Object obj : mList) {
                    acc = reducer.run(acc, obj);
                }
            } else if (isSetLike(arg3)) {
                Set<String> mSet = toSet(arg3);
                for (String obj : mSet) {
                    acc = reducer.run(acc, obj);
                }
            } else if (isMapLike(arg3)) {
                Map<String, Object> mMap = toMap(arg3);
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    acc = reducer.run(acc, new Pair(key, val));
                }
            } else if (isStringLike(arg3)) {
                List<String> mChars = toCharList(arg3);
                for (String mChar : mChars) {
                    acc = reducer.run(acc, mChar);
                }
            }

            return acc;
        }
    }

    private class SliceFunc extends pp_Func {
        public SliceFunc() {
            super(-1);
        }

        public override Object exec(Object arg1, Object arg2) {
            Integer first = toInteger(arg1);
            Integer last = null;
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                Integer size = mList.size();
                first = getIndexInRange(first, size);
                last = size;
                List<Object> newList = new List<Object>();
                if (first > last) {
                    return newList;
                }
                for (Integer i = first; i < last; i++) {
                    newList.add(mList.get(i));
                }
                return newList;
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                Integer size = mCharList.size();
                first = getIndexInRange(first, size);
                last = size;
                List<String> newCharList = new List<String>();
                if (first > last) {
                    return '';
                }
                for (Integer i = first; i < last; i++) {
                    newCharList.add(mCharList.get(i));
                }
                return String.join(newCharList, '');
            }

            return arg2;
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Integer first = toInteger(arg1);
            Integer last = toInteger(arg2);
            if (isListLike(arg3)) {
                List<Object> mList = toList(arg3);
                Integer size = mList.size();
                first = getIndexInRange(first, size);
                last = getIndexInRange(last, size);
                last = last > size ? size : last;
                List<Object> newList = new List<Object>();
                if (first > last) {
                    return newList;
                }
                for (Integer i = first; i < last; i++) {
                    newList.add(mList.get(i));
                }
                return newList;
            } else if (isStringLike(arg3)) {
                List<String> mCharList = toCharList(arg3);
                Integer size = mCharList.size();
                first = getIndexInRange(first, size);
                last = getIndexInRange(last, size);
                last = last > size ? size : last;
                List<String> newCharList = new List<String>();
                if (first > last) {
                    return '';
                }
                for (Integer i = first; i < last; i++) {
                    newCharList.add(mCharList.get(i));
                }
                return String.join(newCharList, '');
            }

            return arg3;
        }
    }

    private class TakeFunc extends pp_Func {
        public TakeFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Boolean fromRight = toBoolean(arg1);
            if (isNumber(arg2)) {
                Integer num = toInteger(arg2);
                return fromRight ?
                        pp_R.slice.run(-num, arg3) :
                        pp_R.slice.run(0, num, arg3);
            } else {
                pp_Func pred = toFunc(arg2);
                if (isListLike(arg3)) {
                    List<Object> mList = toList(arg3);
                    List<Object> newList = new List<Object>();
                    if (fromRight) {
                        for (Integer i = mList.size() - 1; i >= 0; i--) {
                            Boolean pass = toBoolean(pred.run(mList.get(i)));
                            if (pass) {
                                newList.add(mList.get(i));
                            } else {
                                newList = (List<Object>) pp_R.reverse.run(newList);
                                break;
                            }
                        }
                    } else {
                        for (Integer i = 0; i < mList.size(); i++) {
                            Boolean pass = toBoolean(pred.run(mList.get(i)));
                            if (pass) {
                                newList.add(mList.get(i));
                            } else {
                                break;
                            }
                        }
                    }
                    return newList;
                } else if (isStringLike(arg3)) {
                    List<String> mCharList = toCharList(arg3);
                    List<String> newCharList = new List<String>();
                    if (fromRight) {
                        for (Integer i = mCharList.size() - 1; i >= 0; i--) {
                            Boolean pass = toBoolean(pred.run(mCharList.get(i)));
                            if (pass) {
                                newCharList.add(mCharList.get(i));
                            } else {
                                newCharList = toStringList(pp_R.reverse.run(newCharList));
                                break;
                            }
                        }
                    } else {
                        for (Integer i = 0; i < mCharList.size(); i++) {
                            Boolean pass = toBoolean(pred.run(mCharList.get(i)));
                            if (pass) {
                                newCharList.add(mCharList.get(i));
                            } else {
                                break;
                            }
                        }
                    }
                    return String.join(newCharList, '');
                }
            }

            return arg3;
        }
    }

    private class DropFunc extends pp_Func {
        public DropFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Boolean fromRight = toBoolean(arg1);
            if (isNumber(arg2)) {
                Integer num = toInteger(arg2);
                return fromRight ?
                        pp_R.slice.run(0, -num, arg3) :
                        pp_R.slice.run(num, arg3);
            } else {
                pp_Func pred = toFunc(arg2);
                if (isListLike(arg3)) {
                    List<Object> mList = toList(arg3);
                    List<Object> newList = new List<Object>();
                    if (fromRight) {
                        Integer i = mList.size() - 1;
                        for (; i >= 0; i--) {
                            Boolean pass = toBoolean(pred.run(mList.get(i)));
                            if (!pass) {
                                break;
                            }
                        }
                        for (; i >= 0; i--) {
                            newList.add(mList.get(i));
                        }

                        newList = (List<Object>) pp_R.reverse.run(newList);
                    } else {
                        Integer i = 0;
                        for (; i < mList.size(); i++) {
                            Boolean pass = toBoolean(pred.run(mList.get(i)));
                            if (!pass) {
                                break;
                            }
                        }
                        for (; i < mList.size(); i++) {
                            newList.add(mList.get(i));
                        }
                    }
                    return newList;
                } else if (isStringLike(arg3)) {
                    List<String> mCharList = toCharList(arg3);
                    List<String> newCharList = new List<String>();
                    if (fromRight) {
                        Integer i = mCharList.size() - 1;
                        for (; i >= 0; i--) {
                            Boolean pass = toBoolean(pred.run(mCharList.get(i)));
                            if (!pass) {
                                break;
                            }
                        }
                        for (; i >= 0; i--) {
                            newCharList.add(mCharList.get(i));
                        }

                        newCharList = toStringList(pp_R.reverse.run(newCharList));
                    } else {
                        Integer i = 0;
                        for (; i < mCharList.size(); i++) {
                            Boolean pass = toBoolean(pred.run(mCharList.get(i)));
                            if (!pass) {
                                break;
                            }
                        }
                        for (; i < mCharList.size(); i++) {
                            newCharList.add(mCharList.get(i));
                        }
                    }
                    return String.join(newCharList, '');
                }
            }

            return arg3;
        }
    }

    private class ReverseFunc extends pp_Func {
        public ReverseFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (isListLike(arg)) {
                List<Object> mList = toList(arg);
                List<Object> newList = new List<Object>();
                for (Integer i = mList.size() - 1; i >= 0; i--) {
                    newList.add(mList.get(i));
                }
                return newList;
            } else if (isStringLike(arg)) {
                List<String> mCharList = toCharList(arg);
                List<String> newCharList = new List<String>();
                for (Integer i = mCharList.size() - 1; i >= 0; i--) {
                    newCharList.add(mCharList.get(i));
                }
                return String.join(newCharList, '');
            }

            return arg;
        }
    }

    private class SortFunc extends pp_Func {
        public SortFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func comparator = toFunc(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                List<ComparableWrapper> wrappers = new List<ComparableWrapper>();
                for (Object obj : mList) {
                    wrappers.add(new ComparableWrapper(obj, comparator));
                }
                wrappers.sort();
                List<Object> newList = new List<Object>();
                for (ComparableWrapper wrapper : wrappers) {
                    newList.add(wrapper.getVal());
                }
                return newList;
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                List<ComparableWrapper> wrappers = new List<ComparableWrapper>();
                for (String obj : mCharList) {
                    wrappers.add(new ComparableWrapper(obj, comparator));
                }
                wrappers.sort();
                List<String> newCharList = new List<String>();
                for (ComparableWrapper wrapper : wrappers) {
                    newCharList.add(toString(wrapper.getVal()));
                }
                return String.join(newCharList, '');
            }

            return arg2;
        }
    }

    private class SortDefaultFunc extends pp_Func {
        public SortDefaultFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (isListLike(arg)) {
                List<Object> mList = toList(arg);
                List<Object> newList = new List<Object>(mList);
                newList.sort();
                return newList;
            } else if (isStringLike(arg)) {
                List<String> mCharList = toCharList(arg);
                List<String> newCharList = new List<String>(mCharList);
                newCharList.sort();
                return String.join(newCharList, '');
            }

            return arg;
        }
    }

    private class ContainsFunc extends pp_Func {
        public ContainsFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Object target = arg1;
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                for (Object obj : mList) {
                    Boolean matches = toBoolean(equals(obj, target));
                    if (matches) {
                        return true;
                    }
                }
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                for (String obj : mSet) {
                    Boolean matches = toBoolean(equals(obj, target));
                    if (matches) {
                        return true;
                    }
                }
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    Boolean matches = toBoolean(equals(val, target));
                    if (matches) {
                        return true;
                    }
                }
            } else if (isStringLike(arg2)) {
                List<String> mChars = toCharList(arg2);
                for (String mChar : mChars) {
                    Boolean matches = toBoolean(equals(mChar, target));
                    if (matches) {
                        return true;
                    }
                }
            }

            return false;
        }
    }

    private class ContainsByFunc extends pp_Func {
        public ContainsByFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            pp_Func pred = toFunc(arg1);
            Object target = arg2;
            if (isListLike(arg3)) {
                List<Object> mList = toList(arg3);
                for (Object obj : mList) {
                    Boolean matches = toBoolean(pred.run(obj, target));
                    if (matches) {
                        return true;
                    }
                }
            } else if (isSetLike(arg3)) {
                Set<String> mSet = toSet(arg3);
                for (String obj : mSet) {
                    Boolean matches = toBoolean(pred.run(obj, target));
                    if (matches) {
                        return true;
                    }
                }
            } else if (isMapLike(arg3)) {
                Map<String, Object> mMap = toMap(arg3);
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    Boolean matches = toBoolean(pred.run(val, target));
                    if (matches) {
                        return true;
                    }
                }
            } else if (isStringLike(arg3)) {
                List<String> mChars = toCharList(arg3);
                for (String mChar : mChars) {
                    Boolean matches = toBoolean(pred.run(mChar, target));
                    if (matches) {
                        return true;
                    }
                }
            }

            return false;
        }
    }

    private class ContainsKeyFunc extends pp_Func {
        public ContainsKeyFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Object target = arg1;
            Map<String, Object> mMap = toMap(arg2);
            return mMap.containsKey(toString(target));
        }
    }

    private class TransformFunc extends pp_Func {
        public TransformFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func fn = toFunc(arg1);

            return fn.run(arg2);
        }
    }

    private class UniqFunc extends pp_Func {
        public UniqFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            Set<Object> mSet = new Set<Object>();
            List<Object> newList = new List<Object>();

            for (Object obj : mList) {
                Boolean exists = mSet.contains(obj);
                if (!exists) {
                    mSet.add(obj);
                    newList.add(obj);
                }
            }

            return newList;
        }
    }

    private class UnionFunc extends pp_Func {
        public UnionFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg1) && isListLike(arg2)) {
                List<Object> mList1 = toList(arg1);
                List<Object> mList2 = toList(arg2);
                List<Object> newList = new List<Object>();
                for (Object obj : mList2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newList));
                    if (!exists) {
                        newList.add(obj);
                    }
                }
                for (Object obj : mList1) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newList));
                    if (!exists) {
                        newList.add(obj);
                    }
                }
                return newList;
            } else if (isSetLike(arg1) && isSetLike(arg2)) {
                Set<String> mSet1 = toSet(arg1);
                Set<String> mSet2 = toSet(arg2);
                Set<String> newSet = new Set<String>();
                for (String obj : mSet2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newSet));
                    if (!exists) {
                        newSet.add(obj);
                    }
                }
                for (String obj : mSet1) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newSet));
                    if (!exists) {
                        newSet.add(obj);
                    }
                }
                return newSet;
            } else if (isStringLike(arg1) && isStringLike(arg2)) {
                List<String> mCharList1 = toCharList(arg1);
                List<String> mCharList2 = toCharList(arg2);
                List<String> newCharList = new List<String>();
                for (String obj : mCharList2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newCharList));
                    if (!exists) {
                        newCharList.add(obj);
                    }
                }
                for (String obj : mCharList1) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newCharList));
                    if (!exists) {
                        newCharList.add(obj);
                    }
                }
                return String.join(newCharList, '');
            }

            return arg1;
        }
    }

    private class IntersectionFunc extends pp_Func {
        public IntersectionFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg1) && isListLike(arg2)) {
                List<Object> mList1 = toList(arg1);
                List<Object> mList2 = toList(arg2);
                List<Object> newList = new List<Object>();
                for (Object obj : mList2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mList1));
                    if (!exists && existsInOther) {
                        newList.add(obj);
                    }
                }
                for (Object obj : mList1) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mList2));
                    if (!exists && existsInOther) {
                        newList.add(obj);
                    }
                }
                return newList;
            } else if (isSetLike(arg1) && isSetLike(arg2)) {
                Set<String> mSet1 = toSet(arg1);
                Set<String> mSet2 = toSet(arg2);
                Set<String> newSet = new Set<String>();
                for (String obj : mSet2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newSet));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mSet1));
                    if (!exists && existsInOther) {
                        newSet.add(obj);
                    }
                }
                for (String obj : mSet1) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newSet));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mSet2));
                    if (!exists && existsInOther) {
                        newSet.add(obj);
                    }
                }
                return newSet;
            } else if (isStringLike(arg1) && isStringLike(arg2)) {
                List<String> mCharList1 = toCharList(arg1);
                List<String> mCharList2 = toCharList(arg2);
                List<String> newCharList = new List<String>();
                for (String obj : mCharList2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newCharList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mCharList1));
                    if (!exists && existsInOther) {
                        newCharList.add(obj);
                    }
                }
                for (String obj : mCharList1) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newCharList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mCharList2));
                    if (!exists && existsInOther) {
                        newCharList.add(obj);
                    }
                }
                return String.join(newCharList, '');
            }

            return arg1;
        }
    }

    private class XorFunc extends pp_Func {
        public XorFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg1) && isListLike(arg2)) {
                List<Object> mList1 = toList(arg1);
                List<Object> mList2 = toList(arg2);
                List<Object> newList = new List<Object>();
                for (Object obj : mList2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mList1));
                    if (!exists && !existsInOther) {
                        newList.add(obj);
                    }
                }
                for (Object obj : mList1) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mList2));
                    if (!exists && !existsInOther) {
                        newList.add(obj);
                    }
                }
                return newList;
            } else if (isSetLike(arg1) && isSetLike(arg2)) {
                Set<String> mSet1 = toSet(arg1);
                Set<String> mSet2 = toSet(arg2);
                Set<String> newSet = new Set<String>();
                for (String obj : mSet2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newSet));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mSet1));
                    if (!exists && !existsInOther) {
                        newSet.add(obj);
                    }
                }
                for (String obj : mSet1) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newSet));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mSet2));
                    if (!exists && !existsInOther) {
                        newSet.add(obj);
                    }
                }
                return newSet;
            } else if (isStringLike(arg1) && isStringLike(arg2)) {
                List<String> mCharList1 = toCharList(arg1);
                List<String> mCharList2 = toCharList(arg2);
                List<String> newCharList = new List<String>();
                for (String obj : mCharList2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newCharList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mCharList1));
                    if (!exists && !existsInOther) {
                        newCharList.add(obj);
                    }
                }
                for (String obj : mCharList1) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newCharList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mCharList2));
                    if (!exists && !existsInOther) {
                        newCharList.add(obj);
                    }
                }
                return String.join(newCharList, '');
            }

            return arg1;
        }
    }

    private class DifferenceFunc extends pp_Func {
        public DifferenceFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg1) && isListLike(arg2)) {
                List<Object> mList1 = toList(arg1);
                List<Object> mList2 = toList(arg2);
                List<Object> newList = new List<Object>();
                for (Object obj : mList2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mList1));
                    if (!exists && !existsInOther) {
                        newList.add(obj);
                    }
                }
                return newList;
            } else if (isSetLike(arg1) && isSetLike(arg2)) {
                Set<String> mSet1 = toSet(arg1);
                Set<String> mSet2 = toSet(arg2);
                Set<String> newSet = new Set<String>();
                for (String obj : mSet2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newSet));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mSet1));
                    if (!exists && !existsInOther) {
                        newSet.add(obj);
                    }
                }
                return newSet;
            } else if (isStringLike(arg1) && isStringLike(arg2)) {
                List<String> mCharList1 = toCharList(arg1);
                List<String> mCharList2 = toCharList(arg2);
                List<String> newCharList = new List<String>();
                for (String obj : mCharList2) {
                    Boolean exists = toBoolean(pp_R.contains.run(obj, newCharList));
                    Boolean existsInOther = toBoolean(pp_R.contains.run(obj, mCharList1));
                    if (!exists && !existsInOther) {
                        newCharList.add(obj);
                    }
                }
                return String.join(newCharList, '');
            }

            return arg1;
        }
    }

    private class AdjustFunc extends pp_Func {
        public AdjustFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            pp_Func fn = toFunc(arg1);
            Integer index = toInteger(arg2);
            if (isListLike(arg3)) {
                List<Object> mList = toList(arg3);
                List<Object> newList = new List<Object>(mList);
                Object val = newList.get(index);
                newList.set(index, fn.run(val));
                return newList;
            } else if (isStringLike(arg3)) {
                List<String> mCharList = toCharList(arg3);
                List<String> newCharList = new List<String>(mCharList);
                String val = newCharList.get(index);
                newCharList.set(index, toString(fn.run(val)));
                return String.join(newCharList, '');
            }

            return arg3;
        }
    }

    private class AllFunc extends pp_Func {
        public AllFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func pred = toFunc(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                for (Object obj : mList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (!pass) {
                        return false;
                    }
                }
                return true;
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                for (String obj : mSet) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (!pass) {
                        return false;
                    }
                }
                return true;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    Boolean pass = toBoolean(pred.run(val, key));
                    if (!pass) {
                        return false;
                    }
                }
                return true;
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                for (String obj : mCharList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (!pass) {
                        return false;
                    }
                }
                return true;
            }

            return false;
        }
    }

    private class AnyFunc extends pp_Func {
        public AnyFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func pred = toFunc(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                for (Object obj : mList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        return true;
                    }
                }
                return false;
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                for (String obj : mSet) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        return true;
                    }
                }
                return false;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    Boolean pass = toBoolean(pred.run(val, key));
                    if (pass) {
                        return true;
                    }
                }
                return false;
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                for (String obj : mCharList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        return true;
                    }
                }
                return false;
            }

            return false;
        }
    }

    private class NoneFunc extends pp_Func {
        public NoneFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func pred = toFunc(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                for (Object obj : mList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        return false;
                    }
                }
                return true;
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                for (String obj : mSet) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        return false;
                    }
                }
                return true;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    Boolean pass = toBoolean(pred.run(val, key));
                    if (pass) {
                        return false;
                    }
                }
                return true;
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                for (String obj : mCharList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        return false;
                    }
                }
                return true;
            }

            return false;
        }
    }

    private class AppendFunc extends pp_Func {
        public AppendFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg2)) {
                Object val = arg1;
                List<Object> mList = toList(arg2);
                List<Object> newList = new List<Object>(mList);
                newList.add(val);
                return newList;
            } else if (isStringLike(arg2)) {
                String val = toString(arg1);
                List<String> mCharList = toCharList(arg2);
                List<String> newCharList = new List<String>(mCharList);
                newCharList.add(val);
                return String.join(newCharList, '');
            }

            return arg2;
        }
    }

    private class PrependFunc extends pp_Func {
        public PrependFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg2)) {
                Object val = arg1;
                List<Object> mList = toList(arg2);
                List<Object> newList = new List<Object>();
                newList.add(val);
                newList.addAll(mList);
                return newList;
            } else if (isStringLike(arg2)) {
                String val = toString(arg1);
                List<String> mCharList = toCharList(arg2);
                List<String> newCharList = new List<String>();
                newCharList.add(val);
                newCharList.addAll(mCharList);
                return String.join(newCharList, '');
            }

            return arg2;
        }
    }

    private class ApplySpecFunc extends pp_Func {
        private Map<String, Object> applySpec(Map<String, Object> spec, List<Object> args) {
            Map<String, Object> ret = new Map<String, Object>();
            for (String key : spec.keySet()) {
                Object specVal = spec.get(key);
                if (isFuncLike(specVal)) {
                    pp_Func specFn = toFunc(specVal);
                    ret.put(key, specFn.runN(args));
                } else if (isMapLike(specVal)) {
                    ret.put(key, applySpec(toMap(specVal), args));
                } else {
                    ret.put(key, specVal);
                }
            }

            return ret;
        }

        public override Object execN(List<Object> args) {
            Map<String, Object> spec = toMap(args.get(0));
            List<Object> newArgs = slice(1, args);
            return applySpec(spec, newArgs);
        }
    }

    private class JuxtFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            List<pp_Func> funcs = toFuncList(args.get(0));
            List<Object> newArgs = slice(1, args);
            List<Object> newList = new List<Object>();

            for (pp_Func fn : funcs) {
                newList.add(fn.runN(newArgs));
            }

            return newList;
        }
    }

    private class AssocFunc extends pp_Func {
        public AssocFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            if (isListLike(arg3)) {
                Integer index = toInteger(arg1);
                Object val = arg2;
                List<Object> mList = toList(arg3);
                List<Object> newList = new List<Object>(mList);
                newList.set(index, val);
                return newList;
            } else if (isSObjectLike(arg3)) {
                String key = toString(arg1);
                Object val = arg2;
                SObject obj = toSObject(arg3);
                SObject newObj = (SObject) doClone(obj);
                newObj.put(key, val);
                return newObj;
            } else if (isMapLike(arg3)) {
                String key = toString(arg1);
                Object val = arg2;
                Map<String, Object> mMap = toMap(arg3);
                Map<String, Object> newMap = new Map<String, Object>(mMap);
                newMap.put(key, val);
                return newMap;
            } else if (isStringLike(arg3)) {
                Integer index = toInteger(arg1);
                String val = toString(arg2);
                List<String> mCharList = toCharList(arg3);
                List<String> newCharList = new List<String>(mCharList);
                newCharList.set(index, val);
                return String.join(newCharList, '');
            }

            return arg3;
        }
    }

    private class ClampFunc extends pp_Func {
        public ClampFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            if (compare(arg1, arg3) > 0) {
                return arg1;
            } else if (compare(arg3, arg2) > 0) {
                return arg2;
            } else {
                return arg3;
            }
        }
    }

    private class CloneFunc extends pp_Func {
        public CloneFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (isListLike(arg)) {
                return new List<Object>(toList(arg));
            } else if (isSetLike(arg)) {
                return new Set<String>(toSet(arg));
            } else if (isSObjectLike(arg)) {
                return toSObject(arg).clone(true, true, true, true);
            } else if (isMapLike(arg)) {
                return new Map<String, Object>(toMap(arg));
            } else if (isStringLike(arg)) {
                return toString(arg);
            } else {
                return arg;
            }
        }
    }

    private class ConcatFunc extends pp_Func {
        public ConcatFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg1) && isListLike(arg2)) {
                List<Object> mList1 = toList(arg1);
                List<Object> mList2 = toList(arg2);
                List<Object> newList = new List<Object>(mList2);
                newList.addAll(mList1);
                return newList;
            } else if (isSetLike(arg1) && isSetLike(arg2)) {
                Set<String> mSet1 = toSet(arg1);
                Set<String> mSet2 = toSet(arg2);
                Set<String> newSet = new Set<String>(mSet2);
                newSet.addAll(mSet1);
                return newSet;
            } else if (isMapLike(arg1) && isMapLike(arg2)) {
                Map<String, Object> mMap1 = toMap(arg1);
                Map<String, Object> mMap2 = toMap(arg2);
                Map<String, Object> newMap = new Map<String, Object>(mMap2);
                newMap.putAll(mMap1);
                return newMap;
            } else if (isStringLike(arg1) && isStringLike(arg2)) {
                String s1 = toString(arg1);
                String s2 = toString(arg2);
                return s2 + s1;
            }

            return arg1;
        }
    }

    private class CountByFunc extends pp_Func {
        public CountByFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func fn = toFunc(arg1);
            Map<String, Integer> countMap = new Map<String, Integer>();
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                for (Object obj : mList) {
                    String key = toString(fn.run(obj));
                    Integer count = countMap.get(key);
                    if (count == null) {
                        count = 0;
                    }
                    count += 1;
                    countMap.put(key, count);
                }
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                for (String obj : mSet) {
                    String key = toString(fn.run(obj));
                    Integer count = countMap.get(key);
                    if (count == null) {
                        count = 0;
                    }
                    count += 1;
                    countMap.put(key, count);
                }
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                for (String obj : mCharList) {
                    String key = toString(fn.run(obj));
                    Integer count = countMap.get(key);
                    if (count == null) {
                        count = 0;
                    }
                    count += 1;
                    countMap.put(key, count);
                }
            }

            return countMap;
        }
    }

    private class GroupByFunc extends pp_Func {
        public GroupByFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func fn = toFunc(arg1);
            Map<String, List<Object>> groupMap = new Map<String, List<Object>>();
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                for (Object obj : mList) {
                    String key = toString(fn.run(obj));
                    List<Object> mGroup = groupMap.get(key);
                    if (mGroup == null) {
                        mGroup = new List<Object>();
                    }
                    mGroup.add(obj);
                    groupMap.put(key, mGroup);
                }
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                for (String obj : mSet) {
                    String key = toString(fn.run(obj));
                    List<Object> mGroup = groupMap.get(key);
                    if (mGroup == null) {
                        mGroup = new List<Object>();
                    }
                    mGroup.add(obj);
                    groupMap.put(key, mGroup);
                }
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                for (String obj : mCharList) {
                    String key = toString(fn.run(obj));
                    List<Object> mGroup = groupMap.get(key);
                    if (mGroup == null) {
                        mGroup = new List<Object>();
                    }
                    mGroup.add(obj);
                    groupMap.put(key, mGroup);
                }
            }

            return groupMap;
        }
    }

    private class IndexByFunc extends pp_Func {
        public IndexByFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func fn = toFunc(arg1);
            Map<String, Object> indexMap = new Map<String, Object>();
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                for (Object obj : mList) {
                    String key = toString(fn.run(obj));
                    indexMap.put(key, obj);
                }
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                for (String obj : mSet) {
                    String key = toString(fn.run(obj));
                    indexMap.put(key, obj);
                }
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                for (String obj : mCharList) {
                    String key = toString(fn.run(obj));
                    indexMap.put(key, obj);
                }
            }

            return indexMap;
        }
    }

    private class DefaultToFunc extends pp_Func {
        public DefaultToFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            return arg2 == null ? arg1 : arg2;
        }
    }

    private class DissocFunc extends pp_Func {
        public DissocFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg2)) {
                Integer index = toInteger(arg1);
                List<Object> mList = toList(arg2);
                List<Object> newList = new List<Object>(mList);
                newList.set(index, null);
                return newList;
            } else if (isSObjectLike(arg2)) {
                String key = toString(arg1);
                SObject obj = toSObject(arg2);
                SObject newObj = (SObject) doClone(obj);
                newObj.put(key, null);
                return newObj;
            } else if (isMapLike(arg2)) {
                String key = toString(arg1);
                Map<String, Object> mMap = toMap(arg2);
                Map<String, Object> newMap = new Map<String, Object>(mMap);
                newMap.remove(key);
                return newMap;
            } else if (isStringLike(arg2)) {
                Integer index = toInteger(arg1);
                List<String> mCharList = toCharList(arg2);
                List<String> newCharList = new List<String>(mCharList);
                newCharList.set(index, '');
                return String.join(newCharList, '');
            }

            return arg2;
        }
    }

    private class StartsWithFunc extends pp_Func {
        public StartsWithFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg1) && isListLike(arg2)) {
                List<Object> mList1 = toList(arg1);
                List<Object> mList2 = toList(arg2);
                if (mList1.size() > mList2.size()) {
                    return false;
                }
                for (Integer i = 0; i < mList1.size(); i++) {
                    if (!equals(mList1.get(i), mList2.get(i))) {
                        return false;
                    }
                }

                return true;
            } else if (isStringLike(arg1) && isStringLike(arg2)) {
                String s1 = toString(arg1);
                String s2 = toString(arg2);
                return s2.startsWith(s1);
            }

            return false;
        }
    }

    private class EndsWithFunc extends pp_Func {
        public EndsWithFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg1) && isListLike(arg2)) {
                List<Object> mList1 = toList(arg1);
                List<Object> mList2 = toList(arg2);
                if (mList1.size() > mList2.size()) {
                    return false;
                }
                for (Integer i = 0; i < mList1.size(); i++) {
                    if (!equals(mList1.get(mList1.size() - 1 - i), mList2.get(mList2.size() - 1 - i))) {
                        return false;
                    }
                }

                return true;
            } else if (isStringLike(arg1) && isStringLike(arg2)) {
                String s1 = toString(arg1);
                String s2 = toString(arg2);
                return s2.endsWith(s1);
            }

            return false;
        }
    }

    private class EvolveFunc extends pp_Func {
        public EvolveFunc() {
            super(2);
        }

        private Map<String, Object> applySpec(Map<String, Object> spec, Map<String, Object> data) {
            Map<String, Object> ret = new Map<String, Object>();
            for (String key : data.keySet()) {
                Object val = data.get(key);
                Object specVal = spec.get(key);
                if (isFuncLike(specVal)) {
                    pp_Func specFn = toFunc(specVal);
                    ret.put(key, specFn.run(val));
                } else if (isMapLike(specVal) && isMapLike(val)) {
                    Map<String, Object> specMap = toMap(specVal);
                    Map<String, Object> valMap = toMap(val);
                    ret.put(key, applySpec(specMap, valMap));
                } else {
                    ret.put(key, val);
                }
            }

            return ret;
        }

        public override Object exec(Object arg1, Object arg2) {
            Map<String, Object> spec = toMap(arg1);
            Map<String, Object> data = toMap(arg2);

            return applySpec(spec, data);
        }
    }

    private class FindFunc extends pp_Func {
        private Boolean reverse;

        public FindFunc(Boolean reverse) {
            super(2);
            this.reverse = reverse;
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func pred = toFunc(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                mList = reverse ? (List<Object>) pp_R.reverse.run(mList) : mList;
                for (Object obj : mList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        return obj;
                    }
                }

                return null;
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                for (String obj : mSet) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        return obj;
                    }
                }

                return null;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    Boolean pass = toBoolean(pred.run(val, key));
                    if (pass) {
                        return new Pair(key, val);
                    }
                }

                return null;
            } else if (isStringLike(arg2)) {
                List<Object> mCharList = toCharList(arg2);
                mCharList = reverse ? (List<Object>) pp_R.reverse.run(mCharList) : mCharList;
                for (Object mChar : mCharList) {
                    Boolean pass = toBoolean(pred.run(mChar));
                    if (pass) {
                        return mChar;
                    }
                }

                return null;
            }

            return arg2;
        }
    }

    private class FindIndexFunc extends pp_Func {
        private Boolean reverse;

        public FindIndexFunc(Boolean reverse) {
            super(2);
            this.reverse = reverse;
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func pred = toFunc(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                if (!reverse) {
                    for (Integer i = 0; i < mList.size(); i++) {
                        Boolean pass = toBoolean(pred.run(mList.get(i)));
                        if (pass) {
                            return i;
                        }
                    }
                } else {
                    for (Integer i = mList.size() - 1; i >= 0; i--) {
                        Boolean pass = toBoolean(pred.run(mList.get(i)));
                        if (pass) {
                            return i;
                        }
                    }
                }

                return -1;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    Boolean pass = toBoolean(pred.run(val, key));
                    if (pass) {
                        return key;
                    }
                }

                return null;
            } else if (isStringLike(arg2)) {
                List<Object> mCharList = toCharList(arg2);
                if (!reverse) {
                    for (Integer i = 0; i < mCharList.size(); i++) {
                        Boolean pass = toBoolean(pred.run(mCharList.get(i)));
                        if (pass) {
                            return i;
                        }
                    }
                } else {
                    for (Integer i = mCharList.size() - 1; i >= 0; i--) {
                        Boolean pass = toBoolean(pred.run(mCharList.get(i)));
                        if (pass) {
                            return i;
                        }
                    }
                }

                return -1;
            }

            return arg2;
        }
    }

    private class UnnestFunc extends pp_Func {
        public UnnestFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Object> mList = toList(arg);
            List<Object> newList = new List<Object>();
            for (Object obj : mList) {
                if (isListLike(obj)) {
                    List<Object> subList = toList(obj);
                    newList.addAll(subList);
                } else {
                    newList.add(obj);
                }
            }

            return newList;
        }
    }

    private class FlattenFunc extends pp_Func {
        public FlattenFunc() {
            super(1);
        }

        private Object flatten(Object target) {
            if (isListLike(target)) {
                List<Object> mList = toList(target);
                List<Object> newList = new List<Object>();
                for (Object obj : mList) {
                    Object flattened = flatten(obj);
                    if (isListLike(flattened)) {
                        newList.addAll(toList(flattened));
                    } else {
                        newList.add(flattened);
                    }
                }

                return newList;
            } else {
                return target;
            }
        }

        public override Object exec(Object arg) {
            return flatten(arg);
        }
    }

    private class PairFunc extends pp_Func {
        public override Object exec(Object arg) {
            return toPair(arg);
        }

        public override Object exec(Object arg1, Object arg2) {
            return new Pair(arg1, arg2);
        }
    }

    private class FromPairsFunc extends pp_Func {
        public FromPairsFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            List<Pair> pairs = toPairList(arg);
            Map<String, Object> newMap = new Map<String, Object>();
            for (Pair p : pairs) {
                newMap.put(toString(p.fst), p.snd);
            }

            return newMap;
        }
    }

    private class ToPairsFunc extends pp_Func {
        public ToPairsFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Map<String, Object> mMap = toMap(arg);
            List<Object> newPairs = new List<Object>();
            for (String key : mMap.keySet()) {
                Object val = mMap.get(key);
                newPairs.add(new Pair(key, val));
            }

            return newPairs;
        }
    }

    private class FirstFunc extends pp_Func {
        public FirstFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (isListLike(arg)) {
                List<Object> mList = toList(arg);
                return getNthElement(0, mList);
            } else if (isStringLike(arg)) {
                List<String> mCharList = toCharList(arg);
                return getNthElement(0, mCharList);
            }

            return arg;
        }
    }

    private class LastFunc extends pp_Func {
        public LastFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (isListLike(arg)) {
                List<Object> mList = toList(arg);
                return getNthElement(mList.size() - 1, mList);
            } else if (isStringLike(arg)) {
                List<String> mCharList = toCharList(arg);
                return getNthElement(mCharList.size() - 1, mCharList);
            }

            return arg;
        }
    }

    private class InitFunc extends pp_Func {
        public InitFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (isListLike(arg)) {
                List<Object> mList = toList(arg);
                return slice(0, mList.size() - 1, mList);
            } else if (isStringLike(arg)) {
                List<String> mCharList = toCharList(arg);
                return String.join(slice(0, mCharList.size() - 1, mCharList), '');
            }

            return arg;
        }
    }

    private class TailFunc extends pp_Func {
        public TailFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (isListLike(arg)) {
                List<Object> mList = toList(arg);
                return slice(1, mList);
            } else if (isStringLike(arg)) {
                List<String> mCharList = toCharList(arg);
                return String.join(slice(1, mCharList), '');
            }

            return arg;
        }
    }

    private class IndexOfFunc extends pp_Func {
        private Boolean reverse;

        public IndexOfFunc(Boolean reverse) {
            super(2);
            this.reverse = reverse;
        }

        public override Object exec(Object arg1, Object arg2) {
            Object target = arg1;

            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                if (!reverse) {
                    for (Integer i = 0; i < mList.size(); i++) {
                        if (equals(target, mList.get(i))) {
                            return i;
                        }
                    }

                    return -1;
                } else {
                    for (Integer i = mList.size() - 1; i >= 0; i--) {
                        if (equals(target, mList.get(i))) {
                            return i;
                        }
                    }

                    return -1;
                }
            } else if (isStringLike(arg2)) {
                String str = toString(arg2);
                return reverse ?
                        str.indexOf(toString(target)) :
                        str.lastIndexOf(toString(target));
            }

            return -1;
        }
    }

    private class InsertFunc extends pp_Func {
        public InsertFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Integer index = toInteger(arg1);
            if (isListLike(arg3)) {
                Object val = arg2;
                List<Object> mList = toList(arg3);
                List<Object> newList = new List<Object>(mList);
                newList.add(index, val);
                return newList;
            } else if (isStringLike(arg3)) {
                String val = toString(arg2);
                List<String> mCharList = toCharList(arg3);
                List<String> newCharList = new List<String>(mCharList);
                newCharList.add(index, val);
                return String.join(newCharList, '');
            }

            return arg3;
        }
    }

    private class InsertAllFunc extends pp_Func {
        public InsertAllFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Integer index = toInteger(arg1);
            if (isListLike(arg3) && isListLike(arg2)) {
                List<Object> targetList = toList(arg2);
                List<Object> mList = toList(arg3);
                List<Object> newList = new List<Object>(mList);
                for (Integer i = 0; i < targetList.size(); i++) {
                    newList.add(index + i, targetList.get(i));
                }
                return newList;
            } else if (isStringLike(arg3) && isStringLike(arg2)) {
                String val = toString(arg2);
                List<String> mCharList = toCharList(arg3);
                List<String> newCharList = new List<String>(mCharList);
                newCharList.add(index, val);
                return String.join(newCharList, '');
            }

            return arg3;
        }
    }

    private class InvertFunc extends pp_Func {
        private Boolean overrideValue;

        public InvertFunc(Boolean overrideValue) {
            super(1);
            this.overrideValue = overrideValue;
        }

        public override Object exec(Object arg) {
            if (isMapLike(arg)) {
                Map<String, Object> mMap = toMap(arg);
                Map<String, Object> newMap = new Map<String, Object>();
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    if (overrideValue) {
                        if (val != null) {
                            newMap.put(toString(val), key);
                        }
                    } else {
                        if (val != null) {
                            String newKey = toString(val);
                            List<Object> mList = (List<Object>) newMap.get(newKey);
                            if (mList == null) {
                                mList = new List<Object>();
                            }
                            mList.add(key);
                            newMap.put(newKey, mList);
                        }
                    }
                }

                return newMap;
            }

            return arg;
        }
    }

    private class JoinFunc extends pp_Func {
        public JoinFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            String separator = toString(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                return String.join(mList, separator);
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                return String.join(mCharList, separator);
            }

            return arg2;
        }
    }

    private class KeysFunc extends pp_Func {
        public KeysFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (isMapLike(arg)) {
                Map<String, Object> mMap = toMap(arg);
                return mMap.keySet();
            }

            return new Set<String>();
        }
    }

    private class ValuesFunc extends pp_Func {
        public ValuesFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (isMapLike(arg)) {
                Map<String, Object> mMap = toMap(arg);
                return mMap.values();
            }

            return new List<Object>();
        }
    }

    private class MatchFunc extends pp_Func {
        public MatchFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            String regex = toString(arg1);
            String input = toString(arg2);
            if (input == null) {
                return null;
            }
            Pattern ptn = patternCache.get(regex);
            if (ptn == null) {
                ptn = Pattern.compile(regex);
                patternCache.put(regex, ptn);
            }
            Matcher matcher = ptn.matcher(input);
            List<String> groups = new List<String>();
            if (matcher.matches()) {
                groups.add(matcher.group(0));

                for (Integer i = 1; i <= matcher.groupCount(); i++) {
                    groups.add(matcher.group(i));
                }
            }

            return groups;
        }
    }

    private class MaxFunc extends pp_Func {
        public MaxFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            return compare(arg1, arg2) < 0 ? arg2 : arg1;
        }
    }

    private class MinFunc extends pp_Func {
        public MinFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            return compare(arg1, arg2) < 0 ? arg1 : arg2;
        }
    }

    private class MergeFunc extends pp_Func {
        public MergeFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Map<String, Object> mMap1 = toMap(arg1);
            Map<String, Object> mMap2 = toMap(arg2);
            Map<String, Object> newMap = new Map<String, Object>(mMap2);
            newMap.putAll(mMap1);
            return newMap;
        }
    }

    private class NthFunc extends pp_Func {
        public NthFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                Integer index = toInteger(arg1);
                return index >= 0 && index < mList.size() ? mList.get(index) : null;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                String key = toString(arg1);
                return mMap.get(key);
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                Integer index = toInteger(arg1);
                return index >= 0 && index < mCharList.size() ? mCharList.get(index) : null;
            }

            return null;
        }
    }

    private class PickFunc extends pp_Func {
        public PickFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            List<Object> keyList = toList(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                List<Object> newList = new List<Object>();
                for (Object key : keyList) {
                    Integer index = toInteger(key);
                    if (index >= 0 && index < mList.size()) {
                        newList.add(mList.get(index));
                    }
                }

                return newList;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                Map<String, Object> newMap = new Map<String, Object>();
                for (Object key : keyList) {
                    String keyStr = toString(key);
                    newMap.put(keyStr, mMap.get(keyStr));
                }

                return newMap;
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                List<String> newCharList = new List<String>();
                for (Object key : keyList) {
                    Integer index = toInteger(key);
                    if (index >= 0 && index < mCharList.size()) {
                        newCharList.add(mCharList.get(index));
                    }
                }

                return newCharList;
            }

            return arg2;
        }
    }

    private class OmitFunc extends pp_Func {
        public OmitFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            List<Object> keyList = toList(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                List<Object> newList = new List<Object>();
                List<Integer> indexList = toIntegerList(keyList);
                for (Integer i = 0; i < mList.size(); i++) {
                    if (!indexList.contains(i)) {
                        newList.add(mList.get(i));
                    }
                }

                return newList;
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                Map<String, Object> newMap = new Map<String, Object>();
                for (Object key : mMap.keySet()) {
                    String keyStr = toString(key);
                    if (!keyList.contains(key)) {
                        newMap.put(keyStr, mMap.get(keyStr));
                    }
                }

                return newMap;
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                List<String> newCharList = new List<String>();
                List<Integer> indexList = toIntegerList(keyList);
                for (Integer i = 0; i < mCharList.size(); i++) {
                    if (!indexList.contains(i)) {
                        newCharList.add(mCharList.get(i));
                    }
                }

                return newCharList;
            }

            return arg2;
        }
    }

    private class PartitionFunc extends pp_Func {
        public PartitionFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            pp_Func pred = toFunc(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                List<Object> fstList = new List<Object>();
                List<Object> sndList = new List<Object>();
                for (Object obj : mList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        fstList.add(obj);
                    } else {
                        sndList.add(obj);
                    }
                }

                return new Pair(fstList, sndList);
            } else if (isSetLike(arg2)) {
                Set<String> mSet = toSet(arg2);
                Set<String> fstSet = new Set<String>();
                Set<String> sndSet = new Set<String>();
                for (String obj : mSet) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        fstSet.add(obj);
                    } else {
                        sndSet.add(obj);
                    }
                }

                return new Pair(fstSet, sndSet);
            } else if (isMapLike(arg2)) {
                Map<String, Object> mMap = toMap(arg2);
                Map<String, Object> fstMap = new Map<String, Object>();
                Map<String, Object> sndMap = new Map<String, Object>();
                for (String key : mMap.keySet()) {
                    Object val = mMap.get(key);
                    Boolean pass = toBoolean(pred.run(val, key));
                    if (pass) {
                        fstMap.put(key, val);
                    } else {
                        sndMap.put(key, val);
                    }
                }

                return new Pair(fstMap, sndMap);
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                List<String> fstCharList = new List<String>();
                List<String> sndCharList = new List<String>();
                for (String obj : mCharList) {
                    Boolean pass = toBoolean(pred.run(obj));
                    if (pass) {
                        fstCharList.add(obj);
                    } else {
                        sndCharList.add(obj);
                    }
                }

                return new Pair(String.join(fstCharList, ''), String.join(sndCharList, ''));
            }

            return arg2;
        }
    }

    private class ProductFunc extends pp_Func {
        public override Object execN(List<Object> args) {
            List<Decimal> decimalList = toDecimalList(args);
            Decimal total = 1;
            for (Decimal num : decimalList) {
                total *= num;
            }

            return total;
        }
    }

    private class ProjectFunc extends pp_Func {
        public ProjectFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            List<String> fields = toStringList(arg1);
            List<Object> mList = toList(arg2);
            List<Object> newList = new List<Object>();
            for (Object obj : mList) {
                newList.add(pp_R.pick.run(fields, obj));
            }

            return newList;
        }
    }

    private class RangeFunc extends pp_Func {
        public RangeFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Decimal d1 = toDecimal(arg1);
            Decimal d2 = toDecimal(arg2);
            List<Decimal> newList = new List<Decimal>();
            if (d1 < d2) {
                for (Decimal i = d1; i < d2; i++) {
                    newList.add(i);
                }
            }

            return newList;
        }
    }

    private class RemoveFunc extends pp_Func {
        public RemoveFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Integer first = toInteger(arg1);
            Integer count = toInteger(arg2);
            if (isListLike(arg3)) {
                List<Object> mList = toList(arg3);
                List<Object> newList = new List<Object>();
                for (Integer i = 0; i < mList.size(); i++) {
                    if (i < first || i >= first + count) {
                        newList.add(mList.get(i));
                    }
                }

                return newList;
            } else if (isStringLike(arg3)) {
                List<String> mCharList = toCharList(arg3);
                List<String> newCharList = new List<String>();
                for (Integer i = 0; i < mCharList.size(); i++) {
                    if (i < first || i >= first + count) {
                        newCharList.add(mCharList.get(i));
                    }
                }

                return String.join(newCharList, '');
            }

            return arg3;
        }
    }

    private class RepeatFunc extends pp_Func {
        public RepeatFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Integer count = toInteger(arg1);
            Object val = arg2;
            List<Object> newList = new List<Object>();
            for (Integer i = 0; i < count; i++) {
                newList.add(doClone(val));
            }

            return newList;
        }
    }

    private class TimesFunc extends pp_Func {
        public TimesFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Integer count = toInteger(arg1);
            pp_Func fn = toFunc(arg2);
            List<Object> newList = new List<Object>();
            for (Integer i = 0; i < count; i++) {
                newList.add(fn.run(i));
            }

            return newList;
        }
    }

    private class ReplaceFunc extends pp_Func {
        private Boolean isGlobal;

        public ReplaceFunc(Boolean isGlobal) {
            super(3);
            this.isGlobal = isGlobal;
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            String pattern = toString(arg1);
            String replacement = toString(arg2);
            String target = toString(arg3);

            if (isGlobal) {
                return target.replaceAll(pattern, replacement);
            } else {
                return target.replaceFirst(pattern, replacement);
            }
        }
    }

    private class SplitFunc extends pp_Func {
        public SplitFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            String separator = toString(arg1);
            String source = toString(arg2);
            if (source == null)
                return null;
            return source.split(separator);
        }
    }

    private class TestFunc extends pp_Func {
        public TestFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            String ptn = toString(arg1);
            String target = toString(arg2);

            if (ptn == null || target == null) {
                return false;
            }
            return Pattern.matches(ptn, target);
        }
    }

    private class ToLowerFunc extends pp_Func {
        public ToLowerFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            String str = toString(arg);
            return str.toLowerCase();
        }
    }

    private class ToUpperFunc extends pp_Func {
        public ToUpperFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            String str = toString(arg);
            return str.toUpperCase();
        }
    }

    private class TrimFunc extends pp_Func {
        public TrimFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            String str = toString(arg);
            return str.trim();
        }
    }

    private class UpdateFunc extends pp_Func {
        public UpdateFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Integer index = toInteger(arg1);
            if (isListLike(arg3)) {
                Object val = arg2;
                List<Object> mList = toList(arg3);
                List<Object> newList = new List<Object>(mList);
                if (index >= 0 && index < mList.size()) {
                    newList.set(index, val);
                }

                return newList;
            } else if (isStringLike(arg3)) {
                String val = toString(arg2);
                List<String> mCharList = toCharList(arg3);
                List<String> newCharList = new List<String>(mCharList);
                if (index >= 0 && index < mCharList.size()) {
                    newCharList.set(index, val);
                }

                return String.join(newCharList, '');
            }

            return arg3;
        }
    }

    private class ZipFunc extends pp_Func {
        private Boolean toObject;

        public ZipFunc(Boolean toObject) {
            super(2);
            this.toObject = toObject;
        }

        public override Object exec(Object arg1, Object arg2) {
            List<Object> mList1 = toList(arg1);
            List<Object> mList2 = toList(arg2);
            Integer length = mList1.size() < mList2.size() ? mList1.size() : mList2.size();
            if (toObject) {
                Map<String, Object> newMap = new Map<String, Object>();
                for (Integer i = 0; i < length; i++) {
                    Object obj1 = mList1.get(i);
                    Object obj2 = mList2.get(i);
                    newMap.put(toString(obj1), obj2);
                }

                return newMap;
            } else {
                List<Object> newList = new List<Object>();
                for (Integer i = 0; i < length; i++) {
                    Object obj1 = mList1.get(i);
                    Object obj2 = mList2.get(i);
                    newList.add(new Pair(obj1, obj2));
                }

                return newList;
            }
        }
    }

    private class ShuffleFunc extends pp_Func {
        public ShuffleFunc() {
            super(1);
        }

        private Integer randomInt(Integer max) {
            return (Integer) (Math.random() * max);
        }

        private List<Object> shuffle(List<Object> mList) {
            List<Object> newList = new List<Object>(mList);
            for (Integer i = newList.size() - 1; i >= 1; i--) {
                Integer j = randomInt(i);
                Object val = newList.get(i);
                newList.set(i, newList.get(j));
                newList.set(j, val);
            }
            return newList;
        }

        public override Object exec(Object arg) {
            if (isListLike(arg)) {
                List<Object> mList = toList(arg);
                return shuffle(mList);
            } else if (isStringLike(arg)) {
                List<String> mCharList = toCharList(arg);
                return String.join(shuffle(mCharList), '');
            }

            return arg;
        }
    }

    private class SampleFunc extends pp_Func {
        public SampleFunc() {
            super(2);
        }

        private List<Object> sample(Integer size, List<Object> mList) {
            List<Object> shuffledList = (List<Object>) pp_R.shuffle.run(mList);
            List<Object> newList = new List<Object>();
            for (Integer i = 0; i < size && i < shuffledList.size(); i++) {
                newList.add(shuffledList.get(i));
            }

            return newList;
        }

        public override Object exec(Object arg1, Object arg2) {
            Integer size = toInteger(arg1);
            if (isListLike(arg2)) {
                List<Object> mList = toList(arg2);
                return sample(size, mList);
            } else if (isStringLike(arg2)) {
                List<String> mCharList = toCharList(arg2);
                return String.join(sample(size, mCharList), '');
            }

            return arg2;
        }
    }

    private class CapitalizeFunc extends pp_Func {
        public CapitalizeFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            String str = toString(arg);
            return str.capitalize();
        }
    }

    private class PadFunc extends pp_Func {
        private Padding pd;

        public PadFunc(Padding pd) {
            super(3);
            this.pd = pd;
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Integer length = toInteger(arg1);
            String fill = toString(arg2);
            String target = toString(arg3);

            if (pd == Padding.Both) {
                return target.center(length, fill);
            } else if (pd == Padding.Left) {
                return target.leftPad(length, fill);
            } else if (pd == Padding.Right) {
                return target.rightPad(length, fill);
            } else {
                return arg3;
            }
        }
    }

    private class DbQueryFunc extends pp_Func {
        public DbQueryFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            String query = toString(arg);

            return Database.query(query);
        }
    }

    private class DbInsertFunc extends pp_Func {
        public DbInsertFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg instanceof SObject) {
                insert (SObject) arg;
            } else if (arg instanceof List<SObject>) {
                insert (List<SObject>) arg;
            }

            return arg;
        }
    }

    private class DbUpdateFunc extends pp_Func {
        public DbUpdateFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg instanceof SObject) {
                update (SObject) arg;
            } else if (arg instanceof List<SObject>) {
                update (List<SObject>) arg;
            }

            return arg;
        }
    }

    private class DbDeleteFunc extends pp_Func {
        public DbDeleteFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            if (arg instanceof SObject) {
                delete (SObject) arg;
            } else if (arg instanceof List<SObject>) {
                delete (List<SObject>) arg;
            }

            return arg;
        }
    }

    private class AssertFunc extends pp_Func {
        public AssertFunc() {
            super(-1);
        }

        public override Object exec(Object arg) {
            Boolean condition = toBoolean(arg);

            System.Assert.isTrue(condition);

            return null;
        }

        public override Object exec(Object arg1, Object arg2) {
            Boolean condition = toBoolean(arg1);
            String msg = toString(arg2);

            System.Assert.isTrue(condition, msg);

            return null;
        }
    }

    private class AssertAreEqualFunc extends pp_Func {
        public AssertAreEqualFunc() {
            super(-1);
        }

        public override Object exec(Object arg1, Object arg2) {
            Object expected = arg1;
            Object actual = arg2;

            System.Assert.areEqual(expected, actual);

            return null;
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Object expected = arg1;
            Object actual = arg2;
            String msg = toString(arg3);

            System.Assert.areEqual(expected, actual, msg);

            return null;
        }
    }

    private class AssertAreNotEqualFunc extends pp_Func {
        public AssertAreNotEqualFunc() {
            super(-1);
        }

        public override Object exec(Object arg1, Object arg2) {
            Object expected = arg1;
            Object actual = arg2;

            System.Assert.areNotEqual(expected, actual);

            return null;
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Object expected = arg1;
            Object actual = arg2;
            String msg = toString(arg3);

            System.Assert.areNotEqual(expected, actual, msg);

            return null;
        }
    }
}