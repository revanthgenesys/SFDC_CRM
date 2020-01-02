public class CasePremContactProdSelection {
       
   public Case cs {get; set;}
    public String caseTypeName {get; set;}
    public String caseType {get; set;}
    public String contactName {get;set;}
    public String contactId {get; set;}
    public String endUserName {get;set;}
    public String soldToName {get; set;}
    public String endUserAccId {get; set;}
    public String soldToAccId {get; set;}
    public String boaId {get; set;}
    public String boaPlatform {get; set;}
    public Boolean isProductNotFound {get; set;}
    public List<SelectOption> products {get; set;}
    public List<SelectOption> components {get; set;}
    public List<SelectOption> majorReleases {get; set;}
    public List<SelectOption> productVersions {get; set;}
    public List<SelectOption> pureCnctGroups {get; set;}
    public List<SelectOption> pureCnctProbCateg {get; set;}
    public String selectedCategory {get; set;}
    public String selectedProduct {get;set;}
    public String selectedComponent {get;set;}
    public String selectedVersion {get;set;}
    public String selectedMjrRel {get;set;}
    public String selectedPureCnctGrp {get; set;}
    public String selectedPureCnctProblm {get; set;}
    public Boolean disableProdSelections {get; set;}
    public Boolean isPortalUser {get; set;}
    public Boolean isPureEngage {get; set;}
    public Boolean isPureConnect {get; set;}
    public Boolean showPortalProdsNotFoundMsg {get; set;}
    public Boolean btnSave {get; set;}
    public Boolean btnNext {get; set;}
    public String portalFilter {get; set;}
    public String portalRequest {get; set;}
    public Boolean selectProd {get; set;}
    public String patchRelease {get; set;}
    
    private List<SelectOption> productsStandard;
    private List<SelectOption> productsTools;
    private List<SelectOption> productsApps;
    
    private ID recTypeId;
   
    private List<Product_Version__c> allversions;
    private Map<ID, Support_Product__c> compsByProd;
    
    private final String CATEGORY_TOOLS = 'Genesys Care Tools';
    private final String CATEGORY_APPS = 'Custom PS Applications';
    private final String CATEGORY_STANDARD = 'PureEngage Products';
    private final String CATEGORY_PURECONNECT = 'PureConnect Products';
       
   public List<SelectOption> categories {
      get {
          List<SelectOption> catg = new List<SelectOption>();

          if (boaPlatform.startswith('PureConnect') || (portalFilter != null && portalFilter.equals('cnct')) )  {
                 catg.add(new SelectOption(CATEGORY_PURECONNECT, CATEGORY_PURECONNECT));
                 catg.add(new SelectOption( CATEGORY_APPS, CATEGORY_APPS)); 
          }              
          else {
                  catg.add(new SelectOption( CATEGORY_STANDARD, CATEGORY_STANDARD));
                  catg.add(new SelectOption( CATEGORY_TOOLS, CATEGORY_TOOLS));
                  catg.add(new SelectOption( CATEGORY_APPS, CATEGORY_APPS)); 
          }  
          return catg;
      }
      set;
   }
    
   public CasePremContactProdSelection(ApexPages.StandardController stdController) {
        ID caseId;
        String rectpstr = ApexPages.currentPage().getParameters().get('RecordType'); 
        String caseidstr = ApexPages.currentPage().getParameters().get('id'); 
        String recTypeUpd = ApexPages.currentPage().getParameters().get('updRecTp'); 
        String subtype = ApexPages.currentPage().getParameters().get('subtp'); 
        portalFilter = ApexPages.currentPage().getParameters().get('fltr'); 
        portalRequest = ApexPages.currentPage().getParameters().get('rqst'); //mac, dtprv
       
        btnSave = false;
        btnNext = false;
        selectProd = true;
 
        isPortalUser = ContactUtil.isPortalUser();
        contactId = null;
        isProductNotFound = false;
        showPortalProdsNotFoundMsg = false;
   
        isPureEngage = false;
        isPureConnect = false;
  
        products = new List<SelectOption>(); 
        productsStandard = new List<SelectOption>();
        productsTools = new List<SelectOption>();
        productsApps = new List<SelectOption>();
        
        compsByProd = new Map<ID, Support_Product__c>();
                  
        majorReleases = new List<SelectOption>(); 
        components = new List<SelectOption>();
        productVersions = new List<SelectOption>();
        
        pureCnctGroups = new List<SelectOption>();
        pureCnctProbCateg = new List<SelectOption>();
         
        boaPlatform = '';    
        selectedProduct ='';
        selectedComponent ='';
        selectedVersion ='';
        selectedMjrRel ='';
        
        selectedPureCnctGrp = '';
        selectedPureCnctProblm = '';
        
        setDisableSelectionsFlg();
                
        try {       
            if ( String.isNotBlank(rectpstr) &&  String.isBlank(caseidstr) ) {
                 ///Record Type && blank case Id -> new case
                recTypeId = Id.ValueOf(rectpstr);
                btnNext = true;  
                newCase();
            } 
            else if ( String.isNotBlank(rectpstr) && String.isNotBlank(caseidstr) && recTypeUpd == '1' ) {
                /// record type update
                recTypeId = Id.ValueOf(rectpstr);
                caseId = Id.ValueOf(caseidstr); 
                btnSave = true;
                initRecTypeUpd(caseId, recTypeId, subtype);
            }
            else if ( String.isBlank(rectpstr) &&  String.isNotBlank(caseidstr) ) {
                /// Record Type & contact/ account/ product update
                caseId = Id.ValueOf(caseidstr); 
                btnSave = true;
                initCaseUpd(caseId);
            }   
        }
        catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating a Case.');
            ApexPages.addMessage(errorMessage);   
            return;
        }     
    }
        
    private void newCase() {    
        cs = new Case( RecordTypeId = recTypeId ); /// this only used to populate Major Version dropdown
        
        caseTypeName = CaseUtil.getAllTScaseTypesMap().get(recTypeId).Name;
        caseType = CaseUtil.getAllTScaseTypesMap().get(recTypeId).DeveloperName;    
        
        if ( isPortalUser )  {
            contactId = ContactUtil.getUserContactId(); 
            contactName = contactId; //this is hidden on portal, need for lookup
            
            List<Support_Access__c> saAll = ContactUtil.getRWSupprtAccLstByContact(contactId);
            List<Support_Access__c> saFiltered = new List<Support_Access__c>();
           
            Boolean managed = false;
            if ( portalRequest != null && (portalRequest.equals('dtprv') || portalRequest.equals('mac')) ) {
                managed = true;
                selectProd = false;
            }  
            ///this part is to fill in BOA in case only one available           
            if ( portalFilter != null )  {                                    
                    for ( Support_Access__c sa : saAll ) {                      
                        if ( managed && sa.BOA_Support_Package__c != null && sa.BOA_Support_Package__c.startswith('Managed') &&
                             sa.BOA_Platform__c.startswith('PureEngage') && portalFilter.equals('eng') ) {
                                        saFiltered.add(sa);                         
                        }  
                        else if ( managed && sa.BOA_Support_Package__c != null && sa.BOA_Support_Package__c.startswith('Managed') &&
                             sa.BOA_Platform__c.startswith('PureConnect') && portalFilter.equals('cnct') ) {
                                        saFiltered.add(sa);                         
                        }                                           
                        else if ( !managed && sa.BOA_Platform__c.startswith('PureEngage') && portalFilter.equals('eng') )
                                 saFiltered.add(sa);                                                   
                        else if ( !managed && sa.BOA_Platform__c.startswith('PureConnect') && portalFilter.equals('cnct') )
                                saFiltered.add(sa);                                           
                        else
                           continue;                                           
                    }
            }
            else
                saFiltered.addAll(saAll);
                                
            /// single ST/EU combination
            if ( saFiltered.size() == 1 ) {
                soldToAccId = saFiltered[0].Sold_To_Account__c;
                soldToName = saFiltered[0].Sold_To_Account__r.Name;
                endUserAccId = saFiltered[0].End_User_Account__c;
                endUserName = saFiltered[0].End_User_Account__r.Name; 
                boaId = saFiltered[0].Back_Office_Account__c;
                boaPlatform = saFiltered[0].BOA_Platform__c;
                
                populateAllSelectOptions();                
            }
        }
        return;                                            
    }
    
  public void initRecTypeUpd(Id caseId, Id recTypeId, String subtype)  {
      CaseService.caseInstanceRecTypeUpd caseinst = new CaseService.caseInstanceRecTypeUpd('toPremise', recTypeId);
      cs = caseinst.cs;
      cs.Id = caseId;
      cs.Problem_Sub_Type__c = subtype;
  }

  private void initCaseUpd(Id caseId)  {
    
         cs = [SELECT id, ContactId, Contact.Name, End_User_Account__c, End_User_Account__r.Name, Support_Product__r.Category__c,
                    Sold_To_Account__r.Name, Sold_To_Account__c, RecordType.DeveloperName, RecordType.Name, RecordTypeId,
                    Support_Product__c, Component__c, Major_Release1__c, Product_Version__c, Back_Office_Account__c,
                    Back_Office_Account__r.Platform__c, Problem_Category__c, Product_Group__c, Major_Version__c, Patch_Release__c
              FROM Case WHERE id =: caseId];
         
         if ( cs.Back_Office_Account__r.Platform__c.startswith('PureConnect') ) {
            isPureEngage = false;
            isPureConnect = true;
         }
         else {
            isPureEngage = true;
            isPureConnect = false;
         }
                                       
         caseType = cs.RecordType.DeveloperName;
         caseTypeName = cs.RecordType.Name;
         contactName = cs.Contact.Name;
         contactId = cs.ContactId;
         
         boaId = cs.Back_Office_Account__c;
         boaPlatform = cs.Back_Office_Account__r.Platform__c;
         
         endUserAccId = cs.End_User_Account__c;
         endUserName = cs.End_User_Account__r.Name;
         soldToAccId = cs.Sold_To_Account__c;
         soldToName = cs.Sold_To_Account__r.Name;
         patchRelease = String.valueOf(cs.Patch_Release__c);
          
         selectedCategory = cs.Support_Product__r.Category__c;

         if ( isPureEngage ) {        	
            populatePureEngageProducts(); 	       
            selectedProduct = cs.Support_Product__c;
                 
            onchangeProduct();
            selectedMjrRel = cs.Major_Release1__c;
                 
            onchangeRelease();
            selectedComponent = cs.Component__c;
                 
            onchangeComponent();
            selectedVersion = cs.Product_Version__c;
         }
         else if ( isPureConnect ) {
         	setPureCnctGroups();
            
            selectedPureCnctGrp = cs.Product_Group__c;              
            onchangePCGroup();
            
            selectedProduct = cs.Support_Product__c;
            onchangeProduct();
            selectedPureCnctProblm = cs.Problem_Category__c;                
         } 
   }
   
   public void onProdNotFound() {  
      if ( isPortalUser )  {    
          showPortalProdsNotFoundMsg = true;    
      }
      else {
         isProductNotFound = true;
         populateAllSelectOptions();
         isProductNotFound = false; 
               
         ApexPages.Message prdmsg = new ApexPages.Message(ApexPages.Severity.INFO, 'All available Products are now selectable.');          
         ApexPages.addMessage(prdmsg); 
      }
       return;                              
   }
   
   public void populateAllSelectOptions() {
        resetProductOpts();
        resetReleaseOpts();
        resetCompOpts();
        resetVersOpts();
        resetPureCnctGroup();
        resetPureCnctPrblm();
         
        if ( boaPlatform.startswith('PureEngage') ) {     	
           populatePureEngageProducts();
           isPureEngage = true;
           isPureConnect = false;
        }
        else if ( boaPlatform.startswith('PureConnect') ) {        	
           setPureCnctGroups();
           isPureConnect = true;
           isPureEngage = false;
        }  
        
        return;
    }
    
   public void populatePureEngageProducts() {  
                
           if ( String.isNotBlank(endUserAccId) && String.isNotBlank(soldToAccId) )  {
           List<Support_Product__c> suppProducts = new List<Support_Product__c>();
  
           if ( isProductNotFound ) {
                  suppProducts = SupportAccessProductSelector.getProductsAccessAll();
           } 
           else {
                 suppProducts = SupportAccessProductSelector.getProductsByStEu(soldToAccId, endUserAccId);
           }         
 
           productsTools.clear();
           productsApps.clear();
           productsStandard.clear();

           for (Support_Product__c eachSP: suppProducts )  {

                   if ( eachSP.Category__c == CATEGORY_TOOLS)  
                         productsTools.add( new SelectOption(eachSP.id, eachSP.Name) );
                    else if ( eachSP.Category__c == CATEGORY_APPS )  {                 	
                        productsApps.add( new SelectOption(eachSP.id, eachSP.Name) );
                    }
                   else
                        productsStandard.add( new SelectOption(eachSP.id, eachSP.Name) );
           }
                    
           setProductsByCategory();         
           setDisableSelectionsFlg();            
                   
        } 
        return;                 
   }
   
    public void setProductsByCategory() {     	
      resetProductOpts();
      if ( selectedCategory == CATEGORY_TOOLS)
         products.addAll(productsTools);
      else if ( selectedCategory == CATEGORY_APPS)
          products.addAll(productsApps);
      else
         products.addAll(productsStandard); 
      return;
   }
   
   /// PureConnect set Methods
   public void setPureCnctGroups() {  
           resetPureCnctGroup();  

           if ( selectedCategory == CATEGORY_APPS) {
           	  pureCnctGroups.add( new SelectOption('Custom App for PureConnect', 'Custom App for PureConnect') ); 
           	  selectedPureCnctGrp = 'Custom App for PureConnect';
           	  setPureCnctProdsByGroup();
           }
           else {                    
	           Map<String, Map<Id, String>> groupWtProds = SupportAccessProductSelector.getPureCnctGroupWithProducts(false);
	           
	           Set<String> grps = groupWtProds.keySet();
	           for (string grp : grps) {
	           	   if ( grp != 'Custom App for PureConnect')
	              	 pureCnctGroups.add( new SelectOption(grp, grp) ); 
	           }
	       
	           pureCnctGroups.sort(); 
	           resetProductOpts();     
           }
 
           setDisableSelectionsFlg();                   
   }
   
   public void setPureCnctProdsByGroup() {      
       resetProductOpts();  
 
       Map<String, Map<Id, String>> groupWtProds = SupportAccessProductSelector.getPureCnctGroupWithProducts(false);

        if ( String.isNotBlank(selectedPureCnctGrp) )  {                          
             Map<Id, String> prds = groupWtProds.get(selectedPureCnctGrp);         
             for ( Id prdid : prds.keySet() ) 
               products.add( new SelectOption( prdid, prds.get(prdid) ) );                          
       }  
        
      resetPureCnctPrblm();             
   }
   
   public void setPureCnctProblmByProd() { 
       resetPureCnctPrblm();
       Map<Id, Map<Id, String>> prdsWtPrblms = SupportAccessProductSelector.getPureCnctProdWithProbCateg(false);
  
       if ( String.isNotBlank(selectedProduct) && prdsWtPrblms.get(selectedProduct) != null )  {
               Map<Id, String> grps = prdsWtPrblms.get(selectedProduct);
               for (Id grpId : grps.keySet() )
                     pureCnctProbCateg.add( new SelectOption(grpId, grps.get(grpId)) );  
           }
           pureCnctProbCateg.sort();
   }
     
   /// on change methods 
   public void onchangeCategory() {
   	   if ( isPureEngage )
           setProductsByCategory(); 
       else  
       	   setPureCnctGroups();
       
       resetReleaseOpts();
       resetCompOpts();
       resetVersOpts();
      return;
   }
   
   public void onchangePureEngageProduct() {
       resetReleaseOpts();
       resetCompOpts();
       resetVersOpts();
       
        if ( String.isNotBlank(selectedProduct) )  {
           majorReleases.add(new SelectOption('Unknown', 'Unknown'));
        
           compsByProd = new Map<ID, Support_Product__c>(SupportAccessProductSelector.getComponentsByProduct(selectedProduct));

           Set<Id> prdIds = compsByProd.keySet();                           
           allversions = [SELECT Id, Version__c, Parent_Product__c 
                           FROM Product_Version__c 
                           WHERE Parent_Product__c IN :prdIds AND Version__c != null 
                             AND Customer_Available__c = true 
                             ORDER BY Version__c DESC];
            
           Set<String> uniquevers = new Set<String>();
           for (Product_Version__c pv : allversions)
                 uniquevers.add(pv.Version__c.left(3));
                             
           for (String vrs : uniquevers)  {
              if ( vrs == 'Uns' )
                  continue;
              majorReleases.add(new SelectOption(vrs, vrs));    
           }                  
        }
        
        return;         
   }
        
   public void onchangeProduct()  {
       if ( isPureEngage )
          onchangePureEngageProduct();
       else if ( isPureConnect ) 
          onchangePureConnectProduct();       
       return;
   }
   
   public void onchangePureConnectProduct() {
           resetPureCnctPrblm();
           setPureCnctProblmByProd();
   }
   
   public void onchangePCGroup() {
          resetProductOpts();
          setPureCnctProdsByGroup();
          resetPureCnctPrblm();
   }
   
   public void onchangeRelease()  {
       resetCompOpts();
       resetVersOpts();
               
       if ( selectedMjrRel == 'Unknown' )  {
           for ( Support_Product__c cmp : compsByProd.values() )
              components.add(new SelectOption(cmp.Id, cmp.Name));
       }
       else if ( String.isNotBlank(selectedMjrRel) && selectedMjrRel.length() == 3 )  {
            Set<ID> compsByRel = new Set<ID>();
            
            for ( Product_Version__c ver : allversions ) {
                if ( ver.Version__c.startswith(selectedMjrRel) )
                   compsByRel.add(ver.Parent_Product__c);
            }
            
            for ( ID compId : compsByRel)  {
                if ( compsByProd.containsKey(compId) )
                   components.add(new SelectOption(compId, compsByProd.get(compId).Name));
            }       
       }
       
       return;
   }
   
   public void onchangeComponent()  {
       resetVersOpts();
 
       if ( String.isNotBlank(selectedComponent) && String.isNotBlank(selectedMjrRel) )  {

           for ( Product_Version__c ver : allversions ) {
               if ( (ver.Version__c.startswith(selectedMjrRel) || ver.Version__c == 'Unspecified') && ver.Parent_Product__c == selectedComponent )
                    productVersions.add(new SelectOption(ver.Id, ver.Version__c == 'Unspecified' ? 'Unknown' : ver.Version__c));
          }
       } 
           
       return;
   }
      
   public void resetOptionsAll() {
       resetPureCnctGroup();
       resetProductOpts();
       resetReleaseOpts();
       resetCompOpts();
       resetVersOpts();
       resetPureCnctPrblm();
       disableProdSelections = true;
   }
   
   public void setDisableSelectionsFlg() {        
      if ( String.isNotBlank(contactId) && String.isNotBlank(endUserAccId) && String.isNotBlank(soldToAccId) )  
            disableProdSelections = false;
      else
            disableProdSelections = true;
   } 
   
   private void resetProductOpts() {
       selectedProduct = '';
       products.clear();
       products.add(new SelectOption('', '--None--'));          
   }    
   private void resetReleaseOpts() {
        selectedMjrRel = '';
        majorReleases.clear();
        majorReleases.add(new SelectOption('', '--None--'));
   }   
   private void resetCompOpts() {
       selectedComponent = '';
       components.clear();
       components.add(new SelectOption('', '--None--'));  
   }
   private void resetVersOpts() {
       selectedVersion ='';
       productVersions.clear();
       productVersions.add(new SelectOption('', '--None--'));                  
   }
   
   ///PureConnect
   private void resetPureCnctGroup() {          
       selectedPureCnctGrp = '';
       pureCnctGroups.clear(); 
       pureCnctGroups.add(new SelectOption('', '--None--'));                  
   }
   private void resetPureCnctPrblm() {
           selectedPureCnctProblm = '';
       pureCnctProbCateg.clear();
       pureCnctProbCateg.add(new SelectOption('', '--None--'));                  
   }
   
    public PageReference nextPage() {
       if ( !verifyRequiredInput() )
            return null;
            
       PageReference pr;       
       if ( caseType == 'Genesys_Product_Case' )  {
          if ( isPortalUser )
             pr = new PageReference('/customercare/CasePremiseCreatePortal');      
          else
             pr = new PageReference('/apex/CasePremiseCreateInternal');            
       }       
       else if ( caseType == 'Genesys_Feature_Request_Case' )  {
          if ( isPortalUser )
             pr = new PageReference('/customercare/CaseFRCreatePortal');      
          else
            pr = new PageReference('/apex/CaseFRCreateInternal'); 
       }
       else if ( caseType == 'Premises_Service_Request' )  {
          if ( isPortalUser && portalRequest != null ) {
                   if ( portalRequest.equals('mac') ) 
                     pr = new PageReference('/customercare/CustCareMACTemplate'); 
               else if ( portalRequest.equals('dtprv') ) {
                     pr = new PageReference('/customercare/CasePortalDataPrivacy');
                     
        pr.getParameters().put('euId', endUserAccId); 
        pr.getParameters().put('stId', soldToAccId);
        pr.getParameters().put('boaId', boaId); 
                     
                     
                     pr.getParameters().put('fltr', portalFilter); 
               } 
          }      
          else {
             pr = new PageReference('/apex/CasePremiseCreateInternal');
          } 
       }
             
        pr.getParameters().put('RecordType', recTypeId); 
        pr.getParameters().put('contId', contactId); 
        pr.getParameters().put('euId', endUserAccId); 
        pr.getParameters().put('stId', soldToAccId);
        pr.getParameters().put('boaId', boaId); 
        pr.getParameters().put('prdId', selectedProduct); 
        
        if ( isPureEngage )  {
                pr.getParameters().put('pltf', 'eng');
                pr.getParameters().put('rel', selectedMjrRel);
                pr.getParameters().put('compId', selectedComponent); 
                pr.getParameters().put('ver', selectedVersion);     
        }
        else if ( isPureConnect ) {
                pr.getParameters().put('pltf', 'cnct');
                pr.getParameters().put('prb', selectedPureCnctProblm); 
                pr.getParameters().put('mjvr', cs.Major_Version__c);
                pr.getParameters().put('ptch', patchRelease);
        }
          
       pr.setRedirect(true);
       return pr;
   }
   
   public PageReference saveCaseUpdates() {   
          if ( !verifyRequiredInput() )
             return null;
             
     try {          
          cs.ContactId = contactId;         
          cs.End_User_Account__c = endUserAccId;
          cs.Sold_To_Account__c = soldToAccId; 
          cs.Back_Office_Account__c = boaId;                         
          cs.Support_Product__c = selectedProduct;
          
          if ( isPureEngage ) {
                  cs.Major_Release1__c = selectedMjrRel;    
                  cs.Component__c = selectedComponent;
                  cs.Product_Version__c = selectedVersion;
                  cs.Problem_Category__c = null;
                  cs.Major_Version__c = null;
                  cs.Patch_Release__c = null;
          }
          else if ( isPureConnect ) {
                  cs.Problem_Category__c = selectedPureCnctProblm;
                  
                  if ( patchRelease != null && String.isNotBlank(patchRelease) )                                    
                          cs.Patch_Release__c = Integer.valueOf(patchRelease);
                  
                  cs.Major_Release1__c = null;    
                  cs.Component__c = null;
                  cs.Product_Version__c = null;
          }
         
          update cs;         
       }
       catch(Exception ex) {  
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating the Case. Additional details: ' + ex.getMessage() );
           ApexPages.addMessage(msg); 
           return null;
       }

       return new PageReference('/' + cs.Id);
   }
   
   private Boolean verifyRequiredInput() {         
       Boolean reqErr = false; 
       Boolean patchErr = false;
                      
       if ( String.isBlank(contactId) || String.isBlank(endUserAccId) || String.isBlank(soldToAccId) ) {
                reqErr = true;
       } 
       else if ( String.isBlank(selectedProduct) && selectProd ) {
                reqErr = true;
       } 
       else if ( isPureEngage && selectProd && (
             String.isBlank(selectedMjrRel) ||
            (String.isNotBlank(selectedComponent) && String.isBlank(selectedVersion))) ) {
                reqErr = true;
       } 
       else if ( selectProd && (isPureConnect && String.isBlank(cs.Major_Version__c)) )
                reqErr = true;
       
       //patchRelease
       if ( isPureConnect && selectProd && patchRelease != null && String.isNotBlank(patchRelease) )  {            
            try {
                Integer rel = Integer.valueOf(patchRelease);
                patchErr = rel > 99 ? true : false;                                
            }
            catch (Exception ex) {
                 patchErr = true;
            }         
       }
       
      if ( reqErr )  {
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please populate all required fields.');
           ApexPages.addMessage(msg);                                   
           return false;                                    
       }
       else if ( patchErr ) {
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Patch Release number.');
          ApexPages.addMessage(msg);                                   
          return false;   
       }
       
       return true;                
   }
   
   public String pageTitle {
      get {
        return CaseUtil.casePageTitleByType(recTypeId);
      } 
      set;
   } 
    
}