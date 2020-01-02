<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Partner_Contract_Approved_by_Legal</fullName>
        <description>Partner Contract Approved by Legal</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Contract_for_Review</template>
    </alerts>
    <alerts>
        <fullName>Partner_Contract_Approved_by_PCM</fullName>
        <description>Partner Contract Approved by PCM</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Local_Channel_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PRM_Regional_Channel_Lead_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Contract_Approved_By_PCM</template>
    </alerts>
    <alerts>
        <fullName>Partner_Contract_for_Review_Legal</fullName>
        <description>Partner Contract for Review Legal</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Legal_Review</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Contract_Drawing_Requested_from_Legal</template>
    </alerts>
    <fieldUpdates>
        <fullName>Partner_Contract_Approved_By_PCM</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Partner Contract Approved By PCM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Contract_Final_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Partner Contract Final Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Contract_Legal_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved by Legal</literalValue>
        <name>Partner Contract Legal Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Contract_Legal_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected by Legal</literalValue>
        <name>Partner Contract Legal Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Contract_Rejected_By_PCM</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Partner Contract Rejected By PCM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
