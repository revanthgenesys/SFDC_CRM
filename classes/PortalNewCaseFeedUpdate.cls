/************************************************************************************
Purpose : Controller class post update to a Case on Support portal
Written By : Mariya Steason
Test Classes : PortalNewCaseFeedUpdate_Test
Business Areas affected: Customer Care portal
*************************************************************************************/
public class PortalNewCaseFeedUpdate {
    
    public String errMsg {get; set;}
    public String caseupdate {get; set;}
    public String updtype {get; set;}
    public Case cs {get; set;}
    public String selectedSubStatClose {get; set;}
    public Boolean fr_case {get;set;}
    private String caseId;
    
    public PortalNewCaseFeedUpdate() {
        caseId = ApexPages.currentPage().getParameters().get('cs');
        updtype = ApexPages.currentPage().getParameters().get('tp'); 
        
        fr_case = false;    
        errMsg = '';
        
        try {
            if ( String.isNotBlank(caseId) ) {
                List<Case> cslst = [SELECT CaseNumber, RecordType.DeveloperName, Sub_Status__c, Status, New_Updates__c,
                                            Closure_Category__c, Closure_Reason_Code__c, Subject
                                    FROM Case WHERE Id = :caseId];
                                    
                if ( !cslst.isEmpty() ) {
                    cs = cslst[0];
                    
                    if (cs.RecordType.DeveloperName.contains('Feature') )
                            fr_case = true;             
                }
            }
        }
        catch (Exception ex) {
             errMsg='Error processing the request.';             
        }
    }
    
    public PageReference returnDetPage() {
            PageReference pr;
            
            if ( cs.RecordType.DeveloperName == 'Genesys_Admin_Case' )
                   pr = new PageReference('/customercare/CaseDetailAdminPortal?id=' + caseId); 
            else if ( cs.RecordType.DeveloperName == 'Genesys_Cloud_Feature_Request' )
                   pr = new PageReference('/customercare/CaseFRDetailCloudPortal?id=' + caseId); 
            else if ( cs.RecordType.DeveloperName.startswith('Genesys_Cloud_') )
                   pr = new PageReference('/customercare/CaseDetailCloudPortal?id=' + caseId); 
            else
                   pr = new PageReference('/customercare/CaseDetail?id=' + caseId); 
 
            return pr;
    }
    
    public PageReference cancel(){
        return returnDetPage();
    }
    
    public PageReference saveOpen(){
           if ( String.isBlank(caseupdate) )  {
                  errMsg='Please provide Update description';             
              return null;             
           }       

           try {
                
                if ( ! addCaseUpdate() ) {
                    errMsg='Cannot save the update due to unsupported format in the content.';
                    return null;               
                }
                
                if ( !fr_case ) 
                    cs.Status = 'Open'; 

                cs.New_Updates__c = true;
                cs.Last_Public_Customer_Update__c = System.now();               
                cs.Sub_Status__c = 'Update from Customer'; 
                                                                                
                update cs;
           }
           catch (Exception ex) {
              errMsg='Error processing the request.';             
              return null;
        }
                      
         return returnDetPage();
     }
     
    public PageReference saveClose() {
         if ( String.isBlank(caseupdate) )  {
                  errMsg='Please provide Closure Comment';             
              return null;              
           }       
        
           try {
               if ( ! addCaseUpdate() ) {
                        errMsg='Error processing the request.';
                        return null;
                }
                
                cs.New_Updates__c = true;   
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
     
                update cs;
           }
           catch (Exception ex) {
              errMsg='Error processing the request.';             
              return null;
           }
            
          return returnDetPage();
        }
        
    public Boolean addCaseUpdate() {  
     /* per SFDC FeedItem API reference, remove tags: br, span, style if contains color 
       1. replace <br> tags with <p></p> ; Match <br> <br > <br/> <br /> 
	   2. put text inside open/close <p> tags if text starts with <p>  
	*/
         String body = caseupdate.replaceAll('<br[^>]*>', '</p><p>');
         body = body.replaceAll('</span[^>]*>', '');
         body = body.replaceAll('<span[^>]*>', '');
         
          if ( ! body.startsWith('<p>') )
              body = '<p>' + body + '</p>';

          FeedItem fdi = new FeedItem();
          fdi.Body = body;
          fdi.ParentId = caseId;
          fdi.Visibility = 'AllUsers';
          fdi.Title = 'Update from Customer';
          //fdi.IsRichText = true;//Commented for INC0429308
          try {   	
                  insert fdi; 
                  System.debug('** fdi.Body : ' + fdi.Body) ;  
          }
          catch (Exception ex) {         	
			  System.debug('** ERROR fdi.Body : ' + fdi.Body) ;       	
              return false;
          }
          
          return true;
     }
       
     public PageReference reopenCase() {
        if ( String.isBlank(caseupdate) )  {
                  errMsg='Please provide Reason for Re-opening';             
              return null;            
         }                       
        try {
                if ( ! addCaseUpdate() ) {
                        errMsg='Cannot save the update due to unsupported format in the content.';
                        return null;
                }
        
                cs.New_Updates__c = true;
                cs.Last_Public_Customer_Update__c = System.now();
                cs.Sub_Status__c = 'Customer Requested to Re-open';                                       
                update cs;
        }
        catch (Exception ex) {
                  errMsg='Error processing the request.';             
              return null;
        }    
        return returnDetPage();
     }
     
}