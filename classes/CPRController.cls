public class CPRController {
	// Variable to decide whether the page is invoked from CPR Tab or it is invoved from some URL
    public String cprFrom {get; set;}
    
    // Variable for Account Input Capture
    public CPR_Report__c accountInput {get; set;}
    //public CPR_Report__c cprReport {get; set;}

    public CPR_Report__c pureEngageCPRReport {get; set;}
    public CPR_Report__c pureConnectCPRReport {get; set;}
    
    public Account account {get; set;}
    public List<CPRWrapper> cprItems {get; set;}
 
    public string platformType {get; set;}
    public List<SelectOption> platformTypes {get; set;}
    
    public Integer pureEngageCount {get; set;}
    public Integer pureConnectCount {get; set;}
    
    public CPRController(){
        pureEngageCount = 0;
        pureConnectCount = 0;
        
        platformType = '';
        // Collect Parameters if any 
        cprFrom = 'tab';
        if(ApexPages.CurrentPage().getparameters().get('cprFrom') != null){ 
        	cprFrom = ApexPages.CurrentPage().getparameters().get('cprFrom');
        } 
        accountInput = new CPR_Report__c();
        if(ApexPages.CurrentPage().getparameters().get('accid') != null){ 
        	accountInput.Account__c = ApexPages.CurrentPage().getparameters().get('accid');
        }
        if(ApexPages.CurrentPage().getparameters().get('platformType') != NULL){
            platformType = ApexPages.CurrentPage().getparameters().get('platformType');   
        }
        if(accountInput.Account__c != NULL){
            if(String.isBlank(platformType)){
                checkPlatformType();
            }
            createCPR();
        }
    }
    
    public void loadCPRComments(){
        // Pure Engage CPR Comments
        List<CPR_Report__c> pureEngageCPRReportRecords = [SELECT id, CPR_Comments__c FROM CPR_Report__c 
                                                          WHERE Account__c = :accountInput.Account__c AND Offering_Type__c = 'PureEngage'];
        if(!pureEngageCPRReportRecords.isEmpty())
       		pureEngageCPRReport = pureEngageCPRReportRecords[0];
        else {
            pureEngageCPRReport = new CPR_Report__c(Account__c = accountInput.Account__c, CPR_Comments__c = '', Offering_Type__c = 'PureEngage');
            if(pureEngageCount > 0)
            	insert pureEngageCPRReport;
        }
        
        // Pure Connect CPR Comments
        List<CPR_Report__c> pureConnectCPRReportRecords = [SELECT id, CPR_Comments__c FROM CPR_Report__c 
                                                          WHERE Account__c = :accountInput.Account__c AND Offering_Type__c = 'PureConnect'];
        if(!pureConnectCPRReportRecords.isEmpty())
       		pureConnectCPRReport = pureConnectCPRReportRecords[0];
        else {
            pureConnectCPRReport = new CPR_Report__c(Account__c = accountInput.Account__c, CPR_Comments__c = '', Offering_Type__c = 'PureConnect');
            if(pureConnectCount > 0)
            	insert pureConnectCPRReport;
        }
    }

    public void createCPR(){
        if(cprFrom == 'tab'){
        	loadCPRComments();
        }
        Boolean isPureEngagePrem = (platformType == 'PureEngage') ? true : false;
        Boolean isPureConnectPrem = (platformType == 'PureConnect') ? true : false;
        
		Id NROOrderRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Non-Revenue Orders').getRecordTypeId();
        Id GenesysRenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
       
        account = [select Id, CPR__c, CPR_2__c, Name from Account where id = :accountInput.Account__c];

        // Query Contract Line Items for Calculating 1. Split (Transfer), 2. Drop/ Downsize, 3. Retired, 4. Shelved, 5. In Negotiation/ Pending
         List<ContractLineItem> contractLineItems = [SELECT id, ServiceContract.Order__r.recordTypeId,ServiceContract.Opp_Status__c ,ServiceContract.Cancellation_Reason__c,
                                                     Servicecontract.End_User_Name__c,ServiceContract.Renewal_Opportunity__r.Split_Parent_Quote__r.BigMachines__Status__c,
                                                     ServiceContract.Renewal_Opportunity__r.Account.id, ServiceContract.Renewal_Opportunity__r.Opportunity_Status__c,
                                                     ServiceContract.Renewal_Opportunity__r.Split_Parent_Quote__r.Order__r.Status__c,
                                                     ServiceContract.Renewal_Opportunity__r.Quote_Quote_Status__c,
                                                     pricebookentry.product2Id, pricebookentry.product2.Base_Item__c, pricebookentry.product2.APN_Number__c,
                                                     pricebookentry.product2.Name, Current_Quantity__c,ServiceContract.Agreement_Status__c,
                                                     ServiceContract.order__c, ServiceContract.order__r.RecordType.id, Maintenance_Start_Date__c, Maintenance_End_Date__c
                                                     ,ServiceContract.Service_Contract_Type__c
                                                     FROM contractLineItem 
                                                     WHERE ( Servicecontract.Agreement_Status__c IN ('Split', 'Drop', 'Retired', 'Shelved', 'Downsize', 'In Negotiation', 'Pending')  
                                                         OR (ServiceContract.Opp_Status__c = 'Cancelled' 
                                                             	AND  ServiceContract.Cancellation_Reason__c NOT IN ('Went Indirect' , 
                                                                                                                     'Went Direct' , 
                                                                                                                     'Switched Partner', 
                                                                                                                     'Prior Hypothetical', 
                                                                                                                     'Duplicate - mark for deletion',
                                                                                                                     'Change of VAR/Sold To',
                                                                                                                     'Merged onto a new quote')
                                                             )
                                                     ) 
                                                     AND (servicecontract.End_User_Name__c =:accountInput.Account__c 
                                                          OR servicecontract.accountid = :accountInput.Account__c 
                                                          OR servicecontract.Split_Parent_Account_Id__c = :accountInput.Account__c 
                                                          OR ServiceContract.Renewal_Opportunity__r.Account.id = :accountInput.Account__c
                                                         )
                                                     AND servicecontract.Exclude_from_CPR__c = false
                                                     AND servicecontract.Service_Contract_Type__c != 'Subscription'
                                                     AND servicecontract.Service_Contract_Type__c != 'Hardware'
                                                   	 AND priceBookEntry.product2.Type__c != 'Genesys Care' 
                                                     AND priceBookEntry.product2.Type__c != '3RD PARTY CD' 
                                                     AND priceBookEntry.product2.Type__c != 'CD/DVD' 
                                                     AND priceBookEntry.product2.Type__c != 'GU' 
                                                     AND priceBookEntry.product2.Type__c != 'Flex Care' 
                                                     AND priceBookEntry.product2.Type__c != 'PS' 
                                                   	 AND isPureEngagePrem__c = :isPureEngagePrem
                                                     AND isPureConnectPrem__c = :isPureConnectPrem];

		Map<String, CPRWrapper> mapBaseProductCPRWrapper = new Map<String, CPRWrapper>();
        
        for(ContractLineItem eachCLI : contractLineItems){
            String baseItem = eachCLI.pricebookentry.product2.Base_Item__c;
            String key = '';
            if(platformType == 'PureConnect'){
            	String mirrored = eachCLI.ServiceContract.Service_Contract_Type__c == 'Mirror' ? 'Mirror' : 'NoMirror';
            	key = eachCLI.pricebookentry.product2.Name + ' ' + eachCLI.pricebookentry.product2.APN_Number__c + ' ' + mirrored;
            } else {
               	key = baseItem;
            }
            CPRWrapper cprWrapperRecord;
            if(mapBaseProductCPRWrapper.get(key) == null) {
                cprWrapperRecord = new CPRWrapper();
            } else {
                cprWrapperRecord = mapBaseProductCPRWrapper.get(key);
            } 
            if(platformType == 'PureConnect'){
                cprWrapperRecord.productName = eachCLI.pricebookentry.product2.Name;
            } else {
                cprWrapperRecord.productName = baseItem;
            }
            cprWrapperRecord.productAPNNumber = eachCLI.pricebookentry.product2.APN_Number__c;
            cprWrapperRecord.ProductId = eachCLI.pricebookentry.product2Id;
            if(cprWrapperRecord.isMirrored != true)
				cprWrapperRecord.isMirrored = eachCLI.ServiceContract.Service_Contract_Type__c == 'Mirror' ? true : false;
            System.debug('APN + TYPE = ' + eachCLI.pricebookentry.product2.APN_Number__c + ' ' + eachCLI.ServiceContract.Service_Contract_Type__c);

            if(eachCLI.ServiceContract.Agreement_Status__c == 'Split' && eachCLI.ServiceContract.Renewal_Opportunity__c != NULL){
                if(
                	(
                		eachCLI.ServiceContract.Renewal_Opportunity__r.AccountId != accountInput.Account__c 
                    	&& 
                    	(
	                    	(
	                    		eachCLI.ServiceContract.Renewal_Opportunity__r.Opportunity_Status__c.equals('Closed-CoTerm')
	                			|| 
	                    		eachCLI.ServiceContract.Renewal_Opportunity__r.Opportunity_Status__c.equals('Renewed')
	                    	) 
	                    	&& 
	                    	eachCLI.ServiceContract.Renewal_Opportunity__r.Quote_Quote_Status__c == 'Order Accepted'
            			)
                   	)
                   	|| 
                   	(
                   		eachCLI.ServiceContract.Renewal_Opportunity__r.Accountid == accountInput.Account__c 
                   		&& 
                   		eachCLI.Servicecontract.End_User_Name__c != accountInput.Account__c 
					)
				){
                    if(eachCLI.Maintenance_Start_Date__c <= Date.today()){
						if(eachCLI.ServiceContract.Renewal_Opportunity__r.AccountId.equals(accountInput.Account__c) && (!eachCLI.Servicecontract.End_User_Name__c.equals(accountInput.Account__c)))
    	                    cprWrapperRecord.transferActive = cprWrapperRecord.transferActive + Integer.valueOf(eachCLI.Current_Quantity__c);
    	                else
    	                    cprWrapperRecord.transferActive = cprWrapperRecord.transferActive - Integer.valueOf(eachCLI.Current_Quantity__c);
                    }
                    
					if(eachCLI.ServiceContract.Renewal_Opportunity__r.AccountId.equals(accountInput.Account__c) && (!eachCLI.Servicecontract.End_User_Name__c.equals(accountInput.Account__c)))
                    	cprWrapperRecord.transfer = cprWrapperRecord.transfer + Integer.valueOf(eachCLI.Current_Quantity__c);
                    else 
						cprWrapperRecord.transfer = cprWrapperRecord.transfer - Integer.valueOf(eachCLI.Current_Quantity__c);
                    
                    if(cprWrapperRecord.transferLineItemIds != '')
                        cprWrapperRecord.transferLineItemIds = cprWrapperRecord.transferLineItemIds + ','; 
                    cprWrapperRecord.transferLineItemIds = cprWrapperRecord.transferLineItemIds + (String.valueOf(eachCLI.Id).left(15));
                }
            }
            
            // Do not show count for Drop/downsize line item if start date in the future (could be active currently). 
            // If exists but start date in future, show highlighted with details in detailed view.
			// Drop/downsize  line item start date in the past, should show in count and details.
			// Drop/downsize line item start 'today' - should show in count and details. Should show regardless of end date, dependent on reinstatement process
            if(eachCLI.ServiceContract.Agreement_Status__c == 'Drop' || eachCLI.ServiceContract.Agreement_Status__c == 'Downsize' ){
                if(eachCLI.Maintenance_Start_Date__c <= Date.today()){
                    cprWrapperRecord.dropDownsizeActive = cprWrapperRecord.dropDownsizeActive + Integer.valueOf(eachCLI.Current_Quantity__c);
                }
                cprWrapperRecord.dropDownsize = cprWrapperRecord.dropDownsize + Integer.valueOf(eachCLI.Current_Quantity__c);
                
                if(cprWrapperRecord.dropDownsizeLineItemIds != '')
                    cprWrapperRecord.dropDownsizeLineItemIds = cprWrapperRecord.dropDownsizeLineItemIds + ','; 
                cprWrapperRecord.dropDownsizeLineItemIds = cprWrapperRecord.dropDownsizeLineItemIds + (String.valueOf(eachCLI.Id).left(15));
            }
            
            // Do not show count for retired line item if start date in the future (could be active currently). If exists but start date in future, show highlighted with details in detailed view.
			// Retired line item start date in the past - should show count
			// Retired line item start date today - should show count
			// Regardless of end date at line item level.
            if(eachCLI.ServiceContract.Agreement_Status__c == 'Retired'){
                if(eachCLI.Maintenance_Start_Date__c <= Date.today()){
	                cprWrapperRecord.retiredActive = cprWrapperRecord.retiredActive + Integer.valueOf(eachCLI.Current_Quantity__c);
                }
                cprWrapperRecord.retired = cprWrapperRecord.retired + Integer.valueOf(eachCLI.Current_Quantity__c);

                if(cprWrapperRecord.retiredLineItemIds != '')
                    cprWrapperRecord.retiredLineItemIds = cprWrapperRecord.retiredLineItemIds + ','; 
                cprWrapperRecord.retiredLineItemIds = cprWrapperRecord.retiredLineItemIds + (String.valueOf(eachCLI.Id).left(15));
            }
            
            // Do not show count for shelved line item if start date in the future (could be active currently). 
            // If exists but start date in future, show highlighted with details in detailed view.
			// Shelved line item start date in the past, should show in count and details.
			// Shelved line item start 'today' - should show in count and details.
            if(eachCLI.ServiceContract.Agreement_Status__c == 'Shelved'){
                if(eachCLI.Maintenance_Start_Date__c <= Date.today() && eachCLI.Maintenance_End_Date__c >= Date.today()){
	                cprWrapperRecord.shelvedActive = cprWrapperRecord.shelvedActive + Integer.valueOf(eachCLI.Current_Quantity__c);
                }
                cprWrapperRecord.shelved = cprWrapperRecord.shelved + Integer.valueOf(eachCLI.Current_Quantity__c);
                
                if(cprWrapperRecord.shelvedLineItemIds != '')
                    cprWrapperRecord.shelvedLineItemIds = cprWrapperRecord.shelvedLineItemIds + ','; 
                cprWrapperRecord.shelvedLineItemIds = cprWrapperRecord.shelvedLineItemIds + (String.valueOf(eachCLI.Id).left(15));
            }
            
            // Count should show in cancelled column if marked Cancelled and IF the end date of the associated service contract is in the past. 
			// If Cancelled, but associated service contract end date is today or in the future then should be highlighted, not included in overall count, 
			// and details appear in detailed view.
            if(eachCLI.ServiceContract.Opp_Status__c == 'Cancelled'){
                if(eachCLI.Maintenance_End_Date__c <= Date.today()){
	                cprWrapperRecord.canceledActive = cprWrapperRecord.canceledActive + Integer.valueOf(eachCLI.Current_Quantity__c);
                }
                cprWrapperRecord.canceled = cprWrapperRecord.canceled + Integer.valueOf(eachCLI.Current_Quantity__c);
                if(cprWrapperRecord.canceledLineItemIds != '')
                    cprWrapperRecord.canceledLineItemIds = cprWrapperRecord.canceledLineItemIds + ','; 
                cprWrapperRecord.canceledLineItemIds = cprWrapperRecord.canceledLineItemIds + (String.valueOf(eachCLI.Id).left(15));
            }

            // Pending/ In Negotiation are not Date dependent ...
            if((eachCLI.ServiceContract.Agreement_Status__c == 'In Negotiation' || eachCLI.ServiceContract.Agreement_Status__c == 'Pending')
               && (eachCLI.ServiceContract.order__c != NULL && eachCLI.ServiceContract.order__r.RecordType.id != NROOrderRecordTypeId)) {
                cprWrapperRecord.pendingInNegotiation = cprWrapperRecord.pendingInNegotiation + Integer.valueOf(eachCLI.Current_Quantity__c);
                if(cprWrapperRecord.pendingInNegotiationLineItemIds != '')
                    cprWrapperRecord.pendingInNegotiationLineItemIds = cprWrapperRecord.pendingInNegotiationLineItemIds + ','; 
                cprWrapperRecord.pendingInNegotiationLineItemIds = cprWrapperRecord.pendingInNegotiationLineItemIds + (String.valueOf(eachCLI.Id).left(15));
            }
            
            mapBaseProductCPRWrapper.put(key, cprWrapperRecord);
        }
        
        for(ContractLineItem cl:[select id,quantity,initial_quantity__c,current_quantity__c, pricebookentry.product2.Name,
                                 pricebookentry.product2.id,Lic_Invoice__c,servicecontract.name,ServiceContract.Order__r.recordTypeId,
                                 servicecontract.startdate,servicecontract.enddate,Original_Quantity__c,Actual_Original_Quantity__c,
                                 servicecontract.order__r.name,servicecontract.order__r.id, servicecontract.Agreement_Status__c,
                                 pricebookentry.product2.description,pricebookentry.product2.Base_Item__c, pricebookentry.product2.APN_Number__c,
                                 createddate,servicecontractid,Service_Contract_status__c,
                                 servicecontract.order__r.NRO_Type__c, servicecontract.order__r.RecordType.id, servicecontract.order__r.Status__c,
                                 Maintenance_Start_Date__c, Maintenance_End_Date__c, ServiceContract.Service_Contract_Type__c, ServiceContract.RentalOrder__c 
                                 FROM contractlineitem 
                                 WHERE (servicecontract.End_User_Name__c = :accountInput.Account__c OR servicecontract.accountid = :accountInput.Account__c)
                                 AND servicecontract.Agreement_Status__c IN ('Active','Closed')
                                 AND servicecontract.Service_Contract_Type__c != 'Subscription'
                                 AND servicecontract.Service_Contract_Type__c != 'Hardware'
                                 AND (Lic_Invoice__c != NULL OR servicecontract.Order__r.Invoice_Number__c != NULL OR servicecontract.Order__r.Order_Type__c LIKE '%Non-Revenue')
                                 // AND (priceBookEntry.product2.Type__c = 'Product' OR priceBookEntry.product2.Type__c = '' OR priceBookEntry.product2.Type__c = NULL)
                                 AND priceBookEntry.product2.Type__c != 'Genesys Care' 
                                 AND priceBookEntry.product2.Type__c != '3RD PARTY CD' 
                                 AND priceBookEntry.product2.Type__c != 'CD/DVD' 
                                 AND priceBookEntry.product2.Type__c != 'GU' 
                                 AND priceBookEntry.product2.Type__c != 'Flex Care' 
								 AND priceBookEntry.product2.Type__c != 'PS' 
                                 AND (isPureEngagePrem__c = :isPureEngagePrem OR (isPureEngagePrem__c = true AND isPureConnectPrem__c = true))
                                 AND (isPureConnectPrem__c = :isPureConnectPrem OR (isPureEngagePrem__c = true AND isPureConnectPrem__c = true))
                                ])
        {

            System.debug('@@Part'+cl.pricebookentry.product2.APN_Number__c);
            String baseItem = cl.pricebookentry.product2.Base_Item__c;
            String key = '';
            if(platformType == 'PureConnect'){
                String mirrored = cl.ServiceContract.Service_Contract_Type__c == 'Mirror' ? 'Mirror' : 'NoMirror';
            	key = cl.pricebookentry.product2.Name + ' ' + cl.pricebookentry.product2.APN_Number__c + ' ' + mirrored;
            } else {
               	key = baseItem;
            }
            CPRWrapper cprWrapperRecord;
            if(mapBaseProductCPRWrapper.get(key) == null) {
                cprWrapperRecord = new CPRWrapper();
            } else {
                cprWrapperRecord = mapBaseProductCPRWrapper.get(key);
            } 
            if(platformType == 'PureConnect'){
                cprWrapperRecord.productName = cl.pricebookentry.product2.Name;
            } else {
                cprWrapperRecord.productName = baseItem;
            }
            cprWrapperRecord.productAPNNumber = cl.pricebookentry.product2.APN_Number__c;
            cprWrapperRecord.ProductId = cl.pricebookentry.product2.id;
            if(cprWrapperRecord.isMirrored != true)
            	cprWrapperRecord.isMirrored = cl.ServiceContract.Service_Contract_Type__c == 'Mirror' ? true : false;
            /*
             if(
                cl.servicecontract.order__r.RecordType.id != NROOrderRecordTypeId || 
				(cl.servicecontract.order__r.RecordType.id == NROOrderRecordTypeId && (cl.servicecontract.order__r.NRO_Type__c == 'Entitlement Adjustment' || cl.servicecontract.order__r.NRO_Type__c == 'Data Correction') && cl.servicecontract.order__r.Status__c == 'Completed')
              )
			*/

            System.debug('Current Part'+cprWrapperRecord.productAPNNumber);
			if(
                (cl.servicecontract.order__r.RecordType.id != NROOrderRecordTypeId && cl.ServiceContract.Service_Contract_Type__c != 'Rental' && cl.ServiceContract.RentalOrder__c == false)
                || 
				(cl.servicecontract.order__r.RecordType.id == NROOrderRecordTypeId && (cl.servicecontract.order__r.NRO_Type__c == 'Entitlement Adjustment' || cl.servicecontract.order__r.NRO_Type__c == 'Data Correction') && cl.servicecontract.order__r.Status__c == 'Completed')
              )
            {
                // Maintenance Grants need to be active as of today
                if(cl.current_quantity__c != null && cl.servicecontract.Agreement_Status__c.equals('Active') && cl.Maintenance_Start_Date__c <= Date.today() && cl.Maintenance_End_Date__c >= Date.today()){
					cprWrapperRecord.maintenanceGrants = cprWrapperRecord.maintenanceGrants + Integer.valueOf(cl.Current_Quantity__c);
                    if(cprWrapperRecord.maintenanceGrantsLineItemIds != '')
                    	cprWrapperRecord.maintenanceGrantsLineItemIds = cprWrapperRecord.maintenanceGrantsLineItemIds + ','; 
                	cprWrapperRecord.maintenanceGrantsLineItemIds = cprWrapperRecord.maintenanceGrantsLineItemIds + (String.valueOf(cl.Id).left(15));
                }
                /*
                if(cl.Original_Quantity__c!=null){
					cprWrapperRecord.originalLicenseGrants = cprWrapperRecord.originalLicenseGrants + Integer.valueOf(cl.Original_Quantity__c);
                    if(cprWrapperRecord.originalLicenseGrantsLineItemIds != '')
                    	cprWrapperRecord.originalLicenseGrantsLineItemIds = cprWrapperRecord.originalLicenseGrantsLineItemIds + ','; 
                	cprWrapperRecord.originalLicenseGrantsLineItemIds = cprWrapperRecord.originalLicenseGrantsLineItemIds + (String.valueOf(cl.Id).left(15));
                }
                */
				
                if(cl.Actual_Original_Quantity__c!=null){
					cprWrapperRecord.actualOriginal = cprWrapperRecord.actualOriginal + Integer.valueOf(cl.Actual_Original_Quantity__c);
                    if(cprWrapperRecord.actualOriginalLineItemIds != '')
                    	cprWrapperRecord.actualOriginalLineItemIds = cprWrapperRecord.actualOriginalLineItemIds + ','; 
                	cprWrapperRecord.actualOriginalLineItemIds = cprWrapperRecord.actualOriginalLineItemIds + (String.valueOf(cl.Id).left(15));
                }
            } 
            else 
            {
                cprWrapperRecord.nro = cprWrapperRecord.nro + Integer.valueOf(cl.Current_Quantity__c);
                if(cprWrapperRecord.nroLineItemIds != '')
                    cprWrapperRecord.nroLineItemIds = cprWrapperRecord.nroLineItemIds + ','; 
                cprWrapperRecord.nroLineItemIds = cprWrapperRecord.nroLineItemIds + (String.valueOf(cl.Id).left(15));
                
                if(cl.servicecontract.Agreement_Status__c.equals('Active')){
                    cprWrapperRecord.nroActive = cprWrapperRecord.nroActive + Integer.valueOf(cl.Current_Quantity__c);
                }
			}
            mapBaseProductCPRWrapper.put(key, cprWrapperRecord);
        }
        String entitlementAdjustmentCategory = platformType + ' On Premise';
        // Fetch data for Entitlement Adjustments
        for(AggregateResult ar: [SELECT Product__r.Base_Item_Lookup__c bid, Product__r.base_item__c bi, Product__r.Name pn, Product__r.APN_Number__c apnn, Sum(Total__c) cnt 
                                 FROM License_Audit__c 
                                 WHERE Account__c = :accountInput.Account__c AND Total__c <> null
                                 AND Product__r.OfferingType__c = :entitlementAdjustmentCategory
                                 GROUP BY Product__r.Base_Item_Lookup__c, Product__r.base_item__c, Product__r.Name, Product__r.APN_Number__c])
        {
            String baseItem = String.valueOf(ar.get('bi'));
            String key = '';
            if(platformType == 'PureConnect'){
            	key = String.valueOf(ar.get('pn')) + ' ' + String.valueOf(ar.get('apnn')) + ' ' + 'NoMirror';
            } else {
               	key = baseItem;
            }
            CPRWrapper cprWrapperRecord;
            if(mapBaseProductCPRWrapper.get(key) == null) {
                cprWrapperRecord = new CPRWrapper();
            } else {
                cprWrapperRecord = mapBaseProductCPRWrapper.get(key);
            } 
            if(platformType == 'PureConnect'){
                cprWrapperRecord.productName = String.valueOf(ar.get('pn'));
            } else {
                cprWrapperRecord.productName = baseItem;
            }
            cprWrapperRecord.productAPNNumber = String.valueOf(ar.get('apnn'));
            cprWrapperRecord.ProductId = ar.get('bid') != NULL ? String.valueOf(ar.get('bid')) : '';
            
            cprWrapperRecord.entitlementAdjustments = cprWrapperRecord.entitlementAdjustments + Integer.valueOf(ar.get('cnt'));
            mapBaseProductCPRWrapper.put(key, cprWrapperRecord);
        }
        
        String orderCategory = platformType + ' - On Premise';
        Set<String> nonEvalOrders = new Set<String>();
        for(Invoice__c inv:[SELECT Id, Name, Order__c FROM Invoice__c WHERE 
                            Order__r.End_User_Name__c= :accountInput.Account__c 
                            AND (eval__c <> 'true' OR Include_in_CPR__c = true OR (Net_License_Amount__c <> NULL AND Net_License_Amount__c !=0) OR (Invoice_Amount__c <> NULL AND Invoice_Amount__c != 0)) ]){
            nonEvalOrders.add(inv.order__c);
        }
        // Order__r.PO_Number__c),'EVAL'
        /*
        for(Invoice__c inv:[SELECT Id, Name, Order__c FROM Invoice__c WHERE 
                            Order__r.End_User_Name__c= :accountInput.Account__c AND eval__c<> 'true' AND
                            (Include_in_CPR__c = true OR (Net_License_Amount__c <> NULL AND Net_License_Amount__c !=0) OR (Invoice_Amount__c <> NULL AND Invoice_Amount__c != 0)) 
                            AND Order__r.License_FYM_detail__c != 'Maintenance Only Order'
                             AND (Order__r.Opportunity__r.RecordType.id != :GenesysRenewalOppRecordTypeId)])
        {
            nonEvalOrders.add(inv3.order__c);
        }
        */
        
        Map<String, Product_Upgrade_Request__c> upgradeRequestsMap = new Map<String, Product_Upgrade_Request__c>();
        for(Product_Upgrade_Request__c pur : [SELECT Product__c, Product__r.APN_Number__c, Quantity__c, CreatedDate FROM Product_Upgrade_Request__c 
                                                      WHERE Account__c = :accountInput.Account__c
                                                      AND Type__c = 'Version' AND Processed__c = false])
		{
        	upgradeRequestsMap.put(pur.Product__r.APN_Number__c, pur);                                              	
		}
        
        System.debug('orderCategory = ' + orderCategory);
        // Fecth data for Criginal License Grants
 		List<Order_Line_Item__c> orderLineItems = [SELECT id,name,BigMachines_Quantity__c,Quantity_Credit__c, Order__c, Order__r.Name, Product__r.Name,Order__r.recordTypeId,
                                                   		Product__r.description, Product__r.id, Product__r.Base_Item__c, Product__r.APN_Number__c,
                                                   release_version__c, Product__c, Build_Type__c,Override_CPR__c,
                                                   		Order__r.NRO_Type__c, Order__r.Net_License__c, Maintenance_Start_Date__c FROM Order_Line_Item__c 
                                                   WHERE Order__r.End_User_Name__c= :accountInput.Account__c
                                                   	AND Order__r.Bypass_Entitlements__c != true 
                                                   	AND Order__r.License_FYM_detail__c != 'Maintenance Only Order' 
                                                   	AND Order__r.License_FYM_detail__c != 'PS Orders' 
                                                   	AND Order__r.Opportunity__r.RecordType.id != :GenesysRenewalOppRecordTypeId
                                                   	AND Order__r.Status__c != 'Credit'
                                                   	AND (isPureEngagePrem__c = :isPureEngagePrem OR (isPureEngagePrem__c = true AND isPureConnectPrem__c = true)) 
                                 					AND (isPureConnectPrem__c = :isPureConnectPrem OR (isPureEngagePrem__c = true AND isPureConnectPrem__c = true))
                                                   	AND (
                                                       		(Order__r.Name LIKE 'Order%')
                                                        	OR
                                                        	((NOT Order__r.name LIKE 'Order%') AND Override_CPR__c = true)
                                                       		OR 
                                                        	(
                                                                (NOT Order__r.name LIKE 'Order%') AND Extended_Net_Price__c > 0
                                                            )
                                                        	OR 
                                                        	(
                                                                (NOT Order__r.name LIKE 'Order%') 
                                                                AND 
                                                                ((release_version__c != '' AND release_version__c != NULL) OR Build_Type__c = 'GA')
                                                                AND 
                                                                (Order__r.Net_License__c != NULL AND Order__r.Net_License__c != 0)
                                                            )
                                                        	OR 
                                                        	(
                                                                (NOT Order__r.name LIKE 'Order%') 
                                                             	AND
                                                                (Order__r.NRO_Type__c = 'Entitlement Adjustment' OR Order__r.NRO_Type__c = 'Data Correction')
                                                        	)
                                                   		)
                                                   AND Product__r.Type__c !='Genesys Care' AND Product__r.Type__c !='3RD PARTY CD' 
                                                   AND Product__r.Type__c !='CD/DVD' AND Product__r.Type__c !='GU'];

        	
         for(Order_Line_Item__c oli : orderLineItems)
         {
             if(nonEvalOrders.contains(oli.Order__c) || (oli.Order__r.NRO_Type__c == 'Entitlement Adjustment' || oli.Order__r.NRO_Type__c == 'Data Correction')){
                String baseItem = oli.Product__r.Base_Item__c;
                String key = '';
				if(platformType == 'PureConnect'){
                    String mirrored = oli.Order__r.NRO_Type__c == 'Mirror' ? 'Mirror' : 'NoMirror';
                    key = oli.Product__r.Name + ' ' + oli.Product__r.APN_Number__c + ' ' + mirrored;
                } else {
                    key = baseItem;
                }
                 CPRWrapper cprWrapperRecord;
                 if(mapBaseProductCPRWrapper.get(key) == null) {
                     cprWrapperRecord = new CPRWrapper();
                 } else {
                     cprWrapperRecord = mapBaseProductCPRWrapper.get(key);
                 } 
                 if(platformType == 'PureConnect'){
                     cprWrapperRecord.productName = oli.Product__r.Name;
                 } else {
                     cprWrapperRecord.productName = baseItem;
                 }
                 cprWrapperRecord.productAPNNumber = oli.Product__r.APN_Number__c;
                 cprWrapperRecord.productId = oli.Product__r.id;
                 if(cprWrapperRecord.isMirrored != true)
                 	cprWrapperRecord.isMirrored = oli.Order__r.NRO_Type__c == 'Mirror' ? true : false;
                 
                 // Original License Grants are not Date dependent ..., all history
                 cprWrapperRecord.originalLicenseGrants = cprWrapperRecord.originalLicenseGrants + Integer.valueOf(oli.Quantity_Credit__c);
                 
                 if(upgradeRequestsMap.get(oli.Product__r.APN_Number__c) != NULL && upgradeRequestsMap.get(oli.Product__r.APN_Number__c).CreatedDate.date() >= oli.Maintenance_Start_Date__c)
                 	cprWrapperRecord.originalLicenseGrantsBeforeUpgrade = cprWrapperRecord.originalLicenseGrantsBeforeUpgrade + Integer.valueOf(oli.Quantity_Credit__c);
                 
                 if(cprWrapperRecord.originalLicenseGrantsLineItemIds != '')
                     cprWrapperRecord.originalLicenseGrantsLineItemIds = cprWrapperRecord.originalLicenseGrantsLineItemIds + ','; 
                 cprWrapperRecord.originalLicenseGrantsLineItemIds = cprWrapperRecord.originalLicenseGrantsLineItemIds + (String.valueOf(oli.Id).left(15));
                 
                 mapBaseProductCPRWrapper.put(key, cprWrapperRecord);
             }
		}
        
        // Fecth data for Product level Comments
        for(CPR_Comment__c eachComment : [SELECT Product__r.Base_Item__c, Product__r.Name, Product__r.APN_Number__c, Comments__c FROM CPR_Comment__c WHERE Account__c = :accountInput.Account__c]){
            if(eachComment.Comments__c != null){
                String key = '';
                if(platformType == 'PureConnect'){
                    key = eachComment.Product__r.Name + ' ' + eachComment.Product__r.APN_Number__c;
                } else {
                    key = eachComment.Product__r.Base_Item__c;
                }
                if(mapBaseProductCPRWrapper.get(key) != null) {
                    mapBaseProductCPRWrapper.get(key).comment = eachComment.id;
                } 
            }          
        }
		
        // Return only Values ...
        List<String> allBaseProducts = new List<String>();
        allBaseProducts.addAll(mapBaseProductCPRWrapper.keySet());
        allBaseProducts.sort();
        
        cprItems = new List<CPRWrapper>();
        for(String key: allBaseProducts){
            CPRWrapper cprw = mapBaseProductCPRWrapper.get(key);
            if(cprw.hasValues()){
				cprItems.add(cprw);
           	}
        }
        if(platformType == 'PureConnect'){
            // apply pending version upgrades
            performVersionUpgrades();
            // apply purchase upgardes
            // performPurchaseUpgrades();
            // update Product Category and Version 
        	updateProductCategoryVersion();
        	
        	// update for sorting and merge duplicate rows after version upgrades
        	finalCPRRecords();
        }
        
        
   	}
    
    public void saveComments(){
        if(pureEngageCPRReport != NULL && platformType == 'PureEngage')
        	upsert pureEngageCPRReport;
        if(pureConnectCPRReport != NULL && platformType == 'PureConnect')
        	upsert pureConnectCPRReport;
    }
    
    public void accountSelectionChanged(){
    	checkPlatformType();
        createCPR();
    }
    public void platformSelectionChanged(){
        createCPR();
    }
    
    public void checkPlatformType(){
        pureEngageCount = 0;
        Integer pureEngageCount1 = [SELECT count() FROM contractlineitem 
                                    WHERE (servicecontract.End_User_Name__c = :accountInput.Account__c OR servicecontract.accountid = :accountInput.Account__c)
                                    AND servicecontract.Agreement_Status__c IN ('Active','Closed') 
                                    AND servicecontract.Service_Contract_Type__c != 'Subscription'
                                    AND servicecontract.Service_Contract_Type__c != 'Hardware'
                                    AND (Lic_Invoice__c != NULL OR servicecontract.Order__r.Invoice_Number__c != NULL OR servicecontract.Order__r.Order_Type__c LIKE '%Non-Revenue') 
                                    AND priceBookEntry.product2.Type__c != 'Genesys Care' 
                                    AND priceBookEntry.product2.Type__c != '3RD PARTY CD' 
                                    AND priceBookEntry.product2.Type__c != 'CD/DVD' 
                                    AND priceBookEntry.product2.Type__c != 'GU' 
                                    AND priceBookEntry.product2.Type__c != 'Flex Care' 
                                    AND priceBookEntry.product2.Type__c != 'PS' 
                                    AND isPureEngagePrem__c = true];
        Integer pureEngageCount2 = [SELECT count() FROM contractLineItem 
                                    WHERE ( Servicecontract.Agreement_Status__c IN ('Split', 'Drop', 'Retired', 'Shelved', 'Downsize', 'In Negotiation', 'Pending')  
                                           OR (ServiceContract.Opp_Status__c = 'Cancelled' 
                                               AND  ServiceContract.Cancellation_Reason__c NOT IN ('Went Indirect' , 
                                                                                                   'Went Direct' , 
                                                                                                   'Switched Partner', 
                                                                                                   'Prior Hypothetical', 
                                                                                                   'Duplicate - mark for deletion',
                                                                                                   'Change of VAR/Sold To',
                                                                                                   'Merged onto a new quote')
                                              )
                                          ) 
                                    AND (servicecontract.End_User_Name__c =:accountInput.Account__c 
                                         OR servicecontract.accountid = :accountInput.Account__c 
                                         OR servicecontract.Split_Parent_Account_Id__c = :accountInput.Account__c 
                                         OR ServiceContract.Renewal_Opportunity__r.Account.id = :accountInput.Account__c
                                        )
                                    AND servicecontract.Service_Contract_Type__c != 'Subscription'
                                    AND servicecontract.Service_Contract_Type__c != 'Hardware'
                                    AND servicecontract.Exclude_from_CPR__c = false
                                    AND priceBookEntry.product2.Type__c != 'Genesys Care' 
                                    AND priceBookEntry.product2.Type__c != '3RD PARTY CD' 
                                    AND priceBookEntry.product2.Type__c != 'CD/DVD' 
                                    AND priceBookEntry.product2.Type__c != 'GU' 
                                    AND priceBookEntry.product2.Type__c != 'Flex Care' 
                                    AND priceBookEntry.product2.Type__c != 'PS' 
                                   	AND isPureEngagePrem__c = true];
        pureEngageCount = pureEngageCount1 + pureEngageCount2;
        
        pureConnectCount = 0;
		Integer pureConnectCount1 = [SELECT count() FROM contractlineitem 
                                    WHERE (servicecontract.End_User_Name__c = :accountInput.Account__c OR servicecontract.accountid = :accountInput.Account__c)
                                    AND servicecontract.Agreement_Status__c IN ('Active','Closed') 
                                    AND servicecontract.Service_Contract_Type__c != 'Subscription'
                                    AND servicecontract.Service_Contract_Type__c != 'Hardware'
                                    AND (Lic_Invoice__c != NULL OR servicecontract.Order__r.Invoice_Number__c != NULL OR servicecontract.Order__r.Order_Type__c LIKE '%Non-Revenue') AND priceBookEntry.product2.Type__c != 'Genesys Care' 
                                    AND priceBookEntry.product2.Type__c != '3RD PARTY CD' 
                                    AND priceBookEntry.product2.Type__c != 'CD/DVD' 
                                    AND priceBookEntry.product2.Type__c != 'GU' 
                                    AND priceBookEntry.product2.Type__c != 'Flex Care' 
                                    AND priceBookEntry.product2.Type__c != 'PS' 
                                    AND isPureConnectPrem__c = true];
        Integer pureConnectCount2 = [SELECT count() FROM contractLineItem 
                                    WHERE ( Servicecontract.Agreement_Status__c IN ('Split', 'Drop', 'Retired', 'Shelved', 'Downsize', 'In Negotiation', 'Pending')  
                                           OR (ServiceContract.Opp_Status__c = 'Cancelled' 
                                               AND  ServiceContract.Cancellation_Reason__c NOT IN ('Went Indirect' , 
                                                                                                   'Went Direct' , 
                                                                                                   'Switched Partner', 
                                                                                                   'Prior Hypothetical', 
                                                                                                   'Duplicate - mark for deletion',
                                                                                                   'Change of VAR/Sold To',
                                                                                                   'Merged onto a new quote')
                                              )
                                          ) 
                                    AND (servicecontract.End_User_Name__c =:accountInput.Account__c 
                                         OR servicecontract.accountid = :accountInput.Account__c 
                                         OR servicecontract.Split_Parent_Account_Id__c = :accountInput.Account__c 
                                         OR ServiceContract.Renewal_Opportunity__r.Account.id = :accountInput.Account__c
                                        )
                                    AND servicecontract.Service_Contract_Type__c != 'Subscription'
                                    AND servicecontract.Service_Contract_Type__c != 'Hardware'
                                    AND servicecontract.Exclude_from_CPR__c = false
                                    AND priceBookEntry.product2.Type__c != 'Genesys Care' 
                                    AND priceBookEntry.product2.Type__c != '3RD PARTY CD' 
                                    AND priceBookEntry.product2.Type__c != 'CD/DVD' 
                                    AND priceBookEntry.product2.Type__c != 'GU' 
                                    AND priceBookEntry.product2.Type__c != 'Flex Care' 
                                    AND priceBookEntry.product2.Type__c != 'PS' 
                                   	AND isPureConnectPrem__c = true];
        pureConnectCount = pureConnectCount1 + pureConnectCount2;
        platformTypes = new List<SelectOption>();
        if(pureEngageCount > 0)
        	platformTypes.add(new SelectOption('PureEngage', 'PureEngage'));
        if(pureConnectCount > 0)
        	platformTypes.add(new SelectOption('PureConnect', 'PureConnect'));
        System.debug('PureEngage = ' + pureEngageCount);
        System.debug('PureConnect = ' + pureConnectCount);
        if(platformTypes.size() > 0)
            	platformType = platformTypes[0].getValue();
    }
    
   
    public void performVersionUpgrades(){
        List<Pure_Connect_Version_Upgrade__c> upgrProdsMapping = new List<Pure_Connect_Version_Upgrade__c>();
        List<Product_Upgrade_Request__c> upgrReqst = [SELECT Product__c, Product__r.APN_Number__c, Quantity__c FROM Product_Upgrade_Request__c 
                                                      WHERE Account__c = :accountInput.Account__c
                                                      AND Type__c = 'Version' AND Processed__c = false];
                                                      
                                                    
        if ( ! upgrReqst.isEmpty() )   {
	        Map<String, Integer> upgrReqstMap = new Map<String, Integer>();
            Set<String> prodIds = new Set<String>();
            
            for (Product_Upgrade_Request__c r : upgrReqst){
            	prodIds.add(String.ValueOf(r.Product__c));
            	upgrReqstMap.put(String.ValueOf(r.Product__r.APN_Number__c), r.Quantity__c.intValue());
            }
            
            Map<String, CPRWrapper> cprItemsUpgraded = new Map<String, CPRWrapper>();
            for(Pure_Connect_Version_Upgrade__c pcvu : [SELECT Old_Product__c, Old_Product_APN_Number__c, New_Product_APN_Number__c, New_Product__c, New_Product__r.Name, New_Product__r.Product_Group__c
                                                            FROM Pure_Connect_Version_Upgrade__c
                                                          WHERE Old_Product__c IN : prodIds])
            {
            	Boolean foundInList = false;
             	for(CPRWrapper cprw : cprItems){
                    if(cprw.productAPNNumber == pcvu.Old_Product_APN_Number__c && cprw.isMirrored == false){
                    	cprw.productAPNNumber = pcvu.New_Product_APN_Number__c;
                    	cprw.productName = pcvu.New_Product__r.Name;
                        cprw.versionUpgrade = true;
                        cprw.upgraded = cprw.maintenanceGrants;
                        //cprw.upgraded = upgrReqstMap.get(pcvu.Old_Product_APN_Number__c);
                        foundInList = true;
                    }
                }
                if(foundInList == false){
                	if(cprItemsUpgraded.get(pcvu.New_Product_APN_Number__c) != NULL){
                		CPRWrapper cprWrapperRecord = cprItemsUpgraded.get(pcvu.New_Product_APN_Number__c);	
                		cprWrapperRecord.upgraded = cprWrapperRecord.upgraded + upgrReqstMap.get(pcvu.Old_Product_APN_Number__c);
                		cprWrapperRecord.maintenanceGrants = cprWrapperRecord.upgraded;
                	} else {
                		CPRWrapper cprWrapperRecord = new CPRWrapper();
		                cprWrapperRecord.productAPNNumber = pcvu.New_Product_APN_Number__c;
                		cprWrapperRecord.productName = pcvu.New_Product__r.Name;
	                 	cprWrapperRecord.productId = pcvu.New_Product__c;
						cprWrapperRecord.isMirrored = false;
						cprWrapperRecord.versionUpgrade = true;
						cprWrapperRecord.upgraded = cprWrapperRecord.upgraded + upgrReqstMap.get(pcvu.Old_Product_APN_Number__c);
						cprWrapperRecord.maintenanceGrants = cprWrapperRecord.upgraded;
						cprItemsUpgraded.put(pcvu.New_Product_APN_Number__c, cprWrapperRecord);
                	}
                }                                                 
            }
            
            cprItems.addAll(cprItemsUpgraded.values());
            
            List<CPRWrapper> cprItemsNew = new List<CPRWrapper>();
            for(CPRWrapper cprw : cprItems){
                if(cprw.productAPNNumber != NULL){
                    cprItemsNew.add(cprw);
                }
            }
            cprItems = cprItemsNew;
        }
    }
    /*
	public void performPurchaseUpgrades(){
    	Map<String, UL_Upsize_Parts__c> ULUpsizeParts = UL_Upsize_Parts__c.getAll();
        // CPR Records with UL Parts
        List<CPRWrapper> recordsULPart = new List<CPRWrapper>();
        Set<String> ULUpsizePartsNamesUpgradeFrom = new Set<String>();
        Set<String> ULUpsizePartsNamesUpgradeTo = new Set<String>();

        for(CPRWrapper cprw : cprItems){
            if(ULUpsizeParts.KeySet().contains(cprw.productAPNNumber)){
            	recordsULPart.add(cprw);
                ULUpsizePartsNamesUpgradeFrom.add(ULUpsizeParts.get(cprw.productAPNNumber).Part_To_Be_Decremented__c);
                ULUpsizePartsNamesUpgradeTo.add(ULUpsizeParts.get(cprw.productAPNNumber).Part_To_Be_Incremented__c);
            }
        }

        if(!recordsULPart.isEmpty()){
            Map<String, String> itemCategories = new Map<String, String>();
            for(LMS_ItemCategory__c lic : [SELECT id, Category_Id__c, Short_Name__c FROM LMS_ItemCategory__c]){
                itemCategories.put(lic.Category_Id__c, lic.Short_Name__c);  
            }
            
            Map<String, Product2> productsMap = new Map<String, Product2>();
            for(Product2 p: [SELECT Id, Name, APN_Number__c, Description FROM Product2 WHERE APN_Number__c IN :ULUpsizePartsNamesUpgradeTo]){
                productsMap.put(p.APN_Number__c, p);
            }
            
            List<CPRWrapper> recordsDecrementParts = new List<CPRWrapper>();
			List<CPRWrapper> recordsIncrementParts = new List<CPRWrapper>();
            for(CPRWrapper cprw : cprItems){
            	if(ULUpsizePartsNamesUpgradeFrom.contains(cprw.productAPNNumber)){
                    recordsDecrementParts.add(cprw);
                }
                if(ULUpsizePartsNamesUpgradeTo.contains(cprw.productAPNNumber)){
                    recordsIncrementParts.add(cprw);
                }
            }
            
            // Loop through each UL Part which is Purchase upgrade part ...
            for(CPRWrapper ulLSRecord : recordsULPart){
                UL_Upsize_Parts__c ulPart = ULUpsizeParts.get(ulLSRecord.productAPNNumber);
                
                // Loop through each Record that needs to be decremented and update maintenanceGrants...
                for(CPRWrapper decrementLSRecord : recordsDecrementParts){
                    if(decrementLSRecord.productAPNNumber == ulPart.Part_To_Be_Decremented__c){
                        decrementLSRecord.maintenanceGrants = decrementLSRecord.maintenanceGrants - ulLSRecord.maintenanceGrants;
                        // Check if the same part exists in recordsIncrementParts as well so you need to pass updated quanties
                        // The following for loop helps to handle situations where you have UPLIFT PARTS like A-->B, B-->C
                        for(Integer i=0; i < recordsIncrementParts.size(); i++){
                            if(recordsIncrementParts[i].productAPNNumber == decrementLSRecord.productAPNNumber){
                                recordsIncrementParts[i] = decrementLSRecord;       
                            }   
                        }
                    }
                }
                
                // Loop through each Records that needs to be incremented and update maintenanceGrants...
                Boolean incrementPartAlreadyExists = false;
                for(CPRWrapper incrementLSRecord : recordsIncrementParts){
                    if(incrementLSRecord.productAPNNumber == ulPart.Part_To_Be_Incremented__c){
                        incrementLSRecord.maintenanceGrants = incrementLSRecord.maintenanceGrants + ulLSRecord.maintenanceGrants;
                        incrementPartAlreadyExists = true;
                    }
                }
                
                // Create new snapshot record if the record does not exist
                if(incrementPartAlreadyExists == false){
                    Product2 product = productsMap.get(ulPart.Part_To_Be_Incremented__c);
                    CPRWrapper recordNew = new CPRWrapper();
                    recordNew.maintenanceGrants = ulLSRecord.maintenanceGrants;
                    recordNew.productAPNNumber = product.APN_Number__c;
                    recordNew.productName = product.Name;
                    recordNew.productId = product.Id;
                    recordNew.purchaseUpgrade = true;
                    cprItems.add(recordNew);
                }
            }
        }
    }
    */
    
    public void updateProductCategoryVersion(){
        
        Set<String> productAPNNumbers = new Set<String>();
        for(CPRWrapper cprw : cprItems){
            productAPNNumbers.add(cprw.productAPNNumber);
        }
        
        Map<String, String> itemCategories = new Map<String, String>();
        for(LMS_ItemCategory__c lic : [SELECT id, Category_Id__c, Short_Name__c FROM LMS_ItemCategory__c]){
            itemCategories.put(lic.Category_Id__c, lic.Short_Name__c);  
        }
        
        Map<String, Product2> productCategories = new Map<String, Product2>();
        for(Product2 p : [SELECT APN_Number__c, New_Category__c, item_category__c, Product_Sub_category__c  FROM Product2 WHERE APN_Number__c IN :productAPNNumbers ]){
            productCategories.put(p.APN_Number__c, p);  
        }
        
        for(CPRWrapper cprw : cprItems){
            if(cprw.productAPNNumber != NULL){
                String[] splitCodes = cprw.productAPNNumber.split('-');
                if(splitCodes.size() > 2){
                    if(itemCategories.get(splitCodes[1]) != NULL){
                        cprw.productCategoryVersion = itemCategories.get(splitCodes[1]) + ' ' + splitCodes[2];
                    } else if(productCategories.get(cprw.productAPNNumber) != NULL && productCategories.get(cprw.productAPNNumber).Product_Sub_category__c != NULL){
                        cprw.productCategoryVersion = productCategories.get(cprw.productAPNNumber).Product_Sub_category__c + ' ' + splitCodes[2];
                    } else if(productCategories.get(cprw.productAPNNumber) != NULL && productCategories.get(cprw.productAPNNumber).New_Category__c != NULL){
                        cprw.productCategoryVersion = productCategories.get(cprw.productAPNNumber).New_Category__c;
                    } else {
                        cprw.productCategoryVersion = splitCodes[2];
                    }
                }
            }
        }
    }
    
    public void finalCPRRecords(){
    	Map<String, CPRWrapper> cprRecordsMap = new Map<String, CPRWrapper>();
    	for(CPRWrapper cprw : cprItems){
    		String key = cprw.productName + '' + cprw.productAPNNumber;
    		if(cprRecordsMap.KeySet().contains(key)){
    			CPRWrapper cprw1 = cprRecordsMap.get(key);
    			CPRWrapper cprwMerged = mergeCPRWrappers(cprw1, cprw);		
    			cprRecordsMap.put(key, cprwMerged);
    		} else {
	    		cprRecordsMap.put(key, cprw);	
    		}
    	}
    	
    	// Return only Values ...
        List<String> keys = new List<String>();
        keys.addAll(cprRecordsMap.keySet());
        keys.sort();
        
        List<CPRWrapper> cleanedList = new List<CPRWrapper>();
        for(String key: keys){
            CPRWrapper cprw = cprRecordsMap.get(key);
            if(cprw.hasValues()){
				cleanedList.add(cprw);
           	}
        }	
    	
    	cprItems = cleanedList;
    }
    
    public CPRWrapper mergeCPRWrappers(CPRWrapper cprw1, CPRWrapper cprw2){
    		cprw1.upgraded = cprw1.upgraded + cprw2.upgraded;
            cprw1.maintenanceGrants = cprw1.maintenanceGrants + cprw2.maintenanceGrants;
            cprw1.pendingInNegotiation = cprw1.pendingInNegotiation + cprw2.pendingInNegotiation;
            cprw1.currentEntitlements = cprw1.currentEntitlements + cprw2.currentEntitlements;
            cprw1.originalLicenseGrants = cprw1.originalLicenseGrants + cprw2.originalLicenseGrants;
			cprw1.originalLicenseGrantsBeforeUpgrade = cprw1.originalLicenseGrantsBeforeUpgrade + cprw2.originalLicenseGrantsBeforeUpgrade;
            cprw1.actualOriginal = cprw1.actualOriginal + cprw2.actualOriginal;
            cprw1.entitlementAdjustments = cprw1.entitlementAdjustments + cprw2.entitlementAdjustments;
            cprw1.transferActive = cprw1.transferActive + cprw2.transferActive;
            cprw1.dropDownsizeActive = cprw1.dropDownsizeActive + cprw2.dropDownsizeActive;
            cprw1.retiredActive = cprw1.retiredActive + cprw2.retiredActive;
            cprw1.shelvedActive = cprw1.shelvedActive + cprw2.shelvedActive;
            cprw1.canceledActive = cprw1.canceledActive + cprw2.canceledActive;
            cprw1.nroActive = cprw1.nroActive + cprw2.nroActive;
            cprw1.transfer = cprw1.transfer + cprw2.transfer;
            cprw1.dropDownsize = cprw1.dropDownsize + cprw2.dropDownsize;
            cprw1.retired = cprw1.retired + cprw2.retired;
            cprw1.shelved = cprw1.shelved + cprw2.shelved;
            cprw1.canceled = cprw1.canceled + cprw2.canceled;
            cprw1.nro = cprw1.nro + cprw2.nro;
    	
    		
    		cprw1.maintenanceGrantsLineItemIds = (cprw1.maintenanceGrantsLineItemIds != '' ? 
    													cprw1.maintenanceGrantsLineItemIds 
    													+ (cprw2.maintenanceGrantsLineItemIds != '' ?  ',' + cprw2.maintenanceGrantsLineItemIds : cprw1.maintenanceGrantsLineItemIds) 
    													: cprw2.maintenanceGrantsLineItemIds);
    		cprw1.pendingInNegotiationLineItemIds = (cprw1.pendingInNegotiationLineItemIds != '' ? 
    													cprw1.pendingInNegotiationLineItemIds 
    													+ (cprw2.pendingInNegotiationLineItemIds != '' ?  ',' + cprw2.pendingInNegotiationLineItemIds : cprw1.pendingInNegotiationLineItemIds) 
    													: cprw2.pendingInNegotiationLineItemIds);											
    		cprw1.originalLicenseGrantsLineItemIds = (cprw1.originalLicenseGrantsLineItemIds != '' ? 
    													cprw1.originalLicenseGrantsLineItemIds 
    													+ (cprw2.originalLicenseGrantsLineItemIds != '' ?  ',' + cprw2.originalLicenseGrantsLineItemIds : cprw1.originalLicenseGrantsLineItemIds) 
    													: cprw2.originalLicenseGrantsLineItemIds);											
    		cprw1.actualOriginalLineItemIds = (cprw1.actualOriginalLineItemIds != '' ? 
    													cprw1.actualOriginalLineItemIds 
    													+ (cprw2.actualOriginalLineItemIds != '' ?  ',' + cprw2.actualOriginalLineItemIds : cprw1.actualOriginalLineItemIds) 
    													: cprw2.actualOriginalLineItemIds);	
    													
    		cprw1.transferLineItemIds = (cprw1.transferLineItemIds != '' ? 
    													cprw1.transferLineItemIds 
    													+ (cprw2.transferLineItemIds != '' ?  ',' + cprw2.transferLineItemIds : cprw1.transferLineItemIds) 
    													: cprw2.transferLineItemIds);											
    		cprw1.dropDownsizeLineItemIds = (cprw1.dropDownsizeLineItemIds != '' ? 
    													cprw1.dropDownsizeLineItemIds 
    													+ (cprw2.dropDownsizeLineItemIds != '' ?  ',' + cprw2.dropDownsizeLineItemIds : cprw1.dropDownsizeLineItemIds) 
    													: cprw2.dropDownsizeLineItemIds);											
    		cprw1.retiredLineItemIds = (cprw1.retiredLineItemIds != '' ? 
    													cprw1.retiredLineItemIds 
    													+ (cprw2.retiredLineItemIds != '' ?  ',' + cprw2.retiredLineItemIds : cprw1.retiredLineItemIds) 
    													: cprw2.retiredLineItemIds);											
    		cprw1.shelvedLineItemIds = (cprw1.shelvedLineItemIds != '' ? 
    													cprw1.shelvedLineItemIds 
    													+ (cprw2.shelvedLineItemIds != '' ?  ',' + cprw2.shelvedLineItemIds : cprw1.shelvedLineItemIds) 
    													: cprw2.shelvedLineItemIds);											
    		cprw1.canceledLineItemIds = (cprw1.canceledLineItemIds != '' ? 
    													cprw1.canceledLineItemIds 
    													+ (cprw2.canceledLineItemIds != '' ?  ',' + cprw2.canceledLineItemIds : cprw1.canceledLineItemIds) 
    													: cprw2.canceledLineItemIds);											
    		cprw1.nroLineItemIds = (cprw1.nroLineItemIds != '' ? 
    													cprw1.nroLineItemIds 
    													+ (cprw2.nroLineItemIds != '' ?  ',' + cprw2.nroLineItemIds : cprw1.nroLineItemIds) 
    													: cprw2.nroLineItemIds);											
            
            return cprw1;
    }
    
    public class CPRWrapper {
        
        public string productId {get; set;}
        public string productName {get; set;}
        public string productAPNNumber {get; set;}
        public string productCategoryVersion {get; set;}
        public Integer maintenanceGrants {get; set;} 
        public String maintenanceGrantsLineItemIds {get; set;} 

        public Integer pendingInNegotiation {get; set;}
        public String pendingInNegotiationLineItemIds {get; set;}

        public Integer originalLicenseGrants {get; set;}
        public String originalLicenseGrantsLineItemIds {get; set;}
        public Integer originalLicenseGrantsBeforeUpgrade {get; set;}
			
        public Integer actualOriginal {get; set;}
        public String actualOriginalLineItemIds {get; set;}
        
        public Integer transfer {get; set;}
        public Integer transferActive {get; set;}
        public String transferLineItemIds {get; set;}
        
        public Integer dropDownsize {get; set;}
        public Integer dropDownsizeActive {get; set;}
        public String dropDownsizeLineItemIds {get; set;}
        
        public Integer retired {get; set;}
        public Integer retiredActive {get; set;}
        public String retiredLineItemIds {get; set;}
        
        public Integer shelved {get; set;}
        public Integer shelvedActive {get; set;}
        public String shelvedLineItemIds {get; set;}
        
        public Integer canceled {get; set;}
        public Integer canceledActive {get; set;}
        public String canceledLineItemIds {get; set;}
        
        public Integer nro {get; set;}
        public Integer nroActive {get; set;}
        public String nroLineItemIds {get; set;}

        public Integer upgraded {get; set;}

        public Integer entitlementAdjustments {get; set;}
        public String comment {get; set;}
        
        
        public boolean versionUpgrade {get; set;}
        public boolean purchaseUpgrade {get; set;}
        public boolean isMirrored {get; set;}
        
        public Integer currentEntitlements {
            get{
				return originalLicenseGrants + (getTransferredFinal() + entitlementAdjustments) - (dropDownsizeActive + retiredActive + canceledActive + shelvedActive)  + upgraded - originalLicenseGrantsBeforeUpgrade ;   
            }
            set;
        }
        
        public Integer getTransferredFinal (){
            // return -1 * transferActive;
            return transferActive;
        }
	
        public Boolean hasValues(){
            if(String.isBlank(productName))
                return false;
            if(maintenanceGrants != 0 || originalLicenseGrants != 0 || pendingInNegotiation !=0 || transfer != 0 || dropDownsize != 0 || retired != 0  || shelved != 0 ||  canceled != 0 || nro != 0 || entitlementAdjustments != 0 
              || transferActive !=0 || dropDownsizeActive !=0 || retiredActive !=0 || shelvedActive !=0 || canceledActive !=0 || nroActive !=0)
                return true;
            else
                return false;
        }
        
        public CPRWrapper(){
            upgraded = 0;
            maintenanceGrants = 0;
            pendingInNegotiation = 0;
            currentEntitlements = 0;
            originalLicenseGrants = 0;
            actualOriginal = 0;
            entitlementAdjustments = 0;
            transferActive = 0;
            dropDownsizeActive = 0; 
            retiredActive = 0;
            shelvedActive = 0;
            canceledActive = 0;
            nroActive = 0;
            transfer = 0;
            dropDownsize = 0;
            retired = 0;
            shelved = 0;
            canceled = 0;
            nro = 0;
            originalLicenseGrantsBeforeUpgrade = 0;
            
            maintenanceGrantsLineItemIds = '';
            pendingInNegotiationLineItemIds = '';
            originalLicenseGrantsLineItemIds = '';
            actualOriginalLineItemIds = '';
            transferLineItemIds = '';
            dropDownsizeLineItemIds = '';
            retiredLineItemIds = '';
            shelvedLineItemIds = '';
            canceledLineItemIds = '';
            nroLineItemIds = ''; 
            comment = '';
            // PureConnect Specific fields
            productCategoryVersion = '';
            versionUpgrade = false;
            purchaseUpgrade = false;
        }
    }
}