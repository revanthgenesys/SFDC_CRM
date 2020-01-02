<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Unique_Analyst_Skill</fullName>
        <field>Unique_Analyst_Skill__c</field>
        <formula>User__r.Id +  Support_Product__r.Id</formula>
        <name>Unique Analyst Skill</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Unique Analyst Skill</fullName>
        <actions>
            <name>Unique_Analyst_Skill</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Care_Analyst_Skill__c.Skill_Level__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
