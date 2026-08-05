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
 * pp_MObjects are Managed Objects, which are peers of SObjects, with the ability to better control
 * object relationships
 *
 * For SObjects, the reference and relationship fields are system-generated and we cannot update them directly
 * by putting values in
 * We have to manually take care of the orders of creating and updating SObjects
 *
 * pp_MObjects are used to get rid of the chores by tracking the object changes and persisting them automatically
 *
 * Example:
 * ```
 * Opportunity op = findOpportunity();
 * pp_MObject mo = pp_MObject.create(op);
 * mo.put('Name', 'New ' + mo.get('Name'));
 * mo.put('Pricebook2', pp_MObject.create(new Pricebook2(Name='test price book')));
 * mo.persist();
 * ```
 *
 * Note:
 * pp_MObjects take care of pure object relationships and therefore the 'Pricebook2Id' in the above example,
 * which is used to track the reference to Pricebook2, is not generated in pp_MObject as 'Pricebook2' object
 * relationship is already available
 */
public class pp_MObject {
    private static Boolean isDebug = false;

    // The type info
    private TypeInfo info;

    // Fields are to track the basic Object values
    private Map<String, Object> fields = new Map<String, Object>();

    // References are to track the Object lookup values
    private Map<String, pp_MObject> references = new Map<String, pp_MObject>();

    // Relationships are to track the lists of Object having the lookup references
    private Map<String, List<pp_MObject>> relationships = new Map<String, List<pp_MObject>>();

    // Track if the pp_MObject is updated
    private Boolean isDirty = false;

    // Track if the pp_MObject is marked to be deleted
    private Boolean isDeleted = false;

    // Track the reference Ids passed down from parent pp_MObject
    private Map<String, Id> refKeys = new Map<String, Id>();

    /**
     * Create an instance of pp_MObject, with SObjectType and data
     *
     * @param sType The SObjectType
     * @param data The Object values
     */
    private pp_MObject(Schema.SObjectType sType, Map<String, Object> data) {
        // get object type from possible Id
        if (sType == null && data.containsKey('Id')) {
            Id sId = (Id) data.get('Id');
            sType = sId.getSobjectType();
        }

        this.info = getTypeInfo(sType);

        if (data == null) {
            data = new Map<String, Object>();
        }

        for (String key : data.keySet()) {
            Object value = data.get(key);

            if (this.info.containsField(key)) {
                Schema.DescribeFieldResult field = this.info.findField(key);
                if (field != null) {
                    if (field.getType() == Schema.DisplayType.BOOLEAN && value == null) {
                        value = false;
                    }
                    // Maps qualified field name to its value
                    this.fields.put(field.getName(), value);
                }
            } else if (this.info.containsReference(key)) {
                Schema.DescribeFieldResult reference = this.info.findReference(key);
                if (reference != null) {
                    List<Schema.SObjectType> referenceTos = reference.getReferenceTo();
                    Schema.SObjectType referenceTo = referenceTos.get(0);
                    // Maps qualified relationship name to the pp_MObject
                    this.references.put(reference.getRelationshipName(), create(referenceTo, value));
                }
            } else if (this.info.containsRelationship(key)) {
                Schema.ChildRelationship relationship = this.info.findRelationship(key);
                if (relationship != null) {
                    if (value instanceof List<Object>) {
                        List<Object> children = (List<Object>) value;
                        Schema.SObjectType childType = relationship.getChildSObject();

                        // Maps qualified relationship name to the list of pp_MObjects
                        this.relationships.put(relationship.getRelationshipName(), createList(childType, children));
                    }
                }
            }
        }

        // Fill default values
        for (Schema.DescribeFieldResult field : this.info.qualifiedFields.values()) {
            String name = field.getLocalName();
            String qualifiedName = field.getName();
            if (!data.containsKey(name) && !data.containsKey(qualifiedName) && field.getDefaultValueFormula() != null) {
                this.fields.put(qualifiedName, field.getDefaultValue());
            }
        }
    }

    /**
     * Convert to map with trimmed namespaces
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * Map<String, Object> data = mo.toMap(true);
     * ```
     *
     * @param trimNamespace Whether namespace is trimmed
     * @return Map<String, Object>
     */
    public Map<String, Object> toMap(Boolean trimNamespace) {
        return (Map<String, Object>) F.toMap.run(trimNamespace, this);
    }

    /**
     * Convert to map with untrimmed namespace
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * Map<String, Object> data = mo.toMap();
     * ```
     *
     * @return Map<String, Object>
     */
    public Map<String, Object> toMap() {
        return toMap(false);
    }

    /**
     * Get the value of the path, returning default value if null
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * String name = (String)mo.get('LastModifiedBy.Name', 'Unknown');
     * ```
     *
     * @param path The path of the field
     * @param defaultValue The default value if null
     * @return Object
     */
    public Object get(String path, Object defaultValue) {
        return F.get.run(defaultValue, path, this);
    }

    /**
     * Get the value of the path
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * String name = (String)mo.get('LastModifiedBy.Name');
     * ```
     *
     * @param path The path of the field
     * @return Object
     */
    public Object get(String path) {
        return F.get.run(path, this);
    }

