<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Email_Alert</fullName>
        <ccEmails>Raj.Nallamotu@genesys.com,carol.donato@genesys.com</ccEmails>
        <description>Approval Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Submitter__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Finance_MDM_L1_Approval_Notification</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>Finance_MDM_L2_Approval_Notification</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Business_Segment_Approval_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Business_Segment_First_Approval_Email</fullName>
        <description>Business Segment First Approval Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>Finance_MDM_Email_Notification</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Business_Segment_Approval_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Email_Alert</fullName>
        <ccEmails>Raj.Nallamotu@genesys.com,carol.donato@genesys.com</ccEmails>
        <description>Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Submitter__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Finance_MDM_L1_Approval_Notification</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>Finance_MDM_L2_Approval_Notification</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Business_Segment_Rejection_Email_Temp</template>
    </alerts>
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
        <fullName>Bus_Segment_Set_Last_Approved_Date</fullName>
        <field>Last_Approved_Date__c</field>
        <formula>Now()</formula>
        <name>Bus Segment: Set Last Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
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
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Freez_Record</fullName>
        <field>Freez_Record__c</field>
        <literalValue>1</literalValue>
        <name>Freez Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increase_Approval_Counter</fullName>
        <description>Approval Count + 1</description>
        <field>Approval_Counter__c</field>
        <formula>IF(ISNULL(Approval_Counter__c) , 1, Approval_Counter__c + 1)</formula>
        <name>Increase Approval Counter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Blackout</fullName>
        <description>Reset Blackout to false</description>
        <field>Blackout_Period__c</field>
        <literalValue>0</literalValue>
        <name>Reset Blackout</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Reset Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Submitter_Email</fullName>
        <field>Approval_Submitter__c</field>
        <formula>$User.Email</formula>
        <name>Set Submitter Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
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
        <fullName>Bus Segment%3A Set Last Approved Date</fullName>
        <actions>
            <name>Bus_Segment_Set_Last_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Business_Segment__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Business Segment First Approval Email</fullName>
        <actions>
            <name>Business_Segment_First_Approval_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email sent to Finance_MDM_Email_Notification group when a NEW Business Segment approved</description>
        <formula>AND(!$User.BypassWorkflows__c, ISCHANGED(Approval_Status__c), ISPICKVAL(Approval_Status__c, &apos;Approved&apos;), Approval_Counter__c = 1)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check whether BS record is modified</fullName>
        <actions>
            <name>Update_Approval_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(!$User.BypassWorkflows__c ,TEXT(Approval_Status__c) = &apos;Approved&apos;,OR(ISCHANGED(Business_Segment_ID__c),ISCHANGED(Description__c),ISCHANGED(Definition__c),ISCHANGED(Hierarchy_node__c),ISCHANGED(Business_Segment_Offer_Type_Hierarchy1__c),ISCHANGED(Business_Segment_Cloud_Hierarchy__c),ISCHANGED(Name),ISCHANGED(Status__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
