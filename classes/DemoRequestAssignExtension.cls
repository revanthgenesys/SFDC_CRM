public class DemoRequestAssignExtension {
    private final Demo_Request__c req;
    private final Map<String, Id> userPresenters;
    
    public Boolean showNotAbleToAssign { get; set; } 
    public Boolean showAssignSelection { get; set; }
    public Boolean showAssigned { get; set; }
    public Boolean showPreviousEventWarning { get; set; }
    public Boolean canAccept { get; set; }
    public final List<SelectOption> displayedPresenters { get; set; }
    public String selectedPerson { get; set; }
    public List<Event> conflicts { get; set; }
    public Boolean suppressNotifications { get; set; }
    private Boolean acceptedSelf { get; set; } { acceptedSelf = false; }
    
    public DemoRequestAssignExtension(ApexPages.StandardController stdController) {
        if(!test.isRunningTest())
            stdController.addFields(new List<String>{'LastModifiedDate', 'AudienceType__c', 'State__c', 'Org_URL__c', 'Timestamp_Accepted__c',
                'SuppressNotification__c', 'Demo_Owner__c', 'Other_Applications__c', 'Demo_Time_Length__c', 'Chatter_Feed_ID__c', 'Demo_Date_Time__c'});
        this.req = (Demo_Request__c)stdController.getRecord();
		System.Debug('Running DRAssign as: ' + UserInfo.getUserId());
        
        showNotAbleToAssign = DemoRequestUtility.unassignableStates.contains(req.State__c);
        showAssignSelection = !showNotAbleToAssign;
        
        if(req.Demo_Owner__c != UserInfo.getUserId() && DemoRequestUtility.getAllTSIds().contains(UserInfo.getUserId())) canAccept = true;
        
        if(!showNotAbleToAssign) {
            List<Demonstration_Presenter__c> allPresenters = [Select Id, User_Name__c, Display_Name__c from Demonstration_Presenter__c where isTS__c = true order by Display_Name__c];
            userPresenters = new Map<String, Id>();
            Map<String, Id> demoPresenters = new Map<String, Id>();
            displayedPresenters = new List<SelectOption>();
            for(Demonstration_Presenter__c p : allPresenters){
                demoPresenters.put(p.Display_Name__c, p.Id);
                userPresenters.put(p.Display_Name__c, p.User_Name__c);
                if(req.Demo_Owner__c == p.User_Name__c) continue;
                if(p.User_Name__c == UserInfo.getUserId()) continue;
                displayedPresenters.add(new SelectOption(p.Display_Name__c, p.Display_Name__c));
            }
            
            suppressNotifications = req.SuppressNotification__c;
        }
       
    }

    public PageReference submitSelf() {
        selectedPerson = UserInfo.getName();
        acceptedSelf = true;
        return submitAssign();
    }
    
    public PageReference submitAssign() {
        if(checkConflicts()) return null;
        return submitFinal();
    }
    
    private Boolean checkConflicts() {
        conflicts = DemoRequestUtility.GetRequestEventConflicts(req, userPresenters.get(selectedPerson));
        if(conflicts.size() > 0) {
            showAssignSelection = false;
            showPreviousEventWarning = true;
            return true;
        }
        return false;
    }
    
    public PageReference submitFinal() {
        if(!DemoRequestClass.checkLastModified(req)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Request has been recently modified, please verify you still want to accept/assign and try again.'));
            System.debug('########################################################## Request Recently modified: ' + req.Id + ' blocking Accept');
            return null;
        }
        Id owner = userPresenters.get(selectedPerson);
        System.debug('########################################################## Submitting Accept Demo request: ' + req.Id + ' for ' + selectedPerson + ' ' + owner);
        req.SuppressNotification__c = suppressNotifications;
        DemoRequestClass.AcceptDemos(new Map<Demo_Request__c,Id>{req => owner});
        System.debug('########################################################## Request state: ' + req.State__c + ' for owner: '+ owner);
        showAssignSelection = false;
        showPreviousEventWarning = false;
        if(acceptedSelf){
            PageReference page = new PageReference('/apex/DemoRequestActivityTracking?id=' + req.Id);
            page.setRedirect(true);
            return page;
        }
        PageReference demo = new ApexPages.StandardController(req).view();
        demo.setRedirect(true);
        return demo;

    }
    
}