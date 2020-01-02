<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_PureCloud_Monthly_Minimum_Zero</fullName>
        <description>Account PureCloud Monthly Minimum Zero</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Account_PureCloud_Monthly_Minimum_Zero</template>
    </alerts>
    <rules>
        <fullName>Account PureCloud Monthly Minimum Zero</fullName>
        <actions>
            <name>Account_PureCloud_Monthly_Minimum_Zero</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account_PureCloud_Monthly_Minimum__c.Monthly_Minimum__c</field>
            <operation>lessOrEqual</operation>
            <value>0</value>
        </criteriaItems>
        <description>E-mail sent when a PureCloud Monthly Minimum for an Account is 0</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
