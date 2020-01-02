//Nik Mills - 27-May-2019
//For code coverage and testing of the chkOpportunityRecursive trigger flow handlers
@isTest
public class chkOpportunityRecursive_Test {

    // test Opportunity recursion handling code
    static testMethod void testBeforeInsert() {
        Boolean retVal;

        Test.startTest();         

        // initial call
        retVal = checkOpportunityRecursive.runBeforeInsertOnce();
        System.AssertEquals(retVal, true);
        
        // secondary call (should now return false)
        retVal = checkOpportunityRecursive.runBeforeInsertOnce();        
        System.AssertEquals(retVal, false);

        Test.stopTest();
    }

    // test Opportunity recursion handling code
    static testMethod void testBeforeUpdate() {
        Boolean retVal;

        Test.startTest();         

        // initial call
        retVal = checkOpportunityRecursive.runBeforeUpdateOnce();
        System.AssertEquals(retVal, true);
        
        // secondary call (should now return false)
        retVal = checkOpportunityRecursive.runBeforeUpdateOnce();        
        System.AssertEquals(retVal, false);

        Test.stopTest();
    }
    
}