<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Update_Made_Public_Customer_Notification</fullName>
        <description>Case Update Made Public - Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Support_Email_Templates/FR_Case_Change</template>
    </alerts>
</Workflow>
