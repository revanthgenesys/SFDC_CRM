public class DemoRequestMyDemosController {
    
    public List<DemoRequestWrapper> reqWithRelated { get; set; }
    public List<SelectOption> statusFilter { get; set; } 
    public String selectedState { get; set; }
    private List<String> filterStates = new List<String>{'Upcoming', 'Ready to Track'};
    private List<String> queryStates = new List<String>{'Accepted', 'Completed'};
    private List<String> allQueryStates = new List<String>{'Upcoming', 'Ready to Track', 'Accepted', 'Completed'};
    private list<String> activityTypes = new List<String>{'Demo', 'Tradeshow','Demo Training'};
    private List<Demo_Request_Tracking__c> tracking = new List<Demo_Request_Tracking__c>();
    private List<Demo_Request__c> allRequests = new List<Demo_Request__c>();
    private List<Demo_Request__c> myRequests = new List<Demo_Request__c>();
    private Map<Id, Demo_Request_Tracking__c> reqToTrack = new Map<Id, Demo_Request_Tracking__c>();
    
    
    public DemoRequestMyDemosController() { 
        statusFilter = new List<SelectOption>();
        for(string i : filterStates){
            statusFilter.add(new SelectOption(i,i));
        }
        
        String start = ApexPages.currentPage().getParameters().get('pageFilter');
        if(start != null) {
            selectedState = start;
        } else {
            selectedState = 'Upcoming';
        }
        
        tracking = [SELECT Demo_Request__c, Activity_State__c, Activity_Date_Time__c FROM Demo_Request_Tracking__c WHERE Activity_Type__c IN :activityTypes AND Activity_Completed_By__c = :Userinfo.getUserId() AND Activity_State__c != 'Completed'];
        System.debug('############################################################################################ Number of tracking records returned: ' + tracking.size() + ' for User: ' + Userinfo.getName() + ' [' + Userinfo.getUserId() + ']');
        for(Demo_Request_Tracking__c t : tracking){
            reqToTrack.put(t.Demo_Request__c, t);
        }
        allRequests = [SELECT Id, Name, State__c, Demo_Time_Length__c, Requester_Name__c, Requester_Company__c, Demo_Date_Time__c, On_site_Location__c, Opportunity__c, Account__c, Opportunity__r.Name, Account__r.Name, Demo_Owner__c FROM Demo_Request__c WHERE Id IN :reqToTrack.keySet() AND State__c IN :queryStates ORDER BY Demo_Date_Time__c ASC];
        //myRequests  = [SELECT Id, Name, State__c, Demo_Time_Length__c, Requester_Name__c, Requester_Company__c, Demo_Date_Time__c, On_site_Location__c, Opportunity__c, Account__c, Opportunity__r.Name, Account__r.Name, Demo_Owner__c FROM Demo_Request__c WHERE I
        System.debug('############################################################################################ Number of demo records returned: ' + allRequests.size());
        getRequestWrappers();
    }
    
    public List<DemoRequestWrapper> getRequestWrappers(){
        reqWithRelated = new List<DemoRequestWrapper>();
        List<Demo_Request__c> filteredRequests = new List<Demo_Request__c>();
        List<Id> reqIds = new List<Id>();
        DateTime now = DateTime.now();
        System.debug('############################################################################################ Number of records in loop: ' + allRequests.size());
        for(Demo_Request__c d : allRequests){
            Demo_Request_Tracking__c track = reqToTrack.get(d.Id);
            if(selectedState == 'Upcoming' && track.Activity_Date_Time__c >= now){
                filteredRequests.add(d);
                reqIds.add(d.Id);
                System.debug('############################################################################################ Demo Request ID added to UPCOMING list: ' + d.Name);
            } else if (selectedState == 'Ready to Track' && track.Activity_Date_Time__c < now){
                filteredRequests.add(d);
                reqIds.add(d.Id);
                System.debug('########## Demo Request ID added to Ready to Track: ' + d.Name);
            } else {
                System.debug('############################################################################################ No match found.  Activity Date/Time: ' + track.Activity_Date_Time__c + ' Activity State: ' + track.Activity_State__c + ' Selected State: ' + selectedState + ' Demo Request ID: ' + d.Name);
            }
        }
        System.debug('############################################################################################ Number of records returned: ' + filteredRequests.size());
        Map<Id, List<String>> req2Plats = DemoRequestClass.GetRequestRelatedPlatforms(reqIds);
        Map<Id, List<String>> req2Prods = DemoRequestClass.GetRequestRelatedProducts(reqIds);
        Map<Id, List<String>> req2GenCons = DemoRequestClass.GetRequestRelatedGenCons(reqIds);
        Map<Id, List<String>> req2Ints = DemoRequestClass.GetRequestRelatedIntegrations(reqIds);
        
        for(Demo_Request__c r : filteredRequests){
            reqWithRelated.add(new DemoRequestWrapper(r, req2Plats.get(r.Id), req2Prods.get(r.Id), req2GenCons.get(r.Id), req2Ints.get(r.Id), 0));
        }
        
        return reqWithRelated;
    }
    
    public void refresh(){
        getRequestWrappers();
    }

}