public without sharing class CreatePureCloudOrderController {
    //Declare variables
    public zqu__Quote__c objQuote { get; set; }
    public Attachment objAttachment { get; set; }
    public List<Order__c> list_NewParentOrders { get; set; }
    public Integer intNoOfOrders { get; set; }
    
    public Id expScrnChkLstId { get; set; }
    
    public Boolean blnShowExportScreeningMsg {get; private set;}
    public Boolean blnShowExportScreeningExpireMsg {get; private set;}
    
    private Map<String, RecordType> map_OrderRecTypes = new Map<String, RecordType>();
    private Map<String, RecordType> map_OrderLnItmRecTypes = new Map<String, RecordType>();
    private Map<Id, Id> map_HWShipToAddrIdFromMasterOrdToNewHWOrderId;
    private Map<Id, Order_Line_Item__c> map_QtChrgeDtlIdToOrdLnItm;
    private Map<Id, ServiceContract> map_HWOrderIdToServContract;
    private List<Order_Line_Item__c> list_AllOrderLineItems; 
    private List<Order_Line_Item__c> list_HWOrderLineItems; 
    private List<zqu__QuoteRatePlanCharge__c> list_QuoteRatePlanCharges;
    private List<zqu__QuoteChargeDetail__c> list_HWQuoteLineItems;
    private List<Account_Order_Address__c> list_AllAccountOrderAddresses;
    private List<Account_Order_Address__c> list_HWShipToOrderAddresses;
    private List<Account_Order_Address__c> list_NonShipToOrderAddresses;
    private List<Account_Order_Address__c> list_NewHWOrderAddresses;
    private List<Order_Line_Item_Allocation__c> list_AllOLIAllocations;
    private List<Order__c> list_NewHWOrders;
    private Set<Id> set_NewOrderIds;
    private Order__c objNewOrder;
    private String strQuoteId;
    
    //ZQuoteDomain class for adding Dependent Parts
    private ZQuoteDomain quoteDomain;
    //ZuoraOrderUtil class for sending the Quote to Zuora
    private ZuoraOrderUtil orderUtil;    
    
    // *** Constructor to initialize variables and to pull quote info from url *** 
    public CreatePureCloudOrderController() {
        initializeVariables();
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        if(!String.isBlank(strQuoteId)) {
            objQuote = [SELECT Id, Name, zqu__Opportunity__c, zqu__Account__c, zqu__ApprovalStatus__c, Order_PO_Received_Date__c,
                               Order_PO_Number__c, Order_PO_Date__c, Order_Special_Instructions__c, zqu__PaymentTerm__c,
                               PureCloud_Annual_Minimum__c, zqu__Previewed_MRR__c, zqu__Previewed_TCV__c, Order__c,                            
                               zqu__Opportunity__r.Gene_Care_Specialist__r.Email, zqu__Opportunity__r.Quote_Mtce_Ops__r.Email,
                               zqu__Opportunity__r.BusinessPartner__c, zqu__Opportunity__r.Country_Region__c, 
                               Customer_PO_Not_Required__c, zqu__ZuoraAccountID__c, zqu__Status__c, CurrencyIsoCode, zqu__Currency__c,
                               zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c, zqu__Account__r.Country__r.Name,
                               zqu__Opportunity__r.Region__c, zqu__Opportunity__r.Quote_SG2_Region__c, zqu__Opportunity__r.Name,
                               zqu__Opportunity__r.OwnerId, zqu__Opportunity__r.StageName,
                               zqu__SoldToContact__c,zqu__SoldToContact__r.Country__r.name, zqu__SoldToContact__r.Country__c, zqu__SoldToContact__r.StateProvince__c, zqu__SoldToContact__r.City__c 
                        FROM zqu__Quote__c 
                        WHERE Id =: (Id)strQuoteId LIMIT 1];
            list_NewParentOrders = getNewOrders();                        
            findNoOfOrders();

            // Get ZQuoteDomain instance
            this.quoteDomain =  ZQuoteDomain.getInstance(this.objQuote.Id);
            // Get ZuoraOrderUtil instance
            this.orderUtil = new ZuoraOrderUtil(this.objQuote);   
            
            objAttachment = new Attachment(ParentId = objQuote.Id);       
        }
    }
    
    
       
    
    // *** Method called to store order info under quote *** 
    public void saveOrderBtn() {
        try { 
            insertAttachment();
            if(checkRequiredFieldsonSoldTo()) { return; }
            update objQuote;
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }
    }
    
    // *** Method called while submitting an order ***    
    public void submitOrderBtn() {  
        Savepoint objSP = Database.setSavepoint(); 
        List<zqu__QuoteRatePlanCharge__c> list_QtRtPlnChrgsShippable = new List<zqu__QuoteRatePlanCharge__c>();
        try {         
            Boolean blnIsAttachmentUploaded = false;
            map_OrderRecTypes = getOrderRecordTypes('Order__c');
            map_OrderLnItmRecTypes = getOrderRecordTypes('Order_Line_Item__c');
            
            if(String.isNotBlank(objAttachment.Name))
            {
                upsert objAttachment;
                objAttachment = new Attachment(ParentId = objQuote.Id);
                blnIsAttachmentUploaded = true;
            }       
            
            if(checkRequiredFieldsOnPO()) { return; }
            if(checkRequiredFieldsonSoldTo()) { return; }
            
            //Check for existing order for an opportunity
            if([SELECT count() 
                FROM Order__c 
                WHERE RecordType.Name = 'Cloud Billing Master Order'
                  AND Opportunity__c = :objQuote.zqu__Opportunity__c
                  AND (Status__c = 'Order Submitted' OR Status__c = 'Approved')] > 0) {
                objQuote.addError('An Order has already been submitted for this Opportunity. Please verify.');                
            }
            
            // Checking for Export Screening Check-list (Country is not US and Checklist is not checked)
            List<Export_Screening_Checklist__c > list_ExpScrChkLsts = [SELECT Id, Checklist_expiration_date__c 
                                                                       FROM Export_Screening_Checklist__c 
                                                                       WHERE Account__c =: objQuote.zqu__Account__c];
            if(list_ExpScrChkLsts.size() > 0) {
                if(list_ExpScrChkLsts[0].Checklist_Expiration_Date__c < Date.today()) {
                    objQuote.addError('Export screening has expired / not completed. Please contact Account Executive/Channel Manager.');
                    objQuote.addError('Please extend the expiration date of Export Screening Checklist for the End User Account.');
                    expScrnChkLstId = list_ExpScrChkLsts[0].Id;
                    blnShowExportScreeningExpireMsg = true;
                    return;
                }
            }    
            if(objQuote.zqu__Account__c != null 
               && objQuote.zqu__Account__r.Country__r.Name != 'United States' 
               && ![SELECT Screening_Checklist_Completed__c 
                    FROM Account 
                    WHERE Id =: objQuote.zqu__Account__c].Screening_Checklist_Completed__c) {
                objQuote.addError('Export screening has expired / not completed. Please contact Account Executive/Channel Manager.');
                objQuote.addError('Please complete Export Screening Checklist for the End User Account.');
                blnShowExportScreeningMsg = true;
                return;   
            }            
            
            //Check for opportunity stage
            if(!Test.isRunningTest() && 
               [SELECT StageName
                FROM Opportunity
                WHERE Id = :objQuote.zqu__Opportunity__c].StageName != Label.Oppty_Stage_Order_Submission) {
                objQuote.addError('Please change opportunity stage to ' + Label.Oppty_Stage_Order_Submission + ' before submitting an order.');                
                return; 
            }
            
            //Check to ensure there are no unallocated shippable products
            list_QtRtPlnChrgsShippable = [SELECT Id, zqu__Quantity__c
                                          FROM zqu__QuoteRatePlanCharge__c
                                          WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =: objQuote.Id
                                            AND zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.ProductShippable__c = 'Yes'];
            if(list_QtRtPlnChrgsShippable.size() > 0) {
                Map<Id, Decimal> map_OLIAProdQuantities = new Map<Id, Decimal>();
                for(Order_Line_Item_Allocation__c objOLIA : [SELECT Id, Order_Shipping_Location__c, Quantity__c, Quote_Rate_Plan_Charge__c
                                                             FROM Order_Line_Item_Allocation__c 
                                                             WHERE Zuora_Quote__c =: objQuote.Id]) {
                    if(map_OLIAProdQuantities.containsKey(objOLIA.Quote_Rate_Plan_Charge__c)) {
                        map_OLIAProdQuantities.put(objOLIA.Quote_Rate_Plan_Charge__c, map_OLIAProdQuantities.get(objOLIA.Quote_Rate_Plan_Charge__c) + objOLIA.Quantity__c);
                    }
                    else {
                        map_OLIAProdQuantities.put(objOLIA.Quote_Rate_Plan_Charge__c, objOLIA.Quantity__c);
                    }    
                }
                for(zqu__QuoteRatePlanCharge__c objQtRtPlChrg : list_QtRtPlnChrgsShippable) {
                    if(!map_OLIAProdQuantities.containsKey(objQtRtPlChrg.Id) 
                       || map_OLIAProdQuantities.get(objQtRtPlChrg.Id) != objQtRtPlChrg.zqu__Quantity__c) {
                        objQuote.addError(Label.PC_Unallocated_Quantity_Error_Message);
                        return;
                    }
                }
            }             
            
            if(!objQuote.Customer_PO_Not_Required__c && !blnIsAttachmentUploaded && ([SELECT count() FROM Attachment WHERE ParentId =: objQuote.Id] == 0)) {
                objQuote.addError('There are no attachments on this quote. Please attach PO before submitting order.');
                return;
            }
            update objQuote;
            
            //Initialize all variables
            initializeVariables();
            //Check if there is any address validation errors
            if(!addressValidationErrors()) { 
                                
                //Create new Master Order
                objNewOrder = mapOrderFields();        
                insert objNewOrder;
                set_NewOrderIds.add(objNewOrder.Id);
                System.debug('$$$$$set_NewOrderIds: '+set_NewOrderIds);
                // Add Dependent Parts
                this.quoteDomain.AutoAddDependentCharges();

                //Build differnet maps to pull quantity and prices
                if(Test.isRunningTest()){
                    list_QuoteRatePlanCharges = TestDataFactoryForQuoteTool.setupQuoteRatePlanCharges(objQuote, false); 
                }else{
                    buildQuoteChargeDetailMaps();
                }
                //Create OLI for Master Order
                mapOrderLineItemFields(objNewOrder.Id);
                System.debug('$$$$$AllOLI'+list_AllOrderLineItems.size());
                insert list_AllOrderLineItems;
                //Pull account order address and differentiate between ship to and other addresses
                prepareShipToAndOtherAddresses(objNewOrder.Id);
                //if HW order needs to be created
                if(list_HWShipToOrderAddresses.size() > 0) {
                    //Create HW orders
                    buildHWOrders(objNewOrder);
                    System.debug('$$$$$NewHWOrders'+list_NewHWOrders.size());
                    insert list_NewHWOrders;                    
                    for(Order__c objHWOrder : list_NewHWOrders) {                    
                        set_NewOrderIds.add(objHWOrder.Id);
                    }                    
                    System.debug('$$$$$set_NewOrderIds: '+set_NewOrderIds);                    
                    //Create HW account order addresses for new HW Order: one ship to, sold to, end user and bill to addresses
                    createHWOrderAccountAddresses();
                    System.debug('$$$$$AllOLI'+list_NewHWOrderAddresses.size());
                    insert list_NewHWOrderAddresses;
                    //Create HW order line items
                    buildHWOrderLineItems();  
                    System.debug('$$$$$HWOrderLineItems'+list_HWOrderLineItems.size());
                    insert list_HWOrderLineItems;                      
                      
                    //Create service contracts and line items
                    //createServiceContractsForHWOrds(list_NewHWOrders);
                }
                
                //Share orders with created by user and opportunity owner
                shareOrders(set_NewOrderIds);    
                
                //Update Opportunity forecast status - Anju - Oct 11 - Starts
                Opportunity QuoteOpportunity = new Opportunity(Id = objQuote.zqu__Opportunity__c, ForecastStatus__c = Label.Oppty_Forecast_Status_Order_Submission); 
                Util.Bypass_Trigger_Chk = true;
                update QuoteOpportunity;
                //Update Opportunity forecast status - Anju - Oct 11 - Ends           
               
                //Update Quote status
                objQuote.zqu__ApprovalStatus__c = 'Order Submitted';
                objQuote.Order__c = objNewOrder.Id;
                update objQuote;
                
                //Pull new Master Order record
                list_NewParentOrders = getNewOrders();     
                findNoOfOrders();         
            }
            else {
                return;
            }
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(objSP);
        } 
    }
    
    private void shareOrders(Set<Id> set_NewOrderIds) {
        List<Order__Share> list_InsertOrderShares = new List<Order__Share>();
        for(Id orderId : set_NewOrderIds) {
            list_InsertOrderShares.add(new Order__Share(ParentId = orderId, AccessLevel = Label.Access_Permission,
                                                        UserOrGroupId = objQuote.zqu__Opportunity__r.OwnerId,
                                                        RowCause = Schema.Order__Share.RowCause.Rep_Access__c));
            if(objQuote.zqu__Opportunity__r.OwnerId != UserInfo.getUserId()) {
                list_InsertOrderShares.add(new Order__Share(ParentId = orderId, AccessLevel = Label.Access_Permission,
                                                            UserOrGroupId = UserInfo.getUserId(),
                                                            RowCause = Schema.Order__Share.RowCause.Rep_Access__c));
            }
        }        
        insert list_InsertOrderShares;
    }
    
    // *** Method to create service contracts for HW orders ***
   /* private void createServiceContractsForHWOrds(List<Order__c> list_NewHWOrders) {
        Map<Id, Id> map_ProductIdToPBEId = new Map<Id, Id>();
        Map<Id, ServiceContract> map_ServiceContracts = new Map<Id, ServiceContract>(); 
        Map<Id, ServiceContract> map_InsertedServiceContracts = new Map<Id, ServiceContract>(); 
        Map<Id, List<Order_Line_Item__c>> map_HWOrderIdToOLIs = new  Map<Id, List<Order_Line_Item__c>>();   
        List<ServiceContract> list_UpdateServiceContracts = new List<ServiceContract>(); 
        List<ContractLineItem> list_InsertContractLineItems = new List<ContractLineItem>();   
        List<Order_Line_Item__c> list_OrderLineItems = new List<Order_Line_Item__c>();    
        List<Order_Line_Item__c> list_UpdateOrderLineItems = new List<Order_Line_Item__c>();                 
        Set<Id> set_ProductIds = new Set<Id>();
        for(Order__c objHWOrder : list_NewHWOrders) {
            ServiceContract objServCntrct = new ServiceContract();
            objServCntrct.Name = objQuote.zqu__Opportunity__r.Name + ' Maintenance Contract';
            objServCntrct.Order__c = objHWOrder.Id;
            objServCntrct.Opportunity__c = objQuote.zqu__Opportunity__c;    
            objServCntrct.Big_Four__c = objQuote.zqu__Opportunity__r.Region__c;
            objServCntrct.SG2_Region__c = objQuote.zqu__Opportunity__r.Quote_SG2_Region__c;
            objServCntrct.pricebook2Id = Label.Standard_Pricebook_Id;   
            map_ServiceContracts.put(objHWOrder.Id, objServCntrct);
        }
        if(!map_ServiceContracts.isEmpty()) {
            insert map_ServiceContracts.values();
            for(ServiceContract objServCntrct : [SELECT Id, Name, Order__c, pricebook2Id, Agreement_Number__c, Agreement_Status__c, 
                                                        Previous_Maint_Rate__c, Current_Maint_Rate__c
                                                 FROM ServiceContract WHERE Order__c =: map_ServiceContracts.keySet()]) {
                map_InsertedServiceContracts.put(objServCntrct.Order__c, objServCntrct);
                objServCntrct.Name = objServCntrct.Agreement_Number__c;
                list_UpdateServiceContracts.add(objServCntrct);
            }
            list_OrderLineItems = [SELECT Id, Order__c, Sales_Price__c, Order__r.Sold_To_Name__c, Order__r.Invoice_Number__c,
                                          Order__r.Original_License_Invoice_Date__c, Order__r.PO_Number__c, Product__c,
                                          Order__r.Revised_Net_License_Value__c, Order__r.Maintenance_Level__c,
                                          Annualized_Maintenance_Due__c, Service_Contract_Line_ID__c, BigMachines_Quantity__c                                                      
                                   FROM Order_Line_Item__c 
                                   WHERE Order__c IN : map_InsertedServiceContracts.keySet()];
                                   
            for(Order_Line_Item__c objHWOLI : list_OrderLineItems ) {
                set_ProductIds.add(objHWOLI.Product__c);
            }
            if(!set_ProductIds.isEmpty()) {
                for(PricebookEntry objPBE : [SELECT Product2Id, Id 
                                             FROM PricebookEntry 
                                             WHERE Pricebook2.IsStandard = true 
                                               AND Pricebook2.IsActive=true
                                               AND CurrencyIsoCode = :objQuote.zqu__Currency__c 
                                               AND Product2Id IN :set_ProductIds]) {
                    map_ProductIdToPBEId.put(objPBE.Product2Id, objPBE.Id);
                }
            }
            for(Order_Line_Item__c objHWOLI : list_OrderLineItems ) {
                ContractLineItem objNewCLI = new ContractLineItem();
                ServiceContract objCurrServCtrct = map_InsertedServiceContracts.get(objHWOLI.Order__c);
                objNewCLI.Order_Line_Item__c = objHWOLI.Id;
                objNewCLI.ServiceContractId = objCurrServCtrct.Id;      
                objNewCLI.PricebookEntryId = map_ProductIdToPBEId.get(objHWOLI.Product__c); 
                objNewCLI.Agreement_Status__c = objCurrServCtrct.Agreement_Status__c;
                objNewCLI.Previous_Maintenance_Rate__c = objCurrServCtrct.Previous_Maint_Rate__c;
                objNewCLI.Current_Maintenance_Rate__c = objCurrServCtrct.Current_Maint_Rate__c;
                objNewCLI.Quantity = objHWOLI.BigMachines_Quantity__c;      
                objNewCLI.UnitPrice = objHWOLI.Sales_Price__c;
                objNewCLI.Sold_To_Name_Lookup__c = objHWOLI.Order__r.Sold_To_Name__c;
                objNewCLI.Original_License_Invoice__c = objHWOLI.Order__r.Invoice_Number__c;
                objNewCLI.Lic_Invoice__c = objHWOLI.Order__r.Invoice_Number__c;
                objNewCLI.Original_License_Invoice_Date__c = objHWOLI.Order__r.Original_License_Invoice_Date__c;
                objNewCLI.Original_PO__c = objHWOLI.Order__r.PO_Number__c;      
                objNewCLI.Previous_Line_Maintenance_Value__c = objHWOLI.Annualized_Maintenance_Due__c;
                objNewCLI.Annualized_Maintenance_Due__c = objHWOLI.Annualized_Maintenance_Due__c;   
                objNewCLI.Revised_Net_License_value__c = objHWOLI.Order__r.Revised_Net_License_Value__c;
                objNewCLI.Maintenance_Level__c = objHWOLI.Order__r.Maintenance_Level__c;       
                objNewCLI.Contract_Line_Item__c = objHWOLI.Service_Contract_Line_ID__c;     
                list_InsertContractLineItems.add(objNewCLI);
            }
            
            if(!list_InsertContractLineItems.isEmpty())
                insert list_InsertContractLineItems;
                
            if(!list_UpdateServiceContracts.isEmpty())
                update list_UpdateServiceContracts;
                
            for(ContractLineItem objCLI : list_InsertContractLineItems){
                list_UpdateOrderLineItems.add(new Order_Line_Item__c(Id=objCLI.Order_Line_Item__c, Contract_Line_Item__c = objCLI.Id));
            }
            update list_UpdateOrderLineItems;   
        }
    }*/
    
    // *** Method to redirect to Quote record from vf page ***
    public PageReference cancelOrderBtn() {
        return new PageReference('/'+objQuote.Id);
    }
    
    // *** Method to pull account order addresses and differentiate between ship to and other addresses ***
    @testVisible
    private void prepareShipToAndOtherAddresses(Id orderId) {
        list_AllAccountOrderAddresses = [SELECT Id, Address__c, Address2__c, Attention_To__c, Shipping_Method_Name__c, Address_Type__c,
                                                City__c, Company__c, Country__c, Email__c, Account__c, Fax__c, Need_By_Date__c, 
                                                Order__c, Phone__c, Shipping_Instructions__c, Sold_To_Business_Partner__c, 
                                                Sort_Order__c, State__c, Zip_Code__c, Zuora_Quote__c
                                         FROM Account_Order_Address__c
                                         WHERE Zuora_Quote__c = :objQuote.Id];
        System.debug('$$$$$AllAccountOrderAddresses'+list_AllAccountOrderAddresses.size());
        for(Account_Order_Address__c obj_AOA : list_AllAccountOrderAddresses) {                
            //Below list size will be the no of HW orders to be created
            if(obj_AOA.Address_Type__c == 'Ship To' && !String.isBlank(obj_AOA.Shipping_Method_Name__c)) {
                list_HWShipToOrderAddresses.add(obj_AOA);
            }
            //Each of these addresses will be associated to each new HW order
            else if(obj_AOA.Address_Type__c == 'Bill To' || obj_AOA.Address_Type__c == 'Sold To' || obj_AOA.Address_Type__c == 'End User') {
                list_NonShipToOrderAddresses.add(obj_AOA);
            }
            obj_AOA.Order__c = orderId;
        }
        System.debug('$$$$$list_HWShipToOrderAddresses'+list_HWShipToOrderAddresses.size());
        System.debug('$$$$$list_NonShipToOrderAddresses'+list_NonShipToOrderAddresses.size());
        update list_AllAccountOrderAddresses; 
    }
    
    // *** Method to build HW Orders ***
    @testVisible
    private void buildHWOrders(Order__c objNewOrder) {
        System.debug('$$$$$list_HWShipToOrderAddresses'+list_HWShipToOrderAddresses.size());        
        Id idHWOwner = [SELECT Id FROM Group WHERE DeveloperName = 'Cloud_Billing_Master_Orders_Queue' AND Type = 'Queue' LIMIT 1].Id;
        //Build as many HW orders as ship to (with Shipping method field populated) address count
        for(Integer i=0; i<list_HWShipToOrderAddresses.size(); i++) {
            Order__c obj_NewHWOrder = objNewOrder.clone(false, false, false, false);
            obj_NewHWOrder.Name = objNewOrder.Name + '-HW-' + (i+1) ;
            obj_NewHWOrder.RecordTypeId = map_OrderRecTypes.get('Hardware Order').Id;
            obj_NewHWOrder.OwnerId = idHWOwner;
            obj_NewHWOrder.Order_Type__c = 'Revenue';
            obj_NewHWOrder.License_FYM_detail__c = 'Hardware Order';
            obj_NewHWOrder.Original_Parent_Order1__c = objNewOrder.Id;
            list_NewHWOrders.add(obj_NewHWOrder);
        }
    }
    
    // *** Method to build HW Account Address ***
    @testVisible
    private void createHWOrderAccountAddresses() {
        for(Integer i=0; i<list_HWShipToOrderAddresses.size(); i++) {
            //Associate one ship to address to HW Order
            Account_Order_Address__c obj_NewShipToAddr = list_HWShipToOrderAddresses[i].clone(false, false, false, false);
            obj_NewShipToAddr.Order__c = list_NewHWOrders[i].Id;
            obj_NewShipToAddr.Zuora_Quote__c = null;
            list_NewHWOrderAddresses.add(obj_NewShipToAddr);
            
            //Lookup in oli allocation is master order's account order address id. Need to map that id with newly created HW order
            map_HWShipToAddrIdFromMasterOrdToNewHWOrderId.put(list_HWShipToOrderAddresses[i].Id, list_NewHWOrders[i].Id);
            //Associate Sold To, End User and Bill To addresses to each new HW Order
            for(Account_Order_Address__c obj_NonShipToAddr : list_NonShipToOrderAddresses) {
                Account_Order_Address__c obj_NewNonShipToAddr = obj_NonShipToAddr.clone(false, false, false, false);
                obj_NewNonShipToAddr.Order__c = list_NewHWOrders[i].Id;
                obj_NewNonShipToAddr.Zuora_Quote__c = null;
                list_NewHWOrderAddresses.add(obj_NewNonShipToAddr);
            }
        }
    }
    
    // *** Method to build HWOrder Line Items ***
    @testVisible
    private void buildHWOrderLineItems() {
        //Pull OLI allocation records
        list_AllOLIAllocations = [SELECT Id, Order_Shipping_Location__c, Quantity__c, Zuora_Quote__c, Quote_Rate_Plan_Charge__c
                                  FROM Order_Line_Item_Allocation__c 
                                  WHERE Zuora_Quote__c =: objQuote.Id];
        System.debug('$$$$$AllOLIAllocations'+list_AllOLIAllocations.size());
        for(Order_Line_Item_Allocation__c obj_OLIAlloc : list_AllOLIAllocations) {                
            //Consider records which has a quantity
            if(obj_OLIAlloc.Quantity__c > 0) {
                //Retrieve master order line item based on quote charge detail
                Order_Line_Item__c objNewOLI = map_QtChrgeDtlIdToOrdLnItm.get(obj_OLIAlloc.Quote_Rate_Plan_Charge__c).clone(false, false, false, false);
                //Associate HW order based on OLI Allocation's shipping location and HW Order's ship to address. 
                //Below map points to Master Order's ship to address and new HW Order id
                objNewOLI.Order__c = map_HWShipToAddrIdFromMasterOrdToNewHWOrderId.get(obj_OLIAlloc.Order_Shipping_Location__c);
                objNewOLI.Quantity__c = Integer.valueOf(obj_OLIAlloc.Quantity__c);
                objNewOLI.BigMachines_Quantity__c = objNewOLI.Quantity__c;
                objNewOLI.Ext_List__c = objNewOLI.List_Price__c;
                objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c;
                if(objNewOLI.Quantity__c != null || objNewOLI.Quantity__c > 0) {
                    objNewOLI.Ext_List__c = objNewOLI.List_Price__c * objNewOLI.Quantity__c;
                    objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c * objNewOLI.Quantity__c;
                    objNewOLI.Tax_Amount__c = objNewOLI.Tax_Amount__c /objNewOLI.Quantity__c;
                }
                //objNewOLI.Total_Discount__c = objQtChrgeDtl.zqu__BillingDiscount__c;                 
                objNewOLI.Sales_Price__c = objNewOLI.Net_Unit_Price__c;
                list_HWOrderLineItems.add(objNewOLI);
            } 
        } 
    }
    
    // *** Method to pull quantity, prices for each quote line item ***
    private void buildQuoteChargeDetailMaps() { 
        list_QuoteRatePlanCharges = [SELECT Id, zqu__Discount__c, zqu__ListPrice__c, zqu__ProductRatePlanCharge__c,
                                            zqu__EffectivePrice__c, zqu__Quantity__c, zqu__UOM__c, Partner_Price__c,
                                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, zqu__BillingTax__c,
                                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c,
                                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name,
                                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c,
                                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Description__c
                                     FROM zqu__QuoteRatePlanCharge__c 
                                     WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =: objQuote.Id];        
    }
    
    // *** Method to build order ***
    private Order__c mapOrderFields() {
        Order__c objNewOrder = new Order__c();
        objNewOrder.Name = 'Order ' + objQuote.Name;
        objNewOrder.Status__c = 'Order Submitted';
        objNewOrder.OwnerId = getOrderManagementQueue();
        objNewOrder.RecordTypeId = map_OrderRecTypes.get('Cloud Billing Master Order').Id;
        objNewOrder.Date_Submitted__c = System.Now();
        objNewOrder.Zuora_Quote__c = objQuote.Id;
        objNewOrder.Annual_Contract_Value__c = objQuote.PureCloud_Annual_Minimum__c;
        objNewOrder.CMRR__c = objQuote.zqu__Previewed_MRR__c;
        objNewOrder.TCV__c = objQuote.zqu__Previewed_TCV__c; //zqu__Previewed_Total__c
        objNewOrder.PO_Received_Date__c = objQuote.Order_PO_Received_Date__c;
        objNewOrder.End_User_Name__c = objQuote.zqu__Account__c;
        objNewOrder.Sold_To_Name__c = objQuote.zqu__Account__c;
        if(objQuote.zqu__Opportunity__r.BusinessPartner__c != null) {
            objNewOrder.Sold_To_Name__c = objQuote.zqu__Opportunity__r.BusinessPartner__c;
        }
        objNewOrder.Bill_To_Name__c = objQuote.zqu__Account__c;
        objNewOrder.Order_Type__c = 'Non-Revenue';
        objNewOrder.Opportunity__c = objQuote.zqu__Opportunity__c; 
        objNewOrder.Genesys_Care_Specialist_Email__c = objQuote.zqu__Opportunity__r.Gene_Care_Specialist__r.Email;
        objNewOrder.Genesys_Care_Ops_Email__c = objQuote.zqu__Opportunity__r.Quote_Mtce_Ops__r.Email;
        objNewOrder.PO_Number__c = objQuote.Order_PO_Number__c;
        objNewOrder.PO_Date__c = objQuote.Order_PO_Date__c;
        objNewOrder.Payment_Terms__c = objQuote.zqu__PaymentTerm__c;
        objNewOrder.CurrencyIsoCode = objQuote.zqu__Currency__c;
        return objNewOrder;
    }
    
    // *** Method to build and assign order line items ***
    @testVisible
    private void mapOrderLineItemFields(Id idOrder) {
        Integer intOLICount = 1;
        //for(zqu__QuoteChargeDetail__c objQtChrgeDtl : list_AllQuoteLineItems) { 
        for (zqu__QuoteRatePlanCharge__c objQtRtPlChrg : list_QuoteRatePlanCharges) {           
            Order_Line_Item__c objNewOLI = new Order_Line_Item__c();
            objNewOLI.Order__c = idOrder;
            objNewOLI.Quote_Rate_Plan_Charge__c = objQtRtPlChrg.Id;
            objNewOLI.Line_Number__c = intOLICount;
            objNewOLI.CurrencyIsoCode=  objQuote.zqu__Currency__c;
            objNewOLI.Product__c = objQtRtPlChrg.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c;
            objNewOLI.Product_txt__c = objQtRtPlChrg.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name;
            objNewOLI.APN_Number__c = objQtRtPlChrg.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c;
            objNewOLI.Name = objQtRtPlChrg.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name;
            objNewOLI.Description__c = objQtRtPlChrg.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Description__c;
            objNewOLI.RecordTypeId = map_OrderLnItmRecTypes.get('Default').Id;            
            objNewOLI.Unit_of_Measure__c = objQtRtPlChrg.zqu__UOM__c != null ? objQtRtPlChrg.zqu__UOM__c : '';
            objNewOLI.Quantity__c = objQtRtPlChrg.zqu__Quantity__c != null ? Integer.valueOf(objQtRtPlChrg.zqu__Quantity__c) : 0;
            objNewOLI.BigMachines_Quantity__c = objNewOLI.Quantity__c;
            objNewOLI.List_Price__c = objQtRtPlChrg.zqu__ListPrice__c != null ? objQtRtPlChrg.zqu__ListPrice__c : 0;                       
            objNewOLI.Net_Unit_Price__c = objQtRtPlChrg.zqu__EffectivePrice__c != null ? objQtRtPlChrg.zqu__EffectivePrice__c : 0;
            if(objQuote.zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) {
                objNewOLI.Net_Unit_Price__c = objQtRtPlChrg.Partner_Price__c != null ? objQtRtPlChrg.Partner_Price__c : objNewOLI.Net_Unit_Price__c;
            }            
            objNewOLI.Ext_List__c = objNewOLI.List_Price__c;
            objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c;
            if(objNewOLI.Quantity__c != null || objNewOLI.Quantity__c > 0) {
                objNewOLI.Ext_List__c = objNewOLI.List_Price__c * objNewOLI.Quantity__c;
                objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c * objNewOLI.Quantity__c;
            }            
            objNewOLI.Total_Discount__c = objQtRtPlChrg.zqu__Discount__c;
            objNewOLI.Tax_Amount__c = objQtRtPlChrg.zqu__BillingTax__c != null ? objQtRtPlChrg.zqu__BillingTax__c : 0;
            objNewOLI.Sales_Price__c = objNewOLI.Net_Unit_Price__c;              
            list_AllOrderLineItems.add(objNewOLI);
            map_QtChrgeDtlIdToOrdLnItm.put(objQtRtPlChrg.Id, objNewOLI);
            intOLICount++;
        }
    }
    
    // *** Method to pull record types of a sobject ***
    @testVisible
    private Map<String, RecordType> getOrderRecordTypes(String strObjType) {
        Map<String, RecordType> map_rts = new Map<String, RecordType>();
        for(RecordType recType : [SELECT Id, Name FROM RecordType WHERE SobjectType =: strObjType]) {
            map_rts.put(recType.Name, recType);
        }
        return map_rts;
    }   
        
    // *** Method to initialize variables before submitting an order ***
    private void initializeVariables() {
        strQuoteId = '';
        expScrnChkLstId = null;
        intNoOfOrders = 0;
        objNewOrder = new Order__c();
        blnShowExportScreeningMsg = false;
        blnShowExportScreeningExpireMsg = false;
        list_NewParentOrders = new List<Order__c>();
        list_AllOrderLineItems = new List<Order_Line_Item__c>();
        list_HWOrderLineItems = new List<Order_Line_Item__c>();
        list_QuoteRatePlanCharges = new List<zqu__QuoteRatePlanCharge__c>();
        list_HWQuoteLineItems = new List<zqu__QuoteChargeDetail__c>();
        list_NewHWOrders = new List<Order__c>();
        list_AllAccountOrderAddresses = new List<Account_Order_Address__c>();
        list_HWShipToOrderAddresses = new List<Account_Order_Address__c>();
        list_NonShipToOrderAddresses = new List<Account_Order_Address__c>();
        list_NewHWOrderAddresses = new List<Account_Order_Address__c>();  
        list_AllOLIAllocations = new List<Order_Line_Item_Allocation__c>();
        map_HWShipToAddrIdFromMasterOrdToNewHWOrderId = new Map<Id, Id>();
        map_QtChrgeDtlIdToOrdLnItm = new Map<Id, Order_Line_Item__c>();
        map_HWOrderIdToServContract = new Map<Id, ServiceContract>();
        set_NewOrderIds = new Set<Id>();
    } 
    
    // *** Method to display order information based on quote's status ***
    public Boolean getIsOrderInfoAvailable() {
        if(objQuote.zqu__ApprovalStatus__c == 'Approved' || objQuote.zqu__ApprovalStatus__c == 'Quote Approved' ||        
           objQuote.zqu__ApprovalStatus__c == 'Order Submitted' || objQuote.zqu__ApprovalStatus__c == 'Rejected') //|| objQuote.BigMachines__Status__c == 'Order Accepted' || )
            return true;
        return false;
    }
    
    //**** Method to insert attachment and associate to quote  ****
    public void insertAttachment() {
        if(objAttachment != null && String.isNotBlank(objAttachment.Name)) {
            try {
                insert objAttachment;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Attachment Uploaded.'));
                objAttachment = new Attachment(ParentId = objQuote.Id);
            }
            catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }    
    }
    
    // *** Method to assign HW order's owner based on region ***
    private String getOrderManagementQueue() {        
        Global_Setting__c obj = Global_Setting__c.getInstance('Order Queue');
        String region = objQuote.zqu__Opportunity__r.Country_Region__c;        
        if(region == 'North America') {            
            obj = Global_Setting__c.getInstance('NA Order Queue');
        }
        else if(region == 'EMEA'){
            obj = Global_Setting__c.getInstance('EMEA Order Queue');
        }
        else if(region == 'LATAM'){
            obj = Global_Setting__c.getInstance('LATAM Order Queue');
        }
        else if(region == 'APAC'){
            obj = Global_Setting__c.getInstance('APAC Order Queue');
        }
        else if(region == 'Japan' || region=='JAPAN'){
            obj = Global_Setting__c.getInstance('Japan Order Queue');
        }        
        return obj.ID__c;       
    }
    // *** Method to find no of orders ***
    private void findNoOfOrders() {
        intNoOfOrders = [SELECT COUNT() 
                         FROM zqu__Quote__c 
                         WHERE zqu__Opportunity__c=:objQuote.zqu__Opportunity__c
                           AND zqu__ApprovalStatus__c='Order Submitted'];
    }
    // *** Method to pull newly created master order ***
    private List<Order__c> getNewOrders() {
        return [SELECT Id, Name FROM Order__c WHERE Zuora_Quote__c =: objQuote.Id AND Original_Parent_Order1__c = null];
    }
    
    // *** Method to validate addresses under Account Order Address object ***
    private Boolean addressValidationErrors() {
        Boolean blnHasAddrValErrors = false;
        //Checks if the master record has Sold To, Ship To, End User and Bill To addresses
        String addressValidation = OrderAddressPureCloudController.validateOrderSubmission(objQuote.Id);
        if(addressValidation != 'OK'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, addressValidation));
            blnHasAddrValErrors = true;
        }
        //Checks if email is populated for Ship To addresses
        if([SELECT count() 
            FROM Account_Order_Address__c 
            WHERE Zuora_Quote__c =: objQuote.Id
              AND Address_Type__c = 'Ship To' 
              //AND Shipping_Method_Name__c != ''
              AND Email__c = null] > 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter email for Ship To address(es).'));
            blnHasAddrValErrors = true;
        }
        return blnHasAddrValErrors;
    }
    
    // *** Method to check whether required fields are filled or not ***
    private Boolean checkRequiredFieldsOnPO() {
        
        Boolean blnHasRequiredError = false;
        if(!objQuote.Customer_PO_Not_Required__c && String.isBlank(objQuote.Order_PO_Number__c)) {
            objQuote.Order_PO_Number__c.addError('Required To Submit Order');
            blnHasRequiredError = true;
        }
        if(!objQuote.Customer_PO_Not_Required__c && objQuote.Order_PO_Date__c == null) {
            objQuote.Order_PO_Date__c.addError('Required To Submit Order');
            blnHasRequiredError = true;
        }
        if(String.isBlank(objQuote.zqu__PaymentTerm__c)) {
            objQuote.zqu__PaymentTerm__c.addError('Required To Submit Order');
            blnHasRequiredError = true;
        }  
        return blnHasRequiredError;
    }
    
    //Check Sold to contact validations Sep 14 Anju Starts
    private Boolean checkRequiredFieldsonSoldTo() {
        Boolean blnHasSoldtoError = false;
        //Sep 7 - Anju - Sold To contact Country and state are required - Validation starts
        //Query again sold to contact to see values
        
        Contact objSoldToContact = new Contact();
        if(objQuote.zqu__SoldToContact__c != null){
            objSoldToContact = [Select id, Country__c, City__c, StateProvince__c, Country__r.name, Mailingcountry, Mailingstate
                                From Contact 
                                Where id = :objQuote.zqu__SoldToContact__c];
            if(String.isBlank(objSoldToContact.MailingCountry)) {
                objQuote.zqu__SoldToContact__c.addError('Country is required.');
                blnHasSoldtoError = true;
            }
            if(objSoldToContact.MailingCountry == 'United States' && String.isBlank(objSoldToContact.StateProvince__c)) {
                objQuote.zqu__SoldToContact__c.addError('State is required.');
                blnHasSoldtoError  = true;
            }
        }
         
        //Sep 7 - Anju - Sold To contact Country and state are required - Validation ends
        return blnHasSoldtoError ;
    }
}