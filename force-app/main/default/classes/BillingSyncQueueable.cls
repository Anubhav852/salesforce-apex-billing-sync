public class BillingSyncQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> subscriptionIds;
    
    // Constructor accepts list of Ids from the trigger
    public BillingSyncQueueable(List<Id> ids) {
        this.subscriptionIds = ids;
    }
    
    public void execute(QueueableContext context) {
        // Bulkified relationship query - no SOQL inside loop
        List<Subscription__c> subs = [
            SELECT Id, Name, Total_Amount__c, Account__r.Name 
            FROM Subscription__c 
            WHERE Id IN :subscriptionIds
        ];
        
        List<Subscription__c> subsToUpdate = new List<Subscription__c>();
        
        for (Subscription__c sub : subs) {
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                
                // Using Named Credentials for secure endpoint config
                request.setEndpoint('callout:MockBillingGateway/v1/charges');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                
                // Build JSON payload
                String jsonBody = JSON.serialize(new Map<String, Object>{
                    'subId'    => sub.Id,
                    'customer' => sub.Account__r.Name,
                    'amount'   => sub.Total_Amount__c
                });
                request.setBody(jsonBody);
                
                HttpResponse response = http.send(request);
                
                // Handle response and update Sync_Status__c accordingly
                Subscription__c subToUpdate = new Subscription__c(Id = sub.Id);
                
                if (response.getStatusCode() == 200) {
                    subToUpdate.Sync_Status__c = 'Synced';
                } else {
                    subToUpdate.Sync_Status__c = 'Failed';
                }
                
                subsToUpdate.add(subToUpdate);
                
            } catch (Exception e) {
                // Log error and mark as Failed
                System.debug('BillingSyncQueueable Error: ' + e.getMessage());
                subsToUpdate.add(new Subscription__c(
                    Id = sub.Id,
                    Sync_Status__c = 'Failed'
                ));
            }
        }
        
        // Bulk update all records at once - outside the loop
        if (!subsToUpdate.isEmpty()) {
            update subsToUpdate;
        }
    }
}