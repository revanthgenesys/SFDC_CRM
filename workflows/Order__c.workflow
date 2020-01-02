<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Education_Order_Notification</fullName>
        <ccEmails>education@genesys.com</ccEmails>
        <ccEmails>Marianne.desjardins@genesys.com</ccEmails>
        <description>Education Order Notification</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>all/Education_Order_Notification</template>
    </alerts>
    <alerts>
        <fullName>New_Order_Submission_Alert</fullName>
        <description>New Order Submission Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner1__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/Order_Creation</template>
    </alerts>
    <alerts>
        <fullName>New_Order_Submission_Alert_Business_Edition_North_America</fullName>
        <description>New NA BE Order Submission Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>sasha.sobol@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/Order_Submission_for_Approva_NA_BE</template>
    </alerts>
    <alerts>
        <fullName>New_Pending_order_alert</fullName>
        <description>New Pending order alert</description>
        <protected>false</protected>
        <recipients>
            <field>Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/Order_Creation</template>
    </alerts>
    <alerts>
        <fullName>Order_Approval_Notification_Maintenance</fullName>
        <description>Order Approval Notification Maintenance</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/Order_Approved</template>
    </alerts>
    <alerts>
        <fullName>Order_Approved_Alert</fullName>
        <description>Order Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/Order_Approved</template>
    </alerts>
    <alerts>
        <fullName>Order_ReSubmitted_Alert</fullName>
        <description>Order ReSubmitted Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/Order_ReSumbmitted</template>
    </alerts>
    <alerts>
        <fullName>Order_Rejected_Alert</fullName>
        <description>Order Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Genesys_Care_Ops_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Genesys_Care_Specialist_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/Order_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Order_Rejected_Alert_Maintenance</fullName>
        <description>Order Rejected Alert - Maintenance</description>
        <protected>false</protected>
        <recipients>
            <field>Genesys_Care_rep_email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Maintenance_Queue_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/Order_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Order_Rejected_Notification_Maintenance</fullName>
        <description>Order Rejected Notification Maintenance</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/Order_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Order_Rejection_Alert</fullName>
        <description>Order Rejection Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner1__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Order_Rejection</template>
    </alerts>
    <alerts>
        <fullName>PC_Order_Rejected_Alert_To_Owners</fullName>
        <description>PC Order Rejected Alert To Owners</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/PC_Order_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Partner_NRO_Created_to_Creator</fullName>
        <description>Partner NRO Created to Creator</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_NRO_Created</template>
    </alerts>
    <alerts>
        <fullName>Partner_NRO_Created_to_Owner</fullName>
        <description>Partner NRO Created to Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_NRO_Created_Internal</template>
    </alerts>
    <alerts>
        <fullName>Partner_NRO_Notification_to_CM_24_hours_follow_up</fullName>
        <description>Partner NRO Notification to CM 24 hours follow up</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Partner_NRO_Created_Internal_24_hour_followup</template>
    </alerts>
    <alerts>
        <fullName>Partner_NRO_Notification_to_CM_48_hours_follow_up</fullName>
        <description>Partner NRO Notification to CM 48 hours follow up</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Partner_NRO_Created_Internal_48_hour_followup</template>
    </alerts>
    <alerts>
        <fullName>Partner_NRO_Notification_to_CM_7_days_follow_up</fullName>
        <description>Partner NRO Notification to CM 7 days follow up</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Partner_NRO_Created_Internal_7_day_followup</template>
    </alerts>
    <alerts>
        <fullName>Partner_NRO_Send_To_RCL_For_Approval</fullName>
        <description>Partner NRO Send To RCL For Approval</description>
        <protected>false</protected>
        <recipients>
            <field>RCL_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_NRO_Waiting_For_RCL_Approval</template>
    </alerts>
    <alerts>
        <fullName>Pricing_method_conversion_orders_email_alert</fullName>
        <ccEmails>GenesysCareOperations@genesys.com</ccEmails>
        <description>Pricing method conversion orders email alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Order_Pricing_method_conversion</template>
    </alerts>
    <alerts>
        <fullName>PureCloud_Project_Notification</fullName>
        <description>PureCloud Project Notification</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner1__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/PureCloud_Project_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Rejection_Email_to_PureCloud_Connect_PS</fullName>
        <ccEmails>oc@genesys.com</ccEmails>
        <ccEmails>PSNABillingRequests@genesys.com</ccEmails>
        <ccEmails>nik.mills@genesys.com</ccEmails>
        <description>Send Rejection Email to PureCloud_Connect PS</description>
        <protected>false</protected>
        <recipients>
            <recipient>scott.boggs@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/PS_Order_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Send_Rejection_Email_to_PureEngage_PS</fullName>
        <ccEmails>psoperations@genesys.com</ccEmails>
        <ccEmails>oc@genesys.com</ccEmails>
        <ccEmails>PSNABillingRequests@genesys.com</ccEmails>
        <ccEmails>nik.mills@genesys.com</ccEmails>
        <description>Send Rejection Email to PureEngage PS</description>
        <protected>false</protected>
        <recipients>
            <recipient>scott.boggs@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Templates/PS_Order_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Order_Creation_Notification</fullName>
        <description>Subscription Order Creation Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ankit.sanghvi@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>naresh.kumar@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vikram.sharma@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Subscription_Order_Creation_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Order_Status_to_Send_To_ERP</fullName>
        <field>status__c</field>
        <literalValue>Send to ERP</literalValue>
        <name>Update Order Status to Send To ERP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Reject_Date</fullName>
        <field>Date_Rejected__c</field>
        <formula>NOW()</formula>
        <name>Update Reject Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_bypass_entitlement_flag_for_renta</fullName>
        <field>Bypass_Entitlements__c</field>
        <literalValue>1</literalValue>
        <name>Update bypass entitlement flag for renta</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Education Order Notification</fullName>
        <actions>
            <name>Education_Order_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Has_Education_Lines__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Approval Notification - Maintenance</fullName>
        <actions>
            <name>Order_Approval_Notification_Maintenance</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Order__c.status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.Ship_software_via__c</field>
            <operation>equals</operation>
            <value>No Shipment Required</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.Source__c</field>
            <operation>notEqual</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.NRO_Type__c</field>
            <operation>notEqual</operation>
            <value>Mirror</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Order Approved Notification</fullName>
        <actions>
            <name>Order_Approved_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Order_Approved_Email_Sent_Successfully</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <formula>AND(
NOT($User.BypassWorkflows__c),
ISPICKVAL( status__c, &apos;Approved&apos;),
RecordType.Name != &apos;Cloud Monthly Billing Order&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Creation Notification</fullName>
        <actions>
            <name>New_Pending_order_alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Order_Submission_Email_Sent_Successfully</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <formula>AND(
OR(ISPICKVAL( status__c, &apos;Submitted&apos;),ISPICKVAL( status__c, &apos;Order Submitted&apos;)),
$User.BypassWorkflows__c = false
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Creation Notification-Business Edition_North America</fullName>
        <actions>
            <name>New_Order_Submission_Alert_Business_Edition_North_America</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Used to send email when Order is Submitted for Business Edition Offfering Type for North America.</description>
        <formula>AND( 
OR(ISPICKVAL( status__c, &apos;Submitted&apos;),ISPICKVAL( status__c, &apos;Order Submitted&apos;)), 
$User.BypassWorkflows__c = false, 
Region__c = &apos;North America&apos;, 
Quote__r.Offering_Type__c = &apos;Business Edition&apos; 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Rejected Notification</fullName>
        <actions>
            <name>Order_Rejected_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Order_Rejection_Email_Sent_Successfully</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <formula>AND(
ISPICKVAL( status__c, &apos;Rejected&apos;),
NOT($User.BypassWorkflows__c)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Rejected Notification - Maintenance</fullName>
        <actions>
            <name>Order_Rejected_Alert_Maintenance</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Order_Rejection_Email_Sent_Successfully</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <formula>AND( ISPICKVAL( status__c, &apos;Rejected&apos;), NOT($User.BypassWorkflows__c), ISPICKVAL(Ship_software_via__c,&apos;No Shipment Required&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Rejected ReSubmitted</fullName>
        <actions>
            <name>Order_ReSubmitted_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Order_Re_Submission_Email_Sent_Successfully</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <formula>AND(
ISPICKVAL(status__c, &apos;Re-Submitted&apos;),
NOT($User.BypassWorkflows__c)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Rejection Notification</fullName>
        <actions>
            <name>Order_Rejected_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>No Shipping, Order Submitted Notification</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Submitted Notification - Maintenance</fullName>
        <actions>
            <name>New_Order_Submission_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Order_Submission_Email_Sent_Successfully</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>No Shipping, Order Submitted Notification</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PC Order Rejected Notification</fullName>
        <actions>
            <name>PC_Order_Rejected_Alert_To_Owners</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>To send email notification to order owners for PC orders</description>
        <formula>AND( 
ISPICKVAL( status__c, &apos;Rejected&apos;), 
NOT($User.BypassWorkflows__c), 
Offering_Type__c=&apos;PureCloud&apos; 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureCloud_Connect Order Rejected Notification</fullName>
        <actions>
            <name>Send_Rejection_Email_to_PureCloud_Connect_PS</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Reject_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>PureCloud and PureConnect invoice/order rejection notification workflow from Salesforce</description>
        <formula>AND( ISPICKVAL( status__c, &apos;Rejected&apos;), 
RecordType.Name = &apos;PS_Orders&apos;,
NOT($User.BypassWorkflows__c),  ISPICKVAL( License_FYM_detail__c,&apos;PS Orders&apos;), OR(PS_Line_of_Business__c = &apos;PureCloud&apos;, PS_Line_of_Business__c = &apos;PureConnect&apos;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureEngage Order Rejected Notification</fullName>
        <actions>
            <name>Send_Rejection_Email_to_PureEngage_PS</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Reject_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISPICKVAL( status__c, &apos;Rejected&apos;),
RecordType.Name = &apos;PS_Orders&apos;,
NOT($User.BypassWorkflows__c), 
ISPICKVAL( License_FYM_detail__c,&apos;PS Orders&apos;),
PS_Line_of_Business__c = &apos;PureEngage&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Partner NRO Approval Awaiting Notification to RCL</fullName>
        <actions>
            <name>Partner_NRO_Send_To_RCL_For_Approval</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Request_for_Approval_sent_to_RCL</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Order__c.status__c</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.Order_Completed_by_AE__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.NRO_Type__c</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.Source__c</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Partner NRO Created Notification</fullName>
        <actions>
            <name>Partner_NRO_Created_to_Creator</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Partner_NRO_Created_to_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Source__c</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.NRO_Type__c</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Non-Revenue Orders</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.status__c</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <description>notifications to order owner and to the creator (Partner)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Partner_NRO_Notification_to_CM_24_hours_follow_up</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Partner_NRO_Notification_to_CM_48_hours_follow_up</name>
                <type>Alert</type>
            </actions>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Partner_NRO_Notification_to_CM_7_days_follow_up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Partner NRO Created Notification - old</fullName>
        <actions>
            <name>Partner_NRO_Created_to_Creator</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Partner_NRO_Created_to_Owner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Order__c.Source__c</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.NRO_Type__c</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Non-Revenue Orders</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>notifications to order owner and to the creator (Partner)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Rental field update</fullName>
        <actions>
            <name>Update_bypass_entitlement_flag_for_renta</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>auto-check the exclude from entitlement flag when the #1 is checked</description>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp; Text(License_FYM_detail__c) = &apos;Rental Order&apos; &amp;&amp; Not(Bypass_Entitlements__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Subscription Order Creation Notification</fullName>
        <actions>
            <name>Subscription_Order_Creation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Order Notification to Naresh, Ankit and Vikram.</description>
        <formula>AND(CONTAINS(Order_Category__c, &apos;Subscription&apos;),$User.BypassWorkflows__c = false)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Order Status to Send To ERP</fullName>
        <actions>
            <name>Update_Order_Status_to_Send_To_ERP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp;
(RecordType.Name == &apos;Cloud Monthly Billing Order&apos; ||
 (Order_Category__c == &apos;PureEngage - Renewal&apos; &amp;&amp;
  Subsidaries__c == &apos;a24U00000004XlJ&apos; /* 8100 */
 )
)
&amp;&amp;  ISPICKVAL(status__c,&apos;Approved&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Order_Approved_Email_Sent_Successfully</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>1-ASAP</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Order Approved Email Sent Successfully</subject>
    </tasks>
    <tasks>
        <fullName>Order_Re_Submission_Email_Sent_Successfully</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>1-ASAP</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Order Re Submission Email Sent Successfully</subject>
    </tasks>
    <tasks>
        <fullName>Order_Rejection_Email_Sent_Successfully</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>1-ASAP</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Order Rejection Email Sent Successfully</subject>
    </tasks>
    <tasks>
        <fullName>Order_Submission_Email_Sent_Successfully</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>1-ASAP</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Order Submission Email Sent Successfully</subject>
    </tasks>
    <tasks>
        <fullName>Request_for_Approval_sent_to_RCL</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>1-ASAP</priority>
        <protected>false</protected>
        <status>Done</status>
        <subject>Request for Approval sent to RCL</subject>
    </tasks>
</Workflow>
