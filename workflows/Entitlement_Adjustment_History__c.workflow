<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approved</fullName>
        <description>Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/New_Entitlement_Adjustment_1</template>
    </alerts>
    <alerts>
        <fullName>Entitlement_Adjustment</fullName>
        <description>Entitlement Adjustment</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashley.kane@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paul.notaro@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vikram.sharma@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/New_Entitlement_Adjustment</template>
    </alerts>
    <rules>
        <fullName>Mail</fullName>
        <actions>
            <name>Entitlement_Adjustment</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Entitlement_Adjustment_History__c.Adjustment_Count__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
