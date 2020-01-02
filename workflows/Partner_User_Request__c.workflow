<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Create_Account_Email_For_SalesOps</fullName>
        <ccEmails>AskSalesOps@genesys.com</ccEmails>
        <ccEmails>partners@genesys.com</ccEmails>
        <description>Create Account Email For SalesOps</description>
        <protected>false</protected>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Account_Creation_Email_For_SalesOps</template>
    </alerts>
    <alerts>
        <fullName>Login_Request_New_User_Approved_External</fullName>
        <description>Login Request New User Approved External</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Communities_Login_Request_New_User_Approved_External</template>
    </alerts>
    <alerts>
        <fullName>Login_Request_New_User_External</fullName>
        <ccEmails>partners@genesys.com</ccEmails>
        <description>Login Request New User External</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Login_Request_New_User_External</template>
    </alerts>
    <alerts>
        <fullName>Login_Request_New_User_Rejected_External</fullName>
        <description>Login Request New User Rejected External</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Login_Request_New_User_Rejected_External</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Request_Approved</fullName>
        <description>Partner Application Request Approved.</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Submitted_Internal_Old</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Request_Rejected</fullName>
        <description>Partner Application Request Rejected.</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Login_Request_New_User_Rejected_External_Old</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Create_New_Account_to_True</fullName>
        <field>Create_New_Account__c</field>
        <literalValue>1</literalValue>
        <name>Set Create New Account to &apos;True&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>User_Request_Approval_Denial_Date</fullName>
        <field>Approval_Denial_Date__c</field>
        <formula>NOW()</formula>
        <name>User Request Approval/Denial Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>User_Request_Status_to_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>User Request Status to Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>User_Request_Status_to_Awaiting_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>User Request Status to Awaiting Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>User_Request_Status_to_Denied</fullName>
        <field>Status__c</field>
        <literalValue>Denied</literalValue>
        <name>User Request Status to Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Create Account Email For SalesOps</fullName>
        <actions>
            <name>Create_Account_Email_For_SalesOps</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Partner_User_Request__c.SendAccount_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Partner Portal New User Email</fullName>
        <actions>
            <name>Login_Request_New_User_External</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Partner_User_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Approval</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
