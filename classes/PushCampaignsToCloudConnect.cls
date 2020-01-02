/***********************************************************************************************
 * Class Name   : PushCampaignsToCloudConnect
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : This class holds 3 methods - 1) to push campigns to cloud connect, 2) to push campaignmemebers to cloud connect, 
                          3)to push campaignmembers to cloud connnect when lead is synced with cloud connect
 **********************************************************************************************/
 
public without sharing class PushCampaignsToCloudConnect
{
    public static Boolean isExecutedCampaign = false;
    public static Boolean isExecutedCampaignMember = false;
    
    public static String result;
    
    static Cloud_Connect_Configuration__c cc = Cloud_Connect_Configuration__c.getOrgDefaults();
    
    static String campaignWherClause = ' from Campaign where Id in ';
    static String campaignMemberLeadWherClause = ' from CampaignMember where Campaign.Marketing_Group__c = \'Cloud Connect\' and LeadId in ';
    static String campaignMemberWherClause = ' from CampaignMember where Campaigns_Marketing_Group__c = \'Cloud Connect\' and Id in ';
    static String campaignsRestUrl = cc.Campaigns_URL__c;
    static String campaignMembersRestUrl = cc.Campaign_Members_URL__c;
    static String fieldsetName = 'Cloud_Connect';
    
    @future(callout=true)
    public static void pushCampaignsFuture(Set<Id> campaignIds)
    {
        pushCampaigns(campaignIds);
    }
    
    public static void pushCampaigns(Set<Id> campaignIds)
    {        
        List<Campaign> cList = new List<Campaign>();
        String queryStr = ''; String idStr = '';
        String JSONC;
        List<Database.UpsertResult> upsertResult;
        
        try
        {
        queryStr = getFields(Schema.SObjectType.Campaign.fieldSets.getMap().get(fieldsetName).getFields());
        
        idStr = formIdString(campaignIds);
        
        queryStr += campaignWherClause + idStr;
        
        System.debug('------>QueryStr: '+queryStr);
        
        cList = Database.query(queryStr);
        
        System.debug('-----> Campaigns Size: '+cList.size());
        
        if(cList.size()>0)
        {
            JSONC = JSON.serialize(cList);
            
            System.debug('-----> JSON Campaign Request: '+JSONC);
            
            if(RESTAPICallsToCloudConnect.authenticate()==200)
            {
                upsertResult = RESTAPICallsToCloudConnect.upsertCall(JSONC,campaignsRestUrl);
                System.debug('-----> Upsert Result: '+upsertResult);
                updateFlags(cList,upsertResult);
            }
        }
        }
        catch(Exception e)
        {
            updateFlagsOnInternalError(cList,e.getMessage());
        }
    }
    
    @future(callout=true)
    public static void pushCampaignMembersFromLeadFuture(Set<Id> leadIds, Id scheduledJobId)
    {
        pushCampaignMembersFromLead(leadIds,scheduledJobId);
    }
    
    public static void pushCampaignMembersFromLead(Set<Id> leadIds, Id scheduledJobId)
    {
        List<CampaignMember> cMembersList = new List<CampaignMember>();
        String queryStr = ''; String idStr = '';
        String JSONCM;
        List<Database.UpsertResult> upsertResult;
        
        try
        {
        queryStr = getFields(Schema.SObjectType.CampaignMember.fieldSets.getMap().get(fieldsetName).getFields());
        
        idStr = formIdString(leadIds);
        
        queryStr += campaignMemberLeadWherClause + idStr;
        
        System.debug('----->QueryStr: '+queryStr);
        
        cMembersList = Database.query(queryStr);
        
        System.debug('-----> Campaign Members Size: '+cMembersList.size());
        
        if(cMembersList.size()>0)
        {
            JSONCM = JSON.serialize(cMembersList);
            
            System.debug('-----> JSON Campaign Member Request: '+JSONCM);
            
            if(RESTAPICallsToCloudConnect.authenticate()==200)
            {
                upsertResult = RESTAPICallsToCloudConnect.upsertCall(JSONCM,campaignMembersRestUrl);
                System.debug('-----> Upsert Result: '+upsertResult);
                updateFlags(cMembersList,upsertResult);
            }
            
            System.abortJob(scheduledJobId);
        }
        }
        catch(Exception e)
        {
            updateFlagsOnInternalError(cMembersList,e.getMessage());
        }
    }
    
    @future(callout=true)
    public static void pushCampaignMembersFuture(Set<Id> unsyncedMemberIds,Set<Id> syncedMemberIds)
    {
        pushCampaignMembers(unsyncedMemberIds,syncedMemberIds);
    }
    
    public static void pushCampaignMembers(Set<Id> unsyncedMemberIds,Set<Id> syncedMemberIds)
    {
        List<CampaignMember> cMembersList = new List<CampaignMember>();
        List<CampaignMember> cMembersList1 = new List<CampaignMember>();
        List<CampaignMember> cMembersList2 = new List<CampaignMember>();
        String queryStr1 = ''; String queryStr2 = ''; String idStr1 = '('; String idStr2 = '(';
        String JSONCM;
        List<Database.UpsertResult> upsertResult;
        
        try
        {
        queryStr1 = getFields(Schema.SObjectType.CampaignMember.fieldSets.getMap().get(fieldsetName).getFields());
        
        if(queryStr1.contains('LeadId,')) queryStr2 = queryStr1.replace('LeadId,','');
        else queryStr2 = queryStr1.replace('LeadId','');
        if(queryStr2.contains('CampaignId,')) queryStr2 = queryStr2.replace('CampaignId,','');
        else queryStr2 = queryStr2.replace('CampaignId','');
        
        IdStr1 = formIdString(unsyncedMemberIds);
        IdStr2 = formIdString(syncedMemberIds);
        
        queryStr1 += campaignMemberWherClause + idStr1;
        queryStr2 += campaignMemberWherClause + idStr2;
        
        System.debug('------>Query Str 1: '+queryStr1);
        System.debug('------>Query Str 2: '+queryStr2);
        
        if(unsyncedMemberIds.size()>0)
        {
            cMembersList1 = Database.query(queryStr1);
            cMembersList.addAll(cMembersList1);
        }
        if(syncedMemberIds.size()>0)
        {
            System.debug('=====>'+queryStr2);
            cMembersList2 = Database.query(queryStr2);
            System.debug('=====>'+cMembersList2);
            cMembersList.addAll(cMembersList2);
        }
            
        System.debug('-----> Campaign Members List 1: '+cMembersList1);
        System.debug('-----> Campaign Members List 2: '+cMembersList2);            
        
        System.debug('-----> Campaign Member Size: '+cMembersList.size());
        
        if(cMembersList.size()>0)
        {            
            JSONCM = JSON.serialize(cMembersList);
            
            System.debug('-----> JSON Campaign Member Request: '+JSONCM);
            
            if(RESTAPICallsToCloudConnect.authenticate()==200)
            {
                upsertResult = RESTAPICallsToCloudConnect.upsertCall(JSONCM,campaignMembersRestUrl);
                System.debug('-----> Upsert Result: '+upsertResult);
                updateFlags(cMembersList,upsertResult);
            }
        }
        }
        catch(Exception e)
        {
            System.debug('------------------------------------------'+e.getMessage());
            updateFlagsOnInternalError(cMembersList,e.getMessage());
        }
    }
    
    public static void updateFlags(List<SObject> cList, List<Database.UpsertResult> upsertResult)
    {
        isExecutedCampaignMember = true;
        isExecutedCampaign = true;
        
        for(Integer i=0; i<cList.size(); i++)
        {
            /*As per Apex Reference guide - spring 13, "Each element in the UpsertResult
              array corresponds to the sObject array passed as the sObject[] parameter in the upsert database method, that is, the first
              element in the UpsertResult array matches the first element passed in the sObject array, the second element corresponds with
              the second element, and so on. If only one sObject is passed in, the UpsertResults array contains a single element."
            */
            if(upsertResult.size() <= i){
                break;
            }
            if(!upsertResult[i].isSuccess())
            {
                cList[i].put('Cloud_Connect_Failed__c',true);
                cList[i].put('Cloud_Connect_Failed_Reason__c',upsertResult[i].getErrors()[0].getMessage());
            }
            else 
            {
                cList[i].put('Sent_to_Cloud_Connect__c',true);
                cList[i].put('Cloud_Connect_Failed__c',false);
                cList[i].Put('Cloud_Connect_Failed_Reason__c','');
            }
        }
        
        if(cList.size()>0)
        {
            update cList;
        }
    }
    
    public static void updateFlagsOnInternalError(List<SObject> cList, String errorMsg)
    {
        System.debug('Exception-----> '+errorMsg);
        isExecutedCampaignMember = true;
        isExecutedCampaign = true;
        
        for(Integer i=0; i<cList.size(); i++)
        {

            cList[i].put('Cloud_Connect_Failed__c',true);
            cList[i].put('Cloud_Connect_Failed_Reason__c',errorMsg);
        }
        
        if(cList.size()>0)
        {
            update cList;
        }
    }
    
    public static String getFields(List<Schema.FieldSetMember> fields)
    {
        String queryStr = 'Select';
        String referenceFieldNames;
        
        for(Schema.FieldSetMember f : fields)
        {
            queryStr += ' '+f.getFieldPath()+',';
        }
        if(queryStr.contains(','))
            queryStr = queryStr.subString(0,queryStr.length()-1);

        return queryStr;
    }
    
    public static String formIdString(Set<Id> ids)
    {
        String idStr = '(';
        
        for(Id i : ids)
        {
              idStr += '\''+i+'\', ';
        }
        if(idStr.contains(', '))
           idStr = idStr.subString(0,idStr.length()-2);
        idStr += ')';
        
        return idStr;
    }
}