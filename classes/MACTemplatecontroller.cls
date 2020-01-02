/*
   Test class: MACTemplatecontrollertest
*/
public class MACTemplatecontroller {

    /************** Variable for MAC Type Picklist From case object *************/
    public list<SelectOption> listMacType { get; set; }
    public String MACType { get; set; }

    /************** Variable declaration for 01.Add A User & 02.Delete Existing User *************/

    public string UserID{get; set;}
    public string FirstName{get; set;}
    public string LastName{get; set;}
    public string Extension{get; set;}    
    public string Password{get; set;}
    public string SelfActivation{get; set;}
    public string MaximumCalls{get; set;}
    public string MaximumChats{get; set;}
    public string UserToMimicAdditionalSettings{get; set;}
    public string WorkgroupMembership{get; set;}      
    public string AdditionalInstructions{get; set;} // reusing for many place   07,08,16
    public string userExtension{get; set;} 
    
    /************ 03.Modify Existing User PageBlocksection *********/
    public string CurrentUserID{get; set;} 
    public string CurrentUserFirstName{get; set;} 
    public string CurrentUserLastName{get; set;} 
    public string CurrentUserExtension{get; set;}
    public string UserNewFirstName{get; set;}
    public string UserNewLastName{get; set;}
    public string UserNewExtension{get; set;}
    public string UserNewPassword{get; set;}
    public string WorkgroupAction{get; set;}
    public string WorkgroupChanges{get; set;}
    public string NewUserMaximumCalls{get; set;}
    public string NewUserMaximumChats{get; set;}
    public string ModifyUserAdditionalInstructions{get; set;}
    public string UserSelfActivation {get; set;}
    

    /************Variable declaration for 03.Modify Existing User***********/
    public string userFirstNameMod{get; set;} 
    public string userLastNameMod{get; set;} 
    public string userIDUniqueMod{get; set;} 
    public string userExtensionMod{get; set;} 

    /************** Variable declaration 04.Add A New Workgroup***********/
    public string WorkgroupName{get; set;}
    public string WorkgroupHasQueue{get; set;}
    public string WorkgroupExtension{get; set;}
    public string WorkgroupMaxCalls{get; set;}
    public string WorkgroupMaxChats{get; set;}
    public string WorkgroupToMimicAdditionalSettings{get; set;}
    public string WorkgroupMembers{get; set;}
    public string WorkgroupAdditionalInstructions{get; set;}

    /************** Variable declaration 05.Modify Existing Workgroup***********/
    public string ModifyWGName{get; set;}
    public string NewWorkgroupExtension{get; set;}
    public string NewWorkgroupHasQueue{get; set;}    
    public string WorkgroupUserAction{get; set;}
    public string WorkgroupUsers{get; set;}
    public string NewWorkgroupAdditionalInstructions{get; set;}

    /************** Variable declaration06.Create new Managed Phone/Station***********/
    public string MACAddressOfPhone{get; set;}
    public string Manufacturerofphone {get; set;}
    public string PhoneModel{get; set;}
    public string ComputerName{get; set;}
    public string LocationOfPhone{get; set;}
    public string PhoneName{get; set;}
    public string Language{get; set;}
    public string ExtensionForPhone{get; set;}
    public string NumOfLineKeys{get; set;}
    public string EnableMWI{get; set;}
    /************** Variable declaration 07.DID/DNIS Table Modification ***********/
    public string DID{get; set;}
    public string UserWorkgroupPhoneAssignedTo{get; set;}

    /************** Variable declaration 08.Wav File Upload ***********/
    public string LanguageFolderForFilesToBePlacedIn{get; set;}
    public string OverwriteDuplicateFiles{get; set;}

    /************** Variable declaration 09.TSRA Add User & 10.TSRA Password Reset & 11.TSRA User Deletion ***********/
    public string UserName{get; set;}  // used in 09,10,11
    public string UserEmail{get; set;} // used in 09,10,11
    public string UserToMirrorAccessAfter{get; set;}

