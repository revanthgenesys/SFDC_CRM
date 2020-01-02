public class SoldToTransferToolUtil {
	public static boolean firstRun = true;
	
    public static void performTransfer(String soldToTransferToolId){
    	
    	Util.Bypass_Trigger_Chk = true;
    	// Get All Service Contracts requested to be transferred
        List<Sold_To_Transfer_Request_Detail__c> transferDetails = [SELECT id, Original_Service_Contract__c, Original_Service_Contract__r.Renewal_Opportunity__c, Original_Service_Contract__r.Sold_To_Name__c, 
        															Transferred_Service_Contract__c, Sold_To_Transfer_Request_Header__c, Sold_To_Transfer_Request_Header__r.Target_Sold_To__c, Sold_To_Transfer_Request_Header__r.Target_Sold_To__r.Name,
        															Sold_To_Transfer_Request_Header__r.Account__c, Sold_To_Transfer_Request_Header__r.Account__r.Name,
        															Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_specialist__c, Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_specialist__r.Email, 
        															Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_specialist__r.Name,
        															Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_Ops__c, Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_Ops__r.Email,
        															Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_Ops__r.Name
        															FROM Sold_To_Transfer_Request_Detail__c 
        															WHERE Sold_To_Transfer_Request_Header__c = :soldToTransferToolId];
        
        Map<String, String> originalSCRenewalOppsMap = new Map<String, String>();
        // Set<String> originalServiceContractIds = new Set<String>();
        // Set<String> originalOpportunityIds = new Set<String>();
        String originalServiceContractIdsStr = '';
        String originalOpportunityIdsStr = '';
         
        for(Sold_To_Transfer_Request_Detail__c sttrd: transferDetails){
        	originalSCRenewalOppsMap.put(sttrd.Original_Service_Contract__c, sttrd.Original_Service_Contract__r.Renewal_Opportunity__c);
        	if(sttrd.Original_Service_Contract__c != NULL){
        		//originalServiceContractIds.add(sttrd.Original_Service_Contract__c);
        		if(originalServiceContractIdsStr != '')
	        		originalServiceContractIdsStr = originalServiceContractIdsStr + ', \'' + sttrd.Original_Service_Contract__c + '\'';
				else
	        		originalServiceContractIdsStr = '\'' + sttrd.Original_Service_Contract__c + '\'';
        	}
        	if(sttrd.Original_Service_Contract__r.Renewal_Opportunity__c != NULL){
        		// originalOpportunityIds.add(sttrd.Original_Service_Contract__r.Renewal_Opportunity__c);
        		if(originalOpportunityIdsStr != '')
	        		originalOpportunityIdsStr = originalOpportunityIdsStr + ', \'' + sttrd.Original_Service_Contract__r.Renewal_Opportunity__c + '\'';
				else
	        		originalOpportunityIdsStr = '\'' + sttrd.Original_Service_Contract__r.Renewal_Opportunity__c + '\'';
        	}
        }
        
        // Fetch Old Service Contracts 
        String oldServiceContractsSOQL = CloneUtility.getCreatableFieldsSOQL('ServiceContract','id IN ('+originalServiceContractIdsStr +')');  
        List<ServiceContract> originalSCS = (List<ServiceContract>)Database.query(oldServiceContractsSOQL); 
        Map<String, ServiceContract> originalSCSMap = new Map<String, ServiceContract>();
        for(ServiceContract sc : originalSCS){
        	originalSCSMap.put(sc.Id, sc);	
        }
        
        // Get the Opportunities linked to Original Service Contracts
        String oldOpportunitiesSOQL = CloneUtility.getCreatableFieldsSOQL('Opportunity','id IN (' + originalOpportunityIdsStr +')');   
        List<Opportunity> originalOpps = (List<Opportunity>)Database.query(oldOpportunitiesSOQL);
        Map<String, Opportunity> originalOppsMap = new Map<String, Opportunity>();
        for(Opportunity opp : originalOpps){
        	originalOppsMap.put(opp.id, opp);	
        }
        
        // Opportunity oldServiceContractOpportunity = orgOpportunityList[0];	
        // ServiceContract oldServiceContract =  lstSC[0];
        
        // Create new Renewal Opportunities --> Set Sold To as Requested Sold To
        List<Opportunity> newOpportunities = new List<Opportunity>();
        Map<String, String> OldOpportunityNewOpportunityIdMap = new Map<String, String>();
        for(ServiceContract oldServiceContract : originalSCS){
			if(originalSCRenewalOppsMap.get(oldServiceContract.Id) != NULL){
				Opportunity oldServiceContractOpportunity = originalOppsMap.get(originalSCRenewalOppsMap.get(oldServiceContract.Id));
				Opportunity newRenewalOpportunity = oldServiceContractOpportunity.clone(false,true,false,false);
				newRenewalOpportunity.Service_Contract_Siebel_ID__c = null;
		        newRenewalOpportunity.Legacy_EMG_Id__c = null;
		        newRenewalOpportunity.Opportunity_Status__c = getOpportunityStatus(oldServiceContractOpportunity.Opportunity_Status__c);
		        newRenewalOpportunity.Previous_Service_Contract_Amount__c  =  oldServiceContract.Maintenance_Amount__c;                   
		        newRenewalOpportunity.Previous_Service_Contract_Maint_Value__c =  oldServiceContract.Maintenance_Amount__c;
		        newRenewalOpportunity.Previous_Service_Contract_Number__c =  oldServiceContract.Name; 
		        newRenewalOpportunity.BusinessPartner__c = transferDetails[0].Sold_To_Transfer_Request_Header__r.Target_Sold_To__c;
		        newRenewalOpportunity.TrackingOpportunityId__c = oldServiceContractOpportunity.Id;
		        clearAllQuoteRelatedFields(newRenewalOpportunity);
	            newOpportunities.add(newRenewalOpportunity);
			}
        }
        if(newOpportunities.size() > 0){
        	insert newOpportunities;
        	for(Opportunity newOpp: newOpportunities)
        		OldOpportunityNewOpportunityIdMap.put(newOpp.TrackingOpportunityId__c, newOpp.Id);
        }
        
        // Create new Service Contracts --> Set Start Date as today, Status as Active, Set Sold To as Requested Sold To
        List<ServiceContract> newServiceContracts = new List<ServiceContract>();
        Map<String, String> OldSCNewSCIdMap = new Map<String, String>();
		for(ServiceContract oldServiceContract : originalSCS){
            ServiceContract newServiceContract = oldServiceContract.clone(false, true);
            newServiceContract.End_User_Name__c = transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__c;
            newServiceContract.Sold_To_Name__c = transferDetails[0].Sold_To_Transfer_Request_Header__r.Target_Sold_To__c;
            if(originalSCRenewalOppsMap.get(oldServiceContract.id) != NULL && OldOpportunityNewOpportunityIdMap.get(originalSCRenewalOppsMap.get(oldServiceContract.id)) != NULL){
            	newServiceContract.Renewal_Opportunity__c = OldOpportunityNewOpportunityIdMap.get(originalSCRenewalOppsMap.get(oldServiceContract.id));
            } else {
            	newServiceContract.Renewal_Opportunity__c = NULL;	
            }
            newServiceContract.Siebel_ID__c = null;
            newServiceContract.Agreement_Status__c ='Active';
            //newServiceContract.Quote_Name__c = null;
            newServiceContract.Maintenance_Amount__c = 0.0;
            newServiceContract.Name = 'Test';
            if(newServiceContract.Original_Service_Contract__c == null) {
                newServiceContract.Original_Service_Contract__c = oldServiceContract.id;
            }
            if(oldServiceContract.StartDate >=  Date.today())
            	newServiceContract.StartDate = oldServiceContract.StartDate;	
            else if(oldServiceContract.EndDate >=  Date.today())
            	newServiceContract.StartDate = Date.today(); 
            newServiceContract.TrackingServiceContractId__c = oldServiceContract.id;	
            newServiceContract.Maintenance_Amount__c = oldServiceContract.Maintenance_Amount__c;
            newServiceContract.Override_Offering_Type__c = oldServiceContract.Override_Offering_Type__c;
            newServiceContract.Quote_Name__c = oldServiceContract.Quote_Name__c;
            newServiceContracts.add(newServiceContract);
		}
		if(newServiceContracts.size() > 0){
        	insert newServiceContracts;
        	for(ServiceContract newSC: newServiceContracts)
        		OldSCNewSCIdMap.put(newSC.TrackingServiceContractId__c, newSC.Id);
        }
        
        // Create Contract Line Items for new Service Contracts
       
		String oldServiceContractLineItemsSOQL = CloneUtility.getCreatableFieldsSOQL('ContractLineItem','ServiceContractId IN ('+originalServiceContractIdsStr +')');  
        List<ContractLineItem> lineItemsFromOldServiceContract = (List<ContractLineItem>)Database.query(oldServiceContractLineItemsSOQL ); 
        List<ContractLineItem> newContractlineItems = new  List<ContractLineItem>();

        for(ContractLineItem cli : lineItemsFromOldServiceContract){
            ContractLineItem newCli = new ContractLineItem();
            newCli.ServiceContractid = OldSCNewSCIdMap.get(cli.ServiceContractid ); 
            newCli.PricebookEntryId = cli.PricebookEntryId;
            newCli.Quantity =  cli.Quantity; 
            newCli.UnitPrice = cli.UnitPrice; 
            newCli.Siebel_ID__c = null;
            newCli.Lic_Invoice__c = cli.Lic_Invoice__c;
            newCli.Original_License_Invoice_Date__c = cli.Original_License_Invoice_Date__c;
            
            if(cli.Maintenance_Start_Date__c >= Date.today())
            	newCli.Maintenance_Start_Date__c = cli.Maintenance_Start_Date__c;
            else if(cli.Maintenance_End_Date__c >= Date.today())
        		newCli.Maintenance_Start_Date__c = Date.today(); 
        	else
        		newCli.Maintenance_Start_Date__c = cli.Maintenance_End_Date__c;
            newCli.Maintenance_End_Date__c = cli.Maintenance_End_Date__c;
            newCli.Sales_Order__c = cli.Sales_Order__c;
            newCli.Original_PO__c = cli.Original_PO__c;
            newCli.Current_Quantity__c = cli.Current_Quantity__c;
            newCli.Actual_Original_Quantity__c = cli.Current_Quantity__c;
            newCli.Original_Quantity__c = cli.Current_Quantity__c;
            newCli.Non_Billable__c = cli.Non_Billable__c;
            newCli.Annualized_Maintenance_Due__c = cli.Annualized_Maintenance_Due__c;
            newCli.Previous_Line_Maintenance_Value__c = cli.Previous_Line_Maintenance_Value__c;
            newCli.Original_Net_License_value__c = cli.Original_Net_License_value__c;
            newCli.Revised_Net_License_value__c = cli.Revised_Net_License_value__c;
            
            newCli.Upgraded_Product__c = cli.Upgraded_Product__c;
            newCli.Override_License_Metric__c = cli.Override_License_Metric__c;
            newCli.Maintenance_Level__c = cli.Maintenance_Level__c;
            newCli.Original_License_Invoice__c = cli.Original_License_Invoice__c;
            newCli.Agreement_Status__c = 'Active';
            // Add records in contract line item List
            newContractlineItems.add(newCli);
        }
		if(newContractlineItems.size() > 0){
			Database.insert(newContractlineItems, false);	
		}
		
		// Fetch service contracts for latest information            
        List<ServiceContract> scTempList = [SELECT id, Name, Agreement_Number__c, End_User_Name__c,Sold_To_Name__c, Renewal_Opportunity__c, Sold_To_Name__r.name, End_User_Name__r.name  from ServiceContract where id IN : newServiceContracts];
        // Update all Service Contract for their names
        for(ServiceContract sc : scTempList){
            sc.Name = sc.Agreement_Number__c + '-T';
        }            
        Update scTempList;
            
		// Updated Opportunity Names
		Map<Id, Opportunity> oppTempMap = new Map<Id, Opportunity>();
        for(Opportunity opp: newOpportunities){
            oppTempMap.put(opp.id, opp);
        }
		for(ServiceContract sc: scTempList){
            if(sc.Renewal_Opportunity__c != NULL){
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
        }            
        update oppTempMap.values(); 
        
		// Update old Service Contracts
		// Finally Set the Status on Old Service Contracts Opporunity to Closed Transferred
		
		for(ServiceContract sc:  originalSCS){
			sc.Agreement_Status__c = 'Transferred';
		}
		update originalSCS;	
		
		// Update old Renewal Opportunities
		for(Opportunity opp:  originalOpps){
			opp.Opportunity_Status__c = 'Closed Transferred'; 
		}
		update originalOpps;	
		
		// Update Transfer Request Details and Header
		for(Sold_To_Transfer_Request_Detail__c stt : transferDetails){
			stt.Transferred_Service_Contract__c = OldSCNewSCIdMap.get(stt.Original_Service_Contract__c);	
		}
		Update transferDetails;
		
		Util.Bypass_Trigger_Chk = false;
		// ******************************************************************************************************************
		// Send Email Transfer Info to Genesys Care Team
     	String EmailBody,sSubject;
     	List<String> lstEmail = new List<String>();
     	String emailAddressedTo = '';
		if(transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_specialist__c != NULL){
			lstEmail.add(transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_specialist__r.Email);
			emailAddressedTo = transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_specialist__r.Name;	
		}
		
     	if(transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_Ops__c != NULL){
			lstEmail.add(transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_Ops__r.Email);	
			if(emailAddressedTo == '')
				emailAddressedTo = transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_Ops__r.Name;
			else
				emailAddressedTo = emailAddressedTo + ' AND ' + transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__r.Genesys_Care_Ops__r.Name;
		}
		emailAddressedTo = 'Hello ' + emailAddressedTo;
		
		If(Test.isRunningTest())
			lstEmail.add(UserInfo.getUserEmail());
		
		Set<String> selectedSCSoldTos = new Set<String>();
     	for(Sold_To_Transfer_Request_Detail__c sttrd : transferDetails){
			selectedSCSoldTos.add(sttrd.Original_Service_Contract__r.Sold_To_Name__c);
     	}
		List<BigMachines__Quote__c> pendingQuotes = [SELECT id, Name, BigMachines__Status__c, End_User_ID__c, End_User_ID__r.Name, Sold_To_Name__c, Sold_To_Name__r.Name 
						     							FROM BigMachines__Quote__c WHERE End_User_ID__c = :transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__c AND Sold_To_Name__c IN :selectedSCSoldTos 
						     							AND BigMachines__Is_Primary__c = true AND BigMachines__Status__c IN ('Quote In Progress', 'Quote Approved')];
		
		if(lstEmail.size() > 0 && pendingQuotes.size() > 0){
	     	sSubject = 'A Completed Sold To Transfer has been completed for ' + transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__r.Name;
	     	EmailBody = '<html><body>';
	     	EmailBody = EmailBody + emailAddressedTo;
	     	EmailBody = EmailBody + '<BR/><BR/>';
	     	EmailBody = EmailBody + 'A Sold To Transfer for End User ' + transferDetails[0].Sold_To_Transfer_Request_Header__r.Account__r.Name + ' has been completed and it impacts one or more of your quotes. Please see the details of the Sold To Transfer here: <link to STTA Header>';
			EmailBody = EmailBody + '<BR/><BR/>';
			EmailBody = EmailBody + 'The impacted quotes are: ';
			EmailBody = EmailBody + '<BR/><BR/>';
	     	EmailBody = EmailBody + '<TABLE BORDER="1">';
			EmailBody = EmailBody + '	<TR><TD>Quote Name</TD><TD>Original Sold To</TD><TD>Target Sold To</TD></TR>';
			for(BigMachines__Quote__c quote : pendingQuotes){
				EmailBody = EmailBody + '	<TR><TD>' + quote.Name + '</TD><TD>' + quote.Sold_To_Name__r.Name + '</TD><TD>' + transferDetails[0].Sold_To_Transfer_Request_Header__r.Target_Sold_To__r.Name + '</TD></TR>';
	     	}
			EmailBody = EmailBody + '</TABLE>';
			EmailBody = EmailBody + '<BR/><BR/>';
			EmailBody = EmailBody + 'Please review to determine what actions are needed. You may contact Genesys Licensing with any questions or concerns.';
			EmailBody = EmailBody + '<BR/><BR/>';
			EmailBody = EmailBody + 'Thanks,';
			EmailBody = EmailBody + 'Salesforce';
			EmailBody = EmailBody + '</body></html>';
			// Send email
       		Util.EmailNotification(EmailBody, sSubject, lstEmail);
		}
		
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
    
    public static String getOpportunityStatus(String currentStatus){
		Map<String, String> OpportunityStatusMap = new Map<String, String>();
	 	OpportunityStatusMap.put('Cancelled','Cancelled');
	 	OpportunityStatusMap.put('Renewed','Renewed');
	 	OpportunityStatusMap.put('Closed CoTerm','Closed CoTerm');
	 	OpportunityStatusMap.put('Closed-CoTerm','Closed-CoTerm');
	 	OpportunityStatusMap.put('Duplicate','Duplicate');
	 	OpportunityStatusMap.put('Non-Renewed','Non-Renewed');
	 	OpportunityStatusMap.put('Declined','Declined');
	 	OpportunityStatusMap.put('Dropped','Dropped');
	 	OpportunityStatusMap.put('Split','Split');
	 	OpportunityStatusMap.put('Prior Siebel','Prior Siebel');
		OpportunityStatusMap.put('Non Renewed','Non Renewed');
		
	 	OpportunityStatusMap.put('In Progress','In Progress');
	 	OpportunityStatusMap.put('CoTerm Pending','In Progress');
	 	OpportunityStatusMap.put('CO-Term Pending','In Progress');
	 	OpportunityStatusMap.put('Quoted','In Progress');
	 	OpportunityStatusMap.put('With Customer','In Progress');
	 	OpportunityStatusMap.put('Sent To Customer','In Progress');
	 	OpportunityStatusMap.put('Hypothetical','In Progress');
		
		String newStatus = '';
		if(OpportunityStatusMap.containsKey(currentStatus)){
			newStatus = OpportunityStatusMap.get(currentStatus); 	
		} else {
			newStatus = currentStatus;
		}
		return newStatus;
     }
}