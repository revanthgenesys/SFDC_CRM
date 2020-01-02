<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IB_qualif_lvl_to_FULL</fullName>
        <field>Installed_base_qualification_level__c</field>
        <literalValue>1-Full qualification</literalValue>
        <name>IB qualif lvl to FULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IB_qualif_lvl_to_HIGH</fullName>
        <field>Installed_base_qualification_level__c</field>
        <literalValue>2-High qualification</literalValue>
        <name>IB qualif lvl to HIGH</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IB_qualif_lvl_to_MEDIUM</fullName>
        <field>Installed_base_qualification_level__c</field>
        <literalValue>3-Medium qualification</literalValue>
        <name>IB qualif lvl to MEDIUM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IB_qualif_lvl_to_POOR</fullName>
        <field>Installed_base_qualification_level__c</field>
        <literalValue>4-Poor qualification</literalValue>
        <name>IB qualif lvl to POOR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EMG_WKF022_IB qualif level-MEDIUM</fullName>
        <actions>
            <name>IB_qualif_lvl_to_MEDIUM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.TOTAL_Quality_rate_IB__c</field>
            <operation>lessThan</operation>
            <value>80</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.TOTAL_Quality_rate_IB__c</field>
            <operation>greaterOrEqual</operation>
            <value>50</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>level of qualification on IB based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF024_IB qualif level-HIGH</fullName>
        <actions>
            <name>IB_qualif_lvl_to_HIGH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.TOTAL_Quality_rate_IB__c</field>
            <operation>lessThan</operation>
            <value>100</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.TOTAL_Quality_rate_IB__c</field>
            <operation>greaterOrEqual</operation>
            <value>80</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>level of qualification on IB based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF025_IB qualif level-POOR</fullName>
        <actions>
            <name>IB_qualif_lvl_to_POOR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.TOTAL_Quality_rate_IB__c</field>
            <operation>lessThan</operation>
            <value>50</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>level of qualification on IB based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF026_IB qualif level-FULL</fullName>
        <actions>
            <name>IB_qualif_lvl_to_FULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.TOTAL_Quality_rate_IB__c</field>
            <operation>equals</operation>
            <value>100</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>level of qualification on IB based on TOTAL percentage quality field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
