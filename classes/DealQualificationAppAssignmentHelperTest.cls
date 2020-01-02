/*
Created By: Mukunthan Koothan
Created On: 11-JAN-2018
Purpose: Test class for DealQualificationAppAssignmentHelper
*/

@isTest(seealldata = true)
public class DealQualificationAppAssignmentHelperTest {
    static testmethod void populateReasonToCurrentApprovalRecordTest(){
        Test.StartTest();
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),2);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureCloud';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Discount_Base_Package__c = '< 25%';
            dq.Payment_Terms__c = 'Net 45';
            dq.Deal_Score__c = 2;
            dq.Third_Party_Discount__c = 40;
            dq.Net_Deal_Size_Amount__c = 100000;
            dq.Net_Deal_Value__c = '25K - 50K';
        }
        dqList[1].Type__c = 'History';
        dqList[1].New_Pricing_Discount__c = 'No Discount';
        dqList[1].Net_Deal_Value__c = '<25K';
        dqList[0].Deal_Score__c = 2;
        insert dqList;
        
        List<Product2> listOfP2s = TestUtil.createProducts(4, false);
        listOfP2s[0].Type__c = DealQualificationApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE;
        listOfP2s[1].Type__c = DealQualificationApprovalUtil.PRODUCT_TYPE_GU;
        listOfP2s[2].Third_Party__c = 'TRUE';
        listOfP2s[3].Type__c = 'Software';        
        insert listOfP2s;
        
        List<Deal_Qualification_Products__c> listOfDQProducts = new List<Deal_Qualification_Products__c>();
        for(Integer i = 0; i < 4; i++){
            Deal_Qualification_Products__c objDQProduct = new Deal_Qualification_Products__c();
            objDQProduct.Product__c = listOfP2s[i].id;
            objDQProduct.Deal_Qualification__c = dqList[1].id;
            listOfDQProducts.add(objDQProduct);
        }
        insert listOfDQProducts;
        
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        string popRsToCrntAppRec = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);   
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = 'Discount Size - Base Package';
        qaConfig.Approval_Type__c = 'Discount Size - Base Package';
        update qaConfig;
        qASD.add(qAppStepDetails);
        
        
        string popRsToCrntAppRec2 = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = 'Deal Size';
        qaConfig.Approval_Type__c = 'Deal Size';
        update qaConfig;
        qASD.add(qAppStepDetails);
        system.debug(qASD);
        string popRsToCrntAppRec3 = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = 'ELA';
        qaConfig.Approval_Type__c = 'ELA';
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].ELA__c = 'Yes';
        string popRsToCrntAppRec4 = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        string popRsToCrntAppRec5 = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
           
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = '3rd Party';
        qaConfig.Approval_Type__c = '3rd Party';
        update qaConfig;
        qASD.add(qAppStepDetails);
        string popRsToCrntAppRec6 = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = 'Special Offer Terms';
        qaConfig.Approval_Type__c = 'Special Offer Terms';
        update qaConfig;
        qASD.add(qAppStepDetails);
        string popRsToCrntAppRec7 = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = 'Product Specific';
        qaConfig.Approval_Type__c = 'Product Specific';
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Pricing_Model__c = DealQualificationApprovalUtil.CONCURRENT;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Expiration_Date__c = System.today() +10;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].If_Other_Term_Months_Requested__c = 200;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Ramp_Period_Days__c = '90';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Monthly_Recurring_Revenue_less_than_14K__c = 'Yes';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_AGENT_MINIMUM;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_AGENT_MINIMUM;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Estimated_Number_of_Agents__c = 2;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],null,qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MAX_BUSINESS_USERS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MAX_BUSINESS_USERS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Estimated_Number_of_Business_Users__c = 6000;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Business_User_to_Agent_Ratio_Exception__c = 'Yes';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].If_Other_PureCloud_Monthly_Minimum_Req__c = 100;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].PureCloud_Credit_Applied__c = true;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].PS_Discount_on_Quote__c = 35;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Hardware_Discount__c = 35;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Software_Discount__c = 35;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        Test.StopTest();
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Overage_Discount__c = 35;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TCVREDUCTION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TCVREDUCTION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Overage_Discount__c = 35;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Billing_Period__c = 'Monthly';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Payment_Terms__c = '90';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].offering_type__c = 'PureCloud';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS;
        update qaConfig;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);

        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD;
        qaConfig.Threshold_From__c = 2;
        update qaConfig;
        update appConfStepList;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);

        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_THIRDPARTY;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_THIRDPARTY;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_Cloud_Deal;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_Cloud_Deal;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
    }
    
    static testmethod void populateReasonToCurrentApprovalRecordTest1(){
        Test.StartTest();
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),2);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Discount_Base_Package__c = '< 25%';
            dq.Payment_Terms__c = 'Net 45';
            dq.Deal_Score__c = 2;
            dq.Third_Party_Discount__c = 40;
            dq.Net_Deal_Size_Amount__c = 100000;
        }
        dqList[1].Type__c = 'History';
        dqList[0].Deal_Score__c = 2;
        insert dqList;
        
        List<Product2> listOfP2s = TestUtil.createProducts(4, false);
        listOfP2s[0].Type__c = DealQualificationApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE;
        listOfP2s[1].Type__c = DealQualificationApprovalUtil.PRODUCT_TYPE_GU;
        listOfP2s[2].Third_Party__c = 'TRUE';
        listOfP2s[3].Type__c = 'Software';        
        insert listOfP2s;
        
        List<Deal_Qualification_Products__c> listOfDQProducts = new List<Deal_Qualification_Products__c>();
        for(Integer i = 0; i < 4; i++){
            Deal_Qualification_Products__c objDQProduct = new Deal_Qualification_Products__c();
            objDQProduct.Product__c = listOfP2s[i].id;
            objDQProduct.Deal_Qualification__c = dqList[1].id;
            listOfDQProducts.add(objDQProduct);
        }
        insert listOfDQProducts;
        
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',
                                                                        Threshold_From__c = 2,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        
        

        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD;
        qaConfig.Threshold_From__c = 2;
        update qaConfig;
        update appConfStepList;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);

        
    }
    
    static testmethod void populateReasonToCurrentApprovalRecordTest2(){
        Test.StartTest();
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),2);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';
        }
        dqList[1].Type__c = 'History';
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                         Threshold_Price_From__c = 90000000,
                                                                         Criteria__c = 'test',
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        Quote_Approval__c qApproval = new Quote_Approval__c(Name='Level 1',Approval_Submission_Counter__c = 1,Deal_Qualification__c = dqList[0].id,Status__c ='Pending');
        insert qApproval;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
       
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_LEGAL_EXCEPTION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_LEGAL_EXCEPTION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRIORITY_VIP_SUPPORT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRIORITY_VIP_SUPPORT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BASE_AGENT_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BASE_AGENT_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWARE_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWARE_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADD_ON_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADD_ON_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DATA_CENTER_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DATA_CENTER_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARVEOUT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARVEOUT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SMART_USE_CASE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SMART_USE_CASE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ANNUAL_PRICE_ESCALATOR;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ANNUAL_PRICE_ESCALATOR;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGE_ALLOWANCE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGE_ALLOWANCE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS_SUBSCRIPTION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS_SUBSCRIPTION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Payment_Terms__c = 'test';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SUBSCRIPTION_SMART_QUALIFIED_APPROVAL;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SUBSCRIPTION_SMART_QUALIFIED_APPROVAL;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Subscription_Smart_Qualified_Approval__c = true;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_RENTAL_QUOTE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_RENTAL_QUOTE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Rental__c = true;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_USASE_DATA_SUBMISSION_METHOD;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_USASE_DATA_SUBMISSION_METHOD;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Usage_Data_Submission_Method__c = 'No Bursting';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
    
        DealQualificationAppAssignmentHelper.getAlreadyApprovedRecords(dqList[0],1);
        DealQualificationAppAssignmentHelper.cancelDQApprovalsOnRevise(dqList[0].id);
        DealQualificationAppAssignmentHelper.byPassApprovals(dqList[0].id);
        DealQualificationAppAssignmentHelper.orderReasons('test,test');
        List<BigMachines__Quote__c> bmq = [Select id,BigMachines__Status__c from BigMachines__Quote__c where BigMachines__Status__c != 'Revision Pending' and BigMachines__Status__c != null limit 1 ];
        Map<id,BigMachines__Quote__c> mapQ = new Map<id,BigMachines__Quote__c>();
        mapQ.put(bmq[0].id,bmq[0]);
        List<BigMachines__Quote__c> bmq2 = [Select id,BigMachines__Status__c from BigMachines__Quote__c where BigMachines__Status__c != 'Revision Pending' 
        and BigMachines__Status__c != null and id =:bmq[0].Id limit 1 ];
        bmq2[0].BigMachines__Status__c = 'Revision Pending';
        Quote_Approval__c qApproval2 = new Quote_Approval__c(Name='Level 1',Approval_Submission_Counter__c = 1,BigMachines_Quote__c = bmq2[0].Id, Status__c ='Pending');
        insert qApproval2;
        DealQualificationAppAssignmentHelper.quoteRevisionActions(bmq2,mapQ);
        
        Deal_Qualification_Products__c dqp = [Select id,Deal_Qualification__c from Deal_Qualification_Products__c limit 1];
        Deal_Qualification__c dq = DealQualificationApprovalUtil.getDQFromId(dqp.Deal_Qualification__c);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dq,null,qASD,mapIdVsQuoteConfigAndSteps);
        Test.StopTest();
        
        
    }
    
    static testmethod void populateReasonToCurrentApprovalRecordTest3(){
        Test.StartTest();
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        
        Product_Manager_Approval_Group__c testPMGroup = new Product_Manager_Approval_Group__c();
        testPMGroup.Name = 'Test PM Group';
        insert testPMGroup;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod';
        objTestProd.zqu__SKU__c ='Test1';
        objTestProd.Type__c = 'Product';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Product_Specific_Discount__c = 2;
        objTestProd.Product_Manager_Approval_Group__c = testPMGroup.id;
        objTestProd.Description = 'test 0';
        objTestProd.Shipment_Approval__c = Label.Highly_Technical_Sale_PM_Approval_Required;
        insert objTestProd;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),2);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';
            dq.Deal_Score_Size__c='< 50K';
            dq.Deal_Score__c=50;
            dq.Net_Deal_Size_Amount__c=500000;
        }
        dqList[1].Type__c = 'History';
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                         Threshold_Price_From__c = 90000000,
                                                                         Threshold_To__c=99999999999.00,
                                                                         Criteria__c = '1;50',
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;

        Quote_Approval__c qApproval = new Quote_Approval__c(Name='Level 1',Approval_Submission_Counter__c = 1,Deal_Qualification__c = dqList[0].id,Status__c ='Pending');
        insert qApproval;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
       
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_LEGAL_EXCEPTION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_LEGAL_EXCEPTION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRIORITY_VIP_SUPPORT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRIORITY_VIP_SUPPORT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BASE_AGENT_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BASE_AGENT_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWARE_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWARE_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADD_ON_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADD_ON_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DATA_CENTER_DISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DATA_CENTER_DISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARVEOUT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARVEOUT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SMART_USE_CASE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SMART_USE_CASE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ANNUAL_PRICE_ESCALATOR;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ANNUAL_PRICE_ESCALATOR;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGE_ALLOWANCE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGE_ALLOWANCE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS_SUBSCRIPTION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS_SUBSCRIPTION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Payment_Terms__c = 'test';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SUBSCRIPTION_SMART_QUALIFIED_APPROVAL;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SUBSCRIPTION_SMART_QUALIFIED_APPROVAL;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Subscription_Smart_Qualified_Approval__c = true;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_RENTAL_QUOTE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_RENTAL_QUOTE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Rental__c = true;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_USASE_DATA_SUBMISSION_METHOD;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_USASE_DATA_SUBMISSION_METHOD;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Usage_Data_Submission_Method__c = 'No Bursting';
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SEASONAL_LICENSING;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SEASONAL_LICENSING;
        update qaConfig;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
       
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT;
        update qaConfig;
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE;
        update qaConfig;
        
        qASD.add(qAppStepDetails);
        DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetails,appConfStepList,null);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        DealQualificationAppAssignmentHelper.getAlreadyApprovedRecords(dqList[0],1);
        DealQualificationAppAssignmentHelper.approvalRejectionActions(dqList[0].id);
        DealQualificationAppAssignmentHelper.cancelDQApprovalsOnRevise(dqList[0].id);
        DealQualificationAppAssignmentHelper.byPassApprovals(dqList[0].id);
        DealQualificationAppAssignmentHelper.orderReasons('test,test');
        List<BigMachines__Quote__c> bmq = [Select id,BigMachines__Status__c from BigMachines__Quote__c limit 1];
        Map<id,BigMachines__Quote__c> mapQ = new Map<id,BigMachines__Quote__c>();
        mapQ.put(bmq[0].id,bmq[0]);
        DealQualificationAppAssignmentHelper.quoteRevisionActions(bmq,mapQ);
        
        Deal_Qualification_Products__c dqp = [Select id,Deal_Qualification__c from Deal_Qualification_Products__c limit 1];
        dqp.Product__c = objTestProd.id;
        dqp.Discount__c = 3;
        update dqp;
        Deal_Qualification__c dq = DealQualificationApprovalUtil.getDQFromId(dqp.Deal_Qualification__c);
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dq,null,qASD,mapIdVsQuoteConfigAndSteps);
        String strReason = DealQualificationAppAssignmentHelper.orderReasons('New,Old');
        
        Deal_Qualification_Products__c dqp2 = new Deal_Qualification_Products__c();
        dqp2.Deal_Qualification__c= dq.id;
        dqp2.Product__c = objTestProd.id;
        dqp2.Discount__c = 15;
        insert dqp2;
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dq,dqList[1],qASD,mapIdVsQuoteConfigAndSteps);
        String strReason2 = DealQualificationAppAssignmentHelper.orderReasons('New,Old');
        Test.StopTest();
        
        
        
    }

     static testmethod void populateReasonToCurrentApprovalRecordTest4(){
        Test.StartTest();
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        
        Product_Manager_Approval_Group__c testPMGroup = new Product_Manager_Approval_Group__c();
        testPMGroup.Name = 'Test PM Group';
        insert testPMGroup;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod';
        objTestProd.zqu__SKU__c ='Test1';
        objTestProd.Type__c = 'Product';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Product_Specific_Discount__c = 2;
        objTestProd.Product_Manager_Approval_Group__c = testPMGroup.id;
        objTestProd.Description = 'test 0';
        objTestProd.Shipment_Approval__c = 'Notification Only';
        insert objTestProd;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),2);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';
        }
        dqList[1].Type__c = 'History';
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                         Threshold_Price_From__c = 90000000,
                                                                         Criteria__c = 'test',
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;

        Quote_Approval__c qApproval = new Quote_Approval__c(Name='Level 1',Approval_Submission_Counter__c = 1,Deal_Qualification__c = dqList[0].id,Status__c ='Pending');
        insert qApproval;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        
        DealQualificationAppAssignmentHelper.byPassApprovals(dqList[0].id);
        Test.StopTest();   
        
    }

    static testmethod void populateReasonToCurrentApprovalRecordTest5(){
        Test.StartTest();
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        
        Product_Manager_Approval_Group__c testPMGroup = new Product_Manager_Approval_Group__c();
        testPMGroup.Name = 'Test PM Group';
        insert testPMGroup;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod';
        objTestProd.zqu__SKU__c ='Test1';
        objTestProd.Type__c = 'Product';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Product_Specific_Discount__c = 2;
        objTestProd.Product_Manager_Approval_Group__c = testPMGroup.id;
        objTestProd.Description = 'test 0';
        objTestProd.Shipment_Approval__c = 'Notification Only';
        insert objTestProd;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),2);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';
        }
        dqList[1].Type__c = 'History';
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                         Threshold_Price_From__c = 90000000,
                                                                         Criteria__c = '2;3',
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;

        Quote_Approval__c qApproval = new Quote_Approval__c(Name='Level 1',Approval_Submission_Counter__c = 1,Deal_Qualification__c = dqList[0].id,Status__c ='Pending');
        insert qApproval;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c>qASD = new List<Quote_Approval_Step_Details__c>();
        Boolean blnResult = DealQualificationAppAssignmentHelper.getApprovalForThresholdTypeIfAny(qASD,qAppConfSteps,qAppStepDetails,100000000);
        Boolean blnResult2 = DealQualificationAppAssignmentHelper.getApprovalForThresholdTypeIfAny(qASD,qAppConfSteps,qAppStepDetails,1000000);
        Boolean blnResult3 =  DealQualificationAppAssignmentHelper.getApprovalForDealScoreThresholdTypeIfAny(qASD,qAppConfSteps,qAppStepDetails,100000000,3);
        Test.StopTest();   
        
    }

    static testMethod void unitTest(){
        
        List<Account> accounts = TestUtil.createAccounts(1, true);
        accounts[0].SMART_Qualified__c = true;
        update accounts;
        
        RecordType rt = [Select id, name, developername from Recordtype where developername = 'Professional_Services' LIMIT 1];
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today();
        opportunities.Direct_Indirect_Sale__c ='Direct';
        opportunities.StageName = '5.Purchase Solution';
        opportunities.Competitor__c = 'Bridgetec';
        opportunities.ForecastStatus__c = '0.Booked';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.License_Amount__c = 24000;
        opportunities.RecordTypeId = rt.id;
        insert opportunities;
        
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                                        = new Product_Manager_Approval_Group__c(name='Test',
                                                                                     Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod';
        objTestProd.zqu__SKU__c ='Test1';
        objTestProd.Type__c = 'Product';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Discount__c = 10;
        objTestProd.Product_Manager_Approval_Group__c =objProdMangerApprovalGroup.id;
        objTestProd.Product_Specific_Discount__c = 1;
        insert objTestProd;
        
        Deal_Qualification__c dealObj = new Deal_Qualification__c();
        dealObj.CurrencyIsoCode = 'USD';
        dealObj.Opportunity__c = opportunities.id;
        dealObj.Pricing_Type__c = 'New Pricing';
        dealObj.Type__c = 'Original';
        dealObj.Competitor__c = 'Bridgetec';
        dealObj.Compliance_of_the_Request_with_Value_Pri__c = 'Green = Value Pricing Compliant';
        dealObj.New_Pricing_Discount__c = '< 25%';
        dealObj.Net_Deal_Value__c = '25K - 50K';
        insert dealObj;
        
        Deal_Qualification_Products__c dqp = new Deal_Qualification_Products__c();
        dqp.Deal_Qualification__c= dealObj.id;
        dqp.Product__c = objTestProd.id;
        dqp.Discount__c = 15;
        insert dqp;
        
        Quote_Approver_Step_Approver_Details__c quoteApproverStepDetail = new Quote_Approver_Step_Approver_Details__c();
        quoteApproverStepDetail.Name = 'test';
        insert quoteApproverStepDetail;
        
        Quote_Approval_Steps__c quoteStep = new Quote_Approval_Steps__c();
        quoteStep.Name = 'test1';
        quoteStep.Deal_Size_Threshold_From__c = 1;
        quoteStep.Step_Type__c = 'test2';
        insert quoteStep;
        
        Quote_Approval_Step_Details__c qupteApprovalStep = new Quote_Approval_Step_Details__c();
        qupteApprovalStep.Product_Manager_Approval_Group__c = objProdMangerApprovalGroup.id;
        qupteApprovalStep.Quote_Approver_Step_Approver_Detail__c = quoteApproverStepDetail.id;
        qupteApprovalStep.Quote_Approval_Step__c = quoteStep.id;
        insert qupteApprovalStep;
        
        Quote_Approval_Config__c testConfig1 = new Quote_Approval_Config__c();
        testConfig1.Approval_Type__c = 'ELA';
        testConfig1.Quote_Type__c = 'Cloud';
        testConfig1.Offering_Type__c = 'Business Edition';
        testConfig1.Pricing_Type__c = 'New Pricing';
        testConfig1.Active__c = true;
        testConfig1.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        //testConfig1.Threshold_From__c = 2;
        //testConfig1.Criteria__c = '50;100';
        insert testConfig1;
        
        
        Quote_Approval_Config__c testConfig2 = new Quote_Approval_Config__c();
        testConfig2.Approval_Type__c = 'Deal Score';
        testConfig2.Quote_Type__c = 'Cloud';
        testConfig2.Offering_Type__c = 'Business Edition';
        testConfig2.Pricing_Type__c = 'New Pricing';
        testConfig2.Active__c = true;
        testConfig2.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfig2.Threshold_From__c = 2;
        testConfig2.Criteria__c = '50;100';
        insert testConfig2;
        
        List<Quote_Approval_Config_And_Steps__c> configAndStepList = new List<Quote_Approval_Config_And_Steps__c>();
        
        Quote_Approval_Config_And_Steps__c configAndStep = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig1.id;
        //insert configAndStep;
        configAndStepList.add(configAndStep);
        
        Quote_Approval_Config_And_Steps__c configAndStep2 = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig2.id;
        configAndStepList.add(configAndStep2);
        insert configAndStepList;
        
        Map<string,List<Quote_Approval_Config_And_Steps__c>> mapAbc = new Map<string,List<Quote_Approval_Config_And_Steps__c>>();
        mapAbc.put(qupteApprovalStep.Quote_Approval_Step__c,configAndStepList);
        
        
        
        
        
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dealObj,NULL,new List<Quote_Approval_Step_Details__c>{qupteApprovalStep},mapAbc);
        
        
        DealQualificationAppAssignmentHelper.getApprovalForThresholdTypeIfAny(new List<Quote_Approval_Step_Details__c>{qupteApprovalStep},
        configAndStep2, qupteApprovalStep, 3);
        
        
        
        DealQualificationAppAssignmentHelper.updateAmountToReadableFormat(1000);
        
        
        
        DealQualificationAppAssignmentHelper.updateAmountToReadableFormat(9999990);
        
        DealQualificationAppAssignmentHelper.updateAmountToReadableFormat(100000000);
        
        
        DealQualificationAppAssignmentHelper.getQuoteApprovalsIfReviseQuoteIsApplicableUpfront(dealObj, 2.0);

        DealQualificationAppAssignmentHelper.getQuoteApprovalsIfReviseQuoteIsApplicable(dealObj,2.0, true);
        
             
    }

    static testMethod void unitTest1(){
        
        List<Account> accounts = TestUtil.createAccounts(1, true);
        accounts[0].SMART_Qualified__c = true;
        update accounts;
        
        RecordType rt = [Select id, name, developername from Recordtype where developername = 'Professional_Services' LIMIT 1];
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today();
        opportunities.Direct_Indirect_Sale__c ='Direct';
        opportunities.StageName = '5.Purchase Solution';
        opportunities.Competitor__c = 'Bridgetec';
        opportunities.ForecastStatus__c = '0.Booked';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.License_Amount__c = 24000;
        opportunities.RecordTypeId = rt.id;
        insert opportunities;
        
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                                        = new Product_Manager_Approval_Group__c(name='Test',
                                                                                     Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod';
        objTestProd.zqu__SKU__c ='Test1';
        objTestProd.Type__c = 'Product';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Discount__c = 10;
        objTestProd.Product_Manager_Approval_Group__c =objProdMangerApprovalGroup.id;
        objTestProd.Product_Specific_Discount__c = 1;
        insert objTestProd;
        
        Deal_Qualification__c dealObj = new Deal_Qualification__c();
        dealObj.CurrencyIsoCode = 'USD';
        dealObj.Opportunity__c = opportunities.id;
        dealObj.Pricing_Type__c = 'New Pricing';
        dealObj.Type__c = 'Original';
        dealObj.Competitor__c = 'Bridgetec';
        dealObj.Compliance_of_the_Request_with_Value_Pri__c = 'Green = Value Pricing Compliant';
        dealObj.New_Pricing_Discount__c = '< 25%';
        dealObj.Net_Deal_Value__c = '25K - 50K';
        insert dealObj;
        
        Deal_Qualification_Products__c dqp = new Deal_Qualification_Products__c();
        dqp.Deal_Qualification__c= dealObj.id;
        dqp.Product__c = objTestProd.id;
        dqp.Discount__c = 15;
        insert dqp;
        
        Quote_Approver_Step_Approver_Details__c quoteApproverStepDetail = new Quote_Approver_Step_Approver_Details__c();
        quoteApproverStepDetail.Name = 'test';
        insert quoteApproverStepDetail;
        
        Quote_Approval_Steps__c quoteStep = new Quote_Approval_Steps__c();
        quoteStep.Name = 'test1';
        quoteStep.Deal_Size_Threshold_From__c = 1;
        quoteStep.Step_Type__c = 'test2';
        insert quoteStep;
        
        Quote_Approval_Step_Details__c qupteApprovalStep = new Quote_Approval_Step_Details__c();
        qupteApprovalStep.Product_Manager_Approval_Group__c = objProdMangerApprovalGroup.id;
        qupteApprovalStep.Quote_Approver_Step_Approver_Detail__c = quoteApproverStepDetail.id;
        qupteApprovalStep.Quote_Approval_Step__c = quoteStep.id;
        insert qupteApprovalStep;
        
        Quote_Approval_Config__c testConfig1 = new Quote_Approval_Config__c();
        testConfig1.Approval_Type__c = 'ELA';
        testConfig1.Quote_Type__c = 'Cloud';
        testConfig1.Offering_Type__c = 'Business Edition';
        testConfig1.Pricing_Type__c = 'New Pricing';
        testConfig1.Active__c = true;
        testConfig1.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        //testConfig1.Threshold_From__c = 2;
        //testConfig1.Criteria__c = '50;100';
        insert testConfig1;
        
        Quote_Approval_Config__c testConfig2 = new Quote_Approval_Config__c();
        testConfig2.Approval_Type__c = 'Deal Score';
        testConfig2.Quote_Type__c = 'Cloud';
        testConfig2.Offering_Type__c = 'Business Edition';
        testConfig2.Pricing_Type__c = 'New Pricing';
        testConfig2.Active__c = true;
        testConfig2.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfig2.Threshold_From__c = 2;
        testConfig2.Criteria__c = '50;100';
        insert testConfig2;
        
        List<Quote_Approval_Config_And_Steps__c> configAndStepList = new List<Quote_Approval_Config_And_Steps__c>();
        
        Quote_Approval_Config_And_Steps__c configAndStep = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig1.id;
        //insert configAndStep;
        configAndStepList.add(configAndStep);
        
        Quote_Approval_Config_And_Steps__c configAndStep2 = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig2.id;
        configAndStepList.add(configAndStep2);
        insert configAndStepList;
        
        
        
        Map<string,List<Quote_Approval_Config_And_Steps__c>> mapAbc = new Map<string,List<Quote_Approval_Config_And_Steps__c>>();
        mapAbc.put(quoteStep.id,new List<Quote_Approval_Config_And_Steps__c>{configAndStep});
        
        System.debug('mapAbc ' + mapAbc );
        
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dealObj,dealObj,new List<Quote_Approval_Step_Details__c>{qupteApprovalStep},mapAbc);
        
        
        
                   
    }
    
    static testMethod void unitTest2(){
        
        List<Account> accounts = TestUtil.createAccounts(1, true);
        accounts[0].SMART_Qualified__c = true;
        update accounts;
        
        RecordType rt = [Select id, name, developername from Recordtype where developername = 'Professional_Services' LIMIT 1];
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today();
        opportunities.Direct_Indirect_Sale__c ='Direct';
        opportunities.StageName = '5.Purchase Solution';
        opportunities.Competitor__c = 'Bridgetec';
        opportunities.ForecastStatus__c = '0.Booked';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.License_Amount__c = 24000;
        opportunities.RecordTypeId = rt.id;
        insert opportunities;
        
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                                        = new Product_Manager_Approval_Group__c(name='Test',
                                                                                     Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod';
        objTestProd.zqu__SKU__c ='Test1';
        objTestProd.Type__c = 'Product';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Discount__c = 10;
        objTestProd.Product_Manager_Approval_Group__c =objProdMangerApprovalGroup.id;
        objTestProd.Product_Specific_Discount__c = 1;
        insert objTestProd;
        
        Deal_Qualification__c dealObj = new Deal_Qualification__c();
        dealObj.CurrencyIsoCode = 'USD';
        dealObj.Opportunity__c = opportunities.id;
        dealObj.Pricing_Type__c = 'New Pricing';
        dealObj.Type__c = 'Original';
        dealObj.Competitor__c = 'Bridgetec';
        dealObj.Compliance_of_the_Request_with_Value_Pri__c = 'Green = Value Pricing Compliant';
        dealObj.New_Pricing_Discount__c = '< 25%';
        dealObj.Net_Deal_Value__c = '25K - 50K';
        dealObj.Deal_Score__c = 2;
        insert dealObj;
        
        Deal_Qualification_Products__c dqp = new Deal_Qualification_Products__c();
        dqp.Deal_Qualification__c= dealObj.id;
        dqp.Product__c = objTestProd.id;
        dqp.Discount__c = 15;
        insert dqp;
        
        Quote_Approver_Step_Approver_Details__c quoteApproverStepDetail = new Quote_Approver_Step_Approver_Details__c();
        quoteApproverStepDetail.Name = 'test';
        insert quoteApproverStepDetail;
        
        Quote_Approval_Steps__c quoteStep = new Quote_Approval_Steps__c();
        quoteStep.Name = 'test1';
        quoteStep.Deal_Size_Threshold_From__c = 1;
        quoteStep.Step_Type__c = 'test2';
        insert quoteStep;
        
        Quote_Approval_Step_Details__c qupteApprovalStep = new Quote_Approval_Step_Details__c();
        qupteApprovalStep.Product_Manager_Approval_Group__c = objProdMangerApprovalGroup.id;
        qupteApprovalStep.Quote_Approver_Step_Approver_Detail__c = quoteApproverStepDetail.id;
        qupteApprovalStep.Quote_Approval_Step__c = quoteStep.id;
        insert qupteApprovalStep;
        
        Quote_Approval_Config__c testConfig1 = new Quote_Approval_Config__c();
        testConfig1.Approval_Type__c = 'ELA';
        testConfig1.Quote_Type__c = 'Cloud';
        testConfig1.Offering_Type__c = 'Business Edition';
        testConfig1.Pricing_Type__c = 'New Pricing';
        testConfig1.Active__c = true;
        testConfig1.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        //testConfig1.Threshold_From__c = 2;
        //testConfig1.Criteria__c = '50;100';
        insert testConfig1;
        
        Quote_Approval_Config__c testConfig2 = new Quote_Approval_Config__c();
        testConfig2.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD;
        testConfig2.Quote_Type__c = 'Cloud';
        testConfig2.Offering_Type__c = 'Business Edition';
        testConfig2.Pricing_Type__c = 'New Pricing';
        testConfig2.Active__c = true;
        testConfig2.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfig2.Threshold_From__c = 2;
        insert testConfig2;
        
        List<Quote_Approval_Config_And_Steps__c> configAndStepList = new List<Quote_Approval_Config_And_Steps__c>();
        
        Quote_Approval_Config_And_Steps__c configAndStep = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig1.id;
        //insert configAndStep;
        configAndStepList.add(configAndStep);
        
        Quote_Approval_Config_And_Steps__c configAndStep2 = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig2.id;
        configAndStepList.add(configAndStep2);
        insert configAndStepList;
        
        
        
        Map<string,List<Quote_Approval_Config_And_Steps__c>> mapAbc = new Map<string,List<Quote_Approval_Config_And_Steps__c>>();
        mapAbc.put(quoteStep.id,new List<Quote_Approval_Config_And_Steps__c>{configAndStep});
        
        System.debug('mapAbc ' + mapAbc );
        
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dealObj,dealObj,new List<Quote_Approval_Step_Details__c>{qupteApprovalStep},mapAbc);
        
        
        
                   
    }

    static testmethod void populateReasonToCurrentApprovalRecordTestnew(){
        Util.Bypass_Trigger_Chk = true;
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),2);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '200M - 500M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureCloud';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Discount_Base_Package__c = '< 25%';
            dq.Payment_Terms__c = 'Net 45';
            dq.Deal_Score__c = 2;
            dq.Third_Party_Discount__c = 40;
            dq.Net_Deal_Size_Amount__c = 100000;
            dq.Net_Deal_Value__c = '25K - 50K';
            dq.Pricing_Model__c = 'PPU';
            dq.Finance_Exception__c = 'Non-Standard Warranty';
            dq.Legal_Exceptions__c = 'Deal Written on Customer Paper';
        }
        dqList[1].Type__c = 'History';
        dqList[1].New_Pricing_Discount__c = 'No Discount';
        dqList[1].Net_Deal_Value__c = '<25K';
        dqList[1].Legal_Exceptions__c = 'Limitation of Liability';
        dqList[1].Finance_Exception__c = 'Non-Standard Payment terms';

        dqList[0].Deal_Score__c = 2;
        insert dqList;
        
        List<Product2> listOfP2s = TestUtil.createProducts(4, false);
        listOfP2s[0].Type__c = DealQualificationApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE;
        listOfP2s[1].Type__c = DealQualificationApprovalUtil.PRODUCT_TYPE_GU;
        listOfP2s[2].Third_Party__c = 'TRUE';
        listOfP2s[3].Type__c = 'Software';        
        insert listOfP2s;
        
        List<Deal_Qualification_Products__c> listOfDQProducts = new List<Deal_Qualification_Products__c>();
        for(Integer i = 0; i < 4; i++){
            Deal_Qualification_Products__c objDQProduct = new Deal_Qualification_Products__c();
            objDQProduct.Product__c = listOfP2s[i].id;
            objDQProduct.Deal_Qualification__c = dqList[1].id;
            listOfDQProducts.add(objDQProduct);
        }
        insert listOfDQProducts;
        
        Map<Id,Quote_Approval_Steps__c> qAppStepsList = new Map<Id,Quote_Approval_Steps__c>([Select Id,Name from Quote_Approval_Steps__c where id in (Select Quote_Approval_Steps__c from Quote_Approval_Config_And_Steps__c) and id in(Select Quote_Approval_Step__c from Quote_Approval_Step_Details__c) limit 10]);
        
        List<Quote_Approval_Config_And_Steps__c>qAppConfStepslist = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,Quote_Approval_Config__r.Threshold_From_Details__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c,Quote_Approval_Steps__c from Quote_Approval_Config_And_Steps__c where Quote_Approval_Steps__c in:qAppStepsList.keyset()
                                                                    AND Quote_Approval_Config__r.Approval_Type__c != null];

        List<Quote_Approval_Step_Details__c>qAppStepDetailslist = [Select Id,Quote_Approval_Step__c,Quote_Approval_Step__r.Name,Product_Manager_Approval_Group__c from Quote_Approval_Step_Details__c where Quote_Approval_Step__c in:qAppStepsList.keyset() ];
        
        
            
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        for(Quote_Approval_Config_And_Steps__c qAppConfSteps:qAppConfStepslist){
         mapIdVsQuoteConfigAndSteps.put(qAppConfSteps.Quote_Approval_Steps__c,qAppConfStepslist);
         }
        
        //string aprRsn = '';
        string popRsToCrntAppRec = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetailsList[0],qAppConfStepslist,null);
        

       //Map<String, List<Quote_Approval_Config_And_Steps__c>> map_DQ = DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],dqList[1],qAppStepDetailslist,mapIdVsQuoteConfigAndSteps);
       
    }


    static testmethod void populateReasonToCurrentApprovalRecordTestnew2(){
        Util.Bypass_Trigger_Chk = true;
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),2);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '200M - 500M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureCloud';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Discount_Base_Package__c = '< 25%';
            dq.Payment_Terms__c = 'Net 45';
            dq.Deal_Score__c = 2;
            dq.Third_Party_Discount__c = 40;
            dq.Net_Deal_Size_Amount__c = 100000;
            dq.Net_Deal_Value__c = '25K - 50K';
            dq.Pricing_Model__c = 'PPU';
            dq.Finance_Exception__c = 'Non-Standard Warranty';
            dq.Legal_Exceptions__c = 'Deal Written on Customer Paper';
        }
        dqList[1].Type__c = 'History';
        dqList[1].New_Pricing_Discount__c = 'No Discount';
        dqList[1].Net_Deal_Value__c = '<25K';
        dqList[1].Legal_Exceptions__c = 'Limitation of Liability';
        dqList[1].Finance_Exception__c = 'Non-Standard Payment terms';

        dqList[0].Deal_Score__c = 2;
        insert dqList;
        
        List<Product2> listOfP2s = TestUtil.createProducts(4, false);
        listOfP2s[0].Type__c = DealQualificationApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE;
        listOfP2s[1].Type__c = DealQualificationApprovalUtil.PRODUCT_TYPE_GU;
        listOfP2s[2].Third_Party__c = 'TRUE';
        listOfP2s[3].Type__c = 'Software';        
        insert listOfP2s;
        
        List<Deal_Qualification_Products__c> listOfDQProducts = new List<Deal_Qualification_Products__c>();
        for(Integer i = 0; i < 4; i++){
            Deal_Qualification_Products__c objDQProduct = new Deal_Qualification_Products__c();
            objDQProduct.Product__c = listOfP2s[i].id;
            objDQProduct.Deal_Qualification__c = dqList[1].id;
            listOfDQProducts.add(objDQProduct);
        }
        insert listOfDQProducts;
        
        Map<Id,Quote_Approval_Steps__c> qAppStepsList = new Map<Id,Quote_Approval_Steps__c>([Select Id,Name from Quote_Approval_Steps__c where id in (Select Quote_Approval_Steps__c from Quote_Approval_Config_And_Steps__c) and id in(Select Quote_Approval_Step__c from Quote_Approval_Step_Details__c) limit 5]);
        
        List<Quote_Approval_Config_And_Steps__c>qAppConfStepslist = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,Quote_Approval_Config__r.Threshold_From_Details__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c,Quote_Approval_Steps__c from Quote_Approval_Config_And_Steps__c where Quote_Approval_Steps__c in:qAppStepsList.keyset()];

        List<Quote_Approval_Step_Details__c>qAppStepDetailslist = [Select Id,Quote_Approval_Step__c,Quote_Approval_Step__r.Name,Product_Manager_Approval_Group__c from Quote_Approval_Step_Details__c where Quote_Approval_Step__c in:qAppStepsList.keyset() ];
        
        
            
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        for(Quote_Approval_Config_And_Steps__c qAppConfSteps:qAppConfStepslist){
         mapIdVsQuoteConfigAndSteps.put(qAppConfSteps.Quote_Approval_Steps__c,qAppConfStepslist);
         }
        
        //string aprRsn = '';
        //string popRsToCrntAppRec = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dqList[0],qAppStepDetailsList[0],qAppConfStepslist,null);
        

       Test.StartTest();
       //Map<String, List<Quote_Approval_Config_And_Steps__c>> map_DQ1 = DealQualificationAppAssignmentHelper.filterQuoteApprovals(dqList[0],null,qAppStepDetailslist,mapIdVsQuoteConfigAndSteps);
       Test.stopTest();
    }

        
}