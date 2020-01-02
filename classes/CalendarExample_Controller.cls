public class CalendarExample_Controller {
 
    public Boolean includeMyEvents {get;set;}
    public list<calEvent> events {get;set;}
     
    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated correctly
    String dtFormat = 'EEE, d MMM yyyy HH:mm:ss z';
     
    //constructor
    public CalendarExample_Controller() {
        //Default showing my events to on
        includeMyEvents = true;
    }
     
    public PageReference pageLoad() {
        events = new list<calEvent>();
        //Get Contact's Birthdays
        for(Marketing_Activity__c actRec : [Select Id,Name,Partner_Event_Start_Date__c , Partner_Event_End_Date__c,Description__c,Region__c, Activity_Link__c FROM Marketing_Activity__c WHERE Partner_Event_Start_Date__c!=null AND Genesys_Involvement_in_Event__c includes ('Partner Presence') AND Publish_to_Partner_Portal_New__c = 'Yes' AND Partner_Event_Start_Date__c >= LAST_N_DAYS:365 Order By Partner_Event_Start_Date__c LIMIT 150]){
            //here we need to replace the birth year with the current year so that it will show up on this years calendar
            calEvent activityCal = new calEvent();
             
            activityCal.title = actRec.Name;
            activityCal.allDay = false;
            
            
            
            activityCal.startString = actRec.Partner_Event_Start_Date__c.format();
            //activityCal.endString = actRec.Partner_Event_End_Date__c !=null?actRec.Partner_Event_End_Date__c.addDays(1).format():'';
            activityCal.endString = actRec.Partner_Event_End_Date__c !=null?actRec.Partner_Event_End_Date__c.format():'';
            activityCal.description = actRec.description__c!=null?actRec.description__c.substring(0,actRec.description__c.length()).escapeEcmaScript():'';
            if(actRec.Activity_Link__c!=null){
                if(!(actRec.Activity_Link__c.containsIgnoreCase('http://') || actRec.Activity_Link__c.containsIgnoreCase('https://')))
                    activityCal.url = 'http://' + actRec.Activity_Link__c;
                else
                    activityCal.url = actRec.Activity_Link__c;
            }
            else{
                activityCal.url = '#';
            }
            if(actRec.Region__c!=null){
                if(actRec.Region__c.equalsIgnoreCase('GLOBAL')){
                    activityCal.className = 'event-Global';
                }
                else if(actRec.Region__c.equalsIgnoreCase('North America')){
                    activityCal.className = 'event-NA';
                }
                else if(actRec.Region__c.equalsIgnoreCase('APAC')){
                    activityCal.className = 'event-APAC';
                }
                else if(actRec.Region__c.equalsIgnoreCase('EMEA')){
                    activityCal.className = 'event-EMEA';
                }
                else if(actRec.Region__c.equalsIgnoreCase('LATAM')){
                    activityCal.className = 'event-LATAM';
                }
            }
            
            events.add(activityCal);
        }
        return null;
    }
 
     
    //Class to hold calendar event data
    public class calEvent{
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public String startString {get;set;}
        public String endString {get;set;}
        public String url {get;set;}
        public String toolTip {get;set;}
        public String className {get;set;}
        public String description {get;set;}
    }
}