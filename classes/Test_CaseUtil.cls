@isTest
private class Test_CaseUtil {

    static testmethod void testCaseUtil1() {
      
      Util.Bypass_Trigger_Chk = true;
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
        
        Account acct = TestUtil.createAccounts(1, true)[0];
        acct.Support_Group__c = 'Japan';
        update acct;
        
        Contact[] testContacts = TestUtil.createContacts(1, acct, true);  
     
        Case cs = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
                           recordtypeid = rectp[0].id);                        
        insert cs;
   
        List<User> owner = TestUtil.createUsers(1, true);
        owner[0].Support_Group__c = 'Applications';
        update owner[0];
        cs.OwnerId = owner[0].Id;
        update cs;
     
        Support_Product__c prodLn = new Support_Product__c (name='Cloud', Product_Type__c = 'Product Line' );
        insert prodLn;
        
        Support_Product__c prod = new Support_Product__c (name='Cloud Products', Product_Type__c = 'Product', Parent_Product__c = prodLn.Id);
        insert prod;
        
        List<Case> lst = new List<Case>();
        lst.add(cs);  
        
        cs.Status = 'Closed';
        cs.Closure_Category__c='Closed';
        cs.Closure_Reason_Code__c='Closed';
        update cs;
        
        CaseUtil.getCloudProdLine();
        CaseUtil.getCloudProducts(prodLn);
      
