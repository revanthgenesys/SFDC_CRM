/************************************************************************************
Purpose : Class to pull Cloud Deployment configuration from Service Now 
Written By : Mariya Steason
Test Classes : SNOWIntegration_Test
Business Areas affected: Customer Support, internal app
*************************************************************************************/
public class SNOWfromJSON {
	
	public cls_Customer_URLs Customer_URLs {get; set;}
    public cls_Deployment_model_RCM_LCM Deployment_model_RCM_LCM {get; set;}
    public cls_MPLS_Voice_DB_owned_by_CaaS_Customer MPLS_Voice_DB_owned_by_CaaS_Customer {get; set;}     
    public List<String> Version_patch_information {get; set;}
    public List<cls_Primary_key_backup_server> Primary_key_backup_server {get; set;}
  
    public static SNOWfromJSON parse(String json) {
		return (SNOWfromJSON) System.JSON.deserialize(json, SNOWfromJSON.class);
	}
            
	public class cls_Customer_URLs {
	    public String CIC_for_Salesforce_URL {get; set;}
	    public String Exchange_Web_Service_URL {get; set;}
	    public String FTP_URL {get; set;}
	    public String Interaction_Connect_URL {get; set;}
	    public String Marquee_URL {get; set;}
	    public String Mobile_Client_URL {get; set;}
	    public String Optimizer_URL {get; set;}
	    public String SharePoint_URL {get; set;}
	    public String TSRA_Application_URL {get; set;}
	    public String Web_Chat_URL {get; set;}
	    public String Web_Client_URL {get; set;}
	    public String iPad_Supervisor_URL {get; set;} 	
	}
	    
	public class cls_Deployment_model_RCM_LCM {
	   	public String Deployment_Model {get; set;}
	}
		
	public class cls_MPLS_Voice_DB_owned_by_CaaS_Customer {
		public String DB_owned_by {get; set;}
		public String MPLS_owned_by {get; set;}
		public String Voice_owned_by {get; set;}
	}
		
	public class cls_Primary_key_backup_server {
		public String Property_Key {get; set;}
		public String Property_Value {get; set;}
		public String Server {get; set;}
	}
	    
}