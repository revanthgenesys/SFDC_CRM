/*
QuoteFieldMappings
04/17/2013    Naresh Kumar    Original for Task/Story #   
Description : Class provides fields mapping between quote and other objects.
*/
public without sharing class QuoteFieldMappings {
    /*
    Some mapping logic used in this class doesn't support bulk insert/update.
    */
    public static void populateFieldsOnInsert(List<BigMachines__Quote__c> newQuoteList){
        populateFieldsOnUpdate(newQuoteList, null, true);
    }
    public static void populateFieldsOnUpdate(List<BigMachines__Quote__c> newQuoteList, Map<Id,BigMachines__Quote__c> oldMap){
        populateFieldsOnUpdate(newQuoteList, oldMap, false);
    }
    public static void populateFieldsOnUpdate(List<BigMachines__Quote__c> newQuoteList, Map<Id,BigMachines__Quote__c> oldMap, Boolean isInsert){
        //populates sales info fields
        populateSalesInfoFieldsOnQuote(newQuoteList, oldMap, isInsert);
    }
    public static void populateFieldsOnOrderInsertUpdate(List<Order__c> newList, Map<Id, Order__c> oldMap){
        if(oldMap == null){
            populateFieldsOnOrder(newList);
        }
        else{
            updateOpportunitiesStatusOnUpdate(newList, oldMap);
            populateContractLineFields(newList, oldMap);            
        }    
        updateOppRecordType(newList, oldMap);
    }
    //Converts the opp to Gen Record type if it's partner record type
    private static void updateOppRecordType(List<Order__c> newList, Map<Id,Order__c> oldMap){
    	Order__c currentOrder = newList[0];
        System.debug('NKC debug currentOrder.Status__c [' + currentOrder.Status__c + ']');
        System.debug('NKC debug oldMap [' +oldMap + ']');
        if(oldMap != null)
        	System.debug('NKC debug oldMap.get(currentOrder.id).Status__c [' +oldMap.get(currentOrder.id).Status__c + ']');
        if(currentOrder.Status__c == 'Submitted' && (oldMap == null || currentOrder.Status__c != oldMap.get(currentOrder.id).Status__c) 
           	&& currentOrder.Opportunity__c != null){
            Opportunity objOpp = [SELECT RecordType.DeveloperName FROM Opportunity WHERE id=: currentOrder.Opportunity__c];            
            if(objOpp.RecordType.DeveloperName == 'Partner_Opportunity'){
            	List<RecordType> list_OfRecordType = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName = 'GEN_Opportunity_Record_Type_New' AND SObjectType = 'Opportunity'];    
                if(!list_OfRecordType.isEmpty()){
                    Opportunity objOppToBeUpdated = new Opportunity(id = currentOrder.Opportunity__c, RecordTypeId = list_OfRecordType[0].id);
                    Util.Bypass_Trigger_Chk = true;
                    update objOppToBeUpdated;
                    Order__c objOrderToBeUpdated = new Order__c(id = currentOrder.id, Opportunity_Type__c = list_OfRecordType[0].DeveloperName);
                    update objOrderToBeUpdated;
                    Util.Bypass_Trigger_Chk = false;
            	}
            }  
        }        
    }
    public static void populateFieldsOnServiceContract(List<ServiceContract> newList, Map<Id, ServiceContract> oldMap){
        populateFieldsOnServiceContractOnInsert(newList);
    }
    public static void populateOrderInfoOnQuoteOnInsertUpdate(List<Order__c> newList, Map<Id,Order__c> oldMap){
        Order__c currentOrder = newList[0];
        if(currentOrder.Quote__c != null){
            BigMachines__Quote__c quoteToUpdate = [SELECT Order__c, Order_Date_Submitted__c, BigMachines__Opportunity__c FROM BigMachines__Quote__c WHERE id =: currentOrder.Quote__c];
            if(oldMap == null || (currentOrder.Invoiced__c != oldMap.get(currentOrder.id).Invoiced__c)){                
                quoteToUpdate.Order__c = currentOrder.id;               
                quoteToUpdate.Order_Date_Submitted__c = currentOrder.Order_Date__c;
                quoteToUpdate.Order_Special_Instructions__c = currentOrder.Special_Instructions__c;
                quoteToUpdate.Invoiced__c = currentOrder.Invoiced__c;
                update quoteToUpdate;
                //populateOrderInfoOnOppOnInsert(newList, quoteToUpdate.BigMachines__Opportunity__c);
            }
        }
    }
    /*
    private static void populateOrderInfoOnOppOnInsert(List<Order__c> newList, String oppId){
        Order__c currentOrder = newList[0];
        if(oppId == null) return;
        Opportunity currentOpp = new Opportunity(id = oppId);
        currentOpp.Invoice__c = currentOrder.Invoice_Number__c;
        currentOpp.Invoice_Date__c = currentOrder.Invoice_Date__c;
        currentOpp.PO_Number__c = currentOrder.PO_Number__c;
        currentOpp.PO_Date__c = currentOrder.PO_Date__c;        
        update currentOpp;
    }
    */
    private static void updateOpportunitiesStatusOnUpdate(List<Order__c> newList, Map<Id, Order__c> oldMap){   
		//Naresh 06/14/2017 Moved SOQL under if condition, it would save 7 SOQLs on order submission.        
        if(!newList.isEmpty() && newList[0].Quote__c != null && newList[0].Invoiced__c != oldMap.get(newList[0].id).Invoiced__c && newList[0].Invoiced__c){        	
            //4 lines added by Ankit on 4/28/2013
            List<Order__c> currentOrder_lst = [SELECT id, Invoiced__c, Quote__c, Opportunity__c FROM Order__c WHERE id =: newList[0].id];
            Order__c currentOrder;
            if(currentOrder_lst.size()>0){
        		currentOrder =  currentOrder_lst[0];
            
            List<Opportunity> oppsToBeUpdated = new List<Opportunity>(); 
            Set<String> oppIds = new Set<String>();
            for(Quote_Service_Contracts__c eachQuoteSC : [SELECT id, Service_Contract__r.Renewal_Opportunity__c FROM Quote_Service_Contracts__c
            WHERE Quote__c =: currentOrder.Quote__c]){
                if(eachQuoteSC.Service_Contract__r.Renewal_Opportunity__c != null && eachQuoteSC.Service_Contract__r.Renewal_Opportunity__c != currentOrder.Opportunity__c){
                    if(!oppIds.contains(eachQuoteSC.Service_Contract__r.Renewal_Opportunity__c)){
                        Opportunity oppToBeUpdated = new Opportunity(id = eachQuoteSC.Service_Contract__r.Renewal_Opportunity__c);
                        oppToBeUpdated.Opportunity_Status__c = 'Closed-CoTerm';
                        oppsToBeUpdated.add(oppToBeUpdated);
                        oppIds.add(eachQuoteSC.Service_Contract__r.Renewal_Opportunity__c);
                    }
                }
            }
            if(!oppsToBeUpdated.isEmpty())
                update oppsToBeUpdated;
            }
        }
    }
    private static void populateContractLineFields(List<Order__c> newList, Map<Id, Order__c> oldMap){
        System.debug('vikram testing this' );
        Date tempStart;
        Date tempEnd; 
        integer tempTerm;        
        Order__c currentOrder = newList[0];
        
        if(oldMap == null || (currentOrder.Status__c != oldMap.get(currentOrder.id).Status__c && currentOrder.Status__c == 'Approved')
            || (currentOrder.Invoiced__c != oldMap.get(currentOrder.id).Invoiced__c && currentOrder.Invoiced__c)){
                currentOrder = [SELECT id,Decline_Maintenance__c,Invoice_Date__c,Sold_To_Name__r.Name,End_User_Name__r.Name, Maintenance_End__c,Maintenance_Start__c,Sold_To_Name__c,End_User_Name__c,Status__c,Invoice_Number__c, PO_Number__c,Invoiced__c,Original_License_Invoice_Date__c,Name, Quote__c, 
                Quote__r.BigMachines__Opportunity__r.RecordType.DeveloperName,Quote__r.Current_Maint_Rate__c,Quote__r.Order_Numb_of_Maint_Months__c,
                Quote__r.Quote_Business_Type__c FROM Order__c WHERE id =: newList[0].id];
        
                List<BigMachines__Quote_Product__c> quoteLineItems = [SELECT id,
                BigMachines__Quote__c, Original_Net_License_Value__c, Revised_Net_License_Value__c, 
                Sold_To_Name__c, End_User_Name__c, Current_Qty__c, BigMachines__Quantity__c,
                Lic_Invoice__c, Original_PO__c, original_qty__c,Sales_Order__c, Original_License_Invoice_Date__c,
                Maintenance_Due__c, Maintenance_End_Date__c, Maintenance_Start_Date__c, Name,
                Order__r.Sold_To_Name__r.Name, Order__r.End_User_Name__r.Name, Order__r.Maintenance_End__c,
                Order__r.Maintenance_Start__c,BigMachines__Total_Price__c,BigMachines__Sales_Price__c, Order__r.Sold_To_Name__c, 
                Order__r.End_User_Name__c, Service_Contract_Line_ID__c,Annualized_Maintenance_Last_Period__c
                FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: currentOrder.Quote__c];
                
                List<ContractLineItem> contractLineItems = [SELECT id, quote_product__c,Product_Description__c,
                Original_Net_License_value__c, Revised_Net_License_Value__c, Sold_To_Name_Txt__c, End_User_Name_txt__c ,
                Current_Quantity__c, Original_Quantity__c, Lic_Invoice__c, Original_PO__c, Sales_Order__c, 
                Original_License_Invoice_Date__c, Maintenance_Amount__c, Maintenance_End_Date__c, ServiceContract.Flex_Care_Optimization__c,
                Maintenance_Start_Date__c, PricebookEntry.Product2.Name,PricebookEntry.Product2.Type__c             
                FROM ContractLineItem WHERE ServiceContract.Order__c =: currentOrder.id];
                Map<Id, BigMachines__Quote_Product__c> mapNameVsQP = new Map<Id, BigMachines__Quote_Product__c>(); 
                Map<String, ContractLineItem> mapIdVsCLI = new Map<String, ContractLineItem>();
                for(BigMachines__Quote_Product__c eachQP : quoteLineItems){
                                       // mapNameVsQP.put(eachQP.Name+'-UNIQUE KEY-'+eachQP.Original_Qty__c, eachQP);
                                         mapNameVsQP.put(eachQP.id, eachQP);
                                                         mapIdVsCLI.put(eachQP.Service_Contract_Line_ID__c, null);
                }
                List<ContractLineItem> parentCLIs = [Select Actual_Original_Quantity__c,Original_Quantity__c FROM ContractLineItem WHERE id IN : mapIDVsCLI.keyset()];
                mapIdVsCLI.clear();
                for(ContractLineItem eachCLI : parentCLIs){
                    mapIdVsCLI.put(eachCLI.id, eachCLI);    
                }
                List<ContractLineItem> contractLineItmesToBeUpdated = new List<ContractLineItem>(); 
                for(ContractLineItem eachCLI : contractLineItems){
                   //BigMachines__Quote_Product__c quoteProductLine = mapNameVsQP.get(eachCLI.PricebookEntry.Product2.Name+'-UNIQUE KEY-'+eachCLI.Original_Quantity__c);                                                                        
                    
                  BigMachines__Quote_Product__c quoteProductLine = mapNameVsQP.get(eachCLI.Quote_Product__c);
                  System.debug('NKC debug quoteProductLine ['+quoteProductLine+']');
                    if(quoteProductLine == null)    
                      continue; 
                    
                    //System.debug('vikram one' + currentOrder.Quote__r.BigMachines__Opportunity__r.RecordType.DeveloperName + ' ' +ServiceContractUtil.OPP_GEN_NEW_DEV_NAME );
                    if(currentOrder.Quote__r.BigMachines__Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME){
                      eachCLI.Sold_To_Name__c = currentOrder.Sold_To_Name__r.Name;
                        eachCLI.End_User_Name__c = currentOrder.End_User_Name__r.Name;
                        eachCLI.Current_Quantity__c = quoteProductLine.BigMachines__Quantity__c;
                       // System.debug('NKC debug quoteProductLine.Current_Qty__c ['+quoteProductLine.Current_Qty__c+']');
                       // System.debug('NKC debug eachCLI.Current_Quantity__c ['+eachCLI.Current_Quantity__c+']');
                        eachCLI.Original_Quantity__c = quoteProductLine.BigMachines__Quantity__c;
                        eachCLI.Lic_Invoice__c =currentOrder.Invoice_Number__c;
                        eachCLI.Original_PO__c = currentOrder.PO_Number__c;
                       // System.debug('vikram testing'+currentOrder.Name );
                        eachCLI.Sales_Order__c = currentOrder.Name;
                        eachCLI.Original_License_Invoice_Date__c = currentOrder.Invoice_Date__c;
                        eachCLI.Maintenance_Amount__c = quoteProductLine.Maintenance_Due__c;
               
                        eachCLI.Maintenance_End_Date__c = currentOrder.Maintenance_End__c;
                        eachCLI.Maintenance_Start_Date__c = currentOrder.Maintenance_Start__c;                 
                      
                        if(!currentOrder.Decline_Maintenance__c) {      
                         if(eachCLI.PricebookEntry.Product2.Type__c != ServiceContractUtil.MAINTENANCE && eachCLI.PricebookEntry.Product2.Type__c != ServiceContractUtil.GENESYS_CARE) {
                            eachCLI.Original_Net_License_value__c = quoteProductLine.BigMachines__Total_Price__c;
                            eachCLI.Revised_Net_License_Value__c = quoteProductLine.BigMachines__Total_Price__c;
                            if(currentOrder.Quote__r.Quote_Business_Type__c != 'Renewal' && currentOrder.Quote__r.Current_Maint_Rate__c != null && currentOrder.Quote__r.Order_Numb_of_Maint_Months__c != null) {
                                eachCLI.Annualized_Maintenance_Due__c = ((quoteProductLine.BigMachines__Total_Price__c * (currentOrder.Quote__r.Current_Maint_Rate__c/100))/12)*currentOrder.Quote__r.Order_Numb_of_Maint_Months__c;
                            }
            
                // Storing Annualized Maintenance Due as the Previous Annualized Value for Service Contract
                if(quoteProductLine.Annualized_Maintenance_Last_Period__c != null)
                  eachCLI.Previous_Line_Maintenance_Value__c = quoteProductLine.Annualized_Maintenance_Last_Period__c;
                  
                            else if(currentOrder.Quote__r.Order_Numb_of_Maint_Months__c !=0 && eachCLI.Annualized_Maintenance_Due__c != null)                          
                                  eachCLI.Previous_Line_Maintenance_Value__c =  (eachCLI.Annualized_Maintenance_Due__c/currentOrder.Quote__r.Order_Numb_of_Maint_Months__c)*12;
                         
                         }                    
                      }
                  
                        if(eachCLI.PricebookEntry.Product2.Type__c == ServiceContractUtil.MAINTENANCE || eachCLI.PricebookEntry.Product2.Type__c == ServiceContractUtil.GENESYS_CARE) {  
                          eachCLI.Current_Quantity__c = 1;
                          System.debug('NKC debug eachCLI.Current_Quantity__c ['+eachCLI.Current_Quantity__c+']');
                          //eachCLI.Maintenance_Start_Date__c = quoteProductLine.Maintenance_End_Date__c.addMonths(-currentOrder.Quote__r.Order_Numb_of_Maint_Months__c);
                         }    
                       
                        contractLineItmesToBeUpdated.add(eachCLI);
                    }
                    else if(currentOrder.Quote__r.BigMachines__Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME){
                      System.debug('NKC debug eachCLI.PricebookEntry.Product2.Type__c ['+eachCLI.PricebookEntry.Product2.Type__c+']');
                      if(eachCLI.PricebookEntry.Product2.Type__c != ServiceContractUtil.GENESYS_CARE){
                          eachCLI.Original_Net_License_value__c = quoteProductLine.Original_Net_License_Value__c;
                          eachCLI.Revised_Net_License_Value__c = quoteProductLine.Revised_Net_License_Value__c;
                      }
                        eachCLI.Sold_To_Name__c = quoteProductLine.Order__r.Sold_To_Name__c;
                        eachCLI.End_User_Name__c = quoteProductLine.Order__r.End_User_Name__c;
                        
                        eachCLI.Current_Quantity__c = quoteProductLine.Current_Qty__c;
                        
                        System.debug('NKC debug quoteProductLine.Current_Qty__c ['+quoteProductLine.Current_Qty__c+']');
                        System.debug('NKC debug quoteProductLine.Current_Qty__c ['+quoteProductLine.Current_Qty__c+']');
                        System.debug('NKC debug eachCLI.Current_Quantity__c ['+eachCLI.Current_Quantity__c+']');
                        System.debug('NKC debug eachCLI.Original_Quantity__c ['+eachCLI.Original_Quantity__c+']');
                        System.debug('NKC debug eachCLI.Product_Description__c ['+eachCLI.Product_Description__c+']');
                         
                         
                        ContractLineItem parentLineItemToBeUpdated = mapIdVsCLI.get(quoteProductLine.Service_Contract_Line_ID__c);     
                        //System.debug('NKC debug parentLineItemToBeUpdated.Original_Quantity__c ['+parentLineItemToBeUpdated.Original_Quantity__c+']');
                        /*
                        if(parentLineItemToBeUpdated.Actual_Original_Quantity__c == null || parentLineItemToBeUpdated.Actual_Original_Quantity__c ==0) {
                          parentLineItemToBeUpdated.Actual_Original_Quantity__c = parentLineItemToBeUpdated.Original_Quantity__c;
                          contractLineItmesToBeUpdated.add(parentLineItemToBeUpdated);                      
                        }
                        */
                        
                        if(parentLineItemToBeUpdated != null)
                        eachCLI.Actual_Original_Quantity__c = parentLineItemToBeUpdated.Actual_Original_Quantity__c;
                        
                        eachCLI.Original_Quantity__c = quoteProductLine.Current_Qty__c;  
                        eachCLI.Current_Quantity__c = quoteProductLine.Current_Qty__c;                   
                        
                        
                         
                        //eachCLI.Original_Quantity__c = quoteProductLine.Original_Qty__c;
                        eachCLI.Lic_Invoice__c = quoteProductLine.Lic_Invoice__c;
                        eachCLI.Original_PO__c = quoteProductLine.Original_PO__c;
                        eachCLI.Sales_Order__c = quoteProductLine.Sales_Order__c;
                        eachCLI.Original_License_Invoice_Date__c = quoteProductLine.Original_License_Invoice_Date__c;
                        eachCLI.Maintenance_Amount__c = quoteProductLine.Maintenance_Due__c;
                        if(currentOrder.Quote__r.Quote_Business_Type__c != 'Renewal')
                          eachCLI.Annualized_Maintenance_Due__c = quoteProductLine.Maintenance_Due__c;
                        eachCLI.Maintenance_End_Date__c = quoteProductLine.Maintenance_End_Date__c;
                        eachCLI.Maintenance_Start_Date__c = quoteProductLine.Maintenance_Start_Date__c;                 
                        if(eachCLI.ServiceContract.Flex_Care_Optimization__c || (eachCLI.PricebookEntry.Product2.Type__c != ServiceContractUtil.MAINTENANCE 
                            && eachCLI.PricebookEntry.Product2.Type__c != ServiceContractUtil.GENESYS_CARE)) 
            {                              
                                if(quoteProductLine.Annualized_Maintenance_Last_Period__c != null)
                  eachCLI.Previous_Line_Maintenance_Value__c = quoteProductLine.Annualized_Maintenance_Last_Period__c;
                  
                else if(quoteProductLine.Maintenance_Due__c != null && quoteProductLine.Maintenance_Due__c != 0 && 
                                    quoteProductLine.Maintenance_Start_Date__c != null && quoteProductLine.Maintenance_End_Date__c !=null)
                {
                                    tempStart = OrderUtil.adjustDatetoStartofMonth(quoteProductLine.Maintenance_Start_Date__c);
                                    tempEnd = OrderUtil.adjustDatetoStartofMonth(quoteProductLine.Maintenance_End_Date__c);
                                    tempTerm = (12 * (tempEnd.year() - tempStart.year())) + (tempEnd.month() - tempStart.month());
                                    //obj.Maintenance_No_of_Months__c = tempTerm;                           
                                    if(tempTerm != 0)
                                        eachCLI.Previous_Line_Maintenance_Value__c =  (quoteProductLine.Maintenance_Due__c/tempTerm)*12;
                                }
                        }
                       
                        if(eachCLI.PricebookEntry.Product2.Type__c == ServiceContractUtil.MAINTENANCE || eachCLI.PricebookEntry.Product2.Type__c == ServiceContractUtil.GENESYS_CARE) {  
                            eachCLI.Current_Quantity__c = 1;
                            eachCLI.Previous_Line_Maintenance_Value__c = null;
                            eachCLI.Maintenance_Amount__c =null;
                            eachCLI.Maintenance_Start_Date__c = currentOrder.Maintenance_Start__c;
                            if(currentOrder.Quote__r.Quote_Business_Type__c != 'Renewal')
                              eachCLI.Annualized_Maintenance_Due__c = null;
                        }  
                        //System.debug('NKC debug parentLineItemToBeUpdated ['+parentLineItemToBeUpdated+']');
                        contractLineItmesToBeUpdated.add(eachCLI);
                       
                      
                    }
                }
                if(!contractLineItmesToBeUpdated.isEmpty())
                    update contractLineItmesToBeUpdated;
                    
                TriggerFlowManager.ORDER_AFTER_SCLINES_POPULATE = false;
        }       
    }    
    private static void populateFieldsOnServiceContractOnInsert(List<ServiceContract> newSCs){      
        ServiceContract currentServiceContract = new ServiceContract(id = newSCs[0].id);
        if(newSCs[0].Order__c == null) return;
        Order__c currentOrder = [SELECT id, Big_Four__c, Big_Six__c, Sales_Org__c, Direct_Sales_Rep_1__c, 
            Indirect_Sales_Rep_1__c, Maintenance_Start__c, Maintenance_End__c FROM Order__c WHERE id =: newSCs[0].Order__c];         
        currentServiceContract.Big_Four__c = currentOrder.Big_Four__c;
        currentServiceContract.Big_Six__c = currentOrder.Big_Six__c;
        currentServiceContract.Sales_Org__c = currentOrder.Sales_Org__c;
        currentServiceContract.StartDate = currentOrder.Maintenance_Start__c;
        currentServiceContract.EndDate = currentOrder.Maintenance_End__c;       
        update currentServiceContract;              
    }
    private static void populateFieldsOnOrder(List<Order__c> newOrders){
        Order__c currentOrder = new Order__c(id = newOrders[0].id);
        if(newOrders[0].Quote__c == null) return;
        BigMachines__Quote__c quote = [SELECT id, BigMachines__Opportunity__r.RecordType.DeveloperName FROM BigMachines__Quote__c WHERE id =: newOrders[0].Quote__c];        
        currentOrder.Opportunity_Type__c = quote.BigMachines__Opportunity__r.RecordType.DeveloperName;
        update currentOrder;        
    }
    private static void populateSalesInfoFieldsOnQuote(List<BigMachines__Quote__c> newQuoteList, Map<Id,BigMachines__Quote__c> oldMap, Boolean isInsert){
        Map<String, String> mapQuoteIdVsSOId = new Map<String, String>();
        Map<String, Account> mapSOIdVsCountry = new Map<String, Account>();
        Set<String> quoteIds = new Set<String>();
        
        List<BigMachines__Quote__c> quotesToBeUpdated = new List<BigMachines__Quote__c>();  
        for(BigMachines__Quote__c eachQuote : newQuoteList){
            if(eachQuote.Support_Owner__c != null && (isInsert || eachQuote.Support_Owner__c != oldMap.get(eachQuote.id).Support_Owner__c )){
                mapQuoteIdVsSOId.put(eachQuote.id, eachQuote.Support_Owner__c);
            }
            quoteIds.add(eachQuote.id);
        }
        if(mapQuoteIdVsSOId.keyset().size() == 0)
            return;
        newQuoteList = [SELECT id,   Support_Owner__c, Sold_To_Name__r.OwnerId, End_User_ID__r.OwnerId, 
            BigMachines__Opportunity__r.Quote_Mtce_Ops__r.FirstName, BigMachines__Opportunity__r.Quote_Mtce_Ops__r.LastName FROM
            BigMachines__Quote__c WHERE id in : quoteIds];            
               
        for(Account eachAccount : [SELECT id, Country__r.Big_Four__c, Country__r.Big_Six__c, Country__r.Sales_org__c,
            Country__r.SubRU__c, Country__r.RU__c FROM Account WHERE id in : mapQuoteIdVsSOId.values()]){
            mapSOIdVsCountry.put(eachAccount.id, eachAccount);
        }
        for(BigMachines__Quote__c eachQuote : newQuoteList){
            BigMachines__Quote__c quoteToBeUpdated = new BigMachines__Quote__c(id = eachQuote.id);          
            Account suppOwnerRecord = mapSOIdVsCountry.get(mapQuoteIdVsSOId.get(eachQuote.id));
            Boolean quoteAlreadyInList = false;
            if(suppOwnerRecord != null){
                quoteToBeUpdated.Big_Four__c = suppOwnerRecord.Country__r.Big_Four__c;
                quoteToBeUpdated.Big_Six__c = suppOwnerRecord.Country__r.Big_Six__c;
                quoteToBeUpdated.Sales_Org__c = suppOwnerRecord.Country__r.Sales_Org__c;
                quoteToBeUpdated.Genesys_Care_Region__c = suppOwnerRecord.Country__r.RU__c;
                quoteToBeUpdated.Direct_Sales_Rep_1__c = eachQuote.End_User_ID__r.OwnerId;
                quoteToBeUpdated.Indirect_Sales_Rep_1__c = eachQuote.Sold_To_Name__r.OwnerId;  
                //quoteToBeUpdated.Sub_Sub_Region__c = suppOwnerRecord.Country__r.SubRU__c;              
                quotesToBeUpdated.add(quoteToBeUpdated);
                quoteAlreadyInList = true;
            }
            if(quoteToBeUpdated.Genesys_Care_Ops__c == null){
                quoteToBeUpdated.Genesys_Care_Ops__c = eachQuote.BigMachines__Opportunity__r.Quote_Mtce_Ops__r.FirstName + ' ' + eachQuote.BigMachines__Opportunity__r.Quote_Mtce_Ops__r.LastName;
                if(quoteAlreadyInList == false)
                    quotesToBeUpdated.add(quoteToBeUpdated);
            }            
        }
        if(!quotesToBeUpdated.isEmpty()){
            Database.SaveResult[] result = Database.update(quotesToBeUpdated, false);
            Integer counter = 0;
            //Iterate through the Save Results
            for(Database.SaveResult sr:result){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];        
                    quotesToBeUpdated[counter].addError(err.getMessage());
                }
                counter ++;
            }
        }       
    }
    public static void populateAccountInfoFields(List<Order__c> newOrderList){
        BigMachines__Quote__c currentQuote = [SELECT Sold_To_Name__c, Support_Owner__c, Bill_To_Name__c, End_User_ID__c,
            System_Integrator__c, BP_or_MSP_End_User__c, Sold_To_Name__r.Name, End_User_ID__r.Name FROM BigMachines__Quote__c WHERE id =: newOrderList[0].Quote__c];
        //Updating on order
        List<Order__c> orderLinked = [SELECT Maintenance_Start__c,Maintenance_End__c,Sold_To_Name__c, Support_Owner__c, End_User_Name__c, Bill_To_Name__c, System_Integrator__c,
            End_User_ID__c FROM Order__c WHERE id =: newOrderList[0].id order by Name limit 1];
        if(!orderLinked.isEmpty()){
             //if conditions added by Ankit on 6/26/2012
            if(orderLinked[0].Sold_To_Name__c == null)
            orderLinked[0].Sold_To_Name__c = currentQuote.Sold_To_Name__c;
            if(orderLinked[0].Support_Owner__c ==null)
            orderLinked[0].Support_Owner__c = currentQuote.Support_Owner__c;
            if(orderLinked[0].End_User_ID__c ==null)
            orderLinked[0].End_User_Name__c = currentQuote.End_User_ID__c;
            if(orderLinked[0].Bill_To_Name__c==null)
            orderLinked[0].Bill_To_Name__c = currentQuote.Bill_To_Name__c;
            if(orderLinked[0].System_Integrator__c==null)
            orderLinked[0].System_Integrator__c = currentQuote.System_Integrator__c;
            update orderLinked[0]; 
            /*orderLinked[0].Sold_To_Name__c = currentQuote.Sold_To_Name__c;
            orderLinked[0].Support_Owner__c = currentQuote.Support_Owner__c;
            orderLinked[0].End_User_Name__c = currentQuote.End_User_ID__c;
            //changed by ankit on 5/22 for netsuite integration
            if(orderLinked[0].Bill_To_Name__c==null)
            orderLinked[0].Bill_To_Name__c = currentQuote.Bill_To_Name__c;
            orderLinked[0].System_Integrator__c = currentQuote.System_Integrator__c;
            update orderLinked[0]; */
        }
        //Updating on service contract
        List<ServiceContract> scLinked = [SELECT Sold_To_Name__c, Support_Owner__c, End_User_Name__c, Bill_To_Name__c, System_Integrator__c 
            FROM ServiceContract WHERE Quote_Name__c =: currentQuote.id order by Name limit 1];
        if(!scLinked.isEmpty()){
            Boolean updateSC = false;
            if(scLinked[0].Sold_To_Name__c == null){
                scLinked[0].Sold_To_Name__c = currentQuote.Sold_To_Name__c;
                updateSC = true;
            }
            if(scLinked[0].Support_Owner__c == null){
                scLinked[0].Support_Owner__c = currentQuote.Support_Owner__c;
                updateSC = true;
            }
            if(scLinked[0].End_User_Name__c == null){
                scLinked[0].End_User_Name__c = currentQuote.End_User_ID__c;
                updateSC = true;
            }
            if(scLinked[0].Bill_To_Name__c == null){
                scLinked[0].Bill_To_Name__c = currentQuote.Bill_To_Name__c;
                updateSC = true;
            }
            if(scLinked[0].System_Integrator__c == null){
                scLinked[0].System_Integrator__c = currentQuote.System_Integrator__c;
                updateSC = true;
            }
            /*
            if(!orderLinked.isEmpty()) {
              scLinked[0].Maintenance_Start_Date__c = orderLinked[0].Maintenance_Start__c;
              scLinked[0].Maintenance_End_Date__c = orderLinked[0].Maintenance_End__c;
            }
           */ 
            if(updateSC)
                update scLinked[0]; 
        }
    }
    public static void updateFieldsOnServiceContractOnOrderUpdate(List<Order__c> newList, Map<Id, Order__c> oldMap){
        Map<Id, Order__c> orderIdVsOrderMapWithApprovedStatus = new Map<Id, Order__c>();
		for(Order__c eachOrder : newList){
            if((eachOrder.Status__c != oldMap.get(eachOrder.id).Status__c && eachOrder.Status__c == 'Approved')
               || (eachOrder.Invoiced__c != oldMap.get(eachOrder.id).Invoiced__c && eachOrder.Invoiced__c)){
                   orderIdVsOrderMapWithApprovedStatus.put(eachOrder.id, eachOrder);
               }
            List<ServiceContract> scToBeUpdated = new List<ServiceContract>();
            if(!orderIdVsOrderMapWithApprovedStatus.isEmpty()){
                for(ServiceContract eachSC : [SELECT StartDate, EndDate, Order__c FROM ServiceContract WHERE Order__c IN : orderIdVsOrderMapWithApprovedStatus.keyset()]){
                    eachSC.StartDate = orderIdVsOrderMapWithApprovedStatus.get(eachSC.Order__c).Maintenance_Start__c;
                    eachSC.EndDate = orderIdVsOrderMapWithApprovedStatus.get(eachSC.Order__c).Maintenance_End__c;
                    scToBeUpdated.add(eachSC);                              
                }
                if(!scToBeUpdated.isEmpty())
                    update scToBeUpdated;
            }
        }
        
        Set<Id> orderIdsWithCompletedStatus = new Set<Id>();
        for(Order__c eachOrder : newList){
            if((eachOrder.Status__c != oldMap.get(eachOrder.id).Status__c && eachOrder.Status__c == 'Completed')){
                orderIdsWithCompletedStatus.add(eachOrder.id);  
            }
        }
        if(!orderIdsWithCompletedStatus.isEmpty()){  
            
            Map<String, String> OrderRenewedServiceContractIds = new Map<String, String>();
            List<ServiceContract> scToBeUpdated = new List<ServiceContract>();
            for(ServiceContract eachSC : [SELECT Id, Agreement_Status__c, Order__c FROM ServiceContract WHERE Order__c IN : orderIdsWithCompletedStatus]){
                eachSC.Agreement_Status__c = 'Active';
                scToBeUpdated.add(eachSC);
                OrderRenewedServiceContractIds.put(eachSC.Order__c, eachSC.Id);
            }
            
            // Following code block is to update Quote Service Contracts for Renewed_With__c & Status = Closed if it is in "In Negotiation"
            List<ServiceContract> scToBeUpdatedForRenewedWith = new List<ServiceContract>();
            Set<String> uniqueSCIds = new Set<String>();
            for(Quote_Service_Contracts__c eachQSC : [SELECT Service_Contract__c, Quote__c, Quote__r.Order__c, Service_Contract__r.Agreement_Status__c 
                                                      FROM Quote_Service_Contracts__c 
                                                      WHERE Quote__r.Order__c IN : orderIdsWithCompletedStatus AND Service_Contract__c != null])
            {
                if(OrderRenewedServiceContractIds.containsKey(eachQSC.Quote__r.Order__c)){
                    if(!uniqueSCIds.contains(eachQSC.Service_Contract__c)){
                        uniqueSCIds.add(eachQSC.Service_Contract__c);
                        if(eachQSC.Service_Contract__r.Agreement_Status__c == 'In Negotiation'){
                            scToBeUpdatedForRenewedWith.add(new ServiceContract(Id= eachQSC.Service_Contract__c, Renewed_With__c = OrderRenewedServiceContractIds.get(eachQSC.Quote__r.Order__c), Agreement_Status__c = 'Closed'));               
                        } else {
                            scToBeUpdatedForRenewedWith.add(new ServiceContract(Id= eachQSC.Service_Contract__c, Renewed_With__c = OrderRenewedServiceContractIds.get(eachQSC.Quote__r.Order__c)));               
                        }		                    
                    }
                }
            }
            
            if(!scToBeUpdated.isEmpty())
                update scToBeUpdated;
            if(!scToBeUpdatedForRenewedWith.isEmpty())
                update scToBeUpdatedForRenewedWith;
            // Update Genesys Care Offering on Account when Order is Completed
            // Update Auto Renewal Anniversary on Account when Order is Completed if the Current Order is on Auto Quote
            Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
            for(Order_Line_Item__c oli : [SELECT id, Product__r.Description, Contract_Line_Item__r.ServiceContract.Offering_Type__c, Order__r.Quote__r.Name,
                                          Order__r.End_User_Name__c, Order__r.End_User_Name__r.Genesys_Care_Offering__c, 
                                          Order__r.End_User_Name__r.Auto_Renew_Eligible__c, Order__r.End_User_Name__r.Auto_Renew_Contract_Term__c, Order__r.End_User_Name__r.Auto_Renew_Anniversary__c         								  
                                          FROM Order_Line_Item__c 
                                          WHERE Order__c IN :orderIdsWithCompletedStatus 
                                          AND Product__r.Type__c = 'Genesys Care'
                                          AND Contract_Line_Item__r.ServiceContract.Offering_Type__c != 'PureConnect']){
                                              
                                              if(oli.Order__r.End_User_Name__r.Auto_Renew_Eligible__c && oli.Order__r.Quote__r.Name.contains('-A')){
                                                  Integer contractTerm = oli.Order__r.End_User_Name__r.Auto_Renew_Contract_Term__c != NULL ? oli.Order__r.End_User_Name__r.Auto_Renew_Contract_Term__c.intValue() : 12;
                                                  Date autoRenewAnniversary = oli.Order__r.End_User_Name__r.Auto_Renew_Anniversary__c.addMonths(contractTerm);
                                                  accountsToUpdate.put(oli.Order__r.End_User_Name__c, new Account(Id = oli.Order__r.End_User_Name__c, Genesys_Care_Offering__c = oli.Product__r.Description, Auto_Renew_Anniversary__c = autoRenewAnniversary));
                                              } else {
                                                  accountsToUpdate.put(oli.Order__r.End_User_Name__c, new Account(Id = oli.Order__r.End_User_Name__c, Genesys_Care_Offering__c = oli.Product__r.Description));
                                              }                                         		
                                          }
            if(!accountsToUpdate.isEmpty())
                update accountsToUpdate.values();
            
            
            // Update Product Upgrade Requests to Processed 
            Map<String, Set<String>> accountProductsMap = new Map<String, Set<String>>();
            for(Order_Line_Item__c oli : [SELECT id, Order__r.End_User_Name__c, Product__c FROM Order_Line_Item__c 
                                          WHERE Order__c IN :orderIdsWithCompletedStatus 
                                          AND Contract_Line_Item__r.ServiceContract.Offering_Type__c = 'PureConnect']){
                                              if(accountProductsMap.containsKey(oli.Order__r.End_User_Name__c)){
                                                  accountProductsMap.get(oli.Order__r.End_User_Name__c).add(oli.Product__c);	
                                              } else {
                                                  accountProductsMap.put(oli.Order__r.End_User_Name__c, new Set<String>{oli.Product__c});
                                              }                               	
                                          } 
            
            Map<String, List<Product_Upgrade_Request__c>> accountProductUpgradeRequestsMap = new Map<String, List<Product_Upgrade_Request__c>>();
            for(Product_Upgrade_Request__c pur : [SELECT Id, Account__c, Product__c, Type__c, Quantity__c, Processed__c FROM Product_Upgrade_Request__c
                                                  WHERE Account__c IN :accountProductsMap.KeySet() AND Type__c = 'Version' AND Processed__c = false]){
                                                      if(accountProductUpgradeRequestsMap.containsKey(pur.Account__c)){
                                                          accountProductUpgradeRequestsMap.get(pur.Account__c).add(pur);	
                                                      } else {
                                                          accountProductUpgradeRequestsMap.put(pur.Account__c, new List<Product_Upgrade_Request__c>{pur});
                                                      }   											
                                                  }
            
            List<Product_Upgrade_Request__c> versionUpgradeRequestsToUpdate = new List<Product_Upgrade_Request__c>();
            for(String key : accountProductUpgradeRequestsMap.KeySet()){
                List<Product_Upgrade_Request__c> purList = accountProductUpgradeRequestsMap.get(key);
                for(Product_Upgrade_Request__c pur : purList){
                    if(accountProductsMap.get(pur.Account__c).contains(pur.Product__c)){
                        pur.Processed__c = true;
                        versionUpgradeRequestsToUpdate.add(pur);	
                    }
                }
            }
            
            if(versionUpgradeRequestsToUpdate.size() > 0)	
                Database.update(versionUpgradeRequestsToUpdate);	
            
            createDropDownsizeShelvedSCsOnOrderComplete(orderIdsWithCompletedStatus);
            updateDropSCOnReinstatement(orderIdsWithCompletedStatus);            
        }
	}
    public static void populateOrder(List<Order__c> newOrderList,List<Order__c> oldOrderList) {
    if(!newOrderList.isEmpty()) {
       List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
       if(newOrderList[0].Invoice_Number__c != oldOrderList[0].Invoice_Number__c) {
       Order__c ord = [Select Opportunity__c,Quote__r.Genesys_Care__c,Opportunity__r.Name, Quote__r.BigMachines__Is_Primary__c from Order__c where id=:newOrderList[0].id];
       
       System.debug('vv'+ ord.Quote__r.BigMachines__Is_Primary__c);   
       if(ord.Opportunity__r.Name !=null && ord.Quote__r.BigMachines__Is_Primary__c) {
        Opportunity oppToBeUpdated = new Opportunity(id =ord.Opportunity__c);
      
        oppToBeUpdated.Invoice_Date__c = newOrderList[0].Invoice_Date__c;
        oppToBeUpdated.Invoice__c = newOrderList[0].Invoice_Number__c;
        oppToBeUpdated.PO_Date__c = newOrderList[0].PO_Date__c;
        oppToBeUpdated.PO_Number__c = newOrderList[0].PO_Number__c;  
        /*
        if(newOrderList[0].status__c =='Order Submitted' || newOrderList[0].status__c == 'Approved' || newOrderList[0].status__c =='Submitted') {
         oppToBeUpdated.Opportunity_Status__c = 'Renewed';
         oppToBeUpdated.StageName ='6.Closed';
        }
        */
         
         oppsToBeUpdated.add(oppToBeUpdated);
      
      
      
     // Check what version of Genesys Care
        
      
      }
    }
    if(!oppsToBeUpdated.isEmpty())
     update oppsToBeUpdated;
   }
  }
  
  public static void populateInvoiceInfoOnSCLineItems(Map<Id, Order__c> newMap, Map<Id, Order__c> oldMap){
      Set<Id> updatedOrderIds = new Set<Id>();
      Map<Id, Order__c> newRefreshedMap = new Map<Id, Order__c>([SELECT Invoice_Number__c, Opportunity__r.RecordType.DeveloperName FROM Order__c
        WHERE id in : newMap.keyset()]);
      for(Order__c eachOrder : newRefreshedMap.values()){
          //In case of license opp only
          if(eachOrder.Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && eachOrder.Invoice_Number__c != oldMap.get(eachOrder.id).Invoice_Number__c)
              updatedOrderIds.add(eachOrder.id);
      }
      if(updatedOrderIds.isEmpty())
          return;
      List<ContractLineItem> contLineItems = [SELECT Lic_Invoice__c, Original_License_Invoice_Date__c,
              Order_Line_Item__r.Order__c FROM ContractLineItem WHERE Order_Line_Item__r.Order__c IN : updatedOrderIds];
      
      Map<Id, List<ContractLineItem>> mapOrderIdVsCLIs = new Map<Id, List<ContractLineItem>>();
      for(ContractLineItem eachCLI : contLineItems){
          Id orderId = eachCLI.Order_Line_Item__r.Order__c;
          if(mapOrderIdVsCLIs.get(orderId) == null){
              List<ContractLineItem> newList = new List<ContractLineItem>();
              newList.add(eachCLI);
              mapOrderIdVsCLIs.put(orderId, newList); 
          }
          else{
              mapOrderIdVsCLIs.get(orderId).add(eachCLI);        
          }      
      }
      List<ContractLineItem> cliToBeUpdated = new List<ContractLineItem>();
      for(Id orderId : updatedOrderIds){
          List<ContractLineItem> contLineItems1 = mapOrderIdVsCLIs.get(orderId);
          if(contLineItems1 == null)
              continue;
          for(ContractLineItem eachCLI : contLineItems1){
              eachCLI.Lic_Invoice__c = newMap.get(orderId).Invoice_Number__c;
              eachCLI.Original_License_Invoice_Date__c = newMap.get(orderId).Invoice_Date__c;
              cliToBeUpdated.add(eachCLI);    
          }          
      }
      if(!cliToBeUpdated.isEmpty())
          update cliToBeUpdated;
  }
    
  public static void populateGenesysCare(List<BigMachines__Quote__c> newQuoteList,Map<Id, BigMachines__Quote__c> oldQuoteMap) {
     List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
     if(!newQuoteList.isEmpty()) {  
       if(newQuoteList[0].BigMachines__Is_Primary__c) {
         Opportunity oppToBeUpdated = new Opportunity(id=newQuoteList[0].BigMachines__Opportunity__c);
         
         if(newQuoteList[0].Genesys_Care__c != null && newQuoteList[0].Genesys_Care__c.contains('Basic')) 
          oppToBeUpdated.Quote_Genesys_Care__c ='Basic';
        
         if(newQuoteList[0].Genesys_Care__c != null && newQuoteList[0].Genesys_Care__c.contains('Premium')) 
          oppToBeUpdated.Quote_Genesys_Care__c ='Premium'; 
       
        if(newQuoteList[0].Genesys_Care__c != null && newQuoteList[0].Genesys_Care__c.contains('Business')) 
          oppToBeUpdated.Quote_Genesys_Care__c ='Business';
          
        /*
         if(newQuoteList[0].BigMachines__Status__c == 'Quote In Progress' || newQuoteList[0].BigMachines__Status__c == 'Quote Rejected' ||  newQuoteList[0].BigMachines__Status__c == 'Quote Expired') {
           oppToBeUpdated.Opportunity_Status__c ='In Progress';  
         }         
         if(newQuoteList[0].BigMachines__Status__c == 'Quote Pending Approval' || newQuoteList[0].BigMachines__Status__c == 'Quote Approved'  ||  newQuoteList[0].BigMachines__Status__c == 'Quote Expired') {
            oppToBeUpdated.Opportunity_Status__c ='Quoted';  
         }
         */      
         oppToBeUpdated.Hardware_Total__c = newQuoteList[0].Total_Hardware__c;                    
          oppsToBeUpdated.add(oppToBeUpdated);
       }       
     }
     if(!oppsToBeUpdated.isEmpty()){
        TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER = true;
        update oppsToBeUpdated;
     }
   }
  
  //Update the quote value fields on opp of each primary business quote
  //Suman 11202013
  
  public static void populateQuoteValues(List<BigMachines__Quote__c> newQuoteList,Map<Id, BigMachines__Quote__c> oldQuoteMap) 
  {
     List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
     set<id> setOppIds = new Set<id>();//to make sure same opp is not added twice to list,this shouldn't happen
     
     if(!newQuoteList.isEmpty()) 
     {  
       for(BigMachines__Quote__c quo: newQuoteList)
        {   
           if(quo.Is_Business_Primary__c) 
           {
             Opportunity oppToBeUpdated = new Opportunity(id=quo.BigMachines__Opportunity__c);
             
             if(quo.Quote_Business_Type__c=='Hybrid') 
                oppToBeUpdated.Hybrid_Quote_Value__c =quo.BigMachines__Total_Amount__c;
            
             else if(quo.Quote_Business_Type__c=='On Premise') 
                oppToBeUpdated.On_Premise_Quote_Value__c =quo.BigMachines__Total_Amount__c;
           
             else if(quo.Quote_Business_Type__c=='Cloud') 
                oppToBeUpdated.Cloud_Quote_Value__c =quo.BigMachines__Total_Amount__c;
            if(!setOppIds.contains(quo.BigMachines__Opportunity__c))                        
              oppsToBeUpdated.add(oppToBeUpdated);
           }       
       }
     }
     if(!oppsToBeUpdated.isEmpty())
     {
        TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER = true;
        update oppsToBeUpdated;
     }
  }
    
    // ADDED BY RAO FOR CREATING DROP/ DOWNSIZE/ Service Contracts on Order Completed
    // Moved the code from trigger BigMachines_Quote_After on BigMachines__Quote__c
    public static void createDropDownsizeShelvedSCsOnOrderComplete(Set<Id> orderIds){
        List<BigMachines__Quote__c> quotes = [SELECT id, Name from BigMachines__Quote__c WHERE Order__c IN :orderIds];
        for(BigMachines__Quote__c q : quotes){
            QuoteSplitDrop.createDropSplit(q.id,'Drop');
            QuoteSplitDrop.createDropSplit(q.id,'Shelved');
            QuoteSplitDrop.createDropSplit(q.id,'Downsize');
        }
    } 
  
    // ADDED BY RAO FOR REINSTATEMENT PROCESS WHEN DROP SC ARE CO-TERMED
    @future
    public static void updateDropSCOnReinstatement(Set<Id> orderIds){
        // Get all Quotes from orders
        Set<String> quoteIds = new Set<String>();
        for(Order__c o : [SELECT id, Quote__c, Quote__r.Name FROM Order__c WHERE id  IN :orderIds]){
            quoteIds.add(o.Quote__c);
        }
        
        // Get Quote Products which are reinstated:
        Map<String, String> serviceContractQuoteIds = new Map<String, String>();
        Map<String, BigMachines__Quote_Product__c> ContractLineItemReinstateQtys = new Map<String, BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c p : [SELECT id, Name, Current_Qty__c, Original_Qty__c, 
                                               Contract_Line_Update_Status__c, Service_Contract_Line__c, Service_Contract_Line__r.ServiceContractId,
                                               BigMachines__Quote__c, CurrencyIsoCode  
                                        FROM BigMachines__Quote_Product__c 
                                        WHERE BigMachines__Quote__c IN :quoteIds 
                                                             AND Contract_Line_Update_Status__c  = 'Reinstate'
                                                            AND Current_Qty__c > 0 ]){
            ContractLineItemReinstateQtys.put(p.Service_Contract_Line__c, p);
            serviceContractQuoteIds.put(p.Service_Contract_Line__r.ServiceContractId, p.BigMachines__Quote__c);                                                    
        }
        
        // Get the Contract Lines from Drop Service Contract:
        List<ContractLineItem> contractLineItems = [SELECT id, Original_Dropped_Qty__c, Current_Quantity__c, Original_Quantity__c, Product_Description__c, Lic_Invoice__c,
                                                    Actual_Original_Quantity__c, ServiceContractId,
                                                    Revised_Net_License_Value__c, Maintenance_Amount__c, Previous_Line_Maintenance_Value__c
                                                FROM ContractLineItem WHERE Id IN :ContractLineItemReinstateQtys.keySet()];
        Set<String> serviceContractIds = new Set<String>();
  
        List<Service_Contract_Histrory__c> historyRecords = new List<Service_Contract_Histrory__c>();
        // Update quantities on Drop Service Contract Line Items
        for(ContractLineItem c: contractLineItems){
            BigMachines__Quote_Product__c p = ContractLineItemReinstateQtys.get(c.Id);
            // perform amount calculations here ...
            serviceContractIds.add(c.ServiceContractId);
            if(c.Original_Dropped_Qty__c == NULL || c.Original_Dropped_Qty__c == 0){
                c.Original_Dropped_Qty__c = c.Current_Quantity__c;
            }
            
            Integer resinstateQty = (Integer)p.Current_Qty__c;
            Integer updatedDroppedQty = (Integer)c.Current_Quantity__c - resinstateQty;
            Double previousNetLicense = c.Revised_Net_License_Value__c;
            Double revisedNetLicense = 0.0;
            Double previousAnnualizedMaintenanceDue = c.Previous_Line_Maintenance_Value__c;
            Double revisedAnnualizedMaintenanceDue = 0.0;
            Double revisedMaintenanceAmount = 0.0;
                
            if(c.Revised_Net_License_Value__c != NULL && c.Revised_Net_License_Value__c > 0 && c.Current_Quantity__c > 0){
                revisedNetLicense = (c.Revised_Net_License_Value__c / c.Current_Quantity__c) * (c.Current_Quantity__c - (Integer)p.Current_Qty__c);
            }
            if(c.Previous_Line_Maintenance_Value__c != NULL && c.Previous_Line_Maintenance_Value__c > 0 && c.Current_Quantity__c > 0){
                revisedAnnualizedMaintenanceDue = (c.Previous_Line_Maintenance_Value__c / c.Current_Quantity__c) * (c.Current_Quantity__c - (Integer)p.Current_Qty__c);
            }
            if(c.Maintenance_Amount__c != NULL && c.Maintenance_Amount__c > 0 && c.Current_Quantity__c > 0){
                revisedMaintenanceAmount = (c.Maintenance_Amount__c / c.Current_Quantity__c) * (c.Current_Quantity__c - (Integer)p.Current_Qty__c);
            }

            c.Maintenance_Amount__c = revisedMaintenanceAmount;
            c.Revised_Net_License_Value__c = revisedNetLicense;
            c.Previous_Line_Maintenance_Value__c = revisedAnnualizedMaintenanceDue;
                
            Service_Contract_Histrory__c scHistroyRecord = new Service_Contract_Histrory__c(
                                                                    Service_Contract__c = c.ServiceContractId,
                                                                    Related_Line_Item__c = c.Id,
                                                                    Reference_Quote__c = p.BigMachines__Quote__c,
                                                                    Original_Dropped_Qty__c = c.Original_Dropped_Qty__c,
                                                                    Product__c = c.Product_Description__c,
                                                                    Original_License_Invoice__c = c.Lic_Invoice__c,
                                                                    Reinstated_Qty__c = resinstateQty,
                                                                    Updated_Dropped_Qty__c = updatedDroppedQty,
                                                                    Previous_Net_License__c = previousNetLicense,
                                                                    Revised_Net_License__c = revisedNetLicense,
                                                                    Previous_Annualized_Maintenance_Due__c = previousAnnualizedMaintenanceDue,
                                                                    Revised_Annualized_Maintenance_Due__c = revisedAnnualizedMaintenanceDue,
                                                                    CurrencyIsoCode = p.CurrencyIsoCode,
                                                                    Change_Date__c = System.now()
                                                            );
            historyRecords.add(scHistroyRecord);
            c.Current_Quantity__c = c.Current_Quantity__c - (Integer)p.Current_Qty__c;
            c.Original_Quantity__c = c.Current_Quantity__c;
        }
        Update contractLineItems;
        insert historyRecords;
        
        
        // Find Renewal Opportunities to be recreated
        Set<String> serviceContractIdsNeedsOpps = new Set<String>();
        for(ContractLineItem cli : [SELECT id, ServiceContractId FROM ContractLineItem 
                                    WHERE ServiceContractId IN :serviceContractIds AND Current_Quantity__c > 0]){
            serviceContractIdsNeedsOpps.add(cli.ServiceContractId);            
        }
        List<Service_Contract_Renewal_Opportunity_Map__c> scOppsHistoryList = new List<Service_Contract_Renewal_Opportunity_Map__c>();
        // Get the Opportunity from Drop Service Contract:
        List<ServiceContract> serviceContracts = [SELECT id, Renewal_Opportunity__c, Renewal_Opportunity__r.Name 
                                                  FROM ServiceContract WHERE id IN :serviceContractIdsNeedsOpps];
        Map<String, Opportunity> opportunitiesMap = new Map<String, Opportunity>();

        for(ServiceContract sc: serviceContracts){
            Opportunity originalOpp = (Opportunity)Database.query(CloneUtil.getCreatableFieldsSOQL('Opportunity','id=\''+sc.Renewal_Opportunity__c +'\''));
            scOppsHistoryList.add(new Service_Contract_Renewal_Opportunity_Map__c(Opportunity__c = sc.Renewal_Opportunity__c, Service_Contract__c= sc.id, Quote__c = serviceContractQuoteIds.get(sc.id)));
            
            Opportunity newOpp = originalOpp.clone(false, true);    
            String oppName = newOpp.Name;
            if(oppName.length() > 114){
               oppName = oppName.substring(0,114); 
            }
            
            if(oppName.indexOf('- D') > 0){
               String firstPart = oppName.substring(0, oppName.indexOf('- D'));
               String secondPart = oppName.substring(oppName.indexOf('- D')+3);
               oppName = firstPart + '- D' + (Integer.valueOf(secondPart)+1); 
            } else {
               oppName = oppName + '- D1';  
            }
            // Update with new Name
            newOpp.Name = oppName;
            if(newOpp.Name.startsWithIgnoreCase('Drop'))
                newOpp.Opportunity_Status__c = 'Dropped';
            else if (newOpp.Name.startsWithIgnoreCase('Downsize'))
                newOpp.Opportunity_Status__c = 'Downsize';
            else if (newOpp.Name.startsWithIgnoreCase('Shelved'))
                newOpp.Opportunity_Status__c = 'Shelved';
            else
                newOpp.Opportunity_Status__c = 'Dropped';
            // Update Split_Parent_Quote__c 
            newOpp.Split_Parent_Quote__c = serviceContractQuoteIds.get(sc.id);
            // Update status to blank
            newOpp.Quote_Quote_Status__c = '';
            opportunitiesMap.put(sc.id, newOpp);
        }
        
        if(opportunitiesMap.size() > 0){
            database.insert(opportunitiesMap.values());
            database.insert(scOppsHistoryList);
            for(ServiceContract sc: serviceContracts){
                 sc.Renewal_Opportunity__c = opportunitiesMap.get(sc.Id).Id;
            }
            database.update(serviceContracts);
        }
        
        // Finally add history for Completely reinstated contracts
        Set<String> completelyReinstatedSCIDs = new Set<String>();
        for(String sId : serviceContractIds){
            if(!serviceContractIdsNeedsOpps.contains(sId)){
                completelyReinstatedSCIDs.add(sId);
            }
        }
        if(completelyReinstatedSCIDs.size() > 0){
            List<Service_Contract_Renewal_Opportunity_Map__c> completelyReinstatedSCsOppsHistoryList = new List<Service_Contract_Renewal_Opportunity_Map__c>();
            List<ServiceContract> completelyReinstatedSCs = [SELECT id, Renewal_Opportunity__c, Renewal_Opportunity__r.Name 
                              FROM ServiceContract WHERE id IN :completelyReinstatedSCIDs];
            
            for(ServiceContract sc: completelyReinstatedSCs){
                completelyReinstatedSCsOppsHistoryList.add(new Service_Contract_Renewal_Opportunity_Map__c(Opportunity__c = sc.Renewal_Opportunity__c, Service_Contract__c= sc.id, Quote__c = serviceContractQuoteIds.get(sc.id)));
            }
            database.insert(completelyReinstatedSCsOppsHistoryList);
        }
    }
}