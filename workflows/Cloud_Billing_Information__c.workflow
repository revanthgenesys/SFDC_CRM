<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_email</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Send email</description>
        <protected>false</protected>
        <recipients>
            <recipient>vikram.sharma@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Professional_Services_PM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Send_Go_Live_Announcement_VF</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_email_sent_date</fullName>
        <description>Update the email sent date so that email will be sent out only once</description>
        <field>Go_Live_Email_Sent_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update email sent date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Send Go Live Announcement</fullName>
        <actions>
            <name>Send_email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_email_sent_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cloud_Billing_Information__c.Go_Live_Text__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Cloud_Billing_Information__c.Go_Live_Email_Sent_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This will send an email to PM of revenue page having go live announcement</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
