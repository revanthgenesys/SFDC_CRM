<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Activation_File_Request_Follow_Up_1</fullName>
        <description>Activation File Request Follow-Up #1</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email_for_Email_Alerts__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>genesyslicensing@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Licensing_Global/License_Request_Contact_FollowUp_1_2</template>
    </alerts>
    <alerts>
        <fullName>Activation_File_Request_Follow_up_2</fullName>
        <description>Activation File Request Follow-up #2</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email_for_Email_Alerts__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>genesyslicensing@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Licensing_Global/License_Request_Contact_FollowUp_1_2</template>
    </alerts>
    <alerts>
        <fullName>Activation_File_Request_Follow_up_3</fullName>
        <description>Activation File Request Follow-up #3</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email_for_Email_Alerts__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>genesyslicensing@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Licensing_Global/License_Request_Contact_FollowUp3</template>
    </alerts>
    <alerts>
        <fullName>License_Activation_Created_Email_to_Submitter</fullName>
        <description>License Activation Created: Email to Submitter</description>
        <protected>false</protected>
        <recipients>
            <field>Corporate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>genesyslicensing@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Licensing_Global/LicenseRequest_Submitted_From_Web</template>
    </alerts>
    <alerts>
        <fullName>License_Email_Notification_urgent</fullName>
        <description>License Email Notification urgent</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>ashley.kane@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>genesyslicensing@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Licensing_Global/License_Request_Made_Urgent</template>
    </alerts>
    <alerts>
        <fullName>License_Request_Owner_change</fullName>
        <description>License Request Owner change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesyslicensing@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Licensing_Global/License_Request_Owner_Changed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Contact_Email</fullName>
        <field>Contact_Email_for_Email_Alerts__c</field>
        <formula>IF (ISBLANK(Contact__c),
Corporate_Email__c, 
Contact__r.Email
)</formula>
        <name>Set Contact Email for Alerts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contact_Email_for_Alerts</fullName>
        <field>Contact_Email_for_Email_Alerts__c</field>
        <formula>IF (ISBLANK(Contact__c),
Corporate_Email__c, 
Contact__r.Email
)</formula>
        <name>Set Contact Email for Alerts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contacts_Email</fullName>
        <field>Contact_Email_for_Email_Alerts__c</field>
        <formula>IF (ISBLANK(Contact__c),
Corporate_Email__c, 
Contact__r.Email
)</formula>
        <name>Set Contacts Email for Alerts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Auto-Follow Up</fullName>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>License_Request__c.Block_Auto_Follow_Ups__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>License_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>License_Request__c.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Info required from customer</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Activation_File_Request_Follow_up_3</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Contact_Email_for_Alerts</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Auto_Follow_up_3_has_been_sent</name>
                <type>Task</type>
            </actions>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Activation_File_Request_Follow_Up_1</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Contacts_Email</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Auto_Follow_up_1_has_been_sent</name>
                <type>Task</type>
            </actions>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Activation_File_Request_Follow_up_2</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Contact_Email</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Auto_Follow_up_2_has_been_sent</name>
                <type>Task</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>License Activation Created%3A Email to Submitter</fullName>
        <actions>
            <name>License_Activation_Created_Email_to_Submitter</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>License_Request__c.Corporate_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>License_Request__c.Source__c</field>
            <operation>startsWith</operation>
            <value>WEB</value>
        </criteriaItems>
        <criteriaItems>
            <field>License_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Editable</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>License Request Change Owner</fullName>
        <actions>
            <name>License_Request_Owner_change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(OwnerId), NOT (Urgent__c), NOT($User.BypassWorkflows__c), RecordType.DeveloperName != &apos;Email_to_LicenseRequest&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>License Request Email Notification Urgent</fullName>
        <actions>
            <name>License_Email_Notification_urgent</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( OR(ISCHANGED(OwnerId), ISCHANGED(Urgent__c)), Urgent__c, NOT($User.BypassWorkflows__c), RecordType.DeveloperName != &apos;Email_to_LicenseRequest&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Auto_Follow_up_1_has_been_sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>First Auto-Follow up has been sent</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>4-Low</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Auto-Follow up #1 has been sent</subject>
    </tasks>
    <tasks>
        <fullName>Auto_Follow_up_2_has_been_sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>Second Auto-Follow up has been sent</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>4-Low</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Auto-Follow up #2 has been sent</subject>
    </tasks>
    <tasks>
        <fullName>Auto_Follow_up_3_has_been_sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>Third Auto-Follow up has been sent</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>4-Low</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Auto-Follow up #3 has been sent</subject>
    </tasks>
</Workflow>
