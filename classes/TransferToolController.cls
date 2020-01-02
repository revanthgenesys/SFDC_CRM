public class TransferToolController {
    
    public Transfer_Tool_Approval__c currentTTA {get; set;}
    public Transfer_Tool__c transferTool {get; set;}
    public List<ServiceContract> serviceContractList {get; set;} 
    public List<selectOption> serviceContractName {get; set;}
    public Id selectServiceContractId {get; set;}
    public boolean hasServiceContracts {get; set;}
    public boolean hasCli {get; set;}
    public List<TransferLineItemsWrapper> transferCliWrapperList {get; set;}
    
    public List<Transfer_Tool__c> newTransferToolList {get; set;}
    public Id selectCliId {get; set;}
    public boolean hasTransferRows {get; set;}
    // public boolean clickedTransfer {get; set;}
    public boolean clickedTransferHistory {get; set;}
    public boolean awaitingForApproval {get; set;}
    public boolean hasTranToolApp {get; set;}
    public boolean blnReinstateTransfer {get; set;}
    public Map<String, List<Transfer_Tool__c>> transferredItemsMap {get; set;}
    public List<Transfer_Tool_Approval__c> tta {get; set;}
    // public List<Transfer_Attachment__c> tAttachment;
    public Id removeTransferId {get; set;}
    public Id lineItemId {get; set;}
    // public Transfer_Attachment__c ta{get; set;}
    public Id approvalRecordId{get; set;}
    public Id tAttachmentId{get; set;}
    
    //Hard Code values for Demo
    public Transfer_Tool__c selectAcc {get; set;}
    // public List<selectOption> opts {get; set;}
    // public List<selectOption> svContractNames {get; set;}
    // public List<selectOption> productNames {get; set;}
    // public Id selectedAccountName {get; set;}
    public String selectedOpt {get; set;}
    // public Id selectedCntId {get; set;}
    // public Id selectedPrdId {get; set;}
    public boolean hasContracts {get; set;}
    public boolean hasOpts {get; set;}
    public boolean hasPrds {get; set;}
    //public List<Transfer_Tool__c> transfersBasedSC {get; set;}
    
    public integer LineItemCnt{get;set;}
    public boolean hasSelected {get; set;}
    public boolean zeroQuantityItemsSelected {get; set;}
    public boolean sameEndUserItemsSelected {get; set;}
    public boolean NoEndUserItemsSelected {get; set;}
    
    public boolean hasLine {get; set;}
    
    // public Id recId{get;set;} 
    public ID TTA_ID {get;set;} 
    public Transfer_Tool_Approval__c objTTApp{get;set;}
    //Added by Swastika on 12/Nov/2015 for CSV functionality<Start>
    //public Map<String, Schema.SObjectType> objs {get; set;}
    public String obj {get;set;}
    public List<String> availableFieldNames = new List<String>();
    public String sql = '';
    public String strWhere= '';
    public Integer count{get; set;}
    //Added by Swastika on 12/Nov/2015 for CSV functionality<End>
    // public ServiceContract objOldSC{get;set;}
    public boolean blnDisableConTrans{get;set;}
    public string RegionName;
    
    public TransferToolController() {
        transferCliWrapperList = new List<TransferLineItemsWrapper>();
        transferTool = new Transfer_Tool__c(); 
        newTransferToolList = new List<Transfer_Tool__c>();
        selectAcc = new Transfer_Tool__c();
        //transfersBasedSC  = new List<Transfer_Tool__c>();

        blnDisableConTrans = false;
        blnReinstateTransfer = false;
        LineItemCnt = 0;
        selectServiceContractId=null;
        clickedTransferHistory = false;
        hasServiceContracts = false;
        hasCli = false;
        selectCliId = null;
        hasTransferRows = false;
        getTransferredItems();
        //TransferToolAppData();
        
        //hard coded values for demo
        hasContracts = false;
        hasOpts = false;
        hasPrds = false;
        selectedOpt = null;
        hasSelected=false;
        zeroQuantityItemsSelected = false;
        sameEndUserItemsSelected = false;
        NoEndUserItemsSelected = false;    
        
        hasLine=false;

        //Added by Swastika on 12/Nov/2015 for CSV functionality<Start>
        obj = 'Transfer_Tool__c' ;
        strWhere='';
        awaitingForApproval = false;  
        hasTranToolApp =false;
        count=0;
        //Added by Swastika on 12/Nov/2015 for CSV functionality<End>
    }
    
    public void TransferToolAppData(){
        string sStatus = 'New';
        List<Transfer_Tool_Approval__c> lstTTA = [Select Name,id,Account__c,Account__r.Name,Service_Contract__c,Service_Contract__r.Name,Status__c,Account__r.Region__c from Transfer_Tool_Approval__c where Account__c =:transferTool.Account__c and Service_Contract__c =: selectServiceContractId and Status__c = 'New']; 
        
        if(lstTTA != null && lstTTA.size() >0){
            TTA_ID = lstTTA[0].id;
            objTTApp = lstTTA[0];
            hasTranToolApp =true;
            blnDisableConTrans = false;
        } else {
            hasTranToolApp =false;
            blnDisableConTrans = true;
        }
        
        List<Transfer_Tool_Approval__c> lstTTARejected = [Select Name,id,Account__c,Account__r.Name,Service_Contract__c,Service_Contract__r.Name,Status__c,Account__r.Region__c from Transfer_Tool_Approval__c where Account__c =:transferTool.Account__c and Service_Contract__c =: selectServiceContractId and Status__c = 'Rejected']; 
        if(lstTTARejected != null && lstTTARejected.size() >0 )
            blnReinstateTransfer = true;
        else
            blnReinstateTransfer = false;
    }
    
    public PageReference reinstateTransfer(){
        List<Transfer_Tool_Approval__c> lstTTA = [Select Name,id,Account__c,Account__r.Name,Service_Contract__c,Service_Contract__r.Name,Status__c,Account__r.Region__c from Transfer_Tool_Approval__c where Account__c =:transferTool.Account__c and Service_Contract__c =:selectServiceContractId and Status__c = 'Rejected']; 
        List<String> lstTTAIds = new List<String>();
        for(Transfer_Tool_Approval__c ttaObj : lstTTA){
            lstTTAIds.add(ttaObj.id);
            ttaObj.Status__c = 'New';
        }
        Database.update(lstTTA);
        
        List<Transfer_Tool__c> lstTT = [SELECT Id,Product__r.Name,Product__r.Description,Service_Contract__c,Contract_Line_Item__c,Transfer_Quantity__c, Transfer_to_ST_EU__c,Transfer_Status__c,Transfer_to_Sold_To__c,Transfer_Tool_Approval__c from Transfer_Tool__c WHERE Transfer_Tool_Approval__c  = :lstTTAIds];
        for(Transfer_Tool__c tt : lstTT){
            tt.Transfer_Status__c = 'New';
        }
        Database.update(lstTT);
        return getContractLineItems();
        
    }
    
    /*
    public PageReference showOptions() {
        transfersBasedSC.clear();
        selectedOpt = null;
        hasContracts = false;
        hasPrds = false;
        opts = new List<selectoption>(); 
        opts.add(new selectOption('','Please Select'));
        opts.add(new selectOption('Service Contracts','Service Contracts'));
        opts.add(new selectOption('Products','Products')); 
        if(!opts.isEmpty())
            hasOpts = true;     
        return null;
    }
    
    public pageReference showContracts() {
        transfersBasedSC.clear();
        approvalRecordId = null;
        
        System.debug('selectedOpt-->'+selectedOpt);
        svContractNames = new List<selectoption>();
        hasPrds = false;
        svContractNames.add(new selectOption('','Please Select'));
        List<Transfer_Tool_Approval__c > lstServiceContract=new List<Transfer_Tool_Approval__c >();
        lstServiceContract=[select  name,Service_Contract__c,Service_Contract__r.Name from Transfer_Tool_Approval__c where Status__c=:'Approved' and Account__c=:selectAcc.Account__c];
        System.debug('selectAcc.Account__c-->'+selectAcc.Account__c);
        if(lstServiceContract.Size()>0) {
            for(Transfer_Tool_Approval__c App: lstServiceContract){
                svContractNames.add(new  SelectOption(App.Service_Contract__c , App.Service_Contract__r.Name));
            }
        }
        
        if(!svContractNames.isEmpty()) 
            hasContracts = true;  
        
        return null;
    }
    
    public PageReference showApprovedContractsTransfers() {
        System.debug('selectedCntId----'+selectedCntId);
        System.debug('selectAcc.Account__c----'+selectAcc.Account__c);
        transfersBasedSC = [select Product__r.Name,Product__r.Description,Transfer_Quantity__c,Transfer_to_ST_EU__c,Transfer_to_Sold_To__c,
                            New_Contract_No__c,Date_of_Transfer__c,CreatedBy.Name,Approved_by__c,Transfer_Tool_Approval__c,Transfer_Tool_Approval__r.LastModifiedBy.Name,New_Contract_No__r.Original_Service_Contract__c from Transfer_Tool__c where Account__c =: selectAcc.Account__c and
                            Service_Contract__c =: selectedCntId];
        // Get line items count
        if(transfersBasedSC.size()>0)
            LineItemCnt = transfersBasedSC.size();
        else
            LineItemCnt  = 0;
        
        System.debug('transfersBasedSC----'+transfersBasedSC);
        System.debug('transfersBasedSCcccc----'+transfersBasedSC[0].New_Contract_No__r.Original_Service_Contract__c);
        
        objOldSC = new ServiceContract();
        //objOldSC = [select New_Origin_SC__r.name,name,New_Origin_SC__c,Original_Service_Contract__c,Original_Service_Contract__r.name from ServiceContract where Id=:transfersBasedSC[0].Service_Contract__r.Original_Service_Contract__c];  
        //objOldSC = [select id,name from ServiceContract where Id=:transfersBasedSC[0].New_Contract_No__r.Original_Service_Contract__c]; 
        
        objOldSC = [Select Id,name,New_Origin_SC__c,New_Origin_SC__r.name,New_Origin_SC__r.Original_Service_Contract__c,New_Origin_SC__r.Original_Service_Contract__r.name from ServiceContract where id =:selectedCntId];
        
        System.debug('objOldSC ----'+objOldSC ); 
        return null;
    }
    
    public PageReference showApprovedProductTransfers() {
        System.debug('selectedCntId----'+selectedCntId);
        System.debug('selectAcc.Account__c----'+selectAcc.Account__c);
        transfersBasedSC = [select Product__r.Name,Transfer_Quantity__c,Transfer_to_ST_EU__c,Transfer_to_Sold_To__c,
                            New_Contract_No__c,Date_of_Transfer__c,CreatedBy.Name,Approved_by__c,Transfer_Tool_Approval__c,Transfer_Tool_Approval__r.LastModifiedBy.Name 
                            from Transfer_Tool__c where Account__c =: selectAcc.Account__c and
                            Product__c =: selectedPrdId];
        // Get line items count
        if(transfersBasedSC.size()>0)
            LineItemCnt = transfersBasedSC.size();
        else
            LineItemCnt  = 0;
        
        System.debug('transfersBasedSC----'+transfersBasedSC);
        return null;
    }
    */
    
    public String clickedTransferStr { 
        get;
        // *** setter is NOT being called ***
        set {
            clickedTransferStr = value;
            System.debug('value: '+value);
        }
    }
    
    /*
    public void clickTransferHistory() {
        clickedTransferHistory = true;
    }
	*/
    
    public pageReference getServiceContracts() {
        if(!transferCliWrapperList.isEmpty())
            transferCliWrapperList.clear(); 
        if(!newTransferToolList.isEmpty())
            newTransferToolList.clear(); 
        
        clickedTransferHistory = false;
        tAttachmentId = null;
        approvalRecordId = null;
        hasTransferRows = false;
        hasCli = false;
        serviceContractName = new List<selectoption>(); 
        serviceContractList = new List<ServiceContract>();
        if(transferTool.Account__c != null)
            serviceContractList = [SELECT Id, Name, ContractNumber, Sold_To_Name__c, StartDate,  EndDate, Agreement_Status__c, Maintenance_Amount__c, Opp_Status__c, Service_Contract_Type__c
                					FROM ServiceContract where AccountId =: transferTool.Account__c and Agreement_Status__c IN ('Active', 'In Negotiation') ORDER BY Name]; 
        System.debug('Account Name->'+transferTool.Account__c);
        System.debug('serviceContractList.size-->'+serviceContractList.size());
        System.debug('serviceContractList-->'+serviceContractList);
        
        serviceContractName.add(new selectOption('','Please Select'));
        for(ServiceContract sc: serviceContractList) {
            System.debug('for loop inside....>');
            serviceContractName.add(new selectOption(sc.Id,sc.Name)); 
            hasServiceContracts = true;  
        }
        System.debug('hasServiceContracts---->'+hasServiceContracts);
        return null;
    }
    
    public pageReference getContractLineItems() {
        if(!transferCliWrapperList.isEmpty())
            transferCliWrapperList.clear(); 
        if(!newTransferToolList.isEmpty())
            newTransferToolList.clear(); 
                
        
        // Dont show products from Products_To_Exclude_In_New_SC__c & Products_To_Include_In_New_SC__c in Transferrable Line Items
        Set<String> productNames = new Set<String>();

        List<Products_To_Exclude_In_New_SC__c> productsToExcludeConfig = Products_To_Exclude_In_New_SC__c.getall().values();
        for(Products_To_Exclude_In_New_SC__c p : productsToExcludeConfig){
            productNames.add(p.ProductName__c);    
        }

        List<Products_To_Include_In_New_SC__c> productsToIncludeConfig = Products_To_Include_In_New_SC__c.getall().values();
        for(Products_To_Include_In_New_SC__c p : productsToIncludeConfig){
            productNames.add(p.ProductName__c);    
        }

        if(productNames.size() == 0)
            productNames.add('Dummy');

        clickedTransferHistory = false;
        approvalRecordId = null;
        tAttachmentId = null;
        awaitingForApproval = false;
        getApprovalProcess();
        // getTransferAttachments();
        hasTransferRows = false;
        //hasCli = false;       
        //newTransferToolList = new List<Transfer_Tool__c>();
        Set<Id> cliIdSet = new Set<Id>();
        Map<Id,Transfer_Tool__c> cliTransferToolMap = new Map<Id,Transfer_Tool__c>();
        System.debug('selectServiceContractId---->'+selectServiceContractId);
		
        
        List<ContractLineItem>  cliList = [SELECT Id, PricebookEntry.Product2.Name,PricebookEntry.Product2.Description,PricebookEntry.Product2Id,
                                           Actual_Original_Quantity__c, Current_Quantity__c,ServiceContractId, Sold_To_Name_Lookup__c,SoldTo_User__c, Lic_Invoice__c, Original_License_Invoice_Date__c 
                                           FROM ContractLineItem WHERE ServiceContractId =: selectServiceContractId 
                                           AND PricebookEntry.Product2.Type__c NOT IN ('Genesys Care', 'Maintenance', 'Flex Care', 'GU', 'PS', 'Fees')
                                           AND PricebookEntry.Product2.Name NOT IN : productNames 
                                           ORDER BY Lic_Invoice__c, Original_License_Invoice_Date__c];
        System.debug('cliList--->'+cliList);
        
        for(ContractLineItem cli :  cliList) {
            cliIdSet.add(cli.Id);   
        } 
        List<Transfer_Tool__c> ttlist=  getTransferTool(cliIdSet);
        for(Transfer_Tool__c tt: ttlist) {
            if(tt.Transfer_Status__c == 'New' || tt.Transfer_Status__c == 'Awaiting for Approval') {
                System.debug('tt.Transfer_Status__c--->');
                if(!cliTransferToolMap.containsKey(tt.Contract_Line_Item__c)) {
                    cliTransferToolMap.put(tt.Contract_Line_Item__c,tt);    
                }    
            } 
        }
        
        for(ContractLineItem cli: cliList) {
            if(cliTransferToolMap.containsKey(cli.Id) && cliTransferToolMap.get(cli.Id).Transfer_Status__c == 'New') {
                System.debug('cliTransferToolMap.get(cli.Id).Transfer_Status__c---'+cliTransferToolMap.get(cli.Id).Transfer_Status__c);
                // transferCliWrapperList.add(new TransferLineItemsWrapper(cli,transferTool.Account__c ,true,cliTransferToolMap.get(cli.Id).Transfer_Quantity__c,cliTransferToolMap.get(cli.Id).Transfer_to_ST_EU__c,cliTransferToolMap.get(cli.Id).Transfer_Status__c));    
                transferCliWrapperList.add(new TransferLineItemsWrapper(cli, cliTransferToolMap.get(cli.Id)));
            }
            else if(cliTransferToolMap.containsKey(cli.Id) && cliTransferToolMap.get(cli.Id).Transfer_Status__c == 'Awaiting for Approval') {
                awaitingForApproval = true;
                System.debug('cliTransferToolMap.get(cli.Id).Transfer_Status__c---'+cliTransferToolMap.get(cli.Id).Transfer_Status__c);
                // transferCliWrapperList.add(new TransferLineItemsWrapper(cli,transferTool.Account__c ,true,cliTransferToolMap.get(cli.Id).Transfer_Quantity__c,cliTransferToolMap.get(cli.Id).Transfer_to_ST_EU__c,cliTransferToolMap.get(cli.Id).Transfer_Status__c));    
                transferCliWrapperList.add(new TransferLineItemsWrapper(cli, cliTransferToolMap.get(cli.Id)));
            }
            else {
                transferCliWrapperList.add(new TransferLineItemsWrapper(cli,transferTool.Account__c ,false,0,null,null));
            }
            
        }
        if(transferCliWrapperList.size() > 0) {
            System.debug('inside.hasCli...>');
            hasCli = true;  
            //LineItemCnt =  transferCliWrapperList.size(); 
        }
        System.debug('transferCliWrapperList--->'+transferCliWrapperList);
        hasLine=false;
        //FundisplayTransferredRows();
        /* Load list to display line items*/
        newTransferToolList.addAll(ttlist);
        if(newTransferToolList != null && newTransferToolList.size()>0)
            LineItemCnt = newTransferToolList.size();
        else  
            LineItemCnt = 0;
        
        //fill data for Transfer tool approval
        TransferToolAppData();
        
        /*Get region from selected service conytract of End User*/
        
        ServiceContract objS = [Select id,End_User_Name__r.Region__c from ServiceContract where id =:selectServiceContractId];
        RegionName = objS.End_User_Name__r.Region__c;
        
        return null;
    }
    
    /* Method to insert/update Transfer tool records*/
    public pageReference displayTransferredRows() {
        //TransferToolAppData();
        hasLine=true;  
        hasSelected=false;  
        zeroQuantityItemsSelected = false;
        sameEndUserItemsSelected = false;
        NoEndUserItemsSelected = false;    
        FundisplayTransferredRows();
        return null;    
    }
    public pageReference FundisplayTransferredRows()
    {
        try
        {      
            //clickedTransferStr = ApexPages.currentPage().getParameters().get('transferParam');
            //System.debug('clickedTransferStr-->'+clickedTransferStr);
            
            Set<Id> contractLineItemIdSet = new Set<Id>();
            Set<Id> selectedCliIdSet = new Set<Id>();
            
            Map<Id,Transfer_Tool__c> cliTransferToolMap = new Map<Id,Transfer_Tool__c>();
            List<Transfer_Tool__c> insertTransferToolList = new List<Transfer_Tool__c>();
            List<Transfer_Tool__c> deleteTransferToolList = new List<Transfer_Tool__c>();
            
            /* Insert record in Transfer Tool Approval */ 
            /* check any record for Transfer Tool Approval if not exist then insert record*/
            /*List<Transfer_Tool_Approval__c>lstTTA = [Select id,Account__c,Service_Contract__c,Status__c from Transfer_Tool_Approval__c where Account__c =:transferTool.Account__c and Service_Contract__c =: selectServiceContractId]; 

if(lstTTA != null && lstTTA.size() >0)
{
TTA_ID = lstTTA[0].id;
objTTApp = lstTTA[0];
}
else*/
            System.debug('+++++++objTTApp in FundisplayTransferredRows() ++++++'+objTTApp );
            string sStatus = 'New';
            List<Transfer_Tool_Approval__c>lstTTA = [Select Name,id,Account__c,Account__r.Name,Service_Contract__c,Service_Contract__r.Name,Status__c from Transfer_Tool_Approval__c where Account__c =:transferTool.Account__c and Service_Contract__c =: selectServiceContractId and Status__c =: sStatus]; 
            
            //Get data of Regional Controller
            
            //Regional_Controller__c objRC = [Select Regional_Controller_User__c,Region__c from Regional_Controller__c where Region__c =: RegionName];
            
            List<Regional_Controller_List__c> lstCstSetting = Regional_Controller_List__c.getall().values();
            string sUserName;
            for(integer k=0;k<lstCstSetting.size();k++)
            {
                if(RegionName == lstCstSetting[k].Region__c)
                {
                    sUserName = lstCstSetting[k].Regional_Controller_User__c;
                }
            }
            /*Get user on the basis of username*/
            User objSC = [Select id from User where username =: sUserName];
            
            
            if(lstTTA != null && lstTTA.size() >0)
            {
                objTTApp = lstTTA[0];
            }
            else
            {
                objTTApp   = new Transfer_Tool_Approval__c();
                objTTApp.Account__c = transferTool.Account__c;
                objTTApp.Service_Contract__c = selectServiceContractId;
                objTTApp.Status__c = 'New';
                objTTApp.Regional_Controller__c = objSC.id;//objRC.Regional_Controller_User__c;
                insert objTTApp;         
                TTA_ID = objTTApp.id;        
            }
            
            System.debug('transferCliWrapperList-->'+transferCliWrapperList);
            for(TransferLineItemsWrapper tli:  transferCliWrapperList) {
                contractLineItemIdSet.add(tli.cli.Id);  
            }    
            List<Transfer_Tool__c> ttlist= getTransferTool(contractLineItemIdSet);
            System.debug('ttlist-->'+ttlist);
            for(Transfer_Tool__c tt: ttlist) {
                //if(tt.Transfer_Status__c == 'New') {
                if(!cliTransferToolMap.containsKey(tt.Contract_Line_Item__c)) {
                    cliTransferToolMap.put(tt.Contract_Line_Item__c,tt);    
                }    
                //} 
            }
            
            for(TransferLineItemsWrapper tli:  transferCliWrapperList) {
                
                System.debug('clickedTransferStr-->'+clickedTransferStr);
                if(clickedTransferStr == 'true') {
                    System.debug('clickedTransferStr-->'+clickedTransferStr);
                    if(tli.isSelect == true && tli.transferQty <= 0) 
                    	zeroQuantityItemsSelected = true;
					
                    if(tli.isSelect == true && transferTool.Account__c == tli.toolForAccTransfer.Transfer_to_ST_EU__c)
                        sameEndUserItemsSelected = true;
                    
                    if(tli.isSelect == true && String.isBlank(tli.toolForAccTransfer.Transfer_to_ST_EU__c))
                        NoEndUserItemsSelected = true;
                    
                    if(tli.isSelect == true)
                    	hasSelected=true;  
                    
                    if(tli.isSelect == true && tli.transferQty > 0) {
                                         
                        System.debug('tli.isSelect-->'+tli.isSelect);
                        if(!cliTransferToolMap.containsKey(tli.cli.Id)) 
                        {                        
                            insertTransferToolList.add(new Transfer_Tool__c(Contract_Line_Item__c = tli.cli.Id,
                                                                            Product__c = tli.cli.PricebookEntry.Product2Id,
                                                                            Service_Contract__c  = tli.cli.ServiceContractId,
                                                                            Transfer_Quantity__c = tli.transferQty,
                                                                            Transfer_Status__c = 'New',
                                                                            Transfer_to_ST_EU__c = tli.toolForAccTransfer.Transfer_to_ST_EU__c,
                                                                            Account__c = transferTool.Account__c,
                                                                            Transfer_to_Sold_To__c = tli.cli.Sold_To_Name_Lookup__c,
                                                                            Transfer_Tool_Approval__c = TTA_ID 
                                                                           ));  
                            
                        }
                        else
                        {
                            //Update the already transfer record in Transfer_tool__c
                            List<Transfer_Tool__c> updateTool=[SELECT Id FROM Transfer_tool__c Where Contract_Line_Item__c=:tli.cli.Id and Transfer_to_ST_EU__c=:tli.toolForAccTransfer.Transfer_to_ST_EU__c and Transfer_to_Sold_To__c=:tli.cli.Sold_To_Name_Lookup__c];
                            if (updateTool.Size()>0)
                            {
                                updateTool[0].Transfer_Quantity__c=tli.transferQty;
                                //updateTool[0].Transfer_to_ST_EU__c = tli.toolForAccTransfer.Transfer_to_ST_EU__c;
                                //updateTool[0].Account__c = transferTool.Account__c;
                                // updateTool[0].Transfer_to_Sold_To__c = tli.cli.Sold_To_Name_Lookup__c;
                                Update updateTool[0];
                            }
                            else
                            {
                                insertTransferToolList.add(new Transfer_Tool__c(Contract_Line_Item__c = tli.cli.Id,
                                                                                Product__c = tli.cli.PricebookEntry.Product2Id,
                                                                                Service_Contract__c  = tli.cli.ServiceContractId,
                                                                                Transfer_Quantity__c = tli.transferQty,
                                                                                Transfer_Status__c = 'New',
                                                                                Transfer_to_ST_EU__c = tli.toolForAccTransfer.Transfer_to_ST_EU__c,
                                                                                Account__c = transferTool.Account__c,
                                                                                Transfer_to_Sold_To__c = tli.cli.Sold_To_Name_Lookup__c,
                                                                                Transfer_Tool_Approval__c = TTA_ID 
                                                                               ));  
                            }
                        }
                        selectedCliIdSet.add(tli.cli.Id);
                    }
                    else {
                        if(cliTransferToolMap.containsKey(tli.cli.Id)) {                       
                            deleteTransferToolList.add(cliTransferToolMap.get(tli.cli.Id));
                        }
                    }
                }
                else {
                    selectedCliIdSet.add(tli.cli.Id);
                }
            }
            System.debug('insertTransferToolList-->'+insertTransferToolList);
            System.debug('hasSelected-->'+hasSelected);
            System.debug('hasLine-->'+hasLine);
            
            // Collect all Validation Error Messages ...
            boolean noValidationErrors = true;
            if(sameEndUserItemsSelected && hasLine==true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Transfer to End User cannot be same as selected Account, Please select different End User.'));
                noValidationErrors = false;
            }
            if(NoEndUserItemsSelected && hasLine==true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Transfer to End User cannot be Empty, Please select Transfer to End User.'));
                noValidationErrors = false;
            }
 			if(zeroQuantityItemsSelected && hasLine==true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Transfer Quantity should be greated than 0, Please uncheck items with 0 Quanity.'));
                noValidationErrors = false;
            } 
            if(!hasSelected && hasLine==true) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Please select atleast one record to transfer.'));
                noValidationErrors = false;
            } 
            
            if(noValidationErrors && hasLine){ 
                System.debug('hasSelected-->'+hasSelected);
                if(insertTransferToolList.size()>0)  
                    insert insertTransferToolList;
                
                if(deleteTransferToolList.size()>0) 
                    delete deleteTransferToolList;
                
                if((ttlist.size() > 0) || (insertTransferToolList.size() > 0)) {
                    hasTransferRows = true;
                    hasTranToolApp =true; 
                    TransferToolAppData();   
                }
                else {
                    hasTransferRows = false;
                }
                newTransferToolList = getTransferTool(selectedCliIdSet);
                //clickedTransfer = false;
                if(newTransferToolList.size()>0 ) {
                    LineItemCnt  =  newTransferToolList.size();
                }
                
            }
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.error, e.getMessage());
        } 
        
        return null; 
    }
    
    /*    
public PageReference SubmitforApproval() {

objTTApp = [Select name,id,Account__c,Status__c,Account__r.Name,Service_Contract__r.Name from Transfer_Tool_Approval__c where id =: TTA_ID] ;
if(objTTApp != null){
approvalRecordId = objTTApp.id; //tta[0].Id;
Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
approvalReq.setComments('Submitting request for approval.');
approvalReq.setObjectId(objTTApp.id);//tta[0].id);
try{
// Submit the approval request for Transfer tool 
Approval.ProcessResult result = Approval.process(approvalReq);
System.debug('result-->'+result);
} 
catch (Exception e) {
ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error approval process '+e.getMessage()));  
}            
} 
return null;
}
*/
    
    public Map<String, List<Transfer_Tool__c>> getTransferredItems() 
    {
        transferredItemsMap = new Map<String, List<Transfer_Tool__c>>(); 
        List<Transfer_Tool__c> approvedTtlist= [select Id,Account__r.Name,Product__r.Name,Service_Contract__c,Service_Contract__r.Name,Contract_Line_Item__c,Transfer_Quantity__c, Transfer_to_ST_EU__c,Transfer_Status__c, New_Contract_No__c,Date_of_Transfer__c,CreatedBy.Name,Approved_by__c,Transfer_to_Sold_To__c,Transfer_Tool_Approval__c from Transfer_Tool__c where Transfer_Status__c = 'Approved' order by Service_Contract__c];
        System.debug('approvedTtlist-->'+approvedTtlist);
        for(Transfer_Tool__c tt : approvedTtlist) {
            if(!transferredItemsMap.containsKey(tt.Service_Contract__r.Name)) {
                transferredItemsMap.put(tt.Service_Contract__r.Name,new List<Transfer_Tool__c>{tt});    
            } else {
                transferredItemsMap.get(tt.Service_Contract__r.Name).add(tt);
            }
        }
        System.debug('transferredItemsMap-->'+transferredItemsMap);
        return transferredItemsMap;
    }
    
    @testVisible
    class TransferLineItemsWrapper {
        public ContractLineItem cli{get; set;} 
        public Id accountId{get; set;}
        public boolean isSelect{get; set;}
        public integer transferQty {get; set;}
        public Transfer_Tool__c toolForAccTransfer {get; set;}
        public String transferStatus {get; set;}
        public Id transferToSoldTo {get; set;}
        
        TransferLineItemsWrapper(ContractLineItem cliRecord, Transfer_Tool__c ttRecord) {
            cli = cliRecord; 
            
            isSelect = false;
            toolForAccTransfer = new Transfer_Tool__c(); 
            accountId=null;            
            transferQty = 0;    
            
            if(ttRecord != NULL){
                accountId = ttRecord.Account__c; 
                isSelect = true;
                transferQty = Integer.valueOf(ttRecord.Transfer_Quantity__c);
                toolForAccTransfer = ttRecord;
                transferStatus = ttRecord.Transfer_Status__c;
                transferToSoldTo = ttRecord.Transfer_to_Sold_To__c;
                cli.Sold_To_Name_Lookup__c = ttRecord.Transfer_to_Sold_To__c;  
            } else {
                transferToSoldTo = cli.Sold_To_Name_Lookup__c;
            	cli.Sold_To_Name_Lookup__c = cli.SoldTo_User__c;  
            }
            
        }
        TransferLineItemsWrapper(ContractLineItem cliRecord, Id accId,boolean selected,decimal qty,Id transferAccId,String tStatus) {
            cli = cliRecord; 
            if(qty > 0)
                transferQty = Integer.valueOf(qty); 
            else
                transferQty = 0;
            toolForAccTransfer = new Transfer_Tool__c();
            if(transferAccId != null)
                toolForAccTransfer.Transfer_to_ST_EU__c  =   transferAccId;
            else
                toolForAccTransfer.Transfer_to_ST_EU__c  =  null;
            if(tStatus != null)
                transferStatus = tStatus;    
            accountId = accId; 
            isSelect = selected;
            //Added by swastika
            transferToSoldTo = cli.Sold_To_Name_Lookup__c;
            cli.Sold_To_Name_Lookup__c=cli.SoldTo_User__c;     
        }
    }
    
    public PageReference removeNonApprovedRows() 
    {
        try
        {            
            System.debug('removeNonApprovedRows-->+removeNonApprovedRows');
            for(TransferLineItemsWrapper wrapper :transferCliWrapperList) {
                if(wrapper.cli.id == lineItemId) {
                    wrapper.transferQty = 0;
                    wrapper.isSelect = false;
                    wrapper.toolForAccTransfer.Transfer_to_ST_EU__c  =  null;
                } 
            }
            for(Integer j = 0; j < newTransferToolList.size(); j++){
                if(newTransferToolList.get(j).Id == removeTransferId){
                    newTransferToolList.remove(j);
                }
            }
            
            if(removeTransferId != null) {
                Transfer_Tool__c transferToRemove = new Transfer_Tool__c(Id=removeTransferId);
                System.debug('transferToRemove Id'+transferToRemove.Id);
                delete transferToRemove;            
            }
            
            if(newTransferToolList != null && newTransferToolList.size()>0)
            {
                LineItemCnt = newTransferToolList.size();
            } 
            else
            {
                LineItemCnt  = 0;
                /*If there is no record for transfer then remove record from Transfer Tool Approval object*/
                Transfer_Tool_Approval__c objTTA = [Select id from Transfer_Tool_Approval__c where Account__c =: transferTool.Account__c and Service_Contract__c =: selectServiceContractId];
                delete objTTA;
                objTTApp = null;
                System.debug('+++++objTTA from remove method++++'+objTTA);
                
                //Added by Swastika on 16-Nov-2015
                getContractLineItems();
            }       
            
        }
        catch (Exception e) {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in Transferred Entitlement'+e.getMessage()));  
        }   
        return null;       
    }
    
    public List<Transfer_Tool__c> getTransferTool(Set<Id> cliIdSet) {
        List<Transfer_Tool__c> ttlist= [SELECT Id, Account__c, Product__r.Name, Product__r.Description, Service_Contract__c, Contract_Line_Item__c, Transfer_Quantity__c, 
                                        Transfer_to_ST_EU__c, Transfer_Status__c, Transfer_to_Sold_To__c, Transfer_Tool_Approval__c 
                                        FROM Transfer_Tool__c where Account__c =: transferTool.Account__c and Contract_Line_Item__c in: cliIdSet];
        return ttlist;
    }
    
    public void getApprovalProcess() {
        System.debug('transferTool.Account__c-->'+transferTool.Account__c);
        System.debug('selectServiceContractId-->'+selectServiceContractId);
        currentTTA = null;
        tta = [select Id, Name, Status__c from Transfer_Tool_Approval__c where Account__c =: transferTool.Account__c and
               Service_Contract__c =: selectServiceContractId];
        
        if(tta.size() > 0){
            currentTTA = tta[0];
            approvalRecordId = currentTTA.Id;
            if (currentTTA.Status__c =='New')
                awaitingForApproval =false;
            else    
                awaitingForApproval =true;
        } else {
            awaitingForApproval =false;
        }
        
        System.debug('tta-->'+currentTTA);
        System.debug('approvalRecordId-->'+approvalRecordId);
    }
    
    /*
    public pageReference exportFun(){
        availableFieldNames.Clear();
        availableFieldNames.add('Product__r.Name');
        availableFieldNames.add('Product__r.Description');
        availableFieldNames.add('Transfer_Quantity__c');
        availableFieldNames.add('Transfer_to_ST_EU__r.Name');
        availableFieldNames.add('Transfer_to_Sold_To__r.Name');
        availableFieldNames.add('New_Contract_No__r.Name');
        availableFieldNames.add('Date_of_Transfer__c');
        availableFieldNames.add('CreatedBy.Name');
        availableFieldNames.add('Transfer_Tool_Approval__r.LastModifiedBy.Name');  
        strWhere=' Where Account__c =\''+ selectAcc.Account__c +'\''; 
        strWhere =strWhere+ ' and Service_Contract__c =\''+ selectedCntId+ '\''; 

        Integer i =0;
        Integer len = availableFieldNames.size() - 1;
        sql = 'SELECT ';
        for(i = 0; i < availableFieldNames.size(); i++)
        {   
            if(i != len)
            {
                sql = sql + availableFieldNames[i] + ',';
            }
            else
            {
                sql = sql + availableFieldNames[i] + ' FROM ' + obj+ strWhere;
            }
        }
        System.debug('Selected Object is ' + obj);
        pageReference pg = new pageReference('/apex/ExportToCSV?objName='+obj+'&soql='+sql);
        pg.setRedirect(true);
        return pg;
    }  
    */
    
    public PageReference refreshCurrentPage(){
        PageReference pageRef = Page.TransferToolPage;
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
public void PageRef(){
awaitingForApproval = true;
}

public PageReference incrementCounter() {
count=count+10;
return null;
}
*/
}