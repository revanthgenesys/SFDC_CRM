<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>General_Rejection_Email_Tri</fullName>
        <description>General_Rejection_Email_Tri</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/General_Rejection_Email_TRI</template>
    </alerts>
    <alerts>
        <fullName>PKB_Auto_Approve_Con_TRI</fullName>
        <description>PKB_Auto_Approve_Con_TRI</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/PKB_Auto_Approve_Triage</template>
    </alerts>
    <fieldUpdates>
        <fullName>Triage_Set_Customer_to_False</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>0</literalValue>
        <name>Triage Set Customer to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Triage_Set_Customer_to_True</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Triage Set Customer to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Triage_Set_Partner_to_False</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>0</literalValue>
        <name>Triage Set Partner to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Triage_Set_Partner_to_True</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Triage Set Partner to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Triage_Set_Public_to_False</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Triage Set Public to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Triage_Set_Public_to_True</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>1</literalValue>
        <name>Triage Set Public to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>Approve_and_Publish</fullName>
        <action>PublishAsNew</action>
        <label>Approve and Publish</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <knowledgePublishes>
        <fullName>Approve_and_Publish_Triage</fullName>
        <action>Publish</action>
        <label>Approve and Publish</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <rules>
        <fullName>Triage Validated Customer</fullName>
        <actions>
            <name>Triage_Set_Customer_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Triage_Set_Partner_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Triage_Set_Public_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Triage__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Customer</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Triage Validated Internal</fullName>
        <actions>
            <name>Triage_Set_Customer_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Triage_Set_Partner_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Triage_Set_Public_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Triage__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Internal</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Triage Validated Partner</fullName>
        <actions>
            <name>Triage_Set_Customer_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Triage_Set_Partner_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Triage_Set_Public_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Triage__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Partner</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Triage Validated Public</fullName>
        <actions>
            <name>Triage_Set_Customer_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Triage_Set_Partner_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Triage_Set_Public_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Triage__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Public</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
