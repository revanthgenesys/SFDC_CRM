<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Gainsight_Send_Task_Email</fullName>
        <description>Gainsight Send Task Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer_Care_CSM</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Customer_Care_Support_Expert</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>EMEA_France_Sales_Support</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>North_America_MM_Central_South_Sales_AE</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>WW_Customer_Care_Ops</recipient>
            <type>role</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>all/Gainsight_Task_Notification</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Assessment_Creation</fullName>
        <ccEmails>deal.desk@genesyslab.onmicrosoft.com</ccEmails>
        <description>Opportunity Assessment Creation</description>
        <protected>false</protected>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Opportunity_Assessment_Creation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_Activity_Type_Was_Clicked</fullName>
        <field>Activity_Type__c</field>
        <literalValue>Tracked Email - Clicked</literalValue>
        <name>Populate Activity Type - Was Clicked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Activity_Type_Was_Opened</fullName>
        <field>Activity_Type__c</field>
        <literalValue>Tracked Email - Open</literalValue>
        <name>Populate Activity Type - Was Opened</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Activity_Type_Was_Sent</fullName>
        <field>Activity_Type__c</field>
        <literalValue>Tracked Email</literalValue>
        <name>Populate Activity Type - Was Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Task_Name_Update</fullName>
        <field>Subject</field>
        <formula>&apos;P2P Assessment&apos;</formula>
        <name>Task Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Task_Type_Populate</fullName>
        <description>Updates the Task Type Field for Task reporting</description>
        <field>Task_Type__c</field>
        <formula>TEXT(Type)</formula>
        <name>Task Type Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Subject_Field_for_Mobile</fullName>
        <field>Subject</field>
        <formula>TEXT( Task_Subject__c )</formula>
        <name>Update Subject Field for Mobile</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Activity Type - Was Clicked</fullName>
        <actions>
            <name>Populate_Activity_Type_Was_Clicked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>contains</operation>
            <value>Clicked Link</value>
        </criteriaItems>
        <description>Workflow to populate the Activity Type with Subject contains Was Clicked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Activity Type - Was Opened</fullName>
        <actions>
            <name>Populate_Activity_Type_Was_Opened</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>contains</operation>
            <value>Opened Sales Email</value>
        </criteriaItems>
        <description>Workflow to populate the Activity Type with Subject contains Was Opened</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Activity Type - Was Sent</fullName>
        <actions>
            <name>Populate_Activity_Type_Was_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>contains</operation>
            <value>was sent</value>
        </criteriaItems>
        <description>Workflow to populate the Activity Type with Subject contains Was Sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Copy Task Subject for Mobile</fullName>
        <actions>
            <name>Update_Subject_Field_for_Mobile</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This copied the value from Task Subject into the standard subject field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Task Type Populate</fullName>
        <actions>
            <name>Task_Type_Populate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Type</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populates the Task Type field so that reports can be run</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Task Name</fullName>
        <actions>
            <name>Task_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>P2P Assessment</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
