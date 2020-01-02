public without sharing class DemoRequestUtility {

    public static Set<String> States { 
        get { if(States == null) States = new Set<String>{'Submitted', 'Pending Approval', 'In Review', 'Accepted', 'Cancelled',
            'Escalated', 'Completed', 'Rescheduled', 'Declined', 'Approval'};
                return States; }
        private set; }
    public static Set<String> DeclineReasons {
        get { if(DeclineReasons == null) DeclineReasons = new Set<String>{'Demo Prep', 'Personal Appointment', 'Product Knowledge',
            'Scheduled Demo', 'Scheduled Meeting', 'Travel', 'Maybe', 'PTO', 'Other'};
                return DeclineReasons; }
        private set; }
    public static Set<String> timezones {
        get { if(timezones == null) timezones = new Set<String>{'GMT–05:00 Eastern Standard Time (America/Indiana/Indianapolis)','GMT+14:00 Line Islands Time (Pacific/Kiritimati)','GMT+13:45 Chatham Daylight Time (Pacific/Chatham)','GMT+13:00 New Zealand Daylight Time (Pacific/Auckland)','GMT+13:00 Phoenix Islands Time (Pacific/Enderbury)','GMT+13:00 Fiji Summer Time (Pacific/Fiji)','GMT+13:00 Tonga Time (Pacific/Tongatapu)','GMT+12:00 Magadan Time (Asia/Kamchatka)','GMT+11:30 Norfolk Islands Time (Pacific/Norfolk)','GMT+11:00 Lord Howe Daylight Time (Australia/Lord_Howe)','GMT+11:00 Australian Eastern Daylight Time (Australia/Sydney)','GMT+11:00 Solomon Islands Time (Pacific/Guadalcanal)','GMT+10:30 Australian Central Daylight Time (Australia/Adelaide)','GMT+10:00 Australian Eastern Standard Time (Australia/Brisbane)','GMT+09:30 Australian Central Standard Time (Australia/Darwin)','GMT+09:00 Korean Standard Time (Asia/Seoul)','GMT+09:00 Japan Standard Time (Asia/Tokyo)','GMT+08:00 Hong Kong Time (Asia/Hong_Kong)','GMT+08:00 Malaysia Time (Asia/Kuala_Lumpur)','GMT+08:00 Philippine Time (Asia/Manila)','GMT+08:00 China Standard Time (Asia/Shanghai)','GMT+08:00 Singapore Standard Time (Asia/Singapore)','GMT+08:00 Taipei Standard Time (Asia/Taipei)','GMT+08:00 Australian Western Standard Time (Australia/Perth)','GMT+07:00 Indochina Time (Asia/Bangkok)','GMT+07:00 Indochina Time (Asia/Ho_Chi_Minh)','GMT+07:00 Western Indonesia Time (Asia/Jakarta)','GMT+06:30 Myanmar Time (Asia/Rangoon)','GMT+06:00 Bangladesh Time (Asia/Dhaka)','GMT+05:45 Nepal Time (Asia/Kathmandu)','GMT+05:30 India Standard Time (Asia/Colombo)','GMT+05:30 India Standard Time (Asia/Kolkata)','GMT+05:00 Pakistan Time (Asia/Karachi)','GMT+05:00 Uzbekistan Time (Asia/Tashkent)','GMT+05:00 Yekaterinburg Time (Asia/Yekaterinburg)','GMT+04:30 Afghanistan Time (Asia/Kabul)','GMT+04:00 Azerbaijan Time (Asia/Baku)','GMT+04:00 Gulf Standard Time (Asia/Dubai)','GMT+04:00 Georgia Time (Asia/Tbilisi)','GMT+04:00 Armenia Time (Asia/Yerevan)','GMT+03:30 Iran Standard Time (Asia/Tehran)','GMT+03:00 East African Time (Africa/Nairobi)','GMT+03:00 Arabian Standard Time (Asia/Baghdad)','GMT+03:00 Arabian Standard Time (Asia/Kuwait)','GMT+03:00 Arabian Standard Time (Asia/Riyadh)','GMT+03:00 Further-eastern European Time (Europe/Minsk)','GMT+03:00 Moscow Standard Time (Europe/Moscow)','GMT+02:00 Eastern European Time (Africa/Cairo)','GMT+02:00 South Africa Standard Time (Africa/Johannesburg)','GMT+02:00 Eastern European Time (Asia/Beirut)','GMT+02:00 Israel Standard Time (Asia/Jerusalem)','GMT+02:00 Eastern European Time (Europe/Athens)','GMT+02:00 Eastern European Time (Europe/Bucharest)','GMT+02:00 Eastern European Time (Europe/Helsinki)','GMT+02:00 Eastern European Time (Europe/Istanbul)','GMT+01:00 Central European Time (Africa/Algiers)','GMT+01:00 Central European Time (Europe/Amsterdam)','GMT+01:00 Central European Time (Europe/Berlin)','GMT+01:00 Central European Time (Europe/Brussels)','GMT+01:00 Central European Time (Europe/Paris)','GMT+01:00 Central European Time (Europe/Prague)','GMT+01:00 Central European Time (Europe/Rome)','GMT+00:00 Western European Time (Africa/Casablanca)','GMT+00:00 Greenwich Mean Time (Europe/Dublin)','GMT+00:00 Western European Time (Europe/Lisbon)','GMT+00:00 Greenwich Mean Time (Europe/London)','GMT+00:00 Greenwich Mean Time (GMT)','GMT–01:00 East Greenland Time (America/Scoresbysund)','GMT–01:00 Azores Time (Atlantic/Azores)','GMT–01:00 Cape Verde Time (Atlantic/Cape_Verde)','GMT–02:00 Brasilia Summer Time (America/Sao_Paulo)','GMT–02:00 South Georgia Time (Atlantic/South_Georgia)','GMT–03:00 Argentina Time (America/Argentina/Buenos_Aires)','GMT–03:00 Chile Summer Time (America/Santiago)','GMT–03:30 Newfoundland Standard Time (America/St_Johns)','GMT–04:00 Atlantic Standard Time (America/Halifax)','GMT–04:00 Atlantic Standard Time (America/Puerto_Rico)','GMT–04:00 Atlantic Standard Time (Atlantic/Bermuda)','GMT–04:30 Venezuela Time (America/Caracas)','GMT–05:00 Colombia Time (America/Bogota)','GMT–05:00 Peru Time (America/Lima)','GMT–05:00 Eastern Standard Time (America/New_York)','GMT–05:00 Eastern Standard Time (America/Panama)','GMT–06:00 Central Standard Time (America/Chicago)','GMT–06:00 Central Standard Time (America/El_Salvador)','GMT–06:00 Central Standard Time (America/Mexico_City)','GMT–07:00 Mountain Standard Time (America/Denver)','GMT–07:00 Mountain Standard Time (America/Mazatlan)','GMT–07:00 Mountain Standard Time (America/Phoenix)','GMT–08:00 Pacific Standard Time (America/Los_Angeles)','GMT–08:00 Pacific Standard Time (America/Tijuana)','GMT–08:00 Pitcairn Time (Pacific/Pitcairn)','GMT–09:00 Alaska Standard Time (America/Anchorage)','GMT–09:00 Gambier Time (Pacific/Gambier)','GMT–09:30 Marquesas Time (Pacific/Marquesas)','GMT–10:00 Hawaii-Aleutian Standard Time (America/Adak)','GMT–10:00 Hawaii-Aleutian Standard Time (Pacific/Honolulu)','GMT–11:00 Niue Time (Pacific/Niue)','GMT–11:00 Samoa Standard Time (Pacific/Pago_Pago)'};
            return timezones; }
        private set; }
    public static Set<String> unavailableStates {
        get { if(unavailableStates == null) unavailableStates = new Set<String>{'Cancelled', 'Approval Denied',
            'Completed', 'Accepted'};
                return unavailableStates; }
        private set; }
    public static Set<String> unassignableStates {
        get { if(unassignableStates == null) unassignableStates =  new Set<String>{'Cancelled', 'Completed', 'Approval Denied', 'Pending Approval'};
            return unassignableStates; }
        private set; }
    public static Set<String> uncancelableStates {
        get { if(uncancelableStates == null) uncancelableStates =  new Set<String>{'Cancelled', 'Completed', 'Approval Denied'};
            return uncancelableStates; }
        private set; }
    public static Set<String> unschedulableStates {
        get { if(unschedulableStates == null) unschedulableStates =  new Set<String>{'Completed', 'Pending Approval'};
            return unschedulableStates; }
        private set; }
    public static Set<String> activeDemoStates {
        get { if(activeDemoStates == null) activeDemoStates =  new Set<String>{'Submitted', 'In Review', 'Escalated',
            'Rescheduled', 'Pending Approval'};
                return activeDemoStates; }
        private set; }
    public static Set<String> canAddPresenter {
        get { if(canAddPresenter == null) canAddPresenter =  new Set<String>{'Accepted', 'Completed', 'Pending Approval'};   
            return canAddPresenter; }
        private set; }
    public static Set<String> busyEventStates {
        get { if(busyEventStates == null) busyEventStates =  new Set<String>{'Busy', 'OutOfOffice'};
            return busyEventStates; }
        private set; }
    public static List<String> chatterPostType {
        get { if(chatterPostType == null) chatterPostType =  new List<String>{'Submit', 'Reschedule', 'Escalate', 'Decline',
            'Cancel', 'Accept'};
                return chatterPostType; }
        private set; }
    public static Set<String> rescheduleReasons {
        get { if(rescheduleReasons == null) rescheduleReasons =  new Set<String>{'Requester Reschedule', 'Submission Error',
            'Technical Sales Unavailable', 'Velocity Sales Unavailable', 'Presenter Conflict'};
                return rescheduleReasons; }
        private set; }
    public static Set<String> escalationReasons {
        get { if(escalationReasons == null) escalationReasons =  new Set<String>{'Submitted With Short Notice', 'Rescheduled With Short Notice',
            'TSC SLA Not Met', 'TSCs Unavailable'};
                return escalationReasons; }
        private set; }
    public static Set<String> cancelReasons {
        get { if(cancelReasons == null) cancelReasons =  new Set<String>{'Technical Sales Unavailable', 'Deal Lost', 'Prospect Cancelled',
            'Requester Cancelled', 'Submission Error', 'Company Holiday', 'Product Not Available', 'Process Testing', 'Performed By Partner',
            'Performed By Other Department', 'No Show'};
                return cancelReasons; }
        private set; }
    public static List<String> demoLocations { 
        get { if(demoLocations == null) demoLocations = new List<String> { 'Web Based','HQ Simulation Room', 'ININ HQ Campus', 'On-site (Requires Approval)'};
            return demoLocations; }
        private set; }
    public static Map<String, String> requestToActType { 
        get { if(requestToActType == null) requestToActType = new Map<String, String>{'Tradeshow' => 'Tradeshow','Bootcamp' => 'Demo Training','Webinar Series' => 'Demo Training'};
                return requestToActType;
        } private set; } 
    public static Set<String> queueNames {
        get {if(queueNames == null) queueNames =  new Set<String>{'Technical Sales', 'Velocity Sales'};
                return queueNames;
        } private set; }
    public static String orgUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    
    public static DateTime ConvertTimeToGmt(DateTime dtTime, String tmZone){
        //example timezone GMT–05:00 Eastern Standard Time (America/Indiana/Indianapolis)
        if(tmZone.substring(0, 3) == 'GMT') tmZone = tmZone.substring(tmZone.indexOf('(')+1,tmZone.indexOf(')'));
        System.debug('substring: ' + tmZone);
        TimeZone tz = TimeZone.getTimeZone(tmZone);
        Integer tzOffset = tz.getOffset(dtTime); //offset in milliseconds
        tzOffset /= 1000; //offset in seconds
        DateTime dt = dtTime.addSeconds(-tzOffset);
        return dt;
    }
    
    public static DateTime ConvertTimeFromGmt(DateTime dtTime, String tmZone){
        if(tmZone.substring(0, 3) == 'GMT' && tmZone.length() > 5) tmZone = tmZone.substring(tmZone.indexOf('(')+1,tmZone.indexOf(')'));
        TimeZone tz = TimeZone.getTimeZone(tmZone);
        Integer tzOffset = tz.getOffset(dtTime); //offset in milliseconds
        tzOffset /= 1000; //offset in seconds
        DateTime dt = dtTime.addSeconds(tzOffset);
        return dt;
    }
    
    public static void defaultQueue(Demo_Request__c req){
        if(String.isBlank(req.QueueName__c)) req.QueueName__c = 'Technical Sales';
    }
    
    public static String getPresentersQueue(Id user) {
        List<Demonstration_Presenter__c> pres = [Select QueueName__c from Demonstration_Presenter__c where User_Name__c = :user];
        return pres[0].QueueName__c;
    }
    
    public static Boolean EscalateForRequestedTime(DateTime dt){
        DateTime dtNow = DateTime.Now();
        //if is in past, don't escalate
        if(dt < dtNow) return false;
        DateTime dtAddTime = dtNow.addHours(96);
        String reqDay = dt.format('EEE');
        String dayToday = dtNow.format('EEE');
        
        if(dt.addHours(-24) < dtNow){
            return true;
        } else if((dayToday == 'Fri') && (dt < dtAddTime)) {
            if(reqDay == 'Fri'){
                return true;
            } else if(reqDay == 'Sat'){
                return true;
            } else if(reqDay == 'Sun'){
                return true;
            } else if(reqDay == 'Mon'){
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        } 
    }
    
    public static Integer ConvertDecimalToMinutes(Decimal d){
        Integer intHours = d.intValue();
        Decimal decHours = d - intHours;    	
        Decimal minutes = decHours * 60;
        return minutes.intValue();    	
    }
    
    public static Set<Id> GetTSCsIds(String queue) {
        List<Demonstration_Presenter__c> pres = [Select User_Name__c from Demonstration_Presenter__c where isTSC__c=true and isTSM__c=false and QueueName__c = :queue];
        return presenterToIds(pres);
    }
    
    public static Set<Id> GetTSMsIds(String queue) {
        List<Demonstration_Presenter__c> pres = [Select User_Name__c from Demonstration_Presenter__c where isTSM__c=true and QueueName__c = :queue];
        return presenterToIds(pres);
    }
    
    public static Set<Id> getAllTSIds(String queue) {
        List<Demonstration_Presenter__c> pres = [Select User_Name__c from Demonstration_Presenter__c where isTS__c=true and QueueName__c = :queue];
        return presenterToIds(pres);
    }
    
    public static Set<Id> getAllTSIds() {
        List<Demonstration_Presenter__c> pres = [Select User_Name__c from Demonstration_Presenter__c where isTS__c=true];
        return presenterToIds(pres);
    }
    
    public static Set<Id> presenterToIds(List<Demonstration_Presenter__c> pres) {
        Set<Id> i = new Set<Id>();
        for(Demonstration_Presenter__c p : pres) {
            i.add(p.User_Name__c);
        }
        return i;
    }
    
    public static Set<Id> getDeclinersIDs(String queue) {
        List<Demonstration_Presenter__c> pres = [Select User_Name__c from Demonstration_Presenter__c where isTSC__c=true and QueueName__c=:queue];
        return presenterToIds(pres);
    }
    
    public static Integer getDeclineBuffer(){
        DemoProcessConfig__c s = DemoProcessConfig__c.getInstance('DeclineBuffer');
        return Integer.valueof(s.Number__c);
    }
    
    public static String getDistroEmail(String queue){
        DemoProcessConfig__c s = DemoProcessConfig__c.getInstance(queue.replace(' ', '')+'Distro');
        return s.String__c;
    }
    
    public static Integer GetNumTscAvailable(DateTime startDateTime, Decimal duration, String queue){
        Set<Id> users = getTSCsIds(queue);
        return users.size() - GetUsersConflictingEvents(startDateTime, duration, users).size();
    }
    
    public static Integer GetNumUsersAvailable(DateTime startDateTime, Decimal duration, String queue){
        Set<Id> users = getAllTSIds(queue);
        return users.size() - GetUsersConflictingEvents(startDateTime, duration, users).size();
    }
    
    public static List<SelectOption> populateSelectOptions(List<String> ops){
        List<SelectOption> options = new List<SelectOption>();
        for(String l : ops) {
            options.add(new SelectOption(l, l));
        }
        return options;
    }
    
    public static List<DateTime> getAlternativeTimeSuggestions(DateTime startDateTime, Decimal duration, String queue) {
        List<DateTime> suggestions = new List<DateTime>();
        Integer step = 15;
        Integer modifier = 0;
        Set<Id> userIds = getDeclinersIDs(queue);
        Integer availableMin = userIds.size()/2;
        Set<Id> busyUser = new Set<Id>();
        Time startOfDay = Time.newInstance(8,0,0,0);
        Time endOfDay = Time.newInstance(18,0,0,0);
        Time previousBefore;
        Time previousAfter;
        system.debug('finding suggestions for start: ' + startDateTime.format() + '     duration: '  + duration.toPlainString());
        List<Event> busyEvents = [SELECT Id, StartDateTime, EndDateTime, OwnerId, Type, ShowAs, IsAllDayEvent FROM Event
                                  WHERE OwnerId IN :userIds AND EndDateTime > :startDateTime.addDays(-1) AND StartDateTime < :startDateTime.addDays(1)];
        Map<Id,List<Event>> userEvents = new Map<Id, List<Event>>();
        for(Event e : busyEvents){
            if(userEvents.containsKey(e.OwnerId))
                userEvents.get(e.OwnerId).add(e);
            else
                userEvents.put(e.OwnerId, new List<Event>{e});
        }
        
        system.debug('found busy events: ' + busyEvents.size());
        while(true){           
            DateTime earlyStart = DateTime.newInstance(startDateTime.date(),startDateTime.time().addMinutes(-modifier));
        	DateTime earlyEnd = DateTime.newInstance(startDateTime.date(),startDateTime.time().addMinutes(-modifier+Integer.valueOf(duration)));
            if(earlyStart.time() >= startOfDay){
                for(Id i : userEvents.keySet()){
                    for(Event e : userEvents.get(i)){
                        if(checkEventTimesConflict(e, earlyStart, earlyEnd)){
                            busyUser.add(e.OwnerId);
                            break;
                        }
                    }
                }
                system.debug('checking user count '+busyUser.size()+' for time slot:' + earlyStart);
                if(busyUser.size() <= availableMin) {
                    if(previousBefore != null && previousBefore.addMinutes(-30) < earlyStart.time()){
                        system.debug('skipping time suggestion due to within 30 minutes of another');
                    } else{
                        suggestions.add(earlyStart);
                        previousBefore = earlyStart.time();
                        system.debug('adding sugestion: ' + earlyStart);
                    }
                } else
                    system.debug('skipping suggestion due to too early: ' + earlyStart);
                busyUser.clear();
            }          
            
            DateTime laterStart = DateTime.newInstance(startDateTime.date(),startDateTime.time().addMinutes(modifier));
        	DateTime laterEnd = DateTime.newInstance(startDateTime.date(),startDateTime.time().addMinutes(modifier+Integer.valueOf(duration)));
            if(laterEnd.time() <= endOfDay){
                for(Id i : userEvents.keySet()){
                    for(Event e : userEvents.get(i)){
                        if(checkEventTimesConflict(e, laterStart, laterEnd)){
                            busyUser.add(e.OwnerId);
                            break;
                        }
                    }
                }
                system.debug('checking user count '+busyUser.size()+' for time slot:' + laterStart);
                if(busyUser.size() <= availableMin) {
                    if(previousAfter != null && previousAfter.addMinutes(-30) < laterStart.time()){
                        system.debug('skipping time suggestion due to within 30 minutes of another');
                    } else{
                        suggestions.add(laterStart);
                        previousAfter = laterStart.time();
                        system.debug('adding sugestion: ' + laterStart);
                    }
                } else
                    system.debug('skipping suggestion due to too late: ' + laterStart);
                busyUser.clear();
            }
            
            if(suggestions.size() > 3) break;
            if(laterEnd.time() > endOfDay && earlyStart.time() < startOfDay){
                system.debug('modifier moved past the current day, stopping: ' + modifier);
                break;
            } 
            modifier+=step;
        }
        suggestions.sort();
        return suggestions;
    }
    
    public static Set<Id> GetUsersConflictingEvents(DateTime startDateTime, Decimal duration, Set<Id> usersIds){
        Integer buffer = DemoRequestUtility.getDeclineBuffer();
        DateTime requestStartTime = startDateTime.addMinutes(-buffer); //create a - min padding to the start time
        if(duration == null || buffer == null)
            return null;
        DateTime requestEndTime = requestStartTime.addHours(duration.intValue()).addMinutes(ConvertDecimalToMinutes(duration)+buffer);  //add duration to the start time + min padding
        Set<Id> busyUser = new Set<Id>();
        system.debug('checking for user events: ' + usersIds);
        List<Event> busyEvents = [SELECT Id, StartDateTime, EndDateTime, OwnerId, Type, ShowAs, IsAllDayEvent FROM Event WHERE OwnerId IN :usersIds
                                  AND ShowAs IN :busyEventStates AND EndDateTime > :DateTime.now().AddDays(-1)];
        if(busyEvents.size() < 1) {
            system.debug('No events found');
            system.debug('start: ' + startDateTime.AddDays(-1).format() + '   end: ' + startDateTime.AddDays(1).format());
            return busyUser; 
        }
        system.debug('Starting event check against: ' + startDateTime + '    ' + duration);
        for(Event e : busyEvents){
            system.debug('checking ' + e + '     ' + requestStartTime + '     ' + requestEndTime);
            if(checkEventTimesConflict(e, requestStartTime, requestEndTime)){
                busyUser.add(e.OwnerId);
                system.debug('Busy User: ' + e.OwnerId);
            }
        }
        Integer numAvailable = usersIds.size() - busyUser.size();
        System.debug('Busy User IDs: ' + busyUser + ' Number of Users Available: ' + numAvailable);
        return busyUser;
    }
    
    public static Set<Id> GetUsersWithConflictingEvent(DateTime startDateTime, Decimal duration, String queue){
        Set<Id> userIds = getDeclinersIDs(queue);
        return GetUsersConflictingEvents(startDateTime, duration, userIds);
    }
    
    public static Map<Id, Integer> GetNumLeftToDecline(List<Demo_Request__c> requestIds, String queue){
        Map<Id, Integer> leftToDecline = new Map<Id, Integer>();
        Map<String, Integer> queueToDeclineCount = new Map<String,Integer>();
        //map out queue with how many decline members
        for(Demo_Request__c d : requestIds) {
            if(!queueToDeclineCount.containsKey(d.QueueName__c))
                queueToDeclineCount.put(d.QueueName__c, getDeclinersIDs(queue).size());
        }
        Map<Id, List<Demo_Request_Decline__c>> requestToDecline = new Map<Id, List<Demo_Request_Decline__c>>();
        List<Demo_Request_Decline__c> declines = [SELECT Id, Demo_Request_ID__c, User_Name__c FROM Demo_Request_Decline__c WHERE Demo_Request_ID__c IN :requestIds];
        for(Demo_Request_Decline__c d : declines){
            if(requestToDecline.containsKey(d.Demo_Request_ID__c)){
                requestToDecline.get(d.Demo_Request_ID__c).add(d);
                
            } else {
                requestToDecline.put(d.Demo_Request_ID__c, new List<Demo_Request_Decline__c>{d});
            }
        }
        
        for(Demo_Request__c i : requestIds){
            Integer declined = 0;
            if(requestToDecline.get(i.Id) != null) declined = requestToDecline.get(i.Id).size();
            Integer numToDecline = queueToDeclineCount.get(i.QueueName__c) - declined;
            leftToDecline.put(i.Id, numToDecline);
        }
        
        return leftToDecline;
    }
    
    public static Set<User> GetUsersLeftToDecline(Demo_Request__c request) {
        Set<Id> allDeclinerIds = getDeclinersIDs(request.QueueName__c);
        Set<User> userIds = new Set<User>();
        Map<Id, User> userMap = new Map<Id, User>();
        List<Demo_Request_Decline__c> declines = [SELECT Id, Demo_Request_ID__c, User_Name__c FROM Demo_Request_Decline__c WHERE Demo_Request_ID__c = :request.Id];        
        List<User> declineUsers = [SELECT Id, Email, Name FROM User WHERE Id IN: alldeclinerIds];
        
        for(User u : declineUsers){
            userMap.put(u.Id, u);
        }
        
        for(Demo_Request_Decline__c d : declines){
            userIds.add(userMap.get(d.User_Name__c));
        }
        
        Set<User> notDeclined = new Set<User>();
        notDeclined.addAll(declineUsers);
        notDeclined.removeAll(userIds);
        
        return notDeclined; 
    }
    
    public static List<Event> GetRequestEventConflicts(Demo_Request__c request, Id currentUser){
        return GetActivityEventConflicts(request.Demo_Date_Time__c, request.Demo_Time_Length__c, currentUser);
    }
    
    public static List<Event> GetActivityEventConflicts(DateTime start, Decimal duration, Id currentUser){
        List<Event> busyEvents = [SELECT Id, StartDateTime, EndDateTime, OwnerId, Type, ShowAs, Subject, IsAllDayEvent FROM Event WHERE OwnerId = :currentUser AND ShowAs IN :busyEventStates AND EndDateTime > :DateTime.now().addDays(-1)];
        Integer declineBuffer = DemoRequestUtility.getDeclineBuffer();
        DateTime requestStartTime = start.addMinutes(-declineBuffer); //create a -min padding to the start time
        DateTime requestEndTime = requestStartTime.addHours(duration.intValue()).addMinutes(ConvertDecimalToMinutes(duration)+declineBuffer);  //add duration to the start time +min padding
        List<Event> eventConflicts = new List<Event>();
        
        for(Event e : busyEvents){
            if(checkEventTimesConflict(e, requestStartTime, requestEndTime)){
                eventConflicts.add(e);
            }
        }
        return eventConflicts;
        
    }
    
    public static List<Demo_Request_Decline__c> CheckAltDateTimeConflicts(Demo_Request__c request) {
		Set<Id> tscIds = GetTSCsIds(request.QueueName__c);
        DateTime minEndDT = DateTime.now().addDays(-1);
        List<Event> busyEvents = [SELECT Id, StartDateTime, EndDateTime, OwnerId, Type, ShowAs, IsAllDayEvent FROM Event WHERE OwnerId IN :tscIds AND ShowAs IN :busyEventStates AND EndDateTime > :minEndDT];
        Map<Id, List<Event>> userToEvent = new Map<Id, List<Event>>();
        List<Demo_Request_Decline__c> declines = [SELECT Id, Demo_Request_ID__c, User_Name__r.FirstName, User_Name__r.LastName, Alternate_Date_Time_Available__c FROM Demo_Request_Decline__c WHERE Demo_Request_ID__c = :request.Id];
        
        for(Event e : busyEvents){
            if(userToEvent.containsKey(e.OwnerId)){
                userToEvent.get(e.OwnerId).add(e);
            } else {
                userToEvent.put(e.OwnerId, new List<Event>{e});
            }
        }
        for(Demo_Request_Decline__c d : declines){
            if(d.Alternate_Date_Time_Available__c == null) continue;
            DateTime startTime = d.Alternate_Date_Time_Available__c;
            DateTime endTime = d.Alternate_Date_Time_Available__c.addHours(request.Demo_Time_Length__c.intValue()).addMinutes(ConvertDecimalToMinutes(request.Demo_Time_Length__c));
            List<Event> userEvents = userToEvent.get(d.User_Name__c);
            if(userEvents == null) continue;
            for(Event evt : userEvents){
                if((checkEventTimesConflict(evt, startTime, endTime)) || (startTime < minEndDT)){
                    d.Alternate_Date_Time_Available__c = null;
                    break;
                }
            }
        }
        
        return declines;
    }
    
    public static Boolean checkEventTimesConflict(Event e, DateTime start, DateTime finish) {
        return 
            //event start is after demo start and event start is before demo end
            ((e.StartDateTime >= start && e.StartDateTime <= finish) ||
             //event end is after demo start and event end is before demo end
             (e.EndDateTime >= start && e.EndDateTime <= finish) || 
             //event start is before demo start and event end is after demo end
             (e.StartDateTime <= start && e.EndDateTime >= finish) ||
             //event is all day and request start date or end date is on demo date
             (e.IsAllDayEvent && ((e.StartDateTime.dateGMT() == start.dateGMT()) || (e.EndDateTime.dateGMT() == start.dateGMT()))));
    }
    
    public static Boolean isDuringMaintenance(datetime requestGmt, decimal duration){
        
        if(requestGmt.format('EEE') != 'Fri') return false;
        
        Integer maintHrStart;
        Decimal maintHrEnd;
        if(isEDT()){
            maintHrStart = 10;
            maintHrEnd = 12.0;
        } else {
            maintHrStart = 11;
            maintHrEnd = 13.0;
        }
        
        Integer requestHrStart = requestGmt.hourGmt();
        Decimal requestHrEnd = requestGmt.hourGmt() + duration;
        
        if((requestHrStart >= maintHrStart && requestHrStart < maintHrEnd) || 
           (requestHrEnd >= maintHrStart && requestHrEnd < maintHrEnd) || 
           (requestHrStart <= maintHrStart && requestHrEnd >= maintHrEnd)){
            return true;
        } else {
            return false;
        }
       
    }
    
    public static Boolean isEDT(){
        TimeZone tz = TimeZone.getTimeZone('America/New_York');
        DateTime now = DateTime.now();
        Integer tzOffset = tz.getOffset(now);
        
        if(tzOffset == -14400000){
            return true; // Eastern Daylight Time (EDT)
        } else {
            return false; //Easstern Standard Time (EST)
        }
        
    }
    
    public static String stringify(List<SelectOption> ops) {
        if(ops == null || ops.size() == 0) return '';
        String f = '';
        for(SelectOption o : ops) f = f + ', ' + o.getLabel();
        return f.removeStart(',');
    }
    
    public static PageReference returnToDemo(Demo_Request__c req) {
        PageReference demo = new ApexPages.StandardController(req).view();
        demo.setRedirect(true);
        return demo;
    }
    
}