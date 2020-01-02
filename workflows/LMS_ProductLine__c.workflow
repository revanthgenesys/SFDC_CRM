<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Name_Update</fullName>
        <description>This updates name field with custom name and version</description>
        <field>Name</field>
        <formula>ProductLineName__c&amp;&apos; &apos;&amp; ProductLine_Version__c</formula>
        <name>Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Name Auto Fill</fullName>
        <actions>
            <name>Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LMS_ProductLine__c.ProductLineName__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LMS_ProductLine__c.ProductLine_Version__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This rule auto populates product line Name with custom name and version concatenation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
