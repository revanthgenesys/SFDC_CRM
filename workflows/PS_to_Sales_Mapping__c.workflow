<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PS_to_SalesMap_Set_DSR_Email_Target</fullName>
        <description>Set the PS DSR EMail target Email address based on the presence of an associated user to the PS to Sales mapping record</description>
        <field>PS_DSR_Email_Target_Email_Address__c</field>
        <formula>PS_DSR_Email_Target_Username__r.Email</formula>
        <name>PS to SalesMap - Set DSR Email Target</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>PS to SalesMap - Set PS DSR Email</fullName>
        <actions>
            <name>PS_to_SalesMap_Set_DSR_Email_Target</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_to_Sales_Mapping__c.PS_DSR_Email_Target_Username__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Set the PS DSR Email based on the associated user record for the DSR target</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
