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
 * The controller for trigger handlers
 *
 * Example:
 * ```
 * // in trigger
 * trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
 *     pp_Trap.getInstance().start();
 * }
 *
 * // in trigger handler
 *  public with sharing class CaseTrigger extends pp_Trap.TriggerHandler {
 *
 *     public override void setUpBeforeInsert(pp_Trap.BulkObject bulkObj) {
 *         bulkObj.newStream
 *             .tap(pp_R.debug.apply('before insert'))
 *             .subscribe(pp_Trap.F.addError.apply('test error'));
 *     }
 * }
 * ```
 */
public class pp_Trap {
    /**
     * Exposed functions
     *
     * Example:
     * ```
     * pp_Trap.F.isBeforeInsert.run();
     * ```
     *
     */
    public static final Funcs F = new Funcs();

    // All pp_Trap instances, differentiated by suffixes
    private static Map<String, pp_Trap> INSTANCES = new Map<String, pp_Trap>();

    // The default trigger handler suffix
    private static final String DEFAULT_SUFFIX = 'TRIGGER';

    // The global trigger context
    private static Context currentTriggerContext = null;

    // Use mock handler for testing instead of real handlers
    private static Boolean useMock = false;

    // The trigger handler suffix for this controller
    private String suffix = DEFAULT_SUFFIX;

    // All instantiated trigger handlers
    private final Map<String, TriggerHandler> handlers = new Map<String, TriggerHandler>();

    // All instantiated trigger configs
    private final Map<String, TriggerConfig> configs = new Map<String, TriggerConfig>();

    // The recursion depth for the trigger handler events
    private Map<String, Integer> recursionDepth = new Map<String, Integer>();

    // The save point for the trigger handler events
    private Map<String, Savepoint> savePoints = new Map<String, Savepoint>();

    // The stack of trigger contexts
    private List<Context> triggerContexts = new List<Context>();

    // If all trigger handlers are disabled
    private Boolean disabled = false;

    /**
     * Get the default pp_Trap instance
     *
     * @return pp_Trap
     */
    public static pp_Trap getInstance() {
        return pp_Trap.getInstance(null);
    }

    /**
     * Get the pp_Trap instance with the given suffix of the trigger handlers
     *
     * @param suffix The suffix of the trigger handler
     * @return pp_Trap
     */
    public static pp_Trap getInstance(String suffix) {
        suffix = String.isBlank(suffix) ? DEFAULT_SUFFIX : suffix.toUpperCase();
        pp_Trap instance = INSTANCES.get(suffix);
        if (instance == null) {
            instance = new pp_Trap(suffix);
            INSTANCES.put(suffix, instance);
        }

        return instance;
    }

    // Private constructor
    private pp_Trap(String suffix) {
        this.suffix = suffix;
    }

    /**
     * Check if a trigger handler is enabled
     *
     * Example:
     * ```
     * pp_Trap.getInstance().isEnabled('Case');
     * ```
     *
     * @param name The name of the trigger handler
     * @return Boolean
     */
    public Boolean isEnabled(String name) {
        if (this.disabled) {
            return false;
        }

        TriggerConfig config = this.getTriggerConfig(name);
        return config.enabled;
    }

    /**
     * Enable the trigger handler
     *
     * Example:
     * ```
     * pp_Trap.getInstance().enable('Case');
     * ```
     *
     * @param name The name of the trigger handler
     * @return pp_Trap
     */
    public pp_Trap enable(String name) {
        return this.setEnabled(name, true);
    }

    /**
     * Disable the trigger handler
     *
     * Example:
     * ```
     * pp_Trap.getInstance().disable('Case');
     * ```
     *
     * @param name The name of the trigger handler
     * @return pp_Trap
     */
    public pp_Trap disable(String name) {
        return this.setEnabled(name, false);
    }

    /**
     * Set whether the trigger handler is enabled
     *
     * Example:
     * ```
     * pp_Trap.getInstance().setEnabled('Case', true);
     * ```
     *
     * @param name The name of the trigger handler
     * @param enabled Whehter the trigger handler is enabled
     * @return pp_Trap
     */
    public pp_Trap setEnabled(String name, Boolean enabled) {
        TriggerConfig config = this.getTriggerConfig(name);
        config.enabled = enabled;

        return this;
    }

    /**
     * Set the max re-entry of the trigger handler
     *
     * Example:
     * ```
     * pp_Trap.getInstance().setMaxReEntry('Case', 3);
     * ```
     *
     * @param name The name of the trigger handler
     * @param count The max count of re-entry for this trigger handler event
     * @return pp_Trap
     */
    public pp_Trap setMaxReEntry(String name, Integer count) {
        TriggerConfig config = this.getTriggerConfig(name);
        config.maxReEntry = count;

        return this;
    }

    /**
     * Get the max re-entry of the trigger handler
     *
     * Example:
     * ```
     * Integer max = pp_Trap.getInstance().getMaxReEntry('Case');
     * ```
     *
     * @param name The name of the trigger handler
     * @return Integer
     */
    public Integer getMaxReEntry(String name) {
        TriggerConfig config = this.getTriggerConfig(name);
        return config.maxReEntry;
    }

    /**
     * Set whether to use a new transaction in the trigger handler
     *
     * Example:
     * ```
     * pp_Trap.getInstance().setUsingNewTransaction('Case', true);
     * ```
     *
     * @param name The name of the trigger handler
     * @param use Whether to use a new transaction in the trigger handler
     * @return pp_Trap
     */
    public pp_Trap setUsingNewTransaction(String name, Boolean use) {
        TriggerConfig config = this.getTriggerConfig(name);
        config.usingNewTransaction = use;

        return this;
    }

    /**
     * Check whether to use a new transaction in the trigger handler
     *
     * Example:
     * ```
     * Boolean usingNewTransaction = pp_Trap.getInstance().isUsingNewTransaction('Case');
     * ```
     *
     * @param name The name of the trigger handler
     * @return Boolean
     */
    public Boolean isUsingNewTransaction(String name) {
        TriggerConfig config = this.getTriggerConfig(name);
        return config.usingNewTransaction;
    }

