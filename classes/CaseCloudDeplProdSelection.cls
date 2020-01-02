/************************************************************************************
Purpose : Controller class for creating new Cloud cases
Written By : Mariya Steason
Test Classes : CaseCloudDeplProdSelection_Test
Business Areas affected: Customer Care portal, Customer Support internal app
*************************************************************************************/
public class CaseCloudDeplProdSelection {

    public Case cs {get; set;}
    public String caseTypeName {get; set;}
    public String caseType {get; set;}
    public String contactName {get;set;}
    public String contactId {get; set;}   
    public List<SelectOption> prodopts {get; set;}
    public List<SelectOption> deplopts {get; set;} 
    public List<SelectOption> pureCnctGroups {get; set;}
    public List<SelectOption> pureCnctProducts {get; set;}
    public List<SelectOption> pureCnctProbCateg {get; set;}
    public String selectedPureCnctGrp {get; set;}
    public String selectedPureCnctProblm {get; set;}
    public String selectedPureCnctProduct {get; set;}
    public String selectedCategory {get; set;}
    public Map<Id, String> accts {get; set;}
    public Boolean btnSave {get; set;}
    public Boolean btnNext {get; set;}
    public String cldId {get; set;}
    public String cldName {get; set;}
    public String cdPlatform {get; set;}
    public Boolean isPureConnect {get; set;}
    public String portalFilter {get; set;}
    public String portalRequest {get; set;}
    public Boolean selectProd {get; set;}
    public Boolean selectCldCateg {get; set;}
    public String patchRelease {get; set;}
    public List<SelectOption> cdLocations {get; set;}    
    public Boolean locRequired {get; set;}
     
    private Boolean isPortalUser;   
    private ID recTypeId;
    
    private final String CATEGORY_APPS = 'Custom PS Applications';
    private final String CATEGORY_PURECONNECT = 'PureConnect Products';
       
    public List<SelectOption> categories {
      get {
          List<SelectOption> catg = new List<SelectOption>();
          catg.add(new SelectOption(CATEGORY_PURECONNECT, CATEGORY_PURECONNECT));
          catg.add(new SelectOption( CATEGORY_APPS, CATEGORY_APPS)); 
 
          return catg;
      }
      set;
   }
    
