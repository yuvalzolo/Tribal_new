/**
 * @description Controller class for the Account Dashboard Lightning Web Component
 * Provides data access and calculations for dashboard statistics, charts, and account listing
 * @author Tribal AI Platform
 * @date 2026
 */
public with sharing class ADA_AccountDashboardCtrl {

    /**
     * @description Wrapper class for dashboard statistics
     */
    public class DashboardStats {
        @AuraEnabled public Integer totalAccounts { get; set; }
        @AuraEnabled public Integer activeAccounts { get; set; }
        @AuraEnabled public Decimal averageRevenue { get; set; }
        @AuraEnabled public Decimal averageHealthScore { get; set; }
    }

    /**
     * @description Wrapper class for distribution data (charts)
     */
    public class DistributionData {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Integer count { get; set; }
    }

    /**
     * @description Wrapper class for account record data
     */
    public class AccountRecord {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String tier { get; set; }
        @AuraEnabled public Decimal healthScore { get; set; }
        @AuraEnabled public Decimal totalRevenue { get; set; }
        @AuraEnabled public String industry { get; set; }
        @AuraEnabled public Date lastActivityDate { get; set; }
        @AuraEnabled public Boolean isActive { get; set; }
    }

    /**
     * @description Retrieves key dashboard statistics
     * @return DashboardStats wrapper containing aggregate metrics
     */
    @AuraEnabled(cacheable=false)
    public static DashboardStats getDashboardStats() {
        try {
            DashboardStats stats = new DashboardStats();

            // Get total account count
            stats.totalAccounts = [SELECT COUNT() FROM Account];

            // Get active account count
            stats.activeAccounts = [SELECT COUNT() FROM Account WHERE ADA_IsActive__c = true];

            // Calculate average revenue
            AggregateResult revenueResult = [
                SELECT AVG(ADA_Total_Revenue__c) avgRevenue
                FROM Account
                WHERE ADA_Total_Revenue__c != null
            ];
            Object avgRev = revenueResult.get('avgRevenue');
            stats.averageRevenue = avgRev != null ? (Decimal)avgRev : 0;

            // Calculate average health score
            AggregateResult healthResult = [
                SELECT AVG(ADA_Account_Health_Score__c) avgHealth
                FROM Account
                WHERE ADA_Account_Health_Score__c != null
            ];
            Object avgHealth = healthResult.get('avgHealth');
            stats.averageHealthScore = avgHealth != null ? (Decimal)avgHealth : 0;

            return stats;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving dashboard statistics: ' + e.getMessage());
        }
    }

    /**
     * @description Retrieves account distribution by tier
     * @return List of DistributionData containing tier breakdown
     */
    @AuraEnabled(cacheable=false)
    public static List<DistributionData> getTierDistribution() {
        try {
            List<DistributionData> distribution = new List<DistributionData>();

            List<AggregateResult> results = [
                SELECT ADA_Account_Tier__c tier, COUNT(Id) cnt
                FROM Account
                WHERE ADA_Account_Tier__c != null
                GROUP BY ADA_Account_Tier__c
            ];

            for (AggregateResult ar : results) {
                DistributionData data = new DistributionData();
                data.label = (String)ar.get('tier');
                data.count = (Integer)ar.get('cnt');
                distribution.add(data);
            }

            return distribution;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving tier distribution: ' + e.getMessage());
        }
    }

    /**
     * @description Retrieves account distribution by industry
     * @return List of DistributionData containing industry breakdown
     */
    @AuraEnabled(cacheable=false)
    public static List<DistributionData> getIndustryDistribution() {
        try {
            List<DistributionData> distribution = new List<DistributionData>();

            List<AggregateResult> results = [
                SELECT Industry ind, COUNT(Id) cnt
                FROM Account
                WHERE Industry != null
                GROUP BY Industry
                ORDER BY COUNT(Id) DESC
                LIMIT 10
            ];

            for (AggregateResult ar : results) {
                DistributionData data = new DistributionData();
                data.label = (String)ar.get('ind');
                data.count = (Integer)ar.get('cnt');
                distribution.add(data);
            }

            return distribution;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving industry distribution: ' + e.getMessage());
        }
    }

    /**
     * @description Retrieves account distribution by type
     * @return List of DistributionData containing type breakdown
     */
    @AuraEnabled(cacheable=false)
    public static List<DistributionData> getTypeDistribution() {
        try {
            List<DistributionData> distribution = new List<DistributionData>();

            List<AggregateResult> results = [
                SELECT Type typ, COUNT(Id) cnt
                FROM Account
                WHERE Type != null
                GROUP BY Type
            ];

            for (AggregateResult ar : results) {
                DistributionData data = new DistributionData();
                data.label = (String)ar.get('typ');
                data.count = (Integer)ar.get('cnt');
                distribution.add(data);
            }

            return distribution;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving type distribution: ' + e.getMessage());
        }
    }

    /**
     * @description Retrieves all accounts with search functionality
     * @param searchTerm Optional search term to filter accounts by name
     * @return List of AccountRecord wrappers
     */
    @AuraEnabled(cacheable=false)
    public static List<AccountRecord> getAccounts(String searchTerm) {
        try {
            List<AccountRecord> accountRecords = new List<AccountRecord>();
            String searchPattern = searchTerm != null && searchTerm != ''
                ? '%' + String.escapeSingleQuotes(searchTerm) + '%'
                : '%';

            List<Account> accounts = [
                SELECT Id, Name, ADA_Account_Tier__c, ADA_Account_Health_Score__c,
                       ADA_Total_Revenue__c, Industry, ADA_Last_Activity_Date__c,
                       ADA_IsActive__c
                FROM Account
                WHERE Name LIKE :searchPattern
                ORDER BY Name ASC
                LIMIT 1000
            ];

            for (Account acc : accounts) {
                AccountRecord record = new AccountRecord();
                record.id = acc.Id;
                record.name = acc.Name;
                record.tier = acc.ADA_Account_Tier__c;
                record.healthScore = acc.ADA_Account_Health_Score__c;
                record.totalRevenue = acc.ADA_Total_Revenue__c;
                record.industry = acc.Industry;
                record.lastActivityDate = acc.ADA_Last_Activity_Date__c;
                record.isActive = acc.ADA_IsActive__c != null ? acc.ADA_IsActive__c : false;
                accountRecords.add(record);
            }

            return accountRecords;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving accounts: ' + e.getMessage());
        }
    }

    /**
     * @description Retrieves picklist values for Account Tier field
     * @return List of label-value maps for UI consumption
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getAccountTierPicklistValues() {
        try {
            List<Map<String, String>> options = new List<Map<String, String>>();
            Schema.DescribeFieldResult fieldResult = Account.ADA_Account_Tier__c.getDescribe();
            List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry entry : entries) {
                if (entry.isActive()) {
                    options.add(new Map<String, String>{
                        'label' => entry.getLabel(),
                        'value' => entry.getValue()
                    });
                }
            }

            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving tier picklist values: ' + e.getMessage());
        }
    }
}
