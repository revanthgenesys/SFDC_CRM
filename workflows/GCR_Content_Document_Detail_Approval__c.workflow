<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>GCR_Approval_Assignment</fullName>
        <description>GCR Approval Assignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>legalrequest@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/GCR_Approval_Assignment_VF</template>
    </alerts>
    <rules>
        <fullName>GCR Approval Assignment</fullName>
        <actions>
            <name>GCR_Approval_Assignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>GCR_Content_Document_Detail_Approval__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
