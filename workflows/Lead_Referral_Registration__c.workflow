<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Final_Approval_Emails_To_AE</fullName>
        <description>Final Approval Emails To AE</description>
        <protected>false</protected>
        <recipients>
            <recipient>AccountAccessibilityCSM</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Partner_Lead_Refe_Approved_Email_Templa</template>
    </alerts>
    <alerts>
        <fullName>Lead_Referral_Complete_Notification</fullName>
        <description>Lead Referral Complete Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Lead_Referral_Approval_AE_Group</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Lead_Referral_Approved_by_Genesys</template>
    </alerts>
    <alerts>
        <fullName>Lead_Referral_Registration_SWAT_Notification</fullName>
        <ccEmails>SalesOpSwat@genesys.com</ccEmails>
        <description>Lead Referral Registration SWAT Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>prabhuram.doraiswamy@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Lead_Referral_Registration_SWAT_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Lead_Referal_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Lead Referal Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Referral_Registration_Set_Expired</fullName>
        <field>Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Lead Referral Registration Set Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Referral_Status</fullName>
        <field>Status__c</field>
        <literalValue>Request Pending</literalValue>
        <name>Update Lead Referral Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Referral_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Lead Referral Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Referral_Status_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Lead Referral Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>isCMApproved</fullName>
        <field>isCMApproved__c</field>
        <literalValue>1</literalValue>
        <name>isCMApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lead Referral Registration Expiration</fullName>
        <active>true</active>
        <description>This workflow fires a field update to expire the Lead Referral Registration when the expiry date is reached</description>
        <formula>AND (     Opportunity__c == NULL,        ISPICKVAL(Status__c,&apos;Expired&apos;) == false )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Lead_Referral_Registration_Set_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead_Referral_Registration__c.End_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
