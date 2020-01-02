/*
Class : TestUtil
Usage : Utility Class For Test Classes
Author : Rashmi K - Cleartask 3/27/2013
*/
@isTest(seeAllData=true)
public class TestUtil {

    public static List<Account> createAccounts( Integer numToInsert, Boolean doInsert ) {
        List<Account> accounts = new List<Account>();
       
        for( Integer i=0; i < numToInsert; i++ ) {
            Account a = new Account( Name='Test Account', Status__c = 'Active' );            
            accounts.add( a );
        }
        
        if( doInsert )
            insert accounts;
        return accounts;
    }
    
    public static List<Contact> createContacts(Integer numToInsert, Account acc, Boolean doInsert){
        List<Contact> conts = new List<Contact>();
        Account holdAcct = new Account(Name='Holding Account', Status__c = 'Active');
        
        
        insert holdAcct;
        
        for( Integer i=0; i < numToInsert; i++ ) {
            Contact cont = new Contact(LastName = 'TestContact'+i, Email = i+'test@genesys.com', accountId = acc.id, FirstName = 'Test'+i);
            conts.add(cont);
        }
        if(doInsert)
            insert conts;
        return conts;
    }
    
    public static List<Opportunity> createOpportunities( Integer numToInsert, Id accId, Boolean doInsert ) {
        
        //Country__c cntry = new Country__c(Name='TestCOuntry',Country__c='TestCountry'+numToInsert);
        //insert cntry;
        //Country__c cntry  = [Select Id from Country__c where Name = 'United States'];
        List<Opportunity> opps = new List<Opportunity>();
        for( Integer i=0; i < numToInsert; i++ ) {
            Opportunity opp = new Opportunity( Name='Test Opp', accountId=accId );
            opp.closeDate = Date.today().addMonths(1);
            opp.StageName = '1.Recognize Needs';     
            opp.CurrencyIsoCode = 'USD';
            //opp.Country__c=cntry.Id;
            opps.add( opp );
        }
        
        if( doInsert )
            insert opps;
        return opps;
    }
    
    public static List<Opportunity> createOpportunities( Integer numToInsert, Boolean doInsert ) {
        Account acc = TestUtil.createAccounts(1, true)[0];
        List<Opportunity> opps = new List<Opportunity>();
        for( Integer i=0; i < numToInsert; i++ ) {
            Opportunity opp = new Opportunity( Name='Test Opp', accountId = acc.Id );
            opp.closeDate = Date.today().addMonths(1);
            opp.StageName = '1.Recognize Needs';     
            opp.CurrencyIsoCode = 'USD';       
            opps.add( opp );
        }
        
        if( doInsert )
            insert opps;
        return opps;
    }
    
