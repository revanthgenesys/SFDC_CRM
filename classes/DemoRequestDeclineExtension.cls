public class DemoRequestDeclineExtension {
	private final Demo_Request__c req;
    private final Map<String, Id> presenters;
    private Set<Id> tsc { get; set; }
    private Set<String> TSCNames { get; set; }
    private Set<String> declinedNames { get; set; }
    
    private Boolean possibleLastTSC { get; set; } { possibleLastTSC = false; }
    
    public Integer tscCount { get; set; } { tscCount = 0; }
    
    public final List<Demo_Request_Decline__c> declines { get; set; }
    public final List<Demonstration_Presenter__c> undeclined { get; set; } 
    
    public Boolean showNotAbleToDecline { get; set; }
    public Boolean showDeclineInfo { get; set; }
    public Boolean showPersonSelection { get; set; }
    public Boolean lastTSCDecline { get; set; } { lastTSCDecline = false; }
    public Boolean lastDecline { get; set; } { lastDecline = false; }
    public Boolean canDeclineSelf { get; set;}
    public List<SelectOption> declineReasons { get; set; }
    public String declineReason { get; set; }
    public String rescheduleDate { get; set; }
    public String rescheduleTime { get; set; }
    private DateTime parsed { get; private set; }
    public String selectedPerson { get; set; }
    public List<SelectOption> displayUndeclinedUsers { get; set;}
    public String comments { get; set; }
    
    public String demoDate { get; set; }
    public String demoTime { get; set; }
    
    public Demo_Request_Decline__c dec { get; set; }
        
    public DemoRequestDeclineExtension(ApexPages.StandardController stdController) {
        if(!test.isRunningTest())
        	stdController.addFields(new List<String>{'State__c', 'Org_URL__c', 'Chatter_Feed_ID__c', 'Id', 'Requester_Email_Addr__c', 'SuppressNotification__c',
                'Demo_Date_Time__c', 'Requested_Timezone__c', 'Account__c', 'Account__r.Name', 'Lead__c', 'Lead__r.Name', 'Name', 'Demo_Time_Length__c', 'CompanyName__c',
                'LastModifiedDate', 'QueueName__c'});
        this.req = (Demo_Request__c)stdController.getRecord();

        //remove in a month or so
        DemoRequestUtility.defaultQueue(req);
        
        
        demoDate = req.Demo_Date_Time__c.format('MM/dd/yyyy');
        demoTime = req.Demo_Date_Time__c.format('hh:mm a');
        
        showNotAbleToDecline = DemoRequestUtility.unavailableStates.contains(req.State__c);
        showPersonSelection = !showNotAbleToDecline;
        
        if(!showNotAbleToDecline) {
            dec = new Demo_Request_Decline__c();
            
            declineReasons = new List<SelectOption>();
            for(String r : DemoRequestUtility.DeclineReasons){
                declineReasons.add(new SelectOption(r,r));
            }

            tsc = DemoRequestUtility.GetTSCsIds(req.QueueName__c);

            Set<Id> allTS = DemoRequestUtility.getDeclinersIDs(req.QueueName__c);          
            
            declines = [SELECT User_Name__c, Decline_Reason__c FROM Demo_Request_Decline__c WHERE Demo_Request_ID__c = :req.Id AND User_Name__c IN :allTS];
        	
            declinedNames = new Set<String>();
            for(Demo_Request_Decline__c d : declines){
                declinedNames.add(d.User_Name__c);
            }
            
            if(declinedNames.contains(UserInfo.getUserId()) || !allTs.contains(UserInfo.getUserId())){
                canDeclineSelf = false;
            } else {
                canDeclineSelf = true;
            }
            
            
            //Get all TSC Names to limit presenters
            List<User> members = [Select Name, Id from User where Id in :allTS];
            TSCNames = new Set<String>();
            for(User u : members) {
                if(tsc.contains(u.Id)) TSCNames.add(u.Name);
            }
            //Map Name to resolve after User selects decline person
            undeclined = [Select User_Name__c, Display_Name__c from Demonstration_Presenter__c where User_Name__c not in :declinedNames AND User_Name__c IN :allTs AND QueueName__c = :req.QueueName__c];
            presenters = new Map<String, Id>();
            displayUndeclinedUsers = new List<SelectOption>();
            for(Demonstration_Presenter__c p : undeclined){
                presenters.put(p.Display_Name__c, p.User_Name__c);
                displayUndeclinedUsers.add(new SelectOption(p.Display_Name__c, p.Display_Name__c));
            }

            if(declinedNames.size() == allTS.size() - 1) {
                lastDecline = true;
            }

        }
    }
    
    public void selectSelf() {
        selectedPerson = UserInfo.getName();
        //Count TSC declines
        for(Id name : tsc) {
            if(declinedNames.contains(name)) tscCount++;
        }
        if(tsc.size() - 1 == tscCount && TSCNames.contains(selectedPerson)) {
            lastTSCDecline = true;
        }
        showDeclineInfo=true;
        showPersonSelection=false;
    }
    
    public void selectPerson() {
        //Count TSC declines
        for(Id name : tsc) {
            if(declinedNames.contains(name)) tscCount++;
        }
        if(tsc.size() - 1 == tscCount && TSCNames.contains(selectedPerson)) {
            lastTSCDecline = true;
        }
        showDeclineInfo=true;
        showPersonSelection=false;
    }
    
    public PageReference submitDecline() {
        if(!DemoRequestClass.checkLastModified(req)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Request has been recently modified, please verify you still want to decline and try again.'));
            PageReference demo = new PageReference('/apex/DemoRequestDecline?id=' + req.Id);
            demo.setRedirect(true);
            return demo;
        }
        if(checkDemoDateInFuture()) return null;
        Demo_Request_Decline__c d = new Demo_Request_Decline__c();
        d.Demo_Request_ID__c = req.Id;
        d.Decline_Reason__c = declineReason;
        d.Decline_Comments__c = comments;
        d.User_Name__c = presenters.get(selectedPerson);
        if(parsed != null && parsed != req.Demo_Date_Time__c)
            d.Alternate_Date_Time_Available__c = parsed;
        DemoRequestClass.DeclineDemos(new List<Demo_Request_Decline__c>{d});

        if(req.State__c == 'Pending Approval') {
            //not changing state for approval process.
        } else if(lastDecline) {
            //send decline
            DemoRequestClass.SetToDeclined(new List<Demo_Request__c>{req});
        } else if(lastTSCDecline) {
            //escalate
            DemoRequestClass.SetToEscalate(new List<Demo_Request__c>{req});
        } else if(req.State__c != 'Escalated')
        	DemoRequestClass.SetToInReview(new List<Demo_Request__c>{req});
        
        showDeclineInfo=false;
        //if selecting PTO or appt for decline reason, redirect to cal to create that blocking event
        if(selectedPerson == UserInfo.getName() && (declineReason == 'PTO' || declineReason == 'Personal Appointment')){
            PageReference demo = new PageReference('/00U/e?aid='+UserInfo.getUserId()+'&anm=' + UserInfo.getFirstName() + '+' + UserInfo.getLastName() + '&evt5=' + declineReason + '&ShowAs=Busy');
            demo.setRedirect(true);
            
            return demo;
        }
        return DemoRequestUtility.returnToDemo(req);
    }
    
    private Boolean checkDemoDateInFuture() {
        DateTime current = DateTime.newInstanceGmt(DateTime.now().dateGmt(), DateTime.now().timeGmt());
        if(rescheduleDate != null && rescheduleTime != null && rescheduleDate.length() == 0 && rescheduleTime.length() == 0) return false;
        if(rescheduleDate != null && rescheduleDate.length() == 0) return false;
        try{
            if(rescheduleTime != null && rescheduleTime.length() > 1 && rescheduleTime != null && rescheduleTime.length() > 1) {
                parsed = Datetime.parse(rescheduleDate+' '+rescheduleTime);
            } else if(rescheduleTime != null && rescheduleTime.length() > 1) {
                Date original = Date.newInstance(req.Demo_Date_Time__c.year(), req.Demo_Date_Time__c.month(), req.Demo_Date_Time__c.day());
                DateTime t = DateTime.parse('01/01/2000 ' + rescheduleTime);
                parsed = Datetime.newInstanceGmt(original, t.timeGmt());
            }
            if(parsed < current) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a time in the future'));
                return true;
            }
            return false;
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in parsing datetime. Please use MM/dd/yyyy and HH:mm AM/PM. e.g. 07/15/2015 11:00 AM'));
            return true;
        }
    }
    
}