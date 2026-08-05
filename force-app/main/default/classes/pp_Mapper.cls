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
 * A pp_Mapper is an object that maps the source object to the destination object
 *
 * pp_Mappers in fact convert from objects to objects
 *
 * Rules of how to map each field can be applied to the Mapper
 *
 * Also pp_Mappers are subclasses of pp_Funcs, which means that pp_Mappers can be used as pp_Funcs
 *
 */
public class pp_Mapper extends pp_Func {
    // Convert an object to pp_Mapper.DTO
    public static final String TO_DTO = 'DTO';

    // Convert an object to Map<String, Object>
    public static final String TO_MAP = 'Map';

    // Convert an object to SObject
    public static final String TO_SOBJECT = 'SObject';

    // Convert an object to Object
    public static final String TO_OBJECT = 'Object';

    // Convert an object to JSON string
    public static final String TO_JSON = 'JSON';

    // If constructing using this value, empty keys will be ignored during the mapping
    public static final Boolean IGNORE_NULLS = true;

    // The names for the input objects, used in case of converting multiple objects to one
    private List<String> inputNames = null;

    // The mappers for each field
    private Map<String, FieldMapper> fieldMappers = new Map<String, FieldMapper>();

    // Keep track of which result should the pp_Mapper convert the object to
    private String convertTo = TO_DTO;

    // Keep track of the type of the object, should it be converted to SObject or Object
    private Type convertToType = null;

    // Ignore empty keys during the mapping
    private Boolean ignoreNulls = false;

    /**
     * Default constructor
     */
    public pp_Mapper() {
        super(-1);
    }

    /**
     * Constructor with ignore nulls configuration
     */
    public pp_Mapper(Boolean ignoreNulls) {
        this();

        this.ignoreNulls = ignoreNulls;
    }

    /**
     * Rename inputs as the given names, so that they can be referenced in the field mapper key expressions
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .inputAs(new List<String>{ 'a', 'b' })
     *     .mapField('x', 'a.name')
     *     .mapField('y', 'b.name')
     *     .run(objA, objB);
     * ```
     *
     * @param names The new names for the inputs
     * @return pp_Mapper
     */
    public pp_Mapper inputAs(List<String> names) {
        this.inputNames = names;

        return this;
    }

    /**
     * Rename inputs as the given names, so that they can be referenced in the field mapper key expressions
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .inputAs('a', 'b')
     *     .mapField('x', 'a.name')
     *     .mapField('y', 'b.name')
     *     .run(objA, objB);
     * ```
     *
     * @param name1 The name of the first object to be converted
     * @param name2 The name of the second object to be converted
     * @return pp_Mapper
     */
    public pp_Mapper inputAs(String name1, String name2) {
        return this.inputAs(new List<String>{
                name1, name2
        });
    }

    /**
     * Rename inputs as the given names, so that they can be referenced in the field mapper key expressions
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .inputAs('a', 'b', 'c')
     *     .mapField('x', 'a.name')
     *     .mapField('y', 'b.name')
     *     .mapField('z', 'c.name')
     *     .run(objA, objB, objC);
     * ```
     *
     * @param name1 The name of the first object to be converted
     * @param name2 The name of the second object to be converted
     * @param name3 The name of the third object to be converted
     * @return pp_Mapper
     */
    public pp_Mapper inputAs(String name1, String name2, String name3) {
        return this.inputAs(new List<String>{
                name1, name2, name3
        });
    }

    /**
     * Map the field using the FieldMapper
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', new pp_Mapper.FieldMapper('Name'))
     * // Map an object with 'Name' to an object with 'name'
     * ```
     *
     * @param fieldName The target object field name
     * @param fMapper The field mapper
     * @return pp_Mapper
     */
    public pp_Mapper mapField(String fieldName, pp_Mapper.FieldMapper fMapper) {
        if (fMapper != null) {
            fMapper.setFieldName(fieldName);
            fMapper.setInputNames(this.inputNames);

            this.fieldMappers.put(fieldName, fMapper);
        }

        return this;
    }

    /**
     * Map the field using the keys and transformer pp_Func
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', new List<String>{ 'Name', 'Description' }, pp_R.concat)
     * // Map an object with 'Name' and 'Description' to an object with 'name', concatenating
     * // values from 'Name' and 'Description'
     * ```
     *
     * @param fieldName The target object field name
     * @param keys The keys of the fields in the source object
     * @param transformer The transforming pp_Func
     * @return pp_Mapper
     */
    public pp_Mapper mapField(String fieldName, List<String> keys, pp_Func transformer) {
        return mapField(fieldName, new FieldMapper(keys, transformer));
    }

