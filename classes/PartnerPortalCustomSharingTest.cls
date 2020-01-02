/*
 * Class            : PartnerPortalCustomSharingTest
 * Description      : A Test class for various different utility, batch and queueable classes realated to Partner Portal Custom Sharing.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : NA   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 @isTest
 public class PartnerPortalCustomSharingTest {
    
    @isTest(SeeAllData=true)
    static void testManageOpportunityTeamAndShareRelatedObjects(){
        
        Util.Bypass_Trigger_Chk = true;
        
        List<User> users = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 20];
        List<String> contactIds = new List<String>();
        List<String> accountIds = new List<String>();
        for(User u : users){
            contactIds.add(u.ContactId);    
            accountIds.add(u.Contact.AccountId);
        }
        
        List<Opportunity> opportunities = [SELECT id, Name, BusinessPartner__c, OwnerId FROM Opportunity WHERE BusinessPartner__c != NULL AND BusinessPartner__c IN :accountIds AND Owner.isActive = true LIMIT 10]; 
        Set<String> businessPartners = new Set<String>();
        for(Opportunity o : opportunities){
            businessPartners.add(o.BusinessPartner__c); 
        }
        
        
        List<BigMachines__Quote__c> quotes1 = TestUtil.createQuotes(1, opportunities[0].Id, true);
        List<BigMachines__Quote__c> quotes2 = TestUtil.createQuotes(1, opportunities[0].Id, true);
        List<BigMachines__Quote__c> quotes3 = TestUtil.createQuotes(1, opportunities[1].Id, true);
        List<BigMachines__Quote__c> quotes4 = TestUtil.createQuotes(1, opportunities[1].Id, true);
        
        List<Order__c> orders1 = TestUtil.createOrders(1, quotes1[0].Id, opportunities[0].Id, true);
        List<Order__c> orders2 = TestUtil.createOrders(1, quotes2[0].Id, opportunities[0].Id, true);
        List<Order__c> orders3 = TestUtil.createOrders(1, quotes3[0].Id, opportunities[1].Id, true);
        List<Order__c> orders4 = TestUtil.createOrders(1, quotes4[0].Id, opportunities[1].Id, true);
        List<Deal_Support__c> dealSupportRequests = new List<Deal_Support__c>();
        for(Opportunity opp : opportunities){
            dealSupportRequests.add(new Deal_Support__c(Opportunity__c = opp.Id, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test1', Description__c = 'test1'));
            dealSupportRequests.add(new Deal_Support__c(Opportunity__c = opp.Id, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test2', Description__c = 'test2'));
        }
        insert dealSupportRequests;   
        Util.Bypass_Trigger_Chk = false;
        
        
        Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name, AccountId FROM Contact WHERE Contact.Account.RecordTypeId = :partnerRecordTypeId AND Designated_Partner_Contact__c = true AND Status__c = 'Active' LIMIT 10];             
        Test.startTest();
        //PartnerPortalCustomSharing.manageOpportunityTeamAndShareRelatedObjects(contactIds, opportunities);
        Test.stopTest();                
    }    
    @isTest(SeeAllData=true)
    static void testManageOpportunityTeamForPartnerContacts(){
        
        Util.Bypass_Trigger_Chk = true;
        Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, Name, AccountId FROM Contact WHERE Contact.Account.RecordTypeId = :partnerRecordTypeId AND Designated_Partner_Contact__c = true AND Status__c = 'Active' LIMIT 10];             
        Test.startTest();
        //PartnerPortalCustomSharing.manageOpportunityTeamForPartnerContacts(contacts);
        Test.stopTest();                
        Util.Bypass_Trigger_Chk = false; 
    }
    
    @isTest(SeeAllData=true)
    static void testShareRelatedObjectsWithOpportunityTeam1(){
        Util.Bypass_Trigger_Chk = true;
        List<OpportunityTeamMember> otmList = [SELECT id, OpportunityId, UserId FROM OpportunityTeamMember WHERE Opportunity.BusinessPartner__c != NULL 
                                                    AND Opportunity.BusinessPartner__r.RecordType.Name = 'Enterprise - Business Partner' 
                                                    AND Opportunity.Owner.isActive = true
                                                    AND User.isActive = true
                                                    LIMIT 2]; 

        List<BigMachines__Quote__c> quotes1 = TestUtil.createQuotes(1, otmList[0].OpportunityId, true);
        List<BigMachines__Quote__c> quotes2 = TestUtil.createQuotes(1, otmList[1].OpportunityId, true);
        List<Order__c> orders1 = TestUtil.createOrders(1, quotes1[0].Id, otmList[0].OpportunityId, true);
        List<Order__c> orders2 = TestUtil.createOrders(1, quotes2[0].Id, otmList[1].OpportunityId, true);
        List<Deal_Support__c> dealSupportRequests = new List<Deal_Support__c>();
        for(OpportunityTeamMember otm : otmList){
            dealSupportRequests.add(new Deal_Support__c(Opportunity__c = otm.OpportunityId, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test', Description__c = 'test'));
        }
        insert dealSupportRequests;   
        Util.Bypass_Trigger_Chk = false;
            
        Test.startTest();
        Set<String> opportunityIds = new Set<String>();
        opportunityIds.add(otmList[0].OpportunityId);
        opportunityIds.add(otmList[1].OpportunityId);
        PartnerPortalCustomSharing.shareRelatedObjectsWithOpportunityTeam(otmList);
        Test.stopTest();    
    }
    
    @isTest(SeeAllData=true)
    static void testShareRelatedObjectsWithOpportunityTeam2(){
        Util.Bypass_Trigger_Chk = true;
        List<OpportunityTeamMember> otmList = [SELECT id, OpportunityId FROM OpportunityTeamMember WHERE Opportunity.BusinessPartner__c != NULL 
                                                    AND Opportunity.BusinessPartner__r.RecordType.Name = 'Enterprise - Business Partner' 
                                                    AND Opportunity.Owner.isActive = true
                                                    AND User.isActive = true LIMIT 2]; 

        List<BigMachines__Quote__c> quotes1 = TestUtil.createQuotes(1, otmList[0].OpportunityId, true);
        List<BigMachines__Quote__c> quotes2 = TestUtil.createQuotes(1, otmList[1].OpportunityId, true);
        List<Order__c> orders1 = TestUtil.createOrders(1, quotes1[0].Id, otmList[0].OpportunityId, true);
        List<Order__c> orders2 = TestUtil.createOrders(1, quotes2[0].Id, otmList[1].OpportunityId, true);
        List<Deal_Support__c> dealSupportRequests = new List<Deal_Support__c>();
        for(OpportunityTeamMember otm : otmList){
            dealSupportRequests.add(new Deal_Support__c(Opportunity__c = otm.OpportunityId, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test', Description__c = 'test'));
        }
        insert dealSupportRequests;   
        Util.Bypass_Trigger_Chk = false;
            
        Test.startTest();
        Set<String> opportunityIds = new Set<String>();
        opportunityIds.add(otmList[0].OpportunityId);
        opportunityIds.add(otmList[1].OpportunityId);
        PartnerPortalCustomSharing.shareRelatedObjectsWithOpportunityTeam(opportunityIds);
        Test.stopTest();    
    }
    
    /*
    @isTest(SeeAllData=true)
        static void testShareDealSupportRequestWithOpportunityTeam(){
        Util.Bypass_Trigger_Chk = true;
        Test.startTest();

        List<OpportunityTeamMember> otmList = [SELECT id, OpportunityId FROM OpportunityTeamMember WHERE Opportunity.BusinessPartner__c != NULL 
                                                    AND Opportunity.BusinessPartner__r.RecordType.Name = 'Enterprise - Business Partner' 
                                                    AND Opportunity.Owner.isActive = true
                                                    AND User.isActive = true LIMIT 2]; 
       
            
        List<Deal_Support__c> dealSupportRequests = new List<Deal_Support__c>();
        for(OpportunityTeamMember otm : otmList){
            Deal_Support__c objTestDS = new Deal_Support__c();
            objTestDS.Opportunity__c = otm.OpportunityId;
            objTestDS.Support_Area__c = 'Business Consulting';
            objTestDS.Request_Type__c = 'Business Consulting Inquiry';
            objTestDS.Subject__c = 'test';
            objTestDS.Description__c = 'test';
            dealSupportRequests.add(objTestDS);
        }
        insert dealSupportRequests;
        Test.stopTest();
        Util.Bypass_Trigger_Chk = false;
    }
    
    @isTest(SeeAllData=true)
    static void testShareOrderWithOpportunityTeam(){
        Util.Bypass_Trigger_Chk = true;
        Test.startTest();
        List<OpportunityTeamMember> otmList = [SELECT id, OpportunityId FROM OpportunityTeamMember WHERE Opportunity.BusinessPartner__c != NULL 
                                                    AND Opportunity.BusinessPartner__r.RecordType.Name = 'Enterprise - Business Partner' 
                                                    AND Opportunity.Owner.isActive = true
                                                    AND User.isActive = true LIMIT 2]; 
                                                    
        List<BigMachines__Quote__c> quotes1 = TestUtil.createQuotes(1, otmList[0].OpportunityId, true);
        List<BigMachines__Quote__c> quotes2 = TestUtil.createQuotes(1, otmList[1].OpportunityId, true);
        List<Order__c> orders1 = TestUtil.createOrders(1, quotes1[0].Id, otmList[0].OpportunityId, true);
        List<Order__c> orders2 = TestUtil.createOrders(1, quotes2[0].Id, otmList[1].OpportunityId, true);
        Test.stopTest();
        Util.Bypass_Trigger_Chk = false;
    }*/
    
    @isTest(SeeAllData=true)
    static void testShareQuoteWithOpportunityTeam(){
        Util.Bypass_Trigger_Chk = true;
        Test.startTest();
        List<OpportunityTeamMember> otmList = [SELECT id, OpportunityId FROM OpportunityTeamMember WHERE Opportunity.BusinessPartner__c != NULL 
                                                    AND Opportunity.BusinessPartner__r.RecordType.Name = 'Enterprise - Business Partner' 
                                                    AND Opportunity.Owner.isActive = true
                                                    AND User.isActive = true LIMIT 2]; 
        List<BigMachines__Quote__c> quotes1 = TestUtil.createQuotes(1, otmList[0].OpportunityId, true);
        List<BigMachines__Quote__c> quotes2 = TestUtil.createQuotes(1, otmList[1].OpportunityId, true);
        Test.stopTest();
        Util.Bypass_Trigger_Chk = false;
    }
    
    
    @isTest(SeeAllData=true)
    static void testCleanupRelatedObjectsSharing1(){
        
        Util.Bypass_Trigger_Chk = true;
        
        User u = [SELECT Id, ContactId, Contact.AccountId FROM User 
                    WHERE isActive = true 
                    AND ContactId != NULL 
                    AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' 
                    AND Contact.Designated_Partner_Contact__c = true LIMIT 1];

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opp', AccountId = u.Contact.AccountId, BusinessPartner__c = u.Contact.AccountId, CloseDate = Date.today().addMonths(1), StageName = '1.Recognize Needs');
        insert testOpportunity;
        
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = testOpportunity.Id, UserId = u.Id, TeamMemberRole = 'Designated Partner Contact', OpportunityAccessLevel = 'Edit');
        insert otm;
        
        List<BigMachines__Quote__c> quotes1 = TestUtil.createQuotes(1, testOpportunity.Id, true);
        List<BigMachines__Quote__c> quotes2 = TestUtil.createQuotes(1, testOpportunity.Id, true);
        
        List<BigMachines__Quote__Share> quoteShares = new List<BigMachines__Quote__Share>(); 
        quoteShares.add(new BigMachines__Quote__Share(ParentId = quotes1[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
        quoteShares.add(new BigMachines__Quote__Share(ParentId = quotes2[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
        insert quoteShares;
        
        List<Order__c> orders1 = TestUtil.createOrders(1, quotes1[0].Id, testOpportunity.Id, true);
        List<Order__c> orders2 = TestUtil.createOrders(1, quotes2[0].Id, testOpportunity.Id, true);
        
        List<Order__Share> orderShares = new List<Order__Share>(); 
        orderShares.add(new Order__Share(ParentId = orders1[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
        orderShares.add(new Order__Share(ParentId = orders2[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
        insert orderShares;
        
        List<Deal_Support__c> dealSupportRequests = new List<Deal_Support__c>();
        dealSupportRequests.add(new Deal_Support__c(Opportunity__c = testOpportunity.Id, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test1', Description__c = 'test1'));
        dealSupportRequests.add(new Deal_Support__c(Opportunity__c = testOpportunity.Id, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test2', Description__c = 'test2'));
        insert dealSupportRequests;   
        
        List<Deal_Support__Share> dealSupportShares = new List<Deal_Support__Share>();
        dealSupportShares.add(new Deal_Support__Share(ParentId = dealSupportRequests[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
        dealSupportShares.add(new Deal_Support__Share(ParentId = dealSupportRequests[1].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
        insert dealSupportShares; 
        
        Util.Bypass_Trigger_Chk = false;
        
        Test.startTest();
        Contact c = new Contact(id = u.ContactId, Designated_Partner_Contact__c = false);
        Update c;
        Test.stopTest();                
    }    
    
     @isTest(SeeAllData=true)
    static void testCleanupRelatedObjectsSharing2(){
        
        Util.Bypass_Trigger_Chk = true;
        
        User u = [SELECT Id, ContactId, Contact.AccountId FROM User 
                    WHERE isActive = true 
                    AND ContactId != NULL 
                    AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' 
                    AND Contact.Designated_Partner_Contact__c = true LIMIT 1];

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opp', AccountId = u.Contact.AccountId, BusinessPartner__c = u.Contact.AccountId, CloseDate = Date.today().addMonths(1), StageName = '1.Recognize Needs');
        insert testOpportunity;
        
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = testOpportunity.Id, UserId = u.Id, TeamMemberRole = 'Designated Partner Contact', OpportunityAccessLevel = 'Edit');
        insert otm;
        
        List<BigMachines__Quote__c> quotes1 = TestUtil.createQuotes(1, testOpportunity.Id, true);
        List<BigMachines__Quote__c> quotes2 = TestUtil.createQuotes(1, testOpportunity.Id, true);
        
        List<BigMachines__Quote__Share> quoteShares = new List<BigMachines__Quote__Share>(); 
        quoteShares.add(new BigMachines__Quote__Share(ParentId = quotes1[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
        quoteShares.add(new BigMachines__Quote__Share(ParentId = quotes2[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c));
        insert quoteShares;
        
        List<Order__c> orders1 = TestUtil.createOrders(1, quotes1[0].Id, testOpportunity.Id, true);
        List<Order__c> orders2 = TestUtil.createOrders(1, quotes2[0].Id, testOpportunity.Id, true);
        
        List<Order__Share> orderShares = new List<Order__Share>(); 
        orderShares.add(new Order__Share(ParentId = orders1[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
        orderShares.add(new Order__Share(ParentId = orders2[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.Order__Share.RowCause.Sales_Team_Access__c));
        insert orderShares;
        
        List<Deal_Support__c> dealSupportRequests = new List<Deal_Support__c>();
        dealSupportRequests.add(new Deal_Support__c(Opportunity__c = testOpportunity.Id, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test1', Description__c = 'test1'));
        dealSupportRequests.add(new Deal_Support__c(Opportunity__c = testOpportunity.Id, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test2', Description__c = 'test2'));
        insert dealSupportRequests;   
        
        List<Deal_Support__Share> dealSupportShares = new List<Deal_Support__Share>();
        dealSupportShares.add(new Deal_Support__Share(ParentId = dealSupportRequests[0].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
        dealSupportShares.add(new Deal_Support__Share(ParentId = dealSupportRequests[1].Id, UserOrGroupId = u.Id, AccessLevel = 'Edit', RowCause = Schema.Deal_Support__Share.RowCause.Sales_Team_Access__c));
        insert dealSupportShares; 
        
        Util.Bypass_Trigger_Chk = false;
        Test.startTest();
        delete otm;
        Test.stopTest();                
    }   
    
    // Test Classes for Batches
    @isTest(seeAllData=true)
    static void testAddPartnerContactsToOpportunityTeamBatch(){
        Database.executeBatch(new AddPartnerContactsToOpportunityTeamBatch()); 
    }
    
    @isTest(seeAllData=true)
    static void testShareOpportunityRelatedObjectsToOTMBatch(){
        Database.executeBatch(new ShareOpportunityRelatedObjectsToOTMBatch()); 
    }

    @isTest(seeAllData=true)
    static void testPartnerPortalCustomSharingQueueable(){
        List<User> users = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 10];
        List<String> contactIds = new List<String>();
        for(User u : users){
            contactIds.add(u.ContactId);    
        }       
        System.enqueueJob(new PartnerPortalCustomSharingQueueable(contactIds));
    }

    @isTest(seeAllData=true)
    static void testPartnerPortalCustomSharingBatch(){
        List<User> users = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 10];
        List<String> contactIds = new List<String>();
        for(User u : users){
            contactIds.add(u.ContactId);    
        }       
        Database.executeBatch(new PartnerPortalCustomSharingBatch(contactIds)); 
    }
    
    @isTest(seeAllData=true)
    static void testPartnerDealRegistrationShareOneTimeBatch(){
        Database.executeBatch(new PartnerDealRegistrationShareOneTimeBatch()); 
    }
    
    @isTest(seeAllData=true)
    static void testPartnerDealRegistrationSharingQueueable(){
        List<Partner_Portal_Prospect__c> dealRegistrations = [SELECT id, Name, Account__r.Name, OwnerId, Owner.Name FROM Partner_Portal_Prospect__c where Owner.isActive = true AND Owner.Profile.Name = 'Genesys Portal Partner' LIMIT 2];
        Set<String> userIds = new Set<String>();
        for(Partner_Portal_Prospect__c dealRegistration : dealRegistrations){
            userIds.add(dealRegistration.OwnerId);
        }
        
        List<String> contactIds = new List<String>();
        for(User u : [SELECT id, Name, ContactId FROM User WHERE Id IN :userIds AND ContactId != NULL]){
            contactIds.add(u.ContactId);    
        }       
        System.enqueueJob(new PartnerDealRegistrationSharingQueueable(contactIds));
    }

    @isTest(seeAllData=true)
    static void testPartnerDealRegistrationSharingBatch(){
        List<Partner_Portal_Prospect__c> dealRegistrations = [SELECT id, Name, Account__r.Name, OwnerId, Owner.Name FROM Partner_Portal_Prospect__c where Owner.isActive = true AND Owner.Profile.Name = 'Genesys Portal Partner' LIMIT 2];
        Set<String> userIds = new Set<String>();
        for(Partner_Portal_Prospect__c dealRegistration : dealRegistrations){
            userIds.add(dealRegistration.OwnerId);
        }
        
        List<String> contactIds = new List<String>();
        for(User u : [SELECT id, Name, ContactId FROM User WHERE Id IN :userIds AND ContactId != NULL]){
            contactIds.add(u.ContactId);    
        }       
        Database.executeBatch(new PartnerDealRegistrationSharingBatch(contactIds)); 
    }
    
    
    @isTest(seeAllData=true)
    static void testPartnerDealRegDeleteSharingQueueable(){
        User u = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 1];
        Partner_Portal_Prospect__c oppReg = new Partner_Portal_Prospect__c
                    ( Name='Test Account', Customer_Company_Name__c = 'Customer Company Name', Status__c = 'Approved', Genesys_AE__c='exec',
                      End_User_Account__c = u.Contact.AccountId,
                      Account__c = u.Contact.AccountId,
                      Offerings_Type__c = 'PureConnect',
                      Offering_Details__c = 'Subscription',
                      Opportunity_Currency__c = 'USD',
                      What_is_the_Expected_Close_Date__c = Date.today().addDays(1));                      
        insert oppReg; 
        System.enqueueJob(new PartnerDealRegDeleteSharingQueueable(new List<String>{u.ContactId}));
    }
    
    @isTest(seeAllData=true)
    static void testPartnerDealRegDeleteSharingBatch(){
        User u = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 1];
        Partner_Portal_Prospect__c oppReg = new Partner_Portal_Prospect__c
                    ( Name='Test Account', Customer_Company_Name__c = 'Customer Company Name', Status__c = 'Approved', Genesys_AE__c='exec',
                      End_User_Account__c = u.Contact.AccountId,
                      Account__c = u.Contact.AccountId,
                      Offerings_Type__c = 'PureConnect',
                      Offering_Details__c = 'Subscription',
                      Opportunity_Currency__c = 'USD',
                      What_is_the_Expected_Close_Date__c = Date.today().addDays(1));                      
        insert oppReg; 
        Database.executeBatch(new PartnerDealRegDeleteSharingBatch(new List<String>{u.ContactId}));
    }
    
    // Test Classes for Triggers
    @isTest(seeAllData=true)
    static void testTrigger_Quote_After(){
        List<Opportunity> opportunities = [SELECT id, Name, AccountId, BusinessPartner__c, OwnerId FROM Opportunity 
                                           WHERE BusinessPartner__c != NULL AND RecordType.Name = 'GEN - Opportunity Record Type' AND Owner.isActive = true LIMIT 1]; 
        List<BigMachines__Quote__c> quotes = TestUtil.createQuotes(1, opportunities[0].Id, true);
    }
    
    @isTest(seeAllData=true)
    static void testTrigger_Order_After_Share(){
        List<Opportunity> opportunities = [SELECT id, Name, AccountId, BusinessPartner__c, OwnerId FROM Opportunity 
                                           WHERE BusinessPartner__c != NULL AND RecordType.Name = 'GEN - Opportunity Record Type' AND Owner.isActive = true LIMIT 1]; 
        List<BigMachines__Quote__c> quotes = TestUtil.createQuotes(1, opportunities[0].Id, true);
        
        Order__c orderObj = new Order__c();
        orderObj.Quote__c = quotes[0].id;
        orderObj.Maintenance_Start__c = Date.today();
        orderObj.Maintenance_End__c = Date.today().addYears(1);
        orderObj.Opportunity__c = opportunities[0].id;
        orderObj.Numb_of_Maint_Months__c = 12;
        orderObj.End_User_Name__c = opportunities[0].AccountId;
        orderObj.Sold_To_Name__c = opportunities[0].BusinessPartner__c;
        orderObj.status__c = 'In Progress';
        insert orderObj;
    }

    // Also run DealSupport_Test
    @isTest(seeAllData=true)
    static void testTrigger_DealSupport_After(){
        List<Opportunity> opportunities = [SELECT id, Name, BusinessPartner__c, OwnerId 
                                           FROM Opportunity WHERE BusinessPartner__c != NULL AND Owner.isActive = true LIMIT 1]; 
        Deal_Support__c ds = new Deal_Support__c(Opportunity__c = opportunities[0].Id, Support_Area__c = 'Business Consulting', Request_Type__c = 'Business Consulting Inquiry', Subject__c = 'test', Description__c = 'test');
        insert ds;
    }

    @isTest(seeAllData=true)
    static void testTrigger_Contact_After(){
        List<User> users = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 2];
        Contact c = new Contact(Id = users[0].ContactId, Designated_Partner_Contact__c = false);
        update c;
        c.Designated_Partner_Contact__c = true;
        update c;
    }
    
    @isTest(seeAllData=true)
    static void testTrigger_PartnerPortalOpportunityRegistration_After(){
        User u = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 1];
        Partner_Portal_Prospect__c oppReg = new Partner_Portal_Prospect__c
                    ( Name='Test Account', Customer_Company_Name__c = 'Customer Company Name', Status__c = 'Approved', Genesys_AE__c='exec',
                      End_User_Account__c = u.Contact.AccountId,
                      Account__c = u.Contact.AccountId,
                      Offerings_Type__c = 'PureConnect',
                      Offering_Details__c = 'Subscription',
                      Opportunity_Currency__c = 'USD',
                      What_is_the_Expected_Close_Date__c = Date.today().addDays(1));                      
        insert oppReg; 
    }
}