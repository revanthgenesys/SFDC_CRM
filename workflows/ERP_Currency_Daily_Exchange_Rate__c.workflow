<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Email_Alert</fullName>
        <ccEmails>jitendra.jain@genesys.com,Raj.Nallamotu@genesys.com,nrathore@deloitte.com</ccEmails>
        <description>Approval Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/ERP_Currency_Exchange_Rate_Approval_Temp</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Email_Alert</fullName>
        <ccEmails>jitendra.jain@genesys.com,Raj.Nallamotu@genesys.com,nrathore@deloitte.com</ccEmails>
        <description>Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/ERP_Currency_Exchange_Rate_Rejection_Tem</template>
    </alerts>
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
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Change Status to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Submitted</fullName>
        <description>Updates the Status to &apos;Submitted&apos;</description>
        <field>Approval_Status__c</field>
        <literalValue>Pending L1 Approval</literalValue>
        <name>Change Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ERP_Currency_Type_Freez</fullName>
        <field>ERP_Currency_Freeze__c</field>
        <literalValue>1</literalValue>
        <name>ERP Currency Type Freez</name>
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
        <fullName>Reset_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Reset Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Check whether Exchange Rate record is modified</fullName>
        <actions>
            <name>Change_Status_to_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(!$User.BypassWorkflows__c ,TEXT(Approval_Status__c) = &apos;Approved&apos;, OR( ISCHANGED( Name ), ISCHANGED( EXCHANGE_RATE_TYPE__c ), ISCHANGED( Effective_Date__c ), ISCHANGED( From_Currency_Name__c ), ISCHANGED( To_Currency_Name__c ), ISCHANGED( Status__c ), ISCHANGED( Exchange_Rate_Source__c ), ISCHANGED( CONVERSION_RATE__c ), ISCHANGED( Average_Conversion_rate__c ), ISCHANGED( BS_Conversion_Rate__c ), ISCHANGED( Period_Month_Year__c ) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