    /**
     * Get the value of the path, returning default value if null
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * String name = (String)mo.get(new List<String>{ 'LastModifiedBy', 'Name' }, 'Unknown');
     * ```
     *
     * @param path The path of the field
     * @param defaultValue The default value if null
     * @return Object
     */
    public Object get(List<String> path, Object defaultValue) {
        return F.get.run(defaultValue, path, this);
    }

    /**
     * Get the value of the path
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * String name = (String)mo.get(new List<String>{ 'LastModifiedBy', 'Name' });
     * ```
     *
     * @param path The path of the field
     * @return Object
     */
    public Object get(List<String> path) {
        return F.get.run(path, this);
    }

    /**
     * Update the value of the path
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * mo.put('LastModifiedBy.Name', 'Wilson');
     * ```
     *
     * @param path The path of the field
     * @param value The value to be updated to
     * @return pp_MObject
     */
    public pp_MObject put(String path, Object value) {
        F.put.run(path, value, this);

        return this;
    }

    /**
     * Update the value of the path
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * mo.put(new List<String>{ 'LastModifiedBy', 'Name' }, 'Wilson');
     * ```
     *
     * @param path The path of the field
     * @param value The value to be updated to
     * @return pp_MObject
     */
    public pp_MObject put(List<String> path, Object value) {
        F.put.run(path, value, this);

        return this;
    }

    /**
     * Mark the pp_MObject as deleted cascadingly
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * mo.markDeleted(true);
     * ```
     *
     * @param cascade Whether to delete all children cascadingly
     * @return pp_MObject
     */
    public pp_MObject markDeleted(Boolean cascade) {
        F.markDeleted.run(cascade, this);

        return this;
    }

    /**
     * Mark the pp_MObject as deleted
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * mo.markDeleted();
     * ```
     *
     * @return pp_MObject
     */
    public pp_MObject markDeleted() {
        F.markDeleted.run(this);

        return this;
    }

    /**
     * Check if the pp_MObject has been updated
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * Boolean dirty = mo.isDirty();
     * ```
     *
     * @return Boolean
     */
    public Boolean isDirty() {
        return this.isDirty;
    }

    /**
     * Check if the pp_MObject has been marked as deleted
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * Boolean deleted = mo.isDeleted();
     * ```
     *
     * @return Boolean
     */
    public Boolean isDeleted() {
        return this.isDeleted;
    }

    /**
     * Persist the pp_MObject
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * mo.put('Name', 'new name');
     * mo.persist();
     * ```
     *
     * @return pp_MObject
     */
    public pp_MObject persist() {
        persist(this);

        return this;
    }

    /**
     * Give a string representation of the pp_MObject
     *
     * @return String
     */
    public override String toString() {
        return 'pp_MObject[' + getName(this.info.sType) + '] Fields: ' + this.fields +
                ' References: ' + this.references + ' Relationships: ' + this.relationships;
    }

    // Get the value mapped by the key, non-recursive, checking accessibility
    private Object getValue(String key) {
        if (this.info.containsField(key)) {
            Schema.DescribeFieldResult field = this.info.findField(key);
            if (!field.isAccessible()) {
                throw new MObjectException('Field is not accessible: ' + key);
            }
            String fieldName = field.getName();
            return this.fields.get(fieldName);
        } else if (this.info.containsReference(key)) {
            Schema.DescribeFieldResult reference = this.info.findReference(key);
            if (!reference.isAccessible()) {
                throw new MObjectException('Reference is not accessible: ' + key);
            }
            String referenceName = reference.getRelationshipName();
            return this.references.get(referenceName);
        } else if (this.info.containsRelationship(key)) {
            Schema.ChildRelationship relationship = this.info.findRelationship(key);
            Schema.DescribeFieldResult field = relationship.getField().getDescribe();
            if (!field.isAccessible()) {
                throw new MObjectException('Relationship is not accessible: ' + key);
            }
            String relationshipName = relationship.getRelationshipName();
            return this.relationships.get(relationshipName);
        } else {
            return null;
        }
    }

    // Set the value mapped the key, non-recursive, checking updateability
    private Boolean setValue(String key, Object value) {
        if (this.info.containsField(key)) {
            Schema.DescribeFieldResult field = this.info.findField(key);
            if (!field.isUpdateable() && !(this.fields.get('Id') == null && (key == 'Id' || field.isCreateable()))) {
                throw new MObjectException('Field is not updateable: ' + key);
            }
            String fieldName = field.getName();
            this.fields.put(fieldName, value);

            this.isDirty = true;
            return true;
        } else if (this.info.containsReference(key)) {
            Schema.DescribeFieldResult reference = this.info.findReference(key);
            if (!reference.isUpdateable() && !(this.fields.get('Id') == null && reference.isCreateable())) {
                throw new MObjectException('Field is not updateable: ' + key);
            }
            String referenceName = reference.getRelationshipName();
            this.references.put(referenceName, create(value));

            this.isDirty = true;
            return true;
        } else if (this.info.containsRelationship(key)) {
            Schema.ChildRelationship relationship = this.info.findRelationship(key);
            Schema.DescribeFieldResult field = relationship.getField().getDescribe();
            if (!field.isUpdateable() && !(this.fields.get('Id') == null && field.isCreateable())) {
                throw new MObjectException('Relationship is not updateable: ' + key);
            }
            String relationshipName = relationship.getRelationshipName();
            this.relationships.put(relationshipName, createList((List<Object>) value));

            this.isDirty = true;
            return true;
        }

        return false;
    }

