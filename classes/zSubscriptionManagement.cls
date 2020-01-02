public class zSubscriptionManagement {
    
    public static void afterInsert(List<Zuora__Subscription__c> newSubscriptions)
    {
        zSubscriptionManagement.checkForRemovedProduct(newSubscriptions);
    }
    
    private static void checkForRemovedProduct(List<Zuora__Subscription__c> newSubscriptions)
    {
        List<zqu__QuoteRatePlan__c> plansToUpdate = new List<zqu__QuoteRatePlan__c>();
        Map<String, Zuora__Subscription__c> subNameMap = new Map<String, Zuora__Subscription__c>();
        Map<String, Account> subAcctMap = new Map<String, Account>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> acctIds = new Set<Id>();
        // Create Map of Subscription Name to Subscription
        for(Zuora__Subscription__c s : newSubscriptions)
        {
            acctIds.add(s.Zuora__Account__c);
            if(s.Zuora__OriginalCreated_Date__C != null && s.Zuora__OriginalCreated_Date__c != s.createdDate)
            {
                subNameMap.put(s.Name, s);
            }            
        }

        Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, Name, PureCloud_OrgID__c, (SELECT Org_Id__c FROM PureCloud_Organizations__r) FROM Account WHERE Id IN :acctIds]);

        for(Zuora__Subscription__c s : newSubscriptions)
        {
            if(acctMap.get(s.Zuora__Account__c) != null)
            {
                subAcctMap.put(s.Name, acctMap.get(s.Zuora__Account__c));
            }
        }
        String subName = '';
        // Loop Through Quotes and Find All Removed Rate Plans from the Subscriptions passed in
        for(zqu__Quote__c quote : [SELECT Id, Name, zqu__Subscription_Name__c, 
                                    (SELECT Id, Name, Send_Email__c, zqu__QuoteProductName__c FROM zqu__Quote_Rate_Plans__r WHERE zqu__AmendmentType__c = 'RemoveProduct' AND Send_Email__c = true)
                                    FROM zqu__Quote__c 
                                    WHERE zqu__SubscriptionType__c = 'Amend Subscription' AND zqu__Status__c = 'Sent to Z-Billing' AND zqu__Subscription_Name__c IN :subNameMap.keySet() 
                                    ORDER BY zqu__SubscriptionVersion__c DESC])
        {
            if(quote.zqu__Subscription_Name__c == subName) continue;
            subName = quote.zqu__Subscription_Name__c;
            String itemsRemoved = '';
            List<zqu__QuoteRatePlan__c> quoteRatePlans = quote.zqu__Quote_Rate_Plans__r;
            if(quoteRatePlans.isEmpty()) continue;
            
            // List each product removed
            for (zqu__QuoteRatePlan__c quoteRatePlan : quoteRatePlans)
            {
                system.debug(quoteRatePlan.zqu__QuoteProductName__c);
                itemsRemoved += '<li>' + quoteRatePlan.zqu__QuoteProductName__c;
                
                // Remove flag
                quoteRatePlan.Send_Email__c = false;
                plansToUpdate.add(quoteRatePlan);
            }

            if(String.isNotEmpty(itemsRemoved) 
                && subNameMap.get(quote.zqu__Subscription_Name__c) != null
                && subAcctMap.get(quote.zqu__Subscription_Name__c) != null)
            {
                mails.add(createRemovedProductEmail(subNameMap.get(quote.zqu__Subscription_Name__c),
                                                    itemsRemoved,
                                                    subAcctMap.get(quote.zqu__Subscription_Name__c)));
            }

        }

        // Send email(s)
        if(!Test.isRunningTest())
        {
            Messaging.sendEmail(mails);
        }
        // Update Quote Rate Plans
        update plansToUpdate;
    }
    
    public static Messaging.SingleEmailMessage createRemovedProductEmail(Zuora__Subscription__c subscription, string removedProduct, Account account)
    {
        //Account account = [SELECT Name, PureCloud_OrgID__c, (SELECT Org_Id__c FROM PureCloud_Organizations__r LIMIT 1) FROM Account WHERE Id = :subscription.Zuora__Account__c];
        String PCOrgId = '';
        List<PureCloud_Organization__c> pcOrgs = account.PureCloud_Organizations__r;
        // Check for PC Org Id
        if (!pcOrgs.isEmpty())
        {
            for(PureCloud_Organization__c pcOrg : pcOrgs)
            {
                PCOrgId += (pcOrg.Org_Id__c + ' ');
            }            
        }
        else
        {
            PCOrgId = Account.PureCloud_OrgID__c;
        }
        
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setOrgWideEmailAddressId(General_Custom_Settings__c.GetValues('NoReplyOrgWideEmailId').Value__c);
        email.setToAddresses(new string[] {Zuora_Custom_Settings__c.GetValues('PureCloudProductRemoval_EmailId').Value__c});
        email.saveAsActivity = false;
        email.setSubject(account.Name + ' Product Removal Approved');
        email.setHtmlBody('<b>Account:</b> ' + account.Name
                          + '<br>' + '<b>PC Org Id:</b> ' + PCOrgId
                          + '<br><br>' + 'Removed licenses:' 
                          + '<ul>'
                          + removedProduct
                          + '</ul>');
        
        return email;
    }
    
    public static void afterUpdate(List<Zuora__Subscription__c> newSubscriptions, List<Zuora__Subscription__c> oldSubscriptions)
    {
        
        if (newSubscriptions.Size() > 1)
        {
            
            Map<Id, Zuora__Subscription__c> oldSubscriptionMap = new Map<Id, Zuora__Subscription__c>(oldSubscriptions);
            
            for (Zuora__Subscription__c newSubscription : newSubscriptions) 
            {
                Zuora__Subscription__c oldSubscription = oldSubscriptionMap.get(newSubscription.Id);
                
                SyncSubscriptionToZuora(newSubscription, oldSubscription);
            }
            
        }
        else if (newSubscriptions.Size() == 1)
        {
            
            SyncSubscriptionToZuora(newSubscriptions[0], oldSubscriptions[0]);
            
        }
        
        
    }
    
    //
    //    This syncs changes in the following fields from the Salesforce Zuora__Subscription__c object to the Zuora Subscription object:
    //    - PureCloud_Monthly_Minimum__c
    //    - PureCloud_Ramp_Up_Period__c
    //    
    private static void SyncSubscriptionToZuora(Zuora__Subscription__c newSubscription, Zuora__Subscription__c oldSubscription)
    {
        
        if ((newSubscription.PureCloud_Monthly_Minimum__c != oldSubscription.PureCloud_Monthly_Minimum__c) ||
            (newSubscription.PureCloud_Ramp_Up_Period__c != oldSubscription.PureCloud_Ramp_Up_Period__c)  )
        {
            UpdateFieldsInZuora(newSubscription.Id);
        }
        
    }
    
    //
    //    This only updates the following fields the Zuora Subscription object:
    //    - PureCloud_Monthly_Minimum__c
    //    - PureCloud_Ramp_Up_Period__c
    //    
    @future(callout=true)
    private static void UpdateFieldsInZuora(string subscriptionId)
    {
        //ININDebugLog logger = new ININDebugLog();
        Time now = DateTime.now().time();
        
        // This method makes calls to the Zuora API.  We don't want to do that if we are running in a test
            
        Zuora__Subscription__c sfSubscription = [SELECT Id, Zuora__Zuora_Id__c, PureCloud_Monthly_Minimum__c, PureCloud_Ramp_Up_Period__c FROM Zuora__Subscription__c WHERE Id = :subscriptionId LIMIT 1];
        
        Zuora.zApi zuora = new Zuora.zApi();
        if (!Test.isRunningTest()) {
            
            try {
                Zuora.zApi.LoginResult loginResult = zuora.zlogin();
            } 
            catch (Exception ex) {
                //logger.AddToQueue('ZuoraSubscriptionTriggerHandler.SyncChangesToZuora', 'Login Error: ' + ex.getMessage());
                System.debug('Login Error: ' + ex.getMessage());
            }
            
            try {
                String zoql = 'SELECT Id, PureCloud_Monthly_Minimum__c, PureCloud_Ramp_Up_Period__c FROM Subscription WHERE Id = \'' + sfSubscription.Zuora__Zuora_Id__c + '\'';
                List<Zuora.zObject> zObjects = zuora.zquery(zoql);
                
                if (zObjects.size() != 1)
                {
                    //logger.AddToQueue('ZuoraSubscriptionTriggerHandler.SyncChangesToZuora', 'Query Error: Expected 1 subscription record found ' + zObjects.size().format());
                    System.debug('Query Error: Expected 1 subscription record found ' + zObjects.size().format());
                }
                else
                {
                    String monthlyMinimum = (String)zObjects[0].getValue('PureCloud_Monthly_Minimum__c');
                    String rampUp = (String)zObjects[0].getValue('PureCloud_Ramp_Up_Period__c');
                    
                    zObjects[0].setValue('PureCloud_Monthly_Minimum__c', sfSubscription.PureCloud_Monthly_Minimum__c);
                    zObjects[0].setValue('PureCloud_Ramp_Up_Period__c', sfSubscription.PureCloud_Ramp_Up_Period__c);
                    
                    List<Zuora.zApi.SaveResult> saveResults = zuora.zupdate(zObjects);
                    if (saveResults.size() != 1)
                    {
                        //logger.AddToQueue('ZuoraSubscriptionTriggerHandler.SyncChangesToZuora', 'Update Error: Expected 1 save result record found ' + saveResults.size().format());
                        System.debug('Update Error: Expected 1 save result record found ' + saveResults.size().format());
                    }
                    else
                    {
                        if (!saveResults[0].Success)
                        {
                            for (Zuora.zObject error : saveResults[0].Errors)                        
                            {
                                //logger.AddToQueue('ZuoraSubscriptionTriggerHandler.SyncChangesToZuora', 'Update Error: ' + error.toString());
                                System.debug('Update Error: ' + error.toString());
                            }
                        }
                    }
                    
                }
                
                
            } 
            catch (Exception ex) {
                //logger.AddToQueue('ZuoraSubscriptionTriggerHandler.SyncChangesToZuora', 'Query Error: ' + ex.getMessage());
                System.debug('Query Error: ' + ex.getMessage());
            }
            
        }
        
        //logger.FlushQueue();        
    }    
    
}