/***************************************************************************************************
* 
*  Class Name      :   GSRelationshipTriggerHandler
*  Description     :   This class is used to define the method for GSRelationshipTrigger.trigger.
*  Auther          :   R Systems
* 
****************************************************************************************************/
 
public with sharing class GSRelationshipTriggerHandler {
    
    // To avoid recursion of Trigger Excucation
    public static Boolean stopRecursion = true;
    /**
    *   Method Name :   afterInsert()
    *   Description :   This method used to insert Source Account record based on the GS Relationship record.
    *   Parameters  :   mapNewGSRelationship => Map of New inserted records.
    **/
    
    public static void afterInsertUpdate(Map<Id, JBCXM__GSRelationship__c> mapNewGSRelationship,  Map<Id, JBCXM__GSRelationship__c> mapOldGSRelationship){
        
        try{
            // List to collect the Source Account record to be insert
            
            List<SourceAccounts__c> lstSourceAccountInsert = new List<SourceAccounts__c>();
            
            // List to collect the Source Account record to be Update
            
            List<SourceAccounts__c> lstSourceAccountUpdate = new List<SourceAccounts__c>();
            
            // Iterate the GS Relationship records 
            
            Map<Id, JBCXM__GSRelationship__c> mapGSRelationshipVal = new Map<Id, JBCXM__GSRelationship__c>([Select Id, JBCXM__RelationshipType__r.Name, (Select Id from Source_Accounts__r) from JBCXM__GSRelationship__c where Id In : mapNewGSRelationship.keyset()]);
            
            for(JBCXM__GSRelationship__c  gsRelationship: mapNewGSRelationship.values()){
                
                SourceAccounts__c sourceAccount = new SourceAccounts__c();
                sourceAccount.of_IVRs__c = gsrelationship.of_IVRs__c;
                sourceAccount.X2016_Revenue__c = gsrelationship.X2016_Revenue__c;
                sourceAccount.X2017_Revenue__c = gsrelationship.X2017_Revenue__c;
                sourceAccount.X2018_Revenue__c = gsrelationship.X2018_Revenue__c;
                sourceAccount.Account__c = gsrelationship.JBCXM__Account__c;
                sourceAccount.Annual_Contract_Value__c = gsrelationship.Annual_Contract_Value__c;
                sourceAccount.Applications_in_Production__c = gsrelationship.Applications_in_Production__c;
                sourceAccount.Auto_renew__c = gsrelationship.Auto_renew__c;
                sourceAccount.Auto_Speech_Recognition_ASR__c = gsrelationship.Auto_Speech_Recognition_ASR__c;
                sourceAccount.GSAverageNPSBucket__c = gsrelationship.JBCXM__GSAverageNPSBucket__c;
                sourceAccount.Billing_Frequency__c = gsrelationship.Billing_Frequency__c;
                sourceAccount.BlueIP_Softphone__c = gsrelationship.BlueIP_Softphone__c;
                sourceAccount.Bulk_Agent_Change__c = gsrelationship.Bulk_Agent_Change__c;
                sourceAccount.CaaS_Contract_Term_Date__c = gsrelationship.CaaS_Contract_Term_Date__c;
                sourceAccount.Call_Recording_Customizations__c = gsrelationship.Call_Recording_Customizations__c;
                sourceAccount.Cancel_Date__c = gsrelationship.Cancel_Date__c;
                sourceAccount.Notice_of_Cancellation__c = gsrelationship.Notice_of_Cancellation__c;
                sourceAccount.Care_Package__c = gsrelationship.Care_Package__c;
                sourceAccount.Cancellation_Reason__c = gsrelationship.Cancellation_Reason__c;
                sourceAccount.Churn_Probability__c = gsrelationship.Churn_Probability__c;
                sourceAccount.CMRR_Agents__c = gsrelationship.CMRR_Agents__c;
                sourceAccount.CMRR_CXA__c = gsrelationship.CMRR_CXA__c;
                sourceAccount.CMRR_Support__c = gsrelationship.CMRR_Support__c;
                sourceAccount.CMRR_Minutes__c = gsrelationship.CMRR_Minutes__c;
                sourceAccount.CMRR_Other__c = gsrelationship.CMRR_Other__c;
                sourceAccount.CMRR_Usage__c = gsrelationship.CMRR_Usage__c;
                sourceAccount.Collaborate_Only__c = gsrelationship.Collaborate_Only__c;
                sourceAccount.GSComments__c = gsrelationship.JBCXM__GSComments__c;
                sourceAccount.Comments_Other__c = gsrelationship.Comments_Other__c;
                sourceAccount.Committed_Agent_Seats_per_month__c = gsrelationship.Committed_Agent_Seats_per_month__c;
                sourceAccount.Communicate_Only__c = gsrelationship.Communicate_Only__c;
                sourceAccount.CSM_Company_Description__c = gsrelationship.CSM_Company_Description__c;
                sourceAccount.Complex_Integrations__c = gsrelationship.Complex_Integrations__c;
                sourceAccount.Complexity__c = gsrelationship.Complexity__c;
                sourceAccount.Compliance__c = gsrelationship.Compliance__c;
                sourceAccount.Renewal_Date__c = gsrelationship.Renewal_Date__c;
                sourceAccount.Contract_Renewal_Date_Old__c = gsrelationship.Contract_Renewal_Date_Old__c;
                sourceAccount.Contract_Term_Years__c = gsrelationship.Contract_Term_Years__c;
                sourceAccount.Contract_Term__c = gsrelationship.Contract_Term__c;
                sourceAccount.Contract_Type__c = gsrelationship.Contract_Type__c;
                sourceAccount.CRM_CTI_Adapter__c = gsrelationship.CRM_CTI_Adapter__c;
                sourceAccount.GSCSM__c = gsrelationship.JBCXM__GSCSM__c;
                sourceAccount.CSM_EOL_Communication__c = gsrelationship.CSM_EOL_Communication__c;
                sourceAccount.Premier_Edition_CSM_Manager__c = gsrelationship.Premier_Edition_CSM_Manager__c;
                sourceAccount.Premier_Edition_CSM_Mgr_Mgr__c = gsrelationship.Premier_Edition_CSM_Mgr_Mgr__c;
                sourceAccount.GSCSMModel__c = gsrelationship.JBCXM__GSCSMModel__c;
                sourceAccount.CSM_Current_Application_Use__c = gsrelationship.CSM_Current_Application_Use__c;
                sourceAccount.Custom_Adapters__c = gsrelationship.Custom_Adapters__c;
                sourceAccount.Customer_Lifecycle_Status__c = gsrelationship.Customer_Lifecycle_Status__c;
                sourceAccount.Customer_Migrated__c = gsrelationship.Customer_Migrated__c;
                sourceAccount.Customer_Since__c = gsrelationship.Customer_Since__c;
                sourceAccount.Custom_Grammars__c = gsrelationship.Custom_Grammars__c;
                sourceAccount.Customizations__c = gsrelationship.Customizations__c;
                sourceAccount.Data_File_Driven_Routing__c = gsrelationship.Data_File_Driven_Routing__c;
                sourceAccount.Data_File_Import__c = gsrelationship.Data_File_Import__c;
                sourceAccount.Date_of_Assessment__c = gsrelationship.Date_of_Assessment__c;
                sourceAccount.Dynamic_Call_Routing__c = gsrelationship.Dynamic_Call_Routing__c;
                sourceAccount.Edition__c = gsrelationship.Edition__c;
                sourceAccount.Engagement_Level__c = gsrelationship.Engagement_Level__c;
                sourceAccount.Estimated_Monthly_Revenue__c = gsrelationship.Estimated_Monthly_Revenue__c;
                sourceAccount.Executive_Sponsor__c = gsrelationship.Executive_Sponsor__c;
                sourceAccount.Explanation__c = gsrelationship.Explanation__c;
                sourceAccount.FINAL_Validated_LOE__c = gsrelationship.FINAL_Validated_LOE__c;
                sourceAccount.Full_Production_Date__c = gsrelationship.Full_Production_Date__c;
                sourceAccount.Full_production_Date_Old__c = gsrelationship.Full_production_Date_Old__c;
                sourceAccount.Gainsight_Health_Score__c = gsrelationship.Gainsight_Health_Score__c;
                sourceAccount.Go_Live_Date__c = gsrelationship.Go_Live_Date__c;
                sourceAccount.Go_Live_Date_Old__c = gsrelationship.Go_Live_Date_Old__c;
                sourceAccount.Color__c = gsrelationship.Color__c;
                sourceAccount.High_Voicemail_Boxes__c = gsrelationship.High_Voicemail_Boxes__c;
                sourceAccount.Implementation_Amount__c = gsrelationship.Implementation_Amount__c;
                sourceAccount.Implementation_Package__c = gsrelationship.Implementation_Package__c;
                sourceAccount.In_Delivery_CMRR__c = gsrelationship.In_Delivery_CMRR__c;
                sourceAccount.In_Delivery_Telco_CMRR__c = gsrelationship.In_Delivery_Telco_CMRR__c;
                sourceAccount.In_Force_CMRR__c = gsrelationship.In_Force_CMRR__c;
                sourceAccount.In_Force_Telco_CMRR__c = gsrelationship.In_Force_Telco_CMRR__c;
                sourceAccount.Initial_Order_Date__c = gsrelationship.Initial_Order_Date__c;
                sourceAccount.International__c = gsrelationship.International__c;
                sourceAccount.International_TFNs__c = gsrelationship.International_TFNs__c;
                sourceAccount.Key_Business_Outcomes_3_Year__c = gsrelationship.Key_Business_Outcomes_3_Year__c;
                sourceAccount.Key_Business_Outcomes_Critical_Use_Case__c = gsrelationship.Key_Business_Outcomes_Critical_Use_Case__c;
                sourceAccount.Key_Business_Outcomes_Critical_UseCases__c = gsrelationship.Key_Business_Outcomes_Critical_UseCases__c;
                sourceAccount.Key_Business_Outcomes_Now__c = gsrelationship.Key_Business_Outcomes_Now__c;
                sourceAccount.Key_Characteristics__c = gsrelationship.Key_Characteristics__c;
                sourceAccount.GSLatestNPSScore__c = gsrelationship.JBCXM__GSLatestNPSScore__c;
                sourceAccount.Legacy_Tier__c = gsrelationship.Legacy_Tier__c;
                sourceAccount.Live_Status__c = gsrelationship.Live_Status__c;
                sourceAccount.Premier_Edition_LOB_Leader__c = gsrelationship.Premier_Edition_LOB_Leader__c;
                sourceAccount.Status_Type__c = gsrelationship.Status_Type__c;
                sourceAccount.Manual_Override_Reason__c = gsrelationship.Manual_Override_Reason__c;
                sourceAccount.MAX_Concurrent_Calls__c = gsrelationship.MAX_Concurrent_Calls__c;
                sourceAccount.Migration_Completion_Date__c = gsrelationship.Migration_Completion_Date__c;
                sourceAccount.Migration_Notes__c = gsrelationship.Migration_Notes__c;
                sourceAccount.Migration_Platform__c = gsrelationship.Migration_Platform__c;
                sourceAccount.Migration_Target_Date__c = gsrelationship.Migration_Target_Date__c;
                sourceAccount.MPLS_Circuits__c = gsrelationship.MPLS_Circuits__c;
                sourceAccount.Multi_Channel__c = gsrelationship.Multi_Channel__c;
                sourceAccount.MultiChannel_Functionality__c = gsrelationship.MultiChannel_Functionality__c;
                sourceAccount.Multi_Lingual__c = gsrelationship.Multi_Lingual__c;
                sourceAccount.Net_Promoter_Score__c = gsrelationship.Net_Promoter_Score__c;
                sourceAccount.Status__c = gsrelationship.Status__c;
                sourceAccount.Non_Commit_MRR__c = gsrelationship.Non_Commit_MRR__c;
                sourceAccount.Open_Support_Cases__c = gsrelationship.Open_Support_Cases__c;
                sourceAccount.Original_PS_LOE_Estimate__c = gsrelationship.Original_PS_LOE_Estimate__c;
                sourceAccount.Outbound__c = gsrelationship.Outbound__c;
                sourceAccount.Outsourced_Call_Centers__c = gsrelationship.Outsourced_Call_Centers__c;
                sourceAccount.Overall_Value_Profile_Agents__c = gsrelationship.Overall_Value_Profile_Agents__c;
                sourceAccount.Overall_Value_Profile_Cross_Sell_Upsell__c = gsrelationship.Overall_Value_Profile_Cross_Sell_Upsell__c;
                sourceAccount.Overall_Value_Profile_Financial_Health__c = gsrelationship.Overall_Value_Profile_Financial_Health__c;
                sourceAccount.Overall_Value_Profile_Premier__c = gsrelationship.Overall_Value_Profile_Premier__c;
                sourceAccount.Partner_Type__c = gsrelationship.Partner_Type__c;
                sourceAccount.Payment_CC_Processing__c = gsrelationship.Payment_CC_Processing__c;
                sourceAccount.Payment_Term__c = gsrelationship.Payment_Term__c;
                sourceAccount.PC_1__c = gsrelationship.PC_1__c;
                sourceAccount.PC_2__c = gsrelationship.PC_2__c;
                sourceAccount.PC_3__c = gsrelationship.PC_3__c;
                sourceAccount.PE_SS_Flag__c = gsrelationship.PE_SS_Flag__c;
                sourceAccount.Physical_Sites__c = gsrelationship.Physical_Sites__c;
                sourceAccount.Platform__c = gsrelationship.Platform__c;
                sourceAccount.Post_to_Customer_DB__c = gsrelationship.Post_to_Customer_DB__c;
                sourceAccount.Primary_Churn_Reason__c = gsrelationship.Primary_Churn_Reason__c;
                sourceAccount.Production_Date__c = gsrelationship.Production_Date__c;
                sourceAccount.Production_SU__c = gsrelationship.Production_SU__c;
                sourceAccount.Production_Version__c = gsrelationship.Production_Version__c;
                sourceAccount.PureEngage_Cloud_Stage__c = gsrelationship.PureEngage_Cloud_Stage__c;
                sourceAccount.Ramp_Status__c = gsrelationship.Ramp_Status__c;
                sourceAccount.Reason_Customer_Left__c = gsrelationship.Reason_Customer_Left__c;
                sourceAccount.Recommendation_Est_Total_Agent_Monthly__c = gsrelationship.Recommendation_Est_Total_Agent_Monthly__c;
                sourceAccount.Recommendation_Incentive__c = gsrelationship.Recommendation_Incentive__c;
                sourceAccount.Recommendation_Migration_Target_Start__c = gsrelationship.Recommendation_Migration_Target_Start__c;
                sourceAccount.Recommendation_Migration_Type__c = gsrelationship.Recommendation_Migration_Type__c;
                sourceAccount.Recommendation_Offer__c = gsrelationship.Recommendation_Offer__c;
                sourceAccount.Recommendation_Review_Tech_Notes__c = gsrelationship.Recommendation_Review_Tech_Notes__c;
                sourceAccount.Recommendation_Validated_Lead__c = gsrelationship.Recommendation_Validated_Lead__c;
                sourceAccount.Recommendation_Value_Prop__c = gsrelationship.Recommendation_Value_Prop__c;
                sourceAccount.Remote_Agents__c = gsrelationship.Remote_Agents__c;
                sourceAccount.Replacement_Competitor__c = gsrelationship.Replacement_Competitor__c;
                sourceAccount.Reporting__c = gsrelationship.Reporting__c;
                sourceAccount.Revenue_Forecast_Target_Multiplier__c = gsrelationship.Revenue_Forecast_Target_Multiplier__c;
                sourceAccount.Risk_Profile_Customer_Engagement_Health__c = gsrelationship.Risk_Profile_Customer_Engagement_Health__c;
                sourceAccount.Risk_Profile_Financial_Health__c = gsrelationship.Risk_Profile_Financial_Health__c;
                sourceAccount.Risk_Profile_Overall_Health__c = gsrelationship.Risk_Profile_Overall_Health__c;
                sourceAccount.Risk_Profile_Product_Gap_Risk__c = gsrelationship.Risk_Profile_Product_Gap_Risk__c;
                sourceAccount.Risk_Profile_Readiness_Health__c = gsrelationship.Risk_Profile_Readiness_Health__c;
                sourceAccount.Sales_Channel__c = gsrelationship.Sales_Channel__c;
                sourceAccount.Secondary_Churn_Reason__c = gsrelationship.Secondary_Churn_Reason__c;
                sourceAccount.Segment__c = gsrelationship.Segment__c;
                sourceAccount.Self_Deployed_Self_Service_IVR__c = gsrelationship.Self_Deployed_Self_Service_IVR__c;
                sourceAccount.Self_Service_NO_ACD__c = gsrelationship.Self_Service_NO_ACD__c;
                sourceAccount.SM_EOL_Communication__c = gsrelationship.SM_EOL_Communication__c;
                sourceAccount.Spend_Category__c = gsrelationship.Spend_Category__c;
                sourceAccount.Stage__c = gsrelationship.Stage__c;
                sourceAccount.Store_Locator_Svcs__c = gsrelationship.Store_Locator_Svcs__c;
                sourceAccount.Switch_Integration__c = gsrelationship.Switch_Integration__c;
                sourceAccount.TAM__c = gsrelationship.TAM__c;
                sourceAccount.TAM_Leader__c = gsrelationship.TAM_Leader__c;
                sourceAccount.TAM_Manager__c = gsrelationship.TAM_Manager__c;
                sourceAccount.TAM_Manager_Manager__c = gsrelationship.TAM_Manager_Manager__c;
                sourceAccount.Team__c = gsrelationship.Team__c;
                sourceAccount.Third_Party_Integration__c = gsrelationship.Third_Party_Integration__c;
                sourceAccount.Tier__c = gsrelationship.Tier__c;
                sourceAccount.Timeline_Activity_Last_30__c = gsrelationship.Timeline_Activity_Last_30__c;
                sourceAccount.Timeline_Activity_Last_60__c = gsrelationship.Timeline_Activity_Last_60__c;
                sourceAccount.Top_40__c = gsrelationship.Top_40__c;
                sourceAccount.Total_Contract_Value__c = gsrelationship.Total_Contract_Value__c;
                sourceAccount.Transcription_Svcs__c = gsrelationship.Transcription_Svcs__c;
                sourceAccount.Type_of_Minutes__c = gsrelationship.Type_of_Minutes__c;
                sourceAccount.Usage_Commitment_per_Contract_Term__c = gsrelationship.Usage_Commitment_per_Contract_Term__c;
                sourceAccount.Usage_Term__c = gsrelationship.Usage_Term__c;
                sourceAccount.Validated_PS_LOE_Estimate__c = gsrelationship.Validated_PS_LOE_Estimate__c;
                sourceAccount.Variable_Driven_Survey__c = gsrelationship.Variable_Driven_Survey__c;
                sourceAccount.Win_Date__c = gsrelationship.Win_Date__c;
                sourceAccount.GS_Relationship__c = gsrelationship.Id;
                sourceAccount.Name = gsrelationship.Name;
                sourceAccount.Sales_Partner__c = gsrelationship.Sales_Partner__c;
                sourceAccount.Implementation_Partner__c = gsrelationship.Implementation_Partner__c;
                sourceAccount.Support_Partner__c = gsrelationship.Support_Partner__c;
                sourceAccount.CMRR__c = gsrelationship.CMRR__c;
                //sourceAccount.CMRR_Subscription__c = gsrelationship.CMRR_Subscription__c;
                sourceAccount.Product_Tier__c = gsrelationship.Product_Tier__c;
                sourceAccount.Support_Tier__c = gsrelationship.Support_Tier__c;
                sourceAccount.Cloud_Support_Tier__c = gsrelationship.Cloud_Support_Tier__c;
                sourceAccount.Deployment_Type__c = gsrelationship.Deployment_Type__c;
                sourceAccount.License_Amount__c = gsrelationship.License_Amount__c;
                sourceAccount.Hardware_Amount__c = gsrelationship.Hardware_Amount__c;
                sourceAccount.Genesys_Care_Amount__c = gsrelationship.Genesys_Care_Amount__c;
                sourceAccount.Step_in_Start_Date__c = gsrelationship.Step_in_Start_Date__c;
                sourceAccount.Step_in_End_Date__c = gsrelationship.Step_in_End_Date__c;
                sourceAccount.Step_in_Year_1__c = gsrelationship.Step_in_Year_1__c;
                sourceAccount.Step_in_Year_2__c = gsrelationship.Step_in_Year_2__c;
                sourceAccount.Step_in_Year_3__c = gsrelationship.Step_in_Year_3__c;
                //sourceAccount.CMRRPureCloudMonthlyMinimum__c = gsrelationship.CMRRPureCloudMonthlyMinimum__c;
                sourceAccount.ContractAttributesManualOveride__c = gsrelationship.ContractAttributesManualOveride__c;
                sourceAccount.ContractAttributesManualOverideReason__c = gsrelationship.ContractAttributesManualOverideReason__c;
                sourceAccount.Contract_Override_Initiated__c = gsrelationship.Contract_Override_Initiated__c;
                sourceAccount.Health_Score_Override_Initiated__c = gsrelationship.Health_Score_Override_Initiated__c;
                sourceAccount.Last_Contract_Override_Validation__c = gsrelationship.Last_Contract_Override_Validation__c;
                sourceAccount.Migration_Implementation_Start_Date__c = gsrelationship.Migration_Implementation_Start_Date__c;
                sourceAccount.Partner_Tier__c = gsrelationship.Partner_Tier__c;
                sourceAccount.Relationship_Level_CSM_Overide__c = gsrelationship.Relationship_Level_CSM_Overide__c;
                sourceAccount.Step_in_Year_One__c = gsrelationship.Step_in_Year_One__c;
                sourceAccount.Telco_CMRR__c = gsrelationship.Telco_CMRR__c;
                sourceAccount.Trial_Status__c = 'Active';
                sourceAccount.Offering_detail__c = gsrelationship.Offerings_Detail__c;
                sourceAccount.Type__c = gsrelationship.Offerings_Type__c;
                //Added on 11/3/17
                sourceAccount.Migration_Office_Offer_Review_c__c = gsrelationship.Migration_Office_Offer_Review__c;
                sourceAccount.Migration_Office_Offer_Second_Review_c__c= gsrelationship.Migration_Office_Offer_Review__c;
                
                if(mapGSRelationshipVal.containsKey(gsrelationship.Id)){
                    
                    // Set the Relationship Type based on RelationshipType__c lookup field
                    
                    sourceAccount.Relationship_Type__c = mapGSRelationshipVal.get(gsrelationship.Id).JBCXM__RelationshipType__r.Name;
                    
                    // Set the Record Type Id based on the Relationship Type
                    if(sourceAccount.Relationship_Type__c != '' && sourceAccount.Relationship_Type__c != null){
                        sourceAccount.recordTypeId = getRecordTypeId(getRecordTypeName(sourceAccount.Relationship_Type__c), 'SourceAccounts__c');
                    }
                }
                
                if(mapOldGSRelationship != null){
                     // If record is Updated
                     if(mapGSRelationshipVal.containsKey(gsrelationship.Id)){
                         
                         // Get Source Account Id from Inner Quesry Result
                         List<SourceAccounts__c> lstSourceAccount = mapGSRelationshipVal.get(gsrelationship.Id).Source_Accounts__r;
                         
                         if(lstSourceAccount.size() > 0){
                             sourceAccount.Id = lstSourceAccount[0].Id;
                         }
                     }
                    lstSourceAccountUpdate.add(sourceAccount);
                }else{
                     // If record is Inserted
                    lstSourceAccountInsert.add(sourceAccount);
                }
            }
            
            // Update the existing Source Account
            if(lstSourceAccountUpdate.size() > 0){
                Database.Update(lstSourceAccountUpdate, true);
            }
            // Insert the new Source Account
            if(lstSourceAccountInsert.size() > 0){
                Database.Insert(lstSourceAccountInsert, true);
            
                // Update the Source Account field on GS Relationship
                
                List<SourceAccounts__c> lstSourceAccount = [Select Id, GS_Relationship__c from SourceAccounts__c where GS_Relationship__c In : mapNewGSRelationship.keyset()];
                
                List<JBCXM__GSRelationship__c> lstGSRelationshipUpdate = new List<JBCXM__GSRelationship__c>();
                
                if(lstSourceAccount.size() > 0){
                    for(SourceAccounts__c sa : lstSourceAccount){
                        JBCXM__GSRelationship__c gsNew = new JBCXM__GSRelationship__c();
                        gsNew.Id = sa.GS_Relationship__c;
                        gsNew.Source_Account__c = sa.Id;
                        lstGSRelationshipUpdate.add(gsNew);
                    }
                    // Update the existing GS Relationship Records.
                    Database.update(lstGSRelationshipUpdate, true);
                }
            
            }
            
            stopRecursion = false;
            
        }catch(Exception ex){
           system.debug('********'+ ex.getMessage());
        }
    }
    
    public Static void afterInsert(Map<Id, JBCXM__GSRelationship__c> mapNewGSRelationship,  Map<Id, JBCXM__GSRelationship__c> mapOldGSRelationship){
        
        // Set of Account ids 
        Set<Id> accountIds = new Set<Id>();
        
         // Set of Account ids 
        Set<String> offeringTypes = new Set<String>();
        
         // Set of Account ids 
        Set<String> offeringDetails = new Set<String>();
        
        // Map to maintain the Source Account to Account
        Map<Id, List<SourceAccounts__c>> mapAccountToSourceAccount = new Map<Id, List<SourceAccounts__c>>();
        // List to update the found Source Account
        List<SourceAccounts__c> lstSourceAccountUpdate = new List<SourceAccounts__c>();
        
        // List to update the found Source Account
        List<JBCXM__GSRelationship__c> lstGSUpdate = new List<JBCXM__GSRelationship__c>();
        
        // Map to provide the need to create the Source Accocunt
        Map<Id, JBCXM__GSRelationship__c> mapNewGSCreate = new Map<Id, JBCXM__GSRelationship__c>();
        
        for(JBCXM__GSRelationship__c gs : mapNewGSRelationship.values()){
            accountIds.add(gs.JBCXM__Account__c);
            offeringTypes.add(gs.Offerings_Type__c);
            offeringDetails.add(gs.Offerings_Detail__c);
        }
        
        List<SourceAccounts__c> lstSourceAccount = [Select Id,  Account__c, Type__c, 
                                                                Offering_detail__c, 
                                                                Trial_Status__c, 
                                                                GS_Relationship__c 
                                                                from SourceAccounts__c 
                                                                where Account__c In: accountIds
                                                                and Offering_Detail__c In : offeringDetails
                                                                and Type__c In : offeringTypes];
        
        // If found multiple Account with Source Account then hanlded the Map accourdingly
        for(SourceAccounts__c sourceAccount : lstSourceAccount){
            if(mapAccountToSourceAccount.containsKey(sourceAccount.Account__c)){
                List<SourceAccounts__c> lstSA = mapAccountToSourceAccount.get(sourceAccount.Account__c);
                lstSA.add(sourceAccount);
                mapAccountToSourceAccount.put(sourceAccount.Account__c, lstSA);
            }else{
                List<SourceAccounts__c> lstSA = new List<SourceAccounts__c>();
                lstSA.add(sourceAccount);
                mapAccountToSourceAccount.put(sourceAccount.Account__c, lstSA);
            }
        }
        
        for(JBCXM__GSRelationship__c gs : mapNewGSRelationship.values()){
            if(mapAccountToSourceAccount.containsKey(gs.JBCXM__Account__c)){
                List<SourceAccounts__c> lstsa = mapAccountToSourceAccount.get(gs.JBCXM__Account__c);
                Boolean isCreate = false;
                for(SourceAccounts__c sa : lstsa){
                    if(sa.Trial_Status__c == 'Active' && sa.GS_Relationship__c != null && sa.GS_Relationship__c == gs.Id){
                        isCreate = true;
                    }else if(sa.Trial_Status__c == 'Active' && sa.GS_Relationship__c == null){
                        
                        // If found and GS Relationship is null then update the Source Account
                        isCreate = true;
                        SourceAccounts__c saUpdate = new SourceAccounts__c();
                        saUpdate.Id = sa.id;
                        saUpdate.GS_Relationship__c = gs.Id;
                        lstSourceAccountUpdate.add(saUpdate);
                        
                        JBCXM__GSRelationship__c gsUpdate = new JBCXM__GSRelationship__c();
                        gsUpdate.Id = gs.Id;
                        gsUpdate.Source_Account__c = sa.Id;
                        lstGSUpdate.add(gsUpdate);
                    }
                }
                if(!isCreate){
                     // Create Source Account Record : Here are the changes on 11/28/2017
                     mapNewGSCreate.put(gs.Id, gs);
                }
            }else{
                // Create Source Account Record : Here are the changes on 11/28/2017
                mapNewGSCreate.put(gs.Id, gs);
            }
        }
        
        if(lstSourceAccountUpdate.size() > 0 ){
            update lstSourceAccountUpdate;
        }
        if(lstGSUpdate.size() > 0 ){
            update lstGSUpdate;
        }
        // Create Source Account Record : Here are the changes on 11/28/2017
        if(mapNewGSCreate.keySet().size() > 0){
            afterInsertUpdate(mapNewGSCreate, null);
        }
        
    }
    
    /**
    *   Method Name :   getRecordTypeName()
    *   Description :   This method used to get the record Type name from Custom setting 
    *   Parameters  :   relationshipType => Relationship Type from GS Relationship
    **/
    
    public Static String getRecordTypeName(String relationshipType){
        
        if(relationshipType != null){
            
            GS_Relationship_Settings__c   gsSetting  = GS_Relationship_Settings__c.getInstance(relationshipType);
            String recordTypeName = gsSetting.Record_Type_Name__c;
            
            return recordTypeName;
        }
        return null;
    }
    
    /**
    *   Method Name :   getRecordTypeId()
    *   Description :   This method used to get the record Type Id based on the Record Type Name 
    *   Parameters  :   recordTypeName => Record Type Name, sobj => Object Name
    **/
    
    public Static Id getRecordTypeId(String recordTypeName, String sobj){
        
        if(recordTypeName != null && sobj != null){
            
            Id SoureAccountRecordTypeId = Schema.getGlobalDescribe().get(sobj).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            
            return SoureAccountRecordTypeId;
        }
        
        return null;
    }
    
    /**
    *   Method Name :   afterInsertArfUpdate()
    *   Description :   This method used to update the ARF records if Gs and ARF contains same account id and offering type
    *   Added by Priyank as discussed with JJ.
    */
    
    public Static void afterInsertArfUpdate(List<JBCXM__GSRelationship__c> listGsObj){
        Map<String, String> map_GSNameARFOffering = new Map<String, String>{'PureCloud' => 'PureCloud', 'PureConnect Cloud' => 'PureConnect', 'PureEngage Cloud' => 'PureEngage', 'PureEnagae Cloud Outbound' => 'Outbound', 'Premier Edition' => 'Premier', 'Cloud Solution Partner (PPU)' => 'Cloud Solution Partner (PPU)'};
        Map<String,String> mapAccountIdOffering = new Map<String,String>();
        List<Account_Revenue_Forecast__c> arfList = new List<Account_Revenue_Forecast__c>();
        Map<String,String> mapAccountIdGsObj = new Map<String,String>();
        
        for(JBCXM__GSRelationship__c gsObj : listGsObj){
            if(gsObj.JBCXM__Account__c != null && map_GSNameARFOffering.containsKey(gsObj.Name)){
                mapAccountIdOffering.put(gsObj.JBCXM__Account__c, map_GSNameARFOffering.get(gsObj.Name));
                mapAccountIdGsObj.put(gsObj.JBCXM__Account__c,gsObj.id);
            }
        }
        
        //for loop to fetch the ARF records which contain account id and offreing type with respect to map mapAccountIdOffering.
        for(Account_Revenue_Forecast__c arfObj : [SELECT id,GS_Relationship__c,Offering_Type__c,Account__c FROM Account_Revenue_Forecast__c 
                                                    WHERE GS_Relationship__c = '' AND Account__c IN : mapAccountIdOffering.KeySet() AND Offering_Type__c IN : mapAccountIdOffering.values()]){
            arfObj.GS_Relationship__c = mapAccountIdGsObj.get(arfObj.Account__c);
            arfList.add(arfObj);
        }   
        
        //updateing ARF records and checking the size of list greater then 0.
        if(arfList.size()>0){
            update arfList;
        }
    }
}