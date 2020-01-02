<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NewAccount_Approved</fullName>
        <description>NewAccount Approved</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_creation/NewAccount_Approved</template>
    </alerts>
    <alerts>
        <fullName>NewAccount_Awaiting_Approval</fullName>
        <ccEmails>liam.clifford@genesys.com</ccEmails>
        <description>NewAccount Awaiting Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>carmela.meneses@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>france.ramos@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>scott.boggs@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_creation/NewAccount_Awaiting_Approval</template>
    </alerts>
    <alerts>
        <fullName>NewAccount_More_Info_Needed</fullName>
        <description>NewAccount More Info Needed</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_creation/NewAccount_More_Info_Needed</template>
    </alerts>
    <alerts>
        <fullName>NewAccount_ReReview</fullName>
        <description>NewAccount ReReview</description>
        <protected>false</protected>
        <recipients>
            <recipient>carmela.meneses@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>france.ramos@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>scott.boggs@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/NewAccount_ReReview</template>
    </alerts>
    <alerts>
        <fullName>NewAccount_Rejected</fullName>
        <description>NewAccount Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Account_creation/NewAccount_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Partner_account_owner_change_alert</fullName>
        <description>Partner account owner change alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>vinay.ravula@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>asksalesops@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Partner_Account_owner_change_notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Record_Type_to_Customer</fullName>
        <description>Change the account record type to EMG - Customer</description>
        <field>RecordTypeId</field>
        <lookupValue>EMGCustomerRecordType</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Account Record Type to Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BP_OwnerChanged</fullName>
        <field>ToBeTreatedByBA001__c</field>
        <literalValue>1</literalValue>
        <name>BP_OwnerChanged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_ABS_Verified_Target_Date</fullName>
        <description>Clears the ABS Verified Target Date when ABS Verified Target  field is &quot;unchecked&quot;</description>
        <field>ABS_Verified_Target_Date__c</field>
        <name>Clear ABS Verified Target Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DupeMasterchange</fullName>
        <field>DupeId__c</field>
        <formula>MasterOfTheDuplicate__r.Id</formula>
        <name>DupeMasterchange</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Isdirect_EMG_Prospect_Record</fullName>
        <field>IsDirect__c</field>
        <literalValue>1</literalValue>
        <name>Isdirect - EMG - Prospect Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MAJ_TM_Acc_Country_Name_copie</fullName>
        <field>TM_Acc_Country_Name_Copie__c</field>
        <formula>Country__r.Name</formula>
        <name>MAJ TM - Acc Country Name -copie</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MAJ_TM_Acc_Country_RU</fullName>
        <field>TM_Acc_Country_RU_copie__c</field>
        <formula>text(Country__r.RU__c)</formula>
        <name>MAJ TM - Acc Country RU - copie</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MAJ_TM_Acc_Country_Region_copie</fullName>
        <field>TM_Acc_Country_Region_copie__c</field>
        <formula>text(Country__r.Region__c)</formula>
        <name>MAJ TM - Acc Country Region - copie</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MAJ_TM_Acc_Country_SubRU_copie</fullName>
        <field>TM_Acc_Country_SubRU_copie__c</field>
        <formula>text(Country__r.SubRU__c)</formula>
        <name>MAJ TM - Acc Country SubRU - copie</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_New_Logo_Conversion_Date</fullName>
        <field>New_Logo_Conversion_Date__c</field>
        <formula>NOW()</formula>
        <name>Populate New Logo Conversion Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Unique_Name_GroupAccount</fullName>
        <field>Unique_Name_GroupAccount__c</field>
        <formula>Name</formula>
        <name>Populate Unique Name GroupAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Unique_Name_GroupAccount_Clear</fullName>
        <field>Unique_Name_GroupAccount__c</field>
        <name>Populate Unique Name GroupAccount Clear</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_ABS_Verified_Target_Date</fullName>
        <description>Set the ABS Verified Target Date when ABS Verified Target  field is &quot;checked&quot;</description>
        <field>ABS_Verified_Target_Date__c</field>
        <formula>NOW()</formula>
        <name>Set ABS Verified Target Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update</fullName>
        <field>Partner_Active_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Partner Active Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Partner_Termination_Date</fullName>
        <field>Partner_termination_Date__c</field>
        <formula>now()</formula>
        <name>Update Partner Termination Date</name>
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
        <formula>NOW()</formula>
        <name>Update Rejected/Accepted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Accepted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>Update Status (Accepted)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status (Rejected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
        <formula>NOW()</formula>
        <name>Update Submitted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>acc_qualif_lvl_to_FULL</fullName>
        <field>Account_completeness_level__c</field>
        <literalValue>1-Full qualification</literalValue>
        <name>acc_qualif_lvl_to_FULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>acc_qualif_lvl_to_HIGH</fullName>
        <field>Account_completeness_level__c</field>
        <literalValue>2-High qualification</literalValue>
        <name>acc_qualif_lvl_to_HIGH</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>acc_qualif_lvl_to_POOR</fullName>
        <field>Account_completeness_level__c</field>
        <literalValue>4-Poor qualification</literalValue>
        <name>acc_qualif_lvl_to_POOR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>accc_qualif_lvl_to_MEDIUM</fullName>
        <field>Account_completeness_level__c</field>
        <literalValue>3-Medium qualification</literalValue>
        <name>acc_qualif_lvl_to_MEDIUM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Clear ABS Verified Target Date</fullName>
        <actions>
            <name>Clear_ABS_Verified_Target_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ABS_Verified_Target__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Clear ABS Verified Target Date if ABS Verified Target is unchecked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMG - WKF095 - Copy TM - Account * - copie</fullName>
        <actions>
            <name>MAJ_TM_Acc_Country_Name_copie</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MAJ_TM_Acc_Country_RU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MAJ_TM_Acc_Country_Region_copie</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MAJ_TM_Acc_Country_SubRU_copie</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Enterprise - Business Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Copy the formula &quot;TM-...&quot; filed in another text &quot;TM-...-copie&quot; field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF003_Account Type - Customer</fullName>
        <actions>
            <name>Account_Record_Type_to_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Change the account record Type when Type become &apos;customer&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF018_Account qualif level-FULL</fullName>
        <actions>
            <name>acc_qualif_lvl_to_FULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.TOTAL_percent_Quality_rate_Account__c</field>
            <operation>equals</operation>
            <value>100</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>level of qualification on accounts based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF019_Account qualif level-MEDIUM</fullName>
        <actions>
            <name>accc_qualif_lvl_to_MEDIUM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Account.TOTAL_percent_Quality_rate_Account__c</field>
            <operation>lessThan</operation>
            <value>80</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.TOTAL_percent_Quality_rate_Account__c</field>
            <operation>greaterOrEqual</operation>
            <value>50</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>level of qualification on accounts based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF020_Account qualif level-HIGH</fullName>
        <actions>
            <name>acc_qualif_lvl_to_HIGH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Account.TOTAL_percent_Quality_rate_Account__c</field>
            <operation>lessThan</operation>
            <value>100</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.TOTAL_percent_Quality_rate_Account__c</field>
            <operation>greaterOrEqual</operation>
            <value>80</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>level of qualification on accounts based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF021_Account qualif level-POOR</fullName>
        <actions>
            <name>acc_qualif_lvl_to_POOR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.TOTAL_percent_Quality_rate_Account__c</field>
            <operation>lessThan</operation>
            <value>50</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>level of qualification on accounts based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF027_Master of the duplicates</fullName>
        <actions>
            <name>DupeMasterchange</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.TEST_Duplicates__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Fill the Field &apos;Account: Dupe ID&apos; with the Account ID of the record in the Look-up</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF066_BP Owner changed</fullName>
        <actions>
            <name>BP_OwnerChanged</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update field on Business Partner owner has been modified</description>
        <formula>IF( AND(NOT($User.BypassWorkflows__c),$RecordType.DeveloperName == &apos;EMGBusinessPartnerRecordType&apos;, ISCHANGED(OwnerId)),true,false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Isdirect - EMG - Prospect Record</fullName>
        <actions>
            <name>Isdirect_EMG_Prospect_Record</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update field on Business Partner owner has been modified</description>
        <formula>IF( AND(NOT($User.BypassWorkflows__c),$RecordType.DeveloperName == &apos;EMGBusinessPartnerRecordType&apos;, ISCHANGED(RecordTypeId)),true,false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Logo Conversion Date %28%22Prospect%22 -%3E %22Customer%22%29</fullName>
        <actions>
            <name>Populate_New_Logo_Conversion_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c)
&amp;&amp;
ISPICKVAL(PRIORVALUE(Type),&apos;Prospect&apos;) 
&amp;&amp; 
ISPICKVAL(Type,&apos;Customer&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Partner Account owner change</fullName>
        <actions>
            <name>Partner_account_owner_change_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>if ( RecordType.Name = &apos;Enterprise - Business Partner&apos;, 

ISCHANGED( OwnerId ),not (True))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Unique Account Name GroupAccount</fullName>
        <actions>
            <name>Populate_Unique_Name_GroupAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>Group Account</value>
        </criteriaItems>
        <description>save account name if account is of type Group Account. Used to enforce unique value</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Unique Name GroupAccount - Clear</fullName>
        <actions>
            <name>Populate_Unique_Name_GroupAccount_Clear</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>notContain</operation>
            <value>Group</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.InactiveAccount__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set ABS Verified Target Date</fullName>
        <actions>
            <name>Set_ABS_Verified_Target_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ABS_Verified_Target__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets ABS Verified Target Date when ABS Verified Target is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Partner Active Date</fullName>
        <actions>
            <name>Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Partner Active Date (set when Status = active) – When we flip an account from a Prospect to a Partner</description>
        <formula>AND(ISPICKVAL(Status__c, &apos;Active&apos;), ISPICKVAL(PRIORVALUE(Type), &apos;Prospective Partner&apos;), ISPICKVAL(Type,&apos;Partner&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Partner Termination Date</fullName>
        <actions>
            <name>Update_Partner_Termination_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Partner termination Date (set when Partner Type = Support Only) – When we terminate a Partner Account the Partner Type is set to Support Only) Record Type - Enterprise - Prospective Partner to Enterprise - Business Partner</description>
        <formula>or( INCLUDES(PartnerType__c, &apos;Support Only&apos;), ISPICKVAL(Status__c, &apos;Inactive&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
