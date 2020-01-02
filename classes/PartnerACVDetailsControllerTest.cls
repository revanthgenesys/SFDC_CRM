/*
Created By: Mukunthan Koothan
Created On: 02/02/2018
Purpose: Test class for PartnerACVDetailsController
*/

@isTest

public class PartnerACVDetailsControllerTest{

    static testmethod void getoptyListTest(){
    
        test.startTest();
        string bizAccRT;
        string euACCRT;
        string oppNewRT;
        string renewalRT;
        
        List<recordtype> recTp = [Select Id,DeveloperName from recordtype where DeveloperName IN 
                                     ('EMGBusinessPartnerRecordType','EMGCustomerRecordType','GEN_Opportunity_Record_Type_New','Genesys_Renewal')];
        
        for(recordtype rt:recTp){
            if(rt.developername == 'EMGBusinessPartnerRecordType'){
                bizAccRT = rt.Id;
            }
            else if(rt.developername == 'EMGCustomerRecordType'){
                euACCRT = rt.Id;
            }
            else if(rt.developername == 'GEN_Opportunity_Record_Type_New'){
                oppNewRT = string.valueof(rt.Id).Left(15);
            }
            else if(rt.developername == 'Genesys_Renewal'){
                renewalRT = rt.Id;
            }
        }
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'GEN - Direct Touch AMERICAS' LIMIT 1]; 

        User usr = new User(profileId = partnerProfile.id,username = 'newUser211@salesforce.com',email = 'pb211@ff.com',
                                    emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                    timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',Bypass_Triggers__c = true, BypassValidationRules__c=true);
        insert usr;
        
        System.runAs(usr){

            account testBizPartner = new Account(Name='TestBizAccount',Partner_Offering_Type__c = 'PureCloud Reseller',
                                                    recordtypeid=bizAccRT);
            insert testBizPartner;
            account testEndUsrAcc = new Account(Name = 'TestEUAcc',recordtypeid = euACCRT);
            insert testEndUsrAcc;
            
            Contact testContact = new Contact (AccountId = testBizPartner.id,FirstName='TestContact',LastName = 'Foss',Designated_Partner_Contact__c = true);
            insert testContact;
            
            opportunity opty = new opportunity(Name = 'TestOpty',ACV_Subscription_Only__c=15000.00,BusinessPartner__c = testBizPartner.Id,AccountId=testEndUsrAcc.Id,Closedate = system.today(),
                                        Lines_of_Businesses__c='PureCloud',recordtypeid=oppNewRT, Win_Loss_Status__c = 'Won',StageName='6.Closed',
                                        ForecastStatus__c='0.Booked',Competitor__c = 'Avaya (Nortel)',Account=testEndUsrAcc,BusinessPartner__r=testBizPartner,
                                        Factors_Influencing_Price__c='Fit within customer budget',Key_Business_Objective__c='Reduce Workforce Planning Inefficiencies and Costs',
                                        Was_SIP_Server_part_of_the_Solution__c='Yes',WonLostCancelledComments__c='This is a test This is a test This is a test This is a testThis is a test This is a test This is a test This is a test This is a test This is a test This is a test This is a test This is a testThis is a test This is a test This is a test This is a test This is a test This is a test This is a test This is a test This is a test ');
            insert opty;
            
            list<global_setting__c> glgSetLst = new list<global_setting__c>();
            Global_setting__c perfDashb = new Global_setting__c(Name='Performance Dash 2019',Information__c='2019,2020,2021,2022,2023,2024,2025');
            Global_setting__c optyRecTp = new Global_setting__c(Name='GEN - Opportunity Record Type',Information__c='RecordType',ID__c='012U0000000LrBP',Type__c='Opportunity');
            glgSetLst.add(perfDashb);
            glgSetLst.add(optyRecTp);
            insert glgSetLst;
            
            list<Opportunity> testOpp1 = TestUtil.createOpportunities(1, testEndUsrAcc.id, false);
            testOpp1[0].Closedate = date.newinstance(2018, 2, 17);
            testOpp1[0].Lines_of_Businesses__c='PureCloud';
            testOpp1[0].BusinessPartner__c = testBizPartner.id;
            testOpp1[0].Win_Loss_Status__c = 'Won';
            testOpp1[0].RecordTypeId = '012U0000000LrBP';
            
            /*testOpp1[1].Closedate = date.newinstance(2019, 2, 18);
            testOpp1[1].StageName = '6.Closed';
            testOpp1[1].Win_Loss_Status__c = 'Won';
            testOpp1[1].RecordTypeId = '012U0000000LrBP';
            testOpp1[1].BusinessPartner__c = testBizPartner.id;
            testOpp1[1].Lead_Offer__c = 'PureConnect Premise';
            
            testOpp1[2].Closedate = date.newinstance(2019, 2, 18);
            testOpp1[2].StageName = '6.Closed';
            testOpp1[2].Win_Loss_Status__c = 'Won';
            testOpp1[2].RecordTypeId = '012U0000000LrBP';
            testOpp1[2].BusinessPartner__c = testBizPartner.id;
            testOpp1[2].Lead_Offer__c = 'PureConnect Cloud';*/
            
            insert testOpp1;

              PageReference tstpg = Page.PartnerACVDetails;
              Test.setCurrentPage(tstpg);
              tstpg.getParameters().put('syr',string.valueof(opty.CloseDate.year()));
              tstpg.getParameters().put('recTp',renewalRT);
              tstpg.getParameters().put('uAccId',testBizPartner.Id);
              PartnerACVDetailsController pACV = new PartnerACVDetailsController();
              pACV.getoptyList();
              pACV.getdatedCurrencies();
              
              PageReference tstpg1 = Page.PartnerACVDetails;
              Test.setCurrentPage(tstpg1);
              tstpg1.getParameters().put('syr','2018');
              tstpg1.getParameters().put('recTp',renewalRT);
              tstpg1.getParameters().put('uAccId',testBizPartner.Id);
              PartnerACVDetailsController pACV1 = new PartnerACVDetailsController();
              pACV1.getoptyList();
        }
        
        test.stopTest();
        
    }
}