<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AppFoundry_Email_Alert</fullName>
        <description>AppFoundry Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>liam.clifford@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/AppFoundry_Win_Notification</template>
    </alerts>
    <alerts>
        <fullName>AppFoundry_Email_Alert_for_APAC_AE</fullName>
        <description>AppFoundry Opportunity Closed Won - APAC - AE</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/AppFoundry_Opportunity_Closed_Won_APAC_html_AE</template>
    </alerts>
    <alerts>
        <fullName>AppFoundry_Email_Alert_for_APAC_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <description>AppFoundry Opportunity Closed Won - APAC - All</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/AppFoundry_Opportunity_Closed_Won_APAC_html_All</template>
    </alerts>
    <alerts>
        <fullName>AppFoundry_Email_Alert_for_EMEA_AE</fullName>
        <description>AppFoundry Opportunity Closed Won - EMEA - AE</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/AppFoundry_Opportunity_Closed_Won_EMEA_html_AE</template>
    </alerts>
    <alerts>
        <fullName>AppFoundry_Email_Alert_for_EMEA_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <description>AppFoundry Opportunity Closed Won - EMEA - All</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/AppFoundry_Opportunity_Closed_Won_EMEA_html_All</template>
    </alerts>
    <alerts>
        <fullName>AppFoundry_Email_Alert_for_LATAM_AE</fullName>
        <description>AppFoundry Opportunity Closed Won - LATAM - AE</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/AppFoundry_Opportunity_Closed_Won_LATAM_html_AE</template>
    </alerts>
    <alerts>
        <fullName>AppFoundry_Email_Alert_for_LATAM_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <description>AppFoundry Opportunity Closed Won - LATAM - All</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/AppFoundry_Opportunity_Closed_Won_LATAM_html_All</template>
    </alerts>
    <alerts>
        <fullName>AppFoundry_Email_Alert_for_NA_AE</fullName>
        <description>AppFoundry Opportunity Closed Won - NA - AE</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/AppFoundry_Opportunity_Closed_Won_NA_html_AE</template>
    </alerts>
    <alerts>
        <fullName>AppFoundry_Email_Alert_for_NA_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <description>AppFoundry Opportunity Closed Won - NA - All</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/AppFoundry_Opportunity_Closed_Won_NA_html_All</template>
    </alerts>
    <alerts>
        <fullName>Booked_Opportunity_Needing_to_be_closed</fullName>
        <description>Booked Opportunity Needs to be closed</description>
        <protected>false</protected>
        <recipients>
            <recipient>liam.clifford@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Booked_Opportunity_Needing_to_be_closed</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_EUA_New_Logo_APAC</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won EUA New Logo APAC</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloud_EUA_New_logo_APAC_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_EUA_New_Logo_EMEA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won EUA New Logo EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloud_EUA_New_logo_EMEA_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_EUA_New_Logo_LATAM</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won EUA New Logo LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloud_EUA_New_logo_LATAM_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_EUA_New_Logo_NA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won EUA New Logo NA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloud_EUA_New_logo_NA_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_TCV_APAC</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won TCV APAC</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Opportunity_Closed_Won_TCV_APAC_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_TCV_EMEA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won TCV EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Opportunity_Closed_Won_TCV_EMEA_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_TCV_LATAM</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won TCV LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Opportunity_Closed_Won_TCV_LATAM_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_TCV_NA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won TCV NA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Opportunity_Closed_Won_TCV_NA_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_TCV_NEW_TestEmailAlert</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won TCV NEW-TestEmailAlert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Win_Announcements_Updated_2018/Cloud_Opportunity_Closed_Won_TCV_NEW</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_TCV_NewLogo_APAC_html</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won TCV New Logo APAC</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Opportunity_Closed_Won_TCV_NewLogo_APAC_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_TCV_NewLogo_EMEA_html</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won TCV New Logo EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Opportunity_Closed_Won_TCV_NewLogo_EMEA_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_TCV_NewLogo_LATAM_html</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won TCV New Logo LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Opportunity_Closed_Won_TCV_NewLogo_LATAM_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Opportunity_Closed_Won_TCV_NewLogo_NA_html</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won TCV New Logo NA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Opportunity_Closed_Won_TCV_NewLogo_NA_html</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Renewal_Opps_with_Forecast_Status_Booked</fullName>
        <description>Cloud Renewal Opps with Forecast Status Booked</description>
        <protected>false</protected>
        <recipients>
            <field>CSM_GA_Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/Opp_FC_Status_Booked</template>
    </alerts>
    <alerts>
        <fullName>Email_Template_for_APAC</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Opportunity Closed Won - APAC</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_APAC_html</template>
    </alerts>
    <alerts>
        <fullName>Email_Template_for_EMEA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Opportunity Closed Won - EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_EMEA_html</template>
    </alerts>
    <alerts>
        <fullName>Email_Template_for_LATAM</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Opportunity Closed Won - LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_LATAM_html</template>
    </alerts>
    <alerts>
        <fullName>Expired_Opportunity</fullName>
        <description>Expired Opportunity</description>
        <protected>false</protected>
        <recipients>
            <recipient>liam.clifford@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Expired_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Keep_the_telesales_inform_about_the_refused_oppty</fullName>
        <description>Keep the telesales inform about the refused oppty</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ALU_E_Sales_Oppty_Assignation/ALU_E_Template_Email_Oppty_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Keepthetelesalesinformed</fullName>
        <description>Keep the telesales inform about the accepted oppty</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ALU_E_Sales_Oppty_Assignation/ALU_E_Template_Email_Oppty_Acceptance</template>
    </alerts>
    <alerts>
        <fullName>LDR_Closed_Lost_Opp</fullName>
        <description>LDR Closed Lost Opp</description>
        <protected>false</protected>
        <recipients>
            <field>LeadDevelopmentRep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/LDR_Closed_Lost_Opp</template>
    </alerts>
    <alerts>
        <fullName>MKTG_5_Days_Before_Oppt_Close_Date</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - 5 Days Before Oppt Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>eric.orton@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_Reminder_5_Days_Before_Oppt_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>MKTG_APAC_Stalled_Oppt_Alert_14_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - APAC Stalled Oppt Alert 14 Days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_14_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_APAC_Stalled_Oppt_Alert_21_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - APAC Stalled Oppt Alert 21 Days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_21_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_APAC_Stalled_Oppt_Alert_28_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - APAC Stalled Oppt Alert 28 Days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>bruce.eidsvik@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_28_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_APAC_Stalled_Oppt_Alert_35_days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - APAC Stalled Oppt Alert 35 days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>bruce.eidsvik@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tom.eggemeier@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_35_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_EMEA_Stalled_Oppt_Alert_14_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - EMEA Stalled Oppt Alert 14 Days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_14_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_EMEA_Stalled_Oppt_Alert_21_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - EMEA Stalled Oppt Alert 21 Days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_21_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_EMEA_Stalled_Oppt_Alert_28_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - EMEA Stalled Oppt Alert 28 Days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>mark.turner@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_28_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_EMEA_Stalled_Oppt_Alert_35_days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - EMEA Stalled Oppt Alert 35 days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>mark.turner@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tom.eggemeier@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_35_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_LATAM_Stalled_Oppt_Alert_14_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - LATAM Stalled Oppt Alert 14 Days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_14_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_LATAM_Stalled_Oppt_Alert_21_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - LATAM Stalled Oppt Alert 21 Days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_21_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_LATAM_Stalled_Oppt_Alert_28_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - LATAM Stalled Oppt Alert 28 Days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>john.carr@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_28_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_LATAM_Stalled_Oppt_Alert_35_days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - LATAM Stalled Oppt Alert 35 days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>john.carr@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tom.eggemeier@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_35_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_North_America_Stalled_Oppt_Alert_14_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - North America Stalled Oppt Alert 14 Days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_14_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_North_America_Stalled_Oppt_Alert_21_Days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - North America Stalled Oppt Alert 21 Days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_21_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_North_America_Stalled_Oppt_Alert_28_days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - North America Stalled Oppt Alert 28 days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>richard.brown@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_28_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_North_America_Stalled_Oppt_Alert_35_days</fullName>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - North America Stalled Oppt Alert 35 days</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>richard.brown@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tom.eggemeier@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_35_Day_Stalled_Oppt</template>
    </alerts>
    <alerts>
        <fullName>MKTG_Reminder_1_Day_Past_Oppt_Close_Date</fullName>
        <ccEmails>Brian.Jonkman@Genesys.com</ccEmails>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - Reminder - 1 Day Past Oppt Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>brian.jonkman@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_Reminder_1_Day_Past_Oppt_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>MKTG_Reminder_1_Days_Past_Oppt_Close_Date</fullName>
        <ccEmails>Peter.Segre@genesys.com</ccEmails>
        <description>MKTG - Reminder - 1 Day Past Oppt Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/MKTG_Reminder_1_Day_Past_Oppt_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>MKTG_Reminder_Opportunity_14_Days_Past_Close_Date</fullName>
        <ccEmails>Brian.Jonkman@Genesys.com</ccEmails>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - Reminder - Opportunity 14 Days Past Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LeadDevelopmentRep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>brian.jonkman@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_Reminder_14_Days_Past_Oppt_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>MKTG_Reminder_Opportunity_7_Days_Past_Close_Date</fullName>
        <ccEmails>Brian.Jonkman@Genesys.com</ccEmails>
        <ccEmails>marketingoperations@genesys.com</ccEmails>
        <description>MKTG - Reminder - Opportunity 7 Days Past Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>brian.jonkman@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_Reminder_7_Days_Past_Oppt_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>MKTG_Return_to_Nurture</fullName>
        <description>MKTG - Return to Nurture</description>
        <protected>false</protected>
        <recipients>
            <recipient>annemiek.van_der_kolk@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eileen.chua@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>heidi.parcell@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>marketo@genesyslab.com.marketo</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>russell.foster@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>LeadDevelopmentRep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>eric.orton@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_Return_to_Nurture</template>
    </alerts>
    <alerts>
        <fullName>Marketing_Sourced_Opportunity_Notification</fullName>
        <description>Marketing Sourced Opportunity Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Marketing_ALL</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>barbara.gonzalez@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/Marketing_Sourced_Opp_Notification_HTML</template>
    </alerts>
    <alerts>
        <fullName>New_Cloud_Renewal_Opportunity_Direct</fullName>
        <description>New Cloud Renewal Opportunity Direct</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>navaneetha.krishnan@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>cloudrenewals@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cloud_Renewal_Email_Template/Creation_of_Renewal_Opportunity_Direct</template>
    </alerts>
    <alerts>
        <fullName>New_Cloud_Renewal_Opportunity_Direct_PCC</fullName>
        <description>New Cloud Renewal Opportunity Direct-PureConnect Cloud</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>navaneetha.krishnan@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cloud_Renewal_Email_Template/Renewal_Opp_for_Direct_Customers_PCC</template>
    </alerts>
    <alerts>
        <fullName>New_Cloud_Renewal_Opportunity_Direct_PEC</fullName>
        <description>New Cloud Renewal Opportunity Direct-PureEngage Cloud</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>navaneetha.krishnan@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cloud_Renewal_Email_Template/Renewal_Opportunity_Direct_PECloud</template>
    </alerts>
    <alerts>
        <fullName>New_Cloud_Renewal_Opportunity_Indirect</fullName>
        <description>New Cloud Renewal Opportunity Indirect</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Sold_To_Business_Partner_Mail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>navaneetha.krishnan@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>cloudrenewals@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cloud_Renewal_Email_Template/Temp_for_Renewal_Opp_for_Indirect</template>
    </alerts>
    <alerts>
        <fullName>New_Cloud_Renewal_Opportunity_Indirect_PCC</fullName>
        <description>New Cloud Renewal Opportunity Indirect-PureConnect Cloud</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Sold_To_Business_Partner_Mail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>navaneetha.krishnan@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cloud_Renewal_Email_Template/Temp_for_Renewal_Opp_for_Indirect_PCC</template>
    </alerts>
    <alerts>
        <fullName>New_Cloud_Renewal_Opportunity_Indirect_PEC</fullName>
        <description>New Cloud Renewal Opportunity Indirect-PureEngage Cloud</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Sold_To_Business_Partner_Mail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>navaneetha.krishnan@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cloud_Renewal_Email_Template/Renewal_Opportunity_InDirect_PECloud</template>
    </alerts>
    <alerts>
        <fullName>Notify_on_WIns</fullName>
        <ccEmails>windsor.tanner@genesys.com</ccEmails>
        <ccEmails>josh.abich@genesyslab.com</ccEmails>
        <ccEmails>pushpa.ramachandran@genesys.com</ccEmails>
        <ccEmails>theresa.Monturano@genesys.com</ccEmails>
        <ccEmails>alex.ball@genesys.com</ccEmails>
        <description>Notify on WIns</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Notify</template>
    </alerts>
    <alerts>
        <fullName>On_Permise_Opportunity_Closed_Won_TestEmailAlert</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <description>On Permise Opportunity Closed Won -TestEmailAlert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Win_Announcements_Updated_2018/On_Premise_Opportunity_Closed_Won</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won</fullName>
        <ccEmails>SalesAllWorldwide@genesyslab.com</ccEmails>
        <ccEmails>SFDCWins@genesyslab.com</ccEmails>
        <ccEmails>SFDCWinsSLT@genesyslab.com</ccEmails>
        <description>Opportunity Closed Won</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesyslab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_Cloud</fullName>
        <ccEmails>SalesAllWorldwide@genesyslab.com</ccEmails>
        <ccEmails>SFDCWins@genesyslab.com</ccEmails>
        <ccEmails>SFDCWinsSLT@genesyslab.com</ccEmails>
        <description>Opportunity Closed Won Cloud</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesyslab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloudhtml</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_Cloud_EUA</fullName>
        <ccEmails>SalesAllWorldwide@genesyslab.com</ccEmails>
        <ccEmails>SFDCWins@genesyslab.com</ccEmails>
        <ccEmails>SFDCWinsSLT@genesyslab.com</ccEmails>
        <description>Cloud Opportunity Closed Won EUA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesyslab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cloud_Approval_Process/Opportunity_Closed_Won_Cloud_EUA_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_Cloud_EUA_APAC</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won EUA APAC</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloud_EUA_APAC_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_Cloud_EUA_EMEA_html</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won EUA EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloud_EUA_EMEA_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_Cloud_EUA_LATAM_html</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won EUA LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloud_EUA_LATAM_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_Cloud_EUA_NA_html</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Cloud Opportunity Closed Won EUA NA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloud_EUA_NA_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_Cloud_EUA_New_Logo_html</fullName>
        <ccEmails>SalesAllWorldwide@genesyslab.com</ccEmails>
        <ccEmails>SFDCWins@genesyslab.com</ccEmails>
        <ccEmails>SFDCWinsSLT@genesyslab.com</ccEmails>
        <description>Opportunity Closed-Won Cloud EUA New Logo html</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesyslab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cloud_Approval_Process/Opportunity_Closed_Won_Cloud_EUA_New_logohtml</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_Cloud_New_Logo_html</fullName>
        <ccEmails>SalesAllWorldwide@genesyslab.com</ccEmails>
        <ccEmails>SFDCWins@genesyslab.com</ccEmails>
        <ccEmails>SFDCWinsSLT@genesyslab.com</ccEmails>
        <description>Opportunity Closed-Won Cloud New Logo html</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesyslab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_Cloud_New_Logohtml</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_NA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Opportunity Closed Won - NA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_NA_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_New_Logo_APAC</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Opportunity Closed Won New Logo - APAC</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_New_Logo_APAC_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_New_Logo_EMEA_html</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Opportunity Closed Won New Logo - EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_New_Logo_EMEA_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_New_Logo_LATAM</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Opportunity Closed Won New Logo - LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_New_Logo_LATAM_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_New_Logo_NA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Opportunity Closed Won New Logo - NA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_New_Logo_NA_html</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_New_Logo_html</fullName>
        <ccEmails>SalesAllWorldwide@genesyslab.com</ccEmails>
        <ccEmails>SFDCWins@genesyslab.com</ccEmails>
        <ccEmails>SFDCWinsSLT@genesyslab.com</ccEmails>
        <description>Opportunity Closed-Won New Logo html</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>tom.eggemeier@genesyslab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_New_Logohtml</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_PPU</fullName>
        <description>Opportunity Closed Won PPU</description>
        <protected>false</protected>
        <recipients>
            <recipient>pushpa.ramachandran@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/Opportunity_Closed_Won_PPU</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Notification_to_CM</fullName>
        <description>Opportunity Notification to CM</description>
        <protected>false</protected>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Opportunity_Notification_to_CM</template>
    </alerts>
    <alerts>
        <fullName>P2P_Destination_Migration_Platform_Update</fullName>
        <ccEmails>PlatformToPlatformMigrationTeam@genesys.com</ccEmails>
        <description>P2P Destination Migration Platform Update</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Genesys_Care_Specialist__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Primary_Solution_Consultant__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/P2P_Destination_Migration_Platform_Update</template>
    </alerts>
    <alerts>
        <fullName>P2P_Destination_and_Lead_Platform_not_match</fullName>
        <ccEmails>debora.lane@genesys.com</ccEmails>
        <description>P2P Destination and Lead Platform not match</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Genesys_Care_Specialist__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Primary_Solution_Consultant__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>navaneetha.krishnan@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Gene_Care_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Solution_Consultant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/P2P_Destination_Migration_Platform_Update</template>
    </alerts>
    <alerts>
        <fullName>P2PemailNotification</fullName>
        <description>Email alert that triggers a notification to the creator of the P2P Assessment once it has been created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/P2PemailNotification</template>
    </alerts>
    <alerts>
        <fullName>PB_Opportunity_Assessment_Email</fullName>
        <description>PB Opportunity Assessment Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Opportunity_Assessment_Creation</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_APAC</fullName>
        <description>PS Opportunity Closed Won - APAC</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_APAC_html_OwnerAE</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_APAC_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <ccEmails>PSWorldwide@genesys.com</ccEmails>
        <description>PS Opportunity Closed Won - APAC - All</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_APAC_html</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_Cloud_Client_Services</fullName>
        <description>PS Opportunity Closed Won - Cloud Client Services</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_Cloud_Client_Services_html_OwnerAE</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_Cloud_Client_Services_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <ccEmails>PSWorldwide@genesys.com</ccEmails>
        <description>PS Opportunity Closed Won - Cloud Client Services- All</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_Cloud_Client_Services_html</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_EMEA</fullName>
        <description>PS Opportunity Closed Won - EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_EMEA_html_OwnerAE</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_EMEA_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <ccEmails>PSWorldwide@genesys.com</ccEmails>
        <description>PS Opportunity Closed Won - EMEA - All</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_EMEA_html</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_LATAM</fullName>
        <description>PS Opportunity Closed Won - LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_LATAM_html_OwnerAE</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_LATAM_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <ccEmails>PSWorldwide@genesys.com</ccEmails>
        <description>PS Opportunity Closed Won - LATAM - All</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_LATAM_html</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_North_America</fullName>
        <description>PS Opportunity Closed Won - North America</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_North_America_html_OwnerAE</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_North_America_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <ccEmails>PSWorldwide@genesys.com</ccEmails>
        <description>PS Opportunity Closed Won - North America - All</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_North_America_html</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_PureEngage_Cloud</fullName>
        <description>PS Opportunity Closed Won - PureEngage Cloud</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_PureEngage_Cloud_html_OwnerAE</template>
    </alerts>
    <alerts>
        <fullName>PS_Email_Template_for_PureEngage_Cloud_All</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <ccEmails>PSWorldwide@genesys.com</ccEmails>
        <description>PS Opportunity Closed Won - PureEngage Cloud - All</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PS_Opportunity_Closed_Won_PureEngage_Cloud_html</template>
    </alerts>
    <alerts>
        <fullName>Partner_Notification_Opportunity_Amount_Update</fullName>
        <description>Partner Notification Opportunity Amount Update</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_Submitted_Opportunity__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Opportunity_Amount_Updated</template>
    </alerts>
    <alerts>
        <fullName>Partner_Notification_Opportunity_Pipeline_Stage_Update</fullName>
        <description>Partner Notification Opportunity Pipeline Stage Update</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_Submitted_Opportunity__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Opportunity_Pipeline_Stage_Updated</template>
    </alerts>
    <alerts>
        <fullName>Partner_Notification_on</fullName>
        <description>Partner Notification Opportunity Forecast Status Update</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_Submitted_Opportunity__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Opportunity_Forecast_Status_Updated</template>
    </alerts>
    <alerts>
        <fullName>Partner_Op_Creation_Notification</fullName>
        <description>Partner Op Creation Notification</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>claire.flatley@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Partner_Op_Notification_for_Claire_Flatley</template>
    </alerts>
    <alerts>
        <fullName>Partner_Opportunity_Converted_Email_Alert</fullName>
        <description>Partner Opportunity Converted Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Opportunity_Converted_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Partner_Opportunity_Created_Email_Alert</fullName>
        <description>Partner Opportunity Created Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/Partner_Opportunity_Created</template>
    </alerts>
    <alerts>
        <fullName>Pre_Game_Decline_Manager_notification</fullName>
        <description>Pre-Game Decline Manager notification</description>
        <protected>false</protected>
        <recipients>
            <field>ManagerEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Pre_Game_Opp_Rejection_Notification2</template>
    </alerts>
    <alerts>
        <fullName>Prem_Perpetual_Oppty_Approval_Request_APAC</fullName>
        <ccEmails>apac@genesys.com.invalid</ccEmails>
        <description>Prem Perpetual Oppty Approval Request - APAC</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Pre_Sales_Engagements/Prem_Perpetual_Oppty_Approval_Request</template>
    </alerts>
    <alerts>
        <fullName>Prem_Perpetual_Oppty_Approval_Request_EMEA</fullName>
        <ccEmails>emea@genesys.com.invalid</ccEmails>
        <description>Prem Perpetual Oppty Approval Request - EMEA</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Pre_Sales_Engagements/Prem_Perpetual_Oppty_Approval_Request</template>
    </alerts>
    <alerts>
        <fullName>Prem_Perpetual_Oppty_Approval_Request_LATAM</fullName>
        <ccEmails>latam@genesys.com.invalid</ccEmails>
        <description>Prem Perpetual Oppty Approval Request - LATAM</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Pre_Sales_Engagements/Prem_Perpetual_Oppty_Approval_Request</template>
    </alerts>
    <alerts>
        <fullName>Prem_Perpetual_Oppty_Approval_Request_NA</fullName>
        <ccEmails>mariya@genesys.com.invalid</ccEmails>
        <description>Prem Perpetual Oppty Approval Request - NA</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Pre_Sales_Engagements/Prem_Perpetual_Oppty_Approval_Request</template>
    </alerts>
    <alerts>
        <fullName>Prem_Perpetual_Oppty_Approved</fullName>
        <ccEmails>approved@genesys.com.invalid</ccEmails>
        <description>Prem Perpetual Oppty Approved</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Pre_Sales_Engagements/Prem_Perpetual_Oppty_Approved</template>
    </alerts>
    <alerts>
        <fullName>Prem_Perpetual_Oppty_Declined</fullName>
        <ccEmails>declined@genesys.com.invalid</ccEmails>
        <description>Prem Perpetual Oppty Declined</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Pre_Sales_Engagements/Prem_Perpetual_Oppty_Declined</template>
    </alerts>
    <alerts>
        <fullName>PureCloud_Stage_5_Email_Notification</fullName>
        <description>PureCloud Stage 5 Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>richard.hodges@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>samantha.cushing@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/PureCloud_Stage_5_Notification</template>
    </alerts>
    <alerts>
        <fullName>Rental_Opportunity_Closed_Won</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <description>Rental Opportunity Closed Won</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Win_Announcements_Updated_2018/Rental_Win_Announcements</template>
    </alerts>
    <alerts>
        <fullName>Rental_Opportunity_Closed_Won_APAC</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Rental Opportunity Closed Won - APAC</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Rental_Opportunity_Closed_Won_APAC</template>
    </alerts>
    <alerts>
        <fullName>Rental_Opportunity_Closed_Won_EMEA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Rental Opportunity Closed Won - EMEA</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Rental_Opportunity_Closed_Won_EMEA</template>
    </alerts>
    <alerts>
        <fullName>Rental_Opportunity_Closed_Won_LATAM</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Rental Opportunity Closed Won - LATAM</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Rental_Opportunity_Closed_Won_LATAM</template>
    </alerts>
    <alerts>
        <fullName>Rental_Opportunity_Closed_Won_NA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Rental Opportunity Closed Won - NA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Rental_Opportunity_Closed_Won_NA</template>
    </alerts>
    <alerts>
        <fullName>Send_Welcome_Kit</fullName>
        <description>Send Welcome Kit</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/Begin_Onboarding_Process</template>
    </alerts>
    <alerts>
        <fullName>Send_an_email_alert_to_AE_for_Op_Forecast_Status_Booked</fullName>
        <description>Send an email alert to AE for Op Forecast Status = Booked</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/Opp_FC_Status_Booked</template>
    </alerts>
    <alerts>
        <fullName>Send_an_email_alert_to_Josh_Abich_for_BE_Opps_250</fullName>
        <description>Send an email alert to Josh Abich for BE Opps &lt; 250</description>
        <protected>false</protected>
        <recipients>
            <recipient>Marketing_Operations</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>josh.abich@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/BE_Opps_for_Josh_Abich</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Opportunity_Closed_Won</fullName>
        <ccEmails>SalesAllWorldwide@genesys.com</ccEmails>
        <description>Subscription Opportunity Closed Won</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Win_Announcements_Updated_2018/Subscription_Win_Announcement</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Opportunity_Closed_Won_APAC</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Subscription Opportunity Closed Won - APAC</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Pre_Sales_Engagements/Subscription_Opportunity_Closed_Won_APAC</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Opportunity_Closed_Won_EMEA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Subscription Opportunity Closed Won - EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Pre_Sales_Engagements/Subscription_Opportunity_Closed_Won_EMEA</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Opportunity_Closed_Won_LATAM</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Subscription Opportunity Closed Won - LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Pre_Sales_Engagements/Subscription_Opportunity_Closed_Won_LATAM</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Opportunity_Closed_Won_NA</fullName>
        <ccEmails>GenesysAll@genesys.com</ccEmails>
        <description>Subscription Opportunity Closed Won - NA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>genesys.wins@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Pre_Sales_Engagements/Subscription_Opportunity_Closed_Won_NA</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Order_Completion</fullName>
        <description>Subscription Order Completion</description>
        <protected>false</protected>
        <recipients>
            <recipient>ann_marie.vega@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>arjun.ramchandran@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>holli.bingham@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>joanne.veitch@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>salvina.pluchino@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>trevor.dewitt@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Subscription_Stage_5_Notification</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Stage_5_Email_Notification</fullName>
        <ccEmails>GU-SALES-OPS@genesys.com</ccEmails>
        <ccEmails>CCStaffTAMGlobalManagement@genesys.com</ccEmails>
        <description>Subscription Stage 5 Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ann_marie.vega@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>arjun.ramchandran@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>debbie.benoit@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>holli.bingham@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>janelle.dieken@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michele.remsing@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pushpa.ramachandran@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>salvina.pluchino@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>trevor.dewitt@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>viniti.mahbubani@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>zhengwei.luo@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce-noreply@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Subscription_Stage_5_Notification</template>
    </alerts>
    <alerts>
        <fullName>Test_Email</fullName>
        <description>Test Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>ankit.sanghvi@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pushpa.ramachandran@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/Opportunity_Closed_Won</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Name_Update</fullName>
        <description>Copy Opportunity Account Name in Account Name Custom field.</description>
        <field>Account_Name_Custom__c</field>
        <formula>Account.Name</formula>
        <name>Account Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Actual_Closed_Update</fullName>
        <field>Actual_Closed_Date__c</field>
        <formula>NOW()</formula>
        <name>Actual Closed Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Amount_of_Time_Opp_is_Open</fullName>
        <field>How_Long_Opportunity_Took_To_Close__c</field>
        <formula>NOW() -  CreatedDate</formula>
        <name>Amount of Time Opp is Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_record_type</fullName>
        <description>Change an opportunity&apos;s record type if year in closed date &gt; 2011</description>
        <field>RecordTypeId</field>
        <lookupValue>GEN_Opportunity_Record_Type_New</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change record type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_date_Update</fullName>
        <field>CloseDate</field>
        <formula>Today()</formula>
        <name>Close date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Direct_Sales_Update</fullName>
        <field>Direct_Sales__c</field>
        <literalValue>1</literalValue>
        <name>Direct Sales Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_Sent</fullName>
        <field>Win_Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Email Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_Sent_Cloud</fullName>
        <field>Win_Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Email Sent  Cloud</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_Sent_On_Premise</fullName>
        <field>Win_Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Email Sent  On Premise</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_Sent_Rental</fullName>
        <field>Win_Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Email Sent Rental</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Forecast_status_to_Expected</fullName>
        <field>ForecastStatus__c</field>
        <literalValue>3.Expected</literalValue>
        <name>Forecast status to &apos;Expected&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Indirect_update</fullName>
        <field>Direct_Sales__c</field>
        <literalValue>0</literalValue>
        <name>Indirect update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MKTG_Populate_Last_Significant_Update</fullName>
        <description>This will populate the Last Significant Update date field whenever an Opportunity owner makes a specified change to an Opportunity.</description>
        <field>Last_Significant_Update__c</field>
        <formula>Today()</formula>
        <name>MKTG - Populate Last Significant Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MKTG_Update_Owner_s_RM_Email</fullName>
        <field>RM_Email__c</field>
        <formula>IF( 
AND( 
NOT(Opportunity_Owner__r.Manager.Manager.Id=&quot;005U0000000dzYD&quot;), 
NOT(Opportunity_Owner__r.Manager.Manager.Id=&quot;005U0000000dwT1&quot;), 
NOT(Opportunity_Owner__r.Manager.Manager.Id=&quot;005U0000001ukfL&quot;), 
NOT(Opportunity_Owner__r.Manager.Manager.Id=&quot;005U0000000dwTY&quot;), 
NOT(Opportunity_Owner__r.Manager.Manager.Id=&quot;005U0000000e3Sj&quot;)),Opportunity_Owner__r.Manager.Manager.Email,&quot;&quot;)</formula>
        <name>MKTG - Update Owner&apos;s RM Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MKTG_Update_Owners_Managers_Email</fullName>
        <field>ManagerEmail__c</field>
        <formula>IF(
AND(
NOT(Opportunity_Owner__r.Manager.Id=&quot;005U0000000dzYD&quot;),
NOT(Opportunity_Owner__r.Manager.Id=&quot;005U0000000dwT1&quot;),
NOT(Opportunity_Owner__r.Manager.Id=&quot;005U0000001ukfL&quot;),
NOT(Opportunity_Owner__r.Manager.Id=&quot;005U0000000dwTY&quot;),
NOT(Opportunity_Owner__r.Manager.Id=&quot;005U0000000e3Sj&quot;)),Opportunity_Owner__r.Manager.Email,&quot;&quot;)</formula>
        <name>MKTG - Update Owners Managers Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MKTG_Update_Return_to_Nurture_Status</fullName>
        <field>Return_to_Nurture_Status__c</field>
        <literalValue>New</literalValue>
        <name>MKTG - Update Return to Nurture Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Sales_Status_Accepted</fullName>
        <field>Opportunity_Sales_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Opportunity Sales Status = Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Sales_Status_Rejected</fullName>
        <field>Opportunity_Sales_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Opportunity Sales Status = Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Sales_Status_Submitted</fullName>
        <field>Opportunity_Sales_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Opportunity Sales Status = Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PS_Oppty_Set_PSA_Submit_for_Approval</fullName>
        <description>What it does? Sets the PSA Submitted for OM opportunity approval status to Submitted