    /**
     * Map the field using the keys and transformer pp_Func
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name', 'Description', pp_R.concat)
     * // Map an object with 'Name' and 'Description' to an object with 'name', concatenating
     * // values from 'Name' and 'Description'
     * ```
     *
     * @param fieldName The target object field name
     * @param key1 The first key field
     * @param key2 The second key field
     * @param transformer The transforming pp_Func
     * @return pp_Mapper
     */
    public pp_Mapper mapField(String fieldName, String key1, String key2, pp_Func transformer) {
        return this.mapField(fieldName, new List<String>{
                key1, key2
        }, transformer);
    }

    /**
     * Map the field using the key and transformer pp_Func
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name', pp_R.prepend.apply('Mr.'))
     * // Map an object with 'Name' to an object with 'name', prepending 'Mr.' to the value
     * ```
     *
     * @param fieldName The target object field name
     * @param key The key field
     * @param transformer The transforming pp_Func
     * @return pp_Mapper
     */
    public pp_Mapper mapField(String fieldName, String key, pp_Func transformer) {
        return this.mapField(fieldName, new List<String>{
                key
        }, transformer);
    }

    /**
     * Map the field using the transformer pp_Func
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('Name', pp_R.prepend.apply('Mr.'))
     * // Map an object with 'Name' to an object with 'Name', prepending 'Mr.' to the value
     * ```
     *
     * @param fieldName The target object field name
     * @param transformer The transforming pp_Func
     * @return pp_Mapper
     */
    public pp_Mapper mapField(String fieldName, pp_Func transformer) {
        return this.mapField(fieldName, new List<String>(), transformer);
    }

    /**
     * Map the field using the key
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name')
     * // Map an object with 'Name' to an object with 'name'
     * ```
     *
     * @param fieldName The target object field name
     * @param key The key field
     * @return pp_Mapper
     */
    public pp_Mapper mapField(String fieldName, String key) {
        return this.mapField(fieldName, key, null);
    }

    /**
     * Map the field using the key same as the field name
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('Name')
     * // Map an object with 'Name' to an object with 'Name'
     * ```
     *
     * @param fieldName The target object field name
     * @return pp_Mapper
     */
    public pp_Mapper mapField(String fieldName) {
        return this.mapField(fieldName, new List<String>(), null);
    }

    /**
     * Map the fields using the field mappers
     * The keys in the mapping will be used as the new field name
     * The values in the mapping will be used to map the field
     * The value can be a FieldMapper, String or pp_Func
     * If the value is a FieldMapper, it will be used in mapping the field
     * If the value is a String, it will simply copy the value of the field to new field
     * If the value is a pp_Func, it will convert the original value to the new value under the same field name
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapFields(new Map<String, Object>{
     *         'name' => 'Name',
     *         'description' => 'Description'
     *     })
     * // Map an object with 'Name' and 'Description' to an object with 'name' and 'description'
     * ```
     *
     * @param mapping The field mappers
     * @return pp_Mapper
     */
    public pp_Mapper mapFields(Map<String, Object> mapping) {
        for (String key : mapping.keySet()) {
            Object val = mapping.get(key);

            if (val instanceof FieldMapper) {
                mapField(key, (FieldMapper) val);
            } else if (val instanceof String) {
                mapField(key, (String) val);
            } else if (val instanceof pp_Func) {
                mapField(key, (pp_Func) val);
            } else {
                mapField(key);
            }
        }

        return this;
    }

    /**
     * Create a reversed mapper from the mapper
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name')
     *     .reverseTo(pp_Mapper.TO_SOBJECT, Account.class)
     * // Create a reversed mapper that converts the object back to an Account
     * ```
     *
     * @param convertToType The type of object to convert the object to
     * @param objectType The type of object if converted to SObject/Object
     * @return pp_Mapper
     */
    public pp_Mapper reverseTo(String convertToType, Type objectType) {
        pp_Mapper reversed = new pp_Mapper(ignoreNulls);
        for (FieldMapper fMapper : this.fieldMappers.values()) {
            FieldMapper reversedFieldMapper = fMapper.reverse();
            reversed.mapField(reversedFieldMapper.getFieldName(), reversedFieldMapper);
        }

        if (convertToType == TO_DTO) {
            reversed.toDTO();
        } else if (convertToType == TO_MAP) {
            reversed.toMap();
        } else if (convertToType == TO_JSON) {
            reversed.toJSON();
        } else if (convertToType == TO_SOBJECT) {
            reversed.toSObject(objectType);
        } else if (convertToType == TO_OBJECT) {
            reversed.toObject(objectType);
        } else {
            reversed.toDTO();
        }

        return reversed;
    }

