<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Marketing_Operation_Project_File_Upload_Complete</fullName>
        <ccEmails>Joe.Parathara@Genesyslab.com</ccEmails>
        <description>Marketing Operation Project - File Upload Complete</description>
        <protected>false</protected>
        <recipients>
            <recipient>clifton.colburn@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/Marketing_Operations_File_Upload_Completed</template>
    </alerts>
    <alerts>
        <fullName>Marketing_Operation_Project_Outsourced_Job_Complete</fullName>
        <ccEmails>joe.parathara@genesyslab.com</ccEmails>
        <description>Marketing Operation Project - Outsourced Job Complete</description>
        <protected>false</protected>
        <recipients>
            <recipient>clifton.colburn@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ross.hays@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/Marketing_Operations_Outsourced_Service_Completed</template>
    </alerts>
    <alerts>
        <fullName>Marketing_Operation_Projects_To_Requester_File_Upload_Complete</fullName>
        <ccEmails>Joe.Parathara@genesyslab.com</ccEmails>
        <description>Marketing Operation Projects - Alert To Requester - File Upload Complete</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Lookup__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>clifton.colburn@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/Marketing_Operations_Requester_File_Upload_Complete</template>
    </alerts>
    <rules>
        <fullName>Marketing Operation Projects - Rule To Requester - File Upload Complete</fullName>
        <actions>
            <name>Marketing_Operation_Projects_To_Requester_File_Upload_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow was created to email a file upload requester that their file upload is complete. A field on the Marketing Ops Project object will trigger this.</description>
        <formula>AND(
ISPICKVAL( Request_Type__c, &apos;File Upload Request&apos;),
 Emailed_Requester_Finished__c ,
NOT($User.BypassValidationRules__c = True)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Marketing Operations - Outsourced Service Completed</fullName>
        <actions>
            <name>Marketing_Operation_Project_Outsourced_Job_Complete</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends notification to Marketing Operations that an Outsourced service has been completed.</description>
        <formula>AND(
 Completed_by_Vendor__c ,
NOT($User.BypassValidationRules__c = True)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Marketing Operations Project - File Upload Complete</fullName>
        <active>true</active>
        <description>Sends a notification to Marketing Operations when a File Upload is completed</description>
        <formula>AND(
 File_Upload_Complete__c ,
NOT($User.BypassValidationRules__c = True)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Marketing_Operation_Project_File_Upload_Complete</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
