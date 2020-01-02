global class UpdateQuoteNumberBatch implements Database.Batchable<SObject>, Database.Stateful {    
    
    // *** Start Method :  ***
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {   Util.Bypass_Trigger_Chk = true;
     User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
     objuser.Bypass_Triggers__c = true;
     objuser.BypassValidationRules__c = true;
     objuser.BypassWorkflows__c = true;
     update objuser;
     String strQuery = 'select id,(select id,BigMachines__Quote__r.Name,Line_Number__c,createddate from BigMachines__BigMachines_Quote_Products__r order by createddate asc) from BigMachines__Quote__c where createddate > 2019-08-01T00:00:00z and offering_type__c in (\'PureCloud\',\'PureConnect Cloud\') and order_type__C = \'New Subscription\' order by createddate asc';
     return Database.getQueryLocator(strQuery);
    }    
    // *** Execute Method :***
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) 
    {        
        BigMachines__Quote__c objNewQuote = (BigMachines__Quote__c)sObjects[0]; 
        List<BigMachines__Quote_Product__c> list_QPtoUpdate = new list<BigMachines__Quote_Product__c>();
        Decimal decLinenumber = 1;
        Map<Decimal,BigMachines__Quote_Product__c> map_lntoQP  = new Map<Decimal,BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c objQP:objNewQuote.BigMachines__BigMachines_Quote_Products__r){
            map_lntoQP.put(objQP.Line_Number__c,objQP);
        }
        for(BigMachines__Quote_Product__c objQP:objNewQuote.BigMachines__BigMachines_Quote_Products__r){
            if(map_lntoQP.containsKey(decLinenumber)){
                continue;
            }
            else
            {
                if(objQP.Line_Number__c == null){objQP.Line_Number__c = decLinenumber;
                                                 decLinenumber++;
                                                 list_QPtoUpdate.add(objQP);}
            }
        }
        
        Database.update(list_QPtoUpdate);
    }
    
    // *** Finish Method : Post Processing Logic ***
    global void finish(Database.BatchableContext BC) 
    {
        list<Order_line_item__c> list_OLI=[select id,name,Line_Number__c,Quote_Product__r.Line_Number__c,createddate from Order_Line_Item__c where Line_Number__c = null and Quote_Product__r.Line_Number__c !=null and createddate > 2019-08-01T00:00:00z];
        for(Order_line_item__c objOLI:list_OLI){
            objOLI.Line_Number__c = objOLI.Quote_Product__r.Line_Number__c;
        }
        Database.update(list_OLI);
        list<Subscription_Product__c> list_SP=[select id,name,Line_Number__c,Quote_Product__r.Line_Number__c,createddate from Subscription_Product__c where Line_Number__c = null and Quote_Product__r.Line_Number__c !=null and createddate > 2019-08-01T00:00:00z];
        for(Subscription_Product__c objSP:list_SP){
            objSP.Line_Number__c = objSP.Quote_Product__r.Line_Number__c;
        }
        Database.update(list_SP);
    }    
}