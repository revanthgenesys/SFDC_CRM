<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MPLS_RVA_Data_Center_Quote_Request_Status_Change_Alert</fullName>
        <description>MPLS / RVA / Data Center Quote Request Status Change Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/MPLS_RVA_DC_Quote_Request_Status_Changed</template>
    </alerts>
    <alerts>
        <fullName>MPLS_RVA_Request_Creation_Email_Alert</fullName>
        <ccEmails>rheadinafoster1+elnqeknwndymmfijw8vl@boards.trello.com</ccEmails>
        <description>MPLS / RVA / Data Center Quote Request Workflow Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>Sales Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>rheadina.foster@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/MPLS_RVA_Request_Creation_Email_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>MPLS_RVA_DC_QR_Submitted_Date</fullName>
        <field>Submitted_Date__c</field>
        <formula>Today()</formula>
        <name>MPLS/RVA/DC QR - Submitted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MPLS %2F RVA %2F Data Center Quote Request %3A Status Changed</fullName>
        <actions>
            <name>MPLS_RVA_Data_Center_Quote_Request_Status_Change_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(Status__c ), Not(ISPICKVAL( Status__c , &apos;Draft&apos;)),Not(ISPICKVAL( Status__c , &apos;Submitted&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MPLS %2F RVA %2F Data Center Quote Request Changed to Submitted</fullName>
        <actions>
            <name>MPLS_RVA_Request_Creation_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>MPLS_RVA_DC_QR_Submitted_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MPLS_RVA_Quote_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>MPLS_RVA_Quote_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Data Center</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
