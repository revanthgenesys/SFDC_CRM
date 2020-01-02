/*********************************************************************************************
Purpose :  Controller for the UpdateProductDetails page used in Update Product button on Case
Written By :  ChandraMouli N
Test Classes :  TestUpdateProductDetailsCntrl
**********************************************************************************************/

public class UpdateProductDetailsCntrl {
    
    public Boolean isPureEngageCloud {get; set;}
    public Boolean isPureCloud {get; set;}
    public Boolean isPureConnectCloud {get; set;}
    public Boolean isElse {get; set;}
    
    public String boaPlatform {get; set;}
    public String selectedCategory {get; set;}
    public String selectedProduct {get;set;}
    public Case cs {get; set;}
    
    public List<SelectOption> products {get; set;}
    private List<SelectOption> productsStandard;
    public List<SelectOption> pureCnctProbCateg {get; set;}
    public String selectedPureCnctProblm {get; set;}
    public String selectedComponent {get;set;}
    public List<SelectOption> components {get; set;}
    private Map<ID, Support_Product__c> compsByProd;
    public String selectedPureCnctGrp {get; set;}
    public List<SelectOption> pureCnctGroups {get; set;}
    
    public UpdateProductDetailsCntrl(ApexPages.StandardController controller) {
        ID caseId;
        
        String caseidstr = ApexPages.currentPage().getParameters().get('id'); 
        
        boaPlatform = '';
        selectedProduct ='';
        selectedPureCnctProblm = '';
        selectedComponent ='';
        selectedPureCnctGrp = '';
        
        isPureEngageCloud=false;
        isPureCloud = false;
        isPureConnectCloud =false;
        isElse =false;
        
        products = new List<SelectOption>();
        productsStandard = new List<SelectOption>();
        pureCnctProbCateg = new List<SelectOption>();
        components = new List<SelectOption>();
        compsByProd = new Map<ID, Support_Product__c>();
        pureCnctGroups = new List<SelectOption>();
        
        caseId = Id.ValueOf(caseidstr); 
        initCaseUpd(caseId);
    }
    
    private void initCaseUpd(Id caseId)  {
        cs = [SELECT id, Support_Product__r.Category__c,Support_Product__c, Component__c, 
              Cloud_Platform__c, Problem_Category__c, Product_Group__c
              FROM Case WHERE id =: caseId];
            boaPlatform = cs.Cloud_Platform__c;
        
        if(cs.Cloud_Platform__c =='PureEngage Cloud'){
            isPureEngageCloud = True;
        }else 
        if(cs.Cloud_Platform__c =='PureCloud'){
            isPureCloud = True;
        }else 
        if(cs.Cloud_Platform__c =='PureConnect Cloud'){
            isPureConnectCloud = True;
        }else{
            isElse = True;
        }
        
        if(isPureEngageCloud){
            
            if(String.isNotBlank(cs.Support_Product__c)){
                selectedCategory= cs.Support_Product__r.Category__c;
                selectedPureCnctGrp = cs.Product_Group__c;
                populateProducts(); 
                selectedProduct = cs.Support_Product__c;
                setPureCnctGroups();
                selectedPureCnctGrp = cs.Product_Group__c;
                onchangeProduct();
                selectedPureCnctProblm = cs.Problem_Category__c;
                selectedComponent = cs.Component__c;
            }else{
                selectedCategory= 'PureEngage Products';
                setPureCnctGroups();
                populateProducts();
            }
            
        }else
            if(isPureCloud){
                if(String.isNotBlank(cs.Support_Product__c)){
                selectedCategory= cs.Support_Product__r.Category__c;
                selectedPureCnctGrp = cs.Product_Group__c;
                populateProducts(); 
                selectedProduct = cs.Support_Product__c;
                setPureCnctGroups();
                selectedPureCnctGrp = cs.Product_Group__c;
                onchangeProduct();
                selectedPureCnctProblm = cs.Problem_Category__c;
                selectedComponent = cs.Component__c;
            }else{
                selectedCategory= 'PureCloud Products';
                setPureCnctGroups();
                populateProducts();
            }
                
            }
        
    }
    
     public List<SelectOption> categories {
      get {
          List<SelectOption> catg = new List<SelectOption>();

          if (boaPlatform == ('PureEngage Cloud'))  {
                catg.add(new SelectOption('PureEngage Products', 'PureEngage Products'));
                catg.add(new SelectOption('Custom PS Applications', 'Custom PS Applications'));
          }              
          else if (boaPlatform == ('PureCloud')){
                catg.add(new SelectOption('PureCloud Products', 'PureCloud Products'));
                catg.add(new SelectOption('Custom PS Applications', 'Custom PS Applications'));
          }  
          return catg;
      }
      set;
   }
    
