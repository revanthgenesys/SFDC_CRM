public class showBundleProductsController {

    public List <wrapperList> listOfProducts {get;set;}
    public string bundletext {get;set;}

    public showBundleProductsController() {

        listOfProducts = new List <wrapperList> ();
        List < BigMachines__Quote_Product__c > quotebundleproduct = new List < BigMachines__Quote_Product__c > ();
        string quoteid = ApexPages.currentPage().getParameters().get('quoteid');
        string productid = ApexPages.currentPage().getParameters().get('productid');
        String productGroupId = ApexPages.currentPage().getParameters().get('pgId');  
       // BigMachines__Quote__c objQuote = [Select Offering_Type__c from BigMachines__Quote__c where id = :quoteid  ];      
        if(productGroupId != null){
            for(Product_Group_Item__c eachItem : [SELECT Product__r.Name, Product__r.Description, Product_Group__r.Name,Product_Group__r.Group_Type__c,Product_Type__c, Quantity__c,Product__r.APN_Number__c,Product_Group__r.Quote_Type__c,Product_Group__r.Offering_Type__C  
   
                                                   FROM Product_Group_Item__c WHERE Product_Group__c =: productGroupId]){
                    wrapperList newItem = new wrapperList();
                    newItem.Name = eachItem.Product__r.APN_Number__c  ;
                    newItem.Description =(eachItem.Product_Group__r.Quote_Type__c != 'PureCloud' && eachItem.Product_Group__r.Quote_Type__c != 'PureConnect Cloud' && eachItem.Product_Group__r.Offering_Type__c != 'PureConnect Subscription') ? eachItem.Product__r.Description : eachItem.Product__r.Name ; 
                    newItem.Quantity = eachItem.Quantity__c;  
                    newItem.ProductType = String.valueof(eachItem.Product_Type__c);      
                    newItem.GroupType = String.valueof(eachItem.Product_Group__r.Group_Type__c);
                    newItem.Offer = String.valueof(eachItem.Product_Group__r.Quote_Type__c);                                   
                    System.debug('###Item'+newItem);                                  
                    listOfProducts.add(newItem);
                    bundletext = eachItem.Product_Group__r.Name;                                          
            }
        }
        else{
            string bmproductid = ApexPages.currentPage().getParameters().get('id');
            //quotebundleproduct = [select id,name,Product__c,Product_Description__c from BigMachines__Quote_Product__c where BigMachines__Quote__c=:quoteid and   BigMachines__Product__c=:productid];
            quotebundleproduct = [select id, name, Product__c, Product_Description__c from BigMachines__Quote_Product__c where id =: bmproductid];
            
            if(quotebundleproduct.size() > 0){
                for(BigMachines__Quote_Product__c eachQP : [select id, name, Product_Description__c, Quantity__c from BigMachines__Quote_Product__c where BigMachines__Quote__c =: quoteid and Bundle_Line__c =: quotebundleproduct[0].id]){
                    wrapperList newItem = new wrapperList();
                    newItem.Name = eachQP.Name;
                    newItem.Description = eachQP.Product_Description__c;
                    newItem.Quantity = eachQP.Quantity__c;    
                    listOfProducts.add(newItem);
                }
                bundletext = quotebundleproduct[0].name;
            }
        }
    }
    
    public class wrapperList{
        public string Name {get; private set;}
        public string Description {get; private set;}
        public Decimal Quantity {get; private set;}
        public String ProductType{get;private set;}
        public String GroupType{get;private set;}
        public String Offer{get;private set;}
        
    }
}