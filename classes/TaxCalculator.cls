global with sharing class TaxCalculator {
    	// Order Line Item.Tax Status picklist options
        public static final String TAX_STATUS_COMPLETE = 'Tax Complete';
        public static final String TAX_ROLLUP_COMPLETED = 'Rollup Tax Completed';
    	public static final String TAX_NO_TAX_RETURNED = 'No Tax Returned';
        public static final Integer SURETAX_REQUEST_RESPONSE_SIZE = 120000;
    
	    private String strJsonRequest;
	    private String strJsonResponse;
    
	    private class TaxException extends Exception {}

       // Log Record for this job
        public Cloud_Billing_Log__c objJobLog;
    
        //public List<TaxCalculator.TaxLineItem> aggregatedItemList {get; set;}
        private SureTax.Request request;
        private Http http;
    	private Order__c objOrder;
        //public Map<Id, Order__c> map_OrderIdToOrder;
        public Map<String, SureTax_Settings__c> sureTaxSettings;
        public List<Service_Usage__c> serviceUsageList;
        public List<String> errorList;
        public String returnMessage;
        public Boolean isRecalculating;
    	public String strPPUCountry;
	    public String strPPUPostalCode;
    	private String strOffering = 'PEC';
    
        private List<Cloud_Billing_Exception__c> list_CloudBillingExceptions;
        public Map<Id, Order_Line_Item__c> map_IdToOrderLineItem;
        private List<Order_Line_Item__c> list_ProcessedOrderLineItems;
        private List<Service_Usage__c> list_DeletedServiceUsage;
        public Map<String, Contract_Tier_Set_Month_Charges__c> map_TaxSum;
        private List<Service_Usage_Tax__c> listOrderListItemTax;
    
        List<Id> listOliIdToUpdate = new List<Id>();

        Map<Id, Order_Line_Item__c> mapOliIdToOliToUpdate = new Map<Id, Order_Line_Item__c>();
        List<Order_Line_Item__c> listOliToInsert = new List<Order_Line_Item__c>();
    
    	//List<String> listOrderLineIdsSentInRequest = new list<String>();
    	//Set<String> setOrderLineIdsReturnedInResponse = new Set<String>();

        private void TaxCalculatorSetup() {
            sureTaxSettings = SureTax_Settings__c.getAll();
            returnMessage = '';
            errorList = new List<String>();
            isRecalculating = false;
            list_CloudBillingExceptions = new List<Cloud_Billing_Exception__c>();
            map_IdToOrderLineItem = new Map<Id, Order_Line_Item__c>();
            list_ProcessedOrderLineItems = new List<Order_Line_Item__c>();
            list_DeletedServiceUsage = new List<Service_Usage__c>();
        }
        public TaxCalculator()
        {
            TaxCalculatorSetup();
        }
    
    
        // We already have the Service Usage Tax children of Service Usage.
        // Roll them up to the Contract Tier Set Month
        public void rollupServiceUsageTaxes(List<Service_Usage__c> listServiceUsage) {
            Map<Id, Service_Usage__c> map_serviceUsage = new Map<Id, Service_Usage__c>();
            List<Service_Usage_Tax__c> listServiceUsageTax = new List<Service_Usage_Tax__c>();
    
            //list_ContractTierSetMonthIds = new<
            for (Service_Usage__c objServiceUsage : listServiceUsage) {
                map_serviceUsage.put(objServiceUsage.Id, objServiceUsage);
                listServiceUsageTax.addAll(objServiceUsage.Service_Usage_Taxes__r);
                objServiceUsage.Tax_Status__c = TAX_ROLLUP_COMPLETED;
            }
            createOrUpdateMonthlyTierSetTax(listServiceUsageTax, map_serviceUsage);
            update listServiceUsage;
        }
    
        public void createOrUpdateMonthlyTierSetTax(List<Service_Usage_Tax__c> listServiceUsageTax, Map<Id, Service_Usage__c> map_serviceUsage)
        {
            List<Id> list_ContractTierSetMonthIds = new List<Id>();
            Map<Id, Id> map_ContractTierSetMonth = new Map<Id, Id>();
    
            // Get all monthly tier sets related to service usage
            for (Id serviceUsageId : map_serviceUsage.keySet()) 
            {
                Service_Usage__c serviceUsage = map_serviceUsage.get(serviceUsageId);
                list_ContractTierSetMonthIds.add(serviceUsage.Contract_Tier_Set_Month__c);
                map_ContractTierSetMonth.put(serviceUsage.Id, serviceUsage.Contract_Tier_Set_Month__c);
            }
            system.debug('##Month Map: ' + map_ContractTierSetMonth);
            
            // Map monthly tier set (key) to map of monthly tier set taxes (value)
            // String Contract_Tier_Set_Month__c#Description__c as Key
            map_TaxSum = new Map<String, Contract_Tier_Set_Month_Charges__c>();
            Map<String,Contract_Tier_Set_Month_Charges__c> map_ContractTierSetMonthCharge = new Map<String,Contract_Tier_Set_Month_Charges__c>();
            
            for(Contract_Tier_Set_Month_Charges__c contractTierSetMonthCharge : [SELECT Id, Description__c, Amount__c, Contract_Tier_Set_Month__c 
                                                                                        FROM Contract_Tier_Set_Month_Charges__c
                                                                                        WHERE Contract_Tier_Set_Month__c IN :list_ContractTierSetMonthIds])
            {
                String strKey = contractTierSetMonthCharge.Contract_Tier_Set_Month__c+'#'+contractTierSetMonthCharge.Description__c;
                map_TaxSum.put(strKey, contractTierSetMonthCharge);
                map_ContractTierSetMonthCharge.put(contractTierSetMonthCharge.Contract_Tier_Set_Month__c, contractTierSetMonthCharge);
            }
            system.debug('##Tax Sum Map: ' + map_TaxSum); 
            
            // loop through service usage, check to see if related tier has the tax code already
            // If it does, add to the monthly tier set tax, otherwise create new and include in map.
            Map<String,Contract_Tier_Set_Month_Charges__c> map_UpsertTierSetMonthCharges = new Map<String,Contract_Tier_Set_Month_Charges__c>();
                
            Contract_Tier_Set_Month_Charges__c monthCharge;
            for (Service_Usage_Tax__c usageTax : listServiceUsageTax)
            {
                monthCharge = new Contract_Tier_Set_Month_Charges__c();
                Service_Usage__c serviceUsage = map_serviceUsage.get(usageTax.Service_Usage__c);
                String strKey =  serviceUsage.Contract_Tier_Set_Month__c+'#'+usageTax.Tax_Type_Code__c;  
                if(map_TaxSum.containsKey(strKey)){
                    system.debug('##Adding to ' + usageTax.Tax_Type_Code__c);
                    monthCharge = map_TaxSum.get(strKey);
                    monthCharge.Amount__c += usageTax.Tax_Amount__c;
                    if(!map_UpsertTierSetMonthCharges.containsKey(strKey)){
                        map_UpsertTierSetMonthCharges.put(strKey, monthCharge);
                    }
                }
                else{
                    system.debug('##New Month Entry: ' + serviceUsage.Contract_Tier_Set_Month__c);
                    // Create new charge and new map key for the given tier set month
                    monthCharge = new Contract_Tier_Set_Month_Charges__c();
                    monthCharge.Contract_Tier_Set_Month__c = serviceUsage.Contract_Tier_Set_Month__c;
                    monthCharge.Description__c = usageTax.Tax_Type_Code__c;
                    monthCharge.Amount__c = usageTax.Tax_Amount__c;                                  	   	  
                    map_UpsertTierSetMonthCharges.put(strKey, monthCharge);
                    map_TaxSum.put(strKey, monthCharge);
                }  
            }
            
            for (Contract_Tier_Set_Month_Charges__c objCTSMC: map_UpsertTierSetMonthCharges.values()) {
                System.debug(objCTSMC);
            }
            
            upsert map_UpsertTierSetMonthCharges.values();
        }

        private Decimal calculateTotalRevenue(List<Order_Line_Item__c> listOrderLineItemsToTax)
        {
            Decimal totalRevenue = 0;
            for (Order_Line_Item__c objOLI : listOrderLineItemsToTax)
            {
                if (objOLI.Total_Price__c != null)
                {
                    totalRevenue += objOLI.Total_Price__c;
                }
            }   
            system.debug('Revenue: ' + totalRevenue);
            return totalRevenue;
        }
    
        public HttpResponse sendSureTaxRequest(HttpRequest objHttpRequest)
        {
            if(!Test.isRunningTest())
            {
                system.debug('#Request: ' + objHttpRequest);
                HttpResponse objHttpResponse = http.send(objHttpRequest);
                system.debug('objHttpResponse.getBody() ' + objHttpResponse.getBody());
    
                Integer intHttpResponseStatusCode = objHttpResponse.getStatusCode();
                System.Debug('intHttpResponseStatusCode ' + intHttpResponseStatusCode);
                if (intHttpResponseStatusCode == 200)
                {
                    system.debug('sendSureTaxRequest: Response OK');
                }
                else
                {
                    system.debug('sendSureTaxRequest: Response ERROR ' + objHttpResponse.getStatusCode());
                    SureTax.Response sureTaxResponse = (SureTax.Response)JSON.deserializeStrict(JSON.createParser(objHttpResponse.getBody()).getText(), 
                                                                                                SureTax.Response.class);
                    errorList.add(sureTaxResponse.HeaderMessage);
                    // **Add exception log if not recalculateTaxes
                }
                return objHttpResponse;
            }
            
            return null;
        }
    
        private void parseResponse(HttpResponse objHttpResponse)
        {
            System.debug('parseResponse: objHttpResponse ' + objHttpResponse);
//            System.debug('objHttpResponse.getBody() ' + objHttpResponse.getBody());
    
            JSONParser parser;
            if (!Test.isRunningTest())
            {
	            System.debug('objHttpResponse.getBody() ' + objHttpResponse.getBody());
                parser = JSON.createParser(objHttpResponse.getBody());
            }
            else
            {
                parser = JSON.createParser(TaxCalculatorTest.mockResponse(null));
            }
            
            while (parser.nextToken() != null) 
            {
                // Get the response, which is wrapped in a 'd' object
                if (parser.getCurrentToken() == JSONToken.START_OBJECT)
                {
                    // Get the value.
                    parser.nextToken();
                    parser.nextValue();
    
                    SureTax.Response sureTaxResponse = (SureTax.Response)JSON.deserializeStrict(parser.getText(), SureTax.Response.class);
                    //system.debug('sureTaxResponse ' + sureTaxResponse);
                    strJsonResponse = JSON.serializePretty(sureTaxResponse);
                    System.debug('sureTaxResponse pretty ' + strJsonResponse);
    
                    // Log any messages on the item level passed in the response
                    if (sureTaxResponse.ItemMessages != null && sureTaxResponse.ItemMessages.size() > 0)
                    {
                        System.debug('sureTaxResponse.ItemMessages is NOT null');
                        for (SureTax.ItemMessage message : sureTaxResponse.ItemMessages) {
                            if (message != null) System.debug(message);
                        }
                        createBillingExceptions(sureTaxResponse.ItemMessages);
                    } else if (sureTaxResponse.GroupList != null)
                    {
                        System.debug('sureTaxResponse.ItemMessages is null or size zero');
                        System.debug('sureTaxResponse.GroupList is NOT null, create Order Line Item');

/*
                        // put all returned Order Line Items from SureTax into a set                        
                        for (SureTax.ItemTax itemTax : sureTaxResponse.GroupList) {
                            setOrderLineIdsReturnedInResponse.add(itemTax.LineNumber);
                        }
                        // Check that we got a tax line for every Order Line Item. Throw exception if not.
                        for (String strOrderLineId : listOrderLineIdsSentInRequest) {
                            if (!setOrderLineIdsReturnedInResponse.contains(strOrderLineId)) {
                                String strError = 'Order Line Id ' + strOrderLineId + ' did not return a tax item in the Response';
                                errorList.add(strError);
                                throw new TaxException(strError);
                            }
                        }
*/
                        createOrderLineItemTax(sureTaxResponse.GroupList);
                    } else {
                        System.debug('sureTaxResponse.ItemMessages is null or size zero');
                        System.debug('sureTaxResponse.GroupList is null');
                    }
    
                    // Delete service usage records that had response errors.
                    /*
                    if (list_DeletedServiceUsage.size() > 0)
                    {
                        deleteErroredServiceUsage();
                    }
                    */
                    break;
                }
            }
        }

        private void createOrderLineItemTax(SureTax.ItemTax[] itemTaxes)
        {
            System.Debug('createOrderLineItemTax itemTaxes size ' + itemTaxes.size());
            listOrderListItemTax = new List<Service_Usage_Tax__c>();
    
            // First delete any previous service usage tax if recalculating tax
            /*
            if (isRecalculating)
            {
                Set<Id> serviceUsageIds = (new Map<Id, Service_Usage__c>(serviceUsageList)).keySet();
                List<Service_Usage_Tax__c> obj_listServiceUsageTax = new List<Service_Usage_Tax__c>([SELECT Id FROM Service_Usage_Tax__c WHERE Service_Usage__c IN :serviceUsageIds]);
    
                if (obj_listServiceUsageTax.size() > 0)
                {
//                    delete obj_listServiceUsageTax;
                }
            }
            */
    
            for (SureTax.ItemTax itemTax : itemTaxes)
            {
                system.debug('createOrderLineItemTax itemTax ' + itemTax);
                system.debug('Line: ' + itemTax.LineNumber + ' State: ' + itemTax.StateCode);
                for (SureTax.Tax tax : itemTax.TaxList)
                {
                    system.debug('tax: ' + tax.TaxTypeCode + ' ' + tax.TaxTypeDesc + ': ' + tax.TaxAmount);
                    Order_Line_Item__c objOLI = map_IdToOrderLineItem.get(itemTax.LineNumber);

                    Service_Usage_Tax__c objSuTax = new Service_Usage_Tax__c();
                    objSuTax.Order_Line_Item__c = objOLI.Id;
                    objSuTax.Tax_Amount__c = Decimal.valueOf(tax.TaxAmount);
                    objSuTax.Tax_Type_Code__c = tax.TaxTypeCode;
                    // New Info Added
                    objSuTax.City_Name__c = tax.CityName;
                    objSuTax.County_Name__c = tax.CountyName;
                    objSuTax.Fee_Rate__c = String.valueOf(tax.FeeRate);
                    //objSuTax.Jurisdiction_Code__c = tax.JurisdictionCode;
                    objSuTax.Jurisdiction_Code__c = tax.Juriscode;
                    objSuTax.Percent_Taxable__c = String.valueOf(tax.PercentTaxable);
                    objSuTax.Revenue__c = tax.Revenue;
                    objSuTax.Revenue_Base__c = tax.RevenueBase;
                    //objSuTax.Tax_Auth_Id__c = tax.TaxAuthId;
                    objSuTax.Tax_Auth_Id__c = tax.TaxAuthorityID;
                    //objSuTax.Tax_Auth_Name__c = tax.TaxAuthName;
                    objSuTax.Tax_Auth_Name__c = tax.TaxAuthorityName;
                    objSuTax.Tax_On_Tax__c = tax.TaxOnTax;
                    objSuTax.Tax_Type_Desc__c = tax.TaxTypeDesc;
                    // End New Info Added
                    listOrderListItemTax.add(objSuTax);
                }
            }
    
            if (listOrderListItemTax.size() > 0)
            {
                insert listOrderListItemTax;
                updateParentOrderLineItemTaxStatus(listOrderListItemTax);
            }
        }
        private void updateParentOrderLineItemTaxStatus(List<Service_Usage_Tax__c> listChildOrderLineItemTaxes)
        {
            Set<Order_Line_Item__c> set_OLI = new Set<Order_Line_Item__c>();
    
            for (Service_Usage_Tax__c objChildTaxOLI : listChildOrderLineItemTaxes)
            {
                Order_Line_Item__c objOLI = map_IdToOrderLineItem.get(objChildTaxOLI.Order_Line_Item__c);
                if(!set_OLI.contains(objOLI))
                {
                    objOLI.Tax_Status__c = TAX_STATUS_COMPLETE;
                    set_OLI.add(objOLI);
                }
            }
    
            list_ProcessedOrderLineItems.addAll(set_OLI);
    
            update list_ProcessedOrderLineItems;
        }
    
        private void createBillingExceptions(SureTax.ItemMessage[] itemMessages)
        {
            System.Debug('createBillingExceptions itemMessages size ' + itemMessages.size());
            for (SureTax.ItemMessage message : itemMessages)
            {
                System.Debug('createBillingExceptions add error message ' + message);
                errorList.add(message.Message);
            }
        }

        public static Order_Line_Item__c createNewOrderLineItem(Product2 objProduct) {
            Order_Line_Item__c objOLI = new Order_Line_Item__c();
            if (objProduct != null) {
                objOLI.Product__c = objProduct.Id;
                objOLI.APN_Number__c = objProduct.APN_Number__c;
                objOLI.Name = objProduct.Name;
                objOLI.Description__c = objProduct.Name;
	            objOLI.Unit_Of_Measure__c = objProduct.Unit_Of_Measure__c;
            }
            objOLI.RecordTypeId = (Id)Label.Cloud_Monthly_Billing_Order_Line_RecordTypeId;
            objOLI.Description__c = '';
            objOLI.Tier_Set_Period_In_Months__c = 1;
            objOLI.Installment_Plan__c = false;
            objOLI.POB_Type__c = 'Not Applicable';
            objOLI.Revenue_Classification__c = 'Not Applicable';
            return objOLI;
        }
/*        
        private String getErrorsToLog() {
            String strErrors;
            Boolean blnFirst = false;
            for (String strError : errorList) {
                if (blnFirst) {
                    strErrors = strError;
                } else {
                    strErrors += ',' + strError;
                }
            }
            if (!String.isBlank(strErrors)) {
                if (strErrors.length() > 255) {
                    strErrors = strErrors.substring(0,254);
                }
            }
            return strErrors;
        }
*/    
        // Main Entry Point to Call from Batch Processing For Taxing Order Line Items
        public void processSureTaxRequestTopLevel(List<Order__c> listOrdersToTax) {
            if (listOrdersToTax.size() > 1) {
                objJobLog.Exceptions__c += 'Not expecting to handle more than one order per batch. Please contact your administrator';
                return;
            }
            objOrder = listOrdersToTax[0];
            if (objOrder.Offering_Type__c != null && objOrder.Offering_Type__c.contains('PureConnect')) {
                strOffering = 'PCC';
            }
            //objJobLog.Exceptions__c = 'Order:' + objOrder.Id + ':';
            /*
            if (String.isNotBlank(objOrder.Contract_Lookup__r.PPU_Country__c)) {
                strPPUCountry = objOrder.Contract_Lookup__r.PPU_Country__c;
            }
			*/
            if (String.isNotBlank(objOrder.Contract_Lookup__r.Postal_Code_Override__c)) {
                strPPUPostalCode = objOrder.Contract_Lookup__r.Postal_Code_Override__c;
            }
            if (String.isBlank(strPPUPostalCode)) {
                Account_Order_Address__c objAccountOrderAddress = [
                    SELECT Order__c, Country__c, Zip_Code__c, State__c
                    FROM Account_Order_Address__c
                    WHERE Order__c = :objOrder.Id AND Address_Type__c = 'Bill To'
                ];
                if (objAccountOrderAddress == null) {
                    String strError = 'No Bill To Address Found';
                    errorList.add(strError);
                    throw new TaxException(strError);
                }
                if (objAccountOrderAddress.Zip_Code__c == null) {
                    String strError = 'No Zip Code in Bill To Address';
                    errorList.add(strError);
                    throw new TaxException(strError);
                }
                strPPUPostalCode = objAccountOrderAddress.Zip_Code__c;
            }
            List<Order_Line_Item__c> listOLIsToTax = [
                SELECT
                Id,Order__c,Order__r.Offering_Type__c,Order__r.Sales_Org__c,Product__c,
                Order__r.Name,
                Product__r.APN_Number__c,Order__r.End_User_SAP_Code__c,Order__r.Subsidaries__r.Name,
                Product__r.SureTax_Code_Undetermined__c,
                Product__r.SureTax_Grouping__c,
                Product__r.SureTax_Regulatory_Code__c,
                Order__r.Year__c,
                Order__r.Month__c,
                Order__r.Maintenance_Start__c,
                Total_Price__c,
                BigMachines_Quantity__c,
                Tax_Status__c,
                CreatedDate
                FROM Order_Line_Item__c
                WHERE Order__c = :objOrder.Id
                AND Tax_Status__c = :BatchTaxCloudUsageData.TAX_STATUS_ORDER_LINE_SURETAX_NEEDED
            ];

			//System.debug('processSureTaxRequestTopLevel: Order Line Tax strSOQL ' + strSOQL);
            //List<Order_Line_Item__c> listOLIsToTax = (List<Order_Line_Item__c>)Database.query(strSOQL);
            processSureTaxRequest(listOLIsToTax);

            if (mapOliIdToOliToUpdate != null && mapOliIdToOliToUpdate.size() > 0) {
                List<Order_Line_Item__c> listOliToUpdate = new List<Order_Line_Item__c>();
                for (Id i : mapOliIdToOliToUpdate.keySet()) {
                    Order_Line_Item__c objOLI = mapOliIdToOliToUpdate.get(i);
                    System.Debug('objOLI to update ' + objOLI);
                    listOliToUpdate.add(objOLI);
                }
                // Do not bypass the triggers
                Util.Bypass_Trigger_Chk = false;
                // Force running of the Summation Trigger and order total process
                Util.blnRunPPUTrigger = TriggerFlowManager.POPULATE_PPU_ORDER_TOTAL = true;
                //Changing to upsert as this might contain new items
                upsert listOliToUpdate;
            }
            if (listOliToInsert != null && listOliToInsert.size() > 0) {
                List<Order_Line_Item__c> listOliToInsertRemoveWithId = new List<Order_Line_Item__c>();
                for (Order_Line_Item__c objOLI : listOliToInsert) {
                    if (objOLI.Id != null) {
                        System.debug('OLI already inserted ' + objOLI);
                    } else {
                        listOliToInsertRemoveWithId.add(objOLI);
                    }
                }
	            if (listOliToInsertRemoveWithId != null && listOliToInsertRemoveWithId.size() > 0) {
                    // Do not bypass the triggers
                    Util.Bypass_Trigger_Chk = false;
                    // Force running of the Summation Trigger and order total process
                    Util.blnRunPPUTrigger = TriggerFlowManager.POPULATE_PPU_ORDER_TOTAL = true;
                    insert listOliToInsertRemoveWithId;
                }
            }
            update listOrdersToTax;

            if (errorList!= null && errorList.size() > 0) {
                objJobLog.Exceptions__c += errorList;
            }
        }
    
        // Order_Line_Item__c from only one Order unit
        public void processSureTaxRequest(List<Order_Line_Item__c> listOrderLineItemsToTax) {
            Order_Line_Item__c objFirstOLI = null;
            if (listOrderLineItemsToTax != null && listOrderLineItemsToTax.size() > 0) {
                objFirstOLI = listOrderLineItemsToTax[0];
            }
            List<Order_Line_Item__c> listAllOrderLineItems = [
                select Id, Order__c, Name, Sales_Price__c, Order__r.Offering_Type__c, Product__r.APN_Number__c
                from Order_Line_Item__c
                where Order__c = :objFirstOLI.Order__c
            ];
            // Map of OLI APN Numbers to the OLI so we can pull an existing OLI to add more tax to an existing line
            Map<String, Order_Line_Item__c> map_OliProductAPNToOli = new Map<String, Order_Line_Item__c>();
            for (Order_Line_Item__c objOLI : listAllOrderLineItems) {
                map_OliProductAPNToOli.put(objOLI.Product__r.APN_Number__c, objOLI);
            }

            HttpRequest objHttpRequest;
            try {
	            objHttpRequest = prepareSureTaxRequest(listOrderLineItemsToTax);
            } catch (TaxException te) {
                throw te;
            }

            HttpResponse objHttpResponse = sendSureTaxRequest(objHttpRequest);
            if (objHttpResponse != null) {
                parseResponse(objHttpResponse);
            } else if (Test.isRunningTest()) {
                //ECD
                parseResponse(null);
            }

            // These strings are assigned during above request and response processing
            {
                if (strJsonRequest.length() > SURETAX_REQUEST_RESPONSE_SIZE) {
                    System.Debug('Length of Request too long ' + strJsonRequest.length());
                    strJsonRequest = strJsonRequest.substring(1, SURETAX_REQUEST_RESPONSE_SIZE);
                }
                System.Debug('Length of Request length ' + strJsonRequest.length());
                objOrder.SureTax_Request__c = strJsonRequest;
            }
            {
                //System.Debug('Response: ' + strJsonResponse);
                if (strJsonResponse.length() > SURETAX_REQUEST_RESPONSE_SIZE) {
                    System.Debug('Length of Response too long ' + strJsonResponse.length());
                    strJsonResponse = strJsonResponse.substring(1, SURETAX_REQUEST_RESPONSE_SIZE);
                }
                System.Debug('Length of Response length ' + strJsonResponse.length());
                objOrder.SureTax_Response__c = strJsonResponse;
            }

            // If we added some tax, roll it up to Order Line Items if they exist or create new ones if needed.
            Set<Id> setOliIdToUpdate = new Set<Id>();
            if (listOrderListItemTax != null && listOrderListItemTax.size() > 0) {
                //Prepare possible Tax Products
                Set<String> setTaxProductAPNs = new Set<String>();
                for (Service_Usage_Tax__c objTax : listOrderListItemTax) {
                    // ECD Tax Append PEC/PCC
                    String strtaxProductAPN = CloudBillingUtil.getSureTaxProductAPNFromResponseCode(objTax.Tax_Type_Code__c, strOffering);
                    System.Debug('processSureTaxRequest: objTax.Tax_Type_Code__c '+ objTax.Tax_Type_Code__c + ' returned ' + strtaxProductAPN);
                    setTaxProductAPNs.add(strtaxProductAPN);
                }
                Map<String, Product2> map_TaxProductAPNToProduct = CloudBillingUtil.getMapOfferingAPNNumberToProduct(setTaxProductAPNs);
    
                for (Service_Usage_Tax__c objTax : listOrderListItemTax) {
                    // ECD Tax Need to deal with this
                    String strTaxAPNNumber = CloudBillingUtil.getSureTaxProductAPNFromResponseCode(objTax.Tax_Type_Code__c, strOffering);
                    Order_Line_Item__c objExistingOLI = map_OliProductAPNToOli.get(strTaxAPNNumber);
                    System.Debug('processSureTaxRequest: objTax.Tax_Type_Code__c ' + objTax.Tax_Type_Code__c);
                    Integer intLineCount = map_OliProductAPNToOli.size();
                    System.Debug('processSureTaxRequest: Got match of existing map Order Line Items for Order with APN ' + strTaxAPNNumber);
                    //Order_Line_Item__c objOLI = map_ProductAPNToOLI.get(strTaxAPNNumber);
                    if (objExistingOLI != null) {
                        System.Debug('processSureTaxRequest: Found Matching OLI already existing ' + objExistingOLI);
                        objExistingOLI.Sales_Price__c += objTax.Tax_Amount__c;
                        objExistingOLI.Net_Unit_Price__c = objExistingOLI.List_Price__c = objExistingOLI.Ext_Net_Price__c = objExistingOLI.Sales_Price__c;
                        if(!setOliIdToUpdate.contains(objExistingOLI.Id)) {
                            System.Debug('processSureTaxRequest: Adding objOLI to update ' + objExistingOLI);
                            mapOliIdToOliToUpdate.put(objExistingOLI.Id, objExistingOLI);
                        }
                    } else {
                        System.Debug('processSureTaxRequest: No Matching OLI for tax ' + strTaxAPNNumber + ' found need to create one');
                        String strTaxProductAPN = CloudBillingUtil.getSureTaxProductAPNFromResponseCode(objTax.Tax_Type_Code__c, strOffering);
                        Product2 objProduct = map_TaxProductAPNToProduct.get(strTaxProductAPN);
                        System.Debug('processSureTaxRequest: objProduct ' + objProduct);
                        Order_Line_Item__c objOLI = createNewOrderLineItem(objProduct);
                        objOLI.Order__c = objOrder.Id;
                        objOLI.Line_Number__c = ++intLineCount;
                        objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = 1.0;
                        objOLI.Net_Unit_Price__c = objOLI.Ext_Net_Price__c =
                            objOLI.Sales_Price__c = objOLI.List_Price__c = objTax.Tax_Amount__c;
                        objOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                        objOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c;
                        map_OliProductAPNToOli.put(objProduct.APN_Number__c, objOLI); // So we can add to this line again if we see the same named tax line again
                        listOliToInsert.add(objOLI);
                    }
                }
            }
            
            // OLIs that did not return a tax, this is OK. Mark them as No Tax Needed
            System.debug('Attempting to set unchanged OLIs to No Tax Returned');
            for (Order_Line_Item__c objOLI : listOrderLineItemsToTax) {
                if (objOLI.Tax_Status__c == BatchTaxCloudUsageData.TAX_STATUS_ORDER_LINE_SURETAX_NEEDED) {
	                System.debug('No Tax Returned for ' + objOLI);
                    objOLI.Tax_Status__c = TAX_NO_TAX_RETURNED;
                    mapOliIdToOliToUpdate.put(objOLI.Id, objOLI);
                }
            }
        }
                                             
        public HttpRequest prepareSureTaxRequest(List<Order_Line_Item__c> listOrderLineItemsToTax) {
            Decimal totalRevenue = calculateTotalRevenue(listOrderLineItemsToTax);
            try {
            	return prepareSureTaxRequest(totalRevenue, listOrderLineItemsToTax);
            } catch (TaxException te) {
                throw te;
            }
        }
    
        public HttpRequest prepareSureTaxRequest(Decimal totalRevenue, List<Order_Line_Item__c> listOrderLineItemsToTax)
        {
            Order_Line_Item__c objFirstOLI = null;
            if (listOrderLineItemsToTax != null && listOrderLineItemsToTax.size() > 0) {
                objFirstOLI = listOrderLineItemsToTax[0];
            }
            http = new Http();
            HttpRequest objHttpRequest = new HttpRequest();
            objHttpRequest.setMethod('POST');
            //request.setHeader('Accept','application/json');
            objHttpRequest.setHeader('Content-Type', 'application/json');
            objHttpRequest.setEndpoint(sureTaxSettings.get('SureTaxEndpoint').Value__c + '/PostRequest');
    
            Date requestDate = Date.Today();
            request = new SureTax.Request();
            if (objFirstOLI != null) {
                if (objFirstOLI.Order__r.Offering_Type__c != null) {
                    request.BusinessUnit = objFirstOLI.Order__r.Offering_Type__c;
                } else {
                    request.BusinessUnit = objFirstOLI.Order__r.Sales_Org__c;
                }
            }
            //ECD
            String strSureTaxClientNumber = 'SureTaxClientNumber-' + strOffering + '-' + objFirstOLI.Order__r.Subsidaries__r.Name;
            System.debug('prepareSureTaxRequest: Looking for strSureTaxClientNumber ' + strSureTaxClientNumber);
            request.ClientNumber = sureTaxSettings.get(strSureTaxClientNumber).Value__c;
            request.ClientTracking = objFirstOLI.Order__r.Name;
            String strSureTaxValidationKey = 'SureTaxValidationKey-' + strOffering + '-' + objFirstOLI.Order__r.Subsidaries__r.Name;
            System.debug('prepareSureTaxRequest: Looking for strSureTaxValidationKey ' + strSureTaxValidationKey);
            request.ValidationKey = sureTaxSettings.get(strSureTaxValidationKey).Value__c;
            request.ResponseGroup = sureTaxSettings.get('SureTaxResponseGroup').Value__c;
            request.ResponseType = sureTaxSettings.get('SureTaxResponseType').Value__c;
            request.ReturnFileCode = sureTaxSettings.get('SureTaxReturnFileCode').Value__c;
            request.STAN = String.valueOf(objFirstOLI.Order__c).substring(0, 15);
            request.DataYear = request.CmplDataYear = objFirstOLI.Order__r.Year__c;
            request.DataMonth = request.CmplDataMonth = objFirstOLI.Order__r.Month__c;
            request.TotalRevenue = totalRevenue;
            try {
                request.ItemList = prepareSureTaxRequestItemList(listOrderLineItemsToTax);
                // SureTax uses their own HTTP standardization, format accordingly
                String body = '{"request":' + JSON.serialize(JSON.serialize(request, true)) +'}';    
                objHttpRequest.setBody(body);
                //system.debug(body);
    
                strJsonRequest = JSON.Serializepretty(request);
                System.Debug('Serializepretty request ' + strJsonRequest);
    
                return objHttpRequest;
            } catch (TaxException te) {
                throw te;
            }
        }
/*    
        private Boolean blnValidateAddress(Account_Order_Address__c objAddress) {
            if (objAddress == null) {
                return false;
            }
            if (objAddress.State__c.length() != 2) {
                return false;
            }
            if (objAddress.Country__c.length() != 2) {
                return false;
            }
            if (objAddress.Zip_Code__c.length() == 5 || objAddress.Zip_Code__c.length() == 10) {
                return true;
            } else {
                return false;
            }
        }
*/
        private SureTax.Item[] prepareSureTaxRequestItemList(List<Order_Line_Item__c> listOrderLineItemsToTax)
        {
            SureTax.Item[] items = new SureTax.Item[]{};
            List<String> serviceHashes = new List<String>();
            Map<String, String> taxCodeMap = new Map<String, String>();
            Integer index = 0;
    
            // Create a request item for each Service Usage record passed
            for (Order_Line_Item__c objOLI : listOrderLineItemsToTax)
            {
                //listOrderLineIdsSentInRequest.add(String.valueOf(objOLI.Id));

                if (objOLI.Product__r.SureTax_Code_Undetermined__c == null) {
                    String strError = 'No Undetermined SureTax Code';
                    errorList.add(strError);
                    throw new TaxException(strError);
                }

                System.debug('prepareSureTaxRequestItemList objOLI ' + objOLI);
                System.debug('prepareSureTaxRequestItemList objOLI.Product__r.SureTax_Code_Undetermined__c: ' + objOLI.Product__r.SureTax_Code_Undetermined__c +
                             ' objAddress.Zip_Code__c ' + strPPUPostalCode);
                map_IdToOrderLineItem.put(objOLI.Id, objOLI);
                
                SureTax.Item requestItem = new SureTax.Item();
                
                String strCustomerNumber = objOLI.Order__r.End_User_SAP_Code__c + '-' + objOLI.Order__r.Subsidaries__r.Name;
                System.Debug('Created strCustomerNumber ' + strCustomerNumber);
                requestItem.CustomerNumber = strCustomerNumber; // **Populate from where?
                requestItem.InvoiceNumber = objOLI.Order__c;
                requestItem.LineNumber = objOLI.Id; //
                requestItem.Revenue = objOLI.Total_Price__c;
                requestItem.Parameter1 = objOLI.Product__r.SureTax_Grouping__c;
                requestItem.Parameter2 = objOLI.Product__r.APN_Number__c;
                //requestItem.Seconds = Math.Round(objOLI.BigMachines_Quantity__c);//Math.Round(serviceUsage.Total_Duration__c); //** how do they round?
                requestItem.TransDate = objOLI.Order__r.Maintenance_Start__c.format();
                requestItem.TransTypeCode = objOLI.Product__r.SureTax_Code_Undetermined__c;
                requestItem.RegulatoryCode = objOLI.Product__r.SureTax_Regulatory_Code__c;
                requestItem.Units = Math.Round(objOLI.BigMachines_Quantity__c);
                //requestItem.State = '';//objAddress.State__c;//'MA';
                //requestItem.Country = '';//objAddress.Country__c;//'IE';//objOLI.Order__r.Bill_To_Name__r.Country__c;
                //requestItem.PostalCode = strPostalCode.substringBefore('-');
                String strPostalCodeFull = strPPUPostalCode;
                
                //TEST TO FORCE FAILURE...DO NOT RELEASE
                /*
if (index == 0) {
strPostalCodeFull = 'badtest';
index++;
}
*/
                //TEST TO FORCE FAILURE...DO NOT RELEASE
                
                String strPostalCode = strPostalCodeFull.substringBefore('-');
                String strPlus4 = strPostalCodeFull.substringAfter('-');
                if (strPlus4 == null ||  strPlus4.length() == 0) {
                    requestItem.Plus4 = '0000';
                } else {
                    requestItem.Plus4 = strPlus4;
                }
                System.Debug('ZipCode Settings strPostalCodeFull ' + strPostalCodeFull +
                             ' strPostalCode ' + strPostalCode +
                             ' strPlus4 ' + strPlus4);
                requestItem.Address = new SureTax.Address(strPostalCode, strPlus4);
                requestItem.P2PAddress = new SureTax.Address(strPostalCode, strPlus4);
                
                //System.debug('all applyItemListDefaults with requestItem ' + requestItem);
                applyItemListDefaults(requestItem);
                if (validateItem(requestItem, objOLI))
                {
                    items.add(requestItem);
                }
            }
    
            return items;
        }
    
        private void applyItemListDefaults(SureTax.Item requestItem)
        {
            String[] exemptionsList;
            String strExemptionsList = sureTaxSettings.get('SureTaxExemptionCodeList').Value__c;
            if (strExemptionsList != null) {
                exemptionsList = strExemptionsList.split(',');
            } else {
                exemptionsList = new String[]{'00'};
            }
    
            //requestItem.AuxRevenue = requestItem.AuxRevenue == null ? 0 : requestItem.AuxRevenue;
            requestItem.AuxRevenueType = requestItem.AuxRevenueType == null ? '01' : requestItem.AuxRevenueType;
            requestItem.BillToNumber = requestItem.BillToNumber == null ? '' : requestItem.BillToNumber;
            //requestItem.CommonCarrier = requestItem.CommonCarrier == null ? true : requestItem.CommonCarrier;
            requestItem.CustomerNumber = requestItem.CustomerNumber == null ? '' : requestItem.CustomerNumber;
            //requestItem.DestCountryCode = requestItem.DestCountryCode == null ? '' : requestItem.DestCountryCode;
            //requestItem.FreightOnBoard = requestItem.FreightOnBoard == null ? 'D' : requestItem.FreightOnBoard;
            requestItem.Geocode = requestItem.Geocode == null ? '' : requestItem.Geocode;
            //requestItem.InvoiceNumber = requestItem.InvoiceNumber == null ? '' : requestItem.InvoiceNumber;
            requestItem.LineNumber = requestItem.LineNumber == null ? '' : requestItem.LineNumber;
            //requestItem.MailOrder = requestItem.MailOrder == null ? true : requestItem.MailOrder;
            //requestItem.OrderApprovalZipcode = requestItem.OrderApprovalZipcode == null ? '' : requestItem.OrderApprovalZipcode;
            //requestItem.OrderApprovalPlus4 = requestItem.OrderApprovalPlus4 == null ? '0000' : requestItem.OrderApprovalPlus4;
            //requestItem.OrderPlacementZipcode = requestItem.OrderPlacementZipcode == null ? '' : requestItem.OrderPlacementZipcode;
            //requestItem.OrderPlacementPlus4 = requestItem.OrderPlacementPlus4 == null ? '0000' : requestItem.OrderPlacementPlus4;
            //requestItem.OriginCountryCode = requestItem.OriginCountryCode == null ? '' : requestItem.OriginCountryCode;
            requestItem.OrigNumber = requestItem.OrigNumber == null ? '' : requestItem.OrigNumber;
            requestItem.Plus4 = requestItem.Plus4 == null ? '' : requestItem.Plus4;
            //requestItem.PostalCode = requestItem.PostalCode == null ? '' : requestItem.PostalCode;
            requestItem.P2PPlus4 = requestItem.P2PPlus4 == null ? '' : requestItem.P2PPlus4;
            requestItem.P2PZipcode = requestItem.P2PZipcode == null ? '' : requestItem.P2PZipcode;
            requestItem.RegulatoryCode = requestItem.RegulatoryCode == null ? sureTaxSettings.get('SureTaxRegulatoryCode').Value__c : requestItem.RegulatoryCode;
            requestItem.SalesTypeCode = requestItem.SalesTypeCode == null ? sureTaxSettings.get('SureTaxSalesTypeCode').Value__c : requestItem.SalesTypeCode;
            //requestItem.Seconds = requestItem.Seconds == null ? 1 : requestItem.Seconds;
            //requestItem.ShipFromZipCode = requestItem.ShipFromZipCode == null ? '' : requestItem.ShipFromZipCode;
            //requestItem.ShipFromPlus4 = requestItem.ShipFromPlus4 == null ? '0000' : requestItem.ShipFromPlus4;
            //requestItem.ShipFromPOB = requestItem.ShipFromPOB == null ? true : requestItem.ShipFromPOB;
            requestItem.TaxExemptionCodeList = requestItem.TaxExemptionCodeList == null ? exemptionsList : requestItem.TaxExemptionCodeList;
            requestItem.TaxIncludedCode = requestItem.TaxIncludedCode == null ? sureTaxSettings.get('SureTaxTaxIncludedCode').Value__c : requestItem.TaxIncludedCode;
            requestItem.TaxSitusRule = requestItem.TaxSitusRule == null ? sureTaxSettings.get('SureTaxSitusRule').Value__c : requestItem.TaxSitusRule;
            requestItem.TermNumber = requestItem.TermNumber == null ? '' : requestItem.TermNumber;
            //requestItem.UDF = requestItem.UDF == null ? '' : requestItem.UDF;
            requestItem.UnitType = requestItem.UnitType == null ? sureTaxSettings.get('SureTaxUnitType').Value__c : requestItem.UnitType;
            requestItem.Units = requestItem.Units == null ? 1 : requestItem.Units;
            //requestItem.ZipCode = requestItem.Zipcode == null ? '' : requestItem.Zipcode;
        }
    
        // TODO May remove
        private Boolean validateItem(SureTax.Item requestItem, Order_Line_Item__c objOLI)
        {
            List<String> validationErrorList = new List<String>();
            if (requestItem.TransTypeCode == null || requestItem.TransTypeCode == '')
            {
                validationErrorList.add(RequestItem.LineNumber + ': No SureTax Transaction Type Code on the Product for Order Line Item ' + objOLI);
            }
    
            errorList.addAll(validationErrorList);
    
            return validationErrorList.size() == 0;
        }
    
    }