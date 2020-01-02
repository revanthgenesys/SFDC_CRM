<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NPS_Passive_Detractor_Notification</fullName>
        <description>NPS Passive Detractor Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Owner_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>musa.hanhan@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Survey_Passive_Detractor</template>
    </alerts>
    <alerts>
        <fullName>NPS_Promoter_Notification</fullName>
        <description>NPS Promoter Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Owner_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>musa.hanhan@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Survey_Promoter</template>
    </alerts>
    <alerts>
        <fullName>NPS_Promoter_Notification1</fullName>
        <description>NPS Promoter Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Owner_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>musa.hanhan@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Survey_Promoter</template>
    </alerts>
    <alerts>
        <fullName>NPS_Promoter_Notification_Acct</fullName>
        <description>NPS Promoter Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Account_Owner_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>musa.hanhan@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Survey_Promoter</template>
    </alerts>
    <alerts>
        <fullName>NPS_PurConnect_Cloud_Notification</fullName>
        <ccEmails>PCCloudRelationshipNPSDetractorAlert@genesys.com</ccEmails>
        <description>NPS PurConnect Cloud Notification</description>
        <protected>false</protected>
        <senderAddress>customerfeedback@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Relationship_Survey_Alert</template>
    </alerts>
    <alerts>
        <fullName>NPS_PurConnect_Premise</fullName>
        <ccEmails>PCPremRelationshipNPSDetractorAlert@genesys.com</ccEmails>
        <description>NPS PurConnect Premise</description>
        <protected>false</protected>
        <senderAddress>customerfeedback@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Relationship_Survey_Alert</template>
    </alerts>
    <alerts>
        <fullName>NPS_PureCloud_Notification</fullName>
        <ccEmails>PureCloudRelationshipNPSDetractorAlert@genesys.com</ccEmails>
        <description>NPS PureCloud Notification</description>
        <protected>false</protected>
        <senderAddress>customerfeedback@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Relationship_Survey_Alert</template>
    </alerts>
    <alerts>
        <fullName>NPS_PureEngage_Cloud_Notification</fullName>
        <ccEmails>PECloudRelationshipNPSDetractorAlert@genesys.com</ccEmails>
        <description>NPS PureEngage Cloud Notification</description>
        <protected>false</protected>
        <senderAddress>customerfeedback@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Relationship_Survey_Alert</template>
    </alerts>
    <alerts>
        <fullName>NPS_PureEngage_Notification</fullName>
        <ccEmails>PEPremRelationshipNPSDetractorAlert@genesys.com</ccEmails>
        <description>NPS PureEngage Notification</description>
        <protected>false</protected>
        <senderAddress>customerfeedback@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Relationship_Survey_Alert</template>
    </alerts>
    <alerts>
        <fullName>NPS_Relationship_Alert_for_Australia_and_New_Zealand</fullName>
        <ccEmails>ANZNPSDetractor@genesys.com</ccEmails>
        <description>NPS Relationship Alert for Australia and New Zealand</description>
        <protected>false</protected>
        <senderAddress>customerfeedback@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NPS_Templates/NPS_Relationship_Survey_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Account_Owner_Email</fullName>
        <field>Account_Owner_Email__c</field>
        <formula>Account__r.Owner.Email</formula>
        <name>Set Account Owner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_Owner_Manager_Email</fullName>
        <field>Account_Owner_Manager_Email__c</field>
        <formula>Account__r.Owner.Manager.Email</formula>
        <name>Set Account Owner Manager Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>NPS Relationship Australia and New Zealand</fullName>
        <actions>
            <name>NPS_Relationship_Alert_for_Australia_and_New_Zealand</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If End User Country Australia or New Zealand send to ANZNPSDetractor@genesys.com</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp;  TEXT(Survey_Type__c) = &quot;Relationship&quot; &amp;&amp; NPS_Rating__c != &quot;10&quot; &amp;&amp; NPS_Rating__c != &quot;9&quot; &amp;&amp; NPS_Rating__c != &quot;8&quot; &amp;&amp; NPS_Rating__c != &quot;7&quot; &amp;&amp; (End_User_Country__c = &quot;Australia&quot; || End_User_Country__c = &quot;New Zealand&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NPS Relationship PureCloud</fullName>
        <actions>
            <name>NPS_PureCloud_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If field NPS_Deployment_Type__c = “PureCloud” send to PureCloudRelationshipNPSDetractorAlert@genesys.com
Exclude Australia and New Zealand</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp;  TEXT(Survey_Type__c) = &quot;Relationship&quot; &amp;&amp; NPS_Deployment_Type__c = &quot;PureCloud&quot; &amp;&amp; NPS_Rating__c != &quot;10&quot; &amp;&amp; NPS_Rating__c != &quot;9&quot; &amp;&amp; NPS_Rating__c != &quot;8&quot; &amp;&amp; NPS_Rating__c != &quot;7&quot; &amp;&amp; End_User_Country__c != &quot;Australia&quot; &amp;&amp; End_User_Country__c != &quot;New Zealand&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NPS Relationship PureConnect Cloud</fullName>
        <actions>
            <name>NPS_PurConnect_Cloud_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If field NPS_Deployment_Type__c = “PureConnect Cloud” send to PCCloudRelationshipNPSDetractorAlert@genesys.com
Exclude Australia and New Zealand</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp;  TEXT(Survey_Type__c) = &quot;Relationship&quot; &amp;&amp; NPS_Deployment_Type__c = &quot;PureConnect Cloud&quot; &amp;&amp; NPS_Rating__c != &quot;10&quot; &amp;&amp; NPS_Rating__c != &quot;9&quot; &amp;&amp; NPS_Rating__c != &quot;8&quot; &amp;&amp; NPS_Rating__c != &quot;7&quot; &amp;&amp; End_User_Country__c != &quot;Australia&quot; &amp;&amp; End_User_Country__c != &quot;New Zealand&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NPS Relationship PureConnect Premise</fullName>
        <actions>
            <name>NPS_PurConnect_Premise</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If field NPS_Deployment_Type__c = “PureConnect Premise” send to PCPremRelationshipNPSDetractorAlert@genesys.com
Exclude Australia and New Zealand</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp;  TEXT(Survey_Type__c) = &quot;Relationship&quot; &amp;&amp; NPS_Deployment_Type__c = &quot;PureConnect Premise&quot; &amp;&amp; NPS_Rating__c != &quot;10&quot; &amp;&amp; NPS_Rating__c != &quot;9&quot; &amp;&amp; NPS_Rating__c != &quot;8&quot; &amp;&amp; NPS_Rating__c != &quot;7&quot; &amp;&amp; End_User_Country__c != &quot;Australia&quot; &amp;&amp; End_User_Country__c != &quot;New Zealand&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NPS Relationship PureEngage</fullName>
        <actions>
            <name>NPS_PureEngage_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If field NPS_Deployment_Type__c = “PureEngage Premise” or blank send the following email to PEPremRelationshipNPSDetractorAlert@genesys.com
Exclude Australia and New Zealand</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp;  TEXT(Survey_Type__c) = &quot;Relationship&quot; &amp;&amp; NPS_Rating__c != &quot;10&quot; &amp;&amp; NPS_Rating__c != &quot;9&quot; &amp;&amp; NPS_Rating__c != &quot;8&quot; &amp;&amp; NPS_Rating__c != &quot;7&quot; &amp;&amp; (NPS_Deployment_Type__c = &quot;PureEngage Premise&quot; || ISBLANK(NPS_Deployment_Type__c)) &amp;&amp; End_User_Country__c != &quot;Australia&quot; &amp;&amp; End_User_Country__c != &quot;New Zealand&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NPS Relationship PureEngage Cloud</fullName>
        <actions>
            <name>NPS_PureEngage_Cloud_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If field NPS_Deployment_Type__c = “PureEngage Cloud” OR “Premier” or “Outbound” or “LEC” send to PECloudRelationshipNPSDetractorAlert@genesys.com
Exclude Australia and New Zealand</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp;  TEXT(Survey_Type__c) = &quot;Relationship&quot; &amp;&amp; (NPS_Deployment_Type__c = &quot;PureEngage Cloud&quot; || NPS_Deployment_Type__c = &quot;Premier&quot; ||  NPS_Deployment_Type__c = &quot;Outbound&quot; ||  NPS_Deployment_Type__c = &quot;Legacy Enterprise&quot; ) &amp;&amp; NPS_Rating__c != &quot;10&quot; &amp;&amp; NPS_Rating__c != &quot;9&quot; &amp;&amp; NPS_Rating__c != &quot;8&quot; &amp;&amp; NPS_Rating__c != &quot;7&quot; &amp;&amp; End_User_Country__c != &quot;Australia&quot; &amp;&amp; End_User_Country__c != &quot;New Zealand&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NPS Survey Detractor Notification</fullName>
        <actions>
            <name>Set_Account_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Account_Owner_Manager_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sent to Account Owner and Account Owner Manager
NPS Rating 0 to 6
sent out in 72 hrs.</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp; TEXT(Survey_Type__c) = &quot;Relationship&quot; &amp;&amp; NPS_Rating__c != &quot;10&quot; &amp;&amp; NPS_Rating__c != &quot;9&quot; &amp;&amp; NPS_Rating__c != &quot;8&quot; &amp;&amp; NPS_Rating__c != &quot;7&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>NPS_Passive_Detractor_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Survey_Response__c.CreatedDate</offsetFromField>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>NPS Survey Passive Notification</fullName>
        <actions>
            <name>Set_Account_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Account_Owner_Manager_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sent to Account Owner and Account Owner Manager
NPS Rating 7 or 8
does out in 24 hrs.</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp; TEXT(Survey_Type__c) = &quot;Relationship&quot; &amp;&amp; (NPS_Rating__c = &quot;7&quot; || NPS_Rating__c = &quot;8&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>NPS_Passive_Detractor_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Survey_Response__c.CreatedDate</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>NPS Survey Promoter</fullName>
        <actions>
            <name>NPS_Promoter_Notification1</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Account_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Account_Owner_Manager_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sent to Account Owner and Account Owner Manager
NPS Rating &gt; 8
sent out immediately</description>
        <formula>!$User.BypassWorkflows__c &amp;&amp; TEXT(Survey_Type__c) = &quot;Relationship&quot; &amp;&amp; (NPS_Rating__c = &quot;10&quot; || NPS_Rating__c = &quot;9&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
