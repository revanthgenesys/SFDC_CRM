<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MyForecast_Unique_Record_Key_FU</fullName>
        <field>Unique_Record_Key__c</field>
        <formula>Text(Current_Year__c) &amp; Text(Quarter__c) &amp; UserID__c</formula>
        <name>MyForecast_Unique_Record_Key_FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MyForecast_Unique_Key_WR</fullName>
        <actions>
            <name>MyForecast_Unique_Record_Key_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Current_Year__c &lt;&gt; 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
