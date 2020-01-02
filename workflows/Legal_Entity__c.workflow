<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Email_Alert</fullName>
        <ccEmails>Raj.Nallamotu@genesys.com,carol.donato@genesys.com</ccEmails>
        <description>Approval Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Finance_MDM_L1_Approval_Notification</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>Finance_MDM_L2_Approval_Notification</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Legal_Entity_Approval_Template</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Email_Alert</fullName>
        <ccEmails>Raj.Nallamotu@genesys.com,carol.donato@genesys.com</ccEmails>
        <description>Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Legal_Entity_Rejection_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Approval_Status_to_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Change Approval Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Approval_Status_to_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Change Approval Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Approval_Status_to_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Change Approval Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Change Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Freeze_Legal_Entity_Id</fullName>
        <field>Freez_Record__c</field>
        <literalValue>1</literalValue>
        <name>Freeze Legal Entity Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Update Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Check whether LE record is modified</fullName>
        <actions>
            <name>Update_Approval_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(!$User.BypassWorkflows__c ,TEXT(Approval_Status__c) = &apos;Approved&apos;,OR(ISCHANGED(Name),ISCHANGED(Legal_Entity_ID__c),ISCHANGED(Country__c),ISCHANGED(Name_No_Hierarchy__c),ISCHANGED(Legal_Entity_Hierarchy__c),ISCHANGED(Legal_Entity_Management_Hierarchy__c),ISCHANGED(Business_Region__c),ISCHANGED(Currency__c),ISCHANGED(Tax_ID__c),ISCHANGED(Status__c),ISCHANGED(Definition__c),ISCHANGED(Elimination__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
