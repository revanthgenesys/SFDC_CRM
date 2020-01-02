trigger partnerRequestApproval on Partner_Contract__c (after insert,before update) {
List<Approval.ProcessSubmitRequest> approvalReqList = new List<Approval.ProcessSubmitRequest>();
 
  if(Trigger.isInsert)
  {
      for (Partner_Contract__c pcont: Trigger.New)
      {       
          if (pcont.Status__c =='Draft')
          {           
            // create the new approval request to submit    
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();   
            req.setComments('Submitted for approval. Please approve.');
            req.setObjectId(pcont.Id);
            approvalReqList.add(req);        
          }   
      }
  }
// submit the approval request for processing        
List<Approval.ProcessResult> resultList = Approval.process(approvalReqList);        
// display if the reqeust was successful
for(Approval.ProcessResult result: resultList )
{        
System.debug('Submitted for approval successfully: '+result.isSuccess());      
}
}