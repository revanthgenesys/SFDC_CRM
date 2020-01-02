/*
Created By:            Swastika Rajkhowa
Created On:            04/Mar/2016
Function:              a) User click on the link which comes in email
                       b) A VF page will open having a list of Technical Profiles which are required Acknowledgement and are owned by the logged-in user.
                       c) User can see details of the Technical Profile by clicking the name of profile.
                       d) User has to select the profiles and need to click on the Update button.
                       e) All the technical profiles will be acknowledged in a single go.
Modified By:           Swastika Rajkhowa
Modified Date:         14-Apr-2016
Function:              Email is received - click the email link - click profile name - review the profile - leave comments in the validation box and save profile - return to validation page - Check validation box - click the Acknowledge button - Validation time is reset, and the process is completed for the next 6 months              
  
*/
public class TechnicalProfileAckController{
    //Declaration of list
    public List<Technical_Profile__c> lst_Tech {get; set;}
    public List<wrapperTechProfile> lst_wTechProfile{get; set;}
    public List<Technical_Profile__c> lst_selectedTechProfile {get; set;}
    //Declaration of variables
    public id id_User{get; set;}
    public boolean hasTechprofile{get; set;}
    public boolean IsSelectAll{get; set;}
    public boolean IsAck{get; set;} //to acknowledge all the records 
     
    
    //Constructor
    public TechnicalProfileAckController(){
        lst_Tech =new List<Technical_Profile__c>();
        id_User = userInfo.getUserId();
        hasTechprofile=false;
        IsSelectAll=false;
        IsAck=false;
        getTechnicalprofiles();
        }
    public void getTechnicalprofiles(){
         string techid = ApexPages.currentPage().getParameters().get('id'); 
         lst_Tech = [SELECT Id,Name,Account__c,Account__r.name,Contact_Center_Type__c,Technical_Profile_Acknowledgment_Date__c,Account__r.Owner.Id,Account__r.Owner.Email,Validation_Box__c
                                            FROM Technical_Profile__c 
                                            WHERE (Technical_Profile_Acknowledgment_Date__c=:null OR (Technical_Profile_Acknowledgment_Date__c<=TODAY AND Technical_Profile_Acknowledgment_Date__c!=LAST_N_DAYS:180)) AND id=:techid];//id_User 
                                            
          lst_wTechProfile= new List<wrapperTechProfile>();
           for (Technical_Profile__c objTech: lst_Tech) {
            lst_wTechProfile.add(new wrapperTechProfile(objTech));
            }                                  
          if(lst_wTechProfile.size()>0)                                  
             hasTechprofile=true;
          else
          {
              hasTechprofile=false;
              if(IsAck==false)
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'There is no Technical Profile available to acknowledge owned by you.'));
              
          }    
        }
     //On action of Acknowledge
     public  void Acknowledged()
         {
         lst_selectedTechProfile = new List<Technical_Profile__c>();
        for (wrapperTechProfile objWProfile: lst_wTechProfile) {
            if (objWProfile.selected == true) {
                objWProfile.TechicalProfile.Technical_Profile_Acknowledgment_Date__c=System.today();
                lst_selectedTechProfile.add(objWProfile.TechicalProfile); // This adds the wrapper technical Profile to selected list
            }                       
           }
           system.debug('lst_selectedTechProfile'+lst_selectedTechProfile);
           if(lst_selectedTechProfile.size()>0)   
               {        
               update lst_selectedTechProfile;
               IsAck=true;
               getTechnicalprofiles();
               ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Your acknowledgement has been accepted and updated the acknowledgement date for selected Technical Profiles.'));
               }
           else
               { 
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please add Validation Notes to the Technical Profile before acknowledging.'));
               }    
         }  
        
        //Create a wrapper class for Service Contracts with check box
    public class wrapperTechProfile {
            public Technical_Profile__c TechicalProfile{get; set;}
            public boolean selected {get; set;}
    
            public wrapperTechProfile(Technical_Profile__c techProfile) {
            this.TechicalProfile= techProfile;
            selected = false; //If you want all checkboxes initially selected, set this to true
            }
        }
        
}