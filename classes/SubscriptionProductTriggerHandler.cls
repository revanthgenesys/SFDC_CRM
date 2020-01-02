/************************************************************************************
Purpose : Handler fo related triggers under Subscription Product to display quote products in email template
Written By : Ranjith Punneli
Test Classes : SubscriptionProductTest
*************************************************************************************/
public Class SubscriptionProductTriggerHandler {
    
    public static void createServiceTokens(List<Subscription_Product__c> list_NewSubscrProds) { 
        
      
        Map<Id, Account> map_Accounts = new Map<Id, Account>();
        Map<Id, List<Subscription_Product__c>> map_AcctChrgs = new Map<Id, List<Subscription_Product__c>>();
        List<Subscription_Product__c> list_SubscrProds = new List<Subscription_Product__c>();
        List<Subscription_Product__c> list_ReqSubscrProds = new List<Subscription_Product__c>();
        Set<Id> set_SubscrProdIds = new Set<Id>();
        
        for(Subscription_Product__c objSubscrProd : list_NewSubscrProds) {
            set_SubscrProdIds.add(objSubscrProd.Id);
        }
        if(set_SubscrProdIds.size()>0){
        list_SubscrProds = [SELECT Id, Name, Product__r.APN_Number__c, APN_Number__c, Subscription__r.Subscription_Start_Date__c, Quantity__c,
                                   Subscription__c, Subscription__r.Name, Subscription__r.Account__c, Subscription__r.Start_Date__c, 
                                   Subscription__r.Account__r.Support_Option__c, Subscription__r.Account__r.PureCloud_Products__c 
                            FROM Subscription_Product__c
                            WHERE Id IN :set_SubscrProdIds
                              AND Subscription__r.Offering_Type__c =: SubscriptionUtil.OFFERING_TYPE_PC];
            
        }
        if(list_SubscrProds.size() > 0) {
              Map<String, Service_Token_Definition__c> map_TokDefs = SubscriptionUtil.loadServiceTokenDefinition();
            for(Subscription_Product__c objSubscrProd : list_SubscrProds) {
                if(map_TokDefs.containsKey(objSubscrProd.Product__r.APN_Number__c)){
                    list_ReqSubscrProds.add(objSubscrProd);
                    if(map_AcctChrgs.containsKey(objSubscrProd.Subscription__r.Account__c)) {
                        map_AcctChrgs.get(objSubscrProd.Subscription__r.Account__c).add(objSubscrProd);
                    }
                    else {
                        map_AcctChrgs.put(objSubscrProd.Subscription__r.Account__c, new List<Subscription_Product__c>{objSubscrProd});
                    }
                }
                map_Accounts.put(objSubscrProd.Subscription__r.Account__c, new Account(Id=objSubscrProd.Subscription__r.Account__c, 
                                                                         Support_Option__c=objSubscrProd.Subscription__r.Account__r.Support_Option__c, 
                                                                         PureCloud_Products__c=objSubscrProd.Subscription__r.Account__r.PureCloud_Products__c));
            }
            SubscriptionUtil.createServiceTokens(list_ReqSubscrProds, map_TokDefs);
            SubscriptionUtil.updateAccountSupportOptions(map_Accounts, map_AcctChrgs);
        }
    }
}