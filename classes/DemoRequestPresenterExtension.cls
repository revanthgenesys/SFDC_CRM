public class DemoRequestPresenterExtension {

    private Demo_Request__c req;
    public Boolean showPresenter { get; private set; }
    public Boolean showWarning { get; private set; }
    public Boolean showConflict { get; private set; }
    public Boolean showAddMe { get; private set; }
    public Boolean showRemoveMe { get; private set; }
    public Boolean showRemove { get; private set; }
    private Boolean hasMultipleActs { get { return tracks.size() > 0; } }
    
    List<Demonstration_Presenter__c> pres { get; set; }
    List<Request_Presenter_Junction__c> curr { get; set; }
    public List<Request_Presenter_Junction__c> displayCurrent { get; set; }
    private Set<Id> currPres { get; set; }
    private Map<Id, Id> userToPresenter { get; set; }
    private Map<Id, Id> presenterToUser { get; set; }
    private Map<Id, String> presenterToName { get; set; }

    public List<SelectOption> currentPresenters { get; set; }    
    public List<SelectOption> possiblePresenters { get; set; }
    public List<Event> conflicts { get; private set; }

    public String selectedPersonAdd { get; set; }
    public String selectedPersonRemove { get; set; }
    public String selectedPersonName { get; private set; }
    private Id selectedId { get; set; }
    public String demoOwner { get; set; }
    private Id demoOwnerId { get; set; }
    private String currentUserPresenterId { get; set; }
    
    private Set<Id> ts { get { return DemoRequestUtility.getAllTSIds(); } }
    private List<Demo_Request_Tracking__c> tracks { get; private set; }
    //Activity types to delete
    private List<String> actTypes {get; private set;} { actTypes = new List<String>{'Demo', 'Tradeshow', 'Demo Training'}; }
    
    public DemoRequestPresenterExtension(ApexPages.StandardController stdController) {
        if(!test.isRunningTest())
            stdController.addFields(new List<String>{'Other_Applications__c', 'State__c', 'Demo_Date_Time__c', 'Demo_Time_Length__c', 'Demo_Owner__c', 'Demo_Owner__r.Name', 'AudienceType__c'});
        this.req = (Demo_Request__c) stdController.getRecord();
        tracks = [Select Activity_Type__c, Activity_Date_Time__c, Activity_Duration__c, hasEvent__c, Demo_Request__c, isTemplate__c, Activity_State__c from Demo_Request_Tracking__c where isTemplate__c = true and Demo_Request__c = :req.Id];
        
        setupCurrentPresenters();
    }
    
    private void setupCurrentPresenters() {
        curr = [Select User_Name__c, Demonstration_Presenter__c, Id from Request_Presenter_Junction__c where Demo_Request__c = :req.Id];
        if(checkViewAllowed()) return;
        showAddMe = true;
        showRemoveMe = false;
        showRemove = false;
        currPres = new Set<Id>();
        currentPresenters = new SelectOption[]{};
        displayCurrent = new List<Request_Presenter_Junction__c>();
        userToPresenter = new Map<Id, Id>();
        presenterToUser = new Map<Id, Id>();
        presenterToName = new Map<Id, String>();
        
        demoOwner = req.Demo_Owner__r.Name;
        demoOwnerId = req.Demo_Owner__c;
        
        for(Request_Presenter_Junction__c r : curr) {
            currPres.add(r.Demonstration_Presenter__c);
            if(r.User_Name__c == UserInfo.getName()) {
                showAddMe = false;
                showRemoveMe = true;
                if(demoOwner != r.User_Name__c) displayCurrent.add(r);
            } else if(demoOwner != r.User_Name__c) {
            	currentPresenters.add(new SelectOption(r.Demonstration_Presenter__c, r.User_Name__c));
                displayCurrent.add(r);
            }
        }
        
        //if at least one other person and they are not current user, show remove dropdown list
        if(curr.size() > 1 && currentPresenters.size() != 0) showRemove = true;
        if(demoOwnerId == UserInfo.getUserId()) showRemoveMe = false;
        
        pres = [Select Name, Id, User_Name__r.Name, User_Name__r.Id from Demonstration_Presenter__c WHERE isTs__c = true];
        possiblePresenters = new List<SelectOption>();
        for(Demonstration_Presenter__c p : pres) {
            userToPresenter.put(p.User_Name__r.Id, p.Id);
            presenterToUser.put(p.Id,p.User_Name__r.Id);
            presenterToName.put(p.Id, p.User_Name__r.Name);
            if(p.User_Name__r.Id == UserInfo.getUserId()) {
             	currentUserPresenterId = p.Id;
                continue;
            }
            if(!currPres.contains(p.Id) || p.User_Name__c == UserInfo.getUserId()) possiblePresenters.add(new SelectOption(p.Id, p.User_Name__r.Name));
        }
    }
    
    private Boolean checkViewAllowed() {
        if(curr.size() < 1 || !DemoRequestUtility.canAddPresenter.contains(Req.State__c)) {
            showWarning = true;
            return true;
        }
        showPresenter = true;
        return false;
    }
    
    public void addMe() {
        selectedPersonAdd = userToPresenter.get(UserInfo.getUserId());
        addPresenter();
    }
    
    public void addPresenter() {
        conflicts = DemoRequestUtility.GetRequestEventConflicts(req, presenterToUser.get(selectedPersonAdd));
        selectedId = selectedPersonAdd;
        selectedPersonName = presenterToName.get(selectedPersonAdd);
        if(conflicts.size() > 0) {
            showConflict = true;
            showPresenter = false;
        } else {
            submitAddPresenter();
        }
    }
    
    public void submitAddPresenter() {
        showConflict = false;
        DemoRequestClass.addPresenter(new Map<Id, Demo_Request__c>{selectedId => req});
        Id user = presenterToUser.get(selectedId);
        if(hasMultipleActs){
            DemoRequestClass.createEventActivities(tracks, new Map<Id, Id>{ req.Id => user });
        } else {
        	DemoRequestClass.addDemoActivity(new Map<Id, Demo_Request__c>{user => req});
        }
        setupCurrentPresenters();
    }
    
    public void removeMe() {
        selectedPersonRemove = userToPresenter.get(UserInfo.getUserId());
		removePresenterLogic();
    }
    
    public void removePresenter() {
        if(selectedPersonRemove == null) return;
        removePresenterLogic();
    }
    
    private void removePresenterLogic() {
        List<Request_Presenter_Junction__c> removals = new List<Request_Presenter_Junction__c>();
        for(Request_Presenter_Junction__c r : curr) {
            if(r.Demonstration_Presenter__c == selectedPersonRemove) removals.add(r);
        }
        DemoRequestClass.removePresenter(removals);
        List<String> actTypes = new List<String>{'Demo', 'Tradeshow', 'Demo Training'};
        List<Demo_Request_Tracking__c> acts = [Select Id, Demo_Request__c, Activity_Completed_By__c, Activity_Date_Time__c, Activity_Type__c, GoToMeeting_ID__c from Demo_Request_Tracking__c
                                               where Demo_Request__c = :req.Id and Activity_Type__c in :actTypes and Activity_Completed_By__c = :presenterToUser.get(selectedPersonRemove)
                                              and Activity_Date_Time__c > :DateTime.now()];
        DemoRequestClass.removeDemoActivity(acts);
        setupCurrentPresenters();
    }
}