    /**
     * Create an instance of pp_MObject
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(Pricebook2.sObjectType, new Map<String, Object>());
     * ```
     *
     * @param sType The SObject type
     * @param source The source of the data
     * @return pp_MObject
     */
    public static pp_MObject create(Schema.SObjectType sType, Object source) {
        return (pp_MObject) F.create.run(sType, source);
    }

    /**
     * Create an instance of pp_MObject
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(Pricebook2.sObjectType);
     * ```
     *
     * @param sType The SObject type
     * @return pp_MObject
     */
    public static pp_MObject create(Schema.SObjectType sType) {
        return create(sType, null);
    }

    /**
     * Create an instance of pp_MObject
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create('Pricebook2', new Map<String, Object>());
     * ```
     *
     * @param typeName The SObject type name
     * @param source The source of data
     * @return pp_MObject
     */
    public static pp_MObject create(String typeName, Object source) {
        return (pp_MObject) F.create.run(typeName, source);
    }

    /**
     * Create an instance of pp_MObject
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create('Pricebook2');
     * ```
     *
     * @param typeName The SObject type name
     * @return pp_MObject
     */
    public static pp_MObject create(String typeName) {
        return create(typeName, null);
    }

    /**
     * Create an instance of pp_MObject
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2());
     * ```
     *
     * @param source The source of data
     * @return pp_MObject
     */
    public static pp_MObject create(Object source) {
        return (pp_MObject) F.create.run(source);
    }

    /**
     * Create a list of pp_MObjects
     *
     * Example:
     * ```
     * List<pp_MObject> mos = pp_MObject.createList(Pricebook2.sObjectType, new List<Map<String, Object>>());
     * ```
     *
     * @param sType The SObject type
     * @param sources The sources of data
     * @return List<pp_MObject>
     */
    public static List<pp_MObject> createList(Schema.SObjectType sType, List<Object> sources) {
        List<pp_MObject> ret = new List<pp_MObject>();
        for (Object source : sources) {
            ret.add(create(sType, source));
        }

        return ret;
    }

    /**
     * Create a list of pp_MObjects
     *
     * Example:
     * ```
     * List<pp_MObject> mos = pp_MObject.createList('Pricebook2', new List<Map<String, Object>>());
     * ```
     *
     * @param typeName The SObject type name
     * @param sources The sources of data
     * @return List<pp_MObject>
     */
    public static List<pp_MObject> createList(String typeName, List<Object> sources) {
        List<pp_MObject> ret = new List<pp_MObject>();
        for (Object source : sources) {
            ret.add(create(typeName, source));
        }

        return ret;
    }

    /**
     * Create a list of pp_MObjects
     *
     * Example:
     * ```
     * List<pp_MObject> mos = pp_MObject.createList(new List<Pricebook2>());
     * ```
     *
     * @param sources The sources of data
     * @return List<pp_MObject>
     */
    public static List<pp_MObject> createList(List<Object> sources) {
        List<pp_MObject> ret = new List<pp_MObject>();
        for (Object source : sources) {
            ret.add(create(source));
        }

        return ret;
    }

    /**
     * Persist the list of pp_MObjects
     *
     * Example:
     * ```
     * List<pp_MObject> mos = pp_MObject.createList(new List<Pricebook2>());
     * for(pp_MObject mo : mos) {
     *     mo.put('Name', 'new name');
     * }
     * pp_MObject.persist(mos);
     * ```
     *
     * @param mos The list of pp_MObjects
     */
    public static void persist(List<pp_MObject> mos) {
        F.persist.run(mos);
    }

    /**
     * Persist the list of pp_MObjects with DML options
     *
     * Example:
     * ```
     * List<pp_MObject> mos = pp_MObject.createList(new List<Pricebook2>());
     * for(pp_MObject mo : mos) {
     *     mo.put('Name', 'new name');
     * }
     * Database.DMLOptions dmlOptions = new Database.DMLOptions();
     * dmlOptions.allowFieldTruncation = true;
     * pp_MObject.persist(mos, dmlOptions);
     * ```
     *
     * @param mos The list of pp_MObjects
     * @param dmlOptions Database.DMLOptions variable
     */
    public static void persist(List<pp_MObject> mos, Database.DMLOptions dmlOptions) {
        F.persist.run(mos, dmlOptions);
    }

    /**
     * Persist one pp_MObject
     *
     * Example:
     * ```
     * pp_MObject mo = pp_MObject.create(new Pricebook2(Name='pricebook'));
     * pp_MObject.persist(mo);
     * ```
     *
     * @param mo The pp_MObject
     */
    public static void persist(pp_MObject mo) {
        F.persist.run(mo);
    }

    // All SObject types mapped by names with namespace
    private static final Map<String, Schema.SObjectType> qualifiedSObjectTypes = Schema.getGlobalDescribe();

