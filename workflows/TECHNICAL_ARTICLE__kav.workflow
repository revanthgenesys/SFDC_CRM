<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>General_Rejection_Email_TA</fullName>
        <description>General_Rejection_Email_TA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/General_Rejection_Email_TA</template>
    </alerts>
    <alerts>
        <fullName>General_Rejection_Email_TA2</fullName>
        <description>General_Rejection_Email_TA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/General_Rejection_Email_TA</template>
    </alerts>
    <alerts>
        <fullName>PKB_Auto_Approve_Con_TA</fullName>
        <description>PKB_Auto_Approve_Con_TA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/PKB_Auto_Approve_TA</template>
    </alerts>
    <alerts>
        <fullName>PKB_Auto_Approve_NV_TA</fullName>
        <description>PKB_Auto_Approve_NV_TA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/PKB_Auto_Approve_TA</template>
    </alerts>
    <alerts>
        <fullName>PKB_Coach_Has_Approved_TA</fullName>
        <description>PKB_Coach_Has_Approved_TA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/PKB_Coach_Has_Approved_TA</template>
    </alerts>
    <alerts>
        <fullName>PKB_Coach_Has_Approved_TA_2</fullName>
        <description>PKB_Coach_Has_Approved_TA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/PKB_Coach_Has_Approved_TA</template>
    </alerts>
    <alerts>
        <fullName>PKB_Coach_Has_Rejected_TA</fullName>
        <description>PKB_Coach_Has_Rejected_TA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/PKB_Coach_Has_Rejected_TA</template>
    </alerts>
    <alerts>
        <fullName>PKB_Coach_Has_Rejected_TA_2</fullName>
        <description>PKB_Coach_Has_Rejected_TA</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/PKB_Coach_Has_Approved_TA</template>
    </alerts>
    <alerts>
        <fullName>PKB_Rejection_Email</fullName>
        <description>PKB_Rejection_Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/PKB_Rejection_Email_TA</template>
    </alerts>
    <alerts>
        <fullName>TA_Rejection_Email</fullName>
        <description>TA_Rejection_Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Old_Templates/PKB_Rejection_Email_TA</template>
    </alerts>
    <fieldUpdates>
        <fullName>How_To_PKB_False</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Technical Article PKB False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Partner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Customer</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set Customer To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Customer_To_False</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set Customer To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Customer_To_True</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Customer To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Customer_True</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Customer True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Internal</fullName>
        <field>IsVisibleInApp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Internal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Internal_To_True</fullName>
        <field>IsVisibleInApp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Internal True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Internal_True</fullName>
        <field>IsVisibleInApp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Internal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_PKB_To_False</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set PKB To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Partner_True</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Partner to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Portal_To_False</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set Portal To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Public_True</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Public True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_Set_Public_to_False</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set Public to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_to_Set_Partner_To_True</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Partner True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Channel_to_Internal</fullName>
        <field>IsVisibleInApp</field>
        <literalValue>1</literalValue>
        <name>Set Channel to Internal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_PKB_False</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Technical Article PKB False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Partner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Customer</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set Customer To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Customer_To_False</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set Customer To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Customer_To_True</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Customer To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Customer_True</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Customer True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Internal</fullName>
        <field>IsVisibleInApp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Internal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Internal_To_True</fullName>
        <field>IsVisibleInApp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Internal True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Internal_True</fullName>
        <field>IsVisibleInApp</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Internal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_PKB_To_False</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set PKB To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Partner_To_True</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Partner True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Partner_True</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Partner to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Portal_To_False</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set Portal To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Public_True</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>1</literalValue>
        <name>Technical Article Set Public True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Article_Set_Public_to_False</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Technical Article Set Public to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>Approve_and_Publish</fullName>
        <action>Publish</action>
        <label>Approve and Publish</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <knowledgePublishes>
        <fullName>Auto_Approval_Publish</fullName>
        <action>PublishAsNew</action>
        <label>Auto_Approval_Publish</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <rules>
        <fullName>Tech Article Validated Public</fullName>
        <actions>
            <name>Technical_Article_Set_Customer_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Internal_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Partner_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Public_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>TECHNICAL_ARTICLE__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Public</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Technical Article Validated Customer</fullName>
        <actions>
            <name>Technical_Article_PKB_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Customer_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Internal_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Partner_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>TECHNICAL_ARTICLE__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Customer</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Technical Article Validated Internal</fullName>
        <actions>
            <name>Set_Channel_to_Internal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Customer_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Portal_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Public_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>TECHNICAL_ARTICLE__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Internal</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Technical Article Validated Partner</fullName>
        <actions>
            <name>Technical_Article_Set</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_Internal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Technical_Article_Set_PKB_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>TECHNICAL_ARTICLE__kav.ValidationStatus</field>
            <operation>equals</operation>
            <value>Validated Partner</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
