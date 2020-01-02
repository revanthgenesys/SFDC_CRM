<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Ent_Transfer_Recalled_Email</fullName>
        <description>Ent Transfer Recalled Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>License_Entitlement_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/Entitlement_Transfer_Recalled_Template</template>
    </alerts>
    <alerts>
        <fullName>Ent_Transfer_Rejected_Email</fullName>
        <description>Ent Transfer Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>License_Entitlement_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/Entitlement_Transfer_Rejected_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Ent_Transfer_Tool_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Ent Transfer Tool Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ent_Transfer_Tool_Status_New</fullName>
        <field>Status__c</field>
        <literalValue>New</literalValue>
        <name>Ent Transfer Tool Status New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ent_Transfer_Tool_Status_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Ent Transfer Tool Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ent_Transfer_Tool_Status_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Ent Transfer Tool Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Transfer Tool Approval Accept</fullName>
        <actions>
            <name>Ent_Transfer_Tool_Status_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Transfer_Tool_Approval__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
