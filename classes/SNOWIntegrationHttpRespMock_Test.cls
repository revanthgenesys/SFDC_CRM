@isTest
global class SNOWIntegrationHttpRespMock_Test implements HttpCalloutMock {
	
	global static String resp;
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        SNOWfromJSON sn = new SNOWfromJSON();
        sn.Customer_URLs = new SNOWfromJSON.cls_Customer_URLs();
        sn.Deployment_model_RCM_LCM = new SNOWfromJSON.cls_Deployment_model_RCM_LCM();
        sn.MPLS_Voice_DB_owned_by_CaaS_Customer = new SNOWfromJSON.cls_MPLS_Voice_DB_owned_by_CaaS_Customer();
        sn.Version_patch_information = new List<String>();
        sn.Primary_key_backup_server = new List<SNOWfromJSON.cls_Primary_key_backup_server>();
        
        sn.Customer_URLs.CIC_for_Salesforce_URL= 'str';
	    sn.Customer_URLs.Exchange_Web_Service_URL= 'str';
	    sn.Customer_URLs.FTP_URL= 'str';
	    sn.Customer_URLs.Interaction_Connect_URL= 'str';
	    sn.Customer_URLs.Marquee_URL= 'str';
	    sn.Customer_URLs.Mobile_Client_URL= 'str';
	    sn.Customer_URLs.Optimizer_URL= 'str';
	    sn.Customer_URLs.SharePoint_URL= 'str';
	    sn.Customer_URLs.TSRA_Application_URL= 'str';
	    sn.Customer_URLs.Web_Chat_URL= 'str';
	    sn.Customer_URLs.Web_Client_URL= 'str';
	    sn.Customer_URLs.iPad_Supervisor_URL= 'str'; 
	    
	    sn.Deployment_model_RCM_LCM.Deployment_Model = 'str';
	    
	    sn.MPLS_Voice_DB_owned_by_CaaS_Customer.DB_owned_by = 'str';
	    sn.MPLS_Voice_DB_owned_by_CaaS_Customer.MPLS_owned_by = 'str';
	    sn.MPLS_Voice_DB_owned_by_CaaS_Customer.Voice_owned_by = 'str';
	    
	    sn.Primary_key_backup_server.add(new SNOWfromJSON.cls_Primary_key_backup_server() );
	
        res.setBody(JSON.serialize(sn));
        res.setStatusCode(200);
        return res;
    }
	
    
}