    /**
     * Disable all trigger handlers
     *
     * Example:
     * ```
     * pp_Trap.getInstance().disableAll();
     * ```
     *
     * @return pp_Trap
     */
    public pp_Trap disableAll() {
        this.disabled = true;

        return this;
    }

    /**
     * Enable all trigger handlers
     * Notice that this will enable all trigger handlers, but each one is still further controlled by its own enablement and active status
     *
     * Example:
     * ```
     * pp_Trap.getInstance().enableAll();
     * ```
     *
     * @return pp_Trap
     */
    public pp_Trap enableAll() {
        this.disabled = false;

        return this;
    }

    /**
     * Start the pp_Trap controller
     * Note that this will use the default Salesforce trigger context to initiate the pp_Trap
     *
     * Example:
     * ```
     * pp_Trap.getInstance().start();
     * ```
     *
     */
    public void start() {
        this.start(null, Trigger.old, Trigger.new);
    }

    /**
     * Start the pp_Trap controller with the trigger event, old list and new list
     * Note that this is primarily used in unit tests, as the same trigger logic will be run in a separate context, completely independent from
     * Salesforce trigger context
     *
     * Example:
     * ```
     * pp_Trap.getInstance().start(pp_Trap.Event.BeforeInsert, null, new List<SObject>{ new Case() });
     * ```
     *
     * @param triggerEvent The trigger event to start the pp_Trap instance
     * @param oldList The old values of the SObjects
     * @param newList The new values of the SObjects
     */
    public void start(pp_Trap.Event triggerEvent, List<SObject> oldList, List<SObject> newList) {
        String name = pp_Trap.getCurrentSObjectTypeName(oldList, newList);
        TriggerHandler handler = this.find(name);
        if (handler != null) {
            handler.run(triggerEvent, oldList, newList);
        }
    }

    /**
     * Find the trigger handler by name
     * By default, this method will try to create the trigger handler if it is not found
     * Name conventions are used
     *
     * Example:
     * ```
     * // We have a trigger handler named 'CaseTrigger'
     * pp_Trap.getInstance().find('Case');
     * ```
     *
     * @param name The name of the trigger handler
     * @return TriggerHandler
     */
    public TriggerHandler find(String name) {
        name = normalizeName(name);

        if (!this.handlers.containsKey(name)) {
            Type triggerType = Type.forName(name);
            TriggerHandler handler = useMock ? new pp_Trap_TestMock() : (TriggerHandler) triggerType.newInstance();
            handler.setController(this);
            handler.setName(name);
            this.handlers.put(name, handler);
        }

        return this.handlers.get(name);
    }

    // Set Mock trigger instance for unit testing
    @TestVisible
    private static void setMockHandler() {
        useMock = true;
    }

    // Create the trigger context
    private static Context createTriggerContext(Event triggerEvent, List<SObject> oldList, List<SObject> newList, TriggerHandler handler) {
        if (Trigger.isExecuting) {
            if (triggerEvent == null) {
                if (Trigger.isBefore && Trigger.isInsert) {
                    triggerEvent = Event.BeforeInsert;
                } else if (Trigger.isBefore && Trigger.isUpdate) {
                    triggerEvent = Event.BeforeUpdate;
                } else if (Trigger.isBefore && Trigger.isDelete) {
                    triggerEvent = Event.BeforeDelete;
                } else if (Trigger.isAfter && Trigger.isInsert) {
                    triggerEvent = Event.AfterInsert;
                } else if (Trigger.isAfter && Trigger.isUpdate) {
                    triggerEvent = Event.AfterUpdate;
                } else if (Trigger.isAfter && Trigger.isDelete) {
                    triggerEvent = Event.AfterDelete;
                } else if (Trigger.isAfter && Trigger.isUndelete) {
                    triggerEvent = Event.AfterUndelete;
                }
            }

            if (oldList == null) {
                oldList = Trigger.old;
            }

            if (newList == null) {
                newList = Trigger.new;
            }
        }

        Context triggerContext = new Context();

        triggerContext.isExecuting = true;
        triggerContext.triggerEvent = triggerEvent;
        triggerContext.oldList = oldList;
        triggerContext.newList = newList;

        if (oldList != null && !oldList.isEmpty()) {
            Map<Id, SObject> oldMap = new Map<Id, SObject>();
            for (SObject sObj : oldList) {
                oldMap.put((Id) sObj.get('Id'), sObj);
            }

            triggerContext.oldMap = oldMap;
        } else {
            triggerContext.oldMap = null;
        }

        if (newList != null && !newList.isEmpty()) {
            Map<Id, SObject> newMap = new Map<Id, SObject>();
            for (SObject sObj : newList) {
                newMap.put((Id) sObj.get('Id'), sObj);
            }

            triggerContext.newMap = newMap;
        } else {
            triggerContext.newMap = null;
        }

        triggerContext.triggerObject = pp_Trap.getCurrentSObjectTypeName(triggerContext.oldList, triggerContext.newList);
        triggerContext.handler = handler;

        return triggerContext;
    }

    // Get current sobject by deduction
    private static String getCurrentSObjectTypeName(List<SObject> oldList, List<SObject> newList) {
        List<SObject> dataList = newList;
        if (dataList == null || dataList.isEmpty()) {
            dataList = oldList;
        }

        if (dataList != null) {
            if (dataList.getSObjectType() != null) {
                return dataList.getSObjectType().getDescribe().getName();
            } else if (!dataList.isEmpty()) {
                SObject sObj = dataList.get(0);
                return sObj.getSObjectType().getDescribe().getName();
            }
        }

        throw new TrapException('Cannot detect current trigger name');
    }

    // Get the trigger config
    private TriggerConfig getTriggerConfig(String name) {
        name = normalizeName(name);

        TriggerConfig config = this.configs.get(name);
        if (config == null) {
            config = new TriggerConfig();
            this.configs.put(name, config);
        }

        return config;
    }

    // Normalize the trigger handler name
    private String normalizeName(String name) {
        if (String.isBlank(name)) {
            return name;
        }

        name = name.removeEndIgnoreCase('__c').toUpperCase();

        if (!name.endsWith(this.suffix)) {
            name = name + this.suffix;
        }

        return name;
    }

