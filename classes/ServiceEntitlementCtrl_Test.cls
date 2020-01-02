@isTest(SeeAllData = true)
private class ServiceEntitlementCtrl_Test
{

              static Contact testContact;
    static testmethod void testOnServiceEntitlementCtrlNew()
    {
        try
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
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                objOpportunity.Sold_To_Country__c = objCountry.Id;
                insert objOpportunity;
                
          /*      CurrencyType crtype = new CurrencyType();
                crtype.ConversionRate = 1.2749;
                crtype.IsActive = true;
                crtype.IsCorporate = false;
                crtype.IsoCode = 'AUD';
                insert crtype; */
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = objOpportunity.Id;
                objQuote.Quote_Created_Date__c = System.today();
                objQuote.BigMachines__Status__c = 'Quote In Progress';
                objQuote.Grid_Group_By__c = 'Use Cases';
                objQuote.Service_Level__c = 'Business';
                objQuote.PPU_Rental__c = true;
                objQuote.Pricing_Model__c = 'Enabled';
                //objQuote.Opp_Sold_To_Country__c = 'Test';
                objQuote.Quote_Opportunity_Type__c = 'New Pricing';
                objQuote.Quote_Business_Type__c = 'On Premise';
                //objQuote.Offering_Type__c = 'PureEngage Subscription';
                objQuote.Offering_Type__c = 'PureCloud';
                objQuote.Order_Numb_of_Maint_Months__c = 12;
                insert objQuote;
        
                List<CurrencyType> currencyValue = new List<CurrencyType>([SELECT ConversionRate,Id,IsActive,IsCorporate,IsoCode FROM CurrencyType  Limit 1]);
                
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
              
              prdgrp.Name = 'PureSuccess A la Carte';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Id RecordTypeIdOrder = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Quote__c = objQuote.id;
              ord_1.RecordTypeId = RecordTypeIdOrder;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.License_FYM_detail__c = 'Cloud Order';
              ord_1.CurrencyIsoCode = 'USD';
              insert ord_1;
              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);
              
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              //tkAll.Currency__c = 'USD';
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
               List<Contact> lstcont = new List<Contact>();
               List<GU_Entitlement__c> lstGUEnt= new List<GU_Entitlement__c>();
               
               Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;  
               ppkg.token_Status__c = 'Allocated';
               ppkg.Order__c = ord_1.Id;
               ppkg.Package_Type__c = 'Pure Success' ;
               insert ppkg;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;
                
                Pure_Success_Package__c ppkg1 = new Pure_Success_Package__c();
               ppkg1.Account__c = list_Accounts[0].id;
               ppkg1.Product__c = list_Products[0].id;  
               ppkg1.token_Status__c = 'Allocated';
               ppkg1.Order__c = ord_1.Id;
               ppkg1.Package_Type__c = 'Pure Success' ;  
               insert ppkg1;
               
                Package_services__c pkg1 = new Package_services__c ();
                pkg1.Case__c = cs.id;
                pkg1.Status__c = 'Allocated';        
                pkg1.PureSuccess_Package__c = ppkg1.id;
                insert pkg1;
                
               Pure_Success_Package__c ppkg2 = new Pure_Success_Package__c();
               ppkg2.Account__c = list_Accounts[0].id;
               ppkg2.Product__c = list_Products[0].id;
               ppkg2.Order__c = ord_1.Id;
               ppkg2.Package_Type__c = 'A la Carte';
               insert ppkg2;
               
                Package_services__c pkg2 = new Package_services__c ();
                pkg2.Case__c = cs.id;
                pkg2.Status__c = 'Consumed';        
                pkg2.PureSuccess_Package__c = ppkg2.id;
                insert pkg2;
                
                Pure_Success_Package__c ppkg3 = new Pure_Success_Package__c();
               ppkg3.Account__c = list_Accounts[0].id;
               ppkg3.Product__c = list_Products[0].id;
               ppkg3.Order__c = ord_1.Id;
               ppkg3.Package_Type__c = 'A la Carte';
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
                
