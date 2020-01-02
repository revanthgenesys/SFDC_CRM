public class DemoRequestSubmissionController {
    
    public Demo_Request__c req { get; private set; }
    public DemoRequestBuilder drb { get; set; }
    public DemoRequestRelatedItems drl { get; set; }
    
    public Boolean showYourInformation { get; set; }
    public Boolean showClientInformation { get; set; }
    public Boolean showLinkedOppurtunities { get; set; }
    public Boolean showDemoInformation { get; set; }
    public Boolean showSelectPlatform { get; set; }
    public Boolean showItems { get; set; }
    public Boolean showSchedule { get; set; }
    public Boolean showVerifySchedule { get; set; }
    public Boolean showAvailability { get; set; }
    public Boolean showOnsite { get; set; }
    public Boolean showHQ { get; set; }
    public Boolean showVerifyInformation { get; set; }
    public Boolean showFinished { get; set; }
    private Boolean fromAccount { get; set; }    
    public Boolean showCompanyName { get; set; }
    public Boolean showNavigation { get; set; }
    public Boolean showReturnClient { get; set; }
    public Boolean showReturnDemo { get; set; }
    public Boolean showReturnSchedule { get; set; }
    public Boolean showReturnVerify { get; set; }
    public Boolean showAltTimes { get; set; }
    
    public Boolean showDecline { get; set; }
    public Boolean showSubmitAndDecline { get; private set; } { showSubmitAndDecline = false; }
    public Boolean showSubmitAndAccept { get; private set; } { showSubmitAndAccept = false; }
    public Boolean showSubmitAndComplete { get; private set; } { showSubmitAndComplete = false; }
    
    public Boolean isTSMember { get; set; }
    public Boolean isPartner { get; set; }
    
    public SelectOption[] audienceTypeOptions { get; set; } { audienceTypeOptions = new SelectOption[]{}; }
    public SelectOption[] queueOptions { get; set; } { queueOptions = new SelectOption[]{}; }
    public SelectOption[] requestTypeOptions { get; set; } { requestTypeOptions = new SelectOption[]{}; }
    public SelectOption[] verticalOptions { get; set; } { verticalOptions = new SelectOption[]{}; }
    public SelectOption[] competitorOptions { get; set; } { competitorOptions = new SelectOption[]{}; }
    public SelectOption[] locationOptions { get; set; } { locationOptions = new SelectOption[]{}; }
    public SelectOption[] timezoneOptions { get; set; } { timezoneOptions = new SelectOption[]{}; }
    
    public SelectOption[] selectedCompetitors { get; set; } { selectedCompetitors = new SelectOption[]{}; }
    public SelectOption[] opportunityOptions { get; set; } { opportunityOptions = new SelectOption[]{}; }
    
    public List<String> altTimes { get; set; } {altTimes = new List<String>(); }

    public String selectedLinkedOpp { get; set; }
    public String selectedCompetitorsDisplay { get; set;  }
    
    public Integer tscCount { get; set; }
    public Integer tscProgress { get; set; }
    public Integer allTsCount { get; set; }
    public String demoDate { get; set; }
    public String demoTime { get; set; }
    public String demoDateTimeDisplay { get { return demoDate + ' ' + demoTime; } }
    public Integer demoDurationHours { get; set; } { demoDurationHours = 1; }
    public Integer demoDurationMinutes { get; set; } { demoDurationMinutes = 0;}
    
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
    
    public String userName { get { return UserInfo.getFirstName() + ' ' + UserInfo.getLastName(); } }
    
    public DemoRequestSubmissionController() {
        Map<String,String> param = ApexPages.currentPage().getParameters();
        drb = new DemoRequestBuilder();
        drl = new DemoRequestRelatedItems();
        if(UserInfo.getUserType() != 'Guest')
            drb.withRequester(UserInfo.getUserId());
        fromAccount = false;
        
        Id i = param.get('id');
        if(i != null) {
            SObjectType ty = i.getSobjectType();
            String name = ty.getDescribe().getName();
            
            if(name == 'Account') {
                drb.withAccount(i);
                fromAccount = true;
            } else if (name == 'Opportunity') {
                drb.withOpportunity(i);
            } else if (name == 'Lead') {
                drb.withLead(i);
            } else {
                showCompanyName = true;
            }
        } else {
            showCompanyName = true;
        }
        
        if(DemoRequestUtility.getAllTSIds().contains(UserInfo.getUserId())) isTSMember = true;
        else isTSMember = false;
        if(UserInfo.getUserType() == 'PowerPartner') isPartner = true;
        
        buildSelections();
        buildCompetitors();
        showYourInformation = true;
        showAltTimes = false;
    }
    
    public void submitRequestor() {
        showYourInformation = false;
        buildRequestTypes();
        if(fromAccount) {
            showLinkedOppurtunities = true;
            List<Opportunity> opps = [Select Id, Name from Opportunity where AccountId = :drb.acct and CloseDate > :Date.today()];
            opportunityOptions = new List<SelectOption>();
            opportunityOptions.add(new SelectOption('No', 'No'));
            for(Opportunity o : opps) {
                opportunityOptions.add(new SelectOption(o.Id, o.Name));
            }
            if(opps.size() > 0) return;
        }
        if(drb.audienceType == 'Internal') {
            drb.withInternalAccount();
            showCompanyName = false;
        }
        showLinkedOppurtunities = false;
        showClientInformation = true;
        showNavigation = true;
    }
    
    public void submitClient() {
        showClientInformation = false;
        for(SelectOption s : selectedCompetitors) {
            drb.selectedCompetitors.add(s.getValue());
        }
        selectedCompetitorsDisplay = DemoRequestUtility.stringify(selectedCompetitors);
        showDemoInformation = true;
        showSelectPlatform = true;
        showReturnClient = true;
    }
    
    public void submitLinkedOpp() {
        if(selectedLinkedOpp != 'No') {
            drb.withOpportunity(selectedLinkedOpp);
            buildCompetitors();
        }
        showLinkedOppurtunities = false;
        showClientInformation = true;
        showNavigation = true;
    }
    
    public void submitItems() {
        if(checkDemoItems()) return;
        drl.updateDisplay();
        showDemoInformation = false;
        showSchedule = true;
        showReturnDemo = true;
        showNavigation = true;
    }
    
    private void dateTimeErrorMessage() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The date/time fields are invalid. Please use the formats: yyyy-mm-dd and hh:mm '));
    }
    
    private Boolean invalidDemoSchedule(){
        if(checkLocationFields()) return true;  
        try {
            Integer hours = Integer.valueOf(demoTime.substring(0,2));
            Integer minutes = Integer.valueOf(demoTime.substring(demoTime.indexOf(':')+1,demoTime.length()));                           
            if(hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
                dateTimeErrorMessage();
                return true;
            }
            
            drb.demoDateTime = DemoRequestUtility.ConvertTimeToGmt(DateTime.valueOfGMT(demoDate + ' ' + demoTime + ':00'), drb.demoTimezone);
            if(checkDemoDateInFuture()) return true;
            //DateTime current = DateTime.newInstanceGmt(DateTime.now().dateGmt(), DateTime.now().timeGmt());
            if(DemoRequestUtility.EscalateForRequestedTime(drb.demoDateTime)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                'Be aware that requests with less than one business day notice have a low likelihood of being accepted. Please try to give us three business days notice when submitting requests.'));
            }
        } catch (Exception e) {
            dateTimeErrorMessage();
            return true;
        }
        
        //round to 2 sig digits
        drb.demoDuration = Math.round(((double)demoDurationHours + (double)demoDurationMinutes/60)*100)/100.0;
        Integer tscTotal = DemoRequestUtility.GetTSCsIds(drb.queue).size();
        tscCount = DemoRequestUtility.GetNumTscAvailable(drb.demoDateTime, drb.demoDuration, drb.queue);
        allTsCount = DemoRequestUtility.GetNumUsersAvailable(drb.demoDateTime, drb.demoDuration, drb.queue);
        system.debug('Queue: ' + drb.queue);
        system.debug('Available tscs: ' + allTsCount);
        system.debug('All Available tscs: ' + tscCount);
        system.debug('Total ts: ' + tscTotal);
        if(tscCount == 0 && !isTSMember) {
            drb.allTscDeclined = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                                                       'Unfortunately, there are no available resources for the time you have requested. Please select a new Date or Time for your request.  If you feel your request cannot be moved to a different Date or Time, please contact Techincal Marketing directly.'));
        }
        if(tscCount-1 < tscTotal/2) {
            showAltTimes = true;
            List<DateTime> times = DemoRequestUtility.getAlternativeTimeSuggestions(drb.demoDateTime, drb.demoDuration, drb.queue);
            altTimes.clear();
            for(DateTime t : times){
               altTimes.add(t.format());
            }
        } else showAltTimes = false;
        if(allTsCount == 0) drb.allTsDeclined = true;
        double temp = ((double)tscCount/(double)tscTotal)*100;
        tscProgress = (Integer) temp;
        system.debug('TSC Progress: ' + tscProgress);
        
        if(drb.demoLocation != 'On-site (Requires Approval)' && isTSMember) {
            showSubmitAndAccept = true;
            showSubmitAndComplete = true;
        }
        
        return false;
    }
    
    public void checkAvail() {
        if(invalidDemoSchedule()) return;
        showSchedule = false;
        showVerifySchedule = true;
        showAvailability = true;
        showReturnSchedule = true;
    }
    
    public void resetSchedule() {
        showVerifySchedule = false;
        showSchedule = true;
    }
    
    public void getLocationDetails() {
        showHQ = drb.demoLocation == 'ININ HQ Campus';
        showOnsite = drb.demoLocation == 'On-site (Requires Approval)';
    }
    
    public void submitWhen() {
        if(invalidDemoSchedule()) return;
        showSchedule = false;
        showVerifySchedule = false;
        showAvailability = true;
        showReturnSchedule = true;
        showVerifyInformation = true;
        showReturnVerify = true;
    }
    
    public void submitVerify() {
        drb.demoDateTime = DemoRequestUtility.ConvertTimeToGmt(DateTime.valueOfGMT(demoDate + ' ' + demoTime + ':00'), drb.demoTimezone);
        showVerifyInformation = false;
        req = drb.build();
        drl.setDemo(req);
        drl.saveChanges();
        showFinished = true;
        showNavigation = false;
    }
    
    public void submitVerifyAccept() {
        submitVerify();
        //requery to get chatter feed id
        req = [Select Demo_Owner__c, Id, State__c, Demo_Owner_Signature__c, Demo_Owner_Email__c, Opportunity__c, Account__c, Chatter_Feed_ID__c, Demo_Date_Time__c, Demo_Time_Length__c, Other_Applications__c From Demo_Request__c where Id = :req.Id];
        DemoRequestClass.AcceptDemos(new Map<Demo_Request__c, Id>{req => UserInfo.getUserId()});
    }
    
    public void submitVerifyDecline() {
        submitVerify();
        showFinished = false;
        showDecline = true;
    }
    
    public void submitDecline() {
        try {
            if(declineDate.length() != 0 && declineTime.length() != 0)
                DateTime.parse(declineDate+' '+declineTime);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a time in the future'));
            return;
        }
        Demo_Request_Decline__c d = new Demo_Request_Decline__c();
        d.Demo_Request_ID__c = req.Id;
        d.Decline_Reason__c = declineReason;
        if(declineDate.length() != 0 && declineTime.length() != 0) {
            DateTime parsed = DateTime.parse(declineDate+' '+declineTime);
            if(parsed != drb.demoDateTime) d.Alternate_Date_Time_Available__c = parsed;
        }
        
        d.User_Name__c = UserInfo.getUserId();
        DemoRequestClass.DeclineDemos(new List<Demo_Request_Decline__c>{d});
        showFinished = true;
        showDecline = false;
    }
    
    public PageReference submitVerifyComplete() {
        submitVerifyAccept();
        PageReference page = new PageReference('/apex/DemoRequestActivityTracking?demo=t&id=' + req.Id);
        page.setRedirect(true);
        return page;
    }
    
    public void backToRequestor() {
        clearViews();
        showYourInformation = true;
    }
    
    public void backToClient() {
        clearViews();
        showClientInformation = true;
    }
    
    public void backToItems() {
        clearViews();
        showDemoInformation = true;
        showItems = true;
    }
    
    public void backToSchedule() {
        clearViews();
        showVerifySchedule = true;
    }
    
    public void backToVerify() {
        if(checkPlatform()) return;
        if(checkDemoItems()) return;
        if(checkDemoDateInFuture()) return;
        clearViews();
        showVerifyInformation = true;
    }
    
    private void clearViews() {
        showSchedule = false;
        showDemoInformation = false;
        showItems = false;
        showSelectPlatform = false;
        showYourInformation= false;
        showClientInformation = false;
        showVerifySchedule = false;
        showVerifyInformation = false;
    }
    
    private Boolean checkLocationFields() {
        if(drb.demoLocation == 'On-site (Requires Approval)' && (drb.onsiteDemoLocation == '' || drb.onsiteJustify == '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify a location and justification'));
            return true;
        } else if(drb.demoLocation == 'ININ HQ Campus' && drb.onsiteMeetingRoom == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify a meeting room'));
            return true;
        }
        return false;
    }
    
    private Boolean checkDemoItems() {
        if(drl.checkItems()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one item'));
            return true;
        }
        return false;
    }
    
    private Boolean checkPlatform() {
        if(drl.checkPlatform()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one Platform and Solution'));
            return true;
        }
        return false;
    }
    
    private Boolean checkDemoDateInFuture() {
        DateTime current = DateTime.newInstanceGmt(DateTime.now().dateGmt(), DateTime.now().timeGmt());
        if(drb.demoDateTime < current) {
            if(isTSMember) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The selected time is in the past'));
                showSubmitAndDecline = false;
                return false;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a time in the future'));
            return true;
        }
        if(isTSMember) showSubmitAndDecline = true;
        DateTime estTime = DemoRequestUtility.ConvertTimeFromGmt(drb.demoDateTime, 'GMT–05:00 Eastern Standard Time (America/Indiana/Indianapolis)');
        if(estTime.hourGMT() < 7 || estTime.hourGMT() > 19) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This time converts to ' + estTime.formatGMT('HH') + 
                                                       ':' + estTime.formatGMT('mm') + ' in the Eastern timezone. Please consider making the request to be 7:00 to 19:00 in EST.' +
                                                       ' If your requests cannot be moved to within the requested range, please understand that consultant availability will be extremely limited.'));
        }
        return false;
    }
    
    private void buildSelections() {
        for(String at : drb.requestTypes.keySet()) {
            audienceTypeOptions.add(new SelectOption(at, at));
        }
        for(String q : drb.queues){
            queueOptions.add(new SelectOption(q,q));
        }
        for(String v : drb.verticals) {
            verticalOptions.add(new SelectOption(v, v));
        }
        for(String l : drb.demoLocations) {
            locationOptions.add(new SelectOption(l, l));
        }
        for(String t : drb.timezones) {
            timezoneOptions.add(new SelectOption(t, t));
        }
    }
    
    private void buildRequestTypes() {
        requestTypeOptions.clear();
        for(String rt : drb.requestTypes.get(drb.audienceType)) {
            requestTypeOptions.add(new SelectOption(rt, rt));
        }
    }
    
    private void buildCompetitors() {
        for(Competition__c c : drb.getCompetitors()) {
            competitorOptions.add(new SelectOption(c.Id ,c.Name));
        }
        for(Competition__c c : drb.getSelectedCompetitors()) {
            selectedCompetitors.add(new SelectOption(c.Id ,c.Name));
        }
    }
    
    public void resetPlatform() {
        showSelectPlatform = true;
        showItems = false;
        drl.buildPlatformOptions();
        drl.saveCurrentSelected();
    }
    
    public void submitPlatform() {
        if(checkPlatform()) return;
        showSelectPlatform = false;
        showItems = true;
        drl.updatePlatform();
    }
}