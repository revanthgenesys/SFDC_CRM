/************************************************************************************
Purpose : Unit test class for UpdateLegalException
Written By : Rony Joseph
Test Classes : N/A
*************************************************************************************/
@isTest(seealldata=true)
public class UpdateLegalExeptionTest {
    @isTest
    public static void TestMethod1(){
                    
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        /*List<Contact> list_NewContacts = TestDataFactoryForQuoteTool.createContacts(list_NewAccts[0].id, 1);
        System.assertEquals(list_NewContacts.size(), 1);*/
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        GCR__c objGCR = new GCR__c();
        //objGCR.Contact__c =  list_NewContacts[0].Id;
        objGCR.Account__c =list_NewAccts[0].Id;
        objGCR.Request_Type__c = 'Sales';
        //objGCR.Contact_Name__c = list_NewContacts[0].Name;
        //objGCR.Contact_Phone__c = list_NewContacts[0].ContactPhone__c;
        objGCR.Requestor_Name__c = UserInfo.getUserId();
        objGCR.Attorney_Name__c = UserInfo.getUserId();
        objGCR.Status__c = '1-New';
        objGCR.Offering_type__c = 'PureCloud'; 
        objGCR.Opportunity__c = list_NewOpps[0].Id;
        insert  objGCR;
        Subscription__c sc = new Subscription__c();
		sc.Account__c = list_NewAccts[0].id;
        sc.Opportunity_LookUp__c = list_NewOpps[0].id;
        sc.Subscription_End_Date__c = date.today() +10;
        sc.Subscription_Start_Date__c = date.today();
        insert sc; 
        GCR_Content_Document_Folder__c objGCRFolder = new GCR_Content_Document_Folder__c();
        objGCRFolder.Name = objGCR.Name;
        objGCRFolder.Account__c = objGCR.Account__c;
        objGCRFolder.GCR__c = objGCR.id;
        objGCRFolder.Active__c = true;
        insert objGCRFolder;
        GCR_Content_Document_Detail__c  objGCRDocDetail = new GCR_Content_Document_Detail__c();
        objGCRDocDetail.Folder__c = objGCRFolder.id;
        objGCRDocDetail.Account_Name__c = objGCR.Account__c;
        objGCRDocDetail.GCR__c = objGCR.id;
        objGCRDocDetail.Document_Name__c = objGCR.Name;
        objGCRDocDetail.Legal_Exceptions__c = 'Background Checks;';
        objGCRDocDetail.Contract_Type__c = 'Adoption Agreement';
        objGCRDocDetail.Active__c = true;
        insert objGCRDocDetail;
        Test.startTest();
        objGCR.Status__c = '10-Completed';
        update  objGCR;   
        Test.stopTest();

    }   
    public static void testMethod2()
    {
        
    }

}