                ServiceEntitlementCtrl MyControllerObj = new ServiceEntitlementCtrl();
                MyControllerObj.offeringTypeName = 'PureCloud-Cloud Order';
                Boolean isBuy = MyControllerObj.isBuy;
                
                 
                pSuccessPkg = ServiceEntitlementCtrl.pureSuccessPacklist(accountId,'true','true' ); 
                tknlst = ServiceEntitlementCtrl.getTokenAllocation(accountId,'true','true');              
                pkgSrv  = ServiceEntitlementCtrl.getPackageServicesConsumed(packageId,'true','true');
                pkgSrv = ServiceEntitlementCtrl.getPackageServicesAvailable(packageId1,'true','true');
                pkgSrv = ServiceEntitlementCtrl.getConsumedAlaCarte(accountId,'true','true','PureCloud');
                pkgSrv = ServiceEntitlementCtrl.getExpiredAlaCarte(accountId,'true','true','PureCloud');
                pkgSrv = ServiceEntitlementCtrl.getAlocatedAlaCarte(accountId,'true','true','PureCloud');
                ServiceEntitlementCtrl.CreateTokenConsumption(prdgrpItm.id , null , list_Accounts[0].Id,list_Products[0].id ,prdgrp.id ,null ,null ,'PureCloud');
                ServiceEntitlementCtrl.fetchCounter(list_Accounts[0].Id);
                
                tknlst = ServiceEntitlementCtrl.getTokenAllocationGU(accountId,'true','true');
                lstcont = ServiceEntitlementCtrl.getEndContactList(accountId);
                tknlst = ServiceEntitlementCtrl.getTokenAllocationForBuy(accountId,'true','true');
                tknc1  = ServiceEntitlementCtrl.getTokenConsumptionFortknAllc(tknc.id);
                
                string crrid = currencyValue[0].id;
               //   = ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true', crrid );
                ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true','AUD','PureCloud');
                ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true','BRL','PureCloud');
                ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true','CAD','PureCloud');
                ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true','EUR','PureCloud');
                ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true','GBP','PureCloud');
                ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true','JPY','PureCloud');
                ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true','NZD','PureCloud');
                ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true','USD','PureCloud');
                ServiceEntitlementCtrl.getProductGroupItems(accountId,'true','true','ZAR','PureCloud');
                
                lstGUEnt = ServiceEntitlementCtrl.getTokenAllocationGUcancelled(accountId,'true','true');
                lstGUEnt = ServiceEntitlementCtrl.getTokenAllocationGUInProgress(accountId,'true','true');
                tknlst = PartnerServiceEntitlementCtrl.getTokenAllocationGU(accountId,'','');
                
