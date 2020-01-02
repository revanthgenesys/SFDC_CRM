//Naresh Kumar  03/08/2014
public without sharing class CloudQuoteUtil {
    public static Boolean DO_NOT_CALL_OPP_PRODUCT_TOTAL_LOGIC = false;
    //Returns field from given fieldset
    private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String objectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
    
    public static String getQuoteForFieldSet(String fieldSetName, String objectName){
        List<Schema.FieldSetMember> fieldSetMemberList = readFieldSet(fieldSetName, objectName);
        String query = 'SELECT ';
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            query += fieldSetMemberObj.getFieldPath() + ',';
        }
        query = query.substring(0, query.lastIndexOf(','));
        query += ' FROM '+ objectName;
        return query;
    }
    
    public static String cloneQuoteAndAddLineItemsFromSCLine(String selectedQuoteId, String primaryQuoteId, String selectedUpgradeType, String oppId){
        List<RecordType> cloudQuoteRecordType = [SELECT id FROM RecordType WHERE SobjectType = 'BigMachines__Quote__c' AND DeveloperName = 'Cloud_Quote' LIMIT 1];      
        BigMachines__Quote__c quote = (BigMachines__Quote__c)Database.query(ServiceOrderQuoteHelper.prepareQuoteQuery((id)selectedQuoteId));
        BigMachines__Quote__c clonedQuote = quote.clone(false, true);
        clonedQuote.BigMachines__Transaction_Id__c = null;
        clonedQuote.Quote_Created_Date__c = System.today();     
        clonedQuote.Is_Business_Primary__c = true;
        clonedQuote.BigMachines__Is_Primary__c = true;     
         clonedQuote.BigMachines__Status__c = 'Quote In Progress';
        insert clonedQuote;
        clonedQuote = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: clonedQuote.id];
        clonedQuote.Name = clonedQuote.Quote_Number__c;
        clonedQuote.BigMachines__Status__c = 'Quote In Progress';
        clonedQuote.Parent_Quote__c = primaryQuoteId;
        clonedQuote.BigMachines__Opportunity__c = oppId;
        
        if(!cloudQuoteRecordType.isEmpty()) 
            clonedQuote.RecordTypeId = cloudQuoteRecordType[0].id;      
        clonedQuote.Upgrade_Type__c = selectedUpgradeType;
        update clonedQuote;     
        if(primaryQuoteId != null){
            List<ContractLineItem> contLineItems = [SELECT UnitPrice, Discount, Quantity, Maintenance_Amount__c,
                PricebookEntry.Product2Id, Product_Group__c, Quote_Product__r.Name, Device__c, Original_Net_License_value__c, Installation_Activation_Fee__c,
                Product_Option__c FROM ContractLineItem 
                WHERE ServiceContract.Quote_Name__c =: primaryQuoteId];
                
            List<BigMachines__Quote_Product__c> quoteProductsToBeInserted = new List<BigMachines__Quote_Product__c>(); 
            for(ContractLineItem eachLineItem : contLineItems){
                BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
                newQuoteProduct.List_Price__c = eachLineItem.UnitPrice;
                newQuoteProduct.Discount__c = eachLineItem.Discount;
                newQuoteProduct.BigMachines__Quantity__c = eachLineItem.Quantity;
                newQuoteProduct.Fees_Applied__c = eachLineItem.Maintenance_Amount__c;
                newQuoteProduct.BigMachines__Quote__c = clonedQuote.id;
                newQuoteProduct.BigMachines__Sales_Price__c = eachLineItem.UnitPrice;
                newQuoteProduct.Product_Group__c = eachLineItem.Product_Group__c;       
                newQuoteProduct.BigMachines__Product__c = eachLineItem.PricebookEntry.Product2Id;
                newQuoteProduct.Name = eachLineItem.Quote_Product__r.Name;
                newQuoteProduct.Product__c = eachLineItem.Quote_Product__r.Name;
                newQuoteProduct.Device__c = eachLineItem.Device__c;
                newQuoteProduct.Extended_Price_Per_Month__c = eachLineItem.Original_Net_License_value__c;
                newQuoteProduct.Installation_Fees__c = eachLineItem.Installation_Activation_Fee__c;
                newQuoteProduct.Product_Option__c = eachLineItem.Product_Option__c;
                quoteProductsToBeInserted.add(newQuoteProduct);
            }
            if(!quoteProductsToBeInserted.isEmpty())    
                insert quoteProductsToBeInserted;
        }
        return clonedQuote.id;
    }
    
    public static void initCreateServiceContract(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap ){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity eachOpp : newMap.values()){
            if((eachOpp.StageName == '6.Closed' && oldMap.get(eachOpp.id).StageName != '6.Closed')
                || (eachOpp.Win_Loss_Status__c == 'Won' && oldMap.get(eachOpp.id).Win_Loss_Status__c != 'Won')){
                    oppIds.add(eachOpp.id);
                }               
        }
        Set<Id> quoteIds = new Set<Id>();
        if(!oppIds.isEmpty()){
            List<BigMachines__Quote__c> cloudQuotes = [SELECT id FROM BigMachines__Quote__c WHERE BigMachines__Is_Primary__c = true AND 
                RecordType.DeveloperName = 'Cloud_Quote' AND BigMachines__Opportunity__c IN : oppIds];
            for(BigMachines__Quote__c eachQuote : cloudQuotes){
                quoteIds.add(eachQuote.id);
            }
            if(!quoteIds.isEmpty())
                createServiceContract(quoteIds);
        }
    }
    
    private static void updateProspectToCustomerAccount(List<BigMachines__Quote__c> cloudQuotes){
        //prospect to customer conversion
        Boolean isAccountUpdateRequired = false;
        if(cloudQuotes[0].End_User_ID__c != null){
            account accrtype = [select IsDirect__c,recordtypeid from Account where id =: cloudQuotes[0].End_User_ID__c];
            Id ProspectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMG - Prospect Record Type').getRecordTypeId();
            Id CustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMG - Customer Record Type').getRecordTypeId();         
            
            if(accrtype.recordtypeid == ProspectRecTypeId || accrtype.recordtypeid == CustomerRecTypeId){
                Account acc = new account(id = cloudQuotes[0].End_User_ID__c);
                if(accrtype.recordtypeid == ProspectRecTypeId){
                    acc.recordtypeid = CustomerRecTypeId;                    
                    AccountStatusHelper.populateAccountOppDetails(acc, cloudQuotes[0].BigMachines__Opportunity__c);
                    isAccountUpdateRequired = true;
                }            
            if(cloudQuotes[0].Sold_To_Name__c == cloudQuotes[0].End_User_ID__c &&  cloudQuotes[0].End_User_ID__c != null && accrtype.IsDirect__c==false){
                  acc.IsDirect__c=true;
                 isAccountUpdateRequired = true;
            }
            if(isaccountupdaterequired){
                update acc;
            }
        }
       }
    }
    
    public static void createServiceContract(Set<Id> quoteIds){
        
        //System.savepoint sp =  Database.setSavePoint();
        //try{
            List<ServiceContract> scToBeInserted = new List<ServiceContract>();
            
            List<BigMachines__Quote__c> quotes = [SELECT id, Name, End_User_ID__c, Sold_To_Name__c, CurrencyISOCode, BigMachines__Opportunity__c, 
                BigMachines__Status__c, RecordType.DeveloperName, Parent_Quote__c, Maintenance_Start_Date__c, Maintenance_End_Date__c,
                Initial_Subscription_Term__c FROM BigMachines__Quote__c WHERE id IN : quoteIds];
                
            
            List<BigMachines__Quote__c> cloudQuotes = new List<BigMachines__Quote__c>();    
            Set<Id> uniqueOppIds = new Set<Id>();
            Set<Id> cloudQuoteIds = new Set<Id>();
            List<BigMachines__Quote__c> upgradeDownGradeQuotes = new List<BigMachines__Quote__c>();
            for(BigMachines__Quote__c eachQuote : quotes){                      
                if(eachQuote.BigMachines__Status__c == 'Quote Approved' & eachQuote.RecordType.DeveloperName == 'Cloud_Quote'){                 
                    if(eachQuote.Parent_Quote__c != null)
                        upgradeDownGradeQuotes.add(eachQuote);
                    else{
                        cloudQuotes.add(eachQuote);
                        uniqueOppIds.add(eachQuote.BigMachines__Opportunity__c);
                        cloudQuoteIds.add(eachQuote.id);    
                    }
                }               
            }
            if(!upgradeDownGradeQuotes.isEmpty())
                updateQuantitiesOnSCLines(upgradeDownGradeQuotes);
            Map<Id, Opportunity> mapOppIdVsOpp = ServiceContractUtil.getOppsMap(uniqueOppIds);
            for(BigMachines__Quote__c eachQuote : cloudQuotes){
                Integer term = 1;
                if(eachQuote.Initial_Subscription_Term__c == '2 Years')
                    term = 2;
                else if(eachQuote.Initial_Subscription_Term__c == '3 Years')
                    term = 3;
                else if(eachQuote.Initial_Subscription_Term__c == '5 Years')
                    term = 5;
                
                ServiceContract newServiceContract = new ServiceContract();
                newServiceContract.End_User_Name__c = eachQuote.End_User_ID__c;
                newServiceContract.Sold_To_Name__c = eachQuote.Sold_To_Name__c;
                newServiceContract.AccountId = eachQuote.End_User_ID__c;
                newServiceContract.CurrencyISOCode = eachQuote.CurrencyISOCode;
                newServiceContract.Quote_Name__c = eachQuote.id;
                newServiceContract.Name = eachQuote.Name;
                newServiceContract.Agreement_Status__c = 'Active';
                newServiceContract.Service_Contract_Type__c = 'Cloud';
                newServiceContract.pricebook2Id = mapOppIdVsOpp.get(eachQuote.BigMachines__Opportunity__c).pricebook2Id;
                if(eachQuote.Maintenance_Start_Date__c != null && eachQuote.Maintenance_End_Date__c != null){
                    newServiceContract.StartDate = eachQuote.Maintenance_Start_Date__c;
                    newServiceContract.EndDate = eachQuote.Maintenance_End_Date__c;
                }
                else{
                    newServiceContract.StartDate = System.today();
                    newServiceContract.EndDate = System.today().addYears(term);                 
                }
                scToBeInserted.add(newServiceContract);
            }
            if(!scToBeInserted.isEmpty())
                insert scToBeInserted;
            Map<Id,Id> mapQuoteIdVsSCId = new Map<Id,Id>();
            for(ServiceContract eachSC : scToBeInserted){
                mapQuoteIdVsSCId.put(eachSC.Quote_Name__c, eachSC.id);
            }           
            
            List<BigMachines__Quote_Product__c> quoteProducts = [SELECT id, BigMachines__Product__c, List_Price__c, Discount__c, BigMachines__Quantity__c,
                Fees_Applied__c, CurrencyIsoCode, BigMachines__Quote__c, Product_Group__c, Device__c, Extended_Price_Per_Month__c, Installation_Fees__c,
                Product_Option__c FROM BigMachines__Quote_Product__c 
                WHERE BigMachines__Quote__c IN : cloudQuoteIds];
            
            if(!quoteProducts.isEmpty())
                insertSCLineItems(quoteProducts, mapQuoteIdVsSCId);
            if(!cloudQuotes.isEmpty()){
                updateProspectToCustomerAccount(cloudQuotes);
            }
        //}
        //catch(Exception ex){
        //  Database.rollback(sp);  
        //}
    }
    
    private static void insertSCLineItems(List<BigMachines__Quote_Product__c> quoteProducts, Map<Id,Id> mapQuoteIdVsSCId){
        Set<String> product2Ids = new Set<String>();
            Set<String> isoCodes = new Set<String>();
            
            for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
                product2Ids.add(eachQuoteProduct.BigMachines__Product__c);
                isoCodes.add(eachQuoteProduct.CurrencyIsoCode);
            }
            
            Map<String, List<PricebookEntry>> pb2IdToPBE = new Map<String, List<PricebookEntry>>();
            if(!product2Ids.isEmpty())
                for(PricebookEntry pbe : [Select Product2Id, Pricebook2Id, Id, CurrencyIsoCode 
                                          From PricebookEntry 
                                      where Pricebook2.IsStandard = true and Pricebook2.IsActive=true
                                            and CurrencyIsoCode IN :isocodes 
                                            and Product2Id IN : product2Ids]){
                if(!pb2IdToPBE.containsKey(pbe.Product2Id))
                    pb2IdToPBE.put(pbe.Product2Id, new List<PricebookEntry>{pbe});
                else
                    pb2IdToPBE.get(pbe.Product2Id).add(pbe);
            }
            
            
            List<ContractLineItem> contLineItemsToBeInserted = new List<ContractLineItem>();
            for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
                ContractLineItem newContractLineItem = new ContractLineItem();
                if(pb2IdToPBE.get(eachQuoteProduct.BigMachines__Product__c) == null)
                    continue;
                System.debug('NKC debug pb2IdToPBE ['+pb2IdToPBE+']');
                System.debug('NKC debug eachQuoteProduct.BigMachines__Product__c ['+eachQuoteProduct.BigMachines__Product__c+']');
                for(PricebookEntry pbe : pb2IdToPBE.get(eachQuoteProduct.BigMachines__Product__c)){
                    System.debug('NKC debug pbe.CurrencyIsoCode ['+pbe.CurrencyIsoCode+']');
                    System.debug('NKC debug eachQuoteProduct.CurrencyIsoCode ['+eachQuoteProduct.CurrencyIsoCode+']');
                    if(pbe.CurrencyIsoCode == eachQuoteProduct.CurrencyIsoCode)
                    newContractLineItem.PricebookEntryId = pbe.Id;
                }
                
                if(mapQuoteIdVsSCId.get(eachQuoteProduct.BigMachines__Quote__c) == null )
                    newContractLineItem.ServiceContractId = mapQuoteIdVsSCId.get(eachQuoteProduct.BigMachines__Quote__r.Parent_Quote__c);
                else
                    newContractLineItem.ServiceContractId = mapQuoteIdVsSCId.get(eachQuoteProduct.BigMachines__Quote__c);
                System.debug('NKC debug eachQuoteProduct.List_Price__c ['+eachQuoteProduct.List_Price__c+']');
                if(eachQuoteProduct.List_Price__c == null || eachQuoteProduct.List_Price__c == 0)
                    newContractLineItem.UnitPrice = 1;
                else
                    newContractLineItem.UnitPrice = eachQuoteProduct.List_Price__c;
                //newContractLineItem.Discount = eachQuoteProduct.Discount__c;
                if(eachQuoteProduct.BigMachines__Quantity__c == 0)
                    eachQuoteProduct.BigMachines__Quantity__c = 1;
                newContractLineItem.Quantity = eachQuoteProduct.BigMachines__Quantity__c;
                newContractLineItem.Maintenance_Amount__c = eachQuoteProduct.Fees_Applied__c;
                newContractLineItem.Quote_Product__c = eachQuoteProduct.id;     
                newContractLineItem.Product_Group__c = eachQuoteProduct.Product_Group__c;
                newContractLineItem.Device__c = eachQuoteProduct.Device__c;
                newContractLineItem.Original_Net_License_value__c = eachQuoteProduct.Extended_Price_Per_Month__c;
                newContractLineItem.Installation_Activation_Fee__c = eachQuoteProduct.Installation_Fees__c;
                newContractLineItem.Product_Option__c = eachQuoteProduct.Product_Option__c;
                contLineItemsToBeInserted.add(newContractLineItem);
            }
            if(!contLineItemsToBeInserted.isEmpty())
                insert contLineItemsToBeInserted;
    }
    
    public static void updateQuantitiesOnSCLines(List<BigMachines__Quote__c> quotes){
        Map<Id,Id> mapQuoteIdVsParentQuoteId = new Map<Id, Id>();
        for(BigMachines__Quote__c eachQuote : quotes){
            mapQuoteIdVsParentQuoteId.put(eachQuote.id, eachQuote.Parent_Quote__c);
        }   
        Map<Id,Id> mapQuoteIdVsSCId = new Map<Id,Id>();
        List<ContractLineItem> contLineItems = [SELECT id, ServiceContract.Quote_Name__c, PricebookEntry.Product2Id, Quantity, ServiceContractId, Device__c, Installation_Activation_Fee__c  FROM ContractLineItem 
            WHERE ServiceContract.Quote_Name__c IN : mapQuoteIdVsParentQuoteId.values()];
        Map<String, ContractLineItem> mapQuoteIdVsContractLineItems = new Map<String, ContractLineItem>();
        for(ContractLineItem eachCLI : contLineItems){
            String key = eachCLI.ServiceContract.Quote_Name__c + '-' + eachCLI.PricebookEntry.Product2Id + '-' + eachCLI.Device__c;
            mapQuoteIdVsContractLineItems.put(key, eachCLI);
            mapQuoteIdVsSCId.put(eachCLI.ServiceContract.Quote_Name__c, eachCLI.ServiceContractId);         
        } 
        
        List<BigMachines__Quote_Product__c> quoteProducts = [SELECT id, BigMachines__Product__c, List_Price__c, Discount__c, BigMachines__Quantity__c,
                Fees_Applied__c, CurrencyIsoCode, BigMachines__Quote__c, Product_Group__c, BigMachines__Quote__r.Parent_Quote__c, Device__c, Extended_Price_Per_Month__c,
                Installation_Fees__c, Product_Option__c
            FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c IN : mapQuoteIdVsParentQuoteId.keyset()];
        Map<String, BigMachines__Quote_Product__c> mapQuoteIdVsQuoteProducts = new Map<String, BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
            String key = mapQuoteIdVsParentQuoteId.get(eachQuoteProduct.BigMachines__Quote__c) + '-' + eachQuoteProduct.BigMachines__Product__c + '-' + eachQuoteProduct.Device__c;
            System.debug('NKC debug key ['+key+']');            
            mapQuoteIdVsQuoteProducts.put(key, eachQuoteProduct);
        } 
        //System.debug('NKC dbeug mapQuoteIdVsContractLineItems ['+mapQuoteIdVsContractLineItems+']');
        //System.debug('NKC dbeug mapQuoteIdVsQuoteProducts ['+mapQuoteIdVsQuoteProducts+']');
        List<ContractLineItem> contLineItemsToBeUpdated = new List<ContractLineItem>();
        List<BigMachines__Quote_Product__c> quoteLinesToBeInsertedInSC = new List<BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c eachQuoteProduct : mapQuoteIdVsQuoteProducts.values()){
            String key = mapQuoteIdVsParentQuoteId.get(eachQuoteProduct.BigMachines__Quote__c) + '-' + eachQuoteProduct.BigMachines__Product__c + '-' + eachQuoteProduct.Device__c;
            System.debug('NKC debug key ['+key+']');            
            ContractLineItem contLineItem = mapQuoteIdVsContractLineItems.get(key);
            if(contLineItem == null){
                quoteLinesToBeInsertedInSC.add(eachQuoteProduct);
            }
            else{
                //contLineItem.Quantity += eachQuoteProduct.BigMachines__Quantity__c;
                contLineItem.Quantity = eachQuoteProduct.BigMachines__Quantity__c;
                contLineItemsToBeUpdated.add(contLineItem);
            }           
        }
        if(!contLineItemsToBeUpdated.isEmpty())
            update contLineItemsToBeUpdated;
        if(!quoteLinesToBeInsertedInSC.isEmpty()){
            System.debug('NKC debug mapQuoteIdVsSCId ['+mapQuoteIdVsSCId+']');
            insertSCLineItems(quoteLinesToBeInsertedInSC, mapQuoteIdVsSCId);
        }
    }
    
    public static void updateBusinessPrimary(Map<Id, BigMachines__Quote__c> newMap){
        
        List<BigMachines__Quote__c> quotes = [SELECT id, Is_Business_Primary__c, BigMachines__Opportunity__c FROM BigMachines__Quote__c 
            WHERE id IN : newMap.keyset()];
        Set<String> oppIds = new Set<String>();
        for(BigMachines__Quote__c eachQuote : quotes){
            oppIds.add(eachQuote.BigMachines__Opportunity__c);
        }
        quotes = [SELECT id, Is_Business_Primary__c, BigMachines__Opportunity__c FROM BigMachines__Quote__c 
            WHERE BigMachines__Opportunity__c IN : oppIds];
        if(quotes.isEmpty()){
            return;
        }
        Map<String, BigMachines__Quote__c> mapOppIdVsQuote = new Map<String, BigMachines__Quote__c>();
        Map<String, Integer> mapOppIdVsNoOfQuotes = new Map<String, Integer>();
        for(BigMachines__Quote__c eachQuote : quotes){
            if(mapOppIdVsNoOfQuotes.get(eachQuote.BigMachines__Opportunity__c) == null)
                mapOppIdVsNoOfQuotes.put(eachQuote.BigMachines__Opportunity__c, 1);
            else{
                Integer noOfQuotes = mapOppIdVsNoOfQuotes.get(eachQuote.BigMachines__Opportunity__c);
                noOfQuotes ++;
                mapOppIdVsNoOfQuotes.put(eachQuote.BigMachines__Opportunity__c, noOfQuotes);
            }
            mapOppIdVsQuote.put(eachQuote.BigMachines__Opportunity__c, eachQuote);
        } 
        System.debug('NKC debug mapOppIdVsQuote ['+mapOppIdVsQuote+']');
        System.debug('NKC debug mapOppIdVsNoOfQuotes ['+mapOppIdVsNoOfQuotes+']');
        
        List<BigMachines__Quote__c> quotesToBeUpdated = new List<BigMachines__Quote__c>();
        for(String oppId : mapOppIdVsNoOfQuotes.keyset()){
            if(mapOppIdVsNoOfQuotes.get(oppId) != null && mapOppIdVsNoOfQuotes.get(oppId) == 1){
                BigMachines__Quote__c quote = mapOppIdVsQuote.get(oppId);
                quote.Is_Business_Primary__c = true;
                quotesToBeUpdated.add(quote);
            }
        }       
        if(!quotesToBeUpdated.isEmpty())
            update quotesToBeUpdated;
    }
}