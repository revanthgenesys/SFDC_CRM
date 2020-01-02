/* ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Harish, 03/13/2017 - commenting Bypass_Trigger_Chk check to run the trigger for test class. 
 */
@isTest(seealldata=true)
public class TechnichalProfileMain_Test {
 	public static testmethod void testTechnichalProfileMainTrigger(){
 
 	//MS- temp measure to pass deployment errors
  	//Util.Bypass_Trigger_Chk = true;
    
        List<Wow_Request_Form__c> wowForms = [SELECT Id, Account_Id__c FROM Wow_Request_Form__c LIMIT 1];
        List<POC_Engagement_Request__c> pocForms = [SELECT Id, Account_Id__c FROM POC_Engagement_Request__c LIMIT 1];
        if(!wowForms.isEmpty()){
            List<Technical_Profile__c> techProfiles = [SELECT id FROM Technical_Profile__c WHERE Account__c = :wowForms[0].Account_Id__c];
            if(!techProfiles.isEmpty()){
                update techProfiles[0];                
            } else {
                Technical_Profile__c techProfile = new Technical_Profile__c();
                techProfile.Account__c = wowForms[0].Account_Id__c;
                 insert techProfile;
            }
        }
        if(!pocForms.isEmpty()){
            List<Technical_Profile__c> techProfiles = [SELECT id FROM Technical_Profile__c WHERE Account__c = :pocForms[0].Account_Id__c];
            if(!techProfiles.isEmpty()){          	
                update techProfiles[0];                
            } else {
                Technical_Profile__c techProfile = new Technical_Profile__c();
                techProfile.Account__c = pocForms[0].Account_Id__c;              
                insert techProfile;
            }
        }
    }
}