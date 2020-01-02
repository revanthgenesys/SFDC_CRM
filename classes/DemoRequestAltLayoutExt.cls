public class DemoRequestAltLayoutExt {
    
    private final Demo_Request__c req;
    public Boolean isTS { get { return DemoRequestUtility.getAllTSIds().contains(UserInfo.getUserId()); } }
    public String source { get; set; }
    public List<Demo_Request_Tracking__c> tracks { get; set; }
    
    public DemoRequestAltLayoutExt(ApexPages.StandardController stdController) {
        if(!test.isRunningTest())
        	stdController.addFields(new List<String>{'State__c', 'Account__c', 'Opportunity__c', 'Lead__c'});
        req = (Demo_Request__c)stdController.getRecord();
        tracks = [Select Activity_Type__c, Activity_Duration__c, Activity_Date_Time__c, Activity_Completed_By__c, Activity_State__c 
                  from Demo_Request_Tracking__c where Activity_Completed_By__c != '' and Demo_Request__c = :req.Id];
        
        if(String.isNotBlank(req.Opportunity__c)){
            source = 'Opportunity';
        } else if(String.isBlank(req.Opportunity__c) && String.isNotBlank(req.Account__c)){
            source = 'Account';
        } else if (String.isNotBlank(req.Lead__c)){
            source = 'Lead';
        } else {
            source = 'Not Linked to Object';
        }
        
    }
    
    public PageReference decline(){
        PageReference page = new PageReference('/apex/DemoRequestDecline?id=' + req.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference acceptAssign(){
        PageReference page = new PageReference('/apex/DemoRequestAssignVF?id=' + req.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference reschedule(){
        PageReference page = new PageReference('/apex/DemoRequestRescheduleVF?id=' + req.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference cancel(){
        PageReference page = new PageReference('/apex/DemoRequestCancelVF?id=' + req.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference updateItems(){
        PageReference page = new PageReference('/apex/DemoRequestUpdateItems?id=' + req.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference addPresenters(){
        PageReference page = new PageReference('/apex/DemoRequestPresenter?id=' + req.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference manageActivities(){
        PageReference page = new PageReference('/apex/DemoRequestActivityTracking?id=' + req.Id);
        page.setRedirect(true);
        return page;
    }

}