public class UpdateProductDetails2 {
    
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
    public List<SelectOption> Products {get; set;}
    
    public String selectedComponent {get;set;}
    public String selectedProblemCategory {get;set;}
    
    public String selectedProblemCategoryName {get;set;}
    
    public UpdateProductDetails2(ApexPages.StandardController controller) {
        isPureEngageCloud=false;
		isPureCloud = false;
        isPureConnectCloud =false;
        isElse =false;
        selectedProblemCategoryName='';
        selectedProblemCategory ='';
        
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
        if(!String.isBlank(c.Problem_Category__c)){
			selectedProblemCategory= c.Problem_Category__c;
        	selectedProblemCategoryName = c.Problem_Category__r.Name;
            OnloadProblemCategorys();
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
            
        /*ProductGroups = new List<SelectOption>();
        Products = new List<SelectOption>();
        components = new List<SelectOption>();
        ProblemCategorys = new List<SelectOption>();*/
        //onchangeCategory();
        //onchangeGroup();
        }else
        if(isPureCloud){
        	selectedCategory = 'PureCloud Products';
        	selectedProductGroup = 'None';
            
        ProductGroups = new List<SelectOption>();
        Products = new List<SelectOption>();
        components = new List<SelectOption>();
        ProblemCategorys = new List<SelectOption>();
        onchangeCategory();
        onchangeGroup();
        }
        
    }
    
    public List<SelectOption> components {
      get {
      
      system.debug('selectedProduct####compon##'+selectedProduct);
      
          List<SelectOption> comp = new List<SelectOption>();
          comp.add(new SelectOption('', '--None--'));  
          List<Support_Product__c> components =  [SELECT id, Name FROM Support_Product__c 
                     							  WHERE Parent_Product__c = :selectedProduct AND Parent_Product__c !='' 
                      							  AND Customer_Available__c = true AND Active__c = true ORDER BY Name ASC ];
         system.debug('components####'+components);            
         system.debug('components####'+components.size());   
                  
         for(Support_Product__c cmp:components){
            comp.add(new SelectOption(cmp.Id, cmp.Name));
         }
            
          return comp;
      }
      set;
   }
   
   public List<SelectOption> ProblemCategorys {
      get {
          List<SelectOption> pcat = new List<SelectOption>();
      		pcat.add(new SelectOption('', '--None--'));
          ProblemCategorys.clear();
        if(!String.isBlank(selectedProblemCategory)){
            pcat.add(new SelectOption(selectedProblemCategory, selectedProblemCategoryName)); 
            return pcat;
        }else{
          system.debug('Enter #####');
      
      
      
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
          
      system.debug('prodProbCategories####'+prodProbCategories);    
      //Map<Id, Map<Id, String>> prodProbCategories = SupportAccessProductSelector.getPureCnctProdWithProbCateg(false);
       if ( String.isNotBlank(selectedProduct) && prodProbCategories.get(selectedProduct) != null )  {
               Map<Id, String> grps = prodProbCategories.get(selectedProduct);
               for (Id grpId : grps.keySet() )
                     pcat.add( new SelectOption(grpId, grps.get(grpId)) );  
           }
       
            
       	return pcat;
        }
       }
      set;
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
            //SupportAccessProductSelector.getPureCnctGroupWithProducts(false);
        
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
             /*List<Support_Product__c> productGrp =  [SELECT id, Name, Parent_Product__c, Parent_Product__r.Name, Category__c FROM Support_Product__c 
                                                     WHERE Category__c = 'PureEngage Products'  
                                                     AND Status__c = 'Active' 
                                                     AND Customer_Available__c = true ORDER BY Name ASC];
            
        
        
        
        
        
        ProductGroups.clear();
            components.clear();
            for (Support_Product__c PrdGrp: productGrp)  {
                
                ProductGroups.add(new SelectOption(PrdGrp.Name,PrdGrp.Name));
            }        */   
            onchangeGroup();
        }else{
            ProductGroups.clear();
            components.clear();
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
                                                     AND Status__c = 'Active' 
                                                     AND Customer_Available__c = true 
                                                     ORDER BY Name ASC ];
        system.debug('product##'+product);
        system.debug('product size##'+product.size());
            Products.clear();
            components.clear();
            Products.add(new SelectOption('', '--None--'));
            if(product.isempty()){
                selectedProduct='';
                  
            }
            for (Support_Product__c Prds: product)  {
                
                Products.add(new SelectOption(Prds.id,Prds.Name));
            }           
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
    
    private void OnloadProblemCategorys() {
       ProblemCategorys.clear();
        if(!String.isBlank(selectedProblemCategory)){
            ProblemCategorys.add(new SelectOption(selectedProblemCategory, selectedProblemCategoryName)); 
        }else{
            ProblemCategorys.add(new SelectOption('', '--None--'));  
        }
                
	}
    
}