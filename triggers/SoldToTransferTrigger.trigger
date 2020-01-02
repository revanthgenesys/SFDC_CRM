trigger SoldToTransferTrigger on Sold_To_Transfer_Request_Header__c (before update) {

	if((Trigger.old[0].Status__c == 'Submitted' && Trigger.new[0].Status__c == 'Approved') && SoldToTransferToolUtil.firstRun){
        SoldToTransferToolUtil.performTransfer(trigger.New[0].id);
        trigger.New[0].Transfer_Date__c = Date.Today();
        SoldToTransferToolUtil.firstRun=false;
    }
}