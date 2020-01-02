public with sharing class ExportToExcelCloudController 
{
    public BigMachines__Quote__c quote {get; set;}
    public List<QuoteProductWrapper> list_QuoteProducts {get; set;} 
    String quoteId;
    
    // List of Group Headers i.e. Categories or Proposal Group Numbers
    public List<String> list_GroupHeaders {get; set;}
    // Map of Group Header to List of Quote Product Wrappers
    public Map<String,List<QuoteProductWrapper>> map_GroupHeaderToQuoteProdWrapper {get; set;}
    // Service Level
    public BigMachines__Quote_Product__c objServiceLevel {get; private set;}
    // Third Party GC Line
    public BigMachines__Quote_Product__c objThirdPartyGCLine {get; private set;}  
    // List of Proposal Groups being displayed
    public List<Quote_Proposal_Group__c> list_ProposalGroups {get; set;}
    // Map of Proposal Group Number to Record
    Map<String,Quote_Proposal_Group__c> map_GroupNumToGrouprecord;
    // Proposal Group record to store un-grouped amount
    public Quote_Proposal_Group__c objUngrouped {get; private set;}
    // All products excluding configuration products and bundle items products on the quote
    List<BigMachines__Quote_Product__c> list_QuoteProductRecords;
    // To indicate whether there is at least 1 HW Line
    public Boolean blnHasHWLines {get; private set;}
    // To indicate whether there is at least 1 Bundle
    public Boolean blnHasBundles {get; private set;}
    public User_Col_Preference__c objColumnPreference {get; set;}
    // Map to store Bundle Quote Products
    Map<Id,BigMachines__Quote_Product__c> map_BundleQuoteProducts;
    
    //Mukunth added for 6 digit project on 16-APR-2019
    public string strQuoteCurcy {get;set;}

    public Boolean blnHasRDP {get; private set;}
    
    public class QuoteProductWrapper
    {
        public BigMachines__Quote_Product__c record {get; set;}
        public Boolean selected {get; set;}
        
        public QuoteProductWrapper()
        {
            selected = false;
        }
    }
    
    public ExportToExcelCloudController()
    {
        init();
    }
    
    private void init()
    {
        quoteId = ApexPages.currentPage().getParameters().get('id');
        blnHasRDP = false;
        objUngrouped = new Quote_Proposal_Group__c();
        
        //objColumnPreference = User_Col_Preference__c.getInstance(UserInfo.getUserId());
        List<User_Col_Preference__c> list_UserColPref = [SELECT Id,Third_Party__c,Name,Building_Block__c,Ext_List_Price__c,
                List_Price__c,Net_Unit_Price__c,PM_Approver__c,Product_Specific_Discount__c,Unit_of_measure__c, Sub_Category__c 
                FROM User_Col_Preference__c WHERE User__c = :UserInfo.getUserId()];
        if(list_UserColPref.size() == 0)
          objColumnPreference = new User_Col_Preference__c(Third_Party__c = true,User__c = UserInfo.getUserId(),
                Building_Block__c = true,Ext_List_Price__c = true,List_Price__c = true,Net_Unit_Price__c = true,
                PM_Approver__c = true,Product_Specific_Discount__c = true,Unit_of_measure__c = true);
        else
          objColumnPreference = list_UserColPref[0];
        
        // Fetching Quote information
        quote = getQuote((Id)quoteId);

        list_QuoteProducts = new List<QuoteProductWrapper>();
        if(quoteId != null)
        {                   
            // Fetching Proposal Groups
            fetchProposalGroups();
            
            // Fetching Quote Products
            getQuoteProducts(quoteId);
            
            // Calculating Group Sub Totals
            calculateGroupSubTotals();
        }
    }
  
    // *** Method to query Proposal Groups ***
    private void fetchProposalGroups()
    {
        list_ProposalGroups = [SELECT Id,Description__c,Discount__c,Group_Number__c,Name__c,Sub_Total__c,Goal_Seek__c
                        FROM Quote_Proposal_Group__c WHERE Quote__c = :quote.Id ORDER BY Group_Number__c];
    
        map_GroupNumToGrouprecord = new Map<String,Quote_Proposal_Group__c>();
        for(Quote_Proposal_Group__c objPG: list_ProposalGroups)
          map_GroupNumToGrouprecord.put(objPG.Group_Number__c,objPG);
    } 
  
  // *** Method to return quote object ***
    public BigMachines__Quote__c getQuote(Id quoteId)
    {
        BigMachines__Quote__c quote = (BigMachines__Quote__c)Database.query(prepareQuoteQuery(quoteId));
        
        if(String.isBlank(quote.Grid_Group_By__c))
          quote.Grid_Group_By__c = 'Categories';
          //Mukunth added below line for 6 digit project
          strQuoteCurcy = quote.currencyisocode;
      
        return quote;
    }
  
  // *** Method to generate query string to query Quote from the DB ***
    public String prepareQuoteQuery(Id quoteId)
    {
        String strQuoteQuery = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_On_Premise.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuoteQuery += field.getFieldPath() + ', ';
        
        strQuoteQuery += 'No_Of_Months__c,Ramp_Period__c,Initial_Subscription_Term__c,Deployment_Model__c,End_User_ID__r.Country__r.Name,Quote_Cloned_Revised__r.Name,BigMachines__Opportunity__r.Country_Sub_Region__c,';     
        strQuoteQuery += 'Renewal_Subscription_Term__c,Billing_Period__c,BigMachines__Opportunity__r.Direct_Sales__c,BigMachines__Opportunity__r.Country_Region__c,End_User_ID__r.Name,BigMachines__Opportunity__r.Name,MSA_Link__c,';
        strQuoteQuery += 'Product_Tier__c,BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country_DAP__c, BigMachines__Opportunity__r.New_DAP_Region__c,';
        strQuoteQuery += 'CMRR_Pre_Discount__c, ACV_Pre_Discount__c, TCV_Pre_Discount__c,Base_Agent_Discount__c,Hardware_Discount__c,Business_Users_Add_On__c,';
        strQuoteQuery += 'Data_Center_Provisioning_Discount__c, CMRR__c,Annual_Contract_Value__c,Total_Contract_Value__c,Deal_Qualification__c,Deal_Qualification__r.Status__c,Opp_Sold_To_Country__c,';
        strQuoteQuery += 'Owner.Name FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
        return strQuoteQuery;
    }
        
    // *** Method to get Quote Products ***
    public void getQuoteProducts(Id quoteId)
    {
        list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
        list_QuoteProducts = new List<QuoteProductWrapper>();
        objServiceLevel = null;
        objThirdPartyGCLine = null;
        blnHasHWLines = blnHasBundles = false;
        map_BundleQuoteProducts = new Map<Id,BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c eachQuoteProduct : (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId)))
        {
            if(eachQuoteProduct.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages')
                blnHasRDP = true;
      
            if(eachQuoteProduct.BigMachines__Product__r.Genesys_Care_Quote__c)
            {
                objServiceLevel = eachQuoteProduct;
                // Setting Service Level on Quote if it is blank
                if(String.isNotBlank(objServiceLevel.Product_Description__c) && String.isBlank(quote.Service_Level__c))
                {
                  List<String> list_Words = objServiceLevel.Product_Description__c.split(' ');
                  if(list_Words.size() > 0)
                    quote.Service_Level__c = list_Words[0];
                }
            }
      
          else if(eachQuoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care')
            objThirdPartyGCLine = eachQuoteProduct;
          //Commented By Ranjith on Jun 21, 2016 -- Starts  
          /*else if(eachQuoteProduct.BigMachines__Product__r.Type__c == 'Bundle')
          {
            QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
            wrapperRecord.record = eachQuoteProduct;
            list_QuoteProducts.add(wrapperRecord);
            list_QuoteProductRecords.add(eachQuoteProduct);
            blnHasBundles = true;
            map_BundleQuoteProducts.put(eachQuoteProduct.Id,eachQuoteProduct);
          }*/
          //Commented By Ranjith on Jun 21, 2016 -- Starts  
          else if(eachQuoteProduct.Bundle_Line__c != null)
          {
            // do nothing
          }
          
          else
          {
            QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
            wrapperRecord.record = eachQuoteProduct;
            list_QuoteProducts.add(wrapperRecord);
            list_QuoteProductRecords.add(eachQuoteProduct);
            if(eachQuoteProduct.BigMachines__Product__r.Type__c == 'Product – Hardware')
              blnHasHWLines = true;
          }
        }
    
    if(objServiceLevel == null)
      quote.Service_Level__c = 'Decline';
    }
    
    // *** Method to generate query string to query Quote Products from the DB ***
    public String prepareQuoteProductQuery(Id quoteId)
    {
        String strQueryAllFields = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFieldsOnPremise.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQueryAllFields += field.getFieldPath() + ', ';
        
        //Mukunth added BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c to below query for 6 digit project
        strQueryAllFields += 'Id,APN_Number__c,BigMachines__Product__r.New_Category__c,BigMachines__Product__r.Building_Block__c,BigMachines__Product__r.Sub_Category__c,BigMachines__Product__r.Flavors_Available__c,';
    strQueryAllFields += 'BigMachines__Product__r.Pricing_Model__c,BigMachines__Product__r.Is_Concurrent__c,BigMachines__Product__r.Genesys_Care_Quote__c,BigMachines__Product__r.Shipment_Approval__c,';
    strQueryAllFields += 'BigMachines__Product__r.Care_Rate_Applicable__c,BigMachines__Product__r.Type__c,Bundle__r.Name,BigMachines__Product__r.Name,BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c';
    
    if(String.isNotBlank(quote.New_Price_Book__c))
      strQueryAllFields += ',BigMachines__Product__r.' + quote.New_Price_Book__c + '_Price__c, BigMachines__Product__r.Description__c ';
    
        strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quoteId + '\'';
    
    if(quote.Grid_Group_By__c == 'Categories')
      strQueryAllFields += ' ORDER BY BigMachines__Product__r.New_Category__c ASC NULLS LAST,BigMachines__Product__r.Building_Block__c,BigMachines__Product__r.Anchor_Product__c,Product_Description__c';
    else if(quote.Grid_Group_By__c == 'Bundles/Products')
      strQueryAllFields += ' ORDER BY Bundle__c NULLS LAST,Bundle__r.Name,Product_Description__c';
    else if(quote.Grid_Group_By__c == 'Proposal Groups')
      strQueryAllFields += ' ORDER BY Group_Number__c NULLS LAST,Product_Description__c';
    else
      strQueryAllFields += ' ORDER BY Third_Party__c NULLS FIRST,Product_Description__c';
      
        return strQueryAllFields;
    }
    
  // *** Method to calculate proposal group Sub Totals ***
  public void calculateGroupSubTotals()
  {
    // Initializing sub totals
    objUngrouped.Sub_Total__c = 0;
    for(Quote_Proposal_Group__c objPG: list_ProposalGroups)
      objPG.Sub_Total__c = 0;
    
    for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
        {
      if(objQP.Ext_Net_Price__c != null)
      {
        Quote_Proposal_Group__c objPG;
        if(String.isNotBlank(objQP.Group_Number__c) && map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c))
          objPG = map_GroupNumToGrouprecord.get(objQP.Group_Number__c);
        else
          objPG = objUngrouped;
          
        objPG.Sub_Total__c += objQP.Ext_Net_Price__c;
      }
    }
  }
}