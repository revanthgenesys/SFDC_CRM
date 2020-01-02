<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AppFoundry_Email_Notification_OLI</fullName>
        <description>AppFoundry Email Notification (OLI)</description>
        <protected>false</protected>
        <recipients>
            <recipient>liam.clifford@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/AppFoundry_Order_Notification</template>
    </alerts>
    <alerts>
        <fullName>AppFoundry_Order_Notification</fullName>
        <description>AppFoundry Order Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>liam.clifford@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/AppFoundry_Order_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Line</fullName>
        <description>Updates Line Number On Order Line Based on Max Line # fetched from Order Header.</description>
        <field>Line_Number__c</field>
        <formula>BLANKVALUE(Order__r.Max_Line__c,0) + 1</formula>
        <name>Update Line #</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Line %23 On Manually Added Cloud Billing Order Lines</fullName>
        <actions>
            <name>Update_Line</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cloud Monthly Billing Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order_Line_Item__c.Line_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Could be deleted once line numbering logic is moved to trigger</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
