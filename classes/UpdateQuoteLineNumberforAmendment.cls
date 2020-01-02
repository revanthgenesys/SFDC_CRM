global class UpdateQuoteLineNumberforAmendment implements Database.Batchable<SObject>, Database.Stateful {
    DateTime dtRunDate;
    global UpdateQuoteLineNumberforAmendment(Date dtCreatedate){
        dtRunDate = dtCreatedate;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {   
        
        Util.Bypass_Trigger_Chk = true;
        User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
        objuser.Bypass_Triggers__c = true;
        objuser.BypassValidationRules__c = true;
        objuser.BypassWorkflows__c = true;
        update objuser;
        String strQuery = 'select id,Amendment_For__r.quote__c from BigMachines__Quote__c where order_type__C = \'Amend Subscription\' and createddate > :dtRunDate order by createddate desc';
        If(Test.isRunningTest()){
            strQuery = 'select id,(select id,BigMachines__Quote__r.Name,Line_Number__c,createddate from BigMachines__BigMachines_Quote_Products__r order by createddate asc) from BigMachines__Quote__c where order_type__C  = \'New Subscription\' and offering_type__c in (\'PureCloud\',\'PureConnect Cloud\',\'PureEngage Cloud\')and createddate > 2019-09-01T00:00:00z order by createddate desc limit 1';
        }
        return Database.getQueryLocator(strQuery);
    }    
    //*****Main Method***
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) 
    {
        Set<Id> set_QPId = new Set<Id>();
        Util.Bypass_Trigger_Chk = true;
        User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
        objuser.Bypass_Triggers__c = true;
        objuser.BypassValidationRules__c = true;
        objuser.BypassWorkflows__c = true;
        update objuser;
        BigMachines__Quote__c objQuote = (BigMachines__Quote__c)sObjects[0];
        System.debug('objQuote:'+objQuote);
        List<BigMachines__Quote_Product__c> list_QPtoretrive = [select id,Line_Number__c,Subscription_Product__r.Quote_Product__r.Line_Number__c from BigMachines__Quote_Product__c where BigMachines__Quote__c =:objQuote.Id   order by createddate asc ];
        List<BigMachines__Quote_Product__c> list_OriginalQPtoretrive = [select id,Line_Number__c,Subscription_Product__r.Quote_Product__r.Line_Number__c from BigMachines__Quote_Product__c where BigMachines__Quote__c =:objQuote.Amendment_For__r.quote__c order by createddate asc ];
        Decimal decLineNumber = 1;
        List<BigMachines__Quote_Product__c> list_QPtoUpdate = new list<BigMachines__Quote_Product__c>();
        Map<Decimal,BigMachines__Quote_Product__c> map_lntoQP  = new Map<Decimal,BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c objQP:list_OriginalQPtoretrive){
            if(objQP.Line_Number__c != null){map_lntoQP.put(objQP.Line_Number__c,objQP);}
            if(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c != null){map_lntoQP.put(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c,objQP);}
        }
        for(BigMachines__Quote_Product__c objQP:list_QPtoretrive){
            if(objQP.Line_Number__c != null && !map_lntoQP.containsKey(objQP.Line_Number__c)){map_lntoQP.put(objQP.Line_Number__c,objQP);}
            if(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c != null && !map_lntoQP.containsKey(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c)){map_lntoQP.put(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c,objQP);}
        }	
        
        for(BigMachines__Quote_Product__c objQP:list_QPtoretrive){
            System.debug('objQP:'+objQP);
            System.debug('decLinenumber:'+decLinenumber);
            System.debug('map_lntoQP.containsKey(decLinenumber):'+map_lntoQP.containsKey(decLinenumber));
            System.debug('objQP.Line_Number__c:'+objQP.Line_Number__c);
            System.debug('objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c:'+objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c);
            if(objQP.Line_Number__c !=  null || (objQP.Line_Number__c == null && objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c != null)){
                if(objQP.Line_Number__c == null && objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c != null){
                    objQP.Line_Number__c = objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c;
                    list_QPtoUpdate.add(objQP);
                }
            }
            else
            {
                if(objQP.Line_Number__c == null ){
                    do{
                        decLinenumber++;
                    }while(map_lntoQP.containsKey(decLinenumber));
                    objQP.Line_Number__c = decLinenumber;
                    list_QPtoUpdate.add(objQP);
                }    
            }
            set_QPId.add(objQP.Id);
            
        }	
        
        System.debug('list_QPtoUpdate.size():'+list_QPtoUpdate.size());
        System.debug('list_QPtoUpdate'+list_QPtoUpdate);    
        Database.update(list_QPtoUpdate,false);
        list<Order_line_item__c> list_OLI=[select id,name,Line_Number__c,Quote_Product__r.Line_Number__c,createddate from Order_Line_Item__c where Quote_Product__c in :set_QPId and Quote_Product__r.Line_Number__c !=null and ORder__r.recordtypeid = '012U0000000MqMG'];
        for(Order_line_item__c objOLI:list_OLI){
            objOLI.Line_Number__c = objOLI.Quote_Product__r.Line_Number__c;
        }
        Database.update(list_OLI,false);
        list<Subscription_Product__c> list_SP=[select id,name,Line_Number__c,Quote_Product__r.Line_Number__c,createddate from Subscription_Product__c where Quote_Product__c in :set_QPId and Quote_Product__r.Line_Number__c !=null  and Subscription__r.offering_type__C in ('PureCloud','PureConnect Cloud','PureEngage Cloud')];
        for(Subscription_Product__c objSP:list_SP){
            objSP.Line_Number__c = objSP.Quote_Product__r.Line_Number__c;
        }
        Database.update(list_SP,false);
    }
    
    // *** Finish Method : Post Processing Logic ***
    global void finish(Database.BatchableContext BC) 
    {
        
    }     
    
    
}