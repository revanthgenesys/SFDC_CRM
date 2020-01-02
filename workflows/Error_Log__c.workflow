<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Error_Log_License_Email_Notification</fullName>
        <description>Error Log: License Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>jessica.doucette@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mariya.steason@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Licensing_Global/Email_Error_Notification</template>
    </alerts>
    <alerts>
        <fullName>Error_Log_Notification</fullName>
        <description>Error Log Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>mariya.steason@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Error_Log_Alert</template>
    </alerts>
    <alerts>
        <fullName>Error_Notification_on_Survey_Response_import</fullName>
        <ccEmails>Pankaj.Arora@genesys.com</ccEmails>
        <description>Error Notification on Survey Response import</description>
        <protected>false</protected>
        <recipients>
            <recipient>mariya.steason@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/Survey_Response_Import_Error_Notification</template>
    </alerts>
    <alerts>
        <fullName>LMS_Integration_Error_Notification</fullName>
        <description>LMS Integration Error Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>mariya.steason@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/LMS_Integration_Error_Notification</template>
    </alerts>
    <alerts>
        <fullName>MDM_Error_Notification</fullName>
        <description>MDM Error Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>mariya.steason@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>marty.long@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDM_Templates/MDM_Error_Notification</template>
    </alerts>
    <rules>
        <fullName>Case errors Notification</fullName>
        <actions>
            <name>Error_Log_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Error_Log__c.Code_Type__c</field>
            <operation>startsWith</operation>
            <value>Case</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Error Log%3A License Email Service</fullName>
        <actions>
            <name>Error_Log_License_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Error_Log__c.Code_Type__c</field>
            <operation>startsWith</operation>
            <value>LicenseRequestEmailService</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Error Log%3A Survey Response Notification</fullName>
        <actions>
            <name>Error_Notification_on_Survey_Response_import</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Error_Log__c.Code_Type__c</field>
            <operation>equals</operation>
            <value>Survey Response</value>
        </criteriaItems>
        <description>send notification when an error occur importing Survey Response</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LMS Integration Error</fullName>
        <actions>
            <name>LMS_Integration_Error_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Error_Log__c.Code_Type__c</field>
            <operation>startsWith</operation>
            <value>LMSIntegration</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MDM Error Notification</fullName>
        <actions>
            <name>MDM_Error_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Error_Log__c.Code_Type__c</field>
            <operation>startsWith</operation>
            <value>MDM:</value>
        </criteriaItems>
        <description>internal email notifications on MDM errors</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
