<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Security_Customer_True</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Security Customer True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Security_PKB_Customer_True</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Security PKB Customer True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Security_PKB_False</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Security PKB False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Security_PKB_False1</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Security PKB False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Security_PKB_PKB_True</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>1</literalValue>
        <name>Security PKB PKB True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Security_PKB_Partner_True</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Security PKB Partner True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Security_Partner_Customer_False</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Security Partner Customer False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Security_Partner_Partner_True</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Security Partner Partner True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Security_Partner_True</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Security Partner True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>Approve_and_Publish_Security</fullName>
        <action>PublishAsNew</action>
        <label>Approve and Publish Security</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <knowledgePublishes>
        <fullName>Auto_Approval_Publish</fullName>
        <action>PublishAsNew</action>
        <label>Auto_Approval_Publish</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <rules>
        <fullName>Security Advisories Validated Customer</fullName>
        <actions>
            <name>Security_Customer_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Security_PKB_False1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Security_Partner_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Security_Advisories__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Customer</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Security Advisories Validated Partner</fullName>
        <actions>
            <name>Security_PKB_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Security_Partner_Customer_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Security_Partner_Partner_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Security_Advisories__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Partner</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Security Validation PKB True</fullName>
        <actions>
            <name>Security_PKB_Customer_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Security_PKB_PKB_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Security_PKB_Partner_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Security_Advisories__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Public</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
