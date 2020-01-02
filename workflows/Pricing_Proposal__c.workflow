<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Post_Pricing_Committee_Approval_Email_to_PM_Ops</fullName>
        <description>Post Pricing Committee Approval Email to PM Ops</description>
        <protected>false</protected>
        <recipients>
            <recipient>ansel.moore@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chris.lee@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>elaine.goco@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Post_Pricing_Committee_Approval_Email_to_PM_Ops</template>
    </alerts>
    <alerts>
        <fullName>Pricing_Committee_approve_for_publish</fullName>
        <description>Pricing Committee approve for publish</description>
        <protected>false</protected>
        <recipients>
            <recipient>ansel.moore@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chris.lee@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ngoc.nguyen@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>victoria.chen@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wasi.wahid@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Pricing_Committee_approve_for_publish</template>
    </alerts>
    <fieldUpdates>
        <fullName>f1</fullName>
        <field>Pricing_Status__c</field>
        <literalValue>Approved for Publishing</literalValue>
        <name>f1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
