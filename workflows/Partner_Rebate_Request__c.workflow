<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Partner_Rebate_Request_Approved</fullName>
        <description>Partner Rebate Request Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Rebate_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Partner_Rebate_Request_Rejected</fullName>
        <description>Partner Rebate Request Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Rebate_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Partner_Rebate_Request_Submitted</fullName>
        <description>Partner Rebate Request Submitted</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Rebate_Request_Submitted</template>
    </alerts>
    <fieldUpdates>
        <fullName>Partner_Rebate_Request_Status_Cancelled</fullName>
        <description>Field update to set the Partner Rebate Request Status to Cancelled when the request is Rejected</description>
        <field>Status__c</field>
        <literalValue>Cancelled</literalValue>
        <name>Partner Rebate Request Status Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Rebate_Request_Status_In_Process</fullName>
        <description>Field update to set the Partner Rebate Request Status to In-Process when the request is submitted</description>
        <field>Status__c</field>
        <literalValue>In-Process</literalValue>
        <name>Partner Rebate Request Status In Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Rebate_Request_Status_Processed</fullName>
        <description>Field update to set the Partner Rebate Request Status to Processed when the request is  Approved</description>
        <field>Status__c</field>
        <literalValue>Processed</literalValue>
        <name>Partner Rebate Request Status Processed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Partner Rebate Request Submitted</fullName>
        <actions>
            <name>Partner_Rebate_Request_Submitted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Partner_Rebate_Request_Status_In_Process</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Rebate_Request__c.Requested_Rebate_Amount__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