    // All SObject types mapped by names without namespace
    private static final Map<String, List<Schema.SObjectType>> sObjectTypes = new Map<String, List<Schema.SObjectType>>();

    // Mapping from SObject type to TypeInfo
    private static final Map<Schema.SObjectType, TypeInfo> typeInfos = new Map<Schema.SObjectType, TypeInfo>();

    // Get default namespace
    private static final String namespace = getNamespaceFromClass();

    // Functional support
    public static final Funcs F = new Funcs();

    static {
        for (Schema.SObjectType sType : qualifiedSObjectTypes.values()) {
            Schema.DescribeSObjectResult describe = sType.getDescribe();
            String name = describe.getLocalName();
            List<Schema.SObjectType> sTypes = sObjectTypes.get(name);
            if (sTypes == null) {
                sTypes = new List<Schema.SObjectType>();
            }
            sTypes.add(sType);
            sObjectTypes.put(name, sTypes);
        }
    }

    private static void debug(String message) {
        if (isDebug) {
            System.debug(message);
        }
    }

    // Get value recursively
    private static Object getValue(pp_MObject mo, List<String> path) {
        if (path == null || path.isEmpty()) {
            return null;
        } else if (path.size() == 1) {
            return mo.getValue(path.get(0));
        } else {
            Object value = mo.getValue(path.get(0));
            if (value instanceof pp_MObject) {
                return getValue((pp_MObject) value, pp_R.of(path).drop(1).toStringList());
            } else if (value instanceof List<pp_MObject>) {
                List<pp_MObject> mos = (List<pp_MObject>) value;
                String next = path.get(1);
                if (next.isNumeric()) {
                    Integer index = Integer.valueOf(next);
                    List<String> restPath = pp_R.of(path).drop(2).toStringList();
                    if (restPath.isEmpty()) {
                        return mos.get(index);
                    } else {
                        return getValue(mos.get(index), restPath);
                    }
                } else {
                    return null;
                }
            } else {
                return null;
            }
        }
    }

