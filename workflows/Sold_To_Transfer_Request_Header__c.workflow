<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sold_To_Transfer_Recalled_Email</fullName>
        <description>Sold To Transfer Recalled Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>License_Entitlement_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/Sold_To_Transfer_Recalled_Template</template>
    </alerts>
    <alerts>
        <fullName>Sold_To_Transfer_Rejected_Email</fullName>
        <description>Sold To Transfer Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>License_Entitlement_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/Sold_To_Transfer_Rejected_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Sold_To_Transfer_Tool_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Sold To Transfer Tool Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sold_To_Transfer_Tool_Status_New</fullName>
        <field>Status__c</field>
        <literalValue>New</literalValue>
        <name>Sold To Transfer Tool Status New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sold_To_Transfer_Tool_Status_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Sold To Transfer Tool Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sold_To_Transfer_Tool_Status_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Sold To Transfer Tool Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
