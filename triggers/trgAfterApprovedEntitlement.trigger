trigger trgAfterApprovedEntitlement on Transfer_Tool_Approval__c (before update) {
	if((Trigger.old[0].Status__c == 'Submitted' && Trigger.new[0].Status__c == 'Approved') && TransferToolUtil.firstRun){
		
        String returnServiceContractId = TransferToolUtil.performTransfer(trigger.New[0].id);
		Trigger.New[0].Transfer_Date__c = System.today();
        if(returnServiceContractId != NULL)
        	Trigger.New[0].New_Service_Contract__c = returnServiceContractId;
        
        TransferToolUtil.firstRun=false;
    }
}