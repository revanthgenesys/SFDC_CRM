<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Failed_Operation_Recovery_Notification</fullName>
        <description>Failed Operation Recovery Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>mariya.steason@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Failed_Operation_Recovery_Notification</template>
    </alerts>
    <rules>
        <fullName>Failed Operation Recovery Notification</fullName>
        <actions>
            <name>Failed_Operation_Recovery_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Failed_Operation_Recovery__c.Last_Retry_Failed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
