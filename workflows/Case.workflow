<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Closed</fullName>
        <description>Case Closed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Alternate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Case_Closed_Custom</template>
    </alerts>
    <alerts>
        <fullName>Case_Closed_30_Days</fullName>
        <description>Case Closed 30 Days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Expert_Help__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Case_Closed_30_Days_Notification</template>
    </alerts>
    <alerts>
        <fullName>Case_Closed_Cloud</fullName>
        <description>Case Closed - Cloud</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Alternate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Case_Closed_Cloud_Custom</template>
    </alerts>
    <alerts>
        <fullName>Case_Closed_Notification_to_Owner</fullName>
        <description>Case Closed Notification to Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Expert_Help__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Case_Closed_Owner_Notification</template>
    </alerts>
    <alerts>
        <fullName>Case_Closed_Notification_to_Owner_Cloud</fullName>
        <description>Case Closed Notification to Owner - Cloud</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Expert_Help__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Case_Closed_Owner_Notification</template>
    </alerts>
    <alerts>
        <fullName>Case_Pending_For_Review_Alert</fullName>
        <ccEmails>genesyscareww@genesyslab.com</ccEmails>
        <description>Case Pending For Review Alert</description>
        <protected>false</protected>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Case_Pending_for_Review_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Pending_For_Review_Alert_APAC</fullName>
        <ccEmails>GCAPAC@genesys.com</ccEmails>
        <description>Case Pending For Review Alert APAC</description>
        <protected>false</protected>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Case_Pending_for_Review_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Pending_For_Review_Alert_EMEA</fullName>
        <ccEmails>GCEMEA@genesys.com</ccEmails>
        <description>Case Pending For Review Alert EMEA</description>
        <protected>false</protected>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Case_Pending_for_Review_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Pending_For_Review_Alert_LATAM</fullName>
        <ccEmails>LATAMGenesysCare@genesys.com</ccEmails>
        <description>Case Pending For Review Alert LATAM</description>
        <protected>false</protected>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Case_Pending_for_Review_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Pending_For_Review_Alert_NA</fullName>
        <ccEmails>GenesysCareNA@genesys.com</ccEmails>
        <description>Case Pending For Review Alert NA</description>
        <protected>false</protected>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Case_Pending_for_Review_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Pending_For_Review_Alert_null</fullName>
        <ccEmails>GenesysCareNA@genesys.com</ccEmails>
        <description>Case Pending For Review Alert null</description>
        <protected>false</protected>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Case_Pending_for_Review_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Case_Alert</fullName>
        <description>Cloud Case Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>robert.davis@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vikram.sharma@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/Cloud_Case_Alert</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Case_Creation_Alert</fullName>
        <ccEmails>michael.davies@genesys.com</ccEmails>
        <description>Cloud Case Creation Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>prabhuram.doraiswamy@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Case_Creation</template>
    </alerts>
    <alerts>
        <fullName>Critical_First_Follow_up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>Critical First Follow-up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/Critical_Priority_First_Follow_up</template>
    </alerts>
    <alerts>
        <fullName>Critical_Third_Follow_up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>Critical Third Follow-up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/Critical_Third_Follow_up</template>
    </alerts>
    <alerts>
        <fullName>Email_to_Ginger</fullName>
        <description>Email to Ginger Alford on new FR created</description>
        <protected>false</protected>
        <recipients>
            <recipient>ginger.alford@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Support_Auto_Notifications/FR_Case_Opened</template>
    </alerts>
    <alerts>
        <fullName>FR_Due_Date_nearing_Alert</fullName>
        <description>FR Due Date nearing Alert</description>
        <protected>false</protected>
        <recipients>
            <field>PMOwnerNew__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/FR_DueDate_Nearing_new</template>
    </alerts>
    <alerts>
        <fullName>FR_Due_Date_nearing_Alert_before_14_days</fullName>
        <description>FR Due Date nearing Alert before 14 days</description>
        <protected>false</protected>
        <recipients>
            <field>PMOwnerNew__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/FR_DueDate_Nearing_new</template>
    </alerts>
    <alerts>
        <fullName>FR_Due_Date_nearing_Alert_for_0_days</fullName>
        <description>FR Due Date nearing Alert for 0 days</description>
        <protected>false</protected>
        <recipients>
            <field>PMOwnerNew__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/FR_DueDate_Nearing_new</template>
    </alerts>
    <alerts>
        <fullName>FR_Due_Date_nearing_Alert_for_7_days</fullName>
        <description>FR Due Date nearing Alert for 7 days</description>
        <protected>false</protected>
        <recipients>
            <field>PMOwnerNew__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/FR_DueDate_Nearing_new</template>
    </alerts>
    <alerts>
        <fullName>Feature_Request_Assignment_Alert</fullName>
        <description>Feature Request Assignment Alert</description>
        <protected>false</protected>
        <recipients>
            <field>PMOwnerNew__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/FR_Assignment_New</template>
    </alerts>
    <alerts>
        <fullName>Feature_Request_Case_Change_Alert</fullName>
        <description>Feature Request Case  Change Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Alternate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/FR_Update_Public_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>Feature_Request_Due_Date_nearing_Alert</fullName>
        <description>Feature Request Due Date nearing Alert</description>
        <protected>false</protected>
        <recipients>
            <field>PMOwnerNew__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/FR_DueDate_Nearing_new</template>
    </alerts>
    <alerts>
        <fullName>Feature_Request_Due_Date_overdue_Alert</fullName>
        <description>Feature Request Due Date overdue Alert</description>
        <protected>false</protected>
        <recipients>
            <field>PMOwnerNew__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/FR_Due_Date_Over_New</template>
    </alerts>
    <alerts>
        <fullName>Feature_request_Case_Update</fullName>
        <description>Feature request Case Update</description>
        <protected>false</protected>
        <recipients>
            <field>PMOwnerNew__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/FR_Case_Update_Text</template>
    </alerts>
    <alerts>
        <fullName>High_Priority_Awaiting_Info_Status_First_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>High Priority Awaiting Info Status First Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/High_Priority_Awaiting_Info_Status_First_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>High_Priority_Awaiting_Info_Status_Second_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>High Priority Awaiting Info Status Second Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/High_Priority_Awaiting_Info_Status_Second_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>High_Priority_Awaiting_Info_Status_Third_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>High Priority Awaiting Info Status Third Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/Case_CaseNumber</template>
    </alerts>
    <alerts>
        <fullName>High_Priority_Solution_Proposed_Status_First_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>High Priority Solution Proposed Status First Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/High_Priority_Solution_Proposed_Status_First_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>High_Priority_Solution_Proposed_Status_Second_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>High Priority Solution Proposed Status Second Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/High_Priority_Solution_Proposed_Status_Second_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>High_Priority_Solution_Proposed_Status_Third_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>High Priority Solution Proposed Status Third Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/High_Priority_Solution_Proposed_Status_Third_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Maintenance_Case_Created_Owner</fullName>
        <description>Maintenance Case Created Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Maintenance_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/Maintenance_Case_Created</template>
    </alerts>
    <alerts>
        <fullName>Maintenance_Case_Created_Queue</fullName>
        <description>Maintenance Case Created Queue</description>
        <protected>false</protected>
        <recipients>
            <field>Maintenance_Queue_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/Maintenance_Case_Created</template>
    </alerts>
    <alerts>
        <fullName>Maintenance_Case_Updated_Owner</fullName>
        <description>Maintenance Case Updated Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Maintenance_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/Maintenance_Case_Updated</template>
    </alerts>
    <alerts>
        <fullName>Maintenance_Case_Updated_Queue</fullName>
        <description>Maintenance Case Updated Queue</description>
        <protected>false</protected>
        <recipients>
            <field>Maintenance_Queue_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/Maintenance_Case_Updated</template>
    </alerts>
    <alerts>
        <fullName>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>Medium and Low Priority Awaiting Info Status First Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/Medium_Low_Priority_Awaiting_Info_Status_First_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>Medium and Low Priority Awaiting Info Status Second Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/Medium_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>Medium and Low Priority Awaiting Info Status Third Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/Medium_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>Medium and Low Priority Solution Proposed Status First Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/Medium_Low_Priority_Solution_Proposed_Status_First_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Medium_and_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>Medium and Low Priority Solution Proposed Status Second Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/Medium_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</fullName>
        <ccEmails>customercare@genesyslab.com</ccEmails>
        <description>Medium and Low Priority Solution Proposed Status Third Follow-Up</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/Medium_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>New_Feature_Request_Alert</fullName>
        <description>New Feature Request Alert</description>
        <protected>false</protected>
        <recipients>
            <field>PMOwnerNew__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/New_FR</template>
    </alerts>
    <alerts>
        <fullName>Partner_Request_Create_Website_Account</fullName>
        <description>Partner Request Create Website Account</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Request_Create_Website_Account</template>
    </alerts>
    <alerts>
        <fullName>PureConnect_MIM_Email_Alert</fullName>
        <ccEmails>pcc-major-incident@genesyscloud.pagerduty.com</ccEmails>
        <description>PureConnect MIM Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer_Care_MIM</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PureConnect_Email_Templates/MIM_Prod_Down_Notification</template>
    </alerts>
    <alerts>
        <fullName>Support_APAC_1st_Response_Approaching_Target</fullName>
        <description>Support: APAC 1st Response Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_First_Response</template>
    </alerts>
    <alerts>
        <fullName>Support_APAC_1st_Response_Target_Breach</fullName>
        <description>Support: APAC 1st Response Target Breach</description>
        <protected>false</protected>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_First_Response</template>
    </alerts>
    <alerts>
        <fullName>Support_APAC_New_Outage_Reported_on_Critical_Prod_Down_Case</fullName>
        <description>Support: APAC New Outage Reported on Critical/Prod Down Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Outage_Reported</template>
    </alerts>
    <alerts>
        <fullName>Support_APAC_Resolution_Approaching_Target</fullName>
        <description>Support: APAC Resolution Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_Resolution</template>
    </alerts>
    <alerts>
        <fullName>Support_APAC_Resolution_Target_Breached</fullName>
        <description>Support: APAC Resolution Target Breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Resolution_Target_Breached</template>
    </alerts>
    <alerts>
        <fullName>Support_APAC_Tech_Lead_Case_Assigned</fullName>
        <description>Support: APAC Tech Lead Case Assigned</description>
        <protected>false</protected>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Tech_Lead_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Support_Bounce_Unauthorised_Email_Escalations</fullName>
        <description>Support: Bounce Unauthorised Email Escalations</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/Support_Unauthorised_Escalations</template>
    </alerts>
    <alerts>
        <fullName>Support_Case_Assignation</fullName>
        <description>Support: Tier 3 Case Assignation</description>
        <protected>false</protected>
        <recipients>
            <field>Tier_3_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Support_Case_Created</fullName>
        <description>Support: Case Created</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Alternate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Case_Created_Custom</template>
    </alerts>
    <alerts>
        <fullName>Support_Case_Created_Cloud</fullName>
        <description>Support: Case Created - Cloud</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact_Alternate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Cloud_Care_Case_Created_Custom</template>
    </alerts>
    <alerts>
        <fullName>Support_Customer_Care_PSG_Case_Assignment</fullName>
        <description>Support: Customer Care - PSG Case Assignment</description>
        <protected>false</protected>
        <recipients>
            <field>PSG_email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/Customer_Care_PSG_Notify_Alias</template>
    </alerts>
    <alerts>
        <fullName>Support_Customer_Care_PSG_Expert_Help_notification</fullName>
        <description>Support: Customer Care - PSG Expert Help notification</description>
        <protected>false</protected>
        <recipients>
            <field>Expert_Help__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support_Email_Templates/Customer_Care_PSG_Notify_Expert_Help</template>
    </alerts>
    <alerts>
        <fullName>Support_Customer_Care_Tier_3_Case_Assignment</fullName>
        <description>Support: Customer Care - Tier 3 Case Assignment</description>
        <protected>false</protected>
        <recipients>
            <field>Tier_3_Queue_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Tier_3_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Support_EMEA_1st_Response_Approaching_Target</fullName>
        <description>Support: EMEA 1st Response Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>EMEA_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_First_Response</template>
    </alerts>
    <alerts>
        <fullName>Support_EMEA_1st_Response_Target_Breached</fullName>
        <description>Support: EMEA 1st Response Target Breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>EMEA_Support_Group</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_First_Response_Target_Breached</template>
    </alerts>
    <alerts>
        <fullName>Support_EMEA_New_Outage_Reported_on_Critical_Prod_Down_Case</fullName>
        <description>Support: EMEA New Outage Reported on Critical/Prod Down Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>EMEA_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Outage_Reported</template>
    </alerts>
    <alerts>
        <fullName>Support_EMEA_Resolution_Approaching_Target</fullName>
        <description>Support: EMEA Resolution Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>EMEA_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_Resolution</template>
    </alerts>
    <alerts>
        <fullName>Support_EMEA_Resolution_Target_Breached</fullName>
        <description>Support: EMEA Resolution Target Breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>EMEA_Support_Group</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Resolution_Target_Breached</template>
    </alerts>
    <alerts>
        <fullName>Support_EMEA_Tech_Lead_Case_Assigned</fullName>
        <description>Support: EMEA Tech Lead Case Assigned</description>
        <protected>false</protected>
        <recipients>
            <recipient>alan.gatto@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>annie.kingston@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dean.cottle@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>oleg.osadchyy@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>phil.murray@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tracy.vickers@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Tech_Lead_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Support_Japan_1st_Response_Approaching_Target</fullName>
        <description>Support: Japan 1st Response Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_First_Response</template>
    </alerts>
    <alerts>
        <fullName>Support_Japan_1st_Response_Target_Breached</fullName>
        <description>Support: Japan 1st Response Target Breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_First_Response_Target_Breached</template>
    </alerts>
    <alerts>
        <fullName>Support_Japan_New_Outage_Reported_on_Critical_Prod_Down_Case</fullName>
        <description>Support: Japan New Outage Reported on Critical/Prod Down Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Outage_Reported</template>
    </alerts>
    <alerts>
        <fullName>Support_Japan_Resolution_Approaching_Target</fullName>
        <description>Support: Japan Resolution Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_Resolution</template>
    </alerts>
    <alerts>
        <fullName>Support_Japan_Resolution_Target_Breached</fullName>
        <description>Support: Japan Resolution Target Breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Resolution_Target_Breached</template>
    </alerts>
    <alerts>
        <fullName>Support_Japan_Tech_Lead_Case_Assigned</fullName>
        <description>Support: Japan Tech Lead Case Assigned</description>
        <protected>false</protected>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Tech_Lead_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Support_Latin_America_1st_Response_Approaching_Target</fullName>
        <description>Support: Latin America 1st Response Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_First_Response</template>
    </alerts>
    <alerts>
        <fullName>Support_Latin_America_1st_Response_Target_Breached</fullName>
        <description>Support: Latin America 1st Response Target Breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_First_Response_Target_Breached</template>
    </alerts>
    <alerts>
        <fullName>Support_Latin_America_Resolution_Approaching_Target</fullName>
        <description>Support: Latin America Resolution Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_Resolution</template>
    </alerts>
    <alerts>
        <fullName>Support_Latin_America_Resolution_Target_Breached</fullName>
        <description>Support: Latin America Resolution Target Breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Resolution_Target_Breached</template>
    </alerts>
    <alerts>
        <fullName>Support_Latin_America_Tech_Lead_Case_Assigned</fullName>
        <description>Support: Latin America Tech Lead Case Assigned</description>
        <protected>false</protected>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Tech_Lead_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Support_Latin_American_New_Outage_Reported_on_Critical_Prod_Down_Case</fullName>
        <description>Support: Latin American New Outage Reported on Critical/Prod Down Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Outage_Reported</template>
    </alerts>
    <alerts>
        <fullName>Support_New_Internal_Case_Update_on_Case</fullName>
        <description>Support: New Internal Case Update on Case</description>
        <protected>false</protected>
        <recipients>
            <field>Tier_3_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Tier_3_Case_Update</template>
    </alerts>
    <alerts>
        <fullName>Support_New_public_case_comment</fullName>
        <description>Support: New public Care Case Comment</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Case_Update_to_Customer_VF</template>
    </alerts>
    <alerts>
        <fullName>Support_North_America_1st_Response_Approaching_Target</fullName>
        <description>Support: North America 1st Response Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_First_Response</template>
    </alerts>
    <alerts>
        <fullName>Support_North_America_1st_Response_Target_Breach</fullName>
        <description>Support: North America 1st Response Target Breach</description>
        <protected>false</protected>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_First_Response</template>
    </alerts>
    <alerts>
        <fullName>Support_North_America_Resolution_Approaching_Target</fullName>
        <description>Support: North America Resolution Approaching Target</description>
        <protected>false</protected>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Approaching_Target_For_Resolution</template>
    </alerts>
    <alerts>
        <fullName>Support_North_America_Resolution_Target_Breached</fullName>
        <description>Support: North America  Resolution Target Breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Resolution_Target_Breached</template>
    </alerts>
    <alerts>
        <fullName>Support_North_America_Tech_Lead_Case_Assigned</fullName>
        <description>Support: North America Tech Lead Case Assigned</description>
        <protected>false</protected>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Tech_Lead_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Support_North_American_New_Outage_Reported_on_Critical_Prod_Down_Case</fullName>
        <description>Support: North American New Outage Reported on Critical/Prod Down Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Outage_Reported</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_APAC_Management_Outage_SLA_Breached</fullName>
        <description>Support: Notify APAC Management Outage SLA Breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Breach_of_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_APAC_Management_Outage_SLA_approach</fullName>
        <description>Support: Notify APAC Management Outage SLA approach</description>
        <protected>false</protected>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Approaching_Target_For_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_APAC_Management_about_Priority_change_Prod_down_Critical_Cases</fullName>
        <description>Support: Notify APAC Management about Priority change Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Priority_Change_Case</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_APAC_Management_about_Prod_down_Critical_Cases</fullName>
        <description>Support: Notify APAC Management about Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>APAC_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/New_Case_Critical_or_Prod_Down</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_EMEA_Management_Outage_SLA_approach</fullName>
        <description>Support: Notify EMEA Management Outage SLA approach</description>
        <protected>false</protected>
        <recipients>
            <recipient>EMEA_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Approaching_Target_For_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_EMEA_Management_Outage_SLA_breached</fullName>
        <description>Support: Notify EMEA Management Outage SLA breached</description>
        <protected>false</protected>
        <recipients>
            <recipient>EMEA_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Breach_of_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_EMEA_Management_about_Priority_change_Prod_down_Critical_Cases</fullName>
        <description>Support: Notify EMEA Management about Priority change Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>EMEA_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Priority_Change_Case</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_EMEA_Management_about_Prod_down_Critical_Cases</fullName>
        <description>Support: Notify EMEA Management about Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>EMEA_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/New_Case_Critical_or_Prod_Down</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_Japan_Management_Outage_SLA_Breach</fullName>
        <description>Support: Notify Japan Management Outage SLA Breach</description>
        <protected>false</protected>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Breach_of_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_Japan_Management_Outage_SLA_approach</fullName>
        <description>Support: Notify Japan Management Outage SLA approach</description>
        <protected>false</protected>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Approaching_Target_For_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_Japan_Management_about_Priority_change_Prod_down_Critical_Cases</fullName>
        <description>Support: Notify Japan Management about Priority change Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Priority_Change_Case</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_Japan_Management_about_Prod_down_Critical_Cases</fullName>
        <description>Support: Notify Japan Management about Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>Japan_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/New_Case_Critical_or_Prod_Down</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_Latin_America_Management_Outage_SLA_Breach</fullName>
        <description>Support: Notify Latin America Management Outage SLA Breach</description>
        <protected>false</protected>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Breach_of_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_Latin_America_Management_Outage_SLA_approach</fullName>
        <description>Support: Notify Latin America Management Outage SLA approach</description>
        <protected>false</protected>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Approaching_Target_For_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_Latin_America_Management_about_Priority_change_Prod_down_Critical</fullName>
        <description>Support: Notify Latin America Management about Priority change Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Priority_Change_Case</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_Latin_America_Management_about_Prod_down_Critical_Cases</fullName>
        <description>Support: Notify Latin America Management about Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>Latin_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/New_Case_Critical_or_Prod_Down</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_North_America_Management_Outage_SLA_Breach</fullName>
        <description>Support: Notify North America Management Outage SLA Breach</description>
        <protected>false</protected>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Breach_of_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_North_America_Management_Outage_SLA_approach</fullName>
        <description>Support: Notify North America Management Outage SLA approach</description>
        <protected>false</protected>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Outage_Approaching_Target_For_SLA</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_North_America_Management_about_Priority_change_Prod_down_Critical</fullName>
        <description>Support: Notify North America Management about Priority change Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Priority_Change_Case</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_North_America_Management_about_Prod_down_Critical_Cases</fullName>
        <description>Support: Notify North America Management about Prod down Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>North_America_Support_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/New_Case_Critical_or_Prod_Down</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_Owner_of_Update_on_Critical_Case</fullName>
        <description>Support: Notify Owner of Update on Critical Case</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Customer_Care_Critical_Case_Update</template>
    </alerts>
    <alerts>
        <fullName>Support_Notify_new_owner_of_Critical_case_reassignment</fullName>
        <description>Support: Notify new owner of Critical case reassignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/New_Critical_Case_Assigned</template>
    </alerts>
    <fieldUpdates>
        <fullName>Block_Auto_Follow_Up_Until</fullName>
        <field>Do_Not_Auto_Follow_Up_Until__c</field>
        <formula>if(isnull( Do_Not_Auto_Follow_Up_Until__c ), today(), Do_Not_Auto_Follow_Up_Until__c )</formula>
        <name>Block Auto Follow Up Until</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Check_New_Updates_Flg</fullName>
        <field>New_Updates__c</field>
        <literalValue>1</literalValue>
        <name>Case Check New Updates Flg</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Clone_Clear_Siebel_Fields1</fullName>
        <description>need to support FTP functionality - when case is cloned remove Siebel ids</description>
        <field>Case_Number__c</field>
        <name>Case Clone Clear Siebel Fields1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Clone_Clear_Siebel_Fields2</fullName>
        <field>Siebel_FR_Number__c</field>
        <name>Case Clone Clear Siebel Fields2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Clone_Clear_Siebel_Fields3</fullName>
        <field>Siebel_ID__c</field>
        <name>Case Clone Clear Siebel Fields3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Populate_Alternate_Email</fullName>
        <description>populate field Case Contact Alternate Email</description>
        <field>Contact_Alternate_Email__c</field>
        <formula>Contact.Alternate_Email__c</formula>
        <name>Case: Populate Alternate Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FR_Due_Date_nearing_TDA_Update</fullName>
        <field>FR_Due_Date_nearing_TDA__c</field>
        <literalValue>1</literalValue>
        <name>FR Due Date nearing TDA Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_TS_Case_Set_Owner_Unassigned</fullName>
        <field>OwnerId</field>
        <lookupValue>Genesys_Support_Unassigned_Cases</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>New TS Case - Set Owner Unassigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Priority_to_High</fullName>
        <field>Priority</field>
        <literalValue>2-High</literalValue>
        <name>Priority to High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Priority_to_Medium</fullName>
        <field>Priority</field>
        <literalValue>Medium</literalValue>
        <name>Priority to Medium</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Closure_Category</fullName>
        <field>Closure_Category__c</field>
        <name>Reset Closure Category</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Closure_Reason_Code</fullName>
        <field>Closure_Reason_Code__c</field>
        <name>Reset Closure Reason Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Sub_Status</fullName>
        <field>Sub_Status__c</field>
        <name>Reset Sub-Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Prod_Down_Flag</fullName>
        <field>Production_Down__c</field>
        <literalValue>1</literalValue>
        <name>Set Prod Down Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_sub_status_to_New</fullName>
        <description>This field update will set the case update sub status to New.</description>
        <field>Sub_Status__c</field>
        <literalValue>New</literalValue>
        <name>Set sub-status to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Approaching_First_Response</fullName>
        <field>Workflow_Field_Alert_Name__c</field>
        <formula>&quot;Workflow_Approaching_First_Response__c&quot;</formula>
        <name>Support: Approaching First Response</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Approaching_Resolution_Targets</fullName>
        <field>Workflow_Field_Alert_Name__c</field>
        <formula>&quot;Workflow_Approaching_Resolution_Target__c&quot;</formula>
        <name>Support: Approaching Resolution Targets</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Approaching_SLA_of_Outage</fullName>
        <field>Workflow_Field_Alert_Name__c</field>
        <formula>&quot;Workflow_Outage_Restore_Nearing_SLA__c&quot;</formula>
        <name>Support: Approaching SLA of Outage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Assign_to_Tier_1</fullName>
        <description>This field update will change the owner to Tier 1 support queue.</description>
        <field>OwnerId</field>
        <lookupValue>Admin_Case</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Support: Assign to Tier 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Assign_to_Tier_2</fullName>
        <description>This field update will assign cases from the portal to Tier 2</description>
        <field>OwnerId</field>
        <lookupValue>Tier_2_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Support: Assign to Tier 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Breach_of_Outage_SLA</fullName>
        <field>Workflow_Field_Alert_Name__c</field>
        <formula>&quot;Workflow_Outage_Restore_Violation_SLA__c&quot;</formula>
        <name>Support: Breach of Outage SLA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Change_Status_to_Open_Prod</fullName>
        <field>Status</field>
        <literalValue>Open - Product Management</literalValue>
        <name>Support: Change Status to Opn Prd M</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Close_Case</fullName>
        <description>This field update will close the case.</description>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Support: Close Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_First_Response_Breached</fullName>
        <field>Workflow_Field_Alert_Name__c</field>
        <formula>&quot;Workflow_First_Response_Breached__c&quot;</formula>
        <name>Support : First Response Breached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Next_Update_Due</fullName>
        <field>Next_Update_Due__c</field>
        <formula>Now()+30</formula>
        <name>Support: Next Update Due</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_PM_Engaged_ON</fullName>
        <field>PM_Engaged_on__c</field>
        <formula>Now()</formula>
        <name>Support: PM Engaged ON</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Pause_SLA_Clock</fullName>
        <description>This field update will pause the SLA clock</description>
        <field>IsStopped</field>
        <literalValue>1</literalValue>
        <name>Support: Pause SLA Clock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Resolution_Breached</fullName>
        <field>Workflow_Field_Alert_Name__c</field>
        <formula>&quot;Workflow_Resolution_Target_Breached__c&quot;</formula>
        <name>Support : Resolution Breached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Returning_Escalation_to_Tier_3</fullName>
        <description>This field update will update the tier 3 status to returning.</description>
        <field>Tier_3_Status__c</field>
        <literalValue>Tier 3 Queue - Returning</literalValue>
        <name>Support: Returning Escalation to Tier 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Set_Origin_To_Web</fullName>
        <description>This field update will set the case origin to web, for portal cases.</description>
        <field>Origin</field>
        <literalValue>Web</literalValue>
        <name>Support: Set Origin To Web</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Set_Tier_3_Date_Time</fullName>
        <description>THis field update will update the date/time a case has been sent to Tier 3</description>
        <field>reports_Date_Time_Sent_to_Tier_3__c</field>
        <formula>NOW()</formula>
        <name>Support: Set Tier 3 Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Set_sub_status_to_ER</fullName>
        <description>This field update will set the case sub-status to ER.</description>
        <field>Sub_Status__c</field>
        <literalValue>Engineering Request</literalValue>
        <name>Support: Set sub-status to ER</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Sub_Status_to_Tier_3</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Tier 3</literalValue>
        <name>Support: Sub Status to Tier 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Tier_2</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Tier 2</literalValue>
        <name>Support: Tier 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Tier_3_Status_T3_Queue_Returning</fullName>
        <field>Tier_3_Status__c</field>
        <literalValue>Tier 3 Queue - Returning</literalValue>
        <name>Support:Tier 3 Status-T3 Queue Returning</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Tier_3_Status_To_Ti3_Queue_New</fullName>
        <field>Tier_3_Status__c</field>
        <literalValue>Tier 3 Queue - New</literalValue>
        <name>Support : Tier 3 Status To Ti3 Queue New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Unpause_SLA_Clock</fullName>
        <description>This field update will restart the SLA clock.</description>
        <field>IsStopped</field>
        <literalValue>0</literalValue>
        <name>Support: Unpause SLA Clock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Update</fullName>
        <description>This field will update the Approaching Resolution Target to true. This is determine whether a workflow rule will fire to the interested parties.</description>
        <field>Workflow_Approaching_Resolution_Target__c</field>
        <literalValue>1</literalValue>
        <name>Support: Approaching  Resolution Target</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Update_Approaching</fullName>
        <description>This will update the field to true when the milestone has breached First Response. This will determine if a workflow rule will fire to notify interested parties.</description>
        <field>Workflow_First_Response_Breached__c</field>
        <literalValue>1</literalValue>
        <name>Support: Update 1st Response Breached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Update_Resolution_Breached</fullName>
        <description>This field will update the Resolution Target Breached to true once the resolution milestone has been breached. This will determine whether a workflow rule will fire to the interested parties.</description>
        <field>Workflow_Resolution_Target_Breached__c</field>
        <literalValue>1</literalValue>
        <name>Support: Update Resolution Breached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateModifiedTime</fullName>
        <field>Date_Modified__c</field>
        <formula>now()</formula>
        <name>UpdateModifiedTime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approaching_First_Response</fullName>
        <description>This will update the field to true when the milestone is approaching First Response. This will determine if a workflow rule will fire to notify interested parties.</description>
        <field>Workflow_Approaching_First_Response__c</field>
        <literalValue>1</literalValue>
        <name>Support: Update Approaching 1st Response</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PSG_email</fullName>
        <description>Product support groups email alias update</description>
        <field>PSG_email__c</field>
        <formula>CASE(Product_Support_Group__c, 
&quot;Custom Applications&quot;,&quot;TSCaseQueue-CustomApplications@genesys.com&quot;, 
&quot;PureCloud&quot;,&quot;CCCaseQueue-CloudPureCloud@genesys.com&quot;, 
&quot;PureEngage Business Applications&quot;,&quot;TSCaseQueue-BusinessApplications@genesys.com&quot;, 
&quot;PureEngage Reporting &amp; Analytics&quot;,&quot;TSCaseQueue-Reporting&amp;Analytics@genesys.com&quot;, 
&quot;PureEngage Telephony&quot;,&quot;TSCaseQueue-Telephony@genesys.com&quot;, 
&quot;PureEngage Voice Self Service&quot;,&quot;TSCaseQueue-VoiceSelfService@genesys.com&quot;, 
&quot;PureEngage CC Tools &amp; Infrastructure&quot;,&quot;CCCaseQueue-ToolsInfrastructure@genesys.com&quot;, 
&quot;PureEngage Cloud Hybrid&quot;,&quot;CCCaseQueue-CloudHybrid@genesys.com&quot;, 
&quot;PureEngage CC Provisioning&quot;,&quot;PECCCProv@genesys.com&quot;, 
&quot;&quot; )</formula>
        <name>Update PSG email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sub_Status_Change_Date_Time</fullName>
        <field>Sub_Status_Change_Date_Time__c</field>
        <formula>now()</formula>
        <name>Update Sub Status Change Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>sub_status_to_new</fullName>
        <field>Sub_Status__c</field>
        <literalValue>New</literalValue>
        <name>sub status to new</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case Clone Clear Fields</fullName>
        <actions>
            <name>Case_Clone_Clear_Siebel_Fields1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Clone_Clear_Siebel_Fields2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Clone_Clear_Siebel_Fields3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Case_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>clear legacy fields if case is cloned</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Closed 30 Days Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Admin,Feature Request,Support,Cloud Incident,Cloud Support Request,Cloud Service Request,Cloud Feature Request,On-Premises Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>notification 30 days after the case closure</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Closed_30_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case Sub status to Maintenance Investigated</fullName>
        <actions>
            <name>Case_Pending_For_Review_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Maintenance Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Sub status to Maintenance Investigated APAC</fullName>
        <actions>
            <name>Case_Pending_For_Review_Alert_APAC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Maintenance Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.End_User_Account_Country_Region__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Sub status to Maintenance Investigated EMEA</fullName>
        <actions>
            <name>Case_Pending_For_Review_Alert_EMEA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Maintenance Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.End_User_Account_Country_Region__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Sub status to Maintenance Investigated LATAM</fullName>
        <actions>
            <name>Case_Pending_For_Review_Alert_LATAM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Maintenance Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.End_User_Account_Country_Region__c</field>
            <operation>equals</operation>
            <value>LATAM</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Sub status to Maintenance Investigated NA</fullName>
        <actions>
            <name>Case_Pending_For_Review_Alert_NA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Maintenance Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.End_User_Account_Country_Region__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Sub status to Maintenance Investigated end user null</fullName>
        <actions>
            <name>Case_Pending_For_Review_Alert_null</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Maintenance Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.End_User_Account_Country_Region__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Maintenance Created Owner</fullName>
        <actions>
            <name>Maintenance_Case_Created_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   (RecordType.DeveloperName = &apos;Genesys_Admin_Case&apos;),   AND (     (ISCHANGED(Sub_Status__c)),     (ISPICKVAL(Sub_Status__c, &apos;Maintenance Review&apos;))   ),   (NOT(ISBLANK(Maintenance_Owner__c))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Maintenance Created Queue</fullName>
        <actions>
            <name>Maintenance_Case_Created_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   (RecordType.DeveloperName = &apos;Genesys_Admin_Case&apos;),   AND (     (ISCHANGED(Sub_Status__c)),     (ISPICKVAL(Sub_Status__c, &apos;Maintenance Review&apos;))   ),   (ISBLANK(Maintenance_Owner__c)),   (NOT(ISBLANK(Maintenance_Queue_Email__c))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Maintenance Updated Owner</fullName>
        <actions>
            <name>Maintenance_Case_Updated_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   (RecordType.DeveloperName = &apos;Genesys_Admin_Case&apos;),   (ISPICKVAL(Sub_Status__c, &apos;Maintenance Review&apos;)),   (ISCHANGED(Last_Public_Case_Update_Description__c)),   (NOT(ISBLANK(Maintenance_Owner__c))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Maintenance Updated Queue</fullName>
        <actions>
            <name>Maintenance_Case_Updated_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   (RecordType.DeveloperName = &apos;Genesys_Admin_Case&apos;),   (ISPICKVAL(Sub_Status__c, &apos;Maintenance Review&apos;)),   (ISCHANGED(Last_Public_Case_Update_Description__c)),   (ISBLANK(Maintenance_Owner__c)),   (NOT(ISBLANK(Maintenance_Queue_Email__c))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A New Updates Flag</fullName>
        <actions>
            <name>Case_Check_New_Updates_Flg</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (
    (NOT($User.BypassWorkflows__c)),
        $User.Id != OwnerId,
        ISCHANGED(LastModifiedDate),
      NOT(ISCHANGED(New_Updates__c)),
      New_Updates__c = false,
      $User.Alias != &apos;ccare&apos;,
      $User.Alias != &apos;badmin&apos;
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A PSG notification-All</fullName>
        <actions>
            <name>Support_Customer_Care_PSG_Case_Assignment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_PSG_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notify the corresponding Product Support Group alias every time &quot;Assignment Status&quot; is changed to New, Please Reassign or Help</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp; (RecordType.Name =&apos;Support&apos; || RecordType.Name =&apos;Feature Request&apos; || BEGINS(RecordType.DeveloperName,&apos;Genesys_Cloud_&apos;)) &amp;&amp; ( ISNEW() || ISCHANGED( Product_Support_Group__c) ||   (ISCHANGED(Assignment_Status__c) &amp;&amp; (ISPICKVAL(Assignment_Status__c,&quot;NEW&quot;) || ISPICKVAL(Assignment_Status__c,&quot;Please Reassign or Help&quot;)) ) ||   (ISCHANGED(Sub_Status__c) &amp;&amp; ISPICKVAL(Sub_Status__c,&quot;Customer Requested to Re-open&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A PSG notification-Expert Help</fullName>
        <actions>
            <name>Support_Customer_Care_PSG_Expert_Help_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify to the person who is assigned as “Expert Help”</description>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp; ISCHANGED( Expert_Help__c )  &amp;&amp; NOT( ISBLANK(Expert_Help__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Case Alert</fullName>
        <actions>
            <name>Cloud_Case_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT($User.BypassWorkflows__c),
   OR(
    ISPICKVAL(Status, &apos;New&apos;),
    ISPICKVAL(Status, &apos;Open&apos;),    
    ISPICKVAL(Status, &apos;Solution Proposed&apos;)
     ),
    OR(
       CONTAINS(End_User_Account__r.Name, &apos;Starbucks Corporation&apos;),
       CONTAINS(End_User_Account__r.Name, &apos;Red Hat&apos;),
       CONTAINS(End_User_Account__r.Name, &apos;MedSynergies&apos;)


       )
   )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Case Creation</fullName>
        <actions>
            <name>Cloud_Case_Creation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Problem_Sub_Type__c</field>
            <operation>equals</operation>
            <value>Cloud Service Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Cloud_Offering__c</field>
            <operation>equals</operation>
            <value>Business/Enterprise Edition</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>DUPLICATE - Support %3A Tier 3 Status Update to Tier 3 Queue New</fullName>
        <actions>
            <name>Support_Tier_3_Status_To_Ti3_Queue_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>MCliffe: Naresh, I&apos;ve already got a rule for this - deactivating for the time being.</description>
        <formula>IF(  AND(  (NOT($User.BypassWorkflows__c)),  ISPICKVAL(Sub_Status__c, &apos;Tier 3&apos;),  NOT(ISPICKVAL(PRIORVALUE(Sub_Status__c), &apos;Tier 2&apos;)), NOT(ISPICKVAL(Tier_3_Status__c, &apos;Back to Tier 2 - Info Requested&apos;)) ), true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FR Case Change</fullName>
        <actions>
            <name>Feature_Request_Case_Change_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>FR Case Change</description>
        <formula>AND ( (NOT($User.BypassWorkflows__c)), (NOT(CONTAINS($Profile.Name, &quot;Portal&quot;))), OR
((ISPICKVAL(PRIORVALUE(Status), &quot;Open - Customer Care&quot;) &amp;&amp; ISPICKVAL(Status, &quot;Open - Product Management&quot;)), (ISPICKVAL(Status, &quot;Open - Product Management&quot;) &amp;&amp; ISCHANGED(Sub_Status__c)))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FR Case Update</fullName>
        <actions>
            <name>Feature_request_Case_Update</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND ( (NOT($User.BypassWorkflows__c)), 
CONTAINS( RecordType.DeveloperName , &quot;Feature&quot;),
NOT ISPICKVAL( Status, &quot;Closed&quot;),   
IF($User.Id != PMOwnerNew__c, true, false)
 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FR Case Update to Tier 3 Owner</fullName>
        <actions>
            <name>Support_New_Internal_Case_Update_on_Case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND (
  (NOT($User.BypassWorkflows__c)),
  IF($User.Id != Tier_3_Owner__c , true, false)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FR Due Date Nearing New</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Next_Update_Due__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>FR_Due_Date_nearing_Alert_for_7_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Next_Update_Due__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>FR_Due_Date_nearing_Alert_for_0_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Next_Update_Due__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>FR_Due_Date_nearing_Alert_before_14_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Next_Update_Due__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>FR Due Date nearing</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Next_Update_Due__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>FR_Due_Date_nearing_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Next_Update_Due__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>FR New%3A FR by RecType</fullName>
        <actions>
            <name>Email_to_Ginger</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cloud Feature Request,Feature Request</value>
        </criteriaItems>
        <description>notification to Ginger Alfron when a new Case with FR record type is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FR Support%3A Tier 3 Assigned to Open Product Management</fullName>
        <actions>
            <name>Support_Change_Status_to_Open_Prod</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Support_Next_Update_Due</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Support_PM_Engaged_ON</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>sub_status_to_new</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Tier_3_Status__c</field>
            <operation>equals</operation>
            <value>Assigned to Product Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FR Support%3A Update PM Engaged On %2B Due date</fullName>
        <actions>
            <name>Support_PM_Engaged_ON</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open - Product Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Feature Request Assignment</fullName>
        <actions>
            <name>Feature_Request_Assignment_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Feature Request Assignment.   This should alert the PM owner that new Feature requests is assigned to them.</description>
        <formula>AND(   (NOT($User.BypassWorkflows__c)),   ISCHANGED(PMOwnerNew__c),   PMOwnerNew__c &lt;&gt;$User.Id )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Feature Request Due Date nearing</fullName>
        <actions>
            <name>Feature_Request_Due_Date_nearing_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Feature Request Due Date nearing</description>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   OR(     IF(Next_Update_Due__c-TODAY() &lt;= 14, true, false),     IF(Next_Update_Due__c-TODAY() &lt;= 7, true, false),     IF( Next_Update_Due__c -  TODAY() = 0, true, false)   ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Feature Request Due Date nearing TDA</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.CaseNumber</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>this workflow is a time dependent workflow to execute Feature WF called Request Due Date nearing</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>FR_Due_Date_nearing_TDA_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Feature Request Due Date overdue</fullName>
        <actions>
            <name>Feature_Request_Due_Date_overdue_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Feature Request Due Date overdue</description>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   OR(     IF(       ISPICKVAL(Status,&quot;Closed&quot;),       true,       false),     if( TODAY() - Next_Update_Due__c&lt;0,       true,       false),     AND(       if( TODAY() - Next_Update_Due__c&gt;0,         true,         false),       ISPICKVAL(Status, &quot;Open – Product Management&quot;)     )   ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>High Priority</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Importance Score Updates</fullName>
        <active>false</active>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   ischanged( LastModifiedDate ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Feature Request</fullName>
        <actions>
            <name>New_Feature_Request_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>New Feature Request</description>
        <formula>And (   (NOT($User.BypassWorkflows__c)),   ISCHANGED(Status) ,   ISPICKVAL(Status, &quot;Open - Product Management&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New TS Case - Set Owner Unassigned</fullName>
        <actions>
            <name>New_TS_Case_Set_Owner_Unassigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 OR 3 OR 4 OR 6) AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>Cloud</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Feature Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>On-Premises Service Request</value>
        </criteriaItems>
        <description>Set Owner to queue Unassigned when a new Case is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Priority - Prod Down%2C Update Prod Down Flag</fullName>
        <actions>
            <name>Set_Prod_Down_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PureConnect MIM Engagement</fullName>
        <actions>
            <name>PureConnect_MIM_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Cloud_Platform__c</field>
            <operation>equals</operation>
            <value>PureConnect Cloud</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>When PureConnect Cloud case is set to Prod Down priority, email alert will go out to MIM team.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reset Sub-Status%2C Closure Category%2C and Closure Reason Code on Case</fullName>
        <actions>
            <name>Reset_Closure_Category</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Closure_Reason_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT($User.BypassWorkflows__c)) &amp;&amp; ISPICKVAL(PRIORVALUE (Status),  &quot;Closed&quot;) &amp;&amp; ISPICKVAL(Status , &quot;Open&quot;) &amp;&amp; NOT( ISPICKVAL(Sub_Status__c, &quot;&quot; ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Suppor%3A Tier 3%2FER Case Update</fullName>
        <actions>
            <name>Support_New_Internal_Case_Update_on_Case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will issue an update to the Tier 3 Owner is there is a case update on a case when the sub-status equals Tier 3 or ER.</description>
        <formula>AND (
  (NOT($User.BypassWorkflows__c)),
  OR(
    ISPICKVAL(Sub_Status__c, &quot;Tier 3&quot;),
    ISPICKVAL(Sub_Status__c, &quot;Engineering Request&quot;)
  ),
  ($User.Id != Tier_3_Owner__c)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support %3A APAC New Outage Case on High or Critical Case</fullName>
        <actions>
            <name>Support_APAC_New_Outage_Reported_on_Critical_Prod_Down_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>Prod Down</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Outage</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send email to Case owner of High or Critical case when new outage case is created against that case.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support %3A EMEA New Outage Case on High or Critical Case</fullName>
        <actions>
            <name>Support_EMEA_New_Outage_Reported_on_Critical_Prod_Down_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>Prod Down</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Outage</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send email to Case owner of High or Critical case when new outage case is created against that case.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support %3A Japan New Outage Case on High or Critical Case</fullName>
        <actions>
            <name>Support_Japan_New_Outage_Reported_on_Critical_Prod_Down_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>Prod Down</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Outage</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send email to Case owner of High or Critical case when new outage case is created against that case.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support %3A Latin American New Outage Case on High or Critical Case</fullName>
        <actions>
            <name>Support_North_American_New_Outage_Reported_on_Critical_Prod_Down_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>Prod Down</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Outage</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send email to Case owner of High or Critical case when new outage case is created against that case.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support %3A North American New Outage Case on High or Critical Case</fullName>
        <actions>
            <name>Support_North_American_New_Outage_Reported_on_Critical_Prod_Down_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>Prod Down</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Parent_Priority__c</field>
            <operation>equals</operation>
            <value>1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Outage</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send email to Case owner of High or Critical case when new outage case is created against that case.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A AF - Critical Priority Cases</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Critical_Third_Follow_up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_High</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Critical_Second_Follow_up</name>
                <type>Task</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Critical_First_Follow_up</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Critical Priority Cases - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up Blocked Until process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Critical_Third_Follow_up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_High</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Critical_First_Follow_up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Critical_Second_Follow_up</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Friday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Friday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Friday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Friday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up Blocked Until process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Monday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Monday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Monday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Monday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up Blocked Until process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Thursday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Thursday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Thursday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Thursday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Tuesday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Tuesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Tuesday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Tuesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Wednesday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Wednesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Awaiting Info Status Cases - Wednesday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Wednesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Friday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Friday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Friday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Friday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Monday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Monday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Monday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Monday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Thursday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Thursday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Thursday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Thursday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Tuesday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Tuesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Tuesday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Tuesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Wednesday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Wednesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - High Priority Solution Proposed Status Cases - Wednesday -BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Wednesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Priority_to_Medium</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Friday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Friday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Friday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Friday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Monday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Monday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Monday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Monday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Thursday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Thursday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Thursday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Thursday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Tuesday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Tuesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Tuesday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Tuesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Wednesday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Wednesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Awaiting Info Status Cases - Wednesday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Wednesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Awaiting_Info_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Friday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Friday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Friday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Friday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Monday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Monday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Monday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Monday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Thursday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Thursday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Thursday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Thursday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>High_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Tuesday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Tuesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Tuesday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Tuesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Wednesday</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week__c</field>
            <operation>equals</operation>
            <value>Wednesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A AF - Medium and Low Priority Solution Proposed Status Cases - Wednesday - BD</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>3-Medium,4-Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up_Until__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Day_of_Week_Block_Auto_Follow_Up_Until__c</field>
            <operation>equals</operation>
            <value>Wednesday</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used for the Auto follow-up process.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_First_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Second_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Medium_and_Low_Priority_Solution_Proposed_Status_Third_Follow_Up</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Close_the_Case</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Do_Not_Auto_Follow_Up_Until__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A APAC Tech Lead Case Assigned</fullName>
        <actions>
            <name>Support_APAC_Tech_Lead_Case_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow rule will fire whenever the case is assigned to a Tech Lead engineer.</description>
        <formula>AND(   (NOT($User.BypassWorkflows__c)),   ISCHANGED( Tech_Lead_Status__c ) ,   ISPICKVAL(Tech_Lead_Status__c, &quot;Tech Lead Queue&quot;) ,   ISPICKVAL( Owner_Support_Group__c , &quot;APAC&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Back to Tier 2 - Tier 2</fullName>
        <actions>
            <name>Support_Tier_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will fire when a case is reassigned to Tier 3 from Tier 2.</description>
        <formula>AND (   (NOT($User.BypassWorkflows__c)), IF(  AND(     ISCHANGED(Tier_3_Status__c),    OR(       ISPICKVAL(Tier_3_Status__c, &apos;Back to Tier 2 - Info Requested&apos;),        ISPICKVAL(Tier_3_Status__c, &apos;Back to Tier 2 - Solution Proposed&apos;))    ), true, false) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Case Closed</fullName>
        <actions>
            <name>Case_Closed_Notification_to_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow will fire whenever a case is closed.</description>
        <formula>AND( NOT($User.BypassWorkflows__c),       ISPICKVAL(Status, &quot;Closed&quot;),      ISCHANGED(Status),  OR (RecordType.DeveloperName = &quot;Genesys_Admin_Case&quot;,   (AND((RecordType.DeveloperName = &quot;Genesys_Product_Case&quot; || RecordType.DeveloperName = &quot;Premises_Service_Request&quot;),  NOT(ISBLANK(End_User_Account__c )))))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Case Closed - Cloud</fullName>
        <actions>
            <name>Case_Closed_Notification_to_Owner_Cloud</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow will fire whenever a Cloud Case is closed.</description>
        <formula>AND( NOT($User.BypassWorkflows__c),      BEGINS(RecordType.DeveloperName, &quot;Genesys_Cloud_&quot; ),      ISPICKVAL(Status, &quot;Closed&quot;),     ISCHANGED(Status),     NOT ISBLANK(End_User_Account__c)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Case First Created</fullName>
        <actions>
            <name>Support_Case_Created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>The following workflow rule will trigger when the case is first inserted into the database.</description>
        <formula>AND (NOT($User.BypassWorkflows__c),       OR (RecordType.Name = &quot;Admin&quot;,  (AND((RecordType.Name = &quot;Support&quot; || RecordType.Name = &quot;Feature Request&quot;), NOT(ISBLANK(End_User_Account__c ))))) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Case First Created - Cloud</fullName>
        <actions>
            <name>Support_Case_Created_Cloud</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>The following workflow rule will trigger when the Cloud case is first inserted into the database.</description>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),         BEGINS(RecordType.DeveloperName, &quot;Genesys_Cloud_&quot; ),        NOT(ISBLANK( End_User_Account__c ))  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Case Set to 3rd Party Pending</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Third Party Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire when we assign a case with the sub-status of third party pending</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Critical Proposed Solution Follow-up</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Critical_First_Follow_up</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Critical_Second_Follow_up</name>
                <type>Task</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Critical_Third_Follow_up</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support%3A Critical Proposed Solution Follow-up 1</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Auto_Follow_Up__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Customer Care - Tier 3 Case Assignment</fullName>
        <actions>
            <name>Support_Customer_Care_Tier_3_Case_Assignment</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   OR (     (RecordType.Name = &apos;Support&apos;)     ,(RecordType.Name = &apos;Feature Request&apos;)   )   ,(ISPICKVAL(Sub_Status__c, &apos;Tier 3&apos;))   ,(NOT(ISBLANK(Tier_3_Queue_Email__c)))   ,OR (     AND (       (ISCHANGED(Tier_3_Status__c))       ,OR (         (ISPICKVAL(Tier_3_Status__c, &apos;Tier 3 Queue - New&apos;))         ,(ISPICKVAL(Tier_3_Status__c, &apos;Tier 3 Queue - Returning&apos;))       )     )     ,AND (       (ISCHANGED(Tier_3_Queue__c))       ,(ISCHANGED(Tier_3_Queue_Email__c))     )   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A EMEA Tech Lead Case Assigned</fullName>
        <actions>
            <name>Support_EMEA_Tech_Lead_Case_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow rule will fire whenever the case is assigned to a Tech Lead engineer.</description>
        <formula>AND(   (NOT($User.BypassWorkflows__c)),   ISCHANGED( Tech_Lead_Status__c ) ,   ISPICKVAL(Tech_Lead_Status__c, &quot;Tech Lead Queue&quot;) ,   ISPICKVAL( Owner_Support_Group__c , &quot;EMEA&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Engineering Engaged</fullName>
        <actions>
            <name>Support_Set_sub_status_to_ER</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Tier_3_Status__c</field>
            <operation>equals</operation>
            <value>R&amp;D Engaged - Issue Reported,R&amp;D Engaged - Waiting For Fix,R&amp;D Engaged - Consultation,R&amp;D Engaged - Scheduled for Release</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire when a case is sent to engineering by a Tier 3 agent.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Japan Tech Lead Case Assigned</fullName>
        <actions>
            <name>Support_Japan_Tech_Lead_Case_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow rule will fire whenever the case is assigned to a Tech Lead engineer.</description>
        <formula>AND(   (NOT($User.BypassWorkflows__c)),   ISCHANGED( Tech_Lead_Status__c ) ,   ISPICKVAL(Tech_Lead_Status__c, &quot;Tech Lead Queue&quot;) ,   ISPICKVAL( Owner_Support_Group__c , &quot;Japan&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Latin America Tech Lead Case Assigned</fullName>
        <actions>
            <name>Support_Latin_America_Tech_Lead_Case_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow rule will fire whenever the case is assigned to a Tech Lead engineer.</description>
        <formula>AND(   (NOT($User.BypassWorkflows__c)),   ISCHANGED( Tech_Lead_Status__c ) ,   ISPICKVAL(Tech_Lead_Status__c, &quot;Tech Lead Queue&quot;) ,   ISPICKVAL( Owner_Support_Group__c , &quot;Latin America&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A New Escalation to Tier 3</fullName>
        <actions>
            <name>Support_Case_Assignation</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Support_Set_Tier_3_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Support_Tier_3_Status_To_Ti3_Queue_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Tier 3</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Tier_3_Owner__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Tier_3_Status__c</field>
            <operation>notEqual</operation>
            <value>Back to Tier 2 - Info Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Tier_3_Status__c</field>
            <operation>notEqual</operation>
            <value>Tier 3 Queue - Returning</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire whenever the case is escalated to Tier 3.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A New Public Care Case Update</fullName>
        <actions>
            <name>Support_New_public_case_comment</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will fire whenever a new public case update is made by Customer Care to a customer.</description>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   ISCHANGED(Last_Public_Care_Update__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A North America Tech Lead Case Assigned</fullName>
        <actions>
            <name>Support_North_America_Tech_Lead_Case_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow rule will fire whenever the case is assigned to a Tech Lead engineer.</description>
        <formula>AND(   (NOT($User.BypassWorkflows__c)),   ISCHANGED( Tech_Lead_Status__c ) ,   ISPICKVAL(Tech_Lead_Status__c, &quot;Tech Lead Queue&quot;) ,   ISPICKVAL( Owner_Support_Group__c , &quot;North America&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify APAC Support Manager 1st Response Approaching Target</fullName>
        <actions>
            <name>Support_APAC_1st_Response_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_First_Response__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify APAC Support Managers that 1st Response is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify APAC Support Manager New Prod Down or Critical Case</fullName>
        <actions>
            <name>Support_Notify_APAC_Management_about_Prod_down_Critical_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify APAC Support Managers that a new Prod Down or Critical Case has been created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify APAC Support Manager Outage Restore Breached</fullName>
        <actions>
            <name>Support_Notify_APAC_Management_Outage_SLA_Breached</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Violation_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify APAC Support Managers that Outage Restore is breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify APAC Support Manager Outage Restore Nearing SLA</fullName>
        <actions>
            <name>Support_Notify_APAC_Management_Outage_SLA_approach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Nearing_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify APAC Support Managers that Outage Restore is approaching SLA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify APAC Support Manager Resolution Approaching Target</fullName>
        <actions>
            <name>Support_APAC_Resolution_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_Resolution_Target__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify APAC Support Managers that Resolution milestone is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify APAC Support Manager Resolution Target Breached</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Resolution_Target_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify APAC Support Managers that Resolution target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify APAC Support Manager Response Target Breached</fullName>
        <actions>
            <name>Support_APAC_1st_Response_Target_Breach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_First_Response_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify APAC Support Managers that Response target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify APAC Support Manager Update to Priority Prod Down or Critical Case</fullName>
        <actions>
            <name>Support_Notify_APAC_Management_about_Priority_change_Prod_down_Critical_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify APAC Support Managers that a new Prod Down or Critical Case has been created</description>
        <formula>(NOT($User.BypassWorkflows__c)) &amp;&amp; ISPICKVAL(Owner_Support_Group__c, &quot;APAC&quot;) &amp;&amp; ischanged(Priority) &amp;&amp; case(Priority,&quot;Prod Down&quot;,1,&quot;1-Critical&quot;,1,0) = 1 &amp;&amp; not(isnew())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify EMEA Support Manager 1st Response Approaching Target</fullName>
        <actions>
            <name>Support_EMEA_1st_Response_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_First_Response__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify EMEA Support Managers that 1st Response is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify EMEA Support Manager Outage Approaching Target</fullName>
        <actions>
            <name>Support_Notify_EMEA_Management_Outage_SLA_approach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Nearing_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify EMEA Support Managers that Outage SLA is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify EMEA Support Manager Outage Breached</fullName>
        <actions>
            <name>Support_Notify_EMEA_Management_Outage_SLA_breached</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Violation_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify EMEA Support Managers that Outage SLA is breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify EMEA Support Manager Prod Down or Critical New Case</fullName>
        <actions>
            <name>Support_Notify_EMEA_Management_about_Prod_down_Critical_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify EMEA Support Managers that a new Prod down or Critical case has been created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify EMEA Support Manager Resolution Approaching Target</fullName>
        <actions>
            <name>Support_EMEA_Resolution_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_Resolution_Target__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify EMEA Support Managers that Resolution milestone is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify EMEA Support Manager Resolution Target Breached</fullName>
        <actions>
            <name>Support_EMEA_Resolution_Target_Breached</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Resolution_Target_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify EMEA Support Managers that Resolution target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify EMEA Support Manager Response Target Breached</fullName>
        <actions>
            <name>Support_EMEA_1st_Response_Target_Breached</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_First_Response_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify EMEA Support Managers that Response target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify EMEA Support Manager Update to Priority Prod Down or Critical New Case</fullName>
        <actions>
            <name>Support_Notify_EMEA_Management_about_Priority_change_Prod_down_Critical_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify EMEA Support Managers that a priority update Prod down or Critical case has been created</description>
        <formula>(NOT($User.BypassWorkflows__c)) &amp;&amp; ISPICKVAL(Owner_Support_Group__c, &quot;EMEA&quot;) &amp;&amp; ischanged(Priority) &amp;&amp; case(Priority,&quot;Prod Down&quot;,1,&quot;1-Critical&quot;,1,0) = 1 &amp;&amp; not(isnew())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Japan Support Manager 1st Response Approaching Target</fullName>
        <actions>
            <name>Support_Japan_1st_Response_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_First_Response__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Japan Support Managers that 1st Response is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Japan Support Manager Outage Approaching Target</fullName>
        <actions>
            <name>Support_Notify_Japan_Management_Outage_SLA_approach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Nearing_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Japan Support Managers that Outage SLA is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Japan Support Manager Outage Breached</fullName>
        <actions>
            <name>Support_Notify_Japan_Management_Outage_SLA_Breach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Violation_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Japan Support Managers that Outage SLA is breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Japan Support Manager Resolution Approaching Target</fullName>
        <actions>
            <name>Support_Japan_Resolution_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_Resolution_Target__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Japan Support Managers that Resolution milestone is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Japan Support Manager Resolution Target Breached</fullName>
        <actions>
            <name>Support_Japan_Resolution_Target_Breached</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Resolution_Target_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Japan Support Managers that Resolution target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Japan Support Manager Response Target Breached</fullName>
        <actions>
            <name>Support_Japan_1st_Response_Target_Breached</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_First_Response_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Japan Support Managers that Response target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Japan Support Manager of Priority Update prod down or critical new case</fullName>
        <actions>
            <name>Support_Notify_Japan_Management_about_Priority_change_Prod_down_Critical_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Japan Support Managers that a prod down or critical priority update on a case has been created</description>
        <formula>(NOT($User.BypassWorkflows__c)) &amp;&amp; ISPICKVAL(Owner_Support_Group__c, &quot;Japan&quot;)  &amp;&amp; ischanged(Priority) &amp;&amp; case(Priority,&quot;Prod Down&quot;,1,&quot;1-Critical&quot;,1,0) = 1 &amp;&amp; not(isnew())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Japan Support Manager prod down or critical new case</fullName>
        <actions>
            <name>Support_Notify_Japan_Management_about_Prod_down_Critical_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Japan Support Managers that a prod down or critical new case has been created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Latin America Support Manager 1st Response Approaching Target</fullName>
        <actions>
            <name>Support_Latin_America_1st_Response_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_First_Response__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Latin America Support Managers that 1st Response is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Latin America Support Manager Outage Approaching Target</fullName>
        <actions>
            <name>Support_Notify_Latin_America_Management_Outage_SLA_approach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Nearing_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Latin America Support Managers that Outage is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Latin America Support Manager Outage Breached</fullName>
        <actions>
            <name>Support_Notify_Latin_America_Management_Outage_SLA_Breach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Violation_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Latin America Support Managers that Outage is breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Latin America Support Manager Priority Change for Prod or Critical Case</fullName>
        <actions>
            <name>Support_Notify_Latin_America_Management_about_Priority_change_Prod_down_Critical</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Latin America Support Managers that a priority change has happened on a Critical or Prod down case</description>
        <formula>(NOT($User.BypassWorkflows__c)) &amp;&amp; ISPICKVAL(Owner_Support_Group__c, &quot;Latin America&quot;) &amp;&amp;  ischanged(Priority) &amp;&amp; case(Priority,&quot;Prod Down&quot;,1,&quot;1-Critical&quot;,1,0) = 1 &amp;&amp; not(isnew())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Latin America Support Manager Prod or Critical Case</fullName>
        <actions>
            <name>Support_Notify_Latin_America_Management_about_Prod_down_Critical_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Latin America Support Managers that a new Critical or Prod down case has been created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Latin America Support Manager Resolution Approaching Target</fullName>
        <actions>
            <name>Support_Latin_America_Resolution_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_Resolution_Target__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Latin America Support Managers that Resolution milestone is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Latin America Support Manager Resolution Target Breached</fullName>
        <actions>
            <name>Support_Latin_America_Resolution_Target_Breached</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Resolution_Target_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Latin America Support Managers that Resolution target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Latin America Support Manager Response Target Breached</fullName>
        <actions>
            <name>Support_Latin_America_1st_Response_Target_Breached</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_First_Response_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify Latin America Support Managers that Response target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify North America Support Manager 1st Response Approaching Target</fullName>
        <actions>
            <name>Support_North_America_1st_Response_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_First_Response__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify North America Support Managers that 1st Response is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify North America Support Manager Outage Approaching Target</fullName>
        <actions>
            <name>Support_Notify_North_America_Management_Outage_SLA_approach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Nearing_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify North America Support Managers that outage is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify North America Support Manager Outage Breached</fullName>
        <actions>
            <name>Support_Notify_North_America_Management_Outage_SLA_Breach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Outage_Restore_Violation_SLA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify North America Support Managers that outage is breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify North America Support Manager Priority Update Prod Down or Critical Case</fullName>
        <actions>
            <name>Support_Notify_North_America_Management_about_Priority_change_Prod_down_Critical</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify North America Support Managers that a case of type Prod Down or Critical has been created</description>
        <formula>(NOT($User.BypassWorkflows__c)) &amp;&amp; ISPICKVAL(Owner_Support_Group__c, &quot;North America&quot;) &amp;&amp; ischanged(Priority) &amp;&amp; case(Priority,&quot;Prod Down&quot;,1,&quot;1-Critical&quot;,1,0) = 1 &amp;&amp; not(isnew())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify North America Support Manager Prod Down or Critical Case</fullName>
        <actions>
            <name>Support_Notify_North_America_Management_about_Prod_down_Critical_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify North America Support Managers that a case of type Prod Down or Critical has been created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify North America Support Manager Resolution Approaching Target</fullName>
        <actions>
            <name>Support_North_America_Resolution_Approaching_Target</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Approaching_Resolution_Target__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify North America Support Managers that Resolution milestone is approaching target</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify North America Support Manager Resolution Target Breached</fullName>
        <actions>
            <name>Support_North_America_Resolution_Target_Breached</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_Resolution_Target_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Prod Down,2-High,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify North America Support Managers that Resolution target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify North America Support Manager Response Target Breached</fullName>
        <actions>
            <name>Support_North_America_1st_Response_Target_Breach</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Owner_Support_Group__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Workflow_First_Response_Breached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>2-High,Prod Down,1-Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify North America Support Managers that Response target breached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify Owner of Updates to Critical Cases</fullName>
        <actions>
            <name>Support_Notify_Owner_of_Update_on_Critical_Case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateModifiedTime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow rule will notify the owner if there has been updates made to a critical case.</description>
        <formula>AND(   (NOT($User.BypassWorkflows__c)),  $User.Alias != &apos;badmin&apos;, NOT(BEGINS( OwnerId , &quot;00G&quot;)) ,    OR( ISPICKVAL(Priority, &quot;1-Critical&quot;), ISPICKVAL(Priority, &quot;Prod Down&quot;) ),              ISCHANGED( LastModifiedDate ),              $User.Id !=  OwnerId , or( isnull(Date_Modified__c), LastModifiedDate -   Date_Modified__c  &gt; 0.0001) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Notify new rep of Critical Case assignment</fullName>
        <actions>
            <name>Support_Notify_new_owner_of_Critical_case_reassignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>used to notify new case owner of new critical case</description>
        <formula>(NOT($User.BypassWorkflows__c)) &amp;&amp; ischanged( OwnerId ) &amp;&amp; left(OwnerId,3)=&quot;005&quot; &amp;&amp; not(isnew()) &amp;&amp; case(Priority,&quot;Prod Down&quot;,1,&quot;1-Critical&quot;,1,0) = 1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Portal Admin Case Created</fullName>
        <actions>
            <name>Support_Assign_to_Tier_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Support_Set_Origin_To_Web</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Customer Portal Manager,Customer Portal User,High Volume Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire when an Admin case has been created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Portal Product Case Created</fullName>
        <actions>
            <name>Set_sub_status_to_New</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Support_Set_Origin_To_Web</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Feature Request,Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Customer Portal User,Customer Portal Manager,High Volume Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire when a case has been created from the portal.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Returning Escalation to Tier 3</fullName>
        <actions>
            <name>Support_Tier_3_Status_T3_Queue_Returning</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will fire whenever the case is escalated to Tier 3.</description>
        <formula>AND (   (NOT($User.BypassWorkflows__c))   ,(ISCHANGED(Sub_Status__c))   ,(ISPICKVAL(Sub_Status__c, &apos;Tier 3&apos;))   ,(NOT(ISBLANK(Tier_3_Owner__c)))   ,(NOT(ISPICKVAL(Tier_3_Status__c, &apos;Tier 3 Queue - Returning&apos;))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Returning Escalation to Tier 3 Deactivated</fullName>
        <actions>
            <name>Support_Returning_Escalation_to_Tier_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Tier 3</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Tier_3_Status__c</field>
            <operation>equals</operation>
            <value>Back to Tier 2 - Solution Proposed,Back to Tier 2 - Info Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire whenever the case is returned to Tier 3.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Start Entitlement Process When Not Awaiting Info or Solution Proposed</fullName>
        <actions>
            <name>Support_Unpause_SLA_Clock</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Awaiting Info,Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This rule will start the entitlement process for cases when status is not Awaiting Info/Solution Suggested</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Stop Entitlement Process When Awaiting Info</fullName>
        <actions>
            <name>Support_Pause_SLA_Clock</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Info,Solution Proposed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This rule will stop the entitlement process for premium cases when status is Awaiting Info or Solution Proposed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Sub Status T2 to T3 - T3 Substatus to T3 Queue Returning</fullName>
        <actions>
            <name>Support_Tier_3_Status_T3_Queue_Returning</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND (   (NOT($User.BypassWorkflows__c)), IF( AND(           ISPICKVAL(Sub_Status__c, &apos;Tier 3&apos;),           ISPICKVAL(PRIORVALUE(Sub_Status__c),  &apos;Tier 2&apos;) ), true, false) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Tech Lead Case Assigned</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Tech_Lead_Status__c</field>
            <operation>equals</operation>
            <value>Tech Lead Assigned</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire whenever the case is assigned to a Tech Lead engineer.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Tier 3 Case Assigned</fullName>
        <actions>
            <name>Support_Case_Assignation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Tier 3</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Tier_3_Status__c</field>
            <operation>equals</operation>
            <value>Tier 3 Assigned</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Feature Request,Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Tier_3_Owner__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire whenever the case is assigned to a Tier 3 engineer.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Tier 3 Status to Tier-3 Asigned</fullName>
        <actions>
            <name>Support_Sub_Status_to_Tier_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Tier_3_Status__c</field>
            <operation>equals</operation>
            <value>Tier 3 Assigned</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Unauthorised Escalations</fullName>
        <actions>
            <name>Support_Bounce_Unauthorised_Email_Escalations</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Support_Close_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.rules_unauthorised_escalation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire when an escalation is received from an unauthorised email domain.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TS Case Contact Update</fullName>
        <actions>
            <name>Case_Populate_Alternate_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>populate alternate email field when contact on a case has been updated</description>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp;
OR ( ISNEW(), ISCHANGED(Contact_PIN__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Sub Status Change Date%2FTime</fullName>
        <actions>
            <name>Update_Sub_Status_Change_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   ISCHANGED(Sub_Status__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Close_the_Case</fullName>
        <assignedToType>owner</assignedToType>
        <description>The 3rd follow-up has been sent. Please close the case.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Close the Case</subject>
    </tasks>
    <tasks>
        <fullName>Critical_Second_Follow_up</fullName>
        <assignedToType>owner</assignedToType>
        <description>There has been no update from the customer within the past 3 days.
Call the primary contact for this case and negotiate the current priority of the case and when the requested information will be provided.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.Date_Modifiedx__c</offsetFromField>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Critical Second Follow-up</subject>
    </tasks>
    <tasks>
        <fullName>Support_Task_for_Milestone_is_Breached</fullName>
        <assignedToType>owner</assignedToType>
        <description>Response Milestone has been breached. Please follow up with the Case.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Support: Task for Milestone is Breached</subject>
    </tasks>
</Workflow>