    /**
     * A bulk object represents a block of objects in the trigger to be processed
     * Each bulk object corresponds to one trigger event, and delegates operations to streams
     *
     * Example:
     * ```
     * pp_Trap.BulkObject bo = new pp_Trap.BulkObject();
     * bo.newStream
     *     .filter(new CustomFilterFunc())
     *     .subscribe(pp_Trap.F.updateField.apply('Subject', 'New subject'));
     *
     * for(Case c : caseList) {
     *     bo.newStream.next(c);
     * }
     * ```
     */
    public class BulkObject {
        // The stream for the new data
        public pp_Stream.Subject newStream = new pp_Stream.Subject();

        // The stream for the old data
        public pp_Stream.Subject oldStream = new pp_Stream.Subject();

        // Keep track of the global data used by the bulk object
        private Map<String, Object> data = new Map<String, Object>();

        /**
         * Get the global data by key
         *
         * Example:
         * ```
         * List<Account> accounts = (List<Account>)bulkObj.getData('AccountList');
         * ```
         *
         * @param key The key of the data
         * @return Object
         */
        public Object getData(String key) {
            return this.data.get(key);
        }

        /**
         * Set the global data by key
         *
         * Example:
         * ```
         * List<Account> accounts = [ SELECT Id FROM Account WHERE Id IN = : ids ];
         * bulkObj.setData('Accounts', accounts);
         * ```
         *
         * @param key The key of the data
         * @param value The value
         * @return BulkObject
         */
        public BulkObject setData(String key, Object value) {
            this.data.put(key, value);

            return this;
        }

        /**
         * Check if the bulk object contains the data by key
         *
         * Example:
         * ```
         * Boolean contains = bulkObj.containsData('Accounts');
         * ```
         *
         * @param key The key of the data
         * @return Boolean
         */
        public Boolean containsData(String key) {
            return this.data.containsKey(key);
        }

        /**
         * Return a pp_Func that gets the data by the key
         *
         * Example:
         * ```
         * pp_Func f = bulkObj.data('Accounts');
         * List<Account> accounts = (List<Account>)f.run();
         * ```
         *
         * @param key The key of the data
         * @return pp_Func
         */
        public pp_Func data(String key) {
            return pp_Trap.F.data.apply(this, key);
        }

        /**
         * Return a pp_Func that wraps the original pp_Func with data from the bulk object
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .filter(bulkObj.provide('accounts', new CustomFilterFunc()));
         * // Provide 'accounts' data to the CustomFilterFunc
         * ```
         *
         * @param key The key of the data
         * @param f The wrapped function
         * @return pp_Func
         */
        public pp_Func provide(String key, pp_Func f) {
            return this.provide(new List<String>{
                    key
            }, f);
        }

        /**
         * Return a pp_Func that wraps the original pp_Func with data from the bulk object
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .filter(bulkObj.provide('accounts', 'ids', new CustomFilterFunc()));
         * // Provide 'accounts' data to the CustomFilterFunc
         * ```
         *
         * @param key1 The key of the first data
         * @param key2 The key of the second data
         * @param f The wrapped function
         * @return pp_Func
         */
        public pp_Func provide(String key1, String key2, pp_Func f) {
            return this.provide(new List<String>{
                    key1, key2
            }, f);
        }

        /**
         * Return a pp_Func that wraps the original pp_Func with data from the bulk object
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .filter(bulkObj.provide('accounts', 'ids', 'urls', new CustomFilterFunc()));
         * // Provide 'accounts' data to the CustomFilterFunc
         * ```
         *
         * @param key1 The key of the first data
         * @param key2 The key of the second data
         * @param key3 The key of the third data
         * @param f The wrapped function
         * @return pp_Func
         */
        public pp_Func provide(String key1, String key2, String key3, pp_Func f) {
            return this.provide(new List<String>{
                    key1, key2, key3
            }, f);
        }

        /**
         * Return a pp_Func that wraps the original pp_Func with data from the bulk object
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .filter(bulkObj.provide(new List<String>{ 'accounts' }, new CustomFilterFunc()));
         * // Provide 'accounts' data to the CustomFilterFunc
         * ```
         *
         * @param dataKeys The keys of the data
         * @param f The wrapped function
         * @return pp_Func
         */
        public pp_Func provide(List<String> dataKeys, pp_Func f) {
            return (pp_Func) pp_Trap.F.provide.run(this, dataKeys, f);
        }

        /**
         * Return a pp_Func that sets the computed value from the func and data into the data of key
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .tap(bulkObj.data('accounts', new CustomGetAccountsFunc(), new List<String>{ 'ids' }));
         * ```
         *
         * @param key The key of the data
         * @param f The pp_Func to compute the value
         * @param dataNames The names of the input data from the bulk object
         * @return pp_Func
         */
        public pp_Func data(String key, pp_Func f, List<String> dataNames) {
            return pp_Trap.F.data.applyN(new List<Object>{
                    this, key, f, dataNames
            });
        }

        /**
         * Return a pp_Func that sets the computed value from the func and data into the data of key
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .tap(bulkObj.data('accounts', new CustomGetAccountsFunc());
         * ```
         *
         * @param key The key of the data
         * @param f The pp_Func to compute the value
         * @return pp_Func
         */
        public pp_Func data(String key, pp_Func f) {
            return this.data(key, f, new List<String>());
        }

        /**
         * Return a pp_Func that sets the computed value from the func and data into the data of key
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .tap(bulkObj.data('accounts', new CustomGetAccountsFunc(), 'ids'));
         * ```
         *
         * @param key The key of the data
         * @param f The pp_Func to compute the value
         * @param dataName1 The name of the first input data
         * @return pp_Func
         */
        public pp_Func data(String key, pp_Func f, String dataName1) {
            return this.data(key, f, new List<String>{
                    dataName1
            });
        }

