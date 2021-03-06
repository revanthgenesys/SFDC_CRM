//Naresh Kumar	11/05/2014
public without sharing class QuoteProductsPMEmailTemplateControlller {
	public Id quoteId {get; set;}
	public Id dqId {get; set;}
    public List<BigMachines__Quote_Product__c> getProducts() {
       if(quoteId != null){
        List<BigMachines__Quote_Product__c> quoteProducts = [SELECT Name, Product_Description__c, List_Price__c, Ext_List__c,
        	BigMachines__Quantity__c, Net_Unit_Price__c, Total_Discount__c, Ext_Net_Price__c, Product_Specific_Discount__c FROM BigMachines__Quote_Product__c
            WHERE BigMachines__Quote__c = :quoteId AND BigMachines__Product__r.Type__c != 'Bundle'];
            if(quoteProducts != null  && !quoteProducts.isEmpty())
                return quoteProducts;        
       }       
       return null;
    }	
    
    public List<Deal_Qualification_Products__c> getDQProducts() {
       if(dqId != null){
        List<Deal_Qualification_Products__c> dqProducts = [SELECT Product__r.Name, Product__r.Description__c, Discount__c,
        	Quantity__c FROM Deal_Qualification_Products__c
            WHERE Deal_Qualification__c = :dqId AND Discount__c > 0 AND Quantity__c>0 AND Product__r.Type__c != 'Bundle'];
            if(dqProducts != null  && !dqProducts.isEmpty())
                return dqProducts;        
       }       
       return null;
    }
}