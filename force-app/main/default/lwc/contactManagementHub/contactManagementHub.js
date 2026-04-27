import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContacts from '@salesforce/apex/ECP_ContactMgmtController.getContacts';
import getContactsGroupedByAccount from '@salesforce/apex/ECP_ContactMgmtController.getContactsGroupedByAccount';
import getContactRolePicklistValues from '@salesforce/apex/ECP_ContactMgmtController.getContactRolePicklistValues';
import getEngagementLevelPicklistValues from '@salesforce/apex/ECP_ContactMgmtController.getEngagementLevelPicklistValues';
import getPreferredContactMethodPicklistValues from '@salesforce/apex/ECP_ContactMgmtController.getPreferredContactMethodPicklistValues';
import getAccountOptions from '@salesforce/apex/ECP_ContactMgmtController.getAccountOptions';

export default class ContactManagementHub extends NavigationMixin(LightningElement) {
    @track contacts = [];
    @track accountGroups = [];
    @track isLoading = false;
    @track viewMode = 'list'; // 'list' or 'grouped'

    // Filter values
    @track roleFilter = '';
    @track engagementFilter = '';
    @track accountFilter = '';
    @track searchTerm = '';

    // Picklist options
    @track roleOptions = [];
    @track engagementOptions = [];
    @track preferredMethodOptions = [];
    @track accountOptions = [];

    connectedCallback() {
        this.loadPicklistValues();
        this.loadContacts();
    }

    loadPicklistValues() {
        Promise.all([
            getContactRolePicklistValues(),
            getEngagementLevelPicklistValues(),
            getPreferredContactMethodPicklistValues(),
            getAccountOptions()
        ])
        .then(([roleValues, engagementValues, methodValues, accountValues]) => {
            this.roleOptions = [{ label: 'All Roles', value: '' }, ...roleValues];
            this.engagementOptions = [{ label: 'All Levels', value: '' }, ...engagementValues];
            this.preferredMethodOptions = [{ label: 'All Methods', value: '' }, ...methodValues];
            this.accountOptions = [{ label: 'All Accounts', value: '' }, ...accountValues];
        })
        .catch(error => {
            this.showError('Error loading filter options', error);
        });
    }

    loadContacts() {
        this.isLoading = true;

        if (this.viewMode === 'list') {
            this.loadContactsList();
        } else {
            this.loadContactsGrouped();
        }
    }

    loadContactsList() {
        getContacts({
            roleFilter: this.roleFilter,
            engagementFilter: this.engagementFilter,
            accountFilter: this.accountFilter,
            searchTerm: this.searchTerm
        })
        .then(result => {
            this.contacts = this.processContactData(result);
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.showError('Error loading contacts', error);
        });
    }

    loadContactsGrouped() {
        getContactsGroupedByAccount({
            roleFilter: this.roleFilter,
            engagementFilter: this.engagementFilter
        })
        .then(result => {
            this.accountGroups = result.map(group => ({
                ...group,
                contacts: this.processContactData(group.contacts)
            }));
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.showError('Error loading grouped contacts', error);
        });
    }

    processContactData(contacts) {
        return contacts.map(contact => ({
            ...contact,
            formattedLastContactDate: this.formatDate(contact.lastContactDate),
            engagementBadgeClass: this.getEngagementBadgeClass(contact.engagementLevel)
        }));
    }

    // Filter handlers
    handleRoleChange(event) {
        this.roleFilter = event.detail.value;
        this.debounceLoadContacts();
    }

    handleEngagementChange(event) {
        this.engagementFilter = event.detail.value;
        this.debounceLoadContacts();
    }

    handleAccountChange(event) {
        this.accountFilter = event.detail.value;
        this.debounceLoadContacts();
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.debounceSearch();
    }

    // Debounce methods
    debounceLoadContacts() {
        clearTimeout(this.loadTimeout);
        this.loadTimeout = setTimeout(() => {
            this.loadContacts();
        }, 300);
    }

    debounceSearch() {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            this.loadContacts();
        }, 500);
    }

    // View toggle
    handleToggleView() {
        this.viewMode = this.viewMode === 'list' ? 'grouped' : 'list';
        this.loadContacts();
    }

    get viewModeLabel() {
        return this.viewMode === 'list' ? 'Group by Account' : 'List View';
    }

    get viewModeIcon() {
        return this.viewMode === 'list' ? 'utility:jump_to_top' : 'utility:list';
    }

    get isListView() {
        return this.viewMode === 'list';
    }

    get isGroupedView() {
        return this.viewMode === 'grouped';
    }

    get hasContacts() {
        return this.contacts && this.contacts.length > 0;
    }

    get hasAccountGroups() {
        return this.accountGroups && this.accountGroups.length > 0;
    }

    // Refresh handler
    handleRefresh() {
        this.loadContacts();
    }

    // Navigation and action handlers
    handleContactClick(event) {
        event.stopPropagation();
        const contactId = event.currentTarget.dataset.id;
        this.navigateToRecord(contactId);
    }

    handleEmailClick(event) {
        event.stopPropagation();
        const email = event.currentTarget.dataset.email;
        const contactId = event.currentTarget.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });

        // Also open email client
        window.location.href = `mailto:${email}`;
    }

    handleCallClick(event) {
        event.stopPropagation();
        const phone = event.currentTarget.dataset.phone;
        const contactId = event.currentTarget.dataset.id;

        // Navigate to contact record
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Call Contact',
                message: `Phone: ${phone}`,
                variant: 'info'
            })
        );
    }

    handleLinkedInClick(event) {
        event.stopPropagation();
        const url = event.currentTarget.dataset.url;

        if (url) {
            window.open(url, '_blank');
        }
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

    // Utility methods
    formatDate(dateValue) {
        if (!dateValue) return '';
        return new Date(dateValue).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    }

    getEngagementBadgeClass(engagementLevel) {
        if (!engagementLevel) return '';

        switch (engagementLevel.toLowerCase()) {
            case 'high':
                return 'slds-badge_success';
            case 'medium':
                return 'slds-badge_warning';
            case 'low':
                return 'slds-badge_error';
            default:
                return '';
        }
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
}
