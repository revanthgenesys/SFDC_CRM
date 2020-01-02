public class CaseSelectRecordTypePortal {
        
   public Boolean isCloudUser {get; set;}
   public Boolean isPremUser {get; set;}
   public Boolean mngPremCases {get; set;}
   public Boolean mngCloudCases {get; set;}

    private Map<String, Id> casetypesMap;
    private String mode;
    private String caseType;
 
    public CaseSelectRecordTypePortal() {
         mode = ApexPages.currentPage().getParameters().get('mode'); 
         caseType = ApexPages.currentPage().getParameters().get('cstp'); 
                
         isCloudUser = ContactUtil.isCloudUser(); 
		 isPremUser = ContactUtil.isPremiseUser();
	
         mngPremCases = isPremUser? true : ContactUtil.isPremiseReadOnlyUser();
         mngCloudCases = isCloudUser? true : ContactUtil.isCloudReadOnlyUser();

		 casetypesMap = new Map<String, Id>();
		 List<RecordType> caseTypeLst = CaseUtil.getAllTScaseTypes();
		 if ( !caseTypeLst.isEmpty() ) {
		        for ( RecordType rt : caseTypeLst ) 
		              casetypesMap.put( rt.DeveloperName, rt.Id );
		 }
    }
        
  public pageReference autoRedirect() {         
          if (  mode == 'new' && isPremUser == isCloudUser )  
        	  return null;
        	  
          if (  mode == 'mng' &&  mngPremCases == mngCloudCases)  
        	  return null;
          
          PageReference pr; 
          if ( mode == 'new' && caseType == 'sprt' ) 
                     pr = isPremUser ? premSupportType() : null;
        
          else if ( mode == 'new' && caseType == 'fr' )
                     pr = isPremUser ? premFRType() : cloudFRType();
                             
          else if ( mode == 'mng' && caseType == 'sprt' )  
                     pr = mngPremCases ? viewSupportType() : viewCloudTypes();
                                 
          else if ( mode == 'mng' && caseType == 'fr' )
                     pr = mngPremCases ? viewPremFRType() : viewCloudFRType();    
                     
          return pr;
  }
        
   // Open a Case
   public pageReference premSupportType()  {    
         return new PageReference('/customercare/CasePremiseProductSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Product_Case'));
    }
    
    public pageReference premFRType() {
         return new PageReference('/customercare/CasePremiseProductSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Feature_Request_Case'));
    }
    
    public pageReference cloudSupportType() {           
         return new PageReference('/customercare/CaseCloudProdSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Cloud_Support_Request'));
    }
    
    public pageReference cloudServiceType() {
         return new PageReference('/customercare/CaseCloudProdSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Cloud_Service_Request'));
    }
          
    public pageReference cloudFRType() {
         return new PageReference('/customercare/CaseCloudProdSelectionPortal?RecordType=' + casetypesMap.get('Genesys_Cloud_Feature_Request'));
    }
    
    public pageReference adminType() {
         return new PageReference('/customercare/CaseAdminCreatePortal?RecordType=' + casetypesMap.get('Genesys_Admin_Case'));
    }
     
    /// List Views
    public pageReference viewSupportType()  { 
         return new PageReference('/customercare/CasesViewListPremPortal?rectp=sprt&pgsize=20');
    }
    
    public pageReference viewCloudTypes() {
         return new PageReference('/customercare/CasesViewListCloudPortal?rectp=cld&pgsize=20');
    }
    
    public pageReference viewAdmin() {
         return new PageReference('/customercare/CasesViewListPremPortal?rectp=adm&pgsize=20');
    }
    
    public pageReference viewPremFRType() {
         return new PageReference('/customercare/CasesViewListPremPortal?rectp=frprm&pgsize=20' );
    }
    
    public pageReference viewCloudFRType() {
         return new PageReference('/customercare/CasesViewListCloudPortal?rectp=frcld&pgsize=20' );
    }
    
}