    public void setPureCnctGroups() {  
        resetPureCnctGroup();  
        system.debug('selectedCategory@@@@@'+selectedCategory);
        if(selectedCategory == 'PureEngage Products' || selectedCategory == 'PureCloud Products'){
            
        Map<String, Map<Id, String>> groupWtProds = new Map<String, Map<Id, String>> ();
        
        Map<String, Map<Id, String>> groupWithProds = new  Map<String, Map<Id, String>>();
        
         List<Support_Product__c> prods =  [SELECT Id, Product_Name__c, Product_Group__c, Category__c,
                                                (SELECT Support_Problem_Category__c, Support_Problem_Category__r.Name
                                                FROM Support_Product_Related_Categories__r
                                                WHERE Support_Problem_Category__r.Status__c = 'Active')
                                            FROM Support_Product__c 
                                            WHERE Category__c =:selectedCategory 
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
        pureCnctGroups.clear();
        
        if(grps.size()==1){
            //pureCnctGroups.add(new SelectOption('', '--None--'));
            for (string grp : grps) {
                  if ( grp != 'Custom App for PureConnect')
                   pureCnctGroups.add( new SelectOption(grp, grp) ); 
                  selectedPureCnctGrp=grp;
             }
             
        }else{  
        pureCnctGroups.add(new SelectOption('', '--None--'));
        for (string grp : grps) {
                  if ( grp != 'Custom App for PureConnect')
                   pureCnctGroups.add( new SelectOption(grp, grp) ); 
             }
        }
         
        }else{
            pureCnctGroups.clear();
            if(boaPlatform=='PureEngage Cloud'){
                pureCnctGroups.add(new SelectOption('Custom App for PureEngage','Custom App for PureEngage'));
                selectedPureCnctGrp='Custom App for PureEngage';
            }else
                if(boaPlatform=='PureCloud'){
                    pureCnctGroups.add(new SelectOption('Custom App for PureCloud','Custom App for PureCloud'));
                    selectedPureCnctGrp='Custom App for PureCloud';
                }
        }   
   }
    
    public void populateProducts() {  
        
        List<Support_Product__c> suppProducts = new List<Support_Product__c>();
        system.debug('selectedCategory##'+selectedCategory);
        system.debug('selectedProductGroup##'+selectedPureCnctGrp);
        suppProducts = UpdateProductDetailsHelper.getProducts(selectedCategory,selectedPureCnctGrp);
        system.debug('suppProducts##'+suppProducts);
        
        productsStandard.clear();
        for (Support_Product__c eachSP: suppProducts )  {

                   productsStandard.add( new SelectOption(eachSP.id, eachSP.Name) );
           }
        setProductsByCategory();
        
    }
    
    public void setProductsByCategory() {       
      resetProductOpts();
      
         products.addAll(productsStandard); 
      return;
   }
    
    public PageReference Cancel() {
        return new PageReference('/' + cs.Id);
    }
    public PageReference saveCaseUpdates() {   
          if ( !verifyRequiredInput() )
             return null;
        
        try {          
          cs.Support_Product__c = selectedProduct;
          if(!String.isBlank(selectedComponent)){
            cs.Component__c = selectedComponent;
          }
          cs.Problem_Category__c = selectedPureCnctProblm;
          
          
         
          update cs; 
            system.debug('Update Done#####');
       }
       catch(Exception ex) {  
           system.debug('Error Message###'+ex.getMessage());
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating the Case. Additional details: ' + ex.getMessage() );
           ApexPages.addMessage(msg); 
           return null;
       }

       return new PageReference('/' + cs.Id);
       
    }
    
    private Boolean verifyRequiredInput() {         
       Boolean reqErr = false; 
                      
       if ( String.isBlank(selectedCategory) || String.isBlank(selectedPureCnctGrp) || String.isBlank(selectedProduct) ) {
                reqErr = true;
       } 
       
      if ( reqErr )  {
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please populate all required fields.');
           ApexPages.addMessage(msg);                                   
           return false;                                    
       }
      
       return true;                
   }
    
    public void onchangeCategory() {
        system.debug('change#####Yes');
        resetCompOpts();
        resetPrblm();
        resetPureCnctGroup();
        resetProductOpts();
        setPureCnctGroups();
        onchangePCGroup(); 
        return;
    }
    
    public void onchangeProduct()  {
        if(!String.isBlank(selectedProduct)){
            resetPrblm();
            setProblmByProd();
            resetCompOpts();
            compsByProd = new Map<ID, Support_Product__c>(UpdateProductDetailsHelper.getComponentsByProduct2(selectedProduct));
            for ( Support_Product__c cmp : compsByProd.values() ){
              components.add(new SelectOption(cmp.Id, cmp.Name));
            } 
        }
       
        
       return;
    }
    
    public void setProblmByProd() { 
       resetPrblm();
       system.debug(selectedCategory+'######'+selectedPureCnctGrp);
        system.debug('selectedProduct#####'+selectedProduct);
       Map<Id, Map<Id, String>> prdsWtPrblms = UpdateProductDetailsHelper.getProdWithProbCateg(selectedCategory,selectedPureCnctGrp);
       system.debug('prdsWtPrblms####'+prdsWtPrblms);
       
  
       if ( String.isNotBlank(selectedProduct) && prdsWtPrblms.get(selectedProduct) != null )  {
               Map<Id, String> grps = prdsWtPrblms.get(selectedProduct);
           for (Id grpId : grps.keySet() ){
                   system.debug('inside####'+grpId);
                     pureCnctProbCateg.add( new SelectOption(grpId, grps.get(grpId)) );  
           }
           }
        system.debug('pureCnctProbCateg####'+pureCnctProbCateg);
           pureCnctProbCateg.sort();
   }
   
    
    public void onchangePCGroup() {
        system.debug('change grp@@@');
          resetProductOpts();
          populateProducts();
          resetPrblm();
   }

     private void resetProductOpts() {
       selectedProduct = '';
       products.clear();
       products.add(new SelectOption('', '--None--'));          
    }  
     private void resetPrblm() {
       selectedPureCnctProblm = '';
       pureCnctProbCateg.clear();
       pureCnctProbCateg.add(new SelectOption('', '--None--'));                  
   }
    
    private void resetPureCnctGroup() {          
       selectedPureCnctGrp = '';
       pureCnctGroups.clear(); 
       pureCnctGroups.add(new SelectOption('', '--None--'));                  
   }
     private void resetCompOpts() {
       selectedComponent = '';
       components.clear();
       components.add(new SelectOption('', '--None--'));  
    }
    
    public PageReference backToObject(){
        system.debug('caseassetId ='+cs.Id);
        return new PageReference('/'+cs.Id);
    }
}