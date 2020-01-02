public with sharing class DemoRequestRescheduleExtension {
    
    public final Demo_Request__c req { get; set; }
    public final Demo_Request__c orig;
    
    public Boolean canReschedule { get; set; }
    public Boolean cannotReschedule { get; set; }
    public Boolean showReschedule { get; set; }
    public Boolean showAvailability { get; set; }
    public Boolean showDecline { get; set; }
    public Boolean showHQ { get; set; }
    public Boolean showOnsite { get; set; }
    public Boolean showRescheduleAndAccept { get; set; }
    public String rDate { get; set; }
    public String rTime { get; set; }
    private DateTime demoDateTime { get; set; }
    public List<SelectOption> timezones { get; set; }
    public String timezone { get; set; }
    public List<SelectOption> rescheduleReasons { get; set; }
    public String rescheduleReason { get; set; }
    public List<SelectOption> locationOptions { get; set; }
    public String demoLocation { get; set; }
    public List<SelectOption> queueOptions { get; set; } 
    
    public Integer tscCount { get; set; }
    public Integer tscProgress { get; set; }
    
    public Boolean isTSMember { get { return DemoRequestUtility.getAllTSIds().contains(UserInfo.getUserId()); } }
    public Boolean suppressNotifications { get; set; }
    
    public String onsiteMeetingRoom { get; set; }
    public String onsiteJustify { get; set; }
    public String onsiteDemoLocation { get; set; }
    
    public String declineDate { get; set; }
    public String declineTime { get; set; }
    public String declineComments { get; set; }
    public String declineReason { get; set; }
    public List<SelectOption> declineReasons { get; private set; } { 
        declineReasons = new List<SelectOption>();
        for(String a : DemoRequestUtility.DeclineReasons) {
            declineReasons.add(new SelectOption(a, a));
        }
    }
    public String origDate { get; set; } 
    public String origTime { get; set; } 
    public String userName { get { return UserInfo.getFirstName() + ' ' + UserInfo.getLastName(); } }
    
    public DemoRequestRescheduleExtension(ApexPages.StandardController stdController) {
        if(!test.isRunningTest())
            stdController.addFields(new List<String>{'State__c', 'QueueName__c', 'SuppressNotification__c', 'Org_URL__c', 'Demo_Date_Time__c', 'Requested_Timezone__c', 'Demo_Time_Length__c',
                'Chatter_Feed_ID__c', 'Reschedule_Reason__c', 'Requester_Email_Addr__c', 'CompanyName__c', 'Account__r.Name', 'Lead__r.Name', 'Lead__c', 'Account__c', 
                'Demo_Owner__c', 'Requester_Name__c', 'OnSite_Justification__c', 'On_site_Location__c', 'Demo_Location__c', 'HQ_Meeting_Room__c','LastModifiedDate'});
        req = (Demo_Request__c)stdController.getRecord();
        orig = req.clone(true, true, true, true);
        
        origDate = req.Demo_Date_Time__c.format('yyyy-MM-dd');
        origTime = req.Demo_Date_Time__c.format('HH:mm');
        
        if(!DemoRequestUtility.unschedulableStates.contains(req.State__c)) {
            canReschedule = true;
            showReschedule = true;
        } else cannotReschedule = true;
        
        demoLocation = req.Demo_Location__c;
        onsiteMeetingRoom = req.HQ_Meeting_Room__c;
        onsiteJustify = req.OnSite_Justification__c;
        onsiteDemoLocation = req.On_site_Location__c;
        getLocationDetails();
        
        timezones = DemoRequestUtility.populateSelectOptions(new List<string>(DemoRequestUtility.timezones));
        rescheduleReasons = DemoRequestUtility.populateSelectOptions(new List<string>(DemoRequestUtility.rescheduleReasons));
        locationOptions = DemoRequestUtility.populateSelectOptions(new List<string>(DemoRequestUtility.demoLocations));
        queueOptions = DemoRequestUtility.populateSelectOptions(new List<string>(DemoRequestUtility.queueNames));

        suppressNotifications = req.SuppressNotification__c;
    }
    
    public void checkAvail() {
        if(checkDemoDateInFuture()) return;
        if(checkLocationValid()) return;
        if(checkRescheduleReason()) return;
        DateTime current = DateTime.newInstanceGmt(DateTime.now().dateGmt(), DateTime.now().timeGmt());
        if(demoDateTime < current.addDays(1)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                                                       'Be aware that requests with less than 24 hours have a low likelihood of being accepted. Please try to give us three business days notice when submitting requests.'));
        }
        showAvailability = true;
        showReschedule = false;
        tscCount = DemoRequestUtility.GetNumTscAvailable(demoDateTime, req.Demo_Time_Length__c, req.QueueName__c);
        Integer tscTotal = DemoRequestUtility.GetTSCsIds(req.QueueName__c).size();
        double temp = ((double)tscCount/(double)tscTotal)*100;
        tscProgress = (Integer) temp;
        if(isTSMember && demoLocation != 'On-site (Requires Approval)') showRescheduleAndAccept = true;
    }
    
    private Boolean checkDemoDateInFuture() {
        try {
            demoDateTime = DemoRequestUtility.ConvertTimeToGmt(DateTime.valueOfGMT(rDate+' '+rTime+':00'), timezone);
            DateTime current = DateTime.newInstanceGmt(DateTime.now().dateGmt(), DateTime.now().timeGmt());
            if(demoDateTime < current) {
                if(isTSMember) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The selected time is in the past'));
                    return false;
                } 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a time in the future'));
                return true;
            }
            if(!isTSMember){
                DateTime estTime = DemoRequestUtility.ConvertTimeFromGmt(demoDateTime, 'GMT–05:00 Eastern Standard Time (America/Indiana/Indianapolis)');
                if(estTime.hourGMT() < 6 || estTime.hourGMT() > 18) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This time converts to ' + estTime.formatGMT('HH') + 
                                                               ':' + estTime.formatGMT('mm') + ' in the Eastern timezone. Please consider making the request to be 7:00 to 19:00 in EST.' +
                                                               ' If your requests cannot be moved to within the requested range, please understand that consultant availability will be extremely limited.'));
                }
            }
            return false;
        } catch(Exception e) {
            system.debug(e.getLineNumber() + '  ' + e.getMessage() + '  ' + e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The date or time format is incorrect'));
            return true;
        }
    }
    
    private Boolean checkLocationValid() {
        if(orig.Demo_Location__c != demoLocation) {
            if(demoLocation == 'ININ HQ Campus' && String.isEmpty(onsiteMeetingRoom)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                	'Meeting Room needs a value.'));
                return true;
            }
            if(demoLocation == 'On-site (Requires Approval)' && (String.isEmpty(onsiteJustify) || String.isEmpty(onsiteDemoLocation))) {
               system.debug('justify ' + onsiteJustify + '  location ' + onsiteDemoLocation);
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                	'Onsite information is required.'));
                return true;
            }
        }
        system.debug('Location was valid');
        return false;
    }
    
    private Boolean checkRescheduleReason() {
        if(String.IsBlank(rescheduleReason)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                	'Please select a reschedule reason.'));
            return true;
        } return false;
    }
    
    public void resetTime() {
        showAvailability = false;
        showReschedule = true;
    }
    
    public PageReference submit(){
        if(rescheduleLogic()) return null;
        return DemoRequestUtility.returnToDemo(req);
    }
    
    public PageReference submitAccept() {
        if(checkDemoDateInFuture()) return null;
        if(checkLocationValid()) return null;
        if(checkRescheduleReason()) return null;

        req.Demo_Date_Time__c = demoDateTime;
        req.Requested_Timezone__c = timezone;
        req.Reschedule_Reason__c = rescheduleReason;
        req.SuppressNotification__c = suppressNotifications;
        req.Demo_Owner__c = Userinfo.getUserId();
        locationLogic();
        DemoRequestClass.RescheduleAndAccept(new Map<Demo_Request__c, DateTime>{req => demoDateTime}, new Map<Id, Demo_Request__c>{req.Id => orig});
        return DemoRequestUtility.returnToDemo(req);
    }
    
    public void submitDecline() {
        if(rescheduleLogic()) return;
        rDate = demoDateTime.format('MM/dd/yyyy');
        rTime = demoDateTime.format('HH:mm');
        showDecline = true;
        showReschedule = false;
        showAvailability = false;
    }
    
    public PageReference submitDeclineFinal() {
        if(declineLogic()) return null;
        return DemoRequestUtility.returnToDemo(req);
    }
    
    private Boolean rescheduleLogic() {  
        if(checkDemoDateInFuture()) return true;
        if(!DemoRequestClass.checkLastModified(req)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Request has been recently modified, please verify you still want to reschedule and try again.'));
            return null;
        }
        req.Demo_Date_Time__c = demoDateTime;
        req.Requested_Timezone__c = timezone;
        req.Reschedule_Reason__c = rescheduleReason;
        req.SuppressNotification__c = suppressNotifications;
        locationLogic();
        Boolean runApproval = DemoRequestClass.checkIfShouldRunApproval(req) && orig.Demo_Location__c != demoLocation;
        if(runApproval) req.State__c = 'Pending Approval';
        DemoRequestClass.RescheduleDemos(new Map<Demo_Request__c, DateTime>{req => demoDateTime}, new Map<Id, Demo_Request__c>{req.Id => orig});
        if(runApproval) DemoRequestClass.createApprovalProcess(req);
        return false;
    }
    
    private void locationLogic() {
        req.Demo_Location__c = demoLocation;
        req.HQ_Meeting_Room__c = onsiteMeetingRoom;
        req.OnSite_Justification__c = onsiteJustify;
        req.On_site_Location__c = onsiteDemoLocation;
    }
    
    public Boolean declineLogic() {
        try {
            if(declineDate.length() != 0 && declineTime.length() != 0)
                DateTime.parse(declineDate+' '+declineTime);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a time in the future'));
            return true;
        }
        Demo_Request_Decline__c d = new Demo_Request_Decline__c();
        d.Demo_Request_ID__c = req.Id;
        d.Decline_Reason__c = declineReason;
        //if date/time are empty and not same as demo time
        if(declineDate.length() != 0 && declineTime.length() != 0) {
            DateTime parsed = DateTime.parse(declineDate+' '+declineTime);
            if(parsed != req.Demo_Date_Time__c) d.Alternate_Date_Time_Available__c = parsed;
        }
        d.User_Name__c = UserInfo.getUserId();
        DemoRequestClass.DeclineDemos(new List<Demo_Request_Decline__c>{d});
        return false;
    }
    
    public void getLocationDetails() {
        showHQ = demoLocation == 'ININ HQ Campus';
        showOnsite = demoLocation == 'On-site (Requires Approval)';
    }
}