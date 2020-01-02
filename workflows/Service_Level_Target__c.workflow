<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SLT_Coppy_Resol_High</fullName>
        <field>Resolution_High__c</field>
        <formula>Source_Template__r.Resolution_High__c</formula>
        <name>SLT Copy Resol High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Copy_Resol_Medium</fullName>
        <field>Resolution_Medium__c</field>
        <formula>Source_Template__r.Resolution_Medium__c</formula>
        <name>SLT Copy Resol Medium</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Copy_Respns_Critical</fullName>
        <field>Response_Critical__c</field>
        <formula>Source_Template__r.Response_Critical__c</formula>
        <name>SLT Copy Respns Critical</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Copy_Respns_Prod_Down</fullName>
        <field>Response_Production_Down__c</field>
        <formula>Source_Template__r.Response_Production_Down__c</formula>
        <name>SLT Copy Respns Prod Down</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Copy_SLT_Level_From_Template</fullName>
        <field>SLT_Level__c</field>
        <formula>Source_Template__r.SLT_Level__c</formula>
        <name>SLT Copy SLT Level From Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Resol_Critical</fullName>
        <field>Resolution_Critical__c</field>
        <formula>Source_Template__r.Resolution_Critical__c</formula>
        <name>SLT Resol Critical</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Resol_Low</fullName>
        <field>Resolution_Low__c</field>
        <formula>Source_Template__r.Resolution_Low__c</formula>
        <name>SLT Resol Low</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Resol_Prod_Down</fullName>
        <field>Resolution_Production_Down__c</field>
        <formula>Source_Template__r.Resolution_Production_Down__c</formula>
        <name>SLT Resol Prod Down</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Respns_High</fullName>
        <field>Response_High__c</field>
        <formula>Source_Template__r.Response_High__c</formula>
        <name>SLT Respns High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Respns_Low</fullName>
        <field>Response_Low__c</field>
        <formula>Source_Template__r.Response_Low__c</formula>
        <name>SLT Respns Low</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Respns_Medium</fullName>
        <field>Response_Medium__c</field>
        <formula>Source_Template__r.Response_Medium__c</formula>
        <name>SLT Respns Medium</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SLT_Set_SLT_Level_To_Custom</fullName>
        <field>SLT_Level__c</field>
        <formula>&quot;Custom&quot;</formula>
        <name>SLT: Set SLT Level To Custom</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SLT%3A Copy SLT From Template</fullName>
        <actions>
            <name>SLT_Coppy_Resol_High</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SLT_Copy_Resol_Medium</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SLT_Copy_Respns_Critical</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SLT_Copy_Respns_Prod_Down</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SLT_Resol_Critical</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SLT_Resol_Low</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SLT_Resol_Prod_Down</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SLT_Respns_High</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SLT_Respns_Low</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SLT_Respns_Medium</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( RecordType.Name =&quot;SLT STEU&quot;,        NOT ISBLANK(Source_Template__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SLT%3A Copy SLT Level</fullName>
        <actions>
            <name>SLT_Copy_SLT_Level_From_Template</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( RecordType.Name =&quot;SLT STEU&quot;,        NOT ISBLANK(Source_Template__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SLT%3A Update SLT Level To Custom</fullName>
        <actions>
            <name>SLT_Set_SLT_Level_To_Custom</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( RecordType.Name =&quot;SLT STEU&quot;,       ISBLANK(Source_Template__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
