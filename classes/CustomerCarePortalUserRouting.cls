/************************************************************************************
Purpose : Controller class to redirect portal user based on the user permissions 
Written By : Mariya Steason
Test Classes : CustomerCarePortalUserRouting_Test
Business Areas affected: Customer Care portal
*************************************************************************************/
public class CustomerCarePortalUserRouting {
    
    public String pureEngPrem {get; set;}
    public String pureCnctPrem {get; set;}
    public String pureEngCld {get; set;}
    public String pureCnctCld {get; set;}
    public String pureCld {get; set;}
    public Boolean isPartner {get; set;}
    public String premCnctMngSrv {get; set;}
    public String premEngMngSrv {get; set;}
    public String searchTxt {get; set;}
    public String usageFileUpload {get; set;}
    private String partner {get; set;}       
    private static Map<String, Id> casetypesMap;
 
    public CustomerCarePortalUserRouting() {
        isPartner = false;
        searchTxt = '';
        
        Map<String, String> perms = ContactUtil.getPortalUserPermissionMap();
        
        if ( !perms.isEmpty() )  {
            pureEngPrem = perms.get('PureEngagePremise');
            pureCnctPrem = perms.get('PureConnectPremise');
            pureEngCld = perms.get('PureEngageCloud');
            pureCnctCld = perms.get('PureConnectCloud');
            pureCld = perms.get('PureCloud');
            partner = perms.get('PartnerAccess');
            premCnctMngSrv = perms.get('PureCnctPremMngSrv');
            premEngMngSrv = perms.get('PureEngPremMngSrv');
            usageFileUpload = perms.get('UsageFileUpload');
            
            if ( partner.equals('Yes') ) 
                isPartner = true;
        } 
    }
    
    private static void getCaseTypes() {
        casetypesMap = new Map<String, Id>();
        List<RecordType> caseTypeLst = CaseUtil.getAllTScaseTypes();
        if ( !caseTypeLst.isEmpty() ) {
            for ( RecordType rt : caseTypeLst ) 
                casetypesMap.put( rt.DeveloperName, rt.Id );
       }
    }
    
    public PageReference redirectByUserPerms() {
        PageReference pr;
       

  /*** needed to define the order in which pages are evaluated ***/         
      /**** Read/Write ***/   
       if ( pureEngPrem.equals('Read/Write') )
           pr = new PageReference('/customercare/CustCarePePremLanding'); 
           
        else if ( pureEngCld.equals('Read/Write') )        
           pr = new PageReference('/customercare/CustCarePeCloudLanding');
                  
        else if ( pureCnctPrem.equals('Read/Write') )
           pr = new PageReference('/customercare/CustCarePcnctPremLanding'); 
               
        else if ( pureCnctCld.equals('Read/Write') )
           pr = new PageReference('/customercare/CustCarePcnctCloudLanding'); 
           
        else if ( pureCld.equals('Read/Write') )
           pr = new PageReference('/customercare/CustCarePCloudLanding'); 
             
      /*** Read Only ***/     
        else if ( pureEngPrem.equals('Read Only') )
           pr = new PageReference('/customercare/CustCarePePremLanding'); 
           
        else if ( pureEngCld.equals('Read Only') )        
           pr = new PageReference('/customercare/CustCarePeCloudLanding');
                  
        else if ( pureCnctPrem.equals('Read Only') )
           pr = new PageReference('/customercare/CustCarePcnctPremLanding'); 
               
        else if ( pureCnctCld.equals('Read Only') )
           pr = new PageReference('/customercare/CustCarePcnctCloudLanding'); 
           
        else if ( pureCld.equals('Read Only') )
           pr = new PageReference('/customercare/CustCarePCloudLanding'); 
    
    /*** Basic Access ***/
        else if ( pureEngPrem.equals('Basic') )
           pr = new PageReference('/customercare/CustCarePePremLanding'); 
           
        else if ( pureEngCld.equals('Basic') )        
           pr = new PageReference('/customercare/CustCarePeCloudLanding');
                  
        else if ( pureCnctPrem.equals('Basic') )
           pr = new PageReference('/customercare/CustCarePcnctPremLanding'); 
               
        else if ( pureCnctCld.equals('Basic') )
           pr = new PageReference('/customercare/CustCarePcnctCloudLanding'); 
           
        else if ( pureCld.equals('Basic') )
           pr = new PageReference('/customercare/CustCarePCloudLanding'); 
           
            /**** Partner ****/
        else if ( isPartner ) {
           pr = new PageReference('/customercare/CustCarePePremLanding');           
        }
       
      /*** no support access ***/         
        else
           pr = new PageReference('/customercare/CustCarePortalNews'); 
         
        return pr;
    }
    
