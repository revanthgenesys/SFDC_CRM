public class CaseOpenFTPExtension {
                        
    private final Case cs;
    private Id csId;
    private String csnum;
    private String user;
    private String pswd;
    private String srvr;
    private String eu;
    private String st;
    private String strUrl;
    private String supportReg;
    private Boolean isValidURL = false;
 
    public CaseOpenFTPExtension(ApexPages.StandardController stdController) {            
       //this.cs = (Case)stdController.getRecord();
       csId = Apexpages.currentPage().getParameters().get('Id');
       
       user = '';
       pswd = '';
       String status='';

       /// check if the folder exists and create if not
       FTP_Setting__c ftpus = FTP_Setting__c.getInstance('User');
       String wsuser = ftpus.Value__c;          
       FTP_Setting__c ftpp = FTP_Setting__c.getInstance('Pwd');
       String wspwd = ftpp.Value__c;
       FTP_Setting__c ftps = FTP_Setting__c.getInstance('URL_Dest');
       srvr = ftps.Value__c;

           ftp.FTPFolderPort stub = new ftp.FTPFolderPort();
                                
           stub.Security = new ftp.Security_element();
           stub.Security.UsernameToken = new ftp.UsernameToken_element();
           stub.Security.UsernameToken.Username = wsuser;
           stub.Security.UsernameToken.Password = wspwd;
                        
       try {
                Case csquery = [SELECT CaseNumber, Case_Number__c, Siebel_FR_Number__c, End_User_Account__c, Status,
                                       Sold_To_Account__c, End_User_Account__r.Support_Group__c
                                FROM Case WHERE ID= :csId];
                                
                if ( !verifyAccess(csquery.Sold_To_Account__c, csquery.End_User_Account__c) ) {
                	   isValidURL = false;
                	   getStrUrl();
                	   return;
                }
       
            	FTP_Access__c fa = [SELECT f.SAP_Code_Sold_To__c, f.SAP_Code_End_User__c,
                                             f.FTP_User_Name__c, f.FTP_Password__c 
                                      FROM FTP_Access__c f
                                      WHERE f.End_User_Account__c= :csquery.End_User_Account__c
                                        AND f.Sold_To_Account__c= :csquery.Sold_To_Account__c LIMIT 1];
                                        
	            if (csquery.Case_Number__c != null && csquery.Siebel_FR_Number__c == null)
	                 csnum = csquery.Case_Number__c;
	            else
	                csnum = csquery.CaseNumber;  
	            
	            supportReg = csquery.End_User_Account__r.Support_Group__c; 
	            status = csquery.Status;                               
	            user = fa.FTP_User_Name__c;
	            pswd = fa.FTP_Password__c;
	            eu   = fa.SAP_Code_End_User__c;
	            st   = fa.SAP_Code_Sold_To__c;
	                
	            System.debug('### USER '+ user);
	            System.debug('#### PASSW '+ pswd);
	                
	            if (user != '' && pswd != '' && status != 'Closed') {                          
	                 isValidURL = true;                   
	                 ftp.CreateFTPFolder_Create_Output_element retcode = stub.Create(csnum,st,eu);
	            }       
        
        /*
                        eu = '00034';
                        st = '0012';
                        user = 'tst00123';
                pswd = 'K9Lgx-mZ';
        */      
                    //// first create directory for the Case if does not exist                                                                                                           
	       }
	       catch (Exception e) {
	                isValidURL = false; 
	       }
    }
    
    public Boolean getisValidURL() {
        return isValidURL;
    }
    
    public String getServer() {
        return srvr;
    }
 
    public String getCasenumber() {
        return csnum;
    }
   
    public String getFtpuser() {
        return user;
    }
    
    public String getFtppsswd() {
        return pswd;     
    }
    
    public String getStrUrl() {
        String url = '';
        
        if ( isValidURL == false ) {
             url = 'https://' + srvr + '/wftp/voidext.html'; 
        }
                     
        else if ( supportReg != null )
              url = 'https://'                  + srvr + 
                    '/wftp/explorer.aspx?user=' + user + 
                    '&password='                + pswd  + 
                    '&dir=/sr'                  + csnum +
                    '&region='                  + supportReg;
       
        else if ( supportReg == null || supportReg == '' )
              url = 'https://'                  + srvr + 
                    '/wftp/explorer.aspx?user=' + user + 
                    '&password='                + pswd  + 
                    '&dir=/sr'                  + csnum;
         
         System.debug('#### URL ' + url);  
                 
         return url;           
    }
    
    private Boolean verifyAccess(ID stId, ID euId) {
    	Integer portalCnt  = [SELECT count() 
        					  FROM   Profile 
        					  WHERE  id =: userInfo.getProfileId() 
        					    and  name LIKE '%Portal%'];        
    	if ( portalCnt == 0 )
    	    return true;
    	
    	List<User> lstUser = [SELECT Id,ContactId 
                              FROM   User  
                              WHERE  Id = :UserInfo.getUserId()];
                              
        Integer access =   [SELECT count()
                              FROM   Support_Access__c 
                              WHERE Contact__c = :lstUser[0].ContactId                                          
                                and Support_Blocked__c=false 
                                and  SR_Access_Level__c = 'Read/Write'
                                and  Maintenance_Terminated_Flag__c=false
                                and Service_Contract_Status__c IN ('Active','Pending','In Negotiation')
                                and End_User_Account__c = :euId
                                and Sold_To_Account__c = :stId];
        if ( access > 0 ) 
            return true;
        else       
    	    return false;    	
    }
    
    public PageReference pageRef() {   	 
    	 PageReference pageRef;
    	 
         Integer n  = [SELECT count() 
                          FROM Profile 
                         WHERE Name LIKE 'Genesys Portal%' 
                           AND ID= :UserInfo.getProfileId()];
    	if ( n>0 ) {
    		pageRef = new PageReference('/apex/CaseDetail?id=' + csId); 		 
    	}     	
    	else    	    
    	    //pageRef = new ApexPages.StandardController(cs).view();  
    	    pageRef = new PageReference('/' + csId); 
    	    
    	pageRef.setRedirect(true);
        return pageRef;
    }
}