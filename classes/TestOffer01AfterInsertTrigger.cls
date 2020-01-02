/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData = true)
private class TestOffer01AfterInsertTrigger {

    static testMethod void ActiveOffer() {
        OQM_Form__c OQMTest = TestOffer01AfterInsertTrigger.SetupTest();
        
        Offer__c OfferTest1 = new Offer__c();
        OfferTest1.OQMName__c = OQMTest.id;
        
        Offer__c OfferTest2 = new Offer__c();
        OfferTest2.OQMName__c = OQMTest.id;
        
        Test.Starttest();
        database.insert(OfferTest1);
        
        Offer__c O = [SELECT id,Active_Offer1__c
        			  FROM Offer__c
        			  WHERE id = :OfferTest1.id];
        			  	
        //Check New Offer is active
        System.debug('###OfferTest1 : ' + O);
        System.assertEquals(O.Active_Offer1__c,'Active');
        //System.assertEquals(OfferTest1.Active_Offer__c,'Active');
        
        database.insert(OfferTest2);
        
        O = [SELECT id,Active_Offer1__c
        			  FROM Offer__c
        			  WHERE id = :OfferTest1.id];
        
        Offer__c O2 = [SELECT id,Active_Offer1__c
        			  FROM Offer__c
        			  WHERE id = :OfferTest2.id];
        			  
        //Check New Offer is active
        System.debug('###OfferTest2 : ' + O2);
        System.assertEquals(O2.Active_Offer1__c,'Active');

        //Check Old Offer is inactive
        System.debug('###OfferTest1 Updated : ' + O);
        //System.assertEquals(O.Active_Offer1__c,'Inactive');

        Test.stopTest(); 
        
    }
    

    
    static testMethod OQM_Form__c SetupTest () {
      	
      	 OQM_Form__c OQM = New OQM_Form__c();
 		 Opportunity Opp = New Opportunity();
   		 Account Acc = New Account();
 		 Country__c C = New Country__c();
 		 Country__c C2 = New Country__c();
 		 Contact ctc = new contact();
 		 OpportunityContactRole ocr = new OpportunityContactRole();
 		 //BusinessPartner__c bpa = new BusinessPartner__c();
 		 Account bpa = TestCommon.createAccountBP(true);
 		 
 		/* OpportunityLineItem opplt = [SELECT id 
 		 							  FROM OpportunityLineItem
 		 							  limit 1];
 		 Product2 p = [SELECT id
 		 			  FROM Product2
 		 			  limit 1];
 		 PricebookEntry pbk = [SELECT id
 		 							  FROM PricebookEntry limit 1];
 		 */
 		
 		 Acc.Street1__c ='13 Rue de la Tremoille';
        Acc.Name = 'My Account Test';
        Acc.Type = 'Customer';
        Acc.City__c = 'Paris';
        Acc.Country__c = C.id;
        Acc.Industry = 'EDUCATION';
        Acc.InactiveAccount__c=false;
        Acc.Status__c = 'Active';
        Acc.AccountClassification__c = 'Key Account';
        //Acc.AccountProfile__c = 'BP';
        Database.Insert(Acc);
 		 
        ctc.AccountId = acc.id;
        ctc.LastName = 'Polin';
        ctc.Function__c = 'Telecom Director';
        ctc.Email = 'aaa@aaa.com';
        ctc.DecisionRole__c = 'Specifier';
        ctc.FirstName = 'test';
        Database.insert(ctc);
        
        C.Name = 'AAA';
        C.SubRU__c = 'Page.Reg';
        C.Region__c = 'EMEA';
        C.Country__c = 'AAA';
        Database.Insert(C);
        
        C2.Name = 'AAAA';
        C2.SubRU__c = 'Page.Reg';
        C2.Region__c = 'EMEA';
        C2.Country__c = 'AAAA';
        Database.Insert(C2);
        
       
        
        Opp.AccountId = Acc.id;
        Opp.Name = 'My Opp Test OQM';
        Opp.CloseDate = Date.today();
        Opp.StageName = '2-Opportunity';
        opp.BusinessPartner__c = bpa.id;
        Database.Insert(Opp);
 		 
        ocr.OpportunityId = opp.id;
        ocr.ContactId = ctc.id;
        ocr.Role = 'Approver';       
        
        oqm.Name = opp.Name;
        oqm.OpportunityName__c = opp.id;
        oqm.QueueName__c = 'Bid And Proposal EMEA';
        oqm.UserToAddress__c = UserInfo.getUserId();
        oqm.ownerId = UserInfo.getUserId();
        OQM.NewOQM__c = true;
        
        database.insert(oqm);
        database.insert(ocr);
                
        return oqm;
      }
}