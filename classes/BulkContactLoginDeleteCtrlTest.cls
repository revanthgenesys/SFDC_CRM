//Test class for BulkContactLoginDeleteCtrl created by Mukunth on 06-May-2019
@isTest(seeAllData=false)
public class BulkContactLoginDeleteCtrlTest{
    static testmethod void testBulkContactLoginDelete(){
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
        
        Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
        insert a1;
        
        Contact testContact = new Contact (AccountId = a1.id,FirstName='TestContact',LastName = 'Foss',Designated_Partner_Contact__c = true,Has_LDAP_Login__c = true);
        insert testContact;
        
        PageReference testPage = Page.BulkContactLoginDelete;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('acctId',a1.Id);
        BulkContactLoginDeleteCtrl testBulkDelete = new BulkContactLoginDeleteCtrl();
        testBulkDelete.deleteConList[0].selected = true;
        testBulkDelete.procSelectedContacts();
        testBulkDelete.selectAll = true;
        testBulkDelete.selectAllContactsAndProc();
        testBulkDelete.cancelProc();
        
    }
}