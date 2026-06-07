# 🔄 Salesforce Apex Billing Sync Engine

![Salesforce](https://img.shields.io/badge/Salesforce-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)
![Apex](https://img.shields.io/badge/Apex-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)
![LWC](https://img.shields.io/badge/LWC-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

> An asynchronous OmniChannel Subscription & Billing Sync Engine built on Salesforce — capturing subscription events, syncing them to an external billing gateway, and reflecting real-time status on a custom LWC dashboard.

---

## 📌 Project Overview

This project demonstrates enterprise-grade Salesforce development patterns including bulkified Apex Triggers, asynchronous Queueable jobs, secure REST API integration via Named Credentials, and a reactive Lightning Web Component — all following Salesforce Governor Limit best practices.

---

## 🏗️ Architecture

Subscription__c Record Updated
│
▼
SubscriptionTrigger (after update)

Loops Trigger.new (bulkified)
Detects status change → 'Activated'
│
▼
BillingSyncQueueable (Queueable + AllowsCallouts)
Bulkified SOQL query
Builds JSON payload
REST callout → MockBillingGateway (Named Credential)
Updates Sync_Status__c (Synced / Failed)
│
▼
billingTracker LWC (Wire Service)
Reactively displays Sync_Status__c
Color coded status badge
No page refresh needed


---

## 🧰 Tech Stack

| Technology | Usage |
|------------|-------|
| Apex Triggers | Intercept subscription record updates |
| Queueable Apex | Async processing + HTTP callouts |
| Named Credentials | Secure external endpoint configuration |
| REST API Integration | Mock Stripe billing gateway callout |
| Lightning Web Components | Reactive UI with Wire Service |
| SOQL | Bulkified relationship queries |
| GitHub Actions | CI pipeline on every push |

---

## 📁 Project Structure
```
force-app/main/default/
├── objects/
│   └── Subscription__c/
│       ├── Subscription__c.object-meta.xml
│       └── fields/
│           ├── Status__c.field-meta.xml
│           ├── Total_Amount__c.field-meta.xml
│           └── Sync_Status__c.field-meta.xml
├── triggers/
│   ├── SubscriptionTrigger.trigger
│   └── SubscriptionTrigger.trigger-meta.xml
├── classes/
│   ├── BillingSyncQueueable.cls
│   ├── BillingSyncQueueableTest.cls
│   ├── SubscriptionTriggerTest.cls
│   └── MockBillingHttpResponse.cls
├── lwc/
│   └── billingTracker/
│       ├── billingTracker.js
│       ├── billingTracker.html
│       ├── billingTracker.css
│       └── billingTracker.js-meta.xml
├── namedCredentials/
│   └── MockBillingGateway.namedCredential-meta.xml
└── remoteSiteSettings/
└── MockBillingGateway.remoteSite-meta.xml
```
---

##  Key Technical Highlights

### 1. Bulkified Apex Trigger
- Handles up to 200 records in a single execution loop
- Uses `Trigger.oldMap` for context comparison
- Zero SOQL queries inside loops — Governor Limit compliant

### 2. Queueable Apex with Callouts
- Implements `Queueable` + `Database.AllowsCallouts`
- Chosen over `@future` for job monitoring via ID and complex data type support
- Single bulkified SOQL query outside the loop
- All DML updates batched outside the loop

### 3. Named Credentials
- No hardcoded endpoints or secrets in Apex code
- Centralized, secure credential management
- Easy to swap endpoints across environments

### 4. Reactive LWC with Wire Service
- `@wire(getRecord)` automatically re-renders UI on data change
- No manual server calls or page refreshes needed
- Dynamic CSS classes for color coded status badges

---

##  Test Coverage

| Test Class | Scenarios Covered |
|------------|------------------|
| `BillingSyncQueueableTest` | Success (200), Failure (500) callout responses |
| `SubscriptionTriggerTest` | Bulk 200 record activation, no duplicate enqueue |
| `MockBillingHttpResponse` | Mock HTTP callout for isolated unit testing |

---


##  Deploy to Salesforce

```bash
# Authenticate to your Developer Org
sf org login web --alias myDevOrg

# Deploy all metadata
sf project deploy start --source-dir force-app --target-org myDevOrg
```

---

##  Author

**Anubhav** — Salesforce Developer  
🔗 [GitHub](https://github.com/Anubhav852) | 💼 [LinkedIn](#)

---

