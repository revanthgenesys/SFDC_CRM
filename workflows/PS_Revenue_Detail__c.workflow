<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PS_APAC_RevPro_Event_without_Opportunity_being_Approved</fullName>
        <ccEmails>APAC_OMTeam@genesys.com</ccEmails>
        <description>PS APAC RevPro Event without Opportunity being Approved</description>
        <protected>false</protected>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/PS_RevPro_Event_without_Approved_Oppty</template>
    </alerts>
    <alerts>
        <fullName>PS_EMEA_RevPro_Event_without_Opportunity_being_Approved</fullName>
        <ccEmails>revenue_orders.emea@genesys.com</ccEmails>
        <description>PS EMEA RevPro Event without Opportunity being Approved</description>
        <protected>false</protected>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/PS_RevPro_Event_without_Approved_Oppty</template>
    </alerts>
    <alerts>
        <fullName>PS_LATAM_RevPro_Event_without_Opportunity_being_Approved</fullName>
        <ccEmails>issues@genesys.com</ccEmails>
        <description>PS LATAM RevPro Event without Opportunity being Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>thais.brito@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/PS_RevPro_Event_without_Approved_Oppty</template>
    </alerts>
    <alerts>
        <fullName>PS_NA_RevPro_Event_without_Opportunity_being_Approved</fullName>
        <ccEmails>issues@genesys.com</ccEmails>
        <description>PS NA RevPro Event without Opportunity being Approved</description>
        <protected>false</protected>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/PS_RevPro_Event_without_Approved_Oppty</template>
    </alerts>
    <alerts>
        <fullName>PS_RevPro_Event_without_Opportunity_being_Approved</fullName>
        <description>PS RevPro Event without Opportunity being Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>aaron.goss@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nik.mills@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>raf.frasinski@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>samantha.walker@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>shannon.dallenbach@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>susan.parrish@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/PS_RevPro_Event_without_Approved_Oppty</template>
    </alerts>
    <rules>
        <fullName>PS APAC Project RevPro Event on unapproved Oppty</fullName>
        <actions>
            <name>PS_APAC_RevPro_Event_without_Opportunity_being_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Checks whether a PS RevPro revenue event was created for a non-approved opportunity and will inform the OM team that this has occurred</description>
        <formula>AND( NOT(ISPICKVAL(Opportunity__r.Finance_Oppty_Approval_Status__c, &apos;Approved&apos;)), ISPICKVAL(Opportunity__r.PS_Region__c, &apos;APAC&apos;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PS EMEA Project RevPro Event on unapproved Oppty</fullName>
        <actions>
            <name>PS_EMEA_RevPro_Event_without_Opportunity_being_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Checks whether a PS RevPro revenue event was created for a non-approved opportunity and will inform the OM team that this has occurred</description>
        <formula>AND( NOT(ISPICKVAL(Opportunity__r.Finance_Oppty_Approval_Status__c, &apos;Approved&apos;)), ISPICKVAL(Opportunity__r.PS_Region__c, &apos;EMEA&apos;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PS LATAM Project RevPro Event on unapproved Oppty</fullName>
        <actions>
            <name>PS_LATAM_RevPro_Event_without_Opportunity_being_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Checks whether a PS RevPro revenue event was created for a non-approved opportunity and will inform the OM team that this has occurred</description>
        <formula>AND( NOT(ISPICKVAL(Opportunity__r.Finance_Oppty_Approval_Status__c, &apos;Approved&apos;)), ISPICKVAL(Opportunity__r.PS_Region__c, &apos;Latin America&apos;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PS NA Project RevPro Event on unapproved Oppty</fullName>
        <actions>
            <name>PS_NA_RevPro_Event_without_Opportunity_being_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Checks whether a PS RevPro revenue event was created for a non-approved opportunity and will inform the OM team that this has occurred</description>
        <formula>AND( NOT(ISPICKVAL(Opportunity__r.Finance_Oppty_Approval_Status__c, &apos;Approved&apos;)), ISPICKVAL(Opportunity__r.PS_Region__c, &apos;North America&apos;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
