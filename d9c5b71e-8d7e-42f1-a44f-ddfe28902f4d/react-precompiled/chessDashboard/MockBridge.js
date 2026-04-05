/**
 * MockBridge - Mock data bridge for Chess Dashboard development
 *
 * This class provides mock implementations of Apex data operations for local development.
 * It simulates the bridge between React components and Salesforce Apex controllers.
 *
 * NOTE: This is a vanilla JavaScript class, NO imports or exports.
 */
class MockBridge {
    async apexQuery() {
        // Does nothing - subscribe will return the data
    }

    async apexMutate() {
        // Does nothing - it's a mock class for development
    }

    /**
     * Subscribe to data updates for a specific Apex method
     * @param {string} name - Fully qualified method name (e.g., "ClassName.methodName")
     * @param {Function} callback - Callback function that receives {data, loading, error}
     */
    subscribe(name, callback) {
        console.log(`MockBridge.subscribe called for: ${name}`);

        // Simulate initial loading state
        setTimeout(() => {
            if (name === 'ChessDashboardController.getAccounts') {
                // Mock account data
                const mockAccounts = [
                    {
                        Id: '001xx000003DGbXXXX',
                        Name: 'Acme Corporation',
                        Type: 'Customer',
                        Industry: 'Technology',
                        AnnualRevenue: 5000000,
                        NumberOfEmployees: 250,
                        Phone: '(555) 123-4567',
                        Website: 'www.acmecorp.com',
                        BillingCity: 'San Francisco',
                        BillingState: 'CA',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbYYYY',
                        Name: 'Beta Industries',
                        Type: 'Prospect',
                        Industry: 'Manufacturing',
                        AnnualRevenue: 2500000,
                        NumberOfEmployees: 125,
                        Phone: '(555) 234-5678',
                        Website: 'www.betaindustries.com',
                        BillingCity: 'New York',
                        BillingState: 'NY',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbZZZZ',
                        Name: 'Quantum Dynamics',
                        Type: 'Customer',
                        Industry: 'Technology',
                        AnnualRevenue: 8500000,
                        NumberOfEmployees: 400,
                        Phone: '(555) 345-6789',
                        Website: 'www.quantumdynamics.com',
                        BillingCity: 'Austin',
                        BillingState: 'TX',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbaAAAA',
                        Name: 'Delta Partners LLC',
                        Type: 'Partner',
                        Industry: 'Finance',
                        AnnualRevenue: 3200000,
                        NumberOfEmployees: 85,
                        Phone: '(555) 456-7890',
                        Website: 'www.deltapartners.com',
                        BillingCity: 'Boston',
                        BillingState: 'MA',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbbBBBB',
                        Name: 'Epsilon Enterprises',
                        Type: 'Customer',
                        Industry: 'Healthcare',
                        AnnualRevenue: 6700000,
                        NumberOfEmployees: 320,
                        Phone: '(555) 567-8901',
                        Website: 'www.epsilonenterprises.com',
                        BillingCity: 'Seattle',
                        BillingState: 'WA',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbcCCCC',
                        Name: 'Gamma Solutions',
                        Type: 'Prospect',
                        Industry: 'Retail',
                        AnnualRevenue: 1500000,
                        NumberOfEmployees: 65,
                        Phone: '(555) 678-9012',
                        Website: 'www.gammasolutions.com',
                        BillingCity: 'Miami',
                        BillingState: 'FL',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbdDDDD',
                        Name: 'Horizon Technologies',
                        Type: 'Customer',
                        Industry: 'Technology',
                        AnnualRevenue: 12000000,
                        NumberOfEmployees: 550,
                        Phone: '(555) 789-0123',
                        Website: 'www.horizontech.com',
                        BillingCity: 'Denver',
                        BillingState: 'CO',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbeEEEE',
                        Name: 'Innovate Labs',
                        Type: 'Partner',
                        Industry: 'Technology',
                        AnnualRevenue: 4200000,
                        NumberOfEmployees: 175,
                        Phone: '(555) 890-1234',
                        Website: 'www.innovatelabs.com',
                        BillingCity: 'Portland',
                        BillingState: 'OR',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbfFFFF',
                        Name: 'Jupiter Systems',
                        Type: 'Customer',
                        Industry: 'Manufacturing',
                        AnnualRevenue: 7800000,
                        NumberOfEmployees: 380,
                        Phone: '(555) 901-2345',
                        Website: 'www.jupitersystems.com',
                        BillingCity: 'Chicago',
                        BillingState: 'IL',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbgGGGG',
                        Name: 'Kinetic Industries',
                        Type: 'Prospect',
                        Industry: 'Energy',
                        AnnualRevenue: 5500000,
                        NumberOfEmployees: 220,
                        Phone: '(555) 012-3456',
                        Website: 'www.kineticindustries.com',
                        BillingCity: 'Houston',
                        BillingState: 'TX',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbhHHHH',
                        Name: 'Lunar Corp',
                        Type: 'Customer',
                        Industry: 'Finance',
                        AnnualRevenue: 9200000,
                        NumberOfEmployees: 425,
                        Phone: '(555) 123-4560',
                        Website: 'www.lunarcorp.com',
                        BillingCity: 'Atlanta',
                        BillingState: 'GA',
                        OwnerId: '005xx000001X8UZZZ'
                    },
                    {
                        Id: '001xx000003DGbiIIII',
                        Name: 'Meridian Group',
                        Type: 'Partner',
                        Industry: 'Consulting',
                        AnnualRevenue: 3800000,
                        NumberOfEmployees: 95,
                        Phone: '(555) 234-5670',
                        Website: 'www.meridiangroup.com',
                        BillingCity: 'Phoenix',
                        BillingState: 'AZ',
                        OwnerId: '005xx000001X8UZZZ'
                    }
                ];

                callback({
                    data: mockAccounts,
                    loading: false,
                    error: null
                });
            } else if (name === 'ChessDashboardController.getAccountTypes') {
                // Mock account type options
                const mockTypes = [
                    { label: 'All Types', value: '' },
                    { label: 'Customer', value: 'Customer' },
                    { label: 'Partner', value: 'Partner' },
                    { label: 'Prospect', value: 'Prospect' }
                ];

                callback({
                    data: mockTypes,
                    loading: false,
                    error: null
                });
            } else if (name === 'ChessDashboardController.getAccountIndustries') {
                // Mock account industry options
                const mockIndustries = [
                    { label: 'All Industries', value: '' },
                    { label: 'Consulting', value: 'Consulting' },
                    { label: 'Energy', value: 'Energy' },
                    { label: 'Finance', value: 'Finance' },
                    { label: 'Healthcare', value: 'Healthcare' },
                    { label: 'Manufacturing', value: 'Manufacturing' },
                    { label: 'Retail', value: 'Retail' },
                    { label: 'Technology', value: 'Technology' }
                ];

                callback({
                    data: mockIndustries,
                    loading: false,
                    error: null
                });
            } else {
                // Unknown method
                callback({
                    data: null,
                    loading: false,
                    error: `Unknown method: ${name}`
                });
            }
        }, 500); // Simulate network delay
    }

    /**
     * Mock emit function for navigation events
     * @param {string} type - Event type
     * @param {Object} detail - Event details
     */
    emit(type, detail) {
        console.log(`MockBridge.emit called:`, type, detail);
        // In a real environment, this would trigger Salesforce navigation
        // For development, just log the navigation intent
        if (type === 'navigate') {
            console.log(`Would navigate to record: ${detail.attributes.recordId}`);
        }
    }
}
