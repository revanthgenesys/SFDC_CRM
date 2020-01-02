<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_ByPass_Validation_Flag</fullName>
        <field>ByPass_Validation_Rule__c</field>
        <literalValue>0</literalValue>
        <name>Update ByPass Validation Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update ByPass Validation Flag</fullName>
        <actions>
            <name>Update_ByPass_Validation_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Wow_Request_Form__c.ByPass_Validation_Rule__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
