<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Support_Access_Cloud_Set_Unique_Field</fullName>
        <field>Unique_Delpoyment_Contact_Combo__c</field>
        <formula>CASESAFEID(Cloud_Deployment__c) + &apos;_&apos; +   CASESAFEID(Contact__c)</formula>
        <name>Support Access Cloud: Set Unique Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Support Access Cloud%3A Set Unique Field Value</fullName>
        <actions>
            <name>Support_Access_Cloud_Set_Unique_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR ( ISNEW(), ISCHANGED( Cloud_Deployment__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
