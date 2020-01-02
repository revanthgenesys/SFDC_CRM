<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Test_Sellabble_item_Availability</fullName>
        <field>Test_Sellable_Item_Availability__c</field>
        <formula>TEXT(Sellable_Item_Product__r.Availability__c)</formula>
        <name>Test Sellabble item Availability</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Test Sellable Item Availability field value</fullName>
        <actions>
            <name>Test_Sellabble_item_Availability</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Product2.Name</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