Owner? Professional Services/IT</description>
        <field>PSA_Closed_OM_Oppty_Submit_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>PS Oppty Set PSA Submit for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PS_Set_OpenAir_Project_ID_Blank</fullName>
        <description>Sets the OpenAir Project ID field to blank (null) on creation</description>
        <field>OpenAir_Auto_Num__c</field>
        <name>PS Set OpenAir Project ID Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PS_Set_OpenAir_Project_Internal_ID_Blank</fullName>
        <description>Sets the PS OpenAir Project Internal ID to blank (null) on creation</description>
        <field>OpenAir__c</field>
        <name>PS Set OpenAir Project Internal ID Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Pipeline_Added_06242016</fullName>
        <field>Pipeline_Added_Date__c</field>
        <formula>NOW()</formula>
        <name>Populate Pipeline Added 06242016</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PreGame_update</fullName>
        <field>PreGame_Opportunity__c</field>
        <literalValue>1</literalValue>
        <name>PreGame update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Retrieve_New_License_Amount</fullName>
        <field>Revenue_to_Be_Recognized_1__c</field>
        <formula>License_Amount__c</formula>
        <name>Retrieve New License Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Revenue_to_be_Recognized_date</fullName>
        <field>Revenue_to_be_Recognized_date__c</field>
        <formula>CloseDate</formula>
        <name>Revenue to be Recognized date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFDC_test_0_Booked</fullName>
        <field>Land__c</field>
        <literalValue>1</literalValue>
        <name>Opportunity LAND flag 0.Booked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFDC_test_1_In_Hand</fullName>
        <field>Land__c</field>
        <literalValue>1</literalValue>
        <name>SFDC test 1.In Hand</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFDC_test_commit</fullName>
        <field>Land__c</field>
        <literalValue>1</literalValue>
        <name>SFDC test commit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Number_of_Days_in_Stage_1</fullName>
        <description>Calculate and store the number of days the Opportunity was in this Stage.</description>
        <field>Days_in_Stage_1__c</field>
        <formula>TODAY() - Stage_1_Date__c</formula>
        <name>Set Number of Days in Stage 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Number_of_Days_in_Stage_2</fullName>
        <description>Calculate and store the number of days the Opportunity was in this Stage.</description>
        <field>Days_in_Stage_2__c</field>
        <formula>TODAY() - Stage_2_Date__c</formula>
        <name>Set Number of Days in Stage 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Number_of_Days_in_Stage_3</fullName>
        <description>Calculate and store the number of days the Opportunity was in this Stage.</description>
        <field>Days_in_Stage_3__c</field>
        <formula>TODAY() - Stage_3_Date__c</formula>
        <name>Set Number of Days in Stage 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Number_of_Days_in_Stage_4</fullName>
        <description>Calculate and store the number of days the Opportunity was in this Stage.</description>
        <field>Days_in_Stage_4__c</field>
        <formula>TODAY() - Stage_4_Date__c</formula>
        <name>Set Number of Days in Stage 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Number_of_Days_in_Stage_5</fullName>
        <description>Calculate and store the number of days the Opportunity was in this Stage.</description>
        <field>Days_in_Stage_5__c</field>
        <formula>TODAY() - Stage_5_Date__c</formula>
        <name>Set Number of Days in Stage 5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_1_Date_to_TODAY</fullName>
        <field>Stage_1_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Stage 1 Date to TODAY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_2_Date_to_TODAY</fullName>
        <field>Stage_2_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Stage 2 Date to TODAY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_3_Date_to_TODAY</fullName>
        <field>Stage_3_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Stage 3 Date to TODAY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_4_Date_to_TODAY</fullName>
        <field>Stage_4_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Stage 4 Date to TODAY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_5_Date_to_TODAY</fullName>
        <field>Stage_5_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Stage 5 Date to TODAY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_openair_to_true</fullName>
        <field>Create_OpenAir_Project__c</field>
        <literalValue>1</literalValue>
        <name>Set openair to true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stage_2_Opportunity</fullName>
        <field>StageName</field>
        <literalValue>2.Prospect Qualified</literalValue>
        <name>Stage = 2.Prospect Qualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Source</fullName>
        <field>Partner_Opportunity_Source__c</field>
        <literalValue>Marketing Sourced</literalValue>
        <name>Update Opportunity Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prior_Stage</fullName>
        <field>Stage_before_Closed__c</field>
        <formula>if(ispickval(PriorValue(StageName),&apos;1.Understand Needs&apos;),&apos;1.Understand Needs&apos;,if(ispickval(PriorValue(StageName),&apos;2.Define Requirements&apos;),&apos;2.Define Requirements&apos;,if(ispickval(PriorValue(StageName),&apos;3.Evaluate Options&apos;),&apos;3.Evaluate Options&apos;, if(ispickval(PriorValue(StageName),&apos;4.Build Consensus&apos;),&apos;4.Build Consensus&apos;,if(ispickval(PriorValue(StageName),&apos;5.Purchase Solution&apos;),&apos;5.Purchase Solution&apos;,&apos;&apos;)))))</formula>
        <name>Update Prior Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rejected_Accepted_By</fullName>
        <field>Rejected_Accepted_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName</formula>
        <name>Update Rejected/Accepted By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rejected_Accepted_Date</fullName>
        <field>Rejected_Accepted_Date__c</field>
        <formula>now()</formula>
        <name>Update Rejected/Accepted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Submitted_By</fullName>
        <field>Approval_Submitted_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName</formula>
        <name>Update Submitted By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Submitted_Date</fullName>
        <field>Approval_Submission_Date__c</field>
        <formula>now()</formula>
        <name>Update Submitted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Migration_Opportunity</fullName>
        <description>Type= Existing Business – Platform Migration
