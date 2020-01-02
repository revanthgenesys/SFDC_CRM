/************************************************************************************
Purpose : Class to pull Cloud Deployment configuration from Service Now 
Written By : Mariya Steason
Test Classes : SNOWIntegration_Test
Business Areas affected: Customer Support, internal app
*************************************************************************************/
public class SNOWIntegrationDeploymentInfo {
	
	private final String endpoint = '/api/x_cros2_salesforce/customer_system_environment_details/cloud_deployment_id';
    private String snInstanceURL;
    public  String username;    
    public  String password;    
    public  String notifyOnErrors;
    public  String statusCode;
    public  String statusMsg;
    public SNOWfromJSON delpinfo {get; set;}
    public String cldDeplName {get; set;}
    public List<String> primBackSrvr {get; set;}
    public List<VersPatchInfo> versionPatchLst {get; set;}
    private Id cloudDeplId;
         
    public SNOWIntegrationDeploymentInfo() {    	
    	snInstanceURL = ServiceNowIntegration__c.getOrgDefaults().InstanceURL__c;  
    }
    
    public PageReference getByCaseId() { 
    	String caseId = ApexPages.currentPage().getParameters().get('cs');         
        versionPatchLst = new List<VersPatchInfo>();
        
    	if ( !String.isBlank(caseId) ) {
    		List<Case> cs = [SELECT Cloud_Deployment__c, Cloud_Deployment__r.Name FROM Case WHERE Id = :caseId];
     	
	     	if ( ! cs.isEmpty() ) {
	     		cloudDeplId = cs[0].Cloud_Deployment__c;
	     		cldDeplName = cs[0].Cloud_Deployment__r.Name;
	 
		    	if ( String.isBlank(cloudDeplId) ) {
		    		ApexPages.Message statusMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Cloud Deployment is not specified.');
		            ApexPages.addMessage(statusMsg);   
		            return null;
		    	}
	    	}
    		
    		getDeplInfo(cloudDeplId);     		
    	}
    	
    	return null;  	
    }
   
    public void getDeplInfo(String cloudDeplId) { 
    	
    	
    	delpinfo = new SNOWfromJSON();            
	
		HttpRequest req = new HttpRequest();
        req.setEndpoint(snInstanceURL + endpoint);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept', 'application/json');
 
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();     	
        generator.writeStringField('cloud_deployment_id', cloudDeplId);  
        String payload = generator.getAsString();
        req.setBody(payload); 
 
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
      	if ( res.getStatusCode() == 200 )  {
             String responseBody = res.getBody();
             delpinfo = SNOWfromJSON.parse(responseBody);              
		}  
		else {
             ApexPages.Message statusMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: ' + res.toString() + '  ' + res.getBody());
	         ApexPages.addMessage(statusMsg);   
	         return;
		} 
	
		if ( delpinfo != null ) {		
		   ///primary, backup server
		   for ( String vp : delpinfo.Version_patch_information ) {		   	  
		       versionPatchLst.add( new VersPatchInfo(vp) );
		   }
		}
					
    }
    
    public class VersPatchInfo {
    	public String prodName {get; set;}
    	public String server {get; set;}
    	public String version {get; set;}
    	
    	public VersPatchInfo(String toparse) {
    		List<String> lst = toparse.split(',');
    		try {
    			server = lst[0];
    			prodName = lst[1];
    			version = lst[2];
    		}
    		catch (Exception ex) {}
    	}
    }   
}