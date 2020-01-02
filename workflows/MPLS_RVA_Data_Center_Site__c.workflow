<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TotalBandwidthFieldUpdate</fullName>
        <field>Total_Site_Bandwidth_Mbps_numeric__c</field>
        <formula>IF( 
AND(ispickval( Codec__c , &quot;G.711&quot;) , (Model__c =&quot;Remote Control VOIP&quot;)) , 
Bandwidth_Calculation__r.RC_VOIP_G_711_plus_Apps_Mbps__c , 
if( 
AND(ispickval( Codec__c , &quot;G.729&quot;) , (Model__c =&quot;Remote Control VOIP&quot;)), 
Bandwidth_Calculation__r.RC_VOIP_G_729_plus_Apps_Mbps__c , 
IF( 
AND(OR((ispickval( Codec__c , &quot;G.711&quot;) || ispickval( Codec__c , &quot;G.729&quot;))) , Model__c =&quot;Local Control&quot;), 
Bandwidth_Calculation__r.Local_Control_Bandwidth_Mbps__c , 
if( 
AND(ispickval( Codec__c , &quot;G.729&quot;) , Model__c =&quot;Local Control RVA&quot;), 
Bandwidth_Calculation__r.RVA_Total_BW_incl_Apps_at_G_729_Mbps__c , 
if( 
AND(ispickval(Codec__c , &quot;G.711&quot;) , Model__c =&quot;Local Control RVA&quot;), 
Bandwidth_Calculation__r.RVA_Total_BW_incl_Apps_at_G_711_Mbps__c , 
0) 
) 
) 
) 
)</formula>
        <name>TotalBandwidthFieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MPLS_Site_Customer_EF</fullName>
        <field>Customer_QoS_COS_Markings_EF__c</field>
        <formula>if( IsPickVal(Codec__c, &apos;G.711&apos;), 
Ceiling(Bandwidth_Calculation__r.RTP_UDP_46_EF_G_711__c*1000/64)*64/1000, 
Ceiling(Bandwidth_Calculation__r.RTP_UDP_46_EF_G_729__c*1000/64)*64/1000 
)</formula>
        <name>Update MPLS Site - Customer EF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MPLS_Site_DC_EF</fullName>
        <field>DC_QoS_COS_Markings_EF__c</field>
        <formula>if( IsPickVal(Codec__c, &apos;G.711&apos;), 
Ceiling( Bandwidth_Calculation__r.RTP_UDP_46_EF_G_711__c *2)/2, 
Ceiling( Bandwidth_Calculation__r.RTP_UDP_46_EF_G_729__c *2)/2)</formula>
        <name>Update MPLS Site - DC EF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TotalBandwidthFieldPopulationOn MPLS</fullName>
        <actions>
            <name>TotalBandwidthFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(isnew() , ISCHANGED( Codec__c ), ISCHANGED( Bandwidth_Calculation__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update on Every Site Edit</fullName>
        <actions>
            <name>Update_MPLS_Site_Customer_EF</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_MPLS_Site_DC_EF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
