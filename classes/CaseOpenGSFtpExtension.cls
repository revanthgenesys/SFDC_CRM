global class CaseOpenGSFtpExtension {
        
    private ID csId;
    public String strUrl {get; set;}
    public String msg {get; set;}
   
    public CaseOpenGSFtpExtension(CaseDetailController caseDetcont) {            
       csId = Apexpages.currentPage().getParameters().get('Id'); 
    }
   
    public CaseOpenGSFtpExtension(ApexPages.StandardController stdController) {            
       csId = Apexpages.currentPage().getParameters().get('Id');
       if ( csId == null )
           csId = stdController.getId();
    }
    
    /* This method is called from the Case Detail on Portal and internal app CONSOLE */
    public void genUrl() {  
       strUrl = '';    
       msg = '';
          
       if ( csId == null ) {
           msg = 'Sorry, we are unable to process your request at this time. Please refresh the page and try again.';
           return;
       }
      
       try {
                Case csquery = [SELECT CaseNumber, End_User_SAP_Code__c, Sold_To_SAP_Code__c, Status
                                FROM Case WHERE ID= :csId];
                   
                 String csnum = csquery.CaseNumber;             
                 String status = csquery.Status; 
                 String userLogin = Userinfo.getUserName();                              
                 String endUserSAPCode = csquery.End_User_SAP_Code__c;
                 String soldToSAPCode = csquery.Sold_To_SAP_Code__c;
   
                 Integer timeout = (Integer) GScape_FTP_Settings__c.getInstance('Timeout').NumValue__c;

                 if ( status != 'Closed') { 
                       FtpGSservices.WSWrapperEFTServerSoap port = new FtpGSservices.WSWrapperEFTServerSoap();   
                       String region = '';
                                              
                       if ( ContactUtil.isPortalUser() )  {    
                           /// portal customer 
                            
                            List<Contact> cont = [SELECT Support_Region__c FROM Contact 
                                                  WHERE Id IN (Select ContactId From User Where id = :UserInfo.getUserId())];                               
                            
                            if ( !cont.isEmpty() ) 
                                region = cont[0].Support_Region__c ;                                                              
                       }
                       else {
                            /// internal 
                             User usr = [SELECT Employee_Region__c FROM User WHERE id = :UserInfo.getUserId()];
                             region = usr.Employee_Region__c;
                       }
                       
                       port.endpoint_x = getEndpoint(region);
                        
                       if ( timeout != null && timeout > 0)                                    
                                 port.timeout_x= timeout;
                                 
                       strUrl = port.CreateUserAndCase(userLogin, soldToSAPCode, endUserSAPCode, csnum);   
                 }
                 else {
                       msg = 'This case is Closed. The Transfer Files service is not available for closed cases.';
                       return;
                    }
       }                                                                                                        
       catch (Exception e) {
           msg = 'The Transfer Files service is currently unavailable.';          
           if ( ! Test.isRunningTest() )
                        return;
       }
       
       System.debug('#### strURL '+ strUrl);
       return;
   } 
  
   /* This method is called from button on internal app  - NOT Console*/
   WebService static String genUrl(ID caseId) {  
       String ERROR_PAGE = 'apex/CaseFtpError';
       String strUrl = '';    
       String msg = '';
          
       Case csquery = [SELECT CaseNumber, End_User_SAP_Code__c, Sold_To_SAP_Code__c, Status                                      
                       FROM Case WHERE ID= :caseId];
                   
       String csnum = csquery.CaseNumber;             
       String status = csquery.Status; 
       String userLogin = Userinfo.getUserName();                              
       String endUserSAPCode = csquery.End_User_SAP_Code__c;
       String soldToSAPCode = csquery.Sold_To_SAP_Code__c;
         
       Integer timeout = (Integer) GScape_FTP_Settings__c.getInstance('Timeout').NumValue__c;
       
       User usr = [SELECT Employee_Region__c FROM User WHERE id = :UserInfo.getUserId()];
                             
       try {
             FtpGSservices.WSWrapperEFTServerSoap port = new FtpGSservices.WSWrapperEFTServerSoap(); 
             if ( timeout != null && timeout > 0)                                    
                     port.timeout_x= timeout;                                                   
             //port.timeout_x= 120000;
             
             port.endpoint_x = getEndpoint( usr.Employee_Region__c );
             strUrl = port.CreateUserAndCase(userLogin, soldToSAPCode, endUserSAPCode, csnum); 
       }  
       catch (Exception e) {
           if ( ! Test.isRunningTest() )
                        return ERROR_PAGE;
       }
       

       if ( ! strUrl.startsWith('http'))
                return ERROR_PAGE;
       else
           return strUrl;
   }  
   
   public static String getEndpoint(String region) {
       if ( region == null )
          region = 'US';
          
       String endpnt = '';
            
       if ( region.equals('EMEA') ) 
              endpnt = GScape_FTP_Settings__c.getInstance('EMEA').StringValue__c;                              
       else if ( region.equals('APAC') ) 
              endpnt = GScape_FTP_Settings__c.getInstance('APAC').StringValue__c; 
       else
              endpnt = GScape_FTP_Settings__c.getInstance('US').StringValue__c; 

System.debug('*** Endpoint ' + endpnt );                        
           return endpnt;       
   }
                                     
}