        /**
         * Return a pp_Func that sets the computed value from the func and data into the data of key
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .tap(bulkObj.data('accounts', new CustomGetAccountsFunc(), 'ids', 'urls'));
         * ```
         *
         * @param key The key of the data
         * @param f The pp_Func to compute the value
         * @param dataName1 The name of the first input data
         * @param dataName2 The name of the second input data
         * @return pp_Func
         */
        public pp_Func data(String key, pp_Func f, String dataName1, String dataName2) {
            return this.data(key, f, new List<String>{
                    dataName1, dataName2
            });
        }

        /**
         * Return a pp_Func that sets the computed value from the func and data into the data of key
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .tap(bulkObj.data('accounts', new CustomGetAccountsFunc(), 'ids', 'urls', 'src'));
         * ```
         *
         * @param key The key of the data
         * @param f The pp_Func to compute the value
         * @param dataName1 The name of the first input data
         * @param dataName2 The name of the second input data
         * @param dataName3 The name of the third input data
         * @return pp_Func
         */
        public pp_Func data(String key, pp_Func f, String dataName1, String dataName2, String dataName3) {
            return this.data(key, f, new List<String>{
                    dataName1, dataName2, dataName3
            });
        }

        /**
         * Return a pp_Func that sets the value to the data of key
         *
         * Example:
         * ```
         * bulkObj.newStream
         *     .tap(bulkObj.data('data', 'test'));
         * ```
         *
         * @param key The key of the data
         * @param value The value of the data
         * @return pp_Func
         */
        public pp_Func data(String key, Object value) {
            return this.data(key, pp_R.constant.apply(value));
        }
    }

    /**
     * All possible trigger events
     * 'All' means matching all the trigger events, and is only used in the bulk object that
     * tries to match all the events
     */
    public enum Event {
        BeforeInsert,
        BeforeUpdate,
        BeforeDelete,
        AfterInsert,
        AfterUpdate,
        AfterDelete,
        AfterUndelete,
        All
    }

    /**
     * The trigger context
     *
     * This context is a copy of Salesforce trigger context and offers read-only attributes
     */
    public class Context {
        public Boolean isExecuting { get; private set; }
        public String triggerObject { get; private set; }
        public Event triggerEvent { get; private set; }
        public TriggerHandler handler { get; private set; }
        public List<SObject> oldList { get; private set; }
        public List<SObject> newList { get; private set; }
        public Map<Id, SObject> oldMap { get; private set; }
        public Map<Id, SObject> newMap { get; private set; }

        // Activate the context
        void activate() {
            pp_Trap.currentTriggerContext = this;
            pp_Trap controller = this.handler.getController();
            if (controller == null) {
                return;
            }
            String name = this.handler.getName();

            controller.triggerContexts.add(this);

            Integer maxDepth = controller.getMaxReEntry(name);
            Boolean usingNewTransaction = controller.isUsingNewTransaction(name);

            String recursionKey = this.triggerObject + '_' + this.triggerEvent;
            Integer depth = controller.recursionDepth.get(recursionKey);
            if (depth == null) {
                depth = 0;
            }

            if (maxDepth >= 0 && depth >= maxDepth) {
                throw new TrapException('Max re-entry limit of ' + maxDepth + ' is reached');
            } else {
                depth += 1;
                controller.recursionDepth.put(recursionKey, depth);
            }

            if (usingNewTransaction) {
                String spKey = recursionKey + '_' + depth;
                if (!controller.savePoints.containsKey(spKey)) {
                    Savepoint sp = Database.setSavepoint();
                    controller.savePoints.put(spKey, sp);
                } else {
                    throw new TrapException('Transaction already existed for ' + spKey);
                }
            }
        }

        // Handles error in the context
        void onError(Exception e) {
            pp_Trap controller = this.handler.getController();
            if (controller == null) {
                return;
            }
            String name = this.handler.getName();

            Integer maxDepth = controller.getMaxReEntry(name);
            Boolean usingNewTransaction = controller.isUsingNewTransaction(name);

            String recursionKey = this.triggerObject + '_' + this.triggerEvent;
            Integer depth = controller.recursionDepth.get(recursionKey);

            if (usingNewTransaction) {
                String spKey = recursionKey + '_' + depth;
                Savepoint sp = controller.savePoints.get(spKey);
                if (sp != null) {
                    Database.rollback(sp);
                } else {
                    throw new TrapException('Expected transaction is not created');
                }
            } else {
                throw e;
            }
        }

        // Deactivate the context
        void deactivate() {
            pp_Trap controller = this.handler.getController();
            if (controller == null) {
                pp_Trap.currentTriggerContext = null;
                return;
            }
            String name = this.handler.getName();

            Integer maxDepth = controller.getMaxReEntry(name);
            Boolean usingNewTransaction = controller.isUsingNewTransaction(name);

            String recursionKey = this.triggerObject + '_' + this.triggerEvent;
            Integer depth = controller.recursionDepth.get(recursionKey);

            if (usingNewTransaction) {
                String spKey = recursionKey + '_' + depth;
                controller.savePoints.remove(spKey);
            }

            depth -= 1;
            controller.recursionDepth.put(recursionKey, depth);

            controller.triggerContexts.remove(controller.triggerContexts.size() - 1);

            if (!controller.triggerContexts.isEmpty()) {
                pp_Trap.currentTriggerContext = controller.triggerContexts.get(controller.triggerContexts.size() - 1);
            } else {
                pp_Trap.currentTriggerContext = null;
            }
        }
    }

