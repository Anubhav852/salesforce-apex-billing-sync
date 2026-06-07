public class BillingSyncQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> subscriptionIds;
    
    public BillingSyncQueueable(List<Id> ids) {
        this.subscriptionIds = ids;
    }
    
    public void execute(QueueableContext context) {
        // Bulkified query - no Account relationship to avoid missing field error
        List<Subscription__c> subs = [
            SELECT Id, Name, Total_Amount__c
            FROM Subscription__c 
            WHERE Id IN :subscriptionIds
        ];
        
        List<Subscription__c> subsToUpdate = new List<Subscription__c>();
        
        for (Subscription__c sub : subs) {
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:MockBillingGateway/v1/charges');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                
                String jsonBody = JSON.serialize(new Map<String, Object>{
                    'subId'  => sub.Id,
                    'name'   => sub.Name,
                    'amount' => sub.Total_Amount__c
                });
                request.setBody(jsonBody);
                
                HttpResponse response = http.send(request);
                
                Subscription__c subToUpdate = new Subscription__c(Id = sub.Id);
                if (response.getStatusCode() == 200) {
                    subToUpdate.Sync_Status__c = 'Synced';
                } else {
                    subToUpdate.Sync_Status__c = 'Failed';
                }
                subsToUpdate.add(subToUpdate);
                
            } catch (Exception e) {
                System.debug('BillingSyncQueueable Error: ' + e.getMessage());
                subsToUpdate.add(new Subscription__c(
                    Id = sub.Id,
                    Sync_Status__c = 'Failed'
                ));
            }
        }
        
        if (!subsToUpdate.isEmpty()) {
            update subsToUpdate;
        }
    }
}