/**
 * Created by pke on 3/28/17.
 */

public with sharing class CreateOrderMultipleShipPCCCntlr {
    public String strSelectedTab { get; private set; }
    public BigMachines__Quote__c quote { get; set; }
    String quoteId;

    //Praveen
    public String strSubSelectedTab { get; private set; }
    public boolean OrderIsAllNonShippableParts { get; set; }  // If the order has all non-shippable parts, then shipping locations are not required.
    public boolean displayLocationPopup { get; set; }
    public string selectedShippingAddressId { get; set; }
    public OrderingUIClasses.mAddress SelectedShippingAddress { get; set; }
    public integer selectedLocationNumber { get; set; }
    private List<SelectOption> shippingAddressList = new List<SelectOption>();
    public List<SelectOption> shippingMethodList = new List<SelectOption>();
    public string selectedShippingMethod { get; set; }
    public date enteredNeedByDate { get; set; }
    public string AddUpdateAddressStatus { get; set; }
    public string enteredShippingInstructions { get; set; }
    public Integer LineNumber { get; set; }
    public string defaultTab {get;set;}
    public string selectedAddressRecordId {get;set;}
    public boolean CaaSTabVisible {get;set;}
    public List<OrderingUIClasses.LineItem> lineItems = new List<OrderingUIClasses.LineItem>();
    public List<SelectOption> getShippingAddresses() {
        return shippingAddressList;
    }
    public boolean OrderHasNonShippableParts { get; set; }    // if the order has non-shippable parts, then display the non-shippable parts section.
    public string unsubmitableMessage { get; set; }
    private boolean OrderExists = false;
    public boolean CanOrderBeSubmitted {get;set;}           // indicates whether or not Sales can submit the order
    public decimal priceTotal {get; set;}
    private decimal partsTotal;
    public decimal supportRateTotal {get; set;}
    public decimal grandTotal {get; set;}
    public decimal supportDiscountTotal {get; set;}
    private Set<Id> set_AccountIds = new Set<Id>();
    private Map<Id, Account_Order_Address__c> map_ExistingShipToAddrs;
    Map<Decimal, id> locNumsForExisting = new Map<Decimal, id>();


// ----------- Shipping Method List ---------------
    public List<SelectOption> getShippingMethodList() {
        return ShippingMethodList;
    }
    public List<OrderingUIClasses.LineItem> getLineItems() {
        return lineItems;
    }

    public CreateOrderMultipleShipPCCCntlr(ApexPages.StandardController controller){
        quoteId = ApexPages.currentPage().getParameters().get('id');
        system.debug(LoggingLevel.Error, '=====> quoteId()'+quoteId);
        quote = getQuote(quoteId);
        set_AccountIds.add(quote.End_User_ID__c);
        if(quote.Sold_To_Name__c != null) {
            set_AccountIds.add(quote.Sold_To_Name__c);
        }
        System.debug(LoggingLevel.Error, '----quote'+quote);
        showMultiShipTo();
    }
    public void showMultiShipTo() {
        System.debug(LoggingLevel.Error, '----inside showMultiShipTo();');
        strSelectedTab = 'Multi ShipTo';
        defaultTab = 'ShippingTab';
        CaaSTabVisible = true;
        prepareAddressTab();
        System.debug(LoggingLevel.Error, '----defaultTab'+defaultTab);
        System.debug(LoggingLevel.Error, '----strSelectedTab'+strSelectedTab);

        System.debug(LoggingLevel.Error, '----leaving showMultiShipTo();');
    }

//
//-----Shipto Selection
    List<OrderingUIClasses.ShippingLocation> selectedLocations = new List<OrderingUIClasses.ShippingLocation>();
    public void retrieveShiptoLocations() {
        system.debug(LoggingLevel.Error, '=====> retrieveShiptoLocations()');
        try {
            selectedLocations = new List<OrderingUIClasses.ShippingLocation>();
            system.debug(LoggingLevel.Error,'=====> --> OrderNo: ' + quoteId);
            for (Account_Order_Address__c aoa : [
                    SELECT id, Address__c, Address2__c, Address_Type__c, City__c, Country__c, 
                            Account__c, Sold_To_Business_Partner__c, State__c, Zip_Code__c, Order__c,
                            Shipping_Method_Name__c, Need_By_Date__c, Sort_Order__c, Shipping_Instructions__c
                    from Account_Order_Address__c
                    where Quote__c = :quoteId and Sort_Order__c != null
                    order by Sort_Order__c
            ]) {

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

                SelectedLocations.add(shipLoc);
                system.debug(LoggingLevel.Error,'=====> --> aoshipLoca: ' + aoa);
            }
            system.debug(LoggingLevel.Error,'=====> --> selectedLocations size: ' + SelectedLocations.size());
            system.debug(LoggingLevel.Error,'=====> --> selectedLocations size: ' + SelectedLocations);

        } catch (Exception ex) {
            system.debug(LoggingLevel.Error,'=====> ERROR: retrieveShiptoLocations: ' + ex);
        }
    }
    public void ShowLocationPopup() {
        selectedLocationNumber = -1;
        displayLocationPopup = true;
        //Added by Ranjith on Jun 09, 2016 -- Starts
        //Pull all ship to addresses from account order addresses
        map_ExistingShipToAddrs = new Map<Id, Account_Order_Address__c>([SELECT Id, Address_Type__c, Shipping_Method_Name__c
                                                                         FROM Account_Order_Address__c
                                                                         WHERE Quote__c = :quote.Id
                                                                           AND Address_Type__c = 'Ship To']);        
        prepareAddressTab();
        System.debug('######'+map_ExistingShipToAddrs.size());
        System.debug('######'+map_ExistingShipToAddrs);
        //Added By Ranjith on Jun 09, 2016 -- Ends
    }
    public PageReference ShippingAddressSelect() {
        system.debug('ShippingAddressSelect():' + selectedShippingAddressId);
        if (selectedShippingAddressId != 'select') {
            SelectedShippingAddress = RetrieveAddress(selectedShippingAddressId);
        } else {
            SelectedShippingAddress = null;
        }
        return null;
    }
    public OrderingUIClasses.mAddress RetrieveAddress(string addrId) {
        OrderingUIClasses.mAddress mAddr = new OrderingUIClasses.mAddress();

        List<Address__c> addrList = [
                SELECT id, name, Address_Line_1__c, Address_Line_2__c, Address_line_3__c, Country__c,
                        City__c, County__c, Is_Primary__c, Zipcode__c, State__c, Is_Inactive__c
                FROM Address__c
                WHERE id = :addrId
                LIMIT 1
        ];
        if (addrList.size() > 0) {
            Address__c addr = addrList.get(0);
            mAddr.Name = addr.Name;
            //mAddr.LegalName = addr.Legal_Name__c != null ? addr.Legal_Name__c : '';
            mAddr.Street = addr.Address_Line_1__c != null ? addr.Address_Line_1__c : '';
            mAddr.City = addr.City__c != null ? addr.City__c : '';
            mAddr.State = addr.State__c != null ? addr.State__c : '';
            mAddr.PostalCode = addr.Zipcode__c != null ? addr.Zipcode__c : '';
            mAddr.isActive = addr.Is_Inactive__c;
            mAddr.Country = addr.Country__c != null ? addr.Country__c : '';
            //maddr.AxId = addr.AX_Location_ID__c;
            maddr.Id = addr.id;
            /*mAddr.BillingContact = addr.Billing_Contact__r;
            mAddr.BillingContactId = addr.Billing_Contact__c;
            mAddr.BillingContactName = addr.Billing_Contact__r.Name != null ? addr.Billing_Contact__r.Name : 'Contact Not Defined' ;
            mAddr.BillingContactPhone = addr.Billing_Contact__r.Phone != null ? addr.Billing_Contact__r.Phone : '' ;
            mAddr.BillingContactEmail = addr.Billing_Contact__r.Email != null ? addr.Billing_Contact__r.Email : '' ;
            mAddr.BillingContactFax = addr.Billing_Contact__r.Fax != null ? addr.Billing_Contact__r.Fax : '' ;
            mAddr.ShippingContact = addr.Shipping_Contact__r;
            mAddr.ShippingContactId = addr.Shipping_Contact__c;
            mAddr.ShippingContactName = addr.Shipping_Contact__r.Name != null ? addr.Shipping_Contact__r.Name : 'Contact Not Defined' ;
            mAddr.ShippingContactPhone = addr.Shipping_Contact__r.Phone != null ? addr.Shipping_Contact__r.Phone : '' ;
            mAddr.ShippingContactEmail = addr.Shipping_Contact__r.Email != null ? addr.Shipping_Contact__r.Email : '' ;
            mAddr.ShippingContactFax = addr.Shipping_Contact__r.Fax != null ? addr.Shipping_Contact__r.Fax : '' ;*/
        }
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

        return mAddr;
    }
    public PageReference SaveLocation() {
        system.debug(LoggingLevel.Error,'=====> Enter SaveLocation()');

        boolean allowSave = true;
        system.debug('SaveLocation()');
        if (String.isBlank(selectedShippingAddressId)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Shipping Address is required.'));
            allowSave = false;
        }
// validate the shipping method
        if (String.isBlank(selectedShippingMethod)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Shipping Method is required.'));
            allowSave = false;
        }
// validate the shipping location
        else {
            if ((selectedShippingMethod.startsWith('Time Definite')) && (EnteredNeedByDate == null)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Need by Date is required for the selected shipping method.'));
                allowSave = false;
            }
        }

        if (allowSave == false) {
            return null;
        }

        system.debug('===> SelectedLocationNumber: ' + selectedLocationNumber);
        if ((selectedLocationNumber == null) || (selectedLocationNumber == -1)) {
            system.debug('######locNumsForExisting' + locNumsForExisting);
            CreateNewLocation();
        } else {
            UpdateLocation();
        }

        InitializeAddressArea();
        displayLocationPopup = false;
//system.debug('exit SaveLocation()');
        system.debug(LoggingLevel.Error,'=====> Leaving SaveLocation()');
        
        //Added By Ranjith on Jul 06, 2017 -- Starts
        PageReference returnPage = Page.CreateQuoteCloudPC;
        if(quote.offering_type__c == QuoteUtil.OFFERING_TYPE_CAAS) {
            returnPage = Page.CreateQuoteCloud;
        }
        returnPage.getParameters().put('id', quote.Id);
        returnPage.getParameters().put('tab', 'OrderSubmission');
        return returnPage; 
        //Added By Ranjith on Jul 06, 2017 -- Ends
    }
    public void doSaveAllocation(){
        if(ApexPages.currentPage().getParameters().get('saveAlloc') != null)
            SaveOrder();
    }
    private void prepareAddressTab() {
        system.debug(LoggingLevel.Error,'=====> Enter prepareAddressTab()');
        shippingAddressList = new List<SelectOption>();
        system.debug(LoggingLevel.Error,'=====> Enter prepareAddressTab()'+quote.End_User_ID__c);
        
        if(AddUpdateAddressStatus != 'update') { //Added By Ranjith on Jul 13, 2017
            for (Address__c a : [SELECT id, name, type__c from Address__c where Is_Inactive__c = false and account__c IN :set_AccountIds order by name]) {
                shippingAddressList.add(new SelectOption(a.Id, a.Name));
            }
            
            //Added By Ranjith on Jul 13, 2017 -- Starts
            for (Account_Order_Address__c aoa : [SELECT Id, Name, Address__c
                                                 FROM Account_Order_Address__c 
                                                 WHERE New__c = true
                                                   AND Address_Type__c='Ship To' 
                                                   AND Quote__c = :quoteId ORDER BY Name]) {
                shippingAddressList.add(new SelectOption(aoa.Id, aoa.Address__c));
            }
        }
        else {
            for (Account_Order_Address__c aoa : [SELECT Id, Name, Address__c
                                                 FROM Account_Order_Address__c 
                                                 WHERE Quote__c = :quoteId 
                                                   AND Address_Type__c='Ship To' ORDER BY Name]) {
                shippingAddressList.add(new SelectOption(aoa.Id, aoa.Address__c));
            }            
        }
        shippingMethodList.clear();            
        //Added By Ranjith on Jul 13, 2017 -- Ends
        
        Schema.DescribeFieldResult fieldResult = Account_Order_Address__c.Shipping_Method_Name__c.getDescribe();
        for (Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            shippingMethodList.add(new SelectOption(f.getValue(), f.getValue()));
        }
        SelectOption o;
        RetrieveShiptoLocations();
        system.debug('######locNumsForExisting' + locNumsForExisting);
        BuildListofLineItems();
        system.debug(LoggingLevel.Error,'=====> Leaving prepareAddressTab()'+shippingAddressList);
    }
    private void CreateNewLocation() {
        system.debug(LoggingLevel.Error,'CreateNewLocation(): ' );


        try {
            OrderingUIClasses.ShippingLocation s = new OrderingUIClasses.ShippingLocation();            
            integer newNo = selectedLocations.size() + 1;
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
            s.Address = RetrieveAddress(selectedShippingAddressId);
            if (selectedShippingMethod != null) {
                s.shippingmethod = selectedShippingMethod;
            } else {
                s.shippingMethod = '';
            }
            /*if (selectedShippingMethod.startsWith('Time Definite') ) {
                s.NeedByDate = EnteredNeedByDate;
            }*/
            s.NeedByDate = EnteredNeedByDate;
            s.ShippingInstructions = enteredShippingInstructions;
            //Added By Ranjith on Jul 13, 2016 -- Starts
            System.debug('##########'+selectedLocations.size());
            //if(!locNumsForExisting.containsKey(selectedShippingAddressId)) {
                selectedLocations.add(s);
            //}
            //selectedLocations.add(s); 
            System.debug('##########'+selectedLocations.size());
            system.debug('######locNumsForExisting' + locNumsForExisting);
            //Added By Ranjith on Jul 13, 2016 -- Ends
            for (OrderingUIClasses.LineItem item : lineItems) {
                if(item.IsShippable) { //Added By Ranjith on Jul 13, 2016
                    OrderingUIClasses.LineItemAllocation lia = new OrderingUIClasses.LineItemAllocation();
                    lia.Location = newNo;
                    lia.Quantity = 0;
                    item.Allocation.add(lia);
                }
            }
//insert newAddress;
            SaveAccountOrderAddress();
        } catch (Exception ex) {
//system.debug('error on save');
            ApexPages.addMessages(ex);
        }
        system.debug(LoggingLevel.Error,'Leaving CreateNewLocation(): ' );

    }
    public PageReference SaveAccountOrderAddress() {
        System.debug('SaveAccountOrderAddress()');
        /*if (orderExists == false) {
            insert order;
            orderExists=true;
        }*/
        try {
            boolean saved = SetAndSaveOrder();
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));
//InsertNote('Error Saving Order',ex.getMessage() + '\n\n' + ex.getStackTraceString());
        }
        System.debug('end SaveOrder()');
        return null;
    }
    private void UpdateLocation() {
        system.debug(LoggingLevel.Error,'UpdateLocation(): ' );
        system.debug('selectedLocations(): ' + selectedLocations);
        OrderingUIClasses.ShippingLocation s = selectedLocations[selectedLocationNumber];
        if (s != null) {
            s.AddressId = selectedShippingAddressId;
            s.Address = RetrieveAddress(selectedShippingAddressId);
            if (selectedShippingMethod != null) {
                s.shippingmethod = selectedShippingMethod;
            } else {
                s.shippingMethod = '';
            }
            system.debug('selectedShippingMethod: ' + selectedShippingMethod);
            if (selectedShippingMethod.startsWith('Time Definite') || selectedShippingMethod == 'Economy') {
                s.NeedByDate = EnteredNeedByDate;
            } else {
                s.NeedByDate = null;
            }
            system.debug('selectedShippingInstructions: ' + EnteredShippingInstructions);
            s.ShippingInstructions = EnteredShippingInstructions;
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
            system.debug('could not locate shipping location.');
        }
        system.debug(LoggingLevel.Error,'UpdateLocation(): ' );
        
    }
    public PageReference CancelUpdateAddress() {
        system.debug(LoggingLevel.Error,'CancelUpdateAddress(): ' );

        InitializeAddressArea();
        displayLocationPopup = false;
        //Added By Ranjith on Jul 13, 2016 -- Starts
        AddUpdateAddressStatus = 'add';
        prepareAddressTab(); 
        //Added By Ranjith on Jul 13, 2016 -- Ends  
        system.debug(LoggingLevel.Error,'CancelUpdateAddress(): ' );
        return null;
    }
    private void InitializeAddressArea() {
        System.debug(LoggingLevel.Error,'-InitializeAddressArea-');

//system.debug('InitializeAddressArea()');
//SelectedShippingContact = null;
//myListOfContacts.clear();
        selectedShippingAddressId = '';
        selectedShippingAddress = null;
        selectedShippingMethod = '';
        EnteredShippingInstructions = '';
        EnteredNeedByDate = null;
        System.debug(LoggingLevel.Error,'Leaving-InitializeAddressArea-');
    }
    public PageReference EditLocation() {
        System.debug(LoggingLevel.Error,'-EditLocation-');

        AddUpdateAddressStatus = 'update';
        //Added By Ranjith on Jul 13, 2016 -- Starts      
        //integer i = LineNumber - 1;      
        Integer i = 0;
        for (OrderingUIClasses.ShippingLocation selLoc : selectedLocations) {
            if(selLoc.LineNumber == LineNumber) {
                break;
            }
            i++;
        } 
        //Added By Ranjith on Jul 13, 2016 -- Ends  
        prepareAddressTab();      
        selectedLocationNumber = i;
        try {
            selectedShippingAddressId = selectedLocations[i].AddressId;
            System.debug('-selectedShippingAddressId -'+selectedShippingAddressId );
            selectedShippingAddress = RetrieveAddress(selectedShippingAddressId);
            //SelectedShippingContactId = selectedLocations[i].Address.ShippingContactId;
            selectedShippingMethod = selectedLocations[i].ShippingMethod;
            EnteredShippingInstructions = selectedLocations[i].ShippingInstructions;
            EnteredNeedByDate = selectedLocations[i].NeedByDate;

        } catch (Exception ex) {
            system.debug(ex);
        }
        displayLocationPopup = true;
        System.debug(LoggingLevel.Error,'Leaving-EditLocation-');
        return null;
    }
    public PageReference RemoveLocation() {
        System.debug(LoggingLevel.Error,'-RemoveLocation-');
        try {
            Account_Order_Address__c addressToDelete = new Account_Order_Address__c(id=SelectedAddressRecordId);
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
            /*
            for (OrderingUIClasses.LineItem li : lineItems) {
                li.ShippingLocation.remove(LineNumber - 1);
                integer i = 1;
                for (OrderingUIClasses.ShippingLocation lia : li.ShippingLocation) {
                    lia.Location = i;
                    i++;
                }
            }
            */
        } catch (Exception ex) {
            system.debug(ex);
        }
        System.debug(LoggingLevel.Error,'Leaving-RemoveLocation-');
        return null;
    }
    private void RenumberLocations() {
        System.debug(LoggingLevel.Error,'-RenumberLocations-');

//system.debug('RenumberLocations()');
        integer i = 1;
        for (OrderingUIClasses.ShippingLocation s : selectedLocations) {
            s.LineNumber = i;
            i++;
        }
        System.debug(LoggingLevel.Error,'Leaving-RenumberLocations-');
    }
    private void Initialize() {
        System.debug(LoggingLevel.Error,'-Enter Initialize-');
        AddUpdateAddressStatus = 'add';
        System.debug(LoggingLevel.Error,'-Leaving Initialize-');
    }
