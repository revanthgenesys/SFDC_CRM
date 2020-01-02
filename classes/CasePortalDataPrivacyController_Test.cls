@isTest
public class CasePortalDataPrivacyController_Test {
	
	 public static testMethod void tst() {             
            string recordTypeId;
            string contId;
            String stId;
            String euId;            
            
            List<RecordType> premType  = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Premises_Service_Request'];  
            List<RecordType> cldType  = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Service_Request'];  
            
            Case testCase = new Case(); 
           
            
            PageReference pageRef = Page.CasePortalDataPrivacy;
            String caseType = premType[0].developername; 
       //     pageRef.getParameters().put('RecordType' ,premType[0].id);  
            Account testAccount = TestUtil.createAccounts(1, true)[0];
            Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
            
            Test.StartTest();
          
            Apexpages.currentPage().getParameters().put('contId',testContact.id);
            Apexpages.currentPage().getParameters().put('stId',testAccount.id);
            Apexpages.currentPage().getParameters().put('euId',testAccount.id);
            Apexpages.currentPage().getParameters().put('fltr','eng');
            Apexpages.currentPage().getParameters().put('RecordType', premType[0].id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testCase);  
            CasePortalDataPrivacyController cntr1 = new CasePortalDataPrivacyController(sc);   
            
            cntr1.initCloudCase();
            cntr1.reqDetail = 'Right of access';
            cntr1.comments = 'comments';
            cntr1.initPremCase(); 
            cntr1.saveCase();  
            
            Apexpages.currentPage().getParameters().put('fltr','cnct');
            Apexpages.currentPage().getParameters().put('RecordType', cldType[0].id);
            CasePortalDataPrivacyController cntr2 = new CasePortalDataPrivacyController(sc);  
            cntr1.reqDetail = 'Right of access';
            cntr1.comments = 'comments'; 
            cntr2.initCloudCase(); 
            cntr2.saveCase();  
                          
            Test.stopTest();    
	 }
    
}