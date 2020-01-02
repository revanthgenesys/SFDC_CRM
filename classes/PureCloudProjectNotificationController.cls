/************************************************************************************
Purpose : Component controller to display quote products in email template
Written By : Ranjith Punneli
Test Classes : PureCloudProjectTest
*************************************************************************************/

public without sharing class PureCloudProjectNotificationController {
    
    public Id quoteId {get; set;}
    
    public void PureCloudProjectNotificationController() {        
    }
    
    public String getUrlPrefix() {
        return System.URL.getSalesforceBaseUrl().toExternalForm() + '';
    }
    
    public List<BigMachines__Quote_Product__c> getQuoteProducts() {
        List<BigMachines__Quote_Product__c> list_objQPs = new List<BigMachines__Quote_Product__c>();
        list_objQPs = [SELECT Id, Name, BigMachines__Quote__c, BigMachines__Product__c, APN_Number__c,
                              BigMachines__Product__r.New_Category__c, BigMachines__Product__r.Sub_Category__c,
                              List_Price__c, Partner_Price__c, Net_Unit_Price__c, Quantity__c, Total_Discount__c,
                              Ext_List__c, Ext_Net_Price__c, BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c
                       FROM BigMachines__Quote_Product__c
                       WHERE BigMachines__Quote__c =: quoteId
                         AND Is_Overage__c = false
                         AND Hide_Record__c = false];        
        return list_objQPs;
    }
    
    public Account_Order_Address__c getBillToAddress() {
        //Logic to get Bill to address for this quote
        Account_Order_Address__c objBillToAddr = new Account_Order_Address__c();
        
        if(quoteId != null) {
            objBillToAddr = [SELECT Id, Address__c, City__c, Country__c, State__c, Zip_Code__c
                             FROM Account_Order_Address__c 
                             WHERE Quote__c =: quoteId
                               AND Address_Type__c = 'Bill To' LIMIT 1];            
        }
        return objBillToAddr;
    }
    
    public List<Account_Order_Address__c> getShipToAddresses() {
        //Logic to get ship to addresses for this quote
        List<Account_Order_Address__c> list_ShipToAddrs = new List<Account_Order_Address__c>();
        if(quoteId != null) {
            list_ShipToAddrs = [SELECT Id, Address__c, City__c, Country__c, State__c, Zip_Code__c
                                FROM Account_Order_Address__c 
                                WHERE Quote__c =: quoteId
                                  AND Address_Type__c = 'Ship To' LIMIT 10];
        }
        return list_ShipToAddrs;
    }
}