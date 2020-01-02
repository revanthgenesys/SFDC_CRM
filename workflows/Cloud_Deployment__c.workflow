<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Cloud_Deployment_Created</fullName>
        <description>Cloud Deployment Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>vinay.ravula@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>all/New_Cloud_Deployment_record_creation_email</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Deployment_Name_Change</fullName>
        <description>Cloud Deployment Name Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>customercare@genesyslab.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>maria.preobrazhenskaya@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Cloud_Deployment_Name</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Deployment_Name_Changed</fullName>
        <description>Cloud Deployment Name Changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>ccare@genesyslab.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>maria.preobrazhenskaya@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Genesys_Customer_Care_Templates/Cloud_Deployment_Name</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Deployment_Status_Update</fullName>
        <description>Cloud Deployment: Status Update</description>
        <protected>false</protected>
        <recipients>
            <recipient>customercare@genesyslab.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>maria.preobrazhenskaya@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Cloud_Deployment_updated</template>
    </alerts>
    <alerts>
        <fullName>Cloud_Deployment_new_added</fullName>
        <description>Cloud Deployment: new added</description>
        <protected>false</protected>
        <recipients>
            <recipient>customercare@genesyslab.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>maria.preobrazhenskaya@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Genesys_Customer_Care_Templates/Cloud_Deployment_added_new</template>
    </alerts>
    <rules>
        <fullName>Cloud Deployement cloud creat</fullName>
        <actions>
            <name>Cloud_Deployment_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cloud_Deployment__c.Cloud_Platform__c</field>
            <operation>equals</operation>
            <value>PureConnect Cloud,PureCloud,PureEngage Subscription,PureConnect Subscription</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Deployment%3A Name Changed</fullName>
        <actions>
            <name>Cloud_Deployment_Name_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (  NOT($User.BypassWorkflows__c), NOT ISNEW(), ISCHANGED(Name),  
TEXT(Support_Status__c) &lt;&gt; &quot;Billing Only&quot;,
TEXT(Support_Status__c) &lt;&gt; &quot;Order Processing&quot;
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Deployment%3A new added</fullName>
        <actions>
            <name>Cloud_Deployment_new_added</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cloud_Deployment__c.Support_Status__c</field>
            <operation>notEqual</operation>
            <value>Billing Only,Order Processing</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Cloud Deployment%3A updated</fullName>
        <actions>
            <name>Cloud_Deployment_Status_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (  NOT($User.BypassWorkflows__c), NOT ISNEW(), ISCHANGED(Support_Status__c),
TEXT(Support_Status__c) &lt;&gt; &quot;Billing Only&quot;,
TEXT(Support_Status__c) &lt;&gt; &quot;Order Processing&quot; 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
