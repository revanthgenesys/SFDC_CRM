/*
08/05/2013  Suman Tumurugoti    VF report for Product support group case assigmnet. 
Description :   This page shows current case workload, recent case assignment history and user availability
                For any given case, get all users that are assigned to the product support group of the case, show
                # Cases open owned by priority
                # Cases open supervised by priority
                # Cases assigned in the last 24 hours
                # Cases assigned in the last 48 hours
                # Cases assigned in the last 168 hours
Test class: Test_CaseWorkloadReport                
*/
public with sharing class CaseWorkLoadReport {

    public CaseWorkLoadReport(ApexPages.StandardController controller) {
        init();
    }

    public boolean filterEnabled{get;set;}
    public Map<id,wrapper> mapwrapper{get;set;}//wrapper variable to hold results
    public Map<id,user> mapusrs{get;set;}//map of users belonging to this PSG
    public List<string> lstSeverity{get;set;}//List of all case priorities
    public List<user> lstusrs{get;set;}
    public string selectedPSG{get;set;}
    public string sortField{get;set;}
    public string sortFieldtmp{get;set;}
    public string sortOrder{get;set;}
    public datetime current;
    
    //Wrapper class for displaying results
    public class wrapper implements Comparable 
    {   
        CaseWorkLoadReport outerCA;
        
        public User usr{get;set;}
        public Integer cntTotalNonClosed {get; set;}
        public integer cntTotal24{get;set;}
        public integer cntTotal48{get;set;}
        public integer cntTotal168{get;set;}
        public integer cntTotalOwned{get;set;}
        public integer cntTotalSupervised{get;set;}
        public boolean checked{get;set;}
        
        //Map that holds the number of cases assigned in the last 24 hrsfor each priority 
        public map<string,integer> mapSeverity24{get;set;}
        public map<string,integer> mapSeverity48{get;set;}
        public map<string,integer> mapSeverity168{get;set;}
        public map<string,integer> mapSeverityOwned{get;set;}
        public map<string,integer> mapSeveritySupervised{get;set;}
        
        public string usrtime{get;set;}
        public string color{get;set;}
        public wrapper(CaseWorkLoadReport outercls)
        {
            //System.debug('*******in wrapper constru:'+Controller_CaseAssignment.selReport);
            this.outerCA= outercls;
        }
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) 
        {
            System.debug('*******Sort field: '+outerCA.sortField+'*******sortOrder: '+outerCA.sortOrder);
            Wrapper compareToWra = (Wrapper)compareTo;
            
            if(outerCA.sortField=='currentstatus')
            {
                if(outerCA.sortOrder=='dsc')
                {
                    return compareToWra.usr.Current_Status__c.compareTo(usr.Current_Status__c);
                }
                else
                {
                    return usr.Current_Status__c.compareTo(compareToWra.usr.Current_Status__c);                 
                } 
            }           
            else if(outerCA.sortField=='name')
            {
                if(outerCA.sortOrder=='dsc')
                {
                    return compareToWra.usr.name.compareTo(usr.name);
                }
                else
                {
                    return usr.name.compareTo(compareToWra.usr.name);                 
                } 
            }
            else if(outerCA.sortField=='currenttime')
            {
                if(outerCA.sortOrder=='dsc')
                {                   
                    if (Datetime.valueOf(outerCA.current.format('yyyy-MM-dd HH:mm:ss', usr.TimeZoneSidKey))== Datetime.valueOf(outerCA.current.format('yyyy-MM-dd HH:mm:ss', compareToWra.usr.TimeZoneSidKey))) return 0;
                    if (Datetime.valueOf(outerCA.current.format('yyyy-MM-dd HH:mm:ss', usr.TimeZoneSidKey)) < Datetime.valueOf(outerCA.current.format('yyyy-MM-dd HH:mm:ss', compareToWra.usr.TimeZoneSidKey))) return 1;
                    return -1;  
                }
                else
                {
                    if (Datetime.valueOf(outerCA.current.format('yyyy-MM-dd HH:mm:ss', usr.TimeZoneSidKey))== Datetime.valueOf(outerCA.current.format('yyyy-MM-dd HH:mm:ss', compareToWra.usr.TimeZoneSidKey))) return 0;
                    if (Datetime.valueOf(outerCA.current.format('yyyy-MM-dd HH:mm:ss', usr.TimeZoneSidKey)) > Datetime.valueOf(outerCA.current.format('yyyy-MM-dd HH:mm:ss', compareToWra.usr.TimeZoneSidKey))) return 1;
                    return -1; 
                } 
            }
            else if(outerCA.sortField=='totalowned')
            {
                if(outerCA.sortOrder=='dsc')
                {
                    if (cntTotalOwned== compareToWra.cntTotalOwned) return 0;
                    if (cntTotalOwned < compareToWra.cntTotalOwned) return 1;
                    return -1;  
                }
                else
                {
                    if (cntTotalOwned== compareToWra.cntTotalOwned) return 0;
                    if (cntTotalOwned > compareToWra.cntTotalOwned) return 1;
                    return -1; 
                } 
            }
            else if(outerCA.sortField=='total24')
            {
                if(outerCA.sortOrder=='dsc')
                {
                    if (cntTotal24== compareToWra.cntTotal24) return 0;
                    if (cntTotal24 < compareToWra.cntTotal24) return 1;
                    return -1;  
                }
                else
                {
                    if (cntTotal24== compareToWra.cntTotal24) return 0;
                    if (cntTotal24 > compareToWra.cntTotal24) return 1;
                    return -1; 
                } 
            }
            else if(outerCA.sortField=='total48')
            {
                if(outerCA.sortOrder=='dsc')
                {
                    if (cntTotal48== compareToWra.cntTotal48) return 0;
                    if (cntTotal48 < compareToWra.cntTotal48) return 1;
                    return -1;  
                }
                else
                {
                    if (cntTotal48== compareToWra.cntTotal48) return 0;
                    if (cntTotal48 > compareToWra.cntTotal48) return 1;
                    return -1; 
                } 
            }
            else if(outerCA.sortField=='total168')
            {
                System.debug('*******In total168 sort');
                System.debug('*******cntTotal168:'+cntTotal168+'******compareToWra.cntTotal168: '+compareToWra.cntTotal168);
                if(outerCA.sortOrder=='dsc')
                {
                    if (cntTotal168== compareToWra.cntTotal168) return 0;
                    if (cntTotal168 < compareToWra.cntTotal168) return 1;
                    return -1;  
                }
                else
                {
                    if (cntTotal168== compareToWra.cntTotal168) return 0;
                    if (cntTotal168 > compareToWra.cntTotal168) return 1;
                    return -1; 
                } 
            }
            else if(outerCA.sortField=='chkbox')
            {
                System.debug('*******In chkbox sort');
                    if (checked== true) return 0;
                    if (checked==false) return 1;
                    return -1;  
            }                                     
            else
            {
                return -1;
            }
        }
    }
    public void init()
    {
       // selReport='availability';//default report that is shown 
        //selectedPSG = 'Reporting & Analytics'; //default PSG selected   
        lstSeverity = new List<string>();
        List<Schema.PicklistEntry> P = Case.Priority.getDescribe().getPicklistValues();
        List<string> lstSeveritytmp = new List<string>();
        //manipulate so that prod down shows up first in the list
        for(Schema.PicklistEntry sev:P)
        {
            if(sev.getLabel()=='Prod Down')
                lstSeverity.add(sev.getLabel());
        
        }
        for(Schema.PicklistEntry sev:P)
        {
            if(sev.getLabel()!='Prod Down')
                lstSeveritytmp.add(sev.getLabel());
        
        }
        lstSeveritytmp.sort();
        lstSeverity.addAll(lstSeveritytmp);
        if(Apexpages.currentPage().getparameters().containsKey('id'))
        {
            try
            {
                List<case> lstcas = [Select id,Product_Support_Group__c from case where id = :Apexpages.currentPage().getparameters().get('id')];
                if(lstcas.size()>0)
                {
                    if(lstcas[0].Product_Support_Group__c !=null)
                        selectedpsg=lstcas[0].Product_Support_Group__c;
                }            
            }catch(exception e)
            {
                System.debug('*******'+e.getmessage());
            }
        }
        else
            selectedpsg = [SELECT id,Product_Support_Group__c from User where id=:UserInfo.getUserid() LIMIT 1].Product_Support_Group__c; 
        //selectedpsg='All';
        generateReport();
    }
    public PageReference generateReport()
    {
        mapwrapper= new Map<id,wrapper>();
        mapusrs = new Map<id,user>();
        current = System.now();      
        if(selectedpsg!=null && selectedpsg!='')
        {
            System.debug('******selectedPSG:'+selectedPSG);
            //Get all the users belonging to the PSG of the case
            if(selectedpsg=='All')
                lstusrs = [SELECT id,name,city,TimeZoneSidKey,Current_Status__c,alias,availability_Note__c,
                                         Level_of_Expertise__c, Work_Day_End__c, Work_Day_Start__c, Weekdays_Unavailable__c
                          FROM user 
                          WHERE Product_Support_Group__c!=null
                                         //AND profile.name='Tech Support Tier 3 Analyst'
                                         AND isactive=true
                                         ORDER by TimeZoneSidKey,city,name];            

            else
                lstusrs = [SELECT id,name,city,TimeZoneSidKey,Current_Status__c,alias,availability_Note__c,
                                         Level_of_Expertise__c, Work_Day_End__c, Work_Day_Start__c, Weekdays_Unavailable__c
                           FROM user 
                           WHERE Product_Support_Group__c=:selectedPSG
                                         //AND profile.name='Tech Support Tier 3 Analyst'
                                         AND isactive=true
                                         ORDER by TimeZoneSidKey,city,name];
            for(User usr:lstusrs)
            {
                mapusrs.put(usr.id,usr);
            }
    
            //for each user, initialize the counts and put 0
            for(Id usrid:mapusrs.keySet())
            {
                wrapper wra = new wrapper(this);
                wra.usr = mapusrs.get(usrid);
                if(wra.usr.Current_Status__c==null)
                    wra.usr.Current_Status__c='';
                wra.cntTotalNonClosed = 0;
                wra.cntTotal24=0;
                wra.cntTotal48=0;
                wra.cntTotal168=0;
                wra.cntTotalOwned=0;
                wra.cntTotalSupervised=0;       
                map<string,integer> mapSeveritytmp = new map<string,integer>();
                for(string sev:lstSeverity)
                {
                    mapSeveritytmp.put(sev,0);
                
                }
                wra.mapSeverity168= mapSeveritytmp.clone();
                wra.mapSeveritySupervised=mapSeveritytmp.clone();
                wra.mapSeverityowned=mapSeveritytmp.clone();
                wra.mapSeverity48=mapSeveritytmp.clone();
                wra.mapSeverity24=mapSeveritytmp.clone();
                                
                wra.usrtime= current.format('E MM/dd/yyyy hh:mm a', mapusrs.get(usrid).TimeZoneSidKey);//hh:mm a
            
                Integer currTm = Integer.valueOf(current.format('HHmm', mapusrs.get(usrid).TimeZoneSidKey));
                String weekday = current.format('E', mapusrs.get(usrid).TimeZoneSidKey);
                String daysoff = mapusrs.get(usrid).Weekdays_Unavailable__c;

                String daystart = mapusrs.get(usrid).Work_Day_Start__c == null ? '0' : mapusrs.get(usrid).Work_Day_Start__c.replace(':','');
                String dayend = mapusrs.get(usrid).Work_Day_End__c == null ? '0' : mapusrs.get(usrid).Work_Day_End__c.replace(':','');
                Integer starthr = Integer.valueOf(daystart);
                Integer endhr = Integer.valueOf(dayend);

                if ( wra.usr.Current_Status__c == 'Unavailable' )        
                     wra.color= 'black';
                else if ( mapusrs.get(usrid).Work_Day_Start__c == null || mapusrs.get(usrid).Work_Day_End__c == null || 
                                                             mapusrs.get(usrid).Work_Day_Start__c == mapusrs.get(usrid).Work_Day_End__c )
                     wra.color='red'; 
                else {
                    if ( starthr < endhr) {
                        if ( daysoff != null && daysoff.contains(weekday) )
                            wra.color='red'; 
                        else if ( starthr <= currTm && endhr > currTm )
                            wra.color='green';
                        else
                            wra.color='red';
                    }
                    else {
                        String privdy = (current.addDays(-1)).format('E', mapusrs.get(usrid).TimeZoneSidKey);
                        if ( daysoff != null && daysoff.contains(weekday) && daysoff.contains(privdy) )
                            wra.color='red';  
                        else if ( daysoff != null && daysoff.contains(privdy) && starthr > currTm)
                            wra.color='red';      
                        else if ( daysoff != null && daysoff.contains(weekday) && endhr < currTm)
                             wra.color='red'; 
                        else if ( starthr > currTm && endhr < currTm )
                            wra.color='red';
                        else
                            wra.color='green';                  
                    }
                }
                mapwrapper.put(usrid,wra);
            }

        /***************All non-closed by Owner ***********************************/
        AggregateResult[] groupedNonClosedOwner;
           groupedNonClosedOwner = [SELECT ownerid,count(id) cnt FROM case
                                    WHERE ownerid in :mapusrs.keySet() AND Status != 'Closed' group by ownerid];

            for (AggregateResult ar : groupedNonClosedOwner) {
                  if( mapwrapper.containsKey(string.valueOf(ar.get('ownerid'))) ) {
                      wrapper wra = mapwrapper.get(String.valueOf(ar.get('ownerid')));
                      wra.cntTotalNonClosed = Integer.valueOf(ar.get('cnt'));
                      mapwrapper.put(String.valueOf(ar.get('ownerid')),wra);
                  }
            }

        /**********Get counts for Cases Owned***************************************/
        AggregateResult[] groupedResultsOwner;
        if(selectedpsg=='All')
            groupedResultsOwner= [SELECT priority,ownerid,count(id) cnt from case
                        where ownerid in :mapusrs.keySet()
                        AND Owner_Product_Support_Group__c!=null
                         AND isclosed=false
                         AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request')
                         AND Sub_Status__c IN ('Investigation', 'New', 'Customer Responded', 'Update from Customer')
                         AND Status IN ('Open', 'Open - Customer Care', 'Service Restored') 
                        group by ownerid,priority];
        else
            groupedResultsOwner= [SELECT priority,ownerid,count(id) cnt from case
                        where ownerid in :mapusrs.keySet()
                        AND Owner_Product_Support_Group__c=:selectedPSG 
                         AND isclosed=false
                         AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request')
                         AND Sub_Status__c IN ('Investigation', 'New', 'Customer Responded', 'Update from Customer')
                         AND Status IN ('Open', 'Open - Customer Care', 'Service Restored')
                        group by ownerid,priority];
                        
                        for (AggregateResult ar : groupedResultsOwner)  
                        {

                            if(mapwrapper.containsKey(string.valueOf(ar.get('ownerid'))))
                            {
                                wrapper wra = mapwrapper.get(String.valueOf(ar.get('ownerid')));
                
                                map<string,integer> mapSeverityOwnedtmp= wra.mapSeverityOwned;
                                if(mapSeverityOwnedtmp.containsKey(String.valueOf(ar.get('priority'))))
                                    mapSeverityOwnedtmp.put(String.valueOf(ar.get('priority')),mapSeverityOwnedtmp.get(String.valueOf(ar.get('priority')))+Integer.valueOf(ar.get('cnt')));
                                else
                                    {
                                        System.debug('******found a different priority***'+ar.get('priority'));
                                        for(string str:lstseverity)
                                        {
                                            if(str.tolowercase().contains(String.valueOf(ar.get('priority')).tolowercase()))
                                            {
                                                System.debug('******matched a real one***'+str);
                                                
                                                if(mapSeverityOwnedtmp.containsKey(str))
                                                    mapSeverityOwnedtmp.put(str,mapSeverityOwnedtmp.get(str)+Integer.valueOf(ar.get('cnt')));   
                                                else
                                                    mapSeverityOwnedtmp.put(str,Integer.valueOf(ar.get('cnt')));
                                                break;
                                            }
                                        }
                                    }
                                wra.mapSeverityOwned= mapSeverityOwnedtmp;
                                wra.cntTotalOwned = wra.cntTotalOwned+Integer.valueOf(ar.get('cnt'));
                                mapwrapper.put(String.valueOf(ar.get('ownerid')),wra);
                                System.debug('******wra.mapSeveritySupervised:'+mapwrapper.get(String.valueOf(ar.get('ownerid'))).mapSeveritySupervised);
                            }                            
                        }  
          /**********Get counts for Cases Supervised***************************************/              
          AggregateResult[] groupedResultsSupervisor;
          if(selectedpsg=='All')
             groupedResultsSupervisor= [SELECT priority,Expert_help__c,count(id) cnt from case 
                                                          where Expert_help__c in :mapusrs.keySet()
                                                            AND Owner_Product_Support_Group__c!=null
                                                            AND isclosed=false
                                                            AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request')
                                                            AND Sub_Status__c IN ('Investigation', 'New', 'Customer Responded', 'Update from Customer')
                                                            AND Status IN ('Open', 'Open - Customer Care', 'Service Restored')  
                                                            group by Expert_help__c ,priority];
          else
            groupedResultsSupervisor= [SELECT priority,Expert_help__c,count(id) cnt from case 
                                                          where Expert_help__c in :mapusrs.keySet()
                                                            AND Owner_Product_Support_Group__c=:selectedPSG 
                                                            AND isclosed=false
                                                            AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request')
                                                            AND Sub_Status__c IN ('Investigation', 'New', 'Customer Responded', 'Update from Customer')
                                                            AND Status IN ('Open', 'Open - Customer Care', 'Service Restored') 
                                                            group by Expert_help__c ,priority];
                                                            
                        for (AggregateResult ar : groupedResultsSupervisor)  
                        {
            
                            if(mapwrapper.containsKey(string.valueOf(ar.get('Expert_help__c'))))
                            {
                                wrapper wra = mapwrapper.get(String.valueOf(ar.get('Expert_help__c')));
                                
                                map<string,integer> mapSeveritySupervisedtmp= wra.mapSeveritySupervised;
                                System.debug('******wra.mapSeveritySupervised:'+wra.mapSeveritySupervised);
                                if(mapSeveritySupervisedtmp==null)
                                {
                                    mapSeveritySupervisedtmp = new Map<string,integer>();
                                    for(string sev:lstSeverity)
                                    {
                                        mapSeveritySupervisedtmp.put(sev,0);
                                    
                                    }
                                }
                                if(mapSeveritySupervisedtmp.containsKey(String.valueOf(ar.get('priority'))))
                                    mapSeveritySupervisedtmp.put(String.valueOf(ar.get('priority')),mapSeveritySupervisedtmp.get(String.valueOf(ar.get('priority')))+Integer.valueOf(ar.get('cnt')));
                                else
                                {
                                    System.debug('******found a different priority***'+ar.get('priority'));
                                    for(string str:lstseverity)
                                    {
                                        if(str.tolowercase().contains(String.valueOf(ar.get('priority')).tolowercase()))
                                        {
                                            System.debug('******matched a real one***'+str);
                                            
                                            if(mapSeveritySupervisedtmp.containsKey(str))
                                                mapSeveritySupervisedtmp.put(str,mapSeveritySupervisedtmp.get(str)+Integer.valueOf(ar.get('cnt'))); 
                                            else
                                                mapSeveritySupervisedtmp.put(str,Integer.valueOf(ar.get('cnt')));
                                            break;
                                        }
                                    }
                                }
                                wra.mapSeveritySupervised= mapSeveritySupervisedtmp;
                                if(wra.cntTotalSupervised!=null)
                                    wra.cntTotalSupervised = wra.cntTotalSupervised+Integer.valueOf(ar.get('cnt'));
                                else
                                    wra.cntTotalSupervised = 1;
                                mapwrapper.put(String.valueOf(ar.get('Expert_help__c')),wra);
                            }                            
                        }  
                        System.debug('*******mapwrapper after supervisor'+mapwrapper);
                    
          /**********Get counts for Cases assigned in the last 168 hrs***************************************/
          AggregateResult[] groupedResults168;
          if(selectedpsg=='All')
            groupedResults168= [SELECT priority,ownerid,count(id) cnt from case 
                                                          where ownerid in :mapusrs.keySet()
                                                            AND Owner_Product_Support_Group__c!=null
                                                            AND (isclosed=false OR closeddate>=LAST_WEEK)
                                                            AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request')  
                                                            AND Last_Owner_Change__c>:System.now().addhours(-168)
                                                            group by ownerid,priority];
          else
            groupedResults168= [SELECT priority,ownerid,count(id) cnt from case 
                                                          where ownerid in :mapusrs.keySet()
                                                            AND Owner_Product_Support_Group__c=:selectedPSG 
                                                            AND (isclosed=false OR closeddate>=LAST_WEEK)
                                                            AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request')  
                                                            AND Last_Owner_Change__c>:System.now().addhours(-168)
                                                            group by ownerid,priority];                                                         
                        
                        for (AggregateResult ar : groupedResults168)  
                        {
                            if(mapwrapper.containsKey(string.valueOf(ar.get('ownerid'))))
                            {
                                wrapper wra = mapwrapper.get(String.valueOf(ar.get('ownerid')));
                                
                                map<string,integer> mapSeverity168tmp= wra.mapSeverity168;
                                if(mapSeverity168tmp==null)
                                {
                                    mapSeverity168tmp = new Map<string,integer>();
                                    for(string sev:lstSeverity)
                                    {
                                        mapSeverity168tmp.put(sev,0);
                                    
                                    }
                                }
                                if(mapSeverity168tmp.containsKey(String.valueOf(ar.get('priority'))))
                                    mapSeverity168tmp.put(String.valueOf(ar.get('priority')),mapSeverity168tmp.get(String.valueOf(ar.get('priority')))+Integer.valueOf(ar.get('cnt')));
                                else
                                {
                                    //mapSeverity168tmp.put(String.valueOf(ar.get('priority')),Integer.valueOf(ar.get('cnt')));
                                    System.debug('******found a different priority***'+ar.get('priority'));
                                    for(string str:lstseverity)
                                    {
                                        if(str.tolowercase().contains(String.valueOf(ar.get('priority')).tolowercase()))
                                        {
                                            System.debug('******matched a real one***'+str);
                                            
                                            if(mapSeverity168tmp.containsKey(str))
                                                mapSeverity168tmp.put(str,mapSeverity168tmp.get(str)+Integer.valueOf(ar.get('cnt')));   
                                            else
                                                mapSeverity168tmp.put(str,Integer.valueOf(ar.get('cnt')));
                                            break;
                                        }
                                    }
                                }
                                wra.mapSeverity168= mapSeverity168tmp;
                                if(wra.cntTotal168!=null)
                                    wra.cntTotal168 = wra.cntTotal168+Integer.valueOf(ar.get('cnt'));
                                else
                                    wra.cntTotal168 = 1;
                                mapwrapper.put(String.valueOf(ar.get('ownerid')),wra);
                            }                           
                        }  
        /**********Get counts for Cases assigned in the last 48 hrs***************************************/  
        AggregateResult[] groupedResults48;
        if(selectedpsg=='All')      
            groupedResults48= [SELECT priority,ownerid,count(id) cnt from case 
                              where ownerid in :mapusrs.keySet()
                                AND Owner_Product_Support_Group__c!=null
                                AND (isclosed=false OR closeddate>=LAST_WEEK)
                                AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request') 
                                AND Last_Owner_Change__c>:System.now().addhours(-48)
                                group by ownerid,priority];
        else
            groupedResults48= [SELECT priority,ownerid,count(id) cnt from case 
                              where ownerid in :mapusrs.keySet()
                                AND Owner_Product_Support_Group__c=:selectedPSG 
                                AND (isclosed=false OR closeddate>=LAST_WEEK)
                                AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request')  
                                AND Last_Owner_Change__c>:System.now().addhours(-48)
                                group by ownerid,priority];                             
                        
                        for (AggregateResult ar : groupedResults48)  
                        {
                            if(mapwrapper.containsKey(string.valueOf(ar.get('ownerid'))))
                            {
                                wrapper wra = mapwrapper.get(String.valueOf(ar.get('ownerid')));
                                
                                map<string,integer> mapSeverity48tmp= wra.mapSeverity48;
                                if(mapSeverity48tmp==null)
                                {
                                    mapSeverity48tmp = new Map<string,integer>();
                                    for(string sev:lstSeverity)
                                    {
                                        mapSeverity48tmp.put(sev,0);
                                    
                                    }
                                }
                                if(mapSeverity48tmp.containsKey(String.valueOf(ar.get('priority'))))
                                    mapSeverity48tmp.put(String.valueOf(ar.get('priority')),mapSeverity48tmp.get(String.valueOf(ar.get('priority')))+Integer.valueOf(ar.get('cnt')));
                                else
                                {
                                    //mapSeverity48tmp.put(String.valueOf(ar.get('priority')),Integer.valueOf(ar.get('cnt')));
                                    System.debug('******found a different priority***'+ar.get('priority'));
                                    for(string str:lstseverity)
                                    {
                                        if(str.tolowercase().contains(String.valueOf(ar.get('priority')).tolowercase()))
                                        {
                                            System.debug('******matched a real one***'+str);
                                            
                                            if(mapSeverity48tmp.containsKey(str))
                                                mapSeverity48tmp.put(str,mapSeverity48tmp.get(str)+Integer.valueOf(ar.get('cnt'))); 
                                            else
                                                mapSeverity48tmp.put(str,Integer.valueOf(ar.get('cnt')));
                                            break;
                                        }
                                    }                                   
                                }
                                wra.mapSeverity48= mapSeverity48tmp;
                                if(wra.cntTotal48!=null)
                                    wra.cntTotal48 = wra.cntTotal48+Integer.valueOf(ar.get('cnt'));
                                else
                                    wra.cntTotal48 = 1;
                                mapwrapper.put(String.valueOf(ar.get('ownerid')),wra);
                            }                           
                        }
        /**********Get counts for Cases assigned in the last 24 hrs***************************************/
          AggregateResult[] groupedResults24;
          if(selectedpsg=='All')    
            groupedResults24= [SELECT priority,ownerid,count(id) cnt from case 
                              where ownerid in :mapusrs.keySet()
                                AND Owner_Product_Support_Group__c!=null
                                AND (isclosed=false OR closeddate>=LAST_WEEK)
                                AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request')  
                                AND Last_Owner_Change__c>:System.now().addhours(-24)
                                group by ownerid,priority];
          else
            groupedResults24= [SELECT priority,ownerid,count(id) cnt from case 
                              where ownerid in :mapusrs.keySet()
                                AND Owner_Product_Support_Group__c=:selectedPSG 
                                AND (isclosed=false OR closeddate>=LAST_WEEK)
                                AND RecordType.DeveloperName IN ('Genesys_Product_Case','Genesys_Feature_Request_Case','Genesys_Cloud_Support_Request',
                              'Genesys_Cloud_Service_Request','Genesys_Cloud_Incident','Genesys_Cloud_Feature_Request','Premises_Service_Request')  
                                AND Last_Owner_Change__c>:System.now().addhours(-24)
                                group by ownerid,priority];                        
                        for (AggregateResult ar : groupedResults24)  
                        {
                            if(mapwrapper.containsKey(string.valueOf(ar.get('ownerid'))))
                            {
                                wrapper wra = mapwrapper.get(String.valueOf(ar.get('ownerid')));
                                
                                map<string,integer> mapSeverity24tmp= wra.mapSeverity24;
                                if(mapSeverity24tmp==null)
                                {
                                    mapSeverity24tmp = new Map<string,integer>();
                                    for(string sev:lstSeverity)
                                    {
                                        mapSeverity24tmp.put(sev,0);
                                    
                                    }
                                }
                                if(mapSeverity24tmp.containsKey(String.valueOf(ar.get('priority'))))
                                    mapSeverity24tmp.put(String.valueOf(ar.get('priority')),mapSeverity24tmp.get(String.valueOf(ar.get('priority')))+Integer.valueOf(ar.get('cnt')));
                                else
                                {
                                    //mapSeverity24tmp.put(String.valueOf(ar.get('priority')),Integer.valueOf(ar.get('cnt')));
                                    System.debug('******found a different priority***'+ar.get('priority'));
                                    for(string str:lstseverity)
                                    {
                                        if(str.tolowercase().contains(String.valueOf(ar.get('priority')).tolowercase()))
                                        {
                                            System.debug('******matched a real one***'+str);
                                            
                                            if(mapSeverity24tmp.containsKey(str))
                                                mapSeverity24tmp.put(str,mapSeverity24tmp.get(str)+Integer.valueOf(ar.get('cnt'))); 
                                            else
                                                mapSeverity24tmp.put(str,Integer.valueOf(ar.get('cnt')));
                                            break;
                                        }
                                    }                                   
                                }
                                wra.mapSeverity24= mapSeverity24tmp;
                                if(wra.cntTotal24!=null)
                                    wra.cntTotal24 = wra.cntTotal24+Integer.valueOf(ar.get('cnt'));
                                else
                                    wra.cntTotal24 = 1;
                                mapwrapper.put(String.valueOf(ar.get('ownerid')),wra);
                            }                           
                        }
            //sortField = 'currenttime';
            //sort();              
        }
         return null;  
    }
    public PageReference sort()
    {
        //sortField = sortFieldtmp;
        System.debug('*******sortField:'+sortField);
        System.debug('*******sortOrder:'+sortOrder);
        List<wrapper> lst =mapwrapper.values();
        if(sortOrder==null)
            sortOrder='asc';
        else if(sortOrder=='asc')
            sortOrder='dsc';
        else if(sortOrder=='dsc')
            sortOrder='asc';
        lst.sort();
        System.debug('******lst:'+lst);
        lstusrs.clear();
        lstusrs = new List<user>();
        for(Wrapper wra:lst)
        {
            lstusrs.add(wra.usr);
        }
        return null;
    }
    public PageReference filterReport()
    {
        if(filterEnabled==null || filterEnabled==false)
        {            
            //lstusrs.clear(); 
            List<user> tmplst = new List<user>();
            for(User usr:lstusrs)
            {            
                if(mapWrapper.get(usr.id).checked)
                {
                    tmplst.add(mapWrapper.get(usr.id).usr);                    
                }
                else
                   mapWrapper.remove(usr.id);       
            }
            lstusrs.clear();
            lstusrs = tmplst;
            filterEnabled=true;
        }
        else
        {
            filterEnabled=false;
            generateReport();       
            
        }   
       
        return null;
    }
}