    /**
     * Create a reversed mapper from the mapper
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name')
     *     .reverseTo(pp_Mapper.TO_MAP)
     * // Create a reversed mapper that converts the object back to a map
     * ```
     *
     * @param convertToType The type of object to convert the object to
     * @return pp_Mapper
     */
    public pp_Mapper reverseTo(String convertToType) {
        return this.reverseTo(convertToType, null);
    }

    /**
     * Create a reversed mapper from the mapper
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name')
     *     .reverseToDTO()
     * // Create a reversed mapper that converts the object back to a pp_Mapper.DTO
     * ```
     *
     * @return pp_Mapper
     */
    public pp_Mapper reverseToDTO() {
        return this.reverseTo(TO_DTO);
    }

    /**
     * Create a reversed mapper from the mapper
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name')
     *     .reverseToMap()
     * // Create a reversed mapper that converts the object back to a map
     * ```
     *
     * @return pp_Mapper
     */
    public pp_Mapper reverseToMap() {
        return this.reverseTo(TO_MAP);
    }

    /**
     * Create a reversed mapper from the mapper
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name')
     *     .reverseToJSON()
     * // Create a reversed mapper that converts the object back to a JSON string
     * ```
     *
     * @return pp_Mapper
     */
    public pp_Mapper reverseToJSON() {
        return this.reverseTo(TO_JSON);
    }

    /**
     * Create a reversed mapper from the mapper
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name')
     *     .reverseToObject(AccountDTO.class)
     * // Create a reversed mapper that converts the object back to an AccountDTO
     * ```
     *
     * @param objectType The object type of the Object
     * @return pp_Mapper
     */
    public pp_Mapper reverseToObject(Type objectType) {
        return this.reverseTo(TO_OBJECT, objectType);
    }

    /**
     * Create a reversed mapper from the mapper
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('name', 'Name')
     *     .reverseToSObject(Account.class)
     * // Create a reversed mapper that converts the object back to an Account
     * ```
     *
     * @param objectType The object type of the SObject
     * @return pp_Mapper
     */
    public pp_Mapper reverseToSObject(Type objectType) {
        return this.reverseTo(TO_SOBJECT, objectType);
    }

    /**
     * Specify the type of object that the pp_Mapper will convert to
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('Name', 'name')
     *     .to(pp_Mapper.TO_SOBJECT, Account.class)
     * // Create a mapper that converts the object to an Account
     * ```
     *
     * @param type The type of object to convert to
     * @param objectType The type of object when converted to SObject/Object
     * @return pp_Mapper
     */
    public pp_Mapper to(String type, Type objectType) {
        this.convertTo = type;
        this.convertToType = objectType;

        return this;
    }

    /**
     * Specify the type of object that the pp_Mapper will convert to
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('Name', 'name')
     *     .to(pp_Mapper.TO_MAP)
     * // Create a mapper that converts the object to a map
     * ```
     *
     * @param type The type of object to convert to
     * @return pp_Mapper
     */
    public pp_Mapper to(String type) {
        return this.to(type, null);
    }

    /**
     * Specify the type of object that the pp_Mapper will convert to
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('Name', 'name')
     *     .toDTO()
     * // Create a mapper that converts the object to a pp_Mapper.DTO
     * ```
     *
     * @return pp_Mapper
     */
    public pp_Mapper toDTO() {
        return to(TO_DTO);
    }

    /**
     * Specify the type of object that the pp_Mapper will convert to
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('Name', 'name')
     *     .toMap()
     * // Create a mapper that converts the object to a map
     * ```
     *
     * @return pp_Mapper
     */
    public pp_Mapper toMap() {
        return to(TO_MAP);
    }

    /**
     * Specify the type of object that the pp_Mapper will convert to
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('Name', 'name')
     *     .toSObject(Account.class)
     * // Create a mapper that converts the object to an Account
     * ```
     *
     * @param objectType The object type of the SObject
     * @return pp_Mapper
     */
    public pp_Mapper toSObject(Type objectType) {
        return to(TO_SOBJECT, objectType);
    }

    /**
     * Specify the type of object that the pp_Mapper will convert to
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('Name', 'name')
     *     .toObject(AccountDTO.class)
     * // Create a mapper that converts the object to an AccountDTO
     * ```
     *
     * @param objectType The object type of the Object
     * @return pp_Mapper
     */
    public pp_Mapper toObject(Type objectType) {
        return to(TO_OBJECT, objectType);
    }

    /**
     * Specify the type of object that the pp_Mapper will convert to
     *
     * Example:
     * ```
     * new pp_Mapper()
     *     .mapField('Name', 'name')
     *     .toJSON()
     * // Create a mapper that converts the object to a JSON string
     * ```
     *
     * @return pp_Mapper
     */
    public pp_Mapper toJSON() {
        return to(TO_JSON);
    }

