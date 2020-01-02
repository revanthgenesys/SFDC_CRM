public class DealRegApproveRejectController {

        private string recordId;
        private partner_portal_prospect__c dealRegRec = new partner_portal_prospect__c();
        //public string comments{get;set;}
        public string rejectReason{get;set;}
        private string approvalStep;
        public boolean isChnlMgrStep{get;set;}
        public string otherReason{get;set;}

        public DealRegApproveRejectController(){
            recordId = ApexPages.currentPage().getParameters().get('recid');
            approvalStep = ApexPages.currentPage().getParameters().get('step');
            isChnlMgrStep = approvalStep!=null?(approvalStep.equals('Channel_Manager') || approvalStep.equals('Channel_Manager_First_level')):false;
            
            getdealRegRec();
        }
        
        public partner_portal_prospect__c getdealRegRec(){
            
            try{
            
                dealRegRec = [Select Id,Name, owner.Name, Sales_Leader__c,Opportunity_Channel_Manager__c,Rejection_Reason__c,Other_Rejection_Reason__c
                                from partner_portal_prospect__c where Id=:recordId];
                if(approvalStep == 'Channel_Manager' || approvalStep == 'Channel_Manager_First_level'){
                    dealRegRec.Sales_Leader__c = null;
                }
            }
            catch(exception e){
                System.Debug('ErrorGetDeal--->'+e.getMessage());
                System.Debug('ErrorInLineGetDeal--->'+e.getLineNumber());
            }
                return dealRegRec;
            
        }
        
        public List<SelectOption> getRejectionReason(){
                List<SelectOption> rejectoptions = new List<SelectOption>();
                           
                Schema.DescribeFieldResult fieldResult = partner_portal_prospect__c.Rejection_Reason__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                rejectoptions.add(new SelectOption('--None--','--None--'));        
                for( Schema.PicklistEntry f : ple)
            {
                rejectoptions.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
            return rejectoptions;
        }
        
        public pagereference approveRec(){
            
            try{
            
                string workItemId;
                pagereference dealPage = new pagereference('/'+recordId);
                dealPage.setRedirect(true);
                //return dealPage;
                
                for(ProcessInstanceWorkitem workItem  : [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:recordId]){
                    workItemId=workItem.Id;
                }
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItemId);
                req.setAction('Approve');
                req.setComments('Approved');
                if(rejectReason=='--None--'){
                    if(isChnlMgrStep && dealRegRec.Sales_Leader__c!=null){
                        req.setNextApproverIds(new Id[] {dealRegRec.Sales_Leader__c});
                        Approval.ProcessResult processResults = Approval.process(req);
                        System.Debug('chnlmgrreq--->'+processResults);
                    }
                    else if(!isChnlMgrStep){
                        Approval.ProcessResult processResults = Approval.process(req);
                        System.Debug('processResults--->'+processResults);
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your administrator has specified that you must manually choose who the next approver should be. Specify a user in the Next Approver field, then click Approve.'));
                        dealPage = null;
                    }
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rejection reason must not be provided when approving the record. Please remove Rejection Reason and click Approve'));
                    dealPage = null;
                }
                return dealPage;
            }
            catch(exception e){
                System.Debug('ErrorAppr--->'+e.getMessage());
                System.Debug('ErrorInLineAppr--->'+e.getLineNumber());
                return null;
            }

        }
        
        public pagereference rejectRec(){
            
            try{
                pagereference dealPage = new pagereference('/'+recordId);
                dealPage.setRedirect(true);             
            
                if(rejectReason=='--None--'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rejection reason is mandatory when rejecting a deal registration'));
                    dealPage = null;
                }
                else if(rejectReason=='Other' && string.isBlank(otherReason)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Other reason is mandatory if \'Other\' option is selected for Rejection Reason'));
                        dealPage = null;
                }
                else{
                    string workItemId;
                    string mergeComments;
                    for(ProcessInstanceWorkitem workItem  : [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:recordId]){
                        workItemId=workItem.Id;
                    }

                    /*Approval.unlock(recordId);
                    dealRegRec.Rejection_Reason__c = rejectReason;
                    dealRegRec.Other_Rejection_Reason__c = !(string.isBlank(otherReason))?otherReason:null;
                    update dealRegRec;
                    Approval.lock(recordId);*/
                                       
                    
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkitemId(workItemId);
                    req.setAction('Reject');
                    mergeComments = rejectReason!='--None--' && !(string.isBlank(otherReason))?rejectReason+'-'+otherReason:rejectReason;
                    req.setComments(mergeComments);
                    Approval.ProcessResult processResults = Approval.process(req);
                    System.Debug('reject--->'+processResults);
                    
                    dealRegRec.Rejection_Reason__c = rejectReason;
                    dealRegRec.Other_Rejection_Reason__c = !(string.isBlank(otherReason))?otherReason:null;
                    update dealRegRec;
                    
                }
                
                /*if(rejectReason!='--None--'){
                    dealRegRec.Rejection_Reason__c = rejectReason;
                    dealRegRec.Other_Rejection_Reason__c = !(string.isBlank(otherReason))?otherReason:null;
                    update dealRegRec;
                    
                }*/
                
                return dealPage;                
            }
            catch(exception e){
                System.Debug('ErrorRej--->'+e.getMessage());
                System.Debug('ErrorInLineRej--->'+e.getLineNumber());
                return null;
            }
            
        }
        
        public pagereference cancelRec(){
            pagereference dealPage = new pagereference('/'+recordId);
            dealPage.setRedirect(true);
            return dealPage;            
        }

    }