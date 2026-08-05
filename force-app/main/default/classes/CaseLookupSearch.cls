/**
 * Created on 18/11/2022.
 */

public class CaseLookupSearch {
    private final static Integer MAX_RESULTS = 20;


    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> getRecentlyViewed() {
        // Get recently viewed records of type Case
        List<RecentlyViewed> recentRecords = new pp_Query('RecentlyViewed')
                .selectFields(new Set<String>{'Id', 'Name', 'Type'})
                .addConditionEq('Type', 'Case')
                .orderBy('LastViewedDate', 'DESC')
                .setLimit(10)
                .run();
        // Collect recent record Ids
        Set<Id> caseIds = new Set<Id>();
        for (RecentlyViewed recentRecord : recentRecords) {
            caseIds.add(recentRecord.Id);
        }

        return casesToSearchResults(
                new pp_Query('Case')
                        .selectFields(new Set<String>{'Id', 'Subject', 'Case_ID__c', 'Project__r.Name'})
                        .addConditionIn('Id', caseIds)
                        .orderBy('Subject', 'ASC')
                        .run()
        );
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        pp_QuerySearch qSearch = new pp_QuerySearch()
                .find(searchTerm)
                .inAllFields()
                .returning('Case')
                .selectFields(new Set<String>{ 'Id', 'Subject', 'Case_ID__c', 'Project__r.Name' })
                .addConditionEq('IsClosed', false)
                .addConditionNotEq('Project__r.Status__c', 'Done');
        if (selectedIds != null && !selectedIds.isEmpty()) qSearch.addConditionNotIn('Id', selectedIds);
        List<List<SObject>> searchResults = qSearch
                .setLimit(MAX_RESULTS)
                .run();

        return casesToSearchResults((List<Case>) searchResults[0]);
    }

    private static List<LookupSearchResult> casesToSearchResults(List<Case> cases) {
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Cases & convert them into LookupSearchResult
        for (Case c : cases) {
            results.add(new LookupSearchResult(
                    c.Id,
                    'Case',
                    'standard:case',
                    (c.Case_ID__c != null ? c.Case_ID__c + ': ' : '') + c.Subject,
                    c.Project__r.Name));
        }

        // Optionally sort all results on title
        results.sort();

        return results;
    }
}