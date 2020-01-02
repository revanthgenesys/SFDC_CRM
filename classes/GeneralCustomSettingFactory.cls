@isTest
public class GeneralCustomSettingFactory {
    public static List<General_Custom_Settings__c> CreateDefaultCustomSettings()
    {
        List<General_Custom_Settings__c> results = new List<General_Custom_Settings__c>();
        results.add(new General_Custom_Settings__c(Name='EntityAXIDs_for_Default_InterestRt', Value__c='999,825,510,905', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Account_Rejection_EmailTemplate_Id', Value__c='00Xc0000000MUFU', Description__c='Rejection email template'));
        results.add(new General_Custom_Settings__c(Name='NoReplyOrgWideEmailId', Value__c='0D2E0000000GmmA', Description__c='SF Noreply Id'));
        results.add(new General_Custom_Settings__c(Name='NotifyForChangedPrice_ChatterUserId', Value__c='005E0000000dQq2', Description__c='Chatter user ID used by NotifyForChangedPrice'));
        results.add(new General_Custom_Settings__c(Name='OppSplitManager_SplitMasterLabel', Value__c='Revenue', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='OppTeamManager_TerrMgrRole', Value__c='Territory Manager', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='OppTeamManager_ChannelMgrRole', Value__c='Channel Manager', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Default_AX_Legal_Entity_AXId', Value__c='110', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='CountryCodes_for_Default_InterestRt', Value__c='AFG,EGY', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='PublicAPIAppKey', Value__c='DUMMY_KEY', Description__c='PublicAPI Application Key'));
        results.add(new General_Custom_Settings__c(Name='PublicAPITimeOut', Value__c='60', Description__c='PublicAPI Time out'));
        results.add(new General_Custom_Settings__c(Name='PublicApiBaseUrl', Value__c='http://www2-d.inin.com/publicapi/', Description__c='PublicAPI Base URL'));
        results.add(new General_Custom_Settings__c(Name='PublicApiSchemaUrl', Value__c='http://www2-d.inin.com/publicapi/', Description__c='PublicAPI Schema URL'));
        results.add(new General_Custom_Settings__c(Name='Order_Sales_User', Value__c='ININ Standard User', Description__c='Sales User Profile'));
        results.add(new General_Custom_Settings__c(Name='Order_System_Administrator', Value__c='System Administrator', Description__c='Admin User Profile'));
        results.add(new General_Custom_Settings__c(Name='Revenue_Recognition_Role', Value__c='Revenue Recognition', Description__c='RevRec User Role'));
        results.add(new General_Custom_Settings__c(Name='FCS_Role', Value__c='Sales Order Processing', Description__c='FCS User Role'));
        results.add(new General_Custom_Settings__c(Name='RequestTransfer_ChannelMgrRole', Value__c='Channel Manager', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='OppPartnerFieldManager_DefaultTerrMgr', Value__c='005E0000004Jdn0', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='AccountApprovalQueue_ReportId', Value__c='TestId', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='AddressTriggerActive', Value__c='true', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='AllowedAccountTypes_DAMA', Value__c='Customer,Partner,Consultant', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Account_SalesRecordTypeId', Value__c='012E0000000VQyiIAG', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Account_CustomerRecordTypeId', Value__c='012E0000000VQygIAG', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Account_MasterRecordTypeId', Value__c='012E0000000VQyhIAG', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Account_ConsultantRecordTypeId', Value__c='012E0000000Ve66IAC', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Account_AllianceRecordTypeId', Value__c='012E0000000Ve65IAC', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Account_PureCloudRecordTypeId', Value__c='012E0000000oRXFIA2', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='FPX_Acceptable_ProfileIds', Value__c='00eE0000000XLCh', Description__c='	Defines which profile IDs should be allowed to go into FPX after the opp has been closed. Comma separated list'));
        results.add(new General_Custom_Settings__c(Name='FPX_Acceptable_RoleIds', Value__c='00EE0000000YDKB,00EE0000000ZkFl', Description__c='The roles that will allow a user to enter CPQ.'));
        results.add(new General_Custom_Settings__c(Name='FPX_Acceptable_PermissionSetIds', Value__c='0PSE0000000DOui', Description__c='The permissions sets that will allow a user to enter CPQ'));
        results.add(new General_Custom_Settings__c(Name='OrderApprovalQueue_ReportId', Value__c='0PSE0000000DNon', Description__c='The order approval report id'));
        results.add(new General_Custom_Settings__c(Name='Order_Rejection_EmailTemplate_Id', Value__c='00Xc0000000MVBE', Description__c='Includes the Email Template Id of the Rejection email Template being used by DAM O Process'));
        results.add(new General_Custom_Settings__c(Name='DevAzureStorageKey', Value__c='cSHTyt3Rsf9YfFlXnKWX3l8L/xMQ42s3jF9dybTwUaybKtHP2CBUSPVYHHiASfJzuy1y59i+yEMcihWeTV+uUA==', Description__c='Does not matter'));
        results.add(new General_Custom_Settings__c(Name='DevAzureStorageName', Value__c='ininisweblogin', Description__c='Does not matter'));
        results.add(new General_Custom_Settings__c(Name='DevAzureStorageContainer', Value__c='loginmanagement', Description__c='Does not matter'));
        results.add(new General_Custom_Settings__c(Name='DevAzureStorageUrl', Value__c='https://ininisweblogin.queue.core.windows.net/', Description__c='Does not matter'));
        results.add(new General_Custom_Settings__c(Name='AzureStorageKey', Value__c='cSHTyt3Rsf9YfFlXnKWX3l8L/xMQ42s3jF9dybTwUaybKtHP2CBUSPVYHHiASfJzuy1y59i+yEMcihWeTV+uUA==', Description__c='Does not matter'));
        results.add(new General_Custom_Settings__c(Name='AzureStorageName', Value__c='ininisweblogin', Description__c='Does not matter'));
        results.add(new General_Custom_Settings__c(Name='AzureStorageContainer', Value__c='loginmanagement', Description__c='Does not matter'));
        results.add(new General_Custom_Settings__c(Name='AzureStorageUrl', Value__c='https://ininisweblogin.queue.core.windows.net/', Description__c='Does not matter'));
        // Case Related General Settings
        results.add(new General_Custom_Settings__c(Name='Case_Escalation_EmailTemplate_Id', Value__c='00XE0000000O4Ee', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='PureCloudSupport_OrgWideEmail', Value__c='0D2E0000000PD41', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='PureCloudEscalation_EmailId', Value__c='sheela.ponnala@inin.com', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='PartnerCommunity_ProfileIds', Value__c='00eE0000000erHPIAY,00eE0000000ew4LIAQ,00eE0000000NtC0IAK', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='PC_CustomerCommunity_PermissionSetId', Value__c='0PSE0000000U6bb', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='PureCloud_CommunityUserProfileId', Value__c='00eE0000000Nts1', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='PureCloudCommunity_UserAppend', Value__c='.partner.inin', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Case_PureCloudSupport_RecordTypeID', Value__c='012E0000000VeWGIA0', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Case_PureCloudSupport_UnassignedQueue', Value__c='00GE0000002iHvtMAE', Description__c='Unit test'));      
        // DocuSign Related Settings
        results.add(new General_Custom_Settings__c(Name='DemoDocuSignUserName', Value__c='DemoDocuSignUserName', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='DemoDocuSignPassword', Value__c='DemoDocuSignPassword', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='ProdDocuSignUserName', Value__c='DemoDocuSignUserName', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='ProdDocuSignPassword', Value__c='DemoDocuSignPassword', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='DocuSignIntegratorKey', Value__c='DocuSignIntegratorKey', Description__c='Unit test'));
        
        //Ordering related
        results.add(new General_Custom_Settings__c(Name='Opportunity_PCRecordTypeId', Value__c='012E000000063VJIAY', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='TradeDenialIsCalledOnSubmit', Value__c='True', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='DisplayAddressesAndContactsOnOrderPage', Value__c='False', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='Push_All_Orders_To_DAM_O', Value__c='False', Description__c='Unit test'));
        
        results.add(new General_Custom_Settings__c(Name='ZuoraInitialTerm', Value__c='12', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='ZuoraRenewalTerm', Value__c='12', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='ZuoraPaymentMethod', Value__c='ACH', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='ZuoraValidUntilDays', Value__c='30', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='ZuoraStartDateDays', Value__c='90', Description__c='Unit test'));
		results.add(new General_Custom_Settings__c(Name='PureCloudApiUserId', Value__c='005E00000073Ooy', Description__c='Unit test'));
        
        // PureCloud Automated Testing
        results.add(new General_Custom_Settings__c(Name='PureCloudAccountDeleteApiAlias', Value__c='API-PC', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='PureCloudAccountDeletePrefix', Value__c='PC-TEST-ACC', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='PureCloudProductRemoval_EmailId', Value__c='andrew.doering@inin.com', Description__c='Unit test'));

        // Docusign ININ signer         
        results.add(new General_Custom_Settings__c(Name='ININ_DocuSign_CC_User_ID', Value__c='00529000000m3KVAAY', Description__c='Unit test'));
        results.add(new General_Custom_Settings__c(Name='ININ_Sales_Contract_Approver_ID', Value__c='005E0000002yfW5IAI', Description__c='Unit test'));

        
        results.add(new General_Custom_Settings__c(Name='PC_Order_Notification_URL', Value__c='https://apps.ininsca.com:443/webhooks/api/v1/webhook/9d172b75-4fb3-49f3-b3b5-d32f5a550cc4', Description__c='Unit test'));
        
        // Shared Contacts
        results.add(new General_Custom_Settings__c(Name='BypassSharedContactTriggers', Value__c='TRUE', Description__c='Unit test'));

        // PCPQ-33 Validation for only one type of engage license
        results.add(new General_Custom_Settings__c(Name='PureCloudEngagePartNumbers', Value__c='PC-170-NV-USR1;PC-170-NV-USR2;PC-170-NV-USR3;PC-170-NV-USR1C;PC-170-NV-USR2C;PC-170-NV-USR3C', Description__c='Unit test'));

		// Partner Margin Types
        results.add(new General_Custom_Settings__c(Name='Account_PartnerMarginPureCloud', Value__c='PureCloud', Description__c='The PureCloud partner margin type'));
        results.add(new General_Custom_Settings__c(Name='Account_PartnerMarginVoice', Value__c='PureCloud Voice', Description__c='	The Voice partner margin type'));

        return results;
    }

    public static List<Zuora_Custom_Settings__c> CreateZuoraCustomSettings()
    {
        List<Zuora_Custom_Settings__c> results = new List<Zuora_Custom_Settings__c>();
        results.add(new Zuora_Custom_Settings__c(Name='ZuoraInitialStatus', Value__c='Quote In Progress', Description__c='Unit test'));
        results.add(new Zuora_Custom_Settings__c(Name='ZuoraInitialTerm', Value__c='12', Description__c='Unit test'));
        results.add(new Zuora_Custom_Settings__c(Name='ZuoraRenewalTerm', Value__c='1', Description__c='Unit test'));
        results.add(new Zuora_Custom_Settings__c(Name='ZuoraPaymentMethod', Value__c='ACH', Description__c='Unit test'));
        results.add(new Zuora_Custom_Settings__c(Name='ZuoraValidUntilDays', Value__c='30', Description__c='Unit test'));
        results.add(new Zuora_Custom_Settings__c(Name='ZuoraStartDateDays', Value__c='0', Description__c='Unit test'));
        results.add(new Zuora_Custom_Settings__c(Name='PureCloudEngagePartNumbers', Value__c='PC-170-NV-USR1;PC-170-NV-USR2;PC-170-NV-USR3;PC-170-NV-USR1C;PC-170-NV-USR2C;PC-170-NV-USR3C', Description__c='Unit test'));
        results.add(new Zuora_Custom_Settings__c(Name='PureCloudProductRemoval_EmailId', Value__c='andrew.doering@inin.com', Description__c='Unit test'));

        return results;		
    }
}