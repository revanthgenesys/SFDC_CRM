/*
 Purpose: handling Service Level Targets on cases
 Test class: Test_CaseSLTHandler
*/
public without sharing class CaseSLTHandler {
    
    private static Map<Id,Case> processedCases = null;
    private static Map<Id, RecordType> caseTStypesMap;
    
    public static void updateCaseSLTFields (Map<Id, Case> oldMap, List<Case> newList, Boolean isInsert) {
        caseTStypesMap = CaseUtil.getAllTScaseTypesMap();
        if ( processedCases == null )
               processedCases = new Map<Id,Case>();
            
        for ( Case cs : newList ) {
 
            if ( (!caseTStypesMap.get(cs.RecordTypeId).DeveloperName.startswith('Genesys_Cloud_') &&            
                    caseTStypesMap.get(cs.RecordTypeId).DeveloperName != 'Genesys_Product_Case') || 
                  processedCases.containsKey(cs.Id) ) {
                         continue;
             }
                                              
             if ( isInsert ) {
                newCaseSetup(cs);
             }
             else { //Update
                 Case oldCase = oldMap.get(cs.Id);  
                 Boolean isTypeChange = false;
                      ///case type changed from Admin or other type to Product type and not an update from Cloud to Cloud type
                 if ( cs.RecordTypeId != oldCase.RecordTypeId &&
                      (caseTStypesMap.get(cs.RecordTypeId).DeveloperName == 'Genesys_Product_Case' ||
                        caseTStypesMap.get(oldCase.RecordTypeId).DeveloperName == 'Genesys_Product_Case') ) { 
                                                
                        isTypeChange = true;
                 }
                          
                 if ( caseTStypesMap.get(cs.RecordTypeId).DeveloperName == 'Genesys_Product_Case' &&
                      (cs.Sold_To_Account__c  != oldCase.Sold_To_Account__c  || 
                       cs.End_User_Account__c != oldCase.End_User_Account__c || isTypeChange ) ) {                                                    
                            populateTargetsPrem(cs);                            
                 } 
                 else if ( caseTStypesMap.get(cs.RecordTypeId).DeveloperName.startswith('Genesys_Cloud_') &&
                       (cs.Cloud_Deployment__c != oldCase.Cloud_Deployment__c || isTypeChange ) ) {                                                    
                           populateTargetsCloud(cs);                            
                 } 
                                                  
                 ///resolution and status duration fields                
                 if ( cs.Priority != oldCase.Priority || cs.Status != oldCase.Status ) {
                   try {     
                         ///write into cumulative buckets based on the From Status
                         setResolutionDurationFields(cs, oldCase);                  
                         setStatusDurationFields(cs, oldCase);                
    
                         ///reset timestamps based on the To Status               
                         setLastUpdateTimestampStatusFields(cs);
   
                         processedCases.put(cs.Id, null);
                                                   
                   } catch (Exception e){}                                           
                 }     
            }
        }
    }

    static void populateTargetsPrem (Case cs) {
        List<Service_Level_Target__c> srvTrg = new List<Service_Level_Target__c>(); 
        
        if ( cs.Back_Office_Account__c == null )
             return;
  
         srvTrg = [SELECT s.Response_Medium__c, s.Response_Low__c, s.Response_High__c, s.Response_Critical__c, 
                           s.Resolution_Medium__c, s.Resolution_Low__c, s.Resolution_High__c, s.Resolution_Critical__c,
                           s.Restoration_Medium__c, s.Restoration_Low__c, s.Restoration_High__c, s.Restoration_Critical__c,
                           Response_Production_Down__c, Restoration_Production_Down__c, Resolution_Production_Down__c, SLT_Level__c
                    FROM Service_Level_Target__c s
                    WHERE Back_Office_Account__c = :cs.Back_Office_Account__c
                      AND RecordType.DeveloperName = 'SLT_BOA'];
                         
         if ( srvTrg.isEmpty() ) {
                
                List<Back_Office_Account__c> boa = [SELECT Support_Package__c FROM Back_Office_Account__c WHERE Id = :cs.Back_Office_Account__c];
                
                srvTrg = [SELECT s.Response_Medium__c, s.Response_Low__c, s.Response_High__c, s.Response_Critical__c, 
                           s.Resolution_Medium__c, s.Resolution_Low__c, s.Resolution_High__c, s.Resolution_Critical__c,
                           s.Restoration_Medium__c, s.Restoration_Low__c, s.Restoration_High__c, s.Restoration_Critical__c,
                           Response_Production_Down__c, Restoration_Production_Down__c, Resolution_Production_Down__c, SLT_Level__c
                            FROM Service_Level_Target__c s
                            WHERE RecordType.DeveloperName = 'SLT_BOA_Definition'
                             AND BOA_Support_Package__c = :boa[0].Support_Package__c];
          }
          
          if ( ! srvTrg.isEmpty() )  {
          	     cs.SLT_Response_Production_Down__c   = srvTrg[0].Response_Production_Down__c;
          	     cs.SLT_Resolution_Production_Down__c = srvTrg[0].Resolution_Production_Down__c;
          	     cs.SLT_Restoration_Production_Down__c = srvTrg[0].Restoration_Production_Down__c;
                 cs.SLT_Response_Critical__c        = srvTrg[0].Response_Critical__c;
                 cs.SLT_Response_High__c            = srvTrg[0].Response_High__c;
                 cs.SLT_Response_Medium__c          = srvTrg[0].Response_Medium__c;
                 cs.SLT_Response_Low__c             = srvTrg[0].Response_Low__c;
                 cs.SLT_Resolution_Critical__c      = srvTrg[0].Resolution_Critical__c;
                 cs.SLT_Resolution_High__c          = srvTrg[0].Resolution_High__c;
                 cs.SLT_Resolution_Medium__c        = srvTrg[0].Resolution_Medium__c;
                 cs.SLT_Resolution_Low__c           = srvTrg[0].Resolution_Low__c;  
                 cs.SLT_Restoration_Critical__c     = srvTrg[0].Restoration_Critical__c;
                 cs.SLT_Restoration_High__c         = srvTrg[0].Restoration_High__c;
                 cs.SLT_Restoration_Medium__c       = srvTrg[0].Restoration_Medium__c;
                 cs.SLT_Restoration_Low__c          = srvTrg[0].Restoration_Low__c; 
                 cs.SLT_Level__c                    = srvTrg[0].SLT_Level__c;
         }       
         return;     
    }
    
    static void populateTargetsCloud (Case cs) {
        List<Service_Level_Target__c> srvTrg = new List<Service_Level_Target__c>(); 

        if ( cs.Cloud_Deployment__c == null )
             return;
  
         srvTrg = [SELECT s.Response_Medium__c, s.Response_Low__c, s.Response_High__c, s.Response_Critical__c, 
                           s.Resolution_Medium__c, s.Resolution_Low__c, s.Resolution_High__c, s.Resolution_Critical__c,
                           s.Restoration_Medium__c, s.Restoration_Low__c, s.Restoration_High__c, s.Restoration_Critical__c,
                           Response_Production_Down__c, Restoration_Production_Down__c, Resolution_Production_Down__c, SLT_Level__c
                    FROM Service_Level_Target__c s
                    WHERE Cloud_Deployment__c = :cs.Cloud_Deployment__c
                      AND RecordType.DeveloperName = 'SLT_Cloud_Deployment'];
                         
         if ( srvTrg.isEmpty() ) {
                
                List<Cloud_Deployment__c> depl = [SELECT Care_Level__c FROM Cloud_Deployment__c WHERE Id = :cs.Cloud_Deployment__c];
                
                srvTrg = [SELECT s.Response_Medium__c, s.Response_Low__c, s.Response_High__c, s.Response_Critical__c, 
                           s.Resolution_Medium__c, s.Resolution_Low__c, s.Resolution_High__c, s.Resolution_Critical__c,
                           s.Restoration_Medium__c, s.Restoration_Low__c, s.Restoration_High__c, s.Restoration_Critical__c,
                           	Response_Production_Down__c, Restoration_Production_Down__c, Resolution_Production_Down__c, SLT_Level__c
                            FROM Service_Level_Target__c s
                            WHERE RecordType.DeveloperName = 'SLT_Cloud_Master_Definition'
                             AND Cloud_Support_Package__c = :depl[0].Care_Level__c];
          }
          
          if ( ! srvTrg.isEmpty() )  {
          	     cs.SLT_Response_Production_Down__c   = srvTrg[0].Response_Production_Down__c;
          	     cs.SLT_Resolution_Production_Down__c = srvTrg[0].Resolution_Production_Down__c;
          	     cs.SLT_Restoration_Production_Down__c = srvTrg[0].Restoration_Production_Down__c;
                 cs.SLT_Response_Critical__c        = srvTrg[0].Response_Critical__c;
                 cs.SLT_Response_High__c            = srvTrg[0].Response_High__c;
                 cs.SLT_Response_Medium__c          = srvTrg[0].Response_Medium__c;
                 cs.SLT_Response_Low__c             = srvTrg[0].Response_Low__c;
                 cs.SLT_Resolution_Critical__c      = srvTrg[0].Resolution_Critical__c;
                 cs.SLT_Resolution_High__c          = srvTrg[0].Resolution_High__c;
                 cs.SLT_Resolution_Medium__c        = srvTrg[0].Resolution_Medium__c;
                 cs.SLT_Resolution_Low__c           = srvTrg[0].Resolution_Low__c;  
                 cs.SLT_Restoration_Critical__c     = srvTrg[0].Restoration_Critical__c;
                 cs.SLT_Restoration_High__c         = srvTrg[0].Restoration_High__c;
                 cs.SLT_Restoration_Medium__c       = srvTrg[0].Restoration_Medium__c;
                 cs.SLT_Restoration_Low__c          = srvTrg[0].Restoration_Low__c;
                 cs.SLT_Level__c                    = srvTrg[0].SLT_Level__c;                  
         }       
         return;     
    } 
    
    static void setResolutionDurationFields (Case cs, Case oldCase) {
        if ( (oldCase.Status == 'Open' || oldCase.Status == 'Service Restored') && oldCase.Last_SLT_ResolAffecting_Update__c != null ) {
        
            Double lastStateDur = getDurationHours(oldCase.Last_SLT_ResolAffecting_Update__c);
                
            if ( oldCase.Priority == 'Prod Down' ) {
                  cs.Resolution_ProdDown_Duration__c += lastStateDur;                
            }
            else if  ( oldCase.Priority == '1-Critical' ) {
                cs.Resolution_Critical_Duration__c += lastStateDur;              
            }
            else if  ( oldCase.Priority == '2-High' ) {
                cs.Resolution_High_Duration__c += lastStateDur;
            }
            else if  ( oldCase.Priority == '3-Medium' ) {
                cs.Resolution_Medium_Duration__c += lastStateDur;
            }
            else if  ( oldCase.Priority == '4-Low' ) {
                cs.Resolution_Low_Duration__c += lastStateDur;
            }         
        }
    }
    
    static void setStatusDurationFields(Case cs, Case oldCase) {
        
        if ( oldCase.Status == 'Awaiting Info' && oldCase.Last_AwaitingInfo_Timestamp__c != null )  {
                cs.Duration_In_Awaiting_Info__c += getDurationHours(oldCase.Last_AwaitingInfo_Timestamp__c);
        }
        else if ( (oldCase.Status == 'Solution Proposed' || oldCase.Status == 'Replied') && oldCase.Last_SolProposed_Timestamp__c != null )  {
                cs.Duration_In_Solution_Proposed__c += getDurationHours(oldCase.Last_SolProposed_Timestamp__c);
        }   
        else if ( oldCase.Status == 'Closed' && cs.Status == 'Open' ) {
                cs.Duration_In_Closed_Before_Reopen__c += getDurationHours(oldCase.ClosedDate);
        }       
    }
                     
    static void setLastUpdateTimestampStatusFields(Case cs) {  
         ///response, replied, restored and incident resolved timestamps never cleared
         // need to clear for Total time in a Status formula calculations
        cs.Last_SLT_ResolAffecting_Update__c = null;
        cs.Last_AwaitingInfo_Timestamp__c    = null;
        cs.Last_SolProposed_Timestamp__c     = null;
                  
        if ( cs.Status == 'Awaiting Info' ) {
             cs.Last_AwaitingInfo_Timestamp__c = datetime.now();
        } 
        else if ( cs.Status == 'Solution Proposed' || cs.Status == 'Replied') {
             cs.Last_SolProposed_Timestamp__c = datetime.now(); 
             cs.Last_IncidentResolved_Timestamp__c = datetime.now();
             cs.Last_Priority_IncidentResolved__c = cs.Priority;                    
        } 
        else if ( cs.Status == 'Service Restored' ) {
            cs.Last_Service_Restored_Timestamp__c = datetime.now();  
            cs.Last_Priority_ServiceRestored__c = cs.Priority; 
            cs.Last_SLT_ResolAffecting_Update__c = datetime.now();     
        }
        else if ( cs.Status == 'Open' )  {       
             cs.Last_SLT_ResolAffecting_Update__c = datetime.now();  
        }
        else if ( cs.Status == 'Closed' && cs.First_Response_Timestamp__c == null )  {       
             cs.First_Response_Timestamp__c = datetime.now(); 
             cs.Last_Priority_FirstResponse__c = cs.Priority;
        }     
    }
        
    static void newCaseSetup (Case cs) {
        try {
            if ( caseTStypesMap.get(cs.RecordTypeId).DeveloperName == 'Genesys_Product_Case' )
                populateTargetsPrem(cs);
            else 
                populateTargetsCloud(cs);
                          
            setLastUpdateTimestampStatusFields(cs);                       
            processedCases.put(cs.Id, null);
     } catch (Exception e) {}   
    }
    
    static Double getDurationHours (Datetime lastModDate) {
         Datetime current = System.now();
         Long currDt = current.getTime();
         Long lastDt = lastModDate.getTime();
         Double ret = (currDt - lastDt) / (1000.0*60.0*60.0);
         return ret;
    }

}