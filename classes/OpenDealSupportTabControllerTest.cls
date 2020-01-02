@isTest
public class OpenDealSupportTabControllerTest {

    @isTest
    public static void test1(){
		List <Deal_Support__c> lstdealsup = new List<Deal_Support__c>();
 
 Deal_Support__c testds = new Deal_Support__c();
testds.Request_Type__c='On Premise Pricing';
        testds.Subject__c='Test';
            testds.Description__c='Test';
 lstdealsup.add(testds);
 Deal_Support__c testds1 = new Deal_Support__c();
 testds1.Request_Type__c='On Premise Pricing';
            testds1.Subject__c='Test';
            testds1.Description__c='Test';
 lstdealsup.add(testds1);

 insert  lstdealsup;
 
 	Apexpages.StandardSetController sc = new Apexpages.StandardSetController(lstdealsup);

        OpenDealSupportTabController pp=new OpenDealSupportTabController(sc);
          
     pp.getrecentDS(); 
        
    }
}