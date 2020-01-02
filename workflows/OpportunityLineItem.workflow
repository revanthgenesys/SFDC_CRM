<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Average_Lead_Time_not_null</fullName>
        <field>AverageLeadTime__c</field>
        <formula>Product2.LeadTime__c</formula>
        <name>Average Lead Time not null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Forecasted_True</fullName>
        <field>Forecasted__c</field>
        <literalValue>1</literalValue>
        <name>Forecasted = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Category</fullName>
        <field>Product_Category_rp__c</field>
        <formula>TEXT(Product2.Product_Category__c)</formula>
        <name>Opportunity Category</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Product_Type</fullName>
        <field>Product_Type__c</field>
        <formula>TEXT(PricebookEntry.Product2.Type__c)</formula>
        <name>Populate Product Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TEST</fullName>
        <field>Forecasted__c</field>
        <literalValue>1</literalValue>
        <name>TEST</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Has_PPU_Usage</fullName>
        <field>Has_PPU_Usage__c</field>
        <literalValue>1</literalValue>
        <name>Update Has PPU Usage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_third_party_on_opp_line</fullName>
        <field>Third_Party__c</field>
        <literalValue>1</literalValue>
        <name>update third party on opp line</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EMG_WKF044_ForecastedAmount</fullName>
        <actions>
            <name>Forecasted_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT($User.BypassWorkflows__c), PricebookEntry.Product2.Forecasted__c = True )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EMG_WKF053_Average_Lead_Time_not_null</fullName>
        <actions>
            <name>Average_Lead_Time_not_null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.AverageLeadTime__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Product Type</fullName>
        <actions>
            <name>Opportunity_Category</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Product_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Product_Type__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.BypassWorkflows__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity Has PPU Usage</fullName>
        <actions>
            <name>Update_Has_PPU_Usage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT($User.BypassWorkflows__c) &amp;&amp; 
CONTAINS( PricebookEntry.Product2.Name, &quot;PPU Usage&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Third party</fullName>
        <actions>
            <name>update_third_party_on_opp_line</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update third party attribute at the opportunity line level</description>
        <formula>Product2.X3rd_Party__c ||  Product2.Third_Party__c == &apos;TRUE&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
