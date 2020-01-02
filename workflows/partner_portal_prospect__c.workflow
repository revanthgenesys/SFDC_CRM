<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_to_Channel_Manager_24_hours</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Email Alert to Channel Manager - 24 hours</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Portal_Oppty_Reg_Approval_24_hr_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_to_Channel_Manager_48_Hours</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Email Alert to Channel Manager - 48 Hours</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Portal_Oppty_Reg_Approval_48_hr_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_to_Channel_Manager_72_Hours</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Email Alert to Channel Manager - 72 Hours</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Regional_Channel_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Portal_Oppty_Reg_Approval_72_hr_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_to_RCL_24_Hr</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Email Notification to RCL - 24 Hr</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Channel_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Portal_Oppty_Reg_Approval_24_hr_Follow_Up_RCL</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_to_RCL_48_HRs</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Email Notification to RCL - 48 HRs</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Channel_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Portal_Oppty_Reg_Approval_48_hr_Follow_Up_RCL</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_to_RCL_72_HR</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Email Notification to RCL - 72 HR</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Channel_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Portal_Oppty_Reg_Approval_72_hr_Follow_Up_RCL</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_to_Sales_Lead_24_Hr</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Email Notification to Sales Lead - 24 Hr</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Leader__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Portal_Oppty_Reg_Approval_24_hr_Follow_Up_Sales_Lead</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_to_Sales_Lead_48_Hr</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Email Notification to Sales Lead - 48 Hr</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Leader__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Portal_Oppty_Reg_Approval_48_hr_Follow_Up_Sales_Lead</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_to_Sales_Lead_72_Hr</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Email Notification to Sales Lead - 72 Hr</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Channel_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Sales_Leader__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Portal_Oppty_Reg_Approval_72_hr_Follow_Up_Sales_Leader</template>
    </alerts>
    <alerts>
        <fullName>Expiration_Extension_Submitted</fullName>
        <description>Expiration Extension Submitted</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Opportunity_Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Expiration_Extension_Submitted_Email</template>
    </alerts>
    <alerts>
        <fullName>Extension_Approval_Email</fullName>
        <description>Extension Approval Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Opportunity_Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Extension_Approval_Email</template>
    </alerts>
    <alerts>
        <fullName>Extension_Rejection_Email</fullName>
        <description>Extension Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Opportunity_Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Extension_Rejection_Email</template>
    </alerts>
    <alerts>
        <fullName>Partner_Opportunity_Approved_by_Genesys</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Partner Opportunity Approved by Genesys</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Opportunity_Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Opportunity_Approved_by_Genesys</template>
    </alerts>
    <alerts>
        <fullName>Partner_Opportunity_Rejected_by_Genesys</fullName>
        <ccEmails>dealregapprfollowup@1jc8dop5aezon7ujj0fe68kjmi7w17vgtocqznb7aqccrbuqil.u-km1gmaw.na48.apex.salesforce.com</ccEmails>
        <description>Partner Opportunity Rejected by Genesys</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Opportunity_Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Opportunity_Rejected_by_Genesys</template>
    </alerts>
    <alerts>
        <fullName>Partner_Opportunity_Submitted_by_Genesys</fullName>
        <ccEmails>partners@genesys.com</ccEmails>
        <description>Partner Opportunity Submitted  by Genesys</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Opportunity_Registration_Submitted_Internal</template>
    </alerts>
    <alerts>
        <fullName>Send_Rejection_Mail_to_Channel_Manager</fullName>
        <description>Send Rejection Mail to Channel Manager</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Channel_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Opportunity_Rejected_by_Genesys</template>
    </alerts>
    <fieldUpdates>
        <fullName>AE_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>AE Approved</literalValue>
        <name>AE Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AE_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>AE Rejected</literalValue>
        <name>AE Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AE_Sales_Manager_Approved</fullName>
        <description>Approval Status should be updated accordingly when AE Sales Manager approves</description>
        <field>Approval_Status__c</field>
        <literalValue>AE- Sales Manager Approved</literalValue>
        <name>AE Sales Manager Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AE_Sales_Manager_Rejected</fullName>
        <description>Approval Status should be updated accordingly when AE Sales Manager Rejects</description>
        <field>Approval_Status__c</field>
        <literalValue>AE - Sales Manager Rejected</literalValue>
        <name>AE Sales Manager Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>APAC_Channel_Manager_Approved</fullName>
        <description>Approval Status should be updated accordingly once APAC Channel Manager Approves</description>
        <field>Approval_Status__c</field>
        <literalValue>APAC- Regional Channel Manager Approved</literalValue>
        <name>APAC Channel Manager Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>APAC_Channel_Manager_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>APAC- Regional Channel Manager Rejected</literalValue>
        <name>APAC Channel Manager Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Channel_Manager_Approved</fullName>
        <field>Channel_Manager_Approved__c</field>
        <literalValue>1</literalValue>
        <name>Channel Manager Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Channel_Manager_Aprvd_False</fullName>
        <field>Channel_Manager_Approved__c</field>
        <literalValue>0</literalValue>
        <name>Channel Manager Aprvd - False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Channel_Manager_Second_Level_Approved</fullName>
        <description>Approval Status should be updated accordingly when Channel Manager Second Level Review is approved</description>
        <field>Approval_Status__c</field>
        <literalValue>Channel Manager Second Level Approved</literalValue>
        <name>Channel Manager Second Level Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Channel_Manager_Second_Level_Rejected</fullName>
        <description>Approval Status should be updated accordingly when Channel Manager Second Level Review gets Rejected</description>
        <field>Approval_Status__c</field>
        <literalValue>Channel Manager Second Level Rejected</literalValue>
        <name>Channel Manager Second Level Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clean_Proposed_Date</fullName>
        <field>Proposed_End_Date__c</field>
        <name>Clean Proposed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EMEA_Channel_Manager_Approved</fullName>
        <description>Field should be updated accordingly once EMEA Channel Manager approves</description>
        <field>Approval_Status__c</field>
        <literalValue>EMEA- Regional Channel Manager Approved</literalValue>
        <name>EMEA Channel Manager Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EMEA_Channel_Manager_Rejected</fullName>
        <description>Approval Status should be updated accordingly when EMEA Channel Manager Rejects</description>
        <field>Approval_Status__c</field>
        <literalValue>EMEA- Regional Channel Manager Rejected</literalValue>
        <name>EMEA Channel Manager Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LATAM_Channel_Manager_Approved</fullName>
        <description>Approval Status should be updated accordingly once LATAM Channel Manager approves</description>
        <field>Approval_Status__c</field>
        <literalValue>LATAM- Regional Channel Manager Approved</literalValue>
        <name>LATAM Channel Manager Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LATAM_Channel_Manager_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>LATAM- Regional Channel Manager Rejected</literalValue>
        <name>LATAM Channel Manager Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NA_Channel_Manager_Approved</fullName>
        <description>Approval Status should be updated to NA Channel Manager approved</description>
        <field>Approval_Status__c</field>
        <literalValue>NA- Regional Channel Manager Approved</literalValue>
        <name>NA Channel Manager Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NA_Channel_Manager_Rejected</fullName>
        <description>Approval Status should be updated accordingly when NA Channel Manager rejects</description>
        <field>Approval_Status__c</field>
        <literalValue>NA- Regional Channel Manager Rejected</literalValue>
        <name>NA Channel Manager Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opp_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Partner Opp Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opp_CM_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Channel Manager First Level Rejected</literalValue>
        <name>Partner Opp CM Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opp_LCM_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Local CM Approved</literalValue>
        <name>Partner Opp LCM Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opp_LCM_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Local CM Rejected</literalValue>
        <name>Partner Opp LCM Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opp_RCL_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>RCL Approved</literalValue>
        <name>Partner Opp RCL Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opp_RCL_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>RCL Rejected</literalValue>
        <name>Partner Opp RCL Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opp_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Partner Opp Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opportunity_Approval_Pending</fullName>
        <field>Status__c</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>Partner Opportunity Approval Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opportunity_Final_Rejection</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Partner Opportunity Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opportunity_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Partner Opportunity Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Opportunty_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Partner Opportunty Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Portal_Opportunity_Set_Expired</fullName>
        <field>Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Partner Portal Opportunity Set Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Portal_Opportunity_accept</fullName>
        <field>Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Partner Portal Opportunity accept</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Portal_Opportunity_rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Partner Portal Opportunity rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Partner_Portal_rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Partner Portal rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sales_Leader_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>AE- Sales Manager Approved</literalValue>
        <name>Sales Leader Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sales_Leader_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>AE - Sales Manager Rejected</literalValue>
        <name>Sales Leader Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>for_workflow</fullName>
        <field>for_workflow__c</field>
        <formula>&apos;a&apos;</formula>
        <name>for workflow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>status_expiredd</fullName>
        <field>Status__c</field>
        <literalValue>Expired</literalValue>
        <name>status_expiredd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>status_rejectedd</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>status rejectedd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_end_date</fullName>
        <field>End_Date__c</field>
        <formula>Proposed_End_Date__c</formula>
        <name>update end date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Channel Manager Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>partner_portal_prospect__c.Status__c</field>
            <operation>equals</operation>
            <value>Request Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.Channel_Manager_Approved__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.Approval_Status__c</field>
            <operation>notEqual</operation>
            <value>Channel Manager First Level Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.Sales_Leader__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>reminders to channel manager after record submission for approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_to_Channel_Manager_48_Hours</name>
                <type>Alert</type>
            </actions>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_to_Channel_Manager_72_Hours</name>
                <type>Alert</type>
            </actions>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_to_Channel_Manager_24_hours</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Partner Portal Op Reg Reject Notification</fullName>
        <actions>
            <name>Send_Rejection_Mail_to_Channel_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>partner_portal_prospect__c.Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.IsOpportunity_Exist__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Partner Portal Opportunity Expiration</fullName>
        <active>true</active>
        <description>This workflow fires a field update to expire the Partner Portal Opportunity Registration when the expiry date is reached</description>
        <formula>NOT(ISPICKVAL(Status__c,&apos;Expired&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Partner_Portal_Opportunity_Set_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>partner_portal_prospect__c.End_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Partner Portal Opportunity accept</fullName>
        <active>true</active>
        <criteriaItems>
            <field>partner_portal_prospect__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>This workflow works when end date is met and status is  accepted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Partner_Portal_Opportunity_accept</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>partner_portal_prospect__c.End_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Partner Portal Opportunity rejected</fullName>
        <active>true</active>
        <criteriaItems>
            <field>partner_portal_prospect__c.Status__c</field>
            <operation>equals</operation>
            <value>Request Submitted,Request Pending</value>
        </criteriaItems>
        <description>This workflow works when end date is met and status is  Request Submitted, Request Pending</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Partner_Portal_rejected</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>partner_portal_prospect__c.End_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Partner Portal Status Accept immediate</fullName>
        <actions>
            <name>status_expiredd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>partner_portal_prospect__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.End_Date__c</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>This workflow updates status to &quot;Expired&quot; if the status is “Approved&quot; after end_date</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Partner Portal Status reject immediate</fullName>
        <actions>
            <name>status_rejectedd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>partner_portal_prospect__c.Status__c</field>
            <operation>equals</operation>
            <value>Request Submitted,Request Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.End_Date__c</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>This workflow updates status to &quot;Expired&quot; if the status is “Approved&quot; after end_date</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Regional Channel Lead Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>partner_portal_prospect__c.Status__c</field>
            <operation>equals</operation>
            <value>Request Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>AE- Sales Manager Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.Approval_Status__c</field>
            <operation>notEqual</operation>
            <value>AE - Sales Manager Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Notification_to_RCL_24_Hr</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Notification_to_RCL_48_HRs</name>
                <type>Alert</type>
            </actions>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Notification_to_RCL_72_HR</name>
                <type>Alert</type>
            </actions>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Sales Leader Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>partner_portal_prospect__c.Status__c</field>
            <operation>equals</operation>
            <value>Request Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.Channel_Manager_Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.Approval_Status__c</field>
            <operation>notEqual</operation>
            <value>AE- Sales Manager Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>partner_portal_prospect__c.Approval_Status__c</field>
            <operation>notEqual</operation>
            <value>AE - Sales Manager Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Notification_to_Sales_Lead_24_Hr</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Notification_to_Sales_Lead_48_Hr</name>
                <type>Alert</type>
            </actions>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Notification_to_Sales_Lead_72_Hr</name>
                <type>Alert</type>
            </actions>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
