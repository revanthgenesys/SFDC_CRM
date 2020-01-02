public class DemoRequestAvailableController {
    public List<DemoRequestWrapper> reqWithRelated { get {if(reqWithRelated == null) reqWithRelated = getRequests();
        													return reqWithRelated;}
                                                    set; }
	public List<SelectOption> statusFilter { get; set; } 
    public String selectedState { get; set; } {selectedState = 'My Queue';}
    private List<String> filterStates = new List<String>{'My Queue', 'Escalated', 'Rescheduled', 'Pending Approval', 'Auto-Declined', 'Active'};
    public List<SelectOption> sortBy { get; set;}
    public String selectedSort { get; set; } { selectedSort = 'Demo Date/Time';}
    public Boolean requery { get; set; } {requery = true;}
    private List<Id> requestsToDisplay = new List<Id>();
    private List<Id> autoDeclinedIds = new List<Id>();
    private List<Id> allRequestIds = new List<Id>();
    private List<Demo_Request__c> availableRequests = new List<Demo_Request__c>();
    private List<DemoRequestWrapper> reqToDisplay = new List<DemoRequestWrapper>();  
    private Map<String, String> sortStrings = new Map<String, String>{'Demo Date/Time' => 'Demo_Date_Time__c ASC', 'Request ID (Ascending)' => 'Name ASC', 'Request ID (Descending)' => 'Name DESC', 'Request Type (Ascending)' => 'Request_Type__c ASC', 'Request Type (Descending)' => 'Request_Type__c DESC'};  
    private Map<Id, List<String>> req2Plats = new Map<Id, List<String>>();
    private Map<Id, List<String>> req2Prods = new Map<Id, List<String>>();
    private Map<Id, List<String>> req2GenCons = new Map<Id, List<String>>();
    private Map<Id, List<String>> req2Ints = new Map<Id, List<String>>();
    private Map<Id, Integer> leftToDecline = new Map<Id, Integer>();
    private Boolean viewingAutoDecline = false;
    private String queue { get; set; }

    
    public DemoRequestAvailableController() {        
        statusFilter = new List<SelectOption>();
        for(string i : filterStates){
            statusFilter.add(new SelectOption(i,i));
        }
        sortBy = new List<SelectOption>();
        for(String s : sortStrings.keySet()){
            sortBy.add(new SelectOption(s,s));
        }

        queue = DemoRequestUtility.getPresentersQueue(UserInfo.getUserId());
        
    }    
    
    public List<DemoRequestWrapper> getRequests(){
        if(selectedState == 'My Queue') return getAvailableRequests();
        if(selectedState == 'Auto-Declined') return getAutoDeclines();
        if(selectedState == 'Active') return getAllRequests();
        List<DemoRequestWrapper> filteredRequests = new List<DemoRequestWrapper>();        
        for(DemoRequestWrapper d : getAvailableRequests()){
            if(selectedState == d.request.State__c){
                filteredRequests.add(new DemoRequestWrapper(d.request, req2Plats.get(d.request.Id), req2Prods.get(d.request.Id), req2GenCons.get(d.request.Id), req2Ints.get(d.request.Id), leftToDecline.get(d.request.Id)));
            }
        }
        return filteredRequests;
    }
    
    public void filter(){
        reqWithRelated = getRequests();
    }
    
    public void resort(){
        requery = false;
        availableRequests.clear();
        reqWithRelated = getRequests();
    }
    
    public void refresh(){
        requery = true;
        availableRequests.clear();
        reqWithRelated = getRequests();
    }
    
    private List<DemoRequestWrapper> getAvailableRequests(){		       
        if(availableRequests.isEmpty() && requery){            
            reqToDisplay.clear();
            requestsToDisplay.clear();
            autoDeclinedIds.clear();            
            buildIdLists();            
            buildWrappers(requestsToDisplay);            
        } else if (availableRequests.isEmpty() || viewingAutoDecline){
            reqToDisplay.clear();
            buildWrappers(requestsToDisplay);
        }
        viewingAutoDecline = false;
        return reqToDisplay;
    }
    
    private List<DemoRequestWrapper> getAutoDeclines(){
        if(autoDeclinedIds.isEmpty()) buildIdLists();
        reqToDisplay.clear();
        buildWrappers(autoDeclinedIds);
        viewingAutoDecline = true;
        return reqToDisplay;
    }
    
    private List<DemoRequestWrapper> getAllRequests() {
        reqToDisplay.clear();
        buildIdLists();
        buildWrappers(allRequestIds);
        return reqToDisplay;
    }
    
    private void buildWrappers(List<Id> displayIds){
        String queryString = 'SELECT Id, Name, QueueName__c, State__c, Requester_Name__c, Requester_Company__c, Demo_Date_Time__c, ' + 
            'Demo_Time_Length__c, Demo_Location__c, Opportunity__c, Account__c, Opportunity__r.Name, Request_Type__c, Account__r.Name, ' +
            'AudienceType__c FROM Demo_Request__c WHERE Id IN :displayIds ORDER BY ';
        queryString += sortStrings.get(selectedSort);
        availableRequests = Database.query(queryString);
        
        req2Plats = DemoRequestClass.GetRequestRelatedPlatforms(displayIds);
        req2Prods = DemoRequestClass.GetRequestRelatedProducts(displayIds);
        req2GenCons = DemoRequestClass.GetRequestRelatedGenCons(displayIds);
        req2Ints = DemoRequestClass.GetRequestRelatedIntegrations(displayIds);
        leftToDecline = DemoRequestUtility.GetNumLeftToDecline(availableRequests, queue);
        
        for(Demo_Request__c r : availableRequests){
            reqToDisplay.add(new DemoRequestWrapper(r, req2Plats.get(r.Id), req2Prods.get(r.Id), req2GenCons.get(r.Id), req2Ints.get(r.Id), leftToDecline.get(r.Id)));
        }
    }
    
    private void buildIdLists(){
        Set<String> activeState = DemoRequestUtility.activeDemoStates;
        allRequestIds.clear();
        
        List<Demo_Request__c> allRequests = [SELECT Id, Name FROM Demo_Request__c WHERE State__c IN :activeState and QueueName__c = :queue]; //get all demos in an active state
            
        //Get all IDs for demos in an active state
        for(Demo_Request__c d : allRequests){
            allRequestIds.add(d.Id);
        }
        
        //Get all declines records for the active demos
        List<Demo_Request_Decline__c> allDeclines = [SELECT Demo_Request_ID__c, Id, User_Name__c, Decline_Reason__c FROM Demo_Request_Decline__c WHERE Demo_Request_ID__c IN : allRequestIds];
        
        Set<Id> userDeclinedRequest = new Set<Id>();
        Set<Id> declinedRequestIds = new Set<Id>();            
        for(Demo_Request_Decline__c dec: allDeclines){
            //if the current user matches a decline add the demo request ID to the set
            if(dec.User_Name__c == userinfo.getUserId()){
                userDeclinedRequest.add(dec.Demo_Request_ID__c);
                if(dec.Decline_Reason__c == 'Auto-Declined by Calendar'){
                    autoDeclinedIds.add(dec.Demo_Request_ID__c);
                }
            }
            //get all of the Request ID that have declines
            declinedRequestIds.add(dec.Demo_Request_ID__c);
        }                
        
        for(Id i : allRequestIds){
            //If user has not declined request or there are no declines for the request, add it to list to display
            if(!userDeclinedRequest.contains(i) || !declinedRequestIds.contains(i)){
                requestsToDisplay.add(i);
            }
        }
    }
}