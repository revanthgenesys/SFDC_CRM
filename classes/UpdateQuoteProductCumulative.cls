global class  UpdateQuoteProductCumulative implements Database.Batchable<SObject>, Database.Stateful{
    // *** Start Method :  ***
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {   
        Util.Bypass_Trigger_Chk = true;
        User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
        objuser.Bypass_Triggers__c = true;
        objuser.BypassValidationRules__c = true;
        objuser.BypassWorkflows__c = true;
        update objuser;
        String strQuery = 'select id from BigMachines__Quote_Product__c  where createddate > 2018-04-01T00:00:00z and BigMachines__Quote__r.offering_type__c in (\'PureCloud\',\'PureConnect Cloud\',\'PureEngage Cloud\') and (BigMachines__Quote__r.Order__r.status__c = \'Approved\' or BigMachines__Quote__r.Master_Order__r.status__c = \'Approved\') and BigMachines__Quote__r.Order_Type__c = \'Amend Subscription\' order by createddate asc';
        if(Test.isRunningTest()){strQuery = 'select id from BigMachines__Quote_Product__c  where createddate > 2019-06-01T00:00:00z and BigMachines__Quote__r.offering_type__c in (\'PureCloud\',\'PureConnect Cloud\',\'PureEngage Cloud\') and (BigMachines__Quote__r.Order__r.status__c = \'Approved\' or BigMachines__Quote__r.Master_Order__r.status__c = \'Approved\') and BigMachines__Quote__r.Order_Type__c = \'Amend Subscription\' order by createddate asc limit 2000';}
        return Database.getQueryLocator(strQuery);
    }    
    // *** Execute Method :***
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) 
    {        
        Id IssueId; 
        try{
            Util.Bypass_Trigger_Chk = true;
            User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
            objuser.Bypass_Triggers__c = true;
            objuser.BypassValidationRules__c = true;
            objuser.BypassWorkflows__c = true;
            update objuser;
            Set<Id> Set_QPId = new Set<ID>();
            for(SObject objObjext:sObjects){
                BigMachines__Quote_Product__c objQP = (BigMachines__Quote_Product__c)objObjext;
                System.debug('objQP:'+objQP);
                Set_QPId.add(objQP.Id);
                
            }
            List<BigMachines__Quote_Product__c> list_QPS = [select id,Total_Discount__c,BigMachines__Quote__r.Order_Type__c,BigMachines__Quote__r.Amendment_For__c,BigMachines__Quote__r.Amendment_For__r.version__C,BigMachines__Quote__r.Subscription_Amend_Date__c,BigMachines__Quote__r.Subscription_Start_Date__c,Subscription_Product__c,Net_Unit_Price__c,BigMachines__Quantity__c,Quantity_Change__c,Number_of_Remaining_Months__c,Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c,Number_of_Previous_Months__c,Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c,Cumulative_Total_of_Price_for_Amendment__c,Subscription_Product__r.Store_Cumulative_Total_for_Amend__c,BigMachines__Product__r.Include_in_CMMR_Total__c,BigMachines__Quote__r.Subscription_End_Date__c,BigMachines__Quote__r.Amendment_For__r.Subscription_End_Date__c,Subscription_Product__r.Subscription__r.quote__R.order_type__c,Difference_in_Subscription_End_Dates__c from BigMachines__Quote_Product__c where Net_Unit_Price__c!= null and id in :Set_QPId order by createddate asc];
            for(BigMachines__Quote_Product__c objQP:list_QPS){ 
                IssueId = objQP.Id;
                if(objQP.BigMachines__Quote__r.Order_Type__c == 'Amend Subscription' && objQP.BigMachines__Product__r.Include_in_CMMR_Total__c){
                    if(objQP.Subscription_Product__c != null && 
                       (objQP.Quantity_Change__c != 0 || (objQP.BigMachines__Quote__r.Subscription_End_Date__c != objQP.BigMachines__Quote__r.Amendment_For__r.Subscription_End_Date__c) || (objQP.Net_Unit_Price__c != objQP.Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c))){
                           if(objQP.BigMachines__Quote__r.Subscription_Amend_Date__c < objQP.BigMachines__Quote__r.Subscription_Start_Date__c){
                               objQP.Cumulative_Total_of_Price_for_Amendment__c = (objQP.Net_Unit_Price__c*objQP.BigMachines__Quantity__c*objQP.Number_of_Remaining_Months__c);
                           }
                           else
                           {
                               if(objQP.Subscription_Product__r.Subscription__r.quote__R.order_type__c != 'Amend Subscription'){
                                   
                                   objQP.Cumulative_Total_of_Price_for_Amendment__c = ((objQP.Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c * objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c * objQP.Number_of_Previous_Months__c) +  (objQP.Net_Unit_Price__c*objQP.BigMachines__Quantity__c*objQP.Number_of_Remaining_Months__c));
                                   
                               }
                               else if( objQP.Subscription_Product__r.Subscription__r.quote__R.order_type__c == 'Amend Subscription'){
                                   
                                   if (objQP.Subscription_Product__r.Store_Cumulative_Total_for_Amend__c == null || objQP.Subscription_Product__r.Store_Cumulative_Total_for_Amend__c == 0)
                                   {
                                       
                                       objQP.Cumulative_Total_of_Price_for_Amendment__c = ((objQP.Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c * objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c * objQP.Number_of_Previous_Months__c) +  (objQP.Net_Unit_Price__c*objQP.BigMachines__Quantity__c*objQP.Number_of_Remaining_Months__c));
                                       
                                   }
                                   
                                   else{
                                       Decimal decValue = (objQP.Subscription_Product__r.Store_Cumulative_Total_for_Amend__c != null)? objQP.Subscription_Product__r.Store_Cumulative_Total_for_Amend__c:0.00;
                                       objQP.Cumulative_Total_of_Price_for_Amendment__c = (decValue + (objQP.Net_Unit_Price__c*(objQP.Quantity_Change__c != 0? (((objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c != null) ?(objQP.BigMachines__Quantity__c - objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c): objQP.Quantity_Change__c)):0.00)
                                                                                                       *objQP.Number_of_Remaining_Months__c) + ((objQP.Net_Unit_Price__c - objQP.Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c)* objQP.Number_of_Remaining_Months__c * objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c  )+(((objQP.BigMachines__Quote__r.Subscription_End_Date__c != objQP.BigMachines__Quote__r.Amendment_For__r.Subscription_End_Date__c)? objQP.Difference_in_Subscription_End_Dates__c:0.00)  * objQP.Net_Unit_Price__c * objQP.BigMachines__Quantity__c));  
                                   }   
                               }
                               
                               
                           }
                       }   
                    else if(objQP.Subscription_Product__c == null ){
                        
                        objQP.Cumulative_Total_of_Price_for_Amendment__c = (objQP.Net_Unit_Price__c*objQP.BigMachines__Quantity__c*objQP.Number_of_Remaining_Months__c);
                    }
                }
            }			 
            Database.update(list_QPS,false);
            list<Order_line_item__c> list_OLI=[select id,name,Line_Number__c,Quote_Product__r.Line_Number__c,createddate,Cumulative_Total_for_Amendment_c__c,Quote_Product__r.Cumulative_Total_of_Price_for_Amendment__c from Order_Line_Item__c where Quote_Product__c in :Set_QPId];
            for(Order_line_item__c objOLI:list_OLI){
                objOLI.Cumulative_Total_for_Amendment_c__c = objOLI.Quote_Product__r.Cumulative_Total_of_Price_for_Amendment__c;
            }
            Database.update(list_OLI);
            list<Subscription_Product__c> list_SP=[select id,name,Line_Number__c,Quote_Product__r.Line_Number__c,createddate,Store_Cumulative_Total_for_Amend__c,Quote_Product__r.Cumulative_Total_of_Price_for_Amendment__c from Subscription_Product__c where  Quote_Product__c in :Set_QPId];
            for(Subscription_Product__c objSP:list_SP){
                objSP.Store_Cumulative_Total_for_Amend__c = objSP.Quote_Product__r.Cumulative_Total_of_Price_for_Amendment__c;
            }
            Database.update(list_SP); }catch(Exception e){
                System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
                ErrorLogUtil.insertLog('UpdateQuoteProductCumulative', 'Error from UpdateQuoteProductCumulative: ' + IssueId + '\n' +  e.getMessage()+'\n'+e.getStackTraceString(), 'UpdateQuoteProductCumulative.execute()'); 
                
            }
        
    }
    
    // *** Finish Method : Post Processing Logic ***
    global void finish(Database.BatchableContext BC) 
    {
        
    }    
    
}