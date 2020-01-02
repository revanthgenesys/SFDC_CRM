@isTest
public class refreshtokentest {
    public static void testtoken()
    {
    	Account t = new Account(Name='Test Account',status__c = 'Active');
         insert t;
      
         Token_Allocations__c p = new Token_Allocations__c();
           p.Account__c=t.id;
         p.refresh_date__c=System.today();
           insert p;
         Token_Allocations__c p1 = new Token_Allocations__c(); 
           p1.Account__c=t.id;
           p1.Order__c='a0h22000001QMfN';
         p1.Allocation_Type__c= 'Subscription Token'; 
           p1.refresh_date__c=System.today();
           insert p1;        
    }
    static testMethod void testMethod1() 
    {
        testtoken();
        Test.startTest();

            refreshtokenbatch obj = new refreshtokenbatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    

}