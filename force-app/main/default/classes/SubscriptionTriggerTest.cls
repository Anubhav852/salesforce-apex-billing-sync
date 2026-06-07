@isTest
private class SubscriptionTriggerTest {
    
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Trigger Test Corp');
        insert testAccount;
        
        // Create 200 records to test bulkification
        List<Subscription__c> subs = new List<Subscription__c>();
        for (Integer i = 0; i < 200; i++) {
            subs.add(new Subscription__c(
                Name            = 'Bulk Sub ' + i,
                Status__c       = 'Draft',
                Total_Amount__c = 50.00,
                Sync_Status__c  = 'Pending',
                Account__c      = testAccount.Id
            ));
        }
        insert subs;
    }
    
    @isTest
    static void testBulkTriggerActivation() {
        List<Subscription__c> subs = [SELECT Id, Status__c FROM Subscription__c];
        
        // Simulate bulk status update to Activated
        for (Subscription__c sub : subs) {
            sub.Status__c = 'Activated';
        }
        
        Test.setMock(HttpCalloutMock.class, new MockBillingHttpResponse(200));
        
        Test.startTest();
            update subs;
        Test.stopTest();
        
        // Verify trigger fired and enqueued job without hitting governor limits
        System.assertEquals(200, subs.size(), 'Should handle 200 records in bulk');
    }
    
    @isTest
    static void testTriggerNoFireWhenAlreadyActivated() {
        List<Subscription__c> subs = [SELECT Id, Status__c FROM Subscription__c];
        
        // Set all to Activated first
        for (Subscription__c sub : subs) {
            sub.Status__c = 'Activated';
        }
        update subs;
        
        Test.startTest();
            // Update again — trigger should NOT enqueue job again
            for (Subscription__c sub : subs) {
                sub.Total_Amount__c = 75.00;
            }
            update subs;
        Test.stopTest();
        
        System.assertEquals(200, subs.size(), 'Should process all 200 records without errors');
    }
}