    // Set value recursively
    private static Boolean setValue(pp_MObject mo, List<String> path, Object value) {
        if (path == null || path.isEmpty()) {
            return false;
        } else if (path.size() == 1) {
            return mo.setValue(path.get(0), value);
        } else {
            Object next = mo.getValue(path.get(0));
            if (next instanceof pp_MObject) {
                return setValue((pp_MObject) next, pp_R.of(path).drop(1).toStringList(), value);
            } else if (next instanceof List<pp_MObject>) {
                List<pp_MObject> mos = (List<pp_MObject>) next;
                String item = path.get(1);
                if (item.isNumeric()) {
                    Integer index = Integer.valueOf(item);
                    List<String> restPath = pp_R.of(path).drop(2).toStringList();
                    if (restPath.isEmpty()) {
                        mos.set(index, create(value));
                        return mo.setValue(path.get(0), mos);
                    } else {
                        return setValue(mos.get(index), restPath, value);
                    }
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }

    // Get the namespace from this class
    private static String getNamespaceFromClass() {
        final String className = pp_MObject.class.getName();
        final List<String> nameSplit = className.split('\\.');

        if (nameSplit.size() > 1) {
            return nameSplit.get(0) + '__';
        } else {
            return '';
        }
    }

    // Get the display name
    private static String getName(Schema.SObjectType sType) {
        return sType.getDescribe().getName();
    }

    // Find the SObject type from the type name
    private static Schema.SObjectType findSObjectType(String typeName) {
        if (qualifiedSObjectTypes.containsKey(typeName)) {
            return qualifiedSObjectTypes.get(typeName);
        } else if (sObjectTypes.containsKey(typeName)) {
            List<Schema.SObjectType> sTypes = sObjectTypes.get(typeName);
            if (sTypes.size() == 1) {
                return sTypes.get(0);
            } else {
                Schema.SObjectType found = null;
                for (Schema.SObjectType sType : sTypes) {
                    if (sType.getDescribe().getName().startsWith(pp_MObject.namespace)) {
                        found = sType;
                        break;
                    }
                }

                return found;
            }
        }

        return null;
    }

    // Get the type info from the SObject type
    private static TypeInfo getTypeInfo(Schema.SObjectType sType) {
        TypeInfo info = typeInfos.get(sType);
        if (info == null) {
            info = new TypeInfo(sType);
            typeInfos.put(sType, info);
        }

        return info;
    }

    // Trim the namespace
    private static String trimNamespace(String name, String namespace) {
        if (!String.isBlank(name) && !String.isBlank(namespace)) {
            if (name.startsWith(namespace)) {
                return name.substring(namespace.length());
            }
        }

        return name;
    }

    // Prepend namespace to the name
    private static String prependNamespace(String name, String namespace) {
        if (!String.isBlank(name) && !String.isBlank(namespace)) {
            if (!name.startsWith(namespace)) {
                return namespace + name;
            }
        }

        return name;
    }

    // Detect the namespace
    private static String detectNamespace(Schema.DescribeFieldResult field) {
        return detectNamespace(field.getLocalName(), field.getName());
    }

    // Detect the namespace
    private static String detectNamespace(Schema.ChildRelationship relationship) {
        Schema.DescribeFieldResult field = relationship.getField().getDescribe();
        return detectNamespace(field);
    }

    // Detect the namespace
    private static String detectNamespace(String name, String qualifiedName) {
        if (!String.isBlank(name) && !String.isBlank(qualifiedName)) {
            return qualifiedName.substring(0, qualifiedName.length() - name.length());
        }

        return '';
    }

    /**
     * TypeInfos hold the information of the fields, references and relationships of the SObject type
     */
    private class TypeInfo {
        // The target SObject type
        public Schema.SObjectType sType;

        // Fields without namespace
        public Map<String, List<Schema.DescribeFieldResult>> fields = new Map<String, List<Schema.DescribeFieldResult>>();
        // Fields with namespace
        public Map<String, Schema.DescribeFieldResult> qualifiedFields = new Map<String, Schema.DescribeFieldResult>();

        // References without namespace
        public Map<String, List<Schema.DescribeFieldResult>> references = new Map<String, List<Schema.DescribeFieldResult>>();
        // References with namespace
        public Map<String, Schema.DescribeFieldResult> qualifiedReferences = new Map<String, Schema.DescribeFieldResult>();

        // Relationships without namespace
        public Map<String, List<Schema.ChildRelationship>> relationships = new Map<String, List<Schema.ChildRelationship>>();
        // Relationships with namespace
        public Map<String, Schema.ChildRelationship> qualifiedRelationships = new Map<String, Schema.ChildRelationship>();

        /**
         * Construct a TypeInfo from SObject type
         *
         * @param sType The SObject type
         */
        public TypeInfo(Schema.SObjectType sType) {
            if (sType == null) {
                throw new MObjectException('SObject type is required');
            }
            this.sType = sType;

            Schema.DescribeSObjectResult result = sType.getDescribe();
            Map<String, Schema.SObjectField> fields = result.fields.getMap();
            for (Schema.SObjectField f : fields.values()) {
                Schema.DescribeFieldResult fieldDescribe = f.getDescribe();
                if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                    // Manage references
                    this.addReference(fieldDescribe);
                } else {
                    // Manage normal fields
                    this.addField(fieldDescribe);
                }
            }

            for (Schema.ChildRelationship relationship : result.getChildRelationships()) {
                // Manage relationships
                this.addRelationship(relationship);
            }
        }

        /**
         * Check if it contains the field
         *
         * @param name The field name
         * @return Boolean
         */
        public Boolean containsField(String name) {
            return this.fields.containsKey(name) || this.qualifiedFields.containsKey(name);
        }

        /**
         * Check if it contains the reference
         *
         * @param name The reference name
         * @return Boolean
         */
        public Boolean containsReference(String name) {
            return this.references.containsKey(name) || this.qualifiedReferences.containsKey(name);
        }

        /**
         * Check if it contains the relationship
         *
         * @param name The relationship name
         * @return Boolean
         */
        public Boolean containsRelationship(String name) {
            return this.relationships.containsKey(name) || this.qualifiedRelationships.containsKey(name);
        }

        /**
         * Find the field
         *
         * @param fieldName The field name
         * @return DescribeFieldResult
         */
        public Schema.DescribeFieldResult findField(String fieldName) {
            if (this.qualifiedFields.containsKey(fieldName)) {
                return this.qualifiedFields.get(fieldName);
            } else if (this.fields.containsKey(fieldName)) {
                List<Schema.DescribeFieldResult> fields = this.fields.get(fieldName);
                if (fields.size() == 1) {
                    return fields.get(0);
                } else {
                    // If name conflicts occur, resolve to the default namespace
                    Schema.DescribeFieldResult found = null;
                    for (Schema.DescribeFieldResult field : fields) {
                        if (field.getName().startsWith(pp_MObject.namespace)) {
                            found = field;
                            break;
                        }
                    }

                    return found;
                }
            } else {
                return null;
            }
        }

        /**
         * Find the reference
         *
         * @param referenceName The reference name
         * @return DescribeFieldResult
         */
        public Schema.DescribeFieldResult findReference(String referenceName) {
            if (this.qualifiedReferences.containsKey(referenceName)) {
                return this.qualifiedReferences.get(referenceName);
            } else if (this.references.containsKey(referenceName)) {
                List<Schema.DescribeFieldResult> references = this.references.get(referenceName);
                if (references.size() == 1) {
                    return references.get(0);
                } else {
                    // If name conflicts occur, resolve to the default namespace
                    Schema.DescribeFieldResult found = null;
                    for (Schema.DescribeFieldResult reference : references) {
                        if (reference.getName().startsWith(pp_MObject.namespace)) {
                            found = reference;
                            break;
                        }
                    }

                    return found;
                }
            } else {
                return null;
            }
        }

        /**
         * Find the relationship
         *
         * @param relationshipName The relationship name
         * @return ChildRelationship
         */
        public Schema.ChildRelationship findRelationship(String relationshipName) {
            if (this.qualifiedRelationships.containsKey(relationshipName)) {
                return this.qualifiedRelationships.get(relationshipName);
            } else if (this.relationships.containsKey(relationshipName)) {
                List<Schema.ChildRelationship> relationships = this.relationships.get(relationshipName);
                if (relationships.size() == 1) {
                    return relationships.get(0);
                } else {
                    // If name conflicts occur, resolve to the default namespace
                    Schema.ChildRelationship found = null;
                    for (Schema.ChildRelationship relationship : relationships) {
                        if (relationship.getRelationshipName().startsWith(pp_MObject.namespace)) {
                            found = relationship;
                            break;
                        }
                    }

                    return found;
                }
            } else {
                return null;
            }
        }

        // Add field
        private void addField(Schema.DescribeFieldResult field) {
            String name = field.getLocalName();
            String qualifiedName = field.getName();

            List<Schema.DescribeFieldResult> fields = this.fields.get(name);
            if (fields == null) {
                fields = new List<Schema.DescribeFieldResult>();
            }
            fields.add(field);
            this.fields.put(name, fields);

            this.qualifiedFields.put(qualifiedName, field);
        }

        // Add reference
        private void addReference(Schema.DescribeFieldResult reference) {
            String relationshipName = reference.getRelationshipName();
            String namespace = detectNamespace(reference.getLocalName(), reference.getName());
            String name = trimNamespace(relationshipName, namespace);
            String qualifiedName = prependNamespace(relationshipName, namespace);

            List<Schema.DescribeFieldResult> references = this.references.get(name);
            if (references == null) {
                references = new List<Schema.DescribeFieldResult>();
            }
            references.add(reference);
            this.references.put(name, references);

            this.qualifiedReferences.put(qualifiedName, reference);

            // also track in fields
            addField(reference);
        }

        // Add relationship
        private void addRelationship(Schema.ChildRelationship relationship) {
            String relationshipName = relationship.getRelationshipName();
            Schema.DescribeFieldResult fieldDescribe = relationship.getField().getDescribe();
            String namespace = detectNamespace(fieldDescribe.getLocalName(), fieldDescribe.getName());
            String name = trimNamespace(relationshipName, namespace);
            String qualifiedName = prependNamespace(relationshipName, namespace);

            List<Schema.ChildRelationship> relationships = this.relationships.get(name);
            if (relationships == null) {
                relationships = new List<Schema.ChildRelationship>();
            }
            relationships.add(relationship);
            this.relationships.put(name, relationships);

            this.qualifiedRelationships.put(qualifiedName, relationship);
        }
    }

    public class MObjectException extends Exception {
    }

    public class Funcs {
        /**
         * Create an instance of pp_MObject
         *
         * Example:
         * ```
         * pp_MObject mo = (pp_MObject)pp_MObject.F.create.run(new Pricebook2(Name='test'));
         * ```
         *
         * @param arg1 It could be the SObject type/type name/source
         * @param arg2 The source
         * @return Object(pp_MObject)
         */
        public pp_Func create = new CreateFunc();

        /**
         * Convert the pp_MObject to map
         *
         * Example:
         * ```
         * Map<String, Object> data = (Map<String, Object>)pp_MObject.F.toMap.run(false, mo);
         * ```
         *
         * @param arg1 Whether to trim namespaces
         * @param arg2 The pp_MObject
         * @return Object(Map<String, Object>)
         */
        public pp_Func toMap = new ToMapFunc();

        /**
         * Get the value mapped by the path
         *
         * Example:
         * ```
         * Object value = pp_MObject.F.get.run('default', 'Name', mo);
         * ```
         *
         * @param arg1 The default value
         * @param arg2 The path
         * @param arg3 The pp_MObject
         * @return Object
         */
        public pp_Func get = new GetFunc();

        /**
         * Set the value mapped by the path
         *
         * Example:
         * ```
         * pp_MObject.F.put.run('Name', 'new Name', mo);
         * ```
         *
         * @param arg1 The path
         * @param arg2 The new value
         * @param arg3 The pp_MObject
         * @return Object
         */
        public pp_Func put = new PutFunc();

        /**
         * Mark the pp_MObject as deleted
         *
         * Example:
         * ```
         * pp_MObject.F.markDeleted.run(true, mo);
         * ```
         *
         * @param arg1 Whether to delete cascadingly
         * @param arg2 The pp_MObject
         * @return Object(pp_MObject)
         */
        public pp_Func markDeleted = new MarkDeletedFunc();

        /**
         * Persist the pp_MObject(s)
         *
         * Example:
         * ```
         * pp_MObject.F.persist.run(mos);
         * ```
         *
         * @param arg The pp_MObject or list of pp_MObjects
         * @return Object
         */
        public pp_Func persist = new PersistFunc();
    }

    private class CreateFunc extends pp_Func {
        public CreateFunc() {
            super(-1);
        }

        public override Object exec(Object arg) {
            return this.exec(null, arg);
        }

        public override Object exec(Object arg1, Object arg2) {
            Schema.SObjectType sType = null;
            if (arg1 instanceof Schema.SObjectType) {
                sType = (Schema.SObjectType) arg1;
            } else if (arg1 instanceof String) {
                sType = findSObjectType((String) arg1);
            }
            Object source = arg2;

            if (source instanceof pp_MObject) {
                return (pp_MObject) source;
            } else if (source instanceof SObject) {
                SObject so = (SObject) source;
                return new pp_MObject(so.getSObjectType(), so.getPopulatedFieldsAsMap());
            } else if (source instanceof Map<String, Object>) {
                return new pp_MObject(sType, (Map<String, Object>) source);
            } else {
                return null;
            }
        }
    }

    private class ToMapFunc extends pp_Func {
        public ToMapFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Boolean trimNamespace = (Boolean) pp_R.toBoolean.run(arg1);
            pp_MObject mo = (pp_MObject) arg2;
            Map<String, Object> result = new Map<String, Object>();

            for (String key : mo.fields.keySet()) {
                Object value = mo.fields.get(key);
                if (trimNamespace) {
                    Schema.DescribeFieldResult field = mo.info.qualifiedFields.get(key);
                    String namespace = detectNamespace(field);
                    key = trimNamespace(key, namespace);
                }

                result.put(key, value);
            }

            for (String key : mo.references.keySet()) {
                pp_MObject value = mo.references.get(key);
                if (trimNamespace) {
                    Schema.DescribeFieldResult reference = mo.info.qualifiedReferences.get(key);
                    String namespace = detectNamespace(reference);
                    key = trimNamespace(key, namespace);
                }

                result.put(key, value.toMap(trimNamespace));
            }

            for (String key : mo.relationships.keySet()) {
                List<pp_MObject> value = mo.relationships.get(key);
                if (trimNamespace) {
                    Schema.ChildRelationship relationship = mo.info.qualifiedRelationships.get(key);
                    String namespace = detectNamespace(relationship);
                    key = trimNamespace(key, namespace);
                }

                List<Object> mlist = new List<Object>();
                for (pp_MObject child : value) {
                    mlist.add(child.toMap(trimNamespace));
                }

                result.put(key, mlist);
            }

            return result;
        }
    }

    private class GetFunc extends pp_Func {
        public GetFunc() {
            super(-1);
        }

        public override Object exec(Object arg1, Object arg2) {
            return this.exec(null, arg1, arg2);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Object defaultValue = arg1;
            pp_MObject mo = (pp_MObject) arg3;
            List<String> path = null;
            if (arg2 instanceof List<Object>) {
                path = pp_R.of(arg2).toStringList();
            } else {
                path = pp_R.of(arg2).split('\\.').toStringList();
            }

            Object value = getValue(mo, path);
            return value == null ? defaultValue : value;
        }
    }

    private class PutFunc extends pp_Func {
        public PutFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Object value = arg2;
            pp_MObject mo = (pp_MObject) arg3;
            List<String> path = null;
            if (arg1 instanceof List<Object>) {
                path = pp_R.of(arg1).toStringList();
            } else {
                path = pp_R.of(arg1).split('\\.').toStringList();
            }

            return setValue(mo, path, value);
        }
    }