Direct/Indirect Sales = Indirect
Approval Status = Approved 
Partner Portal Opportunity =/ Null</description>
        <field>Partner_Opportunity_Source__c</field>
        <literalValue>Partner Registered Migration Opportunity</literalValue>
        <name>Update to Migration Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Win_Owner_Notification_Sent</fullName>
        <description>Set the Win Owner Notification flag on the Opportunity</description>
        <field>Win_Owner_Notification_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Win Owner Notification Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X1st_Owner_Id_not_null</fullName>
        <field>X1stOwnerId__c</field>
        <formula>OwnerId</formula>
        <name>1st Owner Id not null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>cloud_win</fullName>
        <field>Cloud_Win_Email__c</field>
        <literalValue>1</literalValue>
        <name>cloud win</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>ucm__Opportunity_outbound_messages</fullName>
        <apiVersion>40.0</apiVersion>
        <endpointUrl>http://sfsvc.zinfi.com/services/obm/opportunity.asmx</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>genesys-sf@zinfitech.com</integrationUser>
        <name>Opportunity outbound messages</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Account Name Update Rule</fullName>
        <actions>
            <name>Account_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copy Opportunity Account Name in &apos;Account Name Custom&apos; field.</description>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp; 
NOT(ISBLANK(Account.Name))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Actual Closed Update</fullName>
        <actions>
            <name>Actual_Closed_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT($User.BypassWorkflows__c),
