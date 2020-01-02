//Naresh Kumar  10/09/2015
    public without sharing class SMLBatchHelper {    
        public static void populateData(List<Account> accounts){
            
            Set<Id> setOfAccountIds = new Set<Id>();
            //Looping over each account
            for(Account eachAccount : accounts){
                setOfAccountIds.add(eachAccount.id);
            }        
            //try{
              
              System.debug('NKC debug setOfAccountIds ['+setOfAccountIds+']');
                //Map<String, String> mapOfKeyVsStatus = new Map<String, String>();  
                //Map<String, SML_Data__c> mapOfKeyVsSML = new Map<String, SML_Data__c>();                      
                
                //Map<String, SML_Data__c> mapOfKeyVsExistingSML = getExistingSMLData(setOfAccountIds);
                updateSMLRealTime(setOfAccountIds);
                /*                        
                //Updating Active Oppotunities
                upsertSMLForOpportunity(setOfAccountIds, mapOfKeyVsStatus, mapOfKeyVsSML); 
                //Updating SML Data from Quotes
                upsertSMLForQuotes(setOfAccountIds, mapOfKeyVsStatus, mapOfKeyVsSML, mapOfKeyVsExistingSML);
                //Updating SML Data from Orders
                upsertSMLForOrders(setOfAccountIds, mapOfKeyVsStatus, mapOfKeyVsSML, mapOfKeyVsExistingSML);
                //Updating competitor info
                upsertBlockedOnes(setOfAccountIds, mapOfKeyVsStatus, mapOfKeyVsSML); 
                System.debug('NKC debug setOfAccountIds ['+setOfAccountIds+']');                      
                //Updating Maintenenace
                updateUnderMaintenanceSML(setOfAccountIds);
                 */                                 
                //Calculating engagement score
                //Naresh 12/08/2015 No need to call this method as we moved it to SML trigger itself
                //calculateEngagementScore(setOfAccountIds);
                /*
            }
            catch(Exception ex){
                SMLHelperWTS.insertBatchLog(null, SMLHelper.whileRunningBatch, 'Errors : ' + ex.getMessage() + ', Failed for account ids : ' + String.valueOf(setOfAccountIds));
            }     
              */        
        }
        
        public static void initializeSMLData(Set<Id> setOfAccountIds){
            //Querying all solutions categories
            List<Solution_Category__c> solutionCategories = [SELECT Name FROM Solution_Category__c WHERE Active__c = true];
            //Querying SML Data
            List<SML_Data__c> smlData = [SELECT Account__c, Solution_Category__c FROM SML_Data__c WHERE Account__c IN : setOfAccountIds];
            //Account Map
            Map<Id, Account> accountIdVsAccount = new Map<Id, Account>([SELECT id, OwnerId FROM Account WHERE id IN : setOfAccountIds]); 
            Map<String, SML_Data__c> mapAccountCategoryVsSMLData = new Map<String, SML_Data__c>();
            //Looping over each SML Data
            for(SML_Data__c eachData : smlData){
                String key = String.valueOf(eachData.Account__c) + String.valueOf(eachData.Solution_Category__c);
                mapAccountCategoryVsSMLData.put(key, eachData);                 
            }       
            List<SML_Data__c> smlsToBeInserted = new List<SML_Data__c>();
            //Looping over each account
            for(Id eachAccountId : setOfAccountIds){
                //Looping over each solution category
                for(Solution_Category__c eachSolutionCategory : solutionCategories){
                    String key = String.valueOf(eachAccountId) + String.valueOf(eachSolutionCategory.id);
                    if(mapAccountCategoryVsSMLData.get(key) == null){
                        SML_Data__c newRecord = new SML_Data__c();
                        newRecord.Account__c = eachAccountId;
                        newRecord.Solution_Category__c = eachSolutionCategory.id; 
                        newRecord.AccountSCKey__c = String.valueOf(eachAccountId) + String.valueOf(eachSolutionCategory.id);
                        newRecord.Whitespace_Date__c = System.today();       
                        if(accountIdVsAccount.get(eachAccountId) != null)
                          newRecord.OwnerId = accountIdVsAccount.get(eachAccountId).OwnerId;             
                        smlsToBeInserted.add(newRecord);    
                    }
                }            
            }
            
            if(!smlsToBeInserted.isEmpty()){
                List<Database.SaveResult> listOfResults = Database.insert(smlsToBeInserted);
                Integer counter = 0;
                List<SML_Batch_Log__c> smlBatchLog = new List<SML_Batch_Log__c>();
                for(Database.SaveResult eachSR : listOfResults){                
                    if(!eachSR.isSuccess()){
                        String errorDetails;
                        for(Database.Error err : eachSr.getErrors()){
                            errorDetails = err.getStatusCode() + ': ' + err.getMessage() + '   ';
                        }
                        SMLHelperWTS.addInsertBatchLog(smlBatchLog, String.valueOf(smlsToBeInserted[counter].Account__c), SMLHelper.whileInitData, errorDetails);
                    }
                    counter ++;
                }
                if(!smlBatchLog.isEmpty())
                  insert smlBatchLog;
            }
            
        }
        
        public static Boolean doExcludeProduct(String productEnvironment){
            if(productEnvironment == null)
                return false;
            List<String> keywords = Label.SML_Exclude_Products.split(';');
            for(String eachKeyword : keywords){
                if(productEnvironment.containsIgnoreCase(eachKeyword))
                    return true;                
            }
            return false;
        }
        
        public static void upsertSMLForOpportunity(Set<Id> setOfAccountIds, Map<String, String> mapOfKeyVsStatus, Map<String, SML_Data__c> mapOfKeyVsSML,
          Map<String, SML_Data__c> mapOfKeyVsExistingSML){
          List<OpportunityLineItem> activeOppLineItems = [SELECT id, Opportunity.AccountId, OpportunityId, Opportunity.Account.OwnerId, Opportunity.CurrencyIsoCode,
            PriceBookentry.Product2.Solution_Category1__c, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.Environment__c, PriceBookEntry.Product2.Type__c,
            UnitPrice, Quantity, Quantity__c FROM OpportunityLineItem 
                WHERE Opportunity.StageName != : SMLHelper.OPP_STAGE_CLOSED 
                AND Opportunity.RecordType.DeveloperName = 'GEN_Opportunity_Record_Type_New' 
                AND Opportunity.AccountId IN : setOfAccountIds
                AND PriceBookentry.Product2.Solution_Category1__c != null];
                
            //Removing existing opportunity sml data
            List<Opportunity_SML_Data__c> opportunitySMLDataToBeDeleted = [SELECT id FROM Opportunity_SML_Data__c WHERE Opportunity__r.accountId IN : setOfAccountIds];
            if(!opportunitySMLDataToBeDeleted.isEmpty())
              delete opportunitySMLDataToBeDeleted;
              
            Set<String> setOfKeys = new Set<String>();        
            Map<String, SML_Data__c> mapOfKeyVsSMLData = new Map<String, SML_Data__c>();
            List<Opportunity_SML_Data__c> opportunitySMLDataToBeInserted = new List<Opportunity_SML_Data__c>();
            Map<String, priceInfo> mapOfSMLIdVsOppInfo = new Map<String, priceInfo>();
            Map<String, List<OpportunityLineItem>> mapOfASCVsOLIs = new Map<String, List<OpportunityLineItem>>();
            List<SML_Data__c> smlDataToBeUpserted = new List<SML_Data__c>();
            //Looping over each Opportunity
            for(OpportunityLineItem eachLineItem : activeOppLineItems){
              if(doExcludeProduct(eachLineItem.PriceBookEntry.Product2.Environment__c))
                continue;
                SML_Data__c smlData = new SML_Data__c();
                smlData.Account__c = eachLineItem.Opportunity.accountId;
                smlData.Solution_Category__c = eachLineItem.PriceBookentry.Product2.Solution_Category1__c;
                
                String key = String.valueOf(smlData.Account__c) + String.valueOf(smlData.Solution_Category__c) + String.valueOf(eachLineItem.OpportunityId);
                if(mapOfKeyVsSMLData.containsKey(key))
                    continue;
                 
                smlData.AccountSCKey__c = String.valueOf(smlData.Account__c) + String.valueOf(smlData.Solution_Category__c);
                if(mapOfKeyVsStatus.get(smlData.AccountSCKey__c) == SMLHelper.SOLD || mapOfKeyVsStatus.get(smlData.AccountSCKey__c) == SMLHelper.ACTIVEANDSOLD)
                      smlData.Status__c = SMLHelper.ACTIVEANDSOLD;
                    else
                      smlData.Status__c = SMLHelper.ACTIVE;
                mapOfKeyVsStatus.put(smlData.AccountSCKey__c, smlData.Status__c);            
                smlData.OwnerId = eachLineItem.Opportunity.Account.ownerId; 
                smlData.currencyIsoCode = eachLineItem.Opportunity.currencyIsoCode;
                
                Opportunity_SML_Data__c newOppSMLData = new Opportunity_SML_Data__c();  
                newOppSMLData.SML_Data__c = mapOfKeyVsExistingSML.get(smlData.AccountSCKey__c).id;
                newOppSMLData.Opportunity__c = eachLineItem.OpportunityId;
                opportunitySMLDataToBeInserted.add(newOppSMLData);
                
                mapOfKeyVsSMLData.put(smlData.AccountSCKey__c, smlData); 
                //if(mapOfKeyVsSML != null)        
                mapOfKeyVsSML.put(smlData.AccountSCKey__c, smlData);
                
                String key1 = String.valueOf(smlData.Account__c) + String.valueOf(smlData.Solution_Category__c);
                if(mapOfASCVsOLIs.get(key1) == null){
                  smlDataToBeUpserted.add(smlData);
                  List<OpportunityLineItem> newList = new List<OpportunityLineItem>();
                  newList.add(eachLineItem);
                  mapOfASCVsOLIs.put(key1, newList);
                } 
                else{
                  mapOfASCVsOLIs.get(key1).add(eachLineItem);
                } 
                System.debug(LoggingLevel.INFO, 'NKC debug mapOfASCVsOLIs ['+mapOfASCVsOLIs+']');
            }
            
            if(!opportunitySMLDataToBeInserted.isEmpty()){
              insert opportunitySMLDataToBeInserted;
            }
            
            for(SML_Data__c eachSMLData : smlDataToBeUpserted){
                String key = eachSMLData.AccountSCKey__c;
                if(mapOfASCVsOLIs.get(key) != null){
                    Double oppTotal = 0;
                    Decimal totalQuantity = 0;
                    Double oppTotalCloud = 0;
                    Decimal totalQuantityCloud = 0;
                    List<OpportunityLineItem> oppLineItems = mapOfASCVsOLIs.get(key);
                    for(OpportunityLineItem eachLineItem : oppLineItems){
                      if(mapOfSMLIdVsOppInfo.get(key) != null){
                            oppTotal = mapOfSMLIdVsOppInfo.get(key).totalPrice;
                            totalQuantity = mapOfSMLIdVsOppInfo.get(key).quantity;
                            oppTotalCloud = mapOfSMLIdVsOppInfo.get(key).totalPriceCloud;
                            totalQuantityCloud = mapOfSMLIdVsOppInfo.get(key).quantityCloud;    
                        }
                        if(eachLineItem.PriceBookEntry.Product2.Type__c == 'Cloud'){                            
                            oppTotalCloud +=  eachLineItem.UnitPrice;  
                            totalQuantityCloud += (eachLineItem.Quantity__c == null ? 0 : eachLineItem.Quantity__c);
                        }
                        else{
                            oppTotal +=  eachLineItem.UnitPrice;  
                            totalQuantity += (eachLineItem.Quantity__c == null ? 0 : eachLineItem.Quantity__c);
                        }  
                        priceInfo pi = new priceInfo();
                        pi.totalPrice = oppTotal;
                        pi.quantity = totalQuantity;
                        pi.totalPriceCloud = oppTotalCloud;
                        pi.quantityCloud = totalQuantityCloud;
                        mapOfSMLIdVsOppInfo.put(key, pi);
                    }           
                }
            }           
            List<SML_Data__c> smlsToBeUpdated = new List<SML_Data__c>();
            //Updating SML totals
            for(String eachKey : mapOfSMLIdVsOppInfo.keyset()){
              System.debug(LoggingLevel.INFO, 'NKC debug eachKey ['+eachKey+']');
                if(eachKey == null)
                    continue;
                SML_Data__c smlData = new SML_Data__c(AccountSCKey__c = eachKey);
                smlData.Opportunity_Total__c = mapOfSMLIdVsOppInfo.get(eachKey).totalPrice; 
                smlData.Opportunity_Quantity__c = mapOfSMLIdVsOppInfo.get(eachKey).quantity;
                smlData.Cloud_Opportunity_Total__c = mapOfSMLIdVsOppInfo.get(eachKey).totalPriceCloud;
                smlData.Cloud_Opportunity_Quantity__c = mapOfSMLIdVsOppInfo.get(eachKey).quantityCloud;                 
                smlsToBeUpdated.add(smlData);
            }  
            System.debug(LoggingLevel.INFO, 'NKC debug smlsToBeUpdated ['+smlsToBeUpdated+']');
            
            updateUpsertSMLData(smlsToBeUpdated, 'Upsert', SMLHelper.whileUpdatingSMLDataFromOpps);
            //if(mapOfKeyVsSML == null){
          //    smlDataToBeUpserted = mapOfKeyVsSMLData.values();
              //Upserting sml data 
          //    smlDataToBeUpserted = updateUpsertSMLData(smlDataToBeUpserted, 'Upsert');
            //}
        }
        
        public static void upsertSMLForQuotes(Set<Id> setOfAccountIds, Map<String, String> mapOfKeyVsStatus, Map<String, SML_Data__c> mapOfKeyVsSML, 
          Map<String, SML_Data__c> mapOfKeyVsExistingSML){      
            //Getting quote products from primary in progress quote
            List<BigMachines__Quote_Product__c> quoteProducts = [SELECT BigMachines__Product__r.Solution_Category1__c, SML_Data__c,
                BigMachines__Quote__r.End_User_ID__c, BigMachines__Quote__r.End_User_ID__r.OwnerId, BigMachines__Total_Price__c,
                BigMachines__Quantity__c, BigMachines__Quote__r.currencyIsoCode, BigMachines__Product__r.Name, ACV_Equivalent__c,
                 BigMachines__Product__r.Environment__c, BigMachines__Product__r.Type__c FROM BigMachines__Quote_Product__c
                WHERE BigMachines__Quote__r.BigMachines__Is_Primary__c = true            
                AND BigMachines__Quote__r.BigMachines__Status__c != 'Order Accepted'
                AND BigMachines__Quote__r.BigMachines__Opportunity__r.RecordType.DeveloperName = 'GEN_Opportunity_Record_Type_New'             
                AND BigMachines__Quote__r.End_User_ID__c IN : setOfAccountIds 
                AND BigMachines__Product__r.Solution_Category1__c != null
                AND BigMachines__Quote__r.BigMachines__Opportunity__r.StageName !=: SMLHelper.OPP_STAGE_CLOSED];
            List<SML_Data__c> smlDataToBeUpserted = new List<SML_Data__c>();
            Map<String, List<BigMachines__Quote_Product__c>> mapOfASCVsQPs = new Map<String, List<BigMachines__Quote_Product__c>>(); 
            
            //Looping over each quote product
            for(BigMachines__Quote_Product__c eachQP : quoteProducts){
                if(doExcludeProduct(eachQP.BigMachines__Product__r.Environment__c))
                  continue;  
                    SML_Data__c smlData = new SML_Data__c();
                    smlData.Account__c = eachQP.BigMachines__Quote__r.End_User_ID__c;
                    smlData.Solution_Category__c = eachQP.BigMachines__Product__r.Solution_Category1__c;
                    smlData.AccountSCKey__c = String.valueOf(smlData.Account__c) + String.valueOf(smlData.Solution_Category__c);
            if(mapOfKeyVsExistingSML.get(smlData.AccountSCKey__c) != null)                  
                      smlData.id = mapOfKeyVsExistingSML.get(smlData.AccountSCKey__c).id;
                    if(mapOfKeyVsStatus.get(smlData.AccountSCKey__c) == SMLHelper.SOLD || mapOfKeyVsStatus.get(smlData.AccountSCKey__c) == SMLHelper.ACTIVEANDSOLD)
                      smlData.Status__c = SMLHelper.ACTIVEANDSOLD;
                    else
                      smlData.Status__c = SMLHelper.ACTIVE;                
                    mapOfKeyVsStatus.put(smlData.AccountSCKey__c, smlData.Status__c);
                    System.debug('NKC debug eachQP.BigMachines__Quote__r.End_User_ID__r.OwnerId [' + eachQP.BigMachines__Quote__r.End_User_ID__r.OwnerId + ']');
                    smlData.OwnerId = eachQP.BigMachines__Quote__r.End_User_ID__r.OwnerId; 
                    smlData.currencyIsoCode = eachQP.BigMachines__Quote__r.currencyIsoCode;             
                    //Populating map which will be used to update quote products
                    if(mapOfASCVsQPs.get(smlData.AccountSCKey__c) == null){
                        smlDataToBeUpserted.add(smlData);
                        List<BigMachines__Quote_Product__c> newList = new List<BigMachines__Quote_Product__c>();
                        newList.add(eachQP);
                        mapOfASCVsQPs.put(smlData.AccountSCKey__c, newList);     
                    }
                    else{
                        mapOfASCVsQPs.get(smlData.AccountSCKey__c).add(eachQP);
                    }
                    //if(mapOfKeyVsSML != null)
                    mapOfKeyVsSML.put(smlData.AccountSCKey__c, smlData);
                
            }
            //if(mapOfKeyVsSML == null){
              //Upserting sml data  
              //smlDataToBeUpserted = updateUpsertSMLData(smlDataToBeUpserted, 'Upsert');
            //}
        if(!setOfAccountIds.isEmpty()){        
              List<BigMachines__Quote_Product__c> quoteProductsToBeUnReferenced = [SELECT SML_Data__c FROM BigMachines__Quote_Product__c WHERE 
                SML_Data__c != null AND BigMachines__Quote__r.End_User_ID__c IN : setOfAccountIds];
              //Looping over each quote product to remove existing refrence of SML
              for(BigMachines__Quote_Product__c eachQP :  quoteProductsToBeUnReferenced){
                eachQP.SML_Data__c = null;
              }
              if(!quoteProductsToBeUnReferenced.isEmpty())
                update quoteProductsToBeUnReferenced;
        }
            List<BigMachines__Quote_Product__c> quoteProductsToBeUpdated = new List<BigMachines__Quote_Product__c>(); 
            Map<String, priceInfo> mapOfSMLIdVsQuoteInfo = new Map<String, priceInfo>();
            //Updating references on quote products
            for(SML_Data__c eachSMLData : smlDataToBeUpserted){
                String key = eachSMLData.AccountSCKey__c;
                Double quoteTotal = 0;
                Decimal totalQuantity = 0;
                Double quoteTotalCloud = 0;
                Decimal totalQuantityCloud = 0;
                
                if(mapOfASCVsQPs.get(key) != null){
                    for(BigMachines__Quote_Product__c eachQP : mapOfASCVsQPs.get(key)){
                        BigMachines__Quote_Product__c newQP = new BigMachines__Quote_Product__c();
                        newQP.id = eachQP.id;
                        newQP.SML_Data__c = eachSMLData.id;
                        quoteProductsToBeUpdated.add(newQP);                    
                        
                        if(mapOfSMLIdVsQuoteInfo.get(eachSMLData.id) != null){
                            quoteTotal = mapOfSMLIdVsQuoteInfo.get(eachSMLData.id).totalPrice;
                            totalQuantity = mapOfSMLIdVsQuoteInfo.get(eachSMLData.id).quantity;  
                            quoteTotalCloud = mapOfSMLIdVsQuoteInfo.get(eachSMLData.id).totalPriceCloud;
                            totalQuantityCloud = mapOfSMLIdVsQuoteInfo.get(eachSMLData.id).quantityCloud;      
                        }
                        if(eachQP.BigMachines__Product__r.Type__c == 'Cloud'){                            
                            //quoteTotalCloud +=  eachQP.BigMachines__Total_Price__c;
                            quoteTotalCloud +=  eachQP.ACV_Equivalent__c;  
                            totalQuantityCloud += eachQP.BigMachines__Quantity__c ;
                        }
                        else{
                            quoteTotal +=  eachQP.BigMachines__Total_Price__c;  
                            totalQuantity += eachQP.BigMachines__Quantity__c ;
                        } 
                           
                        priceInfo pi = new priceInfo();
                        pi.totalPrice = quoteTotal;
                        pi.quantity = totalQuantity;
                        pi.totalPriceCloud = quoteTotalCloud;
                        pi.quantityCloud = totalQuantityCloud;                        
                        mapOfSMLIdVsQuoteInfo.put(eachSMLData.id, pi);                        
                    }           
                }
            }           
            //Updating references on quote products
            if(!quoteProductsToBeUpdated.isEmpty())
                update quoteProductsToBeUpdated;
            List<SML_Data__c> smlsToBeUpdated = new List<SML_Data__c>();
            //Updating SML totals
            for(Id eachId : mapOfSMLIdVsQuoteInfo.keyset()){
                if(eachId == null)
                    continue;
                SML_Data__c smlData = new SML_Data__c(id = eachId);
                smlData.Quote_Total__c = mapOfSMLIdVsQuoteInfo.get(eachId).totalPrice; 
                smlData.Quote_Quantity__c = mapOfSMLIdVsQuoteInfo.get(eachId).quantity; 
                smlData.Cloud_Quote_Total__c = mapOfSMLIdVsQuoteInfo.get(eachId).totalPriceCloud; 
                smlData.Cloud_Quote_Quantity__c = mapOfSMLIdVsQuoteInfo.get(eachId).quantityCloud;                
                smlsToBeUpdated.add(smlData);
            }  
            updateUpsertSMLData(smlsToBeUpdated, 'Update', SMLHelper.whileUpdatingSMLDataFromQuotes);
            
        }
        
        public static void upsertSMLForOrders(Set<Id> setOfAccountIds, Map<String, String> mapOfKeyVsStatus, Map<String, SML_Data__c> mapOfKeyVsSML, 
          Map<String, SML_Data__c> mapOfKeyVsExistingSML){
            //Getting order line items
            List<Order_Line_Item__c> orderLineItems = [SELECT id, Name, Product__r.Solution_Category1__c, Order__r.End_User_Name__c,
                Order__r.End_User_Name__r.OwnerId, Total_Price__c, Extended_Net_Price__c, BigMachines_Quantity__c, Order__r.currencyIsoCode,
                Product__r.Name, Product__r.Description__c, Product__r.Environment__c, Product__r.Type__c
                FROM Order_Line_Item__c WHERE Order__r.End_User_Name__c IN : setOfAccountIds  
                AND Product__r.Type__c !='Genesys Care' 
                AND Order__r.License_FYM_detail__c != 'Maintenance Only Order'              
                AND Order__r.Opportunity__r.RecordType.id !='012U0000000M1eQ' //Genesys Renewal
                AND Product__r.Type__c !='3RD PARTY CD' 
                AND Product__r.Type__c !='CD/DVD'
                AND Order__r.Bypass_Entitlements__c != true
                AND (Order__r.Status__c =: SMLHelper.ORDER_STATUS_APPROVED 
                  OR Order__r.Status__c =: SMLHelper.ORDER_STATUS_COMPLETED
                  OR Order__r.Status__c =: SMLHelper.ORDER_STATUS_SEND_TO_ERP)  
                AND Product__r.Solution_Category1__c != null
                AND (Order__r.Opportunity__r.RecordType.DeveloperName = 'GEN_Opportunity_Record_Type_New'          
                OR SML__c = true)
                AND Order__r.SML_Not_Include__c = false];         
                
            Set<Id> setOfOrderId = new Set<Id>();
            for(Order_Line_Item__c eachOLI : orderLineItems){
                setOfOrderId.add(eachOLI.Order__c);
            }
            
            List<ContractLineItem> contracts = [SELECT ServiceContract.AccountId, PricebookEntry.Product2.Solution_Category1__c,
              PricebookEntry.Product2.Name, PricebookEntry.Product2.Description__c, PricebookEntry.Product2.Environment__c FROM ContractLineItem 
                WHERE ServiceContract.Agreement_Status__c = 'Active' 
                AND PricebookEntry.Product2.Solution_Category1__c != null 
                AND ServiceContract.AccountId IN : setOfAccountIds];
                
            Set<String> setOfSCKey = new Set<String>();
            for(ContractLineItem eachCLI : contracts){
                if(doExcludeProduct(eachCLI.PricebookEntry.Product2.Environment__c))
                continue;
                String key = String.valueOf(eachCLI.ServiceContract.AccountId) + String.valueOf(eachCLI.PricebookEntry.Product2.Solution_Category1__c);
                System.debug('NKC debug key [' + key + ']');
                setOfSCKey.add(key);
            }          
            
            List<SML_Data__c> smlDataToBeUpserted = new List<SML_Data__c>();
            Map<String, List<Order_Line_Item__c>> mapOfASCVsOLIs = new Map<String, List<Order_Line_Item__c>>();        
            //Looping over each quote product
            for(Order_Line_Item__c eachOLI : orderLineItems){
              if(doExcludeProduct(eachOLI.Product__r.Environment__c))
                  continue;
                SML_Data__c smlData = new SML_Data__c();
                smlData.Account__c = eachOLI.Order__r.End_User_Name__c;
                smlData.Solution_Category__c = eachOLI.Product__r.Solution_Category1__c;
                String key = String.valueOf(smlData.Account__c) + String.valueOf(smlData.Solution_Category__c);
                smlData.AccountSCKey__c = key;
                if(mapOfKeyVsExistingSML.get(smlData.AccountSCKey__c) != null)
                  smlData.id = mapOfKeyVsExistingSML.get(smlData.AccountSCKey__c).id;
                System.debug('NKC debug mapOfKeyVsStatus.get(smlData.AccountSCKey__c) [' + mapOfKeyVsStatus.get(smlData.AccountSCKey__c) + ']');
                if(mapOfKeyVsStatus.get(smlData.AccountSCKey__c) == SMLHelper.ACTIVE || mapOfKeyVsStatus.get(smlData.AccountSCKey__c) == SMLHelper.ACTIVEANDSOLD)
                    smlData.Status__c = SMLHelper.ACTIVEANDSOLD;
                else{
                    System.debug('NKC debug key [' + key + ']');
                    System.debug('NKC debug setOfSCKey [' + setOfSCKey + ']');
                    if(setOfSCKey.contains(key))
                        smlData.Status__c = SMLHelper.SOLD;
                    else
                        smlData.Status__c = SMLHelper.SOLD_NO_MAINTENANCE;
                } 
                mapOfKeyVsStatus.put(smlData.AccountSCKey__c, smlData.Status__c);
                smlData.OwnerId = eachOLI.Order__r.End_User_Name__r.OwnerId; 
                smlData.currencyIsoCode = eachOLI.Order__r.currencyIsoCode;
                //Populating map which will be used to update quote products
                if(mapOfASCVsOLIs.get(smlData.AccountSCKey__c) == null){
                  smlDataToBeUpserted.add(smlData);
                    List<Order_Line_Item__c> newList = new List<Order_Line_Item__c>();
                    newList.add(eachOLI);
                    mapOfASCVsOLIs.put(smlData.AccountSCKey__c, newList);     
                 }
                 else{
                   mapOfASCVsOLIs.get(smlData.AccountSCKey__c).add(eachOLI);
                 }            
                 //if(mapOfKeyVsSML != null)
                 mapOfKeyVsSML.put(smlData.AccountSCKey__c, smlData);
            }
            //if(mapOfKeyVsSML == null)
            //  smlDataToBeUpserted = updateUpsertSMLData(smlDataToBeUpserted, 'Upsert');    
          if(!setOfAccountIds.isEmpty()){  
              List<Order_Line_Item__c> orderLinesToBeUnReferenced = [SELECT SML_Data__c FROM Order_Line_Item__c WHERE 
                SML_Data__c != null AND Order__r.End_User_Name__c IN : setOfAccountIds];
              //Looping over each quote product to remove existing refrence of SML
              for(Order_Line_Item__c eachOLI :  orderLinesToBeUnReferenced){
                eachOLI.SML_Data__c = null;
              }
              if(!orderLinesToBeUnReferenced.isEmpty())
                update orderLinesToBeUnReferenced;
            }      
            List<Order_Line_Item__c> orderLineItemsToBeUpdated = new List<Order_Line_Item__c>(); 
            Map<Id, priceInfo> mapOfSMLIdVsOrderInfo = new Map<Id, priceInfo>();                
            //Updating references on quote products
            for(SML_Data__c eachSMLData : smlDataToBeUpserted){
                String key = eachSMLData.AccountSCKey__c;
                System.debug('NKC debug key [' + key + ']');
                if(mapOfASCVsOLIs.get(key) != null){
                    Double smlTotal = 0;
                    Decimal quantityTotal = 0;
                    Double smlTotalCloud = 0;
                    Decimal quantityTotalCloud = 0;                    
                    for(Order_Line_Item__c eachOLI : mapOfASCVsOLIs.get(key)){
                        Order_Line_Item__c newOLI = new Order_Line_Item__c();
                        newOLI.id = eachOLI.id;
                        newOLI.SML_Data__c = eachSMLData.id;                    
                        orderLineItemsToBeUpdated.add(newOLI);   
                        System.debug('NKC debug smlTotal [' + smlTotal + ']');
                        if(mapOfSMLIdVsOrderInfo.get(eachSMLData.id) != null){
                            smlTotal = mapOfSMLIdVsOrderInfo.get(eachSMLData.id).totalPrice;
                            quantityTotal = mapOfSMLIdVsOrderInfo.get(eachSMLData.id).quantity == null ? 0 : mapOfSMLIdVsOrderInfo.get(eachSMLData.id).quantity;
                            smlTotalCloud = mapOfSMLIdVsOrderInfo.get(eachSMLData.id).totalPriceCloud;
                            quantityTotalCloud = mapOfSMLIdVsOrderInfo.get(eachSMLData.id).quantityCloud == null ? 0 : mapOfSMLIdVsOrderInfo.get(eachSMLData.id).quantityCloud;
                            
                        }
                        if(eachOLI.Extended_Net_Price__c == null)
                            eachOLI.Extended_Net_Price__c = 0;
                        if(eachOLI.Product__r.Type__c == 'Cloud'){
                            smlTotalCloud +=  (eachOLI.Total_Price__c == 0 ? eachOLI.Extended_Net_Price__c : eachOLI.Total_Price__c);     
                            quantityTotalCloud += (eachOLI.BigMachines_Quantity__c == null ? 0 : eachOLI.BigMachines_Quantity__c);
                        }
                        else{
                            smlTotal +=  (eachOLI.Total_Price__c == 0 ? eachOLI.Extended_Net_Price__c : eachOLI.Total_Price__c);     
                            quantityTotal += (eachOLI.BigMachines_Quantity__c == null ? 0 : eachOLI.BigMachines_Quantity__c);
                        }
                        priceInfo pi = new priceInfo();
                        pi.totalPrice = smlTotal;
                        pi.quantity = quantityTotal;
                        pi.totalPriceCloud = smlTotalCloud;
                        pi.quantityCloud = quantityTotalCloud;                        
                        mapOfSMLIdVsOrderInfo.put(eachSMLData.id, pi);                                     
                    }           
                }
            }       
            //Updating references on quote products
            if(!orderLineItemsToBeUpdated.isEmpty()){
                update orderLineItemsToBeUpdated;
            }        
            List<SML_Data__c> smlsToBeUpdated = new List<SML_Data__c>();
            //Updating SML totals
            for(Id eachId : mapOfSMLIdVsOrderInfo.keyset()){
                if(eachId == null)
                    continue;            
                SML_Data__c smlData = new SML_Data__c(id = eachId);
                smlData.Order_Total__c = mapOfSMLIdVsOrderInfo.get(eachId).totalPrice; 
                smlData.Order_Quantity__c = mapOfSMLIdVsOrderInfo.get(eachId).quantity;  
                smlData.Cloud_Order_Total__c = mapOfSMLIdVsOrderInfo.get(eachId).totalPriceCloud; 
                smlData.Cloud_Order_Quantity__c = mapOfSMLIdVsOrderInfo.get(eachId).quantityCloud;  
                
                smlsToBeUpdated.add(smlData);
            }  
            smlsToBeUpdated = updateUpsertSMLData(smlsToBeUpdated, 'Update', SMLHelper.whileUpdatingSMLDataFromOrders);                  
        }
        
        public static void upsertBlockedOnes(Set<Id> setOfAccountIds, Map<String, String> mapOfKeyVsStatus, Map<String, SML_Data__c> mapOfKeyVsSML){
            List<SML_Data__c> smlDataToBeUpserted = new List<SML_Data__c>();
            //Getting competitors
            List<Technical_Profile_Competitors__c> competitors = [SELECT id, Product_Category__c, Technical_Profile__r.Account__c,
                Competitor__c FROM Technical_Profile_Competitors__c WHERE Technical_Profile__r.Account__c IN : setOfAccountIds];
            for(Technical_Profile_Competitors__c eachCompetitor : competitors){
                SML_Data__c smlData = new SML_Data__c();
                smlData.AccountSCKey__c = String.valueOf(eachCompetitor.Technical_Profile__r.Account__c) + String.valueOf(eachCompetitor.Product_Category__c);  
                smlData.Competitors__c = eachCompetitor.Competitor__c;
                if(eachCompetitor.Competitor__c != null && eachCompetitor.Competitor__c != ''){
                  smlData.Technical_Profile_Competitor__c = eachCompetitor.id;            
                  smlData.Status__c = SMLHelper.BLOCKED;
                }
                mapOfKeyVsStatus.put(smlData.AccountSCKey__c, smlData.Status__c);
                smlDataToBeUpserted.add(smlData);
                //if(mapOfKeyVsSML != null)
                  mapOfKeyVsSML.put(smlData.AccountSCKey__c, smlData);
                           
            } 
            //if(mapOfKeyVsSML != null)
            //  smlDataToBeUpserted = updateUpsertSMLData(smlDataToBeUpserted, 'Upsert');             
        }
        
        public static void calculateEngagementScore(Set<Id> setOfAccountIds){
            List<SML_Data__c> smlData1 = [SELECT Account__c, Solution_Category__c, Status__c FROM SML_Data__c WHERE Account__c IN : setOfAccountIds];
            Map<String, List<SML_Data__c>> mapOfAccountIdVsSMLData = new Map<String, List<SML_Data__c>>();
            //Looping over each data
            for(SML_Data__c eachData : smlData1){
                if(mapOfAccountIdVsSMLData.get(eachData.Account__c) == null){
                    List<SML_Data__c> newList = new List<SML_Data__c>();
                    newList.add(eachData);
                    mapOfAccountIdVsSMLData.put(eachData.Account__c, newList); 
                }
                else{
                    mapOfAccountIdVsSMLData.get(eachData.Account__c).add(eachData);
                }
            }
            List<SML_Account_Engagement_Score__c> accountEngagementScoresToBeInserted = new List<SML_Account_Engagement_Score__c>();
            //Looping over each Account 
            for(String eachAccountId : mapOfAccountIdVsSMLData.keyset()){
                List<SML_Data__c> smlData = mapOfAccountIdVsSMLData.get(eachAccountId);
                //Total # of categories
                Integer totalSize = smlData.size();
                Integer noOfNA = 0, noOfActive = 0, noOfBlocked = 0, noOfSold = 0, noOfWhiteSpace = 0, noOfSoldActive = 0; 
                Decimal noPlanningUnderway = 0;
                //Looping over each reocrd
                for(SML_Data__c eachData : smlData){
                    if(eachData.Status__c == SMLHelper.NA)
                        noOfNA ++;
                    else if(eachData.Status__c == SMLHelper.ACTIVE)
                        noOfActive ++;
                    else if(eachData.Status__c == SMLHelper.SOLD)
                        noOfSold ++;
                    else if(eachData.Status__c == SMLHelper.BLOCKED)
                        noOfBlocked ++;
                    else if(eachData.Status__c == SMLHelper.ACTIVEANDSOLD) 
                        noOfSoldActive ++;
                    else if(eachData.Status__c == SMLHelper.PLANNING_UNDERWAY) 
                        noPlanningUnderway ++; 
                    else 
                        noOfWhiteSpace ++;              
                }
                /*
                System.debug('NKC debug noOfNA [' + noOfNA + ']');
                System.debug('NKC debug noOfActive [' + noOfActive + ']');
                System.debug('NKC debug noOfSold [' + noOfSold + ']');
                System.debug('NKC debug noOfBlocked [' + noOfBlocked + ']');
                System.debug('NKC debug noOfSoldActive [' + noOfSoldActive + ']');
                System.debug('NKC debug noPlanningUnderway [' + noPlanningUnderway + ']');
                System.debug('NKC debug noOfWhiteSpace [' + noOfWhiteSpace + ']');
                */       
                //According to formula given by pushpa
                Decimal b = totalSize - (noOfNA + noOfBlocked);
                Decimal d = noPlanningUnderway == 0 ? 0 : (noPlanningUnderway / 2);
                Decimal c = noOfActive + noOfSold + noOfSoldActive + d; 
                Decimal engagementScore = 0;
                //Integer whiteSpaceScore = 0;
                if(b > 0){
                    engagementScore = (c * 100) / b;
                    //whiteSpaceScore = (whiteSpaceScore * 100) / b;
                }
                engagementScore = engagementScore.round(System.RoundingMode.HALF_UP);
                /*
                System.debug('NKC debug b [' + b + ']');
                System.debug('NKC debug c [' + c + ']');
                System.debug('NKC debug d [' + d + ']');
                System.debug('NKC debug engagementScore [' + engagementScore + ']');
                */
                //List<Integer> scores = new List<Integer>();
                //scores.add(engagementScore);
                //scores.add(whiteSpaceScore); 
                SML_Account_Engagement_Score__c newRecord = new SML_Account_Engagement_Score__c();
                newRecord.Account__c = eachAccountId;
                newRecord.Score__c = engagementScore;  
                newRecord.AccountId__c = eachAccountId;        
                accountEngagementScoresToBeInserted.add(newRecord);
            }
            if(!accountEngagementScoresToBeInserted.isEmpty()){
                Schema.SObjectField f = SML_Account_Engagement_Score__c.Fields.AccountId__c;
                List<Database.UpsertResult> listOfResults = Database.upsert(accountEngagementScoresToBeInserted, f, false);
                Integer counter = 0;
                List<SML_Batch_Log__c> smlBatchLog = new List<SML_Batch_Log__c>();
                for(Database.UpsertResult eachSR : listOfResults){                
                    if(!eachSR.isSuccess()){
                        String errorDetails;
                        for(Database.Error err : eachSr.getErrors()){
                            errorDetails = err.getStatusCode() + ': ' + err.getMessage() + '   ';
                        }
                        SMLHelperWTS.addInsertBatchLog(smlBatchLog, String.valueOf(accountEngagementScoresToBeInserted[counter].Account__c), SMLHelper.whileCalculatingEngagementScore, errorDetails);
                    }
                    counter ++;
                }
                if(!smlBatchLog.isEmpty())
                  insert smlBatchLog;
            }
        }
        
        public static void updateUnderMaintenanceSML(Set<Id> setOfAccountIds){
            List<ContractLineItem> contracts = [SELECT ServiceContract.AccountId, PricebookEntry.Product2.Solution_Category1__c,
              PricebookEntry.Product2.Name, PricebookEntry.Product2.Description__c, PricebookEntry.Product2.Environment__c, Quantity,
              Revised_Net_License_value__c, PricebookEntry.Product2.Type__c FROM ContractLineItem 
                WHERE ServiceContract.Agreement_Status__c = 'Active' AND ServiceContract.AccountId IN : setOfAccountIds
                AND PricebookEntry.Product2.Solution_Category1__c != null AND ServiceContract.AccountId != null];
                
            Map<String, List<ContractLineItem>> mapOfKeyVsCLIs = new Map<String, List<ContractLineItem>>();
            List<SML_Data__c> smlsToBeUpserted = new List<SML_Data__c>();
            List<ContractLineItem> contractLineItemsToBeUpdated = new List<ContractLineItem>();
            
            if(!setOfAccountIds.isEmpty()){
              //List of smls to be set for maintenance to false
              List<SML_Data__c> smlDataToBeUpdate = [SELECT Under_Maintenance__c FROM SML_Data__c 
                WHERE Under_Maintenance__c = true AND Account__c IN : setOfAccountIds];
              //Looping over each sml data
              for(SML_Data__c eachSMLData : smlDataToBeUpdate){
                eachSMLData.Under_Maintenance__c = false;
              }
              if(!smlDataToBeUpdate.isEmpty())
                update smlDataToBeUpdate;
            }
            Set<String> setOfKeys = new Set<String>();
            for(ContractLineItem eachItem : contracts){        
              if(doExcludeProduct(eachItem.PricebookEntry.Product2.Environment__c))
                continue;
                String key = String.valueOf(eachItem.ServiceContract.AccountId) + String.valueOf(eachItem.PricebookEntry.Product2.Solution_Category1__c);                
                System.debug('NKC debug key ['+ key +']');
                if(mapOfKeyVsCLIs.get(key) == null){
                    List<ContractLineItem> newList = new List<ContractLineItem>();
                    newList.add(eachItem);
                    mapOfKeyVsCLIs.put(key, newList); 
                }
                else{
                    List<ContractLineItem> existingList = mapOfKeyVsCLIs.get(key);
                    existingList.add(eachItem);
                    mapOfKeyVsCLIs.put(key, existingList ); 
                }
                System.debug('NKC debug mapOfKeyVsCLIs ['+ mapOfKeyVsCLIs +']');
                if(eachItem.PricebookEntry.Product2.Solution_Category1__c != null){  
                    if(setOfKeys.contains(key))
                        continue;
                    setOfKeys.add(key);                 
                    SML_Data__c smlData = new SML_Data__c();
                    smlData.Account__c = eachItem.ServiceContract.AccountId;
                    smlData.Solution_Category__c = eachItem.PricebookEntry.Product2.Solution_Category1__c;
                    smlData.AccountSCKey__c = key;
                    smlData.Under_Maintenance__c = true;
                    smlsToBeUpserted.add(smlData);
                }
            }       
            
            //Updating maintenance quantity
            for(SML_Data__c eachSMLData : smlsToBeUpserted){
                String key = eachSMLData.AccountSCKey__c;
                List<ContractLineItem> contractLineItems = mapOfKeyVsCLIs.get(key);
                Decimal quantity = 0;
                Double total = 0;
                Decimal quantityCloud = 0;
                Double totalCloud = 0;                
                //PricebookEntry.Product2.Type__c
                for(ContractLineItem eachCLI : contractLineItems){
                    if(eachCLI.PricebookEntry.Product2.Type__c == 'Cloud'){
                        quantityCloud += eachCLI.quantity;
                        totalCloud += eachCLI.Revised_Net_License_value__c == null ? 0 : eachCLI.Revised_Net_License_value__c; 
                    }
                    else{
                        quantity += eachCLI.quantity;
                        total += eachCLI.Revised_Net_License_value__c == null ? 0 : eachCLI.Revised_Net_License_value__c;
                    }
                }
                eachSMLData.Maintenance_Quantity__c = quantity;  
                eachSMLData.Maintenance_Total__c = total; 
                eachSMLData.Cloud_Maintenance_Quantity__c = quantityCloud;  
                eachSMLData.Cloud_Maintenance_Total__c = totalCloud; 
                             
            }
            
            //Upserting sml data        
            smlsToBeUpserted = updateUpsertSMLData(smlsToBeUpserted, 'Upsert', SMLHelper.whileUpdatingUnderMaint);
            
            Set<Id> setOfSMLIds = new Set<Id>();
            //Removing existing quote product references      
            for(SML_Data__c eachData : smlsToBeUpserted){
              setOfSMLIds.add(eachData.id);
            }    
            List<ContractLineItem> contractLinesToBeUnReferenced = [SELECT SML_Data__c FROM ContractLineItem WHERE 
              SML_Data__c != NULL AND ServiceContract.AccountId IN : setOfAccountIds];
            //Looping over each quote product to remove existing refrence of SML
            for(ContractLineItem eachCLI :  contractLinesToBeUnReferenced){
              eachCLI.SML_Data__c = null;
            }
            if(!contractLinesToBeUnReferenced.isEmpty())
              update contractLinesToBeUnReferenced;
                  
            List<ContractLineItem> clisToBeUpdated = new List<ContractLineItem>();
            //Looping over sml data 
            for(SML_Data__c eachData : smlsToBeUpserted){
                String key = String.valueOf(eachData.Account__c) + String.valueOf(eachData.Solution_Category__c);
                if(mapOfKeyVsCLIs.get(key) != null){
                    List<ContractLineItem> clis = mapOfKeyVsCLIs.get(key);
                    //Looping over each contract line item
                    for(ContractLineItem eachItem : clis){
                        System.debug('NKC debug eachItem.id [' + eachItem.id + ']');                        
                        eachItem.SML_Data__c = eachData.id;
                        clisToBeUpdated.add(eachItem);    
                    }
                }
            }
            if(!clisToBeUpdated.isEmpty()){
                update clisToBeUpdated ;
            }
        }
        
        public class priceInfo{
            Double totalPrice;
            Decimal quantity;
            Double totalPriceCloud;
            Decimal quantityCloud;
        }
        
        public static void updateSMLRealTime(Set<Id> setOfAccountIds){
          //Initialzing data
             initializeSMLData(setOfAccountIds);  
          //Key = Account + Product Solution Category
          Map<String, String> mapOfKeyVsStatus = new Map<String, String>();
          Map<String, SML_Data__c> mapOfKeyVsSML = new Map<String, SML_Data__c>();    
          Map<String, SML_Data__c> mapOfKeyVsExistingSML = getExistingSMLData(setOfAccountIds);
          
          //BLOCKED
            //Updating competitor info        
            upsertBlockedOnes(setOfAccountIds, mapOfKeyVsStatus, mapOfKeyVsSML);
          //ACTIVE        
            //Updating Active Oppotunities
            upsertSMLForOpportunity(setOfAccountIds, mapOfKeyVsStatus, mapOfKeyVsSML, mapOfKeyVsExistingSML);
            //Skip Triggers
            Util.Bypass_Trigger_Chk = true;
          //ACTIVE
          //Updating SML Data from Quotes
            upsertSMLForQuotes(setOfAccountIds, mapOfKeyVsStatus, mapOfKeyVsSML, mapOfKeyVsExistingSML);        
            //SOLD - Naresh Kumar   Contract line items to be checked for sold items instead of orders
            //Updating SML Data from Orders
            upsertSMLForOrders(setOfAccountIds, mapOfKeyVsStatus, mapOfKeyVsSML, mapOfKeyVsExistingSML);   
            
            //Skip Triggers
            Util.Bypass_Trigger_Chk = false;
            
            //List of smls to be updated with white space
            List<SML_Data__c> smlDataToBeUpserted = new List<SML_Data__c>();
            //List of smls to be updated with non white space status
            List<SML_Data__c> smlDataToBeUpserted1 = new List<SML_Data__c>();
            //Getting all solution categories
            List<Solution_Category__c> solutionCategories = [SELECT Name FROM Solution_Category__c]; 
            //Set Of Key
            Set<String> setOfKeys = new Set<String>();
            //Looping over each account
            for(String accountId : setOfAccountIds){
              //Looping over each category
              for(Solution_Category__c eachCategory : solutionCategories){
                String key = accountId + eachCategory.id;            
                //If status is manually overriden skip the record
                //Naresh Kumar 07/19/2016.  Removing below condition as asked by Nik/Vikram.
                //if((mapOfKeyVsExistingSML.get(key) != null && mapOfKeyVsExistingSML.get(key).Status_Overridden_Manually__c) || 
                if(setOfKeys.contains(key))
                  continue;
                setOfKeys.add(key);
                //Checking if there is any fresh status for the Key=
                if(mapOfKeyVsStatus.get(key) == null){
                    if(mapOfKeyVsExistingSML.get(key) != null && mapOfKeyVsExistingSML.get(key).Status__c != 'Next Best Action'){
                      SML_Data__c smlData = new SML_Data__c();
                      smlData.Account__c = accountId;
                      smlData.Solution_Category__c = eachCategory.id;
                      smlData.AccountSCKey__c = String.valueOf(smlData.Account__c) + String.valueOf(smlData.Solution_Category__c);
                      smlData.Status__c = SMLHelper.WHITESPACE;
                      smlDataToBeUpserted.add(smlData);               
                    }
                }
                else{
                  SML_Data__c smlData = mapOfKeyVsSML.get(key);
                  smlDataToBeUpserted1.add(smlData);
                }
              }  
            }      
            updateUpsertSMLData(smlDataToBeUpserted, 'Upsert', SMLHelper.whileMakingFinalUpdateWS);
            updateUpsertSMLData(smlDataToBeUpserted1, 'Upsert', SMLHelper.whileMakingFinalUpdateNWS);
            //Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            //Update under maintenance items            
            updateUnderMaintenanceSML(setOfAccountIds);
            
        }
        
        private static List<SML_Data__c> updateUpsertSMLData(List<SML_Data__c> smlDataToBeUpdatedOrUpserted, String actionType, String triggerPoint){
          //Upserting sml data        
            if(!smlDataToBeUpdatedOrUpserted.isEmpty()){
                Schema.SObjectField f = SML_Data__c.Fields.AccountSCKey__c;
                List<Database.UpsertResult> listOfUpsertResults;
                List<Database.SaveResult> listOfUpdateResults;
                
                if(actionType == 'Update')
                  listOfUpdateResults = Database.update(smlDataToBeUpdatedOrUpserted, false);
                else
                  listOfUpsertResults = Database.upsert(smlDataToBeUpdatedOrUpserted, f, false);
                Integer counter = 0;
                List<SML_Batch_Log__c> smlBatchLog = new List<SML_Batch_Log__c>();
                if(actionType == 'Update'){
                  for(Database.SaveResult eachSR : listOfUpdateResults){                
                      if(!eachSR.isSuccess()){
                          String errorDetails;
                          for(Database.Error err : eachSr.getErrors()){
                              errorDetails = err.getStatusCode() + ': ' + err.getMessage() + '   ';
                          }
                          SMLHelperWTS.addInsertBatchLog(smlBatchLog, String.valueOf(smlDataToBeUpdatedOrUpserted[counter].Account__c), triggerPoint , errorDetails);
                      }
                      counter ++;
                  }
                }
                else{
                  for(Database.UpsertResult eachSR : listOfUpsertResults){                
                      if(!eachSR.isSuccess()){
                          String errorDetails;
                          for(Database.Error err : eachSr.getErrors()){
                              errorDetails = err.getStatusCode() + ': ' + err.getMessage() + '   ';
                          }
                          SMLHelperWTS.addInsertBatchLog(smlBatchLog, String.valueOf(smlDataToBeUpdatedOrUpserted[counter].Account__c), triggerPoint, errorDetails);
                      }
                      counter ++;
                  }
                }
                if(!smlBatchLog.isEmpty())
                  insert smlBatchLog;
            }
            return smlDataToBeUpdatedOrUpserted;
        }
        
        private static Map<String, SML_Data__c> getExistingSMLData(Set<Id> setOfAccountIds){
          Map<String, SML_Data__c> mapOfKeyVsExistingSML = new Map<String, SML_Data__c>();
          List<SML_Data__c> existingSMLData = [SELECT id, AccountSCKey__c, Status_Overridden_Manually__c, Status__c FROM SML_Data__c WHERE Account__c IN : setOfAccountIds];
          //Looping over sml data
          for(SML_Data__c eachData : existingSMLData){
            mapOfKeyVsExistingSML.put(eachData.AccountSCKey__c, eachData);    
          }
          return mapOfKeyVsExistingSML;
        }
    }