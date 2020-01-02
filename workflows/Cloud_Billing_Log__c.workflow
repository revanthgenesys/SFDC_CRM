<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Billing_Log_Exceptions_Alert</fullName>
        <description>Billing Log Exceptions Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>erik.doetsch@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sourav.mitra@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cloud_Billing_Templates/Billing_Log_Exceptions_Template</template>
    </alerts>
    <rules>
        <fullName>Log Exceptions Notification</fullName>
        <actions>
            <name>Billing_Log_Exceptions_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cloud_Billing_Log__c.Exceptions__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