    /**
     * Extend this class to provide your own trigger handler implementation
     *
     * Usage 1:
     * ```
     * // Functional reactive stream style
     * public with sharing class CaseTrigger extends pp_Trap.TriggerHandler {
     *     public override void setUpBeforeInsert(pp_Trap.BulkObject bulkObj) {
     *         bulkObj.newStream
     *             .tap(pp_R.debug.apply('before insert'))
     *             .subscribe(pp_Trap.F.addError.apply('test error'));
     *     }
     * }
     * ```
     *
     * Usage 2:
     * ```
     * // Normal event handler style
     * public with sharing class CaseTrigger extends pp_Trap.TriggerHandler {
     *     public override void bulkBefore() {
     *         // Custom code
     *     }
     *
     *     public override void beforeInsert(SObject newSO) {
     *         pp_Trap.Context triggerContext = this.getTriggerContext();
     *         // Custom code
     *     }
     * }
     * ```
     *
     * Usage 3:
     * ```
     * // Integration style
     * public with sharing class CaseTrigger extends Other.TriggerHandler {
     *     private pp_Trap.TriggerHandler handler = new pp_Trap.TriggerHandler();
     *
     *     public CaseTrigger() {
     *         handler.onBeforeInsert().newStream
     *             .tap(pp_R.debug.apply('before insert'))
     *             .subscribe(pp_Trap.F.addError.apply('test error'));
     *     }
     *
     *     public override void beforeInsert(SObject newSO) {
     *         handler.run();
     *     }
     * }
     * ```
     */
    public virtual class TriggerHandler {
        // The pp_Trap controller
        private pp_Trap controller;

        // The name registered in the controller
        private String name;

        // The trigger context
        private Context triggerContext;

        // Bulk objects mapped by the trigger events
        private Map<Event, BulkObject> bulkObjects;

        /**
         * Create a default instance of the trigger handler
         * Usually used when you want to integrate the stream functions in other
         * trigger frameworks
         */
        public TriggerHandler() {
            bulkObjects = new Map<Event, BulkObject>();

            BulkObject bulkBeforeInsert = new BulkObject();
            this.setUpBeforeInsert(bulkBeforeInsert);
            this.bulkObjects.put(Event.BeforeInsert, bulkBeforeInsert);

            BulkObject bulkBeforeUpdate = new BulkObject();
            this.setUpBeforeUpdate(bulkBeforeUpdate);
            this.bulkObjects.put(Event.BeforeUpdate, bulkBeforeUpdate);

            BulkObject bulkBeforeDelete = new BulkObject();
            this.setUpBeforeDelete(bulkBeforeDelete);
            this.bulkObjects.put(Event.BeforeDelete, bulkBeforeDelete);

            BulkObject bulkAfterInsert = new BulkObject();
            this.setUpAfterInsert(bulkAfterInsert);
            this.bulkObjects.put(Event.AfterInsert, bulkAfterInsert);

            BulkObject bulkAfterUpdate = new BulkObject();
            this.setUpAfterUpdate(bulkAfterUpdate);
            this.bulkObjects.put(Event.AfterUpdate, bulkAfterUpdate);

            BulkObject bulkAfterDelete = new BulkObject();
            this.setUpAfterDelete(bulkAfterDelete);
            this.bulkObjects.put(Event.AfterDelete, bulkAfterDelete);

            BulkObject bulkAfterUndelete = new BulkObject();
            this.setUpAfterUndelete(bulkAfterUndelete);
            this.bulkObjects.put(Event.AfterUndelete, bulkAfterUndelete);

            BulkObject bulkAll = new BulkObject();
            this.setUp(bulkAll);
            this.bulkObjects.put(Event.All, bulkAll);
        }

        // Set the pp_Trap controller
        void setController(pp_Trap controller) {
            this.controller = controller;
        }

        // Get the pp_Trap controller
        pp_Trap getController() {
            return this.controller;
        }

        // Set the registered name of this trigger handler
        void setName(String name) {
            this.name = name;
        }

        // Get the registered name of this trigger handler
        String getName() {
            return this.name;
        }

        /**
         * Get the trigger context
         *
         * Example:
         * ```
         * pp_Trap.Context context = handler.getTriggerContext();
         * ```
         *
         * @return Context
         */
        public Context getTriggerContext() {
            return this.triggerContext;
        }

        /**
         * Get the bulk object to process trigger events 'before insert'
         *
         * Example:
         * ```
         * handler.onBeforeInsert().newStream
         *     .subscribe(...)
         * ```
         *
         * @return BulkObject
         */
        public BulkObject onBeforeInsert() {
            return this.bulkObjects.get(Event.BeforeInsert);
        }

        /**
         * Get the bulk object to process trigger events 'before update'
         *
         * Example:
         * ```
         * handler.onBeforeUpdate().newStream
         *     .subscribe(...)
         * ```
         *
         * @return BulkObject
         */
        public BulkObject onBeforeUpdate() {
            return this.bulkObjects.get(Event.BeforeUpdate);
        }

        /**
         * Get the bulk object to process trigger events 'before delete'
         *
         * Example:
         * ```
         * handler.onBeforeDelete().newStream
         *     .subscribe(...)
         * ```
         *
         * @return BulkObject
         */
        public BulkObject onBeforeDelete() {
            return this.bulkObjects.get(Event.BeforeDelete);
        }

        /**
         * Get the bulk object to process trigger events 'after insert'
         *
         * Example:
         * ```
         * handler.onAfterInsert().newStream
         *     .subscribe(...)
         * ```
         *
         * @return BulkObject
         */
        public BulkObject onAfterInsert() {
            return this.bulkObjects.get(Event.AfterInsert);
        }

        /**
         * Get the bulk object to process trigger events 'after update'
         *
         * Example:
         * ```
         * handler.onAfterUpdate().newStream
         *     .subscribe(...)
         * ```
         *
         * @return BulkObject
         */
        public BulkObject onAfterUpdate() {
            return this.bulkObjects.get(Event.AfterUpdate);
        }

        /**
         * Get the bulk object to process trigger events 'after delete'
         *
         * Example:
         * ```
         * handler.onAfterDelete().newStream
         *     .subscribe(...)
         * ```
         *
         * @return BulkObject
         */
        public BulkObject onAfterDelete() {
            return this.bulkObjects.get(Event.AfterDelete);
        }

        /**
         * Get the bulk object to process trigger events 'after undelete'
         *
         * Example:
         * ```
         * handler.onAfterUndelete().newStream
         *     .subscribe(...)
         * ```
         *
         * @return BulkObject
         */
        public BulkObject onAfterUndelete() {
            return this.bulkObjects.get(Event.AfterUndelete);
        }

        /**
         * Get the bulk object to process all trigger events
         *
         * Example:
         * ```
         * handler.onEvent().newStream
         *     .filter(pp_Trap.F.isBeforeInsert)
         *     .subscribe(...)
         * ```
         *
         * @return BulkObject
         */
        public BulkObject onEvent() {
            return this.bulkObjects.get(Event.All);
        }

        /**
         * Override this method to provide set up beforeInsert bulk object
         * @param bulkObj The bulk object
         */
        protected virtual void setUpBeforeInsert(BulkObject bulkObj) {
        }

        /**
         * Override this method to provide set up beforeUpdate bulk object
         * @param bulkObj The bulk object
         */
        protected virtual void setUpBeforeUpdate(BulkObject bulkObj) {
        }

        /**
         * Override this method to provide set up beforeDelete bulk object
         * @param bulkObj The bulk object
         */
        protected virtual void setUpBeforeDelete(BulkObject bulkObj) {
        }

        /**
         * Override this method to provide set up afterInsert bulk object
         * @param bulkObj The bulk object
         */
        protected virtual void setUpAfterInsert(BulkObject bulkObj) {
        }

        /**
         * Override this method to provide set up afterUpdate bulk object
         * @param bulkObj The bulk object
         */
        protected virtual void setUpAfterUpdate(BulkObject bulkObj) {
        }

        /**
         * Override this method to provide set up afterDelete bulk object
         * @param bulkObj The bulk object
         */
        protected virtual void setUpAfterDelete(BulkObject bulkObj) {
        }

        /**
         * Override this method to provide set up afterUndelete bulk object
         * @param bulkObj The bulk object
         */
        protected virtual void setUpAfterUndelete(BulkObject bulkObj) {
        }

        /**
         * Override this method to provide set up catch-all bulk object
         * @param bulkObj The bulk object
         */
        protected virtual void setUp(BulkObject bulkObj) {
        }

        /**
         * Override this method to run code before the 'beforeXxx'
         */
        protected virtual void bulkBefore() {
        }

        /**
         * Override this method to run code before the 'afterXxx'
         */
        protected virtual void bulkAfter() {
        }

        /**
         * Override this method to run code on beforeInsert event
         *
         * @param so The new SObject
         */
        protected virtual void beforeInsert(SObject so) {
            handleSObjects(null, so);
        }

        /**
         * Override this method to run code on beforeUpdate event
         *
         * @param oldSO The old SObject
         * @param newSO The new SObject
         */
        protected virtual void beforeUpdate(SObject oldSO, SObject newSO) {
            handleSObjects(oldSO, newSO);
        }

        /**
         * Override this method to run code on beforeDelete event
         *
         * @param so The old SObject
         */
        protected virtual void beforeDelete(SObject so) {
            handleSObjects(so, null);
        }

        /**
         * Override this method to run code on afterInsert event
         *
         * @param so The new SObject
         */
        protected virtual void afterInsert(SObject so) {
            handleSObjects(null, so);
        }

        /**
         * Override this method to run code on afterUpdate event
         *
         * @param oldSO The old SObject
         * @param newSO The new SObject
         */
        protected virtual void afterUpdate(SObject oldSO, SObject newSO) {
            handleSObjects(oldSO, newSO);
        }

        /**
         * Override this method to run code on afterDelete event
         *
         * @param so The old SObject
         */
        protected virtual void afterDelete(SObject so) {
            handleSObjects(so, null);
        }

        /**
         * Override this method to run code on afterUndelete event
         *
         * @param so The new SObject
         */
        protected virtual void afterUndelete(SObject so) {
            handleSObjects(null, so);
        }

        /**
         * Override this method to indicate whether this trigger handler is active
         *
         * @return Boolean
         */
        protected virtual Boolean isActive() {
            return true;
        }

        // Check if the trigger handler can run
        private Boolean canRun() {
            if (controller != null) {
                return controller.isEnabled(this.name) && this.isActive();
            } else {
                return true;
            }
        }

        /**
         * Run the trigger handler
         * This method is primarily used in Salesforce trigger context
         *
         * Example:
         * ```
         * pp_Trap.getInstance().find('Case').run();
         * ```
         *
         */
        public void run() {
            this.run(null, null, null);
        }

        /**
         * Run the trigger handler
         *
         * Example:
         * ```
         * pp_Trap.getInstance().find('Case').run(pp_Trap.Event.BeforeInsert, null, new List<SObject>{ new Case() });
         * ```
         *
         * @param triggerEvent The trigger event
         * @param oldList The old SObjects
         * @param newList The new SObjects
         */
        public void run(Event triggerEvent, List<SObject> oldList, List<SObject> newList) {
            Context triggerContext = pp_Trap.createTriggerContext(triggerEvent, oldList, newList, this);

            try {
                triggerContext.activate();

                this.doRun(triggerContext);
            } catch (Exception e) {
                triggerContext.onError(e);
            } finally {
                triggerContext.deactivate();
            }
        }

        // Run the trigger handler
        private void doRun(Context triggerContext) {
            if (!this.canRun()) {
                return;
            }

            this.triggerContext = triggerContext;

            Event currentEvent = triggerContext.triggerEvent;

            List<SObject> data = triggerContext.newList;
            if (data == null || data.isEmpty()) {
                data = triggerContext.oldList;
            }

            if (currentEvent == Event.BeforeInsert ||
                    currentEvent == Event.BeforeUpdate ||
                    currentEvent == Event.BeforeDelete) {
                this.bulkBefore();
            } else if (currentEvent == Event.AfterInsert ||
                    currentEvent == Event.AfterUpdate ||
                    currentEvent == Event.AfterDelete ||
                    currentEvent == Event.AfterUndelete) {
                this.bulkAfter();
            }

            for (SObject so : data) {
                SObject oldSO = (SObject) pp_Trap.F.getOld.run(so);
                SObject newSO = (SObject) pp_Trap.F.getNew.run(so);

                if (currentEvent == Event.BeforeInsert) {
                    this.beforeInsert(newSO);
                } else if (currentEvent == Event.BeforeUpdate) {
                    this.beforeUpdate(oldSO, newSO);
                } else if (currentEvent == Event.BeforeDelete) {
                    this.beforeDelete(oldSO);
                } else if (currentEvent == Event.AfterInsert) {
                    this.afterInsert(newSO);
                } else if (currentEvent == Event.AfterUpdate) {
                    this.afterUpdate(oldSO, newSO);
                } else if (currentEvent == Event.AfterDelete) {
                    this.afterDelete(oldSO);
                } else if (currentEvent == Event.AfterUndelete) {
                    this.afterUndelete(newSO);
                }
            }

            complete();
        }

        // Handle the SObjects
        private void handleSObjects(SObject oldSO, SObject newSO) {
            Event currentEvent = this.triggerContext.triggerEvent;
            BulkObject bulkObj = this.bulkObjects.get(currentEvent);
            BulkObject bulkObjAll = this.bulkObjects.get(Event.All);

            if (newSO != null) {
                bulkObj.newStream.next(newSO);
                bulkObjAll.newStream.next(newSO);
            }

            if (oldSO != null) {
                bulkObj.oldStream.next(oldSO);
                bulkObjAll.oldStream.next(oldSO);
            }
        }

        // Complete
        private void complete() {
            Event currentEvent = this.triggerContext.triggerEvent;
            BulkObject bulkObj = this.bulkObjects.get(currentEvent);
            BulkObject bulkObjAll = this.bulkObjects.get(Event.All);

            bulkObj.newStream.complete();
            bulkObjAll.newStream.complete();

            bulkObj.oldStream.complete();
            bulkObjAll.oldStream.complete();
        }
    }

