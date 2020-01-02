public with sharing class CreateRenewalProductUpgrade { 

  public String quoteId {get; set;}
  public BigMachines__Quote__c quote {get; set;}
  public List<BigMachines__Quote_Product__c> list_QuoteProductRecords{get;set;}
  public List<cProduct> productList {get; set;}
  public List<BigMachines__Quote_Product__c> selectedProducts {get;set;}
  

 
 
   public CreateRenewalProductUpgrade () { 
     init();
    }
 
    private void init() {
     quoteId = ApexPages.currentPage().getParameters().get('id');
     list_QuoteProductRecords = [Select id, BigMachines__Product__c,BigMachines__Quote__c,Product_Description__c,BigMachines__Product__r.Product_Upgrade__c ,
      BigMachines__Product__r.Product_Upgrade__r.description,APN_Number__c,BigMachines__Product__r.Product_Upgrade__r.APN_Number__c from BigMachines__Quote_Product__c where BigMachines__Quote__c  =:quoteid and BigMachines__Product__r.Product_Upgrade__c <> ''];
        
       productList = new List<cProduct>();
 
       for(BigMachines__Quote_Product__c c :list_QuoteProductRecords)
         productList.add(new cProduct(c));

     quote = [select id,name from BigMachines__quote__c where id =:quoteId];
    }


    public PageReference processSelected() {
      selectedProducts = new List<BigMachines__Quote_Product__c>();
      
      List <BigMachines__Quote_Product__c> list_ToUpdate = new List<BigMachines__Quote_Product__c>();
      List <Quote_Products_Upgrade__c> history= new List<Quote_Products_Upgrade__c>();
       
       for(cProduct cCon: productList) {
            if(cCon.selected == true) {
                selectedProducts.add(cCon.product);
            }
        }
        
        
       for(BigMachines__Quote_Product__c cp: selectedProducts)  {
           Quote_Products_Upgrade__c objProdUpgradeHistory = new Quote_Products_Upgrade__c
          (Quote__c = cp.BigMachines__Quote__c,From__c =cp.BigMachines__Product__c,To__c = cp.BigMachines__Product__r.Product_Upgrade__c);
     
          cp.BigMachines__Product__c = cp.BigMachines__Product__r.Product_Upgrade__c;
           cp.Is_Product_Upgraded__c = true;
            list_ToUpdate.add(cp);
            history.add(objProdUpgradeHistory);
        }
         
        
        if(list_ToUpdate.size() > 0)  {
            update list_ToUpdate;
            insert history;  
         }
    
         init();

     return null;
    }
  


   public class cProduct {
     public BigMachines__Quote_Product__c product {get; set;}
     public Boolean selected {get; set;}
        public cProduct(BigMachines__Quote_Product__c c) {
         product = c;
         selected = false;
       }
    }


}