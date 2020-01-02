<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Event_Type_Populate</fullName>
        <description>Populates the Task Type field for Reporting</description>
        <field>Task_Type__c</field>
        <formula>TEXT(Type)</formula>
        <name>Event Type Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Event Type Populate</fullName>
        <actions>
            <name>Event_Type_Populate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.Type</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populates the Even Type Field For Reporting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
