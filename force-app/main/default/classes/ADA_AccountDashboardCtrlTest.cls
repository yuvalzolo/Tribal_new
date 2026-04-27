/**
 * @description Test class for ADA_AccountDashboardCtrl
 * @author Tribal AI Platform
 * @date 2026
 */
@isTest
private class ADA_AccountDashboardCtrlTest {

    /**
     * @description Setup method to create test data
     */
    @testSetup
    static void setupTestData() {
        List<Account> testAccounts = new List<Account>();

        // Create Platinum tier accounts
        for (Integer i = 1; i <= 3; i++) {
            Account acc = new Account();
            acc.Name = 'Platinum Account ' + i;
            acc.Industry = 'Technology';
            acc.Type = 'Customer';
            acc.ADA_Account_Tier__c = 'Platinum';
            acc.ADA_Account_Health_Score__c = 90.0 + i;
            acc.ADA_Total_Revenue__c = 100000.0 * i;
            acc.ADA_Last_Activity_Date__c = Date.today().addDays(-i);
            acc.ADA_IsActive__c = true;
            testAccounts.add(acc);
        }

        // Create Gold tier accounts
        for (Integer i = 1; i <= 3; i++) {
            Account acc = new Account();
            acc.Name = 'Gold Account ' + i;
            acc.Industry = 'Healthcare';
            acc.Type = 'Prospect';
            acc.ADA_Account_Tier__c = 'Gold';
            acc.ADA_Account_Health_Score__c = 70.0 + i;
            acc.ADA_Total_Revenue__c = 50000.0 * i;
            acc.ADA_Last_Activity_Date__c = Date.today().addDays(-5 - i);
            acc.ADA_IsActive__c = true;
            testAccounts.add(acc);
        }

        // Create Silver tier accounts
        for (Integer i = 1; i <= 2; i++) {
            Account acc = new Account();
            acc.Name = 'Silver Account ' + i;
            acc.Industry = 'Finance';
            acc.Type = 'Partner';
            acc.ADA_Account_Tier__c = 'Silver';
            acc.ADA_Account_Health_Score__c = 50.0 + i;
            acc.ADA_Total_Revenue__c = 25000.0 * i;
            acc.ADA_Last_Activity_Date__c = Date.today().addDays(-10 - i);
            acc.ADA_IsActive__c = false;
            testAccounts.add(acc);
        }

        // Create Bronze tier accounts
        for (Integer i = 1; i <= 2; i++) {
            Account acc = new Account();
            acc.Name = 'Bronze Account ' + i;
            acc.Industry = 'Retail';
            acc.Type = 'Customer';
            acc.ADA_Account_Tier__c = 'Bronze';
            acc.ADA_Account_Health_Score__c = 30.0 + i;
            acc.ADA_Total_Revenue__c = 10000.0 * i;
            acc.ADA_Last_Activity_Date__c = Date.today().addDays(-15 - i);
            acc.ADA_IsActive__c = false;
            testAccounts.add(acc);
        }

        insert testAccounts;
    }

    /**
     * @description Test getDashboardStats method
     */
    @isTest
    static void testGetDashboardStats() {
        Test.startTest();
        ADA_AccountDashboardCtrl.DashboardStats stats = ADA_AccountDashboardCtrl.getDashboardStats();
        Test.stopTest();

        System.assertNotEquals(null, stats, 'Stats should not be null');
        System.assertEquals(10, stats.totalAccounts, 'Total accounts should be 10');
        System.assertEquals(6, stats.activeAccounts, 'Active accounts should be 6');
        System.assert(stats.averageRevenue > 0, 'Average revenue should be greater than 0');
        System.assert(stats.averageHealthScore > 0, 'Average health score should be greater than 0');
    }

    /**
     * @description Test getTierDistribution method
     */
    @isTest
    static void testGetTierDistribution() {
        Test.startTest();
        List<ADA_AccountDashboardCtrl.DistributionData> distribution = ADA_AccountDashboardCtrl.getTierDistribution();
        Test.stopTest();

        System.assertNotEquals(null, distribution, 'Distribution should not be null');
        System.assertEquals(4, distribution.size(), 'Should have 4 tier categories');

        Map<String, Integer> tierCounts = new Map<String, Integer>();
        for (ADA_AccountDashboardCtrl.DistributionData data : distribution) {
            tierCounts.put(data.label, data.count);
        }

        System.assertEquals(3, tierCounts.get('Platinum'), 'Should have 3 Platinum accounts');
        System.assertEquals(3, tierCounts.get('Gold'), 'Should have 3 Gold accounts');
        System.assertEquals(2, tierCounts.get('Silver'), 'Should have 2 Silver accounts');
        System.assertEquals(2, tierCounts.get('Bronze'), 'Should have 2 Bronze accounts');
    }

