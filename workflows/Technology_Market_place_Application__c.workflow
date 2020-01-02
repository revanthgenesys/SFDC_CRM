<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approved_Email_of_AppFoundry_Application</fullName>
        <description>Approved Email of AppFoundry Application</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_AppFoundry_Group</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Email_Template_for_Approved_AppFoundry_Application_updated</template>
    </alerts>
    <alerts>
        <fullName>Rejected_Email_of_AppFoundry_Application</fullName>
        <description>Rejected Email of AppFoundry Application</description>
        <protected>false</protected>
        <recipients>
            <recipient>PRM_AppFoundry_Group</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/Email_Template_for_Rejecetd_AppFoundry_Application_updated</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Email_alert_to_Marketing_about_AppFoundry_Approval</fullName>
        <description>Reminder Email alert to Marketing about AppFoundry Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>AppFoundry_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/AppFoundry_Application_Reminder_Email_template</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Email_alert_to_PM_about_AppFoundry_Approval</fullName>
        <description>Reminder Email alert to PM about AppFoundry Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>AppFoundry_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/AppFoundry_Application_Reminder_Email_template</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Email_alert_to_PS_about_AppFoundry_Approval</fullName>
        <description>Reminder Email alert to PS about AppFoundry Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>juergen.tolksdorf@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sean.salter@genesys.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/AppFoundry_Application_Reminder_Email_template</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Email_alert_to_RD_about_AppFoundry_Approval</fullName>
        <description>Reminder Email alert to RD about AppFoundry Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>AppFoundry_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/AppFoundry_Application_Reminder_Email_template</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Email_alert_to_Sales_about_AppFoundry_Approval</fullName>
        <description>Reminder Email alert to Sales about AppFoundry Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>AppFoundry_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>partners@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>all/AppFoundry_Application_Reminder_Email_template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Application_Status_to_Approved</fullName>
        <description>Application Status to &apos;Approved&apos;</description>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Application Status to &apos;Approved&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Status_to_Denied</fullName>
        <description>Application Status to &apos;Denied&apos;</description>
        <field>Status__c</field>
        <literalValue>Declined</literalValue>
        <name>Application Status to &apos;Denied&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Status_to_In_Review</fullName>
        <field>Status__c</field>
        <literalValue>In Review</literalValue>
        <name>Application Status to &apos;In Review&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_Has_Not_Approved_by_PM</fullName>
        <field>HasNotApprovedByPM__c</field>
        <literalValue>1</literalValue>
        <name>Field update Has not approved by PM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_Has_approved_by_Marketing</fullName>
        <field>HasNotApprovedby_Marketing__c</field>
        <literalValue>0</literalValue>
        <name>Field update Has approved by Marketing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_Has_approved_by_PM</fullName>
        <field>HasNotApprovedByPM__c</field>
        <literalValue>0</literalValue>
        <name>Field update Has approved by PM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_Has_approved_by_PS</fullName>
        <description>Field update Has approved by PS</description>
        <field>HasNotApprovedby_PS__c</field>
        <literalValue>0</literalValue>
        <name>Field update Has approved by PS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_Has_approved_by_Sales</fullName>
        <description>Field update Has approved by Sales</description>
        <field>HasNotApprovedby_Sales__c</field>
        <literalValue>0</literalValue>
        <name>Field update Has approved by Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_Has_approved_by_TECH</fullName>
        <description>Field update Has approved by Technology</description>
        <field>HasNotApprovedby_TECH__c</field>
        <literalValue>0</literalValue>
        <name>Field update Has approved by Technology</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_Not_approved_by_Marketing</fullName>
        <field>HasNotApprovedby_Marketing__c</field>
        <literalValue>1</literalValue>
        <name>Field update not approved by Marketing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_not_approved_by_PS</fullName>
        <description>Field update not approved by PS</description>
        <field>HasNotApprovedby_PS__c</field>
        <literalValue>1</literalValue>
        <name>Field update not approved by PS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_not_approved_by_Sales</fullName>
        <description>Field update not approved by Sales</description>
        <field>HasNotApprovedby_Sales__c</field>
        <literalValue>1</literalValue>
        <name>Field update not approved by Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_update_not_approved_by_TECH</fullName>
        <description>Field update not approved by TECH</description>
        <field>HasNotApprovedby_TECH__c</field>
        <literalValue>1</literalValue>
        <name>Field update not approved by Technology</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Next_Approver_for_Marketing</fullName>
        <field>Next_Approver__c</field>
        <lookupValue>prabhuram.doraiswamy@genesys.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Next Approver for Marketing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Next_Approver_for_PM</fullName>
        <field>Next_Approver__c</field>
        <lookupValue>prabhuram.doraiswamy@genesys.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Next Approver for PM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Next_Approver_for_PS_Approval</fullName>
        <field>Next_Approver__c</field>
        <lookupValue>prabhuram.doraiswamy@genesys.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Next Approver for PS Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Next_Approver_for_Sales_Approval</fullName>
        <field>Next_Approver__c</field>
        <lookupValue>prabhuram.doraiswamy@genesys.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Next Approver for Sales Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Next_Approver_for_TECH_Approval</fullName>
        <field>Next_Approver__c</field>
        <lookupValue>prabhuram.doraiswamy@genesys.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Next Approver for Tech Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Reminder email for Marketing about AppFoundry Approval</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Technology_Market_place_Application__c.HasNotApprovedby_Marketing__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Reminder email for Marketing about AppFoundry Approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_Email_alert_to_Marketing_about_AppFoundry_Approval</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Reminder email for PM about AppFoundry Approval</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Technology_Market_place_Application__c.HasNotApprovedByPM__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Reminder email for PM about AppFoundry Approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_Email_alert_to_PM_about_AppFoundry_Approval</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Reminder email for PS about AppFoundry Approval</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Technology_Market_place_Application__c.HasNotApprovedby_PS__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Reminder email for PS about AppFoundry Approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_Email_alert_to_PS_about_AppFoundry_Approval</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Reminder email for RD about AppFoundry Approval</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Technology_Market_place_Application__c.HasNotApprovedby_TECH__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Reminder email for RD about AppFoundry Approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_Email_alert_to_RD_about_AppFoundry_Approval</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Reminder email for Sales about AppFoundry Approval</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Technology_Market_place_Application__c.HasNotApprovedby_Sales__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Reminder email for Sales about AppFoundry Approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_Email_alert_to_Sales_about_AppFoundry_Approval</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