    private Object doConvert(DTO d) {
        if (this.convertTo == TO_DTO) {
            return d;
        } else if (this.convertTo == TO_MAP) {
            return d.toMap();
        } else if (this.convertTo == TO_SOBJECT) {
            return d.toSObject(this.convertToType);
        } else if (this.convertTo == TO_OBJECT) {
            return d.toObject(this.convertToType);
        } else if (this.convertTo == TO_JSON) {
            return d.toJSON();
        } else {
            return d;
        }
    }

    /**
     * Run the mapper
     *
     * @param args The list of objects as the source
     * @return Object
     */
    public override Object execN(List<Object> args) {
        DTO d = new DTO();
        DTO orig = new DTO(args);

        for (String fieldName : this.fieldMappers.keySet()) {
            FieldMapper fm = this.fieldMappers.get(fieldName);
            if (ignoreNulls && !orig.containsPath(fm.keys)) {
                // Ignore empty keys
                continue;
            }
            Object value = fm.transform(args);
            d.setObject(fieldName, value);
        }

        return this.doConvert(d);
    }

    /**
     * The field mapper
     */
    public class FieldMapper {
        // The input names from the Mapper
        private List<String> inputNames;

        // The field name of this field mapper
        private String fieldName;

        // The keys used to map the field
        private List<String> keys;

        // The transforming pp_Func
        private pp_Func transformer;

        /**
         * Construct an instance from keys and transformer
         *
         * @param keys The keys
         * @param transformer The transforming pp_Func
         */
        public FieldMapper(List<String> keys, pp_Func transformer) {
            this.keys = keys;
            this.transformer = transformer;

            if (this.transformer == null) {
                this.transformer = pp_R.identity;
            }
        }

        /**
         * Construct an instance from key and transformer
         *
         * @param key The key
         * @param transformer The transforming pp_Func
         */
        public FieldMapper(String key, pp_Func transformer) {
            this(new List<String>{
                    key
            }, transformer);
        }

        /**
         * Construct an instance from the key
         *
         * @param key The key
         */
        public FieldMapper(String key) {
            this(key, null);
        }

        /**
         * Construct an instance from the first key, the second key and the transformer
         *
         * @param key1 The first key
         * @param key2 The second key
         * @param transformer The transforming pp_Func
         */
        public FieldMapper(String key1, String key2, pp_Func transformer) {
            this(new List<String>{
                    key1, key2
            }, transformer);
        }

        void setInputNames(List<String> inputNames) {
            this.inputNames = inputNames;
        }

        void setFieldName(String fieldName) {
            this.fieldName = fieldName;

            if (this.keys == null || this.keys.isEmpty()) {
                this.keys = new List<String>{
                        this.fieldName
                };
            }
        }

        /**
         * Get the field name
         *
         * @return String
         */
        public String getFieldName() {
            return this.fieldName;
        }

        FieldMapper reverse() {
            if (this.inputNames != null && !this.inputNames.isEmpty()) {
                throw new MapperException('Cannot reverse mapper with input names set');
            }

            if (this.keys.size() != 1) {
                throw new MapperException('Cannot reverse field mapper with multiple key inputs');
            }

            if (this.transformer != pp_R.identity) {
                throw new MapperException('Cannot reverse field mapper with transformer func set');
            }

            FieldMapper reversed = new FieldMapper(this.fieldName);
            reversed.setFieldName(this.keys.get(0));

            return reversed;
        }

        private Object getKeyValue(String key, List<Object> args) {
            if (this.inputNames == null || this.inputNames.isEmpty()) {
                DTO d = new DTO(args.get(0));
                return d.getObject(key);
            } else {
                Integer index = key.indexOf('.');
                if (index < 0) {
                    throw new MapperException('Unprefixed key found for ' + key);
                }
                String prefix = key.substring(0, index);
                String realKey = key.substring(index + 1);
                Integer which = this.inputNames.indexOf(prefix);
                if (which < 0) {
                    throw new MapperException('Invalid input name for ' + prefix);
                }
                DTO d = new DTO(args.get(which));
                return d.getObject(realKey);
            }
        }

        Object transform(List<Object> args) {
            List<Object> fnArgs = new List<Object>();
            for (String key : keys) {
                fnArgs.add(getKeyValue(key, args));
            }

            return this.transformer.runN(fnArgs);
        }
    }

    /**
     * The DTO object to easy manipulate structures of nesting maps
     *
     * Example:
     * ```
     * pp_Mapper.DTO d = new pp_Mapper.DTO();
     * d.setObject('person.name', 'Adam');
     * Map<String, Object> person = d.getMap('person');
     * String name = d.getString('person.name');
     * ```
     *
     */
    public class DTO {
        // Holding the map data
        @TestVisible
        private Map<String, Object> data;

