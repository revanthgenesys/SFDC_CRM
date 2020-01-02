<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CSOD_User_Creation_Alert</fullName>
        <ccEmails>partners@genesys.com</ccEmails>
        <description>CSOD User Creation Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Portal_Templates/CSOD_User_Creation_External</template>
    </alerts>
    <alerts>
        <fullName>Contact_Net_Promoter_Change</fullName>
        <description>Contact Net Promoter Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>Genesys Advisor</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>debora.lane@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>navaneetha.krishnan@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Contact_Net_Promoter_Change</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Contacts_APAC</fullName>
        <description>MQL/Hot Lead Notification - Contacts - APAC</description>
        <protected>false</protected>
        <recipients>
            <recipient>ken.cang@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Lead_Development_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Contact_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Contacts_Canada</fullName>
        <description>MQL/Hot Lead Notification - Contacts - Canada</description>
        <protected>false</protected>
        <recipients>
            <recipient>catherine.fortuna@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Lead_Development_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Contact_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Contacts_EMEA</fullName>
        <description>MQL/Hot Lead Notification - Contacts - EMEA</description>
        <protected>false</protected>
        <recipients>
            <recipient>paul.stephen@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Lead_Development_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Contact_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Contacts_Japan</fullName>
        <description>MQL/Hot Lead Notification - Contacts - ANZ</description>
        <protected>false</protected>
        <recipients>
            <recipient>ami.mullenger@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Lead_Development_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Contact_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Contacts_LATAM</fullName>
        <description>MQL/Hot Lead Notification - Contacts - LATAM</description>
        <protected>false</protected>
        <recipients>
            <recipient>sandra.pina@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Lead_Development_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Contact_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Contacts_North_America</fullName>
        <description>MQL/Hot Lead Notification - Contacts - North America</description>
        <protected>false</protected>
        <recipients>
            <recipient>heidi.parcell@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lukau.matuka@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Lead_Development_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Contact_Alert</template>
    </alerts>
    <alerts>
        <fullName>Marketing_New_Contact_MQL_Alert</fullName>
        <ccEmails>Solange.Carvalho@inin.com;catherine.fortuna@genesys.com</ccEmails>
        <description>Marketing New Contact MQL Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Marketing_Operations</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>lukau.matuka@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paul.stephen@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>reena.gangwani@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>robert.billing@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sam.glasspool@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sandra.pina@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Lead_Development_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Contact_Alert</template>
    </alerts>
    <alerts>
        <fullName>Marketing_New_Contact_MQL_Alert1</fullName>
        <ccEmails>catherine.fortuna@genesys.com;Solange.Carvalho@inin.com;</ccEmails>
        <description>Marketing New Contact MQL Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Marketing_Operations</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>lukau.matuka@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paul.stephen@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>reena.gangwani@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>robert.billing@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sam.glasspool@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sandra.pina@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Lead_Development_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Contact_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_LDR_Status_to_Engaged_on_Contact</fullName>
        <field>LDR_Status__c</field>
        <literalValue>Engaged</literalValue>
        <name>Change LDR Status to Engaged on Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_LDR_Status_Field_on_Contact</fullName>
        <description>Clears the LDR Status when specific Lead Status is chosen</description>
        <field>LDR_Status__c</field>
        <name>Clear LDR Status Field on Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Contact_Create_Date_for_Dashboard</fullName>
        <field>Dashboard_Create_Date__c</field>
        <formula>CreatedDate</formula>
        <name>Copy Contact Create Date for Dashboard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Department</fullName>
        <field>Department</field>
        <formula>Department_Name__c</formula>
        <name>Department</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DupemasterchangeCTS</fullName>
        <field>CTS_DupeID__c</field>
        <formula>CTS_Master_of_the_duplicate__r.Id</formula>
        <name>DupemasterchangeCTS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MKTG_Populate_Recycle_Date_Contact</fullName>
        <field>Recycle_Date__c</field>
        <formula>now()</formula>
        <name>MKTG - Populate Recycle Date Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MKTG_Update_First_MQL_Touch_Contact</fullName>
        <field>First_MQL_Touch__c</field>
        <formula>today ()</formula>
        <name>MKTG - Update First MQL Touch Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_MQL_Engaged_Date_on_Contact</fullName>
        <field>MQL_Engaged_Date__c</field>
        <formula>now()</formula>
        <name>Populate MQL Engaged Date on Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SelfServiceelement</fullName>
        <description>Check the Self-Service Element to true</description>
        <field>Self_Service_Elements_Access__c</field>
        <literalValue>1</literalValue>
        <name>SelfServiceelement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SelfServiceelementChecked</fullName>
        <description>If All Service element is check true then check the self Service element</description>
        <field>Self_Service_Elements_Access__c</field>
        <literalValue>1</literalValue>
        <name>SelfServiceelementChecked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Force_SV_Plan_Assignment_C</fullName>
        <field>Force_SV_Plan_Assignment_Rules__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Force SV Plan Assignment C</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAllService</fullName>
        <description>Check the all service element and self-service element checkbox.</description>
        <field>All_Service_Elements_Access__c</field>
        <literalValue>1</literalValue>
        <name>UpdateAllService</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateIsMasterContact</fullName>
        <field>IsMasterContact__c</field>
        <formula>AccountId</formula>
        <name>UpdateIsMasterContact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Care_News</fullName>
        <field>Subscribe_To_Customer_Care_News__c</field>
        <literalValue>1</literalValue>
        <name>Update Customer Care News</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Explicit_Consent_Email_Date</fullName>
        <field>Explicit_Consent_Email_Date__c</field>
        <formula>IF( 
AND ( Explicit_Consent_Email__c ,ISBLANK( Explicit_Consent_Email_Date__c )), 
NOW() , 
IF (Explicit_Consent_Email__c , Explicit_Consent_Email_Date__c, NULL) 

)</formula>
        <name>Update Explicit Consent Email - Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Explicit_Consent_Phone_Date</fullName>
        <field>Explicit_Consent_Phone_Date__c</field>
        <formula>IF( 
AND ( Explicit_Consent_Phone__c ,ISBLANK( Explicit_Consent_Phone_Date__c )), 
NOW() , 
IF (Explicit_Consent_Phone__c , Explicit_Consent_Phone_Date__c , NULL) 

)</formula>
        <name>Update Explicit Consent Phone - Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Privacy_Policy_Acknowledge_Date</fullName>
        <field>Privacy_Policy_Acknowledged_Date__c</field>
        <formula>IF( 
AND ( Privacy_Policy_Acknowledged__c ,ISBLANK( Privacy_Policy_Acknowledged_Date__c )), 
NOW() , 
IF (Privacy_Policy_Acknowledged__c , Privacy_Policy_Acknowledged_Date__c, NULL) 

)</formula>
        <name>Update Privacy Policy Acknowledge - Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>cts_qualif_lvl_to_FULL</fullName>
        <field>Contact_qualification_level__c</field>
        <literalValue>1-Full qualification</literalValue>
        <name>cts qualif lvl to FULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>cts_qualif_lvl_to_HIGH</fullName>
        <field>Contact_qualification_level__c</field>
        <literalValue>2-High qualification</literalValue>
        <name>cts qualif lvl to HIGH</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>cts_qualif_lvl_to_MEDIUM</fullName>
        <field>Contact_qualification_level__c</field>
        <literalValue>3-Medium qualification</literalValue>
        <name>cts qualif lvl to MEDIUM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>cts_qualif_lvl_to_POOR</fullName>
        <field>Contact_qualification_level__c</field>
        <literalValue>4-Poor qualification</literalValue>
        <name>cts qualif lvl to POOR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>refedge__Joined_Reference_Program_Date</fullName>
        <description>Update date is written here when &apos;reference program member&apos; flag is first set to checked</description>
        <field>refedge__Joined_Reference_Program__c</field>
        <formula>Today()</formula>
        <name>Joined Reference Program Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>ucm__Contact_outbound_messages</fullName>
        <apiVersion>40.0</apiVersion>
        <endpointUrl>http://sfsvc.zinfi.com/services/obm/Contact.asmx</endpointUrl>
        <fields>AccountId</fields>
        <fields>Email</fields>
        <fields>FirstName</fields>
        <fields>Id</fields>
        <fields>LastName</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>genesys-sf@zinfitech.com</integrationUser>
        <name>Contact outbound messages</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>AllServiceElement</fullName>
        <actions>
            <name>SelfServiceelementChecked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.All_Service_Elements_Access__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If All Service element check self service element</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CSOD User Creation</fullName>
        <actions>
            <name>CSOD_User_Creation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.CSOD_User_Created__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contact Net Promoter Change</fullName>
        <actions>
            <name>Contact_Net_Promoter_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(NPS__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Copy Contact Create Date for Dashboard</fullName>
        <actions>
            <name>Copy_Contact_Create_Date_for_Dashboard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
 Dashboard_Create_Date__c = null,
NOT($User.BypassWorkflows__c)
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF022_Contact qualif level-FULL</fullName>
        <actions>
            <name>cts_qualif_lvl_to_FULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Total_Quality_Rate_Contact__c</field>
            <operation>equals</operation>
            <value>100</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>level of qualification on contacts based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF023_Contact qualif level-HIGH</fullName>
        <actions>
            <name>cts_qualif_lvl_to_HIGH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Total_Quality_Rate_Contact__c</field>
            <operation>lessThan</operation>
            <value>100</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Total_Quality_Rate_Contact__c</field>
            <operation>greaterOrEqual</operation>
            <value>80</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>level of qualification on contacts based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF028_Contact qualif level-POOR</fullName>
        <actions>
            <name>cts_qualif_lvl_to_POOR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Total_Quality_Rate_Contact__c</field>
            <operation>lessOrEqual</operation>
            <value>50</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>level of qualification on contacts based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF029_Contact qualif level-MEDIUM</fullName>
        <actions>
            <name>cts_qualif_lvl_to_MEDIUM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Total_Quality_Rate_Contact__c</field>
            <operation>lessThan</operation>
            <value>80</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Total_Quality_Rate_Contact__c</field>
            <operation>greaterThan</operation>
            <value>50</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>level of qualification on contacts based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF097_Master of the duplicates CONTACT</fullName>
        <actions>
            <name>DupemasterchangeCTS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.CTS_Duplicates__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Fill the Field &apos;Contact: Dupe ID&apos; with the Contact ID of the record in the Look-up</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Explicit Consent and Privacy Policy Time Stamps - Contacts</fullName>
        <actions>
            <name>Update_Explicit_Consent_Email_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Explicit_Consent_Phone_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Privacy_Policy_Acknowledge_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(  ISCHANGED( Explicit_Consent_Email__c ) ,  ISCHANGED( Explicit_Consent_Phone__c ) ,  ISCHANGED( Privacy_Policy_Acknowledged__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Clear LDR Status</fullName>
        <actions>
            <name>Clear_LDR_Status_Field_on_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>SQL (Sales Qualified Lead),Recycle,No Potential,Inactive</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LDR_Status__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>For Contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Contact Becomes Hot Lead MQL</fullName>
        <actions>
            <name>Marketing_New_Contact_MQL_Alert1</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Record_Type_Contact__c</field>
            <operation>equals</operation>
            <value>EMG - Customer / Prospect Contact Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/14/2017</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordType__c</field>
            <operation>equals</operation>
            <value>EMG - Customer Record Type,EMG - Prospect Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LDR_Status__c</field>
            <operation>equals</operation>
            <value>Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.DoNotUseInReport__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Lead_Development_Rep__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Triggers MQL Notification to LDR&apos;s for Contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Contact Becomes MQL</fullName>
        <actions>
            <name>Marketing_New_Contact_MQL_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 And 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Record_Type_Contact__c</field>
            <operation>equals</operation>
            <value>EMG - Customer / Prospect Contact Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/14/2017</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordType__c</field>
            <operation>equals</operation>
            <value>EMG - Customer Record Type,EMG - Prospect Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.DoNotUseInReport__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Lead_Development_Rep__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Triggers MQL Notification to LDR&apos;s for Contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - MQL Engaged Contact</fullName>
        <actions>
            <name>Change_LDR_Status_to_Engaged_on_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL Engaged</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Authority__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Budget__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Timing__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Need__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow will update the LDR status to engaged when the Lead Status is changed to MQL Engaged on the Contact Object</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Populate First MQL Touch Date Contact</fullName>
        <actions>
            <name>MKTG_Update_First_MQL_Touch_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Contact.MQL_Date__c</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LDR_Status__c</field>
            <operation>notEqual</operation>
            <value>New,Accepted - Managing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL Engaged,SQL (Sales Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Populate MQL Engaged Date Contact</fullName>
        <actions>
            <name>Populate_MQL_Engaged_Date_on_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL Engaged</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Populate Recycle Date Contact</fullName>
        <actions>
            <name>MKTG_Populate_Recycle_Date_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>Recycle</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Contact - APAC</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Contacts_APAC</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 And 7 AND 8 AND 9 AND 10</booleanFilter>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Record_Type_Contact__c</field>
            <operation>equals</operation>
            <value>EMG - Customer / Prospect Contact Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/14/2017</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordType__c</field>
            <operation>equals</operation>
            <value>EMG - Customer Record Type,EMG - Prospect Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.DoNotUseInReport__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Lead_Development_Rep__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Region__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Country_Name__c</field>
            <operation>notEqual</operation>
            <value>Japan</value>
        </criteriaItems>
        <description>Triggers MQL Notification to LDR&apos;s and Regional managers for Contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Contact - EMEA</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Contacts_EMEA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 And 7 AND 8 AND 9</booleanFilter>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Record_Type_Contact__c</field>
            <operation>equals</operation>
            <value>EMG - Customer / Prospect Contact Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/14/2017</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordType__c</field>
            <operation>equals</operation>
            <value>EMG - Customer Record Type,EMG - Prospect Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.DoNotUseInReport__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Lead_Development_Rep__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Region__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <description>Triggers MQL Notification to LDR&apos;s and Regional managers for Contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Contact - Japan</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Contacts_Japan</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 And 7 AND 8 AND 9 AND 10</booleanFilter>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Record_Type_Contact__c</field>
            <operation>equals</operation>
            <value>EMG - Customer / Prospect Contact Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/14/2017</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordType__c</field>
            <operation>equals</operation>
            <value>EMG - Customer Record Type,EMG - Prospect Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.DoNotUseInReport__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Lead_Development_Rep__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Region__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Country_Name__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <description>Triggers MQL Notification to LDR&apos;s and Regional managers for Contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Contact - LATAM</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Contacts_LATAM</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 And 7 AND 8 AND 9</booleanFilter>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Record_Type_Contact__c</field>
            <operation>equals</operation>
            <value>EMG - Customer / Prospect Contact Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/14/2017</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordType__c</field>
            <operation>equals</operation>
            <value>EMG - Customer Record Type,EMG - Prospect Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.DoNotUseInReport__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Lead_Development_Rep__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Region__c</field>
            <operation>equals</operation>
            <value>LATAM</value>
        </criteriaItems>
        <description>Triggers MQL Notification to LDR&apos;s and Regional managers for Contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Contact - North America</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Contacts_North_America</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 And 7 AND 8 AND 9</booleanFilter>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Record_Type_Contact__c</field>
            <operation>equals</operation>
            <value>EMG - Customer / Prospect Contact Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/14/2017</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordType__c</field>
            <operation>equals</operation>
            <value>EMG - Customer Record Type,EMG - Prospect Record Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.DoNotUseInReport__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Lead_Development_Rep__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Region__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <description>Triggers MQL Notification to LDR&apos;s and Regional managers for Contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>On Contact Creation</fullName>
        <active>false</active>
        <formula>IF( Country__c != null, true, false)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PureSuccessAllServiceElement</fullName>
        <actions>
            <name>SelfServiceelement</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateAllService</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateIsMasterContact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.PureSuccess_Main_Contact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If Contact is a mail contact for the Account then both All Service element and self service element should be check in.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Customer Care News</fullName>
        <actions>
            <name>Update_Customer_Care_News</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Designated_Contact_Records__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>department name</fullName>
        <actions>
            <name>Department</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(
 Department_Name__c != null,
NOT($User.BypassValidationRules__c = True)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>refedge__WR_InsertJoinedReferenceProgramDate</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Contact.AccountName</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Depricated(Bound 8)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
