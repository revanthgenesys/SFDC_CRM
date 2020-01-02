public without sharing class UpdateProductDetailsHelper {
    
    private static List<Support_Product__c> prodsPC;
    private static List<Support_Product__c> productsAll;
    private static List<Support_Product__c> components;
    
    /// PureEngage Cloud/ PureCloud Products
   public static Map<Id, Map<Id, String>> getProdWithProbCateg(string selectedCategory,string selectedProductGroup) {
      Map<Id, Map<id, String>> prodProbCategories = new Map<Id, Map<Id, String>>();
      system.debug(selectedCategory+'selectedCategory#####selectedProductGroup'+selectedProductGroup);
      List<Support_Product__c> prods = getProducts(selectedCategory,selectedProductGroup);
      system.debug('prods#####'+prods);                   
      if ( !prods.isEmpty() )  {
         for ( Support_Product__c pr : prods ) {
            system.debug('prods#####pr'+pr.Support_Product_Related_Categories__r);  
            if ( pr.Support_Product_Related_Categories__r.isEmpty() ) 
                continue;
            
            for ( Support_Product_Related_Category__c relctg : pr.Support_Product_Related_Categories__r )  {
                if ( prodProbCategories.get(pr.Id) == null ) {
                    prodProbCategories.put(pr.Id, new Map<Id, String>{relctg.Support_Problem_Category__c => relctg.Support_Problem_Category__r.Name});
                }
                else {
                    Map<Id, String> categ = prodProbCategories.get(pr.Id);
                    categ.put(relctg.Support_Problem_Category__c, relctg.Support_Problem_Category__r.Name);
                    prodProbCategories.put(pr.Id, categ);
                }     
            }           
         }      
      }
    
      
          
      return prodProbCategories;
   }
   
   public static List<Support_Product__c> getProducts(string selectedCategory,string selectedProductGroup) {
    
      if ( prodsPC != null )
           return prodsPC;
         
         prodsPC =  [SELECT Id,Name, Product_Name__c, Product_Group__c, Category__c,
                        (SELECT Support_Problem_Category__c, Support_Problem_Category__r.Name
                         FROM Support_Product_Related_Categories__r
                         WHERE Support_Problem_Category__r.Status__c = 'Active')
                  FROM Support_Product__c 
                  WHERE (Category__c =: selectedCategory AND Product_Group__c =:selectedProductGroup)
                   AND Product_Type__c = 'Product' 
                   AND Customer_Available__c = true AND Active__c = true 
                   ORDER BY Product_Name__c];
     
      return prodsPC;
    
  }
  
  
    
    public static List<Support_Product__c> getComponentsByProduct2 (ID prodId) {
        if ( components != null )
           return components;
        
        if ( prodId == null )
           return null;
        
        components =  [SELECT id, Name 
                       FROM Support_Product__c 
                       WHERE    Parent_Product__c = :prodId
                        AND Customer_Available__c = true AND Status__c = 'Active'AND  Product_Type__c = 'Component'  ORDER BY Name ASC];
                
        return components;
    } 
    
}