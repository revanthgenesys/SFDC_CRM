<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Field_Update_Update_Program_Follow_Up</fullName>
        <description>This will update the Program Follow Up field to &quot;LDR Follow up Requested&quot;</description>
        <field>Program_Follow_Up__c</field>
        <literalValue>LDR Follow up Requested</literalValue>
        <name>Field Update - Update Program Follow Up</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MKTG - Update Program Follow Up Field</fullName>
        <actions>
            <name>Field_Update_Update_Program_Follow_Up</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Program Follow Up = &quot;LDR Follow up Requested&quot; when program type = webinar, trade show or genesys event</description>
        <formula>AND( 
OR( 
ISPICKVAL(Type__c,&quot;Webinar&quot;), 
ISPICKVAL(Type__c,&quot;Tradeshow&quot;), 
ISPICKVAL(Type__c,&quot;Genesys Event&quot;) 
), 
(Start_Event_Date__c &gt; DATEVALUE(&quot;2014-10-09&quot;)) 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
