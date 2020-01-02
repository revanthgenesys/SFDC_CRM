<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SE_Project_Created_or_Changed</fullName>
        <description>SE Project Created or Changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>benjamin.stalder@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>matthew.brannon@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>samantha.cushing@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>theresa.monturano@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/SE_Project_CC</template>
    </alerts>
    <rules>
        <fullName>SE Project Trigger</fullName>
        <actions>
            <name>SE_Project_Created_or_Changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Client_Service__c.Project_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Triggers an email when an SE Project is created or changed.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
