/**
 * Created by kirillreutski on 24.03.24.
 */

public without sharing class PersonToUnitMapService implements Schedulable{

    public static Integer targetYear {
        get {
            if (targetYear == null) targetYear = System.today().year();
            return targetYear;
        }

        set;
    }

    private static List<Person_to_Unit_Mapping_History__c> storage {
        get {
            if (storage == null) {
                storage = [SELECT Id, Person__c, Unit__c, Effective_Date__c FROM Person_to_Unit_Mapping_History__c WHERE CALENDAR_YEAR(Effective_Date__c) =: targetYear];
            }

            return storage;
        }
        private set;
    }

    public static Integer getPersonsInUnit(Id unitId, Integer year, Integer month) {
        Integer result = personsByUnitPerYearPerMonthMap.get(unitId)?.get(year)?.get(month);
        return result == null ? 0 : result;
    }

    public static Map<Id, Integer> getPersonsByUnit(Integer year, Integer month) {
        Map<Id, Integer> result = new Map<Id, Integer>();
        for (Id unitId : personsByUnitPerYearPerMonthMap.keySet()) {
            result.put(unitId, personsByUnitPerYearPerMonthMap.get(unitId)?.get(year)?.get(month));
        }

        return result;
    }

    public static Integer personsAmount(Integer year, Integer month) {
        Map<Id, Integer> byUnit = getPersonsByUnit(year, month);
        Integer result = 0;
        if (byUnit == null) return result;

        for (Id unitId : byUnit.keySet()) result += byUnit.get(unitId) == null ? 0 : byUnit.get(unitId);

        return result;
    }

    private static Map<Id, Map<Integer, Map<Integer, Integer>>> personsByUnitPerYearPerMonthMap {
        get {
            if (personsByUnitPerYearPerMonthMap == null) {
                personsByUnitPerYearPerMonthMap = new Map<Id, Map<Integer, Map<Integer, Integer>>>();

                for (Person_to_Unit_Mapping_History__c l : storage) {
                    Integer year = l.Effective_Date__c.year();
                    Integer month = l.Effective_Date__c.month();
                    if (!personsByUnitPerYearPerMonthMap.containsKey(l.Unit__c)) personsByUnitPerYearPerMonthMap.put(l.Unit__c, new Map<Integer, Map<Integer, Integer>>());
                    if (!personsByUnitPerYearPerMonthMap.get(l.Unit__c).containsKey(year)) personsByUnitPerYearPerMonthMap.get(l.Unit__c).put(year, new Map<Integer, Integer>());
                    if (!personsByUnitPerYearPerMonthMap.get(l.Unit__c).get(year).containsKey(month)) personsByUnitPerYearPerMonthMap.get(l.Unit__c).get(year).put(month, 0);

                    personsByUnitPerYearPerMonthMap.get(l.Unit__c).get(year).put(month,
                        personsByUnitPerYearPerMonthMap.get(l.Unit__c).get(year).get(month) + 1
                    );
                }
            }

            return personsByUnitPerYearPerMonthMap;
        }
        private set;
    }

    private static Map<Id, Map<Integer, Map<Integer, Id>>> personToUnitMap {
        get {
            if (personToUnitMap == null) {
                personToUnitMap = new Map<Id, Map<Integer, Map<Integer, Id>>>();
                for (Person_to_Unit_Mapping_History__c l : storage) {
                    Integer year = l.Effective_Date__c.year();
                    Integer month = l.Effective_Date__c.month();
                    if (!personToUnitMap.containsKey(l.Person__c)) personToUnitMap.put(l.Person__c, new Map<Integer, Map<Integer, Id>>());
                    if (!personToUnitMap.get(l.Person__c).containsKey(year)) personToUnitMap.get(l.Person__c).put(year, new Map<Integer, Id>());
                    personToUnitMap.get(l.Person__c).get(year).put(month, l.Unit__c);
                }
            }
            return personToUnitMap;
        }
        private set;
    }

    public static Id getAccountId(Id personId, Integer year, Integer month) {
        return personToUnitMap.get(personId)?.get(year)?.get(month);
    }

    public static void createSnapshot(Integer year, Integer month) {
        Integer thisYear = System.today().year();
        if (year == null) year = thisYear;

        List<Person_to_Unit_Mapping_History__c> existingRecordsForPeriod = null;
        if (month == null) existingRecordsForPeriod = [SELECT Id,  Effective_Date__c, Person__c, Unit__c FROM Person_to_Unit_Mapping_History__c WHERE CALENDAR_YEAR(Effective_Date__c) =: year];
        else existingRecordsForPeriod = [SELECT Id, Effective_Date__c, Person__c, Unit__c FROM Person_to_Unit_Mapping_History__c WHERE CALENDAR_YEAR(Effective_Date__c) =: year AND CALENDAR_MONTH(Effective_Date__c) =: month];

        Map<Integer, Map<Id, Person_to_Unit_Mapping_History__c>> existingMap = new Map<Integer, Map<Id, Person_to_Unit_Mapping_History__c>>{
                1 => new Map<Id, Person_to_Unit_Mapping_History__c>(), 2 => new Map<Id, Person_to_Unit_Mapping_History__c>(), 3 => new Map<Id, Person_to_Unit_Mapping_History__c>(), 4 => new Map<Id, Person_to_Unit_Mapping_History__c>(),
                5 => new Map<Id, Person_to_Unit_Mapping_History__c>(), 6 => new Map<Id, Person_to_Unit_Mapping_History__c>(), 7 => new Map<Id, Person_to_Unit_Mapping_History__c>(), 8 => new Map<Id, Person_to_Unit_Mapping_History__c>(),
                9 => new Map<Id, Person_to_Unit_Mapping_History__c>(), 10=> new Map<Id, Person_to_Unit_Mapping_History__c>(), 11=> new Map<Id, Person_to_Unit_Mapping_History__c>(), 12=> new Map<Id, Person_to_Unit_Mapping_History__c>()
        };

        for (Person_to_Unit_Mapping_History__c l : existingRecordsForPeriod) {
            existingMap.get(l.Effective_Date__c.month()).put(l.Person__c, l);
        }

        System.debug('existingRecordsForPeriod: ' + existingRecordsForPeriod.size());

        List<Person_to_Unit_Mapping_History__c> mappingUpsert = new List<Person_to_Unit_Mapping_History__c>();
        List<Contact> allContacts = [SELECT Id, Name, Unit__c FROM Contact WHERE RecordType.Name = 'Internal' AND Inactive__c = false];

        System.debug('Contacts to map: ' + allContacts.size());
        // generating only absent records
        if (month == null) {
            System.debug('Month is null');
            Integer currentMonth = year == thisYear ? System.today().month() : 12;
            for (Integer m = 1; m <= currentMonth; m ++) {
                if (existingMap.get(m).size() > 0) {
                    System.debug('Records for month ' + m + ' already exist, skipping');
                    continue;
                }
                System.debug('Generating mapping line for contacts: ' + allContacts);
                for (Contact person : allContacts) {
                    mappingUpsert.add(new Person_to_Unit_Mapping_History__c(Person__c = person.Id, Unit__c = person.Unit__c, Effective_Date__c = Date.newInstance(year, m, 1)));
                }
            }
        }
        // regenerating records
        else {
            System.debug('Month is: ' + month);

            for (Contact person : allContacts) {
                Person_to_Unit_Mapping_History__c mapping = new Person_to_Unit_Mapping_History__c(
                        Person__c = person.Id,
                        Unit__c = person.Unit__c,
                        Effective_Date__c = Date.newInstance(year, month, 1)
                );

                for (Id personId : existingMap.get(month).keySet()) {
                    if (personId == mapping.Person__c) mapping.Id = existingMap.get(month).get(personId).Id;
                }

                mappingUpsert.add(mapping);
            }
        }

        if (mappingUpsert.size() > 0) {
            System.debug('mappingUpsert: ' + mappingUpsert.size());
            upsert mappingUpsert;
        }

    }

    public void execute(SchedulableContext param1) {
        createSnapshot(null, null);
    }

    public static void schedule() {
        //0 0 0 1 1/1 ? *
        System.schedule('Person to Unit Monthly Mapping', '0 0 0 1 1/1 ? *', new PersonToUnitMapService());
    }
}