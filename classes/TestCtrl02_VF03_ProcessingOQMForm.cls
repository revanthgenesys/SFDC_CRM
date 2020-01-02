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
@isTest
private class TestCtrl02_VF03_ProcessingOQMForm {

 
     
static testMethod void TestRejectOQM() {
	OQM_Form__c OQM = TestCtrl02_VF03_ProcessingOQMForm.setupTest();
	Opportunity Opp = TestCtrl02_VF03_ProcessingOQMForm.SetupTestCreateOppty();
        /* Construct the standard controller for OQM. */
        ApexPages.StandardController con = new ApexPages.StandardController(OQM);
        ApexPages.StandardController con2 = new ApexPages.StandardController(Opp);
        
        Test.Starttest();
        Ctrl03_VF01_Create_OQM_Form cof = new Ctrl03_VF01_Create_OQM_Form(con2);
        Ctrl02_VF03_ProcessingOQMForm acr = new Ctrl02_VF03_ProcessingOQMForm(con);
        Ctrl01_VF01_AddContactRole acr2 = new Ctrl01_VF01_AddContactRole(con);
        acr2.getlstOpptyContactRole();
        
        
		acr.Reject_OQM_Form();
		             
		List<ErrorLogItem > lstErrorLogItem = new List<ErrorLogItem >();
		Map<String,Integer> mapObjectNbSuccessDML = new Map<String,Integer>();
		Map<String,Integer> mapObjectNbErrorDML = new Map<String,Integer>();
		List<Account> LstAcc = new List<Account>(); 
		Account acc1 = new Account(Name ='myCompany1');
		Account acc2 = new Account(Name ='myCompany2');
		lstAcc.add(acc1);
		lstAcc.add(acc2);
		Util.dataBaseActionLstSobjects(lstAcc,'Insert',lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML); 
		Util.dataBaseActionLstSobjects(lstAcc,'Delete',lstErrorLogItem,mapObjectNbSuccessDML,mapObjectNbErrorDML); 
	
		
		/* Switch back to test context */  
		Test.stopTest();
}

static testMethod void TestAcceptedOQM() {
	
	RecordType rt = [select Id 
    				 from RecordType 
    				 where DeveloperName = 'OQM_Form_Proposal_Accepted_Record_Type'
    				 AND SobjectType = 'OQM_Form__c'];
      			  
    
    Country__c count = new Country__c( Name = 'USABi',
								RU__c = 'RU USA',
								SubRU__c = 'USA Reg.',
								Region__c = 'AMERICAS',
								Country__c = 'USABi'
								);
    				 
	OQM_Form__c OQM = TestCtrl02_VF03_ProcessingOQMForm.setupTest();
        /* Construct the standard controller for OQM. */
        ApexPages.StandardController con = new ApexPages.StandardController(OQM);
        
        Ctrl02_VF03_ProcessingOQMForm acr = new Ctrl02_VF03_ProcessingOQMForm(con);
         Opportunity o = [SELECT id,accountId
    				 FROM Opportunity
    				 WHERE id = :OQM.OpportunityName__c];
    				 
    	Account a = [SELECT id
    				 FROM Account
    				 WHERE id = : o.AccountId];			 
        Test.Starttest();
        
		acr.Accepted_OQM_Form();
        
       OQM_Form__c rtOQM = [SELECT RecordTypeId
        			   FROM OQM_Form__c
        			   WHERE Id = : OQM.Id];
        			   System.debug('###RTOQM' + rtOQM);
      //  System.assertEquals(rtOQM.RecordTypeId,rt.id);
		
		OQM.OfferMade__c = Date.today();
		oqm.ownerId = '005U0000000dnCY';
		// added owner update by Mani g on 2/12/2012
        //database.update(oqm);
        
        o.StageName = '5-Short List';
        database.update(o);        
        o.StageName = '6-Price Negotiation';
        database.update(o);
        o.StageName= '7-ALU Selected';
        database.update(o);
        o.StageName= '8-Closed Won';
        o.Competitor__c = '3COM';
        o.WonLostCancelledReason__c = 'High Price';
        o.WonLostCancelledComments__c='test';
        o.Factors_Influencing_Price__c='test';
        o.WonLostCancelledComments__c ='testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test';
		o.WonLostCancelledComments__c += ' test testing  test testing  test testing  test testing  test testing  test testing  test testing  test testing ';
        database.update(o);
        o.StageName = '8-Closed Lost';
        o.WonLostCancelledComments__c='test';
        o.WonLostCancelledComments__c ='testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test';
		o.WonLostCancelledComments__c += ' test testing  test testing  test testing  test testing  test testing  test testing  test testing  test testing ';
        database.update(o);
        o.WonLostCancelledComments__c ='testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test';
		o.WonLostCancelledComments__c += ' test testing  test testing  test testing  test testing  test testing  test testing  test testing  test testing ';
        o.StageName = '9-Closed Cancelled';
        o.WonLostCancelledComments__c='test';
        o.WonLostCancelledComments__c ='testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test testing test';
		o.WonLostCancelledComments__c += ' test testing  test testing  test testing  test testing  test testing  test testing  test testing  test testing '; 
        database.update(o);
        
       /* o.OwnerId = u.id;
        database.update(o);
        
        a.CallCenter__c = true;
        a.Country__c = count.id; 
        database.update(a);*/
		/* Switch back to test context */  
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
        Acc.AccountClassification__c = 'Key Account';
        //Acc.AccountProfile__c = 'BP';
        Database.Insert(Acc);

        ctc.AccountId = acc.id;
        ctc.LastName = 'Polin';
        ctc.Function__c = 'Telecom Director';
        ctc.DecisionRole__c = 'Specifier';
        ctc.Email = 'aa@a.com';
        
        Database.insert(ctc);
        
        C.Name = 'Francebis';
        C.SubRU__c = 'Page.Reg';
        C.Region__c = 'EMEA';
        C.Country__c = 'Francebis';
        Database.Insert(C);
        
        C2.Name = 'USAbis';
        C2.SubRU__c = 'Page.Reg';
        C2.Region__c = 'EMEA';
        C2.Country__c = 'USAbis';
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
        //oqm.ownerId = UserInfo.getUserId(); commented by Mani G on 2/10/2012
        oqm.ownerId = '005U0000000dnCY';
        OQM.NewOQM__c = true;
        
        database.insert(oqm);
        database.insert(ocr);
                
        return oqm;
      }
    
