<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Sub_Category_FYM</fullName>
        <description>Set Sub Category as &apos;FYM&apos;</description>
        <field>Sub_category__c</field>
        <literalValue>FYM</literalValue>
        <name>Set Sub Category to FYM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Sub_Category_to_Expected</fullName>
        <description>Set Sub Category to Expected.</description>
        <field>Sub_category__c</field>
        <literalValue>Expected</literalValue>
        <name>Set Sub Category to Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Sub_Category_to_Renewal</fullName>
        <description>Set Sub Category as &apos;Renewal&apos;</description>
        <field>Sub_category__c</field>
        <literalValue>Renewal</literalValue>
        <name>Set Sub Category to Renewal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Sub_Category_to_Upside</fullName>
        <description>Set Sub Category as Upside</description>
        <field>Sub_category__c</field>
        <literalValue>Upside</literalValue>
        <name>Set Sub Category to Upside</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set_Sub_Category_Expected</fullName>
        <actions>
            <name>Set_Sub_Category_to_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>update sub category based on revenue type and opportunity forecast status.
1. Opportunity with Forecast Status = &apos;3.Expected&apos; as Expected.</description>
        <formula>AND(OR(ISNEW(), ISCHANGED( Revenue_Type__c ), ISCHANGED(  Opportunity__c  ) ), ISPICKVAL(  Opportunity__r.ForecastStatus__c , &quot;3.Expected&quot; ),  OR(ISPICKVAL( Revenue_Type__c , &quot;Incremental Revenue&quot;), ISPICKVAL(Revenue_Type__c , &quot;First Year Maintenance&quot;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set_Sub_Category_FYM</fullName>
        <actions>
            <name>Set_Sub_Category_FYM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>update sub category based on revenue type and item description.
1. Item description with &apos;New&apos; will be considered as FYM.</description>
        <formula>AND(OR(ISNEW(), ISCHANGED( Revenue_Type__c ), ISCHANGED( Item_Description__c ) ), CONTAINS( Item_Description__c , &apos;New&apos;),  NOT(ISPICKVAL( Revenue_Type__c , &quot;Incremental Revenue&quot;)), NOT(ISPICKVAL(Revenue_Type__c , &quot;First Year Maintenance&quot;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set_Sub_Category_Renewal</fullName>
        <actions>
            <name>Set_Sub_Category_to_Renewal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>update sub category based on revenue type and item description.
2. Item description with &apos;Renewal&apos; or blank will be considered as Renewal.</description>
        <formula>AND(OR(ISNEW(), ISCHANGED( Revenue_Type__c ), ISCHANGED( Item_Description__c ) ),  CONTAINS( Item_Description__c , &apos;Renewal&apos;), NOT(ISPICKVAL( Revenue_Type__c , &quot;Incremental Revenue&quot;)), NOT(ISPICKVAL(Revenue_Type__c , &quot;First Year Maintenance&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set_Sub_Category_Upside</fullName>
        <actions>
            <name>Set_Sub_Category_to_Upside</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>update sub category based on revenue type and opportunity forecast status.
1. Opportunity with Forecast Status = &apos;4.Upside&apos; as Upside.</description>
        <formula>AND(OR(ISNEW(), ISCHANGED( Revenue_Type__c ), ISCHANGED(  Opportunity__c  ) ), ISPICKVAL(  Opportunity__r.ForecastStatus__c , &quot;4.Upside&quot; ),  OR(ISPICKVAL( Revenue_Type__c , &quot;Incremental Revenue&quot;), ISPICKVAL(Revenue_Type__c , &quot;First Year Maintenance&quot;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
