// OrderLineItemToOpptyProductLinker controller class
// Used for the manual linking of an Order Line Item to an Opportunity Product, which is part of the RevPro integration functionality,
//  in particular as used by PS
// Author: Nik Mills
// Created: February 2019
// Test class/coverage provided by OrderLineItemToOpportunityProductLinker_Test

public with sharing class OrderLineItemToOpptyProductLinker
{
    public PageReference sourcePageRef;

    public String originatingOrderLineItemId {get;set;}
    public String selectedOppProductId {get;set;}
    public String BaseURL {get;set;}
    public String masterPSOpptyName {get;set;}
    public String masterPSOpptyID {get;set;}
    public String masterPSOpptyNumber {get;set;}
    public String parentOrderName {get;set;}
    public String sourceOrderLineItemName {get;set;}
    public String sourceOrderLineItemMaterialDescription {get;set;}
    public String sourceOrderLineItemSolutionNamesCoveredFormula {get;set;}
    public Decimal sourceOrderLineItemTotalPrice {get;set;}
    public String alreadyLinkedProductName {get;set;}
    public String sourceOrderLineItemCurrency {get;set;}
    public Boolean isAlreadyLinked {get;set;}
    public Boolean itemsAreAvailableToLinkTo {get;set;}
    public Boolean isPSMasterOpportunityLinkFound {get;set;}
    public Boolean isRecordSelected {get;set;}

    public List<OpportunityLineItem> opptyProducts;
    private List<OpportunityLineItem> selectedOpptyProd;
    private List<Order_Line_Item__c> thisOrderLineItem;
    private String psRecordTypeId;
    
    private ApexPages.StandardController stdCtrl;

    public OrderLineItemToOpptyProductLinker()
    {
        originatingOrderLineItemId = ApexPages.CurrentPage().getparameters().get('sourceOrderLineItemId');
        isAlreadyLinked = false;
        itemsAreAvailableToLinkTo = false;
        isPSMasterOpportunityLinkFound = false;
        isRecordSelected = false;
         
        CommonMethod();
        GetAssociatedOpportunityProducts();
    }
    
    public void CommonMethod()
    {
        BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
    }
       
    public void GetAssociatedOpportunityProducts()
    {
        System.Debug('NikM: Originating Order Line Item ID is: ' + originatingOrderLineItemId);
        // For CAS Linking for PS, the Order Line item will have a parent Order, which is linked to a CAS 1st Year or Renewal Opportunity,
        // which is turn should be linked to a PS Master Opportunity record
        if (originatingOrderLineItemId != null)
        {
            thisOrderLineItem = [SELECT Order_Line_18_Digit_ID__c, Name, Product__r.Name, Material_Description__c, Order__c, Order__r.Name, Order__r.Opportunity__c, 
                                CurrencyIsoCode, Total_Price__c, Order__r.Opportunity__r.Master_Opportunity__c, Order__r.Opportunity__r.Master_Opportunity__r.Name, 
                                Order__r.Opportunity__r.Master_Opportunity__r.RecordType.Name, Order__r.Opportunity__r.Master_Opportunity__r.OpportunityNumber__c, 
                                Associated_Opportunity_Product_ID__c, Associated_Opportunity_Product_Name__c,
                                Project_Name__c, Project_ID_Formula__c, Solution_Names_Covered1__c, Solution_Names_Covered1_Formula__c 
                                FROM Order_Line_Item__c WHERE Id =:originatingOrderLineItemId];
   
            masterPSOpptyName = thisOrderLineItem[0].Order__r.Opportunity__r.Master_Opportunity__r.Name;
            masterPSOpptyID = thisOrderLineItem[0].Order__r.Opportunity__r.Master_Opportunity__c;
            masterPSOpptyNumber = thisOrderLineItem[0].Order__r.Opportunity__r.Master_Opportunity__r.OpportunityNumber__c;
            parentOrderName = thisOrderLineItem[0].Order__r.Name;
            sourceOrderLineItemName = thisOrderLineItem[0].Name;
            sourceOrderLineItemMaterialDescription = thisOrderLineItem[0].Material_Description__c;
            sourceOrderLineItemTotalPrice = thisOrderLineItem[0].Total_Price__c;
            sourceOrderLineItemCurrency = thisOrderLineItem[0].CurrencyIsoCode;
            sourceOrderLineItemSolutionNamesCoveredFormula = thisOrderLineItem[0].Solution_Names_Covered1_Formula__c;
        
            System.Debug('NikM: Linked Opportunity Master Oppportunity is: ' + thisOrderLineItem[0].Order__r.Opportunity__r.Master_Opportunity__c + ', Master Opp Record Type is: ' + thisOrderLineItem[0].Order__r.Opportunity__r.Master_Opportunity__r.RecordType.Name);
            // Check that the Opportunity being linked to is a PS Opportunity, otherwise do not query further and return
            if (thisOrderLineItem[0].Order__r.Opportunity__r.Master_Opportunity__c != null)
            {
                if (thisOrderLineItem[0].Order__r.Opportunity__r.Master_Opportunity__r.RecordType.Name == 'Professional Services')
                {
                    isPSMasterOpportunityLinkFound = true;
                }
                else
                {
                    return;
                }
            }
            else
            {
                return;
            }
        
            System.Debug('NikM: About to retrieve oppty Products linked to Master Order Oppty ' + thisOrderLineItem[0].Order__r.Opportunity__r.Master_Opportunity__c);
            opptyProducts = [SELECT Id, Opportunity_Product_Line_Item_ID__c, Description__c, OpportunityId, Opportunity.Name, Product2Id, Product2.Name, Quantity__c, 
                UnitPrice, TotalPrice, POB_Type__c, Product_Category__c, Linked_Oppty_Product__c, Linked_Oppty_Product_ID__c, Linked_Oppty_Product_Name__c, Product_Type__c
                FROM OpportunityLineItem WHERE OpportunityId =: masterPSOpptyID AND (Product_Category__c = 'CAS' OR Product2.PS_Expert_Apps_Subscription_Item__c = TRUE)];
                
            // DEV Note: Will need to eventually limit the above query further to only the CAS or EA Subscription Items
            
            if (!opptyProducts.isEmpty())
            {
                itemsAreAvailableToLinkTo = true;
            }
                
            if (thisOrderLineItem[0].Associated_Opportunity_Product_ID__c != null && thisOrderLineItem[0].Associated_Opportunity_Product_ID__c != '')
            {
                selectedOppProductId = thisOrderLineItem[0].Associated_Opportunity_Product_ID__c ;
                alreadyLinkedProductName = thisOrderLineItem[0].Associated_Opportunity_Product_Name__c ;
                isAlreadyLinked = true;
                isRecordSelected = true;
            }
        }
    }
    
    public List<OpportunityLineItem> getopptyProducts()
    {
        return opptyProducts;
    }
    
    private PageReference ReturnToOrderLineItemPage()
    {
        sourcePageRef = new PageReference(BaseURL + '/' + originatingOrderLineItemId);
        sourcePageRef.setRedirect(true);
        return sourcePageRef;    
    }
    
    public PageReference LinkSelectedRecord()
    {
        System.Debug('Selected Oppty Product to Link ID is:' + selectedOppProductId);
        if (selectedOppProductId != null && selectedOppProductId != '')
        {
            isRecordSelected = true;
            thisOrderLineItem[0].Associated_Opportunity_Product_ID__c = selectedOppProductId;
            selectedOpptyProd = [SELECT Product2.Name, Linked_Oppty_Product_Name__c FROM OpportunityLineItem WHERE Id =: selectedOppProductId];
            
            thisOrderLineItem[0].Associated_Opportunity_Product_Name__c = selectedOpptyProd[0].Product2.Name + ' [Linked to ' + selectedOpptyProd[0].Linked_Oppty_Product_Name__c + ']';
            update thisOrderLineItem[0];
            
            return ReturnToOrderLineItemPage();
        }
        else
        {
            isRecordSelected = false;
           
            return null;
        }
    }
   
    public PageReference ClearLinkedItem()
    {
        // remove the linked opportunity product from the sourceOpptyProduct and return back to the OLI page
        thisOrderLineItem[0].Associated_Opportunity_Product_ID__c = null;
        thisOrderLineItem[0].Associated_Opportunity_Product_Name__c = null;
        update thisOrderLineItem[0];

        return ReturnToOrderLineItemPage();
    }
           
    public PageReference Cancel()
    {
        // Cancelled so return back to the Opportunity Product Line item page
        return ReturnToOrderLineItemPage();
    }
}