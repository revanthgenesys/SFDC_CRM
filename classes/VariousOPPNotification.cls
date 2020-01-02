/***************************************************************************************************
* 
*  Class Name      :   VariousOPPNotification 
*  Description     :   This class is called from OPP Trigger and used to send notification to RFP Group when OPP is closed and there
*                      is RFP not having Proposal Status = Response Completed. It is also used to send various notifications
*  Auther          :   R Systems
*  Test Class      :   VariousOPPNotification_Test
****************************************************************************************************/
public class VariousOPPNotification {
    
    public static Boolean isStopDesign = true;
    public static Boolean isStopRFP = true;
    
    public static void RFPNotifications (Map<ID,Opportunity> map_newOpp, Map<ID,Opportunity> map_oldOpp) {
         List<ID>list_ID = new List<ID>();
         for(ID sOppId : map_newOpp.keySet())
         {
            Opportunity objOLD = map_oldOpp.get(sOppId);
            Opportunity objNEW = map_newOpp.get(sOppId);
            if(objOLD.StageName != objNEW.StageName && objNEW.StageName == '6.Closed' && objNEW.Win_Loss_Status__c == 'Merged/Dup Opp')
             list_ID.add(sOppId);
         }
         //Naresh Kumar 04/24/2018 - If the list empty it should return back. It is firing unnecessary SOQLs which is resulting to 101 SOQL error on order approval.
         if(list_ID.isEmpty())
             return;
          /********************Get Email Template*****************************/ 
          List<EmailTemplate>list_EmailTemp = [select id from EmailTemplate where Name =: 'RFP Opportunity Close Notification'];
          
          
          //Get all RFP which are not completed
          List<RFP_Support_Request__c> objRFP = [select id,Proposal_Status__c,Opportunity__c,Opportunity__r.Owner.Region__c from RFP_Support_Request__c where Proposal_Status__c !=: 'Response Complete' and Opportunity__c in : list_ID]; 
          List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
          for(RFP_Support_Request__c obj : objRFP)
          {
              string Region = obj.Opportunity__r.Owner.Region__c;
              //Set email ids
              List<String> emails=new List<String>();
              
              if(Region == 'NORTH AMERICA' || Region == 'Americas')
                  emails = getNotificationEmailID('RFPCentral'); 
              else if(Region == 'EMEA')
                  emails = getNotificationEmailID('RFPCentralEMEA'); 
              else if(Region == 'LATAM')
                  emails = getNotificationEmailID('RFPCentralLATAM'); 
              else if(Region == 'APAC')
                  emails = getNotificationEmailID('RFPCentralAPAC'); 
              else
                  emails.add('jitendra.jain@genesys.com');

              //emails.add('debora.lane@genesys.com');
              //emails.add('jitendra.jain@genesys.com');
              
              
                // Create a new single email message object
                // that will send out a single email to the addresses in the To, CC & BCC list.
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                mail.setToAddresses(emails);
                // Specify the name used as the display name.
                mail.setSenderDisplayName('');                   
                // Set to True if you want to BCC yourself on the email.
                mail.setBccSender(false);
                // Optionally append the salesforce.com email signature to the email.
                // The email address of the user executing the Apex Code will be used.
                mail.setUseSignature(false);
                //Map the VF template
                mail.setTargetObjectId(userinfo.getuseriD()); //Mandatory field when use template
                mail.setWhatId(obj.id);
                mail.setTemplateId(list_EmailTemp[0].Id);  //Find the template on the basis of name                    
                // Send the email you have created.
                mail.SaveAsActivity = false; //Mandatory field when use template
                mails.add(mail);

              //SendEmailByTemplateRFP(obj1.UserOrGroupId,list_EmailTemp[0].id, obj.Opportunity__c, obj.id);
          }
          //Send email as bulk
          if(!Test.isRunningTest())
            Messaging.sendEmail(mails);
            
            isStopRFP = false; 

    }
    
    
     //If OPP has SCE DSR and it doesn't have Design
     public static void SendNotificationforMissingDesign(Map<ID,Opportunity> map_newOpp, Map<ID,Opportunity> map_oldOpp) 
     {
         List<ID>list_ID = new List<ID>();
         for(ID sOppId : map_newOpp.keySet())
         {
            Opportunity objOLD = map_oldOpp.get(sOppId);
            Opportunity objNEW = map_newOpp.get(sOppId);
            
            
            //Get all OPP which are falling in condition
            /*if(objOLD.StageName != objNEW.StageName && (objNEW.StageName == '4.Build Consensus' || objNEW.StageName == '5.Purchase Solution' || (objNEW.StageName == '6.Closed' && objNEW.Win_Loss_Status__c == 'Won')))
             list_ID.add(sOppId);*/
             
            //Added By Anshul 
            
            
            Map<Integer,String> monthToQuarterMap = new Map<Integer,String>
                                                                    {1=>'Q1',
                                                                     2=>'Q1',    
                                                                     3=>'Q1',    
                                                                     4=>'Q2',    
                                                                     5=>'Q2',    
                                                                     6=>'Q2',    
                                                                     7=>'Q3',    
                                                                     8=>'Q3',    
                                                                     9=>'Q3',    
                                                                     10=>'Q4',    
                                                                     11=>'Q4',    
                                                                     12=>'Q4' };
            
            
                if((objNEW.ForecastStatus__c == '0.Booked' || objNEW.ForecastStatus__c == '1.In Hand' || objNEW.ForecastStatus__c == '3.Expected') && objNEW.Type != 'Existing Business - Expansion' && objNEW.Direct_Indirect_Sale__c == 'Direct' && monthToQuarterMap.get(objNEW.CloseDate.month()) == monthToQuarterMap.get(date.today().month())){
                list_ID.add(sOppId); 
             }   
                /*
                  Integer curentDateMonth = date.today().month();
                  Integer oppCloseDateMonth = objNEW.CloseDate.month();
                
                if(monthToQuarterMap.get(oppCloseDateMonth) == monthToQuarterMap.get(curentDateMonth)){
                  list_ID.add(sOppId);  
                    
                    if(objNEW.Direct_Indirect_Sale__c == 'Direct'){
                        if(objNEW.Type != 'Existing Business – Expansion'){
                            if(objNEW.SMART_Opportunity__c){
                               list_ID.add(sOppId);
                            }
                        }
                    }
                   
                }
            }*/ 
             
         }
         
         if(list_ID.size()>0)
         {
             //List<Messaging.SingleEmailMessage>﻿ mails = new List<Messaging.SingleEmailMessage>﻿();
             List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
             List<EmailTemplate>list_EmailTemp = [select id from EmailTemplate where DeveloperName =: 'SC_Engagement_DesignNeeded'];
             List<DSR_SCEngagement__c> scEngagementList = new List<DSR_SCEngagement__c>();
             
             //Get all SCE where Design is missing
             //Smart_Opportunity_Intent_Use__c flag added on 06/28 by JJ as requested by Debbie
             for(DSR_SCEngagement__c objDSRwithoutDesign : [Select ID,Opportunity_ID__c,Opportunity_ID__r.Ownerid,Opportunity_ID__r.Owner.Region__c from DSR_SCEngagement__c where Opportunity_ID__c in : list_ID and Has_Designs__c = false and sc_engagement_status__c != 'Rejected' and Smart_Opportunity_Intent_Use__c = 'Yes' and Is_Design_Notification_Sent__c = false]){
                 
                 string Region = objDSRwithoutDesign.Opportunity_ID__r.Owner.Region__c;
                 
                 //Set email ids
                 List<String> emails=new List<String>();
                 
                 //For testing actual emails are commented
                 
                 //Americas2 Added by Anshul
                 //No need to send notification for other regions as requested by Debbie 
                 if(Region == 'NORTH AMERICA' || Region == 'AMERICAS' || Region == 'AMERICAS2')
                     emails = getNotificationEmailID('OPP Missing Design - NORTH AMERICA'); 
                 /*
                 else if(Region == 'EMEA')
                     emails = getNotificationEmailID('OPP Missing Design - EMEA'); 
                 else if(Region == 'LATAM')
                     emails = getNotificationEmailID('OPP Missing Design - LATAM'); 
                 else if(Region == 'APAC')
                     emails = getNotificationEmailID('OPP Missing Design - APAC');
                 else
                    emails.add('jitendra.jain@genesys.com');
                */ 
                
                //emails.add('debora.lane@genesys.com');
                //emails.add('jitendra.jain@genesys.com');

                // Create a new single email message object
                // that will send out a single email to the addresses in the To, CC & BCC list.
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                mail.setToAddresses(emails);
                // Specify the name used as the display name.
                mail.setSenderDisplayName('');                   
                // Set to True if you want to BCC yourself on the email.
                mail.setBccSender(false);
                // Optionally append the salesforce.com email signature to the email.
                // The email address of the user executing the Apex Code will be used.
                mail.setUseSignature(false);
                //Map the VF template
                mail.setTargetObjectId(userinfo.getuseriD()); //Mandatory field when use template
                mail.setWhatId(objDSRwithoutDesign.Opportunity_ID__c); //Assign Wow Id
                mail.setTemplateId(list_EmailTemp[0].Id);  //Find the template on the basis of name                    
                // Send the email you have created.
                mail.SaveAsActivity = false; //Mandatory field when use template
                mails.add(mail);
                
                //Setting Is_Design_Notification_Sent flag to true By Anshul
                objDSRwithoutDesign.Is_Design_Notification_Sent__c = true;
                scEngagementList.add(objDSRwithoutDesign);
                
             }
                system.debug('>> '+ mails);
                
                //Updating scEngagementList By Anshul
                if(scEngagementList.size() > 0){
                    
                    try{
                        
                       update scEngagementList;
                       
                    }catch(DMLException exp){}
                    
                }
                
                //Send email is bulk
                if(!Test.isRunningTest())
                    Messaging.sendEmail(mails);
                isStopDesign = false;
         }
       

     }
     
         
     public static string[] getNotificationEmailID(string Key)
     {
         
         EmailNotifications__c email = EmailNotifications__c.getValues(Key);
         string[] emails = email.emails__c.split(';');
         
         return emails;
     }
     

}