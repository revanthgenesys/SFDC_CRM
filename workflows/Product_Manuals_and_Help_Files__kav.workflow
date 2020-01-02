<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Alfresco_Customer_true</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Alfresco Customer true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alfresco_Internal_true</fullName>
        <field>IsVisibleInApp</field>
        <literalValue>1</literalValue>
        <name>Alfresco_Internal_true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alfresco_Partner_True</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Alfresco Partner True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alfresco_Public_True</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>1</literalValue>
        <name>Alfresco Public True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alfresco_Public_Validation_Status</fullName>
        <field>ValidationStatus</field>
        <literalValue>Validated Public</literalValue>
        <name>alfresco Public Validation Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AlfrescoVisibility</fullName>
        <actions>
            <name>Alfresco_Customer_true</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Alfresco_Internal_true</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Alfresco_Partner_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Alfresco_Public_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alfresco_Public_Validation_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
