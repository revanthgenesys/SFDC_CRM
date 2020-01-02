<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Email_Alert</fullName>
        <ccEmails>Binita.Modi@genesys.com</ccEmails>
        <description>Approval Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Submitter__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Finance_MDM_GL_Account_Notification</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDM_Templates/GL_Account_Approved_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>GL_Account_New_Approved</fullName>
        <ccEmails>GLAccountDistribution@genesys.com; GlobalTreasury@genesys.com; marty.long@genesys.com</ccEmails>
        <description>GL Account New Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>mary.cross@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDM_Templates/GL_Account_Approved_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Email</fullName>
        <ccEmails>Raj.Nallamotu@genesys.com, Binita.Modi@genesys.com, marty.long@genesys.com</ccEmails>
        <description>Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Submitter__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Finance_MDM_GL_Account_Notification</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDM_Templates/GL_Account_Rejection_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Email_Alert</fullName>
        <ccEmails>Raj.Nallamotu@genesys.com, Binita.Modi@genesys.com, marty.long@genesys.com</ccEmails>
        <description>Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Approval_Submitter__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Finance_MDM_GL_Account_Notification</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDM_Templates/GL_Account_Rejection_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Approval_Status_to_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Change Approval Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Approval_Status_to_New</fullName>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Change Approval Status to New</name>
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
        <fullName>Freeze_GL_Account_Record</fullName>
        <field>Freez_Record__c</field>
        <literalValue>1</literalValue>
        <name>Freeze GL Account Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increase_Approval_Counter</fullName>
        <field>Approval_Counter__c</field>
        <formula>IF(ISNULL(Approval_Counter__c) , 1, Approval_Counter__c + 1)</formula>
        <name>Increase Approval Counter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increment_ApprovalCounter</fullName>
        <field>Approval_Counter__c</field>
        <formula>IF(ISNULL(Approval_Counter__c) , 1, Approval_Counter__c + 1)</formula>
        <name>Increment Approval Counter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increment_Approval_Counter</fullName>
        <field>Approval_Counter__c</field>
        <formula>200</formula>
        <name>Increment Approval Counter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Approval_Status_New</fullName>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Make Approval Status New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_GL_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Make GL Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Blackout</fullName>
        <field>Blackout_Period__c</field>
        <literalValue>0</literalValue>
        <name>Reset Blackout</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Last_Approved_Date</fullName>
        <field>Last_Approved_Date__c</field>
        <formula>Now()</formula>
        <name>Set Last Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
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
    <rules>
        <fullName>Check whether GL Account record is modified</fullName>
        <actions>
            <name>Change_Approval_Status_to_New</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Increment_ApprovalCounter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(!$User.BypassWorkflows__c, ISPICKVAL(Approval_Status__c, &apos;Approved&apos;), OR( ISCHANGED(Chart_of_Account__c),  ISCHANGED(Proposed_GL_Account_ID__c),   ISCHANGED(Description__c),  ISCHANGED(Netsuite_Type__c),  ISCHANGED(Currency__c),  ISCHANGED(GL_Account_Status__c),  ISCHANGED(Status__c),  ISCHANGED(Financial_Statement_Rollup__c))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>GL Account First Approval Email</fullName>
        <actions>
            <name>GL_Account_New_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email sent to Finance_MDM_New_GL_Account_Email_Notification group when a NEW GL Account approved</description>
        <formula>AND(!$User.BypassWorkflows__c, ISCHANGED(Approval_Status__c), ((TEXT(Approval_Status__c) = &apos;Approved&apos; &amp;&amp; (Approval_Counter__c = 0 || Approval_Counter__c = null)) ||  TEXT(Status__c) = &apos;Inactive&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>GL Account%3A Set Last Approved Date</fullName>
        <actions>
            <name>Set_Last_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>GL_Account__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
