public class PortalCaseNewSelectTypes {

    public Boolean isPortalUser {get; set;}
        public Boolean isCloudUser {get; set;}
        public Boolean isPremUser {get; set;}
        public Boolean isHybrid {get; set;}
        public String selectedCloudPrem {get; set;}
        public String selectedDepl {get; set;}
        public String selectedRecType {get; set;}
        public Boolean displayCldDepl {get; set;}
        
        public List<SelectOption> recTypes {get; set;}
        public List<SelectOption> deployments {get; set;}
        public Map<Id,Cloud_Deployment__c> selectedDeplObj {get; set;}
        public Boolean isAdminCase {get; set;}
        public String StId {get; set;}
        public String EuId {get; set;}
        public String StName {get; set;}
        public String EuName {get; set;}
        private Boolean isSingleStEu;
        private Boolean isSingleCld;
        
        public PortalCaseNewSelectTypes() {
            recTypes = new List<SelectOption>();
            deployments = new List<SelectOption>();
            selectedDeplObj = new Map<Id,Cloud_Deployment__c>();
            displayCldDepl = false;
            isSingleStEu = false;
            isSingleCld = false;
 
            isAdminCase = ApexPages.currentPage().getParameters().get('adm') == '1' ? true : false; 
                   
            isPortalUser = ContactUtil.isPortalUser();
                isCloudUser = ContactUtil.isCloudUser(); 
                isPremUser = ContactUtil.isPremiseUser();
                isHybrid = isCloudUser && isPremUser ? true : false;
                        
                if ( isPremUser )
                   selectedCloudPrem = 'Premise';
                else if ( isCloudUser )
                   selectedCloudPrem = 'Cloud';  
                        
                getRecTypes(); 
                
                if ( isCloudUser )
                      getDeployments(); 
                       
                if ( isPremUser )
                    getSTEUcombo();                     
        }
        
        public void getRecTypes() {
           List<RecordType> caseRecTypes = [SELECT Id, Name, DeveloperName 
                                                                FROM RecordType WHERE SobjectType = 'Case' ORDER BY Name DESC];
                           
           Map<String, RecordType> recmap = new Map<String, RecordType>();
           for ( RecordType rt : caseRecTypes )  { 
                         recmap.put(rt.DeveloperName, rt);
           } 
             
           recTypes.clear();
           
           if ( isAdminCase )  {
              /// admin for all types of users
               selectedRecType = recmap.get('Genesys_Admin_Case').Id;
           }
           else if ( selectedCloudPrem == 'Cloud' || (isCloudUser && !isHybrid) )  {
              /// cloud user can only log support case
               recTypes.add( new SelectOption( recmap.get('Genesys_Product_Case').Id, recmap.get('Genesys_Product_Case').Name ) );
               selectedRecType = recmap.get('Genesys_Product_Case').Id;               
           }
           else {
                   recTypes.add( new SelectOption( recmap.get('Genesys_Product_Case').Id, recmap.get('Genesys_Product_Case').Name ) );
                   recTypes.add( new SelectOption( recmap.get('Genesys_Feature_Request_Case').Id, recmap.get('Genesys_Feature_Request_Case').Name ) );
           }
               
           return;
      }
        
       public PageReference redirectToCasePage() {
           if ( isPortalUser && !isHybrid && (isSingleStEu || isSingleCld || isAdminCase) )
              return  goNext();
  
           return null;
       }
       
       public PageReference goNext() {

           // checl all required parameters
           if ( selectedRecType == null || selectedRecType == '' )
                 return null;
        
            ///Cloud access. covers Admin and Support types
                if ( selectedCloudPrem == 'Cloud')  {
                          if (selectedDepl == 'none') {
                            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the Cloud Deployment.');
                        ApexPages.addMessage(errorMessage);
                        return null;
                   }
                   else {    
                                    PageReference pgcld = new PageReference('/customercare/PortalNewCloudCase?RecordType=' + selectedRecType + '&dpl=' + selectedDepl + '&ct=Cloud');
                                        pgcld.setRedirect(true);
                                    return pgcld;
                   }
                } 
                
                ///  Premise
                if ( selectedCloudPrem == 'Premise' ) {
                         PageReference pgprm; 
                         
                         if ( isSingleStEu && !isAdminCase )  {       
                              pgprm = new PageReference('/customercare/UpdateCaseProductNew?RecordType=' + selectedRecType + '&ct=Premise' + '&stid=' + StId + '&euid=' + EuId);
                              /// this will handle "&" in account name
                              pgprm.getParameters().put('stnm', Stname);
                              pgprm.getParameters().put('eunm', Euname);                                              
                         }
                             /// multiple premise or (single and admin for redirect)
                         else if ( StId != null && EuId != null )
                           pgprm = new PageReference('/customercare/PortalNewFRCase?RecordType=' + selectedRecType + '&ct=Premise' + '&stid=' + StId + '&euid=' + EuId);                            

                         else       
                          pgprm = new PageReference('/customercare/UpdateCaseProductNew?RecordType=' + selectedRecType + '&ct=Premise');  
                  
                          pgprm.setRedirect(true);
                      return pgprm;
                }
                                                
                return null;            
        }
               
     private void getDeployments() {         
            List<Cloud_Deployment__c>  deplnts =  ContactUtil.getUserCloudDepl();
            if ( deplnts.size() == 1 ) {
                isSingleCld = true;
                selectedDepl = deplnts[0].Id;
                displayCldDepl = false;
            }
            else if ( deplnts.size() > 1 ) { 
                displayCldDepl = true;
                deployments.add( new SelectOption('none', '--Select--' ) ); 
            
                for ( Cloud_Deployment__c cd : deplnts )  {
                        deployments.add( new SelectOption(cd.Id, cd.Name) ); 
                        selectedDeplObj.put(cd.Id, cd);
                }  
            }     
            return; 
    }
        
    private void getSTEUcombo() {
        Id contId = ContactUtil.getUserContactId();
        List<Support_Access__c> salist = ContactUtil.getRWSupprtAccLstByContact(contId);
        if ( salist.size() == 1 ) {
                StId = salist[0].Sold_To_Account__c;
                StName = salist[0].Sold_To_Account__r.Name;
                EuId = salist[0].End_User_Account__c;
                EuName = salist[0].End_User_Account__r.Name; 
                
                isSingleStEu = true;
        }
        return;
    }
        
    public String getacnt { 
           get {
        
            if (selectedDepl != null && selectedDepl != 'none')    
                  return selectedDeplObj.get(selectedDepl).Account__r.Name;
           else
              return null;
              
           }
           set;
        }
}