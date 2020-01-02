<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Email_Alert</fullName>
        <ccEmails>jitendra.jain@genesys.com,Raj.Nallamotu@genesys.com,nrathore@deloitte.com,carol.donato@genesys.com</ccEmails>
        <description>Approval Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Hierarchy_Approval_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Email_Alert</fullName>
        <ccEmails>jitendra.jain@genesys.com,Raj.Nallamotu@genesys.com,nrathore@deloitte.com,carol.donato@genesys.com</ccEmails>
        <description>Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Hierarchy_Rejection_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Allow_Edit</fullName>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Allow Edit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Change_to_L2</fullName>
        <description>Approval Status Change to L2</description>
        <field>Approval_Status__c</field>
        <literalValue>Pending L2 Approval</literalValue>
        <name>Approval Status Change to L2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Active</fullName>
        <description>Change Status to &apos;Active&apos;</description>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Change Status to &apos;Active&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Approved</fullName>
        <description>Change Status to Approved</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Change Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Rejected</fullName>
        <description>Change Status to Rejected</description>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Change Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Submitted</fullName>
        <description>Change Status to Submitted</description>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Change Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Sub_Status_to_L1_Approved</fullName>
        <description>Change Sub Status to L1 Approved</description>
        <field>Approval_Sub_Status__c</field>
        <literalValue>L1 Approved</literalValue>
        <name>Change Sub Status to L1 Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Sub_Status_to_L1_Rejected</fullName>
        <description>Change Sub Status to L1 Rejected</description>
        <field>Approval_Sub_Status__c</field>
        <literalValue>L1 Rejected</literalValue>
        <name>Change Sub Status to L1 Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Sub_Status_to_L2_Approved</fullName>
        <description>Change Sub Status to &apos;L2 Approved&apos;</description>
        <field>Approval_Sub_Status__c</field>
        <literalValue>L2 Approved</literalValue>
        <name>Change Sub Status to &apos;L2 Approved&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Sub_Status_to_L2_Rejected</fullName>
        <description>Change Sub Status to L2 Rejected</description>
        <field>Approval_Sub_Status__c</field>
        <literalValue>L2 Rejected</literalValue>
        <name>Change Sub Status to L2 Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Freez_record</fullName>
        <field>Freez_record__c</field>
        <literalValue>1</literalValue>
        <name>Freez record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Blackout</fullName>
        <description>Reset Blackout</description>
        <field>Blackout_Period__c</field>
        <literalValue>0</literalValue>
        <name>Reset Blackout</name>
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
        <fullName>Check whether Hier record is modified</fullName>
        <actions>
            <name>Update_Approval_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(!$User.BypassWorkflows__c ,TEXT(Approval_Status__c) = &apos;Approved&apos;,OR(ISCHANGED(Unique_Hierarchy_ID1__c),ISCHANGED(Domain__c),ISCHANGED(Hierarchy_Description__c),ISCHANGED(Status__c),ISCHANGED(Top_Node_ID1__c),ISCHANGED(Node_ID1__c),ISCHANGED(Node_Type__c),ISCHANGED(Parent_Node_ID1__c),ISCHANGED(Level__c),ISCHANGED(Node_Description__c),ISCHANGED(Primary_Hierarchy_Parent_Node_ID__c),ISCHANGED(Primary_Hierarchy_Top_Node_ID1__c),ISCHANGED(Data_Storage__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
