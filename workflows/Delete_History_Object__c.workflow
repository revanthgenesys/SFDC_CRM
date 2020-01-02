<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>update_deleted_date</fullName>
        <field>Deleted_Date_Time__c</field>
        <formula>CreatedDate</formula>
        <name>update deleted date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>deleted by date and time</fullName>
        <active>false</active>
        <formula>Deleted_Date_Time__c= CreatedDate</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>deleted by date and time update</fullName>
        <actions>
            <name>update_deleted_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Delete_History_Object__c.Record_ID__c</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
