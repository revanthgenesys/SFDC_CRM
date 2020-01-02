@isTest 
public class Test_CaseSLTHandler {

	static Contact testContact;
	static Case cscld;
	static Case csprm;
	static Case cspinc;
	static Account testAccount;
	static RecordType rectpPrm;
	static RecordType rectpCld;
	static RecordType rectpInc;
	static Service_Level_Target__c srvTrgDflt;
	static Service_Level_Target__c srvTrgCld;
	static Cloud_Deployment__c depl;
	static Back_Office_Account__c boa;
	
	static void setUpdata() {
	
		Util.Bypass_Trigger_Chk = true;
 
    	testAccount = TestUtil.createAccounts(1, true)[0];
    	testAccount.Status__c = 'Active';
    	testAccount.SAP_Account_Code__c ='111';
    	update testAccount;
    	testContact = TestUtil.createContacts(1, testAccount, true)[0];
   
        depl = new Cloud_Deployment__c();
		depl.Support_Status__c = 'Active';
	   	depl.Account__c = testAccount.id;
	   	depl.Sold_To_Account__c = testAccount.id;
	   	depl.Cloud_Platform__c = 'Premier Edition';
	   	depl.Care_Level__c = 'Care for Cloud';
        insert depl; 
        
        boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    boa.Support_Package__c = 'Managed Services';
	    boa.Contract_Status__c = 'Active';
	    insert boa;     
    	
        rectpCld = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Service_Request'][0];
        rectpPrm = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'][0];
        rectpInc = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Incident'][0];
        
        srvTrgDflt = new Service_Level_Target__c (             
              Response_Production_Down__c=1, Response_Medium__c=2, 
              Response_Low__c=3,Response_High__c=4, Response_Critical__c=5, 
              Resolution_Production_Down__c=6, Resolution_Medium__c=7,Resolution_Low__c=8, 
              Resolution_High__c=9, Resolution_Critical__c=10, SLT_Level__c ='Custom', Contract_Type__c='PPU', 
              Sold_To__c = testAccount.Id, End_User__c = testAccount.Id);
       insert srvTrgDflt;
       
       RecordType sltCld = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Service_Level_Target__c' AND DeveloperName = 'SLT_Cloud_Master_Definition'][0]; 
       srvTrgCld = new Service_Level_Target__c ( RecordTypeId = sltCld.Id, Cloud_Support_Package__c = 'Care for Cloud',         
              Response_Medium__c=2, Response_Low__c=3,Response_High__c=4, Response_Critical__c=5, 
              Resolution_Medium__c=7, Resolution_Low__c=8, Resolution_High__c=9, Resolution_Critical__c=10,
              Restoration_Medium__c=7, Restoration_Low__c=8, Restoration_High__c=9, Restoration_Critical__c=10 );
        insert srvTrgCld;
        
       RecordType sltPremPE = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Service_Level_Target__c' AND DeveloperName = 'SLT_BOA_Definition'][0]; 
       Service_Level_Target__c srvTrgPE = new Service_Level_Target__c ( RecordTypeId = sltPremPE.Id, BOA_Support_Package__c = 'Managed Services',     
              Response_Medium__c=2, Response_Low__c=3,Response_High__c=4, Response_Critical__c=5, 
              Resolution_Medium__c=7, Resolution_Low__c=8, Resolution_High__c=9, Resolution_Critical__c=10,
              Restoration_Medium__c=7, Restoration_Low__c=8, Restoration_High__c=9, Restoration_Critical__c=10 );
        insert srvTrgPE;
        
        Util.Bypass_Trigger_Chk = false;
    
	}
	    
    public static testmethod void testPremSLTargetsIns() {       
        setUpdata();        
        List<Case> csLst = new List<Case>();
               
        Case cs = new Case(status='Open',subject='test', priority = 'Prod Down',
                            recordtypeid = rectpPrm.id, Back_Office_Account__c = boa.id,
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs);
        Case cs1 = new Case(status='Open',subject='test', priority = '1-Critical',
                            recordtypeid = rectpPrm.id, Back_Office_Account__c = boa.id,
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs1);
        Case cs2 = new Case(status='Open',subject='test', priority = '2-High',
                           recordtypeid = rectpPrm.id, Back_Office_Account__c = boa.id,
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs2);     
        Case cs3 = new Case(status='Open',subject='test', priority = '3-Medium',
                            recordtypeid = rectpPrm.id, Back_Office_Account__c = boa.id,
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs3);      
        Case cs4 = new Case(status='Open',subject='test', priority = '4-Low',
                            recordtypeid = rectpPrm.id, Back_Office_Account__c = boa.id,
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs4);           
        insert csLst;
        
        System.Test.startTest();
        CaseSLTHandler.updateCaseSLTFields(null, csLst, true); 
        
        System.Test.stopTest();     
    }   