    // The trigger config object
    private class TriggerConfig {
        public Boolean enabled = true;
        public Integer maxReEntry = -1;
        public Boolean usingNewTransaction = false;
    }

    public class TrapException extends Exception {
    }

    // Exported functions
    public class Funcs {
        /**
         * Update the field of the SObject
         *
         * Example:
         * ```
         * SObject newVal = (SObject)pp_Trap.F.updateField.run('Subject', 'New subject', new Case());
         * ```
         *
         * @param arg1 The name of the field
         * @param arg2 The update field name or pp_Func
         * @param arg3 The SObject
         * @return Object(SObject)
         */
        public pp_Func updateField = new UpdateFieldFunc();

        /**
         * Add an error to the SObject
         *
         * Example:
         * ```
         * SObject newVal = (SObject)pp_Trap.F.addError.run('test error', new Case());
         * ```
         *
         * @param arg1 The error, either String or Exception
         * @param arg2 The SObject
         * @return Object(SObject)
         */
        public pp_Func addError = new AddErrorFunc();

        /**
         * Validate the SObject
         *
         * Example:
         * ```
         * SObject newVal = (SObject)pp_Trap.F.validate.run(pp_R.propSatisfies.apply('Subject', pp_R.isNotNull), 'Should not be null', new Case());
         * ```
         *
         * @param arg1 The pred pp_Func to check if the SObject is valid
         * @param arg2 The field name
         * @param arg3 The SObject
         * @return Object(SObject)
         */
        public pp_Func validate = new ValidateFunc();

