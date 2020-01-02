@isTest(SeeAllData=true)
public class Attachment_After_Test {

    static testMethod void insertAttachment() {
     
      Test.startTest();
      BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
	  Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
      
      Order__c ord_1 = new Order__c();
      ord_1.Maintenance_Start__c = Date.today();
      ord_1.Maintenance_End__c = Date.today().addYears(1);
      ord_1.Numb_of_Maint_Months__c = 12;
      ord_1.status__c = 'In Progress';
      ord_1.Approved_By_Manager__c = false;
      ord_1.RecordTypeId = '012U0000000M2Tw';
      insert ord_1;
      
      Attachment attach = new Attachment();   	
      attach.Name='Unit Test Attachment';
      Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
      attach.body=bodyBlob;
      attach.parentId=ord_1.id;
      insert attach;

      List<Attachment> attachments=[select id, name from Attachment where parent.id=:ord_1.id];
      System.assertEquals(1, attachments.size());
      Test.stopTest();
    }
}