/*
10/10/2013    Naresh Kumar    Handler Class for Non Revenue Orders
*/
public without sharing class NonRevenueOrderHandler {
	
	public static void populateNROApprovalRequired(List < Order_Line_Item__c > newList) {
		//Updating PM Approval Required for NRO Orders
		Set < Id > orderIdsToBeUpdated = new Set < Id > ();
		for(Order_Line_Item__c eachLineItem: newList) {
			if(eachLineItem.PM_Approval_Required_Product__c)
				orderIdsToBeUpdated.add(eachLineItem.Order__c);
		}
		System.debug('NKC debug orderIdsToBeUpdated [' + orderIdsToBeUpdated + ']');
		List < Order__c > ordersToBeUpdated = [SELECT PM_Approval_Required__c FROM Order__c WHERE id IN: orderIdsToBeUpdated
			AND RecordType.DeveloperName = 'Non_Revenue_Orders'
		];
		for(Order__c eachOrder: ordersToBeUpdated)
			eachOrder.PM_Approval_Required__c = true;

		if(!ordersToBeUpdated.isEmpty())
			update ordersToBeUpdated;
	}

	public static void updateServiceContractsAndLineItems(Map < Id, Order__c > newMap, Map < Id, Order__c > oldMap) {
		Map < Id, ServiceContract > scsToUpdate = new Map < Id, ServiceContract > ();
		System.debug('Entered Update in Handler 3 >>>>>>>');
        System.debug('newMap.values()>>>>>'+ newMap.values());
		for(Order__c o: newMap.values()) {
			//            for( ServiceContract sc : o.Service_Contracts__r ){
			for(ServiceContract sc: [select id from ServiceContract where order__c =: o.id]) {
				System.debug('Entered Update in Handler 3 1/2  >>>>>>> SC' + o.Service_Contracts__r + sc.Id);
				if(o.Status__c == 'Completed') {
					System.debug('Status is completed >>>>>>>');
					sc.StartDate = o.Maintenance_Start__c;
					sc.EndDate = o.Maintenance_End__c;
					sc.Quote_Name__c = o.Quote__c;
					sc.Agreement_Status__c = 'Active';
					scsToUpdate.put(sc.Id, sc);
                    System.debug('scsToUpdate>>>>>'+ scsToUpdate);
                    System.debug('sc in if cond >>>>>'+ sc);
                    
				}
			}
		}
		System.debug('Entered Update in Handler 4  >>>>>>> Map.size' + scsToUpdate.size());
		if(!scsToUpdate.isEmpty()) {
			System.debug('Entered Update in Handler 5  >>>>>>> Map.size' + scsToUpdate.size());
            System.debug('scsToUpdate>>>>>'+ scsToUpdate);
            System.debug('scsToUpdateValues>>>>>'+ scsToUpdate.values());
			update scsToUpdate.values();
			List < ContractLineItem > clis = ServiceContractUtil.getClis(scsToUpdate.values());
			if(!clis.isEmpty()) {
				for(ContractLineItem cli: clis) {
					cli.Agreement_Status__c = 'Active';
					cli.Original_License_Invoice_Date__c = Date.today();
					cli.StartDate = scsToUpdate.get(cli.ServiceContractId).startDate;
					cli.EndDate = scsToUpdate.get(cli.ServiceContractId).endDate;
					cli.Maintenance_Start_Date__c = scsToUpdate.get(cli.ServiceContractId).startDate;
					cli.Maintenance_End_Date__c = scsToUpdate.get(cli.ServiceContractId).endDate;
				}
				update clis;
			}
		}
	}


	public static void createServiceContractForNRO(Map < Id, Order__c > newMap, Map < Id, Order__c > oldMap) {
		List < ServiceContract > serviceContractToBeInserted = new List < ServiceContract > ();
		List < ServiceContract > existingSCs = [SELECT id, Order__c FROM ServiceContract WHERE Order__c IN: newMap.keyset()];
		Boolean isUpdate = false;
		Set < Id > scIds = new Set < Id > ();
		Map < Id, Id > mapOrderIdVsSCId = new Map < Id, Id > ();
		for(ServiceContract eachSC: existingSCs) {
			mapOrderIdVsSCId.put(eachSC.Order__c, eachSC.id);
		}
		for(Order__c eachOrder: newMap.values()) {
			if(eachOrder.Status__c == 'Approved' && eachOrder.Status__c != oldMap.get(eachOrder.id).Status__c &&
				(eachOrder.Maintenance_Start__c != null && eachOrder.Maintenance_End__c != null)
			) {

				ServiceContract newSC;
				//Creating new service contract
				if(mapOrderIdVsSCId.get(eachOrder.id) == null)
					newSC = new ServiceContract();
				else {
					//Updating existing service contract
					newSC = new ServiceContract(id = mapOrderIdVsSCId.get(eachOrder.id));
					isUpdate = true;
					scIds.add(mapOrderIdVsSCId.get(eachOrder.id));
				}
				newSC.Name = eachOrder.Name;
				newSC.Order__c = eachOrder.Id;
				newSC.Quote_Name__c = eachOrder.Quote__c;
				newSC.End_User_Name__c = eachOrder.End_User_Name__c;
				newSC.CurrencyISOCode = eachOrder.CurrencyISOCode;
				newSC.Sold_To_Name__c = eachOrder.Sold_To_Name__c;
				newSC.Support_Owner__c = eachOrder.Support_Owner__c;
				newSC.System_Integrator__c = eachOrder.System_Integrator__c;
				newSC.Discount_Total_Maint_Amount_Due__c = eachOrder.Discount_Total_Maint_Amount_Due__c;
				newSC.Net_License__c = eachOrder.Net_License__c;
				newSC.Revised_Net_License_Value__c = eachOrder.Revised_Net_License_Value__c;
				newSC.Ext_Net_License__c = eachOrder.Ext_Net_License__c;
				newSC.List_Price__c = eachOrder.List_Price__c;
				newSC.Original_Quantity__c = eachOrder.Original_Quantity__c;
				newSC.PO_Number__c = eachOrder.PO_Number__c;
				newSC.Sales_Order__c = eachOrder.Sales_Order__c;
				newSC.Original_License_Invoice_Date__c = eachOrder.Original_License_Invoice_Date__c;
				newSC.Maintenance_Invoice_Date__c = eachOrder.Maintenance_Invoice_Date__c;
				newSC.Quarterly_Semi_Annual_Billing_Fee__c = eachOrder.Quarterly_Semi_Annual_Billing_Fee__c;
				newSC.Licensing_Reduction_Fee__c = eachOrder.Licensing_Reduction_Fee__c;
				newSC.Reinstatement_Fee__c = eachOrder.Reinstatement_Fee__c;
				newSC.Partner_to_Partner_Uplift__c = eachOrder.Partner_to_Partner_Uplift__c;
				newSC.Extended_End_of_Support__c = eachOrder.Extended_End_of_Support__c;
				newSC.Partner_to_Direct__c = eachOrder.Partner_to_Direct__c;
				newSC.Comments__c = eachOrder.Comments__c;
				newSC.Decreased_Quote_Reason__c = eachOrder.Decreased_Quote_Reason__c;
				newSC.Cancelled_Quote_Reason__c = eachOrder.Cancelled_Quote_Reason__c;
				newSC.Total_Discount__c = eachOrder.Total_Discount__c;
				newSC.Sent_to_Customer__c = eachOrder.Sent_to_Customer__c;
				newSC.Genesys_Care_Rep_name__c = eachOrder.Genesys_Care_Rep_name__c;
				newSC.Genesys_Care_rep_Title__c = eachOrder.Genesys_Care_rep_Title__c;
				newSC.Genesys_Care_rep_Phone__c = eachOrder.Genesys_Care_rep_Phone__c;
				newSC.Genesys_Care_rep_email__c = eachOrder.Genesys_Care_rep_email__c;
				newSC.Genesys_Care_rep_cell__c = eachOrder.Genesys_Care_rep_cell__c;
				newSC.Current_Maint_Rate__c = eachOrder.Current_Maint_Rate__c;
				newSC.Previous_Maint_Rate__c = eachOrder.Previous_Maint_Rate__c;
				newSC.Bill_To_Name__c = eachOrder.Bill_To_Name__c;
				newSC.Ship_To_Name__c = eachOrder.Ship_To_Name__c;
				newSC.Big_Six__c = eachOrder.Big_Six__c;
				newSC.Sales_Org__c = eachOrder.Sales_Org__c;
				newSC.Genesys_Care__c = eachOrder.Genesys_Care__c;
				newSC.Original_License_Invoice__c = eachOrder.Invoice_Number__c;
				newSC.StartDate = eachOrder.Maintenance_Start__c;
				newSC.EndDate = eachOrder.Maintenance_End__c;
				newSC.Service_Level__c = eachOrder.Service_Level__c;
				newSC.Agreement_Status__c = 'Pending';
				newSC.NRO_Type__c = eachOrder.NRO_Type__c;
                //Added below line by Ankit on 09/06/2016
                newSC.Service_Contract_Type__c = Global_Setting__c.getInstance(eachOrder.NRO_Type__c).Information__c;
                
                
				for(PricebookEntry pbe: [SELECT Product2Id, Pricebook2Id, Id, CurrencyIsoCode
						FROM PricebookEntry WHERE Pricebook2.IsStandard = true
						AND Pricebook2.IsActive = true AND CurrencyIsoCode =: eachOrder.CurrencyISOCode
					]) {
					newSC.pricebook2Id = pbe.pricebook2Id;

				}
				serviceContractToBeInserted.add(newSC);
				if(eachOrder.End_User_Name__c != null && eachOrder.NRO_Type__c == 'Pay Per Use'){
					List<Account> endUser = [SELECT id, Type FROM Account WHERE id =: eachOrder.End_User_Name__c];
					if(!endUser.isEmpty() && endUser[0].Type == 'Prospect'){
						Account accToBeUpdated = new Account(id = eachOrder.End_User_Name__c, Status__c = 'Active', Type = 'Customer');
						update accToBeUpdated;
					}
				}
			}
		}
		if(!serviceContractToBeInserted.isEmpty())
			upsert serviceContractToBeInserted;
		if(isUpdate) {
			List < ContractLineItem > contractLineItems = [SELECT id FROM ContractLineItem WHERE ServiceContractId IN: scIds];
			delete contractLineItems;
		}
		createServiceContractLineItems(serviceContractToBeInserted);
		Set < Order__c > orderSet = new Set < Order__c > ();
		for(Order__c eachOrder: newMap.values()) {
			if(eachOrder.Status__c == 'Approved' && eachOrder.Status__c != oldMap.get(eachOrder.id).Status__c &&
				(eachOrder.Maintenance_Start__c != null && eachOrder.Maintenance_End__c != null) 
                && (eachOrder.NRO_Type__c == 'Entitlement Adjustment' || eachOrder.NRO_Type__c == 'Data Correction'))
				orderSet.add(eachOrder);
		}
		System.debug('NKC debug orderSet [' + orderSet + ']');
		if(!orderSet.isEmpty())
			ServiceContractUtil.createRenewalOpportunities(orderSet, null);
	}
	
	public static void createServiceContractLineItems(List < ServiceContract > serviceContracts) {
		Map < Id, ServiceContract > mapOrderIdVsSCId = new Map < Id, ServiceContract > ();
		for(ServiceContract eachSC: serviceContracts) {
			mapOrderIdVsSCId.put(eachSC.Order__c, eachSC);
		}
		List < ContractLineItem > contractLineItemsToBeInserted = new List < ContractLineItem > ();
		List < Order_Line_Item__c > orderLineItems = [Select Id, Order__c, Quote_Product__c, Product__c, Product__r.Description, BigMachines_Quantity__c, End_Support_Date__c,
			Order__r.Invoice_Number__c, Order__r.Invoice_Date__c,
			Order__r.PO_Number__c, Order__r.Previous_Line_Maintenance_Value__c,
			Order__r.Revised_Net_License_Value__c, Order__r.Maintenance_Level__c,
			Order__r.Opportunity__c, Sales_Price__c, Pricebook_Entry_ID__c,
			Maintenance_Due__c, Fees_Applied__c, Comment__c, Genesys_Care_Rate__c,
			Increase__c, Revised_Net_License_Value__c, Extended_End_of_Support__c,
			Sold_To_Name__c, End_User_Name__c, Maintenance_Start_Date__c,
			Maintenance_End_Date__c, Contract_Line_Update_Status__c, Original_Qty__c,
			Current_Qty__c, Product__r.Type__c, Order__r.Original_License_Invoice_Date__c,
			Total_Price__c, Original_Net_License_value__c, Order__r.CurrencyIsoCode, Annualized_Maintenance_Due__c,
			Order__r.Maintenance_Start__c, Order__r.Maintenance_End__c, Contract_Line_Item__c, Contract_Line_Item__r.Non_Billable__c, Order__r.Sold_To_Name__c,
			Order__r.NRO_Type__c, Lic_Invoice__c, Original_License_Invoice_Date__c,
			// 1/21/2015 : To Copy additional information for PS product (if present)
			Project_ID__c, Project_Name__c, Third_Party_Applications__c, Third_Party_Partners__c,
			// 2/5/2015 : few more fields
			Application_Support_Cost_Base__c, Solution_Names_Covered__c, Third_Party_Partner_Fee__c
			from Order_Line_Item__c where Order__c IN: mapOrderIdVsSCId.keySet()
		];

		Set < Id > product2Ids = new Set < Id > ();
		Set < String > isoCodes = new Set < String > ();
        String strOrderCurrency;
		for(Order_Line_Item__c eachOLI: orderLineItems) {
            strOrderCurrency = eachOLI.Order__r.CurrencyIsoCode;
			product2Ids.add(eachOLI.Product__c);
			isoCodes.add(strOrderCurrency);
		}

		System.debug('NKC debug product2Ids [' + product2Ids + ']');
		System.debug('NKC debug isoCodes [' + isoCodes + ']');		

		Map < Id, List < PricebookEntry >> pb2IdToPBE = new Map < Id, List < PricebookEntry >> ();
		if(!product2Ids.isEmpty()) {
            ServiceContractUtil.setProductPriceBooks(product2Ids, strOrderCurrency);
			for(PricebookEntry pbe: [SELECT Product2Id, Pricebook2Id, Id, CurrencyIsoCode
					FROM PricebookEntry WHERE Pricebook2.IsStandard = true
					AND Pricebook2.IsActive = true AND CurrencyIsoCode IN: isocodes
					AND Product2Id IN: product2Ids
				]) {
				if(!pb2IdToPBE.containsKey(pbe.Product2Id))
					pb2IdToPBE.put(pbe.Product2Id, new List < PricebookEntry > {
						pbe
					});
				else
					pb2IdToPBE.get(pbe.Product2Id).add(pbe);
			}
		}

		for(Order_Line_Item__c eachOLI: orderLineItems) {
			ServiceContract sc = mapOrderIdVsSCId.get(eachOLI.Order__c);
			ContractLineItem newCLI = new ContractLineItem();
			newCLI.Order_Line_Item__c = eachOLI.id;
			newCLI.ServiceContractId = sc.Id;
			newCLI.Quantity = eachOLI.BigMachines_Quantity__c;
			newCLI.Sold_To_Name_Lookup__c = eachOLI.Order__r.Sold_To_Name__c;
			newCLI.Upgraded_Product__c = eachOLI.Product__c;
			newCLI.Quote_Product__c = eachOLI.Quote_Product__c;
			newCLI.StartDate = sc.StartDate;
			newCLI.EndDate = sc.EndDate;
			newCLI.Agreement_Status__c = sc.Agreement_Status__c;
			newCLI.UnitPrice = eachOLI.Sales_Price__c;
			newCLI.Original_License_Invoice__c = eachOLI.Order__r.Invoice_Number__c;

			newCLI.Original_PO__c = eachOLI.Order__r.PO_Number__c;
			newCLI.Previous_Line_Maintenance_Value__c = eachOLI.Maintenance_Due__c;
			newCLI.Revised_Net_License_value__c = eachOLI.Order__r.Revised_Net_License_Value__c;
			newCLI.Maintenance_Level__c = eachOLI.Order__r.Maintenance_Level__c;
			newCLI.End_Support_Date__c = eachOLI.End_Support_Date__c;
			newCLI.Fees_Applied__c = eachOLI.Fees_Applied__c;
			newCLI.Comments__c = eachOLI.Comment__c;
			newCLI.Genesys_Care_Rate__c = eachOLI.Genesys_Care_Rate__c;
			newCLI.Increase__c = eachOLI.Increase__c;

			newCLI.Extended_End_of_Support__c = eachOLI.Extended_End_of_Support__c;
			newCLI.Sold_To_Name__c = eachOLI.Sold_To_Name__c;
			newCLI.End_User_Name__c = eachOLI.End_User_Name__c;
			newCLI.Maintenance_Start_Date__c = eachOLI.Maintenance_Start_Date__c;
			newCLI.Maintenance_End_Date__c = eachOLI.Maintenance_End_Date__c;
			newCLI.Agreement_Status__c = sc.Agreement_Status__c;
			newCLI.Previous_Maintenance_Rate__c = sc.Previous_Maint_Rate__c;
			newCLI.Current_Maintenance_Rate__c = sc.Current_Maint_Rate__c;

			newCLI.Contract_Line_Item__c = eachOLI.Contract_Line_Item__c;
			newCLI.Non_Billable__c = eachOLI.Contract_Line_Item__r.Non_Billable__c != NULL ? eachOLI.Contract_Line_Item__r.Non_Billable__c : false;

			newCLI.Current_Quantity__c = eachOLI.BigMachines_Quantity__c;
			newCLI.Original_Quantity__c = eachOLI.BigMachines_Quantity__c;
			newCLI.Maintenance_Start_Date__c = eachOLI.Order__r.Maintenance_Start__c;
			newCLI.Maintenance_End_Date__c = eachOLI.Order__r.Maintenance_End__c;
			newCLI.Quantity = eachOLI.BigMachines_Quantity__c;
			newCLI.UnitPrice = (eachOLI.Sales_Price__c == null ? 0 : eachOLI.Sales_Price__c);

			// 1/21/2015 : To Copy additional information for PS product (if present)
			newCLI.Project_ID__c = eachOLI.Project_ID__c;
			newCLI.Project_Name__c = eachOLI.Project_Name__c;
			newCLI.Third_Party_Partner__c = eachOLI.Third_Party_Partners__c;
			newCLI.Third_Party_Applications__c = eachOLI.Third_Party_Applications__c;
			newCLI.Third_Party_Partner_Fee__c = eachOLI.Third_Party_Partner_Fee__c;
			newCLI.Solution_Name__c = eachOLI.Solution_Names_Covered__c;
			newCLI.Application_Support_Cost_Base__c = eachOLI.Application_Support_Cost_Base__c;

			if(eachOLI.Order__r.NRO_Type__c == 'Entitlement Adjustment') {
				newCLI.Revised_net_license_value__c = eachOLI.Revised_net_license_value__c;
				newCLI.Original_Net_License_value__c = eachOLI.Original_Net_License_Value__c;
				newCLI.Lic_Invoice__c = eachOLI.Lic_Invoice__c;
				newCLI.Original_License_Invoice_Date__c = eachOLI.Original_License_Invoice_Date__c;
				newCLI.Annualized_Maintenance_Due__c = eachOLI.Annualized_Maintenance_Due__c;
				//newCLI.Maintenance_Due__c = eachOLI.Maintenance_Due__c;
			} else {
				newCLI.Annualized_Maintenance_Due__c = eachOLI.Annualized_Maintenance_Due__c;
				newCLI.Original_Net_License_value__c = eachOLI.Total_Price__c;
				newCLI.Revised_Net_License_value__c = eachOLI.Total_Price__c;
				newCLI.Lic_Invoice__c = eachOLI.Order__r.Invoice_Number__c;
				newCLI.Original_License_Invoice_Date__c = eachOLI.Order__r.Original_License_Invoice_Date__c;
			}
			if(pb2IdToPBE.get(eachOLI.Product__c) != null) {
				for(PricebookEntry pbe: pb2IdToPBE.get(eachOLI.Product__c)) {
					if(pbe.CurrencyIsoCode == eachOLI.Order__r.CurrencyIsoCode)
						newCLI.PricebookEntryId = pbe.Id;
				}
			}
			contractLineItemsToBeInserted.add(newCLI);
		}
		if(!contractLineItemsToBeInserted.isEmpty())
			insert contractLineItemsToBeInserted;

	}
}