        /**
         * Construct an empty instance
         */
        public DTO() {
            this.data = new Map<String, Object>();
        }

        /**
         * Construct an instance from another DTO
         *
         * @param other The other DTO
         */
        public DTO(DTO other) {
            this((Object) other);
        }

        /**
         * Construct an instance from a map
         *
         * @param mMap The source of map
         */
        public DTO(Map<String, Object> mMap) {
            this((Object) mMap);
        }

        /**
         * Construct an instance from a JSON string
         *
         * @param jsonStr The JSON string
         */
        public DTO(String jsonStr) {
            this((Object) jsonStr);
        }

        /**
         * Construct an instance from an SObject
         *
         * @param sObj The SObject
         */
        public DTO(SObject sObj) {
            this((Object) sObj);
        }

        /**
         * Construct an instance from a list
         *
         * @param sObj The SObject
         */
        public DTO(List<Object> sObj) {
            this((Object) sObj);
        }

        /**
         * Construct an instance from an Object
         *
         * @param obj The object
         */
        public DTO(Object obj) {
            if (obj instanceof DTO) {
                this.data = new Map<String, Object>(((DTO) obj).data);
            } else if (obj instanceof Map<String, Object>) {
                this.data = new Map<String, Object>((Map<String, Object>) obj);
            } else if (obj instanceof String) {
                this.data = (Map<String, Object>) JSON.deserializeUntyped((String) obj);
            } else if (obj instanceof SObject) {
                this.data = ((SObject) obj).getPopulatedFieldsAsMap();
            } else if (obj instanceof List<Object>) {
                this.data = new Map<String, Object>();
                for (Object item : (List<Object>) obj) {
                    this.data.putAll(new DTO(item).data);
                }
            } else {
                this.data = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            }
        }

        /**
         * Get the key set
         *
         * @return Set<String>
         */
        public Set<String> keySet() {
            return this.data.keySet();
        }

        /**
         * Check if the path is contained
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.containsPath(new List<String>{ 'person', 'name' });
         * ```
         *
         * @param path The path
         * @return Boolean
         */
        public Boolean containsPath(List<String> path) {
            return this.containsPath(this.data, path);
        }

        /**
         * Check if the path is contained
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.containsPath('person.name');
         * ```
         *
         * @param path The path
         * @return Boolean
         */
        public Boolean containsPath(String path) {
            if (String.isEmpty(path)) {
                return false;
            }

            return this.containsPath(path.split('\\.'));
        }

        /**
         * Get the string representation
         *
         * @return String
         */
        public override String toString() {
            return String.valueOf(this.data);
        }

        /**
         * Convert this DTO to map
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setObject('person.name', 'Adam');
         * Map<String, Object> data = d.toMap();
         * ```
         *
         * @return Map<String, Object>
         */
        public Map<String, Object> toMap() {
            return new Map<String, Object>(this.data);
        }

        /**
         * Convert this DTO to JSON string
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setObject('person.name', 'Adam');
         * String jsonStr = d.toJSON();
         * ```
         *
         * @return String
         */
        public String toJSON() {
            return JSON.serialize(this.data);
        }

        /**
         * Convert this DTO to SObject
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setObject('Name', 'Adam');
         * Account acc = (Account)d.toSObject(Account.class);
         * ```
         *
         * @param sObjType The type of the SObject
         * @return SObject
         */
        public SObject toSObject(Type sObjType) {
            return (SObject) JSON.deserialize(this.toJSON(), sObjType);
        }

        /**
         * Convert this DTO to Object
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setObject('Name', 'Adam');
         * AccountDTO acc = (AccountDTO)d.toObject(AccountDTO.class);
         * ```
         *
         * @param objType The type of the Object
         * @return Object
         */
        public Object toObject(Type objType) {
            return JSON.deserialize(this.toJSON(), objType);
        }

        private Boolean containsPath(Object data, List<String> path) {
            String key = path.get(0);
            if (data instanceof Map<String, Object>) {
                Map<String, Object> mMap = (Map<String, Object>) data;
                List<String> nextPath = pp_R.of(path).drop(1).toStringList();
                return nextPath.isEmpty() ? mMap.containsKey(key) : containsPath(mMap.get(key), nextPath);
            } else {
                return false;
            }
        }

        private Object getObject(Object data, List<String> path) {
            String key = path.get(0);
            if (data instanceof Map<String, Object>) {
                Map<String, Object> mMap = (Map<String, Object>) data;
                Object next = mMap.get(key);
                List<String> nextPath = pp_R.of(path).drop(1).toStringList();
                return nextPath.isEmpty() ? next : getObject(next, nextPath);
            } else if (data instanceof SObject) {
                Object next = new DTO(data).getObject(key);
                List<String> nextPath = pp_R.of(path).drop(1).toStringList();
                return nextPath.isEmpty() ? next : getObject(next, nextPath);
            } else {
                return null;
            }
        }

