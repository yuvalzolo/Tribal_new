/**
 * @description Controller for Contact Management Hub LWC
 * Provides contact data access, relationship queries, and filtering
 */
public with sharing class ECP_ContactMgmtController {

    /**
     * @description Wrapper class for Contact data
     */
    public class ContactData {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String contactRole { get; set; }
        @AuraEnabled public String engagementLevel { get; set; }
        @AuraEnabled public String preferredContactMethod { get; set; }
        @AuraEnabled public Date lastContactDate { get; set; }
        @AuraEnabled public String linkedInProfile { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Id accountId { get; set; }
    }

    /**
     * @description Wrapper class for Account with Contacts grouping
     */
    public class AccountWithContacts {
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Integer contactCount { get; set; }
        @AuraEnabled public List<ContactData> contacts { get; set; }

        public AccountWithContacts() {
            this.contacts = new List<ContactData>();
            this.contactCount = 0;
        }
    }

    /**
     * @description Retrieves filtered contacts with key information
     * @param roleFilter Contact role filter value
     * @param engagementFilter Engagement level filter value
     * @param accountFilter Account ID filter value
     * @param searchTerm Search term for contact name or email
     * @return List of ContactData wrapper objects
     */
    @AuraEnabled(cacheable=false)
    public static List<ContactData> getContacts(String roleFilter, String engagementFilter, String accountFilter, String searchTerm) {
        List<ContactData> results = new List<ContactData>();

        String query = 'SELECT Id, FirstName, LastName, Email, Phone, Title, ' +
                      'ECP_Contact_Role__c, ECP_Engagement_Level__c, ECP_Preferred_Contact_Method__c, ' +
                      'ECP_Last_Contact_Date__c, ECP_LinkedIn_Profile__c, ' +
                      'Account.Name, AccountId ' +
                      'FROM Contact WHERE Id != null';

        if (String.isNotBlank(roleFilter)) {
            query += ' AND ECP_Contact_Role__c = :roleFilter';
        }

        if (String.isNotBlank(engagementFilter)) {
            query += ' AND ECP_Engagement_Level__c = :engagementFilter';
        }

        if (String.isNotBlank(accountFilter)) {
            query += ' AND AccountId = :accountFilter';
        }

        if (String.isNotBlank(searchTerm)) {
            String searchPattern = '%' + String.escapeSingleQuotes(searchTerm) + '%';
            query += ' AND (Name LIKE :searchPattern OR Email LIKE :searchPattern)';
        }

        query += ' ORDER BY LastName ASC, FirstName ASC LIMIT 1000';

        try {
            for (Contact con : Database.query(query)) {
                ContactData data = new ContactData();
                data.id = con.Id;
                data.name = (con.FirstName != null ? con.FirstName + ' ' : '') + con.LastName;
                data.email = con.Email;
                data.phone = con.Phone;
                data.title = con.Title;
                data.contactRole = con.ECP_Contact_Role__c;
                data.engagementLevel = con.ECP_Engagement_Level__c;
                data.preferredContactMethod = con.ECP_Preferred_Contact_Method__c;
                data.lastContactDate = con.ECP_Last_Contact_Date__c;
                data.linkedInProfile = con.ECP_LinkedIn_Profile__c;
                data.accountName = con.Account?.Name;
                data.accountId = con.AccountId;
                results.add(data);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving contacts: ' + e.getMessage());
        }

        return results;
    }

    /**
     * @description Retrieves contacts grouped by their associated accounts
     * @param roleFilter Contact role filter value
     * @param engagementFilter Engagement level filter value
     * @return List of AccountWithContacts wrapper objects
     */
    @AuraEnabled(cacheable=false)
    public static List<AccountWithContacts> getContactsGroupedByAccount(String roleFilter, String engagementFilter) {
        Map<Id, AccountWithContacts> accountMap = new Map<Id, AccountWithContacts>();

        String query = 'SELECT Id, FirstName, LastName, Email, Phone, Title, ' +
                      'ECP_Contact_Role__c, ECP_Engagement_Level__c, ECP_Preferred_Contact_Method__c, ' +
                      'ECP_Last_Contact_Date__c, ECP_LinkedIn_Profile__c, ' +
                      'Account.Name, AccountId ' +
                      'FROM Contact WHERE AccountId != null';

        if (String.isNotBlank(roleFilter)) {
            query += ' AND ECP_Contact_Role__c = :roleFilter';
        }

        if (String.isNotBlank(engagementFilter)) {
            query += ' AND ECP_Engagement_Level__c = :engagementFilter';
        }

        query += ' ORDER BY Account.Name ASC, LastName ASC, FirstName ASC LIMIT 1000';

        try {
            for (Contact con : Database.query(query)) {
                if (!accountMap.containsKey(con.AccountId)) {
                    AccountWithContacts acc = new AccountWithContacts();
                    acc.accountId = con.AccountId;
                    acc.accountName = con.Account.Name;
                    accountMap.put(con.AccountId, acc);
                }

                ContactData data = new ContactData();
                data.id = con.Id;
                data.name = (con.FirstName != null ? con.FirstName + ' ' : '') + con.LastName;
                data.email = con.Email;
                data.phone = con.Phone;
                data.title = con.Title;
                data.contactRole = con.ECP_Contact_Role__c;
                data.engagementLevel = con.ECP_Engagement_Level__c;
                data.preferredContactMethod = con.ECP_Preferred_Contact_Method__c;
                data.lastContactDate = con.ECP_Last_Contact_Date__c;
                data.linkedInProfile = con.ECP_LinkedIn_Profile__c;
                data.accountName = con.Account.Name;
                data.accountId = con.AccountId;

                accountMap.get(con.AccountId).contacts.add(data);
                accountMap.get(con.AccountId).contactCount++;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving grouped contacts: ' + e.getMessage());
        }

        return accountMap.values();
    }

    /**
     * @description Retrieves Contact Role picklist values
     * @return List of picklist option maps with label and value
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getContactRolePicklistValues() {
        return getPicklistValues('Contact', 'ECP_Contact_Role__c');
    }

    /**
     * @description Retrieves Engagement Level picklist values
     * @return List of picklist option maps with label and value
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getEngagementLevelPicklistValues() {
        return getPicklistValues('Contact', 'ECP_Engagement_Level__c');
    }

    /**
     * @description Retrieves Preferred Contact Method picklist values
     * @return List of picklist option maps with label and value
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getPreferredContactMethodPicklistValues() {
        return getPicklistValues('Contact', 'ECP_Preferred_Contact_Method__c');
    }

    /**
     * @description Retrieves all accounts for filter dropdown
     * @return List of account option maps with label and value
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getAccountOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();

        try {
            for (Account acc : [SELECT Id, Name FROM Account ORDER BY Name ASC LIMIT 1000]) {
                options.add(new Map<String, String>{
                    'label' => acc.Name,
                    'value' => acc.Id
                });
            }
        } catch (Exception e) {
            System.debug('Error retrieving accounts: ' + e.getMessage());
        }

        return options;
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
