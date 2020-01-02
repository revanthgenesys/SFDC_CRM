@isTest (SeeAllData = False)
public class CustomSWDLRequestExtensionTest {
    
    static testmethod void extendExpiry(){
        
        Test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        User testUser = TestUtil.createUsers(1, true)[0];
        Support_Product__c supportParentProduct = TestUtil.createSupportProducts(1, true)[0];
        supportParentProduct.Name = 'Solution: N/A - Custom Application';
        
        Support_Product__c supportProduct = TestUtil.createSupportProducts(1, true)[0];
        supportProduct.Name = 'Test Product';
        supportProduct.Product_Type__c = 'Product';
        supportProduct.Parent_Product__c = supportParentProduct.Id;
        update supportProduct;
        
        Operating_System__c OS = new Operating_System__c();
        OS.Name = 'Test OS';
        insert OS;
        
        Custom_SWDL_Request__c objCustomSWDL = new Custom_SWDL_Request__c();
        objCustomSWDL.End_User_Account__c = testAccount.Id;
        objCustomSWDL.Requester__c = testUser.id;
        objCustomSWDL.Sold_To_Account__c = testAccount.Id;
        objCustomSWDL.When_Needed__c = Date.today().addDays(2);
        objCustomSWDL.Status__c = 'New';
        objCustomSWDL.Product__c = supportProduct.id;
        objCustomSWDL.Detailed_Description__c = 'Test Desc';
        objCustomSWDL.Number_of_units_seats__c = '2';
        objCustomSWDL.License_Information__c = 'Test Info';
        objCustomSWDL.Version__c = '1';
        objCustomSWDL.OS__c = OS.id;
        objCustomSWDL.FTP_User__c = 'Test FTP User';
        objCustomSWDL.FTP_Password__c = 'Test FTP Password';
        objCustomSWDL.FTP_Comments__c = 'Test FTP Comments';
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objCustomSWDL);
        CustomSWDLRequestExtension testCustomSWDL = new CustomSWDLRequestExtension(sc);
        
        PageReference pageRef = Page.CustomSWDLRequestLayout;
        Test.setCurrentPage(pageRef);
        
        testCustomSWDL.saveAndNew();
        Test.stopTest();   
    }
}