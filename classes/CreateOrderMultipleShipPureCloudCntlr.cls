public with sharing class CreateOrderMultipleShipPureCloudCntlr {
    
    //Initialize variables
    public String strSelectedTab { get; private set; }
    public zqu__Quote__c quote { get; set; }               
    public String strSubSelectedTab { get; private set; }
    public Boolean orderIsAllNonShippableParts { get; set; }  // If the order has all non-shippable parts, then shipping locations are not required.
    public Boolean displayLocationPopup { get; set; }
    public String selectedShippingAddressId { get; set; }
    public OrderingUIClasses.mAddress SelectedShippingAddress { get; set; }
    public Integer selectedLocationNumber { get; set; }
    private List<SelectOption> shippingAddressList = new List<SelectOption>();
    public List<SelectOption> shippingMethodList = new List<SelectOption>();
    public String selectedShippingMethod { get; set; }
    public Date enteredNeedByDate { get; set; }
    public String addUpdateAddressStatus { get; set; }
    public String enteredShippingInstructions { get; set; }
    public Integer LineNumber { get; set; }
    public String defaultTab {get;set;}
    public String selectedAddressRecordId {get;set;}
    public Boolean CaaSTabVisible {get;set;}
    public List<OrderingUIClasses.LineItem> lineItems = new List<OrderingUIClasses.LineItem>();
    public List<SelectOption> getShippingAddresses() {
        return shippingAddressList;
    }
    public Boolean orderHasNonShippableParts { get; set; }    // if the order has non-shippable parts, then display the non-shippable parts section.
    public String unsubmitableMessage { get; set; }
    private Boolean OrderExists = false;
    public Boolean CanOrderBeSubmitted {get;set;}           // indicates whether or not Sales can submit the order
    public Decimal priceTotal {get; set;}
    private Decimal partsTotal;
    public Decimal supportRateTotal {get; set;}
    public Decimal grandTotal {get; set;}
    public Decimal supportDiscountTotal {get; set;}
    public boolean showAllocation  {get;set;}
    public Integer intNoOfOrders { get; set; }
    
    Map<Id, Id> map_QtChrgeDtlToPrdRtPlChrge = new Map<Id, Id>();
    Map<Id, zqu__QuoteRatePlanCharge__c> map_PrdRtPlChrgeToQtRtPlChrge = new Map<Id, zqu__QuoteRatePlanCharge__c>();
    @testVisible
    List<OrderingUIClasses.ShippingLocation> selectedLocations = new List<OrderingUIClasses.ShippingLocation>();
    String quoteId;
    
    private Map<Id, Account_Order_Address__c> map_ExistingShipToAddrs;
    private Set<Id> set_AccountIds = new Set<Id>();
    @testVisible
    Map<Decimal, id> locNumsForExisting = new Map<Decimal, id>();
    
    //*** Constructor to  pull quote information ***
    public createOrderMultipleShipPureCloudCntlr(){
        quoteId = ApexPages.currentPage().getParameters().get('id');
        quote = getQuote(quoteId);
        set_AccountIds.add(quote.zqu__Account__c);
        if(quote.zqu__Opportunity__r.BusinessPartner__c != null) {
            set_AccountIds.add(quote.zqu__Opportunity__r.BusinessPartner__c);
        }
        showMultiShipTo();
        findNoOfOrders();
    }    
    //*** Method to prepare shipping method list ***
    public List<SelectOption> getShippingMethodList() {
        return ShippingMethodList;
    }
    //*** Method to get order line items ***
    public List<OrderingUIClasses.LineItem> getLineItems() {
        return lineItems;
    }
    //*** Method to display multiple ship to addresses ***
    
    public void showMultiShipTo() {
                                                                          
        strSelectedTab = 'Multi ShipTo';
        defaultTab = 'ShippingTab';
        CaaSTabVisible = true;
        prepareAddressTab();                                                                         
    }
    //*** Method to retreive shipping locations ***                                                                                                                 
    public void retrieveShiptoLocations() {
                                                                             
        try {
            selectedLocations = new List<OrderingUIClasses.ShippingLocation>();                                                 
            for (Account_Order_Address__c aoa : [SELECT Id, Address__c, Address2__c, Address_Type__c, City__c, Country__c,
                                                        Account__c, Sold_To_Business_Partner__c, State__c, Zip_Code__c, Order__c,
                                                        Shipping_Method_Name__c, Need_By_Date__c, Sort_Order__c, Shipping_Instructions__c
                                                 FROM Account_Order_Address__c
                                                 WHERE Zuora_Quote__c = :quoteId and Sort_Order__c != null
                                                 ORDER BY Sort_Order__c]) {

                OrderingUIClasses.ShippingLocation shipLoc = new OrderingUIClasses.ShippingLocation();
                OrderingUIClasses.mAddress address = new OrderingUIClasses.mAddress();
                shipLoc.Id = aoa.Id;
                //Added By Ranjith on Jul 13, 2017 -- Starts
                shipLoc.AddressId = aoa.Id;
                locNumsForExisting.put(aoa.Sort_Order__c, aoa.id);
                system.debug('######locNumsForExisting' + locNumsForExisting);
                //Added By Ranjith on Jul 13, 2017 -- Ends  
                shipLoc.LineNumber = Integer.valueOf(String.valueOf(aoa.Sort_Order__c)) ;
                shipLoc.NeedByDate = aoa.Need_By_Date__c;
                shipLoc.ShippingInstructions = aoa.Shipping_Instructions__c;
                shipLoc.ShippingMethod = aoa.Shipping_Method_Name__c;
                
                address.Street = aoa.Address__c;
                address.Street2 = aoa.Address2__c;
                address.City = aoa.City__c;
                address.Country = aoa.Country__c;
                address.State = aoa.State__c;
                address.PostalCode = aoa.Zip_Code__c;
                shipLoc.Address = address;

                selectedLocations.add(shipLoc);                
                                                                                 
            }
        } 
        catch(Exception ex) {
            System.debug(LoggingLevel.Error,'=====> ERROR: retrieveShiptoLocations: ' + ex);
        }
    }
    //*** Method to show popup for location ***  
    public void showLocationPopup() {
        selectedLocationNumber = -1;
        displayLocationPopup = true;
        //Added by Ranjith on Jun 09, 2016 -- Starts
        prepareAddressTab();                      
        //Added By Ranjith on Jun 09, 2016 -- Ends
    }
    //*** Method to select shipping address ***  
    public PageReference shippingAddressSelect() {
                                                                             
        if (selectedShippingAddressId != 'select') {
            SelectedShippingAddress = retrieveAddress(selectedShippingAddressId);
        } else {
            SelectedShippingAddress = null;
        }
        return null;
    }
    //*** Method to retreive address ***  
    public OrderingUIClasses.mAddress retrieveAddress(String addrId) {
        OrderingUIClasses.mAddress mAddr = new OrderingUIClasses.mAddress();                                     
        List<Address__c> addrList = [SELECT Id, Name, Address_Line_1__c, Address_Line_2__c, Address_line_3__c, Country__c,
                                            City__c, County__c, Is_Primary__c, Zipcode__c, State__c, Is_Inactive__c
                                     FROM Address__c
                                     WHERE id = :addrId LIMIT 1];  
        if(addrList.size() > 0) {
            Address__c addr = addrList.get(0);
            mAddr.Name = addr.Name;                                                                                     
            mAddr.Street = addr.Address_Line_1__c != null ? addr.Address_Line_1__c : '';
            mAddr.City = addr.City__c != null ? addr.City__c : '';
            mAddr.State = addr.State__c != null ? addr.State__c : '';
            mAddr.PostalCode = addr.Zipcode__c != null ? addr.Zipcode__c : '';
            mAddr.isActive = addr.Is_Inactive__c;
            mAddr.Country = addr.Country__c != null ? addr.Country__c : '';                                                  
            maddr.Id = addr.id;                                                                
        }
        //Added By Ranjith on Jun 09, 2017 - Starts
        List<Account_Order_Address__c> list_AOAs = [SELECT Id, Name, Address__c, Address2__c,
                        City__c, Country__c, Zip_Code__c, State__c
                FROM Account_Order_Address__c
                WHERE Id = :addrId
                LIMIT 1
        ];
        if (list_AOAs.size() > 0) {
            Account_Order_Address__c addr = list_AOAs.get(0);
            mAddr.Name = addr.Name;
            mAddr.Street = addr.Address__c != null ? addr.Address__c : '';
            mAddr.City = addr.City__c != null ? addr.City__c : '';
            mAddr.State = addr.State__c != null ? addr.State__c : '';
            mAddr.PostalCode = addr.Zip_Code__c != null ? addr.Zip_Code__c : '';
            mAddr.isActive = true;
            mAddr.Country = addr.Country__c != null ? addr.Country__c : '';
            maddr.Id = addr.id;
        }
        //Added By Ranjith on Jun 09, 2017 - Ends
        return mAddr;
    }
    //*** Method to save locations ***  
    public PageReference saveLocation() {
        Boolean allowSave = true;
                                       
        if(String.isBlank(selectedShippingAddressId)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Shipping Address is required.'));
            allowSave = false;
        }
        //validate the shipping method
        if(String.isBlank(selectedShippingMethod)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Shipping Method is required.'));
            allowSave = false;
        }
        //validate the shipping location
        else {
            if((selectedShippingMethod.startsWith('Time Definite')) && (enteredNeedByDate  == null)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Need by Date is required for the selected shipping method.'));
                allowSave = false;
            }
        }
        if(allowSave == false) {
            return null;
        }                                                                 
        if((selectedLocationNumber == null) || (selectedLocationNumber == -1)) {
            createNewLocation();                                
        } 
        else {
            updateLocation();
        }
        initializeAddressArea();
                                
        displayLocationPopup = false;
        //Added By Ranjith on Jul 06, 2017 -- Starts             
        PageReference returnPage = Page.CreatePureCloudOrder;
        returnPage.getParameters().put('id', quote.Id);                                                                     
        return returnPage;   
        //Added By Ranjith on Jul 06, 2017 -- Ends
    }
    //*** Method to prepare values for address tab ***  
    private void prepareAddressTab() {                                                                            
        shippingAddressList = new List<SelectOption>();
        if(AddUpdateAddressStatus != 'update') { //Added By Ranjith on Jul 13, 2017
            for (Address__c a : [SELECT Id, Name, Type__c 
                                 FROM Address__c 
                                 WHERE Is_Inactive__c = false 
                                   //AND Account__c = :quote.zqu__Account__c 
                                   AND Account__c IN :set_AccountIds
                                 ORDER BY Name]) {
                shippingAddressList.add(new SelectOption(a.Id, a.Name));
            }
            
            //Added By Ranjith on Jul 13, 2017 -- Starts
            for (Account_Order_Address__c aoa : [SELECT Id, Name, Address__c
                                                 FROM Account_Order_Address__c 
                                                 WHERE New__c = true 
                                                   AND Zuora_Quote__c = :quoteId ORDER BY Name]) {
                shippingAddressList.add(new SelectOption(aoa.Id, aoa.Address__c));
            }
        }
        else {
            for (Account_Order_Address__c aoa : [SELECT Id, Name, Address__c
                                                 FROM Account_Order_Address__c 
                                                 WHERE Zuora_Quote__c = :quoteId 
                                                   AND Address_Type__c='Ship To' ORDER BY Name]) {
                shippingAddressList.add(new SelectOption(aoa.Id, aoa.Address__c));
            }            
        }
        shippingMethodList.clear();
        //Added By Ranjith on Jul 13, 2017 -- Ends
        
        Schema.DescribeFieldResult fieldResult = Account_Order_Address__c.Shipping_Method_Name__c.getDescribe();
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            shippingMethodList.add(new SelectOption(f.getValue(), f.getValue()));
        }
        SelectOption o;
        RetrieveShiptoLocations();
        buildListOfLineItems();                                                                                                  
    }
    //*** Method to create new location *** 
    @testVisible
    private void createNewLocation() {
        try {
            OrderingUIClasses.ShippingLocation s = new OrderingUIClasses.ShippingLocation();
            Integer newNo = selectedLocations.size() + 1;
            //Added By Ranjith on Jul 13, 2017 -- Starts
            for (OrderingUIClasses.ShippingLocation selLoc : selectedLocations) {
                System.debug('##########'+selectedLocations.size());
                if(newNo <= selLoc.LineNumber) {
                    newNo = selLoc.LineNumber + 1;
                }
                System.debug('##########newNo '+newNo );
            }  
            //Added By Ranjith on Jul 13, 2017 -- Ends   
            s.LineNumber = newNo;
            s.AddressId = selectedShippingAddressId;
            s.Address = retrieveAddress(selectedShippingAddressId);
            s.shippingMethod = '';
            if(selectedShippingMethod != null) {
                s.shippingmethod = selectedShippingMethod;                                      
            }                                                                        
            s.NeedByDate = enteredNeedByDate ;
            s.ShippingInstructions = enteredShippingInstructions;
            
            //Added By Ranjith on Jul 13, 2016 -- Starts
            System.debug('##########'+selectedLocations.size());
            selectedLocations.add(s); 
            System.debug('##########'+selectedLocations.size());
            system.debug('######locNumsForExisting' + locNumsForExisting);
            //Added By Ranjith on Jul 13, 2016 -- Ends
            
            for (OrderingUIClasses.LineItem item : lineItems) {
                if(item.IsShippable) {
                    OrderingUIClasses.LineItemAllocation lia = new OrderingUIClasses.LineItemAllocation();
                    lia.Location = newNo;
                    lia.Quantity = 0;
                    item.Allocation.add(lia);
                } 
            }
            saveAccountOrderAddress();                                      
        } 
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
    }
    //*** Method to save account order address *** 
    public PageReference saveAccountOrderAddress() { 
        try {
            Boolean saved = setAndSaveOrder();
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));
                                                                                       
        }                                        
        return null;
    }
    //*** Method to update location *** 
    @testVisible
    private void updateLocation() {
                                                                  
        OrderingUIClasses.ShippingLocation s = selectedLocations[selectedLocationNumber];
        if(s != null) {
            s.AddressId = selectedShippingAddressId;
            s.Address = retrieveAddress(selectedShippingAddressId);
            s.shippingMethod = '';
            if(selectedShippingMethod != null) {
                s.shippingmethod = selectedShippingMethod;
            }
            s.NeedByDate = null;
            if(selectedShippingMethod.startsWith('Time Definite') || selectedShippingMethod == 'Economy') {
                s.NeedByDate = enteredNeedByDate ;
            }                                                                                         
            s.ShippingInstructions = enteredShippingInstructions;
            //Added By Ranjith on Jul 13, 2016 -- Starts  
            Account_Order_Address__c objUpdateAOA = new Account_Order_Address__c();
            objUpdateAOA.Id = selectedShippingAddressId;
            objUpdateAOA.Need_By_Date__c = EnteredNeedByDate;
            objUpdateAOA.Shipping_Instructions__c = EnteredShippingInstructions;
            objUpdateAOA.Shipping_Method_Name__c = selectedShippingMethod;
            try {
                update objUpdateAOA;
            }
            catch(Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            //Added By Ranjith on Jul 13, 2016 -- Ends
        } else {
            System.debug('Could not locate shipping location.');
        } 
    }
    //*** Method to cancel updating of address *** 
    public PageReference cancelUpdateAddress() {
        initializeAddressArea();
        displayLocationPopup = false;
        //Added By Ranjith on Jul 13, 2016 -- Starts
        AddUpdateAddressStatus = 'add';
        prepareAddressTab(); 
        //Added By Ranjith on Jul 13, 2016 -- Ends                                                              
        return null;
    }
    //*** Method to initialize address area *** 
    private void initializeAddressArea() {
        selectedShippingAddressId = '';
        selectedShippingAddress = null;
        selectedShippingMethod = '';
        enteredShippingInstructions = '';
        enteredNeedByDate = null;
                                                                          
    }
    //*** Method to edit location *** 
    public PageReference editLocation() {
        addUpdateAddressStatus = 'update';
        //Added By Ranjith on Jul 13, 2017 -- Starts      
        //integer i = LineNumber - 1;      
        Integer i = 0;
        for (OrderingUIClasses.ShippingLocation selLoc : selectedLocations) {
            if(selLoc.LineNumber == LineNumber) {
                break;
            }
            i++;
        } 
        prepareAddressTab();   
        //Added By Ranjith on Jul 13, 2017 -- Ends 
        selectedLocationNumber = i;
        try {
            selectedShippingAddressId = selectedLocations[i].AddressId; //Added By Ranjith on Jul 13, 2017
            selectedShippingAddress = retrieveAddress(selectedShippingAddressId);
                                                                             
            selectedShippingMethod = selectedLocations[i].ShippingMethod;
            enteredShippingInstructions = selectedLocations[i].ShippingInstructions;
            enteredNeedByDate  = selectedLocations[i].NeedByDate;

        } catch (Exception ex) {
            System.debug(ex);
        }
        displayLocationPopup = true;
                                                                 
        return null;
    }
    //*** Method to remove location *** 
    public PageReference removeLocation() {
                                                            
        try {
            Account_Order_Address__c addressToDelete = new Account_Order_Address__c(Id=selectedAddressRecordId);
            delete addressToDelete;
            //Added By Ranjith on Jul 13, 2016 -- Starts
            //selectedLocations.remove(LineNumber - 1);
            //RenumberLocations();
            Integer intTobeRemovedLineNo = 0;
            for (OrderingUIClasses.ShippingLocation selLoc : selectedLocations) {
                if(selLoc.LineNumber == LineNumber) {
                    break;
                }
                intTobeRemovedLineNo++;
            } 
            selectedLocations.remove(intTobeRemovedLineNo);
            //Added By Ranjith on Jul 13, 2016 -- Ends
        } 
        catch (Exception ex) {
            System.debug(ex);
        }
                                                                   
        return null;
    }
    //*** Method to renumber location *** 
    @testVisible
    private void renumberLocations() {  
        Integer i = 1;
        for(OrderingUIClasses.ShippingLocation s : selectedLocations) {
            s.LineNumber = i;
            i++;
        }
                                                                      
    }
    //*** Method to initialize *** 
    @testVisible
    private void initialize() {
        addUpdateAddressStatus = 'add';                                                                
    }
    //*** Method to save order *** 
    private Boolean setAndSaveOrder() {             
        Boolean saved = true;
        try {
            saveLocationsAndItems();                            
        }                  
        catch (DmlException ex) {                                                                    
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));
            throw ex;
        } 
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));            
                                                                    
            ApexPages.addMessages(ex);
            throw ex;
        }                                                                       
        return saved;
    }
    //*** Method to save location and items for an order *** 
    @testVisible
    private void saveLocationsAndItems() {
                                                                                 
        Savepoint sp = Database.setSavepoint();
        try {
            //Added By Ranjith on Jul 13, 2017 -- Starts
            //List<Account_Order_Address__c> toDelete = [SELECT id from Account_Order_Address__c where Quote__c = :quote.Id and Sort_Order__c != null];
            //delete toDelete;
            system.debug('######locNumsForExisting' + locNumsForExisting);
            List<Account_Order_Address__c> newLocList = new List<Account_Order_Address__c>();
            Map<String, Id> map_AccAddrFromAOAs = new Map<String, Id>();
            Map<Id, String> map_AccAddrs = new Map<Id, String>();
            for(Address__c objAccAddr : [SELECT Id, Address_Line_1__c, City__c, Country__c, Zipcode__c, State__c
                                         FROM Address__c
                                         //WHERE Account__c =: quote.zqu__Account__c]) {
                                         WHERE Account__c IN :set_AccountIds]) {
                map_AccAddrs.put(objAccAddr.Id, objAccAddr.Address_Line_1__c+objAccAddr.City__c+objAccAddr.State__c+objAccAddr.Country__c+objAccAddr.Zipcode__c);    
            }
            System.debug('######map_AccAddrs'+map_AccAddrs);
            map_ExistingShipToAddrs = new Map<Id, Account_Order_Address__c>([SELECT Id, Address_Type__c, Shipping_Method_Name__c, Account__c, New__c,
                                                                             Quote__c, Hardware_Address__c, Address__c, Address2__c, City__c, Sort_Order__c,
                                                                             Country__c, State__c, Zip_Code__c, Need_By_Date__c, Shipping_Instructions__c 
                                                                         FROM Account_Order_Address__c
                                                                         WHERE Zuora_Quote__c = :quote.Id
                                                                           AND Address_Type__c = 'Ship To']);     
            for(Account_Order_Address__c objAOA : map_ExistingShipToAddrs.values()) {
                if(!objAOA.New__c) {
                    map_AccAddrFromAOAs.put(objAOA.Address__c+objAOA.City__c+objAOA.State__c+objAOA.Country__c+objAOA.Zip_Code__c, objAOA.Id);
                }
            }
            System.debug('######map_ExistingShipToAddrs '+map_ExistingShipToAddrs);
            System.debug('######map_AccAddrFromAOAs'+map_AccAddrFromAOAs);
            //Added By Ranjith on Jul 13, 2017 -- Ends    
            
            for(OrderingUIClasses.ShippingLocation sl : selectedLocations) {
                Account_Order_Address__c newAddress = new Account_Order_Address__c();
                //Added By Ranjith on Jul 13, 2017 -- Starts
                //To check if ship to address needs to created or updated
                System.debug('######'+sl.AddressId);
                if(map_ExistingShipToAddrs.containsKey(sl.AddressId) 
                   && (map_ExistingShipToAddrs.get(sl.AddressId).Shipping_Method_Name__c == null 
                       || map_ExistingShipToAddrs.get(sl.AddressId).Shipping_Method_Name__c == sl.ShippingMethod)) {
                        newAddress = map_ExistingShipToAddrs.get(sl.AddressId);
                }
                else if(map_AccAddrs.containsKey(sl.AddressId) && map_AccAddrFromAOAs.containsKey(map_AccAddrs.get(sl.AddressId))) {
                    Id objAOAId = map_AccAddrFromAOAs.get(map_AccAddrs.get(sl.AddressId));
                    if(map_ExistingShipToAddrs.get(objAOAId).Shipping_Method_Name__c == null 
                       || map_ExistingShipToAddrs.get(objAOAId).Shipping_Method_Name__c == sl.ShippingMethod) {
                        newAddress = map_ExistingShipToAddrs.get(objAOAId);
                    }
                }
                System.debug('######'+newAddress );
                //Added By Ranjith on Jul 13, 2017 -- Ends    
                newAddress.Account__c = quote.zqu__Account__c;
                newAddress.Zuora_Quote__c = quote.Id;                                                      
                newAddress.Address__c = sl.address.Street;
                newAddress.Address2__c = sl.address.Street2;
                newAddress.Address_Type__c = 'Ship To';
                newAddress.City__c = sl.address.City;
                newAddress.Country__c = sl.address.Country;
                newAddress.State__c = sl.address.State;
                newAddress.Zip_Code__c = sl.address.PostalCode;
                newAddress.Need_By_Date__c = sl.NeedByDate;
                newAddress.Shipping_Instructions__c = sl.ShippingInstructions;
                newAddress.Shipping_Method_Name__c = sl.ShippingMethod;
                newAddress.Sort_Order__c = sl.LineNumber;
                if(newAddress.Id == null) {
                    newAddress.New__c = true;
                }
                newLocList.add(newAddress);
            }
            //Added By Ranjith on Jul 13, 2017 -- Starts
            //insert newLocList;
            upsert newLocList;
            Map<Id, List<Order_Line_Item_Allocation__c>> map_ShipLocToOLIAs = new Map<Id, List<Order_Line_Item_Allocation__c>>();
            for(Order_Line_Item_Allocation__c olia : [SELECT Id, Order_Shipping_Location__c,Quantity__c, Quote_Rate_Plan_Charge__c 
                                                      FROM Order_Line_Item_Allocation__c 
                                                      WHERE Order_Shipping_Location__c IN : locNumsForExisting.values()]) {
                if(map_ShipLocToOLIAs.containsKey(olia.Order_Shipping_Location__c)) {
                    map_ShipLocToOLIAs.get(olia.Order_Shipping_Location__c).add(olia);
                }
                else {
                    map_ShipLocToOLIAs.put(olia.Order_Shipping_Location__c, new List<Order_Line_Item_Allocation__c> { olia });
                }
            }
            system.debug('#######' + map_ShipLocToOLIAs);
            //Added By Ranjith on Jul 13, 2017 -- Ends
            system.debug('######locNumsForExisting' + locNumsForExisting);
            Map<Decimal, id> locNums = new Map<Decimal, id>();                                                
            for(Account_Order_Address__c shipLoc : newLocList) {
                if(!locNumsForExisting.containsKey(shipLoc.Sort_Order__c)) {
                    locNums.put(shipLoc.Sort_Order__c, shipLoc.id);
                }
            }                              
            system.debug('#######' + locNums);
            system.debug('#######' + locNumsForExisting);
            List<Order_Line_Item_Allocation__c> allocationList = new List<Order_Line_Item_Allocation__c>();
            for(OrderingUIClasses.LineItem li : LineItems) {
                                                                             
                for(OrderingUIClasses.LineItemAllocation olia : li.Allocation) {
                    //Added By Ranjith on Jul 13, 2017 -- Starts
                    if(locNums.containsKey(olia.Location)
                       || (locNumsForExisting.containsKey(olia.Location) && !map_ShipLocToOLIAs.containsKey(locNumsForExisting.get(olia.Location)))) {                    
                    //Added By Ranjith on Jul 13, 2017 -- Ends                                    
                        Order_Line_Item_Allocation__c newOli = new Order_Line_Item_Allocation__c();
                        if (li.isOrderLine) {
                            newOli.Order_Line_Item__c = li.Id;
                            newOli.Order__c = li.parentId;
                        } 
                        else {
                            newOli.Quote_Rate_Plan_Charge__c = li.Id;
                            newOli.Zuora_Quote__c = li.parentId;
                        } 
                        if(locNums.containsKey(olia.Location)) {                                                                                                                   
                            newOli.Order_Shipping_Location__c = locNums.get(olia.Location);     
                        }
                        else if(locNumsForExisting.containsKey(olia.Location)) {
                            newOli.Order_Shipping_Location__c = locNumsForExisting.get(olia.Location);     
                        }                                                                       
                        newOli.Quantity__c = olia.Quantity;
                        allocationList.add(newOli);
                    //Added By Ranjith on Jul 13, 2017 -- Starts
                    }
                    system.debug('######allocationList' + allocationList.size());                    
                    if(locNumsForExisting.containsKey(olia.Location) && map_ShipLocToOLIAs.containsKey(locNumsForExisting.get(olia.Location))) {
                        for(Order_Line_Item_Allocation__c oliaExisting : map_ShipLocToOLIAs.get(locNumsForExisting.get(olia.Location))) {
                            if(oliaExisting.Quote_Rate_Plan_Charge__c == li.Id) {
                                oliaExisting.Quantity__c = olia.Quantity;
                                allocationList.add(oliaExisting);
                            }
                        }
                    }
                    //Added By Ranjith on Jul 13, 2017 -- Ends
                }
            }
            //Added By Ranjith on Jul 13, 2017 -- Starts
            //insert allocationList;
            system.debug('######allocationList' + allocationList.size()); 
            upsert allocationList;
            system.debug('######allocationList' + allocationList); 
            //Added By Ranjith on Jul 13, 2017 -- Ends            
        } catch (Exception ex) {
            system.debug('ERROR: SaveLocationsAndItems: ' + ex);
            Database.rollback(sp);
        }
                                                                           
    }
    //*** Method to create list of order line items *** 
    private void buildListOfLineItems() {
        // Create array list of parts and allocations from the database
        lineitems = new List<OrderingUIClasses.LineItem>();
        orderHasNonShippableParts = false;
        orderIsAllNonShippableParts = true;   
        
        List<zqu__QuoteRatePlanCharge__c> list_AllQuoteRtPlChrgs = [SELECT Id, zqu__Discount__c, zqu__ListPrice__c, zqu__ProductRatePlanCharge__c,
                                                                           zqu__EffectivePrice__c, zqu__Quantity__c, zqu__UOM__c, Partner_Price__c,
                                                                           zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c,
                                                                           zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c,
                                                                           zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name,
                                                                           zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c,
                                                                           zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.ProductShippable__c,
                                                                           zqu__ProductRatePlanCharge__r.zqu__ListPrice__c,
                                                                           zqu__QuoteRatePlan__r.zqu__Quote__c,
                                                                           (SELECT Order_Shipping_Location__c, Order_Shipping_Location__r.Sort_Order__c, Quantity__c
                                                                            FROM Order_Line_Item_Allocations__r
                                                                            ORDER BY Order_Shipping_Location__r.Sort_Order__c)
                                                                    FROM zqu__QuoteRatePlanCharge__c 
                                                                    WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =: quote.Id];
        if(Test.isRunningTest()){
            list_AllQuoteRtPlChrgs = TestDataFactoryForQuoteTool.setupQuoteRatePlanCharges(quote, false); 
        }
        for (zqu__QuoteRatePlanCharge__c item : list_AllQuoteRtPlChrgs) {
            OrderingUIClasses.LineItem i = buildLineItem(item);
            lineItems.add(i);
        }                                                                 
    }
    //*** Method to calculate support and grand total *** 
    @testVisible
    private void calculateSupportAndGrandTotal(List<Order_Line_Item__c> lstLineItems) {       
                                                      
        priceTotal = 0;
        partsTotal = 0;
        supportRateTotal = 0;
        supportDiscountTotal = 0;
        grandTotal = 0;       
    }
    //*** Method to build order line item for quote charge detail items *** 
    public OrderingUIClasses.LineItem buildLineItem(zqu__QuoteRatePlanCharge__c item) {
        OrderingUIClasses.LineItem i = new OrderingUIClasses.LineItem();
       /* zqu__QuoteRatePlanCharge__c obj_QtRtPlnChrge = new zqu__QuoteRatePlanCharge__c();
        if(map_PrdRtPlChrgeToQtRtPlChrge.containsKey(map_QtChrgeDtlToPrdRtPlChrge.get(item.Id))) {
            obj_QtRtPlnChrge = map_PrdRtPlChrgeToQtRtPlChrge.get(map_QtChrgeDtlToPrdRtPlChrge.get(item.Id));
        }*/
        System.debug('######item.id'+item.id);
        i.Id = item.id;
        i.IsOrderLine = false;
        i.ParentId = item.zqu__QuoteRatePlan__r.zqu__Quote__c; //item.zqu__Quote__c;
        i.PartNumber = item.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c; //item.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c;
        i.ListPrice = item.zqu__ProductRatePlanCharge__r.zqu__ListPrice__c;
        i.SalesPrice = item.zqu__EffectivePrice__c;
        ///i.MSRP = item.MSRP__c;
        i.PartName = item.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name; //item.zqu__ProductRatePlan__r.zqu__Product__r.Name;
        i.Quantity = Integer.valueOf(item.zqu__Quantity__c);
        i.IsShippable = false;
        //Added By Ranjith on May 31, 2017 -- Starts
        //if(item.zqu__ProductRatePlan__r.zqu__Product__r.Type__c == 'Product - Hardware') {
        System.debug('&&&&'+item.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.ProductShippable__c);
        if(item.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.ProductShippable__c=='Yes') {
        //Added By Ranjith on May 31, 2017 -- Ends
            i.IsShippable = true;
        }
        if(i.IsShippable == false) {
            orderHasNonShippableParts = true;
        } 
        else {
            orderIsAllNonShippableParts = false;
        }
        //i.OrderableStartDate = item.Orderable_Start_Date__c;
        //i.OrderableEndDate = item.Orderable_End_Date__c;
        i.Unallocated = i.IsShippable ? i.Quantity : 0;
        i.Allocation = new list<OrderingUIClasses.lineitemAllocation>();
        if(i.IsShippable) {
                                          
            Integer x = 1;
            Map<Decimal, Decimal> allocMap = new Map<Decimal, Decimal>();
            Map<Id, Decimal> map_ShipLocToSortOrder = new Map<Id, Decimal>(); //Added By Ranjith on Jul 13, 2017 
            
            for(Order_Line_Item_Allocation__c olia : item.Order_Line_Item_Allocations__r) {
                allocMap.put(olia.Order_Shipping_Location__r.Sort_Order__c, olia.Quantity__c);
                //Added By Ranjith on Jul 13, 2017 -- Starts
               map_ShipLocToSortOrder.put(olia.Order_Shipping_Location__c, olia.Order_Shipping_Location__r.Sort_Order__c);
               if(olia.Order_Shipping_Location__r.Sort_Order__c > x) {
                   x = Integer.valueOf(olia.Order_Shipping_Location__r.Sort_Order__c);
               }
               //Added By Ranjith on Jul 13, 2017 -- Ends
            }
            System.debug('map_ShipLocToSortOrder '+map_ShipLocToSortOrder );
            shippingLocationCount = selectedLocations.size();

            for(OrderingUIClasses.ShippingLocation s : selectedLocations) {
                OrderingUIClasses.LineItemAllocation ia = new OrderingUIClasses.LineItemAllocation();
                //Added By Ranjith on Jul 13, 2017 -- Starts
                if(map_ShipLocToSortOrder.containsKey(s.AddressId)) {
                    ia.Location = Integer.valueOf(map_ShipLocToSortOrder.get(s.AddressId));
                }
                else {
                //Added By Ranjith on Jul 13, 2017 -- Ends
                    ia.Location = x++;
                }//Added By Ranjith on Jul 13, 2017
                if(shippingLocationCount == 1) {
                    ia.Quantity = i.Quantity;
                } 
                else {
                    ia.Quantity = 0;
                    if(allocMap.containsKey(ia.Location)) {
                        ia.Quantity = Integer.valueOf(allocMap.get(ia.Location));
                    } 
                }
                i.Allocation.add(ia);
                System.debug('map_ShipLocToSortOrder '+ia);
            }
            if(i.Allocation.size() == 1) {
            }
        }                                               
        return i;
    }
    
    //*** Method to show ship to selection ***
    public void showShipToSelection() {
        strSubSelectedTab = 'Ship To Selection';
    }
    //*** Method to input allocation info for shipping address ***
    public PageReference enterAllocationTab() {
        showAllocation =false;
        buildListOfLineItems();
        saveOrder();
        showAllocation =true;
                            
        return null;
    }
    //*** Method to build line items and save order ***
    public PageReference enterSubmitTab() {
                                                            
        strSubSelectedTab = 'Review and Submit';
        buildListOfLineItems();
        saveOrder();                            
                                                                   
        return null;
    }
    //*** Method to save order ***
    public PageReference saveAndClose() {
        saveOrder();
                    
        return new PageReference('/' + quote.Id);
    }
    //*** Method to save order ***
    public PageReference saveOrder() {
        if(orderExists == false) {  
            orderExists=true;
        }
        try {
            Boolean saved = setAndSaveOrder();                                              
        }
        catch(Exception ex) {
         
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,ex.getMessage()) );
                                                                                         
        }
        return null;
    }
    // *** Method to return quote object ***
    public zqu__Quote__c getQuote(Id quoteId) {
        zqu__Quote__c quote = (zqu__Quote__c) Database.query(prepareQuoteQuery(quoteId)); 
        return quote;
    }
    // *** Method to get shipping location count ***
    public Integer shippingLocationCount {
        get {
            return selectedLocations.size();
        }
        set;
    }
    // *** Method to return shipping locations ***
    public List<OrderingUIClasses.ShippingLocation> getselectedLocations() {
        return selectedLocations;
    }
    // *** Method to find no of orders ***
    private void findNoOfOrders() {
        intNoOfOrders = [SELECT COUNT() 
                         FROM zqu__Quote__c 
                         WHERE zqu__Opportunity__c=:quote.zqu__Opportunity__c
                           AND zqu__ApprovalStatus__c='Order Submitted'];
    }
    // *** Method to generate query string to query Quote from the DB ***
    public String prepareQuoteQuery(Id quoteId) {
        String strQuoteQuery = 'SELECT ';                                                                                                                                                                                           
        strQuoteQuery += 'zqu__Opportunity__c, zqu__Account__c, zqu__Opportunity__r.BusinessPartner__c FROM zqu__Quote__c WHERE id = \'' + quoteId + '\'';        
        return strQuoteQuery;
    }
}