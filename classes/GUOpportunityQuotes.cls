//Naresh Kumar  04/09/2017  Displays list of quotes for the opportunity.
public with sharing class GUOpportunityQuotes {
    //contains opportunity id
    public String strOppId {get; private set;}
    //contains list of quotes
    public List<quoteWrapper> list_OfQuotes {get; private set;}
    //whether it's partner login or not
    //show/hide new quote button
    public Boolean blnShowNewQuoteButton {get; private set;}
    //whether it's partner portal or not
    public Boolean blnIsPartner {get; private set;}
    //whether to hide the quote section or not
    public Boolean blnShowQuoteSection {get; private set;}    
    //quote id 
    public String strQuoteIdToBeDeleted {get; set;}
    //quote type to be deleted
    public Boolean blnIsBMQuote {get;set;}    
    //hold opportunity
    public Opportunity objOpp {get;set;}
    // Added by Vijay - Purpose: testing on Zuora Quote - updateOppAndCreateOppLnItms() . Please Do not remove this. - 29th Jul 2017
    public List<zqu__QuoteRatePlanCharge__c> list_ZQRPCs {get; set;}
    //Thirumal Pandian Added isPartnerPortalUser variable specific for two Profiles(Genesys Partner Portal & Genesys Gold Partner Portal)
    public Boolean isPartnerPortalUser {get; set;}
    
    //constructor
    public GUOpportunityQuotes(ApexPages.StandardController stdCtrl){        
        strOppId = stdCtrl.getId();
        blnShowNewQuoteButton = false;        
        blnIsPartner = UserInfo.getUserType() == 'PowerPartner';
        blnShowQuoteSection = true;
        //getting opportunity record
        objOpp = [SELECT Partner_Opportunity_Status__c, Lines_of_Businesses__c, Primary_Line_of_Business__c, AccountId,
                                     Indirect_Partner_PureCloud_Approved__c, Pricebook2Id 
                              FROM Opportunity WHERE id =: strOppId];
        
        //populating whether the opportunity is approved or not
        if(objOpp.Partner_Opportunity_Status__c == 'Approved' && objOpp.Lines_of_Businesses__c == 'PureConnect'){
            blnShowNewQuoteButton = true;
        }        
        if(blnIsPartner && (objOpp.Lines_of_Businesses__c != 'PureConnect' || objOpp.Primary_Line_of_Business__c != 'On Premise')){
            blnShowQuoteSection = false;
        }
       //Added below if condition for User Story#S-647325, Task#T-847992 Date:28-Nov-2019, Added By Thirumal Pandian
        isPartnerPortalUser = GenesysUtility.isPartnerPortalUser();
        if(isPartnerPortalUser && (objOpp.Lines_of_Businesses__c == 'PureCloud')){
            blnShowQuoteSection = true; 
            blnShowNewQuoteButton = true;
        }
       //End Story #S-647325, Task#T-847992
       populateQuote();         
    }
    
    private void populateQuote(){
        list_OfQuotes = new List<quoteWrapper>();
        //Querying BM quotes
        List<BigMachines__Quote__c> list_OfBMQuotes = [SELECT id,Top_Play__c, Name, Revision_No__c, BigMachines__Description__c, BigMachines__Status__c, 
        BigMachines__Total__c, BigMachines__Is_Primary__c, CreatedDate, Special_Offer_Terms__c, Quote_Business_Type__c, Offering_Type__c,Annual_Contract_Value__c 
        FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: strOppId ORDER BY CreatedDate DESC];         
        //looping over each quote
        for(BigMachines__Quote__c eachQuote : list_OfBMQuotes){
            //Naresh Kumar  03/29/2018  Do not show PureEngage Quote for partners if any
            if(blnIsPartner && (eachQuote.Offering_Type__c == null || eachQuote.Offering_Type__c.contains('PureEngage')))
                continue;
            quoteWrapper objWrapper = new quoteWrapper();
            objWrapper.strQuoteId = eachQuote.id;
            objWrapper.strQuoteName = eachQuote.Name;
            objWrapper.strDescription = eachQuote.BigMachines__Description__c;
            objWrapper.decRevisionNO = eachQuote.Revision_No__c;
            objWrapper.strStatus = eachQuote.BigMachines__Status__c;
            objWrapper.strPlatformType = eachQuote.Quote_Business_Type__c;
            objWrapper.strOfferingType = eachQuote.Offering_Type__c;
            objWrapper.Top_Play = eachQuote.Top_Play__c;
            
            //Code merged by JJ on 03/08/18, changed by Ankit in Feb 2018
            //Start
            if(eachQuote.Quote_Business_Type__c == 'On Premise')                                                    
            objWrapper.decTotal = eachQuote.BigMachines__Total__c;
            
            if(eachQuote.Quote_Business_Type__c == 'Cloud')
            objWrapper.decTotal = eachQuote.Annual_Contract_Value__c;                                              
            //End
            
            objWrapper.blnIsPrimary = eachQuote.BigMachines__Is_Primary__c;
            //objWrapper.strQuoteType = eachQuote.Quote_Type__c;
            objWrapper.createdDate = eachQuote.CreatedDate;
            objWrapper.blnIsBMQuote = true;            
            list_OfQuotes.add(objWrapper);
        }
    }
    
    //makes quote primary
    public void updateQuote() {    
        //Quote lists to be updated
        List<BigMachines__Quote__c> list_OfBMQuotesToBeUpdated = new List<BigMachines__Quote__c>();
        List<zqu__Quote__c> list_OfZuoraQuotesToBeUpdated = new List<zqu__Quote__c>();
        String strPrimaryQuoteId;
        String strPrimaryQuoteType = 'BM';  //Added By Ranjith on Jul 29, 2017
        
        for(quoteWrapper eachRecord : list_OfQuotes){
            if(eachRecord.blnIsBMQuote){
                BigMachines__Quote__c objBMQuote = new BigMachines__Quote__c(id = eachRecord.strQuoteId, BigMachines__Is_Primary__c = eachRecord.blnIsPrimary);
                list_OfBMQuotesToBeUpdated.add(objBMQuote);  
                //Populate primary quote id
                if(eachRecord.blnIsPrimary) {
                    strPrimaryQuoteId = eachRecord.strQuoteId; 
                    strPrimaryQuoteType = 'BM'; //Added By Ranjith on Jul 29, 2017
                }                 
            }
        }
        
        Util.Bypass_Trigger_Chk = true;
        if(!list_OfBMQuotesToBeUpdated.isEmpty()){
            update list_OfBMQuotesToBeUpdated;
            
            // Added By Ashish related to Legal DSR
            // Suggested by JJ
            objOpp.Primary_Quote__c = strPrimaryQuoteId;
            update objOpp;
        }
        Util.Bypass_Trigger_Chk = false;
        
        try{
            //Populate total
            if(strPrimaryQuoteId != null){
                changeOppPriceBookToStandard();
                if(strPrimaryQuoteType == 'BM') {    //Added By Ranjith on Jul 29, 2017        
                    MakeQuotePrimary_WS.CorrectTotalCloud(strPrimaryQuoteId);
                    populateOpportunityProducts(strPrimaryQuoteId);
                    updatePrimaryQuoteOnContract(strPrimaryQuoteId, objOpp);
                }
            }
        } catch(Exception e){
            // ...atleast let quote become primary
        }           
    }
    
    private void updatePrimaryQuoteOnContract(String strPrimaryQuoteId, Opportunity objOpp) {        
        List<GCR_Content_Document_Detail__c> listOfContracts = [SELECT id, Quote__c, Account_Name__c FROM GCR_Content_Document_Detail__c 
            WHERE Opportunity__c =: strOppId];
        if(listOfContracts.isEmpty())
            return;
        //Removing Reference of Contract on old Quote
        List<BigMachines__Quote__c> listOfQuoteToBeUpdated = new List<BigMachines__Quote__c>();
        Set<Id> setOfQuoteIds = new Set<Id>();
        //Updating primary quote - Though we have loop below but the list of contracts will be always one.
        for(GCR_Content_Document_Detail__c eachContract : listOfContracts){
            if(eachContract.Quote__c != null && !setOfQuoteIds.contains(eachContract.Quote__c)){
                BigMachines__Quote__c objQuoteToBeUpdated = new BigMachines__Quote__c(id = eachContract.Quote__c);
                objQuoteToBeUpdated.Legal_Contract__c = eachContract.id;
                listOfQuoteToBeUpdated.add(objQuoteToBeUpdated);
                setOfQuoteIds.add(eachContract.Quote__c);
            }
            eachContract.Quote__c = strPrimaryQuoteId;     
            //eachContract = LegalContractFieldPopulationHelper.populateContractFromQuote(strPrimaryQuoteId, eachContract);
            //eachContract = LegalContractFieldPopulationHelper.populateContractFromOpportunity(strOppId, eachContract);
            //eachContract = LegalContractFieldPopulationHelper.populateContractFromAccount(eachContract.Account_Name__c, eachContract);            
        }
        update listOfContracts;
    }
    
    private void changeOppPriceBookToStandard() {
        try{
            PriceBook2 standardPB = [select Id, Name from pricebook2 where Name = 'Standard Price Book'];
            if (objOpp.Pricebook2Id != standardPB.id) {            
                List <OpportunityLineItem> oppLinesToBeDeleted = [SELECT id FROM OpportunityLineItem WHERE OpportunityId =: objOpp.id];
                if (!oppLinesToBeDeleted.isEmpty())
                    delete oppLinesToBeDeleted;      
                Opportunity oppToBeUpdated = new Opportunity(id = objOpp.id, Pricebook2Id = standardPB.id);
                update oppToBeUpdated;
            }
        }
        catch(Exception e){
            System.debug('NKC debug exception : ' + e.getMessage());
        }
    }
 
    public static void populateOpportunityProducts(String strPrimaryQuoteId){
        //primary quote
        BigMachines__Quote__c objPrimaryQuote = [SELECT BigMachines__Opportunity__c, Offering_Type__c, BigMachines__Opportunity__r.CurrencyISOCode, CurrencyISOCode FROM BigMachines__Quote__c WHERE id =: strPrimaryQuoteId];             
        //delete existing lines before creating quote products as opportunity lines
        List <OpportunityLineItem> list_OfOpptyLinesToDelete = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: objPrimaryQuote.BigMachines__Opportunity__c];
        if(list_OfOpptyLinesToDelete.size() > 0)
            delete list_OfOpptyLinesToDelete;
        //fetching quote products
        List<BigMachines__Quote_Product__c> list_OfQuoteProducts = [SELECT id, BigMachines__Product__c, Product_Description__c, Quantity__c,
                    BigMachines__Quantity__c,
                    Net_Unit_Price__c, Total_Discount__c, Unit_of_Measure__c, BigMachines__Product__r.Type__c, Is_Overage__c
                    FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: objPrimaryQuote.id];
        Set<Id> set_OfProductId = new Set<Id>();
        //creating a set of products to fetch pricebooks
        for (BigMachines__Quote_Product__c objQP: list_OfQuoteProducts) {
            set_OfProductId.add(objQP.BigMachines__Product__c);    
        }
        //creating map of products and respective pricebook
        Map<Id, Id> map_OfProdIdVsPBEId = new Map<Id, Id> ();
        for (PricebookEntry objPE: [SELECT Product2Id, Id FROM PricebookEntry WHERE Pricebook2Id =: Label.Standard_Pricebook_Id AND
                Product2Id IN: set_OfProductId AND CurrencyISOCode =: objPrimaryQuote.BigMachines__Opportunity__r.CurrencyISOCode]){
            map_OfProdIdVsPBEId.put(objPE.Product2Id, objPE.Id);
        }
        List<OpportunityLineItem> list_OfOppLinesToBeCreated = new List<OpportunityLineItem>();   
        for (BigMachines__Quote_Product__c objQP: list_OfQuoteProducts) {
            //Naresh Kumar  07/30/2017  Populating Product_Type__c on opportunity line items for Genesys Care Lines            
            String strProductType;
            if(objQP.BigMachines__Product__r.Type__c == 'Genesys Care')
                strProductType = 'Care';
            if (map_OfProdIdVsPBEId.containsKey(objQP.BigMachines__Product__c) 
                && !objQP.Is_Overage__c
                && (((objPrimaryQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objPrimaryQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) && objQP.Quantity__c > 0)
                     || (objPrimaryQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PC && objPrimaryQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PCC))) {
                system.debug(objQP.Quantity__c);
                system.debug(objQP.BigMachines__Quantity__c );
                list_OfOppLinesToBeCreated.add(new OpportunityLineItem(
                                BigMachines__Origin_Quote__c = objPrimaryQuote.Id,
                                Description__c = (String.isNotBlank(objQP.Product_Description__c) && objQP.Product_Description__c.length() > 250 ? objQP.Product_Description__c.substring(0, 250) : objQP.Product_Description__c),
                                OpportunityId = objPrimaryQuote.BigMachines__Opportunity__c,
                                PricebookEntryId = map_OfProdIdVsPBEId.get(objQP.BigMachines__Product__c),
                                Quantity = objQP.Quantity__c == null ? objQP.BigMachines__Quantity__c : objQP.Quantity__c, Quantity__c = objQP.Quantity__c == null ? objQP.BigMachines__Quantity__c : objQP.Quantity__c, UnitPrice = objQP.Net_Unit_Price__c,
                                Total_Discount__c = objQP.Total_Discount__c, Unit_of_Measure__c = objQP.Unit_of_Measure__c,
                                Product_Type__c = strProductType));
                system.debug(list_OfOppLinesToBeCreated);
            }
        }
        if(!list_OfOppLinesToBeCreated.isEmpty()){
            insert list_OfOppLinesToBeCreated;
        }        
    }
    
    public void deleteQuote(){
        if(blnIsBMQuote){
            BigMachines__Quote__c objBMQuote = new BigMachines__Quote__c(id = strQuoteIdToBeDeleted);            
            delete objBMQuote;
        } 
        populateQuote();
    }
    
    //wrapper class to hold all quotes
    public class quoteWrapper{
        public String strQuoteId {get; private set;}
        public String strQuoteName {get; private set;}
        public String Top_Play {get; private set;}
        public String strDescription {get; private set;}
        public Decimal decRevisionNO {get; private set;}
        public String strStatus {get; private set;}
        public String strPlatformType {get; private set;}
        public String strOfferingType {get; private set;}
        public Decimal decTotal {get; private set;}
        public Boolean blnIsPrimary {get; set;}
        public String strQuoteType {get; private set;}
        public DateTime createdDate {get; private set;}
        public Boolean blnIsBMQuote {get; private set;}
    }
}