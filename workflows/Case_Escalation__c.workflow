<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Escalation_Created_Notification</fullName>
        <description>Case Escalation Created Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Escalation_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Tech_Escalation_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Support_Auto_Notifications/Case_Escalation_Created</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Escalation_Add_Owner_Email</fullName>
        <field>Case_Owner_Email__c</field>
        <formula>Case__r.Owner:User.Email</formula>
        <name>Case Escalation - Add Owner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case Escalation Created</fullName>
        <actions>
            <name>Case_Escalation_Created_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Escalation_Add_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>email notification on a new escalation created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