        /**
         * Get the new SObject
         * Note: only available in a trigger context
         *
         * Example:
         * ```
         * SObject newVal = (SObject)pp_Trap.F.getNew.run(val);
         * ```
         *
         * @param arg The SObject
         * @return Object(SObject)
         */
        public pp_Func getNew = new GetNewFunc();

        /**
         * Get the old SObject
         * Note: only available in a trigger context
         *
         * Example:
         * ```
         * SObject oldVal = (SObject)pp_Trap.F.getOld.run(val);
         * ```
         *
         * @param arg The SObject
         * @return Object(SObject)
         */
        public pp_Func getOld = new GetOldFunc();

        /**
         * Check if the sobject has changed according to the condition
         * Note: only available in a trigger context
         *
         * Example:
         * ```
         * Boolean changed = (Boolean)pp_Trap.F.changed.run('Subject', val);
         * ```
         *
         * @param arg1 The field name or the pp_Func to get a value
         * @param arg2 The SObject
         * @return Object(SObject)
         */
        public pp_Func changed = new ChangedFunc();

        /**
         * Get/set the data of the bulk object
         * Please see BulkObject#data method
         */
        public pp_Func data = new DataFunc();

        /**
         * Provide data from the bulk object as the arguments to the wrapped function
         * Please see BulkObject#provide method
         */
        public pp_Func provide = new ProvideFunc();

        /**
         * Check if the current trigger event is the given event
         *
         * Example:
         * ```
         * Boolean result = (Boolean)pp_Trap.F.isEvent.run(pp_Trap.Event.BeforeInsert);
         * ```
         *
         * @param arg The trigger event
         * @return Object(Boolean)
         */
        public pp_Func isEvent = new IsEventFunc();

        /**
         * Check if the current trigger event is beforeInsert
         *
         * Example:
         * ```
         * Boolean result = (Boolean)pp_Trap.F.isBeforeInsert.run();
         * ```
         *
         * @return Object(Boolean)
         */
        public pp_Func isBeforeInsert = isEvent.apply(Event.BeforeInsert);

        /**
         * Check if the current trigger event is beforeUpdate
         *
         * Example:
         * ```
         * Boolean result = (Boolean)pp_Trap.F.isBeforeInsert.run();
         * ```
         *
         * @return Object(Boolean)
         */
        public pp_Func isBeforeUpdate = isEvent.apply(Event.BeforeUpdate);

        /**
         * Check if the current trigger event is beforeDelete
         *
         * Example:
         * ```
         * Boolean result = (Boolean)pp_Trap.F.isBeforeInsert.run();
         * ```
         *
         * @return Object(Boolean)
         */
        public pp_Func isBeforeDelete = isEvent.apply(Event.BeforeDelete);

        /**
         * Check if the current trigger event is afterInsert
         *
         * Example:
         * ```
         * Boolean result = (Boolean)pp_Trap.F.isBeforeInsert.run();
         * ```
         *
         * @return Object(Boolean)
         */
        public pp_Func isAfterInsert = isEvent.apply(Event.AfterInsert);

