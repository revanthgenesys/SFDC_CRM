<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Partner_Email</fullName>
        <description>Send Partner Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Genesys_Email_Manual_Partner</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Out_Litmos_Activated</fullName>
        <field>Litmos__Litmos_Activated__c</field>
        <literalValue>0</literalValue>
        <name>Clear Out Litmos Activated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Out_Litmos_UserId</fullName>
        <field>Litmos__LitmosUserId__c</field>
        <name>Clear Out Litmos UserId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Out_Sync_Litmos</fullName>
        <field>Litmos__Sync_Litmos__c</field>
        <literalValue>0</literalValue>
        <name>Clear Out Sync Litmos</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FirstName_Update</fullName>
        <field>FirstName</field>
        <formula>&quot;Partner&quot;</formula>
        <name>FirstName Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Send_Partner_Email</fullName>
        <field>Send_Partner_Email_Alert__c</field>
        <literalValue>0</literalValue>
        <name>Send Partner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Organisation</fullName>
        <field>Organization__c</field>
        <literalValue>No More Employee</literalValue>
        <name>Update Organisation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sync_Litmos</fullName>
        <field>Litmos__Sync_Litmos__c</field>
        <literalValue>1</literalValue>
        <name>Update Sync Litmos</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Clear Litmos Fields on User Deactivation</fullName>
        <actions>
            <name>Clear_Out_Litmos_Activated</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Out_Litmos_UserId</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Out_Sync_Litmos</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Clears Sync Litmos, Litmos UserId and Litmos Activated fields on User Deactivation</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Partner User Creation</fullName>
        <actions>
            <name>FirstName_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Organisation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF(AND(ContactId &lt;&gt; null,ISPICKVAL(Contact.Account.Type , &apos;Partner&apos;), FirstName = null), true, false)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Partner User Sync Litmos Update</fullName>
        <actions>
            <name>Update_Sync_Litmos</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Sync Litmos (Litmos__Sync_Litmos__c) flag when Partner User is created or updated</description>
        <formula>AND(NOT(ISBLANK(ContactId)), OR(Profile.Name = &apos;Genesys Portal Partner&apos;,Profile.Name = &apos;Custom Gold Partner&apos;), IsActive)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Partner Email</fullName>
        <actions>
            <name>Send_Partner_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Send_Partner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Send_Partner_Email_Alert__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UserIsActiveChanged</fullName>
        <active>true</active>
        <formula>IF( OR (ISCHANGED(IsActive ),  ISNEW() ),True, False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UserProfileChange</fullName>
        <active>false</active>
        <formula>if(or(ISCHANGED( ProfileId),  ISNEW() ),True, False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
