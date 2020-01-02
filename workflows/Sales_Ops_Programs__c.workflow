<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sales_Ops_Program_Creation</fullName>
        <description>Sales Ops Program Creation</description>
        <protected>false</protected>
        <recipients>
            <recipient>pushpa.ramachandran@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>trevor.dewitt@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Sales_Ops_Program_Creation</template>
    </alerts>
    <rules>
        <fullName>Sales Ops Program Creation</fullName>
        <actions>
            <name>Sales_Ops_Program_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Sales_Ops_Programs__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Email to Pushpa and Kyle when program is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