    private class MarkDeletedFunc extends pp_Func {
        public MarkDeletedFunc() {
            super(-1);
        }

        public override Object exec(Object arg) {
            return this.exec(false, arg);
        }

        public override Object exec(Object arg1, Object arg2) {
            Boolean cascade = (Boolean) pp_R.toBoolean.run(arg1);
            pp_MObject mo = (pp_MObject) arg2;
            mo.isDeleted = true;

            if (cascade) {
                for (List<pp_MObject> moList : mo.relationships.values()) {
                    for (pp_MObject child : moList) {
                        child.markDeleted(cascade);
                    }
                }
            }

            return mo;
        }
    }

    private class PersistFunc extends pp_Func {
        public PersistFunc() {
            super(-1);
        }

        private Boolean toBeDeleted(pp_MObject mo) {
            return mo.isDeleted && mo.fields.get('Id') != null;
        }

        private Boolean toBeInserted(pp_MObject mo) {
            return !mo.isDeleted && mo.fields.get('Id') == null;
        }

        private Boolean toBeUpdated(pp_MObject mo) {
            return !mo.isDeleted && mo.isDirty;
        }

        private void collectToBeDeleted(pp_MObject mo, List<Id> ids) {
            for (List<pp_MObject> childList : mo.relationships.values()) {
                for (pp_MObject child : childList) {
                    collectToBeDeleted(child, ids);
                }
            }

            if (toBeDeleted(mo)) {
                ids.add((Id) mo.fields.get('Id'));
            }

            for (pp_MObject reference : mo.references.values()) {
                collectToBeDeleted(reference, ids);
            }
        }