    /************** Variable declaration 12.Attendant Modification & 13.Attendant Add New Profile/Schedule &14.Scheduled Report Modification &15.Schedule Reports Add/Delete User***********/
    public string ProfileName{get; set;}
    public string ScheduleName{get; set;}
    public string ModificationRequest{get; set;} //used in 13 and 20 & 19
    public string DNIS{get; set;}
    public string TimeZone{get; set;}
    public string IsUnplannedSchedule{get; set;}
    public string ScheduleRunTimeDays{get; set;}
    public string ScheduleGreetingWavFile{get; set;}
    public string MenuOptions{get; set;}     
    public string DesiredCallFlow{get; set;}
    public string ReportName{get; set;} //for14
    public string AddDelete{get; set;}//for15

    /************** Variable declaration 16.Add Schedule Report  ***********/
    public string NameOfReport{get; set;}
    public string FilterType{get; set;}
    public string ReportType{get; set;}
    public string ReportDelivery{get; set;}
    public string TimeRange{get; set;}
    public string RecipientEmail{get; set;}
    public string ReportParametersToAdd{get; set;}

    /************** Variable declaration 17.Toll Free Number Add & 18.Toll Free Number Remove & 19.Toll Free Number Modification ***************/
    public string AmountOfNumbersRequested {get; set;} // used in 17, 21
    public string NumberRangePreferred{get; set;}
    public string NumberToBeRemoved{get; set;}
    public string AttendantProfileNames{get; set;}
    public string NumberNeedingModification{get; set;}
    /************** Variable declaration  20.Other MAC Request ***************/
    public string PhoneNumber{get; set;}
    public string MACRequest{get; set;}
    public string Title{get; set;}
    
    /************** Variable declaration 21.DID Number Add ***************/
    public string AreaCodePreferred {get; set;}
    public string AdditionalInformation {get; set;}
  
    public boolean error {get;set;} 
    
    public Case cs {get; set;}
    public String caseType {get; set;}
    private String recordTypeId;
 
 
   public MACTemplatecontroller() {}
 
   public MACTemplatecontroller(ApexPages.StandardController stdController) {
         recordTypeId = ApexPages.currentPage().getParameters().get('RecordType'); 
                 
          if ( String.isNotBlank(recordTypeId) )
                caseType = CaseUtil.getAllTScaseTypesMap().get(recordTypeId).DeveloperName;
                 
          String contId = ApexPages.currentPage().getParameters().get('contId'); 
          String stId = ApexPages.currentPage().getParameters().get('stId');
          String euId = ApexPages.currentPage().getParameters().get('euId');  
                 
          try {
                     CaseService.caseInstance caseinst = new CaseService.caseInstance(recordTypeId);
                     cs = caseinst.cs;
        
                     cs.ContactId = contId;         
                     cs.End_User_Account__c = euId;
                     cs.Sold_To_Account__c = stId;
                     cs.AccountId = euId;
                     cs.Business_Impact_Product__c= 'N/A';
                     
                     cs.Product_Support_Group__c = 'PureConnect MAC';
                     cs.Problem_Sub_Type__c = 'PureConnect MAC';
                    
                     /// Support Product
                     List<Support_Product__c> prdlst = [SELECT Id FROM Support_Product__c WHERE Product_Name__c = 'MAC Request' AND Product_Type__c = 'Product'];
                     if ( !prdlst.isEmpty() )
                        cs.Support_Product__c = prdlst[0].Id;
                   
                     if ( caseType == 'Genesys_Cloud_Service_Request' )  
                         initCloudCase();
                     else if ( caseType == 'Premises_Service_Request')
                         initPremCase();  
   
              }
              catch (Exception ex) {
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to create a Case. Additional details: ' + ex.getMessage() );
                 ApexPages.addMessage(msg);  
              }            
    }
    
  public PageReference initCloudCase() {
                String deplId = ApexPages.currentPage().getParameters().get('dplId');
                cs.Cloud_Deployment__c = deplId;
                                
                 /// Cloud Service
                  List<Support_Product__c> prdlst = [SELECT Id FROM Support_Product__c WHERE Product_Name__c = 'PureConnect Cloud' AND Product_Type__c = 'Cloud Service'];
                     if ( !prdlst.isEmpty() )
                        cs.Cloud_Service__c = prdlst[0].Id;
                                                   
                return null;
        }
        
