/************************************************************************************
Purpose : Controller for excel export in quoting tool
Written By : Ranjith Punneli
Test Classes : ExportToExcelCloudPCControllerTest
*************************************************************************************/

public with sharing class ExportToExcelCloudPCController
{
    public BigMachines__Quote__c quote {get; set;}
    public List<QuoteProductWrapper> list_QuoteProducts {get; set;} 
    String quoteId;
    
    // List of Group Headers i.e. Categories or Proposal Group Numbers
    public List<String> list_GroupHeaders {get; set;}
    
    // List of Proposal Groups being displayed
    public List<Quote_Proposal_Group__c> list_ProposalGroups {get; set;}
    // Map of Proposal Group Number to Record
    Map<String,Quote_Proposal_Group__c> map_GroupNumToGrouprecord;
    // Proposal Group record to store un-grouped amount
    public Quote_Proposal_Group__c objUngrouped {get; private set;}
    // All products excluding configuration products and bundle items products on the quote
    List<BigMachines__Quote_Product__c> list_QuoteProductRecords;
    
    // To indicate whether there is at least 1 Bundle
    public Boolean blnHasBundles {get; private set;}
    public User_Col_Preference__c objColumnPreference {get; set;}
    public String strCurrencySymbol {get; private set;}
        
    public class QuoteProductWrapper
    {
        public BigMachines__Quote_Product__c record {get; set;}
        public Boolean selected {get; set;}
        
        public QuoteProductWrapper()
        {
            selected = false;
        }
    }
    
    public ExportToExcelCloudPCController()
    {
        init();
    }
    
    private void init()
    {
        quoteId = ApexPages.currentPage().getParameters().get('id');
        objUngrouped = new Quote_Proposal_Group__c();
        
        //objColumnPreference = User_Col_Preference__c.getInstance(UserInfo.getUserId());
        List<User_Col_Preference__c> list_UserColPref = [SELECT Id,Third_Party__c,Name,Building_Block__c,Ext_List_Price__c,
                List_Price__c,Net_Unit_Price__c,PM_Approver__c,Product_Specific_Discount__c,Unit_of_measure__c, Sub_Category__c,Partner_Price__c 
                FROM User_Col_Preference__c WHERE User__c = :UserInfo.getUserId()];
        if(list_UserColPref.size() == 0)
          objColumnPreference = new User_Col_Preference__c(Third_Party__c = true,User__c = UserInfo.getUserId(),
                Building_Block__c = true,Ext_List_Price__c = true,List_Price__c = true,Net_Unit_Price__c = true,
                PM_Approver__c = true,Product_Specific_Discount__c = true,Unit_of_measure__c = true,Partner_Price__c = true);
        else
          objColumnPreference = list_UserColPref[0];
        
        // Fetching Quote information
        quote = getQuote((Id)quoteId);
        strCurrencySymbol = quote.CurrencyIsoCode;
        
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
      
        return quote;
    }
  
    // *** Method to generate query string to query Quote from the DB ***
    public String prepareQuoteQuery(Id quoteId)
    {
        String strQuoteQuery = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuoteQuery += field.getFieldPath() + ', ';
        
        strQuoteQuery += 'End_User_ID__r.Country__r.Name, Quote_Cloned_Revised__r.Name,';     
        strQuoteQuery += 'Sold_To_Name__r.Country__r.PSRDP_Region__c,Sold_To_Name__r.Country__r.Name,Sold_To_Name__r.Country__r.Region__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country__r.Old_Price_Book__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,BigMachines__Opportunity__r.Country__r.Name,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Name, BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email, BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,';        
        strQuoteQuery += 'Amendment_For__r.Quote__r.CMRR__c, Amendment_For__r.Quote__r.Annual_Contract_Value__c, Amendment_For__r.Quote__r.Total_Contract_Value__c,';        
        strQuoteQuery += 'Amendment_For__r.Quote__r.Total_Services__c, Amendment_For__r.Quote__r.Total_Education__c, Amendment_For__r.Quote__r.Total_Hardware__c,Amendment_For__r.Quote__r.Non_Recurring_Fees__c,';        
                
        strQuoteQuery += 'BigMachines__Opportunity__r.Account.Partner_Tier__c FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
        return strQuoteQuery;
    }
        
    // *** Method to get Quote Products ***
    public void getQuoteProducts(Id quoteId)
    {
        list_QuoteProducts = new List<QuoteProductWrapper>();
        list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
        blnHasBundles = false;
        for(BigMachines__Quote_Product__c eachQuoteProduct : (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId)))
        { 
            QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
            wrapperRecord.record = eachQuoteProduct;
            list_QuoteProducts.add(wrapperRecord);
            list_QuoteProductRecords.add(eachQuoteProduct);
            if(eachQuoteProduct.BigMachines__Product__r.Type__c == 'Bundle') {                  
                blnHasBundles = true;
            } 
        }
    }
    
    // *** Method to generate query string to query Quote Products from the DB ***
    public String prepareQuoteProductQuery(Id quoteId)
    {
        String strQueryAllFields = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Grid_Fields_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQueryAllFields += field.getFieldPath() + ', ';

        strQueryAllFields += 'Bundle__r.Name, BigMachines__Product__r.Tier__c,BigMachines__Product__r.Charge_Type__c, BigMachines__Product__r.Product_Group__c, BigMachines__Product__r.' + quote.New_Price_Book__c + '_Price__c,BigMachines__Product__r.Partner_Margin_Type__c';
        strQueryAllFields += ',BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quoteId + '\'' + ' AND Hide_Record__c = false';
        
        if(quote.Grid_Group_By__c == 'Categories')
            strQueryAllFields += ' ORDER BY BigMachines__Product__r.New_Category__c ASC NULLS LAST,BigMachines__Product__r.Building_Block__c,BigMachines__Product__r.Anchor_Product__c,BigMachines__Product__r.Sort_Order__c,BigMachines__Product__r.Name';
        
        else if(quote.Grid_Group_By__c == 'Recurring/Non-Recurring')
            strQueryAllFields += ' ORDER BY BigMachines__Product__r.Include_in_CMMR_Total__c DESC,BigMachines__Product__r.Sort_Order__c,BigMachines__Product__r.Name';
        
        else if(quote.Grid_Group_By__c == 'Bundles/Products')
            strQueryAllFields += ' ORDER BY Bundle__c NULLS LAST,Bundle__r.Name,BigMachines__Product__r.Sort_Order__c,BigMachines__Product__r.Name';
        
        else if(quote.Grid_Group_By__c == 'Proposal Groups')
            strQueryAllFields += ' ORDER BY Group_Number__c NULLS LAST,BigMachines__Product__r.Sort_Order__c,BigMachines__Product__r.Name';
        
        else
            strQueryAllFields += ' ORDER BY Third_Party__c NULLS FIRST, BigMachines__Product__r.Sort_Order__c, BigMachines__Product__r.Name';
        
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