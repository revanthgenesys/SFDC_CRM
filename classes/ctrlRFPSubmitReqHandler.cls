public with sharing class ctrlRFPSubmitReqHandler {

public RFP_Support_Request__c objRFP {
        get;
        set;
    }

public ctrlRFPSubmitReqHandler(ApexPages.StandardController controller) {
        objRFP = (RFP_Support_Request__c) controller.getRecord();
        //ApexPages.StandardController con = new ApexPages.StandardController(objRFP);
        //ctrlRFPSubmitReqHandler rfpSupp = new ctrlRFPSubmitReqHandler(con);
         //saveSubmit();    
    
    }


public PageReference saveSubmit() {
boolean check = false;
String ownerEmail ='';
String targetId = '';

List <RFP_Support_Request__c> objRequest = [Select  Direct_Sales_1__c,Total_Amount_1__c,of_Technical_Questions__c,Submitted__c,Proposal_Outcome_1__c,Proposal_Outcome__c,Override_Proposal_Outcome__c ,Account__c,Name,Opportunity__r.OwnerId,Opportunity__r.Owner.Email,SaveSubmitCheck__c,Total_Amount__c,Opportunity__c,Close_Date__c,
                        Opportunity_Owner__c,Direct_Sales__c,Sold_To_Business_Partner__c,Document_Type__c,Date_Received__c,Due_Date__c,Extension_Due_Date__c,Decision_Date__c,Solution_Engineer_Name__c,
                        Additional_Resources__c,Deliverable__c,No_of_Questions__c,Deployment_Model__c,Solution_Type__c,Additional_Details__c,Genesys_Influence__c,Existing_Customer__c,How_do_we_rate_vs_competition__c,
                        Percentage_Solution_Fit__c,Proposal_Status__c,Proposal__c,Proposal_Manager__c,technical_writer__c,
                        Opportunity__r.StageName,
                        Status_Comment__c,Questions_Influenced__c from RFP_Support_Request__C where id = : objRFP.Id];



   for(RFP_Support_Request__c a : objRequest){
     ownerEmail = a.Opportunity__r.Owner.Email;
      targetId = a.Opportunity__r.OwnerId;
     
     a.Deal_Stage_At_Queue_Entry__c = a.Opportunity__r.StageName; 
     
     
     if(a.Submitted__c) 
       check = false;
     else   {
      a.Submitted__c = true;
      a.SaveSubmitCheck__c = true;
      check=true;
    }
   } 
  if(check) {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'RFP Support Request Submitted Successfully.'));       
    update objRequest; 
    
     String templateApiName = 'RFP_Proposal_Manager_Notification';
                List < String > toRecipients = new List < String > {
                    'Kevin.Colliton@genesys.com','vikram.sharma@genesys.com'
                };
               
                Id templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toRecipients);
                email.setTemplateId(templateId);
                email.setSubject(targetId);
                email.setTargetObjectId(targetId);
                email.setsaveAsActivity(false);
               // Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                 //   email
              // });

    
    
    
 } 
 else { 
   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'This opportunity already has a RFP Support Request Submitted.'));    
  }   

 return null;
}


}