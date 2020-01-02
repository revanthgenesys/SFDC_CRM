<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Password_Change_Notification</fullName>
        <description>Password Change Notification</description>
        <protected>false</protected>
        <recipients>
            <field>User_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Templates/Password_Change_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_Email_Field</fullName>
        <field>User_Email__c</field>
        <formula>Username__c</formula>
        <name>Populate Email Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Password Change Notification</fullName>
        <actions>
            <name>Password_Change_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Populate_Email_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Portal_Password__c.Current_Password__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Portal_Password__c.Is_Change_Password__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
