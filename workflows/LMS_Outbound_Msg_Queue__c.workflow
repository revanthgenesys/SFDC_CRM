<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LMS_Request_Third_failure_notification</fullName>
        <description>LMS Request Third failure notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>mariya.steason@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/LMS_Integration_Queue_Error</template>
    </alerts>
    <rules>
        <fullName>LMS Request Third Failure Notification</fullName>
        <actions>
            <name>LMS_Request_Third_failure_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LMS_Outbound_Msg_Queue__c.Failure_Count__c</field>
            <operation>equals</operation>
            <value>3</value>
        </criteriaItems>
        <criteriaItems>
            <field>LMS_Outbound_Msg_Queue__c.Status__c</field>
            <operation>equals</operation>
            <value>Failed</value>
        </criteriaItems>
        <description>notification to IT when LMS integration request failed three times</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
