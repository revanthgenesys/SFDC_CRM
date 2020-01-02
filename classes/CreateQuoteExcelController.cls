/************************************************************************************
Purpose :  Controller class for the excel export vf page for the quote
Written By :  Naresh Kumar	03/21/2018
Test Classes : CreateQuoteExcelControllerTest 
*************************************************************************************/
public class CreateQuoteExcelController {
    public List<BigMachines__Quote_Product__c> listOfQuoteProducts {get; private set;}
    public BigMachines__Quote__c objQuote {get; private set;}
    public CreateQuoteExcelController(){
    	String quoteId = ApexPages.currentPage().getParameters().get('id');
        listOfQuoteProducts = [SELECT BigMachines__Quote__r.CreatedDate, BigMachines__Quote__r.Quote_Created_Date__c, BigMachines__Quote__r.Opportunity_Close_Date__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Age_Opp__c, BigMachines__Quote__r.BigMachines__Opportunity__r.NumberofAgents__c, BigMachines__Quote__r.License_Amount__c, 
            BigMachines__Quote__r.BigMachines__Opportunity__r.Name, BigMachines__Quote__r.Opp_End_User_Country__c, BigMachines__Quote__r.End_User_ID__r.Name, BigMachines__Quote__r.End_User_ID__r.SAP_Account_Code__c, BigMachines__Quote__r.Sold_To_Name__r.SAP_Account_Code__c, BigMachines__Quote__r.Sold_To_Name__r.Name,
            BigMachines__Quote__r.BigMachines__Opportunity__r.OpportunityNumber__c, BigMachines__Quote__r.Offering_Type__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Offering_Detail__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Type, BigMachines__Quote__r.Quote_Opportunity_Type__c,
            BigMachines__Quote__r.End_User_ID__r.Key_Account_Group__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Who_did_Genesys_Replace__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Competitor__c, BigMachines__Quote__r.End_User_ID__r.Industry, BigMachines__Quote__r.End_User_ID__r.Industry__c,
            BigMachines__Quote__r.BigMachines__Opportunity__r.MKTG_Sourced__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Partner_Opportunity_Source__c, BigMachines__Quote__r.ELA__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Direct_Sales__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Name, BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.RU__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.SubRU__c,
            BigMachines__Quote__r.Quote_Number__c, BigMachines__Quantity__c, Unit_of_Measure__c, BigMachines__Product__c, BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Category__c,
            BigMachines__Product__r.Taxonomy_Solution__c, BigMachines__Product__r.Product_Financial__c, BigMachines__Product__r.Third_Party__c, BigMachines__Product__r.Name,
            BigMachines__Product__r.Description, New_Ext_Net_Price_USD__c, Ext_Net_Price__c, Genesys_Care_Amount__c, New_Ext_Net_Price__c, New_Equivalent_Total_New_Price_USD__c, New_Genesys_Care_Amount_USD__c,BigMachines__Quote__r.BigMachines__Opportunity__c, BigMachines__Quote__r.BigMachines__Opportunity__r.ForecastStatus__c, BigMachines__Quote__r.BigMachines__Opportunity__r.StageName, BigMachines__Quote__r.BigMachines__Opportunity__r.Fiscal_Period_Opp__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Primary_Line_of_Business__c,
            BigMachines__Product__r.Type__c, Total_Discount__c, BigMachines__Quote__r.Order_Payment_Terms__c, BigMachines__Quote__r.Pricing_Model__c, BigMachines__Quote__r.New_Price_Book__c, BigMachines__Sales_Price__c, Equivalent_New_List_Price__c,
            BigMachines__Quote__r.Special_Offer_Terms__c, Ext_List__c, Maintenance_Due__c, Bundle__r.Group_Type__c, BigMachines__Quote__r.End_User_ID__r.Vertical_Markets__c,
            NewExtListPrice__c, CurrencyIsoCode, Level_Of_Support__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId];
        
        objQuote = [SELECT id, Name, Revision_No__c, Offering_Type__c FROM BigMachines__Quote__c WHERE id =: quoteId];
    }
}