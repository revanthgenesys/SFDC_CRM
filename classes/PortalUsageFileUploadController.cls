/***
Created By: Mariya Steason, Apr 24, 2018
class: PortalUsageFileUploadController
purpose: Controller for potal page uploading Subscription Usage File
test class: PortalUsageFileUploadController_Test
***/
public class PortalUsageFileUploadController {
	
	public List<Support_Access__c> subscrptSA {get; set;}
	public String boa {get; set;}
	public String platform {get; set;}
	public String strUrl {get; set;}
    public String msg {get; set;}
	
	public PortalUsageFileUploadController() {
	  subscrptSA = new List<Support_Access__c>();
				
	  List<Support_Access__c> allRWSA = ContactUtil.getRWSupprtAccLstByContact( ContactUtil.getUserContactId() );	  	  
	  for ( Support_Access__c sa : allRWSA ) {
	  	 if ( sa.Back_Office_Account__r.Subscription__c )
	  	    subscrptSA.add(sa);	  	
	  }
       
	}
	
	public void openGSfolder() {		
	   strUrl = '';    
       msg = '';
          
       if ( boa == null ) {
           msg = 'Sorry, we are unable to process your request at this time. Please refresh the page and try again.';
           return;
       }
      
       try {
           
           String usageUser = '';
           if ( platform != null && platform.startsWith('PureEngage') )
                 usageUser = 'PE_';
           else if  ( platform != null && platform.startsWith('PureConnect') )
                 usageUser = 'PC_';

           String endpoint = GScape_FTP_Settings__c.getInstance('UsageFileUpload').StringValue__c; 
           String keycode = GScape_FTP_Settings__c.getInstance('FileUsageKeyCode').StringValue__c; 

           HttpRequest req = new HttpRequest();
           HttpResponse res = new HttpResponse();
           Http http = new Http();
           
           req.setEndpoint(endpoint);
           req.setMethod('POST');
           req.setHeader('Content-Type','application/x-www-form-urlencoded');
        
           String body = 'SFDCUser=string=' + UserInfo.getUserName() +
                         '&usageKeyCode='   + keycode +
                         '&UsageUser='      + usageUser + boa;
           req.setBody(body);
                                                       
           res = http.send(req);
   
      	  if ( res.getStatusCode() != 200 )  {
              System.debug('**** ERROR: ' + res.toString() + '  ' + res.getBody());
		   }  
		   else {
		   	  String xmlrespose = res.getbody();
			  strUrl = xmlrespose.substringBetween('>', '</string>').substringAfterLast('>');			
		   }	

       }                                                                                                        
       catch (Exception e) {
           msg = 'The Upload File service is currently unavailable.';          
           if ( ! Test.isRunningTest() )
                        return;
       }
       
       System.debug('#### strURL '+ strUrl);
       return;
   } 

}