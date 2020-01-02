public class DemoRequestTradeshow {
    public Demo_Request__c demo { get; private set; }
    public DemoRequestBuilder drb { get; private set; }
    
    public Boolean showNavigation { get; set; }
    public Boolean showInfo { get; set; } { showInfo = true; }
    public Boolean showTSCs { get; set; }
    public Boolean showTimes { get; set; }
    public Boolean showDates { get; set; }
    public Boolean showDayCount { get; set; }
    public Boolean showVerify { get; set; }
    public Boolean showTSCNav { get; set; }
    public Boolean showTimesNav { get; set; }
    public Boolean showVerifyNav { get; set; }
    public Boolean showAudienceType { get; set; }
    public Boolean isWebinarSeries { get { return eventType == 'Webinar Series'; } }
    public Boolean showMaxAttendees { get { return eventType == 'Bootcamp'; }}
    
    public SelectOption[] presenters { get; set; }
    public SelectOption[] otherpresenters { get; set; }
    public SelectOption[] selectedOtherPresenters { get; set; }
    public SelectOption[] audienceTypes {get; set; }
    public SelectOption[] eventTypes { get; set; }
    public Map<Id, String> presenterNames { get; set; }
    public Map<Id, Id> presenterToUser { get; set; }
    public String tscLeader { get; set; }
    public String eventType { get; set; } { eventType = ''; }
    public String dateRangeStart { get; set; }
    public String dateRangeEnd { get; set; }
    public String origDateRangeStart { get; set; }
    public String origDateRangeEnd { get; set; }
    public String displayAttendees { get; set; }
    public Integer webinarCount { get; set; }
    
    public String[] dayTimeRanges { get; set; }
    public String[] dayTimeEnds { get; set; }
    public Integer[] dayInputs { get; set; }
    public DateTime[] activityTimes { get; set; }
    public String[] webinarDays { get; set; }
    
    private Demonstration_Presenter__c[] pres { get; set; }
    
    public DemoRequestTradeshow() {
        drb = new DemoRequestBuilder();
        drb.RequesterEmail = 'TechSalesDev@inin.com';
        drb.RequesterName = 'Management';
        drb.demoTimezone = 'GMT–05:00 Eastern Standard Time (America/Indiana/Indianapolis)';
        webinarCount = 0;
        activityTimes = new DateTime[]{};
        presenterNames = new Map<Id,String>();
        presenterToUser = new Map<Id,Id>();
        dayTimeRanges = new String[]{};
        dayTimeEnds = new String[]{};
        dayInputs = new Integer[]{};
        webinarDays = new String[]{};
        otherpresenters = new SelectOption[]{};
        selectedOtherPresenters = new SelectOption[]{};
        presenters = new SelectOption[]{};
        pres = [Select Display_Name__c, Id, User_Name__c from Demonstration_Presenter__c];
        presenters.add(new SelectOption('',''));
        for(Demonstration_Presenter__c d : pres) {
            presenters.add(new SelectOption(d.Id, d.Display_Name__c));
            presenterNames.put(d.Id, d.Display_Name__c);
            presenterToUser.put(d.Id, d.User_Name__c);
        }
        eventTypes = new List<SelectOption>();
        eventTypes.add(new SelectOption(' ', ' '));
        eventTypes.add(new SelectOption('Tradeshow', 'Tradeshow'));
        eventTypes.add(new SelectOption('Bootcamp', 'Bootcamp'));
        eventTypes.add(new SelectOption('Webinar Series', 'Webinar Series'));
        audienceTypes = new List<SelectOption>();
        audienceTypes.add(new SelectOption('Partner', 'Partner'));
        audienceTypes.add(new SelectOption('Internal', 'Internal'));
    }
    
    public void updateOtherPresenters() {
        otherpresenters.clear();
        for(Demonstration_Presenter__c d : pres) {
            if(tscLeader == d.Id) continue;
            otherpresenters.add(new SelectOption(d.Id, d.Display_Name__c));
        }
    }
    
    public void submitInfo() {
		if(checkInfoConditions()) return;
        drb.requestType = eventType;
        showNavigation = true;
        showInfo = false;
        showTSCs = true;
        drb.RequesterName = drb.companyName;
        if(origDateRangeEnd != dateRangeEnd || origDateRangeStart != dateRangeStart) {
            showTimesNav = false;
            showVerifyNav = false;
        }
    }
    
    public void submitTSCs() {
        if(tscLeader == null || String.isBlank(tscLeader)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select a leader for the event'));
            return;
        }
        showTSCs = false;
        showTSCNav = true;
        showTimes = true;
        showTimesNav = true;
        if(webinarCount == 0) {
            drb.demoDateTime = DateTime.valueOf(dateRangeStart + ' 00:00:00');
            DateTime en = DateTime.valueOf(dateRangeEnd + ' 23:00:00');
            webinarCount = en.dayOfYear() - drb.demoDateTime.dayOfYear() + 1;
        } 
        dayTimeRanges.clear();
        dayTimeEnds.clear();
        dayInputs.clear();
        webinarDays.clear();
        for(Integer i =0; i <= webinarCount-1; i++) {
            dayTimeRanges.add('08:00');
            dayTimeEnds.add('17:00');
            dayInputs.add(i);
            webinarDays.add('');
        }
        displayAttendees = presenterNames.get(tscLeader)+ ', ';
        for(SelectOption s : selectedOtherPresenters) {
            displayAttendees+=presenterNames.get(s.getValue())+', ';
        }
        displayAttendees = displayAttendees.substring(0,displayAttendees.length()-2);
        
    }
    
    public void submitTimes() {
        activityTimes.clear();
        
        for(Integer i = 0; i < dayInputs.size(); i++) {
            String startTime = dayTimeRanges[i];
            String endTime = dayTimeEnds[i];
            if(String.isBlank(startTime) || String.isBlank(endTime)) {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                     'One of the times is blank. Please supply a time range for each day'));
                return;
            }
            DateTime currentDay = null;
            if(eventType == 'Webinar Series'){
                currentDay = DateTime.valueOf(webinarDays[i] + ' 00:00:00');
            } else {
            	currentDay = drb.demoDateTime.addDays(i);
            }
            DateTime start = DateTime.newInstance(currentDay.year(),
                                                  currentDay.month(),
                                                  currentDay.day(),
                                                  Integer.valueOf(startTime.substring(0,2)),
                                                  Integer.valueOf(startTime.substring(3,5)), 0);
            DateTime en = DateTime.newInstance(currentDay.year(),
                                                  currentDay.month(),
                                                  currentDay.day(),
                                                  Integer.valueOf(endTime.substring(0,2)),
                                                  Integer.valueOf(endTime.substring(3,5)), 0);
            if(start >= en) {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                     startTime + ' is not before ' + endTime + '. Please correct this'));
                return;
            }
            activityTimes.add(start);
            activityTimes.add(en);
        }
        if(isWebinarSeries) {
            drb.demoDuration = 0;
            if(!activityTimes.isEmpty())
            	drb.demoDateTime = activityTimes[0];
        } else {
            if(!activityTimes.isEmpty()){
            	drb.demoDateTime = activityTimes[0];
            	Integer days = activityTimes[activityTimes.size()-1].dayOfYear() - activityTimes[0].dayOfYear()+1;
                drb.demoDuration = days*24;
            }            
        }
        showTimes = false;
        showVerify = true;
        showVerifyNav = true;
    }
    
    public PageReference submitVerify() {
        drb.suppressNotifications = true;
        DateTime midnightFirstDay = DateTime.newInstance(drb.demoDateTime.year(),drb.demoDateTime.month(),drb.demoDateTime.day(),0,0,0);
        drb.demoDateTime = midnightFirstDay;
        drb.requestType = eventType;
        if(eventType == 'Tradeshow') drb.demoLocation = 'Tradeshow';
        else drb.demoLocation = 'On-site (Requires Approval)';
        drb.companyName = 'ININ';
        drb.build();
        demo = drb.demo;
        
        List<Demo_Request_Tracking__c> temps = createTemplateActs();

        DemoRequestClass.AcceptDemos(new Map<Demo_Request__c, Id>{demo => presenterToUser.get(tscLeader)});
        
        List<Id> allUsers = new List<Id>();
        for(SelectOption s : selectedOtherPresenters) {
            DemoRequestClass.addPresenter(new Map<Id,Demo_Request__c>{s.getValue() => demo});
            allUsers.add(presenterToUser.get(s.getValue()));
        }
        
        DemoRequestTrackingBuilder.buildBulkFromTemplate(temps, allUsers);
        if(!isWebinarSeries) DemoRequestEventBuilder.CreateEventsFromDemo(demo, allUsers);
        return DemoRequestUtility.returnToDemo(demo);
    }
    
    private List<Demo_Request_Tracking__c> createTemplateActs() {
        List<Demo_Request_Tracking__c> act = new List<Demo_Request_Tracking__c>();
        string actType = DemoRequestUtility.requestToActType.get(eventType);
        for(Integer i = 0; i < activityTimes.size(); i=i+2){
            DemoRequestTrackingBuilder trb = new DemoRequestTrackingBuilder()
                .withState('Not Started')
                .withType(actType)
                .withRequest(demo.Id)
                .withStartTime(activityTimes[i])
                .withDuration(activityTimes[(i+1)].hour()-activityTimes[i].hour() + (activityTimes[(i+1)].minute()-activityTimes[i].minute())/60)
                .asTemplate(true);
            if(isWebinarSeries) trb.hasEvent(true);
            else trb.hasEvent(false);
            act.add(trb.tracking);
        }
        system.debug('inserting ' + act.size() + ' template activities');
        insert act;
        return act;
    }
    
    public void checkShowAudienceType() {
        if(eventType != 'Tradeshow') showAudienceType = true;
        else showAudienceType = false;
        showDates = false;
        showDayCount = false;
        if(isWebinarSeries) showDayCount = true;
        else showDates = true;
    }
    
    public Boolean checkInfoConditions() {
        if(String.isBlank(drb.companyName) || String.isBlank(drb.onsiteDemoLocation)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Please include a name and location'));
            return true;
        }
        if(String.isBlank(eventType) || String.isBlank(eventType)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Please select an event type'));
            return true;
        }
        if(!isWebinarSeries && (String.isBlank(dateRangeStart) || String.isBlank(dateRangeEnd))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Please include a start and end date'));
            return true;
        }
        if(isWebinarSeries && webinarCount < 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Please enter a valid How many Days'));
            return true;
        }
        return false;
    }
    
    public void backToTSCs() {
        hideAll();
        showTSCs = true;
    }
    
    public void backToInfo() {
        hideAll();
        origDateRangeEnd = dateRangeEnd;
        origDateRangeStart = dateRangeStart;
        showInfo = true;
    }
    
    public void backToTimes() {
        hideAll();
        showTimes = true;
    }
    
    public void backToVerify() {
        hideAll();
        showVerify = true;
    }
    
    private void hideAll() {
        showInfo = false;
        showTSCs = false;
        showTimes = false;
        showVerify = false;
    }
}