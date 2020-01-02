@isTest(SeeAllData = true)
private class PartnerServiceEntitlementCtrl_Test
{

              static Contact testContact;
    static testmethod void testOnServiceEntitlementCtrlNew()
    {
        //try
        //{
            Test.startTest();
            
            
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            Map<ID, Opportunity> opplst;
            //List<Address__c>list_Address = new List<Address__c>();
            RecordType objRecType = [select id,name from RecordType where name =: 'EMG - Customer Record Type'];
            RecordType objRecType_Opp = [select id,name from RecordType where name =: 'GEN - Opportunity Record Type'];
            
            

            System.runAs(runAsUser[0]) 
            {
                Country__c objCountry = setupCountry();
                List<Account> list_Accounts = TestUtil.createAccounts(1,false);
                list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
                list_Accounts[0].Street1__c = 'test';
                list_Accounts[0].City__c= 'test';
                list_Accounts[0].Industry__c = 'Agriculture';
                list_Accounts[0].Country__c= objCountry.id;
                list_Accounts[0].Phone = '123456789';
                list_Accounts[0].Type_of_Commerce__c = 'Business-to-Business';
                list_Accounts[0].ZipCode__c = '12345';
                list_Accounts[0].Auto_Renew_Contractual_Increase__c = 1;
                list_Accounts[0].Auto_Renew_Contract_Term__c = 1;
                list_Accounts[0].Campaign_Target__c ='Please remove from Campaign';
                list_Accounts[0].Campaign_Target_Removal_Reason__c ='other';
                insert list_Accounts;
                
                Contact testContact = new Contact();
                testContact.AccountId = list_Accounts[0].id;
                testContact.LastName = 'Test Contact';
                insert testContact;
               
                //List<Opportunity> opportunities = TestUtil.createOpportunities(2, accounts[0].Id, true);
                Opportunity opportunities = new Opportunity();
                opportunities.Name = 'Test Opp';
                opportunities.accountid = list_Accounts [0].Id;
                opportunities.closeDate = Date.today().addMonths(1);
                opportunities.StageName = '1.Recognize Needs';
                opportunities.CurrencyIsoCode = 'USD';
                opportunities.Country__c = objCountry.Id;
                opportunities.Lines_of_Businesses__c = 'PureCloud';
                
                insert opportunities;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = opportunities.Id;
                objQuote.Quote_Created_Date__c = System.today();
                objQuote.BigMachines__Status__c = 'Quote In Progress';
                objQuote.Grid_Group_By__c = 'Use Cases';
                objQuote.Service_Level__c = 'Business';
                objQuote.PPU_Rental__c = true;
                objQuote.Pricing_Model__c = 'Enabled';
                objQuote.Quote_Opportunity_Type__c = 'New Pricing';
                objQuote.Quote_Business_Type__c = 'On Premise';
                objQuote.Offering_Type__c = 'PureCloud-Cloud Order';
                objQuote.Order_Numb_of_Maint_Months__c = 12;
                insert objQuote;
                
                List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'PureSuccess_Services'];
                Case cs = new Case(status='Open',subject='test', ContactId = testContact.Id,                      
                               recordtypeid = rectp[0].id);                        
                insert cs;
              
                List<Product2> list_Products = TestUtil.createProducts(5, false);
                System.assert(list_Products.size() == 5);
                integer i=1;
                for(Product2 objProduct :  list_Products){
                    objProduct.APN_Number__c = 'APNABC'+objProduct.Name;
                    objProduct.zqu__SKU__c = 'test1'+i;
                    i++;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              //prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              //prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              Id RecordTypeIdOrder = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = opportunities.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.License_FYM_detail__c = 'Subscription Order';
              //ord_1.Offering_Type__c = 'PureCloud';
              ord_1.CurrencyIsoCode = 'USD';
              ord_1.recordtypeid = RecordTypeIdOrder;
              insert ord_1;
              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);
              
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              tkAll.Token_status__c = 'Allocated';
              insert tkAll;
              
              Token_Consumption__c tknc = new Token_Consumption__c();
              tknc.Product__c = list_Products[0].Id;
              tknc.Status__c = 'In Progress';
              tknc.Tokens__c = 10;
              tknc.Token_Allocation__c = tkAll.Id;
              insert tknc;
               List<Pure_Success_Package__c> pSuccessPkg = new List<Pure_Success_Package__c>();
               List<Token_Allocations__c> tknlst = new List<Token_Allocations__c>();
               List<Package_Services__c> pkgSrv = new List<Package_Services__c>();
               List<Product_Group_Item__c> pdgrpItm = new List<Product_Group_Item__c>();
               List<Token_Consumption__c> tknc1 = new List<Token_Consumption__c>();
                List<GU_Entitlement__c> lstGUEnt= new List<GU_Entitlement__c>();
                List<Contact> lstcont = new List<Contact>();
                
                
                
               Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;  
               ppkg.Package_type__c = 'Pure Success';
               ppkg.token_Status__c = 'Allocated';
               ppkg.Order__c = ord_1.Id;
               insert ppkg;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;
                
                Pure_Success_Package__c ppkg1 = new Pure_Success_Package__c();
                ppkg1.Account__c = list_Accounts[0].id;
                ppkg1.Product__c = list_Products[0].id; 
                ppkg1.Package_type__c = 'Pure Success'; 
                ppkg1.token_Status__c = 'Allocated';
                ppkg1.Order__c = ord_1.Id;
                insert ppkg1;
               
                Package_services__c pkg1 = new Package_services__c ();
                pkg1.Case__c = cs.id;
                pkg1.Status__c = 'Allocated';        
                pkg1.PureSuccess_Package__c = ppkg1.id;
                insert pkg1;
                 
               Pure_Success_Package__c ppkg2 = new Pure_Success_Package__c();
               ppkg2.Account__c = list_Accounts[0].id;
               ppkg2.Product__c = list_Products[0].id;
               ppkg2.Package_Type__c = 'A la Carte';
               ppkg2.token_Status__c = 'Allocated';
               ppkg2.Order__c = ord_1.Id;
               insert ppkg2;
               
                Package_services__c pkg2 = new Package_services__c ();
                pkg2.Case__c = cs.id;
                pkg2.Status__c = 'Consumed';        
                pkg2.PureSuccess_Package__c = ppkg2.id;
                insert pkg2;
                
                Pure_Success_Package__c ppkg3 = new Pure_Success_Package__c();
               ppkg3.Account__c = list_Accounts[0].id;
               ppkg3.Product__c = list_Products[0].id;
               ppkg3.Package_Type__c = 'A la Carte';
               ppkg3.token_Status__c = 'Allocated';
               ppkg3.Order__c = ord_1.Id;
               insert ppkg3;
               
                Package_services__c pkg3 = new Package_services__c ();
                pkg3.Case__c = cs.id;
                pkg3.Status__c = 'Allocated';        
                pkg3.PureSuccess_Package__c = ppkg3.id;
                insert pkg3;
                
                pkg3.Status__c= 'In Progress';
                pkg3.Case__c = cs.id;
                
                update pkg3;
        
                string accountId =  list_Accounts[0].Id;
                string packageId = ppkg.id;
                string packageId1 = ppkg1.id;
                string productId = list_Products[0].id;
                String prdGroup =   prdgrp.id;
                string packageSrvId = pkg3.id;
                string tokenId = tkAll.id;
                PageReference testPage = new pagereference('/apex/VisualforcePage');
                ApexPages.currentPage().getParameters().put( 'accId', accountId );
                
                PartnerServiceEntitlementCtrl MyControllerObj = new PartnerServiceEntitlementCtrl();
                Boolean isBuy = MyControllerObj.isBuy;
                
                pSuccessPkg = PartnerServiceEntitlementCtrl.pureSuccessPacklist(accountId,'','');
                pSuccessPkg = PartnerServiceEntitlementCtrl.pureSuccessPacklist(accountId,'false',''); 
                tknlst = PartnerServiceEntitlementCtrl.getTokenAllocation(accountId);              
                pkgSrv  = PartnerServiceEntitlementCtrl.getPackageServicesConsumed(packageId,'','');
                pkgSrv  = PartnerServiceEntitlementCtrl.getPackageServicesConsumed(packageId,'false','');
                pkgSrv = PartnerServiceEntitlementCtrl.getPackageServicesAvailable(packageId1,'','');
                pkgSrv = PartnerServiceEntitlementCtrl.getConsumedAlaCarte(accountId,'PureCloud');
                pkgSrv = PartnerServiceEntitlementCtrl.getExpiredAlaCarte(accountId,'PureCloud');
                pkgSrv = PartnerServiceEntitlementCtrl.getAlocatedAlaCarte(accountId,'','','PureCloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'','','BRL','PureEngage Cloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'true','','USD','PureEngage Cloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'false','','AUD','PureEngage Cloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'false','','CAD','PureConnect Cloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'false','','EUR','PureEngage Cloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'false','','GBP','PureEngage Cloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'false','','JPY','PureEngage Cloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'false','','NZD','PureEngage Cloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'false','','ZAR','PureEngage Cloud');
                pdgrpItm  = PartnerServiceEntitlementCtrl.getProductGroupItems(accountId,'false','','ZAR','PureCloud');
                
                 lstGUEnt = ServiceEntitlementCtrl.getTokenAllocationGUcancelled(accountId,'true','true');
                 lstGUEnt = ServiceEntitlementCtrl.getTokenAllocationGUInProgress(accountId,'true','true');
                 lstGUEnt = ServiceEntitlementCtrl.getTokenAllocationGUCompleted(accountId,'true','true');
                 PartnerServiceEntitlementCtrl.getTokenAllocationGUcancelled(accountId,'true','true');
                 PartnerServiceEntitlementCtrl.getTokenAllocationGUInProgress(accountId,'true','true');
                 PartnerServiceEntitlementCtrl.getTokenAllocationGUCompleted(accountId,'true','true');
                 PartnerServiceEntitlementCtrl.getTokenConsumptionFortknAllc(tknc.id);
                 PartnerServiceEntitlementCtrl.getEndContactList(accountId);
                 
                tknlst = PartnerServiceEntitlementCtrl.getTokenAllocationGU(accountId,'',''); 
                 lstcont = ServiceEntitlementCtrl.getEndContactList(accountId);
                 pkgSrv = PartnerServiceEntitlementCtrl.getPackageServicesAvailable(packageId1,'true','');
                 pkgSrv = PartnerServiceEntitlementCtrl.getPackageServicesAvailable(packageId1,'false','');
                 pkgSrv = PartnerServiceEntitlementCtrl.getAlocatedAlaCarte(accountId,'true','','PureCloud');
                 pkgSrv = PartnerServiceEntitlementCtrl.getAlocatedAlaCarte(accountId,'false','','PureCloud');
                 tknc1  = ServiceEntitlementCtrl.getTokenConsumptionFortknAllc(tknc.id);
                 MyControllerObj.availableTokenAlaCarte =1.01;
                 MyControllerObj.serviceValue = '1.01';
                 MyControllerObj.showAllServiceElement = '1.01';
                 MyControllerObj.showSelfServiceElement = '1.01';
                 MyControllerObj.contactName = '1.01';
                
            }
            
            
            Test.stopTest();
        //}
        //catch(CalloutException e){}
    }
 static testmethod void testOnServiceEntitlementCtrlNew1()
    {
         Test.startTest();
            
            
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            Map<ID, Opportunity> opplst;
            //List<Address__c>list_Address = new List<Address__c>();
            RecordType objRecType = [select id,name from RecordType where name =: 'EMG - Customer Record Type'];
            RecordType objRecType_Opp = [select id,name from RecordType where name =: 'GEN - Opportunity Record Type'];
            
            

            System.runAs(runAsUser[0]) 
            {
                Country__c objCountry = setupCountry();
                List<Account> list_Accounts = TestUtil.createAccounts(1,false);
                list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
                list_Accounts[0].Street1__c = 'test';
                list_Accounts[0].City__c= 'test';
                list_Accounts[0].Industry__c = 'Agriculture';
                list_Accounts[0].Country__c= objCountry.id;
                list_Accounts[0].Phone = '123456789';
                list_Accounts[0].Type_of_Commerce__c = 'Business-to-Business';
                list_Accounts[0].ZipCode__c = '12345';
                list_Accounts[0].Auto_Renew_Contractual_Increase__c = 1;
                list_Accounts[0].Auto_Renew_Contract_Term__c = 1;
                list_Accounts[0].Campaign_Target__c ='Please remove from Campaign';
                list_Accounts[0].Campaign_Target_Removal_Reason__c ='other';
                insert list_Accounts;
                
                Contact testContact = new Contact();
                testContact.AccountId = list_Accounts[0].id;
                testContact.LastName = 'Test Contact';
                insert testContact;
                //List<Opportunity> opportunities = TestUtil.createOpportunities(2, accounts[0].Id, true);
                Opportunity opportunities = new Opportunity();
                opportunities.Name = 'Test Opp';
                opportunities.accountid = list_Accounts [0].Id;
                opportunities.closeDate = Date.today().addMonths(1);
                opportunities.StageName = '1.Recognize Needs';
                opportunities.CurrencyIsoCode = 'USD';
                opportunities.Country__c = objCountry.Id;
                
                insert opportunities;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = opportunities.Id;
                objQuote.Quote_Created_Date__c = System.today();
                objQuote.BigMachines__Status__c = 'Quote In Progress';
                objQuote.Grid_Group_By__c = 'Use Cases';
                objQuote.Service_Level__c = 'Business';
                objQuote.PPU_Rental__c = true;
                objQuote.Pricing_Model__c = 'Enabled';
                objQuote.Quote_Opportunity_Type__c = 'New Pricing';
                objQuote.Quote_Business_Type__c = 'On Premise';
                objQuote.Offering_Type__c = 'PureConnect-Cloud Order';
                objQuote.Order_Numb_of_Maint_Months__c = 12;
                insert objQuote;
                
                List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'PureSuccess_Services'];
                Case cs = new Case(status='Open',subject='test', ContactId = testContact.Id,                      
                               recordtypeid = rectp[0].id);                        
                insert cs;
              
                List<Product2> list_Products = TestUtil.createProducts(5, false);
                System.assert(list_Products.size() == 5);
                integer i=1;
                for(Product2 objProduct :  list_Products){
                    objProduct.APN_Number__c = 'APNABC'+objProduct.Name;
                    objProduct.zqu__SKU__c = 'test2'+i;
                    i++;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              //prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              //prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = opportunities.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'AUD';
              insert ord_1;
              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);
              
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              tkAll.Token_status__c = 'Allocated';
              insert tkAll;
              
              Token_Consumption__c tknc = new Token_Consumption__c();
              tknc.Product__c = list_Products[0].Id;
              tknc.Status__c = 'In Progress';
              tknc.Tokens__c = 10;
              tknc.Token_Allocation__c = tkAll.Id;
              insert tknc;
               List<Pure_Success_Package__c> pSuccessPkg = new List<Pure_Success_Package__c>();
               List<Token_Allocations__c> tknlst = new List<Token_Allocations__c>();
               List<Package_Services__c> pkgSrv = new List<Package_Services__c>();
               List<Product_Group_Item__c> pdgrpItm = new List<Product_Group_Item__c>();
               
               Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;  
               ppkg.Package_type__c = 'Pure Success';
               ppkg.token_Status__c = 'Allocated';
               ppkg.Order__c = ord_1.Id;
               insert ppkg;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;
                
                
        
                string accountId =  list_Accounts[0].Id;
                string packageId = ppkg.id;
                string packageId1 = ppkg.id;
                string productId = list_Products[0].id;
                String prdGroup =   prdgrp.id;
                string packageSrvId = pkg.id;
                PageReference testPage = new pagereference('/apex/VisualforcePage');
                ApexPages.currentPage().getParameters().put( 'accId', accountId );
                
                PartnerServiceEntitlementCtrl MyControllerObj = new PartnerServiceEntitlementCtrl();
                Boolean isBuy = MyControllerObj.isBuy;
                
                String str1 = PartnerServiceEntitlementCtrl.createNRO(packageSrvId, 'Testing', accountId, productId);
            }
            
            
            Test.stopTest();
    }
    static testmethod void testOnServiceEntitlementCtrlNew2()
    {
         Test.startTest();
            
            
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            Map<ID, Opportunity> opplst;
            //List<Address__c>list_Address = new List<Address__c>();
            RecordType objRecType = [select id,name from RecordType where name =: 'EMG - Customer Record Type'];
            RecordType objRecType_Opp = [select id,name from RecordType where name =: 'GEN - Opportunity Record Type'];
            
            

            System.runAs(runAsUser[0]) 
            {
                Country__c objCountry = setupCountry();
                List<Account> list_Accounts = TestUtil.createAccounts(1,false);
                list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
                list_Accounts[0].Street1__c = 'test';
                list_Accounts[0].City__c= 'test';
                list_Accounts[0].Industry__c = 'Agriculture';
                list_Accounts[0].Country__c= objCountry.id;
                list_Accounts[0].Phone = '123456789';
                list_Accounts[0].Type_of_Commerce__c = 'Business-to-Business';
                list_Accounts[0].ZipCode__c = '12345';
                list_Accounts[0].Auto_Renew_Contractual_Increase__c = 1;
                list_Accounts[0].Auto_Renew_Contract_Term__c = 1;
                list_Accounts[0].Campaign_Target__c ='Please remove from Campaign';
                list_Accounts[0].Campaign_Target_Removal_Reason__c ='other';
                insert list_Accounts;
                
                Contact testContact = new Contact();
                testContact.AccountId = list_Accounts[0].id;
                testContact.LastName = 'Test Contact';
                insert testContact;
                
                //List<Opportunity> opportunities = TestUtil.createOpportunities(2, accounts[0].Id, true);
                Opportunity opportunities = new Opportunity();
                opportunities.Name = 'Test Opp';
                opportunities.accountid = list_Accounts [0].Id;
                opportunities.closeDate = Date.today().addMonths(1);
                opportunities.StageName = '1.Recognize Needs';
                opportunities.CurrencyIsoCode = 'USD';
                opportunities.Country__c = objCountry.Id;
                
                insert opportunities;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = opportunities.Id;
                objQuote.Quote_Created_Date__c = System.today();
                objQuote.BigMachines__Status__c = 'Quote In Progress';
                objQuote.Grid_Group_By__c = 'Use Cases';
                objQuote.Service_Level__c = 'Business';
                objQuote.PPU_Rental__c = true;
                objQuote.Pricing_Model__c = 'Enabled';
                objQuote.Quote_Opportunity_Type__c = 'New Pricing';
                objQuote.Quote_Business_Type__c = 'On Premise';
                objQuote.Offering_Type__c = 'PureEngage-Cloud Order';
                objQuote.Order_Numb_of_Maint_Months__c = 12;
                insert objQuote;
                
                List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'PureSuccess_Services'];
                Case cs = new Case(status='Open',subject='test', ContactId = testContact.Id,                      
                               recordtypeid = rectp[0].id);                        
                insert cs;
              
                List<Product2> list_Products = TestUtil.createProducts(5, false);
                System.assert(list_Products.size() == 5);
                integer i=1;
                for(Product2 objProduct :  list_Products){
                    objProduct.APN_Number__c = 'APNABC'+objProduct.Name;
                    objProduct.zqu__SKU__c = 'test3'+i;
                    i++;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              //prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              //prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = opportunities.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'BRL';
              insert ord_1;              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);             
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              tkAll.Token_status__c = 'Allocated';
              insert tkAll;
              
              Token_Consumption__c tknc = new Token_Consumption__c();
              tknc.Product__c = list_Products[0].Id;
              tknc.Status__c = 'In Progress';
              tknc.Tokens__c = 10;
              tknc.Token_Allocation__c = tkAll.Id;
              insert tknc;
               List<Pure_Success_Package__c> pSuccessPkg = new List<Pure_Success_Package__c>();
               List<Token_Allocations__c> tknlst = new List<Token_Allocations__c>();
               List<Package_Services__c> pkgSrv = new List<Package_Services__c>();
               List<Product_Group_Item__c> pdgrpItm = new List<Product_Group_Item__c>();
               
               Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;  
               ppkg.Package_type__c = 'Pure Success';
               ppkg.token_Status__c = 'Allocated';
               ppkg.Order__c = ord_1.Id;
               insert ppkg;
               
               Pure_Success_Package__c ppkg1 = new Pure_Success_Package__c();
               ppkg1.Account__c = list_Accounts[0].id;
               ppkg1.Product__c = list_Products[0].id;  
               ppkg1.Package_type__c = 'A la Carte Partner';
               ppkg1.token_Status__c = 'Allocated';
               ppkg1.Order__c = ord_1.Id;
               insert ppkg1;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;
                
                
        
                string accountId =  list_Accounts[0].Id;
                string packageId = ppkg.id;
                string packageId1 = ppkg.id;
                string productId = list_Products[0].id;
                String prdGroup =   prdgrp.id;
                string packageSrvId = pkg.id;
                PageReference testPage = new pagereference('/apex/VisualforcePage');
                ApexPages.currentPage().getParameters().put( 'accId', accountId );
                
                PartnerServiceEntitlementCtrl MyControllerObj = new PartnerServiceEntitlementCtrl();
                Boolean isBuy = MyControllerObj.isBuy;
                
                string str2 = PartnerServiceEntitlementCtrl.createPackageALaCarte(packageSrvId, 'Test 3', accountId , productId, prdGroup, 1.0, 'USD');
            }
            
            
            Test.stopTest();
    }
    
    static testmethod void testOnServiceEntitlementCtrlNew3()
    {
         Test.startTest();
            
            
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            Map<ID, Opportunity> opplst;
            //List<Address__c>list_Address = new List<Address__c>();
            RecordType objRecType = [select id,name from RecordType where name =: 'EMG - Customer Record Type'];
            RecordType objRecType_Opp = [select id,name from RecordType where name =: 'GEN - Opportunity Record Type'];
            
            

            System.runAs(runAsUser[0]) 
            {
                Country__c objCountry = setupCountry();
                List<Account> list_Accounts = TestUtil.createAccounts(1,false);
                list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
                list_Accounts[0].Street1__c = 'test';
                list_Accounts[0].City__c= 'test';
                list_Accounts[0].Industry__c = 'Agriculture';
                list_Accounts[0].Country__c= objCountry.id;
                list_Accounts[0].Phone = '123456789';
                list_Accounts[0].Type_of_Commerce__c = 'Business-to-Business';
                list_Accounts[0].ZipCode__c = '12345';
                list_Accounts[0].Auto_Renew_Contractual_Increase__c = 1;
                list_Accounts[0].Auto_Renew_Contract_Term__c = 1;
                list_Accounts[0].Campaign_Target__c ='Please remove from Campaign';
                list_Accounts[0].Campaign_Target_Removal_Reason__c ='other';
                insert list_Accounts;
                
                Contact testContact = new Contact();
                testContact.AccountId = list_Accounts[0].id;
                testContact.LastName = 'Test Contact';
                insert testContact;
                
                //List<Opportunity> opportunities = TestUtil.createOpportunities(2, accounts[0].Id, true);
                Opportunity opportunities = new Opportunity();
                opportunities.Name = 'Test Opp';
                opportunities.accountid = list_Accounts [0].Id;
                opportunities.closeDate = Date.today().addMonths(1);
                opportunities.StageName = '1.Recognize Needs';
                opportunities.CurrencyIsoCode = 'USD';
                opportunities.Country__c = objCountry.Id;
                
                insert opportunities;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = opportunities.Id;
                objQuote.Quote_Created_Date__c = System.today();
                objQuote.BigMachines__Status__c = 'Quote In Progress';
                objQuote.Grid_Group_By__c = 'Use Cases';
                objQuote.Service_Level__c = 'Business';
                objQuote.PPU_Rental__c = true;
                objQuote.Pricing_Model__c = 'Enabled';
                objQuote.Quote_Opportunity_Type__c = 'New Pricing';
                objQuote.Quote_Business_Type__c = 'On Premise';
                objQuote.Offering_Type__c = 'PureEngage Subscription';
                objQuote.Order_Numb_of_Maint_Months__c = 12;
                insert objQuote;
                
                List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'PureSuccess_Services'];
                Case cs = new Case(status='Open',subject='test', ContactId = testContact.Id,                      
                               recordtypeid = rectp[0].id);                        
                insert cs;
              
                List<Product2> list_Products = TestUtil.createProducts(5, false);
                System.assert(list_Products.size() == 5);
                integer i=1;
                for(Product2 objProduct :  list_Products){
                    objProduct.APN_Number__c = 'APNABC'+objProduct.Name;
                    objProduct.zqu__SKU__c = 'test3'+i;
                    i++;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              //prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              //prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = opportunities.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'CAD';
              insert ord_1;              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);             
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              tkAll.Token_status__c = 'Allocated';
              insert tkAll;
              
              Token_Consumption__c tknc = new Token_Consumption__c();
              tknc.Product__c = list_Products[0].Id;
              tknc.Status__c = 'In Progress';
              tknc.Tokens__c = 10;
              tknc.Token_Allocation__c = tkAll.Id;
              insert tknc;
               List<Pure_Success_Package__c> pSuccessPkg = new List<Pure_Success_Package__c>();
               List<Token_Allocations__c> tknlst = new List<Token_Allocations__c>();
               List<Package_Services__c> pkgSrv = new List<Package_Services__c>();
               List<Product_Group_Item__c> pdgrpItm = new List<Product_Group_Item__c>();
               
               Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;  
               ppkg.Package_type__c = 'Pure Success';
               ppkg.token_Status__c = 'Allocated';
               ppkg.Order__c = ord_1.Id;
               insert ppkg;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;
                
                
        
                string accountId =  list_Accounts[0].Id;
                string packageId = ppkg.id;
                string packageId1 = ppkg.id;
                string productId = list_Products[0].id;
                String prdGroup =   prdgrp.id;
                string packageSrvId = pkg.id;
                PageReference testPage = new pagereference('/apex/VisualforcePage');
                ApexPages.currentPage().getParameters().put( 'accId', accountId );
                
                PartnerServiceEntitlementCtrl MyControllerObj = new PartnerServiceEntitlementCtrl();
                Boolean isBuy = MyControllerObj.isBuy;
                
                string str2 = PartnerServiceEntitlementCtrl.createPackageALaCarte(packageSrvId, 'Test 3', accountId , productId, prdGroup, 1.0, 'USD');
            }
            
            
            Test.stopTest();
    }
    
     public static Country__c setupCountry(){
        Country__c objCountry = new Country__c(Name='United States A',Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        return objCountry;
    }
}