@isTest
private class BillingSyncQueueableTest {
    
    @testSetup
    static void setupTestData() {
        List<Subscription__c> subs = new List<Subscription__c>();
        for (Integer i = 0; i < 5; i++) {
            subs.add(new Subscription__c(
                Name            = 'Test Sub ' + i,
                Status__c       = 'Draft',
                Total_Amount__c = 100.00 * (i + 1),
                Sync_Status__c  = 'Pending'
            ));
        }
        insert subs;
    }
    
    @isTest
    static void testSuccessfulSync() {
        List<Subscription__c> subs = [SELECT Id FROM Subscription__c];
        List<Id> subIds = new List<Id>();
        for (Subscription__c sub : subs) {
            subIds.add(sub.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new MockBillingHttpResponse(200));
        
        Test.startTest();
            BillingSyncQueueable job = new BillingSyncQueueable(subIds);
            System.enqueueJob(job);
        Test.stopTest();
        
        List<Subscription__c> updatedSubs = [SELECT Sync_Status__c FROM Subscription__c];
        for (Subscription__c sub : updatedSubs) {
            System.assertEquals('Synced', sub.Sync_Status__c, 'Sync status should be Synced');
        }
    }
    
    @isTest
    static void testFailedSync() {
        List<Subscription__c> subs = [SELECT Id FROM Subscription__c];
        List<Id> subIds = new List<Id>();
        for (Subscription__c sub : subs) {
            subIds.add(sub.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new MockBillingHttpResponse(500));
        
        Test.startTest();
            BillingSyncQueueable job = new BillingSyncQueueable(subIds);
            System.enqueueJob(job);
        Test.stopTest();
        
        List<Subscription__c> updatedSubs = [SELECT Sync_Status__c FROM Subscription__c];
        for (Subscription__c sub : updatedSubs) {
            System.assertEquals('Failed', sub.Sync_Status__c, 'Sync status should be Failed');
        }
    }
}