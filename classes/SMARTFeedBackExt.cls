/**=====================================================================
 * Name: SMARTFeedBackExt

 * Unit Test Class: SMARTFeedBackExt_Test
 * Description: Methods related to SMARTFeedBackExt
 * Created By: [Varma Palapala] 
 * 
 * Date Modified           Modified By             Description of the update
 * [MON DD, YYYY]         [FirstName LastName]     [Short description for changes]
 *  11  07  2017           Varma Palapala          SMARTFeedBackExt
  =====================================================================**/
Public with sharing class SMARTFeedBackExt {

   
    Public String Cases { get; set; }
    Public attachment objAttachment{get; set;}
    Public SMART_Feedback__c objFeedbackloop{get; set;}
    
    Public String strRecordName {get; private set;}
    
    //To identify submit
    Public boolean IsSave{get; set;} //check it is for Attachment save or submit
    Public boolean IsValidation{get; set;}  // Upload File Verificaiton 
    
    Public boolean IsNewRecord{get; set;}   // Use ths for Save & Cancel
    Public string BaseURL{get;set;}         // Use to get the Base URL.   

    //Variables for file attachment
    Public string fileName{get;set;}   
    Public transient Blob fileBody{get;set;}
    Public string FileDescType{get;set;}
    Public string sAttachmentId{get;set;}
    
    Public PageReference objRef;
    Public boolean blnIsSubmitted{get;set;}
     
    /*List variables*/
    Public List<Attachment> list_Attachment{get;set;}
    
    Public String reqType {get;set;}
    Public String strRequestor {get;set;}
    Public String strFeedbackRequestor {get;set;}
    Public String strFocusValue {get;set;}
    Public String solutionFeedbackType {get;set;}
    Public String solutionchange {get;set;}
    Public String productchange {get;set;}
    Public String strAccVa {get;set;}
    Public String strOppVa {get;set;}
    Public String strCommVa {get;set;}
    Public String RecordTypeId {get;set;}
    Public String Id {get;set;} 
    Public String strFeedbackCategory {get;set;}
    Public boolean inputflag{get;set;}  
    Public string strupdatedrootComments {get; set;}
    Public string strupdaterootComments {get; set;}
    Public string strAssignedTo {get; set;}
    

    /*

    */
    Public string strIdeaTitle {get; set;}
    Public string strIdeaComments {get; set;}
    Public string strIdeaAntiBenefits {get; set;}

    Public string strDispositionComment {get; set;}
    Public Date strDispositionDate {get; set;}
    Public string strDispositionStatus {get; set;}


    /*
        Use Case Details Picklist Options
    */
    Public String solutionCat {get;set;} 
    Public String solstate {get;set;} // Solution
    Public String ref {get;set;}      // Ref
    Public String usecase {get;set;}  // Usecase 
    
    Public boolean IsEdit{get; set;} 
    Public boolean IsSubmitterOnEdit{get; set;}
    Public List<casewrapper> caselist {get; set;}
    Public List<case> selectedcases   = new List<case>();
    
    private ApexPages.StandardController stdCtrl;
    Public string scontrolCaching {get; set;}

    Public SMARTFeedBackExt(){
        RecordTypeId     = ApexPages.CurrentPage().getparameters().get('RecordTypeId');
        Id               = ApexPages.CurrentPage().getparameters().get('Id');
        if(Id!=null) objFeedbackloop  = getSMartFeedBack(Id);  else objFeedbackloop  = new SMART_Feedback__c();
    }
    
    Public void CommonMethod(){
        System.debug(' Inside the Common method');
        objAttachment   = new Attachment();
        IsNewRecord = true;
        
        /*Get Base URL*/
        BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
        getcase();
        GetAttachments();
    }
    
    Public SMARTFeedBackExt(ApexPages.StandardController controller)
    {
        stdCtrl=controller;
        
        RecordTypeId    = ApexPages.CurrentPage().getparameters().get('RecordType');
        scontrolCaching = ApexPages.CurrentPage().getparameters().get('scontrolCaching'); 
        objFeedbackloop = (SMART_Feedback__c)controller.getRecord();
        System.debug('* * RecordType Name  ** ' + RecordTypeId + '* * objFeedbackloop  ** ' +objFeedbackloop);
        
        if(objFeedbackloop.Id!=null){
            IsEdit = true;            
            objFeedbackloop   = getSMartFeedBack(objFeedbackloop.Id);
             usecase           = objFeedbackloop.Use_Case_Name__c; 
             
             strRecordName     = objFeedbackloop.Name; 
             strCommVa         = objFeedbackloop.User_Comments__c;
             solstate          = objFeedbackloop.Product_Categories__c; 
             ref               = objFeedbackloop.Use_Case_Id__c;  
             

             strIdeaTitle =        objFeedbackloop.Idea_Title__c;                    
             strIdeaComments=      objFeedbackloop.Use_Case_Brief_Description__c;              
             strIdeaAntiBenefits=  objFeedbackloop.Anticipated_Benefits__c;                   
             strDispositionComment=objFeedbackloop.Disposition_Comment__c;            
             strDispositionDate=   objFeedbackloop.Disposition_Date__c;             
             strDispositionStatus= objFeedbackloop.Disposition_Status__c;             

             //usecase           = objFeedbackloop.DSR_Use_Case__c;
             
             // check if the current user is the same as the submitter on edit, and set a flag accordingly
             if (UserInfo.getUserId() == objFeedbackloop.Submitter__c){
                 IsSubmitterOnEdit = true;
             }else{
                 IsSubmitterOnEdit = false;
             }

        }else{
            objFeedbackloop = new SMART_Feedback__c();
            IsEdit = false;    
        } 
        
        CommonMethod(); // Invoke Reqiuired Comman Methods. 
        
         IF(RecordTypeId!=NULL) {
             objFeedbackloop.RecordTypeId = RecordTypeId;
             RecordType Rname             =  [select Id, Name from RecordType where Id=:RecordTypeId limit 1];
             objFeedbackloop.Product_or_Use_Case__c=Rname.Name;
         }
    }
    
    
    public PageReference AccountPopulated(){
      System.debug('strAccVa' +strAccVa);   
      List<Account> accountlist          = new List<Account>([select AccountNumber, Site from Account where Name=:strAccVa and Status__c='Active' limit 1]);  
      if(accountlist.size()>0)
      objFeedbackloop.Sold_To_Account__c = accountlist[0].Id;
      System.debug('  ** Feed back Object  ** '+objFeedbackloop);
      getcase();
      return null;
    }
 
    public PageReference OpportunityPopulated(){
      
      List<Opportunity> Opportunitylist          = new List<Opportunity>([select Id, BusinessPartner__c, BusinessPartner__r.name, AccountId from Opportunity where Name=:strOppVa limit 1]);  
      if(Opportunitylist.size()>0)
      objFeedbackloop.Opportunity__c = Opportunitylist[0].Id;
      
      // set the account on the feedback based on the opportunity sold to/business partner
      if (Opportunitylist.size()>0 && Opportunitylist[0].BusinessPartner__c != null){
          objFeedbackloop.Sold_To_Account__c = Opportunitylist[0].BusinessPartner__c;
          strAccVa = Opportunitylist[0].BusinessPartner__r.name;
          AccountPopulated();
      }else{
        strAccVa = null;
        objFeedbackloop.Sold_To_Account__c = null;
      }
     
      return null;
    }
     
    public void AssignEmail(SMART_Feedback__c objFeedbackloop)
    {
        if(objFeedbackloop.Id == null){
            objFeedbackloop.Submitter__c = UserInfo.getUserId();
            string[] sEmail              = null;
            String emailTo               = null;

            if(objFeedbackloop.Product_or_Use_Case__c=='Product'){
                 FeedBack_GovernanceTeam__C governceTeam       = FeedBack_GovernanceTeam__C.getValues(objFeedbackloop.Product_Category__c);
                 if(governceTeam!=null){
                           sEmail                              = governceTeam.Solution_Target_Aliases__c.split(','); 
                           objFeedbackloop.Group_owner__c      =governceTeam.Prime__c;
                 }else{
                      governceTeam   =  FeedBack_GovernanceTeam__C.getValues('Default');
                     if(governceTeam!=null){
                          sEmail                               = governceTeam.Solution_Target_Aliases__c.split(','); 
                          objFeedbackloop.Group_owner__c       = governceTeam.Prime__c;
                     }
                 }
            }
            if(objFeedbackloop.Product_or_Use_Case__c=='Use Case'){
                 FeedBack_GovernanceTeam__C governceTeam       =  FeedBack_GovernanceTeam__C.getValues(objFeedbackloop.Product_Categories__c);
                 if(governceTeam!=null){
                         emailTo                               = governceTeam.Use_Case_Target_Aliases__c +','+ governceTeam.Solution_Target_Aliases__c;
                         sEmail                                = emailTo.split(',');
                         objFeedbackloop.Group_owner__c        =governceTeam.Prime__c;
                 }else{
                        governceTeam                           =  FeedBack_GovernanceTeam__C.getValues('Default');
                        if(governceTeam!=null){
                           emailTo                             = governceTeam.Use_Case_Target_Aliases__c +','+ governceTeam.Solution_Target_Aliases__c;
                           sEmail                              = emailTo.split(',');
                           objFeedbackloop.Group_owner__c      = governceTeam.Prime__c;
                        }
                 }
            }
            Set<string> myset = new Set<string>();
            List<string> result = new List<string>();
            for (string s : sEmail) {
              if (myset.add(s)) {
                result.add(s);
              }
            }

            if(sEmail!=null) { 
                 objFeedbackloop.Feedback_Sent_To__c           = string.join(result,',');
            }
            objFeedbackloop.isEmailSent__c = true;
            insert objFeedbackloop;
            SendEmailByTemplate(objFeedbackloop.Submitter__c,'SMART_Feedback_Email_Template', objFeedbackloop.Id,sEmail);
        }
    } 
    
    /*
        Submitting the FeedbackLoop Record
    */
    public PageReference submit()
    {
        System.debug(' *  *   objFeedbackloop * * ' + strDispositionComment );
        if(objFeedbackloop.Id == null)
        {
            objFeedbackloop.Submitter__c = UserInfo.getUserId();
            string[] sEmail              = null;
            String emailTo               = null;

            if(objFeedbackloop.Product_or_Use_Case__c=='Product'){
                 FeedBack_GovernanceTeam__C governceTeam       =  FeedBack_GovernanceTeam__C.getValues(objFeedbackloop.Product_Category__c);
                 if(governceTeam!=null){
                           sEmail                              = governceTeam.Solution_Target_Aliases__c.split(','); 
                           objFeedbackloop.Group_owner__c      =governceTeam.Prime__c;
                 }else{
                      governceTeam   =  FeedBack_GovernanceTeam__C.getValues('Default');
                     if(governceTeam!=null){
                          sEmail                               = governceTeam.Solution_Target_Aliases__c.split(','); 
                          objFeedbackloop.Group_owner__c       = governceTeam.Prime__c;
                     }
                 }
            }
            if(objFeedbackloop.Product_or_Use_Case__c=='Use Case'){
                 FeedBack_GovernanceTeam__C governceTeam       =  FeedBack_GovernanceTeam__C.getValues(objFeedbackloop.Product_Categories__c);
                 if(governceTeam!=null){
                         emailTo                               = governceTeam.Use_Case_Target_Aliases__c +','+ governceTeam.Solution_Target_Aliases__c;
                         sEmail                                = emailTo.split(',');
                         objFeedbackloop.Group_owner__c        =governceTeam.Prime__c;
                 }else{
                        governceTeam                           =  FeedBack_GovernanceTeam__C.getValues('Default');
                        if(governceTeam!=null){
                           emailTo                             = governceTeam.Use_Case_Target_Aliases__c +','+ governceTeam.Solution_Target_Aliases__c;
                           sEmail                              = emailTo.split(',');
                           objFeedbackloop.Group_owner__c      = governceTeam.Prime__c;
                        }
                 }
            }

            Set<string> myset = new Set<string>();
            List<string> result = new List<string>();
            for (string s : sEmail) {
              if (myset.add(s)) {
                result.add(s);
              }
            }

            if(sEmail!=null){
              objFeedbackloop.Feedback_Sent_To__c              = string.join(result,',');
              objFeedbackloop.isEmailSent__c                   = true;
            }
            
            objFeedbackloop.Submitted__c=true;
            objFeedbackloop.Use_Cases__c = usecase;
            objFeedbackloop.Disposition_Status__c='Open';
            insert objFeedbackloop;

            strRecordName = objFeedbackloop.Name; 
            SendEmailByTemplate(objFeedbackloop.Submitter__c,'SMART_Feedback_Email_Template', objFeedbackloop.Id,sEmail); 
            
            if(IsNewRecord){
              IsNewRecord = false; 
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your Feedback has now been saved and the details have been sent to the Feedback team for review. Thank you.'));    
              return null;
            }  
        }
        
        try
        {    
            Set<String> CaseSet = new Set<String>();
            Map<String, Case>  CaseMap = new Map<String, Case>();
            
             objFeedbackloop.Idea_Title__c =strIdeaTitle;
             objFeedbackloop.Use_Case_Brief_Description__c=strIdeaComments;
             System.debug('>>>>>>>>>>>>>>>'+strIdeaAntiBenefits);
             objFeedbackloop.Anticipated_Benefits__c = strIdeaAntiBenefits;
             objFeedbackloop.Disposition_Comment__c = strDispositionComment;
             objFeedbackloop.Disposition_Date__c = strDispositionDate;
             objFeedbackloop.Disposition_Status__c = strDispositionStatus;

            if(objFeedbackloop.Id!=null && (objFeedbackloop.isEmailSent__c || objFeedbackloop.Submitted__c)){
                  if(objFeedbackloop.User_Comments__c!=strCommVa) objFeedbackloop.User_Comments__c=strCommVa;
                  update objFeedbackloop;
                   strRecordName = objFeedbackloop.Name; 
                  IsNewRecord = false; 
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your updates have now been saved. Thankyou.'));    
                 return null;
            } 
            if(objFeedbackloop.Id!=null && (!objFeedbackloop.isEmailSent__c || !objFeedbackloop.Submitted__c)){
              
              objFeedbackloop.Submitted__c = true;
              objFeedbackloop.isEmailSent__c = true;
              
              objFeedbackloop.Submitter__c = UserInfo.getUserId();
              string[] sEmail              = null;
              String emailTo = null;
              if(objFeedbackloop.Product_or_Use_Case__c=='Product'){
                 FeedBack_GovernanceTeam__C governceTeam       =  FeedBack_GovernanceTeam__C.getValues(objFeedbackloop.Product_Category__c);
                if(governceTeam!=null){
                           sEmail                              = governceTeam.Solution_Target_Aliases__c.split(','); 
                           objFeedbackloop.Group_owner__c      =governceTeam.Prime__c;
                 }else{
                      governceTeam   =  FeedBack_GovernanceTeam__C.getValues('Default');
                     if(governceTeam!=null){
                          sEmail                               = governceTeam.Solution_Target_Aliases__c.split(','); 
                          objFeedbackloop.Group_owner__c       = governceTeam.Prime__c;
                     }
                 }
              }
              if(objFeedbackloop.Product_or_Use_Case__c=='Use Case'){
                   FeedBack_GovernanceTeam__C governceTeam       =  FeedBack_GovernanceTeam__C.getValues(objFeedbackloop.Product_Categories__c);
                  if(governceTeam!=null){
                           emailTo                               = governceTeam.Use_Case_Target_Aliases__c +','+ governceTeam.Solution_Target_Aliases__c;
                           sEmail                                = emailTo.split(',');
                           objFeedbackloop.Group_owner__c        =governceTeam.Prime__c;
                   }else{
                          governceTeam                           =  FeedBack_GovernanceTeam__C.getValues('Default');
                          if(governceTeam!=null){
                             emailTo                             = governceTeam.Use_Case_Target_Aliases__c +','+ governceTeam.Solution_Target_Aliases__c;
                             sEmail                              = emailTo.split(',');
                             objFeedbackloop.Group_owner__c      = governceTeam.Prime__c;
                          }
                   }
              }

              Set<string> myset = new Set<string>();
              List<string> result = new List<string>();
              for (string s : sEmail) {
                if (myset.add(s)) {
                  result.add(s);
                }
              }

              if(sEmail!=null){
                objFeedbackloop.Feedback_Sent_To__c              = string.join(result,',');
                objFeedbackloop.isEmailSent__c                   = true;
              }

             objFeedbackloop.Submitted__c=true;
             System.debug(' *  *   objFeedbackloop * *  111 strDispositionStatus' + strDispositionStatus);
              System.debug(' *  *   objFeedbackloop * *  111 strDispositionStatus' + objFeedbackloop.Disposition_Status__c);
             
             objFeedbackloop.User_Comments__c = strCommVa;
             objFeedbackloop.Product_Categories__c= solstate; 
             objFeedbackloop.Use_Case_Id__c = ref; 
             

             for(DSR_UseCase_BluePrint_Definition__c smarlist:[select Name__c, ID from DSR_UseCase_BluePrint_Definition__c 
                                                          where Type__c='Use Case' and Solution__c=:solstate AND ShortCode__c=:ref
                                                          and Active__c=True limit 199]){
                objFeedbackloop.DSR_Use_Case__c = smarlist.Id;
                objFeedbackloop.Use_Case_Name__c =smarlist.Name__c;
              }

              update objFeedbackloop;
              strRecordName = objFeedbackloop.Name; 
              objFeedbackloop =getSMartFeedBack(objFeedbackloop.Id);
              
              SendEmailByTemplate(objFeedbackloop.Submitter__c,'SMART_Feedback_Email_Template', objFeedbackloop.Id,sEmail); 
              IsNewRecord = false; 
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your Feedback has now been saved and the details have been sent to the solutions team for review. Thankyou.'));    
              return null;
          }
        
                       
        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return null;
    }
    
    /*
        For “Solution” on the Feedback Form, 
        derived from a list of distinct values from the “DSR UseCase&BluePrint Definition” records, from field “Solution__c”, 
        where Solution Category = the one selected for the Solution Category on the form, and where Active=true.
    */
    
    public List<SelectOption> getSolution(){
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('--Select--','--Select--'));
       Set<String> solSetItems = new Set<String>();
          for(DSR_UseCase_BluePrint_Definition__c  smarlist:[select Solution__c, Active__c from DSR_UseCase_BluePrint_Definition__c 
                                                             where Type__c='Use Case' and Solution__c!='' AND Active__c=TRUE order by Solution__c asc limit 199]){
            solSetItems.add(smarlist.Solution__c);
            System.debug('>>>>>>>>>>>>solSetItems >>>>>>>>' +solSetItems);  
          }
          for(String smarlist:solSetItems){
            options.add(new SelectOption(smarlist,smarlist));
          }
         System.debug('>>>>>>>>>>>>options >>>>>>>>' +options);
         options.sort();
        return options;
    }

    /*
        For “Ref” on the Feedback Form, this should be derived from a list of distinct values from the “DSR UseCase&BluePrint Definition” records, from field “ShortCode__c”, 
        where Solution Category = the one selected for the Solution Category on the form, where Solution = the one selected for the Solution on the form, and where Active=true.
    */
    
    public List<SelectOption> getrefs(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--Select--','--Select--'));
        objFeedbackloop.Product_Categories__c = solstate;
        Set<String> solSetItems = new Set<String>();
        System.debug('>>>>>>>>>>>>solstate >>>>>>>>' +solstate);
        if(solstate!=null){
          for(DSR_UseCase_BluePrint_Definition__c smarlist:[select Id, ShortCode__c,Active__c from DSR_UseCase_BluePrint_Definition__c 
                                                            where Type__c='Use Case' and Solution__c=:solstate AND Active__c=True order by ShortCode__c asc limit 199]){
              solSetItems.add(smarlist.ShortCode__c);
          }
          
          for(String smarlist:solSetItems){
            options.add(new SelectOption(smarlist,smarlist));
          }
        }
        options.sort();
        return options;
    }
    
   

    /*
        Use Cases picklist Options
    */
    public List<SelectOption> getusecases(){
        List<SelectOption> options = new List<SelectOption>();
        Set<String> solSetItems = new Set<String>();
        objFeedbackloop.Use_Case_Id__c =ref;
        System.debug('>>>>>>>>>>>>ref >>>>>>>>' +ref);
        for(DSR_UseCase_BluePrint_Definition__c smarlist:[select Name__c, ID from DSR_UseCase_BluePrint_Definition__c 
                                                          where Type__c='Use Case' and Solution__c=:solstate AND ShortCode__c=:ref
                                                          and Active__c=True limit 199]){
            objFeedbackloop.DSR_Use_Case__c = smarlist.Id;
            objFeedbackloop.Use_Case_Name__c =smarlist.Name__c;
            solSetItems.add(smarlist.Name__c);
        }
        for(String smarlist:solSetItems){
          options.add(new SelectOption(smarlist,smarlist));
        }

        return options;
    } 
    
    
    /*
        Get the Attachmets.
    */ 
    public void GetAttachments(){
        if(objFeedbackloop.Id!=null){ 
            list_Attachment = [Select id,Description,name from Attachment where ParentId =: objFeedbackloop.id];
        }
    }
    
    
    /*
        Delete Attachment
    */
    public void DeleteAttachment(){
        Attachment objATT = [Select id,Description,name from Attachment where id =:sAttachmentId];
        delete objATT;
        GetAttachments();
    }

   /*
    Cancel Action
   */ 
   public PageReference CancelPSDSR(){
        String RecordId = ApexPages.CurrentPage().getparameters().get('id');   
        IsNewRecord = false;
        if(RecordId!=null){
          objFeedbackloop =getSMartFeedBack(RecordId);
          if(!objFeedbackloop.isEmailSent__c) delete objFeedbackloop;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Your changes have now been cancelled. Thankyou.')); 
        }else{
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'The Feedback item you have been working on has now been cancelled. Thankyou.'));    
        }
        return null;
   }  
   
   /*
     Upload Action for Document  
   */
   public PageReference UploadFile()  
    {  
        string sPageUrl = '';
        IsSave=true;
        
        if(fileBody == null || fileName == '') 
        { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select the '+FileDescType+' file.'));
            IsValidation=false;
        } 
        else
            IsValidation=true;
            
        if(IsValidation)
        { 
            if(objFeedbackloop.Id==null)
            {
             selectedcases.clear();
            
             for(casewrapper csswrapper : caselist){
                 if(csswrapper.selected == true){
                        selectedcases.add(csswrapper.css);
                        Case cs = csswrapper.css; 
                        if(objFeedbackloop.Cases__c!=null) objFeedbackloop.Cases__c = objFeedbackloop.Cases__c +','+ cs.CaseNumber; else objFeedbackloop.Cases__c = cs.CaseNumber;
                  }
             }
             objFeedbackloop.Disposition_Status__c='Open';
             System.debug('>>>>>>>>>>>>>' + objFeedbackloop.Anticipated_Benefits__c);
             upsert objFeedbackloop;
            }
            
            Attachment obj = new Attachment();
            obj.Body = fileBody;
            obj.Name = fileName;
            obj.ParentId = objFeedbackloop.id;
            obj.Description = FileDescType ;
            insert obj;
            
            System.debug('Inserted the Documents' +Obj);
            
            fileBody =null;
            fileName = '';
            FileDescType = '';
            
            if(!objFeedbackloop.Attachment__c){
              objFeedbackloop.Attachment__c = true; 
              upsert objFeedbackloop;
            }
            
            GetAttachments();
            
            objRef = new PageReference('/apex/SMARTPages?id='+objFeedbackloop.id); 
            objRef.setRedirect(true);
            return objRef;  
              
         }
               
       return null;
    }
    
    
    /*
        Custom email functionality 
    */
    public static String SendEmailByTemplate(Id UserId,String strTemplateName, Id DealSupportId, string[] sEmail)
    {
        string strResult='Failed';
        try{
            // Create a new single email message object
            // that will send out a single email to the addresses in the To, CC & BCC list.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            // Specify the name used as the display name.
            mail.setSenderDisplayName('');                   
            // Set to True if you want to BCC yourself on the email.
            mail.setBccSender(false);
            
            Set<string> myset = new Set<string>();
            List<string> result = new List<string>();
            for (string s : sEmail) {
              if (myset.add(s)) {
                result.add(s);
              }
            }

            mail.setToAddresses(result);
            
            string sLabel = system.Label.Deal_Support_Email_Service;
            string[] sEmailService = new string[1];
            sEmailService[0] = sLabel;
            //mail.setCcAddresses(sEmailService);
            mail.setUseSignature(false);
            //Map the VF template
            mail.setTargetObjectId(UserId); //Mandatory field when use template
            mail.setWhatId(DealSupportId); //Assign Wow Id
            mail.setTemplateId([select id from EmailTemplate where Name =: strTemplateName].id);  //Find the template on the basis of name                    
            // Send the email you have created.
            mail.SaveAsActivity = false; //Mandatory field when use template
            Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {mail};

            Messaging.sendEmail(emailList);
            strResult='Successful';


            Feedback__c objDSC = new Feedback__c();
            objDSC.Feedback_Loop__c = DealSupportId;
            objDSC.Subject__c = emailList[0].getSubject();
            objDSC.Email_Body__c =emailList[0].getHtmlBody();
            objDSC.To__c =  string.join(result,','); 
            insert objDSC;

            System.debug('Sending the email : ** ');
        }    
        catch(exception ex)
        {
            strResult='Failed';
            system.debug('ex '+ex.getMessage());
        } 
        return strResult;        
    }  
    
    
    
    public class casewrapper
    {
        public Case css{get; set;}
        public Boolean selected {get;set;}
        public Integer caseNumber {get;set;}
        public casewrapper(Integer caseNumber, case c, Boolean selected)
        {  
            this.caseNumber = caseNumber;
            this.css = c;
            this.selected = selected;
        }
    }
    
   public List<casewrapper> getcase() 
   {
       Set<Integer> cNumber = new Set<Integer>();
       String accId        = ApexPages.CurrentPage().getparameters().get('accId'); 
       caselist            = new List<casewrapper>();
       System.debug(' [To mark the cases with checked] ' +caselist);
        
       if(objFeedbackloop.Id!=null){
           objFeedbackloop =getSMartFeedBack(objFeedbackloop.Id); 
       }
       accId               = objFeedbackloop.Sold_To_Account__c; //accId='001U000000YdHSd';
       
       if(objFeedbackloop.Cases__c!=null){
           for(string caseNumber:objFeedbackloop.Cases__c.split(',')){
               cNumber.add(Integer.Valueof(caseNumber));
           }
       }
       
       System.debug('  Existing Cases list ' + cNumber);
        
       for(case c : [select CaseNumber, Id, Type, Status, Subject from case where Sold_To_Account__c!= null and Sold_To_Account__c=:accId Order by lastmodifiedDate desc LIMIT 10]){
         if(cNumber.contains(Integer.Valueof(c.CaseNumber))){
             caselist.add(new casewrapper(Integer.ValueOf(c.CaseNumber), c, true));
         }   
         else{
             caselist.add(new casewrapper(Integer.ValueOf(c.CaseNumber), c, false));
         }
       }
       
       return caseList;
   }
   
   
   public List<casewrapper> getRelcase()
   {
       List<String> cNumber = new List<String>();
       String accId        = ApexPages.CurrentPage().getparameters().get('accId'); 
       caselist            = new List<casewrapper>();
       
       if(objFeedbackloop.Id!=null){
           objFeedbackloop =getSMartFeedBack(objFeedbackloop.Id);
           accId = objFeedbackloop.Sold_To_Account__c;
       }
       
       if(objFeedbackloop.Cases__c!=null){
           for(string caseNumber:objFeedbackloop.Cases__c.split(',')){
               cNumber.add(caseNumber);
           }
       }
       
       System.debug('Account Id ' + cNumber);
      
       for(case c : [select CaseNumber, Id, Type, Status, Subject from case where Sold_To_Account__c!= null and Sold_To_Account__c=:accId and CaseNumber IN :cNumber Order by lastmodifiedDate desc LIMIT 10]){
            caselist.add(new casewrapper(Integer.ValueOf(c.CaseNumber), c, true));
       }
       
       return caseList;
   }
   
   
    public PageReference getSelected(){
        selectedcases.clear();
        
        System.debug(' ** objFeedbackloop.Cases__c >>> ' + caselist.size());
        
        Set<String> Seltedcase = new Set<String>();
         
        for(casewrapper csswrapper : caselist){
            if(csswrapper.selected == true){
             selectedcases.add(csswrapper.css);
             Case cs = csswrapper.css; 
               Seltedcase.add(cs.CaseNumber);
            }
        }
        
        System.debug(' ** objFeedbackloop.Cases__c >>> ' + Seltedcase);
         
        if(objFeedbackloop.Cases__c!=null){ 
            objFeedbackloop.Cases__c=null;
            for(String cn:Seltedcase){
             if(objFeedbackloop.Cases__c!=null) objFeedbackloop.Cases__c = objFeedbackloop.Cases__c  +','+ cn; else objFeedbackloop.Cases__c = cn;
            } 
        }else{
           for(String cn:Seltedcase){
             if(objFeedbackloop.Cases__c!=null) objFeedbackloop.Cases__c = objFeedbackloop.Cases__c  +','+ cn; else objFeedbackloop.Cases__c = cn;
           } 
        }
        
        System.debug('objFeedbackloop.Cases__c' +objFeedbackloop.Cases__c);
         
        if(objFeedbackloop.Id!=null) update objFeedbackloop;
        return null;
    }
    
    public PageReference save() 
    {
        selectedcases.clear();
        
        System.debug('Details Information: :: '+caselist );
        
        for(casewrapper csswrapper : caselist){
            if(csswrapper.selected == true){
                selectedcases.add(csswrapper.css);
                Case cs = csswrapper.css; 
                if(objFeedbackloop.Cases__c!=null) objFeedbackloop.Cases__c = objFeedbackloop.Cases__c +','+ cs.CaseNumber; else objFeedbackloop.Cases__c = cs.CaseNumber;
            }
        }
        
        System.debug('Details Information: :: '+caselist );
        
        System.debug('Details Information: '+objFeedbackloop.Cases__c );
        
        if(!objFeedbackloop.Submitted__c){
            objFeedbackloop.Submitted__c = true;
            AssignEmail(objFeedbackloop);
            update objFeedbackloop;
            objFeedbackloop =getSMartFeedBack(objFeedbackloop.Id);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your Feedback has now been saved and the details have been sent to the solutions team for review. Thankyou.'));    
             
        }else{
            update objFeedbackloop;
            objFeedbackloop =getSMartFeedBack(objFeedbackloop.Id);
        }
            return null;
    }
    
    
    public List<Case> getSelectedCases(){
        if(selectedcases.size()>0)
            return selectedcases;
        else
        return null;
    }  
    
    public SMART_Feedback__c getSMartFeedBack(String FId){ 
      List<SMART_Feedback__c>  objFeedbackloop = new List<SMART_Feedback__c>([select Id, Name, isEmailSent__c, Use_Case_Name__c, Assigned_To__c, Cases__c, Opportunity__c, Submitted__c, 
                                              Product_Details__c, 
                                              Use_Case_Id__c, Root_cause_of_Issue__c,  
                                             Sold_To_Account__c, Product_Category__c, 
                                             Product_Feedback_Category__c,
                                             Product_Feedback_Type__c, 
                                             Product_or_Use_Case__c, 
                                             Product_Categories__c, Submitter__c, 
                                            Use_Case_Feedback_Type__c, Disposition_Status__c, Disposition_Date__c, 
                                            Disposition_Comment__c,
                                             Use_Cases__c, User_Comments__c, What_is_your_suggestion_for_improvement__c,
                                             Use_Case_Brief_Description__c, 
                                             Anticipated_Benefits__c, DSR_Use_Case__c,Idea_Title__c,Attachment__c from SMART_Feedback__c where Id=:FId limit 1]);
      if(objFeedbackloop.size()>0)
          return   objFeedbackloop[0];
      else
          return null;    
    }

    public List<SelectOption> getAnticipatedValues()
    {
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('--Select--','--Select--'));
      Schema.DescribeFieldResult fieldResult = SMART_Feedback__c.Anticipated_Benefits__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
      }      
      options.sort(); 
      return options;
    }

    /*
      Assigned Methods 
    */
    
    public PageReference dummyMethod() {  
        system.debug(' [ objFeedbackloop.Product_or_Use_Case__c ] ' + objFeedbackloop.Product_or_Use_Case__c); 
        objFeedbackloop.Product_or_Use_Case__c   =reqType ;
        objFeedbackloop.Product_Feedback_Type__c =null;
        return null;
    }
    
    public PageReference queryRequestorInfo() {  
       system.debug(' [ objFeedbackloop.Use_Case_Feedback_Type__c ]' + objFeedbackloop.Use_Case_Feedback_Type__c); 
       objFeedbackloop.Use_Case_Feedback_Type__c = strRequestor ;
       return null;
    }
    
    public PageReference feedbackInfo() {  
       objFeedbackloop.Use_Case_Feedback_Type__c = strFeedbackRequestor ;
       return null;
    }
    
    public PageReference solutionFeedbackTypeInfo() {  
       objFeedbackloop.Product_Feedback_Type__c = solutionFeedbackType ;
       return null;
    }
    
    public PageReference Sol() {  
       objFeedbackloop.Product_Category__c= solutionchange;
       return null;
    }
    
    public PageReference Pro() {  
       objFeedbackloop.Product_Details__c = productchange;
       return null;
    }
    
    public PageReference UpdateCommmentsPopulated() { 
       objFeedbackloop.User_Comments__c = strCommVa ; 
       return null;
    }

    public PageReference UpdateIdeaTitle() { 
       objFeedbackloop.Idea_Title__c =strIdeaTitle;
       return null;
    }  
    
    public PageReference UpdateIdeaComments() { 
       objFeedbackloop.Use_Case_Brief_Description__c=strIdeaComments;
       return null;
    }  

    public PageReference UpdateBenefits() { 
      System.debug('>strIdeaAntiBenefits strIdeaAntiBenefits>>'+strIdeaAntiBenefits);
       objFeedbackloop.Anticipated_Benefits__c = strIdeaAntiBenefits;
       return null;
    }  

    public PageReference UpdateDispositionComment() { 
       objFeedbackloop.Disposition_Comment__c = strDispositionComment;
       return null;
    }  

    public PageReference UpdateDispositionDate() { 
       objFeedbackloop.Disposition_Date__c = strDispositionDate;
       return null;
    }  

    public PageReference UpdateDispositionStatus() { 
      System.debug('>>>'+objFeedbackloop.Disposition_Status__c);
       objFeedbackloop.Disposition_Status__c = strDispositionStatus;
       return null;
    }  
    
    public PageReference UpdateAssignedTo() { 
         System.debug('>>>>>>>>>>>>>>>>' +strAssignedTo.length());
      if(strAssignedTo.length()>0){
          List<User> userlist          = new List<User>([select id, UserName, name from User where Name=:strAssignedTo and isActive=true limit 1]);  
          if(userlist.size()>0)
          objFeedbackloop.Assigned_To__c= userlist[0].Id;
      }else{
          objFeedbackloop.Assigned_To__c =null;
      }
      update objFeedbackloop;
      objFeedbackloop =getSMartFeedBack(objFeedbackloop.Id);
      System.debug('>>>>>>>>>>>>>>>>&&& ' +objFeedbackloop.Assigned_To__c);
      return null;
    }
    
     public PageReference FeedbkCategory() { 
        objFeedbackloop.Product_Feedback_Category__c = strFeedbackCategory ; 
        return null;
    }
    
    public PageReference UpdatedRtCause(){
        objFeedbackloop.Root_cause_of_Issue__c= strupdatedrootComments;
        return null;
    } 
    
    public PageReference UpdateSuggestionforImp(){
        objFeedbackloop.What_is_your_suggestion_for_improvement__c= strupdaterootComments;
        return null;
    } 
}