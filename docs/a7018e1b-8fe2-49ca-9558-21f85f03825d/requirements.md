# Account Dashboard App - Requirements

## Introduction

This document outlines the requirements for an Account Dashboard application that provides users with comprehensive statistics and insights about accounts in the Salesforce org. The dashboard will display key metrics, visual charts, and a searchable list of accounts to enable effective account monitoring and management.

## Requirements

### 1. Data Model Setup

**User Story:**
As an administrator, I want the Account object to be extended with custom fields so that the dashboard can track and display relevant account statistics and health metrics.

**Acceptance Criteria:**
- Custom field `Account_Health_Score__c` (Number, 2 decimal places) is added to the Account object to track account health from 0-100
- Custom field `Total_Revenue__c` (Currency) is added to track total revenue associated with the account
- Custom field `Last_Activity_Date__c` (Date) is added to track the most recent activity with the account
- Custom field `Account_Tier__c` (Picklist) is added with values: Platinum, Gold, Silver, Bronze
- Custom field `Active__c` (Checkbox) is added to indicate whether the account is currently active
- All custom fields are visible and editable on the Account page layout
- A custom list view "All Active Accounts" is created to display active accounts

### 2. Interactive Dashboard Page

**User Story:**
As a sales manager, I want to view an interactive dashboard with account statistics and insights so that I can quickly understand the overall health and distribution of our accounts.

**Acceptance Criteria:**
- A Lightning Web Component named `accountDashboard` is created to display account statistics
- Dashboard displays the following key metrics in card format:
  - Total number of accounts
  - Number of active accounts
  - Average account revenue
  - Average account health score
- Dashboard includes visual charts showing:
  - Account distribution by tier (Platinum, Gold, Silver, Bronze)
  - Account distribution by industry
  - Account distribution by type (Customer, Prospect, Partner, etc.)
- Dashboard includes a searchable and filterable account list table with columns:
  - Account Name (clickable link to record)
  - Account Tier
  - Health Score
  - Total Revenue
  - Industry
  - Last Activity Date
- Search functionality filters accounts by name in real-time
- An Apex class `AccountDashboardController` is created to provide data access and calculations for the dashboard
- A Lightning App Page named `Account_Dashboard_Page` is created to host the dashboard component
- A custom tab named `Account_Dashboard` is created for easy navigation to the dashboard
- A custom application named `Account Dashboard App` is created that includes the Account Dashboard tab and the Accounts tab
- Dashboard data refreshes automatically when the page loads
- Dashboard displays appropriate messages when no account data is available