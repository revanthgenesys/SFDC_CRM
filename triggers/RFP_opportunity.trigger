//Test Class: VariousOPPNotification_Test

trigger RFP_opportunity on RFP_Support_Request__c (after insert, after update) {
    if(trigger.isInsert){
        try{
            for(RFP_Support_Request__c rfpobj : Trigger.new){
                Opportunity oppty = [Select id, Proposal_Manager__c,Technical_Writer__c from Opportunity where id =: rfpobj.Opportunity__c];
                List <RFP_Support_Request__c> lisrfpobj = [SELECT Id, Proposal_Manager__c,Technical_Writer__c FROM RFP_Support_Request__c WHERE Opportunity__c = :oppty.Id];
                for(RFP_Support_Request__c rfpco : lisrfpobj) {
                    oppty.Proposal_Manager__c = rfpco.Proposal_Manager__c;
                    oppty.Technical_Writer__c = rfpco.Technical_Writer__c;                    
                }
                update oppty;
            }
        }
            catch (Exception e) {
                System.debug(e);
            }
        }
    if(Trigger.isAfter) {
         if(Trigger.isUpdate){
             try {
                 for (RFP_Support_Request__c rfpobj1 : Trigger.old){
                     Opportunity oppty = [Select id, Proposal_Manager__c,Technical_Writer__c from Opportunity where id =: rfpobj1.Opportunity__c];
                      List <RFP_Support_Request__c> lisrfpobj = [SELECT Id, Proposal_Manager__c,Technical_Writer__c FROM RFP_Support_Request__c WHERE Opportunity__c = :oppty.Id];
                     
                  for(RFP_Support_Request__c rfpco : lisrfpobj) {
                    oppty.Proposal_Manager__c = rfpco.Proposal_Manager__c;
                    oppty.Technical_Writer__c = rfpco.Technical_Writer__c;                    
                 }
                      update oppty;
                 }
                 
             }
              catch (Exception e) {
                System.debug(e);
            }
         }
    }
    }