        private void collectToBeInserted(pp_MObject mo, List<pp_MObject> toBeInserted) {
            for (pp_MObject reference : mo.references.values()) {
                collectToBeInserted(reference, toBeInserted);
            }

            Boolean hasPendingInsert = false;
            for (pp_MObject reference : mo.references.values()) {
                if (toBeInserted(reference)) {
                    hasPendingInsert = true;
                    break;
                }
            }

            if (hasPendingInsert) {
                return;
            }

            if (toBeInserted(mo)) {
                toBeInserted.add(mo);
                return;
            }

            for (String relationshipName : mo.relationships.keySet()) {
                List<pp_MObject> childList = mo.relationships.get(relationshipName);
                Schema.ChildRelationship relationship = mo.info.qualifiedRelationships.get(relationshipName);
                Schema.DescribeFieldResult field = relationship.getField().getDescribe();
                for (pp_MObject child : childList) {
                    child.refKeys.put(field.getName(), (Id) mo.fields.get('Id'));
                    collectToBeInserted(child, toBeInserted);
                }
            }
        }

        private void collectToBeUpdated(pp_MObject mo, List<pp_MObject> toBeUpdated) {
            for (pp_MObject reference : mo.references.values()) {
                collectToBeUpdated(reference, toBeUpdated);
            }

            if (toBeUpdated(mo)) {
                toBeUpdated.add(mo);
            }

            for (String relationshipName : mo.relationships.keySet()) {
                List<pp_MObject> childList = mo.relationships.get(relationshipName);
                Schema.ChildRelationship relationship = mo.info.qualifiedRelationships.get(relationshipName);
                Schema.DescribeFieldResult field = relationship.getField().getDescribe();
                for (pp_MObject child : childList) {
                    child.refKeys.put(field.getName(), (Id) mo.fields.get('Id'));
                    collectToBeUpdated(child, toBeUpdated);
                }
            }
        }

