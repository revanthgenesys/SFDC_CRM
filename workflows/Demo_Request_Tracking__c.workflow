<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DemoRequest_Mark_Complete</fullName>
        <field>State__c</field>
        <literalValue>Completed</literalValue>
        <name>DemoRequest:Update State:Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Demo_Request__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DemoRequest_Set_Completed_Timestamp</fullName>
        <field>Timestamp_Completed__c</field>
        <formula>Now()</formula>
        <name>DemoRequest:Set Completed Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Demo_Request__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>DemoRequest%3ADemo Completed</fullName>
        <actions>
            <name>DemoRequest_Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DemoRequest_Set_Completed_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow for Demo Request Tracking objects to Complete a Demo Request</description>
        <formula>(Activity_Completed_By__r.Id =  Demo_Request__r.Demo_Owner__r.Id ) &amp;&amp; ( ISPICKVAL(Activity_Type__c, &quot;Demo&quot;) ||  ISPICKVAL(Activity_Type__c, &quot;Tradeshow&quot;) ) &amp;&amp;  ISPICKVAL(Activity_State__c, &quot;Completed&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
