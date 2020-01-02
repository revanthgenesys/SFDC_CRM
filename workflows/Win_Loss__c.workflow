<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Buyer_Interview_Email_A</fullName>
        <description>Buyer Interview Email A</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>winloss@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Win_Loss/Buyer_Interview_Email_Notificaiton</template>
    </alerts>
    <alerts>
        <fullName>Buyer_Interview_Email_B</fullName>
        <description>Buyer Interview Email B</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>winloss@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Win_Loss/Buyer_Interview_Email_Request_Primary</template>
    </alerts>
    <alerts>
        <fullName>Buyer_Interview_Email_C</fullName>
        <ccEmails>trevor.dewitt@genesys.com</ccEmails>
        <description>Buyer Interview Email C</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>winloss@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Win_Loss/Buyer_Interview_Email_C</template>
    </alerts>
    <alerts>
        <fullName>Buyer_Interview_Invitation2</fullName>
        <ccEmails>jesyca.hauer@primary-intel.com</ccEmails>
        <description>Buyer Interview Invitation Email E</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_Interview_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>winloss@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Win_Loss/Buyer_Interview_Invitation</template>
    </alerts>
    <alerts>
        <fullName>Buyer_Interview_Nomination_Email</fullName>
        <ccEmails>trevor.dewitt@genesys.com</ccEmails>
        <description>Buyer Interview Nomination Email D</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>winloss@genesys.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Win_Loss/Buyer_Interview_Nomination</template>
    </alerts>
    <fieldUpdates>
        <fullName>Status_Update_to_Do_not_contact</fullName>
        <field>Status__c</field>
        <literalValue>Do not contact for interview</literalValue>
        <name>Status Update to &quot;Do not contact&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Primary_Contact_Confirmed</fullName>
        <field>Status__c</field>
        <literalValue>Primary Contact Confirmed</literalValue>
        <name>Status to Primary Contact Confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_not_confirmed</fullName>
        <field>Status__c</field>
        <literalValue>Alternate Contact Needed</literalValue>
        <name>Status to Alternate Contact Needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Buyer Interview External Email E</fullName>
        <actions>
            <name>Buyer_Interview_Invitation2</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Win_Loss__c.Status__c</field>
            <operation>equals</operation>
            <value>Invite Sent to Contact by Sales Ops</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Buyer Interview Nomination Email C</fullName>
        <actions>
            <name>Buyer_Interview_Email_C</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISBLANK(Buyer_Interview_Contact__c) &amp;&amp;    ISPICKVAL(Status__c, &apos;Nominated for Interview&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Buyer Interview Nomination Email D</fullName>
        <actions>
            <name>Buyer_Interview_Nomination_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>(NOT(ISBLANK(Buyer_Interview_Contact__c)) &amp;&amp;  ISPICKVAL(Status__c, &apos;Nominated for Interview&apos;))  &amp;&amp;  ((Buyer_Interview_Confirm_Primary_Contact__c  == &apos;Yes, confirming the primary contact for buyer interview&apos;)   ||  Reason_for_Decline__c == &apos;Prefer to provide alternate contact offline&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Buyer interview Do not contact</fullName>
        <actions>
            <name>Status_Update_to_Do_not_contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6 and 7 and 8 and 9 and 10 and 11</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo,Existing Business - Cross Sell,Existing Business - New Line of Business</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won,Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Buyer_Interview_Confirm_Primary_Contact__c</field>
            <operation>equals</operation>
            <value>Unable to confirm Primary Contact at this time</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Reason_for_Decline__c</field>
            <operation>notEqual</operation>
            <value>Prefer to provide alternate contact offline</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Offer__c</field>
            <operation>equals</operation>
            <value>PureCloud,PureConnect Premise,PureEngage Premise,PureConnect Premise Subscription,PureEngage Premise Subscription,PureConnect Cloud,PureEngage Cloud,PureEngage Cloud Partner PPU,PureConnect Cloud Partner PPU,Premier Edition Cloud</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PS__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>notEqual</operation>
            <value>Pilot/Trial/POC,Offer Conversion,Enterprise License Agreement (ELA),Version Upgrade,Cloud Partner (PPU)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Detail_on_Won_Lost_Reason__c</field>
            <operation>notEqual</operation>
            <value>Add-on/Expansion of Existing Solution</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Buyer interview Email A WL</fullName>
        <actions>
            <name>Buyer_Interview_Email_A</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Status_to_Primary_Contact_Confirmed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6 and 7 and 8 and 9 and 10</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo,Existing Business - Cross Sell,Existing Business - New Line of Business,Existing Business - Platform Migration</value>
        </criteriaItems>
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
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won,Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PS__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Buyer_Interview_Confirm_Primary_Contact__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, confirming the primary contact for buyer interview&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>notEqual</operation>
            <value>Pilot/Trial/POC,Offer Conversion,Enterprise License Agreement (ELA),Version Upgrade,Cloud Partner (PPU)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Detail_on_Won_Lost_Reason__c</field>
            <operation>notEqual</operation>
            <value>Add-on/Expansion of Existing Solution</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Offer__c</field>
            <operation>equals</operation>
            <value>PureCloud,PureConnect Premise,PureEngage Premise,PureConnect Premise Subscription,PureEngage Premise Subscription,PureConnect Cloud,PureEngage Cloud,PureEngage Cloud Partner PPU,PureConnect Cloud Partner PPU,Premier Edition Cloud</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Buyer interview Email B WL</fullName>
        <actions>
            <name>Buyer_Interview_Email_B</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Status_to_not_confirmed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6 and 7 and 8 and 9 and 10 and 11</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New logo,Existing Business - Cross Sell,Existing Business - New Line of Business</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Loss_Status__c</field>
            <operation>equals</operation>
            <value>Won,Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Buyer_Interview_Confirm_Primary_Contact__c</field>
            <operation>equals</operation>
            <value>Unable to confirm Primary Contact at this time</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6.Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Reason_for_Decline__c</field>
            <operation>equals</operation>
            <value>Prefer to provide alternate contact offline</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Offer__c</field>
            <operation>equals</operation>
            <value>PureCloud,PureConnect Premise,PureEngage Premise,PureConnect Premise Subscription,PureEngage Premise Subscription,PureConnect Cloud,PureEngage Cloud,PureEngage Cloud Partner PPU,PureConnect Cloud Partner PPU,Premier Edition Cloud</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Has_PS__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Cloud_Renewal__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Offering_Detail__c</field>
            <operation>notEqual</operation>
            <value>Pilot/Trial/POC,Offer Conversion,Enterprise License Agreement (ELA),Version Upgrade,Cloud Partner (PPU)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Detail_on_Won_Lost_Reason__c</field>
            <operation>notEqual</operation>
            <value>Add-on/Expansion of Existing Solution</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>GEN - Opportunity Record Type</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
