<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Support_Set_case_to_unauthorised_esc</fullName>
        <description>This field update will identify un-accepted escalations.</description>
        <field>rules_unauthorised_escalation__c</field>
        <literalValue>1</literalValue>
        <name>Support: Set case to unauthorised esc.</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Support%3A Non-Genesys Domain Escalation</fullName>
        <actions>
            <name>Support_Set_case_to_unauthorised_esc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.FromAddress</field>
            <operation>notContain</operation>
            <value>@genesyslab.com,@cleartask.com</value>
        </criteriaItems>
        <description>The following workflow will bounce back emails where the from address is not from a permitted domain</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
