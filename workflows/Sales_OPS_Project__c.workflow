<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_SOP</fullName>
        <description>New SOP</description>
        <protected>false</protected>
        <recipients>
            <recipient>pushpa.ramachandran@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/New_SOP</template>
    </alerts>
    <alerts>
        <fullName>SOP_has_been_modified</fullName>
        <description>SOP has been modified</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>pushpa.ramachandran@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/SOP_has_been_modified</template>
    </alerts>
    <rules>
        <fullName>New SOP</fullName>
        <actions>
            <name>New_SOP</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(
CreatedDate  =  NOW(),
NOT($User.BypassValidationRules__c = True)
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SOP has been modified%2E</fullName>
        <actions>
            <name>SOP_has_been_modified</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(
LastModifiedById  &lt;&gt;  Owner__c,
NOT($User.BypassValidationRules__c = True)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
