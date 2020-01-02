<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Best_Effort_0_G_711</fullName>
        <field>Best_Effort_0_G_711_pct__c</field>
        <formula>if((ispickval(Model__c, &quot;Local Control&quot;)||ispickval(Model__c, &quot;Local Control RVA&quot;)), 
if(Local_Control_Bandwidth_Mbps__c=0,0, Best_Effort_0_G_711__c/Local_Control_Bandwidth_Mbps__c), 
if(RC_VOIP_G_711_plus_Apps_Mbps__c=0,0, Best_Effort_0_G_711__c/RC_VOIP_G_711_plus_Apps_Mbps__c))</formula>
        <name>Best Effort 0 - G.711</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Best_Effort_0_G_729</fullName>
        <field>Best_Effort_0_G_729_pct__c</field>
        <formula>if((ispickval( Model__c , &quot;Local Control&quot;)||ispickval( Model__c, &quot;Local Control RVA&quot;)), 
if(Local_Control_Bandwidth_Mbps__c =0,0, Best_Effort_0_G_729__c / Local_Control_Bandwidth_Mbps__c ), 
if(RC_VOIP_G_729_plus_Apps_Mbps__c =0,0, Best_Effort_0_G_729__c / RC_VOIP_G_729_plus_Apps_Mbps__c ) 
)</formula>
        <name>Best Effort 0 - G.729</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conference_Calls_on_Media_Server_to_NO</fullName>
        <field>Conference_Calls_on_the_Media_Server__c</field>
        <literalValue>No</literalValue>
        <name>Conference Calls on Media Server to NO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conference_Calls_on_Media_Server_to_YES</fullName>
        <field>Conference_Calls_on_the_Media_Server__c</field>
        <literalValue>Yes</literalValue>
        <name>Conference Calls on Media Server to YES</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIP_Signal_TCP_5060_24_CS3_G_711</fullName>
        <description>Updates the &apos;SIP Signal TCP 5060 24 CS3 G.711&apos; field from the &apos;SIP Call Total Bandwidth Mbps&apos; field</description>
        <field>SIP_Signal_TCP_5060_24_CS3_G_711__c</field>
        <formula>SIP_Call_Total_Bandwidth_Mbps__c</formula>
        <name>SIP Signal TCP 5060 24 CS3 G.711</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIP_Signal_TCP_5060_24_CS3_G_729</fullName>
        <description>Updates the &apos;SIP Signal TCP 5060 24 CS3 G.729&apos; field from the &apos;SIP Call Total Bandwidth Mbps&apos; field.</description>
        <field>SIP_Signal_TCP_5060_24_CS3_G_729__c</field>
        <formula>SIP_Call_Total_Bandwidth_Mbps__c</formula>
        <name>SIP Signal TCP 5060 24 CS3 G.729</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sub_Total_of_App_Bandwidth_LC_K</fullName>
        <field>Sub_Total_of_App_Bandwidth_LC_Kbps__c</field>
        <formula>if(
ispickval( SessionManagerLocation__c , &quot;Remote Site&quot;),
Remote_Site_Subtotal__c ,
Sub_Total_On_CIC_Servers__c 
)</formula>
        <name>Update Sub Total of App Bandwidth (LC) K</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CIC 3%2E0 Conf Calls on Media Server No</fullName>
        <actions>
            <name>Conference_Calls_on_Media_Server_to_NO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bandwidth_Calculation__c.Version_of_CIC__c</field>
            <operation>equals</operation>
            <value>3.0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CIC 4%2E0 Conf Calls on Media Server Yes</fullName>
        <actions>
            <name>Conference_Calls_on_Media_Server_to_YES</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bandwidth_Calculation__c.Version_of_CIC__c</field>
            <operation>equals</operation>
            <value>4.0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Created%2C and every edit</fullName>
        <actions>
            <name>Best_Effort_0_G_711</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Best_Effort_0_G_729</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIP_Signal_TCP_5060_24_CS3_G_711</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIP_Signal_TCP_5060_24_CS3_G_729</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sub_Total_of_App_Bandwidth_LC_K</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bandwidth_Calculation__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
