@isTest
public class clsVirtualUsers_Test {
    static testmethod void test1()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;
         
            Test.startTest();
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
            objTestOppty.CloseDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'BRL';
            objTestOppty.Previous_Maintenance_Rate__c = 0;
            objTestOppty.BusinessPartner__c = objTestAccount.Id;
            objTestOppty.Gene_Care_Specialist__c = UserInfo.getUserId();
            
            insert objTestOppty;
            
            DSR_SCEngagement__c objSCE = new DSR_SCEngagement__c();
            objSCE.Account_ID__c = objTestAccount.id;
            objSCE.Opportunity_ID__c = objTestOppty.id;
            objSCE.SC_Engagement_Status__c = 'Open and Not Assigned';
            objSCE.Design_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Design_End_Date__c = Date.Today().addDays(10);
            
            insert objSCE;
            
            clsVirtualUsers objCLS = new clsVirtualUsers();
            objCLS.strDSRID = objSCE.id; 
            List<DSR_Virtual_Team__c> vt = objCLS.list_VT;
            
            Test.stopTest();
        }
        catch(CalloutException ex)
        {}
    }
    
}