        public override Object exec(Object arg) {
            return exec(arg, null);
        }
        public override Object exec(Object arg1, Object arg2) {
            List<pp_MObject> mos = null;
            if (arg1 instanceof List<pp_MObject>) {
                mos = (List<pp_MObject>) arg1;
            } else if (arg1 instanceof pp_MObject) {
                mos = new List<pp_MObject>{
                        (pp_MObject) arg1
                };
            } else {
                return arg1;
            }
            Database.DMLOptions dmlOptions = null;
            if (arg2 != null) dmlOptions = (Database.DMLOptions) arg2;

            // Delete First
            List<Id> toBeDeleted = new List<Id>();
            for (pp_MObject mo : mos) {
                collectToBeDeleted(mo, toBeDeleted);
            }
            debug('To be deleted: ' + toBeDeleted);
            Database.delete(toBeDeleted);

            // Insert
            List<pp_MObject> toBeInserted = new List<pp_MObject>();
            while (true) {
                for (pp_MObject mo : mos) {
                    collectToBeInserted(mo, toBeInserted);
                }

                debug('To be inserted: ' + toBeInserted);

                if (toBeInserted.isEmpty()) {
                    break;
                }

                List<SObject> soList = new List<SObject>();
                for (pp_MObject mo : toBeInserted) {
                    SObject so = mo.info.sType.newSObject();

                    for (String key : mo.fields.keySet()) {
                        Object value = mo.fields.get(key);
                        so.put(key, value);
                    }

                    for (String referenceName : mo.references.keySet()) {
                        pp_MObject reference = mo.references.get(referenceName);
                        Id referenceId = (Id) reference.fields.get('Id');
                        Schema.DescribeFieldResult field = mo.info.qualifiedReferences.get(referenceName);
                        String fieldName = field.getName();
                        so.put(fieldName, referenceId);
                    }

                    for (String refKey : mo.refKeys.keySet()) {
                        Id refKeyId = mo.refKeys.get(refKey);
                        so.put(refKey, refKeyId);
                    }

                    soList.add(so);
                }

                debug('Insert list: ' + soList);
                if (dmlOptions != null) Database.insert(soList, dmlOptions);
                else insert soList;

                for (Integer i = 0; i < toBeInserted.size(); i++) {
                    SObject so = soList.get(i);
                    pp_MObject mo = toBeInserted.get(i);
                    mo.fields.put('Id', so.Id);
                    mo.isDirty = false;
                }
                toBeInserted.clear();
            }

            // Update
            List<pp_MObject> toBeUpdated = new List<pp_MObject>();
            for (pp_MObject mo : mos) {
                collectToBeUpdated(mo, toBeUpdated);
            }

            debug('To be updated: ' + toBeUpdated);
            List<SObject> soList = new List<SObject>();
            for (pp_MObject mo : toBeUpdated) {
                SObject so = mo.info.sType.newSObject();

                for (String key : mo.fields.keySet()) {
                    Object value = mo.fields.get(key);
                    so.put(key, value);
                }

                for (String referenceName : mo.references.keySet()) {
                    pp_MObject reference = mo.references.get(referenceName);
                    Id referenceId = (Id) reference.fields.get('Id');
                    Schema.DescribeFieldResult field = mo.info.qualifiedReferences.get(referenceName);
                    String fieldName = field.getName();
                    so.put(fieldName, referenceId);
                }

                for (String refKey : mo.refKeys.keySet()) {
                    Id refKeyId = mo.refKeys.get(refKey);
                    so.put(refKey, refKeyId);
                }

                soList.add(so);
            }

            debug('update list: ' + soList);
            if (dmlOptions != null) Database.update(soList, dmlOptions);
            else update soList;

            for (pp_MObject mo : toBeUpdated) {
                mo.isDirty = false;
            }

            return arg1;
        }
    }
}