/*
Naresh Kumar    05/27/2013
*/
public without sharing class CaseCommentExtension {
        public Genesys_Case_Updates__c newCaseUpdate {get;set;}
        String caseId;
        public Boolean isPortal {get; set;}
        public Boolean fr_case {get;set;}
        public String selectedSubStatClose {get; set;}
        public Case cs {get; set;}
        
        public CaseCommentExtension(ApexPages.StandardController stdController){
                caseId = ApexPages.currentPage().getParameters().get('caseId');
                if (null == caseId) {
                        // wsmith look for the field value on the URL 
                        // it is best ot to hard code value here but have little choice
                        Genesys_Case_Updates__c caseUpds = (Genesys_Case_Updates__c) stdController.getRecord();
                        if (null != caseUpds) {
                                caseId = caseUpds.Case__c;
                        }
                }
                
                isPortal = ContactUtil.isPortalUser();
                fr_case=false;
                 
                newCaseUpdate = new Genesys_Case_Updates__c(Case__c = caseId, Make_Public__c = isPortal);
                if(isPortal)
                        newCaseUpdate.Type__c = 'Update from Customer';
      
                if ( String.isNotBlank(caseId) )  {
	                cs = [SELECT CaseNumber, recordtypeid, recordtype.name, recordtype.DeveloperName, Status, Sub_Status__c,
	                              Last_Public_Customer_Update__c, 
	                              Closure_Category__c, Closure_Reason_Code__c, Last_Public_Case_Update_Description__c
	                      FROM Case WHERE id =: caseId];
	                
	                if (cs.recordtype.name.contains('Feature') )
	                    fr_case=true;
                }
        }
        
        public PageReference save(){
                insert newCaseUpdate;
                
                if ( newCaseUpdate.Make_Public__c ) {
                        Case existingCase = new Case(id = caseId);
                        if(isPortal || (newCaseUpdate.Type__c != null && newCaseUpdate.Type__c.contains('PS Update')))
                         existingCase.Last_Public_Customer_Update__c = System.now();
                        else 
                         existingCase.Last_Public_Care_Update__c = System.now(); 
                        
                        existingCase.Last_Public_Case_Update_Description__c = newCaseUpdate.Description__c;
                                        
                        update existingCase;
                }
                
                return returnDetPage();
        }
        
        //The following function added by Ankit on 5/29/2013
        public List<SelectOption> getTypes(){
                
            List<SelectOption> options = new List<SelectOption>();
	        Schema.DescribeFieldResult fieldResult = Genesys_Case_Updates__c.Type__c.getDescribe();
	        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                if(fr_case){
                        options.add(new SelectOption('Research', 'Research'));
                        options.add(new SelectOption('Update to Customer', 'Update to Customer'));
                        options.add(new SelectOption('Info Required from Customer', 'Info Required from Customer'));
                        options.add(new SelectOption('Proposed Solution', 'Proposed Solution'));
                     
                } else {
                        for( Schema.PicklistEntry f : ple){
                        options.add(new SelectOption(f.getLabel(), f.getValue()));
                        } 
                } 
           return options;
        }
        /// close form
        public List<SelectOption> getSubStatusClose(){
                
                List<SelectOption> substat = new List<SelectOption>();
                substat.add(new SelectOption('Resolved', 'Resolved'));
                substat.add(new SelectOption('Cancelled', 'Cancelled')); 
            return substat;
        }
               
        public PageReference saveClose() {
                /// called from portal
           if ( newCaseUpdate.Description__c != null && newCaseUpdate.Description__c != '' ) {
                        insert newCaseUpdate;
           }
        
            cs.Last_Public_Customer_Update__c = System.now();
            cs.Status = 'Closed';
            cs.Sub_Status__c = this.selectedSubStatClose;
            
            if ( cs.Closure_Category__c == null || cs.Closure_Category__c == '')
                 cs.Closure_Category__c = 'Customer Closure';
            
            if ( cs.Closure_Reason_Code__c == null ||  cs.Closure_Reason_Code__c == '' ) {
                if ( this.selectedSubStatClose == 'Resolved' ) {         
                    cs.Closure_Reason_Code__c = 'Closed by Customer - Resolved';
                }
                else {
                    cs.Closure_Reason_Code__c = 'Closed by Customer - Cancelled';
                }
            }
            cs.Last_Public_Case_Update_Description__c = newCaseUpdate.Description__c;
                                        
            update cs;
            return returnDetPage();
        }
        
         public PageReference saveOpen(){
                /// called from portal
           if ( newCaseUpdate.Description__c != null && newCaseUpdate.Description__c != '' ) {
                        insert newCaseUpdate;
           }
        
            cs.Last_Public_Customer_Update__c = System.now();
    
            if ( !fr_case && cs.Status != 'Open' ) {
                cs.Status = 'Open';           
                cs.Sub_Status__c = 'Customer Responded';
            }
            else if ( fr_case && 
                   (cs.Sub_Status__c == 'Info Required from Customer' || cs.Sub_Status__c == 'Solution Proposed') )  {
                cs.Sub_Status__c = 'Customer Responded';     
            }
            
            cs.Last_Public_Case_Update_Description__c = newCaseUpdate.Description__c;                                         
            update cs;
            
            return returnDetPage();
        }
        
    public PageReference reopenCase() {
   	    if ( newCaseUpdate.Description__c != null && newCaseUpdate.Description__c != '' ) {
   	    	   newCaseUpdate.Type__c = 'Request to Re-open';
               insert newCaseUpdate;
        }
        
        cs.Last_Public_Customer_Update__c = System.now();
        cs.Sub_Status__c = 'Customer Requested to Re-open';
     	cs.Last_Public_Case_Update_Description__c = newCaseUpdate.Description__c;                                         
        update cs;
            
     	return returnDetPage();
     }
        
    public PageReference cancel(){
        return returnDetPage();
    }
        
       public PageReference returnDetPage() {
        	PageReference pr;
        	
        	if ( !isPortal )
        	   pr = new PageReference('/' + caseId);
        	else {   
	        	if ( cs.RecordType.DeveloperName == 'Genesys_Admin_Case' )
	        	   pr = new PageReference('/apex/CaseDetailAdminPortal?id=' + caseId); 
	        	else if ( cs.RecordType.DeveloperName == 'Genesys_Cloud_Feature_Request' )
	        	   pr = new PageReference('/apex/CaseFRDetailCloudPortal?id=' + caseId); 
	        	else if ( cs.RecordType.DeveloperName.startswith('Genesys_Cloud_') )
	        	   pr = new PageReference('/apex/CaseDetailCloudPortal?id=' + caseId); 
	        	else
	        	   pr = new PageReference('/apex/CaseDetail?id=' + caseId); 
        	}
        	
        	return pr;
        }
}