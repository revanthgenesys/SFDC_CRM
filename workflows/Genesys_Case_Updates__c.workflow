<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Update_Made_Public_Customer_Notification</fullName>
        <description>Case Update Made Public - Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Case_Contact_Alternate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Auto_Follow_Ups/New_Case_Update_Public_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>Case_owner</fullName>
        <description>Case owner</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>vikram.sharma@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/Case_Owner_Notification</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Case_Update_Type_Change</fullName>
        <ccEmails>michael.davies@genesys.com</ccEmails>
        <description>Cloud Case Update Type Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>prabhuram.doraiswamy@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Old_Templates/Cloud_Case_Update_Type_Change</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Owner_of_New_Case_Update_by_Portal_User</fullName>
        <description>Notify Case Owner of New Case Update by Portal User</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/New_Case_Update_Public_Owner_Noti</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Owner_of_New_Case_Update_for_Critical_Cases</fullName>
        <description>Notify Case Owner of New Case Update for Critical Cases</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/New_Case_Update_Critical_Cases</template>
    </alerts>
    <alerts>
        <fullName>Send_Case_Contact_on_New_Public_Case_Update</fullName>
        <description>Send Case Contact on New Public Case Update</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/New_Case_Update_Public</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Update_Created_by_Portal_User</fullName>
        <field>Created_By_Portal_User__c</field>
        <literalValue>1</literalValue>
        <name>Case Update Created by Portal User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Update_Set_Made_Posted_Date</fullName>
        <field>Posted_Date__c</field>
        <formula>NOW()</formula>
        <name>Case Update: Set Made Posted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Update_Record_Type_to_Public</fullName>
        <description>This field update will change the case comment type to public</description>
        <field>RecordTypeId</field>
        <lookupValue>Public</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Case Update Record Type to Public</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Type_to_Update_from_Customer</fullName>
        <field>Type__c</field>
        <literalValue>Update from Customer</literalValue>
        <name>Update Type to Update from Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case Update Made Public - Customer</fullName>
        <actions>
            <name>Case_Update_Made_Public_Customer_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>notification when a new oublic case update is created or when a Case Update was changed from private to public</description>
        <formula>AND ((NOT($User.BypassWorkflows__c)),      NOT(CONTAINS($Profile.Name, &quot;Portal&quot;)), 	    OR(ISNEW(),             AND((ISCHANGED(Make_Public__c)),      (PRIORVALUE(Make_Public__c) = FALSE))), 	       (Make_Public__c = TRUE),    ( Case__r.ContactId = Case_Contact__c),     (IF(Case__r.RecordType.Name != &quot;Admin&quot; &amp;&amp; ISBLANK(Case__r.End_User_Account__c), false,true))   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Update%3A Set Posted Date</fullName>
        <actions>
            <name>Case_Update_Set_Made_Posted_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>set when an update made Public</description>
        <formula>AND (    (NOT($User.BypassWorkflows__c)),     Make_Public__c = TRUE,     ISBLANK(Posted_Date__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Case Update Type Change</fullName>
        <actions>
            <name>Cloud_Case_Update_Type_Change</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(
   OR(ISPICKVAL(Case__r.Problem_Sub_Type__c, &quot;Cloud Service Order&quot;),ISPICKVAL(Case__r.Cloud_Offering__c, &quot;Business Edition Cloud&quot;)),
   ISPICKVAL(Type__c, &quot;Update from Customer&quot;)
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Genesys Support Make Case Update Private</fullName>
        <active>false</active>
        <description>This workflow rule will make a public comment private.</description>
        <formula>AND(   (NOT($User.BypassWorkflows__c)),   Make_Public__c = FALSE,     NOT(ISPICKVAL(CreatedBy.Profile.UserType, &quot;Customer Portal Manager&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Genesys Support Make Case Update Public</fullName>
        <actions>
            <name>Update_Case_Update_Record_Type_to_Public</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Genesys_Case_Updates__c.Make_Public__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will make a private comment public.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Case Update Created by Portal User</fullName>
        <actions>
            <name>Notify_Case_Owner_of_New_Case_Update_by_Portal_User</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Update_Created_by_Portal_User</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.IsPortalEnabled</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire when a case update was created by the portal user.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A New Care Public Case Update</fullName>
        <actions>
            <name>Send_Case_Contact_on_New_Public_Case_Update</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Genesys_Case_Updates__c.Make_Public__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>notEqual</operation>
            <value>Guest,High Volume Portal,Customer Portal Manager,Customer Portal User</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will fire when there has been a Care public update on the case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A New Case Update on Critical Cases</fullName>
        <actions>
            <name>Notify_Case_Owner_of_New_Case_Update_for_Critical_Cases</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will fire when there has been a new case update on Critical Cases</description>
        <formula>(NOT($User.BypassWorkflows__c)) &amp;&amp; case(Case__r.Priority,&quot;Prod Down&quot;,1,&quot;1-Critical&quot;,1,0) = 1  &amp;&amp; Case__r.IsClosed = false</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support%3A Set Contact Email on Case Update</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Genesys_Case_Updates__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule will set the case contact&apos;s email address on the Case Update record, to be used by workflow.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Type to Update from Customer</fullName>
        <actions>
            <name>Update_Type_to_Update_from_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND (   (NOT($User.BypassWorkflows__c)),   ISPICKVAL($User.UserType, &quot;PowerCustomerSuccess&quot;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
