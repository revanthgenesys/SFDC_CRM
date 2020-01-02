<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CORE_OQM_Form_Proposal_Submission_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>OQM_Form_Proposal_Submission_Record_Type</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CORE - OQM Form_Proposal Submission_RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EMG_WKF043_OQM Status Submitted</fullName>
        <actions>
            <name>CORE_OQM_Form_Proposal_Submission_RT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OQM_Form__c.OQMForm_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>When the OQM Status is &quot;Submitted&quot;, put the &quot;OQM Form_Proposal Submission_Record Type&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
