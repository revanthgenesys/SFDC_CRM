public without sharing class DealQualificationApprovalHistoryPgContr {
	public Deal_Qualification__c dq {get;set;}
	public String dqId {get;set;}
	public String oppId {get;set;}
	public String statusStyle {get;set;}
	public DealQualificationApprovalHistoryPgContr(ApexPages.StandardController stdCtrl){
		/*
		oppId = stdCtrl.getId();
		List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(oppId);
        if(!dqs.isEmpty()){
        	dq = dqs[0];
        	dqId = dqs[0].id;
        	if(dq.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_PENDING || dq.Status__c == DealQualificationApprovalUtil.STATUS_REVISION_PENDING)
        		statusStyle = '#FFCC00';
        	else if(dq.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_APPROVED)
        		statusStyle = '#4DFF4D';
        	else
        		statusStyle = '#FF6666';
        	
        }
        */
	}
}