    public static List<BigMachines__Quote__c> createQuotes( Integer numToInsert, Id oppId, Boolean doInsert ) {
        List<BigMachines__Quote__c> quotes = new List<BigMachines__Quote__c>();
        for( Integer i=0; i < numToInsert; i++ ) {
            BigMachines__Quote__c quote = new BigMachines__Quote__c( Name='Test Opp', BigMachines__Opportunity__c=oppId );            
            quotes.add( quote );
        }
        
        if( doInsert )
            insert quotes;
        return quotes;
    }
    public static List<BigMachines__Quote__c> createQuotes( Integer numToInsert, Boolean doInsert ) {
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.id, true)[0];
        List<BigMachines__Quote__c> quotes = new List<BigMachines__Quote__c>();
        for( Integer i=0; i < numToInsert; i++ ) {
            BigMachines__Quote__c quote = new BigMachines__Quote__c( Name='Test Opp', BigMachines__Opportunity__c = testOpp.id);            
            quotes.add( quote );
        }        
        if( doInsert )
            insert quotes;
        return quotes;
    }
    public static List<Quote_Service_Contracts__c> createQuoteServiceContracts(String quoteId, Integer numToInsert, Boolean doInsert){
        List<Quote_Service_Contracts__c> qscs = new List<Quote_Service_Contracts__c>();
        for( Integer i=0; i < numToInsert; i++ ) {
            Quote_Service_Contracts__c qsc = new Quote_Service_Contracts__c(Quote__c = quoteId);
            qscs.add(qsc);
        }
        if(doInsert)
            insert qscs;
        return qscs;
    }
    public static List<ContractLineItem> createContractLineItems(String serviceContractId, Integer numToInsert, Boolean doInsert){
        List<ContractLineItem> cLIs = new List<ContractLineItem>();
        for( Integer i=0; i < numToInsert; i++ ) {
            ContractLineItem cLI = new ContractLineItem(ServiceContractId = serviceContractId);
            cLI.Quantity = 10;
            cLI.UnitPrice = 100;
            //cLI.PricebookEntryId = ;
            cLIs.add(cLI);
        }
        if(doInsert)
            insert cLIs;
        return cLIs;
    }
    public static List<ServiceContract> createServiceContracts(Integer numToInsert, Boolean doInsert){
        List<ServiceContract> scs = new List<ServiceContract>();
        List<Pricebook2> standardPB = [select id from Pricebook2 where isstandard = true];
        for( Integer i=0; i < numToInsert; i++ ) {
            ServiceContract sc = new ServiceContract();
            sc.Name = 'Test Service Contract';
            if(!standardPB.isEmpty())
              sc.pricebook2id = standardPB[0].id;
            scs.add(sc);
        }
        if(doInsert)
            insert scs;
        return scs;
    }
    
    public static List<ServiceContract> createServiceContracts2(Integer numToInsert, Boolean doInsert,Account objAcc){
        List<ServiceContract> scs = new List<ServiceContract>();
        List<Pricebook2> standardPB = [select id from Pricebook2 where isstandard = true];
        for( Integer i=0; i < numToInsert; i++ ) {
            ServiceContract sc = new ServiceContract();
            sc.Name = 'Test Service Contract';
            sc.AccountId = objAcc.id;
            sc.EndDate = Date.Today().addDays(200);
            sc.StartDate = Date.Today();
            sc.End_User_Name__c = objAcc.id;
            if(!standardPB.isEmpty())
              sc.pricebook2id = standardPB[0].id;
            scs.add(sc);
        }
        if(doInsert)
            insert scs;
          system.debug('++++scs+++   '+scs);  
        return scs;
    }
    
    public static List<OpportunityLineItem> createOlis( List<PricebookEntry> pbes, Id oppId, Boolean doInsert ){
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for( PricebookEntry pbe : pbes ){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = oppId;
            oli.PricebookEntryId = pbe.Id;
            olis.add( oli );
        }
        
        if( doInsert )
            insert olis;
        return olis;    
    }
    
    public static List<PricebookEntry> createPriceBookEntries( List<Product2> products, Boolean doInsert){
        return TestUtil.createPriceBookEntries(products, doInsert, null);
    }
    
    public static List<PricebookEntry> createPriceBookEntries( List<Product2> products, Boolean doInsert, String currISOCode){
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        System.debug('+++++products' + products[0].id);
        Pricebook2 standardPB = [select id from Pricebook2 where isstandard=true];
        System.debug('+++++standardPB ' + standardPB.id);
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Test Pricebook';
        pb.IsActive = true;
        insert pb;
       
        Pricebook2 pb1 = new Pricebook2();
        pb1.Name = 'Test Pricebook';
        pb1.IsActive = true;
        insert pb1;
        
        for(Product2 prod : products){
          /*  PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = pb.Id;
            pbe.IsActive = true;            
            pbe.Product2Id = prod.Id;
            pbe.UnitPrice = 10.1;
            pbe.UseStandardPrice = false;
            if(currISOCode != null)
                pbe.CurrencyIsoCode = currISOCode;
            pbes.add( pbe );*/
            
            PricebookEntry pbe1 = new PricebookEntry();
            pbe1.Pricebook2Id = standardPB.Id;
            //pbe1.Pricebook2Id = pb1.Id;
            pbe1.IsActive = true;
            pbe1.Product2Id = prod.Id;
            pbe1.UnitPrice = 10.1;
            pbe1.UseStandardPrice = false;
            if(currISOCode != null)
                pbe1.CurrencyIsoCode = currISOCode;
            pbes.add( pbe1 );   
        }
        
        if( doInsert ) {
            insert pbes;
        }
        return pbes;
    }    
    
    public static List<Product2> createProducts( Integer numToInsert, Boolean doInsert){
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        List<Product2> products = new List<Product2>();
        for(Integer i=0; i<numToInsert-1; i++){
            Product2 prod = new Product2();
            prod.Name = 'Test Prod '+ i;
            prod.recordTypeId = rtypes[0].Id;
            prod.Type__c = 'Product';
            products.add( prod );
        }
        
        products.add(new Product2(Name='Test Prod '+ numToInsert, RecordTypeId = rtypes[0].Id, Type__c=ServiceContractUtil.MAINTENANCE));
        
        if( doInsert )
            insert products;                                             
        return products;    
    }
    
    public static List<Product2> createProducts( Integer numToInsert, Boolean doInsert, Boolean doCreatePBE){
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        List<Product2> products = new List<Product2>();
        for(Integer i=0; i<numToInsert-1; i++){
            Product2 prod = new Product2();
            prod.Name = 'Test Prod '+ i;
            prod.recordTypeId = rtypes[0].Id;
            prod.Type__c = 'Product';
            products.add( prod );
        }
        
        products.add(new Product2(Name='Test Prod '+ numToInsert, RecordTypeId = rtypes[0].Id, Type__c=ServiceContractUtil.MAINTENANCE));
            
        if( doInsert )
            insert products;
        if(doCreatePBE)
            TestUtil.createPriceBookEntries(products, true);                                             
        return products;    
    }    
    
    public static List<Product2> createNoMaintenanceProducts( Integer numToInsert, Boolean doInsert){
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        List<Product2> products = new List<Product2>();
        for(Integer i=0; i<numToInsert-1; i++){
            Product2 prod = new Product2();
            prod.Name = 'Test Prod '+ i;
            prod.recordTypeId = rtypes[0].Id;
            prod.Type__c = 'Product';
            products.add( prod );
        }
        
        if( doInsert )
            insert products;                                             
        return products;    
    }
    
    public static List<BigMachines__Quote_Product__c> createQuoteProducts( List<Product2> products, Boolean doInsert ){
        List<BigMachines__Quote_Product__c>  quoteProducts = new List<BigMachines__Quote_Product__c> ();
        for( Product2 prod : products ){
            BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();
            qp.BigMachines__Quantity__c = 1;
            qp.BigMachines__Sales_Price__c = 100;
            qp.List_Price__c = 100;
            qp.Discount__c = 10;
            qp.Installation_Fees__c = 0;
            qp.Product__c = prod.Id;
            quoteProducts.add( qp );    
        }
        
        if( doInsert )
            insert quoteProducts;
        return quoteProducts;
    }
    public static List<BigMachines__Quote_Product__c> createQuoteProducts( Integer numToInsert, Boolean doInsert, String quoteId ){
        List<BigMachines__Quote_Product__c>  quoteProducts = new List<BigMachines__Quote_Product__c> ();
        List<Product2> products = TestUtil.createProducts(numToInsert, false);
        for( Product2 prod : products ){
            BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();
            qp.Product__c = prod.Id;            
            qp.BigMachines__Quote__c = quoteId;
            qp.BigMachines__Quantity__c = 10;
            qp.BigMachines__Sales_Price__c = 500;
            quoteProducts.add( qp );    
        }
        
        if( doInsert )
            insert quoteProducts;
        return quoteProducts;
    }
    
    public static List<Order__c> createOrders( Integer numToInsert, Id quoteId, Id oppId, Boolean doInsert){
        List<Order__c> orders = new List<Order__c>();
        
        for(Integer i=0; i<numToInsert; i++ ){
            Order__c o = new Order__c();
            o.Quote__c = quoteId;
            o.Maintenance_Start__c = Date.today();
            o.Maintenance_End__c = Date.today().addYears(1);
            o.Opportunity__c = oppId;
            o.Numb_of_Maint_Months__c = 12;
            orders.add( o );
        }
        
        if( doInsert )
            insert orders;
        return orders;  
    }
    
    public static List<Order__c> createOrders( Integer numToInsert, Boolean doInsert){
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];        
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        List<Order__c> orders = new List<Order__c>();
            
        for(Integer i=0; i<numToInsert; i++ ){
            Order__c o = new Order__c();
            o.Quote__c = testQuote.id;
            o.Maintenance_Start__c = Date.today();
            o.Maintenance_End__c = Date.today().addYears(1);
            o.Opportunity__c = testOpp.id;
            o.Numb_of_Maint_Months__c = 12;
            orders.add( o );
        }
        
        if( doInsert )
            insert orders;
        return orders;  
    }
    
    public static List<Order_Line_Item__c> createOrderLines( List<Product2> prods, Id orderId, Boolean doInsert ){
        List<Order_Line_Item__c> orderLines = new List<Order_Line_Item__c>();
        system.debug('in hrer');
        for( Product2 prod : prods ){
            Order_Line_Item__c o = new Order_Line_Item__c();
            o.Order__c = orderId;
            o.Product__c = prod.Id;
            o.Contract_Line_Update_Status__c = '';
            o.BigMachines_Quantity__c = 1;
            o.Sales_Price__c = 10;
            orderLines.add( o );
            system.debug('in hrer');
        } 
        
        if( doInsert )
            insert orderLines;
        return orderLines;
    }
    
    public static void createGlobalSettings(){
        Global_Setting__c gs = new Global_Setting__c();
        gs.Name = 'Maintenence Order RT';
        gs.Information__c = 'Maintenence';
        gs.Type__c = 'Record Type';
        gs.ID__c = '012U0000000LzgY';
        insert gs;
        
        Global_Setting__c gs1 = new Global_Setting__c();
        gs1.Name = 'License Order RT';
        gs1.Information__c = 'License';
        gs1.Type__c = 'Record Type';
        gs1.ID__c = '012U0000000LzgX';
        insert gs1;
    }
    public static List<Case> createCases(Integer numToInsert, Boolean doInsert){
        List<Account> accs = TestUtil.createAccounts(3, true);
        List<Contact> conts = TestUtil.createContacts(1, accs[0], true);
        List<Support_Product__c> prod = TestUtil.createSupportProducts(1, true);
        List<Case> cases = new List<Case>();
        for(Integer i = 0; i< numToInsert; i++){
            Case testCase = new Case();
            testCase.AccountId = accs[0].id;
            testCase.ContactId = conts[0].id;
            //testCase.Support_Product__c = prod[0].Product_Name__c;
            cases.add(testCase);
        }
        if(doInsert)
            insert cases;
        return cases;
    }
    
    public static Related_Case__c createFRRelation(Case parentCase, Case childCase, Boolean doInsert){
        Related_Case__c relCase = new Related_Case__c();
        relCase.Parent_Case__c = parentCase.id;
        relCase.Case__c = childCase.id;
        if(doInsert)
            insert relCase;
        return relCase;
    }
    
    public static List<Support_Product__c> createSupportProducts(Integer numToInsert, Boolean doInsert){
        //User t3Manager = TestCommon.createUser('tstAlias', null, 'Test Last Name', 'Test First Name', null);
        //User pmOwner = TestCommon.createUser('tstAlias', null, 'Test Last Name', 'Test First Name', null);
        List<User> pmOwner = createUsers(1, true);
        
        List<Support_Product__c> supportProducts = new List<Support_Product__c>();
        for(Integer i = 0; i< numToInsert; i++){
            Support_Product__c supportProduct = new Support_Product__c();
           // supportProduct.Tier_3_Manager__c = t3Manager.id;
          //  supportProduct.Tier_3_Queue__c = 'Test Queue';
            supportProduct.PM_Owner__c = pmOwner[0].id;
            supportProducts.add(supportProduct);
        }
        if(doInsert)
            insert supportProducts;
        return supportProducts;     
    }
    
    public static List<Task> createTasks(Integer numToInsert, Boolean doInsert, Case testCase){
      List<Task> tasks = new List<Task>();
        for(Integer i = 0; i< numToInsert; i++){
            Task task = new Task();
            task.WhatId = testCase.id;
            task.Subject = 'test';
            tasks.add(task);
        }
        if(doInsert)
            insert tasks;
        return tasks;     
    }
    public static List<EmailMessage> createEmailMessage(Integer numToInsert, Boolean doInsert, Task task){
      List<EmailMessage> emailMessages = new List<EmailMessage>();
        for(Integer i = 0; i< numToInsert; i++){
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.ActivityId = task.id;
            emailMessage.Subject = 'test';
            emailMessage.ParentId = task.whatId;
            emailMessages.add(emailMessage);
        }
        if(doInsert)
            insert emailMessages;
        return emailMessages;     
    }
    public static List<Attachment> createAttachment(Integer numToInsert, Boolean doInsert, String parentId){
      List<Attachment> atts = new List<Attachment>();
        for(Integer i = 0; i< numToInsert; i++){
            Attachment att = new Attachment();
          att.ParentId = parentId;
          att.Name = 'Test Att ' + i;
          //att.Body = 'asd;fljalsjdlf;jalksdjf';
            atts.add(att);
        }
        if(doInsert)
            insert atts;
        return atts;     
    }    
    public static List<Product_Version__c> createProductVerion(Integer numToInsert, Boolean doInsert, Support_Product__c sp){
      List<Product_Version__c> testPVs = new List<Product_Version__c>();
        for(Integer i = 0; i< numToInsert; i++){
            Product_Version__c testPV = new Product_Version__c();
          testPV.Parent_Product__c = sp.id;
          testPV.Customer_Available__c = true;
          testPV.Major_Release__c = 'TEST';
          testPV.Active__c = true;
          testPV.Version__c = 'test';          
            testPVs.add(testPV);
        }
        if(doInsert)
            insert testPVs;
        return testPVs;     
    }
    public static List<Support_Access__c> createSupportAccess(Integer numToInsert, Boolean doInsert, Contact contact){
      List<Support_Access__c> sas = new List<Support_Access__c>();
      Back_Office_Account__c testBOA = new Back_Office_Account__c(End_User_Account__c = contact.AccountId, Sold_To_Account__c = contact.AccountId);
      insert testBOA;
        for(Integer i = 0; i< numToInsert; i++){
            Support_Access__c sa = new Support_Access__c();
            sa.Contact__c = contact.id;
            sa.Status__c = 'Active';
            sa.End_User_Account__c = contact.AccountId;
            sa.Sold_To_Account__c = contact.AccountId;
            sa.SR_Access_Level__c = 'Read/Write';
            sa.Back_Office_Account__c = testBOA.id;
          sas.add(sa);
        }
        if(doInsert)
            insert sas;
        return sas;     
    } 
    
    public static List<User> createUsers (Integer numToInsert, Boolean doInsert) {
      List<User> users = new List<User>();
      
      for (Integer i = 0; i< numToInsert; i++) {
          User u = new User();
          u.Username = 'test65490121'+ Math.random().format() + Math.random().format() + '@genesys.com';    
          u.LastName= 'Test';
          u.FirstName= 'Test';
          u.Email= u.Username;
          u.CommunityNickname= u.Username.substring(0, u.Username .indexOf('@'));
          u.Alias= u.CommunityNickname.substring(0,5);
          u.TimeZoneSidKey='Europe/Paris';  
          u.LocaleSidKey='fr_FR_EURO';
          u.EmailEncodingKey='ISO-8859-1';
          Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];     
          u.ProfileId = prof.Id;           
          u.LanguageLocaleKey='fr';
          u.isActive=true;
          u.ByPassValidationRules__c = true;
          u.EmployeeNumber = 'EMP-'+ Math.random().format();
          users.add(u);
      }
    
    if(doInsert)
      insert users;
    return users; 
            
    }
    
    public static void setConfigValues() {
      
      Config__c conf1 = new Config__c(name='COREOpportunityRecordType');
      insert conf1;      
    Config__c conf2 = new Config__c(name='CORE_OPP_STAGE_CLOSED_WON');
        insert conf2;   
    Config__c conf3 = new Config__c(name='USER_PARTNER');  insert conf3;  //PRM01
    Config__c conf4 = new Config__c(name='USER_STANDARD');  insert conf4;  //PRM01 test method
    Config__c conf5 = new Config__c(name='CORE_OPP_BP_STATUS_ALLOCATED');  insert conf5;  //PRM01
    Config__c conf6 = new Config__c(name='ALE_TEAM_MEMBER_ROLE');  insert conf6; //PRM01
    Config__c conf7 = new Config__c(name='CORE_OPP_BP_STATUS_REJECTED');  insert conf7;  //PRM03
    Config__c conf8 = new Config__c(name='CORE_OPP_BP_STATUS_NOT_ALLOCATED');  insert conf8;  //PRM03
    Config__c conf9 = new Config__c(name='CORE_OPP_BP_STATUS_APPROVED');  insert conf9;  //PRM04
    Config__c conf10 = new Config__c(name='BP_TEAM_MEMBER_ROLE');  insert conf10; //PRM04
    
    Config__c conf11 = new Config__c(name='TM_MONITOR_AD_EMAIL1');  insert conf11;  // TM02
    Config__c conf12 = new Config__c(name='TM_MONITOR_AD_EMAIL2');  insert conf12;  // TM02
    Config__c conf13 = new Config__c(name='TM_MONITOR_AD_EMAIL3');  insert conf13;  // TM02
    Config__c conf14 = new Config__c(name='TM_VALUE_SEPARATOR');  insert conf14; 
    Config__c conf15 = new Config__c(name='TM_USER_NAME_TEST1');  insert conf15; 
    Config__c conf16 = new Config__c(name='TM_USER_NAME_TEST2');  insert conf16; 
    Config__c conf17 = new Config__c(name='ASSET_DEFAULT_MANUFACTURER');  insert conf17; 
    
    Config__c conf18 = new Config__c(name='CORE_OpportunityApprovalProcess');  insert conf18; 
    
    Config__c conf60 = new Config__c(name='CORE_OPP_RTYPE'); insert conf60;
    
    
    /// Account
    List<RecordType> rt = [Select Id From RecordType LIMIT 1];
    
    Config__c conf19 = new Config__c(name='COREOpportunityRecordType', Value__c=rt[0].Id);  insert conf19; 
    Config__c conf20 = new Config__c(name='EMGBusinessPartnerRecordType');  insert conf20; 
    Config__c conf21 = new Config__c(name='EMGBusinessPartnerOwner');  insert conf21; 
    Config__c conf22 = new Config__c(name='EMGStatusGetRejected');  insert conf22; 
        
      //RFP
     Config__c conf23 = new Config__c(name='RT_RFP_Refused');  insert conf23; 
    Config__c conf24 = new Config__c(name='RT_RFP_Accepted');  insert conf24; 
    Config__c conf25 = new Config__c(name='RT_RFP_PROPOSAL_ACCEPTED');  insert conf25; 
    Config__c conf26 = new Config__c(name='RT_RFP_PROPOSAL_REFUSED');  insert conf26; 
    Config__c conf27 = new Config__c(name='ACCEPTED_RFP_FORM_TEMPLATE');  insert conf27; 
    Config__c conf28 = new Config__c(name='REJECTED_RFP_FORM_TEMPLATE');  insert conf28; 
    Config__c conf29 = new Config__c(name='SUBMIT_RFP_FORM_TEMPLATE');  insert conf29; 
    Config__c conf30 = new Config__c(name='PENDING_RFP_FORM_TEMPLATE');  insert conf30;  
    
      // OQM 
    Config__c conf31 = new Config__c(name='INACTIVE_OFFER');  insert conf31; 
    Config__c conf32 = new Config__c(name='ACTIVE_OFFER');  insert conf32; 
    Config__c conf33 = new Config__c(name='REGION_EMEA');  insert conf33; 
    Config__c conf34 = new Config__c(name='REGION_EMEA');  insert conf34; 
    Config__c conf35 = new Config__c(name='BID_PROPOSAL_CONTACT_EMEA');  insert conf35; 
    Config__c conf36 = new Config__c(name='BID_PROPOSAL_CONTACT_NA');  insert conf36; 
    Config__c conf37 = new Config__c(name='RFP_QUEUE');  insert conf37; 
    Config__c conf38 = new Config__c(name='RFP_MAIL');  insert conf38; 
      
    Config__c conf40 = new Config__c(name='RT_OQM_Submission');  insert conf40; 
    Config__c conf41 = new Config__c(name='RT_RFP_Submission');  insert conf41; 
      
    Config__c conf42 = new Config__c(name='RT_OQM_PROPOSAL_ACCEPTED');  insert conf42; 
    Config__c conf43 = new Config__c(name='RT_OQM_PROPOSAL_REFUSED');  insert conf43; 
    Config__c conf44 = new Config__c(name='OQM_STATUS_PENDING');  insert conf44; 
    Config__c conf45 = new Config__c(name='OQM_STATUS_SUBMIT');  insert conf45; 
    Config__c conf46 = new Config__c(name='OQM_STATUS_REJECTED');  insert conf46; 
    Config__c conf47 = new Config__c(name='OQM_STATUS_ACCEPTED');  insert conf47; 
     
      //Opportunity Stage
      
    Config__c conf48 = new Config__c(name='OPP_STAGE4');  insert conf48; 
    
    Config__c conf49 = new Config__c(name='OPP_STAGE5');  insert conf49; 
    Config__c conf50 = new Config__c(name='OPP_STAGE6');  insert conf50; 
    Config__c conf51 = new Config__c(name='OPP_STAGE7');  insert conf51; 
     
    Config__c conf52 = new Config__c(name='OPP_STAGE81');  insert conf52; 
    Config__c conf53 = new Config__c(name='OPP_STAGE82');  insert conf53; 
    Config__c conf54 = new Config__c(name='OPP_STAGE9');  insert conf54; 
    Config__c conf55 = new Config__c(name='OPP_STAGE10');  insert conf55; 
    Config__c conf56 = new Config__c(name='BP_ROLE');  insert conf56; 
     
    Config__c conf57 = new Config__c(name='PROFIL_ADMIN_ID');  insert conf57;  
    }
    
    public static void setCaseSupportTypesSettings() {
      
      Map<String, String> recrodTypeMap = new Map<String, String>();
      
      for(RecordType rt:[SELECT DeveloperName,Id
                       FROM   RecordType 
                        WHERE  SobjectType = 'Case']){
         recrodTypeMap.put(rt.DeveloperName, rt.Id);                  
        }
        
      Global_Setting__c gs1 = new Global_Setting__c(Name = 'Genesys_Admin_Case');
      gs1.ID__c = recrodTypeMap.get('Genesys_Admin_Case');
      insert gs1;   
      Global_Setting__c gs2 = new Global_Setting__c(Name = 'Genesys_Product_Case');
      gs2.ID__c = recrodTypeMap.get('Genesys_Product_Case');
      insert gs2;   
      Global_Setting__c gs3 = new Global_Setting__c(Name = 'Genesys_Outage');
      gs3.ID__c = recrodTypeMap.get('Genesys_Outage');
      insert gs3; 
      Global_Setting__c gs4 = new Global_Setting__c(Name = 'Genesys_Escalation_Case');
      gs4.ID__c = (String)recrodTypeMap.get('Genesys_Escalation_Case');
      insert gs4;
      Global_Setting__c gs5 = new Global_Setting__c(Name = 'Genesys_Feature_Request_Case');
      gs5.ID__c = (String)recrodTypeMap.get('Genesys_Feature_Request_Case');
      insert gs5;      
    }
    
    public static List<GCR_Content_Document_Detail_Approval__c> createGCRContentDocument( Integer numToInsert, Boolean doInsert ) {
        List<GCR_Content_Document_Detail_Approval__c> listDoc = new List<GCR_Content_Document_Detail_Approval__c>();
       
        for( Integer i=0; i < numToInsert; i++ ) {
            GCR_Content_Document_Detail_Approval__c a = new GCR_Content_Document_Detail_Approval__c(  Approval_Submission_Counter__c = 1,Approved_Rejected_Date__c = Date.Today() );            
            listDoc.add( a );
        }
        
        if( doInsert )
            insert listDoc;
        return listDoc;
    }
}