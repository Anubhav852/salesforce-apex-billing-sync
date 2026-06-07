import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Subscription__c.Sync_Status__c';
import NAME_FIELD from '@salesforce/schema/Subscription__c.Name';
import AMOUNT_FIELD from '@salesforce/schema/Subscription__c.Total_Amount__c';

export default class BillingTracker extends LightningElement {
    @api recordId;

    // Wire service - automatically reactive, updates UI when data changes
    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD, NAME_FIELD, AMOUNT_FIELD] })
    subscription;

    get syncStatus() {
        return getFieldValue(this.subscription.data, STATUS_FIELD);
    }

    get subscriptionName() {
        return getFieldValue(this.subscription.data, NAME_FIELD);
    }

    get totalAmount() {
        return getFieldValue(this.subscription.data, AMOUNT_FIELD);
    }

    get isLoading() {
        return !this.subscription.data && !this.subscription.error;
    }

    get statusClass() {
        const status = this.syncStatus;
        if (status === 'Synced') return 'status-badge synced';
        if (status === 'Failed') return 'status-badge failed';
        return 'status-badge pending';
    }

    get statusIcon() {
        const status = this.syncStatus;
        if (status === 'Synced') return '✅';
        if (status === 'Failed') return '❌';
        return '⏳';
    }
}