    // Open a Case
   public pageReference getPremSupportType()  { 
        if ( casetypesMap == null )
            getCaseTypes();  
         return new PageReference('/customercare/CasePremiseProductSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Product_Case'));
    }
    
    public pageReference getPremFRType() {
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CasePremiseProductSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Feature_Request_Case'));
    }
    
    public pageReference getCloudSupportType() { 
        if ( casetypesMap == null )
            getCaseTypes();          
         return new PageReference('/customercare/CaseCloudProdSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Cloud_Support_Request'));
    }
    
    public pageReference getCloudServiceType() {
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CaseCloudProdSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Cloud_Service_Request'));
    }
          
    public pageReference getCloudFRType() {
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CaseCloudProdSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Cloud_Feature_Request'));
    }
    
    public pageReference getPureCloudFRType() {
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CaseCloudProdSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Cloud_Feature_Request'));
    }
    
    public pageReference getAdminType() {
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CaseAdminCreatePortal?RecordType=' + casetypesMap.get('Genesys_Admin_Case'));
    }
    
    public pageReference getPremServiceType() {
         if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CasePremiseProductSelectionPortal?RecordType=' + casetypesMap.get('Premises_Service_Request'));
    }

    /// List Views
    public pageReference getViewSupportType()  { 
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CasesViewListPremPortal?rectp=sprt&pgsize=20');
    }
    
    public pageReference getViewCloudTypes() {
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CasesViewListCloudPortal?rectp=cld&pgsize=20');
    }
    
    public pageReference getViewAdmin() {
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CasesViewListPremPortal?rectp=adm&pgsize=20');
    }
    
    public pageReference getViewPremFRType() {
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CasesViewListPremPortal?rectp=frprm&pgsize=20' );
    }
    
    public pageReference getViewCloudFRType() {
        if ( casetypesMap == null )
            getCaseTypes();
         return new PageReference('/customercare/CasesViewListCloudPortal?rectp=frcld&pgsize=20' );
    }
    
    /// Search
    public PageReference articleSearchPEng() {
        //String src = EncodingUtil.urlEncode(searchTxt, 'UTF-8');
        PageReference pr = 
        new PageReference('/customercare/GenesysSearchExternal#&firstQueryCause=searchboxSubmit&t=AllPureEngage&q=' + searchTxt);
        return pr;
    }
    
     public PageReference articleSearchPCld() {
        //String src = EncodingUtil.urlEncode(searchTxt, 'UTF-8');
        PageReference pr = 
        new PageReference('/customercare/GenesysSearchExternal#&firstQueryCause=searchboxSubmit&t=AllPureCloud&q=' + searchTxt);            
        return pr;
    }
    
     public PageReference articleSearchPCnct() {
        //String src = EncodingUtil.urlEncode(searchTxt, 'UTF-8');
        PageReference pr = 
        new PageReference('/customercare/GenesysSearchExternal#&firstQueryCause=searchboxSubmit&t=AllPureConnect&q=' + searchTxt);          
        return pr;
    }
    
     public PageReference caseSearch() {
        //String src = EncodingUtil.urlEncode(searchTxt, 'UTF-8');
        PageReference pr = new PageReference('/customercare/CasePortalSearchResults?inp=' + searchTxt);         
        return pr;
    }
  
}