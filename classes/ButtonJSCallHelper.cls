//Naresh Kumar  06/02/2014
global without sharing class ButtonJSCallHelper {
    //Opportunity details button - New PPU Order    
    webservice static String newPPUOrder(String opportunityId){
        System.debug('NKC debug opportunityId ['+opportunityId+']');
        List<OpportunityLineItem> oppLineItems = [SELECT id FROM OpportunityLineItem 
            WHERE PricebookEntry.Product2.PPU_Product__c = true AND OpportunityId =: opportunityId];
        if(oppLineItems.isEmpty())
            return 'You cannot create a PPU Order on a opportunity with no PPU Usage product on it. Please add a PPU Usage product before proceeding';
        return 'OK';
    }
    
    //Updates contract line item fields
    webservice static String updateContractLineItemFields(String serviceContractId){
        try{
            List<ContractLineItem> contractLineItemsToBeUpdated = [SELECT Revised_Net_License_Value__c, 
                Original_Net_License_value__c, Lic_Invoice__c, Original_License_Invoice_Date__c, 
                Order_Line_Item__r.Revised_Net_License_Value__c,
                Contract_Line_Item__r.Original_Net_License_value__c, 
                Contract_Line_Item__r.Lic_Invoice__c, 
                Contract_Line_Item__r.Original_License_Invoice_Date__c
                FROM ContractLineItem WHERE ServiceContractId =: serviceContractId];
                
            for(ContractLineItem eachCLI : contractLineItemsToBeUpdated){
                //Revised Net Lic Value from Order
                if(eachCLI.Order_Line_Item__r.Revised_Net_License_Value__c != null)
                    eachCLI.Revised_Net_License_Value__c = eachCLI.Order_Line_Item__r.Revised_Net_License_Value__c;
                //Below fields from contract line item (lookup)
                if(eachCLI.Contract_Line_Item__r.Original_Net_License_value__c != null)
                    eachCLI.Original_Net_License_value__c = eachCLI.Contract_Line_Item__r.Original_Net_License_value__c;
                if(eachCLI.Contract_Line_Item__r.Lic_Invoice__c != null)
                    eachCLI.Lic_Invoice__c = eachCLI.Contract_Line_Item__r.Lic_Invoice__c;
                if(eachCLI.Contract_Line_Item__r.Original_License_Invoice_Date__c != null)
                    eachCLI.Original_License_Invoice_Date__c = eachCLI.Contract_Line_Item__r.Original_License_Invoice_Date__c;
            }
            
            if(!contractLineItemsToBeUpdated.isEmpty())
                update contractLineItemsToBeUpdated;
            return 'OK';
        }
        catch(Exception ex){
            return 'Error - ' + ex.getMessage();
        }
        return 'OK';
    }
    
    //Updates contract line item fields
    webservice static String updateContractLineItemInvoiceAndInvoiceDate(String serviceContractId){
        try{
            List<ContractLineItem> contractLineItemsToBeUpdated = [SELECT ServiceContract.Renewal_License__c, 
                Lic_Invoice__c, Original_License_Invoice_Date__c, LineItemNumber,
                Order_Line_Item__r.Order__r.Invoice_Number__c, Order_Line_Item__r.Order__r.Invoice_Date__c,             
                Quote_Product__r.Lic_Invoice__c, Quote_Product__r.Original_License_Invoice_Date__c,
                ServiceContract.Copy_from_SC_Line__c, Quote_Product__r.Service_Contract_Line_ID__c,
                Order_Line_Item__r.Service_Contract_Line_ID__c, ServiceContract.Copy_from_Order_Line__c,
                ServiceContract.Order__r.Invoice_Number__c, ServiceContract.Order__r.Invoice_Date__c,
                ServiceContract.Order__r.Maintenance_Start__c,ServiceContract.Order__r.Maintenance_End__c
                FROM ContractLineItem WHERE ServiceContractId =: serviceContractId ];
            Boolean isCopyFromOrderLine = false;
            Map<String, List<ContractLineItem>> mapQuoteProductCLIIdVsCLIs = new Map<String, List<ContractLineItem>>();   
            for(ContractLineItem eachCLI : contractLineItemsToBeUpdated){               
                //License
                if(eachCLI.ServiceContract.Renewal_License__c == 'New'){
                    if(eachCLI.ServiceContract.Order__r.Invoice_Number__c != null)
                        eachCLI.Lic_Invoice__c = eachCLI.ServiceContract.Order__r.Invoice_Number__c;
                    if(eachCLI.ServiceContract.Order__r.Invoice_Date__c != null)
                        eachCLI.Original_License_Invoice_Date__c = eachCLI.ServiceContract.Order__r.Invoice_Date__c;
                    
                    if(eachCLI.Maintenance_Start_Date__c == null )
                        eachCLI.Maintenance_Start_Date__c = eachCLI.ServiceContract.Order__r.Maintenance_Start__c;
      
                    if(eachCLI.Maintenance_End_Date__c == null)
                       eachCLI.Maintenance_End_Date__c = eachCLI.ServiceContract.Order__r.Maintenance_End__c;
             
                
                
                }
                //Renewal
                else{
                    if(eachCLI.ServiceContract.Copy_from_Order_Line__c && eachCLI.Order_Line_Item__r.Service_Contract_Line_ID__c != null){
                        String cliId = eachCLI.Order_Line_Item__r.Service_Contract_Line_ID__c;
                        if(mapQuoteProductCLIIdVsCLIs.get(cliId) == null){
                            List<ContractLineItem> newList = new List<ContractLineItem>();
                            newList.add(eachCLI);
                            mapQuoteProductCLIIdVsCLIs.put(cliId, newList);
                        }
                        else
                            mapQuoteProductCLIIdVsCLIs.get(cliId).add(eachCLI);
                        isCopyFromOrderLine = true;
                    }
                    else if(eachCLI.ServiceContract.Copy_from_SC_Line__c && eachCLI.Quote_Product__r.Service_Contract_Line_ID__c != null){
                        String cliId = eachCLI.Quote_Product__r.Service_Contract_Line_ID__c;
                        if(mapQuoteProductCLIIdVsCLIs.get(cliId) == null){
                            List<ContractLineItem> newList = new List<ContractLineItem>();
                            newList.add(eachCLI);
                            mapQuoteProductCLIIdVsCLIs.put(cliId, newList);
                        }
                        else
                            mapQuoteProductCLIIdVsCLIs.get(cliId).add(eachCLI);
                    }
                    else{
                        if(eachCLI.Quote_Product__r.Lic_Invoice__c != null)
                            eachCLI.Lic_Invoice__c = eachCLI.Quote_Product__r.Lic_Invoice__c;
                        if(eachCLI.Quote_Product__r.Original_License_Invoice_Date__c != null)
                            eachCLI.Original_License_Invoice_Date__c = eachCLI.Quote_Product__r.Original_License_Invoice_Date__c;
                    }
                }               
            }
            if(!mapQuoteProductCLIIdVsCLIs.isEmpty()){
                List<ContractLineItem> sourceLineItems = [SELECT Lic_Invoice__c, Original_License_Invoice_Date__c, Original_Net_License_value__c,
                    Revised_Net_License_value__c FROM ContractLineItem
                    WHERE id IN : mapQuoteProductCLIIdVsCLIs.keyset()];
                List<ContractLineItem> contractLineItemsToBeUpdated1 = new List<ContractLineItem>();    
                for(ContractLineItem eachCLI : sourceLineItems){
                    List<ContractLineItem> contractLineItemToBeUpdateds = mapQuoteProductCLIIdVsCLIs.get(eachCLI.id);
                    for(ContractLineItem eachContractLineItemToBeUpdated : contractLineItemToBeUpdateds){
                        if(eachCLI.Lic_Invoice__c != null)
                            eachContractLineItemToBeUpdated.Lic_Invoice__c = eachCLI.Lic_Invoice__c;
                        if(eachCLI.Original_License_Invoice_Date__c != null)
                            eachContractLineItemToBeUpdated.Original_License_Invoice_Date__c = eachCLI.Original_License_Invoice_Date__c; 
                        if(isCopyFromOrderLine){
                            if(eachCLI.Original_Net_License_value__c != null)
                                eachContractLineItemToBeUpdated.Original_Net_License_value__c = eachCLI.Original_Net_License_value__c;
                            if(eachCLI.Revised_Net_License_value__c != null)
                                eachContractLineItemToBeUpdated.Revised_Net_License_value__c = eachCLI.Revised_Net_License_value__c;
                        }                   
                        contractLineItemsToBeUpdated1.add(eachContractLineItemToBeUpdated);
                    }
                }
                if(!contractLineItemsToBeUpdated1.isEmpty())
                    update contractLineItemsToBeUpdated1;
            }
            else if(!contractLineItemsToBeUpdated.isEmpty())
                update contractLineItemsToBeUpdated;
            return 'OK';
        }
        catch(Exception ex){
            return 'Error - ' + ex.getMessage();
        }
        return 'OK';
    }
}