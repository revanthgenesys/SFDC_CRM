<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_notification_for_AppFoundry_License_form_submission</fullName>
        <ccEmails>AppFoundry@genesys.com</ccEmails>
        <description>Email notification for AppFoundry License form submission</description>
        <protected>false</protected>
        <recipients>
            <recipient>juergen.tolksdorf@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/AppFoundry_LicenseReport</template>
    </alerts>
    <rules>
        <fullName>Technology License Form Submission</fullName>
        <actions>
            <name>Email_notification_for_AppFoundry_License_form_submission</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
