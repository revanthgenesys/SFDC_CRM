//Test class for BulkContactCreationCtrl created by Mukunth on 06-May-2019
@isTest(seeAllData=false)
public class BulkContactCreationCtrlTest{
    static testmethod void testBulkContactCreationCtrl(){
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
        
        Account a1 = new Account (Name = 'Holding Account1', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
        insert a1;
        
        Contact testContact = new Contact (AccountId = a1.id,FirstName='TestContact1',LastName = 'Foss1',email='test123@test.com',Designated_Partner_Contact__c = true,Has_LDAP_Login__c = false,Has_Requested_LDAP_Change__c=false);
        insert testContact;
        
        PageReference testPage = Page.BulkContactCreation;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('acctId',a1.Id);
        BulkContactCreationCtrl bulkConCreation = new BulkContactCreationCtrl();
        bulkConCreation.lstConWrap[0].selected = true;
        bulkConCreation.procSelectedContacts();
        bulkConCreation.selectAll = true;
        bulkConCreation.selectAllContactsAndProc();
        bulkConCreation.cancelProc();
        
    }
}