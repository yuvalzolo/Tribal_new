import { LightningElement, track } from 'lwc';
import getDashboardStats from '@salesforce/apex/ADA_AccountDashboardCtrl.getDashboardStats';
import getTierDistribution from '@salesforce/apex/ADA_AccountDashboardCtrl.getTierDistribution';
import getIndustryDistribution from '@salesforce/apex/ADA_AccountDashboardCtrl.getIndustryDistribution';
import getTypeDistribution from '@salesforce/apex/ADA_AccountDashboardCtrl.getTypeDistribution';
import getAccounts from '@salesforce/apex/ADA_AccountDashboardCtrl.getAccounts';

export default class AdaAccountDashboard extends LightningElement {
    @track isLoading = true;
    @track errorMessage = '';
    @track searchTerm = '';

    // Dashboard stats
    @track totalAccounts = 0;
    @track activeAccounts = 0;
    @track averageRevenue = 0;
    @track averageHealthScore = 0;

    // Distribution data
    @track tierDistribution = [];
    @track industryDistribution = [];
    @track typeDistribution = [];

    // Accounts data
    @track accounts = [];
    @track filteredAccounts = [];

    /**
     * Lifecycle hook - called when component is inserted into DOM
     */
    connectedCallback() {
        this.loadDashboardData();
    }

    /**
     * Load all dashboard data
     */
    async loadDashboardData() {
        this.isLoading = true;
        this.errorMessage = '';

        try {
            // Load all data in parallel for better performance
            const [stats, tierDist, industryDist, typeDist, accountsList] = await Promise.all([
                getDashboardStats(),
                getTierDistribution(),
                getIndustryDistribution(),
                getTypeDistribution(),
                getAccounts({ searchTerm: '' })
            ]);

            // Process dashboard stats
            this.totalAccounts = stats.totalAccounts || 0;
            this.activeAccounts = stats.activeAccounts || 0;
            this.averageRevenue = stats.averageRevenue || 0;
            this.averageHealthScore = stats.averageHealthScore || 0;

            // Process distribution data with bar widths
            this.tierDistribution = this.processDistributionData(tierDist);
            this.industryDistribution = this.processDistributionData(industryDist);
            this.typeDistribution = this.processDistributionData(typeDist);

            // Process accounts data
            this.accounts = this.processAccountsData(accountsList);
            this.filteredAccounts = [...this.accounts];

        } catch (error) {
            this.errorMessage = 'Error loading dashboard data: ' + this.reduceErrors(error).join(', ');
            console.error('Dashboard load error:', error);
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * Process distribution data to add bar widths for charts
     */
    processDistributionData(data) {
        if (!data || data.length === 0) {
            return null;
        }

        const maxCount = Math.max(...data.map(item => item.count));

        return data.map(item => ({
            ...item,
            barWidth: `width: ${maxCount > 0 ? (item.count / maxCount * 100) : 0}%`
        }));
    }

    /**
     * Process accounts data to add formatted values and URLs
     */
    processAccountsData(accounts) {
        if (!accounts || accounts.length === 0) {
            return [];
        }

        return accounts.map(account => ({
            ...account,
            recordUrl: `/${account.id}`,
            formattedHealthScore: account.healthScore ? account.healthScore.toFixed(2) : '-',
            formattedRevenue: account.totalRevenue ? this.formatCurrency(account.totalRevenue) : '-',
            formattedActivityDate: account.lastActivityDate ? this.formatDate(account.lastActivityDate) : '-',
            statusLabel: account.isActive ? 'Active' : 'Inactive',
            statusClass: account.isActive ? 'slds-theme_success' : 'slds-theme_warning'
        }));
    }

    /**
     * Handle search input change
     */
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.filterAccounts();
    }

    /**
     * Filter accounts based on search term
     */
    filterAccounts() {
        if (!this.searchTerm || this.searchTerm.trim() === '') {
            this.filteredAccounts = [...this.accounts];
        } else {
            const searchLower = this.searchTerm.toLowerCase();
            this.filteredAccounts = this.accounts.filter(account =>
                account.name && account.name.toLowerCase().includes(searchLower)
            );
        }
    }

    /**
     * Format currency value
     */
    formatCurrency(value) {
        if (value === null || value === undefined) {
            return '-';
        }
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(value);
    }

    /**
     * Format date value
     */
    formatDate(dateValue) {
        if (!dateValue) {
            return '-';
        }
        try {
            const date = new Date(dateValue);
            return new Intl.DateTimeFormat('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric'
            }).format(date);
        } catch (e) {
            return dateValue;
        }
    }

    /**
     * Reduce errors to array of messages
     */
    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }

        return (
            errors
                .filter(error => !!error)
                .map(error => {
                    if (Array.isArray(error.body)) {
                        return error.body.map(e => e.message);
                    } else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    } else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    return 'Unknown error';
                })
                .reduce((prev, curr) => prev.concat(curr), [])
                .filter(message => !!message)
        );
    }

    /**
     * Getter for formatted average revenue
     */
    get formattedAverageRevenue() {
        return this.formatCurrency(this.averageRevenue);
    }

    /**
     * Getter for formatted average health score
     */
    get formattedAverageHealthScore() {
        return this.averageHealthScore ? this.averageHealthScore.toFixed(2) : '0.00';
    }

    /**
     * Getter to check if there are accounts to display
     */
    get hasAccounts() {
        return this.filteredAccounts && this.filteredAccounts.length > 0;
    }
}
