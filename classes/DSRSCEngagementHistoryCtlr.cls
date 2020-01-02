/***************************************************************************************************
* 
*  Class Name      :   DSRSCEngagementHistoryCtlr
*  Description     :   This class is used to control the Design Page Overview (SC_Engagement_Design_Overview)
*  Auther          :   R Systems
* 
****************************************************************************************************/
public with sharing class DSRSCEngagementHistoryCtlr {
    
    public List<DSR_SC_Engagement_History__c> lstsceHistory{get;set;}
    public String HomeURL{get;set;}
    
    public DSRSCEngagementHistoryCtlr(){
        Id designId = apexpages.currentpage().getparameters().get('id');
        
        lstsceHistory =  [Select  Id, 
                                Action__c, 
                                ActionDate__c,
                                ActionPerformedBy__c,
                                ActionPerformedBy__r.Name,
                                Attachment_Sub_Type__c,
                                Attachment_Type__c,
                                DSRSCEngagement__c,
                                DSRSCEngagement__r.Name,
                                SCEngagementStage__c,
                                SCEngagementStatus__c,
                                User__c,
                                UserType__c,
                                CreatedDate,
                                LastmodifiedDate,
                                CreatedById,
                                LastModifiedById,
                                CreatedBy.Name,
                                LastModifiedBy.Name,
                                DSRSCEngagement__r.Is_Partner_DSR__c
                                from DSR_SC_Engagement_History__c 
                                where DSRSCEngagement__c= : designId ORDER BY CreatedDate DESC];
                                
        if(lstsceHistory[0].DSRSCEngagement__r.Is_Partner_DSR__c == false)
            HomeURL = '/apex/SC_Engagement_DSR?id='+lstsceHistory[0].DSRSCEngagement__c; 
        else                           
            HomeURL = '/partner/SC_EngagementPartner_DSR?id='+lstsceHistory[0].DSRSCEngagement__c; 
        
    }
}