<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Guru_Auto_Follow_Up_Customer</fullName>
        <description>Guru Auto Follow-Up To Customer</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wfm_helpdesk@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GURU_Mentoring_Templates/Guru_Mentoring_FollowUp</template>
    </alerts>
    <alerts>
        <fullName>Guru_Closure_Reminder</fullName>
        <description>Guru Closure Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wfm_helpdesk@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GURU_Mentoring_Templates/Guru_Mentoring_Closure</template>
    </alerts>
    <alerts>
        <fullName>Guru_Question_Assigned</fullName>
        <description>Guru Question Assigned</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>wfm_helpdesk@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GURU_Mentoring_Templates/Guru_Question_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Guru_Question_Auto_Follow_Up</fullName>
        <description>Guru Question Auto Follow Up</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wfm_helpdesk@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GURU_Mentoring_Templates/Guru_Mentoring_FollowUp</template>
    </alerts>
    <alerts>
        <fullName>Guru_Question_New</fullName>
        <description>Guru Question New</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>wfm_helpdesk@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GURU_Mentoring_Templates/Guru_New_Question_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Guru_Set_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>tracy.vickers@genesys.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Guru Set Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Guru Question Assigned</fullName>
        <actions>
            <name>Guru_Question_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Assigned_To__c) &amp;&amp; Assigned_To__c &lt;&gt; &quot;&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Guru Question New%3A Email to Submitter</fullName>
        <actions>
            <name>Guru_Question_New</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND NOT 4</booleanFilter>
        <criteriaItems>
            <field>Guru_Mentoring__c.Contact_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Guru_Mentoring__c.Status__c</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Guru_Mentoring__c.Sub_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Guru_Mentoring__c.Subject__c</field>
            <operation>startsWith</operation>
            <value>Automatic reply:</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Guru Question New%3A Update Owner</fullName>
        <actions>
            <name>Guru_Set_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Guru_Mentoring__c.Sub_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>set owner to Tracy Vickers to ensure email attachments visibility</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Guru Question%3A Auto Follow Up</fullName>
        <active>true</active>
        <criteriaItems>
            <field>User.Bypass_Triggers__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Guru_Mentoring__c.Status__c</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <description>notification sent to contact 7 days after Solution Proposed, status changed to Closed 10 days after Solution Proposed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Guru_Auto_Follow_Up_Customer</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>AutoFollow_up_has_been_sent</name>
                <type>Task</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Guru_Closure_Reminder</name>
                <type>Alert</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>AutoFollow_up_has_been_sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>Auto-Follow up has been sent to customer</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>4-Low</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Auto-Follow up has been sent</subject>
    </tasks>
    <tasks>
        <fullName>Auto_Follow_up_has_been_sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>Auto-Follow up has been sent</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>4-Low</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Auto-Follow up has been sent</subject>
    </tasks>
</Workflow>