    public static testmethod void testPremSLTargetsUpd() {       
        setUpdata();       
        
       System.Test.startTest();        
      
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
                            recordtypeid = rectpPrm.id, 
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs2);     
        Case cs3 = new Case(status='Open',subject='test', priority = '3-Medium',
                            recordtypeid = rectpPrm.id, 
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs3);      
        Case cs4 = new Case(status='Open',subject='test', priority = '4-Low',
                            recordtypeid = rectpPrm.id, 
                            Sold_To_Account__c = testAccount.Id,
                            End_User_Account__c = testAccount.Id); 
        csLst.add(cs4);           
        insert csLst;
        
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
        
        System.Test.stopTest();           
    } 
    
    public static testmethod void testCldSLTargetsIns() {       
        setUpdata();        
        List<Case> csLst = new List<Case>();
 
        Case cs1 = new Case(status='Open',subject='test', priority = '1-Critical',
                            recordtypeid = rectpCld.id, 
                            Cloud_Deployment__c = depl.Id);                          
        csLst.add(cs1);
        Case cs2 = new Case(status='Open',subject='test', priority = '2-High',
                           recordtypeid = rectpCld.id, 
                            Cloud_Deployment__c = depl.Id);          
        csLst.add(cs2);     
        Case cs3 = new Case(status='Open',subject='test', priority = '3-Medium',
                           recordtypeid = rectpCld.id, Last_SLT_RespAffecting_Update__c = System.now(),
                            Cloud_Deployment__c = depl.Id);          
        csLst.add(cs3);      
        Case cs4 = new Case(status='Open',subject='test', priority = '4-Low',
                            recordtypeid = rectpCld.id, 
                            Cloud_Deployment__c = depl.Id);          
        csLst.add(cs4);           
        insert csLst;
        
        System.Test.startTest();
        CaseSLTHandler.updateCaseSLTFields(null, csLst, true); 
 
        System.Test.stopTest();     
    }    
    
    public static testmethod void testCldSLTargetsUpd() {       
        setUpdata();       
        List<Case> csLst = new List<Case>();              
        Case cs1 = new Case(status='Open',subject='test', priority = '1-Critical',
                            recordtypeid = rectpCld.id, 
                            Cloud_Deployment__c = depl.Id);                          
        csLst.add(cs1);
        Case cs2 = new Case(status='Open',subject='test', priority = '2-High',
                           recordtypeid = rectpCld.id, 
                            Cloud_Deployment__c = depl.Id);          
        csLst.add(cs2);     
        Case cs3 = new Case(status='Open',subject='test', priority = '3-Medium',
                           recordtypeid = rectpCld.id, 
                            Cloud_Deployment__c = depl.Id);          
        csLst.add(cs3);      
        Case cs4 = new Case(status='Open',subject='test', priority = '4-Low',
                            recordtypeid = rectpCld.id, 
                            Cloud_Deployment__c = depl.Id);          
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
        csLst[3].Priority = '4-Low';
         
        update csLst;  
        
        csLst[0].recordtypeid = rectpInc.id;
        csLst[3].Priority = '4-Low';     
        update csLst; 
        
        System.Test.stopTest();           
    }
    
   public static testmethod void testIncSLTargetsIns() {       
        setUpdata();        
        List<Case> csLst = new List<Case>();
 
        Case cs1 = new Case(status='Open',subject='test', priority = '1-Critical',
                            recordtypeid = rectpInc.id, 
                            Cloud_Deployment__c = depl.Id);                          
        csLst.add(cs1);
        Case cs2 = new Case(status='Open',subject='test', priority = '2-High',
                            recordtypeid = rectpInc.id, Last_SLT_RespAffecting_Update__c = System.now(),
                            Cloud_Deployment__c = depl.Id);          
        csLst.add(cs2);     
        Case cs3 = new Case(status='Open',subject='test', priority = '3-Medium',
                           recordtypeid = rectpInc.id, 
                            Cloud_Deployment__c = depl.Id);          
        csLst.add(cs3);      
        Case cs4 = new Case(status='Open',subject='test', priority = '4-Low',
                            recordtypeid = rectpInc.id, Last_SLT_RespAffecting_Update__c = System.now(),
                            Cloud_Deployment__c = depl.Id);          
        csLst.add(cs4);           
        insert csLst;
        
        System.Test.startTest();
        CaseSLTHandler.updateCaseSLTFields(null, csLst, true); 
    
        delete cs4;
        
        System.Test.stopTest();     
    } 
}