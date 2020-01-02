@isTest(seeAllData=true)
public class LMSLicenseViewControllerTest {
    @isTest
    static void testLMSLicenseViewController1(){
    	Test.startTest();
    	License_Request_Log__c requestLog = [SELECT id, End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Product_Line__r.Name = 'CIC 3.0' LIMIT 1];
    	PageReference pageRef = Page.LMSLicenseView;
        pageRef.getParameters().put('id', requestLog.id);
        Test.setCurrentPage(pageRef);
        LMSLicenseViewController controller = new LMSLicenseViewController();
    	Test.stopTest();
    }
    
    @isTest
    static void testLMSLicenseViewController2(){
    	Test.startTest();
    	License_Request_Log__c requestLog = [SELECT id, End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Product_Line__r.Name = 'CIC 4.0' LIMIT 1];
    	PageReference pageRef = Page.LMSLicenseView;
        pageRef.getParameters().put('id', requestLog.id);
        Test.setCurrentPage(pageRef);
        LMSLicenseViewController controller = new LMSLicenseViewController();
    	Test.stopTest();
    }
    
    @isTest
    static void testLMSLicenseViewController3(){
    	Test.startTest();
    	License_Request_Log__c requestLog = [SELECT id, End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Product_Line__r.Name = 'SIP Proxy 4.0' LIMIT 1];
    	PageReference pageRef = Page.LMSLicenseView;
        pageRef.getParameters().put('id', requestLog.id);
        Test.setCurrentPage(pageRef);
        LMSLicenseViewController controller = new LMSLicenseViewController();
    	Test.stopTest();
    }
    
    @isTest
    static void testLMSLicenseViewController4(){
    	Test.startTest();
    	License_Request_Log__c requestLog = [SELECT id, End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Product_Line__r.Name = 'Interaction Media Server 3.0' LIMIT 1];
    	PageReference pageRef = Page.LMSLicenseView;
        pageRef.getParameters().put('id', requestLog.id);
        Test.setCurrentPage(pageRef);
        LMSLicenseViewController controller = new LMSLicenseViewController();
    	Test.stopTest();
    }
}