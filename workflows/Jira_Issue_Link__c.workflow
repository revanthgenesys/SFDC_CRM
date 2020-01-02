<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Jira_Issue_Update_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Mapped</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Jira Issue Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Jira Issue Update Record Type</fullName>
        <actions>
            <name>Jira_Issue_Update_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Jira_Issue_Link__c.JIL_Issue__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>update record Type to Mapped when Jira Issue record is linked to an instance in Jira</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
