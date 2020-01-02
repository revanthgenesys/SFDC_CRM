//Naresh Kumar  09/13/2017 
public class OrderFieldPopulationHelper {
    //Populate a flag on order which tells whether the order has education line or not
    public static void populateEducationFlagOnOrder(List<Order_Line_Item__c> list_OfOrderLines){
        Boolean blnHasEducationLines = false;
        String strOrderId;
        //Looping over each line
        for(Order_Line_Item__c eachOLI : list_OfOrderLines){
            if(eachOLI.Product_Type__c == 'GU'){
                blnHasEducationLines = true;
                strOrderId = eachOLI.Order__c;
                break;
            }
        }
        if(blnHasEducationLines){
            Util.Bypass_Trigger_Chk = true;
            Order__c objOrderToBeUpdated = new Order__c(id = strOrderId, Has_Education_Lines__c = true);    
            update objOrderToBeUpdated;
            Util.Bypass_Trigger_Chk = false;
        }        
    }
    
    //Naresh Kumar - 03/26/2018
    //Populate related currency conversion rate
    public static void populateCurrnecyRateLookup(Set<Order__c> setOfOrders){
        /*
        //Invoiced Order - Below logic will work only one order at a time.
        Order__c objOrder;
        for(Order__c objEachOrder : setOfOrders){
            objOrder = objEachOrder;
            break;
        }   
        
        //Checking if invoice date is null and currency conversion lookup is null
        if(objOrder != null && objOrder.Invoice_Date__c != null 
           && objOrder.ERP_Currency_Daily_Exchange_Rate__c == null && objOrder.CurrencyIsoCode != 'USD'){
            //String strPeriod = objOrder.Invoice_Date__c.Month() + '-' + objOrder.Invoice_Date__c.Year();               
            //Getting latest rate record from the date of invoice on order
            List<ERP_Currency_Daily_Exchange_Rate__c> listOfExchangeRate = new List<ERP_Currency_Daily_Exchange_Rate__c>();
           if(!Test.isRunningTest()) 
               listOfExchangeRate = [SELECT id FROM ERP_Currency_Daily_Exchange_Rate__c
                    WHERE Effective_Date__c >=: objOrder.Invoice_Date__c -4 AND FROM_CURRENCY_CODE__c =: objOrder.CurrencyIsoCode
                    AND TO_CURRENCY_CODE__c = 'USD' AND EXCHANGE_RATE_TYPE__c = 'DAILY'
                    AND lastmodifieddate>2019-01-01T14:01:00-04:00 AND  owner.ID ='005U0000001udP6' limit 1];
                //Commeneted above line By Ranjith on Nov 8th, 2018 after discussing with Vikram. 
            //Populating rate record lookup if any
            if(!listOfExchangeRate.isEmpty()){
                objOrder.ERP_Currency_Daily_Exchange_Rate__c = listOfExchangeRate[0].id;
                //Updating the same lookup on related Opportunity
                if(objOrder.Opportunity__c != null){
                    Util.Bypass_Trigger_Chk = true;
                    Opportunity objOppToUpdate = new Opportunity(id = objOrder.Opportunity__c, Spot_Rate__c = listOfExchangeRate[0].id);
                    objOppToUpdate.Spot_Rate_from_Order__c = true;
                    update objOppToUpdate;
                    Util.Bypass_Trigger_Chk = false;
                }
            }
        }
  
        */
    }
    
    //Naresh Kumar - 04/03/2018
    //Populate related currency conversion rate
    public static void populateCurrnecyRateLookup(List<Opportunity> listOfOpps, Map<Id, Opportunity> mapOfOppIdVsOpps){        
     
        Opportunity objOpp = listOfOpps[0];
        Opportunity objOldOpp;
        if(mapOfOppIdVsOpps != null)
            objOldOpp = mapOfOppIdVsOpps.get(objOpp.id);
        //Below logic will work only one order at a time.       
        //Checking if close date is null and currency conversion lookup is null
        if(objOpp.CloseDate != null && (objOldOpp == null || objOpp.CloseDate != objOldOpp.CloseDate) 
            && objOpp.CurrencyIsoCode != 'USD' && !objOpp.Spot_Rate_from_Order__c){
            String strPeriod = objOpp.CloseDate.Month() + '-' + objOpp.CloseDate.Year();               
            //Getting latest rate record from the Opp Close Date
            List<ERP_Currency_Daily_Exchange_Rate__c> listOfExchangeRate = [SELECT id FROM ERP_Currency_Daily_Exchange_Rate__c
                WHERE Period_Month_Year__c =: strPeriod AND FROM_CURRENCY_CODE__c =: objOpp.CurrencyIsoCode
                AND TO_CURRENCY_CODE__c = 'USD' AND EXCHANGE_RATE_TYPE__c = 'FORECAST' AND lastmodifieddate>2018-04-18T14:01:00-04:00 AND Owner.ID ='0050B000006lk2M' limit 1]; //(NOT NAME LIKE 'FORECAST%')];
                //Added and commeneted above line By Ranjith on Nov 8th, 2018 after discussing with Vikram. 
            //Populating rate record lookup if any
            if(!listOfExchangeRate.isEmpty()){
                objOpp.Spot_Rate__c = listOfExchangeRate[0].id;
            }
        }
        
       
        
    }    
}