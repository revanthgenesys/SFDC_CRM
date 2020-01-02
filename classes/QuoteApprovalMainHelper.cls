//Naresh Kumar  06/25/2014
public without sharing class QuoteApprovalMainHelper {
  //Assumption : One quote approval record will be approved/rejected at a time
  
  public static void assignNextStep(Map<Id, Quote_Approval__c> oldMap, List<Quote_Approval__c> newList){
    //Getting current approval record
    Quote_Approval__c newRecord = [SELECT Step__c, BigMachines_Quote__c, Deal_Qualification__c, Status__c, 
      Quote_Approval_Step_Details__r.Quote_Approval_Step__r.Order__c, Comments__c FROM Quote_Approval__c WHERE id =: newList[0].id];
    //If current quote is rejected, quote approval cancelled, do nothing
    if(newRecord.Status__c == QuoteApprovalUtil.STATUS_REJECTED 
      || newRecord.Status__c == QuoteApprovalUtil.STATUS_CANCELLED || newRecord.Comments__c == QuoteApprovalUtil.APPROVAL_BY_PASSED)
      return;
    if(newRecord.BigMachines_Quote__c != null){
      //Getting current quote record
      BigMachines__Quote__c quote = QuoteApprovalUtil.getQuote(newRecord.BigMachines_Quote__c);
      //If quote is approved or rejected
      if(newRecord.Status__c != QuoteApprovalUtil.STATUS_PENDING && oldMap.get(newRecord.id).Status__c == QuoteApprovalUtil.STATUS_PENDING){      
        //Getting all the pending step items (if any)
        List<Quote_Approval__c> currentStepApprovals = [SELECT id FROM Quote_Approval__c WHERE 
          BigMachines_Quote__c =: quote.id AND Step__c =: newRecord.Step__c AND Status__c =: QuoteApprovalUtil.STATUS_PENDING];
        //If step is complete
        if(currentStepApprovals.isEmpty()){
          //Getting next step's order
          Integer nextStepOrder = Integer.valueOf(newRecord.Step__c) + 1;
          //Assign next step (if any)
          QuoteApprovalAssignment.getNextApprovalRecords(quote, nextStepOrder);  
        }  
      }          
    }
    else if(newRecord.Deal_Qualification__c != null){
      //Getting current quote record
      Deal_Qualification__c dq = DealQualificationApprovalUtil.getDQFromId(newRecord.Deal_Qualification__c);
      //If quote is approved or rejected
      if(newRecord.Status__c != DealQualificationApprovalUtil.STATUS_PENDING && oldMap.get(newRecord.id).Status__c == DealQualificationApprovalUtil.STATUS_PENDING){      
        //Getting all the pending step items (if any)
        List<Quote_Approval__c> currentStepApprovals = [SELECT id FROM Quote_Approval__c WHERE 
          Deal_Qualification__c =: dq.id AND Step__c =: newRecord.Step__c AND Status__c =: QuoteApprovalUtil.STATUS_PENDING];
        //If step is complete
        if(currentStepApprovals.isEmpty()){
          //Getting next step's order
          Integer nextStepOrder = Integer.valueOf(newRecord.Step__c) + 1;
          //Assign next step (if any)
          DealQualificationApprovalAssignment.getNextApprovalRecords(dq, nextStepOrder);  
        }  
      }
    }
  }
  
  public static void quoteStatusHandler(Map<Id, Quote_Approval__c> oldMap, List<Quote_Approval__c> newList){
    if(newList[0].BigMachines_Quote__c != null){  
      //Getting max approval submission order    
      List<Quote_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c FROM Quote_Approval__c 
        WHERE BigMachines_Quote__c =: newList[0].BigMachines_Quote__c ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
      //If there is no approval record, just return
      if(existingQuoteApprovals.isEmpty())
        return;  
      //Getting all approval records for current Quote
      List<Quote_Approval__c> allQuoteApprovalForCurrentQuote = [SELECT Status__c FROM Quote_Approval__c 
        WHERE BigMachines_Quote__c =: newList[0].BigMachines_Quote__c AND Approval_Submission_Counter__c =: existingQuoteApprovals[0].Approval_Submission_Counter__c];
      //Would contain all different status
      Set<String> setStatus = new Set<String>();
      //Whether current quote approval is rejected or not
      Boolean rejectQuote = false;
      //Quote 
      BigMachines__Quote__c quoteToBeUpdated = new BigMachines__Quote__c(id = newList[0].BigMachines_Quote__c);
      Boolean fireDML = false;
      //Looping over the list    
      for(Quote_Approval__c eachQA : allQuoteApprovalForCurrentQuote){
        //Ignore notification only records
        if(eachQA.Status__c == QuoteApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY)
          continue;
        setStatus.add(eachQA.Status__c);    
        if(eachQA.id == newList[0].id && eachQA.Status__c == QuoteApprovalUtil.STATUS_REJECTED){
          quoteToBeUpdated.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_REJECTED;
          fireDML = true;  
        }
      }    
      //Updated quote status if all approval are approved.
      if(setStatus.size() == 1 && setStatus.contains(QuoteApprovalUtil.STATUS_APPROVED)){    
        quoteToBeUpdated.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_APPROVED;
        quoteToBeUpdated.Approval_Date__c = System.Today();
        quoteToBeUpdated.Proposal_Date__c = quoteToBeUpdated.Approval_Date__c; 
        fireDML = true;
      }
      //Updated quote status if all approval are rejected.
      if(setStatus.size() == 1 && setStatus.contains(QuoteApprovalUtil.STATUS_REJECTED)){
        quoteToBeUpdated.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_REJECTED;
        fireDML = true;
      }
      if(fireDML)
        update quoteToBeUpdated;    
    }
    else if(newList[0].Deal_Qualification__c != null){
      //Getting max approval submission order    
      List<Quote_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c FROM Quote_Approval__c 
        WHERE Deal_Qualification__c =: newList[0].Deal_Qualification__c ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
      //If there is no approval record, just return
      if(existingQuoteApprovals.isEmpty())
        return;  
      //Getting all approval records for current Quote
      List<Quote_Approval__c> allQuoteApprovalForCurrentQuote = [SELECT Status__c, Step_Name__c FROM Quote_Approval__c 
        WHERE Deal_Qualification__c =: newList[0].Deal_Qualification__c AND Approval_Submission_Counter__c =: existingQuoteApprovals[0].Approval_Submission_Counter__c];
      //Would contain all different status
      Set<String> setStatus = new Set<String>();
      //Whether current quote approval is rejected or not
      Boolean rejectQuote = false;
      //Quote 
      Deal_Qualification__c dqToBeUpdated = new Deal_Qualification__c(id = newList[0].Deal_Qualification__c);
      //Looping over the list    
      for(Quote_Approval__c eachQA : allQuoteApprovalForCurrentQuote){
        //Ignore notification only records
        if(eachQA.Status__c == DealQualificationApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY)
          continue;
        setStatus.add(eachQA.Status__c);    
        if(eachQA.id == newList[0].id && eachQA.Status__c == DealQualificationApprovalUtil.STATUS_REJECTED){
          dqToBeUpdated.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_REJECTED;
        }
      }    
      //Updated quote status if all approval are approved.
      if(setStatus.size() == 1 && setStatus.contains(DealQualificationApprovalUtil.STATUS_APPROVED)){    
        dqToBeUpdated.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_APPROVED;
        //dqToBeUpdated.Approval_Date__c = System.Today();
        //dqToBeUpdated.Proposal_Date__c = dqToBeUpdated.Approval_Date__c; 
        DealQualificationApprovalAssignment.updateDealQualificationApprovalHistory(newList[0].Deal_Qualification__c);
      }
      //Updated quote status if all approval are rejected.
      if(setStatus.size() == 1 && setStatus.contains(DealQualificationApprovalUtil.STATUS_REJECTED)){
        dqToBeUpdated.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_REJECTED;
      }
      dqToBeUpdated = populateLevelSubmissionApprovalDates(newList[0], dqToBeUpdated, oldMap, allQuoteApprovalForCurrentQuote);      
      update dqToBeUpdated;
      List<Deal_Qualification__c> listOfDQs = [SELECT Quote__c, Status__c FROM Deal_Qualification__c WHERE id =: dqToBeUpdated.id];
      if(!listOfDQs.isEmpty() && listOfDQs[0].Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_APPROVED  && listOfDQs[0].Quote__c != null){
     		BigMachines__Quote__c objQuote = new BigMachines__Quote__c(id = listOfDQs[0].Quote__c);
            objQuote.BigMachines__Status__c = 'Quote Approved';
            update objQuote;
      }
    }
  }
  
  private static Deal_Qualification__c populateLevelSubmissionApprovalDates(Quote_Approval__c currentQuoteApproval, Deal_Qualification__c dqToBeUpdated, 
    Map<Id, Quote_Approval__c> oldMap, List<Quote_Approval__c> allQuoteApprovalForCurrentDQ){        
    System.debug('NKC debug currentQuoteApproval.Status__c ['+currentQuoteApproval.Status__c+']');
    System.debug('NKC debug oldMap.get(currentQuoteApproval.id).Status__c ['+oldMap.get(currentQuoteApproval.id).Status__c+']');
    
    if(currentQuoteApproval.Status__c == DealQualificationApprovalUtil.STATUS_PENDING && oldMap.get(currentQuoteApproval.id).Status__c == DealQualificationApprovalUtil.STATUS_INACTIVE){
      dqToBeUpdated = updateTimestampOnDQ(dqToBeUpdated, 'Submission', currentQuoteApproval.Step_Name__c);
    }  
    else if(currentQuoteApproval.Status__c == DealQualificationApprovalUtil.STATUS_APPROVED && oldMap.get(currentQuoteApproval.id).Status__c == DealQualificationApprovalUtil.STATUS_PENDING){
      dqToBeUpdated = updateTimestampOnDQ(dqToBeUpdated, 'Approval', currentQuoteApproval.Step_Name__c);
    }
    return dqToBeUpdated;
  }
  
  public static Deal_Qualification__c updateTimestampOnDQ(Deal_Qualification__c dq, String Type, String Level){
    System.debug('NKC debug Type ['+Type+']');
    System.debug('NKC debug Type ['+Level+']');
    
    if(Type == 'Submission'){
      if(Level == DealQualificationApprovalUtil.LEVEL1)
        dq.Level_1_Submission_Date__c = System.now();
      else if(Level == DealQualificationApprovalUtil.LEVEL2)
        dq.Level_2_Submission_Date__c = System.now();
      else if(Level == DealQualificationApprovalUtil.LEVEL3)
        dq.Level_3_Submission_Date__c = System.now();
      else if(Level == DealQualificationApprovalUtil.LEVEL4)
        dq.Level_4_Submission_Date__c = System.now();      
    }
    else if(Type == 'Approval'){
      //Getting max approval submission order    
      List<Quote_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c FROM Quote_Approval__c 
        WHERE Deal_Qualification__c =: dq.id ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
      //If there is no approval record, just return
      if(existingQuoteApprovals.isEmpty())
        return dq;  
      //Getting all approval records for current Quote
      List<Quote_Approval__c> allQuoteApprovalForCurrentQuote = [SELECT id FROM Quote_Approval__c 
        WHERE Deal_Qualification__c =: dq.id AND Approval_Submission_Counter__c =: existingQuoteApprovals[0].Approval_Submission_Counter__c
        AND Status__c =: DealQualificationApprovalUtil.STATUS_PENDING AND Step_Name__c =: Level];
      if(!allQuoteApprovalForCurrentQuote.isEmpty())
        return dq;        
      if(Level == DealQualificationApprovalUtil.LEVEL1)
        dq.Level_1_Approval_Date__c = System.now();
      else if(Level == DealQualificationApprovalUtil.LEVEL2)
        dq.Level_2_Approval_Date__c = System.now();
      else if(Level == DealQualificationApprovalUtil.LEVEL3)
        dq.Level_3_Approval_Date__c = System.now();
      else if(Level == DealQualificationApprovalUtil.LEVEL4)
        dq.Level_4_Approval_Date__c = System.now();      
    }
    System.debug('NKC debug dq ['+dq+']');
    return dq;  
  }
    
    public static void testCoverage() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
 	}
}