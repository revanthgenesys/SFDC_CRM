<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approve_Reject</fullName>
        <description>Approve / Reject</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Partner_Directory_Staging_Status_Updated</template>
    </alerts>
    <alerts>
        <fullName>Channel_Manager_Approved</fullName>
        <description>Channel Manager Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Current_Requester__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Partner_Directory_Staging_Status_Updated</template>
    </alerts>
    <alerts>
        <fullName>Channel_Manager_Rejected</fullName>
        <description>Channel Manager Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Partner_Directory_Staging_Status_Updated</template>
    </alerts>
    <alerts>
        <fullName>Partner_Directory_Approval</fullName>
        <description>Partner Directory Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>cathy.an@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sean.salter@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Partner_Directory_Staging_New</template>
    </alerts>
    <alerts>
        <fullName>Reject_Email_alert</fullName>
        <description>Reject Email alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Partner_Directory_Staging_Status_Updated</template>
    </alerts>
    <fieldUpdates>
        <fullName>Admin_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Published</literalValue>
        <name>Admin Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChannelManager_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Channel Manager Rejected</literalValue>
        <name>ChannelManager Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Channel_Manager</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Channel Manager Approved</literalValue>
        <name>Channel Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Draft</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