        /**
         * Check if the current trigger event is afterUpdate
         *
         * Example:
         * ```
         * Boolean result = (Boolean)pp_Trap.F.isBeforeInsert.run();
         * ```
         *
         * @return Object(Boolean)
         */
        public pp_Func isAfterUpdate = isEvent.apply(Event.AfterUpdate);

        /**
         * Check if the current trigger event is afterDelete
         *
         * Example:
         * ```
         * Boolean result = (Boolean)pp_Trap.F.isBeforeInsert.run();
         * ```
         *
         * @return Object(Boolean)
         */
        public pp_Func isAfterDelete = isEvent.apply(Event.AfterDelete);

        /**
         * Check if the current trigger event is afterUndelete
         *
         * Example:
         * ```
         * Boolean result = (Boolean)pp_Trap.F.isBeforeInsert.run();
         * ```
         *
         * @return Object(Boolean)
         */
        public pp_Func isAfterUndelete = isEvent.apply(Event.AfterUndelete);
    }

    private class ProvideFunc extends pp_Func {
        public ProvideFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            BulkObject bulkObj = (BulkObject) arg1;
            List<String> dataKeys = (List<String>) pp_R.toStringList.run(arg2);
            pp_Func f = (pp_Func) pp_R.toFunc.run(arg3);

            return new FuncProvide(bulkObj, dataKeys, f);
        }
    }

    private class FuncProvide extends pp_Func {
        private BulkObject bulkObj;
        private List<String> dataKeys;
        private pp_Func target;

        public FuncProvide(BulkObject bulkObj, List<String> dataKeys, pp_Func target) {
            super(-1);

            this.bulkObj = bulkObj;
            this.dataKeys = dataKeys;
            this.target = target;
        }

        public override Object execN(List<Object> args) {
            List<Object> fArgs = new List<Object>();
            for (String key : this.dataKeys) {
                fArgs.add(this.bulkObj.getData(key));
            }

            fArgs.addAll(args);

            return this.target.runN(fArgs);
        }
    }

    private class IsEventFunc extends pp_Func {
        public IsEventFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            Event triggerEvent = (Event) arg;

            return pp_Trap.currentTriggerContext.triggerEvent == triggerEvent;
        }
    }

    private class DataFunc extends pp_Func {
        public DataFunc() {
            super(-1);
        }

        public override Object execN(List<Object> args) {
            BulkObject bulkObj = (BulkObject) args.get(0);
            String name = (String) pp_R.toString.run(args.get(1));

            if (pp_Trap.currentTriggerContext != null && !pp_Trap.currentTriggerContext.isExecuting) {
                return null;
            }

            if (args.size() > 2) {
                if (bulkObj.containsData(name)) {
                    return bulkObj.getData(name);
                }

                pp_Func f = (pp_Func) args.get(2);

                if (f == null) {
                    return bulkObj.getData(name);
                }

                List<Object> fArgs = new List<Object>();
                if (args.size() > 3) {
                    List<String> names = (List<String>) args.get(3);
                    for (String n : names) {
                        fArgs.add(bulkObj.getData(n));
                    }
                }

                if (pp_Trap.currentTriggerContext != null) {
                    Map<Id, SObject> input = pp_Trap.currentTriggerContext.newMap;
                    if (input == null || input.isEmpty()) {
                        input = pp_Trap.currentTriggerContext.oldMap;
                    }
                    fArgs.add(input);
                }

                Object value = f.runN(fArgs);
                bulkObj.setData(name, value);

                return value;
            } else {
                return bulkObj.getData(name);
            }
        }
    }

    private class ChangedFunc extends pp_Func {
        public ChangedFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            Object target = arg2;
            pp_Func f = null;

            if (arg1 instanceof String) {
                f = pp_R.prop.apply(arg1);
            } else if (arg1 instanceof pp_Func) {
                f = (pp_Func) arg1;
            }

            if (f != null) {
                Object oldValue = pp_Trap.F.getOld.run(target);
                Object newValue = pp_Trap.F.getNew.run(target);

                return f.run(oldValue) != f.run(newValue);
            }

            return false;
        }
    }

    private class GetNewFunc extends pp_Func {
        public GetNewFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            SObject target = (SObject) arg;

            if (pp_Trap.currentTriggerContext.isExecuting && pp_Trap.currentTriggerContext.newList != null) {
                Id id = (Id) target.get('Id');
                return id == null ? target : pp_Trap.currentTriggerContext.newMap.get(id);
            }

            return null;
        }
    }

    private class GetOldFunc extends pp_Func {
        public GetOldFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            SObject target = (SObject) arg;

            if (pp_Trap.currentTriggerContext.isExecuting && pp_Trap.currentTriggerContext.oldList != null) {
                Id id = (Id) target.get('Id');
                return id == null ? null : pp_Trap.currentTriggerContext.oldMap.get(id);
            }

            return null;
        }
    }

    private class ValidateFunc extends pp_Func {
        public ValidateFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            pp_Func pred = (pp_Func) arg1;
            Object error = arg2;
            Object target = arg3;

            Boolean pass = (Boolean) pred.run(target);
            if (!pass) {
                target = pp_Trap.F.addError.run(error, target);
            }

            return target;
        }
    }

    private class AddErrorFunc extends pp_Func {
        public AddErrorFunc() {
            super(2);
        }

        public override Object exec(Object arg1, Object arg2) {
            SObject target = (SObject) arg2;

            if (arg1 instanceof String) {
                target.addError((String) arg1);
            } else if (arg1 instanceof Exception) {
                target.addError((Exception) arg1);
            }

            return target;
        }
    }

    private class UpdateFieldFunc extends pp_Func {
        public UpdateFieldFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            String field = (String) pp_R.toString.run(arg1);
            SObject target = (SObject) pp_R.toSObject.run(arg3);

            if (arg2 instanceof pp_Func) {
                pp_Func updateFn = (pp_Func) arg2;

                Object oldValue = target.get(field);
                Object newValue = updateFn.run(oldValue);

                target.put(field, newValue);
            } else {
                Object value = arg2;

                target.put(field, value);
            }

            return target;
        }
    }
}