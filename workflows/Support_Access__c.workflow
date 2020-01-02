<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Support_Access_Expiration_Notification</fullName>
        <description>Support Access Expiration Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>customercare@genesyslab.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/Support_Access_Expiration_Internal</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Maintenance_Terminated_To_True</fullName>
        <field>Maintenance_Terminated_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Update Maintenance Terminated To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_Record_Validation</fullName>
        <field>Unique_Record_Validation__c</field>
        <formula>Contact__r.Id + End_User_Account__r.Id +  Sold_To_Account__r.Id +  Service_Contract__r.Id + TEXT(SR_Access_Level__c )</formula>
        <name>Update Unique Record Validation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Support Access%3A Exparation Notofication</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Support_Access__c.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <description>notification 14 days before the Expiration Date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Support_Access_Expiration_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Support_Access__c.Expiration_Date__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Maintenance Terminated field</fullName>
        <actions>
            <name>Update_Maintenance_Terminated_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow rule to update maintenance terminated field to true if the service contract agreement status is Terminated only when the record is created</description>
        <formula>ISPICKVAL( Service_Contract__r.Agreement_Status__c, &apos;Terminated&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
