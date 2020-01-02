<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BOA_New_Created_Alert</fullName>
        <description>BOA New Created Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>customercare@genesyslab.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/BOA_New_Created</template>
    </alerts>
    <alerts>
        <fullName>BOA_Reinstated</fullName>
        <description>BOA Reinstated</description>
        <protected>false</protected>
        <recipients>
            <recipient>customercare@genesyslab.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/BOA_Support_Reinstated</template>
    </alerts>
    <alerts>
        <fullName>BOA_Terminated</fullName>
        <description>BOA: Terminated</description>
        <protected>false</protected>
        <recipients>
            <recipient>customercare@genesyslab.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/BOA_Support_Terminated</template>
    </alerts>
    <rules>
        <fullName>BOA%3A Created</fullName>
        <actions>
            <name>BOA_New_Created_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT ISBLANK( End_User_Account__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BOA%3A Reinstated</fullName>
        <actions>
            <name>BOA_Reinstated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( NOT ISNEW(),        
ISCHANGED( Contract_Status__c ),        
ISPICKVAL( PRIORVALUE(Contract_Status__c), &apos;Closed&apos; ),       ISPICKVAL( Contract_Status__c, &apos;Active&apos; )   
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BOA%3A Terminated</fullName>
        <actions>
            <name>BOA_Terminated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( NOT ISNEW(),        
ISCHANGED( Contract_Status__c ),        
ISPICKVAL( PRIORVALUE(Contract_Status__c), &apos;Active&apos; ),       ISPICKVAL( Contract_Status__c, &apos;Closed&apos; )   
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
