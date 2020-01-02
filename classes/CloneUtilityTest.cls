@isTest
private class CloneUtilityTest {
 
    public static testmethod void testgetCreatableFieldsSOQL(){
      	Test.startTest();
        CloneUtility.getCreatableFieldsSOQL('Opportunity','id = \'0060d00001s5nw6\'');
        Test.stopTest();
    }
    
    
}