// -------------------------------------------------------------------------------
// Save Order
// -------------------------------------------------------------------------------
//
    private boolean SetAndSaveOrder() {
        System.debug(LoggingLevel.Error,'-ENter SetAndSaveOrder()-');
        List<sObject> ItemsToSave = new List<sObject>();
        boolean saved = true;
        try {
            /*PopulateOrder();
            if (order.id == null) {
                //system.debug('-- insert the order');
                insert order;
            }
            else {
                //system.debug('-- update the order');
                update order;
            }*/
            SaveLocationsAndItems();

            /*if(isPureCloudOrder) {
                SaveQuote();
            }

            customerAccount.Pending_Order__c = true;
            update customerAccount;*/
//System.debug ('order saved.');
        } catch (DmlException ex) {
            system.debug('Error on order save: ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));

//ApexPages.addMessages(ex);
            throw ex;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));
            system.debug('Error on order save: ' + ex.getMessage());
            ApexPages.addMessages(ex);
            throw ex;
        }
        System.debug(LoggingLevel.Error,'-Leaving SetAndSaveOrder()-');
        return saved;
    }
    private void SaveLocationsAndItems() {
        System.debug(LoggingLevel.Error,'-ENter SaveLocationsAndItems-');        
        Savepoint sp = database.setSavepoint();
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
                                         WHERE Account__c IN :set_AccountIds]) {
                map_AccAddrs.put(objAccAddr.Id, objAccAddr.Address_Line_1__c+objAccAddr.City__c+objAccAddr.State__c+objAccAddr.Country__c+objAccAddr.Zipcode__c);    
            }
            System.debug('######map_AccAddrs'+map_AccAddrs);
            map_ExistingShipToAddrs = new Map<Id, Account_Order_Address__c>([SELECT Id, Address_Type__c, Shipping_Method_Name__c, Account__c, New__c,
                                                                             Quote__c, Hardware_Address__c, Address__c, Address2__c, City__c, Sort_Order__c,
                                                                             Country__c, State__c, Zip_Code__c, Need_By_Date__c, Shipping_Instructions__c 
                                                                         FROM Account_Order_Address__c
                                                                         WHERE Quote__c = :quote.Id
                                                                           AND Address_Type__c = 'Ship To']);     
            for(Account_Order_Address__c objAOA : map_ExistingShipToAddrs.values()) {
                if(!objAOA.New__c) {
                    map_AccAddrFromAOAs.put(objAOA.Address__c+objAOA.City__c+objAOA.State__c+objAOA.Country__c+objAOA.Zip_Code__c, objAOA.Id);
                }
            }
            System.debug('######map_ExistingShipToAddrs '+map_ExistingShipToAddrs);
            System.debug('######map_AccAddrFromAOAs'+map_AccAddrFromAOAs);
            //Added By Ranjith on Jul 13, 2017 -- Ends
            for (OrderingUIClasses.ShippingLocation sl : SelectedLocations) {
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
                       || map_ExistingShipToAddrs.get(objAOAId ).Shipping_Method_Name__c == sl.ShippingMethod) {
                        newAddress = map_ExistingShipToAddrs.get(objAOAId);
                    }
                }
                System.debug('######'+newAddress );
                //Added By Ranjith on Jul 13, 2017 -- Ends
                newAddress.Account__c = quote.End_User_ID__c;
                newAddress.Quote__c = quote.Id;
                newAddress.Hardware_Address__c = true;
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
            for(Order_Line_Item_Allocation__c olia : [SELECT Id, Order_Shipping_Location__c,Quantity__c,Quote_Product__c
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
            for (Account_Order_Address__c shipLoc : newLocList) {
                if(!locNumsForExisting.containsKey(shipLoc.Sort_Order__c)) {
                    locNums.put(shipLoc.Sort_Order__c, shipLoc.id);
                }
            }
            system.debug('#######' + locNums);
            system.debug('#######' + locNumsForExisting);
            List<Order_Line_Item_Allocation__c> allocationList = new List<Order_Line_Item_Allocation__c>();
// Here's where we're going to add the allocation records...
            system.debug(loggingLevel.Error, 'LineItems=' + LineItems);

            for (OrderingUIClasses.LineItem li : LineItems) {
                system.debug('######li.Allocation' + li.Allocation.size());  
                for (OrderingUIClasses.LineItemAllocation olia : li.Allocation) {
                    
                    //Added By Ranjith on Jul 13, 2017 -- Starts
                    if(locNums.containsKey(olia.Location)
                       || (locNumsForExisting.containsKey(olia.Location) && !map_ShipLocToOLIAs.containsKey(locNumsForExisting.get(olia.Location)))) {                    
                    //Added By Ranjith on Jul 13, 2017 -- Ends
                        Order_Line_Item_Allocation__c newOli = new Order_Line_Item_Allocation__c();
                        if (li.isOrderLine) {
                            newOli.Order_Line_Item__c = li.Id;
                            newOli.Order__c = li.parentId;
                        } else {
                            newOli.Quote_Product__c = li.Id;
                            newOli.Quote__c = li.parentId;
                        }
                        system.debug(loggingLevel.Error, 'newOli: ' + newOli);
    
                        //Added By Ranjith on Jul 13, 2017 -- Starts
                        if(locNums.containsKey(olia.Location)) {                                                                                                                   
                            newOli.Order_Shipping_Location__c = locNums.get(olia.Location);     
                        }
                        else if(locNumsForExisting.containsKey(olia.Location)) {
                            newOli.Order_Shipping_Location__c = locNumsForExisting.get(olia.Location);     
                        }   
                        //Added By Ranjith on Jul 13, 2017 -- Ends
                        
                        newOli.Quantity__c = olia.Quantity;
                        system.debug(loggingLevel.Error, '=====> add item allocation: ' + li.PartNumber + ' qty: ' + olia.Quantity);
                        allocationList.add(newOli);
                    //Added By Ranjith on Jul 13, 2017 -- Starts
                    }
                    system.debug('######allocationList' + allocationList.size());                    
                    if(locNumsForExisting.containsKey(olia.Location) && map_ShipLocToOLIAs.containsKey(locNumsForExisting.get(olia.Location))) {
                        for(Order_Line_Item_Allocation__c oliaExisting : map_ShipLocToOLIAs.get(locNumsForExisting.get(olia.Location))) {
                            if(oliaExisting.Quote_Product__c == li.Id) {
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
            upsert allocationList;
            //Added By Ranjith on Jul 13, 2017 -- Ends
        } catch (Exception ex) {
            system.debug('ERROR: SaveLocationsAndItems: ' + ex);
            database.rollback(sp);
        }
        System.debug(LoggingLevel.Error,'-Leaving SaveLocationsAndItems-');
    }
    private void BuildListofLineItems() {
        System.debug(LoggingLevel.Error,'-BuildListofLineItems-');

        //system.debug('BuildListOfLineItems');
        // Create the array list of parts and allocations from the database
        lineitems = new List<OrderingUIClasses.LineItem>();
        OrderHasNonShippableParts = false;
        OrderIsAllNonShippableParts = true;
        List<Order_Line_Item__c> lstLineItems = [
                Select o.Quantity__c, o.List_Price__c, o.Sales_Price__c,Order__c,
                        IsShippable__c, Product__r.Type__c,Product__r.ProductShippable__c,(
                        Select Order_Shipping_Location__c, Order_Shipping_Location__r.Sort_Order__c, Quantity__c
                        From Order_Line_Item_Allocations__r
                        Order by Order_Shipping_Location__r.Sort_Order__c
                )
                From Order_Line_Item__c o
                where o.Quote__c = :quote.Id
                Order by Sort_Order__c
        ];
        List<BigMachines__Quote_Product__c> quoteProducts = [
                Select o.BigMachines__Quantity__c, o.List_Price__c, o.BigMachines__Sales_Price__c,
                        BigMachines__Product__r.Type__c, BigMachines__Quote__c,BigMachines__Product__r.ProductShippable__c,
                        IsShippable__c,BigMachines__Product__r.APN_Number__c,BigMachines__Product__r.Name, 
                        BigMachines__Product__r.New_Category__c, Quantity_Change__c,
                        (Select Order_Shipping_Location__c, Order_Shipping_Location__r.Sort_Order__c, Quantity__c
                        From Order_Line_Item_Allocations__r
                        Order by Order_Shipping_Location__r.Sort_Order__c)
                From BigMachines__Quote_Product__c o
                where o.BigMachines__Quote__c = :quote.Id
                Order by Sort_Order__c
        ];
        if (!lstLineItems.isEmpty()){
            for (order_line_item__c item : lstLineItems) {
                OrderingUIClasses.LineItem i = BuildLineitem(item);
                lineItems.add(i);
            }
        } else {
            for (BigMachines__Quote_Product__c item : quoteProducts) {
                OrderingUIClasses.LineItem i = BuildLineitem(item);
                lineItems.add(i);
            }
        }
        /*if (lineItems.size() > 0) {
            calculateSupportAndGrandTotal(lstLineItems);
        }*/
        System.debug(LoggingLevel.Error,'-Leaving BuildListofLineItems-');
    }
    private void calculateSupportAndGrandTotal(List<Order_Line_Item__c> lstLineItems) {
        system.debug('calculateSupportAndGrandTotal');
        priceTotal = 0;
        partsTotal = 0;
        supportRateTotal = 0;
        supportDiscountTotal = 0;
        grandTotal = 0;
        // Implemented as per 'T-288406' description
        /*for(order_Line_item__c orderLineItm : lstLineItems) {
            if(orderLineItm.Sales_Price__c != null && orderLineItm.Quantity__c != null) {
                priceTotal = priceTotal + (orderLineItm.Sales_Price__c * orderLineItm.Quantity__c);
            }
            if(orderLineItm.Maintenance_Part_Number__c != null && orderLineItm.Maintenance_Amount__c != null && orderLineItm.Quantity__c != null) {
                supportRateTotal = supportRateTotal + (orderLineItm.Maintenance_Amount__c * orderLineItm.Quantity__c);
            }
        }
        grandTotal =  priceTotal + supportRateTotal;*/
    }
    public OrderingUIClasses.LineItem BuildLineitem(BigMachines__Quote_Product__c item) {
        System.debug(LoggingLevel.Error,'-BuildLineitem1-');

        OrderingUIClasses.LineItem i = new OrderingUIClasses.LineItem();
        i.id = item.id;
        i.isOrderLine = false;
        i.parentId = item.BigMachines__Quote__c;
        i.PartNumber = item.BigMachines__Product__r.APN_Number__c;
        i.ListPrice = item.List_Price__c;
        i.SalesPrice = item.BigMachines__Sales_Price__c;
        ///i.MSRP = item.MSRP__c;
        i.PartName = item.BigMachines__Product__r.Name;
        i.Quantity = Integer.valueOf(item.BigMachines__Quantity__c);
        if(quote.Offering_Type__c == 'PureCloud' 
           && ((quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.Renew_Subscription) 
                && item.BigMachines__Product__r.New_Category__c == 'Hardware' && item.Quantity_Change__c > 0)) {
            i.Quantity = Integer.valueOf(item.Quantity_Change__c);
        }    
        //Added By Ranjith on May 31, 2017 -- Starts
        i.IsShippable = false;
        if(item.BigMachines__Product__r.ProductShippable__c=='Yes') {
        //Added By Ranjith on May 31, 2017 -- Ends
            if(quote.Offering_Type__c != 'PureCloud' //if Added by Ranjith on Dec 20, 2017
               || (quote.Offering_Type__c == 'PureCloud' 
                   && (quote.Order_Type__c == Label.New_Subscription || quote.Order_Type__c == Label.Replace_Subscription
                       || ((quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.Renew_Subscription) 
                            && item.BigMachines__Product__r.New_Category__c == 'Hardware' && item.Quantity_Change__c > 0)))) 
                i.IsShippable = true;
        } 
        //Added By Ranjith on May 31, 2017 -- Ends
        
        if (i.IsShippable == false) {
            OrderHasNonShippableParts = true;
        } else {
            OrderIsAllNonShippableParts = false;
        }
        //i.OrderableStartDate = item.Orderable_Start_Date__c;
        //i.OrderableEndDate = item.Orderable_End_Date__c;
        i.unallocated = i.IsShippable ? i.quantity : 0;
        i.allocation = new list<OrderingUIClasses.lineitemAllocation>();
        if (i.IsShippable) {
            system.debug('######entered');
            integer x = 1;
            Map<Decimal, Decimal> allocMap = new Map<Decimal, Decimal>();
            Map<Id, Decimal> map_ShipLocToSortOrder = new Map<Id, Decimal>(); //Added By Ranjith on Jul 13, 2017 
            for (Order_Line_Item_Allocation__c olia : item.Order_Line_Item_Allocations__r) {
               allocMap.put(olia.Order_Shipping_Location__r.Sort_Order__c, olia.Quantity__c);
               //Added By Ranjith on Jul 13, 2017 -- Starts
               map_ShipLocToSortOrder.put(olia.Order_Shipping_Location__c, olia.Order_Shipping_Location__r.Sort_Order__c);
               if(olia.Order_Shipping_Location__r.Sort_Order__c > x) {
                   x = Integer.valueOf(olia.Order_Shipping_Location__r.Sort_Order__c);
               }
               //Added By Ranjith on Jul 13, 2017 -- Ends
            }
            shippingLocationCount = selectedLocations.size();

            for (OrderingUIClasses.ShippingLocation s : selectedLocations) {
                OrderingUIClasses.LineItemAllocation ia = new OrderingUIClasses.LineItemAllocation();
                //Added By Ranjith on Jul 13, 2017 -- Starts
                if(map_ShipLocToSortOrder.containsKey(s.AddressId)) {
                    ia.Location = Integer.valueOf(map_ShipLocToSortOrder.get(s.AddressId));
                }
                else {
                //Added By Ranjith on Jul 13, 2017 -- Ends
                    ia.Location = x++;
                }//Added By Ranjith on Jul 13, 2017
                if (shippingLocationCount == 1) {
                    ia.Quantity = i.Quantity;
                } else {
                    if (allocMap.containsKey(ia.Location)) {
                        ia.Quantity = Integer.valueOf(allocMap.get(ia.Location));                     
                    } else {
                        ia.Quantity = 0;
                    }
                }
                i.allocation.add(ia);
            }
            if (i.allocation.size() == 1) {
            }
        }
        System.debug('#####i.allocation.size()'+ i.allocation.size());
        System.debug(LoggingLevel.Error,'-BuildLineitem2-'+ i);
        return i;
    }
    public OrderingUIClasses.LineItem BuildLineitem(order_line_item__c item) {
        System.debug(LoggingLevel.Error,'-BuildLineitem-');
        OrderingUIClasses.LineItem i = new OrderingUIClasses.LineItem();
        i.id = item.id;
        i.isOrderLine = true;
        i.parentId = item.Order__c;
        //i.PartNumber = item.part_number__c;
        i.ListPrice = item.List_Price__c;
        i.SalesPrice = item.Sales_Price__c;
        ///i.MSRP = item.MSRP__c;
        //i.PartName = item.full_part_name__c;
        i.Quantity = Integer.valueOf(item.quantity__c);
        //Added By Ranjith on May 31, 2017 -- Starts
        //if (item.Product__r.Type__c == 'Product - Hardware') {
        if(item.Product__r.ProductShippable__c=='Yes') {
        //Added By Ranjith on May 31, 2017 -- Ends
            i.IsShippable = true;
        } else {
            i.IsShippable = false;
        }
        //if (i.IsShippable == false) {
        if (i.IsShippable) {
            OrderHasNonShippableParts = true;
        } else {
            OrderIsAllNonShippableParts = false;
        }
        //i.OrderableStartDate = item.Orderable_Start_Date__c;
        //i.OrderableEndDate = item.Orderable_End_Date__c;
        i.unallocated = i.IsShippable ? i.quantity : 0;
        i.allocation = new list<OrderingUIClasses.lineitemAllocation>();
        if (i.IsShippable) {
            integer x = 1;
            Map<Decimal, Decimal> allocMap = new Map<Decimal, Decimal>();
            for (Order_Line_Item_Allocation__c olia : item.Order_Line_Item_Allocations__r) {
                allocMap.put(olia.Order_Shipping_Location__r.Sort_Order__c, olia.Quantity__c);
            }
            shippingLocationCount = selectedLocations.size();

            for (OrderingUIClasses.ShippingLocation s : selectedLocations) {
                OrderingUIClasses.LineItemAllocation ia = new OrderingUIClasses.LineItemAllocation();
                ia.Location = x++;
                if (shippingLocationCount == 1) {
                    ia.Quantity = i.Quantity;
                } else {
                    if (allocMap.containsKey(ia.Location)) {
                        ia.Quantity = Integer.valueOf(allocMap.get(ia.Location));
                    } else {
                        ia.Quantity = 0;
                    }
                }
                i.allocation.add(ia);
            }
            if (i.allocation.size() == 1) {
            }
        }
        System.debug(LoggingLevel.Error,'-Leaving BuildLineitem-'+i);
        return i;
    }
    public boolean ShowAllocation {get;set;}

    public void showShipToSelection() {
        strSubSelectedTab = 'Ship To Selection';
    }
    public PageReference EnterAllocationTab() {
        System.debug(LoggingLevel.Error,'-EnterAllocationTab-');
        ShowAllocation=false;
        BuildListofLineItems();
        SaveOrder();
        ShowAllocation=true;
        return null;
    }
    public PageReference EnterSubmitTab() {
        System.debug(LoggingLevel.Error,'-EnterSubmitTab-');
        strSubSelectedTab = 'Review and Submit';
        //system.debug(' =====> EnterSubmitTab()');
        BuildListofLineItems();
        SaveOrder();
        //CanOrderBeSubmitted = ProcessSubmitValidations();
        //if (String.isNotBlank(order.External_Id__c))
        //{
        //
        //}
        //system.debug(' =====> end EnterSubmitTab()');
        System.debug(LoggingLevel.Error,'Leaving-EnterSubmitTab-');
        return null;
    }
    public PageReference SaveAndClose() {
        //system.debug('SaveAndClose()');
        SaveOrder();
        return new PageReference('/' + quote.Id);
    }
    public PageReference SaveOrder() {
        System.debug(LoggingLevel.Error,'Enter-SaveOrder-');

        System.debug('SaveOrder()');
        if (orderExists == false)
        {
            //insert order;
            orderExists=true;
        }
        try
        {
            boolean saved = SetAndSaveOrder();
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,ex.getMessage()) );
            //('Error Saving Order',ex.getMessage() + '\n\n' + ex.getStackTraceString());
        }
        System.debug('end SaveOrder()');
        System.debug(LoggingLevel.Error,'Leaving-SaveOrder-');

        return null;
    }
    // *** Method to return quote object ***
    public BigMachines__Quote__c getQuote(Id quoteId) {
        BigMachines__Quote__c quote = (BigMachines__Quote__c) Database.query(prepareQuoteQuery(quoteId));

        if (String.isBlank(quote.Grid_Group_By__c))
            quote.Grid_Group_By__c = 'Categories';

        return quote;
    }
    public integer shippingLocationCount {
        get {
            return selectedLocations.size(); 
        }
        set;
    }
    public List<OrderingUIClasses.ShippingLocation> getselectedLocations() {
        return selectedLocations;
    }
    // *** Method to generate query string to query Quote from the DB ***
    public String prepareQuoteQuery(Id quoteId) {
        String strQuoteQuery = 'SELECT ';
//Getting all the fields from a field set : field set used to make system more configurable
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_On_Premise.getFields();
        for (Schema.FieldSetMember field : gridFields)
            strQuoteQuery += field.getFieldPath() + ', ';

        strQuoteQuery += 'End_User_ID__r.Country__r.Name, Initial_Subscription_Term__c, End_User_ID__r.Partner_Tier__c, Quote_Cloned_Revised__r.Name,BigMachines__Opportunity__r.Country_Sub_Region__c,Sold_To_Name__r.Country__r.PSRDP_Region__c,PPU_Rental__c,BigMachines__Opportunity__r.Type,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Direct_Sales__c,BigMachines__Opportunity__r.Country_Region__c,Sold_To_Name__r.Country__r.Name,Deal_Qualification__c,BigMachines__Opportunity__r.Country__c,BigMachines__Opportunity__r.Country__r.Name,';
        strQuoteQuery += 'BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country_DAP__c, BigMachines__Opportunity__r.New_DAP_Region__c, X3rd_Party_Override__c,Sold_To_Name__r.Partner_Tier__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country__r.Old_Price_Book__c, Override_Training_Unit__c, Pass_Through__c,Do_Not_Group_Output_By_Taxonomy_Category__c,';
        strQuoteQuery += 'Support_Owner__c, Comment__c, BigMachines__Opportunity__r.Account.Partner_Tier__c, Require_Separate_Quote_for_Genesys_Care__c, Shipping_Handling__c FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
        return strQuoteQuery;
    }
//Praveen

}