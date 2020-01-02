// OpportunityProductLinker controller class
// Used for the manual linking of one opportunity product to another, which is part of the RevPro integration functionality,
//  in particular as used by PS
// Author: Nik Mills
// Created: November 2018
// Test class/coverage provided by OpportunityProductLinker_Test

public with sharing class OpportunityProductLinker
{
    public PageReference sourcePageRef;

    public String originatingOppProductId {get;set;}
    public String selectedOppProductId {get;set;}
    public String BaseURL {get;set;}
    public String parentOppName {get;set;}
    public String sourceOpptyProductName {get;set;}
    public String alreadyLinkedProductName {get;set;}
    public Boolean isAlreadyLinked {get;set;}
    public Boolean itemsAreAvailableToLinkTo {get;set;}

    public List<OpportunityLineItem> opptyProducts;
    private List<OpportunityLineItem> thisOpptyProduct;
    
    private ApexPages.StandardController stdCtrl;

    public OpportunityProductLinker()
    {
        originatingOppProductId = ApexPages.CurrentPage().getparameters().get('sourceOppProdId');
        isAlreadyLinked = false;
        itemsAreAvailableToLinkTo = false;
         
        CommonMethod();
        GetAssociatedOpportunityProducts();
    }
    
    public void CommonMethod()
    {
        BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
    }
       
    public void GetAssociatedOpportunityProducts()
    {
        System.Debug('NikM: Originating Opp Product ID is: ' + originatingOppProductId);
        if (originatingOppProductId != null)
        {
            thisOpptyProduct = [SELECT OpportunityId, Linked_Oppty_Product_ID__c, Linked_Oppty_Product_Name__c, Opportunity.Name, Product2.Name FROM OpportunityLineItem WHERE Id =:originatingOppProductId];
            parentOppName = thisOpptyProduct[0].Opportunity.Name;
            sourceOpptyProductName = thisOpptyProduct[0].Product2.Name;
        
            System.Debug('NikM: About to retrieve oppty Products linked to Oppty ' + thisOpptyProduct[0].OpportunityId);
            opptyProducts = [SELECT Id, Opportunity_Product_Line_Item_ID__c, Description__c, OpportunityId, Opportunity.Name, Product2Id, Product2.Name, Quantity__c, 
                UnitPrice, TotalPrice, POB_Type__c, Product_Category__c, Linked_Oppty_Product__c, Linked_Oppty_Product_ID__c, Linked_Oppty_Product_Name__c, Product_Type__c
                FROM OpportunityLineItem WHERE OpportunityId =: thisOpptyProduct[0].OpportunityId AND Opportunity_Product_Line_Item_ID__c !=: originatingOppProductId];
            
            if (!opptyProducts.isEmpty())
            {
                itemsAreAvailableToLinkTo = true;
            }
                
            if (thisOpptyProduct[0].Linked_Oppty_Product_ID__c != null && thisOpptyProduct[0].Linked_Oppty_Product_ID__c != '')
            {
                selectedOppProductId = thisOpptyProduct[0].Linked_Oppty_Product_ID__c;
                alreadyLinkedProductName = thisOpptyProduct[0].Linked_Oppty_Product_Name__c;
                isAlreadyLinked = true;
            }
        }
    }
    
    public List<OpportunityLineItem> getopptyProducts()
    {
        return opptyProducts;
    }
    
    private PageReference ReturnToOpptyProductPage()
    {
        sourcePageRef = new PageReference(BaseURL + '/' + originatingOppProductId);
        sourcePageRef.setRedirect(true);
        return sourcePageRef;    
    }
    
    public PageReference LinkSelectedRecord()
    {
        System.Debug('Selected Oppty Product to Link ID is:' + selectedOppProductId);
        thisOpptyProduct[0].Linked_Oppty_Product_ID__c = selectedOppProductId;
        update thisOpptyProduct[0];
        
        return ReturnToOpptyProductPage();
    }
   
    public PageReference ClearLinkedItem()
    {
        // remove the linked opportunity product from the sourceOpptyProduct and return back to the OLI page
        thisOpptyProduct[0].Linked_Oppty_Product_ID__c = null;
        thisOpptyProduct[0].Linked_Oppty_Product_Name__c = null;
        update thisOpptyProduct[0];

        return ReturnToOpptyProductPage();
    }
           
    public PageReference Cancel()
    {
        // Cancelled so return back to the Opportunity Product Line item page
        return ReturnToOpptyProductPage();
    }
}