    /**
     * @description Test getIndustryDistribution method
     */
    @isTest
    static void testGetIndustryDistribution() {
        Test.startTest();
        List<ADA_AccountDashboardCtrl.DistributionData> distribution = ADA_AccountDashboardCtrl.getIndustryDistribution();
        Test.stopTest();

        System.assertNotEquals(null, distribution, 'Distribution should not be null');
        System.assertEquals(4, distribution.size(), 'Should have 4 industry categories');

        Map<String, Integer> industryCounts = new Map<String, Integer>();
        for (ADA_AccountDashboardCtrl.DistributionData data : distribution) {
            industryCounts.put(data.label, data.count);
        }

        System.assertEquals(3, industryCounts.get('Technology'), 'Should have 3 Technology accounts');
        System.assertEquals(3, industryCounts.get('Healthcare'), 'Should have 3 Healthcare accounts');
        System.assertEquals(2, industryCounts.get('Finance'), 'Should have 2 Finance accounts');
        System.assertEquals(2, industryCounts.get('Retail'), 'Should have 2 Retail accounts');
    }

    /**
     * @description Test getTypeDistribution method
     */
    @isTest
    static void testGetTypeDistribution() {
        Test.startTest();
        List<ADA_AccountDashboardCtrl.DistributionData> distribution = ADA_AccountDashboardCtrl.getTypeDistribution();
        Test.stopTest();

        System.assertNotEquals(null, distribution, 'Distribution should not be null');
        System.assert(distribution.size() > 0, 'Should have at least one type category');

        Map<String, Integer> typeCounts = new Map<String, Integer>();
        for (ADA_AccountDashboardCtrl.DistributionData data : distribution) {
            typeCounts.put(data.label, data.count);
        }

        System.assertEquals(5, typeCounts.get('Customer'), 'Should have 5 Customer accounts');
        System.assertEquals(3, typeCounts.get('Prospect'), 'Should have 3 Prospect accounts');
        System.assertEquals(2, typeCounts.get('Partner'), 'Should have 2 Partner accounts');
    }

    /**
     * @description Test getAccounts method without search term
     */
    @isTest
    static void testGetAccountsNoSearch() {
        Test.startTest();
        List<ADA_AccountDashboardCtrl.AccountRecord> accounts = ADA_AccountDashboardCtrl.getAccounts('');
        Test.stopTest();

        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        System.assertEquals(10, accounts.size(), 'Should return all 10 accounts');

        // Verify first account (should be sorted alphabetically)
        ADA_AccountDashboardCtrl.AccountRecord firstAccount = accounts[0];
        System.assertNotEquals(null, firstAccount.id, 'Account ID should not be null');
        System.assertNotEquals(null, firstAccount.name, 'Account name should not be null');
    }

    /**
     * @description Test getAccounts method with search term
     */
    @isTest
    static void testGetAccountsWithSearch() {
        Test.startTest();
        List<ADA_AccountDashboardCtrl.AccountRecord> accounts = ADA_AccountDashboardCtrl.getAccounts('Platinum');
        Test.stopTest();

        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        System.assertEquals(3, accounts.size(), 'Should return 3 Platinum accounts');

        for (ADA_AccountDashboardCtrl.AccountRecord acc : accounts) {
            System.assert(acc.name.contains('Platinum'), 'Account name should contain Platinum');
        }
    }

    /**
     * @description Test getAccounts method with null search term
     */
    @isTest
    static void testGetAccountsNullSearch() {
        Test.startTest();
        List<ADA_AccountDashboardCtrl.AccountRecord> accounts = ADA_AccountDashboardCtrl.getAccounts(null);
        Test.stopTest();

        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        System.assertEquals(10, accounts.size(), 'Should return all 10 accounts when search is null');
    }

    /**
     * @description Test getAccountTierPicklistValues method
     */
    @isTest
    static void testGetAccountTierPicklistValues() {
        Test.startTest();
        List<Map<String, String>> picklistValues = ADA_AccountDashboardCtrl.getAccountTierPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
        System.assert(picklistValues.size() > 0, 'Should have at least one picklist value');

        // Verify structure of picklist values
        for (Map<String, String> option : picklistValues) {
            System.assert(option.containsKey('label'), 'Option should have label key');
            System.assert(option.containsKey('value'), 'Option should have value key');
            System.assertNotEquals(null, option.get('label'), 'Label should not be null');
            System.assertNotEquals(null, option.get('value'), 'Value should not be null');
        }
    }

    /**
     * @description Test error handling in getDashboardStats with no data
     */
    @isTest
    static void testGetDashboardStatsNoData() {
        // Delete all test accounts
        delete [SELECT Id FROM Account];

        Test.startTest();
        ADA_AccountDashboardCtrl.DashboardStats stats = ADA_AccountDashboardCtrl.getDashboardStats();
        Test.stopTest();

        System.assertNotEquals(null, stats, 'Stats should not be null even with no data');
        System.assertEquals(0, stats.totalAccounts, 'Total accounts should be 0');
        System.assertEquals(0, stats.activeAccounts, 'Active accounts should be 0');
        System.assertEquals(0, stats.averageRevenue, 'Average revenue should be 0');
        System.assertEquals(0, stats.averageHealthScore, 'Average health score should be 0');
    }
}