        CaseUtil.isCurrentUserProfileReadOnly();
        CaseUtil.isCaseAccessLevelReadOnly(cs);
        CaseUtil.getCaseAccessLevel(String.valueOf(cs.Id));    
        CaseUtil.canUserAccessThisCase(String.valueOf(cs.Id)); 
        Boolean ro = CaseUtil.isCaseAccessLevelReadOnly(cs); 
        List<Support_Product__c> prd = CaseUtil.getCloudProducts(null);  
        List<RecordType> rt = CaseUtil.getTScaseTypes(); 
        String tl = CaseUtil.casePageTitleByType('');
    }
    

    static testmethod void testCaseUtil2() {
       
       Util.Bypass_Trigger_Chk = true;
 
        Account acct = TestUtil.createAccounts(1, true)[0];
        acct.Support_Group__c = 'EMEA';
        update acct;
        
        Contact[] testContacts = TestUtil.createContacts(1, acct, true);
 
        List<User> owner = TestUtil.createUsers(1, true);
        owner[0].Level_of_Expertise__c = 'Expert';
        update owner[0];
        
        Support_Product__c prodLn = new Support_Product__c (name='Cloud', Product_Type__c = 'Product Line' );
        insert prodLn;
        
        Support_Product__c prod = new Support_Product__c (name='Cloud Products', Product_Type__c = 'Product', Parent_Product__c = prodLn.Id);
        insert prod;
            
      Back_Office_Account__c boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = acct.Id;
	    boa.End_User_Account__c = acct.Id;
	    insert boa;

    Support_Access__c sa = new Support_Access__c(Back_Office_Account__c = boa.Id,
                                                   Contact__c = testContacts[0].Id);
      insert sa;
        
        List<RecordType> rectp = [SELECT Id FROM RecordType WHERE SobjectType = 'Case'AND DeveloperName = 'Genesys_Product_Case'];
        Case cs2 = new Case(status='Awaiting Info',subject='test', priority = '3-Medium',            
                           recordtypeid = rectp[0].id,
                            Do_Not_Auto_Follow_Up__c=false,
                            ContactId = testContacts[0].Id,
                            Support_Access__c = sa.Id,
                            ownerId = owner[0].Id,
                            Sold_To_Account__c = acct.Id,
                            End_User_Account__c = acct.Id,
                            Auto_Follow_up_Start_Date__c = datetime.now());
        insert cs2;
        
       cs2.Status='Engineering Request'; 
       cs2.Priority = '4-Low';
       update cs2;
     
    Util.Bypass_Trigger_Chk = false;  
      
    Test.startTest();     
   /*  
        acct.Support_Group__c = 'Japan';
        update acct;        
        cs2.Priority = '1-Critical';
        update cs2;
        cs2.Priority = '4-Low';
        update cs2;
     */   
        acct.Support_Group__c = 'Latin America';
        update acct;       
        cs2.Priority = '2-High';
        update cs2;
        cs2.Priority = '1-Critical';
        update cs2;
        
        acct.Support_Group__c = 'North America';
        update acct;       
        cs2.Priority = '2-High';
        update cs2;
        cs2.Priority = '1-Critical';
        update cs2;
                  
 
      Test.stopTest();  
       
    }
        
     static testmethod void testCldtype() {
       Util.Bypass_Trigger_Chk = true;
       List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Support_Request'];
        
       Account acct = TestUtil.createAccounts(1, true)[0];
        acct.Support_Group__c = 'APAC';
        update acct;
        
        Contact[] testContacts = TestUtil.createContacts(1, acct, true); 
        
       Cloud_Deployment__c depl = new Cloud_Deployment__c();
		depl.Support_Status__c = 'Active';
	   	depl.Account__c = acct.id;
	   	depl.Sold_To_Account__c = acct.id;
        insert depl;
        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContacts[0].Id, Cloud_Deployment__c = depl.Id, Access_Status__c = 'Active');
        insert sa;
                
        CaseUtil.casePageTitleByType(rectp[0].Id);         
        Case cs = new Case(subject='test', priority = '4-Low',  ContactId = testContacts[0].Id, recordtypeid = rectp[0].id,
                           Sold_To_Account__c = acct.Id,
                           End_User_Account__c = acct.Id);                        
        insert cs;
   
        List<User> owner = TestUtil.createUsers(1, true);
        owner[0].Support_Group__c = 'Applications';
        update owner[0];
        cs.OwnerId = owner[0].Id;
        update cs;
        
     Util.Bypass_Trigger_Chk = false;
     Test.startTest();
       
        CaseUtil.canUserAccessThisCase( cs.Id);
            
        List<Case> lst = new List<Case>();
        lst.add(cs);  

        cs.Status = 'Solution Proposed';
        cs.Priority = 'Prod Down';
        cs.Closure_Reason_Code__c = 'Resolved';
        cs.Highest_Level_of_Service__c = '3 Expert';
        update cs;
        
        acct.Support_Group__c = 'APAC';
        update acct;       
        cs.Priority = '1-Critical';
        update cs;
        cs.Priority = '2-High';
        update cs;
        
        acct.Support_Group__c = 'EMEA';
        update acct;       
        cs.Priority = '4-Low';
        update cs;
        cs.Priority = 'Prod Down';
        update cs;
        
      Test.stopTest();
    }
 
  
   static testmethod void busHours() {
   	  Util.Bypass_Trigger_Chk = true;
 
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	testAccount.Status__c = 'Active';
    	testAccount.SAP_Account_Code__c ='111';
    	update testAccount;
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
   
        Cloud_Deployment__c depl = new Cloud_Deployment__c();
		depl.Support_Status__c = 'Active';
	   	depl.Account__c = testAccount.id;
	   	depl.Sold_To_Account__c = testAccount.id;
	   	depl.Cloud_Platform__c = 'Premier Edition';
	   	depl.Care_Level__c = 'Care for Cloud';
        insert depl;      
   
        RecordType rectpCld = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Service_Request'][0];
        RecordType rectpPrm = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'][0];
        RecordType rectpInc = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Incident'][0];
        RecordType rectpFR = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Feature_Request_Case'][0];

        Util.Bypass_Trigger_Chk = false;
        
        List<Case> csLst = new List<Case>();
 
        Case cs = new Case(status='Open',subject='test', priority = 'Prod Down',
                            recordtypeid = rectpPrm.id, 
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs);
        Case cs1 = new Case(status='Open',subject='test', priority = '1-Critical',
                            recordtypeid = rectpPrm.id, 
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs1);
        Case cs2 = new Case(status='Open',subject='test', priority = '2-High',
                           recordtypeid = rectpCld.id, 
                           Cloud_Deployment__c = depl.Id,
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs2);     
        Case cs3 = new Case(status='Open',subject='test', priority = '3-Medium',
                            recordtypeid = rectpPrm.id, 
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs3);      
        Case cs4 = new Case(status='Open',subject='test', priority = '4-Low',
                            recordtypeid = rectpInc.id, 
                            Cloud_Deployment__c = depl.Id,
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs4);           
        insert csLst;
       
        System.Test.startTest();
  
        csLst[0].Status = 'Awaiting Info';
        csLst[0].Priority = '4-Low';
    
        csLst[1].Priority = '3-Medium';
        csLst[1].Status = 'Solution Proposed';
        csLst[1].Closure_Category__c='Closed';
        csLst[1].Closure_Reason_Code__c='Closed';
        
        csLst[2].Priority = '1-Critical';
        
        csLst[3].Status = 'Closed';
        csLst[3].Closure_Category__c='Closed';
        csLst[3].Closure_Reason_Code__c='Closed';
         
        update csLst;   
        
        csLst[2].Priority = '4-Low';
        csLst[2].recordtypeid = rectpCld.id;    
        update csLst;   
        
        csLst[2].Priority = '4-Low';
        csLst[1].Status = 'Open - Customer Care';
        csLst[2].Sub_Status__c = 'Solution Proposed';
        csLst[2].recordtypeid = rectpFR.id;    
        update csLst;   
        
        System.Test.stopTest();     
   	   
   } 
   

}