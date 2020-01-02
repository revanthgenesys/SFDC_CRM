public class extendExpiryController{
   public Boolean isLocked {get;set;}
   public Boolean status {get; set;}
   public partner_portal_prospect__c deal{get;set;} 
   
   public String approver {get; set;} 
        
   public extendExpiryController(ApexPages.StandardController st){
      if(!Test.isRunningTest())
      st.addFields(new List<String>{'End_Date__c', 'Proposed_End_Date__c','Opportunity_Channel_Manager__c','Opportunity_Channel_Manager__r.Name'});
      deal = (partner_portal_prospect__c) st.getRecord();
      System.Debug('deal--->'+deal);
      isLocked = Approval.isLocked(deal.Id);
   }
    
   public PageReference save() {
       try{
           System.Debug('dealInSave--->'+deal.proposed_end_date__c);
           Integer daysFromEndDate = deal.end_date__c.daysBetween(deal.proposed_end_date__c);
           Integer daysFromToday = System.today().daysBetween(deal.proposed_end_date__c); 
           approver = daysFromEndDate < 180 ? deal.Opportunity_Channel_Manager__r.Name : 'Janelle'; 
             if(daysFromEndDate < 0 || daysFromToday < 0){
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'New Expiration Date should be later than the current expiration date'));
             }           
             else if(daysFromEndDate > 180){
                   Update deal;
                   status = invokeApproval('Above_6_Months_Expiration_Extension');
                   isLocked = true;
             }
             else{
                   Update deal;
                   status = invokeApproval('Below_6_Months_Expiration_Extension');
                   isLocked = true;
                  } 
           }
       catch(exception e){
           System.Debug('Error--->'+e.getMessage());
           System.Debug('ErrorInLine--->'+e.getLineNumber());
       }
           return null;
   }
   
     Boolean invokeApproval(String processName){
        Boolean stat = false;
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Expiration Date Extension Request');
        req.setObjectId(deal.Id);
        req.setSubmitterId(userInfo.getUserId());
        req.setProcessDefinitionNameOrId(processName);
        req.setSkipEntryCriteria(true);

        try{
            // submit the approval request for processing
              Approval.ProcessResult result = Approval.process(req);
              stat = result.isSuccess();
              System.Debug('UpdDeal--->'+deal);
        }catch(Exception e){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Approver may not be active or the record may be pending in another approval. Please reach your channel manager'));
             //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));

        }
       return stat; 
    }
    
    
}