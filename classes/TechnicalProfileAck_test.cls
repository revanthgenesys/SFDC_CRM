/*
Created By:    Swastika Rajkhowa-Rsystems(21/Mar/2016)
Function:      Test Class for Class  TechnicalProfileAckController,BatchTechnicalProfileAcknowledgment,SchedulableJobTechnicalProfileAck
*/

@isTest(seealldata=true)
public class TechnicalProfileAck_test{
     static Account testAccount;
      public static testmethod void testmethodTechnicalProfileAckController(){  
          test.starttest(); 
          Technical_Profile__c techProfile=new Technical_Profile__c();
          TechnicalProfileAckController objTechProfile=new TechnicalProfileAckController();
          //objTechProfile.getTechnicalprofiles();
          //Test Account
            testAccount = TestUtil.createAccounts(1, true)[0];
            testAccount.ownerid = userInfo.getUserId();
            techProfile.Account__c = testAccount.id;
            insert techProfile;
          
          //techProfile=objTechProfile.lst_Tech[0];
          TechnicalProfileAckController.wrapperTechProfile objWrapper=new TechnicalProfileAckController.wrapperTechProfile(techProfile);
          objWrapper.selected=true;
          objTechProfile.lst_wTechProfile.add(objWrapper);         
          objTechProfile.Acknowledged();          
          test.stoptest();     
      }
     /*public static testmethod void testMethodBatchTechnicalProfileAcknowledgment()
         {
         test.starttest();
         List<Technical_Profile__c > lsS=[SELECT Id,Name,Account__r.Owner.Id,Account__r.Owner.Email
                                            FROM Technical_Profile__c 
                                            WHERE (Technical_Profile_Acknowledgment_Date__c=:null OR (Technical_Profile_Acknowledgment_Date__c<=TODAY AND Technical_Profile_Acknowledgment_Date__c!=LAST_N_DAYS:180)) LIMIT 1];
         BatchTechnicalProfileAcknowledgment objB = new BatchTechnicalProfileAcknowledgment();  
            objB.start(null);
            objB.execute(null,lsS);
            objB.finish(null);
           test.stoptest();         
         }*/ 
       
     }