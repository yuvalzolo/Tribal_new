import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccounts from '@salesforce/apex/ECP_AccountOpptyController.getAccounts';
import getOpportunities from '@salesforce/apex/ECP_AccountOpptyController.getOpportunities';
import getDashboardSummary from '@salesforce/apex/ECP_AccountOpptyController.getDashboardSummary';
import getAccountTierPicklistValues from '@salesforce/apex/ECP_AccountOpptyController.getAccountTierPicklistValues';
import getPrimaryIndustryPicklistValues from '@salesforce/apex/ECP_AccountOpptyController.getPrimaryIndustryPicklistValues';
import getDealPriorityPicklistValues from '@salesforce/apex/ECP_AccountOpptyController.getDealPriorityPicklistValues';
import getOpportunityStagePicklistValues from '@salesforce/apex/ECP_AccountOpptyController.getOpportunityStagePicklistValues';

export default class AccountOpportunityDashboard extends NavigationMixin(LightningElement) {
    @track accounts = [];
    @track opportunities = [];
    @track summary = {};
    @track isLoading = false;
    @track activeTab = 'accounts';

    // Filter values
    @track accountTierFilter = 'All';
    @track accountIndustryFilter = 'All';
    @track accountSearchTerm = '';
    @track opportunityStageFilter = 'All';
    @track opportunityPriorityFilter = 'All';
    @track opportunityCloseDateFilter = 'All';
    @track opportunitySearchTerm = '';

    // Picklist options
    @track accountTierOptions = [];
    @track industryOptions = [];
    @track dealPriorityOptions = [];
    @track stageOptions = [];
    @track closeDateOptions = [
        { label: 'All', value: 'All' },
        { label: 'This Month', value: 'This Month' },
        { label: 'This Quarter', value: 'This Quarter' },
        { label: 'This Year', value: 'This Year' },
        { label: 'Next 30 Days', value: 'Next 30 Days' }
    ];

    connectedCallback() {
        this.loadPicklistValues();
        this.loadDashboardData();
    }

    loadPicklistValues() {
        Promise.all([
            getAccountTierPicklistValues(),
            getPrimaryIndustryPicklistValues(),
            getDealPriorityPicklistValues(),
            getOpportunityStagePicklistValues()
        ])
        .then(([tierValues, industryValues, priorityValues, stageValues]) => {
            this.accountTierOptions = [{ label: 'All', value: 'All' }, ...tierValues];
            this.industryOptions = [{ label: 'All', value: 'All' }, ...industryValues];
            this.dealPriorityOptions = [{ label: 'All', value: 'All' }, ...priorityValues];
            this.stageOptions = [{ label: 'All', value: 'All' }, ...stageValues];
        })
        .catch(error => {
            this.showError('Error loading picklist values', error);
        });
    }

    loadDashboardData() {
        this.isLoading = true;
        Promise.all([
            this.loadAccounts(),
            this.loadOpportunities(),
            this.loadSummary()
        ])
        .then(() => {
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.showError('Error loading dashboard data', error);
        });
    }

    loadAccounts() {
        return getAccounts({
            tierFilter: this.accountTierFilter,
            industryFilter: this.accountIndustryFilter,
            searchTerm: this.accountSearchTerm
        })
        .then(result => {
            this.accounts = result.map(account => ({
                ...account,
                formattedAnnualContractValue: this.formatCurrency(account.annualContractValue),
                formattedLastEngagementDate: this.formatDate(account.lastEngagementDate)
            }));
        });
    }

    loadOpportunities() {
        return getOpportunities({
            stageFilter: this.opportunityStageFilter,
            priorityFilter: this.opportunityPriorityFilter,
            closeDateFilter: this.opportunityCloseDateFilter,
            searchTerm: this.opportunitySearchTerm
        })
        .then(result => {
            this.opportunities = result.map(opp => ({
                ...opp,
                formattedAmount: this.formatCurrency(opp.amount),
                formattedCloseDate: this.formatDate(opp.closeDate),
                formattedWinProbability: this.formatPercent(opp.winProbability)
            }));
        });
    }

    loadSummary() {
        return getDashboardSummary()
        .then(result => {
            this.summary = result;
        });
    }

    // Tab handling
    handleTabChange(event) {
        this.activeTab = event.target.value;
    }

    get isAccountsTab() {
        return this.activeTab === 'accounts';
    }

    get isOpportunitiesTab() {
        return this.activeTab === 'opportunities';
    }

    // Account filter handlers
    handleAccountTierChange(event) {
        this.accountTierFilter = event.detail.value;
        this.loadAccounts();
    }

    handleAccountIndustryChange(event) {
        this.accountIndustryFilter = event.detail.value;
        this.loadAccounts();
    }

    handleAccountSearch(event) {
        this.accountSearchTerm = event.target.value;
        this.debounceSearch('account');
    }

    // Opportunity filter handlers
    handleOpportunityStageChange(event) {
        this.opportunityStageFilter = event.detail.value;
        this.loadOpportunities();
    }

    handleOpportunityPriorityChange(event) {
        this.opportunityPriorityFilter = event.detail.value;
        this.loadOpportunities();
    }

    handleOpportunityCloseDateChange(event) {
        this.opportunityCloseDateFilter = event.detail.value;
        this.loadOpportunities();
    }

    handleOpportunitySearch(event) {
        this.opportunitySearchTerm = event.target.value;
        this.debounceSearch('opportunity');
    }

    // Debounce search
    debounceSearch(type) {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            if (type === 'account') {
                this.loadAccounts();
            } else {
                this.loadOpportunities();
            }
        }, 500);
    }

    // Navigation handlers
    handleAccountClick(event) {
        const accountId = event.currentTarget.dataset.id;
        this.navigateToRecord(accountId);
    }

    handleOpportunityClick(event) {
        const opportunityId = event.currentTarget.dataset.id;
        this.navigateToRecord(opportunityId);
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    // Refresh handler
    handleRefresh() {
        this.loadDashboardData();
    }

    // Utility methods
    formatCurrency(value) {
        if (value == null) return '$0.00';
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(value);
    }

    formatDate(dateValue) {
        if (!dateValue) return '';
        return new Date(dateValue).toLocaleDateString('en-US');
    }

    formatPercent(value) {
        if (value == null) return '0%';
        return value + '%';
    }

    showError(title, error) {
        const errorMessage = error.body?.message || error.message || 'Unknown error';
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: errorMessage,
                variant: 'error'
            })
        );
    }

    // Computed properties for summary display
    get formattedTotalAccounts() {
        return this.summary.totalAccounts || 0;
    }

    get formattedTotalOpportunities() {
        return this.summary.totalOpportunities || 0;
    }

    get formattedTotalPipeline() {
        return this.formatCurrency(this.summary.totalPipelineValue);
    }

    get formattedAverageWinRate() {
        return this.formatPercent(this.summary.winRate);
    }

    get hasAccounts() {
        return this.accounts && this.accounts.length > 0;
    }

    get hasOpportunities() {
        return this.opportunities && this.opportunities.length > 0;
    }
}
