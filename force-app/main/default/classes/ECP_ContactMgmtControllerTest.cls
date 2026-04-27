/**
 * @description Test class for ECP_ContactMgmtController
 * @author Enterprise CRM Platform
 */
@isTest
private class ECP_ContactMgmtControllerTest {

    @testSetup
    static void setupTestData() {
        // Create test Accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i
            );
            testAccounts.add(acc);
        }
        insert testAccounts;

        // Create test Contacts
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact con = new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                Email = 'testcontact' + i + '@example.com',
                Phone = '555-000-' + String.valueOf(1000 + i),
                Title = 'Test Title ' + i,
                AccountId = testAccounts[Math.mod(i, 3)].Id,
                ECP_Contact_Role__c = i < 3 ? 'Decision Maker' : 'Influencer',
                ECP_Engagement_Level__c = i < 3 ? 'High' : (i < 6 ? 'Medium' : 'Low'),
                ECP_Preferred_Contact_Method__c = i < 5 ? 'Email' : 'Phone',
                ECP_Last_Contact_Date__c = Date.today().addDays(-i),
                ECP_LinkedIn_Profile__c = 'https://linkedin.com/in/test' + i
            );
            testContacts.add(con);
        }
        insert testContacts;
    }

    @isTest
    static void testGetContacts() {
        Test.startTest();
        List<ECP_ContactMgmtController.ContactWrapper> contacts =
            ECP_ContactMgmtController.getContacts(null, null, null, null);
        Test.stopTest();

        System.assertNotEquals(null, contacts, 'Contacts list should not be null');
        System.assert(contacts.size() > 0, 'Should return at least one contact');
    }

    @isTest
    static void testGetContactsWithRoleFilter() {
        Test.startTest();
        List<ECP_ContactMgmtController.ContactWrapper> contacts =
            ECP_ContactMgmtController.getContacts('Decision Maker', null, null, null);
        Test.stopTest();

        System.assertNotEquals(null, contacts, 'Contacts list should not be null');
        for (ECP_ContactMgmtController.ContactWrapper con : contacts) {
            System.assertEquals('Decision Maker', con.contactRole, 'Contact role should be Decision Maker');
        }
    }

    @isTest
    static void testGetContactsWithEngagementFilter() {
        Test.startTest();
        List<ECP_ContactMgmtController.ContactWrapper> contacts =
            ECP_ContactMgmtController.getContacts(null, 'High', null, null);
        Test.stopTest();

        System.assertNotEquals(null, contacts, 'Contacts list should not be null');
        for (ECP_ContactMgmtController.ContactWrapper con : contacts) {
            System.assertEquals('High', con.engagementLevel, 'Engagement level should be High');
        }
    }

    @isTest
    static void testGetContactsWithAccountFilter() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<ECP_ContactMgmtController.ContactWrapper> contacts =
            ECP_ContactMgmtController.getContacts(null, null, testAccount.Id, null);
        Test.stopTest();

        System.assertNotEquals(null, contacts, 'Contacts list should not be null');
        for (ECP_ContactMgmtController.ContactWrapper con : contacts) {
            System.assertEquals(testAccount.Id, con.accountId, 'Account ID should match');
        }
    }

    @isTest
    static void testGetContactsWithSearch() {
        Test.startTest();
        List<ECP_ContactMgmtController.ContactWrapper> contacts =
            ECP_ContactMgmtController.getContacts(null, null, null, 'Test Contact 0');
        Test.stopTest();

        System.assertNotEquals(null, contacts, 'Contacts list should not be null');
        System.assert(contacts.size() > 0, 'Should find matching contact');
    }

    @isTest
    static void testGetContactsGroupedByAccount() {
        Test.startTest();
        List<ECP_ContactMgmtController.AccountContactGroup> accountGroups =
            ECP_ContactMgmtController.getContactsGroupedByAccount(null, null, null);
        Test.stopTest();

        System.assertNotEquals(null, accountGroups, 'Account groups list should not be null');
        System.assert(accountGroups.size() > 0, 'Should return at least one account group');

        for (ECP_ContactMgmtController.AccountContactGroup group : accountGroups) {
            System.assertNotEquals(null, group.accountName, 'Account name should not be null');
            System.assertNotEquals(null, group.contacts, 'Contacts list should not be null');
            System.assert(group.contacts.size() > 0, 'Should have at least one contact');
        }
    }

    @isTest
    static void testGetContactsGroupedWithFilters() {
        Test.startTest();
        List<ECP_ContactMgmtController.AccountContactGroup> accountGroups =
            ECP_ContactMgmtController.getContactsGroupedByAccount('Decision Maker', 'High', null);
        Test.stopTest();

        System.assertNotEquals(null, accountGroups, 'Account groups list should not be null');

        for (ECP_ContactMgmtController.AccountContactGroup group : accountGroups) {
            for (ECP_ContactMgmtController.ContactWrapper con : group.contacts) {
                System.assertEquals('Decision Maker', con.contactRole, 'Contact role should be Decision Maker');
                System.assertEquals('High', con.engagementLevel, 'Engagement level should be High');
            }
        }
    }

    @isTest
    static void testGetContactRolePicklistValues() {
        Test.startTest();
        List<Map<String, String>> options =
            ECP_ContactMgmtController.getContactRolePicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should have at least one option');
    }

    @isTest
    static void testGetEngagementLevelPicklistValues() {
        Test.startTest();
        List<Map<String, String>> options =
            ECP_ContactMgmtController.getEngagementLevelPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should have at least one option');
    }

    @isTest
    static void testGetPreferredContactMethodPicklistValues() {
        Test.startTest();
        List<Map<String, String>> options =
            ECP_ContactMgmtController.getPreferredContactMethodPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should have at least one option');
    }

    @isTest
    static void testGetAccountsForFilter() {
        Test.startTest();
        List<Map<String, String>> options =
            ECP_ContactMgmtController.getAccountsForFilter();
        Test.stopTest();

        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 0, 'Should have at least one option');
        // First option should be 'All Accounts'
        System.assertEquals('All Accounts', options[0].get('label'), 'First option should be All Accounts');
    }

    @isTest
    static void testGetContactsWithMultipleFilters() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<ECP_ContactMgmtController.ContactWrapper> contacts =
            ECP_ContactMgmtController.getContacts('Decision Maker', 'High', testAccount.Id, 'Test');
        Test.stopTest();

        System.assertNotEquals(null, contacts, 'Contacts list should not be null');
        // All returned contacts should match the filters
        for (ECP_ContactMgmtController.ContactWrapper con : contacts) {
            System.assertEquals('Decision Maker', con.contactRole, 'Contact role should be Decision Maker');
            System.assertEquals('High', con.engagementLevel, 'Engagement level should be High');
            System.assertEquals(testAccount.Id, con.accountId, 'Account ID should match');
        }
    }

    @isTest
    static void testErrorHandling() {
        Test.startTest();
        try {
            // Test with invalid filter that might cause an exception
            List<ECP_ContactMgmtController.ContactWrapper> contacts =
                ECP_ContactMgmtController.getContacts('InvalidRole', null, null, null);
            // Should not throw an exception, just return empty or filtered results
            System.assertNotEquals(null, contacts, 'Should handle invalid filter gracefully');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testContactWrapperFields() {
        Test.startTest();
        List<ECP_ContactMgmtController.ContactWrapper> contacts =
            ECP_ContactMgmtController.getContacts(null, null, null, null);
        Test.stopTest();

        System.assert(contacts.size() > 0, 'Should have at least one contact');

        ECP_ContactMgmtController.ContactWrapper contact = contacts[0];
        System.assertNotEquals(null, contact.contactId, 'Contact ID should not be null');
        System.assertNotEquals(null, contact.fullName, 'Full name should not be null');
        System.assertNotEquals(null, contact.accountName, 'Account name should not be null');
    }
}
