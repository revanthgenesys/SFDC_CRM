<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MKTG_Campaign_Created_Late</fullName>
        <field>Campaign_Created_After_Event_Date__c</field>
        <literalValue>1</literalValue>
        <name>MKTG - Campaign Created Late</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>GetCampaignDetails_New</fullName>
        <apiVersion>44.0</apiVersion>
        <description>GetCampaignDetails_New</description>
        <endpointUrl>http://oauth.zinfi.net/SFDC/OBM/Index.aspx?Id=887E2736-7EBB-48D5-9A8A-0B217B37F5C9</endpointUrl>
        <fields>Campaign_ID__c</fields>
        <fields>Channel__c</fields>
        <fields>Id</fields>
        <fields>IsActive</fields>
        <fields>Marketing_Activity_Lookup__c</fields>
        <fields>Name</fields>
        <fields>RecordTypeId</fields>
        <fields>Status</fields>
        <fields>Tactic__c</fields>
        <fields>Zinfi_Composite_Key__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>genesys-sf@zinfitech.com</integrationUser>
        <name>GetCampaignDetails_New</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>GetCampaignDetailsRule</fullName>
        <active>false</active>
        <description>GetCampaignDetailsRule</description>
        <formula>OR(ISCHANGED(Name),ISCHANGED(Campaign_ID__c),ISCHANGED(Channel__c),ISCHANGED(IsActive),ISCHANGED(Marketing_Activity_Lookup__c),ISCHANGED(Tactic__c),ISCHANGED(RecordTypeId),ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>GetCampaignDetailsRule_New</fullName>
        <actions>
            <name>GetCampaignDetails_New</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>GetCampaignDetailsRule_New</description>
        <formula>OR(ISCHANGED(Name),ISCHANGED(Campaign_ID__c),ISCHANGED(Channel__c),ISCHANGED(IsActive),ISCHANGED(Marketing_Activity_Lookup__c),ISCHANGED(Tactic__c),ISCHANGED(RecordTypeId),ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Trigger LDR Follow Up Required</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Campaign.Type</field>
            <operation>equals</operation>
            <value>Field Event,Webinar</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Update Campaign Created Late Checkbox</fullName>
        <actions>
            <name>MKTG_Campaign_Created_Late</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>DATEVALUE(CreatedDate) &gt; Event_Date__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
