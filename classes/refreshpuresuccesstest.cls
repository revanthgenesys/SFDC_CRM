@isTest
public class refreshpuresuccesstest {
    public static void testdata()
    {
    	Account testaccount = new Account(Name='Test Account',status__c = 'Active');
         insert testaccount;
        
            Pure_Success_Package__c p = new Pure_Success_Package__c();
            p.Account__c=testaccount.id;
            p.refresh_date__c=System.today();
        	p.Package_Type__c='Pure Success';
            insert p;
           Pure_Success_Package__c p2 = new Pure_Success_Package__c();
            p2.Account__c=testaccount.id;
            p2.Refresh_date__c=null;
        	p2.Package_Type__c='A la Carte';
            insert p2;
Pure_Success_Package__c p1 = new Pure_Success_Package__c();
            p1.Account__c=testaccount.id;
            p1.Refresh_date__c=System.today();
        	p1.Package_Type__c='A la Carte';
            insert p1;
        Package_Services__c ps = new Package_Services__c();
        ps.PureSuccess_Package__c = p.id;
        ps.Status__c ='Allocated';
        insert ps;
        Package_Services__c ps2 = new Package_Services__c();
        ps2.PureSuccess_Package__c = p1.id;
        ps2.Status__c ='Allocated';
        insert ps2;    
    }
    static testMethod void testMethod1() 
    {
        testdata();
        Test.startTest();
       
        
            refreshpuresuccessbatch obj = new refreshpuresuccessbatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    static testMethod void testMethod2() 
    {
        testdata();
        
        Test.startTest();
        refreshpuresuccessbatch obj1 = new refreshpuresuccessbatch();
            DataBase.executeBatch(obj1);
        Test.stopTest();
        
    }
}