   public PageReference initPremCase() { 
   
          String boaId = ApexPages.currentPage().getParameters().get('boaId');                                                           
          cs.Back_Office_Account__c = boaId;
   
           return null;       
      }
      
      public PageReference saveCase() {  
         try { 
                 cs.Subject = 'MAC Requested: ' + cs.MAC_Type_PureCnct__c;
                 insert cs;
            }
           catch  (Exception ex) {
                   ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to create a Case. Additional details: ' + ex.getMessage() );
                   ApexPages.addMessage(msg); 
                   return null;
          }
        
          PageReference pr;               
  
           if ( caseType.startswith('Genesys_Cloud_') )
                  pr = new PageReference('/customercare/CaseDetailCloudPortal?id=' + cs.id);
            else
                  pr = new PageReference('/customercare/CaseDetail?id=' + cs.id);   
                            
            return pr; 
      }
        
    private String format(Map<String, String> inputVls) {
        String formatted = 'MAC Requested: ' + cs.MAC_Type_PureCnct__c + '\n\n';
        
        for ( String name : inputVls.keySet() )  
                formatted += name + ': ' + inputVls.get(name) + '\n';                 
        
        return formatted;       
    }

    public PageReference submitPage() {
        if ( String.isBlank(cs.MAC_Type_PureCnct__c) ) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please populate all required fields.'));
            return null;
        }
        
        cs.Description = '';
        Boolean validated = false;
        
        if ( cs.MAC_Type_PureCnct__c == 'Add A User')
            validated = getvalueaddUser();
        else if ( cs.MAC_Type_PureCnct__c == 'Delete Existing User' )
             validated = getvaluedeleteUser();
        else if ( cs.MAC_Type_PureCnct__c == 'Modify Existing User' )
            validated = getvalueModifyUser();
        else if ( cs.MAC_Type_PureCnct__c == 'Add A New Workgroup' )
             validated = getvalueAddWorkgroup();
        else if ( cs.MAC_Type_PureCnct__c == 'Modify Existing Workgroup' )
             validated = getvalueModifyWorkgroup();
        else if ( cs.MAC_Type_PureCnct__c == 'Create new Managed Phone/Station' )
             validated = getManagedPhoneStation();
        else if ( cs.MAC_Type_PureCnct__c == 'DID/DNIS Table Modification' )
             validated = getDIDDNISModification();
        else if ( cs.MAC_Type_PureCnct__c == 'Wav File Upload' )
             validated = getWaveFileUpload();
        else if ( cs.MAC_Type_PureCnct__c == 'TSRA Add User' )
             validated = getTSRAAddUser();
        else if ( cs.MAC_Type_PureCnct__c == 'TSRA Password Reset' )
             validated = getTSRAPwdReset();
        else if ( cs.MAC_Type_PureCnct__c == 'TSRA User Deletion' )
             validated = getTSRAUsrDel();
        else if ( cs.MAC_Type_PureCnct__c == 'Attendant Modification' )
             validated = getAttendantModification();
        else if ( cs.MAC_Type_PureCnct__c == 'Attendant Add new profile/schedule' )
             validated = getAttendantAddProfile();
        else if ( cs.MAC_Type_PureCnct__c == 'Scheduled Report Modification' )
                 validated = getSchldRptModification();
        else if ( cs.MAC_Type_PureCnct__c == 'Scheduled Reports Add/Delete User' )
             validated = getSchldRptAddDeleteUser();
        else if ( cs.MAC_Type_PureCnct__c == 'Add Scheduled Report' )
             validated = getAddSchldReportr();
        else if ( cs.MAC_Type_PureCnct__c == 'Toll Free Number Add' )
             validated = getTollFreeNumberAdd();
        else if ( cs.MAC_Type_PureCnct__c == 'Toll Free Number Remove' )
             validated = getTollFreeNumberRemove();
        else if ( cs.MAC_Type_PureCnct__c == 'Toll Free Number Modification' )
             validated = getTollFreeNumberModify();
        else if ( cs.MAC_Type_PureCnct__c == 'Other MAC Request')
            validated = getOtherMACRequest();
        else if ( cs.MAC_Type_PureCnct__c == 'DID Number Add')
            validated = getDIDNumbersAdd();
        else 
            return null; 
        