        private void setObject(Object data, List<String> path, Object value) {
            String key = path.get(0);
            if (data instanceof Map<String, Object>) {
                Map<String, Object> mMap = (Map<String, Object>) data;
                Object next = mMap.get(key);
                List<String> nextPath = pp_R.of(path).drop(1).toStringList();
                if (nextPath.isEmpty()) {
                    mMap.put(key, value);
                } else {
                    if (!(next instanceof Map<String, Object>)) {
                        next = new Map<String, Object>();
                        mMap.put(key, next);
                    }

                    setObject(next, nextPath, value);
                }
            }
        }

        /**
         * Get object from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.getObject(new List<String>{ 'person', 'name' });
         * ```
         *
         * @param path The path
         * @return Object
         */
        public Object getObject(List<String> path) {
            if (path == null || path.isEmpty()) {
                return null;
            }

            return getObject(this.data, path);
        }

        /**
         * Get object from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.getObject('person.name');
         * ```
         *
         * @param path The path
         * @return Object
         */
        public Object getObject(String path) {
            if (String.isEmpty(path)) {
                return null;
            }

            return this.getObject(path.split('\\.'));
        }

        /**
         * Set the object to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setObject(new List<String>{ 'person', 'name' }, 'Wilson');
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setObject(List<String> path, Object value) {
            if (path != null && !path.isEmpty()) {
                this.setObject(this.data, path, value);
            }

            return this;
        }

        /**
         * Set the object to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setObject('person.name', 'Wilson');
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setObject(String path, Object value) {
            if (!String.isEmpty(path)) {
                this.setObject(path.split('\\.'), value);
            }

            return this;
        }

        /**
         * Set the Boolean to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setBoolean(new List<String>{ 'person', 'value' }, true);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setBoolean(List<String> path, Object value) {
            return this.setObject(path, pp_R.toBoolean.run(value));
        }

        /**
         * Set the Boolean to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setBoolean('person.value', true);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setBoolean(String path, Object value) {
            return this.setBoolean(path.split('\\.'), value);
        }

        /**
         * Get the Boolean from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Boolean value = d.getBoolean(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Boolean
         */
        public Boolean getBoolean(List<String> path) {
            return (Boolean) pp_R.toBoolean.run(this.getObject(path));
        }

        /**
         * Get the Boolean from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Boolean value = d.getBoolean('person.value');
         * ```
         *
         * @param path The path
         * @return Boolean
         */
        public Boolean getBoolean(String path) {
            return this.getBoolean(path.split('\\.'));
        }

        /**
         * Set the Integer to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setInteger(new List<String>{ 'person', 'value' }, 2);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setInteger(List<String> path, Object value) {
            return this.setObject(path, pp_R.toInteger.run(value));
        }

        /**
         * Set the Integer to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setInteger('person.value', 2);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setInteger(String path, Object value) {
            return this.setInteger(path.split('\\.'), value);
        }

        /**
         * Get the Integer from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Integer value = d.getInteger(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Integer
         */
        public Integer getInteger(List<String> path) {
            return (Integer) pp_R.toInteger.run(this.getObject(path));
        }

        /**
         * Get the Integer from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Integer value = d.getInteger('person.value');
         * ```
         *
         * @param path The path
         * @return Integer
         */
        public Integer getInteger(String path) {
            return this.getInteger(path.split('\\.'));
        }

        /**
         * Set the Long to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setLong(new List<String>{ 'person', 'value' }, 2);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setLong(List<String> path, Object value) {
            return this.setObject(path, pp_R.toLong.run(value));
        }

        /**
         * Set the Long to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setLong('person.value', 2);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setLong(String path, Object value) {
            return this.setLong(path.split('\\.'), value);
        }

        /**
         * Get the Long from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Long value = d.getLong(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Long
         */
        public Long getLong(List<String> path) {
            return (Long) pp_R.toLong.run(this.getObject(path));
        }

        /**
         * Get the Long from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Long value = d.getLong('person.value');
         * ```
         *
         * @param path The path
         * @return Long
         */
        public Long getLong(String path) {
            return this.getLong(path.split('\\.'));
        }

        /**
         * Set the Double to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setDouble(new List<String>{ 'person', 'value' }, 2);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setDouble(List<String> path, Object value) {
            return this.setObject(path, pp_R.toDouble.run(value));
        }

        /**
         * Set the Double to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setDouble('person.value', 2);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setDouble(String path, Object value) {
            return this.setDouble(path.split('\\.'), value);
        }

        /**
         * Get the Double from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Double value = d.getDouble(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Double
         */
        public Double getDouble(List<String> path) {
            return (Double) pp_R.toDouble.run(this.getObject(path));
        }

