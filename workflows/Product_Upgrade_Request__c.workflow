<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Product Upgrade Request Email Notification</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Product_Upgrade_Request__c.Email_Notification_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