ISNULL(Actual_Closed_Date__c),
ISPICKVAL(StageName, &apos;6.Closed&apos;),
RecordTypeId =&apos;012U0000000LrBP&apos; 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AppFoundry Opportunity Closed Won -APAC - AE</fullName>
        <actions>
            <name>AppFoundry_Email_Alert_for_APAC_AE</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>AppFoundry Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Owner_Notification_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>AppFoundry Opportunity Closed Won - APAC - send notification to AE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AppFoundry Opportunity Closed Won -APAC - All</fullName>
        <actions>
            <name>AppFoundry_Email_Alert_for_APAC_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (10 AND 11)) AND 12 AND (13 OR 14) AND 15 AND 16 AND 17 AND 18</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;USD 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;EUR 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;GBP 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;BRL 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;JPY 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>AppFoundry Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>AppFoundry Opportunity Closed Won - APAC - filtered by Opportunity threshold value and send to all</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AppFoundry Opportunity Closed Won -EMEA - AE</fullName>
        <actions>
            <name>AppFoundry_Email_Alert_for_EMEA_AE</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>AppFoundry Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Owner_Notification_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>AppFoundry Opportunity Closed Won - EMEA - send notification to AE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AppFoundry Opportunity Closed Won -EMEA - All</fullName>
        <actions>
            <name>AppFoundry_Email_Alert_for_EMEA_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (10 AND 11)) AND 12 AND (13 OR 14) AND 15 AND 16 AND 17 AND 18</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;USD 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;EUR 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;GBP 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;BRL 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;JPY 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>AppFoundry Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>AppFoundry Opportunity Closed Won - EMEA - filtered by Opportunity threshold value and send to all</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AppFoundry Opportunity Closed Won -LATAM - AE</fullName>
        <actions>
            <name>AppFoundry_Email_Alert_for_LATAM_AE</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>AppFoundry Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Owner_Notification_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>AppFoundry Opportunity Closed Won - LATAM - send notification to AE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AppFoundry Opportunity Closed Won -LATAM - All</fullName>
        <actions>
            <name>AppFoundry_Email_Alert_for_LATAM_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (10 AND 11)) AND 12 AND (13 OR 14) AND 15 AND 16 AND 17 AND 18</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;USD 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;EUR 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;GBP 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;BRL 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;JPY 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>AppFoundry Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>AppFoundry Opportunity Closed Won - LATAM - filtered by Opportunity threshold value and send to all</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AppFoundry Opportunity Closed Won -NA - AE</fullName>
        <actions>
            <name>AppFoundry_Email_Alert_for_NA_AE</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>AppFoundry Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Owner_Notification_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>AppFoundry Opportunity Closed Won - NA - send notification to AE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AppFoundry Opportunity Closed Won -NA - All</fullName>
        <actions>
            <name>AppFoundry_Email_Alert_for_NA_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (10 AND 11)) AND 12 AND (13 OR 14) AND 15 AND 16 AND 17 AND 18</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;USD 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;EUR 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;GBP 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;BRL 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;JPY 5,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>AppFoundry Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>AppFoundry Opportunity Closed Won -NA - filtered by Opportunity threshold value and send to all</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BE Opps for Josh Abich</fullName>
        <actions>
            <name>Send_an_email_alert_to_Josh_Abich_for_BE_Opps_250</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Lines_of_Businesses__c</field>
            <operation>equals</operation>
            <value>Business Edition</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.NumberofAgents__c</field>
            <operation>equals</operation>
            <value>1-5,6-50,51-100,101-250</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.End_User_Region__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <description>Send a notification to Josh Abich whenever there&apos;s a Business Edition Opportunity with Number of Agent Seats &lt; 250</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change record type</fullName>
        <actions>
            <name>Change_record_type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Will change record type to &quot;GEN - Opportunity Record Type&quot; is closure date is 2012 and beyond</description>
        <formula>AND(
YEAR( CloseDate ) &gt; 2011,
NOT($User.BypassValidationRules__c = True),
Not(ISCHANGED( RecordTypeId)) ,
RecordTypeId =&apos;012U0000000LrBPIA0&apos; 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Changed Stage out of Stage 2</fullName>
        <actions>
            <name>Set_Number_of_Days_in_Stage_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c)
&amp;&amp;
ISPICKVAL( PRIORVALUE( StageName ) , &quot;2.Identify Requirements&quot; ) 
&amp;&amp; 
ISCHANGED( StageName )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Changed Stage out of Stage 3</fullName>
        <actions>
            <name>Set_Number_of_Days_in_Stage_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c)
&amp;&amp;
ISPICKVAL( PRIORVALUE( StageName ) , &quot;3.Evaluate Options&quot; ) 
&amp;&amp; 
ISCHANGED( StageName )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Changed Stage out of Stage 4</fullName>
        <actions>
            <name>Set_Number_of_Days_in_Stage_4</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c)
&amp;&amp;
ISPICKVAL( PRIORVALUE( StageName ) , &quot;4.Resolve Concerns&quot; ) 
&amp;&amp; 
ISCHANGED( StageName )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Changed Stage out of Stage 5</fullName>
        <actions>
            <name>Set_Number_of_Days_in_Stage_5</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c)
&amp;&amp;
ISPICKVAL( PRIORVALUE( StageName ) , &quot;5.Purchase Solution&quot; ) 
&amp;&amp; 
ISCHANGED( StageName )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Close date Update</fullName>
        <actions>
            <name>Close_date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(ForecastStatus__c, &apos;0.Booked&apos;),  