        /**
         * Get the Double from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Double value = d.getDouble('person.value');
         * ```
         *
         * @param path The path
         * @return Double
         */
        public Double getDouble(String path) {
            return this.getDouble(path.split('\\.'));
        }

        /**
         * Set the Decimal to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setDecimal(new List<String>{ 'person', 'value' }, 2);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setDecimal(List<String> path, Object value) {
            return this.setObject(path, pp_R.toDecimal.run(value));
        }

        /**
         * Set the Decimal to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setDecimal('person.value', 2);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setDecimal(String path, Object value) {
            return this.setDecimal(path.split('\\.'), value);
        }

        /**
         * Get the Decimal from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Decimal value = d.getDecimal(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Decimal
         */
        public Decimal getDecimal(List<String> path) {
            return (Decimal) pp_R.toDecimal.run(this.getObject(path));
        }

        /**
         * Get the Decimal from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Decimal value = d.getDecimal('person.value');
         * ```
         *
         * @param path The path
         * @return Decimal
         */
        public Decimal getDecimal(String path) {
            return this.getDecimal(path.split('\\.'));
        }

        /**
         * Set the String to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setString(new List<String>{ 'person', 'value' }, 'test');
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setString(List<String> path, Object value) {
            return this.setObject(path, pp_R.toString.run(value));
        }

        /**
         * Set the String to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setString('person.value', 'test');
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setString(String path, Object value) {
            return this.setString(path.split('\\.'), value);
        }

        /**
         * Get the String from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * String value = d.getString(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return String
         */
        public String getString(List<String> path) {
            return (String) pp_R.toString.run(this.getObject(path));
        }

        /**
         * Get the String from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * String value = d.getString('person.value');
         * ```
         *
         * @param path The path
         * @return String
         */
        public String getString(String path) {
            return this.getString(path.split('\\.'));
        }

        /**
         * Set the List to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setList(new List<String>{ 'person', 'value' }, new List<Object>{ 'test' });
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setList(List<String> path, Object value) {
            return this.setObject(path, pp_R.toList.run(value));
        }

        /**
         * Set the List to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setList('person.value', new List<Object>{ 'test' });
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setList(String path, Object value) {
            return this.setList(path.split('\\.'), value);
        }

        /**
         * Get the List from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * List<Object> value = d.getList(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return List<Object>
         */
        public List<Object> getList(List<String> path) {
            return (List<Object>) pp_R.toList.run(this.getObject(path));
        }

        /**
         * Get the List from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * List<Object> value = d.getList('person.value');
         * ```
         *
         * @param path The path
         * @return List<Object>
         */
        public List<Object> getList(String path) {
            return this.getList(path.split('\\.'));
        }

        /**
         * Set the Set to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setSet(new List<String>{ 'person', 'value' }, new Set<String>{ 'test' });
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setSet(List<String> path, Object value) {
            return this.setObject(path, pp_R.toSet.run(value));
        }

        /**
         * Set the Set to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setSet('person.value', new Set<String>{ 'test' });
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setSet(String path, Object value) {
            return this.setSet(path.split('\\.'), value);
        }

        /**
         * Get the Set from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Set<String> value = d.getSet(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Set<String>
         */
        public Set<String> getSet(List<String> path) {
            return (Set<String>) pp_R.toSet.run(this.getObject(path));
        }

        /**
         * Get the Set from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Set<String> value = d.getSet('person.value');
         * ```
         *
         * @param path The path
         * @return Set<String>
         */
        public Set<String> getSet(String path) {
            return this.getSet(path.split('\\.'));
        }

        /**
         * Set the Map to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setMap(new List<String>{ 'person', 'value' }, new Map<String, Object>{ 'test' => 'value' });
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setMap(List<String> path, Object value) {
            return this.setObject(path, pp_R.toMap.run(value));
        }

        /**
         * Set the Map to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setMap('person.value', new Map<String, Object>{ 'test' => 'value' });
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setMap(String path, Object value) {
            return this.setMap(path.split('\\.'), value);
        }

        /**
         * Get the Map from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Map<String, Object> value = d.getMap(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Map<String, Object>
         */
        public Map<String, Object> getMap(List<String> path) {
            return (Map<String, Object>) pp_R.toMap.run(this.getObject(path));
        }

        /**
         * Get the Map from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Map<String, Object> value = d.getMap('person.value');
         * ```
         *
         * @param path The path
         * @return Map<String, Object>
         */
        public Map<String, Object> getMap(String path) {
            return this.getMap(path.split('\\.'));
        }

