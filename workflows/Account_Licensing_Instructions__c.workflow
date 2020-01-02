<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Account_Unique_Field</fullName>
        <field>Account_Unique__c</field>
        <formula>CASESAFEID(Account__c)</formula>
        <name>Set Account Unique Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>License Instruction%3A Set Unique Account</fullName>
        <actions>
            <name>Set_Account_Unique_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This WF should be active for all accounts.</description>
        <formula>OR ( ISNEW(), ISCHANGED(Account__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