ISCHANGED(ForecastStatus__c), OR(RecordType.Name =&apos;GEN - Opportunity Record Type&apos;, RecordType.Name =&apos;Cloud Renewal&apos;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA</fullName>
        <actions>
            <name>Opportunity_Closed_Won_Cloud_EUA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 80,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA - APAC</fullName>
        <actions>
            <name>Opportunity_Closed_Won_Cloud_EUA_APAC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 80,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won EUA - APAC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA - EMEA</fullName>
        <actions>
            <name>Opportunity_Closed_Won_Cloud_EUA_EMEA_html</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (15 AND 16)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 17 AND 18 AND 19</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 80,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won EUA - EMEA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA - LATAM</fullName>
        <actions>
            <name>Opportunity_Closed_Won_Cloud_EUA_LATAM_html</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 80,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won EUA - LATAM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA - NA</fullName>
        <actions>
            <name>Opportunity_Closed_Won_Cloud_EUA_NA_html</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 80,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won EUA - NA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA New Logo</fullName>
        <actions>
            <name>Opportunity_Closed_Won_Cloud_EUA_New_Logo_html</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>USD 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>GBP 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA New Logo APAC</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_EUA_New_Logo_APAC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed-Won Cloud EUA New Logo APAC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA New Logo EMEA</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_EUA_New_Logo_EMEA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (15 AND 16)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 17 AND 18 AND 19</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed-Won Cloud EUA New Logo EMEA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA New Logo LATAM</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_EUA_New_Logo_LATAM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed-Won Cloud EUA New Logo LATAM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won EUA New Logo NA</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_EUA_New_Logo_NA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Estimated_Usage_Agreements_EUA__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed-Won Cloud EUA New Logo NA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV</fullName>
        <actions>
            <name>Opportunity_Closed_Won_Cloud</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV APAC</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_TCV_APAC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) or (17 and 18) or (19 and 20) or (21 and 22) ) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 80,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 2,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won TCV APAC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV EMEA</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_TCV_EMEA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (16 AND 17) or (19 and 20) or (21 and 22)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 18</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 80,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 2,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won TCV EMEA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV LATAM</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_TCV_LATAM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)  OR (17 AND 18) or (19 and 20) or (21 and 22)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 80,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 2,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won TCV LATAM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV NA</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_TCV_NA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (17 and 18) or (23 and 24) OR  (19 and 20) or (21 and 22)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 80,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 20,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 2,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;CAD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>CAD</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won TCV NA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV NEW</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_TCV_NEW_TestEmailAlert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent_Cloud</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5 AND 6 AND 7 AND 8 AND 9 AND (10 OR 11 OR 12 OR 13 OR 17) AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Primary_Line_of_Business__c</field>
            <operation>equals</operation>
            <value>Cloud</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Trigger_Win_Announcement_Workflow__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>CSM</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won TCV</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV New Logo</fullName>
        <actions>
            <name>Opportunity_Closed_Won_Cloud_New_Logo_html</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>USD 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>GBP 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV New Logo APAC</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_TCV_NewLogo_APAC_html</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR(17 AND 18) or (19 and 20) or (21 and 22) or (23 and 24) ) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>AUD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>AUD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>BRL 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>JPY 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won TCV New Logo APAC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV New Logo EMEA</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_TCV_NewLogo_EMEA_html</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (16 AND 17) or (19 and 20) or( 21 and 22)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 18</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>BRL 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>JPY 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won TCV New Logo EMEA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV New Logo LATAM</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_TCV_NewLogo_LATAM_html</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (17 AND 18) OR (19 AND 20) or (21 and 22)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>JPY 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>BRL 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won TCV New Logo LATAM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Opportunity Closed Won TCV New Logo NA</fullName>
        <actions>
            <name>Cloud_Opportunity_Closed_Won_TCV_NewLogo_NA_html</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) or (17 and 18) or (23 and 24) OR  (19 and 20) or (21 and 22)) AND 10 and 11 and 12 AND (7 OR 8) AND 6 AND 9 AND 13 AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>BRL 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>JPY 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>CAD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Annual_Contract_Value__c</field>
            <operation>greaterThan</operation>
            <value>CAD 0</value>
        </criteriaItems>
        <description>Cloud Opportunity Closed Won TCV New Logo NA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Renewal Forecast Status Booked</fullName>
        <actions>
            <name>Cloud_Renewal_Opps_with_Forecast_Status_Booked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Opportunity.ForecastStatus__c</field>
            <operation>equals</operation>
            <value>0.Booked</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>equals</operation>
            <value>raj.nallamotu@genesyslab.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cloud Renewal</value>
        </criteriaItems>
        <description>Send a notification to AE when Opportunity Forecast Status = Booked and record type is cloud renewal.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Direct%2FIndirect update</fullName>
        <actions>
            <name>Direct_Sales_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Direct_Indirect_Sale__c</field>
            <operation>equals</operation>
            <value>Direct</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>When Direct is selected, Direct Sales check box would be checked.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF065_1st Owner Id</fullName>
        <actions>
            <name>X1st_Owner_Id_not_null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.X1stOwnerId__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Indirect update</fullName>
        <actions>
            <name>Indirect_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Direct_Indirect_Sale__c</field>
            <operation>equals</operation>
            <value>Indirect</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>When In-Direct is selected, Direct Sales check box would be unchecked.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>License Amount</fullName>
        <actions>
            <name>Retrieve_New_License_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp; ISBLANK(Revenue_to_be_Recognized__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Populate Last Significant Update</fullName>
        <actions>
            <name>MKTG_Populate_Last_Significant_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This WF populates the Last Significant Update field with today&apos;s date when the criteria has been met</description>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp;
OR 
(ISCHANGED(StageName), 
ISCHANGED(CloseDate), 
ISCHANGED(Opportunity_Owner__c), 
ISCHANGED(NextStep), 
ISCHANGED(Amount), 
ISCHANGED(License_Amount__c), 
ISCHANGED(Annual_Contract_Value__c), 
ISCHANGED(Hardware_Total__c), 
ISCHANGED(Monthly_Commitment__c), 
ISCHANGED(ForecastStatus__c), 
ISCHANGED(LeadDevelopmentRep__c), 
ISCHANGED(License_Equivalency__c), 
ISCHANGED(Primary_Quote__c) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Reminder - Oppt 1 Day Past Close Date</fullName>
        <active>false</active>
        <description>An alert goes out when an Opportunity (that meets the specific criteria) is 1 day after the close date</description>
        <formula>AND(NOT($User.BypassWorkflows__c), ( CloseDate &gt; DATEVALUE(&quot;2014-10-09&quot;)), (Cloud_Renewal__c = false), (ISPICKVAL(Country__r.Region__c,&quot;North America&quot;)), (RecordTypeId = &quot;012U0000000LrBP&quot;), OR( (ISPICKVAL(StageName,&quot;1.Recognize Needs&quot;)), (ISPICKVAL(StageName,&quot;2.Identify Requirements&quot;)) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_Reminder_1_Day_Past_Oppt_Close_Date</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_Oppt_Expired_1_Day_Ago</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MKTG - Reminder - Oppt 14 Days Past Close Date</fullName>
        <active>false</active>
        <description>An alert goes out when an Opportunity (that meets the specific criteria) is 14 days after the close date</description>
        <formula>AND(NOT($User.BypassWorkflows__c), (Cloud_Renewal__c = false), (ISPICKVAL(Country__r.Region__c,&quot;North America&quot;)), (RecordTypeId = &quot;012U0000000LrBP&quot;), NOT(ISPICKVAL(StageName,&quot;6.Closed&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_Reminder_Opportunity_14_Days_Past_Close_Date</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_Oppt_Expired_14_Days_Ago</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MKTG - Reminder - Oppt 5 Days Before Close Date</fullName>
        <active>false</active>
        <description>An alert goes out when a Marketing Sourced Opportunity (that meets the specific criteria) is about to close in 5 days</description>
        <formula>AND( (Cloud_Renewal__c = false), (LeadDevelopmentRep__c != null), /*(ISPICKVAL(Country__r.Region__c,&quot;North America&quot;)), */(RecordType.Id = &quot;012U0000000LrBP&quot;), OR( (ISPICKVAL(StageName,&quot;1.Recognize Needs&quot;)), (ISPICKVAL(StageName,&quot;2.Identify Requirements&quot;)) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_5_Days_Before_Oppt_Close_Date</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_Oppt_Expires_in_5_Days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MKTG - Reminder - Oppt 7 Days Past Close Date</fullName>
        <active>false</active>
        <description>An alert goes out when an Opportunity (that meets the specific criteria) is 7 days after the close date</description>
        <formula>AND(NOT($User.BypassWorkflows__c), ( CloseDate &gt; DATEVALUE(&quot;2014-10-09&quot;)), (Cloud_Renewal__c = false), (ISPICKVAL(Country__r.Region__c,&quot;North America&quot;)), (RecordTypeId = &quot;012U0000000LrBP&quot;), NOT(ISPICKVAL(StageName,&quot;6.Closed&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_Reminder_Opportunity_7_Days_Past_Close_Date</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_Oppt_Expired_7_Days_Ago</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MKTG - Return to Nurture</fullName>
        <actions>
            <name>MKTG_Return_to_Nurture</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>MKTG_Update_Return_to_Nurture_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Affecting All Marking Sourced Opportunities - Notification/Email when it’s closed-lost (4 reasons — Budget, Authority, Timing, Need)</description>
        <formula>AND( 
OR(
NOT(ISBLANK(LeadDevelopmentRep__c)),
NOT(ISBLANK( Campaign_Source__c))),
OR(
ISPICKVAL( Win_Loss_Status__c , &quot;Lost&quot;),
ISPICKVAL( Win_Loss_Status__c , &quot;No decision&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Stalled Opportunities APAC</fullName>
        <active>false</active>
        <formula>AND 
(LeadDevelopmentRep__c != null, 
/*End_User_Region__c=&quot;APAC&quot;, */
Last_Significant_Update__c&gt; DATE(2015,01,12), 
OR( 
ISPICKVAL (StageName, &quot;1.Recognize Needs&quot;), 
ISPICKVAL (StageName, &quot;2.Identify Requirements&quot;)), 
RecordTypeId = &quot;012U0000000LrBP&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_APAC_Stalled_Oppt_Alert_35_days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_APAC_Oppt_Untouched_35_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>35</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_APAC_Stalled_Oppt_Alert_28_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_APAC_Oppt_Untouched_28_Days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>28</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_APAC_Stalled_Oppt_Alert_21_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_APAC_Oppt_Untouched_21_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_APAC_Stalled_Oppt_Alert_14_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_APAC_Oppt_Untouched_14_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MKTG - Stalled Opportunities EMEA</fullName>
        <active>false</active>
        <formula>AND 
(LeadDevelopmentRep__c != null, 
/*End_User_Region__c=&quot;EMEA&quot;, */
Last_Significant_Update__c&gt; DATE(2015,01,12), 
OR( 
ISPICKVAL (StageName, &quot;1.Recognize Needs&quot;), 
ISPICKVAL (StageName, &quot;2.Identify Requirements&quot;)), 
RecordTypeId = &quot;012U0000000LrBP&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_EMEA_Stalled_Oppt_Alert_14_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_EMEA_Oppt_Untouched_14_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_EMEA_Stalled_Oppt_Alert_21_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_EMEA_Oppt_Untouched_21_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_EMEA_Stalled_Oppt_Alert_35_days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_EMEA_Oppt_Untouched_35_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>35</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_EMEA_Stalled_Oppt_Alert_28_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_EMEA_Oppt_Untouched_28_Days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>28</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MKTG - Stalled Opportunities LATAM</fullName>
        <active>false</active>
        <formula>AND 
(LeadDevelopmentRep__c != null, 
/*End_User_Region__c=&quot;LATAM&quot;, */
Last_Significant_Update__c&gt; DATE(2015,01,12), 
OR( 
ISPICKVAL (StageName, &quot;1.Recognize Needs&quot;), 
ISPICKVAL (StageName, &quot;2.Identify Requirements&quot;)), 
RecordTypeId = &quot;012U0000000LrBP&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_LATAM_Stalled_Oppt_Alert_21_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_LATAM_Oppt_Untouched_21_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_LATAM_Stalled_Oppt_Alert_35_days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_LATAM_Oppt_Untouched_35_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>35</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_LATAM_Stalled_Oppt_Alert_14_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_LATAM_Oppt_Untouched_14_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_LATAM_Stalled_Oppt_Alert_28_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_LATAM_Oppt_Untouched_28_Days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>28</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MKTG - Stalled Opportunities North America</fullName>
        <active>false</active>
        <formula>AND  
(LeadDevelopmentRep__c != null, 
/*End_User_Region__c=&quot;North America&quot;,*/
Last_Significant_Update__c&gt; DATE(2015,01,12), 
OR(
ISPICKVAL (StageName, &quot;1.Recognize Needs&quot;),
ISPICKVAL (StageName, &quot;2.Identify Requirements&quot;)),  RecordTypeId  = &quot;012U0000000LrBP&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_North_America_Stalled_Oppt_Alert_14_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_North_America_Oppt_Untouched_14_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_North_America_Stalled_Oppt_Alert_28_days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_North_America_Oppt_Untouched_28_Days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>28</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_North_America_Stalled_Oppt_Alert_35_days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_North_America_Oppt_Untouched_35_Days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>35</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>MKTG_North_America_Stalled_Oppt_Alert_21_Days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Alert_North_America_Oppt_Untouched_21_days</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MKTG - Stalled Oppt Alert 14 Days</fullName>
        <active>false</active>
        <description>An alert goes out when a Marketing Sourced Opportunity (that meets the specific criteria) has not been touched for 14 days. This only affects Marketing Sourced Opportunities that are in stage 1</description>
        <formula>AND ( (Cloud_Renewal__c = false), LeadDevelopmentRep__c != null, /*(ISPICKVAL(Country__r.Region__c,&quot;North America&quot;)), */(ISPICKVAL (StageName, &quot;1.Recognize Needs&quot;)), RecordType.Id = &quot;012U0000000LrBP&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Opportunity.Last_Significant_Update__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MKTG - Update Owner%27s Managers%27 Emails</fullName>
        <actions>
            <name>MKTG_Update_Owner_s_RM_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MKTG_Update_Owners_Managers_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Marketing Sourced Opportunity Notification</fullName>
        <actions>
            <name>Marketing_Sourced_Opportunity_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.LeadDevelopmentRep__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>12/13/2013</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Business Stage Closed Won</fullName>
        <actions>
            <name>Send_Welcome_Kit</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Send_Welcome_Kit</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <formula>AND(
ISPICKVAL( StageName , &apos;6.Closed&apos;),
ISPICKVAL( Type,  &apos;New logo&apos;),
ISPICKVAL( Win_Loss_Status__c, &apos;Won&apos;),
NOT($User.BypassValidationRules__c = True),
RecordTypeId =&apos;012U0000000LrBPIA0&apos; 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>On Premise Opportunity Closed Won TCV NEW</fullName>
        <actions>
            <name>On_Permise_Opportunity_Closed_Won_TestEmailAlert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent_On_Premise</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5 AND 6 AND 7 AND 8 AND 9 AND (10 OR 11 OR 12 OR 13) AND 14 AND 15 AND 16 AND 17</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Primary_Line_of_Business__c</field>
            <operation>equals</operation>
            <value>On Premise</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Trigger_Win_Announcement_Workflow__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Offer__c</field>
            <operation>equals</operation>
            <value>PureConnect Premise,PureEngage Premise</value>
        </criteriaItems>
        <description>On Premise Opportunity Closed Won TCV</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won</fullName>
        <actions>
            <name>Opportunity_Closed_Won</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 75,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 60,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 10,200,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 220,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won - APAC</fullName>
        <actions>
            <name>Email_Template_for_APAC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22 and 23</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 75,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 60,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 10,200,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 220,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed Won - APAC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won - LATAM</fullName>
        <actions>
            <name>Email_Template_for_LATAM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22 and 23</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 75,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 60,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 10,200,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 220,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed Won - LATAM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won - NA</fullName>
        <actions>
            <name>Opportunity_Closed_Won_NA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((24 AND 25) OR (2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22 AND 23</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 75,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 60,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 10,200,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 220,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>CAD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>&quot;CAD 10,000&quot;</value>
        </criteriaItems>
        <description>Opportunity Closed Won - NA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won -EMEA</fullName>
        <actions>
            <name>Email_Template_for_EMEA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22 and 23</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 74,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 60,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 10,200,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 220,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed Won - EMEA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won New Logo</fullName>
        <actions>
            <name>Opportunity_Closed_Won_New_Logo_html</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>USD 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>EUR 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>GBP 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>JPY 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>BRL 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won New Logo - APAC</fullName>
        <actions>
            <name>Opportunity_Closed_Won_New_Logo_APAC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17) )AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22 and 23</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>JPY 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>BRL 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed Won New Logo - APAC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won New Logo - EMEA</fullName>
        <actions>
            <name>Opportunity_Closed_Won_New_Logo_EMEA_html</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22 AND 23</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>JPY 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>BRL 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed Won New Logo - EMEA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won New Logo - LATAM</fullName>
        <actions>
            <name>Opportunity_Closed_Won_New_Logo_LATAM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22 AND 23</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>JPY 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>BRL 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity Closed Won New Logo - LATAM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won New Logo - NA</fullName>
        <actions>
            <name>Opportunity_Closed_Won_New_Logo_NA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((24 AND 25) OR (2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22 AND 23</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>JPY 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>BRL 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>notEqual</operation>
            <value>,CAD 0,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>equals</operation>
            <value>,CAD 0,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>CAD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>CAD 0</value>
        </criteriaItems>
        <description>Opportunity Closed Won New Logo - NA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won PPU</fullName>
        <actions>
            <name>Opportunity_Closed_Won_PPU</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9)) AND 10 and 11 and 12 AND 13 AND 14 AND 15 AND 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 250,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 200,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 160,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GPB</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ACV_Subscription_Only__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 20,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>contains</operation>
            <value>PPU</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed-Won Notify</fullName>
        <actions>
            <name>Notify_on_WIns</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>cloud_win</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Primary_Line_of_Business__c</field>
            <operation>equals</operation>
            <value>Cloud</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Win_Email__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>DL 8/23 - This rule is no longer being used. This is to notify Opp closed won to &apos;Windsor Tanner&apos;, &apos;Josh Abich&apos;, &apos;Pushpa Ramachandran&apos; Alex Ball and Theresa Monturano&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity LAND flag 0%2EBooked</fullName>
        <actions>
            <name>SFDC_test_0_Booked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(
ISPICKVAL(ForecastStatus__c, &apos;0.Booked&apos;),
NOT($User.BypassValidationRules__c = True),
RecordTypeId =&apos;012U0000000LrBPIA0&apos; 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity LAND flag 1%2EIn Hand</fullName>
        <actions>
            <name>SFDC_test_1_In_Hand</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.ForecastStatus__c</field>
            <operation>equals</operation>
            <value>1.In Hand</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity LAND flag 2%2Ecommit</fullName>
        <actions>
            <name>SFDC_test_commit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.ForecastStatus__c</field>
            <operation>equals</operation>
            <value>2.Commit</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Prior Stage</fullName>
        <actions>
            <name>Update_Prior_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>if(AND(ISCHANGED(StageName),ISPICKVAL(StageName,&apos;6.Closed&apos;),   Stage_before_Closed__c == &apos;&apos; ),true,false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opps with Forecast Status Booked</fullName>
        <actions>
            <name>Send_an_email_alert_to_AE_for_Op_Forecast_Status_Booked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Opportunity.ForecastStatus__c</field>
            <operation>equals</operation>
            <value>0.Booked</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>equals</operation>
            <value>raj.nallamotu@genesyslab.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Professional Services,Cloud Renewal</value>
        </criteriaItems>
        <description>Send a notification to AE when Opportunity Forecast Status = Booked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>P2P Email Notfication Gen Opportunity</fullName>
        <actions>
            <name>P2P_Destination_and_Lead_Platform_not_match</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT($User.BypassWorkflows__c), RecordType.Name = &quot;GEN - Opportunity Record Type&quot;,(TEXT(Lead_Offer__c) &lt;&gt; TEXT(P2P_Destination_Migration_Platform__c)),ISPICKVAL(Partner_Opportunity_Source__c, &apos;Sales Sourced - Premise to Cloud Migration Assessment&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>P2PemailNotification</fullName>
        <actions>
            <name>P2PemailNotification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.P2P_Migration_Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Bypass_Triggers__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send an email to the opportunity owner when his/her P2P Assessment has been completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS - Update Owner%27s Manager%27s Email</fullName>
        <actions>
            <name>MKTG_Update_Owners_Managers_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Owners Managers Email value on create or if the owner changes</description>
        <formula>AND( NOT($User.BypassWorkflows__c), 
OR(ISNEW(), ISCHANGED(OwnerId)) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Closed Won -APAC - Owner</fullName>
        <actions>
            <name>PS_Email_Template_for_APAC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS Opportunity Closed Won - APAC - no value thresholds and targeted to opportunity and Account Owners only</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;APAC&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Owner_Notification_Sent__c = false,  $User.BypassWorkflows__c = false,  Amount &gt; 0,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &lt; 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &lt; 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &lt; 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &lt; 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &lt; 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Closed Won -Cloud Client Services- All</fullName>
        <actions>
            <name>PS_Email_Template_for_Cloud_Client_Services_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS Opportunity Closed Won - Cloud Client Services- filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureEngage&quot;),  OR(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;),  ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;),  ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;),  ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)  ),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Closed Won -Cloud Client Services- Owner</fullName>
        <actions>
            <name>PS_Email_Template_for_Cloud_Client_Services</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS Opportunity Closed Won - Cloud Client Services - no value thresholds and targeted to opportunity and Account Owners only</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  OR(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;),  ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;),  ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;),  ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Owner_Notification_Sent__c = false,  $User.BypassWorkflows__c = false,  Amount &gt; 0,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &lt; 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &lt; 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &lt; 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &lt; 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &lt; 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Closed Won -EMEA - Owner</fullName>
        <actions>
            <name>PS_Email_Template_for_EMEA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS Opportunity Closed Won - EMEA - no value thresholds and targeted to opportunity and Account Owners only</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;EMEA&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Owner_Notification_Sent__c = false,  $User.BypassWorkflows__c = false,  Amount &gt; 0,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &lt; 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &lt; 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &lt; 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &lt; 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &lt; 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Closed Won -LATAM - Owner</fullName>
        <actions>
            <name>PS_Email_Template_for_LATAM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS Opportunity Closed Won - LATAM - no value thresholds and targeted to opportunity and Account Owners only</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;Latin America&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Owner_Notification_Sent__c = false,  $User.BypassWorkflows__c = false,  Amount &gt; 0,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &lt; 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &lt; 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &lt; 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &lt; 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &lt; 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Closed Won -North America - Owner</fullName>
        <actions>
            <name>PS_Email_Template_for_North_America</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS Opportunity Closed Won - North America - no value thresholds and targeted to opportunity and Account Owners only</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;North America&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Owner_Notification_Sent__c = false,  $User.BypassWorkflows__c = false,  Amount &gt; 0,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &lt; 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &lt; 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &lt; 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &lt; 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &lt; 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Closed Won -PureEngage Cloud - All</fullName>
        <actions>
            <name>PS_Email_Template_for_PureEngage_Cloud_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS Opportunity Closed Won - PureEngage Cloud - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureEngage&quot;),  ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Closed Won -PureEngage Cloud - Owner</fullName>
        <actions>
            <name>PS_Email_Template_for_PureEngage_Cloud</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Win_Owner_Notification_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS Opportunity Closed Won - PureEngage Cloud - no value thresholds and targeted to opportunity and Account Owners only</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Owner_Notification_Sent__c = false,  $User.BypassWorkflows__c = false,  Amount &gt; 0,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &lt; 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &lt; 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &lt; 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &lt; 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &lt; 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &lt; 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Set OA IDs blank on create</fullName>
        <actions>
            <name>PS_Set_OpenAir_Project_ID_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PS_Set_OpenAir_Project_Internal_ID_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Purpose: Opportunity workflow to set the PS Opportunity OpenAir IDs to blank when first created, which will resolve them being copied during a clone activity which causes cross platform reference issues
Owner: Professional Services</description>
        <formula>AND( NOT($User.BypassWorkflows__c),  $RecordType.Name = &quot;Professional Services&quot;, NOT($User.ProfileId = &quot;00e0B000000uLkv&quot;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PS Opportunity Set PSA Submission for Approve on Close</fullName>
        <actions>
            <name>PS_Oppty_Set_PSA_Submit_for_Approval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>What it does? Sets the PSA Submitted status when the PS Opportunity is closed/won ready for the OM team approval to start, if not already set
Owner? Professional Services/IT</description>
        <formula>AND  
(NOT($User.BypassWorkflows__c),  
RecordType.Name = &quot;Professional Services&quot;,  
ISPICKVAL( PSA_Closed_OM_Oppty_Submit_Status__c, &quot;&quot; ), 
NOT(ISPICKVAL(Finance_Oppty_Approval_Status__c, &quot;Approved&quot;)),
ISPICKVAL( ForecastStatus__c, &quot;0.Booked&quot;),  
ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  
ISPICKVAL( StageName , &quot;6.Closed&quot;)  
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureCloud Opportunity Closed Won-APAC-All</fullName>
        <actions>
            <name>PS_Email_Template_for_APAC_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureCloud Opportunity Closed Won - APAC - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;APAC&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureCloud&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureCloud Opportunity Closed Won-EMEA-All</fullName>
        <actions>
            <name>PS_Email_Template_for_EMEA_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureCloud Opportunity Closed Won - EMEA - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;EMEA&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureCloud&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureCloud Opportunity Closed Won-LATAM-All</fullName>
        <actions>
            <name>PS_Email_Template_for_LATAM_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureCloud Opportunity Closed Won - LATAM - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;Latin America&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureCloud&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureCloud Opportunity Closed Won-North America-All</fullName>
        <actions>
            <name>PS_Email_Template_for_North_America_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureCloud Opportunity Closed Won - North America - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;North America&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureCloud&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureConnect Opportunity Closed Won-APAC-All</fullName>
        <actions>
            <name>PS_Email_Template_for_APAC_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureConnect Opportunity Closed Won - APAC - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;APAC&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureConnect&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureConnect Opportunity Closed Won-EMEA-All</fullName>
        <actions>
            <name>PS_Email_Template_for_EMEA_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureConnect Opportunity Closed Won - EMEA - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;EMEA&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureConnect&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureConnect Opportunity Closed Won-LATAM-All</fullName>
        <actions>
            <name>PS_Email_Template_for_LATAM_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureConnect Opportunity Closed Won - LATAM - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;Latin America&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureConnect&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureConnect Opportunity Closed Won-North America-All</fullName>
        <actions>
            <name>PS_Email_Template_for_North_America_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureConnect Opportunity Closed Won - North America - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;North America&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureConnect&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureEngage Opportunity Closed Won-APAC-All</fullName>
        <actions>
            <name>PS_Email_Template_for_APAC_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureEngage Opportunity Closed Won - APAC - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;APAC&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureEngage&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureEngage Opportunity Closed Won-EMEA-All</fullName>
        <actions>
            <name>PS_Email_Template_for_EMEA_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureEngage Opportunity Closed Won - EMEA - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;EMEA&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureEngage&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureEngage Opportunity Closed Won-LATAM-All</fullName>
        <actions>
            <name>PS_Email_Template_for_LATAM_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureEngage Opportunity Closed Won - LATAM - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;Latin America&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureEngage&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PS PureEngage Opportunity Closed Won-North America-All</fullName>
        <actions>
            <name>PS_Email_Template_for_North_America_All</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PS PureEngage Opportunity Closed Won - North America - filtered by Opportunity threshold value and send to all</description>
        <formula>AND(  ISPICKVAL( StageName, &quot;6.Closed&quot;),  RecordType.Name = &quot;Professional Services&quot;,  ISPICKVAL( PS_Region__c, &quot;North America&quot;),  ISPICKVAL( Win_Loss_Status__c , &quot;Won&quot;),  ISPICKVAL( PS_Line_of_Business__c, &quot;PureEngage&quot;),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Cloud&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;ARM&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;Decisions&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Outbound&quot;)),  NOT(ISPICKVAL( PS_Business_Units__c , &quot;PureEngage Premier&quot;)),  OR ( CloseDate &gt;= TODAY(), CloseDate &gt; (TODAY()-30) ),  Win_Email_Sent__c = false,  $User.BypassWorkflows__c = false,  OR  (  AND(ISPICKVAL(CurrencyIsoCode, &quot;USD&quot;), Amount &gt;= 100000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;EUR&quot;), Amount &gt;= 75000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;GBP&quot;), Amount &gt;= 60000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;JPY&quot;), Amount &gt;= 10000000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;AUD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;NZD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;SGD&quot;), Amount &gt;= 150000),  AND(ISPICKVAL(CurrencyIsoCode, &quot;BRL&quot;), Amount &gt;= 200000)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Partner Notification Opportunity Amount Update</fullName>
        <actions>
            <name>Partner_Notification_Opportunity_Amount_Update</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>notification to the Partner who submitted the Opportunity</description>
        <formula>AND ( NOT($User.BypassWorkflows__c), ISCHANGED( Amount ),   PRIORVALUE(Amount) &gt; 0,  NOT ( ISNEW() ), ISPICKVAL(Partner_Opportunity_Source__c,&quot;Partner Registered Opportunity&quot;), NOT (ISNULL(Partner_Submitted_Opportunity__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Partner Notification Opportunity Pipeline Stage Update</fullName>
        <actions>
            <name>Partner_Notification_Opportunity_Pipeline_Stage_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>notification to the Partner who submitted the Opportunity</description>
        <formula>AND ( NOT($User.BypassWorkflows__c), NOT (ISNEW()), ISCHANGED(StageName),   ISPICKVAL(Partner_Opportunity_Source__c,&quot;Partner Registered Opportunity&quot;), NOT (ISNULL(Partner_Submitted_Opportunity__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Partner Op Notification for Claire Flatley</fullName>
        <actions>
            <name>Partner_Op_Creation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND 3) AND (4 or 6) AND 5 AND 7</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Lead_Offer__c</field>
            <operation>equals</operation>
            <value>PureCloud,PureConnect Cloud,PureEngage Cloud,PureEngage Cloud Partner PPU,PureConnect Cloud Partner PPU</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Direct_Indirect_Sale__c</field>
            <operation>equals</operation>
            <value>Indirect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>notEqual</operation>
            <value>Lost,Merged/Dup Opp,Short Term Return to Nurture</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>5.Purchase Solution</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notifies Claire Flatley and CSM owner when Op Lead Platform = PEC, PCC, PC or PPU and Op $ &gt;0</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Partner Opportunity Converted Email Notification</fullName>
        <actions>
            <name>Partner_Opportunity_Converted_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Partner_Opportunity_Source__c</field>
            <operation>equals</operation>
            <value>Partner Registered Opportunity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Partner_Submitted_Opportunity__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Partner Opportunity Converted Email Notification</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Partner Opportunity Created Alert</fullName>
        <actions>
            <name>Partner_Opportunity_Created_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Partner_Opportunity_Source__c</field>
            <operation>equals</operation>
            <value>Partner Sourced not registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Cloud Renewal</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Partner Opportunity Forecast Status Update</fullName>
        <actions>
            <name>Partner_Notification_on</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>notification to the Partner who submitted the Opportunity</description>
        <formula>AND ( NOT($User.BypassWorkflows__c), NOT (ISNEW()), ISCHANGED(ForecastStatus__c),   ISPICKVAL(Partner_Opportunity_Source__c,&quot;Partner Registered Opportunity&quot;), NOT (ISNULL(Partner_Submitted_Opportunity__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Marketing Sourced Opportunity</fullName>
        <actions>
            <name>Update_Opportunity_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Partner_Opportunity_Source__c</field>
            <operation>notContain</operation>
            <value>partner,marketing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.LeadDevelopmentRep__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Marketing_Program_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Time Stamp Pipeline Added</fullName>
        <actions>
            <name>Populate_Pipeline_Added_06242016</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>DL 7/5 - It will add a time stamp whenever the Term License Amount (ACV), Annual Contract Value (ACV), License Amount values get added from either $0 or blank</description>
        <formula>AND( OR(ACV_Subscription_Only__c &gt; 0,   License_Amount__c &gt; 0,  Term_License__c &gt; 0),  ISBLANK(Pipeline_Added_Date__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pre-Game Opp Decline Notification</fullName>
        <actions>
            <name>Pre_Game_Decline_Manager_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>4. Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PreGame Opportunity check</fullName>
        <actions>
            <name>PreGame_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Pre-GAME Opp</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prem Perpetual Oppty Approval Request - APAC</fullName>
        <actions>
            <name>Prem_Perpetual_Oppty_Approval_Request_APAC</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(
NOT($User.BypassWorkflows__c), 
ISCHANGED(Prem_Perpetual_Approval__c), 
TEXT(Prem_Perpetual_Approval__c) = &quot;Approval Requested&quot;, 
TEXT(Sold_To_Country__r.Region__c) = &quot;APAC&quot;,
 (TEXT(Lead_Offer__c) = &quot;PureEngage Premise&quot; || TEXT(Lead_Offer__c) = &quot;PureConnect Premise&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prem Perpetual Oppty Approval Request - EMEA</fullName>
        <actions>
            <name>Prem_Perpetual_Oppty_Approval_Request_EMEA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(
NOT($User.BypassWorkflows__c), 
ISCHANGED(Prem_Perpetual_Approval__c), 
TEXT(Prem_Perpetual_Approval__c) = &quot;Approval Requested&quot;, 
TEXT(Sold_To_Country__r.Region__c) = &quot;EMEA&quot;,
 (TEXT(Lead_Offer__c) = &quot;PureEngage Premise&quot; || TEXT(Lead_Offer__c) = &quot;PureConnect Premise&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prem Perpetual Oppty Approval Request - LATAM</fullName>
        <actions>
            <name>Prem_Perpetual_Oppty_Approval_Request_LATAM</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(
NOT($User.BypassWorkflows__c), 
ISCHANGED(Prem_Perpetual_Approval__c), 
TEXT(Prem_Perpetual_Approval__c) = &quot;Approval Requested&quot;, 
TEXT(Sold_To_Country__r.Region__c) = &quot;LATAM&quot;,
 (TEXT(Lead_Offer__c) = &quot;PureEngage Premise&quot; || TEXT(Lead_Offer__c) = &quot;PureConnect Premise&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prem Perpetual Oppty Approval Request - NA</fullName>
        <actions>
            <name>Prem_Perpetual_Oppty_Approval_Request_NA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(
NOT($User.BypassWorkflows__c), 
ISCHANGED(Prem_Perpetual_Approval__c), 
TEXT(Prem_Perpetual_Approval__c) = &quot;Approval Requested&quot;, 
TEXT(Sold_To_Country__r.Region__c) = &quot;North America&quot;,
 (TEXT(Lead_Offer__c) = &quot;PureEngage Premise&quot; || TEXT(Lead_Offer__c) = &quot;PureConnect Premise&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prem Perpetual Oppty Approved</fullName>
        <actions>
            <name>Prem_Perpetual_Oppty_Approved</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(
NOT($User.BypassWorkflows__c), 
ISCHANGED(Prem_Perpetual_Approval__c), 
TEXT(Prem_Perpetual_Approval__c) = &quot;Approved&quot;, 
 (TEXT(Lead_Offer__c) = &quot;PureEngage Premise&quot; || TEXT(Lead_Offer__c) = &quot;PureConnect Premise&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prem Perpetual Oppty Declined</fullName>
        <actions>
            <name>Prem_Perpetual_Oppty_Declined</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(
NOT($User.BypassWorkflows__c), 
ISCHANGED(Prem_Perpetual_Approval__c), 
TEXT(Prem_Perpetual_Approval__c) = &quot;Declined&quot;, 
 (TEXT(Lead_Offer__c) = &quot;PureEngage Premise&quot; || TEXT(Lead_Offer__c) = &quot;PureConnect Premise&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PureCloud Stage 5 Notification</fullName>
        <actions>
            <name>PureCloud_Stage_5_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 or 4) AND (2 and 3 and 5 and 6) AND 7</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>5.Purchase Solution</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Offer__c</field>
            <operation>equals</operation>
            <value>PureCloud</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>ABC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>ABC Test,123 Company</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>notEqual</operation>
            <value>Lost,Merged/Dup Opp</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notifies a group of people when a subscription deal reaches stage 5 or stage 6</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reminder - Oppt 1 Day Past Close Date</fullName>
        <actions>
            <name>MKTG_Reminder_1_Days_Past_Oppt_Close_Date</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Sent_Alert_Oppt_Expired_1_Days_Ago</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <description>An alert goes out when an Opportunity (that meets the specific criteria) is 1 day after the close date</description>
        <formula>AND(( CloseDate &gt; DATEVALUE(&quot;2016-11-30&quot;)), (Cloud_Renewal__c = false), (RecordTypeId = &quot;012U0000000LrBP&quot;),NOT( ISPICKVAL(StageName,&quot;6.Closed&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rental Closed Won - APAC</fullName>
        <actions>
            <name>Rental_Opportunity_Closed_Won_APAC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 23,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 16,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 3,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 94,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>equals</operation>
            <value>Rental</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Rental Closed Won - APAC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rental Closed Won - EMEA</fullName>
        <actions>
            <name>Rental_Opportunity_Closed_Won_EMEA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 23,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 16,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 3,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 94,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>equals</operation>
            <value>Rental</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Rental Closed Won - EMEA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rental Closed Won - LATAM</fullName>
        <actions>
            <name>Rental_Opportunity_Closed_Won_LATAM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 23,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 16,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 3,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 94,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>equals</operation>
            <value>Rental</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Rental Closed Won - LATAM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rental Closed Won - NA</fullName>
        <actions>
            <name>Rental_Opportunity_Closed_Won_NA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 23,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 16,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 3,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 94,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>equals</operation>
            <value>Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Rental Closed Won - NA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rental Win Announcements</fullName>
        <actions>
            <name>Rental_Opportunity_Closed_Won</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent_Rental</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5 AND 6 AND 7 and 8 AND (9 OR 10 OR 11 OR 12) AND 13 AND 14 and 15 and 16</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Subscription_Rental_Win_Announcements__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Offer__c</field>
            <operation>contains</operation>
            <value>Rental</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Rental Win Announcements</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Revenue to be Recognized date</fullName>
        <actions>
            <name>Revenue_to_be_Recognized_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp; 
OR(ISCHANGED(CloseDate), ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stage 1 is set</fullName>
        <actions>
            <name>Set_Stage_1_Date_to_TODAY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>1.Understand Needs</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage 2 is set</fullName>
        <actions>
            <name>Set_Stage_2_Date_to_TODAY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>2.Define Requirements</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage 3 is set</fullName>
        <actions>
            <name>Set_Stage_3_Date_to_TODAY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>3.Evaluate Options</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage 4 is set</fullName>
        <actions>
            <name>Set_Stage_4_Date_to_TODAY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>4.Build Consensus</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage 5 is set</fullName>
        <actions>
            <name>Set_Stage_5_Date_to_TODAY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>5.Purchase Solution</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage Name Update</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage changed out of Stage 1</fullName>
        <actions>
            <name>Set_Number_of_Days_in_Stage_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c)
&amp;&amp;
ISPICKVAL( PRIORVALUE( StageName ) , &quot;1.Understand Needs&quot; )
&amp;&amp;
ISCHANGED( StageName )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Subscription Closed Won - APAC</fullName>
        <actions>
            <name>Subscription_Opportunity_Closed_Won_APAC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 23,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 16,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 3,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 94,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>equals</operation>
            <value>Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Subscription Closed Won - APAC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Subscription Closed Won - EMEA</fullName>
        <actions>
            <name>Subscription_Opportunity_Closed_Won_EMEA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 23,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 16,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 3,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 94,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>equals</operation>
            <value>Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Subscription Closed Won - EMEA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Subscription Closed Won - LATAM</fullName>
        <actions>
            <name>Subscription_Opportunity_Closed_Won_LATAM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 23,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 16,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 3,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 94,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>equals</operation>
            <value>Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Subscription Closed Won - LATAM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Subscription Closed Won - NA</fullName>
        <actions>
            <name>Subscription_Opportunity_Closed_Won_NA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15 AND 18 AND 19 AND 20 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 25,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 23,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 16,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 3,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Term_License_Amount_TCV__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 94,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>equals</operation>
            <value>,JPY 0,USD 0,BRL 0,GBP 0,EUR 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>equals</operation>
            <value>Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>contains</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Subscription Closed Won - NA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Subscription Stage 5 Notification</fullName>
        <actions>
            <name>Subscription_Stage_5_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 or 4) AND (2 and 3 and 5 and 6) AND 7</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>5.Purchase Solution</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Offer__c</field>
            <operation>equals</operation>
            <value>PureConnect Premise Subscription,PureEngage Premise Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>ABC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>ABC Test,123 Company</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>notEqual</operation>
            <value>Lost,Merged/Dup Opp</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notifies a group of people when a subscription deal reaches stage 5 or stage 6</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Subscription Win Announcements</fullName>
        <actions>
            <name>Subscription_Opportunity_Closed_Won</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Sent_Rental</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5 AND 6 AND 7 and 8 AND (9 OR 10 OR 11 OR 12) AND 13 AND 14 AND 15 AND 16 AND 17</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterThan</operation>
            <value>12/29/2018</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Subscription_Rental_Win_Announcements__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>LATAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Country_Region__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>equals</operation>
            <value>Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Email_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Offer__c</field>
            <operation>contains</operation>
            <value>PureConnect Premise Subscription,PureEngage Premise Subscription</value>
        </criteriaItems>
        <description>Subscription Win Announcements</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Test Opportunity Closed Won</fullName>
        <actions>
            <name>Test_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR (4 AND 5) OR (6 AND 7) OR (8 AND 9) OR (16 AND 17))AND 10 and 11 and 12 AND (13 OR 14) AND 15</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 250,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>USD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;EUR 200,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>EUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;GBP 160,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>GBP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;JPY 20,000,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>JPY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.AE_Role__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PPU_Usage__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>notContain</operation>
            <value>PPU</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.License_Amount__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;BRL 500,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CurrencyIsoCode</field>
            <operation>equals</operation>
            <value>BRL</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Amount of Time Opportunity was Open</fullName>
        <actions>
            <name>Amount_of_Time_Opp_is_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Create open air project</fullName>
        <actions>
            <name>Set_openair_to_true</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Change Create open air project to true when forecast status is 1. In Hand</description>
        <formula>AND(  NOT($User.BypassWorkflows__c = True),    NOT( $User.Id =&apos;005U0000001wVCX&apos;),  RecordTypeId =&apos;012U0000000MEzQ&apos;, NOT(ISPICKVAL(PRIORVALUE(ForecastStatus__c),&apos;1.In Hand&apos;)), NOT(ISPICKVAL(PRIORVALUE(ForecastStatus__c),&apos;6.Omitted&apos;)), Create_OpenAir_Project__c = False,  ISPICKVAL( PS_Line_of_Business__c, &apos;PureEngage&apos; ), OR( AND(ISPICKVAL(ForecastStatus__c,&apos;1.In Hand&apos;), ISPICKVAL(Win_Loss_Status__c,&apos;Won&apos;)), AND(ISPICKVAL(ForecastStatus__c,&apos;6.Omitted&apos;), ISPICKVAL(Win_Loss_Status__c,&apos;No Decision&apos;)), AND(ISPICKVAL(ForecastStatus__c,&apos;6.Omitted&apos;), ISPICKVAL(Win_Loss_Status__c,&apos;Merged/Dup Opp&apos;)), AND(ISPICKVAL(ForecastStatus__c,&apos;6.Omitted&apos;), ISPICKVAL(Win_Loss_Status__c,&apos;Lost&apos;)) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Forecast status to %27Expected%27%2E</fullName>
        <actions>
            <name>Forecast_status_to_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Partners move Ops to Stage 5.Purchase Solution we default to the Forecast Status = Expected</description>
        <formula>AND( ISPICKVAL(StageName, &apos;5.Purchase Solution&apos;),  TEXT($User.UserType) == &apos;PowerPartner&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity Source to Migration</fullName>
        <actions>
            <name>Update_to_Migration_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Direct_Indirect_Sale__c</field>
            <operation>equals</operation>
            <value>Indirect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Existing Business - Platform Migration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Partner_Opportunity_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Partner_Opportunity_Source__c</field>
            <operation>equals</operation>
            <value>Partner Registered Opportunity</value>
        </criteriaItems>
        <description>Type= Existing Business – Platform Migration
Direct/Indirect Sales = Indirect
Approval Status = Approved 
Partner Portal Opportunity =/ Null</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Send_Welcome_Kit</fullName>
        <assignedToType>owner</assignedToType>
        <description>se the Template under Genesys Templates folder to send the Welcome Kit.</description>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send Welcome Kit</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_APAC_Oppt_Untouched_14_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Sent Alert: APAC Oppt Untouched 14 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_APAC_Oppt_Untouched_21_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: APAC Oppt Untouched 21 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_APAC_Oppt_Untouched_28_Days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: APAC Oppt Untouched 28 Days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_APAC_Oppt_Untouched_35_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: APAC Oppt Untouched 35 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_EMEA_Oppt_Untouched_14_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: EMEA Oppt Untouched 14 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_EMEA_Oppt_Untouched_21_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: EMEA Oppt Untouched 21 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_EMEA_Oppt_Untouched_28_Days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: EMEA Oppt Untouched 28 Days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_EMEA_Oppt_Untouched_35_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: EMEA Oppt Untouched 35 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_LATAM_Oppt_Untouched_14_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: LATAM Oppt Untouched 14 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_LATAM_Oppt_Untouched_21_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: LATAM Oppt Untouched 21 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_LATAM_Oppt_Untouched_28_Days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: LATAM Oppt Untouched 28 Days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_LATAM_Oppt_Untouched_35_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: LATAM Oppt Untouched 35 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_North_America_Oppt_Untouched_14_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: North America Oppt Untouched 14 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_North_America_Oppt_Untouched_21_days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: North America Oppt Untouched 21 days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_North_America_Oppt_Untouched_28_Days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: North America Oppt Untouched 28 Days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_North_America_Oppt_Untouched_35_Days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Sent Alert: North America Oppt Untouched 35 Days</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_Oppt_Expired_14_Days_Ago</fullName>
        <assignedTo>debora.lane@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Sent Alert: Oppt Expired 14 Days Ago</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_Oppt_Expired_1_Day_Ago</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Sent Alert: Oppt Expired 1 Day Ago</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_Oppt_Expired_1_Days_Ago</fullName>
        <assignedTo>debora.lane@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Sent Alert: Oppt Expired 1 Day Ago</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_Oppt_Expired_7_Days_Ago</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Sent Alert: Oppt Expired 7 Days Ago</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Alert_Oppt_Expires_in_5_Days</fullName>
        <assignedTo>nik.mills@genesys.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>3-Medium</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Sent Alert: Oppt Expires in 5 Days</subject>
    </tasks>
</Workflow>