        /**
         * Set the SObject to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setSObject(new List<String>{ 'person', 'value' }, new Account());
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setSObject(List<String> path, Object value) {
            return this.setObject(path, pp_R.toSObject.run(value));
        }

        /**
         * Set the SObject to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setSObject('person.value', new Account());
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setSObject(String path, Object value) {
            return this.setSObject(path.split('\\.'), value);
        }

        /**
         * Get the SObject from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * SObject value = d.getSObject(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return SObject
         */
        public SObject getSObject(List<String> path) {
            return (SObject) pp_R.toSObject.run(this.getObject(path));
        }

        /**
         * Get the SObject from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * SObject value = d.getSObject('person.value');
         * ```
         *
         * @param path The path
         * @return SObject
         */
        public SObject getSObject(String path) {
            return this.getSObject(path.split('\\.'));
        }

        /**
         * Set the Date to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setDate(new List<String>{ 'person', 'value' }, Date.newInstance(2018, 1, 1));
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setDate(List<String> path, Object value) {
            return this.setObject(path, pp_R.toDate.run(value));
        }

        /**
         * Set the Date to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setDate('person.value', Date.newInstance(2018, 1, 1));
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setDate(String path, Object value) {
            return this.setDate(path.split('\\.'), value);
        }

        /**
         * Get the Date from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Date value = d.getDate(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Date
         */
        public Date getDate(List<String> path) {
            return (Date) pp_R.toDate.run(this.getObject(path));
        }

        /**
         * Get the Date from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Date value = d.getDate('person.value');
         * ```
         *
         * @param path The path
         * @return Date
         */
        public Date getDate(String path) {
            return this.getDate(path.split('\\.'));
        }

        /**
         * Set the Time to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setTime(new List<String>{ 'person', 'value' }, Time.newInstance(10, 0, 0, 0));
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setTime(List<String> path, Object value) {
            return this.setObject(path, pp_R.toTime.run(value));
        }

        /**
         * Set the Time to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setTime('person.value', Time.newInstance(10, 0, 0, 0));
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setTime(String path, Object value) {
            return this.setTime(path.split('\\.'), value);
        }

        /**
         * Get the Time from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Time value = d.getTime(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Time
         */
        public Time getTime(List<String> path) {
            return (Time) pp_R.toTime.run(this.getObject(path));
        }

        /**
         * Get the Time from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Time value = d.getTime('person.value');
         * ```
         *
         * @param path The path
         * @return Time
         */
        public Time getTime(String path) {
            return this.getTime(path.split('\\.'));
        }

        /**
         * Set the Datetime to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setDatetime(new List<String>{ 'person', 'value' }, Datetime.newInstance(2018, 1, 1, 0, 0, 0));
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setDatetime(List<String> path, Object value) {
            return this.setObject(path, pp_R.toDatetime.run(value));
        }

        /**
         * Set the Datetime to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setDatetime('person.value', Datetime.newInstance(2018, 1, 1, 0, 0, 0));
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setDatetime(String path, Object value) {
            return this.setDatetime(path.split('\\.'), value);
        }

        /**
         * Get the Datetime from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Datetime value = d.getDatetime(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return Datetime
         */
        public Datetime getDatetime(List<String> path) {
            return (Datetime) pp_R.toDatetime.run(this.getObject(path));
        }

        /**
         * Get the Datetime from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * Datetime value = d.getDatetime('person.value');
         * ```
         *
         * @param path The path
         * @return Datetime
         */
        public Datetime getDatetime(String path) {
            return this.getDatetime(path.split('\\.'));
        }

        /**
         * Set the pp_Func to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setFunc(new List<String>{ 'person', 'value' }, pp_R.identity);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setFunc(List<String> path, Object value) {
            return this.setObject(path, pp_R.toFunc.run(value));
        }

        /**
         * Set the pp_Func to the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * d.setFunc('person.value', pp_R.identity);
         * ```
         *
         * @param path The path
         * @param value The value
         * @return DTO
         */
        public DTO setFunc(String path, Object value) {
            return this.setFunc(path.split('\\.'), value);
        }

        /**
         * Get the pp_Func from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * pp_Func value = d.getFunc(new List<String>{ 'person', 'value' });
         * ```
         *
         * @param path The path
         * @return pp_Func
         */
        public pp_Func getFunc(List<String> path) {
            return (pp_Func) pp_R.toFunc.run(this.getObject(path));
        }

        /**
         * Get the pp_Func from the path
         *
         * Example:
         * ```
         * pp_Mapper.DTO d = new pp_Mapper.DTO();
         * pp_Func value = d.getFunc('person.value');
         * ```
         *
         * @param path The path
         * @return pp_Func
         */
        public pp_Func getFunc(String path) {
            return this.getFunc(path.split('\\.'));
        }
    }

    public class MapperException extends Exception {
    }
}