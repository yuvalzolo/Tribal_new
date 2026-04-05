/**
 * ChessDashboardController
 *
 * Controller class for Chess Dashboard that queries Account records owned by the current user,
 * sorted by Name (A-Z), and returns account data including Name, Type, Industry, Annual Revenue,
 * Number of Employees, Phone, Website, and Location fields.
 */
public with sharing class ChessDashboardController {

    /**
     * Retrieves all Account records owned by the current user, sorted alphabetically by Name
     *
     * @return List of Account records with key fields populated
     */
    @AuraEnabled(cacheable=false)
    public static List<Account> getAccounts() {
        try {
            return [
                SELECT Id, Name, Type, Industry, AnnualRevenue,
                       NumberOfEmployees, Phone, Website,
                       BillingCity, BillingState, OwnerId
                FROM Account
                WHERE OwnerId = :UserInfo.getUserId()
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving accounts: ' + e.getMessage());
        }
    }

    /**
     * Retrieves distinct Type picklist values from Account records owned by the current user
     *
     * @return List of maps containing label and value for each Type
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getAccountTypes() {
        try {
            List<Map<String, String>> options = new List<Map<String, String>>();

            // Add "All Types" option
            options.add(new Map<String, String>{
                'label' => 'All Types',
                'value' => ''
            });

            // Get distinct Type values from user's accounts
            List<AggregateResult> typeResults = [
                SELECT Type
                FROM Account
                WHERE OwnerId = :UserInfo.getUserId()
                AND Type != null
                GROUP BY Type
                ORDER BY Type ASC
            ];

            for (AggregateResult ar : typeResults) {
                String typeValue = (String)ar.get('Type');
                if (String.isNotBlank(typeValue)) {
                    options.add(new Map<String, String>{
                        'label' => typeValue,
                        'value' => typeValue
                    });
                }
            }

            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving account types: ' + e.getMessage());
        }
    }

    /**
     * Retrieves distinct Industry picklist values from Account records owned by the current user
     *
     * @return List of maps containing label and value for each Industry
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getAccountIndustries() {
        try {
            List<Map<String, String>> options = new List<Map<String, String>>();

            // Add "All Industries" option
            options.add(new Map<String, String>{
                'label' => 'All Industries',
                'value' => ''
            });

            // Get distinct Industry values from user's accounts
            List<AggregateResult> industryResults = [
                SELECT Industry
                FROM Account
                WHERE OwnerId = :UserInfo.getUserId()
                AND Industry != null
                GROUP BY Industry
                ORDER BY Industry ASC
            ];

            for (AggregateResult ar : industryResults) {
                String industryValue = (String)ar.get('Industry');
                if (String.isNotBlank(industryValue)) {
                    options.add(new Map<String, String>{
                        'label' => industryValue,
                        'value' => industryValue
                    });
                }
            }

            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving account industries: ' + e.getMessage());
        }
    }
}
