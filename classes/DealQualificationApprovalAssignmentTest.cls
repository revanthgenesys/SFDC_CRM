/*
Created By: Mukunthan Koothan
Created On: 12-JAN-2018
Purpose: Test class for DealQualificationApprovalAssignment
*/

@isTest(seealldata = true)
public class DealQualificationApprovalAssignmentTest {
    
    static testmethod void submitDQToApprovalTest(){
         Util.Bypass_Trigger_Chk = true;
        Test.StartTest();
        Country__c cntry = [Select id,name,RU__c,Country__c,Old_Pricing_DAP_Region__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            //op.Country__c=cntry.Id;
            op.Country__r=cntry;
        }
        insert optyList;
        System.Debug('optyCntryId-->'+optyList[0].Country__c);
        system.debug('optycntry--->'+optyList[0].Country__r);
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';
            dq.Pricing_Model__c = 'PPU';
            dq.Opportunity__c = null;
            dq.Opportunity__r = optyList[0];
            dq.Pricing_Type__c='New Pricing';
            dq.ownerid = Userinfo.getuserid();
            dq.Type__c = 'Original';
        }
        insert dqList;
        system.debug('dqoptycntry--->'+dqList[0].Opportunity__r.Country__r.RU__c);
        
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Product Management',
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true
                                                                         ,Pricing_Type__c='New Pricing');
        insert qaConfig;
        
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        
        system.debug(dqList[0].ownerid);
        string sta = DealQualificationApprovalAssignment.submitDQToApproval(dqList[0]);
        
        Quote_Approval__c dqA = [Select id, Deal_Qualification__c from Quote_Approval__c where Deal_Qualification__c != null limit 1];
        Deal_Qualification__c dq = DealQualificationApprovalUtil.getDQFromId(dqA.Deal_Qualification__c);
        DealQualificationApprovalAssignment.submitDQToApproval(dq);  
        
        DealQualificationApprovalAssignment.updateDealQualificationApprovalHistory(dq.id);
        DealQualificationApprovalAssignment.updateDealQualificationApprovalHistory(dqlist[0].Id);
        
        dq = [Select id,Offering_Type__c,Pricing_Type__c,Platform_Type__c,Opportunity__c from Deal_Qualification__c where Type__c = :DealQualificationApprovalUtil.DQ_RECORD_HISTORY limit 1];
        dq = [Select id,Offering_Type__c,Pricing_Type__c,Platform_Type__c,Opportunity__c from Deal_Qualification__c where Type__c != :DealQualificationApprovalUtil.DQ_RECORD_HISTORY 
                AND Offering_Type__c = :dq.Offering_Type__c and Pricing_Type__c = :dq.Pricing_Type__c and Platform_Type__c = :dq.Platform_Type__c and Opportunity__c = :dq.Opportunity__c limit 1];
        dq.ELA__c = 'Yes';
        dq.Expiration_Date__c = System.today();
        dq.Ramp_Period_Days__c = 'Other';
        dq.If_Other_Ramp_Period_Requested_Days__c = 1000;
        dq.Initial_Subscription_Term_Months_PC__c = 'Other';
        dq.If_Other_Term_Months_Requested__c = 1000;
        dq.Estimated_Monthly_Recurring_Revenue__c = 90000;
        dq.Estimated_Number_of_Agents__c =-1;
        dq.Estimated_Number_of_Business_Users__c = 9000;
        dq.Business_User_to_Agent_Ratio_Exception__c = 'Yes';
        dq.More_than_5_000_Business_Users__c = 'Yes';
        dq.Less_than_100_Agents__c = 'Yes';
        dq.PureCloud_Credit_Applied__c = true;
        dq.PS_Discount_on_Quote__c = 100;
        dq.Hardware_Discount__c = 100;
        dq.Software_Discount__c = 100;
        dq.Overage_Discount__c = 100;
        dq.If_Other_PureCloud_Monthly_Minimum_Req__c = -1;
        dq.Billing_Period__c = '90';
        dq.Payment_Terms__c = '100';
        dq.Decline__c = true;
        dq.Term_Increase__c = true;
        dq.Cloud_Partner_Approval__c = true;
        dq.PPU_Deal_Approval__c = true;
        dq.IsOldPricingApproved__c = true;
        dq.Editable_List_Price_Approval_Required__c = true;
        dq.Carveout__c = true;
        dq.Additional_Legal_Terms__c = true;
        dq.CAD_Override__c = true;
        dq.Premium_Care__c = true;
        dq.X3rd_Party_Override__c = true;
         
        update dq;
        DealQualificationApprovalAssignment.updateDealQualificationApprovalHistory(dq.id);
        List<Deal_Qualification__c> DQs;
        DQs = [Select id,Offering_Type__c,Pricing_Type__c,Platform_Type__c,Opportunity__c from Deal_Qualification__c where Type__c = :DealQualificationApprovalUtil.DQ_RECORD_HISTORY and Offering_Type__c = 'PureEngage Subscription' limit 1];
        if(!DQs.isEmpty())
            DealQualificationApprovalAssignment.updateDealQualificationApprovalHistory(DQs[0].id);
        
        DQs = new List<Deal_Qualification__c>();       
        DQs = [Select id,Offering_Type__c,Pricing_Type__c,Platform_Type__c,Opportunity__c from Deal_Qualification__c where Type__c != :DealQualificationApprovalUtil.DQ_RECORD_HISTORY 
                AND Offering_Type__c = :dq.Offering_Type__c and Pricing_Type__c = :dq.Pricing_Type__c and Platform_Type__c = :dq.Platform_Type__c and Opportunity__c = :dq.Opportunity__c limit 1];
        if(!DQs.isEmpty())
            DealQualificationApprovalAssignment.updateDealQualificationApprovalHistory(DQs[0].id);
                
        Test.StopTest();
    }

    

    static testmethod void testgetNextApprovalRecords(){
         Util.Bypass_Trigger_Chk = true;
        Test.StartTest();
        Country__c cntry = [Select id,name,RU__c,Country__c,Old_Pricing_DAP_Region__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            //op.Country__c=cntry.Id;
            op.Country__r=cntry;
        }
        insert optyList;
        System.Debug('optyCntryId-->'+optyList[0].Country__c);
        system.debug('optycntry--->'+optyList[0].Country__r);
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';
            dq.Pricing_Model__c = 'PPU';
            dq.Opportunity__c = null;
            dq.Opportunity__r = optyList[0];
            dq.Pricing_Type__c='New Pricing';
            dq.ownerid = Userinfo.getuserid();
            dq.Type__c = 'Original';
            dq.Discount_On_Quote__c = 30;
            dq.Special_Offer_Terms__c = true;
            dq.Monthly_Recurring_Revenue_less_than_14K__c = 'Yes';
            dq.PureCloud_Trial__c = true;
            dq.Estimated_Monthly_Recurring_Revenue__c = 1000;
            dq.TCV_Reduction__c = 10000;
            dq.Billing_Period__c ='Monthly';
            dq.Payment_Terms__c = 'Net45';
        }
        insert dqList;
        list<Deal_Qualification__c> dqList2 = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList2){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 30%';
            dq.Payment_Terms__c = 'Net 45';
            dq.Pricing_Model__c = 'Concurrent';
            dq.Opportunity__c = null;
            dq.Opportunity__r = optyList[0];
            dq.Pricing_Type__c='New Pricing';
            dq.ownerid = Userinfo.getuserid();
            dq.Type__c = 'History';
            dq.Discount_On_Quote__c = 20;
            dq.Special_Offer_Terms__c = false;
            dq.Monthly_Recurring_Revenue_less_than_14K__c = 'No';
            dq.PureCloud_Trial__c = false;
            dq.Estimated_Monthly_Recurring_Revenue__c = 100;
            dq.TCV_Reduction__c = 100;
            dq.Billing_Period__c = 'Yearly';
            dq.Payment_Terms__c ='Net30';
        }
        insert dqList2;
        system.debug('dqoptycntry--->'+dqList[0].Opportunity__r.Country__r.RU__c);
        
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Product Management',
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true
                                                                         ,Pricing_Type__c='New Pricing');
        insert qaConfig;
        
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        
        system.debug(dqList[0].ownerid);
        string sta = DealQualificationApprovalAssignment.submitDQToApproval(dqList[0]);
        
        Quote_Approval__c dqA = [Select id, Deal_Qualification__c from Quote_Approval__c where Deal_Qualification__c != null limit 1];
        Deal_Qualification__c dq = DealQualificationApprovalUtil.getDQFromId(dqA.Deal_Qualification__c);
        DealQualificationApprovalAssignment.submitDQToApproval(dq);  
        
        DealQualificationApprovalAssignment.updateDealQualificationApprovalHistory(dq.id);
        DealQualificationApprovalAssignment.updateDealQualificationApprovalHistory(dqlist[0].Id);
        
        dq = [Select id,Offering_Type__c,Pricing_Type__c,Platform_Type__c,Opportunity__c from Deal_Qualification__c where Type__c = :DealQualificationApprovalUtil.DQ_RECORD_HISTORY limit 1];
        dq = [Select id,Offering_Type__c,Pricing_Type__c,Platform_Type__c,Opportunity__c from Deal_Qualification__c where Type__c != :DealQualificationApprovalUtil.DQ_RECORD_HISTORY 
                AND Offering_Type__c = :dq.Offering_Type__c and Pricing_Type__c = :dq.Pricing_Type__c and Platform_Type__c = :dq.Platform_Type__c and Opportunity__c = :dq.Opportunity__c limit 1];
        dq.ELA__c = 'Yes';
        dq.Expiration_Date__c = System.today();
        dq.Ramp_Period_Days__c = 'Other';
        dq.If_Other_Ramp_Period_Requested_Days__c = 1000;
        dq.Initial_Subscription_Term_Months_PC__c = 'Other';
        dq.If_Other_Term_Months_Requested__c = 1000;
        dq.Estimated_Monthly_Recurring_Revenue__c = 90000;
        dq.Estimated_Number_of_Agents__c =-1;
        dq.Estimated_Number_of_Business_Users__c = 9000;
        dq.Business_User_to_Agent_Ratio_Exception__c = 'Yes';
        dq.More_than_5_000_Business_Users__c = 'Yes';
        dq.Less_than_100_Agents__c = 'Yes';
        dq.PureCloud_Credit_Applied__c = true;
        dq.PS_Discount_on_Quote__c = 100;
        dq.Hardware_Discount__c = 100;
        dq.Software_Discount__c = 100;
        dq.Overage_Discount__c = 100;
        dq.If_Other_PureCloud_Monthly_Minimum_Req__c = -1;
        dq.Billing_Period__c = '90';
        dq.Payment_Terms__c = '100';
        dq.Decline__c = true;
        dq.Term_Increase__c = true;
        dq.Cloud_Partner_Approval__c = true;
        dq.PPU_Deal_Approval__c = true;
        dq.IsOldPricingApproved__c = true;
        dq.Editable_List_Price_Approval_Required__c = true;
        dq.Carveout__c = true;
        dq.Additional_Legal_Terms__c = true;
        dq.CAD_Override__c = true;
        dq.Premium_Care__c = true;
        dq.X3rd_Party_Override__c = true;
        dq.Type__c = 'Original';
         
        update dq;
        DealQualificationApprovalAssignment.updateDealQualificationApprovalHistory(dq.id);
        List<Quote_Approval__c> list_QP =DealQualificationApprovalAssignment.getNextApprovalRecords(dq,1);
        Test.StopTest();
    }

}