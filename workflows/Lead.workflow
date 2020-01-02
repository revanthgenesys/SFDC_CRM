<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Genesys_Consultant</fullName>
        <description>Genesys Consultant Program</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Genesys_Consultant_Program_Registration</template>
    </alerts>
    <alerts>
        <fullName>MKTG_Premier_Lead_Assignment</fullName>
        <description>MKTG Premier Lead Assignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>anissa.khalid@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>damon.fong@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eric.orton@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>heidi.parcell@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jim.casey@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ross.hays@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>marketingoperations@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Operations/MKTG_Premier_Lead_Assignment</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Leads_APAC</fullName>
        <description>MQL/Hot Lead Notification - Leads - APAC</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <recipient>ken.cang@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/New_Lead_MQL_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Leads_Canada</fullName>
        <description>MQL/Hot Lead Notification - Leads - Canada</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <recipient>catherine.fortuna@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/New_Lead_MQL_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Leads_EMEA</fullName>
        <description>MQL/Hot Lead Notification - Leads - EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <recipient>paul.stephen@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/New_Lead_MQL_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Leads_Japan</fullName>
        <description>MQL/Hot Lead Notification - Leads - ANZ</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <recipient>ami.mullenger@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/New_Lead_MQL_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Leads_LATAM</fullName>
        <description>MQL/Hot Lead Notification - Leads - LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <recipient>sandra.pina@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/New_Lead_MQL_Alert</template>
    </alerts>
    <alerts>
        <fullName>MQL_Hot_Lead_Notification_Leads_North_America</fullName>
        <description>MQL/Hot Lead Notification - Leads - North America</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <recipient>heidi.parcell@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lukau.matuka@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/New_Lead_MQL_Alert</template>
    </alerts>
    <alerts>
        <fullName>Marketing_New_Lead_MQL_Alert</fullName>
        <ccEmails>Solange.Carvalho@inin.com</ccEmails>
        <description>Marketing New Lead MQL Alert</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/New_Lead_MQL_Alert</template>
    </alerts>
    <alerts>
        <fullName>Marketing_New_Lead_MQL_Alert1</fullName>
        <ccEmails>Solange.Carvalho@inin.com</ccEmails>
        <description>Marketing New Lead MQL Alert</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
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
        <senderType>CurrentUser</senderType>
        <template>Genesys_Templates/New_Lead_MQL_Alert</template>
    </alerts>
    <alerts>
        <fullName>New_Marketing_Lead_Alert_AMERICAS</fullName>
        <description>New Marketing Lead Alert-AMERICAS</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Lead_Alert</template>
    </alerts>
    <alerts>
        <fullName>New_Marketing_Lead_Alert_APAC</fullName>
        <description>New Marketing Lead Alert-APAC</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Lead_Alert</template>
    </alerts>
    <alerts>
        <fullName>New_Marketing_Lead_Alert_EMEA</fullName>
        <description>New Marketing Lead Alert-EMEA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Lead_Alert</template>
    </alerts>
    <alerts>
        <fullName>New_Marketing_Lead_Alert_GLOBAL</fullName>
        <description>New Marketing Lead Alert-GLOBAL</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Lead_Alert</template>
    </alerts>
    <alerts>
        <fullName>New_Marketing_Lead_Alert_LATAM</fullName>
        <description>New Marketing Lead Alert-LATAM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/New_Marketing_Lead_Alert</template>
    </alerts>
    <alerts>
        <fullName>Premier_Hot_Lead_12_Hour</fullName>
        <description>Premier Hot Lead 12 Hour</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>anissa.khalid@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>arnaud.kraaijvanger@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>brady.meltzer@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>curtis.hartmann1@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eric.orton@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>heidi.parcell@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jim.casey@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john.toler@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lisa.kost@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ross.hays@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>russell.foster@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/Premier_Hot_Lead_12_Hour</template>
    </alerts>
    <alerts>
        <fullName>Premier_Hot_Lead_24_Hour</fullName>
        <description>Premier Hot Lead 24 Hour</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>anissa.khalid@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>arnaud.kraaijvanger@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>brady.meltzer@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>curtis.hartmann1@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eric.orton@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>heidi.parcell@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jim.casey@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john.toler@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>josh.abich@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lisa.kost@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ross.hays@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>russell.foster@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/Premier_Hot_Lead_24_Hour</template>
    </alerts>
    <alerts>
        <fullName>Premier_Hot_Lead_2_Hour</fullName>
        <description>Premier Hot Lead 2 Hour</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>anissa.khalid@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>arnaud.kraaijvanger@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>brady.meltzer@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>curtis.hartmann1@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eric.orton@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>heidi.parcell@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jim.casey@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john.toler@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>josh.abich@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lisa.kost@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ross.hays@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>russell.foster@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/Premier_Hot_Lead_2_Hour</template>
    </alerts>
    <alerts>
        <fullName>Premier_Hot_Lead_Assignment</fullName>
        <description>Premier Hot Lead Assignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>anissa.khalid@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>arnaud.kraaijvanger@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>brady.meltzer@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>curtis.hartmann1@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dave.rennyson@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>david.bukovsky@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eric.orton@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>heidi.parcell@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jim.casey@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john.toler@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>josh.abich@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lisa.kost@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>richard.brown@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ross.hays@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>russell.foster@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/Premier_Hot_Lead_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Premier_Hot_Lead_Reassigned_to_LDR</fullName>
        <description>Premier Hot Lead Reassigned to LDR</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>anissa.khalid@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>arnaud.kraaijvanger@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>curtis.hartmann1@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eric.orton@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>heidi.parcell@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jim.casey@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john.toler@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lisa.kost@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ross.hays@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>russell.foster@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Operations/Premier_Hot_Lead_Reassigned_to_LDR</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_to_Cloud_LDR</fullName>
        <field>OwnerId</field>
        <lookupValue>heidi.parcell@genesys.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to Cloud LDR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Call_LDR_Assignment</fullName>
        <field>Call_Lead_Assignment__c</field>
        <literalValue>1</literalValue>
        <name>Call LDR Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_LDR_status_to_Engaged</fullName>
        <description>Changes the LDR status to Engaged</description>
        <field>LDR_Status__c</field>
        <literalValue>Engaged</literalValue>
        <name>Change LDR status to Engaged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_LDR_Status_Field</fullName>
        <description>Clears the LDR Status when specific Lead Status is chosen</description>
        <field>LDR_Status__c</field>
        <name>Clear LDR Status Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Premier_Hot_Lead_Process</fullName>
        <field>Trigger_Hot_Lead_Process__c</field>
        <literalValue>0</literalValue>
        <name>Clear Premier Hot Lead Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Lead_Create_Date_for_Dashboard</fullName>
        <field>Dashboard_Create_Date__c</field>
        <formula>CreatedDate</formula>
        <name>Copy Lead Create Date for Dashboard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Lead_Status_for_MCL</fullName>
        <field>Lead_Status_Prior_to_Conversion__c</field>
        <literalValue>MCL (Marketing Captured Lead)</literalValue>
        <name>Copy Lead Status for MCL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Lead_Status_for_MQL</fullName>
        <field>Lead_Status_Prior_to_Conversion__c</field>
        <literalValue>MQL (Marketing Qualified Lead)</literalValue>
        <name>Copy Lead Status for MQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Lead_Status_for_MQL_Engaged</fullName>
        <field>Lead_Status_Prior_to_Conversion__c</field>
        <literalValue>MQL Engaged</literalValue>
        <name>Copy Lead Status for MQL Engaged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Lead_Status_for_No_Potential</fullName>
        <field>Lead_Status_Prior_to_Conversion__c</field>
        <literalValue>No Potential</literalValue>
        <name>Copy Lead Status for No Potential</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Lead_Status_for_Recycled</fullName>
        <field>Lead_Status_Prior_to_Conversion__c</field>
        <literalValue>Recycle</literalValue>
        <name>Copy Lead Status for Recycled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Lead_Status_for_SQL</fullName>
        <field>Lead_Status_Prior_to_Conversion__c</field>
        <literalValue>SQL (Sales Qualified Lead)</literalValue>
        <name>Copy Lead Status for SQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Enable_Cloud_Connect_Sync</fullName>
        <field>Cloud_Connect_Sync__c</field>
        <literalValue>1</literalValue>
        <name>Enable Cloud Connect Sync</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Hot_Lead_is_New_MQL</fullName>
        <field>LDR_Status__c</field>
        <literalValue>New</literalValue>
        <name>Hot Lead is New MQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MKTG_Update_Recycle_Date</fullName>
        <field>Recycle_Date__c</field>
        <formula>today()</formula>
        <name>MKTG - Update Recycle Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MKTG_Update_Recycle_Date_on_Lead</fullName>
        <field>Recycle_Date__c</field>
        <formula>today()</formula>
        <name>MKTG - Update Recycle Date on Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_MQL_Engaged_Date_on_Lead</fullName>
        <field>MQL_Engaged_Date__c</field>
        <formula>now()</formula>
        <name>Populate MQL Engaged Date on Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Queue_Name</fullName>
        <field>Queue_Name__c</field>
        <formula>Owner:Queue.QueueName</formula>
        <name>Populate Queue Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_MQL_Date_to_Today</fullName>
        <field>MQL_Date__c</field>
        <formula>Today()</formula>
        <name>Set MQL Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Force_SV_Plan_Assignment</fullName>
        <field>Force_SV_Plan_Assignment_Rules__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Force SV Plan Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Checkbox_Lead_Assigned_to_RQ</fullName>
        <field>Lead_Assigned_to_Routing_Queue__c</field>
        <literalValue>1</literalValue>
        <name>Update Checkbox - Lead Assigned to RQ</name>
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
        <fullName>Update_First_MQL_Touch_Date</fullName>
        <field>First_MQL_Touch__c</field>
        <formula>Today()</formula>
        <name>Update First MQL Touch Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LDR_Status_to_BANT_1</fullName>
        <field>LDR_Status__c</field>
        <literalValue>Bant 1</literalValue>
        <name>Update LDR Status to BANT 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LDR_Status_to_BANT_2</fullName>
        <field>LDR_Status__c</field>
        <literalValue>Bant 2</literalValue>
        <name>Update LDR Status to BANT 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LDR_Status_to_BANT_3</fullName>
        <field>LDR_Status__c</field>
        <literalValue>Bant 3</literalValue>
        <name>Update LDR Status to BANT 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Status_Copy_Known_Name</fullName>
        <field>Lead_Status_Prior_to_Conversion__c</field>
        <literalValue>Known Name</literalValue>
        <name>Update Lead Status Copy Known Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Status_to_MCL</fullName>
        <field>Status</field>
        <literalValue>MCL (Marketing Captured Lead)</literalValue>
        <name>Update Lead Status to MCL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Status_to_MQL</fullName>
        <field>Status</field>
        <literalValue>MQL (Marketing Qualified Lead)</literalValue>
        <name>Update Lead Status to MQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MCL_Date</fullName>
        <field>MCL_Date__c</field>
        <formula>Today()</formula>
        <name>Update MCL Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Privacy_Policy_Acknowledge_Date</fullName>
        <field>Privacy_Policy_Acknowledged_Date__c</field>
        <formula>IF(
AND (  Privacy_Policy_Acknowledged__c ,ISBLANK(  Privacy_Policy_Acknowledged_Date__c )),
NOW() ,
IF (Privacy_Policy_Acknowledged__c , Privacy_Policy_Acknowledged_Date__c, NULL)

)</formula>
        <name>Update Privacy Policy Acknowledge - Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SQL_Date_today</fullName>
        <field>SQL_Date__c</field>
        <formula>Today()</formula>
        <name>Update SQL Date today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Sent_to_Cloud_Connect</fullName>
        <description>This workflow will update the Lead Status field when a Lead is sent to Cloud Connect.</description>
        <field>Status</field>
        <literalValue>Sent to Cloud Connect</literalValue>
        <name>Update Status Sent to Cloud Connect</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>TrayOnLeadWorkflowRule_1RLUCP</fullName>
        <apiVersion>37.0</apiVersion>
        <description>Used by Salesforce to send &quot;webhook&quot; notifications to the tray.io workflow with this URL.</description>
        <endpointUrl>https://57558a80-61db-445f-b1f6-b8d6f39b1f5e-2fff462c49b649e.trayapp.io</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>vikram.sharma@genesys.com.integration1</integrationUser>
        <name>TrayOnLeadWorkflowRule_1RLUCP</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>TrayOnLeadWorkflowRule_oKEdF</fullName>
        <apiVersion>37.0</apiVersion>
        <description>Used by Salesforce to send &quot;webhook&quot; notifications to the tray.io workflow with this URL.</description>
        <endpointUrl>https://57558a80-61db-445f-b1f6-b8d6f39b1f5e-fa20dc33227bf7b.trayapp.io</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>vikram.sharma@genesys.com.integration1</integrationUser>
        <name>TrayOnLeadWorkflowRule_oKEdF</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>ucm__Lead_outbound_messages</fullName>
        <apiVersion>40.0</apiVersion>
        <endpointUrl>http://sfsvc.zinfi.com/services/obm/Lead.asmx</endpointUrl>
        <fields>Company</fields>
        <fields>Email</fields>
        <fields>FirstName</fields>
        <fields>Id</fields>
        <fields>LastName</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>genesys-sf@zinfitech.com</integrationUser>
        <name>Lead outbound messages</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Auto Assign No Potential</fullName>
        <actions>
            <name>Call_LDR_Assignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>No Potential,Inactive</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notContain</operation>
            <value>queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Automatically assign No Potential and Inactive leads to the appropriate queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clear LDR Status</fullName>
        <actions>
            <name>Clear_LDR_Status_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>SQL (Sales Qualified Lead),No Potential,Inactive,Recycle</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
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
        <fullName>Clear Premier Hot Lead Process</fullName>
        <actions>
            <name>Clear_Premier_Hot_Lead_Process</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Trigger_Hot_Lead_Process__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>notEqual</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Connect Sync</fullName>
        <actions>
            <name>Enable_Cloud_Connect_Sync</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow check marks the Cloud Connect Sync field on the Lead object when a lead is owned by the Cloud Connect Lead Queue</description>
        <formula>AND(
OwnerId = &quot;00GU0000000kCkN&quot;,
NOT($User.BypassValidationRules__c = True)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Consultant Lead Notification</fullName>
        <actions>
            <name>Genesys_Consultant</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>ConsultantPortal</value>
        </criteriaItems>
        <description>Consultant Lead Notification</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Copy Campaign Source Opportunity</fullName>
        <active>false</active>
        <description>Copies campaign source data to campaign source opportunity field</description>
        <formula>ISCHANGED( Campaign_Source__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Copy Lead Create Date for Dashboard</fullName>
        <actions>
            <name>Copy_Lead_Create_Date_for_Dashboard</name>
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
        <fullName>Explicit Consent and Privacy Policy Time Stamps - Leads</fullName>
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
        <description>Updates the related time stamps when any of these fields are check</description>
        <formula>OR(  ISCHANGED( Explicit_Consent_Email__c ) ,  ISCHANGED( Explicit_Consent_Phone__c ) ,  ISCHANGED(  Privacy_Policy_Acknowledged__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead Assigned to Routing Queue</fullName>
        <actions>
            <name>Update_Checkbox_Lead_Assigned_to_RQ</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW() || ISCHANGED(OwnerId)) &amp;&amp; (OwnerId = &apos;00GU0000001hYSy&apos; || OwnerId = &apos;00GU0000001hYSyMAM&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead Becomes MCL</fullName>
        <actions>
            <name>Update_Lead_Status_to_MCL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_MCL_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( Behavior_Score__c &gt; 4,  ISPICKVAL( Status , &apos;Inquiry&apos;) , NOT( ISNULL( LastName )) ,NOT( ISNULL(  Company )) ,NOT( ISNULL(   Country__r.Name   )),NOT( ISNULL(   Title   )),NOT( ISNULL(    Email    )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Becomes to Hot Lead MQL</fullName>
        <actions>
            <name>Marketing_New_Lead_MQL_Alert1</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/1/2016</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notContain</operation>
            <value>Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Triggers MQL Notification to LDR</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Becomes to MQL</fullName>
        <actions>
            <name>Marketing_New_Lead_MQL_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/1/2016</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notContain</operation>
            <value>Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Triggers MQL Notification to LDR</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Conversion Status Inactive</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Inactive</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Maintain the Lead Status after the lead get converted for Inactive</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Conversion Status Known Name</fullName>
        <actions>
            <name>Update_Lead_Status_Copy_Known_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Known Name</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Maintain the Lead Status after the lead get converted for Known Name</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Conversion Status MCL</fullName>
        <actions>
            <name>Copy_Lead_Status_for_MCL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MCL (Marketing Captured Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Maintain the Lead Status after the lead get converted for MCL</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Conversion Status MQL</fullName>
        <actions>
            <name>Copy_Lead_Status_for_MQL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Maintain the Lead Status after the lead get converted for MQL</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Conversion Status MQL Engaged</fullName>
        <actions>
            <name>Copy_Lead_Status_for_MQL_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL Engaged</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Maintain the Lead Status after the lead get converted for MQL Engaged</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Conversion Status No Potential</fullName>
        <actions>
            <name>Copy_Lead_Status_for_No_Potential</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>No Potential</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Maintain the Lead Status after the lead get converted for No Potential</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Conversion Status Recycle</fullName>
        <actions>
            <name>Copy_Lead_Status_for_Recycled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Recycle</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Maintain the Lead Status after the lead get converted for Recycle</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Conversion Status SQL</fullName>
        <actions>
            <name>Copy_Lead_Status_for_SQL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>SQL (Sales Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Maintain the Lead Status after the lead get converted for SQL</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Status Sent to Cloud Connect</fullName>
        <actions>
            <name>Update_Status_Sent_to_Cloud_Connect</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Cloud_Connect_Sync__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow updates the Lead Status to &quot;Sent to Cloud Connect&quot; when the Cloud Connect Sync value is true.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Populate MQL Engaged Date Lead</fullName>
        <actions>
            <name>Populate_MQL_Engaged_Date_on_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
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
        <fullName>MKTG - Populate Recycle Date</fullName>
        <actions>
            <name>MKTG_Update_Recycle_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
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
        <fullName>MKTG - Populate Recycle Date Lead</fullName>
        <actions>
            <name>MKTG_Update_Recycle_Date_on_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Recycle</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>DL 11/17 Requested by Mellisa Luis</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MKTG - Premier Lead Assignment</fullName>
        <actions>
            <name>MKTG_Premier_Lead_Assignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT($User.BypassWorkflows__c),ISCHANGED(OwnerId),CONTAINS(Owner:User.UserRole.Name, &quot;Corporate Sales Rep&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MQL Engaged</fullName>
        <actions>
            <name>Change_LDR_status_to_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL Engaged</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>notEqual</operation>
            <value>Bant 2,Bant 1,Bant 3</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Authority__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Budget__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Timing__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Need__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow will update the LDR status to engaged when the Lead Status is changed to MQL Engaged</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Lead - APAC</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Leads_APAC</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/1/2016</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notContain</operation>
            <value>Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Leads_Region__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Country_Name__c</field>
            <operation>notEqual</operation>
            <value>Japan</value>
        </criteriaItems>
        <description>Triggers MQL/Hot Lead Notification to LDR and LDR Management</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Lead - EMEA</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Leads_EMEA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/1/2016</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notContain</operation>
            <value>Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Leads_Region__c</field>
            <operation>equals</operation>
            <value>EMEA</value>
        </criteriaItems>
        <description>Triggers MQL/Hot Lead Notification to LDR and LDR Management</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Lead - Japan</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Leads_Japan</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/1/2016</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notContain</operation>
            <value>Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Leads_Region__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Country_Name__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <description>Triggers MQL/Hot Lead Notification to LDR and LDR Management</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Lead - LATAM</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Leads_LATAM</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/1/2016</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notContain</operation>
            <value>Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Leads_Region__c</field>
            <operation>equals</operation>
            <value>LATAM</value>
        </criteriaItems>
        <description>Triggers MQL/Hot Lead Notification to LDR and LDR Management</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MQL%2FHot Lead Notification - Lead - North America</fullName>
        <actions>
            <name>MQL_Hot_Lead_Notification_Leads_North_America</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL (Marketing Qualified Lead)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.MQL_Date__c</field>
            <operation>greaterThan</operation>
            <value>5/1/2016</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New,Hot Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notContain</operation>
            <value>Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Leads_Region__c</field>
            <operation>equals</operation>
            <value>North America</value>
        </criteriaItems>
        <description>Triggers MQL/Hot Lead Notification to LDR and LDR Management</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate First MQL Touch Date</fullName>
        <actions>
            <name>Update_First_MQL_Touch_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Lead.MQL_Date__c</field>
            <operation>equals</operation>
            <value>LAST 30 DAYS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>notEqual</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>MQL Engaged,SQL (Sales Qualified Lead),Converted,Recycle,No Potential,Inactive</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Queue Name on Leads</fullName>
        <actions>
            <name>Populate_Queue_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>DL 2/8 Requested by Ross Hays</description>
        <formula>ISCHANGED( OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Premier Hot Lead - Step 1</fullName>
        <actions>
            <name>Premier_Hot_Lead_Assignment</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Trigger_Hot_Lead_Process__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Premier Hot Lead - Step 2</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Trigger_Hot_Lead_Process__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Premier_Hot_Lead_2_Hour</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Premier Hot Lead - Step 3</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Trigger_Hot_Lead_Process__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Premier_Hot_Lead_12_Hour</name>
                <type>Alert</type>
            </actions>
            <timeLength>12</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Premier Hot Lead - Step 4</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Trigger_Hot_Lead_Process__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Premier_Hot_Lead_24_Hour</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Premier_Hot_Lead_Reassigned_to_LDR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Assign_to_Cloud_LDR</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>25</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Premier Hot Lead - Step 5</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Trigger_Hot_Lead_Process__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDR_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clear_Premier_Hot_Lead_Process</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>26</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TrayOnLeadWorkflowRule_oKEdF</fullName>
        <actions>
            <name>TrayOnLeadWorkflowRule_oKEdF</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW() || ISCHANGED(OwnerId))  &amp;&amp; (OwnerId = &apos;00GU0000001hYSy&apos; || OwnerId = &apos;00GU0000001hYSyMAM&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update LDR Status to BANT 1</fullName>
        <actions>
            <name>Update_LDR_Status_to_BANT_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(
ISPICKVAL(  Status ,&quot;MQL Engaged&quot;)
,NOT(ISPICKVAL( LDR_Status__c,&quot;Bant 1&quot;))
,NOT(ISPICKVAL( LDR_Status__c,&quot;Bant 2&quot;))
,NOT(ISPICKVAL( LDR_Status__c,&quot;Bant 3&quot;))
,OR(
Budget__c = true
, Authority__c = true
, Need__c = true
, Timing__c = true
)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update LDR Status to BANT 2</fullName>
        <actions>
            <name>Update_LDR_Status_to_BANT_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(
ISPICKVAL( Status ,&quot;MQL Engaged&quot;)
,NOT(ISPICKVAL( LDR_Status__c,&quot;Bant 2&quot;))
,NOT(ISPICKVAL( LDR_Status__c,&quot;Bant 3&quot;))
,OR(
AND(
Budget__c = true
, Authority__c = true)
,AND(
Budget__c = true
, Need__c = true)
,AND(
Budget__c = true
, Timing__c = true)
,AND(
 Authority__c = true
, Need__c = true)
,AND(
 Authority__c = true
, Timing__c = true)
,AND(
Need__c = true
, Timing__c = true)
)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update LDR Status to BANT 3</fullName>
        <actions>
            <name>Update_LDR_Status_to_BANT_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(
ISPICKVAL( Status ,&quot;MQL Engaged&quot;)
,NOT(ISPICKVAL( LDR_Status__c,&quot;Bant 3&quot;))
,OR(
AND(
Budget__c = true
, Authority__c = true
, Need__c = true)
,AND(
Budget__c = true
, Need__c = true
, Timing__c = true)
,AND(
Budget__c = true
, Authority__c = true
, Timing__c = true)
,AND(
Authority__c = true
, Need__c = true
, Timing__c = true)
)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update SQL Date</fullName>
        <actions>
            <name>Update_SQL_Date_today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL(Status, &apos;SQL (Sales Qualified Lead)&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
