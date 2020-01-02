public class LicenseRequestWebFormController {

   public String title {get; set;}	        
   public License_Request__c licReq {get; set;}
   public String confirmedEmail {get; set;}
   public String requestNum {get; set;}   
   public String attName {get;set;} 
   public String reqSource {get; set;}
   public Attachment attachmnt {get; set;}
    
   ///Visibility Flags   
   public Boolean showPageStep1 {get; set;}
   public Boolean isAFRtype {get; set;}
   public Boolean fileCatPpu {get; set;}
   public Boolean fileCatGenesys {get; set;} 
   public Boolean fileThrdPrt {get; set;}  
   ///  
   public Boolean showDeplType {get; set;} 
   public Boolean showImplType {get; set;}
   public Boolean showClarifyReqGenericPrompt {get; set;}
   public Boolean showOS {get; set;}
   public Boolean showPBX {get; set;}
   public Boolean showSoPo {get; set;}
   public Boolean showPrimHost {get; set;}
   public Boolean showBackHost {get; set;}
   public Boolean showExtDate {get; set;}
   public Boolean showThrdParAF {get; set;}
   public Boolean showIvrConfig {get; set;}
   public Boolean showExprDate {get; set;}
   public Boolean showPrimBcDr {get; set;}
   public Boolean showBackBcDr {get; set;}
   public Boolean showPortType {get; set;}
   
   public String selectedGenImplType {get; set;}
   public String selectedGenDeplType {get; set;}
   public String selectedImplType {get; set;}
   public String selectedDeplType {get; set;}
   
   private Map<String, Boolean> visflg;
   private String ownId;
   private String GENERIC_ERROR = 'We encountered an error processing your request. Please try again or contact your regional Licensing Analyst.';
      
   public LicenseRequestWebFormController(ApexPages.StandardController stdController) {
             licReq = new License_Request__c();
             attachmnt = new Attachment();
         
             resetVsibFlags();
 
             licReq.First_Name__c = ApexPages.currentPage().getParameters().get('fnm');               
             licReq.Last_Name__c = ApexPages.currentPage().getParameters().get('lst'); 
             licReq.Corporate_Email__c =  ApexPages.currentPage().getParameters().get('em'); 
             licReq.Submitted_End_User__c = ApexPages.currentPage().getParameters().get('eusr'); 
             licReq.Sold_To_Account__c = ApexPages.currentPage().getParameters().get('sldto'); 
             licReq.Submitted_Employer__c = ApexPages.currentPage().getParameters().get('empl'); 
             licReq.GARN_Code__c = ApexPages.currentPage().getParameters().get('garn');  
             reqSource = ApexPages.currentPage().getParameters().get('src'); 
                                                              
             confirmedEmail = licReq.Corporate_Email__c; 
             showPageStep1 = true; 
             
             /*** LMS entry point ***/
             title = '';
             String lmstype = ApexPages.currentPage().getParameters().get('reqtp');
             if ( lmstype != null && lmstype.equals('Qst') ){
                 licReq.Request_Type__c = 'Question';   
                 title = 'Activation File Related Question';
             } else if ( lmstype != null && lmstype.equals('AFR') )  {
             	 licReq.Request_Type__c = 'Activation File Request';
             	 licReq.License_File_Category__c = 'Third Party Activation File';
             	 title = 'Third-Party Activation File Request';
             	 resetFileType(); 
             }                                             
    }
  
  public void submitRequest() {
        if ( ! fieldValidations() )
           return;
 
        try {
            assignFieldValues();
            upsert licReq;
        }
        catch (DmlException e) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, GENERIC_ERROR));
           return;
        } 
                
        ///assuming still here
        if ( licReq.Id != null ) {
             List<License_Request__c> reqsts = [SELECT Name FROM License_Request__c WHERE Id = :licReq.Id];
             
             if ( !reqsts.isEmpty() )  {
                requestNum = reqsts[0].Name;          
                ///reset owner if have one, on error do nothing - will stay as default system assigned owner
                if ( String.isNotBlank(ownId) ) {
                    try {
                        licReq.OwnerId = ownId;
                        update licReq;
                    }
                    catch(Exception ex) {}
                } 
             }
        }
        
        if ( String.isBlank(requestNum) ) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, GENERIC_ERROR));
           return;
        }
        
        showPageStep1 = false; 
        return;  
  }
  
  private void assignFieldValues() {
      /// if GARN provided
      if ( String.isNotBlank(licReq.GARN_Code__c) ) {
        List<Account> accnts = [SELECT Name, Id, Region__c, Country__r.Name, RecordType.DeveloperName FROM Account WHERE SAP_Account_Code__c= :licReq.GARN_Code__c AND Status__c ='Active'];        
        if ( !accnts.isEmpty() ) {
             String customerId;
             String partnerId;
             for ( Account act : accnts ) {
                if ( act.RecordType.DeveloperName == 'EMGCustomerRecordType')
                    customerId = act.Id;
                if ( act.RecordType.DeveloperName == 'EMGBusinessPartnerRecordType')
                    partnerId = act.Id;
             }      
             if ( String.isNotBlank(customerId) )
                 licReq.End_User__c = customerId;
             else if ( String.isNotBlank(partnerId) )
                 licReq.End_User__c = partnerId;

             if ( licReq.End_User__c != null ) 
               ownId = getOwner(accnts, licReq.End_User__c);                 
          }
       } /// GARN
     /// Record Type
      List<RecordType> rectype = [SELECT Id FROM RecordType WHERE SobjectType = 'License_Request__c' AND DeveloperName = 'Editable'];
      if ( !rectype.isEmpty() )
           licReq.RecordTypeId = rectype[0].Id;
     
      licReq.Status__c = 'Open';
      licReq.Sub_Status__c = 'New';
      licReq.Source__c = 'WEB ' + reqSource;
      
      ///clear fields that were not visible when the form was submitted
      ///Activation File
       licReq.License_File_Category__c = isAFRtype ? licReq.License_File_Category__c : null;
       licReq.License_File_Type__c = isAFRtype ? licReq.License_File_Type__c : null;
       licReq.Urgent__c = isAFRtype ? licReq.Urgent__c : false;  
       licReq.Please_Clarify_Your_Request__c = isAFRtype ? licReq.Please_Clarify_Your_Request__c : null;       
       ///PPU
       licReq.Environment_Type__c = fileCatPpu ? licReq.Environment_Type__c : null;
       licReq.Expiration_Date_of_the_Hosting_Contract__c = fileCatPpu ? licReq.Expiration_Date_of_the_Hosting_Contract__c : null;
       licReq.Max_Number_of_Estimated_Ports__c = fileCatPpu ? licReq.Max_Number_of_Estimated_Ports__c : null;
       ///Genesys and Third Party
       licReq.License_Request_Type__c = showImplType ? selectedGenImplType : null;
       licReq.Deployment_Type__c = showDeplType ? selectedGenDeplType : null;
       licReq.SO_or_PO__c = showSoPo ? licReq.SO_or_PO__c : null;
       licReq.PBX_SIP__c = showPBX ? licReq.PBX_SIP__c : null;
       licReq.O_S__c = showOS ? licReq.O_S__c : null;
       licReq.MAC_ID_or_Host_ID__c = showPrimHost ? licReq.MAC_ID_or_Host_ID__c : null;
       licReq.Backup_MAC_ID_or_Host_ID__c = showBackHost ? licReq.Backup_MAC_ID_or_Host_ID__c : null;
       licReq.Extension_Date__c = showExtDate ? licReq.Extension_Date__c : null;
       licReq.Third_Party_Activation_File_Type__c = showThrdParAF ? licReq.Third_Party_Activation_File_Type__c : null;
       licReq.IVR_Configuration__c = showIvrConfig ? licReq.IVR_Configuration__c : null;
       licReq.Expiration_Date__c = showExprDate ? licReq.Expiration_Date__c : null;
       licReq.Primary_MAC_ID_BC_DR__c = showPrimBcDr ? licReq.Primary_MAC_ID_BC_DR__c : null;
       licReq.Backup_MAC_ID_BC_DR__c = showBackBcDr ? licReq.Backup_MAC_ID_BC_DR__c : null;
       licReq.Port_Type__c = showPortType ? licReq.Port_Type__c : null;
       
  }
    
  private String getOwner(List<Account> accnts, Id euId) {
     if ( euId == null || accnts.isEmpty() )
        return null;
      
     Map<Id, Account> acctmap = new Map<Id, Account>(accnts) ;
     String country = acctmap.get(euId).Country__r.Name;
     String region = acctmap.get(euId).Region__c;

     if ( String.isBlank(region) && String.isBlank(country) )
        return null;
        
     List<Licensing_Analyst__c> licAnalists = [SELECT APAC_Analyst_UserId__c, Canada_Analyst_UserId__c, EMEA_Analyst_UserId__c, US_Analyst_UserId__c,
                                                      LATAM_Analyst_UserId__c, North_America_Analyst_UserId__c, Russia_Analyst_UserId__c
                                               FROM  Licensing_Analyst__c];
     String ownerId;                                          
     if ( !licAnalists.isEmpty() ) { 
        //country
         if ( country == 'United States')
            ownerId = licAnalists[0].US_Analyst_UserId__c;
         else if ( country == 'Canada')
             ownerId = licAnalists[0].Canada_Analyst_UserId__c;
         else if ( country == 'Russian Fed.')
              ownerId = licAnalists[0].Russia_Analyst_UserId__c;
        //region      
         else if ( region == 'APAC' )
               ownerId = licAnalists[0].APAC_Analyst_UserId__c;
         else if ( region == 'EMEA' )
               ownerId = licAnalists[0].EMEA_Analyst_UserId__c;
          else if ( region == 'LATAM' )
               ownerId = licAnalists[0].LATAM_Analyst_UserId__c;
          else if ( region == 'North America' )
               ownerId = licAnalists[0].North_America_Analyst_UserId__c;
     }
     return ownerId; 
  }
  
  public void resetFileType() {
      licReq.License_File_Type__c = null;
      resetVsibFlags();
      return;
  }
  
  public PageReference upload() {
    attachmnt.Name = attName;
    attachmnt.ParentId = licReq.Id; 

    if ( attachmnt.Name == null ) {
       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a File to Upload.'));
       return null;
    }
    
    try {
         insert attachmnt;
         
    } catch (DMLException e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
          return null;
    } finally {
            attName = '';
            attachmnt = new Attachment(); 
    }
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
    return null;
  }
  
  public List<Attachment> attachmList {
      get{  
         List<Attachment> lst = new List<Attachment>();     
         lst = [SELECT Name FROM Attachment WHERE ParentId =: licReq.Id];
         return lst;
      }
      set;
  }
    
  public void resetVsibFlags() {
        visflg = LicenseRequestWebFormSelections.visiblFlags(licReq.Request_Type__c, licReq.License_File_Category__c, licReq.License_File_Type__c);
 
        isAFRtype = visflg.get('isAFRtype');
  /// File Category
        fileCatPpu = visflg.get('fileCatPpu');
        fileCatGenesys = visflg.get('fileCatGenesys');
        fileThrdPrt = visflg.get('fileThrdPrt');  
  // Genesric prompt for the Clarify Request text box       
       showClarifyReqGenericPrompt = visflg.get('showClarifyReqGenericPrompt');  
       
       showDeplType = visflg.get('showDeplType');
       showImplType = visflg.get('showImplType');
       showOS = visflg.get('showOS');
       showPBX = visflg.get('showPBX');
       showSoPo = visflg.get('showSoPo');
       showPrimHost = visflg.get('showPrimHost');
       showBackHost = visflg.get('showBackHost');
       showExtDate = visflg.get('showExtDate');
       showThrdParAF = visflg.get('showThrdParAF');
       showIvrConfig = visflg.get('showIvrConfig');
       showExprDate = visflg.get('showExprDate');
       showPrimBcDr = visflg.get('showPrimBcDr');
       showBackBcDr = visflg.get('showBackBcDr');
       showPortType = visflg.get('showPortType');
    }
        
    public List<SelectOption> implOptions {
        get {
              return LicenseRequestWebFormSelections.implmnts(licReq.License_File_Category__c, licReq.License_File_Type__c);
        }       
        set;
    }
    
  public List<SelectOption> deplOptions {
        get {
             return LicenseRequestWebFormSelections.deplmnts(licReq.License_File_Type__c);
        }       
        set;
    }
    
  public PageReference startNewReq() {
    ///called from the form
        PageReference pr = new PageReference('/ActivationFileRequest');
        pr.getParameters().put('fnm', licReq.First_Name__c);
        pr.getParameters().put('lst', licReq.Last_Name__c);
        pr.getParameters().put('em', licReq.Corporate_Email__c);
        return pr;
  }
  
  public PageReference newReqInternal() {
    ///called from Internal landing page, LicenseReqLandingInternal
        PageReference pr = new PageReference('/ActivationFileRequest');
        pr.getParameters().put('fnm', licReq.First_Name__c);
        pr.getParameters().put('lst', licReq.Last_Name__c);
        pr.getParameters().put('em', licReq.Corporate_Email__c);
        pr.getParameters().put('eusr', licReq.Submitted_End_User__c);
        pr.getParameters().put('garn', licReq.GARN_Code__c);  
        pr.getParameters().put('empl',licReq.Submitted_Employer__c);
        pr.getParameters().put('src', 'intrn');
        
        return pr;
  }
  
  public void pageEdit () {
  	 showPageStep1 = true;
  }
  
  private Boolean fieldValidations() {
  	    if ( String.isBlank(licReq.First_Name__c) || String.isBlank(licReq.Last_Name__c) || String.isBlank(licReq.Request_Type__c) ) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter values into all the fields indicated in Red.'));
            return false;
        }
        
        if ( String.isBlank(licReq.Corporate_Email__c) || String.isBlank(confirmedEmail) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter your corporate email address. You will need to confirm it by entering it a second time.'));
            return false;
        }
        else if ( !licReq.Corporate_Email__c.equalsIgnoreCase(confirmedEmail) ) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'The email addresses you entered do not match. Please enter them again.'));
           return false;
        }
        
        if ( licReq.Date_Needed__c != null && licReq.Date_Needed__c < date.today() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Date Needed cannot be in the past. Please re-enter the Date Needed.'));
           return false;
        }
        
        if ( showExtDate && licReq.Extension_Date__c != null && licReq.Extension_Date__c < date.today() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'New Extension Date Requested cannot be in the past. Please re-enter the New Extension Date Requested.'));
           return false;
        }
        
        if ( licReq.Urgent__c == true && ( licReq.Date_Needed__c == null || String.isBlank(licReq.Date_Reasoning__c) )) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please provide Date Needed and the Date Reasoning.'));
           return false;
        }
        
        if ( showExtDate && licReq.Extension_Date__c == null ) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please provide the New Extension Date Requested.'));
           return false;
        } 
        
        return true;      
  }
  
}