                lstGUEnt = ServiceEntitlementCtrl.getTokenAllocationGUCompleted(accountId,'true','true');

            }
            
            
            Test.stopTest();
        }
        catch(CalloutException e){}
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
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                insert objOpportunity;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = objOpportunity.Id;
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
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.Quote__c = objQuote.id;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'USD';
              insert ord_1;
              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);
              
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              //tkAll.Currency__c = 'USD';
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
               ppkg.Order__c = ord_1.Id;
               ppkg.token_Status__c = 'Allocated';
               ppkg.Package_Type__c = 'Pure Success' ; 
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
                
                ServiceEntitlementCtrl MyControllerObj = new ServiceEntitlementCtrl();
                MyControllerObj.offeringTypeName = 'PureCloud-Cloud Order';
                Boolean isBuy = MyControllerObj.isBuy;
                
                String str1 = ServiceEntitlementCtrl.createNRO(packageSrvId, 'Testing', accountId, productId,prdGroup,1.0);
                string str2 = ServiceEntitlementCtrl.createCase(packageSrvId, 'Test 3', accountId, productId);
                
                ServiceEntitlementCtrl.fetchCounter(list_Accounts[0].id);
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
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                insert objOpportunity;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = objOpportunity.Id;
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
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              
               
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'USD';
              insert ord_1;      
              
              Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;
               ppkg.token_Status__c = 'Allocated';
               ppkg.Package_Type__c = 'Pure Success' ;
               ppkg.Order__c = ord_1.Id;
               insert ppkg;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;        
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              tkAll.Token_status__c = 'Allocated';
              insert tkAll;
              
              String tokenId = tkAll.Id + '-500';
              
              Token_Consumption__c tknc = new Token_Consumption__c();
              tknc.Product__c = list_Products[0].Id;
              tknc.Status__c = 'In Progress';
              tknc.Tokens__c = 10;
              tknc.Token_Allocation__c = tkAll.Id;
              insert tknc;
              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);             
              List<Pure_Success_Package__c> pSuccessPkg = new List<Pure_Success_Package__c>();
               List<Token_Allocations__c> tknlst = new List<Token_Allocations__c>();
               List<Package_Services__c> pkgSrv = new List<Package_Services__c>();
               List<Product_Group_Item__c> pdgrpItm = new List<Product_Group_Item__c>();
              
                
                
        
                string accountId =  list_Accounts[0].Id;
                string packageId = ppkg.id;
                string packageId1 = ppkg.id;
                string productId = list_Products[0].id;
                String prdGroup =   prdgrp.id;
                string packageSrvId = pkg.id;
                PageReference testPage = new pagereference('/apex/VisualforcePage');
                ApexPages.currentPage().getParameters().put( 'accId', accountId );
                
                ServiceEntitlementCtrl MyControllerObj = new ServiceEntitlementCtrl();
                MyControllerObj.offeringTypeName = 'PureCloud-Cloud Order';
                Boolean isBuy = MyControllerObj.isBuy;
                
                string str2 = ServiceEntitlementCtrl.CreateTokenConsumption(packageSrvId, 'Test 3', accountId , productId, prdGroup, tokenId,'','PureCloud');
            }
            
            
            Test.stopTest();
    }
    
    static testmethod void testOnServiceEntitlementCtrlNew2a()
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
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                insert objOpportunity;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = objOpportunity.Id;
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
                    objProduct.zqu__SKU__c = 'test4'+i;
                    i++;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                
              Product_Group__c prdgrp = new Product_group__c();
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
             
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'USD';
              insert ord_1;              
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              tkAll.Token_status__c = 'Allocated';
              insert tkAll;
              
              Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;
               ppkg.token_Status__c = 'Allocated';
               ppkg.Package_Type__c = 'Pure Success' ;
               ppkg.Order__c = ord_1.Id;
               insert ppkg;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;
                
              String tokenId = tkAll.Id + '-500';
              
              Token_Consumption__c tknc = new Token_Consumption__c();
              tknc.Product__c = list_Products[0].Id;
              tknc.Status__c = 'In Progress';
              tknc.Tokens__c = 10;
              tknc.Token_Allocation__c = tkAll.Id;
              insert tknc;
              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);             
              List<Pure_Success_Package__c> pSuccessPkg = new List<Pure_Success_Package__c>();
               List<Token_Allocations__c> tknlst = new List<Token_Allocations__c>();
               List<Package_Services__c> pkgSrv = new List<Package_Services__c>();
               List<Product_Group_Item__c> pdgrpItm = new List<Product_Group_Item__c>();
              
                
                
        
                string accountId =  list_Accounts[0].Id;
                
                string productId = list_Products[0].id;
                String prdGroup =   prdgrp.id;
                
                PageReference testPage = new pagereference('/apex/VisualforcePage');
                ApexPages.currentPage().getParameters().put( 'accId', accountId );
                
                ServiceEntitlementCtrl MyControllerObj = new ServiceEntitlementCtrl();
                MyControllerObj.offeringTypeName = 'PureCloud-Cloud Order';
                Boolean isBuy = MyControllerObj.isBuy;
                
                string str2 = ServiceEntitlementCtrl.CreateTokenConsumption(prdgrpItm.id, 'Test 3', accountId , productId, prdGroup, tokenId,'','PureCloud');
            }
            
            
            Test.stopTest();
    }
    
    static testmethod void testOnServiceEntitlementCtrlNew29()
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
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                insert objOpportunity;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = objOpportunity.Id;
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
                    objProduct.zqu__SKU__c = 'test5'+i;
                    i++;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'USD';
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
               ppkg.token_Status__c = 'Allocated';
               ppkg.Order__c = ord_1.Id;
               ppkg.Package_Type__c = 'Pure Success' ;
               insert ppkg;
               
               Pure_Success_Package__c ppkg1 = new Pure_Success_Package__c();
               ppkg1.Account__c = list_Accounts[0].id;
               ppkg1.Product__c = list_Products[0].id;    
               ppkg1.token_Status__c = 'Allocated';
               ppkg1.Order__c = ord_1.Id;
               ppkg1.Package_Type__c = 'A la carte' ;
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
                
                ServiceEntitlementCtrl MyControllerObj = new ServiceEntitlementCtrl();
                Boolean isBuy = MyControllerObj.isBuy;
                
                string str2 = ServiceEntitlementCtrl.createPackageALaCarte(packageSrvId, 'Test 3', accountId , productId, prdGroup, 1.0);
            }
            
            
            Test.stopTest();
    }
    static testmethod void testOnServiceEntitlementCtrlNew29b()
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
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                insert objOpportunity;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = objOpportunity.Id;
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
                    objProduct.zqu__SKU__c = 'test6'+i;
                    i++;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'USD';
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
               ppkg.token_Status__c = 'Allocated';
               ppkg.Order__c = ord_1.Id;
               ppkg.Package_Type__c = 'Pure Success' ;
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
                
                ServiceEntitlementCtrl MyControllerObj = new ServiceEntitlementCtrl();
                Boolean isBuy = MyControllerObj.isBuy;
                
                string str2 = ServiceEntitlementCtrl.createPackageALaCarte(packageSrvId, 'Test 3', accountId , productId, prdGroup, 1.0);
                objQuote.Offering_Type__c = 'PureEngage-Cloud Order';
                update objQuote;
                ServiceEntitlementCtrl MyControllerObj1 = new ServiceEntitlementCtrl();
                
            }
            
            
            Test.stopTest();
    }
    static testmethod void testOnServiceEntitlementCtrlNew29a()
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
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                insert objOpportunity;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = objOpportunity.Id;
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
                    objProduct.zqu__SKU__c = 'test6'+i;
                    i++;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'USD';
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
               ppkg.token_Status__c = 'Allocated';
               ppkg.Order__c = ord_1.Id;
               ppkg.Package_Type__c = 'Pure Success' ;
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
                
                ServiceEntitlementCtrl MyControllerObj = new ServiceEntitlementCtrl();
                Boolean isBuy = MyControllerObj.isBuy;
                
                string str2 = ServiceEntitlementCtrl.createPackageALaCarte(packageSrvId, 'Test 3', accountId , productId, prdGroup, 1.0);
            }
            
            
            Test.stopTest();
    }
    
    
     static testmethod void testOnServiceEntitlementCtrlNew31()
    {
        try
        {
            Test.startTest();
            
            Country__c objCountry = setupCountry();
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
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
                //list_Accounts[0].Campaign_Target__c ='Please remove from Campaign';
                //list_Accounts[0].Campaign_Target_Removal_Reason__c ='other';
                insert list_Accounts;
            
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            Map<ID, Opportunity> opplst;
            //List<Address__c>list_Address = new List<Address__c>();
            RecordType objRecType = [select id,name from RecordType where name =: 'EMG - Customer Record Type'];
            RecordType objRecType_Opp = [select id,name from RecordType where name =: 'GEN - Opportunity Record Type'];
            
            

            System.runAs(runAsUser[0]) 
            {
                
                
                Contact testContact = new Contact();
                testContact.AccountId = list_Accounts[0].Id;
                testContact.All_Service_Elements_Access__c = true;
                testContact.Self_Service_Elements_Access__c = true;
                testContact.LastName = 'Pankaj001';
                testContact.PureSuccess_Main_Contact__c = true;
                insert testContact;
                
                Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
                objOpportunity.Lines_of_Businesses__c = 'PureCloud';
                insert objOpportunity;
                
                BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
                objQuote.BigMachines__Opportunity__c = objOpportunity.Id;
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
                    objProduct.zqu__SKU__c = 'test7'+i;
                    i++;
                }
                insert list_Products;
                System.assert(list_Products[0].Id != NULL);
              
                Product_Group__c prdgrp = new Product_group__c();
              
              prdgrp.Name = 'Test';
              prdgrp.Group_Type__c = 'A la Carte';
              prdgrp.Order__c = 12;
              prdgrp.Quantity__c = 10;
              prdgrp.Token_Value__c = 500;
              prdgrp.Type__c = 'A la Carte';
              
              Insert prdgrp;
              
              Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
              //prdgrpItm.Name = 'Test product group Item';
              prdgrpItm.Product__c = list_Products[0].Id;
              prdgrpItm.Product_Group__c = prdgrp.id;
              prdgrpItm.Product_Type__c = 'Lab';
              prdgrpItm.Token_Value__c = 20;
              
              insert prdgrpItm;
              
              Order__c ord_1 = new Order__c();
              ord_1.Maintenance_Start__c = Date.today();
              ord_1.Maintenance_End__c = Date.today().addYears(1);
              ord_1.Opportunity__c = objOpportunity.id;
              ord_1.Numb_of_Maint_Months__c = 12;
              ord_1.End_User_Name__c = list_Accounts[0].id;
              ord_1.Bill_To_Name__c = list_Accounts[0].id;
              ord_1.Sold_To_Name__c = list_Accounts[0].id;
              ord_1.Quote__c = objQuote.id;
              ord_1.Ship_To_Name__c  = list_Accounts[0].id;
              ord_1.CurrencyIsoCode = 'USD';
              insert ord_1;
              
              List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, ord_1.Id, true);
              
              
              Token_Allocations__c tkAll = new Token_Allocations__c();
              tkAll.Account__c = list_Accounts[0].id;
              tkAll.Order__c = ord_1.Id;
              tkAll.Product__c = list_Products[0].id;
              tkAll.Product_Group__c = prdgrp.id;
              tkAll.Tokens__c = 500;
              //tkAll.Currency__c = 'USD';
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
               List<Contact> lstcont = new List<Contact>();
               
               Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
               ppkg.Account__c = list_Accounts[0].id;
               ppkg.Product__c = list_Products[0].id;  
               ppkg.Order__c = ord_1.Id;  
               ppkg.token_Status__c = 'Allocated';
               ppkg.Package_Type__c = 'Pure Success' ;
               insert ppkg;
               
                Package_services__c pkg = new Package_services__c ();
                pkg.Case__c = cs.id;
                pkg.Status__c = 'Consumed';        
                pkg.PureSuccess_Package__c = ppkg.id;
                insert pkg;
                
                Pure_Success_Package__c ppkg1 = new Pure_Success_Package__c();
               ppkg1.Account__c = list_Accounts[0].id;
               ppkg1.Product__c = list_Products[0].id;
               ppkg.Order__c = ord_1.Id;
               ppkg.token_Status__c = 'Allocated';
               ppkg.Package_Type__c = 'Pure Success' ;
               insert ppkg1;
               
                Package_services__c pkg1 = new Package_services__c ();
                pkg1.Case__c = cs.id;
                pkg1.Status__c = 'Allocated';        
                pkg1.PureSuccess_Package__c = ppkg1.id;
                insert pkg1;
                
               Pure_Success_Package__c ppkg2 = new Pure_Success_Package__c();
               ppkg2.Account__c = list_Accounts[0].id;
               ppkg2.Product__c = list_Products[0].id;
               ppkg2.Order__c = ord_1.Id;
               ppkg2.Package_Type__c = 'A la Carte';
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
                
                ServiceEntitlementCtrl MyControllerObj = new ServiceEntitlementCtrl();
                MyControllerObj.offeringTypeName = 'PureCloud-Cloud Order';
                Boolean isBuy = MyControllerObj.isBuy;
                
                
                tknlst = ServiceEntitlementCtrl.getTokenAllocationGU(accountId,'true','true');
                lstcont = ServiceEntitlementCtrl.getEndContactList(accountId);
                tknlst = ServiceEntitlementCtrl.getTokenAllocationForBuy(accountId,'true','true');
                tknc1  = ServiceEntitlementCtrl.getTokenConsumptionFortknAllc(tknc.id);
                
            }
            
            
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
    public static Country__c setupCountry(){
        Country__c objCountry = new Country__c(Name= 'United States A',Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        return objCountry;
    }
}