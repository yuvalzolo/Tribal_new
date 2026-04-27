/**
 * @description Controller for Account & Opportunity Dashboard LWC
 * Provides data access, filtering, and aggregation for accounts and opportunities
 */
public with sharing class ECP_AccountOpptyController {

    /**
     * @description Wrapper class for dashboard summary statistics
     */
    public class DashboardSummary {
        @AuraEnabled public Integer totalAccounts { get; set; }
        @AuraEnabled public Decimal totalPipelineValue { get; set; }
        @AuraEnabled public Decimal winRate { get; set; }
        @AuraEnabled public Integer totalOpportunities { get; set; }

        public DashboardSummary() {
            this.totalAccounts = 0;
            this.totalPipelineValue = 0;
            this.winRate = 0;
            this.totalOpportunities = 0;
        }
    }

    /**
     * @description Wrapper class for Account data
     */
    public class AccountData {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String accountTier { get; set; }
        @AuraEnabled public Decimal healthScore { get; set; }
        @AuraEnabled public Decimal annualContractValue { get; set; }
        @AuraEnabled public String primaryIndustry { get; set; }
        @AuraEnabled public Date lastEngagementDate { get; set; }
        @AuraEnabled public String accountManagerName { get; set; }
    }

    /**
     * @description Wrapper class for Opportunity data
     */
    public class OpportunityData {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String stageName { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public Date closeDate { get; set; }
        @AuraEnabled public String dealPriority { get; set; }
        @AuraEnabled public Decimal winProbability { get; set; }
        @AuraEnabled public Date nextStepDate { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Id accountId { get; set; }
    }

    /**
     * @description Retrieves filtered accounts with key metrics
     * @param tierFilter Account tier filter value
     * @param industryFilter Primary industry filter value
     * @param searchTerm Search term for account name
     * @return List of AccountData wrapper objects
     */
    @AuraEnabled(cacheable=false)
    public static List<AccountData> getAccounts(String tierFilter, String industryFilter, String searchTerm) {
        List<AccountData> results = new List<AccountData>();

        String query = 'SELECT Id, Name, ECP_Account_Tier__c, ' +
                      'ECP_Annual_Contract_Value__c, ECP_Primary_Industry__c, ' +
                      'ECP_Last_Engagement_Date__c, ECP_Account_Manager__r.Name ' +
                      'FROM Account WHERE Id != null';

        if (String.isNotBlank(tierFilter) && tierFilter != 'All') {
            query += ' AND ECP_Account_Tier__c = :tierFilter';
        }

        if (String.isNotBlank(industryFilter) && industryFilter != 'All') {
            query += ' AND ECP_Primary_Industry__c = :industryFilter';
        }

        if (String.isNotBlank(searchTerm)) {
            String searchPattern = '%' + String.escapeSingleQuotes(searchTerm) + '%';
            query += ' AND Name LIKE :searchPattern';
        }

        query += ' ORDER BY Name ASC LIMIT 1000';

        try {
            for (Account acc : Database.query(query)) {
                AccountData data = new AccountData();
                data.id = acc.Id;
                data.name = acc.Name;
                data.accountTier = acc.ECP_Account_Tier__c;
                data.annualContractValue = acc.ECP_Annual_Contract_Value__c;
                data.primaryIndustry = acc.ECP_Primary_Industry__c;
                data.lastEngagementDate = acc.ECP_Last_Engagement_Date__c;
                data.accountManagerName = acc.ECP_Account_Manager__r?.Name;
                results.add(data);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving accounts: ' + e.getMessage());
        }

        return results;
    }

    /**
     * @description Retrieves filtered opportunities with key metrics
     * @param stageFilter Stage name filter value
     * @param priorityFilter Deal priority filter value
     * @param searchTerm Search term for opportunity name
     * @return List of OpportunityData wrapper objects
     */
    @AuraEnabled(cacheable=false)
    public static List<OpportunityData> getOpportunities(String stageFilter, String priorityFilter, String searchTerm) {
        List<OpportunityData> results = new List<OpportunityData>();

        String query = 'SELECT Id, Name, StageName, Amount, CloseDate, ' +
                      'ECP_Deal_Priority__c, ECP_Win_Probability__c, ECP_Next_Step_Date__c, ' +
                      'Account.Name, AccountId ' +
                      'FROM Opportunity WHERE Id != null';

        if (String.isNotBlank(stageFilter) && stageFilter != 'All') {
            query += ' AND StageName = :stageFilter';
        }

        if (String.isNotBlank(priorityFilter) && priorityFilter != 'All') {
            query += ' AND ECP_Deal_Priority__c = :priorityFilter';
        }

        if (String.isNotBlank(searchTerm)) {
            String searchPattern = '%' + String.escapeSingleQuotes(searchTerm) + '%';
            query += ' AND Name LIKE :searchPattern';
        }

        query += ' ORDER BY CloseDate ASC LIMIT 1000';

        try {
            for (Opportunity opp : Database.query(query)) {
                OpportunityData data = new OpportunityData();
                data.id = opp.Id;
                data.name = opp.Name;
                data.stageName = opp.StageName;
                data.amount = opp.Amount;
                data.closeDate = opp.CloseDate;
                data.dealPriority = opp.ECP_Deal_Priority__c;
                data.winProbability = opp.ECP_Win_Probability__c;
                data.nextStepDate = opp.ECP_Next_Step_Date__c;
                data.accountName = opp.Account?.Name;
                data.accountId = opp.AccountId;
                results.add(data);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving opportunities: ' + e.getMessage());
        }

        return results;
    }

    /**
     * @description Calculates dashboard summary statistics
     * @return DashboardSummary wrapper with aggregated metrics
     */
    @AuraEnabled(cacheable=false)
    public static DashboardSummary getDashboardSummary() {
        DashboardSummary summary = new DashboardSummary();

        try {
            // Get total accounts count
            summary.totalAccounts = [SELECT COUNT() FROM Account];

            // Get total opportunities and pipeline value
            AggregateResult[] oppResults = [
                SELECT COUNT(Id) oppCount, SUM(Amount) totalAmount
                FROM Opportunity
                WHERE IsClosed = false
            ];

            if (!oppResults.isEmpty() && oppResults[0] != null) {
                summary.totalOpportunities = (Integer)oppResults[0].get('oppCount');
                summary.totalPipelineValue = (Decimal)oppResults[0].get('totalAmount');
                if (summary.totalPipelineValue == null) {
                    summary.totalPipelineValue = 0;
                }
            }

            // Calculate win rate
            AggregateResult[] closedResults = [
                SELECT COUNT(Id) totalClosed
                FROM Opportunity
                WHERE IsClosed = true
            ];

            AggregateResult[] wonResults = [
                SELECT COUNT(Id) totalWon
                FROM Opportunity
                WHERE IsWon = true
            ];

            Integer totalClosed = 0;
            Integer totalWon = 0;

            if (!closedResults.isEmpty() && closedResults[0] != null) {
                totalClosed = (Integer)closedResults[0].get('totalClosed');
            }

            if (!wonResults.isEmpty() && wonResults[0] != null) {
                totalWon = (Integer)wonResults[0].get('totalWon');
            }

            if (totalClosed > 0) {
                summary.winRate = ((Decimal)totalWon / (Decimal)totalClosed) * 100;
                summary.winRate = summary.winRate.setScale(1);
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error calculating dashboard summary: ' + e.getMessage());
        }

        return summary;
    }

    /**
     * @description Retrieves Account Tier picklist values
     * @return List of picklist option maps with label and value
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getAccountTierPicklistValues() {
        return getPicklistValues('Account', 'ECP_Account_Tier__c');
    }

    /**
     * @description Retrieves Primary Industry picklist values
     * @return List of picklist option maps with label and value
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getPrimaryIndustryPicklistValues() {
        return getPicklistValues('Account', 'ECP_Primary_Industry__c');
    }

    /**
     * @description Retrieves Deal Priority picklist values
     * @return List of picklist option maps with label and value
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getDealPriorityPicklistValues() {
        return getPicklistValues('Opportunity', 'ECP_Deal_Priority__c');
    }

    /**
     * @description Retrieves Opportunity Stage picklist values
     * @return List of picklist option maps with label and value
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getOpportunityStagePicklistValues() {
        return getPicklistValues('Opportunity', 'StageName');
    }

    /**
     * @description Generic method to retrieve picklist values for any field
     * @param objectApiName API name of the SObject
     * @param fieldApiName API name of the field
     * @return List of picklist option maps with label and value
     */
    private static List<Map<String, String>> getPicklistValues(String objectApiName, String fieldApiName) {
        List<Map<String, String>> options = new List<Map<String, String>>();

        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            if (sObjectType == null) {
                return options;
            }

            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap().get(fieldApiName).getDescribe();
            List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry entry : entries) {
                if (entry.isActive()) {
                    options.add(new Map<String, String>{
                        'label' => entry.getLabel(),
                        'value' => entry.getValue()
                    });
                }
            }
        } catch (Exception e) {
            // Return empty list if field doesn't exist or isn't a picklist
            System.debug('Error retrieving picklist values: ' + e.getMessage());
        }

        return options;
    }
}
