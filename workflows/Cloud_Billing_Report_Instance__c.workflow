<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Cloud_Billing_Report_Instance_File_Name</fullName>
        <field>File_Name__c</field>
        <formula>SUBSTITUTE(Cloud_Billing_Report_Request__r.Contract__r.Account_Name__r.Name, &apos; &apos;, &apos;&apos;) + &apos;-&apos; +
SUBSTITUTE(Cloud_Billing_Report_Request__r.Contract__r.Name, &apos;Contracts - &apos;, &apos;&apos;) + &apos;-&apos; +
IF (Report_Type__c =&apos;Detail Inbound IVR Usage&apos;, &apos;InboundIVR&apos;, &apos;&apos;) +
IF (Report_Type__c =&apos;Detail Inbound Usage&apos;, &apos;Inbound&apos;, &apos;&apos;) +
IF (Report_Type__c =&apos;Detail Outbound Usage&apos;, &apos;Outbound&apos;, &apos;&apos;) +
IF (Report_Type__c =&apos;Detail Agent Seats Concurrent&apos;, &apos;SeatsConcurrent&apos;, &apos;&apos;) +
IF (Report_Type__c =&apos;Detail Agent Seats Enabled&apos;, &apos;SeatsEnabled&apos;, &apos;&apos;) +
IF (Report_Type__c =&apos;Detail DDI/DID&apos;, &apos;DDI&apos;, &apos;&apos;) +
IF (Report_Type__c =&apos;Detail Port Usage&apos;, &apos;Ports&apos;, &apos;&apos;) + &apos;-&apos; +
Month__c + &apos;-&apos; + Year__c</formula>
        <name>Cloud Billing Report Instance File Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Cloud Billing Report Instance File Name</fullName>
        <actions>
            <name>Cloud_Billing_Report_Instance_File_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>File_Name__c = null</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
