public class UpdateProductDetailsController {
    
    public Boolean isPureEngageCloud {get; set;}
    public Boolean isPureCloud {get; set;}
    public Boolean isPureConnectCloud {get; set;}
    public Boolean isElse {get; set;}
    public Case c {get; set;}
    Public string CloudPlatform {get;set;}
    public String selectedCategory {get; set;}
    public String selectedProductGroup {get; set;}
    public List<SelectOption> ProductGroups {get; set;}
    public String selectedProduct {get; set;}
    public String selectedProductName {get; set;}
    public List<SelectOption> Products {get; set;}
    public List<SelectOption> components {get; set;}
    public String selectedComponent {get;set;}
    public String selectedComponentName {get;set;}
    public List<SelectOption> ProblemCategorys {get; set;}
    public String selectedProblemCategory {get;set;}
    public String selectedProblemCategoryName {get;set;}
    
    
    public UpdateProductDetailsController(ApexPages.StandardController controller) {
        isPureEngageCloud=false;
		isPureCloud = false;
        isPureConnectCloud =false;
        isElse =false;
        selectedProduct='';
        selectedProductName='';
        selectedComponent='';
        selectedComponentName='';
        
        ProductGroups = new List<SelectOption>();
        Products = new List<SelectOption>();
        components = new List<SelectOption>();
        ProblemCategorys = new List<SelectOption>();
        
        String CaseID = ApexPages.currentPage().getParameters().get('id'); 
        
        system.debug('CaseID ###'+CaseID);
        c = [SELECT Id,Cloud_Platform__c,Support_Product__c,Support_Product__r.Name,Component__c,
             Component__r.Name,Problem_Category__c,Problem_Category__r.Name 
             FROM Case WHERE ID=:CaseID];
        
        CloudPlatform = c.Cloud_Platform__c;
        
        if(!String.isBlank(c.Support_Product__c)){
            selectedProduct= c.Support_Product__c;
        	selectedProductName = c.Support_Product__r.Name;
        }
        if(!String.isBlank(c.Problem_Category__c)){
			selectedProblemCategory= c.Problem_Category__c;
        	selectedProblemCategoryName = c.Problem_Category__r.Name;
        }
        if(!String.isBlank(c.Component__c)){
            selectedComponent= c.Component__c;
        	selectedComponentName = c.Component__r.Name;
        }
        
        
        if(c.Cloud_Platform__c =='PureEngage Cloud'){
            isPureEngageCloud = True;
        }else 
        if(c.Cloud_Platform__c =='PureCloud'){
            isPureCloud = True;
        }else 
        if(c.Cloud_Platform__c =='PureConnect Cloud'){
            isPureConnectCloud = True;
        }else{
            isElse = True;
        }
        
        
            
        if(isPureEngageCloud){
        	selectedCategory = 'PureEngage Products';
        	selectedProductGroup = 'None';
            
        onchangeCategory();
        OnloadProduct();
        OnloadComponent();
            //if(!String.isBlank(selectedProblemCategory)){
                OnloadProblemCategorys();
            //}
        //OnloadProblemCategorys();
        }else
        if(isPureCloud){
        	selectedCategory = 'PureCloud Products';
        	selectedProductGroup = 'None';
        
            onchangeCategory();
        	OnloadProduct();
            if(!String.isBlank(selectedProblemCategory)){
                OnloadProblemCategorys();
            }
            
        }
        
    }
    
    public void fetchcomponents() {
        system.debug('selectedCAt###'+selectedCategory);
        system.debug('selectedProductGroup###'+selectedProductGroup);
        system.debug('selectedProduct###'+selectedProduct);
        
		components.add(new SelectOption('', '--None--'));  
        List<Support_Product__c> component =  [SELECT id, Name FROM Support_Product__c 
                     						   WHERE Parent_Product__c = :selectedProduct AND Parent_Product__c !='' 
                                               AND Product_Type__c = 'Component' 
                      						   AND Customer_Available__c = true AND Active__c = true ORDER BY Name ASC ];
        system.debug('Result comp###'+component);
         
        for(Support_Product__c cmp:component){
            components.add(new SelectOption(cmp.Id, cmp.Name));
         }
   }
   
