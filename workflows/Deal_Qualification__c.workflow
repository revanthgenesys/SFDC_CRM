<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DQ_Approved</fullName>
        <description>DQ Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>quotesapproval@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/DQ_Approval</template>
    </alerts>
    <alerts>
        <fullName>DQ_Future_Notification</fullName>
        <description>DQ Future Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ankit.sanghvi@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>quotesapproval@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/QA_Future_Products_Notification</template>
    </alerts>
    <alerts>
        <fullName>DQ_Rejected</fullName>
        <description>DQ Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>quotesapproval@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/DQ_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Telco_Included_in_BEC_Deal_DQ_Notification</fullName>
        <ccEmails>kevin.colliton@genesys.com</ccEmails>
        <description>Telco Included in BEC Deal DQ Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>alberto.fernandez@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>phillip.gallagher@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Telco_Included_in_BEC_Deal_DQ_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Level_1_Approval_Date</fullName>
        <field>Level_1_Approval_Date__c</field>
        <name>Clear Level 1 Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Level_1_Submission_Date</fullName>
        <field>Level_1_Submission_Date__c</field>
        <name>Clear Level 1 Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Level_2_Approval_Date</fullName>
        <field>Level_2_Approval_Date__c</field>
        <name>Clear Level 2 Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Level_2_Submission_Date</fullName>
        <field>Level_2_Submission_Date__c</field>
        <name>Clear Level 2 Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Level_3_Approval_Date</fullName>
        <field>Level_3_Approval_Date__c</field>
        <name>Clear Level 3 Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Level_3_Submission_Date</fullName>
        <field>Level_3_Submission_Date__c</field>
        <name>Clear Level 3 Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Level_4_Approval_Date</fullName>
        <field>Level_4_Approval_Date__c</field>
        <name>Clear Level 4 Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Level_4_Submission_Date</fullName>
        <field>Level_4_Submission_Date__c</field>
        <name>Clear Level 4 Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deal_Qualification_Populate_Oppty_Stage</fullName>
        <field>Oppty_Stage_on_DQ_Submission__c</field>
        <formula>Text(Opportunity__r.StageName)</formula>
        <name>Deal Qualification: Populate Oppty Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approval_Date_To_Today</fullName>
        <field>Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Approval Date To Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Expiry_Date_To_1_year</fullName>
        <description>Sets expiry date to Today + 365 days</description>
        <field>Expiration_Date__c</field>
        <formula>TODAY() + 365</formula>
        <name>Set Expiry Date To +1 year</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_History_Record_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>nareshk.it777@gmail.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update History Record Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_of_Submissions</fullName>
        <field>of_Submissions__c</field>
        <formula>PRIORVALUE(of_Submissions__c)+ 1</formula>
        <name>Update # of Submissions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DQ - Future products</fullName>
        <actions>
            <name>DQ_Future_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Opportunity__r.Country_Region__c = &quot;EMEA&quot; &amp;&amp;  TEXT(Are_you_selling_Non_GA_Future_Roadmap__c)=&quot;Yes&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DQ Approved</fullName>
        <actions>
            <name>DQ_Approved</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Approval_Date_To_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Expiry_Date_To_1_year</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Qualification__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deal_Qualification__c.Type__c</field>
            <operation>equals</operation>
            <value>Original</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DQ Rejected</fullName>
        <actions>
            <name>DQ_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Qualification__c.Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deal_Qualification__c.Type__c</field>
            <operation>equals</operation>
            <value>Original</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Deal Qualification%3A Populate Oppty Stage on DQ Submission</fullName>
        <actions>
            <name>Deal_Qualification_Populate_Oppty_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(PRIORVALUE(Submission_Date__c) = null) 
||
IsChanged( Submission_Date__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deal Qualification%3A Reset Pending Level Status on DQ Resubmission</fullName>
        <actions>
            <name>Clear_Level_1_Approval_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Level_1_Submission_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Level_2_Approval_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Level_2_Submission_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Level_3_Approval_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Level_3_Submission_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Level_4_Approval_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Level_4_Submission_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_of_Submissions</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow rule clears the prior date stamp approval fields to track the new approval statuses and updates the # of submissions.</description>
        <formula>ISPickVal( Status__c, &quot;Approval Pending&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Telco Included Notification</fullName>
        <actions>
            <name>Telco_Included_in_BEC_Deal_DQ_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Qualification__c.Platform_Type__c</field>
            <operation>equals</operation>
            <value>Cloud</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deal_Qualification__c.Offering_Type__c</field>
            <operation>equals</operation>
            <value>Business Edition</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deal_Qualification__c.Status__c</field>
            <operation>equals</operation>
            <value>Approval Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deal_Qualification__c.Is_Telco_Included__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notification to P. Gallagher and A. Fernandez to review if Telco is included in BEC deal.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update DQ History Record Owner</fullName>
        <actions>
            <name>Update_History_Record_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Qualification__c.Type__c</field>
            <operation>equals</operation>
            <value>History</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
