<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Add_Description</fullName>
        <field>Description__c</field>
        <formula>Product_Group__r.Description__c</formula>
        <name>Add Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Product Group Description smart use case alignment</fullName>
        <actions>
            <name>Add_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp;  NOT(ISBLANK(Product_Group__r.Description__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
