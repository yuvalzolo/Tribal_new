/**
 * @description Test class for ECP_AccountOpptyController
 * @author Enterprise CRM Platform
 */
@isTest
private class ECP_AccountOpptyControllerTest {

    @testSetup
    static void setupTestData() {
        // Create test User for Account Manager lookup
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Manager',
            Email = 'testmanager@example.com',
            Username = 'testmanager' + System.currentTimeMillis() + '@example.com',
            Alias = 'tmgr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create test Accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                ECP_Account_Tier__c = i < 3 ? 'Gold' : 'Silver',
                ECP_Annual_Contract_Value__c = 100000 + (i * 10000),
                ECP_Last_Engagement_Date__c = Date.today().addDays(-i),
                ECP_Primary_Industry__c = i < 2 ? 'Technology' : 'Healthcare',
                ECP_Account_Manager__c = testUser.Id
            );
            testAccounts.add(acc);
        }
        insert testAccounts;

        // Create test Contacts
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact con = new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                Email = 'testcontact' + i + '@example.com',
                AccountId = testAccounts[i].Id
            );
            testContacts.add(con);
        }
        insert testContacts;

        // Create test Opportunities
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = testAccounts[i].Id,
                StageName = i < 2 ? 'Prospecting' : 'Qualification',
                CloseDate = Date.today().addDays(30 + i),
                Amount = 50000 + (i * 5000),
                ECP_Deal_Priority__c = i < 2 ? 'High' : 'Medium',
                ECP_Win_Probability__c = 50 + (i * 5),
                ECP_Next_Step_Date__c = Date.today().addDays(7),
                ECP_Executive_Sponsor__c = testContacts[i].Id
            );
            testOpportunities.add(opp);
        }
        insert testOpportunities;
    }

    @isTest
    static void testGetAccounts() {
        Test.startTest();
        List<ECP_AccountOpptyController.AccountWrapper> accounts =
            ECP_AccountOpptyController.getAccounts(null, null, null);
        Test.stopTest();

        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        System.assert(accounts.size() > 0, 'Should return at least one account');
    }

    @isTest
    static void testGetAccountsWithFilters() {
        Test.startTest();
        List<ECP_AccountOpptyController.AccountWrapper> accounts =
            ECP_AccountOpptyController.getAccounts('Gold', 'Technology', null);
        Test.stopTest();

        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        for (ECP_AccountOpptyController.AccountWrapper acc : accounts) {
            System.assertEquals('Gold', acc.accountTier, 'Account tier should be Gold');
            System.assertEquals('Technology', acc.primaryIndustry, 'Industry should be Technology');
        }
    }

    @isTest
    static void testGetAccountsWithSearch() {
        Test.startTest();
        List<ECP_AccountOpptyController.AccountWrapper> accounts =
            ECP_AccountOpptyController.getAccounts(null, null, 'Test Account 0');
        Test.stopTest();

        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        System.assert(accounts.size() > 0, 'Should find matching account');
    }

    @isTest
    static void testGetOpportunities() {
        Test.startTest();
        List<ECP_AccountOpptyController.OpportunityWrapper> opportunities =
            ECP_AccountOpptyController.getOpportunities(null, null, null, null);
        Test.stopTest();

        System.assertNotEquals(null, opportunities, 'Opportunities list should not be null');
        System.assert(opportunities.size() > 0, 'Should return at least one opportunity');
    }

    @isTest
    static void testGetOpportunitiesWithFilters() {
        Test.startTest();
        List<ECP_AccountOpptyController.OpportunityWrapper> opportunities =
            ECP_AccountOpptyController.getOpportunities('Prospecting', 'High', null, null);
        Test.stopTest();

        System.assertNotEquals(null, opportunities, 'Opportunities list should not be null');
        for (ECP_AccountOpptyController.OpportunityWrapper opp : opportunities) {
            System.assertEquals('Prospecting', opp.stageName, 'Stage should be Prospecting');
            System.assertEquals('High', opp.dealPriority, 'Priority should be High');
        }
    }

    @isTest
    static void testGetOpportunitiesWithCloseDateFilter() {
        Test.startTest();
        List<ECP_AccountOpptyController.OpportunityWrapper> opportunities =
            ECP_AccountOpptyController.getOpportunities(null, null, 'Next 30 Days', null);
        Test.stopTest();

        System.assertNotEquals(null, opportunities, 'Opportunities list should not be null');
    }

    @isTest
    static void testGetDashboardSummary() {
        Test.startTest();
        ECP_AccountOpptyController.DashboardSummary summary =
            ECP_AccountOpptyController.getDashboardSummary();
        Test.stopTest();

        System.assertNotEquals(null, summary, 'Summary should not be null');
        System.assert(summary.totalAccounts > 0, 'Should have accounts');
        System.assert(summary.totalOpportunities >= 0, 'Should have opportunities count');
    }

    @isTest
    static void testGetAccountTierPicklistValues() {
        Test.startTest();
        List<Map<String, String>> options =
            ECP_AccountOpptyController.getAccountTierPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should have at least one option');
    }

    @isTest
    static void testGetPrimaryIndustryPicklistValues() {
        Test.startTest();
        List<Map<String, String>> options =
            ECP_AccountOpptyController.getPrimaryIndustryPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should have at least one option');
    }

    @isTest
    static void testGetDealPriorityPicklistValues() {
        Test.startTest();
        List<Map<String, String>> options =
            ECP_AccountOpptyController.getDealPriorityPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should have at least one option');
    }

    @isTest
    static void testGetOpportunityStagePicklistValues() {
        Test.startTest();
        List<Map<String, String>> options =
            ECP_AccountOpptyController.getOpportunityStagePicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should have at least one option');
    }

    @isTest
    static void testErrorHandling() {
        Test.startTest();
        try {
            // Test with invalid filter that might cause an exception
            List<ECP_AccountOpptyController.AccountWrapper> accounts =
                ECP_AccountOpptyController.getAccounts('InvalidTier', null, null);
            // Should not throw an exception, just return empty or filtered results
            System.assertNotEquals(null, accounts, 'Should handle invalid filter gracefully');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
}