    static testMethod Opportunity SetupTestCreateOppty () {
        
         OQM_Form__c OQM = New OQM_Form__c();
         Opportunity Opp = New Opportunity();
         Account Acc = New Account();
         Country__c C = New Country__c();
         Contact ctc = new contact();
         OpportunityContactRole ocr = new OpportunityContactRole();
		
		Acc.Street1__c ='13 Rue de la Tremoille';
        Acc.Name = 'My Account Test';
        Acc.Type = 'Customer';
        Acc.City__c = 'Paris';
        Acc.Country__c = C.id;
        Acc.Industry = 'EDUCATION';
        Acc.AccountClassification__c = 'Key Account';
        //Acc.AccountProfile__c = 'BP';
        Database.Insert(Acc);
        
        ctc.AccountId = acc.id;
        ctc.LastName = 'Polin';
        ctc.Function__c = 'Telecom Director';
        ctc.DecisionRole__c = 'Specifier';
        ctc.Email ='aaa@aa.com';
        
        Database.insert(ctc);
        
        C.Name = 'Francebies';
        C.SubRU__c = 'Page.Reg';
        C.Region__c = 'EMEA';
        C.Country__c = 'Francebies';
        Database.Insert(C);
        
        
        
        Opp.AccountId = Acc.id;
        Opp.Name = 'My Opp Test OQM';
        Opp.CloseDate = Date.today();
        Opp.StageName = '2-Opportunity';
        Database.Insert(Opp);
        
        ocr.OpportunityId = opp.id;
        ocr.ContactId = ctc.id;
        ocr.Role = 'Approver';       
        
        oqm.Name = opp.Name;
        oqm.OpportunityName__c = opp.id;
        
        database.insert(oqm);
        database.insert(ocr);
        return opp;
      }     

}