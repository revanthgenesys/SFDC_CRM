public class DemoRequestCancelExtension {
    private final Demo_Request__c req;
    
    public Boolean showNotAbleToCancel { get; set; }
    public Boolean showVerify { get; set; }
    public Boolean showCancel { get; set; }
    public String Id { get; set; }
    public List<SelectOption> cancelReasons { get; set; }
    public String cancelReason { get; set; }

   public DemoRequestCancelExtension(ApexPages.StandardController stdController) {
        if(!test.isRunningTest())
        	stdController.addFields(new List<String>{'State__c', 'Chatter_Feed_ID__c', 'Cancel_Reason__c', 'SuppressNotification__c'});
        req = (Demo_Request__c)stdController.getRecord();
        Id = req.Id;
        
        showNotAbleToCancel = DemoRequestUtility.uncancelableStates.contains(req.State__c);
        showVerify = !showNotAbleToCancel;
       
       	cancelReasons = new List<SelectOption>();
        cancelReasons.add(new SelectOption(' ', ' '));
        for(String c : DemoRequestUtility.cancelReasons){
            cancelReasons.add(new SelectOption(c, c));
        }

    }
    
    public PageReference Submit() {
        if(checkCancelReason()) return null;
        req.Cancel_Reason__c = cancelReason;
        DemoRequestClass.CancelDemos(new List<Demo_Request__c>{req});
        return DemoRequestUtility.returnToDemo(req);
    }
    
    private Boolean checkCancelReason(){
        if(String.isBlank(cancelReason)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                	'Please select a cancel reason'));
            return true;
        } return false;
    }
    
}