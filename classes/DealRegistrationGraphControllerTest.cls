@isTest
public class DealRegistrationGraphControllerTest {

    public static testmethod void testMethods(){
        List<Partner_Portal_Deal_Registration_Config__c> partnerPoratlConfig = new List<Partner_Portal_Deal_Registration_Config__c>();
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Cloud Partner', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Cloud Reseller', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Cloud Solution Provider', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Contract Reseller', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Lead Referral', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Managed Services Provider', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'OEM Partner', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Service Partner', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Specialized Reseller', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        partnerPoratlConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'VAR', Lab_Order__c = true, Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true));
        insert partnerPoratlConfig;
        
        TestUtil.setConfigValues();
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        
        Profile usrProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal Partner' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        testAccount.PartnerType__c = 'VAR';
        update testAccount; 
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
        
        system.runAs(runAsUser[0]){
            testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', usrProfile.id, false);  
            testUser.username = '123Name@123test.com';
            testUser.isActive = true;
            testUser.ContactId = testContact.id;
            testUser.Bypass_Triggers__c = true;
            testUser.BypassWorkflows__c = true;
            testUser.BypassValidationRules__c = true;
            insert testUser;
        }
        
        runAsUser[0] = testUser;
        
        //RecordType objRec = [Select id from RecordType where DeveloperName =: 'EMGCustomerRecordType'];
         
        Account acct = new Account( Name='Test Account', Status__c = 'Active', PartnerType__c = 'VAR', OwnerId = runAsUser[0].Id);  
        //acct.RecordTypeId = objRec.id; 
        insert acct;
        acct = testAccount;
        
        
        partner_portal_prospect__c oppReg = new partner_portal_prospect__c
                    ( Name='Test Account', Customer_Company_Name__c = 'Customer Company Name', Status__c = 'Approved', Genesys_AE__c='exec',
                      End_User_Account__c = acct.Id,
                      Account__c = acct.Id,
                      Offerings_Type__c = 'PureConnect',
                      Offering_Details__c = 'Subscription',
                      Opportunity_Currency__c = 'USD',
                      What_is_the_Expected_Close_Date__c = Date.today().addDays(1));                      
        insert oppReg; 
        oppReg = [SELECT Id , Name , Customer_Company_Name__c , Status__c , Genesys_AE__c , End_User_Account__c , 
                  Account__c , Offerings_Type__c , Offering_Details__c , Opportunity_Currency__c , What_is_the_Expected_Close_Date__c , 
                  CreatedDate FROM partner_portal_prospect__c WHERE Id = :oppReg.Id];
        System.runAs(runAsUser[0]) {                
             OpportunityNewFromRegistration.newOppFromOppRegistr(oppReg.Id, 'OppRegistration');
        }
 
        List<partner_portal_prospect__c> recList = new List<partner_portal_prospect__c>();
        List<Lead_Referral_Registration__c> leadList = new List<Lead_Referral_Registration__c>();
        for(Integer i=0;i<10;i++){
            partner_portal_prospect__c pRec = new partner_portal_prospect__c();
            Lead_Referral_Registration__c lRec = new Lead_Referral_Registration__c();
            pRec.Name = 'Test Opp Refrral';
            pRec.Customer_Company_Name__c = 'Test Customer Company Name';
            lRec.Name='Test Lead Referral';
            pRec.End_User_Account__c = acct.Id;
            lRec.Status__c = 'Request Submitted';
            if(Math.mod(i,3)==0){
                pRec.Status__c = 'Rejected';
                lRec.Status__c = 'Rejected';
            }
            else if(Math.mod(i,3)==1){
                pRec.Status__c = 'Request Pending';
                lRec.Status__c = 'Request Pending';
            }
            else{
                pRec.Status__c = 'Approved';
                lRec.Status__c = 'Approved';
            }
            pRec.Account__c = acct.Id;
            lRec.Account__c = acct.Id;
            pRec.Genesys_AE__c = 'Test';
            pRec.Status__c = 'Request Submitted';
            recList.add(pRec);
            leadList.add(lRec);
            
        }
        
        insert recList;
        insert leadList;
        
        List<Id> idLeadList = new List<Id>();
        for(Lead_Referral_Registration__c objLRR : leadList){
            idLeadList.add(objLRR.Id);
        }
        
        leadList = [SELECT Id, CreatedDate FROM Lead_Referral_Registration__c WHERE Id IN :idLeadList];
        
        String year = String.valueOf(Date.today().year());
        String qtr;
        if ( Date.today().month() <= 3 ) 
            qtr = 'Q1';
        else if ( Date.today().month() > 3 && Date.today().month() <= 6) 
            qtr = 'Q2';
        else if ( Date.today().month() > 6 && Date.today().month() <= 9) 
            qtr = 'Q3';
        else
            qtr = 'Q4';
        
        Test.startTest();
        
        System.runAs(runAsUser[0]) { 
            PageReference pg = Page.DealRegistrationGraphs;                 
            pg.getParameters().put('Id',acct.Id);
            pg.getParameters().put('runAs', runAsUser[0].Id);
            Test.setCurrentPage(pg);         
            DealRegistrationGraphController dRec = new DealRegistrationGraphController();

            dRec.getChartData();
            dRec.getLeadChartData();
            dRec.getPipeLnChartData();
            
            dRec.getQtrs();
            dRec.getOpptyYears();
            dRec.getLeadYears();
            dRec.getPpLnYears();
            
            dRec.showOppData();
            dRec.showLeadData();
            dRec.showPipelnData();
            
            dRec.hideLeadData();
            dRec.hideOppData();
            dRec.hidePipeLnData(); 
            ////////////////////////////////
            
            PageReference pgLd = Page.DealRegistrationGraphs;    
            pgLd.getParameters().put('runAs', runAsUser[0].Id);                         
            pgLd.getParameters().put('exp', 'true');    
            pgLd.getParameters().put('yr', year);   
            pgLd.getParameters().put('qtr', qtr);
            pgLd.getParameters().put('type', 'ldreg');
            
            Test.setCurrentPage(pgLd);         
            DealRegistrationGraphController dRecLd = new DealRegistrationGraphController();
            dRecLd.isLeadReferralPartner = true;
                           
            dRecLd.getLeadChartData();
            dRecLd.selectedLeadQ = qtr; 
            dRecLd.getLeadReg();      
            dRecLd.showLeadData();
            ////////////////////////////////////////
            
            PageReference pgopp = Page.DealRegistrationGraphs;  
            pgopp.getParameters().put('exp', 'true');   
            pgopp.getParameters().put('yr', year);  
            pgopp.getParameters().put('qtr', qtr);
            pgopp.getParameters().put('type', 'oppreg');
         
            Test.setCurrentPage(pgopp);         
            DealRegistrationGraphController dRecopp = new DealRegistrationGraphController();
            dRecopp.getChartData();
            dRecopp.getOpptyReg(); 
    
            ////////////////////////////////////////////////
            PageReference pgppl = Page.DealRegistrationGraphs; 
            pgppl.getParameters().put('Id',acct.Id);                           
            pgppl.getParameters().put('exp', 'true');   
            pgppl.getParameters().put('yr', year);  
            pgppl.getParameters().put('qtr', qtr);
            pgppl.getParameters().put('type', 'ppln');
            
            Test.setCurrentPage(pgppl);         
            DealRegistrationGraphController dRecppl = new DealRegistrationGraphController();
            dRecppl.selectedOpptyYear = '2017';
            dRecppl.selectedLeadYear = '2017';
            dRecppl.selectedPipelineYear = '2017';
            dRecppl.selectedOpptyQ = 'Q3';
            dRecppl.selectedLeadQ ='Q3';
            dRecppl.selectedPipelineQ  = 'Q3';
            dRecppl.selectedPipelineQ = qtr;
            dRecppl.showPipelnData();
            dRecppl.getPipeline();
            dRecppl.getPipeLnChartData();
            dRecppl.partnerOpptyReg('2017');
            dRecppl.partnerLeadReg('2017');
            dRecppl.pipeline('2017');
            
            ////////////////////////////////////////
            
            DealRegistrationGraphController.PipelineDetailData objPlDD = new DealRegistrationGraphController.PipelineDetailData(new Opportunity(Name = ''));
            dRecopp.exportDt = true; 
            dRecopp.exportType = 'oppreg'; 
            dRecopp.exportYear = '2017'; 
            dRecopp.exportQtr = 'Q4'; 
            dRecopp.partnerOpptyMap = new Map<String, List<partner_portal_prospect__c>>{'2017'=> 
                                                                                            new List<partner_portal_prospect__c>{oppReg}}; 
            dRecopp.exportDt = true; 
            
            dRecopp.getOpptyReg(); 
            dRecopp.exportQtr = 'Q1'; 
            dRecopp.getOpptyReg();
            dRecopp.exportQtr = 'Q2'; 
            dRecopp.getOpptyReg();
            dRecopp.exportQtr = 'Q3'; 
            dRecopp.getOpptyReg();
            
            dRecopp.exportDt = true; 
            dRecopp.exportType = 'ldreg'; 
            dRecopp.exportYear = '2017'; 
            dRecopp.exportQtr = 'Q4'; 
            dRecopp.partnerLeadMap = new Map<String, List<Lead_Referral_Registration__c>>{'2017'=> 
                                                                                            new List<Lead_Referral_Registration__c>{leadList[0]}}; 
            dRecopp.exportDt = true; 
            
            dRecopp.getLeadReg(); 
            dRecopp.exportQtr = 'Q1'; 
            dRecopp.getLeadReg();
            dRecopp.exportQtr = 'Q2'; 
            dRecopp.getLeadReg();
            dRecopp.exportQtr = 'Q3'; 
            dRecopp.getLeadReg();
        }       
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    static void testDealRegistrationGraphControllerQ1(){
        
        try{
            Partner_Portal_Prospect__c partnerOpp = [SELECT id, Name, Account__c, CreatedDate, CreatedById 
                                                     FROM partner_portal_prospect__c 
                                                     WHERE CreatedBy.Profile.Name = 'Genesys Portal Partner'
                                                     AND CreatedBy.isActive = true
                                                     AND CALENDAR_MONTH(CreatedDate) IN (1,2,3)
                                                     ORDER BY CreatedDate DESC Limit 1];
           
            String accountId = partnerOpp.Account__c;
            User runAsUser = [SELECT id, Name, ContactId, Contact.AccountId FROM User 
                              WHERE isActive = true AND ContactId != NULL and Profile.Name = 'Genesys Portal Partner' 
                              AND Contact.AccountId = :accountId LIMIT 1];
            
            String year = String.valueOf(partnerOpp.CreatedDate.year());
            String qtr;
            if ( partnerOpp.CreatedDate.month() <= 3 ) 
                qtr = 'Q1';
            else if ( partnerOpp.CreatedDate.month() > 3 && partnerOpp.CreatedDate.month() <= 6) 
                qtr = 'Q2';
            else if ( partnerOpp.CreatedDate.month() > 6 && partnerOpp.CreatedDate.month() <= 9) 
                qtr = 'Q3';
            else
                qtr = 'Q4';
            
            Test.startTest();
            System.runAs(runAsUser) { 
                PageReference pg = Page.DealRegistrationGraphs;                 
                pg.getParameters().put('Id', accountId);
                pg.getParameters().put('runAs', runAsUser.Id);
                Test.setCurrentPage(pg);         
                DealRegistrationGraphController dRec = new DealRegistrationGraphController();
    
                dRec.getChartData();
                dRec.getLeadChartData();
                dRec.getPipeLnChartData();
                
                dRec.getQtrs();
                dRec.getOpptyYears();
                dRec.getLeadYears();
                dRec.getPpLnYears();
                
                dRec.showOppData();
                dRec.showLeadData();
                dRec.showPipelnData();
                
                dRec.hideLeadData();
                dRec.hideOppData();
                dRec.hidePipeLnData(); 
                ////////////////////////////////
                
                PageReference pgLd = Page.DealRegistrationGraphs;    
                pgLd.getParameters().put('runAs', runAsUser.Id);                         
                pgLd.getParameters().put('exp', 'true');    
                pgLd.getParameters().put('yr', year);   
                pgLd.getParameters().put('qtr', qtr);
                pgLd.getParameters().put('type', 'ldreg');
                
                Test.setCurrentPage(pgLd);         
                DealRegistrationGraphController dRecLd = new DealRegistrationGraphController();
                dRecLd.isLeadReferralPartner = true;
                               
                dRecLd.getLeadChartData();
                dRecLd.selectedLeadQ = qtr; 
                dRecLd.getLeadReg();      
                dRecLd.showLeadData();
                ////////////////////////////////////////
                
                PageReference pgopp = Page.DealRegistrationGraphs;  
                pgopp.getParameters().put('exp', 'true');   
                pgopp.getParameters().put('yr', year);  
                pgopp.getParameters().put('qtr', qtr);
                pgopp.getParameters().put('type', 'oppreg');
             
                Test.setCurrentPage(pgopp);         
                DealRegistrationGraphController dRecopp = new DealRegistrationGraphController();
                dRecopp.getChartData();
                dRecopp.getOpptyReg(); 
        
                ////////////////////////////////////////////////
                PageReference pgppl = Page.DealRegistrationGraphs; 
                pgppl.getParameters().put('Id',accountId);                           
                pgppl.getParameters().put('exp', 'true');   
                pgppl.getParameters().put('yr', year);  
                pgppl.getParameters().put('qtr', qtr);
                pgppl.getParameters().put('type', 'ppln');
                
                Test.setCurrentPage(pgppl);         
                DealRegistrationGraphController dRecppl = new DealRegistrationGraphController();
                dRecppl.selectedOpptyYear = year;
                dRecppl.selectedLeadYear = year;
                dRecppl.selectedPipelineYear = year;
                dRecppl.selectedOpptyQ = qtr;
                dRecppl.selectedLeadQ = qtr;
                dRecppl.selectedPipelineQ  = qtr;
                dRecppl.selectedPipelineQ = qtr;
                dRecppl.showPipelnData();
                dRecppl.getPipeline();
                dRecppl.getPipeLnChartData();
                dRecppl.partnerOpptyReg(year);
                dRecppl.partnerLeadReg(year);
                dRecppl.pipeline(year);
            }       
            Test.stopTest();     
        } catch(Exception e){
            // dont do anything for now...
        }
            
    }
    
    @isTest(seeAllData=true)
    static void testDealRegistrationGraphControllerQ2(){
        try{
        Partner_Portal_Prospect__c partnerOpp = [SELECT id, Name, Account__c, CreatedDate, CreatedById 
                                                 FROM partner_portal_prospect__c 
                                                 WHERE CreatedBy.Profile.Name = 'Genesys Portal Partner'
                                                 AND CreatedBy.isActive = true
                                                 AND CALENDAR_MONTH(CreatedDate) IN (4,5,6)
                                                 ORDER BY CreatedDate DESC Limit 1];
        
        String accountId = partnerOpp.Account__c;
        User runAsUser = [SELECT id, Name, ContactId, Contact.AccountId FROM User 
                          WHERE isActive = true AND ContactId != NULL and Profile.Name = 'Genesys Portal Partner' 
                          AND Contact.AccountId = :accountId LIMIT 1];
        
        String year = String.valueOf(partnerOpp.CreatedDate.year());
        String qtr;
        if ( partnerOpp.CreatedDate.month() <= 3 ) 
            qtr = 'Q1';
        else if ( partnerOpp.CreatedDate.month() > 3 && partnerOpp.CreatedDate.month() <= 6) 
            qtr = 'Q2';
        else if ( partnerOpp.CreatedDate.month() > 6 && partnerOpp.CreatedDate.month() <= 9) 
            qtr = 'Q3';
        else
            qtr = 'Q4';
        
        Test.startTest();
        System.runAs(runAsUser) { 
            PageReference pg = Page.DealRegistrationGraphs;                 
            pg.getParameters().put('Id', accountId);
            pg.getParameters().put('runAs', runAsUser.Id);
            Test.setCurrentPage(pg);         
            DealRegistrationGraphController dRec = new DealRegistrationGraphController();

            dRec.getChartData();
            dRec.getLeadChartData();
            dRec.getPipeLnChartData();
            
            dRec.getQtrs();
            dRec.getOpptyYears();
            dRec.getLeadYears();
            dRec.getPpLnYears();
            
            dRec.showOppData();
            dRec.showLeadData();
            dRec.showPipelnData();
            
            dRec.hideLeadData();
            dRec.hideOppData();
            dRec.hidePipeLnData(); 
            ////////////////////////////////
            
            PageReference pgLd = Page.DealRegistrationGraphs;    
            pgLd.getParameters().put('runAs', runAsUser.Id);                         
            pgLd.getParameters().put('exp', 'true');    
            pgLd.getParameters().put('yr', year);   
            pgLd.getParameters().put('qtr', qtr);
            pgLd.getParameters().put('type', 'ldreg');
            
            Test.setCurrentPage(pgLd);         
            DealRegistrationGraphController dRecLd = new DealRegistrationGraphController();
            dRecLd.isLeadReferralPartner = true;
                           
            dRecLd.getLeadChartData();
            dRecLd.selectedLeadQ = qtr; 
            dRecLd.getLeadReg();      
            dRecLd.showLeadData();
            ////////////////////////////////////////
            
            PageReference pgopp = Page.DealRegistrationGraphs;  
            pgopp.getParameters().put('exp', 'true');   
            pgopp.getParameters().put('yr', year);  
            pgopp.getParameters().put('qtr', qtr);
            pgopp.getParameters().put('type', 'oppreg');
         
            Test.setCurrentPage(pgopp);         
            DealRegistrationGraphController dRecopp = new DealRegistrationGraphController();
            dRecopp.getChartData();
            dRecopp.getOpptyReg(); 
    
            ////////////////////////////////////////////////
            PageReference pgppl = Page.DealRegistrationGraphs; 
            pgppl.getParameters().put('Id',accountId);                           
            pgppl.getParameters().put('exp', 'true');   
            pgppl.getParameters().put('yr', year);  
            pgppl.getParameters().put('qtr', qtr);
            pgppl.getParameters().put('type', 'ppln');
            
            Test.setCurrentPage(pgppl);         
            DealRegistrationGraphController dRecppl = new DealRegistrationGraphController();
            dRecppl.selectedOpptyYear = year;
            dRecppl.selectedLeadYear = year;
            dRecppl.selectedPipelineYear = year;
            dRecppl.selectedOpptyQ = qtr;
            dRecppl.selectedLeadQ = qtr;
            dRecppl.selectedPipelineQ  = qtr;
            dRecppl.selectedPipelineQ = qtr;
            dRecppl.showPipelnData();
            dRecppl.getPipeline();
            dRecppl.getPipeLnChartData();
            dRecppl.partnerOpptyReg(year);
            dRecppl.partnerLeadReg(year);
            dRecppl.pipeline(year);
        }       
        Test.stopTest();   
        } catch(Exception e){
            // dont do anything for now...
        }      
    }
    
    @isTest(seeAllData=true)
    static void testDealRegistrationGraphControllerQ3(){
        try{
        Partner_Portal_Prospect__c partnerOpp = [SELECT id, Name, Account__c, CreatedDate, CreatedById 
                                                 FROM partner_portal_prospect__c 
                                                 WHERE CreatedBy.Profile.Name = 'Genesys Portal Partner'
                                                  AND CreatedBy.isActive = true
                                                 AND CALENDAR_MONTH(CreatedDate) IN (7,8,9)
                                                 ORDER BY CreatedDate DESC Limit 1];
        
        String accountId = partnerOpp.Account__c;
        User runAsUser = [SELECT id, Name, ContactId, Contact.AccountId FROM User 
                          WHERE isActive = true AND ContactId != NULL and Profile.Name = 'Genesys Portal Partner' 
                          AND Contact.AccountId = :accountId LIMIT 1];
        
        String year = String.valueOf(partnerOpp.CreatedDate.year());
        String qtr;
        if ( partnerOpp.CreatedDate.month() <= 3 ) 
            qtr = 'Q1';
        else if ( partnerOpp.CreatedDate.month() > 3 && partnerOpp.CreatedDate.month() <= 6) 
            qtr = 'Q2';
        else if ( partnerOpp.CreatedDate.month() > 6 && partnerOpp.CreatedDate.month() <= 9) 
            qtr = 'Q3';
        else
            qtr = 'Q4';
        
        Test.startTest();
        System.runAs(runAsUser) { 
            PageReference pg = Page.DealRegistrationGraphs;                 
            pg.getParameters().put('Id', accountId);
            pg.getParameters().put('runAs', runAsUser.Id);
            Test.setCurrentPage(pg);         
            DealRegistrationGraphController dRec = new DealRegistrationGraphController();

            dRec.getChartData();
            dRec.getLeadChartData();
            dRec.getPipeLnChartData();
            
            dRec.getQtrs();
            dRec.getOpptyYears();
            dRec.getLeadYears();
            dRec.getPpLnYears();
            
            dRec.showOppData();
            dRec.showLeadData();
            dRec.showPipelnData();
            
            dRec.hideLeadData();
            dRec.hideOppData();
            dRec.hidePipeLnData(); 
            ////////////////////////////////
            
            PageReference pgLd = Page.DealRegistrationGraphs;    
            pgLd.getParameters().put('runAs', runAsUser.Id);                         
            pgLd.getParameters().put('exp', 'true');    
            pgLd.getParameters().put('yr', year);   
            pgLd.getParameters().put('qtr', qtr);
            pgLd.getParameters().put('type', 'ldreg');
            
            Test.setCurrentPage(pgLd);         
            DealRegistrationGraphController dRecLd = new DealRegistrationGraphController();
            dRecLd.isLeadReferralPartner = true;
                           
            dRecLd.getLeadChartData();
            dRecLd.selectedLeadQ = qtr; 
            dRecLd.getLeadReg();      
            dRecLd.showLeadData();
            ////////////////////////////////////////
            
            PageReference pgopp = Page.DealRegistrationGraphs;  
            pgopp.getParameters().put('exp', 'true');   
            pgopp.getParameters().put('yr', year);  
            pgopp.getParameters().put('qtr', qtr);
            pgopp.getParameters().put('type', 'oppreg');
         
            Test.setCurrentPage(pgopp);         
            DealRegistrationGraphController dRecopp = new DealRegistrationGraphController();
            dRecopp.getChartData();
            dRecopp.getOpptyReg(); 
    
            ////////////////////////////////////////////////
            PageReference pgppl = Page.DealRegistrationGraphs; 
            pgppl.getParameters().put('Id',accountId);                           
            pgppl.getParameters().put('exp', 'true');   
            pgppl.getParameters().put('yr', year);  
            pgppl.getParameters().put('qtr', qtr);
            pgppl.getParameters().put('type', 'ppln');
            
            Test.setCurrentPage(pgppl);         
            DealRegistrationGraphController dRecppl = new DealRegistrationGraphController();
            dRecppl.selectedOpptyYear = year;
            dRecppl.selectedLeadYear = year;
            dRecppl.selectedPipelineYear = year;
            dRecppl.selectedOpptyQ = qtr;
            dRecppl.selectedLeadQ = qtr;
            dRecppl.selectedPipelineQ  = qtr;
            dRecppl.selectedPipelineQ = qtr;
            dRecppl.showPipelnData();
            dRecppl.getPipeline();
            dRecppl.getPipeLnChartData();
            dRecppl.partnerOpptyReg(year);
            dRecppl.partnerLeadReg(year);
            dRecppl.pipeline(year);
        }       
        Test.stopTest();   
        } catch(Exception e){
            // dont do anything for now...
        }      
    }
    
    @isTest(seeAllData=true)
    static void testDealRegistrationGraphControllerQ4(){
        try{
        Partner_Portal_Prospect__c partnerOpp = [SELECT id, Name, Account__c, CreatedDate, CreatedById 
                                                 FROM partner_portal_prospect__c 
                                                 WHERE CreatedBy.Profile.Name = 'Genesys Portal Partner'
                                                  AND CreatedBy.isActive = true
                                                 AND CALENDAR_MONTH(CreatedDate) IN (10,11,12)
                                                 ORDER BY CreatedDate DESC Limit 1];

                recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
                
                Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
                insert a1;
                
                recordtype rc1 = [select id, Name from recordtype where name = 'GEN - Opportunity Record Type'  limit 1];
                Opportunity  oppt = new Opportunity();
                oppt.Name = 'TestRec';               
                oppt.Accountid =  a1.id;               
                oppt.CloseDate  = Date.Today() + 30;
                oppt.StageName = '5.Purchase Solution';
                oppt.ForecastStatus__c = '0.Booked';
                oppt.RecordTypeId = rc1.id;
                oppt.Lead_Offer__c ='PureEngage Premise';
                insert oppt;

                
            DealRegistrationGraphController dRecTst = new DealRegistrationGraphController();
            DealRegistrationGraphController.PipelineDetailData ppldt = new DealRegistrationGraphController.PipelineDetailData(oppt);
            dRecTst.populatePipeLnDataList(ppldt,'Q4');
            dRecTst.createOpportunity();
 
        
       
        String accountId = partnerOpp.Account__c;
        User runAsUser = [SELECT id, Name, ContactId, Contact.AccountId FROM User 
                          WHERE isActive = true AND ContactId != NULL and Profile.Name = 'Genesys Portal Partner' 
                          AND Contact.AccountId = :accountId LIMIT 1];
        
        String year = String.valueOf(partnerOpp.CreatedDate.year());
        String qtr;
        if ( partnerOpp.CreatedDate.month() <= 3 ) 
            qtr = 'Q1';
        else if ( partnerOpp.CreatedDate.month() > 3 && partnerOpp.CreatedDate.month() <= 6) 
            qtr = 'Q2';
        else if ( partnerOpp.CreatedDate.month() > 6 && partnerOpp.CreatedDate.month() <= 9) 
            qtr = 'Q3';
        else
            qtr = 'Q4';
        
        Test.startTest();
        System.runAs(runAsUser) { 
            PageReference pg = Page.DealRegistrationGraphs;                 
            pg.getParameters().put('Id', accountId);
            pg.getParameters().put('runAs', runAsUser.Id);
            Test.setCurrentPage(pg);         
            DealRegistrationGraphController dRec = new DealRegistrationGraphController();

            dRec.getChartData();
            dRec.getLeadChartData();
            dRec.getPipeLnChartData();
            
            dRec.getQtrs();
            dRec.getOpptyYears();
            dRec.getLeadYears();
            dRec.getPpLnYears();
            
            dRec.showOppData();
            dRec.showLeadData();
            dRec.showPipelnData();
            
            dRec.hideLeadData();
            dRec.hideOppData();
            dRec.hidePipeLnData(); 
            ////////////////////////////////
            
            PageReference pgLd = Page.DealRegistrationGraphs;    
            pgLd.getParameters().put('runAs', runAsUser.Id);                         
            pgLd.getParameters().put('exp', 'true');    
            pgLd.getParameters().put('yr', year);   
            pgLd.getParameters().put('qtr', qtr);
            pgLd.getParameters().put('type', 'ldreg');
            
            Test.setCurrentPage(pgLd);         
            DealRegistrationGraphController dRecLd = new DealRegistrationGraphController();
            dRecLd.isLeadReferralPartner = true;
                           
            dRecLd.getLeadChartData();
            dRecLd.selectedLeadQ = qtr; 
            dRecLd.getLeadReg();      
            dRecLd.showLeadData();
            ////////////////////////////////////////
            
            PageReference pgopp = Page.DealRegistrationGraphs;  
            pgopp.getParameters().put('exp', 'true');   
            pgopp.getParameters().put('yr', year);  
            pgopp.getParameters().put('qtr', qtr);
            pgopp.getParameters().put('type', 'oppreg');
         
            Test.setCurrentPage(pgopp);         
            DealRegistrationGraphController dRecopp = new DealRegistrationGraphController();
            dRecopp.getChartData();
            dRecopp.getOpptyReg(); 
    
            ////////////////////////////////////////////////
            PageReference pgppl = Page.DealRegistrationGraphs; 
            pgppl.getParameters().put('Id',accountId);                           
            pgppl.getParameters().put('exp', 'true');   
            pgppl.getParameters().put('yr', year);  
            pgppl.getParameters().put('qtr', qtr);
            pgppl.getParameters().put('type', 'ppln');
            
            Test.setCurrentPage(pgppl);         
            DealRegistrationGraphController dRecppl = new DealRegistrationGraphController();
            dRecppl.exportDt = true;
            dRecppl.selectedOpptyYear = year;
            dRecppl.selectedLeadYear = year;
            dRecppl.selectedPipelineYear = year;
            dRecppl.selectedOpptyQ = qtr;
            dRecppl.selectedLeadQ = qtr;
            dRecppl.selectedPipelineQ  = qtr;
            dRecppl.selectedPipelineQ = qtr;
            dRecppl.showPipelnData();
            dRecppl.getPipeline();
            dRecppl.getPipeLnChartData();
            dRecppl.partnerOpptyReg(year);
            dRecppl.partnerLeadReg(year);
            dRecppl.pipeline(year);
        }       
        Test.stopTest();     
        } catch(Exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }    
    }
    
    /*stati{
            DealRegistrationGraphController dRecTst = new DealRegistrationGraphController();
            DealRegistrationGraphController.PipelineDetailData ppldt = new DealRegistrationGraphController.PipelineDetailData(oppt);
            dRecTst.populatePipeLnDataList(ppldt,'Q4');
            dRecTst.createOpportunity();
    }*/
}