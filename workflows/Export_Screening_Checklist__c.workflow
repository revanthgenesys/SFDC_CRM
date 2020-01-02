<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_to_Legal_Team_when_RED_Flags_are_raised</fullName>
        <description>Notification to Legal Team when RED Flags are raised</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>jyldyz.obozbekova@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mark.rosine@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>scott.wolfe@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tracey.mcallister@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/Notification_to_Legal_Team_when_RED_Flags_are_raised</template>
    </alerts>
    <rules>
        <fullName>Notification to Legal Team when RED Flags are raised</fullName>
        <actions>
            <name>Notification_to_Legal_Team_when_RED_Flags_are_raised</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Export_Screening_Checklist__c.Status__c</field>
            <operation>equals</operation>
            <value>Under legal review</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
