# Chess Dashboard for Accounts

## Introduction

This project creates an interactive chess-themed dashboard for displaying Salesforce Account data. The dashboard will present account information in a visually engaging chess board layout with interactive features for searching, filtering, and viewing account details. The solution leverages Lightning Web Components for a modern, responsive user interface and displays only accounts owned by the current user.

## Requirements

### 1. Chess Dashboard for Accounts

**User Story:**
As a sales user, I want to view my accounts in an interactive chess-themed dashboard so that I can quickly access account information in an engaging and visually appealing interface.

**Acceptance Criteria:**
- Dashboard displays Account records owned by the current user in a grid layout styled like a chess board
- Accounts are sorted alphabetically by Account Name (A-Z) when the dashboard loads
- Each account card shows key information: Account Name, Type, Industry, Annual Revenue, Number of Employees, Phone, Website, and Location (City, State)
- Account cards are styled with chess board aesthetics using alternating light and dark colors (no chess piece icons)
- Users can search accounts by name using a search bar
- Users can filter accounts by Type and Industry using dropdown filters
- Dashboard is responsive and works on desktop and mobile devices
- Clicking on an account card navigates to the Account record detail page
- Dashboard shows a count of total accounts displayed
- Empty state message displays when no accounts match the search/filter criteria or when user has no accounts
- Chess-themed color scheme (black, white, gold accents) is applied consistently
- Account cards alternate colors like chess board squares (light/dark pattern)
- Dashboard includes a header with title "Chess Dashboard" and chess-themed styling
- Loading spinner displays while account data is being fetched
- Error handling displays user-friendly messages if data fails to load

### 2. Navigation and Access

**User Story:**
As a sales user, I want to easily navigate to the Chess Dashboard from the app launcher so that I can access it quickly whenever I need to view my accounts.

**Acceptance Criteria:**
- Custom tab "Chess Dashboard" is created and accessible from the app navigation bar
- Custom application "Chess App" is created and includes the Chess Dashboard tab
- Chess Dashboard tab uses a chess-themed icon
- Users with the Chess Dashboard permission set can access the tab and application
- Clicking the Chess Dashboard tab opens the chess-themed account dashboard page

### 3. Data Access and Security

**User Story:**
As a system administrator, I want to control which users can access the Chess Dashboard so that I can manage security and permissions appropriately.

**Acceptance Criteria:**
- Permission set "Chess Dashboard Access" is created
- Permission set grants read access to the Account object
- Permission set grants access to the Chess Dashboard Lightning Web Component
- Permission set grants access to the Chess Dashboard Apex controller class
- Permission set grants access to the Chess Dashboard custom tab
- Permission set grants access to the Chess App custom application
- System administrators can assign the permission set to users who need access

## Existing Salesforce Elements

### Account Object

The standard Account object will be used as the primary data source for the chess dashboard. Account records owned by the current user will be queried and displayed in the chess-themed interface, sorted alphabetically by name.

**Metadata ID:** Account

**Details:**
- Name: Account name displayed as the primary identifier on each card (used for sorting A-Z)
- Type: Account type used for filtering (Prospect, Customer, Partner, etc.)
- Industry: Industry classification used for filtering and display
- AnnualRevenue: Financial metric displayed on account cards
- NumberOfEmployees: Company size metric displayed on account cards
- Phone: Contact phone number displayed on account cards
- Website: Company website displayed as clickable link on account cards
- BillingCity: Location information displayed on account cards
- BillingState: Location information displayed on account cards
- OwnerId: Used to filter accounts owned by the current user