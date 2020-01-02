@isTest
private class CaseTriggerHandlerTest {

    static testmethod void testCaseUtil1() {
      Map<ID, Case> caselst;
            Map<ID, Case> caselstOld;
      Map<ID, Package_Services__c> mppksrv;      
      Util.Bypass_Trigger_Chk = true;
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'PureSuccess_Services'];
        
        Account acct = TestUtil.createAccounts(1, true)[0];
        acct.Support_Group__c = 'China';
        update acct;
        
        Contact[] testContacts = TestUtil.createContacts(1, acct, true);  
        Test.startTest();
        
        /*Case cs = TestUtil.createCases(1, true)[0];
        cs.Sold_To_Account__c = accnt.Id;
        cs.End_User_Account__c = accnt.Id;
        cs.recordtypeid = rectp[0].id;
        cs.Status = 'Closed';
        update cs;  */      
        Case cs = new Case(status='Open',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
                           recordtypeid = rectp[0].id);                        
        insert cs;
        caselstOld = new Map<Id,Case>([Select ID,Status,recordtypeid From Case where ID =: cs.Id]);
        List<User> owner = TestUtil.createUsers(1, true);
        owner[0].Support_Group__c = 'Applications';
        update owner[0];
        
        cs.Status = 'Closed';
        update cs; 
         
        
        
        //CaseUtil.isCaseAccessLevelReadOnly(cs);
        caselst = new Map<Id,Case>([Select ID,Status,recordtypeid From Case where ID =: cs.Id]);
        
        Country__c objCountry = setupCountry();
        
        List<Account> accounts = TestUtil.createAccounts(1, true);
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.Country__c = objCountry.Id;
        
        insert opportunities;
        
        zqu__Quote__c objQuote = CloudBillingTestUtil.setupZuoraQuote(
            'PureCloud Test ZQuote 1', opportunities.AccountId ,opportunities.id, 24);
        objQuote.zqu__StartDate__c = System.today()- 730; 
        objQuote.zqu__Currency__c = 'USD';
        insert objQuote;
        
        
        Order__c testOrder = new Order__c(Name = 'Test Order');
        //objOrder.Contract_Lookup__c = objContract.Id;
        testOrder.Month__c = '6';
        testOrder.Year__c = '2017';
        testOrder.status__c = 'In Progress';
        testOrder.End_User_Name__c = testOrder.Bill_To_Name__c = testOrder.Sold_To_Name__c = testOrder.Ship_To_Name__c = accounts[0].Id ;
        testOrder.Opportunity__c = opportunities.id;
       
        insert testOrder;
        
        List<Product2> list_Products = TestUtil.createProducts(5, false);
        for(integer i = 0 ; i < list_Products.size() ; i++){
            list_Products[i].APN_Number__c = 'APNABC'+i;
            list_Products[i].Unit_of_Measure__c = 'Per Month';
        }
        insert list_Products;
        
        Pure_Success_Package__c ppkg = new Pure_Success_Package__c();
        ppkg.Account__c = acct.id;
        ppkg.Product__c = list_Products[0].id;
        
        insert ppkg;
        
        List<Package_Services__c> lstPack = new List<Package_services__c>();
        Package_services__c pkg = new Package_services__c ();
        pkg.Case__c = cs.id;
        pkg.Status__c = 'Consumed';
        
        pkg.PureSuccess_Package__c = ppkg.id;
        lstPack.add(pkg);
        
        insert lstPack;
        mppksrv = new Map<Id,Package_Services__c>([Select Id, Case__c, Status__c from Package_Services__c where Case__c =: cs.Id]);
        //CaseTriggerHandler obj = new CaseTriggerHandler();
        CaseTriggerHandler.afterCaseUpdateupdatePkgSrv(caselst,caselstOld);
        
        Test.stopTest();
                  
    }
    
    public static Country__c setupCountry(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        return objCountry;
    }
      
 }