        if ( ! validated )  { 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please populate all required fields.'));
            return null;
        }

        return saveCase();
    }
    
    public Boolean getvalueaddUser() {

         if ( String.isNotBlank(FirstName) &&  String.isNotBlank(LastName) && String.isNotBlank(UserID) && 
              String.isNotBlank(Password) && String.isNotBlank(Extension) && String.isNotBlank(SelfActivation) && 
              String.isNotBlank(MaximumCalls) && String.isNotBlank(MaximumChats) && String.isNotBlank(UserToMimicAdditionalSettings) && 
              String.isNotBlank(WorkgroupMembership) )  {
                        
                 Map<String, string> inputs = new Map<String, string>();
                 inputs.put('User First Name', FirstName);
                 inputs.put('User Last Name', LastName);
                 inputs.put('User ID', UserID);
                 inputs.put( 'User Password', Password);
                 inputs.put('User Extension', Extension);
                 inputs.put('User can activate self?', SelfActivation);
                 inputs.put('Maximum Calls ', MaximumCalls);
                 inputs.put('Maximum Chats',  MaximumChats);
                 inputs.put('User to mimic additional settings after', UserToMimicAdditionalSettings);
                 inputs.put('Workgroup Membership', WorkgroupMembership);
                 inputs.put('Additional Instructions Regarding This MAC/User', AdditionalInstructions);
                 
                 cs.Description = format(inputs);                
         }
         else    
                  return false;
 
         return true;             
    }

    public Boolean getvaluedeleteUser(){

        if( String.isNotBlank(FirstName) && String.isNotBlank(LastName) && String.isNotBlank(UserID) && String.isNotBlank(Extension) ) {

                  Map<String, string> inputs = new Map<String, string>();        
                  inputs.put('User First Name', FirstName);
                  inputs.put('User Last Name', LastName);
                  inputs.put('User ID', UserID);
                  inputs.put('User Extension', Extension);
        
                 cs.Description = format(inputs);                
         }
         else    
                  return false;
 
         return true;         
    }
    
    public Boolean getvalueModifyUser(){
        
        if ( String.isNotBlank(CurrentUserFirstName) && String.isNotBlank(CurrentUserLastName) && String.isNotBlank(CurrentUserID) && 
             String.isNotBlank(CurrentUserExtension) ) {
    
             Map<String, string> inputs = new Map<String, string>();     
                 inputs.put('User First Name', CurrentUserFirstName);
                 inputs.put('User Last Name', CurrentUserLastName);
                 inputs.put('User ID', CurrentUserID);
                 inputs.put('User Externsion', CurrentUserExtension);
                 inputs.put('User New First Name', UserNewFirstName);
                 inputs.put('User New Last Name', UserNewLastName);
                 inputs.put('User New Password', UserNewPassword);
                 inputs.put('User New Extension', UserNewExtension);
                 inputs.put('User Can Activate Self',  UserSelfActivation);
                 inputs.put('New User Maximum Calls', NewUserMaximumCalls);
                 inputs.put('New User Maximum Chats', NewUserMaximumChats);
                 inputs.put('Workgroup Action', WorkgroupAction);
                 inputs.put('Workgroups', WorkgroupChanges);
                 inputs.put('Additional Instructions regarding this user modification',  ModifyUserAdditionalInstructions);
                 cs.Description = format(inputs);                
         }
         else    
                  return false;
 
         return true;         
    }

    public Boolean getvalueAddWorkgroup(){ 

        if ( String.isNotBlank(WorkgroupName) && String.isNotBlank(WorkgroupHasQueue) ){
                
                Map<String, string> inputs = new Map<String, string>();     
                 inputs.put('Workgroup Name', WorkgroupName);   
                 inputs.put('Workgroup is Callable (Has Queue)', WorkgroupHasQueue);
                 inputs.put('Workgroup Extension', WorkgroupExtension);
                 inputs.put('Max Calls Per User', WorkgroupMaxCalls);
                 inputs.put('Max Chats Per User', WorkgroupMaxChats);
             inputs.put('Workgroup to mimic additional settings after', WorkgroupToMimicAdditionalSettings);
             inputs.put('Add these users to this workgroup', WorkgroupMembers);
             inputs.put('Additional instructions regarding this workgroup add', WorkgroupAdditionalInstructions);
                 cs.Description = format(inputs);                
         }
         else    
                  return false;
 
         return true;         
    }

    public Boolean getvalueModifyWorkgroup(){

        if ( String.isNotBlank(ModifyWGName) ) {
                
           Map<String, string> inputs = new Map<String, string>(); 
           inputs.put('Current Workgroup Name', ModifyWGName);
           inputs.put('New Workgroup Extension', NewWorkgroupExtension);
           inputs.put('Workgroup Is Callable (Has Queue)', NewWorkgroupHasQueue);
           inputs.put('Workgroup Max Calls', WorkgroupMaxCalls);
           inputs.put('Workgroup Max Chats', +WorkgroupMaxChats);
           inputs.put('User Action', +WorkgroupUserAction);
           inputs.put('User', +WorkgroupUsers);
           inputs.put('Additional instructions for this workgroup modification', +WorkgroupAdditionalInstructions);
           cs.Description = format(inputs);              
         }
         else    
                  return false;
 
         return true;         
    }
    
    public Boolean getManagedPhoneStation(){ 
  
        if ( String.isNotBlank(MACAddressOfPhone) && String.isNotBlank(PhoneModel) && String.isNotBlank(LocationOfPhone) && 
             String.isNotBlank(PhoneName) && String.isNotBlank(Language) && String.isNotBlank(NumOfLineKeys) && 
             String.isNotBlank(ExtensionForPhone) ) {
             
             Map<String, string> inputs = new Map<String, string>();        
             inputs.put('MAC address of phone', MACAddressOfPhone);
             inputs.put('Model type,', PhoneModel);
             inputs.put('If softphone, full computer name', ComputerName);
             inputs.put('Location of phone', LocationOfPhone);
             inputs.put('Phone name', PhoneName);
             inputs.put('Language', Language); 
             inputs.put('Extension for phone', Language);
             inputs.put('# of Line keys', NumOfLineKeys);
             inputs.put('Enable MWI', EnableMWI);  
              cs.Description = format(inputs);           
         }
         else    
                  return false;
 
         return true;         
    }

    public Boolean getDIDDNISModification() {
 
      if ( String.isNotBlank(DID) && String.isNotBlank(UserWorkgroupPhoneAssignedTo) )  {
        
                Map<String, string> inputs = new Map<String, string>();
                inputs.put('DID', DID);
                inputs.put('User/Workgroup/Phone assigned to', UserWorkgroupPhoneAssignedTo);
                inputs.put('Additional Instructions', AdditionalInstructions); 
                        cs.Description = format(inputs);                 
      }
      else    
          return false;
 
         return true;         
    }
    
    public Boolean getWaveFileUpload() { 
       
        if ( String.isNotBlank(LanguageFolderForFilesToBePlacedIn) && String.isNotBlank(OverwriteDuplicateFiles) && String.isNotBlank(OverwriteDuplicateFiles) ) {  
       
                Map<String, string> inputs = new Map<String, string>();
                inputs.put('Language folder for files to be placed in', LanguageFolderForFilesToBePlacedIn);
                inputs.put('Overwrite duplicate files', OverwriteDuplicateFiles);
                inputs.put('Additional instructions', AdditionalInstructions); 
                cs.Description = format(inputs);                 
         }
         else    
                 return false;
 
         return true;    
    }
    
    public Boolean getTSRAAddUser(){ 

       if  ( String.isNotBlank(UserName) && String.isNotBlank(UserEmail) ) {  
        
         Map<String, string> inputs = new Map<String, string>();
         inputs.put('User Name', UserName);
         inputs.put('User email', UserEmail);
         inputs.put('User to mirror access after', UserToMirrorAccessAfter);
         cs.Description = format(inputs);                
       }
        else    
                 return false;
 
         return true;  
    }
 
    public Boolean getTSRAPwdReset() { 
    
      if ( String.isNotBlank(UserName) &&  String.isNotBlank(UserEmail) ) {
         
         Map<String, string> inputs = new Map<String, string>();
         inputs.put('User Name', UserName);
         inputs.put('User Email', UserEmail);
         cs.Description = format(inputs);                
       }
        else    
                 return false;
 
         return true;  
    }
    
    public Boolean getTSRAUsrDel() {    
        if ( String.isNotBlank(UserName) &&  String.isNotBlank(UserEmail) ) {
         
         Map<String, string> inputs = new Map<String, string>();
         inputs.put('User Name', UserName);
         inputs.put('User Email', UserEmail);
         cs.Description = format(inputs);                
       }
        else    
                 return false;
 
         return true;  
    }
    
    public Boolean getAttendantModification() { 
 
        if ( String.isNotBlank(ProfileName) && String.isNotBlank(ScheduleName) &&String.isNotBlank(ModificationRequest) ) {
                
                Map<String, string> inputs = new Map<String, string>();
                inputs.put('Profile name', ProfileName);
                inputs.put('Schedule name', ScheduleName);
                inputs.put('Modification request', ModificationRequest);
            cs.Description = format(inputs);             
       }
        else    
                 return false;
 
         return true;  
    }
    
   public Boolean getAttendantAddProfile() {  
        
        if ( String.isNotBlank(ProfileName) && String.isNotBlank(ScheduleName) && String.isNotBlank(DNIS) && String.isNotBlank(TimeZone) && 
             String.isNotBlank(IsUnplannedSchedule) && String.isNotBlank(IsUnplannedSchedule) && String.isNotBlank(ScheduleRunTimeDays) &&
             String.isNotBlank(MenuOptions) ) {
            
            Map<String, string> inputs = new Map<String, string>();         
                inputs.put('Profile name', ProfileName);
                inputs.put('Schedule name', ScheduleName);
                inputs.put('DNIS', DNIS);
                inputs.put('Time zone', TimeZone);
                inputs.put('Is this an unplanned schedule?', IsUnplannedSchedule);
                inputs.put('Schedule run time/days', ScheduleRunTimeDays);
                inputs.put('Schedule greeting wav file', ScheduleGreetingWavFile);
                inputs.put('Menu options', MenuOptions);
                inputs.put('Desired call flow', DesiredCallFlow);
                cs.Description = format(inputs);                 
       }
        else    
                 return false;
 
         return true;  
    }
    
    public Boolean getSchldRptModification(){    
   
        if ( String.isNotBlank(ReportName) && String.isNotBlank(ModificationRequest) ) {
                
                Map<String, string> inputs = new Map<String, string>(); 
                inputs.put('Report name', ReportName);
                inputs.put('Modification request', ModificationRequest);
            cs.Description = format(inputs);             
       }
        else    
                 return false;
 
         return true;  
    }
    
    public Boolean getSchldRptAddDeleteUser(){ 
   
     if ( String.isNotBlank(AddDelete) && String.isNotBlank(AddDelete) && String.isNotBlank(UserName) && String.isNotBlank(ReportName) ) {                 
           
        Map<String, string> inputs = new Map<String, string>();  
        inputs.put('Add/Delete?', AddDelete);
        inputs.put('User name', UserName);
        inputs.put('Report name', ReportName);
        cs.Description = format(inputs);                 
       }
        else    
                 return false;
 
         return true;  
    }

    public Boolean getAddSchldReportr(){

      if ( String.isNotBlank(NameOfReport) && String.isNotBlank(FilterType) && String.isNotBlank(ReportType) && 
           String.isNotBlank(ReportDelivery) && String.isNotBlank(TimeRange) && String.isNotBlank(RecipientEmail) ) { 
                
                Map<String, string> inputs = new Map<String, string>();
                inputs.put('Name of report', NameOfReport);
                inputs.put('Filter Type', FilterType);
                inputs.put('Report Type', ReportType);
                inputs.put('Report Delivery', ReportDelivery);
                inputs.put('Time Range', TimeRange);
                inputs.put('Recipient Email', RecipientEmail);
                inputs.put('Report parameters to add', ReportParametersToAdd);
                inputs.put('Additional Instructions', AdditionalInstructions);    
                cs.Description = format(inputs);                 
       }
        else    
                 return false;
 
         return true;  
    }
    
    public Boolean getTollFreeNumberAdd(){  
 
    if ( String.isNotBlank(AmountOfNumbersRequested) ) {
        
        Map<String, string> inputs = new Map<String, string>();
        inputs.put('Amount of numbers requested', AmountOfNumbersRequested);
        inputs.put('Number range preferred', NumberRangePreferred);
                cs.Description = format(inputs);                 
       }
        else    
                 return false;
 
         return true;  
    }
    
   public Boolean getTollFreeNumberRemove(){  

      if ( String.isNotBlank(NumberToBeRemoved) ) {
        
                Map<String, string> inputs = new Map<String, string>();
                inputs.put('Number to be removed', NumberToBeRemoved);
                inputs.put('Attendant profile names that use this number', AttendantProfileNames);
                cs.Description = format(inputs);                 
       }
        else    
                 return false;
 
         return true;  
    }
     
   public Boolean getTollFreeNumberModify(){

      if ( String.isNotBlank(NumberNeedingModification) && String.isNotBlank(ModificationRequest) ) {  
        
                Map<String, string> inputs = new Map<String, string>();
                inputs.put('Number needing modified', NumberNeedingModification);
                inputs.put('Modification request', ModificationRequest);
       
                cs.Description = format(inputs);                 
       }
        else    
                 return false;
 
         return true;  
    }
    
    public Boolean getDIDNumbersAdd() {

      if ( String.isNotBlank(AmountOfNumbersRequested) ) {  
        
                Map<String, string> inputs = new Map<String, string>();
                inputs.put('Amount of numbers Requested', AmountOfNumbersRequested);
                inputs.put('Area Code Preferred', AreaCodePreferred);
                inputs.put('Additional Information', AdditionalInformation);
       
                cs.Description = format(inputs);                 
       }
        else    
                 return false;
 
         return true;  
    }
    
    public Boolean getOtherMACRequest(){ 

        if( String.isNotBlank(PhoneNumber) && String.isNotBlank(MACRequest) ) {
                
            Map<String, string> inputs = new Map<String, string>();
                inputs.put('A number at which you can be reached', PhoneNumber);
                inputs.put('MAC request', MACRequest);
                inputs.put('Title', Title);
            cs.Description = format(inputs);             
       }
        else    
                 return false;
 
         return true;  
    }


    /* Radio button for 06.Create new Managed Phone/Station (Enable MWI:) */
    public List<SelectOption> getItems() {
        List<SelectOption> optionsMWI = new List<SelectOption>(); 
        optionsMWI.add(new SelectOption('Yes','Yes')); 
        optionsMWI.add(new SelectOption('No','No')); 
        return optionsMWI; 
    }  

    /* Radio button for 08.Wav File Upload (Overwrite duplicate files) */
    public List<SelectOption> getItems1() {
        List<SelectOption> optionsWavefileupload = new List<SelectOption>(); 
        optionsWavefileupload.add(new SelectOption('Yes','Yes')); 
        optionsWavefileupload.add(new SelectOption('No','No')); 
        return optionsWavefileupload; 
    } 

    /* Radio button for 13.Attendant Add New Profile/Schedule (Is this an unplanned schedule?) */

    public List<SelectOption> getItems2() {
        List<SelectOption> optionsAtten = new List<SelectOption>(); 
        optionsAtten.add(new SelectOption('Yes','Yes')); 
        optionsAtten.add(new SelectOption('No','No')); 
        return optionsAtten; 
    } 

    /* Radio button for 15.Schedule Reports Add/Delete User (Add/Delete?) */

    public List<SelectOption> getItems3() {
        List<SelectOption> optionsAddDel = new List<SelectOption>(); 
        optionsAddDel.add(new SelectOption('Add','Add')); 
        optionsAddDel.add(new SelectOption('Delete','Delete')); 
        return optionsAddDel; 
    } 
}