<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Subscription_Email</fullName>
        <description>Send Subscription Email</description>
        <protected>false</protected>
        <recipients>
            <field>To_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/articleSubscriptionEmailTemplateNew</template>
    </alerts>
    <fieldUpdates>
        <fullName>mark_as_sent</fullName>
        <field>isSent__c</field>
        <literalValue>1</literalValue>
        <name>mark as sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>sendSubscriptionEmails</fullName>
        <actions>
            <name>Send_Subscription_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>mark_as_sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>System_Subscription_Email__c.isSent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
