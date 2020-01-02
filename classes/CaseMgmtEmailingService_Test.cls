@isTest
public class CaseMgmtEmailingService_Test {
	
   public static EmailTemplate et;
   public static Account acct;
   public static Case trigCase;
   public static List<Contact> testContacts;
   public static Map<String, Id> caseSubRecTypes = new  Map<String, Id>();
   public static Map<String, Id> cldSubRecTypes = new  Map<String, Id>();
   public static Map<String, Id> boaSubRecTypes = new  Map<String, Id>();
	
   public static void setupdata() {		
		et = new EmailTemplate();  
		et.isActive = true;  
		et.Name = 'testTemplate';  
		et.DeveloperName = 'testTemplate' + System.now().getTime();  
		et.TemplateType = 'text';  
		et.FolderId = UserInfo.getUserId();  
		et.Body = ''; 		
		insert et;  
		
		acct = TestUtil.createAccounts(1, true)[0];	   
	    testContacts = TestUtil.createContacts(1, acct, true);  
	     testContacts[0].Alternate_Email__c = 'tst@tst.com';
	    update  testContacts[0];
	                		
		for(RecordType tp : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case_Email_Subscription__c'])
		    caseSubRecTypes.put(tp.DeveloperName, tp.Id);
				
		for(RecordType tp : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case_Email_Subscription_CD__c'])
		    cldSubRecTypes.put(tp.DeveloperName, tp.Id);
		    
		for(RecordType tp : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case_Email_Subscription_BOA__c'])
		    boaSubRecTypes.put(tp.DeveloperName, tp.Id);
		
	}
		
	static testMethod void emtst1() {
		
		User runasuser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (runasuser) {
        	Util.Bypass_Trigger_Chk = true; 
		
			setupdata(); 
	 
	        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
	        	                
	        Case cs = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
	                           recordtypeid = rectp[0].id);                        
	        insert cs;
	       
            
	        Case_Email_Subscription__c cssub1 = new Case_Email_Subscription__c( Case__c = cs.Id, Subscription_Type__c='Internal', 
	                                          Genesys_Employee__c = UserInfo.getUserId(), RecordTypeId = caseSubRecTypes.get('Genesys_Employee') );
	        insert cssub1;
	        
	        Case_Email_Subscription__c cssub2 = new Case_Email_Subscription__c( Case__c = cs.Id, Subscription_Type__c='External', 
	                                        Customer_Contact__c = testContacts[0].Id, RecordTypeId = caseSubRecTypes.get('Customer_Contact') );
	        insert cssub2;
	       
	        Case_Email_Subscription__c cssub3 = new Case_Email_Subscription__c( Case__c = cs.Id, Subscription_Type__c='External', 
	                                        Additional_Email_Addr__c = 'ts@tst.com', RecordTypeId = caseSubRecTypes.get('Additional_Email_Addr') );
	        insert cssub3;
			
			CaseMgmtEmailingService.EmailRequest req = new CaseMgmtEmailingService.EmailRequest();		
			req.sourceId = cs.Id;
			req.sourceObject = 'Case';
			req.templateName = et.DeveloperName;
			req.sendToContact = true;
			req.sendToOwner = false;
			
			Test.startTest();
			CaseMgmtEmailingService.emailNotificationRequest(new List<CaseMgmtEmailingService.EmailRequest>{req});
			Test.stopTest();
		
        }
	}
	
	static testMethod void emtstCD() {
		
		User runasuser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (runasuser) {
        	Util.Bypass_Trigger_Chk = true; 
		
			setupdata();
					
	        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Incident'];
	        
	        Cloud_Deployment__c depl = new Cloud_Deployment__c();
			depl.Support_Status__c = 'Active';
		   	depl.Cloud_Platform__c = 'Premier Edition';
		   	depl.Account__c = acct.id;
		   	depl.Sold_To_Account__c = acct.id;
		   	depl.Care_Level__c = 'Care for Cloud';
	        insert depl;   
	           
	        Case cs = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
	                           Cloud_Deployment__c = depl.Id, recordtypeid = rectp[0].id);                        
	        insert cs;
	       
            
	        Case_Email_Subscription_CD__c cssub1 = new Case_Email_Subscription_CD__c( Cloud_Deployment__c = depl.Id, Subscription_Type__c='Internal', 
	                                          Genesys_Employee__c = UserInfo.getUserId(), RecordTypeId = cldSubRecTypes.get('Genesys_Employee') );
	        insert cssub1;
	        
	        Case_Email_Subscription_CD__c cssub2 = new Case_Email_Subscription_CD__c( Cloud_Deployment__c = depl.Id, Subscription_Type__c='External', 
	                                        Customer_Contact__c = testContacts[0].Id, RecordTypeId = cldSubRecTypes.get('Customer_Contact') );
	        insert cssub2;
	       
	        Case_Email_Subscription_CD__c cssub3 = new Case_Email_Subscription_CD__c( Cloud_Deployment__c = depl.Id, Subscription_Type__c='External', 
	                                         	Additional_Email_Addr__c = 'ts@tst.com', RecordTypeId = cldSubRecTypes.get('Additional_Email_Addr') );
	        insert cssub3;
			
			CaseMgmtEmailingService.EmailRequest req = new CaseMgmtEmailingService.EmailRequest();		
			req.sourceId = cs.Id;
			req.sourceObject = 'Case';
			req.templateName = et.DeveloperName;
			req.sendToContact = true;
			req.sendToOwner = false;
			
			Test.startTest();
			CaseMgmtEmailingService.emailNotificationRequest(new List<CaseMgmtEmailingService.EmailRequest>{req});
			Test.stopTest();
		
        }
	}
	
	static testMethod void emtstBOA() {
		
		User runasuser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (runasuser) {
        	Util.Bypass_Trigger_Chk = true; 
		
			setupdata();
					
	        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];

	        Back_Office_Account__c boa = new Back_Office_Account__c();
			boa.Sold_To_Account__c = acct.Id;
			boa.End_User_Account__c = acct.Id;
			insert boa;
	            
	        Case cs = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
	                           Back_Office_Account__c= boa.Id, recordtypeid = rectp[0].id);                        
	        insert cs;
	       
            
	        Case_Email_Subscription_BOA__c cssub1 = new  Case_Email_Subscription_BOA__c( Back_Office_Account__c= boa.Id, Subscription_Type__c='Internal', 
	                                          Genesys_Employee__c = UserInfo.getUserId(), RecordTypeId = boaSubRecTypes.get('Genesys_Employee') );
	        insert cssub1;
	        
	         Case_Email_Subscription_BOA__c cssub2 = new  Case_Email_Subscription_BOA__c( Back_Office_Account__c= boa.Id, Subscription_Type__c='External', 
	                                        Customer_Contact__c = testContacts[0].Id, RecordTypeId = boaSubRecTypes.get('Customer_Contact') );
	        insert cssub2;
	       
	         Case_Email_Subscription_BOA__c cssub3 = new  Case_Email_Subscription_BOA__c( Back_Office_Account__c= boa.Id, Subscription_Type__c='External', 
	                                         	Additional_Email_Addr__c = 'ts@tst.com', RecordTypeId = boaSubRecTypes.get('Additional_Email_Addr') );
	        insert cssub3;
			
			CaseMgmtEmailingService.EmailRequest req = new CaseMgmtEmailingService.EmailRequest();		
			req.sourceId = cs.Id;
			req.sourceObject = 'Case';
			req.templateName = et.DeveloperName;
			req.sendToContact = true;
			req.sendToOwner = false;
			
			Test.startTest();
			CaseMgmtEmailingService.emailNotificationRequest(new List<CaseMgmtEmailingService.EmailRequest>{req});
			Test.stopTest();
		
        }
	}
	
	static testMethod void emtstPost() {
		User runasuser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs (runasuser) {
        	Util.Bypass_Trigger_Chk = true; 
        	
        	setupdata();
        	
            List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
         
            Case cs = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
	                           recordtypeid = rectp[0].id);                        
	        insert cs;

	        FeedItem fdi = new FeedItem();
		      fdi.Body = 'caseupdate';
		      fdi.ParentId = cs.Id;
		      fdi.Visibility = 'AllUsers';
		      fdi.Title = 'Update from Customer';
		      insert fdi;
		    
		    CaseMgmtEmailingService.EmailRequest req = new CaseMgmtEmailingService.EmailRequest();		
			req.sourceId = fdi.Id;
			req.sourceObject = 'FeedItemLog';
			req.templateName = et.DeveloperName;
			req.sendToContact = false;
			req.sendToOwner = true;

		    Test.startTest();
		 		CaseMgmtEmailingService.getCaseIdByFeedPostId(fdi.Id);
		 		CaseMgmtEmailingService.emailNotificationRequest(new List<CaseMgmtEmailingService.EmailRequest>{req});
			Test.stopTest();  
		      		
		}
		
	}
	
	static testMethod void testTrigger_EmailMessageToCase() {
		
     User runasuser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (runasuser) {
        	
		Util.Bypass_Trigger_Chk = true; 
		setupdata();
		
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
         
        trigCase = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
	                           recordtypeid = rectp[0].id);                        
	    insert trigCase;
		
        }
        
		Util.Bypass_Trigger_Chk = false;
		EmailMessage em = new EmailMessage (Incoming = true, ParentId = trigCase.Id, FromAddress = 'tst@tst.com', TextBody='body');
		insert em;
		
        
	}
    
}