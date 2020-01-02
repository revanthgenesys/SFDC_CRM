<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Non_Billable_Flag_set_value</fullName>
        <field>Non_Billable__c</field>
        <literalValue>1</literalValue>
        <name>Non-Billable Flag set value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_EOS_Flag_for_EOS000000001</fullName>
        <field>Extended_End_of_Support__c</field>
        <literalValue>1</literalValue>
        <name>Update EOS Flag for EOS000000001</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SC Line - Set Non-Billable Flag</fullName>
        <actions>
            <name>Non_Billable_Flag_set_value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Service_Contract_Type__c</field>
            <operation>notEqual</operation>
            <value>Perpetual</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update EOS Flag for EOS000000001</fullName>
        <actions>
            <name>Update_EOS_Flag_for_EOS000000001</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ContractLineItem.Upgraded_Product_Name__c</field>
            <operation>equals</operation>
            <value>EOS000000001</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
