public without sharing class CaseDetailController {
        
        public String caseId {get; set;}
        public transient Case currentCase {get;set;}
        public String caseNumberField {get;set;}       
        public String caseUpdatePrivateRecordTypeId {get;set;}
        public Boolean showFtpButton {get;set;}
        public Boolean showCloseButton {get;set;}
        public Boolean showLiveChatButton {get; set;}
        public Boolean showReopenButton {get; set;}
        public Boolean showProvideResponseButton {get;set;}
        public Boolean isCaseAccessReadOnly {get; set; }
        public Boolean isCloudUser {get; set;}
        public Boolean isCaseCloud {get; set;}
        public Boolean showTempFtpAcct {get; set;}
        public Boolean canUserAccessThisCase {get; set;}
        public String liveChUrl {get; set;}
        public String liveChMsg {get; set;}
        public List<Attachment> attachm {get; set;}
        public Boolean showPastUpdates {get; set;}
        private String caseNumber;
        private String ownerFstName;
        private String ownerLastName;
        private String ownerEmail;
        private String ownerAlias;
        private String compName;
        private String prodName;
        private String subject;
        private String threadId;
        private Customer_Care_Live_Chat__c csf;
        private String chatType;
        private String contactLnge;
        private String platform;
        private String ownerId;
        private String ownerPSG;
        private String casePSG;

        public CaseDetailController()  {
            caseId = ApexPages.currentPage().getParameters().get('id');  
                
            if ( !CaseUtil.canUserAccessThisCase(caseId) && !Test.isrunningtest() ) {
                  canUserAccessThisCase = false;
                  return;
            }
            else
                  canUserAccessThisCase = true;                               
           
          List<Case> theCases = [SELECT c.of_Agents_Ports_Affected__c, c.Type_of_Case__c, c.Type, c.Troubleshooting_Actions__c, c.Switch__c, c.Subject, 
           c.Sub_Type__c, c.Sub_Status__c, c.Status, c.Sold_To_SAP_Code__c, c.Sold_To_Account__c, c.Sold_To_Account_For_Search__c, 
           c.Siebel_FR_Number__c, c.Service_Request_Type__c, c.RecordTypeId, c.Product_Version__c, End_User_Account__r.Name,Sold_To_Account__r.Name,
           c.Product_Line__c, c.Problem_Description__c, c.OS__c, c.Major_Release1__c, c.Main_Impact__c, c.LastModifiedDate, c.Id, 
           c.Feature_Request_Case_Number__c, c.Feature_Description__c, c.Environment_Type__c, c.End_User_SAP_Code__c, c.End_User_Account__c,
            c.Description, c.Deployment_Type__c, c.Date_Opened__c, c.Date_Needed__c, c.Date_Modified__c, c.Date_Modified_Closed__c, 
            c.Date_Justification__c, c.Database__c, c.Customer_Environment__c, c.CreatedDate, Un_entitled_product_reason__c,
            c.Contact_Name__c, Contact.Preferred_Language__c, c.ContactId, c.Component__c, OwnerId, Owner_Product_Support_Group__c,
            Support_Product__c, Major_Release__c, RecordType.Name,Date_Modifiedx__c, Product_Support_Group__c,
            c.Component_Name__c, c.Complete_Problem_Description__c,c.Cloud_Product__c, c.Cloud_Offering__c,X3rd_Party_Products__c,
             c.Closure_Reason_Code__c, c.Closure_Category__c, c.ClosedDate, c.Case_Type__c, c.Case_Type_Record__c, c.Case_Number__c, 
             c.CaseNumber, c.Business_Impact_Product__c, RecordType.DeveloperName, Priority, External_Ref__c, Recent_Changes__c, PMOwnerNew__c,
             Next_Update_Due__c, Planned_Release__c, Business_Overview__c, Business_Use_Case_for_the_feature__c, Missing_Functionality__c,
             Cost_Impact_of_missing_the_feature__c, Feature_Usage_Frequency__c, Relevant_Technical_Information__c, Problem_Sub_Type__c, End_User_Account_For_Search__c,
             Case_Owner_Portal__c, Version_Portal__c, Product_Name__c, PM_Owner_Portal__c, Temp_SFTP_Account_Name__c, Temp_SFTP_Password__c, Temp_SFTP_Account_Expiration_Date__c,
             FTP_Server__c, Date_Time_Last_Modified__c,Owner.FirstName, Owner.LastName, Owner.Alias, Owner.Name, Owner.Email, Security_Threat__c, Project_Stage__c, Cloud_Deployment__c,
             Cloud_Service__c, Cloud_Service_Name__c, Cloud_Deployment_Name__c,Thread_ID__c, BOA_Platform__c, Cloud_Platform__c,
             (SELECT Id, Name FROM Attachments WHERE Name LIKE 'Public %')
           FROM Case c WHERE id =: caseId];  
      
           if  ( !theCases.isEmpty() ) {
                
                    currentCase = theCases[0];
                                                
                    ///case access level
                    isCaseAccessReadOnly = CaseUtil.isCaseAccessLevelReadOnly(currentCase);
                        
                     ///button Provide Response                                              
                     if ( isCaseAccessReadOnly ) 
                             showProvideResponseButton = false;
                     else if (currentCase.Status == 'Awaiting Info' || currentCase.Status == 'Solution Proposed')
                           showProvideResponseButton = true;    
                     else if ( currentCase.RecordType.DeveloperName == 'Genesys_Feature_Request_Case' &&
                            (currentCase.Sub_Status__c == 'Solution Proposed' || currentCase.Sub_Status__c == 'Info Required From Customer') )
                           showProvideResponseButton = true;          
                     else
                           showProvideResponseButton = false;
                            
                     ///button Close Case
                     if ( currentCase.Status != 'Closed' && !isCaseAccessReadOnly ) 
                           showCloseButton = true;
                     else 
                           showCloseButton = false;
                           
                     /// reopen button
                     showReopenButton = false;
                 //    if ( currentCase.Status == 'Closed' && !isCaseAccessReadOnly && !currentCase.RecordType.DeveloperName.contains('Feature')  )  {
                     if ( currentCase.Status == 'Closed' && !isCaseAccessReadOnly && !currentCase.RecordType.DeveloperName.contains('Feature')  && 
                          currentCase.ClosedDate > Date.today().addDays(-30) ) {
                                  showReopenButton = true;
                     }
                     
                     // FTP button
                     showFtpButton = showCloseButton;
     
                    if ( currentCase.RecordType.DeveloperName.startswith('Genesys_Cloud_') )    
                         isCaseCloud = true;
                    else
                         isCaseCloud = false;  
                         
                    if ( showFtpButton && currentCase.Temp_SFTP_Account_Name__c != null && 
                         currentCase.Temp_SFTP_Account_Name__c != '' && currentCase.Temp_SFTP_Account_Expiration_Date__c > datetime.now() )  
                              showTempFtpAcct = true;
                    else
                          showTempFtpAcct = false; 
                    
                  /// Live Chat, excluded record types Admin and FR 
                  /// PureEngage link: platforms PureEngage Premise, PureCloud
                  /// PureConnect link: platforms PureConnect Premise and PureConnect Cloud
               String recType = currentCase.RecordType.DeveloperName; 
               csf = Customer_Care_Live_Chat__c.getOrgDefaults();     
               if ( showCloseButton && !recType.contains('Admin') && !recType.contains('Feature') ) {            
                        caseNumber = currentCase.CaseNumber;
                        ownerId = currentCase.OwnerId;
	                    ownerFstName = currentCase.Owner.FirstName;
	                    ownerLastName = currentCase.Owner.LastName;
	                    ownerEmail = currentCase.Owner.Email;
	                    ownerAlias = currentCase.Owner.Alias;
	                    compName = currentCase.Component_Name__c;
	                    prodName = currentCase.Product_Name__c;
	                    subject = currentCase.Subject;
	                    threadId = currentCase.Thread_ID__c;
	                    contactLnge = currentCase.Contact.Preferred_Language__c; 
	                    casePSG = currentCase.Product_Support_Group__c;
	                    ownerPSG = currentCase.Owner_Product_Support_Group__c;
 
                        chatType='';                  
                        if ( recType.contains('Cloud') && currentCase.Cloud_Platform__c != null && currentCase.Cloud_Platform__c.equals('PureCloud') ) {
                        	chatType = 'PureEngage'; /// for now
                        	platform = currentCase.Cloud_Platform__c;
                        }                            
                        else if (recType.contains('Cloud') && currentCase.Cloud_Platform__c != null && currentCase.Cloud_Platform__c.equals('PureConnect Cloud') ) {
                             chatType = 'PureConnect';
                             platform = currentCase.Cloud_Platform__c;
               			}
                        else if ( !recType.contains('Cloud') && currentCase.BOA_Platform__c.startswith('PureEngage') ) {
                             chatType = 'PureEngage';
                             platform = currentCase.BOA_Platform__c;
               			}
                        else if ( !recType.contains('Cloud') && currentCase.BOA_Platform__c.startswith('PureConnect') )  {
                        	chatType = 'PureConnect';
                        	platform = currentCase.BOA_Platform__c;
                        }
      
                        if ( currentCase.Owner.LastName == null && currentCase.Owner.Name == 'Unassigned' && chatType == 'PureConnect' )  
                               showLiveChatButton = false;                          
                        else if ( chatType == 'PureConnect' || (chatType == 'PureEngage' && csf.Enabled__c) )       	                    
	                         showLiveChatButton = true;	                       	           
	                    else
	                         showLiveChatButton = false;
                 }     
                  /// Attachments
                 attachm = new List<Attachment>();
                 for ( Attachment att : currentCase.Attachments )  {
                        attachm.add(att);
                 } 
                 
                 showPastUpdates = currentCase.CreatedDate < Date.valueOf('2017-10-30') ? true : false;                  
         }                        
    }
    
    public void liveChat() {
    	if ( chatType == 'PureEngage')
    	  liveChatEngage();
    	else if ( chatType == 'PureConnect')
    	  liveChatConnect();
    }
     
    public void liveChatConnect() {
    	String url = csf.URL_PureConnect__c;
    	liveChUrl = url + '?' +
                 'CaseID=' + caseId +
                 '&Name=' + UserInfo.getName() + 
                 '&Email=' + UserInfo.getUserEmail() +     
                 '&CaseThreadId=' + threadId;
    } 
      
    public void liveChatEngage() {     	         
          Blob tmEncrypted;
          String tmEncrStr = '';
          String ownerStatus = '';
          String url = csf.URL__c;
          Boolean enabled = csf.Enabled__c;        
          Blob key = EncodingUtil.base64Decode(csf.Key__c);
          
	      if ( !enabled )  {
	        liveChMsg = 'Sorry, Live Chat is not available at this time. Please try again later.';
	        return;
	      }
   
        Datetime tm = Datetime.now();
        String tmStr =  '' + tm.getTime();
        Blob tmBlb = Blob.valueOf(tmStr);
               
         try {
              tmEncrypted = Crypto.encryptWithManagedIV('AES256', key, tmBlb);
              tmEncrStr = EncodingUtil.urlEncode( EncodingUtil.base64Encode( tmEncrypted ), 'UTF-8' );
         }
         catch (Exception ex) {}
         
         liveChUrl = url + '?' +
                 'case='   + caseNumber +
                 '&caseId=' + caseId +
                       '&cntFN=' + UserInfo.getFirstName() +
                       '&cntLN=' + UserInfo.getLastName()  +
                       '&cntEmail=' + UserInfo.getUserEmail() +                       
                       '&ownFN=' + ownerFstName +
                       '&ownLN=' + ownerLastName  +
                       '&ownAlias=' + ownerAlias +
                       '&cmp='   + compName +
                       '&prd='   + prodName +
                       '&token=' + tmEncrStr +
                       '&subject=' + subject +
                       '&caseThreadId=' + threadId +
                       '&prefLanguage=' + contactLnge +
                       '&casePSG=' + casePSG +
                       '&caseOwnerPSG=' + ownerPSG +
				       '&platform=' + platform +
				       '&availbl=' + ownerStatus +
				       '&caseOwnerEmail=' + ownerEmail;			
   }
        
}