<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Credit_Memo_Approved</fullName>
        <description>Credit Memo Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Credit_Memo_Approved_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Credit_Memo_Approved_test</fullName>
        <description>Credit Memo Approved test</description>
        <protected>false</protected>
        <recipients>
            <field>Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Credit_Memo_Approved_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Credit_Memo_More_Info_Needed_Alert</fullName>
        <description>Credit Memo More Info Needed Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Credit_Memo_More_Info_Needed_Template</template>
    </alerts>
    <alerts>
        <fullName>Credit_Memo_Ready_for_Review_Alert</fullName>
        <description>Credit Memo Ready for Review Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>jitendra.jain@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Credit_Memo_Submitted_Alert_Template</template>
    </alerts>
    <alerts>
        <fullName>Credit_Memo_Rejected</fullName>
        <description>Credit Memo Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Credit_Memo_Rejected_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Credit_Memo_Request_Received_Alert</fullName>
        <description>Credit Memo Request Received Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Credit_Memo_Submitted_Alert_Template</template>
    </alerts>
    <alerts>
        <fullName>NA_Credit_Memo_Approval_Email</fullName>
        <description>NA Credit Memo Approval - Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>ezra.yarbro@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>megan.marks@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Credit_Memo_Approved_Notification_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Last_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Last Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusUnderApproval</fullName>
        <field>Status__c</field>
        <literalValue>Submit for Approval</literalValue>
        <name>Update Status to Under Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved - Pending Debooking</literalValue>
        <name>Update Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_update_to_Approvved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Status update to Approvved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Completed</fullName>
        <field>Date_Completed__c</field>
        <formula>TODAY()</formula>
        <name>Update Date Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Approved to Complete</fullName>
        <actions>
            <name>Update_Date_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Credit_Memo__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Approved to Complete</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Credit Memo More Info Needed Alert Rule</fullName>
        <actions>
            <name>Credit_Memo_More_Info_Needed_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Credit_Memo__c.Status__c</field>
            <operation>equals</operation>
            <value>More Info Needed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NA - Write off Approval Mail</fullName>
        <actions>
            <name>NA_Credit_Memo_Approval_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Credit_Memo__c.End_Customer_Region__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Memo__c.Credit_Memo_Type__c</field>
            <operation>equals</operation>
            <value>Business - Write Off/Bad Debt</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Memo__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Non Writeoff %3C100 approved</fullName>
        <actions>
            <name>Status_update_to_Approvved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Credit_Memo__c.Credit_Memo_Type__c</field>
            <operation>notEqual</operation>
            <value>Business - Write Off/Bad Debt</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Memo__c.End_Customer_Region__c</field>
            <operation>contains</operation>
            <value>EMEA,LATAM,North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Memo__c.Final_Credit_Amount_converted__c</field>
            <operation>lessThan</operation>
            <value>USD 100</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Memo__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Completed,Cancelled,Approved - Pending CreditMemo,Awaiting Rebill</value>
        </criteriaItems>
        <description>Non Writeoff &lt;100 approved</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
