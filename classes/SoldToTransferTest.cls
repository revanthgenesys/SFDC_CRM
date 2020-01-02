@isTest(seeAllData=True)
public class SoldToTransferTest {
 	@isTest
    static void soldTotransferToolTest(){
    	PageReference pageRef = Page.SoldToTransferTool;
        Test.setCurrentPageReference(pageRef);
        
        SoldToTransferToolController ttController = new SoldToTransferToolController();
        
        List<ServiceContract> scList = [SELECT Id, Name, AccountId, Account.Name FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation', 'Pending') LIMIT 1];
        
        ttController.accountSelection.AccountId = scList[0].AccountId;
        ttController.goClicked();
        
        ttController.selectAll = true;
        ttController.selectAllServiceContracts();
        ttController.serviceContractSelectionChanged();
        ttController.proceed();
        
        ttController.targetSoldTo.AccountId = scList[0].AccountId;
        ttController.doTransfer();
        ttController.cancel();
        
        // Test Util Class
        //SoldToTransferToolUtil.;
        Sold_To_Transfer_Request_Header__c soldToTransferHeader = [SELECT Id, Status__c FROM Sold_To_Transfer_Request_Header__c LIMIT 1];
        //SoldToTransferToolUtil.performTransfer(soldToTransferHeader.Id);
        soldToTransferHeader.Status__c = 'Submitted';
        Update soldToTransferHeader;
        
        soldToTransferHeader.Status__c = 'Approved';
        Update soldToTransferHeader;
    }   
    
    @isTest
    static void soldTotransferToolAttachmentsTest(){
    	List<ServiceContract> scList = [SELECT Id, Name, AccountId, Account.Name FROM ServiceContract WHERE Agreement_Status__c IN ('Active', 'In Negotiation', 'Pending') LIMIT 1];
    	Sold_To_Transfer_Request_Header__c soldToTransferHeader = new Sold_To_Transfer_Request_Header__c(Account__c = scList[0].AccountId,
    																									Status__c = 'New',
    																									Regional_Controller__c = UserInfo.getUserId(),
    																									Target_Sold_To__c = scList[0].AccountId);
    	insert soldToTransferHeader;
    	 // Insert Attachment for 
        Attachment attachment1 = new Attachment();
        attachment1.body = Blob.valueOf('This is an Attachment Test ...');
        attachment1.name = 'fake-attachment';
        attachment1.parentId = soldToTransferHeader.id;
        insert attachment1;
        
        
        Transfer_Tool_Approval__c transferToolRequest = new Transfer_Tool_Approval__c(Account__c = scList[0].AccountId,
    																									Status__c = 'New',
    																									Regional_Controller__c = UserInfo.getUserId(),
    																									Service_Contract__c = scList[0].Id);	
    																									
    	insert transferToolRequest;
    	// Insert Attachment for 
        Attachment attachment2 = new Attachment();
        attachment2.body = Blob.valueOf('This is an Attachment Test ...');
        attachment2.name = 'fake-attachment';
        attachment2.parentId = transferToolRequest.id;
        insert attachment2;		
        
    }
    
}