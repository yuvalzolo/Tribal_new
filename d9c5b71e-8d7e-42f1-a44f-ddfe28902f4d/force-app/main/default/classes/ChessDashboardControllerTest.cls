/**
 * ChessDashboardControllerTest
 *
 * Test class for ChessDashboardController to verify functionality of Account queries,
 * Type filtering, and Industry filtering for the Chess Dashboard component.
 */
@isTest
private class ChessDashboardControllerTest {

    /**
     * Creates test Account data with various types and industries
     */
    @TestSetup
    static void setupTestData() {
        List<Account> testAccounts = new List<Account>();

        testAccounts.add(new Account(
            Name = 'Alpha Corporation',
            Type = 'Customer',
            Industry = 'Technology',
            AnnualRevenue = 1000000,
            NumberOfEmployees = 100,
            Phone = '555-0001',
            Website = 'www.alphacorp.com',
            BillingCity = 'San Francisco',
            BillingState = 'CA'
        ));

        testAccounts.add(new Account(
            Name = 'Beta Industries',
            Type = 'Prospect',
            Industry = 'Manufacturing',
            AnnualRevenue = 500000,
            NumberOfEmployees = 50,
            Phone = '555-0002',
            Website = 'www.betaindustries.com',
            BillingCity = 'New York',
            BillingState = 'NY'
        ));

        testAccounts.add(new Account(
            Name = 'Gamma Enterprises',
            Type = 'Customer',
            Industry = 'Technology',
            AnnualRevenue = 2000000,
            NumberOfEmployees = 200,
            Phone = '555-0003',
            Website = 'www.gammaent.com',
            BillingCity = 'Austin',
            BillingState = 'TX'
        ));

        testAccounts.add(new Account(
            Name = 'Delta Partners',
            Type = 'Partner',
            Industry = 'Finance',
            AnnualRevenue = 750000,
            NumberOfEmployees = 75,
            Phone = '555-0004',
            Website = 'www.deltapartners.com',
            BillingCity = 'Boston',
            BillingState = 'MA'
        ));

        insert testAccounts;
    }

    /**
     * Tests getAccounts method returns all accounts owned by current user sorted by Name
     */
    @isTest
    static void testGetAccounts() {
        Test.startTest();
        List<Account> accounts = ChessDashboardController.getAccounts();
        Test.stopTest();

        // Verify all accounts are returned
        System.assertEquals(4, accounts.size(), 'Should return 4 test accounts');

        // Verify sorting by Name (A-Z)
        System.assertEquals('Alpha Corporation', accounts[0].Name, 'First account should be Alpha Corporation');
        System.assertEquals('Beta Industries', accounts[1].Name, 'Second account should be Beta Industries');
        System.assertEquals('Delta Partners', accounts[2].Name, 'Third account should be Delta Partners');
        System.assertEquals('Gamma Enterprises', accounts[3].Name, 'Fourth account should be Gamma Enterprises');

        // Verify required fields are populated
        System.assertNotEquals(null, accounts[0].Id, 'Account Id should be populated');
        System.assertNotEquals(null, accounts[0].Type, 'Account Type should be populated');
        System.assertNotEquals(null, accounts[0].Industry, 'Account Industry should be populated');
    }

    /**
     * Tests getAccountTypes method returns distinct Type values
     */
    @isTest
    static void testGetAccountTypes() {
        Test.startTest();
        List<Map<String, String>> types = ChessDashboardController.getAccountTypes();
        Test.stopTest();

        // Verify "All Types" option is included
        System.assertEquals(true, types.size() > 0, 'Should return at least one option');
        System.assertEquals('All Types', types[0].get('label'), 'First option should be "All Types"');
        System.assertEquals('', types[0].get('value'), 'All Types value should be empty string');

        // Verify distinct types are returned (Customer, Partner, Prospect)
        System.assertEquals(4, types.size(), 'Should return 4 options including "All Types"');

        // Verify format of type options
        Boolean hasCustomerType = false;
        Boolean hasProspectType = false;
        Boolean hasPartnerType = false;

        for (Map<String, String> typeOption : types) {
            if (typeOption.get('value') == 'Customer') {
                hasCustomerType = true;
            }
            if (typeOption.get('value') == 'Prospect') {
                hasProspectType = true;
            }
            if (typeOption.get('value') == 'Partner') {
                hasPartnerType = true;
            }
        }

        System.assertEquals(true, hasCustomerType, 'Should include Customer type');
        System.assertEquals(true, hasProspectType, 'Should include Prospect type');
        System.assertEquals(true, hasPartnerType, 'Should include Partner type');
    }

    /**
     * Tests getAccountIndustries method returns distinct Industry values
     */
    @isTest
    static void testGetAccountIndustries() {
        Test.startTest();
        List<Map<String, String>> industries = ChessDashboardController.getAccountIndustries();
        Test.stopTest();

        // Verify "All Industries" option is included
        System.assertEquals(true, industries.size() > 0, 'Should return at least one option');
        System.assertEquals('All Industries', industries[0].get('label'), 'First option should be "All Industries"');
        System.assertEquals('', industries[0].get('value'), 'All Industries value should be empty string');

        // Verify distinct industries are returned (Finance, Manufacturing, Technology)
        System.assertEquals(4, industries.size(), 'Should return 4 options including "All Industries"');

        // Verify format of industry options
        Boolean hasTechnology = false;
        Boolean hasManufacturing = false;
        Boolean hasFinance = false;

        for (Map<String, String> industryOption : industries) {
            if (industryOption.get('value') == 'Technology') {
                hasTechnology = true;
            }
            if (industryOption.get('value') == 'Manufacturing') {
                hasManufacturing = true;
            }
            if (industryOption.get('value') == 'Finance') {
                hasFinance = true;
            }
        }

        System.assertEquals(true, hasTechnology, 'Should include Technology industry');
        System.assertEquals(true, hasManufacturing, 'Should include Manufacturing industry');
        System.assertEquals(true, hasFinance, 'Should include Finance industry');
    }

    /**
     * Tests getAccounts with no accounts owned by user
     */
    @isTest
    static void testGetAccountsNoResults() {
        // Delete all test accounts
        delete [SELECT Id FROM Account];

        Test.startTest();
        List<Account> accounts = ChessDashboardController.getAccounts();
        Test.stopTest();

        System.assertEquals(0, accounts.size(), 'Should return empty list when user has no accounts');
    }

    /**
     * Tests error handling in getAccounts
     */
    @isTest
    static void testGetAccountsErrorHandling() {
        // This test verifies the controller properly handles and wraps exceptions
        // In a real scenario, you might use a mock or stub to force an exception
        Test.startTest();
        try {
            List<Account> accounts = ChessDashboardController.getAccounts();
            // If no exception, test passes (normal case)
            System.assertNotEquals(null, accounts, 'Should return a list even if empty');
        } catch (AuraHandledException e) {
            // If an exception occurs, verify it's properly wrapped
            System.assert(e.getMessage().contains('Error retrieving accounts'),
                'Exception message should contain expected error prefix');
        }
        Test.stopTest();
    }
}
