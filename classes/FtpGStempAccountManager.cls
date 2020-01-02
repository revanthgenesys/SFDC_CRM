public class FtpGStempAccountManager {
        
        private Integer expDays=0;
        public Case theCase {get; private set;}
        private String caseNum;
        private String endUserSAPCode;
        private String soldToSAPCode;
        public Boolean isAcctActive {get; private set;}
        public Boolean isClosed {get; private set;}
        public String msg {get; private set;}
               
        public FtpGStempAccountManager(ApexPages.StandardController stdController) {            
        ID caseID = Apexpages.currentPage().getParameters().get('Id');
   
        if ( caseID == null ) {
           msg='Error: Case not found.'; 
           return;
        }
        
        GScape_FTP_Settings__c ftpset = GScape_FTP_Settings__c.getInstance('TempAccountExpirationDays');
        expDays = (Integer)ftpset.NumValue__c;
        
        theCase = [SELECT Id, CaseNumber, End_User_SAP_Code__c, Sold_To_SAP_Code__c, Status,
                         Temp_SFTP_Account_Expiration_Date__c, Temp_SFTP_Account_Name__c, 
                         Temp_SFTP_Password__c, FTP_Server__c,  FTP_Account_Expiration_Flag__c,
                         Access_Temp_FTP_Folders__c                                      
                  FROM Case WHERE ID= :caseID LIMIT 1];
       
       if ( theCase != null ) {                      
          caseNum = theCase.CaseNumber;                          
          endUserSAPCode = theCase.End_User_SAP_Code__c;
          soldToSAPCode = theCase.Sold_To_SAP_Code__c;
   
          if ( theCase.Temp_SFTP_Account_Expiration_Date__c == null || 
               theCase.Temp_SFTP_Account_Expiration_Date__c < System.now() )
                         isAcctActive = false;
          else if ( theCase.Temp_SFTP_Account_Expiration_Date__c >= System.now() )
                isAcctActive = true;
                
          if ( theCase.Status == 'Closed' )
                isClosed = true;
          else
                isClosed = false;
       }      
     }
        
     public void generateSFTPaccnt() { 
       msg = null;      
       if ( isAcctActive ) {
         msg='The current account is still active. Please first disable an account.';
         return;
       }
       if ( isClosed ) {
         msg='This functionality is not available when a case is Closed.';
         return;
       }
   
       String tmpUserName = GenerateFtpGScredentials.GenFtpAccount(caseNum);
       String tmpPassword = GenerateFtpGScredentials.GenPasswd();
       String userLogin = Userinfo.getUserName(); 
       
       if ( tmpUserName == 'ERROR' || tmpPassword == '' || tmpUserName == '' ) {
           msg='An error occur generating account credentials. Please again later.';
           return;
       }
       
           
       Integer timeout = (Integer) GScape_FTP_Settings__c.getInstance('Timeout').NumValue__c;
       
       String result='';     
       FtpGSservices.WSWrapperEFTServerSoap port = new FtpGSservices.WSWrapperEFTServerSoap();  
       
       port.endpoint_x = GScape_FTP_Settings__c.getInstance('US').StringValue__c; 
        
      if ( timeout != null && timeout > 0)                                     
       		port.timeout_x= timeout;  
       		
      try {      
          result = port.CreateTempUser(userLogin, soldToSAPCode, endUserSAPCode, CaseNum, tmpUserName, tmpPassword);
      }
       catch (Exception e){
          msg='An error occur activating temp account on Globalscape. Please try again later.';
          if ( ! Test.isRunningTest() )
                        return;
       } 
             
       try {
           theCase.Temp_SFTP_Account_Name__c = tmpUserName;
           theCase.Temp_SFTP_Password__c = tmpPassword;
           theCase.Temp_SFTP_Account_Expiration_Date__c = System.Now().addDays(expDays);     
           update(theCase);
       }
       catch (DMLException e) {
         msg = 'Failed to reset Credentials on the Case: ' + e.getMessage();
         return;
       }
 
       if (  result != 'Success') 
            msg='ERROR activating temp account on Globalscape: ' + result;
       else
            msg='The SFTP account has been enabled.';
             
       isAcctActive = true;
   
       return;      
   }
   
   public void disableSFTPaccnt() {
       msg = null;
       if ( ! isAcctActive ) {
         msg='There is no active account to disable.';
         return;
       }
           
       String tmpUserName = theCase.Temp_SFTP_Account_Name__c;
       String tmpPassword = theCase.Temp_SFTP_Password__c;
       String userLogin = Userinfo.getUserName(); 
       
       String result='';
       FtpGSservices.WSWrapperEFTServerSoap port = new FtpGSservices.WSWrapperEFTServerSoap();                                       
       port.timeout_x= 120000;  
       try {      
          result = port.DisableTempUser(userLogin, soldToSAPCode, endUserSAPCode, CaseNum, tmpUserName, tmpPassword);
       }
       catch (Exception e) {
           msg='An error occur deactivating temp account on Globalscape. Please try again later.';
           if ( ! Test.isRunningTest() )
                        return;
       }
  
       try {
               theCase.Temp_SFTP_Account_Name__c = null;
               theCase.Temp_SFTP_Password__c = null;
               theCase.Temp_SFTP_Account_Expiration_Date__c = null;     
               update(theCase);
       }
       catch (DMLException e) {
         msg = 'Failed to reset Credentials on the Case: ' + e.getMessage();
         return;
       }
   
       if (  result != 'Success') 
              msg='ERROR deactivating temp account on Globalscape: ' + result;
       else
             msg ='The SFTP account has been disabled.';
             
       isAcctActive = false;
       return;      
   }
   
 
}