	public void FetchProblemCategorys() {
        
        system.debug('selectedCAt###'+selectedCategory);
        system.debug('selectedProductGroup###'+selectedProductGroup);
        system.debug('selectedProduct###'+selectedProduct);
   		ProblemCategorys.add(new SelectOption('', '--None--'));
      
      	Map<Id, Map<id, String>> prodProbCategories = new Map<Id, Map<Id, String>>();
      	List<Support_Product__c> prods = [SELECT Id, Product_Name__c, Product_Group__c, Category__c,
             						   	(SELECT Support_Problem_Category__c, Support_Problem_Category__r.Name
                         				 FROM Support_Product_Related_Categories__r
                         				 WHERE Support_Problem_Category__r.Status__c = 'Active')
                  					     FROM Support_Product__c 
                                        WHERE (Category__c =: selectedCategory AND Product_Group__c =:selectedProductGroup)
                      					AND Product_Type__c = 'Product' 
                   						AND Customer_Available__c = true AND Active__c = true 
                   						ORDER BY Product_Name__c];
        system.debug('Result###'+prods);
      if ( !prods.isEmpty() )  {
       for ( Support_Product__c pr : prods ) {
         
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
          
      if ( String.isNotBlank(selectedProduct) && prodProbCategories.get(selectedProduct) != null )  {
               Map<Id, String> grps = prodProbCategories.get(selectedProduct);
               for (Id grpId : grps.keySet() )
                     ProblemCategorys.add( new SelectOption(grpId, grps.get(grpId)) );  
           }
   }
   
   
    public List<SelectOption> categories {
      
      
      get {
      
          List<SelectOption> catg = new List<SelectOption>();
          system.debug(isPureEngageCloud+'#######'+isPureCloud);
          if(isPureEngageCloud){
          	catg.add(new SelectOption('PureEngage Products', 'PureEngage Products'));
            catg.add(new SelectOption('Custom PS Applications', 'Custom PS Applications'));     
          }else
              if(isPureCloud){
              	catg.add(new SelectOption('PureCloud Products', 'PureCloud Products'));
            	catg.add(new SelectOption('Custom PS Applications', 'Custom PS Applications'));   
              }
            
          
          return catg;
      }
      set;
   }
   
    
    public void onchangeCategory() {
    if(selectedCategory == 'PureEngage Products' || selectedCategory == 'PureCloud Products'){
            
        Map<String, Map<Id, String>> groupWtProds = new Map<String, Map<Id, String>> ();
        
        Map<String, Map<Id, String>> groupWithProds = new  Map<String, Map<Id, String>>();
        
         List<Support_Product__c> prods =  [SELECT Id, Product_Name__c, Product_Group__c, Category__c,
             									(SELECT Support_Problem_Category__c, Support_Problem_Category__r.Name
                         						FROM Support_Product_Related_Categories__r
                         						WHERE Support_Problem_Category__r.Status__c = 'Active')
                  							FROM Support_Product__c 
                  							WHERE Category__c =:selectedCategory 
                   							//AND Product_Type__c = 'Product' 
                   							AND Customer_Available__c = true 
                   							ORDER BY Product_Name__c ];
        
			if ( !prods.isEmpty() )  {
       for ( Support_Product__c pr : prods ) {
         if ( String.isBlank(pr.Product_Group__c) )
            continue;
         
         if ( groupWithProds.get(pr.Product_Group__c) == null ) {
           groupWithProds.put(pr.Product_Group__c, new Map<Id, String>{pr.Id => pr.Product_Name__c});
         }
         else {
           Map<Id, String> prds = groupWithProds.get(pr.Product_Group__c);
           prds.put(pr.Id, pr.Product_Name__c);
           groupWithProds.put(pr.Product_Group__c, prds);
         }    
       }      
    }
        
        groupWtProds.putAll(groupWithProds);
        Set<String> grps = groupWtProds.keySet();
        ProductGroups.clear();
        components.clear();
        
        if(grps.size()==1){
            for (string grp : grps) {
                  if ( grp != 'Custom App for PureConnect')
                   ProductGroups.add( new SelectOption(grp, grp) ); 
                  selectedProductGroup=grp;
             }
             
        }else{  
        ProductGroups.add(new SelectOption('', '--None--'));
        for (string grp : grps) {
                  if ( grp != 'Custom App for PureConnect')
                   ProductGroups.add( new SelectOption(grp, grp) ); 
             }
        }
          
            onchangeGroup();
        }else{
            ProductGroups.clear();
            components.clear();
            //ProblemCategorys.clear();
            if(isPureEngageCloud){
            	ProductGroups.add(new SelectOption('Custom App for PureEngage','Custom App for PureEngage'));
            	selectedProductGroup='Custom App for PureEngage';
            }else
                if(isPureCloud){
                    ProductGroups.add(new SelectOption('Custom App for PureCloud','Custom App for PureCloud'));
            		selectedProductGroup='Custom App for PureCloud';
                }
            onchangeGroup();
        }
         
        }
    
    public void onchangeGroup() {
        
        system.debug('selectedCategory##'+selectedCategory);
        system.debug('selectedProductGroup##'+selectedProductGroup);
        List<Support_Product__c> product =  [SELECT id, Name, Parent_Product__c, Parent_Product__r.Name, Category__c FROM Support_Product__c 
                                                     WHERE Category__c =: selectedCategory
                                                     AND Product_Group__c =: selectedProductGroup  
                                             		 AND Product_Type__c = 'Product' 
                                                     AND Status__c = 'Active' 
                                                     AND Customer_Available__c = true 
                                                     ORDER BY Name ASC ];
        system.debug('product##'+product);
        system.debug('product size##'+product.size());
            Products.clear();
        system.debug('selectedComponentc###'+selectedComponent);
        system.debug('selectedCAt###'+selectedCategory);
        system.debug('selectedProductGroup###'+selectedProductGroup);
        	components.clear();
        	fetchcomponents();
        	
        
            Products.add(new SelectOption('', '--None--'));
            if(product.isempty()){
                
            }
            for (Support_Product__c Prds: product)  {
                
                Products.add(new SelectOption(Prds.id,Prds.Name));
            }  
        	
        	ProblemCategorys.clear();
        	FetchProblemCategorys();
    }
    
    public PageReference saveCaseUpdates() {   
     
         if ( !verifyRequiredInput() )
             return null;
        
     try { 
         
          c.Support_Product__c = selectedProduct;
          if(!String.isBlank(selectedComponent)){
          	c.Component__c = selectedComponent;
          }
          if(!String.isBlank(selectedProblemCategory)){
          	c.Problem_Category__c = selectedProblemCategory;
          }
          
          update c;
                  
       }
       catch(Exception ex) {  
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating the Case. Additional details: ' + ex.getMessage() );
           ApexPages.addMessage(msg); 
           return null;
       }

       return new PageReference('/' + c.Id);
   }
    
	 private Boolean verifyRequiredInput() {         
       Boolean reqErr = false; 
                      
       if ( String.isBlank(selectedCategory) || String.isBlank(selectedProductGroup) || String.isBlank(selectedProduct) ) {
                reqErr = true;
       } 
       
      if ( reqErr )  {
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please populate all required fields.');
           ApexPages.addMessage(msg);                                   
           return false;                                    
       }
      
       return true;                
   }
    
	private void OnloadProduct() {
        system.debug('Pordexist#####'+selectedProduct);
       products.clear();
        if(!String.isBlank(selectedProduct)){
            products.add(new SelectOption(selectedProduct, selectedProductName)); 
        }else{
            products.add(new SelectOption('', '--None--'));  
        }
                
    } 
    
	private void OnloadComponent() {
       components.clear();
        if(!String.isBlank(selectedComponent)){
            components.add(new SelectOption(selectedComponent, selectedComponentName)); 
        }else{
            components.add(new SelectOption('', '--None--'));  
        }
                
	}
    
    private void OnloadProblemCategorys() {
       ProblemCategorys.clear();
        if(!String.isBlank(selectedProblemCategory)){
            ProblemCategorys.add(new SelectOption(selectedProblemCategory, selectedProblemCategoryName)); 
        }else{
            ProblemCategorys.add(new SelectOption('', '--None--'));  
        }
                
	}
    
    public void onchangeProduct() {
        ProblemCategorys.clear();
        FetchProblemCategorys();
        components.clear();
        fetchcomponents();
    }
    
}