<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Business_Terms_Comment_Admin_Email_to_Partner</fullName>
        <description>Business Terms Comment (Admin) Email to Partner</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Business_Terms_Comment_External</template>
    </alerts>
    <alerts>
        <fullName>Business_Terms_Comment_Partner_Email_to_Admin</fullName>
        <description>Business Terms Comment (Partner) Email to Admin</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Business_Terms_Comment_Internal</template>
    </alerts>
    <alerts>
        <fullName>New_Application_Comment_Admin_Email_to_Partner</fullName>
        <description>New Application Comment (Admin) Email to Partner</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Comment_External</template>
    </alerts>
    <alerts>
        <fullName>New_Application_Comment_Portal_Email_to_Admin</fullName>
        <description>New Application Comment (Partner) Email to Admin</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Application_Comment_Internal</template>
    </alerts>
    <alerts>
        <fullName>Partner_Contract_Comment_Admin_Email_to_Partner</fullName>
        <description>Partner Contract Comment (Admin) Email to Partner</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Contract_Comment_External</template>
    </alerts>
    <alerts>
        <fullName>Partner_Contract_Comment_Partner_Email_to_Admin</fullName>
        <description>Partner Contract Comment (Partner) Email to Admin</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_Partner_Contracts_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Partner_Portal_Templates/Partner_Contract_Comment_Internal</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_Partner_Email</fullName>
        <field>Partner_Email__c</field>
        <formula>IF(Partner_Application__c != null, Partner_Application__r.For_User__r.Email , 
IF(Partner_Business_Terms_and_Conditions__c != null, Partner_Business_Terms_and_Conditions__r.Partner_Application__r.For_User__r.Email,
IF(Partner_Contract__c!= null, Partner_Contract__r.Partner_Business_Terms_and_Conditions__r.Partner_Application__r.For_User__r.Email,
null
)
)
)</formula>
        <name>Populate Partner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Bunsiness Terms Comment %28Partner%29 Send Email To Admin</fullName>
        <actions>
            <name>Business_Terms_Comment_Partner_Email_to_Admin</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Comment__c.Comment_Type__c</field>
            <operation>equals</operation>
            <value>PowerPartner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Comment__c.BA_Comment__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Business Terms Comment %28Admin%29 Send Email To Partner</fullName>
        <actions>
            <name>Business_Terms_Comment_Admin_Email_to_Partner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Comment__c.Comment_Type__c</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <criteriaItems>
            <field>Comment__c.Send_Notification_To_Customer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Comment__c.BA_Comment__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Application Comment %28Admin%29 Send Email To Partner</fullName>
        <actions>
            <name>New_Application_Comment_Admin_Email_to_Partner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Comment__c.Comment_Type__c</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <criteriaItems>
            <field>Comment__c.Send_Notification_To_Customer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Comment__c.PA_comment__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Application Comment %28Partner%29 Send Email To Admin</fullName>
        <actions>
            <name>New_Application_Comment_Portal_Email_to_Admin</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Comment__c.Comment_Type__c</field>
            <operation>equals</operation>
            <value>PowerPartner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Comment__c.PA_comment__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Application Comment Populate Partner Email</fullName>
        <actions>
            <name>Populate_Partner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Comment__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Partner Contract Comment %28Admin%29 Send Email To Partner</fullName>
        <actions>
            <name>Partner_Contract_Comment_Admin_Email_to_Partner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Comment__c.Comment_Type__c</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <criteriaItems>
            <field>Comment__c.Send_Notification_To_Customer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Comment__c.PC_Comment__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Partner Contract Comment %28Partner%29 Send Email To Admin</fullName>
        <actions>
            <name>Partner_Contract_Comment_Partner_Email_to_Admin</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Comment__c.Comment_Type__c</field>
            <operation>equals</operation>
            <value>PowerPartner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Comment__c.PC_Comment__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
