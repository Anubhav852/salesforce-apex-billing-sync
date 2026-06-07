trigger SubscriptionTrigger on Subscription__c (after update) {
    List<Id> targetedSubs = new List<Id>();
    
    // Loop through Trigger.new to handle bulk data uploads (bulkification pattern)
    for (Subscription__c sub : Trigger.new) {
        Subscription__c oldSub = Trigger.oldMap.get(sub.Id);
        
        // Context Check: Only sync if status changes to 'Activated'
        if (sub.Status__c == 'Activated' && oldSub.Status__c != 'Activated') {
            targetedSubs.add(sub.Id);
        }
    }
    
    // Call Queueable Apex to handle external API callout asynchronously
    if (!targetedSubs.isEmpty()) {
        System.enqueueJob(new BillingSyncQueueable(targetedSubs));
    }
}