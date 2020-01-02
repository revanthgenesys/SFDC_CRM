/***************************************************************************************************
* 
*  Class Name      :   DSRViewController
*  Description     :   This class is used to show DSRView
*  Auther          :   R Systems
* 
****************************************************************************************************/
public with sharing class DSRViewController{
    
    /*@RemoteAction
    public static List<DSR_SCEngagement__c> getDSR(){
     
         return null;
    }    */
    
    @RemoteAction
    public static List<DSR_SCEngagement__c> getDSR(List<String> lstIds){
        
        Set<Id> filterIds = new Set<Id>();
        if(lstIds.size() > 0){
            for(String st : lstIds){
                String ss = st;
                filterIds.add(ss);
            }
        }
        List<DSR_SCEngagement__c> lstaccnt = new List<DSR_SCEngagement__c>();
        
        String dsrQuery = '';
        
        dsrQuery = 'Select Id,Name,Is_Partner_DSR__C,Opportunity_ID__r.Name,'
                    + 'Opportunity_ID__c,Account_ID__c,AE_Name__r.Name,SC_Engagement_Status__c,'
                    + 'Account_ID__r.Name,CreatedDate,Createdby.Name,'
                    + 'LastModifiedDate,LastModifiedBy.Name from DSR_SCEngagement__c';
                    
        
        if(filterIds.size() > 0 ){
                    dsrQuery += ' where Id not in :  filterIds AND Opportunity_ID__c != null AND Account_ID__c != null AND AE_Name__c != null  ORDER BY CreatedDate DESC limit 10000' ;
        }else{
                    dsrQuery += ' where Opportunity_ID__c != null AND Account_ID__c != null AND AE_Name__c != null ORDER BY CreatedDate DESC limit 10000' ;
        }
        
        lstaccnt = (List<DSR_SCEngagement__c>)Database.query(dsrQuery);
        
        /*List<DSR_SCEngagement__c> lstaccnt = [Select Id,
                                                     Name, 
                                                     Is_Partner_DSR__C,
                                                     Opportunity_ID__r.Name, 
                                                     Opportunity_ID__c, 
                                                     Account_ID__c,
                                                     AE_Name__r.Name,
                                                     SC_Engagement_Status__c,  
                                                     Account_ID__r.Name,
                                                     CreatedDate,
                                                     Createdby.Name,
                                                     LastModifiedDate,
                                                     LastModifiedBy.Name
                                                     from DSR_SCEngagement__c
                                                     ORDER BY CreatedDate DESC];*/
        
        return lstaccnt;
    }
}