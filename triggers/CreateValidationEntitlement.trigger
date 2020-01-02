/*
Created By: Swastika Rajkhowa
Function : it will handle validation while transfer entitlement in staging table
*/
trigger CreateValidationEntitlement on Transfer_Tool__c (before insert,before update) { 
    
    // No need to perform this validation if the Transfer_Tool__c --> Transfer_Tool_Approval__c is not NEW
    // Query Parent Transfer_Tool_Approval__c and its status
    
    try{
        
        List<Transfer_Tool_Approval__c> approvalRequest = [SELECT id, Status__c FROM Transfer_Tool_Approval__c WHERE Id = :Trigger.New[0].Transfer_Tool_Approval__c];
        if(!approvalRequest.isEmpty() && approvalRequest[0].Status__c == 'New'){
            Decimal TotalTransfer;
            Decimal Qty;
            boolean qtyCalculated;
            
            List<String> lstOfContractLineItemIds = new List<String>();
            for (Transfer_Tool__c T : Trigger.new){
                lstOfContractLineItemIds.add(T.Contract_Line_Item__c);
            }
            Map<Id, ContractLineItem> mapOfContractLineItems = new Map<Id, ContractLineItem>([Select id, Current_Quantity__c FROM ContractLineItem WHERE Id IN :lstOfContractLineItemIds]); 
            
            List<Transfer_Tool__c> listOfAllTransferToolItems =[Select id, Contract_Line_Item__c, Transfer_Quantity__c, Transfer_to_Sold_To__c, Transfer_to_ST_EU__c FROM Transfer_Tool__c WHERE Contract_Line_Item__c IN :lstOfContractLineItemIds];
                                                                // AND (Transfer_to_Sold_To__c!=:T.Transfer_to_Sold_To__c OR Transfer_to_ST_EU__c!=:T.Transfer_to_ST_EU__c)];
                                                                
            Map<String, List<Transfer_Tool__c>> mapOfAllTransferToolItems = new Map<String, List<Transfer_Tool__c>>();                                                
            for(Transfer_Tool__c ttObj : listOfAllTransferToolItems){
                if(mapOfAllTransferToolItems.keySet().contains(ttObj.Contract_Line_Item__c)){
                    mapOfAllTransferToolItems.get(ttObj.Contract_Line_Item__c).add(ttObj);
                } else {
                    mapOfAllTransferToolItems.put(ttObj.Contract_Line_Item__c, new List<Transfer_Tool__c>{ttObj});
                }
            }
            
            
            for (Transfer_Tool__c T : Trigger.new){
                if(T.Transfer_Status__c =='New'){
                    TotalTransfer=0;
                    if(mapOfContractLineItems.containsKey(T.Contract_Line_Item__c)){
                        ContractLineItem cliToCheck =  mapOfContractLineItems.get(T.Contract_Line_Item__c);
                        
                        if(mapOfAllTransferToolItems.containsKey(T.Contract_Line_Item__c)){
                            
                            Qty=0;
                            qtyCalculated = false;
                            list<Transfer_Tool__c> lstTrans = mapOfAllTransferToolItems.get(T.Contract_Line_Item__c);
                            for(Transfer_Tool__c tool:lstTrans){
                                if(tool.Transfer_to_Sold_To__c != T.Transfer_to_Sold_To__c || tool.Transfer_to_ST_EU__c != T.Transfer_to_ST_EU__c){
                                    Qty = Qty + tool.Transfer_Quantity__c;   
                                    qtyCalculated = true;
                                }
                            }
                            
                            if(qtyCalculated){
                                 TotalTransfer = Qty + T.Transfer_Quantity__c;   
                            } else {
                                TotalTransfer = T.Transfer_Quantity__c;   
                            }
                            
                            if (T.Transfer_Quantity__c == 0){
                                T.addError('Transfer Quantity should not be zero.');
                                Break;
                            }
                            if (cliToCheck.Current_Quantity__c < TotalTransfer){
                                T.addError('Transfer Quantity should not be greater than Current Quantity.');
                                Break;
                            }                 
                            
                            if(T.Transfer_to_ST_EU__c == null){
                                T.addError('Transfer to End user should not be blank.');
                                Break;
                            }
                            
                            if(T.Transfer_to_Sold_To__c == null){
                                T.addError('Transfer to sold to should not be blank.');
                                Break;
                            } else {
                                continue; 
                            }
                                
                        }
                    } else {
                        T.addError('There is no line item against this service contract');
                    }
                                    
                    
                   
                    /*
                    TotalTransfer=0;
                    List<ContractLineItem> lstLine = new List<ContractLineItem>();  
                    lstLine=[Select Current_Quantity__c FROM ContractLineItem WHERE Id=: T.Contract_Line_Item__c];        
                    if(lstLine.size() >0)
                    {
                        Qty=0;
                        //for validation transfer record should not be greater tham Current Quantity
                        //If the service contract line item alredy transfer to staging object then again want to re-transfer the same line then add the two transfer amounts
                        list<Transfer_Tool__c> lstTrans=[Select Transfer_Quantity__c FROM Transfer_Tool__c WHERE Contract_Line_Item__c=:T.Contract_Line_Item__c AND (Transfer_to_Sold_To__c!=:T.Transfer_to_Sold_To__c OR Transfer_to_ST_EU__c!=:T.Transfer_to_ST_EU__c)];
                        if(lstTrans.size()>0)
                        {
                            for(Transfer_Tool__c tool:lstTrans){
                                Qty=Qty+tool.Transfer_Quantity__c;   
                            }   
                            TotalTransfer=Qty+T.Transfer_Quantity__c;   
                        }
                        else
                        {
                            TotalTransfer=T.Transfer_Quantity__c;   
                        }
                        if (T.Transfer_Quantity__c==0)
                        {
                            T.addError('Transfer Quantity should not be zero.');
                            Break;
                        }
                        if (lstLine[0].Current_Quantity__c < TotalTransfer){
                            T.addError('Transfer Quantity should not be greater than Current Quantity.');
                            Break;
                        }                 
                        if(T.Transfer_to_ST_EU__c==null){
                            T.addError('Transfer to End user should not be blank.');
                            Break;
                        }
                        if(T.Transfer_to_Sold_To__c==null){
                            T.addError('Transfer to sold to should not be blank.');
                            Break;
                        }
                        else
                            continue;   
                    }
                    else
                        T.addError('There is no line item against this service contract');
                    */
                }
            }
        }
        
    }
    catch(Exception e){
        trigger.new[0].addError(e.getMessage());
    }
    
}