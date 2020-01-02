public class TransferToolUtil {
    public static boolean firstRun = true;
   
    public static String performTransfer(String transferToolApprovalRecordId){
        String returnServiceContractId = NULL;
        
        Id OriginalSCId;
        // Fetch the List of LineItems from Transfer Request that needs to be transferred (Object: Entitlement Transfer Detail - Transfer_Tool__c) 
        List<Transfer_Tool__c> lineItemsToTransfer = [SELECT id,
                                                         Contract_Line_Item__r.Annualized_Maintenance_Due__c,
                                                         Contract_Line_Item__r.Actual_Original_Quantity__c,
                                                         Contract_Line_Item__r.Current_Quantity__c,
                                                         Contract_Line_Item__r.Lic_Invoice__c,
                                                         Contract_Line_Item__r.Maintenance_Start_Date__c,
                                                         Contract_Line_Item__r.Maintenance_End_Date__c,
                                                         Contract_Line_Item__r.Original_License_Invoice_Date__c,
                                                         Contract_Line_Item__r.Original_Net_License_value__c,
                                                         Contract_Line_Item__r.Original_Quantity__c,
                                                         Contract_Line_Item__r.Original_PO__c,
                                                         Contract_Line_Item__r.Previous_Line_Maintenance_Value__c,
                                                         Contract_Line_Item__r.Revised_Net_License_value__c,
                                                         Contract_Line_Item__r.Sales_Order__c,
                                                         Contract_Line_Item__r.Quantity,
                                                         Contract_Line_Item__r.UnitPrice,
                                                         Contract_Line_Item__r.Current_Maintenance_Rate__c,
                                                         Contract_Line_Item__r.Upgraded_Product__c,
                                                         Contract_Line_Item__r.Non_Billable__c,
                                                         Product__r.Description, New_Contract_No__r.Name,
                                                         Approved_by__r.name,CreatedBy.name,Transfer_to_Sold_To__r.name,Transfer_to_ST_EU__r.name,Product__r.name,
                                                         Transfer_to_ST_EU__c,Account__c,New_Contract_No__c,Product__c,
                                                         Service_Contract__c,
                                                         Service_Contract__r.Renewal_Opportunity__c,
                                                         Service_Contract__r.Pricebook2Id, 
                                                         Service_Contract__r.CurrencyIsoCode,
                                                         Transfer_Quantity__c,Transfer_Status__c,Transfer_to_Sold_To__c,
                                                         Transfer_Tool_Approval__c,Contract_Line_Item__c,Date_of_Transfer__c 
                                                         FROM Transfer_Tool__c WHERE Transfer_Tool_Approval__c = :transferToolApprovalRecordId];
        
            
        if(!lineItemsToTransfer.isEmpty()){
            
            Set<String> productNamesToExclude = new Set<String>();
            List<Products_To_Exclude_In_New_SC__c> productsToExcludeConfig = Products_To_Exclude_In_New_SC__c.getall().values();
            for(Products_To_Exclude_In_New_SC__c p : productsToExcludeConfig){
                productNamesToExclude.add(p.ProductName__c);    
            }
            
            Set<String> productNamesToInclude = new Set<String>();
            List<Products_To_Include_In_New_SC__c> productsToIncludeConfig = Products_To_Include_In_New_SC__c.getall().values();
            for(Products_To_Include_In_New_SC__c p : productsToIncludeConfig){
                productNamesToInclude.add(p.ProductName__c);    
            }
            
            Map<String, Transfer_Tool__c> lineItemsToTransferMap = new Map<String, Transfer_Tool__c>();
            Set<id> lineItemsToTransferIds = new Set<id>();
            Set<id> productToTransferIds = new Set<id>();
        
            for(Transfer_Tool__c tt : lineItemsToTransfer){
                lineItemsToTransferIds.add(tt.Contract_Line_Item__c);
                productToTransferIds.add(tt.Product__c);
                lineItemsToTransferMap.put(tt.Contract_Line_Item__c, tt);
            }
        
            String selectedSC = lineItemsToTransfer[0].Service_Contract__c;
            String opportunityIdOfSelectedSC = lineItemsToTransfer[0].Service_Contract__r.Renewal_Opportunity__c;
            String priceBookIdOfSelectedSC = lineItemsToTransfer[0].Service_Contract__r.Pricebook2Id;
            String currencyCodeOfSelectedSC = lineItemsToTransfer[0].Service_Contract__r.CurrencyIsoCode;
            // Get rest contract line item of selected service contract
            List<ContractLineItem> lineItemsRemaining = [Select id, 
                                                         Annualized_Maintenance_Due__c,
                                                         Actual_Original_Quantity__c, 
                                                         Current_Quantity__c,
                                                         Lic_Invoice__c,
                                                         Maintenance_End_Date__c,
                                                         Maintenance_Start_Date__c,
                                                         Original_License_Invoice_Date__c,
                                                         Original_Net_License_value__c,
                                                         Original_Quantity__c,
                                                         Original_PO__c,
                                                         Previous_Line_Maintenance_Value__c,
                                                         Product_Description__c,
                                                         PricebookEntryId,
                                                         PricebookEntry.Product2.Name, 
                                                         PricebookEntry.Product2.Product_Name__c, 
                                                         PricebookEntry.Product2.Type__c,
                                                         Revised_Net_License_value__c,
                                                         Quantity, 
                                                         ServiceContractid,
                                                         ServiceContract.PriceBook2Id,
                                                         ServiceContract.CurrencyIsoCode,
                                                         Sales_Order__c,
                                                         Current_Maintenance_Rate__c,
                                                         Upgraded_Product__c,
                                                         UnitPrice
                                                         FROM ContractLineItem 
                                                         WHERE ID NOT IN :lineItemsToTransferIds AND ServiceContractId = :selectedSC];
    
           
            
            Set<String> automaticLineItemIds = new Set<String>();
            Set<String> excludeLineItemIds = new Set<String>();
            Set<String> lineItemsWithZeroMaintenanceDue = new Set<String>();
            // Set<String> flexCareLineItemIds = new Set<String>();
            
            List<ContractLineItem> automaticLineItems = new  List<ContractLineItem>();
            
            for(ContractLineItem cli : lineItemsRemaining){
                
                // 1. Check if the Line Item Product Name is configured to be exluded completely while creating new Service Contract 
                if(productNamesToExclude.contains(cli.PricebookEntry.Product2.Name)){
                    excludeLineItemIds.add(cli.id);
                } else 
                // 2. Check if the Line Item Product Name is configured to be inlcuded while creating new Service Contract with Zero Values
                if(productNamesToInclude.contains(cli.PricebookEntry.Product2.Name)){
                    automaticLineItemIds.add(cli.id);
                    lineItemsWithZeroMaintenanceDue.add(cli.id);
                } else 
                // 3. Check if the Line Item Product Type is 'Genesys Care' or 'Flex Care' or 'Maintenance' so that this needs to be included 
                if(cli.PricebookEntry.Product2.Type__c == 'Genesys Care' || cli.PricebookEntry.Product2.Type__c == 'Maintenance' || cli.PricebookEntry.Product2.Type__c == 'Flex Care'){
                    automaticLineItemIds.add(cli.id);
                    if(cli.PricebookEntry.Product2.Type__c == 'Flex Care')
                        lineItemsWithZeroMaintenanceDue.add(cli.id);
                    
                } else 
                // 4. Check if the Line Item Product Type is 'GU' or 'PS' or 'Fees' so that this needs to be excluded 
                if(cli.PricebookEntry.Product2.Type__c == 'GU' || cli.PricebookEntry.Product2.Type__c == 'PS' || cli.PricebookEntry.Product2.Type__c == 'Fees'){
                    excludeLineItemIds.add(cli.id);
                }
            }

                
            /*Get All price book entries*/
            List<PricebookEntry> lstPriceBookEntries = [SELECT  Product2Id, UnitPrice, Id, Pricebook2Id, ProductCode, Name, UseStandardPrice 
                                                        FROM PricebookEntry 
                                                        WHERE Pricebook2Id = :priceBookIdOfSelectedSC and Product2Id IN : productToTransferIds and CurrencyIsoCode = :currencyCodeOfSelectedSC ];
            
            Map<String, PricebookEntry> mapPriceBookEntries = new Map<String, PricebookEntry>();
            for(PricebookEntry pbe : lstPriceBookEntries){
                mapPriceBookEntries.put(pbe.Product2Id, pbe);
            }
            
            
            
            // Clone service contract line items
            String oldServiceContractLineItemsSOQL = CloneUtility.getCreatableFieldsSOQL('ContractLineItem','ServiceContractId  =\''+selectedSC+'\'');  
            List<ContractLineItem> lineItemsFromOldServiceContract = (List<ContractLineItem>)Database.query(oldServiceContractLineItemsSOQL ); 

            // Find out whether we need to create a new Original Service Contract and New Opportunity   
            boolean createNewServiceContract = false;
            for(ContractLineItem oldCli  : lineItemsFromOldServiceContract) {
                 // Collect list of automatic transferrable LineItems
                if(automaticLineItemIds.contains(oldCli.id))
                    automaticLineItems.add(oldCli);
                
                if(!(automaticLineItemIds.contains(oldCli.id) || excludeLineItemIds.contains(oldCli.id))){
                    if(lineItemsToTransferMap.keySet().contains(oldCli.Id)){ 
                        if((oldCli.Current_Quantity__c - lineItemsToTransferMap.get(oldCli.Id).Transfer_Quantity__c) > 0)
                            createNewServiceContract = true;  
                    } else {
                        createNewServiceContract = true;
                    }                    
                }
            }

            // Fetch Old Service Contract and Opportunity
            String oldServiceContractSOQL = CloneUtility.getCreatableFieldsSOQL('ServiceContract','id =\''+selectedSC+'\'');  
            List<ServiceContract> lstSC = (List<ServiceContract>)Database.query(oldServiceContractSOQL); 
            ServiceContract oldServiceContract =  lstSC[0];
            
            // Get the Opportunity linked to Original Service Contract
            Opportunity oldServiceContractOpportunity = null;
            if(opportunityIdOfSelectedSC != NULL){
	            String orgOpportunitySOQL = CloneUtility.getCreatableFieldsSOQL('Opportunity','id =\''+opportunityIdOfSelectedSC+'\'');  
	            List<Opportunity> orgOpportunityList = (List<Opportunity>)Database.query(orgOpportunitySOQL);
	            oldServiceContractOpportunity = orgOpportunityList[0];
            }

            OriginalSCId = oldServiceContract.Original_Service_Contract__c == null ? oldServiceContract.id : oldServiceContract.Original_Service_Contract__c;
            
            ServiceContract newServiceContract;
            Opportunity newServiceContractOpportunity;
            
            if(createNewServiceContract){
                // Clone Opportunity
                if(oldServiceContractOpportunity != NULL){
	                newServiceContractOpportunity = oldServiceContractOpportunity.clone(false,true,false,false);
	                newServiceContractOpportunity.Service_Contract_Siebel_ID__c = null;
	                newServiceContractOpportunity.Legacy_EMG_Id__c = null;
	                newServiceContractOpportunity.Opportunity_Status__c = 'In Progress';
	                
	                newServiceContractOpportunity.Previous_Service_Contract_Amount__c  =  oldServiceContract.Maintenance_Amount__c;                   
	                newServiceContractOpportunity.Previous_Service_Contract_Maint_Value__c =  oldServiceContract.Maintenance_Amount__c;
	                newServiceContractOpportunity.Previous_Service_Contract_Number__c =  oldServiceContract.Name; 
	                
	                clearAllQuoteRelatedFields(newServiceContractOpportunity);
	                
	                // Insert Opportunity
	                insert newServiceContractOpportunity; 
                }
                
                // Create New SC with Active status - Clone Service Contract
                newServiceContract = oldServiceContract.clone(false, true);
                newServiceContract.Siebel_ID__c = null; 
                newServiceContract.Renewal_Opportunity__c = newServiceContractOpportunity != NULL ? newServiceContractOpportunity.Id : NULL;
                newServiceContract.Siebel_ID__c = null;
                newServiceContract.Agreement_Status__c ='Active';
                //  newServiceContract.Quote_Name__c = null;
    
                if(newServiceContract.Original_Service_Contract__c == null) {
                    newServiceContract.Original_Service_Contract__c = oldServiceContract.id;
                }
                
                insert newServiceContract;
                
                
                // Create Line Items for new Service Contract
                List<ContractLineItem> lineItemsInNewServiceContract = new List<ContractLineItem>();
                
                newServiceContract.Maintenance_Amount__c = 0.0;
                for(ContractLineItem oldCli  : lineItemsFromOldServiceContract) {
                    
                    ContractLineItem newCli = new ContractLineItem();
    
                    newCli.ServiceContractid = newServiceContract.id;
                    newCli.PricebookEntryId = oldCli.PricebookEntryId;
                    newCli.Quantity =  oldCli.Quantity; 
                    newCli.UnitPrice = oldCli.UnitPrice; 
                    newCli.Siebel_ID__c = null;
                    
                    newCli.Lic_Invoice__c = oldCli.Lic_Invoice__c;
                    newCli.Original_License_Invoice_Date__c = oldCli.Original_License_Invoice_Date__c;
                    newCli.Maintenance_Start_Date__c = oldCli.Maintenance_Start_Date__c;
                    newCli.Maintenance_End_Date__c = oldCli.Maintenance_End_Date__c;
                    newCli.Non_Billable__c = oldCli.Non_Billable__c;
                    
                    newCli.Sales_Order__c = oldCli.Sales_Order__c;
                    newCli.Original_PO__c = oldCli.Original_PO__c;
                    
                    newCli.Current_Maintenance_Rate__c = oldCli.Current_Maintenance_Rate__c;
                    newCli.Upgraded_Product__c = oldCli.Upgraded_Product__c;

                    // Line Items Selected to Transfer
                    if(lineItemsToTransferMap.keySet().contains(oldCli.Id)){ 
                        Transfer_Tool__c objTT = lineItemsToTransferMap.get(oldCli.Id);
    
                        newCli.Current_Quantity__c = oldCli.Current_Quantity__c - objTT.Transfer_Quantity__c;
                        newCli.Actual_Original_Quantity__c = oldCli.Current_Quantity__c - objTT.Transfer_Quantity__c;
                        newCli.Original_Quantity__c = oldCli.Current_Quantity__c - objTT.Transfer_Quantity__c;
    
                        if(oldCli.Annualized_Maintenance_Due__c != null && oldCli.Current_Quantity__c != null && objTT.Transfer_Quantity__c != null)
                            newCli.Annualized_Maintenance_Due__c = (oldCli.Annualized_Maintenance_Due__c/oldCli.Current_Quantity__c)*(oldCli.Current_Quantity__c - objTT.Transfer_Quantity__c);
                        if(oldCli.Previous_Line_Maintenance_Value__c != null && oldCli.Current_Quantity__c != null && objTT.Transfer_Quantity__c != null)
                            newCli.Previous_Line_Maintenance_Value__c = (oldCli.Previous_Line_Maintenance_Value__c/oldCli.Current_Quantity__c)*(oldCli.Current_Quantity__c - objTT.Transfer_Quantity__c);
                        if(oldCli.Original_Net_License_value__c != null && oldCli.Current_Quantity__c != null && objTT.Transfer_Quantity__c != null)
                            newCli.Original_Net_License_value__c = (oldCli.Original_Net_License_value__c/oldCli.Current_Quantity__c)*(oldCli.Current_Quantity__c - objTT.Transfer_Quantity__c);
                        if(oldCli.Revised_Net_License_value__c != null && oldCli.Current_Quantity__c != null && objTT.Transfer_Quantity__c != null)
                            newCli.Revised_Net_License_value__c = (oldCli.Revised_Net_License_value__c/oldCli.Current_Quantity__c)*(oldCli.Current_Quantity__c - objTT.Transfer_Quantity__c);
                    } // Other line Items
                    else {
                        newCli.Current_Quantity__c = oldCli.Current_Quantity__c;
                        newCli.Actual_Original_Quantity__c = oldCli.Current_Quantity__c;
                        newCli.Original_Quantity__c = oldCli.Current_Quantity__c;
                        
                        newCli.Annualized_Maintenance_Due__c = oldCli.Annualized_Maintenance_Due__c;
                        newCli.Previous_Line_Maintenance_Value__c = oldCli.Previous_Line_Maintenance_Value__c;
                        newCli.Original_Net_License_value__c = oldCli.Original_Net_License_value__c;
                        newCli.Revised_Net_License_value__c = oldCli.Revised_Net_License_value__c;
                    }
                    
                    // Only add those line items that has Current_Quantity__c > 0
                    if(newCli.Current_Quantity__c > 0 ){
                        lineItemsInNewServiceContract.add(newCli);
                        if(newCli.Annualized_Maintenance_Due__c != NULL)
                            newServiceContract.Maintenance_Amount__c = newServiceContract.Maintenance_Amount__c + newCli.Annualized_Maintenance_Due__c;
                    }
                }
    
                insert lineItemsInNewServiceContract;

                // Set the New_Origin_SC__c to the Service Contract Created
                oldServiceContract.New_Origin_SC__c = newServiceContract.id;
                
                // Update service contract name with Agreement number because after cloning its generates service contract with same name 
                ServiceContract newSCDetails = [SELECT id, Agreement_Number__c, name, Sold_To_Name__r.name, End_User_Name__r.name  from ServiceContract where id = :newServiceContract.id];
                
                // Update service contract name with Agreement number because after cloning its generates service contract with same name 
                newServiceContract.Name = newSCDetails.Agreement_Number__c + '-T';
                update newServiceContract;
                if(newServiceContractOpportunity != NULL){
	                newServiceContractOpportunity.Name = 'Renewal - ' 
	                    + newSCDetails.Sold_To_Name__r.name + ' - ' 
	                    + newSCDetails.End_User_Name__r.name + ' - ' 
	                    + newSCDetails.Agreement_Number__c + '-T'
	                    + '(' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() +')'; 
	                update newServiceContractOpportunity;
                }

                // Assign the id of the new Service Contract Created for return
                returnServiceContractId = newServiceContract.Id;
            }
            
            // update old service contract with Transferred Status
            oldServiceContract.Agreement_Status__c = 'Transferred';
            update oldServiceContract;
            

            
            // Create list for Service contract and related opportunities
            Set<String> uniqueCombinations = new Set<String>();
            List<ServiceContract> brandNewServiceContracts = new List<ServiceContract>();
            List<Opportunity> brandNewOpportunities = new List<Opportunity>();
            
            
            for(Transfer_Tool__c objTT : lineItemsToTransfer){
                if(!uniqueCombinations.contains(objTT.Transfer_to_ST_EU__c + '|' + objTT.Transfer_to_Sold_To__c)){
                    ServiceContract objSC = lstSC[0].clone(false, true);
                    objSC.Siebel_ID__c = null;
                    objSC.End_User_Name__c = objTT.Transfer_to_ST_EU__c;
                    objSC.Sold_To_Name__c = objTT.Transfer_to_Sold_To__c;
                    objSC.Agreement_Status__c = 'Active';
                    // objSC.Quote_Name__c = null;
                    objSC.Maintenance_Amount__c = 0.0;
                    objSC.Name = 'Test';
                    objSC.Original_Service_Contract__c = OriginalSCId ;
                    if(objSC.EndDate >=  Date.today())
                        objSC.StartDate = Date.today();                    
                    
                    uniqueCombinations.add(objTT.Transfer_to_ST_EU__c + '|' + objTT.Transfer_to_Sold_To__c);
                    brandNewServiceContracts.add(objSC);
                    if(oldServiceContractOpportunity != NULL){
	                    Opportunity objO = oldServiceContractOpportunity.clone(false,true,false,false);
	                    objO.Service_Contract_Siebel_ID__c = null;
	                    objO.Legacy_EMG_Id__c = null;
	                    objO.AccountId = objTT.Transfer_to_ST_EU__c; 
	                    objO.BusinessPartner__c = objTT.Transfer_to_Sold_To__c; 
	                    objO.Opportunity_Status__c = 'In Progress';
	                    objO.Previous_Service_Contract_Amount__c  =  oldServiceContract.Maintenance_Amount__c;                   
	                    objO.Previous_Service_Contract_Maint_Value__c =  oldServiceContract.Maintenance_Amount__c;
	                    objO.Previous_Service_Contract_Number__c =  oldServiceContract.Name;                    
	                    clearAllQuoteRelatedFields(objO);
	                    brandNewOpportunities.add(objO);
                    }
                }  
            }
            
            if(oldServiceContractOpportunity != NULL){
	            // Insert Opportunities
	            insert brandNewOpportunities;  
	            
	            // Set the Renewal_Opportunity__c on each Service Contract  
	            for(integer l=0; l<brandNewServiceContracts.size(); l++ ){
	                brandNewServiceContracts[l].Renewal_Opportunity__c  = brandNewOpportunities[l].id;
	            }
            }
            // Insert Service Contracts
            insert brandNewServiceContracts;  
            
            // *************************************************************************************************************
            // Insert service contract line items
            Map<String, ServiceContract> brandNewServiceContractsMap = new Map<String, ServiceContract>();
            for(ServiceContract bsc : brandNewServiceContracts){
                brandNewServiceContractsMap.put(bsc.End_User_Name__c + '|' +  bsc.Sold_To_Name__c, bsc);
            }
            
            List<ContractLineItem> brandNewSCLineItems = new List<ContractLineItem>();
            for(Transfer_Tool__c ttLine : lineItemsToTransfer){
                ContractLineItem objSCLI = new ContractLineItem();
                
                String scKey = ttLine.Transfer_to_ST_EU__c + '|' + ttLine.Transfer_to_Sold_To__c;
                
                objSCLI.ServiceContractid = brandNewServiceContractsMap.get(scKey).Id;
                objSCLI.PricebookEntryId = mapPriceBookEntries.get(ttLine.Product__c).id;
                
                if(ttLine.Contract_Line_Item__r.Annualized_Maintenance_Due__c != null && ttLine.Contract_Line_Item__r.Current_Quantity__c != null && ttLine.Transfer_Quantity__c !=  null)
                    objSCLI.Annualized_Maintenance_Due__c =(ttLine.Contract_Line_Item__r.Annualized_Maintenance_Due__c/ttLine.Contract_Line_Item__r.Current_Quantity__c)*ttLine.Transfer_Quantity__c;
                
                if(ttLine.Contract_Line_Item__r.Previous_Line_Maintenance_Value__c != null && ttLine.Contract_Line_Item__r.Current_Quantity__c != null && ttLine.Transfer_Quantity__c !=  null)
                    objSCLI.Previous_Line_Maintenance_Value__c = (ttLine.Contract_Line_Item__r.Previous_Line_Maintenance_Value__c/ttLine.Contract_Line_Item__r.Current_Quantity__c)*ttLine.Transfer_Quantity__c;
                
                if(brandNewServiceContractsMap.get(scKey).Maintenance_Amount__c != null && objSCLI.Annualized_Maintenance_Due__c != null)
                    brandNewServiceContractsMap.get(scKey).Maintenance_Amount__c = brandNewServiceContractsMap.get(scKey).Maintenance_Amount__c + objSCLI.Annualized_Maintenance_Due__c;
                
                if(ttLine.Contract_Line_Item__r.Original_Net_License_value__c != null && ttLine.Contract_Line_Item__r.Current_Quantity__c != null && ttLine.Transfer_Quantity__c != null)
                    objSCLI.Original_Net_License_value__c = (ttLine.Contract_Line_Item__r.Original_Net_License_value__c/ttLine.Contract_Line_Item__r.Current_Quantity__c)*ttLine.Transfer_Quantity__c;
                if(ttLine.Contract_Line_Item__r.Revised_Net_License_value__c != null && ttLine.Contract_Line_Item__r.Current_Quantity__c != null && ttLine.Transfer_Quantity__c != null)
                    objSCLI.Revised_Net_License_value__c = (ttLine.Contract_Line_Item__r.Revised_Net_License_value__c/ttLine.Contract_Line_Item__r.Current_Quantity__c)*ttLine.Transfer_Quantity__c;
               
                objSCLI.Sales_Order__c = ttLine.Contract_Line_Item__r.Sales_Order__c;
                objSCLI.Original_PO__c = ttLine.Contract_Line_Item__r.Original_PO__c;
                
                objSCLI.Lic_Invoice__c = ttLine.Contract_Line_Item__r.Lic_Invoice__c;
                objSCLI.Original_License_Invoice_Date__c = ttLine.Contract_Line_Item__r.Original_License_Invoice_Date__c;
                objSCLI.Maintenance_Start_Date__c = ttLine.Contract_Line_Item__r.Maintenance_Start_Date__c;
                objSCLI.Maintenance_End_Date__c = ttLine.Contract_Line_Item__r.Maintenance_End_Date__c;
                objSCLI.Quantity = ttLine.Contract_Line_Item__r.Quantity;
                objSCLI.UnitPrice = ttLine.Contract_Line_Item__r.UnitPrice;
                objSCLI.Current_Maintenance_Rate__c = ttLine.Contract_Line_Item__r.Current_Maintenance_Rate__c;
                objSCLI.Upgraded_Product__c = ttLine.Contract_Line_Item__r.Upgraded_Product__c;
				objSCLI.Non_Billable__c = ttLine.Contract_Line_Item__r.Non_Billable__c;
				
                objSCLI.Siebel_ID__c = null;
                objSCLI.Actual_Original_Quantity__c = ttLine.Transfer_Quantity__c;
                objSCLI.Original_Quantity__c = ttLine.Transfer_Quantity__c;
                objSCLI.Current_Quantity__c = ttLine.Transfer_Quantity__c;
                
                // Add records in contract line item List
                brandNewSCLineItems.add(objSCLI);
                
                // Update details in Transfer Tool New contract and Current date Transfer Tool for History Tab
                ttLine.Date_of_Transfer__c = Date.Today();
                ttLine.New_Contract_No__c = brandNewServiceContractsMap.get(scKey).Id;
                
                // Update the Annual Maintenance Amount
                
            }
            
            // add automaticLineItems for each new service contract created 
            for(ServiceContract bsc : brandNewServiceContracts){
                for(ContractLineItem ali : automaticLineItems){
                    ContractLineItem newAutoCli = new ContractLineItem();
                    newAutoCli.ServiceContractid = bsc.id;
                    newAutoCli.PricebookEntryId = ali.PricebookEntryId;
                    newAutoCli.Quantity =  ali.Quantity; 
                    newAutoCli.UnitPrice = ali.UnitPrice; 
                    newAutoCli.Siebel_ID__c = null;
                    newAutoCli.Lic_Invoice__c = ali.Lic_Invoice__c;
                    newAutoCli.Original_License_Invoice_Date__c = ali.Original_License_Invoice_Date__c;
                    newAutoCli.Maintenance_Start_Date__c = ali.Maintenance_Start_Date__c;
                    newAutoCli.Maintenance_End_Date__c = ali.Maintenance_End_Date__c;
                    newAutoCli.Sales_Order__c = ali.Sales_Order__c;
                    newAutoCli.Original_PO__c = ali.Original_PO__c;
                    newAutoCli.Current_Quantity__c = ali.Current_Quantity__c;
                    newAutoCli.Actual_Original_Quantity__c = ali.Current_Quantity__c;
                    newAutoCli.Original_Quantity__c = ali.Current_Quantity__c;
                    newAutoCli.Non_Billable__c = ali.Non_Billable__c;
                    
                    if(lineItemsWithZeroMaintenanceDue.contains(ali.id)){
                        newAutoCli.Annualized_Maintenance_Due__c = 0;
                        newAutoCli.Previous_Line_Maintenance_Value__c = 0;
                    } else {
                        newAutoCli.Annualized_Maintenance_Due__c = ali.Annualized_Maintenance_Due__c;
                        // newAutoCli.Previous_Line_Maintenance_Value__c = ali.Annualized_Maintenance_Due__c;
                        newAutoCli.Previous_Line_Maintenance_Value__c = ali.Previous_Line_Maintenance_Value__c;
                    }
                    if(brandNewServiceContractsMap.get(bsc.End_User_Name__c + '|' +  bsc.Sold_To_Name__c) != NULL &&  newAutoCli.Annualized_Maintenance_Due__c != NULL)                    
                        brandNewServiceContractsMap.get(bsc.End_User_Name__c + '|' +  bsc.Sold_To_Name__c).Maintenance_Amount__c = brandNewServiceContractsMap.get(bsc.End_User_Name__c + '|' +  bsc.Sold_To_Name__c).Maintenance_Amount__c + newAutoCli.Annualized_Maintenance_Due__c;
                    
                    newAutoCli.Original_Net_License_value__c = ali.Original_Net_License_value__c;
                    newAutoCli.Revised_Net_License_value__c = ali.Revised_Net_License_value__c;
                    // Add records in contract line item List
                    brandNewSCLineItems.add(newAutoCli);
                }
            }
            System.debug('brandNewSCLineItems = ' + brandNewSCLineItems);
            insert brandNewSCLineItems;

            // Fetch service contracts for latest information            
            List<ServiceContract> scTempList = [SELECT id,name,Agreement_Number__c, End_User_Name__c,Sold_To_Name__c, Renewal_Opportunity__c, Sold_To_Name__r.name, End_User_Name__r.name  from ServiceContract where id IN : brandNewServiceContracts];

            // Update all Service Contract for their names
            for(ServiceContract sc : scTempList){
                brandNewServiceContractsMap.get(sc.End_User_Name__c + '|' +  sc.Sold_To_Name__c).Name = sc.Agreement_Number__c + '-T';
            }            
            Update brandNewServiceContractsMap.values();
            
            if(oldServiceContractOpportunity != NULL){
	            // Updated Opportunity Names
	            Map<Id, Opportunity> oppTempMap = new Map<Id, Opportunity>();
	            for(Opportunity opp: brandNewOpportunities){
	                oppTempMap.put(opp.id, opp);
	            }
	
	            for(ServiceContract sc: scTempList){
	                //oppTempMap.get(sc.Renewal_Opportunity__c).Name = 'Renewal - ' + sc.Sold_To_Name__r.name + ' - ' + sc.End_User_Name__r.name + ' - ' + sc.Agreement_Number__c + '-T' + '(' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() +')'; 
	                String oppNewName = 'Renewal - ' + sc.Sold_To_Name__r.name + ' - ' + sc.End_User_Name__r.name + ' - ' + sc.Agreement_Number__c + '-T' + '(' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() +')';
	                if(oppNewName.length() > 119){
	                    if(sc.Sold_To_Name__r.name == sc.End_User_Name__r.name){
	                    	oppNewName = 'Renewal - ' + sc.Sold_To_Name__r.name + ' - [Same as Sold To] - ' + sc.Agreement_Number__c + '-T' + '(' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() +')';    
	                    } else {
	                                oppNewName = 'Renewal - ' + sc.Sold_To_Name__r.name + ' - [Review Sold To] - ' + sc.Agreement_Number__c + '-T' + '(' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() +')';                            
	                    }
	                    if(oppNewName.length() > 119){
	                    	oppNewName = 'Renewal - ' + sc.Sold_To_Name__r.name + ' - [*] - ' + sc.Agreement_Number__c + '-T' + '(' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() +')';                                
	                    }
	                }
	                oppTempMap.get(sc.Renewal_Opportunity__c).Name = oppNewName;
	            }            
	            update oppTempMap.values(); 
            }
            
            //  Finally Set the Status on Old Service Contracts Opporunity to Closed Transferred
            oldServiceContractOpportunity.Opportunity_Status__c = 'Closed Transferred'; 
            update oldServiceContractOpportunity;
                

            // Update Transfer Tool List data for Date of Transfer and New Contract No
            update lineItemsToTransfer;
            
            // Again make that Query because New Contract No does not reflect in lstTT that list
            List<Transfer_Tool__c> lineItemsToTransferrUpdated = [SELECT Product__r.Description,New_Contract_No__r.Name,Approved_by__r.name,CreatedBy.name,Transfer_to_Sold_To__r.name,Transfer_to_ST_EU__r.name,Product__r.name,id,Transfer_to_ST_EU__c,Account__c,New_Contract_No__c,Product__c,Service_Contract__c,Service_Contract__r.Renewal_Opportunity__c,Transfer_Quantity__c,Transfer_Status__c,Transfer_to_Sold_To__c,Transfer_Tool_Approval__c,Contract_Line_Item__c,Date_of_Transfer__c from Transfer_Tool__c where Transfer_Tool_Approval__c =: trigger.old[0].id];
            
            // Get Original Parent Service Contract record
            //ServiceContract originalServiceContract = [SELECT id,name from ServiceContract where id =:OriginalSCId];
            
            
            // Get email list from custom settings
            List<Entitlement_Transfer__c> lstCstSetting = Entitlement_Transfer__c.getall().values();
            List<string>lstEmail = new List<string>();
            for(integer m=0;m<lstCstSetting.size();m++){
                lstEmail.add(lstCstSetting[m].Email__c);
            }
            
            string EmailBody,sSubject;
            //String orginalSCURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + originalServiceContract.id;
            String oldSCURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + oldServiceContract.id;
            
            sSubject = 'New Service Contract';
            EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td>Hi,</td></tr>';
            EmailBody = EmailBody + '<tr><td></td></tr>';
            EmailBody = EmailBody + '<tr><td>Please find below Entitlement Transfer Details.</td></tr>';
            EmailBody = EmailBody + '<tr><td><table border="1">';
            EmailBody = EmailBody + '<tr><td><b>Product Name</b></td><td><b>Product Description</b></td><td><b>Transfer Quantity</b></td><td><b>Transfer to End User</b></td><td><b>Transfer to Sold To</b></td><td><b>Transfer Service Contract</b></td><td><b>Date of Transfer</b></td><td><b>Created By</b></td></tr>';
            for(Transfer_Tool__c objTT : lineItemsToTransferrUpdated){
                EmailBody = EmailBody + '<tr><td>'+objTT.Product__r.name+'</td><td>'+objTT.Product__r.Description+'</td><td>'+objTT.Transfer_Quantity__c+'</td><td>'+objTT.Transfer_to_ST_EU__r.name+'</td><td>'+objTT.Transfer_to_Sold_To__r.name+'</td><td>'+objTT.New_Contract_No__r.Name+'</td><td>'+objTT.Date_of_Transfer__c.format()+'</td><td>'+objTT.CreatedBy.name+'</td></tr>';
            }
            EmailBody = EmailBody + '</table></td></tr>';
            
            EmailBody = EmailBody + '<br><tr><td><b>Transfer Hierarchy : </b></td></tr>';
            EmailBody = EmailBody + '<tr><td><table border="1">';
            EmailBody = EmailBody + '<tr><td><b>Contract Type</b></td><td><b>Contract Number</b></td></tr>';
            EmailBody = EmailBody + '<tr><td>Original Service Contract:</td><td> <a href="'+oldSCURL+'" class="btn-Open-Case">'+oldServiceContract.Name+'</a></td></tr>';
            if(newServiceContract != NULL){
                String newSCURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + newServiceContract.id;
                EmailBody = EmailBody + '<tr><td>Current Service Contract:</td><td> <a href="'+newSCURL+'" class="btn-Open-Case">'+newServiceContract.Name+'</a></td></tr>';
            }
            // EmailBody = EmailBody + '<tr><td>Parent Service Contract: </td><td> <a href="'+orginalSCURL +'" class="btn-Open-Case">'+originalServiceContract.Name+'</a></td></tr>';
            EmailBody = EmailBody + '</table></td></tr>';
            EmailBody = EmailBody + '</table>';
            EmailBody = EmailBody + '<br></br> You may want to attach this email in the attachment section of the affected service contracts.';
            EmailBody = EmailBody + '<br></br> Please use Entitlement Transfer History for more details.';
            EmailBody = EmailBody + '</body></html>';
            
            // Add Current User Email
            lstEmail.add(UserInfo.getUserEmail());
            
            // Send email
            Util.EmailNotification(EmailBody,sSubject,lstEmail);
        }
        return returnServiceContractId;
    }
    
    public static void clearAllQuoteRelatedFields(Opportunity opportunityObj){
        opportunityObj.Quote_Amount__c  = NULL;
        opportunityObj.Quote_Big_Six__c  = NULL;
        opportunityObj.Quote_Cancelled_Quote_Reason__c  = NULL;
        opportunityObj.Quote_Cancelled_Reason__c  = NULL;
        opportunityObj.Quote_Cancelled_Date__c = NULL;
        opportunityObj.Cloud_Quote_Value__c  = NULL;
        opportunityObj.Quote_Comment__c  = NULL;
        opportunityObj.Decreased_Quote_Reason__c  = NULL;
        opportunityObj.Quote_Decreased_Quote_Reason__c  = NULL;
        // opportunityObj.Quote_Genesys_Care__c  = NULL;
        // opportunityObj.Quote_Genesys_Care_Rate__c = NULL;
        opportunityObj.Hybrid_Quote_Value__c  = NULL;
        opportunityObj.Quote_Annual_Increase__c  = NULL;
        opportunityObj.Quote_Annual_Increase_Value__c = NULL;
        opportunityObj.Quote_Maintenance_End_Date__c = NULL;
        opportunityObj.Quote_Maintenance_Start_Date__c = NULL;
        opportunityObj.Quote_Negotiated_Rate_Increase__c = NULL;
        opportunityObj.Number_of_associated_Quotes__c = NULL;
        opportunityObj.On_Premise_Quote_Value__c = NULL;
        opportunityObj.Quote_Order_Payment_Terms__c = NULL;
        opportunityObj.Pre_Quote_License_Amount__c = NULL;
        opportunityObj.Pre_Quote_Total_Amount__c = NULL;
        opportunityObj.Primary_Quote__c = NULL;
        opportunityObj.Prior_Siebel_Quote_End_Date__c = NULL;
        opportunityObj.Prior_Siebel_Quote_Number__c = NULL;
        opportunityObj.New_Opportunity_Status__c = NULL;
        opportunityObj.Quote_Category__c = NULL;
        opportunityObj.Quote_Quote_Created_Date__c = NULL;
        opportunityObj.Quote_Last_Modified_Date__c = NULL;
        opportunityObj.Quote_Quote_Status__c = NULL;
        opportunityObj.Quote_Quote_Version__c = NULL;
        opportunityObj.Quote_Reinstated_Date__c = NULL;
        opportunityObj.Quote_Sales_Org__c = NULL;
        opportunityObj.Quote_SG2_Region__c = NULL;
        opportunityObj.Split_Parent_Quote__c = NULL;
        opportunityObj.Quote_Total_Net_License_Value__c = NULL;
        opportunityObj.Quote_Total_Revised_Net_License__c = NULL;
        opportunityObj.Quote_USD_Equivalent__c = NULL;
        opportunityObj.Quote_Support_Owner_ID__c = NULL;
    }
}