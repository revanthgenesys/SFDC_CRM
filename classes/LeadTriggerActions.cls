/*
* @Name: LeadTriggerActions
* @Desc: Called from LeadTrigger..all actions happen here.
* @Author: Rohit Mehta
* @Date: 11/16/2012
*/
public with sharing class LeadTriggerActions {

    public static void doAfterInsert(List<Lead> leads) {
        List<Lead> cloudConnectLeads = new List<Lead>();
        for (Lead l : leads) {
            if (l.Cloud_Connect_Sync__c) {
                cloudConnectLeads.add(l);
            }
        }
        cloudConnectSync(cloudConnectLeads);
    }

    public static void doAfterUpdate(Map<Id, Lead> oldLeads, Map<Id, Lead> newLeads) {
        List<Lead> cloudConnectLeads = new List<Lead>();
        for (Id leadId : newLeads.keySet()) {
            Lead l = newLeads.get(leadId);
            Lead oldLead = oldLeads.get(leadId);
            if (l.Cloud_Connect_Sync__c && (!oldLead.Cloud_Connect_Sync__c)) {
                cloudConnectLeads.add(l);
            }
        }
        cloudConnectSync(cloudConnectLeads);
    }
    
    public static void cloudConnectSync(List<Lead> leads) {
        //query the connection based on the connection name
        
         if (leads.isEmpty()) {
            //nothing to do here. Return.
            return;
        }
        
        List<PartnerNetworkConnection> connList = new List<PartnerNetworkConnection>(
            [SELECT Id, ConnectionStatus, ConnectionName 
                FROM PartnerNetworkConnection 
                WHERE ConnectionStatus = 'Accepted' 
                AND ConnectionName = :System.Label.Connection_Name
            ]);
            
        if (connList.isEmpty()) {
            //nothing to do here. Return.
            return;
        }
        
        PartnerNetworkConnection connection = connList.get(0);
        
        List<PartnerNetworkRecordConnection> recordConnections = new List<PartnerNetworkRecordConnection>();
        
        for (Lead lead : leads) {
            PartnerNetworkRecordConnection record = new PartnerNetworkRecordConnection();
            record.ConnectionId = connection.Id;
            record.LocalRecordId = lead.Id;  
            recordConnections.add(record);
        }
        
        if (!recordConnections.isEmpty()) {
            insert recordConnections;
        }           
    }


}