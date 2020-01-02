<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PS_APAC_Opportunity_Ready_for_Review</fullName>
        <ccEmails>APAC_OMTeam@genesys.com</ccEmails>
        <description>PS APAC Opportunity Ready for Review</description>
        <protected>false</protected>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>testnavanee/PS_Oppty_Ready_for_Review</template>
    </alerts>
    <alerts>
        <fullName>PS_EMEA_Opportunity_Ready_for_Review</fullName>
        <ccEmails>revenue_orders.emea@genesys.com</ccEmails>
        <description>PS EMEA Opportunity Ready for Review</description>
        <protected>false</protected>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>testnavanee/PS_Oppty_Ready_for_Review</template>
    </alerts>
    <alerts>
        <fullName>PS_LATAM_Opportunity_Ready_for_Review</fullName>
        <ccEmails>issues@genesys.com</ccEmails>
        <description>PS LATAM Opportunity Ready for Review</description>
        <protected>false</protected>
        <recipients>
            <recipient>thais.brito@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>testnavanee/PS_Oppty_Ready_for_Review</template>
    </alerts>
    <alerts>
        <fullName>PS_NA_Opportunity_Ready_for_Review</fullName>
        <ccEmails>issues@genesys.com</ccEmails>
        <description>PS NA Opportunity Ready for Review</description>
        <protected>false</protected>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>testnavanee/PS_Oppty_Ready_for_Review</template>
    </alerts>
    <alerts>
        <fullName>PS_Oppty_Rejected_by_OM_during_Review</fullName>
        <ccEmails>ManilaBusFinOps@genesys.com</ccEmails>
        <description>PS Oppty Rejected by OM during Review</description>
        <protected>false</protected>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>testnavanee/PS_Oppty_Rejected_by_OM</template>
    </alerts>
    <fieldUpdates>
        <fullName>PS_Oppty_Set_Finance_Review_started</fullName>
        <description>What it does? Sets the datetime for when the OM / Finance PS Opportunity review notification was sent 
Downstream Impact? Used for OM SLA tracking for PS Opportunity reviews and acceptance 
Owner? Professional Services, OM/Finance</description>
        <field>Finance_Review_Request_Sent__c</field>
        <formula>NOW()</formula>
        <name>PS Oppty Set Finance Review started</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>PS Oppty APAC Ready for OM Review</fullName>
        <actions>
            <name>PS_APAC_Opportunity_Ready_for_Review</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>PS_Oppty_Set_Finance_Review_started</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow that will send an email to the APAC OM / Finance group to indicate that the PS Opportunity Approval and Opportunity is ready for review, prior to approval</description>
        <formula>AND(NOT($User.BypassWorkflows__c),   ISPICKVAL(Approval_Type__c, &quot;Professional Services&quot;),   OR(ISNEW(), ISCHANGED(Finance_Approval_Status__c)),  OR(ISPICKVAL(Finance_Approval_Status__c , &quot;Submitted&quot;),  ISPICKVAL(Finance_Approval_Status__c , &quot;Resubmitted&quot;)), Opportunity_PS_Region__c = &quot;APAC&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PS Oppty EMEA Ready for OM Review</fullName>
        <actions>
            <name>PS_EMEA_Opportunity_Ready_for_Review</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>PS_Oppty_Set_Finance_Review_started</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow that will send an email to the EMEA OM / Finance group to indicate that the PS Opportunity Approval and Opportunity is ready for review, prior to approval</description>
        <formula>AND(NOT($User.BypassWorkflows__c),   ISPICKVAL(Approval_Type__c, &quot;Professional Services&quot;),   OR(ISNEW(), ISCHANGED(Finance_Approval_Status__c)),  OR(ISPICKVAL(Finance_Approval_Status__c , &quot;Submitted&quot;),  ISPICKVAL(Finance_Approval_Status__c , &quot;Resubmitted&quot;)), Opportunity_PS_Region__c = &quot;EMEA&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PS Oppty Finance Rejected</fullName>
        <actions>
            <name>PS_Oppty_Rejected_by_OM_during_Review</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow that will notify the PS Business Finance team if the PS opportunity has been rejected by the OM/Finance teams during review</description>
        <formula>AND(NOT($User.BypassWorkflows__c),  ISPICKVAL(Approval_Type__c, &quot;Professional Services&quot;),  ISCHANGED(Finance_Approval_Status__c),  ISPICKVAL(Finance_Approval_Status__c , &quot;Rejected&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PS Oppty LATAM Ready for OM Review</fullName>
        <actions>
            <name>PS_LATAM_Opportunity_Ready_for_Review</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>PS_Oppty_Set_Finance_Review_started</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow that will send an email to the LATAM OM / Finance group to indicate that the PS Opportunity Approval and Opportunity is ready for review, prior to approval</description>
        <formula>AND(NOT($User.BypassWorkflows__c),   ISPICKVAL(Approval_Type__c, &quot;Professional Services&quot;),   OR(ISNEW(), ISCHANGED(Finance_Approval_Status__c)),  OR(ISPICKVAL(Finance_Approval_Status__c , &quot;Submitted&quot;),  ISPICKVAL(Finance_Approval_Status__c , &quot;Resubmitted&quot;)), Opportunity_PS_Region__c = &quot;Latin America&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PS Oppty NA Ready for OM Review</fullName>
        <actions>
            <name>PS_NA_Opportunity_Ready_for_Review</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>PS_Oppty_Set_Finance_Review_started</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow that will send an email to the North America OM / Finance group to indicate that the PS Opportunity Approval and Opportunity is ready for review, prior to approval</description>
        <formula>AND(NOT($User.BypassWorkflows__c),   ISPICKVAL(Approval_Type__c, &quot;Professional Services&quot;),   OR(ISNEW(), ISCHANGED(Finance_Approval_Status__c)),   OR(ISPICKVAL(Finance_Approval_Status__c , &quot;Submitted&quot;),  ISPICKVAL(Finance_Approval_Status__c , &quot;Resubmitted&quot;)), Opportunity_PS_Region__c = &quot;North America&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
