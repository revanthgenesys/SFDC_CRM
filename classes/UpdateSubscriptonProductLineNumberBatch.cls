global class UpdateSubscriptonProductLineNumberBatch implements Database.Batchable<SObject>, Database.Stateful{
    DateTime dateCreateddate ;  
    DateTime dateToday;
    global UpdateSubscriptonProductLineNumberBatch(Integer intYear,Integer intMonth,Integer intDay){
        dateCreateddate = DateTime.newInstance(intYear, intMonth, intDay);
        dateToday = System.now(); 
        
    }
    
    // *** Start Method :  ***
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {   
        Util.Bypass_Trigger_Chk = true;
        User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
        objuser.Bypass_Triggers__c = true;
        objuser.BypassValidationRules__c = true;
        objuser.BypassWorkflows__c = true;
        update objuser;
        String strQuery = 'select id from Subscription__c where Status__c = \'Active\' and offering_type__c in (\'PureCloud\',\'PureConnect Cloud\',\'PureEngage Cloud\')and createddate > :dateCreateddate  and createddate < :dateToday order by createddate asc ' ;
        System.debug('strQuery:'+strQuery);
        If(Test.isRunningTest()){
            strQuery = 'select id from Subscription__c where Status__c = \'Active\' and offering_type__c in (\'PureCloud\',\'PureConnect Cloud\',\'PureEngage Cloud\')and createddate > :dateCreateddate order by createddate asc limit 1';
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
        Subscription__c objSub = (Subscription__c)sObjects[0];
        System.debug('objSub:'+objSub);
        List<Subscription_Product__c> list_SPtoretrive = [select id,Line_Number__c,Quote_Product__r.Line_Number__c,Quote_Product__r.name from Subscription_Product__c where Subscription__c =:objSub.Id   order by createddate asc ];
        List<Subscription_Product__c> list_SPtoUpdate = new list<Subscription_Product__c>();
        Decimal decLinenumber = 1;
        Map<Decimal,Subscription_Product__c> map_lntoQP  = new Map<Decimal,Subscription_Product__c>();
        for(Subscription_Product__c objSP:list_SPtoretrive){
            if(objSP.Line_Number__c !=  null ){map_lntoQP.put(objSP.Line_Number__c,objSP);}
            if(objSP.Quote_Product__r.Line_Number__c !=  null ){map_lntoQP.put(objSP.Quote_Product__r.Line_Number__c,objSP);}
        }
        for(Subscription_Product__c objSP:list_SPtoretrive){
            System.debug('objSP:'+objSP);
            System.debug('decLinenumber:'+decLinenumber);
            System.debug('map_lntoQP.containsKey(decLinenumber):'+map_lntoQP.containsKey(decLinenumber));
            System.debug('objSP.Line_Number__c:'+objSP.Line_Number__c);
            System.debug('objSP.Quote_Product__r.Line_Number__c:'+objSP.Quote_Product__r.Line_Number__c);
            if(objSP.Line_Number__c !=  null || (objSP.Line_Number__c == null && objSP.Quote_Product__r.Line_Number__c != null)){
                if(objSP.Line_Number__c == null && objSP.Quote_Product__r.Line_Number__c != null){
                    objSP.Line_Number__c = objSP.Quote_Product__r.Line_Number__c;
                    list_SPtoUpdate.add(objSP);
                }
                continue;
            }
            else
            {
                if(objSP.Line_Number__c == null && decLinenumber <= list_SPtoretrive.size() ){
                    do{
                        decLinenumber++;
                    }while(map_lntoQP.containsKey(decLinenumber));
                    objSP.Line_Number__c = decLinenumber;
                    list_SPtoUpdate.add(objSP);
                }		
            }	
        }
        System.debug('list_SPtoUpdate.size():'+list_SPtoUpdate.size());
        System.debug('list_SPtoUpdate'+list_SPtoUpdate);    
        Database.update(list_SPtoUpdate,false);
    }  
    
    // *** Finish Method : Post Processing Logic ***
    global void finish(Database.BatchableContext BC) 
    {
        
    }    
    
}