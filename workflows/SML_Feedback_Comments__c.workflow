<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Engagement_Map_Feedback_Alert</fullName>
        <description>Engagement Map Feedback Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>nik.mills@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pushpa.ramachandran@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/SML_Feedback_Template</template>
    </alerts>
    <rules>
        <fullName>Engagement Map Feedback Alert</fullName>
        <actions>
            <name>Engagement_Map_Feedback_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SML_Feedback_Comments__c.Comments__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Engagement Map Feedback / Comments alert for AskSalesOps</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
