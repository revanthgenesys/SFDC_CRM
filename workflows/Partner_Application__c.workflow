<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Partner_Application_Approved_Internal_HQ_RCL</fullName>
        <description>Partner Application Approved Internal HQ RCL</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Approved_Internal_HQ_RCL</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Approved_Internal_Lead_CM</fullName>
        <description>Partner Application Approved Internal Lead CM</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Approved_Internal_Lead_CM</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Approved_by_Internal_Legal</fullName>
        <description>Partner Application Approved by Internal Legal</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Approved_Internal_Legal</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Approved_by_Internal_PCM</fullName>
        <description>Partner Application Approved by Internal PCM</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Approved_Internal_PCM</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Approved_by_Internal_PS</fullName>
        <description>Partner Application Approved by Internal PS</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Approved_Internal_PS</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Final_Approval_External</fullName>
        <description>Partner Application Final Approval External</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>janelle.mertens@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Final_Approval_External</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Final_Approval_Internal</fullName>
        <description>Partner Application Final Approval Internal</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Final_Approval_Internal</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Final_Rejection_Internal_RCL</fullName>
        <description>Partner Application Final Rejection Internal RCL</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Final_Rejection_Internal</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Reassigned_Internal_HQ_RCL</fullName>
        <description>Partner Application Reassigned Internal HQ RCL</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Local_Channel_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Reassigned_Internal_HQ_RCL</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Rejected_External</fullName>
        <description>Partner Application Rejected External</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Rejected_External</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Rejected_Internal_HQ_RCL</fullName>
        <description>Partner Application Rejected Internal HQ RCL</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Rejected_Internal_HQ_RCL</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Rejected_Internal_Lead_CM</fullName>
        <description>Partner Application Rejected Internal Lead CM</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Rejected_Internal_Lead_CM</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Rejected_by_Internal_Legal</fullName>
        <description>Partner Application Rejected by Internal Legal</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Approved_Internal_Legal</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Rejected_by_Internal_PCM</fullName>
        <description>Partner Application Rejected by Internal PCM</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Rejected_Internal_PCM</template>
    </alerts>
    <alerts>
        <fullName>Partner_Application_Rejected_by_Internal_PS</fullName>
        <description>Partner Application Rejected by Internal PS</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Rejected_Internal_PS</template>
    </alerts>
    <alerts>
        <fullName>Partner_Business_Terms_Creation_Alert</fullName>
        <description>Partner Business Terms Creation Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_Account_Owner__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Final_Approval_Internal</template>
    </alerts>
    <alerts>
        <fullName>Partner_Internal_Setup_Email</fullName>
        <description>Partner Internal Setup Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>Partner_Application_Approval_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Partner_Approval_Complete_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>App_Approval_Status_LCM_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Local CM Approved</literalValue>
        <name>App Approval Status &apos;LCM Approved&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_LCM_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Local CM Rejected</literalValue>
        <name>App Approval Status &apos;LCM Rejected&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_Legal_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Legal Approved</literalValue>
        <name>App Approval Status &apos;Legal Approved&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_Legal_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Legal Rejected</literalValue>
        <name>App Approval Status &apos;Legal Rejected&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_PCM_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>PCM Approved</literalValue>
        <name>App Approval Status &apos;PCM Approved&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_PCM_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>PCM Rejected</literalValue>
        <name>App Approval Status &apos;PCM Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_PS_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>PS Approved</literalValue>
        <name>App Approval Status &apos;PS Approved&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_PS_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>PS Rejected</literalValue>
        <name>App Approval Status &apos;PS Rejected&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_RCL_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>RCL Approved</literalValue>
        <name>App Approval Status &apos;RCL Approved&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_RCL_Init_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>RCL Initial Approved</literalValue>
        <name>App Approval Status &apos;RCL Init Approved&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_RCL_Init_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>RCL Initial Rejected</literalValue>
        <name>App Approval Status &apos;RCL Init Rejected&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>App_Approval_Status_RCL_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>RCL Rejected</literalValue>
        <name>App Approval Status &apos;RCL Rejected&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Approval_Status_In_Review</fullName>
        <field>Approval_Status__c</field>
        <literalValue>In Review</literalValue>
        <name>Application Approval Status &apos;In Review&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Legal_Rejected_to_False</fullName>
        <field>Is_Legal_Rejected__c</field>
        <literalValue>0</literalValue>
        <name>Application Legal Rejected to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Legal_Rejected_to_True</fullName>
        <field>Is_Legal_Rejected__c</field>
        <literalValue>1</literalValue>
        <name>Application Legal Rejected to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Owner_RCL_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>RCL_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Application Owner RCL Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Status_to_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Application Status to &apos;Approved&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Status_to_Denied</fullName>
        <field>Status__c</field>
        <literalValue>Denied</literalValue>
        <name>Application Status to &apos;Denied&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Status_to_In_Review</fullName>
        <field>Status__c</field>
        <literalValue>In Review</literalValue>
        <name>Application Status to &apos;In Review&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Partner_Account_Owner</fullName>
        <field>Partner_Account_Owner__c</field>
        <formula>Account__r.Owner.Email</formula>
        <name>Field Update-Partner Account Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Legal_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Legal Approved</literalValue>
        <name>Legal Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PA_PCM_Rejected_1</fullName>
        <field>Approval_Status__c</field>
        <literalValue>PCM Rejected</literalValue>
        <name>PA PCM Rejected 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PA_PCM_approved_1</fullName>
        <field>Approval_Status__c</field>
        <literalValue>PCM Approved</literalValue>
        <name>PA PCM approved 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_PS_Rejected_To_False</fullName>
        <field>Is_PS_Rejected__c</field>
        <literalValue>0</literalValue>
        <name>Set PS Rejected To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_PS_Rejected_To_True</fullName>
        <field>Is_PS_Rejected__c</field>
        <literalValue>1</literalValue>
        <name>Set PS Rejected To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Application_Date_Completed</fullName>
        <field>Date_Completed__c</field>
        <formula>NOW()</formula>
        <name>Update Application Date Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Partner Account Owner</fullName>
        <actions>
            <name>Field_Update_Partner_Account_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
