//Naresh Kumar	04/01/2014
public without sharing class QuoteApproveRejectExtension {
	public BigMachines__Quote__c quote {get;set;}
	public String comments {get;set;}
	public Boolean showDetails {get;set;}
	public String approverId {get;set;}
	public Boolean requestInfo {get;set;}
	
	public QuoteApproveRejectExtension(ApexPages.StandardController stdController){
    	init();
    }
    
    public QuoteApproveRejectExtension(){
    	init();
    }
    
    private void init(){
    	requestInfo = false;
    	String quoteId = ApexPages.currentPage().getParameters().get('id');
    	approverId = ApexPages.currentPage().getParameters().get('approver');
    	
    	String query = CloudQuoteUtil.getQuoteForFieldSet('Quote_Approval_Page_Fields','BigMachines__Quote__c');
    	
		query += ' WHERE id = \'' + quoteId + '\'';
		query = query.replace('SELECT ', 'SELECT BigMachines__Status__c, Owner.Email, ');
		System.debug('NKC debug query ['+query+']');
		
		quote = (BigMachines__Quote__c)Database.query(query);
		
		if(quote.BigMachines__Status__c != 'Quote Approval Pending'){
			showDetails = false;
			ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Quote doesn\'t qualify for approval or rejection.');
			ApexPages.addMessage(pMessage);
		}
		else
			showDetails = true;
		
    }
    
    public void approve(){
    	if(approveRejectAP('Approve')){
	    	ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Your approval has been submitted successfully.');
			ApexPages.addMessage(pMessage);
    	}		    	
    }
    
    public void reject(){
    	if(approveRejectAP('Reject')){    	
	    	ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Your rejection has been submitted successfully.');
			ApexPages.addMessage(pMessage);
    	}
    }
    
    public void requestMoreInfo(){
    	requestInfo = true;
    	showDetails = false;
    }
    
    public void sendRequest(){
    	String subject = 'Quote :' + quote.Name + '- More Info requested.';
    	SendEmail.sendSingleEmail(quote.Owner.Email, subject, comments);
    	requestInfo = false;
    	showDetails = false;
    	ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'You request has been sent successfully.');
		ApexPages.addMessage(pMessage);
    }
    
    private Boolean approveRejectAP(String action){
    	Boolean isActionTaken = false;
		List<ProcessInstance> procins = new List<ProcessInstance>([select Id from ProcessInstance where Status = 'Pending' and TargetObjectId = :quote.id]);
		if(!procins.isEmpty()){
				List<ProcessInstanceWorkitem> workItems = new List<ProcessInstanceWorkitem>([select Id, ActorId, OriginalActorId from ProcessInstanceWorkitem where ProcessInstanceId = :procins[0].id]);
				Set<String> queueIds = new Set<String>();
				for(ProcessInstanceWorkitem eachPIWI : workItems){
					queueIds.add(eachPIWI.ActorId);
				}
				List<GroupMember> queueUsers = [Select UserOrGroupId, GroupId From GroupMember where GroupId IN : queueIds];
				Map<String,String> userIdVsQueueId = new Map<String,String>();
				for(GroupMember eachMember : queueUsers){
					userIdVsQueueId.put(eachMember.UserOrGroupId, eachMember.GroupId);
				}  
				System.debug('NKC debug userIdVsQueueId ['+userIdVsQueueId+']');
				for(ProcessInstanceWorkitem eachPIWI : workItems){
					System.debug('NKC debug eachPIWI.ActorId ['+eachPIWI.ActorId+']');
					System.debug('NKC debug userIdVsQueueId.get(fromUser[0].id) ['+userIdVsQueueId.get(UserInfo.getUserId())+']');							
					if(eachPIWI.ActorId == userIdVsQueueId.get(UserInfo.getUserId())){
						System.debug('NKC debug in APPROVE/REJECT');
						Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
						PWR.setComments(comments);						
						PWR.setAction(action);
						PWR.setWorkitemId(eachPIWI.id);											
						Approval.ProcessResult result1 =  Approval.process(PWR);	
						isActionTaken = true;
					}	
				}
		}
		if(isActionTaken == false){
			ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry ! You can\'t approve this quote because you are not one of current approver assigned to approve this quote.');
			ApexPages.addMessage(pMessage);
		}
		showDetails = false;
		return isActionTaken;
	}
	
}