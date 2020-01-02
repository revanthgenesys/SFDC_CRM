/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
global without sharing class CreateLoginQueueWorker implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    private static string CREATE_EXC_FROM_QUEUE_ERR_MSG = 'Create Login Process failed while Processing the Contacts in the Create Login Queue with Message: {0} and Stack trace: {1}';
    global final String query;
    
    global CreateLoginQueueWorker(String q) {
       query = q;
     }
    
  global Database.QueryLocator start(Database.BatchableContext bc)
    {
        // Search for queue entries at least 10 minutes old.  These link to contacts which should have sync'd by now.
        Datetime now = DateTime.now();
        Datetime batachableTime =  now.addMinutes(-5);
        system.debug('Batachable time in CreateLoginQueueWorker: ' + batachableTime);
        system.debug('Query in CreateLoginQueueWorker: ' + query);
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> queueEntries)
    {
        // This batch should be scheduled to only do four contacts at a time to avoid 
        // hitting gov limits. (120 seconds for all web service calls.) - Default Timeout for each Callout is 10 secs (Ex: Can increase/decrease by setting timeout_x = 30000; for 30 secs)
        // See http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_callouts_timeouts.htm

        string Response;        
        // Get contact IDs
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
                
        try
        {   
            system.debug('Entries Queued for Execution in CreateLoginQueueWorker: ' + queueEntries);
            for (sObject queueEntry : queueEntries)
            {
                CreateLoginQueue__c typedQueueEntry = (CreateLoginQueue__c) queueEntry;
                contactMap.put(typedQueueEntry.ContactId__c, null);                                    
            }
            
            // Get contact instances
            for (Contact con : [
                SELECT LastName, FirstName, Phone, MobilePhone, Email, Title, Ldap_Contact_Permissions__c, Portal_Permission__c, Has_Ldap_Login__c, AccountId, Contact_ID__c, Account.External_Source__c, Account.Pricesheet_Permission__c 
                FROM Contact 
                WHERE Id IN :contactMap.keySet()])
            {
                contactMap.put(con.Id, con);
            }
            system.debug('Contacts that will be Processed from the current Batch (from contactMap): ' + contactMap);
            
            // Process each of the queue entries
            for (sObject queueEntry : queueEntries)
            {
                CreateLoginQueue__c typedQueueEntry = (CreateLoginQueue__c) queueEntry;
                Contact con = contactMap.get(typedQueueEntry.ContactId__c);
                
                if (con.Has_LDAP_Login__c)
                {
                    typedQueueEntry.Result__c = 'Login was already created.'; 
                    typedQueueEntry.IsProcessed__c = true;
                    system.debug('Contact login was already created: ' + queueEntry);
                }
                /* Ignoring Contact_ID (BCF ID) per request INC0285608 since it is not needed for ISupport in merged instance.  
                else if (String.IsBlank(con.Contact_ID__c))
                {
                    typedQueueEntry.Result__c = 'Cannot create login because BCF ID is not present.';
                    system.debug('Contact login not created because BCF ID is not present: ' + queueEntry);
                } */
                else
                {
                    //Utilizes the CreateLogin method from the ContactAPIMethods class to Create the Login                    
                    ContactAPIMethods servicesContact = new ContactAPIMethods(con, null);
                    Response = servicesContact.CreateLogin();    
                    system.debug('Contact ' + con.Contact_ID__c + ' was processed by the Callout with the following response from the PublicAPI Webservice: ' + Response); 
                    integer lastIndex = Response.length() - 1;
                    system.debug('Response Received: ' + Response.substring(0, lastIndex));
                    typedQueueEntry.Result__c = Response.substring(0, lastIndex);                    
                    con.Ldap_Pricesheet_Permissions__c = con.Account.Pricesheet_Permission__c;
                    if(Response.startsWith('Error'))
                    {
                        typedQueueEntry.IsError__c = true;
                        typedQueueEntry.IsProcessed__c = false;
                        system.debug('Create Login Response: ' + Response);
                    }
                    else
                    {
                      con.Has_LDAP_Login__c = true;
                      typedQueueEntry.IsProcessed__c = true;
                      con.Status__c = 'Active';
                    }
                }            
            }           
        }
        catch(Exception e)
        {
            throw new ApplicationException(String.format(CREATE_EXC_FROM_QUEUE_ERR_MSG, new string[] { e.getMessage(), e.getStackTraceString() }));
        }
        update queueEntries;
        system.Debug('Updated the QueueEntries: ' + queueEntries);
        update contactMap.values();
        system.debug('Updated Contact fields');
        system.Debug('List of all Updated Contacts by the Batch Job: ' + ContactMap);
    }
    
    global void finish(Database.BatchableContext bc)
    {
        // No finalization action needed.
    }
}