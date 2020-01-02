/*
OppQuoteOrderStatusHandler
04/23/2013    Naresh Kumar    Original for Task/Story #   
Description : Class provides status mapping functionality for Opportunity, Order and Quote.
*/
public with sharing class OppQuoteOrderStatusHandler 
{
    public static void updateOpportunityStatus(List<BigMachines__Quote__c> newQuoteList, Map<Id, BigMachines__Quote__c> oldMap)
    {
        BigMachines__Quote__c currentQuote = newQuoteList[0]; 
        //commenting below lines to update Opportunity Status of ALL the CoTermed Opps On every Revision /*status flow premise project*/
        /*for(Integer i = 0 ; i < newQuoteList.size() ; i++)
        {
            if(!newQuoteList[i].BigMachines__Is_Primary__c)
                continue;       
            currentQuote = newQuoteList[i];
        }

        if(currentQuote == null) 
            return;*/
            
        String quoteStatus = CurrentQuote.BigMachines__Status__c;
        String OrderStatus = CurrentQuote.Order_Status__c;
        
        List<Opportunity> list_Oppty = [SELECT RecordType.DeveloperName, Opportunity_Status__c, Forecast_Status__c, AccountId,BusinessPartner__c, Support_Owner__c 
                                        FROM Opportunity WHERE id =: currentQuote.BigMachines__Opportunity__c LIMIT 1];
        
        if(list_Oppty.size() > 0 && list_Oppty[0].RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
        {
            Opportunity currentOpp = list_Oppty[0];
            Map<Id,Opportunity> map_ToUpdate = new Map<Id,Opportunity>();
            map_ToUpdate.put(currentOpp.Id,currentOpp);
            Boolean isStatusUpdated = false;
            if(currentQuote.Quote_Business_Type__c == 'Renewal')
            {
                currentOpp.AccountId =  currentQuote.End_User_ID__c;
                currentOpp.BusinessPartner__c = currentQuote.Sold_To_Name__c;
                currentOpp.Support_Owner__c = currentQuote.Support_Owner__c;
                isStatusUpdated = true;
            }
            System.debug('inside 1');
            // To sync quote status with quote status on Opportunity
            currentOpp.Quote_Quote_Status__c = quoteStatus;
            
            /* if quote is being inserted or status has been changed or has been made primary now 
                or Sent to Customer checkbox value has changed*/
            if(oldMap == null || quoteStatus != oldMap.get(currentQuote.id).BigMachines__Status__c ||
                (currentQuote.Sent_to_Customer__c != oldMap.get(currentQuote.id).Sent_to_Customer__c && 
                !currentQuote.Sent_to_Customer__c) || !oldMap.get(currentQuote.id).BigMachines__Is_Primary__c)
            {         
                System.debug('inside 2');
                isStatusUpdated = true;
                
                if(currentOpp.Opportunity_Status__c != 'Hypothetical')
                {
                    if(quoteStatus == 'Quote In Progress' || quoteStatus == 'Quote Rejected' || quoteStatus == 'Quote Expired')
                    {
                        currentOpp.Opportunity_Status__c = 'In Progress';
                        currentOpp.Forecast_Status__c = 'Pipeline';
                        /*
                        if(currentQuote.Quote_Business_Type__c == 'Renewal' && quoteStatus == 'Quote Rejected')
                            currentOpp.Opportunity_Status__c = 'Quoted';
                        */
                    }
                    if(quoteStatus == 'Quote Approval Pending' || quoteStatus == 'Quote Approved' || quoteStatus == 'Order Rejected')
                    {
                        if(quoteStatus == 'Quote Approval Pending'){
                            currentOpp.Opportunity_Status__c = 'In Progress';
                        }else{
                            currentOpp.Opportunity_Status__c = 'Quoted';
                        }
                        currentOpp.Forecast_Status__c = 'Pipeline';
                        
                        if(quoteStatus == 'Quote Approved' || quoteStatus == 'Order Rejected'){
                            // Setting status of co-termed opportunities (Condition : they should not have any quote of their own)
                            Set<Id> set_OpptyIds = new Set<Id>();
                            for(Quote_Service_Contracts__c objQSC : [SELECT Service_Contract__r.Renewal_Opportunity__c
                                                                    FROM Quote_Service_Contracts__c WHERE Service_Contract__r.Renewal_Opportunity__c != null
                                                                    AND Service_Contract__r.Renewal_Opportunity__c != :currentOpp.Id AND 
                                                                    Quote__c = :currentQuote.Id])
                            {
                                set_OpptyIds.add(objQSC.Service_Contract__r.Renewal_Opportunity__c);
                            }
                            for(Opportunity objOppty: [SELECT Id,(SELECT Id FROM BigMachines__BigMachines_Quotes__r WHERE BigMachines__Is_Primary__c=true LIMIT 1)
                                                       FROM Opportunity WHERE Id IN :set_OpptyIds])
                            {
                                if(objOppty.BigMachines__BigMachines_Quotes__r.size() == 0)
                                {
                                    objOppty.Opportunity_Status__c = 'CO-Term Pending';
                                    objOppty.Quote_Quote_Status__c = quoteStatus;
                                    objOppty.Send_to_Customer__c = currentQuote.Sent_to_Customer__c;
                                    map_ToUpdate.put(objOppty.Id,objOppty);
                                }
                            }
                        }
                    }
                }
                
                if(quoteStatus == 'Order Submitted' || quoteStatus == 'Order Approved' || quoteStatus == 'Order Accepted')
                {
                    if(quoteStatus == 'Order Submitted' && Orderstatus =='Re-Submitted'){
                        currentOpp.Opportunity_Status__c = 'Quoted';
                        currentOpp.Forecast_Status__c = 'Booked In';
                    }else if(quoteStatus == 'Order Submitted'){
                        currentOpp.Opportunity_Status__c = 'Quoted';
                        currentOpp.Forecast_Status__c = 'Pipeline';
                    }else{
                        currentOpp.Opportunity_Status__c = 'Renewed';
                        currentOpp.Forecast_Status__c = 'Booked In';
                    }
                       
                    
                    if(quoteStatus == 'Order Approved' || quoteStatus == 'Order Accepted')
                    {
                        // Setting status of co-termed opportunities (Condition : they should not have any quote of their own)
                        Set<Id> set_OpptyIds = new Set<Id>();
                        for(Quote_Service_Contracts__c objQSC : [SELECT Service_Contract__r.Renewal_Opportunity__c
                                        FROM Quote_Service_Contracts__c WHERE Service_Contract__r.Renewal_Opportunity__c != null
                                        AND Service_Contract__r.Renewal_Opportunity__c != :currentOpp.Id AND 
                                        Quote__c = :currentQuote.Id])
                        {
                            set_OpptyIds.add(objQSC.Service_Contract__r.Renewal_Opportunity__c);
                        }
                        for(Opportunity objOppty: [SELECT Id,(SELECT Id FROM BigMachines__BigMachines_Quotes__r LIMIT 1)
                                            FROM Opportunity WHERE Id IN :set_OpptyIds])
                        {
                            //if(objOppty.BigMachines__BigMachines_Quotes__r.size() == 0)
                            //{
                                objOppty.Opportunity_Status__c = 'CO-Term Closed';
                                objOppty.Quote_Quote_Status__c = quoteStatus;
                                objOppty.Send_to_Customer__c = currentQuote.Sent_to_Customer__c;
                                map_ToUpdate.put(objOppty.Id,objOppty);
                            //}
                        }
                    }
                }
                
                if(quoteStatus == 'Legacy Cancelled')
                {
                    currentOpp.Opportunity_Status__c = 'Cancelled';
                    currentOpp.Forecast_Status__c = 'Cancelled';     
                }    
                currentOpp.Hardware_Total__c = currentQuote.Total_Hardware__c;
                currentOpp.Send_to_Customer__c = currentQuote.Sent_to_Customer__c;
            }
            if(isStatusUpdated)
            {
                update map_ToUpdate.values();
                TriggerFlowManager.QUOTE_STATUS_TO_OPP_STATUS_POPULATION = false;
            }   
        }
    }       
    
    public static void updateSentToCustomerStatus(List<BigMachines__Quote__c> newQuoteList, Map<Id, BigMachines__Quote__c> oldMap)
    {
        BigMachines__Quote__c currentQuote = newQuoteList[0];
        if(currentQuote.Sent_to_Customer__c && (oldMap == null || !oldMap.get(currentQuote.id).Sent_to_Customer__c ||
            currentQuote.BigMachines__Is_Primary__c != oldMap.get(currentQuote.id).BigMachines__Is_Primary__c))
        {
            if(currentQuote.BigMachines__Opportunity__c == null || !currentQuote.BigMachines__Is_Primary__c) 
                return;
            Opportunity currentOpp = [SELECT Opportunity_Status__c FROM Opportunity WHERE id =:  currentQuote.BigMachines__Opportunity__c];
            if(currentOpp.Opportunity_Status__c != 'Hypothetical'){     
                currentOpp.Opportunity_Status__c = 'With Customer';
                currentOpp.Forecast_Status__c = 'Pipeline';
            }
            currentOpp.Send_to_Customer__c = true;
            update currentOpp;
            TriggerFlowManager.QUOTE_SENT_TO_CUSTOMER_POPULATION = false;
        }
        else if(!currentQuote.Sent_to_Customer__c && oldMap.get(currentQuote.id).Sent_to_Customer__c){
            Opportunity currentOpp = new Opportunity(id = currentQuote.BigMachines__Opportunity__c);
            currentOpp.Send_to_Customer__c = false;
            update currentOpp;          
            TriggerFlowManager.QUOTE_SENT_TO_CUSTOMER_POPULATION = false;
        }
    }
}