   public CaseCloudDeplProdSelection(ApexPages.StandardController stdController)  {
       ID caseId;

       btnSave = false;
       btnNext = false;
       selectProd = true;
       selectCldCateg = true;
       locRequired = false;
    
       isPureConnect = false; 
       pureCnctGroups = new List<SelectOption>();
       pureCnctProbCateg = new List<SelectOption>();
       pureCnctProducts = new List<SelectOption>();
       cdLocations = new List<SelectOption>();
              
       cdPlatform = '';
       selectedPureCnctGrp = '';
       selectedPureCnctProblm = '';
       selectedPureCnctProduct = '';
       
          
       String rectpstr = ApexPages.currentPage().getParameters().get('RecordType'); 
       String caseidstr = ApexPages.currentPage().getParameters().get('id'); 
       String recTypeUpd = ApexPages.currentPage().getParameters().get('updRecTp');
       portalFilter = ApexPages.currentPage().getParameters().get('fltr'); /// cnct, eng
       portalRequest = ApexPages.currentPage().getParameters().get('rqst'); //mac, dtprv
         
       try {       
            if ( String.isNotBlank(rectpstr) &&  String.isBlank(caseidstr) ) {
                /// new case
                recTypeId = Id.ValueOf(rectpstr);   
                caseTypeName = CaseUtil.getAllTScaseTypesMap().get(recTypeId).Name;                    
                btnNext = true;              
                initNewCase();
            }   
            else if ( String.isNotBlank(rectpstr) && String.isNotBlank(caseidstr) && recTypeUpd == '1' ) {
                /// record type update
                recTypeId = Id.ValueOf(rectpstr);
                caseId = Id.ValueOf(caseidstr);          
                btnSave = true;
                initRecTypeUpd(caseId, recTypeId);
            }
            else if ( String.isBlank(rectpstr) &&  String.isNotBlank(caseidstr) ) {
                // update deployment/ product
                caseId = Id.ValueOf(caseidstr);            
                btnSave = true;
                initCaseUpd(caseId);
            }             
        }
        catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating a Case.' );
            ApexPages.addMessage(errorMessage);   
            return;
        }       
   }
   
  public void initNewCase() {   
       cs = new Case( RecordTypeId = recTypeId );
       isPortalUser = ContactUtil.isPortalUser();
              
       /// Portal only         
       if ( isPortalUser ) {
            deplopts = new List<SelectOption>();
            accts = new Map<Id, String>();
                                    
            contactId = ContactUtil.getUserContactId();
            
            /// for case generation remove inactive Cloud Deployments 
            List<Cloud_Deployment__c> deplAll = ContactUtil.getUserCloudDepl();
            List<Cloud_Deployment__c> deplfiltered = new List<Cloud_Deployment__c>();
            
            if ( portalRequest != null && (portalRequest.equals('dtprv') || portalRequest.equals('mac')) ) 
                  selectProd = false;  
            
            if ( portalRequest != null && 
                 (portalRequest.equals('mac') || (portalRequest.equals('dtprv') && portalFilter.equals('cnct'))) )
                    selectCldCateg = false;  
                                               
            ///this part is to fill in deployment in case only one available 
            if ( portalFilter != null )  {
                    for ( Cloud_Deployment__c dpl : deplAll ) {                                              
                          
                        if ( dpl.Cloud_Platform__c.startswith('PureCloud') && portalFilter.equals('pcld') ) {                   
                           deplfiltered.add(dpl);       
                        }                
                        else if ( dpl.Cloud_Platform__c.startswith('PureConnect') && portalFilter.equals('cnct') ) {                     
                           deplfiltered.add(dpl);
                        } 
                        else if ( dpl.Cloud_Platform__c.startswith('PureEngage') && portalFilter.equals('eng') ) {                       
                           deplfiltered.add(dpl);
                        }                                               
                        else if ( !dpl.Cloud_Platform__c.startswith('PureCloud') && !dpl.Cloud_Platform__c.startswith('PureConnect') &&
                           portalFilter.equals('eng') )                  
                           deplfiltered.add(dpl); /// default Engage  
                        else
                           continue;                                             
                    }
            }
            else
                deplfiltered.addAll(deplAll);

            if ( deplfiltered.size() == 1 && deplfiltered[0].Support_Status__c == 'Active' ) {
               //single deployment
               cs.Cloud_Deployment__c = deplfiltered[0].Id; 
               cdPlatform = deplfiltered[0].Cloud_Platform__c;
               accntName =  deplfiltered[0].Account__r.Name;
               
                   getProdOptions();
            }
            else { 
                deplopts.add( new SelectOption('', '--None--') );   
            }          
           
            for ( Cloud_Deployment__c cd : deplfiltered )   { 
                   if ( cd.Support_Status__c == 'Active' ) {               
                       deplopts.add( new SelectOption(cd.Id, cd.Name) );
                       accts.put(cd.Id, cd.Account__r.Name);
               }
            }                     
       }        
  }
  
  public PageReference initCaseUpd(ID csId) {
        
        cs = [SELECT id, ContactId, Contact.Name, Cloud_Deployment__c, Cloud_Service__c, Cloud_Deployment__r.Name, 
                        Cloud_Deployment__r.Cloud_Platform__c, Support_Product__r.Category__c,
                        RecordType.DeveloperName, RecordType.Name, Support_Product__c, Deployment_Location__c,
                        Problem_Category__c, Product_Group__c, Major_Version__c, Patch_Release__c
              FROM Case WHERE id =: csId];
                                       
         caseType = cs.RecordType.DeveloperName;
         caseTypeName = cs.RecordType.Name;
         contactName = cs.Contact.Name;
         contactId = cs.ContactId;
         cldId = cs.Cloud_Deployment__c;
         cldName = cs.Cloud_Deployment__r.Name;
         cdPlatform = cs.Cloud_Deployment__r.Cloud_Platform__c;
         
         selectedCategory = cs.Support_Product__r.Category__c;
         
         if ( cs.Cloud_Deployment__r.Cloud_Platform__c.startswith('PureConnect' ) ) {
               isPureConnect = true;
               patchRelease = String.valueOf(cs.Patch_Release__c);
                
               getProdOptions();
                
               selectedPureCnctGrp = cs.Product_Group__c;              
               onchangePureConnectGroup();
            
               selectedPureCnctProduct = cs.Support_Product__c;
               onchangePureConnectProduct();
               selectedPureCnctProblm = cs.Problem_Category__c;                             
         }
         else
             getProdOptions();
                  
         return null;
        
   }
   
  public void initRecTypeUpd(Id caseId, Id recTypeId)  {
          String subtype = ApexPages.currentPage().getParameters().get('subtp'); 
          String priority = ApexPages.currentPage().getParameters().get('prty'); 
              
          CaseService.caseInstanceRecTypeUpd caseinst = new CaseService.caseInstanceRecTypeUpd('toCloud', recTypeId);
          cs = caseinst.cs;
          cs.Id = caseId; 
          cs.Problem_Sub_Type__c = subtype;  
          if ( String.isNotBlank(priority) && priority == 'crit' )
             cs.Priority = '1-Critical' ;  
  }
  
  public String accntName {
        get {
                
            if ( String.isNotBlank(cs.Cloud_Deployment__c))
                        return accts.get(cs.Cloud_Deployment__c);
            else
                return null;
        }       
        set;
  }
  
  public void resetCldDepoyment() {
          /// called from Portal page
          Cloud_Deployment__c cld = getDepInfo();
          if ( cld != null )
                  cdPlatform = cld.Cloud_Platform__c;
                  
          getProdOptions();
  }
  
  public void getProdOptions() {
        prodopts = new List<SelectOption>();
        locRequired = false;
        if ( cs.Cloud_Deployment__c != null && String.isNotBlank(cs.Cloud_Deployment__c) )  {
                
                populateCDLocations(); 
                        
            List<Support_Product__c> prods = SupportAccessProductSelector.getCloudProductsByDepl(cs.Cloud_Deployment__c); 

            if ( prods.size() > 1 ) 
                prodopts.add( new SelectOption('', '--None--') ); 
                
            for ( Support_Product__c sp : prods )   
                prodopts.add( new SelectOption(sp.Id, sp.Name) );                                                
         
             if ( cdPlatform.startswith('PureConnect') )  {
                        isPureConnect = true;
                        setPureCnctGroups();
             } 
             else
                      isPureConnect = false;
        }            
   } 
  
  /// PureConnect Methods
  public void setPureCnctGroups() {  
         resetPureCnctGroup();
           
          if ( selectedCategory == CATEGORY_APPS) {
           	  pureCnctGroups.add( new SelectOption('Custom App for PureConnect', 'Custom App for PureConnect') ); 
           	  selectedPureCnctGrp = 'Custom App for PureConnect';
           	  setPureCnctProdsByGroup();
           }
           else {                                    
	           Map<String, Map<Id, String>> groupWtProds = SupportAccessProductSelector.getPureCnctGroupWithProducts(true);
	           
	           Set<String> grps = groupWtProds.keySet();
	           for (string grp : grps) {
	           	   if ( grp != 'Custom App for PureConnect')
	               		pureCnctGroups.add( new SelectOption(grp, grp) );   
	           }
	           pureCnctGroups.sort();        
	           resetProductOpts();    
           }              
   }
   
   public void setPureCnctProdsByGroup() {      
           resetProductOpts();  
           Map<String, Map<Id, String>> groupWtProds = SupportAccessProductSelector.getPureCnctGroupWithProducts(true);

       if ( String.isNotBlank(selectedPureCnctGrp) )  {
                          
                   Map<Id, String> prds = groupWtProds.get(selectedPureCnctGrp);
                   for ( Id prdid : prds.keySet() )
                       pureCnctProducts.add( new SelectOption( prdid, prds.get(prdid) ) );            
       }        
      resetPureCnctPrblm();             
   }
   
   public void setPureCnctProblmByProd() { 
       resetPureCnctPrblm();
       Map<Id, Map<Id, String>> prdsWtPrblms = SupportAccessProductSelector.getPureCnctProdWithProbCateg(true);
  
       if ( String.isNotBlank(selectedPureCnctProduct)  && prdsWtPrblms.get(selectedPureCnctProduct) != null )  {
                   Map<Id, String> grps = prdsWtPrblms.get(selectedPureCnctProduct);
                   for (Id grpId : grps.keySet() )
                       pureCnctProbCateg.add( new SelectOption(grpId, grps.get(grpId)) );  
       } 
       
       pureCnctProbCateg.sort();
   }
         
  private void resetPureCnctGroup() {           
       selectedPureCnctGrp = '';
       pureCnctGroups.clear(); 
       pureCnctGroups.add(new SelectOption('', '--None--'));                  
   }
   private void resetProductOpts() {
       selectedPureCnctProduct = '';
       pureCnctProducts.clear();
       pureCnctProducts.add(new SelectOption('', '--None--'));          
   }    
   private void resetPureCnctPrblm() {
       selectedPureCnctProblm = '';
       pureCnctProbCateg.clear();
       pureCnctProbCateg.add(new SelectOption('', '--None--'));                  
   }
   
   public void onchangeCategory() {
   	  resetPureCnctGroup();
   	  resetProductOpts();
   	  setPureCnctGroups();
    //  setPureCnctProdsByGroup();
      resetPureCnctPrblm();
 	  // setPureCnctGroups();       
      // resetReleaseOpts();
     //  resetCompOpts();
    //   resetVersOpts();
   }
     
   public void onchangePureConnectProduct() {
       resetPureCnctPrblm();
       setPureCnctProblmByProd();
   }
   
   public void onchangePureConnectGroup() {
       resetProductOpts();
       setPureCnctProdsByGroup();
       resetPureCnctPrblm();
   }
  
  public void populateCDLocations() {
        cdLocations.clear();
        locRequired = false;            
                if ( cs.Cloud_Deployment__c != null && String.isNotBlank(cs.Cloud_Deployment__c) ) {
                        List<Cloud_Deployment_Location__c> locs = [SELECT Name FROM Cloud_Deployment_Location__c 
                                                                   WHERE Cloud_Deployment__c = :cs.Cloud_Deployment__c
                                                                    ORDER By Name];                             
                    if ( locs.size() > 0 ) { 
                        locRequired = true; 
                        
                        if ( locs.size() > 1 )           
                                         cdLocations.add(new SelectOption('', '--None--')); 
                                         
                                for (Cloud_Deployment_Location__c lc : locs)
                                   cdLocations.add(new SelectOption(lc.Name, lc.Name));
                        }
                }
  }
  
  public PageReference nextPage() {   
        if ( !verifyRequiredInput() )
           return null;
     
         String caseType = CaseUtil.getAllTScaseTypesMap().get(recTypeId).DeveloperName;       
          PageReference pr; 
             
          if ( isPortalUser )  {
                
                  if ( caseType == 'Genesys_Cloud_Feature_Request' )  
                     pr = new PageReference('/customercare/CaseFRCreatePortal');  
                  else if ( portalRequest != null && portalRequest.equals('mac') ) 
                     pr = new PageReference('/customercare/CustCareMACTemplate'); 
                  else if ( portalRequest != null && portalRequest.equals('dtprv') ) {
                     pr = new PageReference('/customercare/CasePortalDataPrivacy');
                     pr.getParameters().put('fltr', portalFilter); 
                  }
                  else
                     pr = new PageReference('/customercare/CaseCloudPortal'); 
 
                     /// deployment name
                          if ( !deplopts.isEmpty() && String.isNotBlank(cs.Cloud_Deployment__c) ) {                                                  
                                  for ( SelectOption so : deplopts ) {                  
                                          if ( so.getValue() != '' && so.getValue() == cs.Cloud_Deployment__c )
                                                pr.getParameters().put('dplnm', so.getLabel()); 
                                  } 
                          } 
      
                          /// cloud service name
                          if ( !prodopts.isEmpty() && String.isNotBlank(cs.Cloud_Service__c) ) {                        
                                  for ( SelectOption so : prodopts ) {                                  
                                     if ( so.getValue() != '' && so.getValue() == cs.Cloud_Service__c )                          
                                             pr.getParameters().put('srvnm', so.getLabel()); 
                                  }
                          }
                                                 
             }               
             /// internal app   
             else  {
                 if ( caseType == 'Genesys_Cloud_Feature_Request' )  
                     pr = new PageReference('/apex/CaseFRCreateInternal');   
                 else
                     pr = new PageReference('/apex/CaseCloudRequestCreate');            
             }
                                   
           try {    
                  Cloud_Deployment__c depl = getDepInfo();

                  pr.getParameters().put('RecordType', recTypeId); 
                  pr.getParameters().put('contId', contactId); 
                  pr.getParameters().put('dplId', cs.Cloud_Deployment__c);                  
                  pr.getParameters().put('stId', depl.Sold_To_Account__c); 
                  pr.getParameters().put('euId', depl.Account__c); 
                  pr.getParameters().put('srvId', cs.Cloud_Service__c);
                  
                  String pltfm = '';
                  if ( depl.Cloud_Platform__c == 'Business/Enterprise Edition' )
                     pltfm = 'BE';
                  else if ( isPureConnect ) {
                     pltfm = 'cnct';
                     pr.getParameters().put('mjvr', cs.Major_Version__c);
                         pr.getParameters().put('ptch', patchRelease);
                  }
                  else
                     pltfm = depl.Cloud_Platform__c;
                     
                  pr.getParameters().put('plfrm', pltfm);                   
                  pr.getParameters().put('prdId', selectedPureCnctProduct); 
                  pr.getParameters().put('prb', selectedPureCnctProblm); 
                  pr.getParameters().put('lctn', cs.Deployment_Location__c);                           
           }
           catch (Exception e) {
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating a Case.' );    
                    ApexPages.addMessage(errorMessage);   
                    return null;
             }    
                        
          pr.setRedirect(true);
          return pr;    
   }
   
    private Boolean verifyRequiredInput() {
            Boolean reqErr = false; 
            Boolean patchErr = false;                      
           
           if ( String.isBlank(contactId) || cs.Cloud_Deployment__c == null || String.isBlank(cs.Cloud_Deployment__c) )
               reqErr = true; 
            else if ( selectProd && (String.isBlank(cs.Cloud_Service__c) || (isPureConnect && String.isBlank(selectedPureCnctProduct))) )   
                reqErr = true;
            else if ( selectProd && (isPureConnect && String.isBlank(cs.Major_Version__c)) )
                reqErr = true;
                
            else if ( locRequired && (cs.Deployment_Location__c == null || String.isBlank(cs.Deployment_Location__c)) )
                reqErr = true;
                
            else if ( isPureConnect && patchRelease != null && String.isNotBlank(patchRelease) )  {                
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
   
   public PageReference saveCaseUpdates() {
           if ( !verifyRequiredInput() )
                   return null;
                   
           try {       
                  Cloud_Deployment__c depl = getDepInfo();
                  
                  if ( !locRequired )
                     cs.Deployment_Location__c = null;
                  
                  cs.Back_Office_Account__c = null;                  
                  cs.ContactId = contactId;              
                  cs.End_User_Account__c = depl.Account__c;
                  cs.Sold_To_Account__c = depl.Sold_To_Account__c;  
                   
                  if ( isPureConnect ) {
                          cs.Support_Product__c = selectedPureCnctProduct;
                          cs.Problem_Category__c = selectedPureCnctProblm;   
                          
                          if ( patchRelease != null && String.isNotBlank(patchRelease) )                                    
                                                 cs.Patch_Release__c = Integer.valueOf(patchRelease);                                                                     
                  }
                  else {
                          cs.Support_Product__c = null;
                          cs.Problem_Category__c = null;
                          cs.Patch_Release__c = null;
                                  cs.Major_Version__c = null;
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
   
   private Cloud_Deployment__c getDepInfo()  {  
         if ( cs.Cloud_Deployment__c != null ) {
            
                 List<Cloud_Deployment__c>  depl = [SELECT Account__c, Sold_To_Account__c, Cloud_Platform__c 
                                                       FROM Cloud_Deployment__c WHERE Id =:cs.Cloud_Deployment__c];                                                    
                 return depl[0];
         }
         else
            return null;
   }
   
   public String pageTitle {
     get {
            if ( portalRequest != null && portalRequest.equals('dtprv') )
               return 'Data Privacy Request';
            else
                return CaseUtil.casePageTitleByType(recTypeId);
          } 
      set;
   }
   
}