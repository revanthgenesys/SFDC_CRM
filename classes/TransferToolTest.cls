/*
    Description     : This Test Class covers all the Classes, Triggers, Pages related to Transfer Tool.
                      The following is the list of artifacts covered for tested using this test class. 
    Apex Classes    :   TransferToolController, TransferEntitlementsAttMsgController
    Apex Triggers   :   trgAfterApprovedEntitlement on Transfer_Tool_Approval__c
                        TransferEntitlementsAttachmentTrigger on Attachment
 
*/
@isTest(seeAllData=True)
private class TransferToolTest {

    @isTest
    static void transferToolTestCase(){
        
        List<Products_To_Exclude_In_New_SC__c> productsToExcludeConfig = new List<Products_To_Exclude_In_New_SC__c>();
        
        List<Products_To_Exclude_In_New_SC__c> productsToExclude = Products_To_Exclude_In_New_SC__c.getall().values();
        if(productsToExclude.isEmpty()){
            productsToExcludeConfig.add(new Products_To_Exclude_In_New_SC__c(Name = 'Dummy', ProductName__c = 'Dummy'));
            Insert productsToExcludeConfig;
        }
        
        List<Products_To_Include_In_New_SC__c> productsToIncludeConfig = new List<Products_To_Include_In_New_SC__c>();
        List<Products_To_Include_In_New_SC__c> productsToInclude = Products_To_Include_In_New_SC__c.getall().values();
        if(productsToInclude.isEmpty()){
            productsToIncludeConfig.add(new Products_To_Include_In_New_SC__c(Name = 'Dummy', ProductName__c = 'Dummy'));
            Insert productsToIncludeConfig;
        }        

        List<Entitlement_Transfer__c> etcs = new List<Entitlement_Transfer__c>();
        List<Entitlement_Transfer__c> etcsList = Entitlement_Transfer__c.getall().values();
        if(etcsList.isEmpty()){
            etcs.add(new Entitlement_Transfer__c(Name = UserInfo.getName(), Email__c = UserInfo.getUserEmail()));
            Insert etcs;
        }
        
        List<Regional_Controller_List__c> rccs = new List<Regional_Controller_List__c>();
        List<Regional_Controller_List__c> rccsList = Regional_Controller_List__c.getall().values();
        if(rccsList.isEmpty()){
            rccs.add(new Regional_Controller_List__c(Name = 'APAC', Region__c = 'APAC', Regional_Controller_User__c = UserInfo.getUserName()));
            rccs.add(new Regional_Controller_List__c(Name = 'EMEA', Region__c = 'EMEA', Regional_Controller_User__c = UserInfo.getUserName()));
            rccs.add(new Regional_Controller_List__c(Name = 'LATAM', Region__c = 'LATAM', Regional_Controller_User__c = UserInfo.getUserName()));
            rccs.add(new Regional_Controller_List__c(Name = 'North America', Region__c = 'North America', Regional_Controller_User__c = UserInfo.getUserName()));
            Insert rccs;
        }
        
        //Util.Bypass_Trigger_Chk = true;
        PageReference pageRef = Page.TransferToolPage;
        Test.setCurrentPageReference(pageRef);
        
        TransferToolController ttController = new TransferToolController();
        // Fetch any ContractLineItem which has Active Contract and Current_Quantity__c greater than 5  
        List<ContractLineItem> cLineItem = [SELECT Id, ServiceContractId, ServiceContract.Name, ServiceContract.AccountId, ServiceContract.Account.Name, Service_Contract_Status__c, Current_Quantity__c  FROM ContractLineItem WHERE ServiceContract.Offering_Type__c = 'PureEngage' AND ServiceContract.Service_Contract_Type__c = 'Perpetual' AND Service_Contract_Status__c ='Active' AND Current_Quantity__c > 5 LIMIT 1];
        // Set the Transfer Tool Selected Account
        ttController.transferTool.Account__c = cLineItem[0].ServiceContract.AccountId;
        // Retrieve Service Contracts for Selected Account
        ttController.getServiceContracts();
        // Set the Transfer Tool Selected Service Contract
        ttController.selectServiceContractId = cLineItem[0].ServiceContractId;
        // Retrieve Service Contract Line Items for Selected Service Contract
        ttController.getContractLineItems();
        
        // SELECT Random Custom to Transfer the Licenses To
        List<Account> customerAccounts = [Select Id, Name FROM Account WHERE Account_Status__c = 'Active' AND Type = 'Customer' LIMIT 2];
        
        // Select one Contract Line to be Transferred to Random Customer 
        for(TransferToolController.TransferLineItemsWrapper tliw : ttController.transferCliWrapperList){
            if(tliw.cli.id == cLineItem[0].Id){
                tliw.isSelect  = True;
                tliw.transferQty = 2;
                if(customerAccounts[0].Id != cLineItem[0].ServiceContract.AccountId)
                    tliw.toolForAccTransfer.Transfer_to_ST_EU__c = customerAccounts[0].Id;
                else 
                    tliw.toolForAccTransfer.Transfer_to_ST_EU__c = customerAccounts[1].Id;
            }
        }
        ttController.clickedTransferStr = 'true';
        ttController.displayTransferredRows();
        // Update the quantity 
        for(TransferToolController.TransferLineItemsWrapper tliw : ttController.transferCliWrapperList){
            if(tliw.cli.id == cLineItem[0].Id){
                tliw.isSelect  = True;
                tliw.transferQty = 4;
                if(customerAccounts[0].Id != cLineItem[0].ServiceContract.AccountId)
                    tliw.toolForAccTransfer.Transfer_to_ST_EU__c = customerAccounts[0].Id;
                else 
                    tliw.toolForAccTransfer.Transfer_to_ST_EU__c = customerAccounts[1].Id;
            }
        }
        ttController.clickedTransferStr = 'true';
        ttController.displayTransferredRows();

        // Remove the Item from the List to Transfer
        ttController.removeTransferId = ttController.newTransferToolList[0].Id;
        ttController.removeNonApprovedRows();
        
        // Select one Contract Line to be Transferred to Random Customer 
        for(TransferToolController.TransferLineItemsWrapper tliw : ttController.transferCliWrapperList){
            if(tliw.cli.id == cLineItem[0].Id){
                tliw.isSelect  = True;
                tliw.transferQty = 2;
                if(customerAccounts[0].Id != cLineItem[0].ServiceContract.AccountId)
                    tliw.toolForAccTransfer.Transfer_to_ST_EU__c = customerAccounts[0].Id;
                else 
                    tliw.toolForAccTransfer.Transfer_to_ST_EU__c = customerAccounts[1].Id;
            }
        }
        ttController.clickedTransferStr = 'true';
        ttController.displayTransferredRows();
        
        // Set the Status to Approved on the Transfer Tool Requests         
        List<Transfer_Tool_Approval__c> ttRequests = [SELECT id, Account__c, Service_Contract__c, Status__c FROM Transfer_Tool_Approval__c WHERE Status__c  = 'New'];
        for(Transfer_Tool_Approval__c tta: ttRequests){
            tta.Status__c = 'Submitted';
        }
        update ttRequests;
        
        for(Transfer_Tool_Approval__c tta: ttRequests){
            tta.Status__c = 'Rejected';
        }
        update ttRequests;
        
        ttController.reinstateTransfer();
        
        for(Transfer_Tool_Approval__c tta: ttRequests){
            tta.Status__c = 'Submitted';
        }
        update ttRequests;
        
        for(Transfer_Tool_Approval__c tta: ttRequests){
            tta.Status__c = 'Approved';
        }
        update ttRequests;

        // Dummy calls .... 
        ttController.refreshCurrentPage();
        
        // Test Cases for TransferEntitlementsAttMsgController & TransferEntitlementsAttachmentTrigger on Attachment
        ApexPages.StandardController sc = new ApexPages.StandardController(ttRequests[0]);
        TransferEntitlementsAttMsgController teamc = new TransferEntitlementsAttMsgController(sc);
        PageReference teamcPageRef = Page.TransferToolApprovalAttachmentsMessage;
        Test.setCurrentPage(teamcPageRef);
        
        // Insert Attachment for 
        Attachment attachment = new Attachment();
        attachment.body = Blob.valueOf('This is an Attachment Test ...');
        attachment.name = 'fake-attachment';
        attachment.parentId = ttRequests[0].id;
        insert attachment;
        
    }

    
    @isTest
    static void transferToolTriggersTestCase(){
        List<ContractLineItem> cLineItem = [SELECT Id, ServiceContractId, ServiceContract.Name, ServiceContract.AccountId, ServiceContract.Account.Name, 
                                            PricebookEntry.Product2.Id, Service_Contract_Status__c, Current_Quantity__c  
                                            FROM ContractLineItem 
                                            WHERE 
                                            	ServiceContract.Offering_Type__c = 'PureEngage' AND ServiceContract.Service_Contract_Type__c = 'Perpetual' AND
                                            	Service_Contract_Status__c ='Active' AND Current_Quantity__c > 5 
                                            LIMIT 1];
        
        // SELECT Random Custom to Transfer the Licenses To
        List<Account> customerAccounts = [Select Id, Name FROM Account WHERE Account_Status__c = 'Active' AND Type = 'Customer' LIMIT 2];
        
        Transfer_Tool_Approval__c ttRequest = new Transfer_Tool_Approval__c(Account__c = cLineItem[0].ServiceContract.AccountId, 
                                                                            Service_Contract__c = cLineItem[0].ServiceContractId, 
                                                                            Status__c = 'New', Attachments_Linked__c = true, 
                                                                            Regional_Controller__c = UserInfo.getUserId());  
        insert ttRequest;
        
         Transfer_Tool__c ttRequestLineItem1 = new Transfer_Tool__c(Contract_Line_Item__c = cLineItem[0].Id, 
                                                                  Service_Contract__c = cLineItem[0].ServiceContractId, 
                                                                  Product__c = cLineItem[0].PricebookEntry.Product2.Id, 
                                                                  Transfer_Quantity__c = 2,
                                                                  Transfer_to_ST_EU__c = customerAccounts[0].Id,
                                                                  Transfer_to_Sold_To__c = customerAccounts[1].Id, 
                                                                  Transfer_Status__c = 'New',
                                                                    Transfer_Tool_Approval__c = ttRequest.Id
                                                                 );
        insert ttRequestLineItem1;
        
        Transfer_Tool__c ttRequestLineItem = new Transfer_Tool__c(Contract_Line_Item__c = cLineItem[0].Id, 
                                                                  Service_Contract__c = cLineItem[0].ServiceContractId, 
                                                                  Product__c = cLineItem[0].PricebookEntry.Product2.Id, 
                                                                  Transfer_Quantity__c = 0,
                                                                  Transfer_Status__c = 'New',
                                                                    Transfer_Tool_Approval__c = ttRequest.Id
                                                                 );
        try{
            insert ttRequestLineItem;
        } catch(Exception e){
            // do nothing
        }
        
        ttRequestLineItem.Transfer_Quantity__c = cLineItem[0].Current_Quantity__c + 1;
        try{
            insert ttRequestLineItem;
        } catch(Exception e){
            // do nothing
        }

        ttRequestLineItem.Transfer_Quantity__c = cLineItem[0].Current_Quantity__c + 1;
        try{
            insert ttRequestLineItem;
        } catch(Exception e){
            // do nothing
        }
        
       ttRequestLineItem.Transfer_Quantity__c = 4;
        try{
            insert ttRequestLineItem;
        } catch(Exception e){
            // do nothing
        }

        ttRequestLineItem.Transfer_to_ST_EU__c = customerAccounts[0].Id; 
        try{
            insert ttRequestLineItem;
        } catch(Exception e){
            // do nothing
        }
        
        ttRequestLineItem.Transfer_to_Sold_To__c = customerAccounts[1].Id;
        try{
            insert ttRequestLineItem;
        } catch(Exception e){
            // do nothing
        }
        
        ttRequest.Status__c = 'Submitted';
        update ttRequest;
        ttRequest.Status__c = 'Approved';
        update ttRequest;
    }
    // 
}