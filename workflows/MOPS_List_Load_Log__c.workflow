<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MOP_List_Load_Log_File_Upload_Complete</fullName>
        <ccEmails>Joe.Parathara@Genesyslab.com</ccEmails>
        <description>MOP List Load Log - File Upload Complete</description>
        <protected>false</protected>
        <recipients>
            <recipient>clifton.colburn@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/MOP_List_Load_Log_File_Upload_Completed</template>
    </alerts>
    <rules>
        <fullName>MOP List Load Log - File Upload Complete</fullName>
        <actions>
            <name>MOP_List_Load_Log_File_Upload_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends a notification to Marketing Operations when a File Upload is completed from the MOP List Load Log related table.</description>
        <formula>AND(
 File_Upload_Complete__c ,
NOT($User.BypassValidationRules__c = True)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
