//Naresh Kumar  08/17/2016
public without sharing class OpportunityCrossSellExpensionHelper{
    
    @future
    public static void populateQuoteSCMapping(Id quoteId){
        populateQuoteSCMapping(quoteId, false);
    }
    public static void populateQuoteSCMapping(Id quoteId, Boolean isBatch){
        //Delete existing records if any
        List<Quote_Service_Contract_CrosSell_Mapping__c> quoteProductSCMappingsToBeDeleted = [SELECT id FROM 
            Quote_Service_Contract_CrosSell_Mapping__c WHERE Quote_Product__r.BigMachines__Quote__c =: quoteId];        
        if(!quoteProductSCMappingsToBeDeleted.isEmpty())
            delete quoteProductSCMappingsToBeDeleted;
        //Query all quote products     
        List<BigMachines__Quote_Product__c> quoteProducts = [SELECT id, BigMachines__Product__c, 
            BigMachines__Quote__r.BigMachines__Opportunity__c, BigMachines__Quote__r.BigMachines__Opportunity__r.AccountId,
            BigMachines__Product__r.Product_Financial__c, BigMachines__Quantity__c, BigMachines__Quote__r.Order_Date_Submitted__c 
            FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId AND BigMachines__Product__r.Product_Financial__c != null 
            AND BigMachines__Product__r.Product_Financial__c != ''];
        //Return if there is no quote product with above filters
        if(quoteProducts.isEmpty())
            return;
        //Getting account id
        String accountId = quoteProducts[0].BigMachines__Quote__r.BigMachines__Opportunity__r.AccountId;
        //Getting opportunity id
        String oppId = quoteProducts[0].BigMachines__Quote__r.BigMachines__Opportunity__c;
        //Quote submitted Date
        DateTime quoteSubmittedDate = quoteProducts[0].BigMachines__Quote__r.Order_Date_Submitted__c;
        //Map will hold product financial value and quote products for that value
        Map<String, List<BigMachines__Quote_Product__c>> mapOfProductFinancialVsQPs = new Map<String, List<BigMachines__Quote_Product__c>>();
        //Map will hold product financial value and total quote products quantities for that value
        Map<String, Decimal> mapOfProductFinancialVsQPQuantities = new Map<String, Decimal>();
        //Looping over each quote product and populating map.
        for(BigMachines__Quote_Product__c eachQP : quoteProducts){
            String productFinancial = eachQP.BigMachines__Product__r.Product_Financial__c;              
            if(mapOfProductFinancialVsQPs.get(productFinancial) == null){
                List<BigMachines__Quote_Product__c> newList = new List<BigMachines__Quote_Product__c>();
                newList.add(eachQP);
                mapOfProductFinancialVsQPs.put(productFinancial, newList);
            }
            else{
                mapOfProductFinancialVsQPs.get(productFinancial).add(eachQP);
            }
            Decimal quantity = (eachQP.BigMachines__Quantity__c == null ? 0 : eachQP.BigMachines__Quantity__c);
            if(mapOfProductFinancialVsQPQuantities.get(productFinancial) == null){
                mapOfProductFinancialVsQPQuantities.put(productFinancial, quantity);
            }
            else{
                Decimal quantityTemp = mapOfProductFinancialVsQPQuantities.get(productFinancial);
                quantityTemp += quantity;
                mapOfProductFinancialVsQPQuantities.put(productFinancial, quantityTemp);
            }
        }   
        //Querying contract line item for the same account and 
        List<ContractLineItem> scLineItems = [SELECT id, PricebookEntry.Product2Id, PricebookEntry.Product2.Product_Financial__c, Quantity FROM ContractLineItem WHERE
            ServiceContract.AccountId =: accountId //AND PricebookEntry.Product2.Product_Financial__c IN : mapOfProductFinancialVsQPs.keyset()
            AND (ServiceContract.Agreement_Status__c = 'Active' OR ServiceContract.Agreement_Status__c = 'Closed'
            OR ServiceContract.Agreement_Status__c = 'Pending') AND ServiceContract.Order__r.Quote__c !=: quoteId 
            AND ServiceContract.Order__r.Name LIKE 'Order%' 
            AND ServiceContract.Order__r.Opportunity__r.RecordType.DeveloperName = 'GEN_Opportunity_Record_Type_New'
            AND ServiceContract.CreatedDate <: quoteSubmittedDate];
        //Map will hold financial value and contract line items
        Map<String, List<ContractLineItem>> mapOfProductFinancialVsCLIs = new Map<String, List<ContractLineItem>>();     
        //Map will hold product financial value and total contract line item quantities for that value
        Map<String, Decimal> mapOfProductFinancialVsCLIQuantities = new Map<String, Decimal>();
        //Populate map only if there are contract line items   
        if(!scLineItems.isEmpty()){        
            //Looping over each contrat line item to populate the map 
            for(ContractLineItem eachLineItem : scLineItems){
                String productFinancial = eachLineItem.PricebookEntry.Product2.Product_Financial__c;              
                if(mapOfProductFinancialVsCLIs.get(productFinancial) == null){
                    List<ContractLineItem> newList = new List<ContractLineItem>();
                    newList.add(eachLineItem);
                    mapOfProductFinancialVsCLIs.put(productFinancial, newList);
                }
                else{
                    mapOfProductFinancialVsCLIs.get(productFinancial).add(eachLineItem);
                }  
                Decimal quantity = (eachLineItem.Quantity == null ? 0 : eachLineItem.Quantity);
                if(mapOfProductFinancialVsCLIQuantities.get(productFinancial) == null){
                    mapOfProductFinancialVsCLIQuantities.put(productFinancial, quantity);
                }
                else{
                    Decimal quantityTemp = mapOfProductFinancialVsCLIQuantities.get(productFinancial);
                    quantityTemp += quantity;
                    mapOfProductFinancialVsCLIQuantities.put(productFinancial, quantityTemp);
                }  
            }
        }
        System.debug('NKC debug mapOfProductFinancialVsQPs.keyset() [' + mapOfProductFinancialVsQPs.keyset() + ']');
        //List will hold record which needs to be inserted
        List<Quote_Service_Contract_CrosSell_Mapping__c> recordsToBeInserted = new List<Quote_Service_Contract_CrosSell_Mapping__c>();
        List<BigMachines__Quote_Product__c> quoteProductsToBeUpdated = new List<BigMachines__Quote_Product__c>();
        //Opportunity type
        String opportunityType;
        //Looping over each product financial value
        for(String eachProductFinancial : mapOfProductFinancialVsQPs.keyset()){
            //Getting quote products from map.
            List<BigMachines__Quote_Product__c> quoteLines = mapOfProductFinancialVsQPs.get(eachProductFinancial);
            //Getting contract line items from map if any
            List<ContractLineItem> scLines = mapOfProductFinancialVsCLIs.get(eachProductFinancial);
            Quote_Service_Contract_CrosSell_Mapping__c newItem = new Quote_Service_Contract_CrosSell_Mapping__c();
            //Quote Product quantities 
            Decimal quoteProductQuantities = mapOfProductFinancialVsQPQuantities.get(eachProductFinancial);
            //Contract line item quantities 
            Decimal contractLineItemQuantities = mapOfProductFinancialVsCLIQuantities.get(eachProductFinancial);
            String quoteProductType;
            newItem.Quote_Product__c = quoteLines[0].id; 
            //Type = NEW 
            System.debug('NKC debug scLines [' + scLines + ']');    
            if(scLines == null){  
                 //System.debug('NKC debug I am not null scLines [' + scLines + ']'); 
                if(mapOfProductFinancialVsCLIs.keyset().size() == 0)              
                    newItem.Type__c = 'New';
                else{                
                    newItem.Type__c = 'Cross Sell';
                    opportunityType = 'Existing Business - Cross Sell';
                }
                quoteProductType = newItem.Type__c;
                recordsToBeInserted.add(newItem);
            }           
            else{
                for(ContractLineItem eachCLI : scLines){
                    Quote_Service_Contract_CrosSell_Mapping__c newItem1 = new Quote_Service_Contract_CrosSell_Mapping__c();
                    newItem1.Quote_Product__c = quoteLines[0].id;
                    
                   // if(quoteProductQuantities >= contractLineItemQuantities){
                     
                     if(contractLineItemQuantities !=0 && (quoteProductQuantities/contractLineItemQuantities >=2)) {
                          newItem1.Type__c = 'Expansion on Cross sell';
                          opportunityType = 'Existing Business - Cross Sell';
                      }    
                        else  {
                          newItem1.Type__c = 'Expansion';
                          
                           if(opportunityType == null)
                            opportunityType = 'Existing Business - Expansion';
                          
                        }  
                        
                     /*   if(opportunityType == null)
                            opportunityType = 'Existing Business - Expansion';
                    }
                    
                    else{
                        newItem1.Type__c = 'Cross Sell';
                        if(opportunityType == null)
                            opportunityType = 'Existing Business - Cross Sell';
                    }
                   */
                    
                    newItem1.Contract_Line_Item__c = eachCLI.id;
                    quoteProductType = newItem1.Type__c;
                    recordsToBeInserted.add(newItem1);
                }
            }
            
            for(BigMachines__Quote_Product__c eachQP : quoteLines){
                BigMachines__Quote_Product__c quoteProductToBeUpdated = new BigMachines__Quote_Product__c(id = eachQP.id);
                quoteProductToBeUpdated.CrosSell_Expension__c = quoteProductType;
                quoteProductsToBeUpdated.add(quoteProductToBeUpdated);  
            }   
        }       
        
        System.debug('NKC debug recordsToBeInserted [' + recordsToBeInserted + ']');    
        //Inserting mapping records      
        if(!recordsToBeInserted.isEmpty())
            insert recordsToBeInserted;       
        if(!quoteProductsToBeUpdated.isEmpty()){
            update quoteProductsToBeUpdated;
        } 
        if(opportunityType != null){
            Opportunity oppToBeUpdated = new Opportunity( id = oppId  );
            if(isBatch)
                oppToBeUpdated.Type_New__c = opportunityType;
            else
                oppToBeUpdated.Type = opportunityType;
            update oppToBeUpdated;            
        }
        
        //Querying all quote products and creating a map to populate crossell/expansion on opportunity lines
        quoteProducts = [SELECT id, BigMachines__Product__r.APN_Number__c, CrosSell_Expension__c   
            FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId AND Bundle_Line__c = null];
        Map<String, BigMachines__Quote_Product__c> mapOfAPNVsQuoteProduct = new Map<String, BigMachines__Quote_Product__c>();
        
        for(BigMachines__Quote_Product__c eachQP : quoteProducts){
            mapOfAPNVsQuoteProduct.put(eachQP.BigMachines__Product__r.APN_Number__c, eachQP);   
        }    
               
        List<OpportunityLineItem> oppLines = [SELECT id, PricebookEntry.Product2.APN_Number__c
            FROM OpportunityLineItem WHERE OpportunityId =: oppId];
        
        List<OpportunityLineItem> oppLinesToBeUpdated = new List<OpportunityLineItem>();
        for(OpportunityLineItem eachItem : oppLines){
            BigMachines__Quote_Product__c quoteProduct = mapOfAPNVsQuoteProduct.get(eachItem.PricebookEntry.Product2.APN_Number__c);
            if(quoteProduct != null){
                OpportunityLineItem newOppLine = new OpportunityLineItem(id = eachItem.id);
                newOppLine.CrosSell_Expension__c = quoteProduct.CrosSell_Expension__c;
                oppLinesToBeUpdated.add(newOppLine);    
            }
        }
        if(!oppLinesToBeUpdated.isEmpty())
            update oppLinesToBeUpdated;
            
    }
}