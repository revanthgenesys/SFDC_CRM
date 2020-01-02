/************************************************************************************
Purpose : Controller class to handle account order address and line item allocation for orders
Written By : Ranjith Punneli
Test Classes : OrderSubmissionControllerTest
*************************************************************************************/

public without sharing class OrderSubmissionController {
    
    public BigMachines__Quote__c objQuote { get; set; }
    public Account_Order_Address__c objNewAddress { get; set; }
    
    public Id selectedAddressId { get; set; }
    public Id allocationErrorProdId { get; set; }
    
    public String strInputShippingMethod { get; set; }
    public String strInputShippingInstructions { get; set; }    
    public String popupTitle { get; set; }
    
    public Boolean blnHasOrderAddress { get; set; }
    public Boolean blnDisplayAddressPopUp { get; set; }
    public Boolean blnAllocationSave { get; set; }

    //Mukunth added on 12-APR-2019
    public string shipToAddrId{get;set;}
    public boolean setTrueOrFalse{get;set;}
        
    public Date dateInputNeedByDate { get; set; }
    
    public Set<String> set_OrderAddressTypes { get; set; }
    public Set<String> set_uniqueShipToAddr { get; set; }
    public Set<Id> set_ShipToAddrIdsWithShipMethod { get; set; }
    public List<Account_Order_Address__c> list_OrderAddresses { get; set; }
    public List<BigMachines__Quote_Product__c> list_ShippableProducts { get; set; }
    public List<BigMachines__Quote_Product__c> list_NonShippableProducts { get; set; }
    public List<WrapperAcountAddress> list_AccountAddresses { get; set; }     
    public Map<Id, Account_Order_Address__c> map_ShipToAddresses { get; set; }
    public Map<Id, Account_Order_Address__c> map_AllOrderAddresses { get; set; } 
    public Map<String, Order_Line_Item_Allocation__c> map_OrdLnItmAllocations { get; set; }
    public Map<Id, Integer> map_ProdUnallocatedQty { get; set; }

    String strQuoteId = '';
    String strNone = '--None--';
    Set<String> set_ExisitngOLIs = new Set<String>();
    Map<Id, Account_Order_Address__c> map_ShipToAddrIdsWithShipMethod = new Map<Id, Account_Order_Address__c>();
    Map<Id, Integer> map_TotalQuantity = new Map<Id, Integer>();
    Map<Id, Id> map_QuoteProductToProduct = new Map<Id, Id>();
    
    public OrderSubmissionController(ApexPages.StandardController controller){
        initializeVariables();
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        objQuote = getQuote(strQuoteId);
        findShippableProducts();
        getAccountAddresses();
        getOrderAddresses();    
        buildUnallocatedQty();   
        createOLIsForMissingProducts(); 
    }
    
    public OrderSubmissionController(){
        initializeVariables();
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        objQuote = getQuote(strQuoteId);
        findShippableProducts();
        getAccountAddresses();
        getOrderAddresses();    
        buildUnallocatedQty();   
        createOLIsForMissingProducts(); 
    }
    
    private void findShippableProducts() {
               
        list_ShippableProducts = new List<BigMachines__Quote_Product__c>();
        list_NonShippableProducts = new List<BigMachines__Quote_Product__c>();
        
        for(BigMachines__Quote_Product__c objQP : [SELECT Id, Name, BigMachines__Product__c, BigMachines__Product__r.APN_Number__c, BigMachines__Product__r.New_Category__c,
                                                          BigMachines__Product__r.Name, BigMachines__Product__r.ProductShippable__c, Quantity__c, Quantity_Change__c                   
                                                   FROM BigMachines__Quote_Product__c
                                                   WHERE BigMachines__Quote__c = :objQuote.Id
                                                     AND Hide_Record__c = false
                                                   ORDER BY Sort_Order__c]) { 
            
            if(objQP.BigMachines__Product__r.ProductShippable__c == 'Yes' 
               && objQP.BigMachines__Product__r.New_Category__c == 'Hardware') {
                Decimal decQty = (objQuote.Order_Type__c == Label.New_Subscription || objQuote.Order_Type__c == Label.Replace_Subscription) ? objQP.Quantity__c : 
                                    objQP.Quantity_Change__c > 0 ? objQP.Quantity_Change__c : 0;
                list_ShippableProducts.add(objQP);
                map_ProdUnallocatedQty.put(objQP.Id, Integer.valueOf(decQty));  
                map_TotalQuantity.put(objQP.Id, Integer.valueOf(decQty));             
            }
            else {
                list_NonShippableProducts.add(objQP);                 
            }
            
            map_QuoteProductToProduct.put(objQP.Id, objQP.BigMachines__Product__c);
        }
        System.debug('#####map_ProdUnallocatedQty: '+ map_ProdUnallocatedQty);
    }
    
    private void getAccountAddresses() {
        Set<Id> set_AccountIds = new Set<Id>();
        Set<String> set_UniqueAccountAddresses = new Set<String>();
        list_AccountAddresses = new List<WrapperAcountAddress>();
        
        if(objQuote.End_User_ID__c != null)
            set_AccountIds.add(objQuote.End_User_ID__c);
        if(objQuote.Sold_To_Name__c != null)
            set_AccountIds.add(objQuote.Sold_To_Name__c);
            
        for(Address__c objAddress :[SELECT Account__c, Address_Line_1__c, Address_Line_2__c, Address_Name__c, Type__c, 
                                           City__c, Country__c, State__c, Account__r.Name, Zipcode__c, Address_Type__c 
                                    FROM Address__c 
                                    WHERE Account__c IN: set_AccountIds]) {
            String strAddr = !String.isBlank(objAddress.Address_Line_1__c) ? objAddress.Address_Line_1__c.trim().replace(',','').replace('-','') : '';
            strAddr += !String.isBlank(objAddress.Zipcode__c) ? objAddress.Zipcode__c.trim().replace(',','').replace('-','') : '';
                
            if(!set_UniqueAccountAddresses.contains(strAddr)) {            
                WrapperAcountAddress wrpAccountAddress = new WrapperAcountAddress();
                wrpAccountAddress.objAddress = objAddress;
                wrpAccountAddress.blnSelected = false;
                wrpAccountAddress.blnMakeEditable = false;
                wrpAccountAddress.strEmail = '';
                wrpAccountAddress.strAdditionalEmails = '';
                wrpAccountAddress.strShippingMethod = '';                
                list_AccountAddresses.add(wrpAccountAddress);
                set_UniqueAccountAddresses.add(strAddr);
            }
        }
        
        //Also add new addresses which user created to available addresses list
        for(Account_Order_Address__c objOrdAddress : [SELECT Address_Type__c, Address__c, Address2__c, City__c, Shipping_Method_Name__c,
                                                             State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c, Additional_Emails__c
                                                      FROM Account_Order_Address__c 
                                                      WHERE Quote__c =: objQuote.Id AND New__c = true 
                                                      ORDER BY Address_Type__c]){
            //Creating temp account record
            Address__c objAddress = new Address__c();
            objAddress.Type__c = objOrdAddress.Address_Type__c;
            objAddress.Address_Type__c = objOrdAddress.Address_Type__c;
            objAddress.Address_Line_1__c = objOrdAddress.Address__c;
            objAddress.Address_Line_2__c = objOrdAddress.Address2__c;
            objAddress.City__c = objOrdAddress.City__c;
            objAddress.State__c = objOrdAddress.State__c;                        
            objAddress.Country__c = objOrdAddress.Country__c;
            objAddress.Zipcode__c = objOrdAddress.Zip_Code__c;            

            WrapperAcountAddress wrpAccountAddress = new WrapperAcountAddress();
            wrpAccountAddress.objAddress = objAddress;
            wrpAccountAddress.blnSelected = false;
            wrpAccountAddress.blnMakeEditable = false;
            wrpAccountAddress.strEmail = objOrdAddress.Email__c;
            wrpAccountAddress.strAdditionalEmails = objOrdAddress.Additional_Emails__c;
            wrpAccountAddress.strShippingMethod = objOrdAddress.Shipping_Method_Name__c;
            list_AccountAddresses.add(wrpAccountAddress);         
        }
    }
    
    private void getOrderAddresses() {        
        list_OrderAddresses = new List<Account_Order_Address__c>();        
        map_AllOrderAddresses = new Map<Id, Account_Order_Address__c>();
        map_ShipToAddresses = new Map<Id, Account_Order_Address__c>();
        set_OrderAddressTypes = new Set<String>();
        set_uniqueShipToAddr = new Set<String>();
        set_ShipToAddrIdsWithShipMethod = new Set<Id>();        
        
        list_OrderAddresses = [SELECT Address_Type__c, Address__c, Address2__c, City__c, Additional_Emails__c,
                                      State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c,
                                      Order__c, Shipping_Method_Name__c, Need_By_Date__c, Sort_Order__c, 
                                      Shipping_Instructions__c, First_Name__c, Last_Name__c,Primary_Ship_To__c
                               FROM Account_Order_Address__c 
                               WHERE Quote__c =: objQuote.Id ORDER BY Address_Type__c];
        if(list_OrderAddresses.size() > 0) {
            blnHasOrderAddress = true;
        }
        for(Account_Order_Address__c objAOA : list_OrderAddresses) {
            map_AllOrderAddresses.put(objAOA.Id, objAOA);
            set_OrderAddressTypes.add(objAOA.Address_Type__c);
            if(objAOA.Address_Type__c == 'Ship To') {
                map_ShipToAddresses.put(objAOA.Id, objAOA);  
                              
                String strAddr = !String.isBlank(objAOA.Address__c) ? objAOA.Address__c.trim().replace(',','').replace('-','') : '';
                strAddr += !String.isBlank(objAOA.Zip_Code__c) ? objAOA.Zip_Code__c.trim().replace(',','').replace('-','') : '';
                set_uniqueShipToAddr.add(strAddr);
                if(!String.isBlank(objAOA.Shipping_Method_Name__c)) {
                    strAddr += !String.isBlank(objAOA.Shipping_Method_Name__c) ? objAOA.Shipping_Method_Name__c : '';                
                    set_uniqueShipToAddr.add(strAddr);
                    set_ShipToAddrIdsWithShipMethod.add(objAOA.Id);
                    map_ShipToAddrIdsWithShipMethod.put(objAOA.Id, objAOA);
                }
            }
        }
        System.debug('#####set_ShipToAddrIdsWithShipMethod: '+ set_ShipToAddrIdsWithShipMethod);
        System.debug('#####set_uniqueShipToAddr: '+ set_uniqueShipToAddr);        
    }
    
    private void buildUnallocatedQty() {
        map_OrdLnItmAllocations = new Map<String, Order_Line_Item_Allocation__c>();  
        set_ExisitngOLIs = new Set<String>();
        for(Order_Line_Item_Allocation__c objOLIA : [SELECT Id, Order_Shipping_Location__c, Quantity__c, Quote_Product__c, Quote_Product__r.Quantity__c,
                                                            Quote_Product__r.Quantity_Change__c, Order_Shipping_Location__r.Shipping_Method_Name__c
                                                     FROM Order_Line_Item_Allocation__c
                                                     WHERE Order_Shipping_Location__c IN :set_ShipToAddrIdsWithShipMethod]) {
            map_OrdLnItmAllocations.put(
                objOLIA.Order_Shipping_Location__c+';'+objOLIA.Quote_Product__c+';'+objOLIA.Order_Shipping_Location__r.Shipping_Method_Name__c, objOLIA);    
            if(map_ProdUnallocatedQty.containsKey(objOLIA.Quote_Product__c)) {
                map_ProdUnallocatedQty.put(objOLIA.Quote_Product__c, map_ProdUnallocatedQty.get(objOLIA.Quote_Product__c) - Integer.valueOf(objOLIA.Quantity__c));
            }
            else if(objOLIA.Quote_Product__c != null) {
                Decimal decQty = (objQuote.Order_Type__c == Label.New_Subscription || objQuote.Order_Type__c == Label.Replace_Subscription) ? objOLIA.Quote_Product__r.Quantity__c : 
                                    objOLIA.Quote_Product__r.Quantity_Change__c > 0 ? objOLIA.Quote_Product__r.Quantity_Change__c : 0;
                map_ProdUnallocatedQty.put(objOLIA.Quote_Product__c, Integer.valueOf(decQty - objOLIA.Quantity__c));
            }
            set_ExisitngOLIs.add(objOLIA.Order_Shipping_Location__c+';'+objOLIA.Quote_Product__c);
        }
        System.debug('#####map_ProdUnallocatedQty: '+ map_ProdUnallocatedQty);
        System.debug('#####map_OrdLnItmAllocations: '+ map_OrdLnItmAllocations);
        System.debug('#####set_ExisitngOLIs: '+ set_ExisitngOLIs);
    }
    
    private void createOLIsForMissingProducts() {
        if(set_ShipToAddrIdsWithShipMethod.size() > 0) {
            List<Order_Line_Item_Allocation__c> list_NewOLIAs = new List<Order_Line_Item_Allocation__c>();
            for(Id ordAddrId : set_ShipToAddrIdsWithShipMethod) {
                for(BigMachines__Quote_Product__c objQP : list_ShippableProducts) {                    
                    if(!set_ExisitngOLIs.contains(ordAddrId+';'+objQP.Id)) {
                        Order_Line_Item_Allocation__c objNewOLIA = new Order_Line_Item_Allocation__c();
                        objNewOLIA.Quote_Product__c = objQP.Id;
                        objNewOLIA.Quote__c = objquote.Id;
                        objNewOLIA.Order_Shipping_Location__c = ordAddrId;
                        objNewOLIA.Quantity__c = 0;
                        map_OrdLnItmAllocations.put(
                            objNewOLIA.Order_Shipping_Location__c+';'+objNewOLIA.Quote_Product__c+';'+map_ShipToAddrIdsWithShipMethod.get(objNewOLIA.Order_Shipping_Location__c).Shipping_Method_Name__c, objNewOLIA);    
                        if(map_ProdUnallocatedQty.containsKey(objNewOLIA.Quote_Product__c)) {
                            map_ProdUnallocatedQty.put(objNewOLIA.Quote_Product__c, map_ProdUnallocatedQty.get(objNewOLIA.Quote_Product__c) - Integer.valueOf(objNewOLIA.Quantity__c));
                        }
                        else if(objNewOLIA.Quote_Product__c != null) {
                            Decimal decQty = (objQuote.Order_Type__c == Label.New_Subscription || objQuote.Order_Type__c == Label.Replace_Subscription) ? objQP.Quantity__c : 
                                    objQP.Quantity_Change__c > 0 ? objQP.Quantity_Change__c : 0;
                            map_ProdUnallocatedQty.put(objNewOLIA.Quote_Product__c, Integer.valueOf(decQty - objNewOLIA.Quantity__c));
                        }
                    }
                }
            }
        }
        System.debug('#####map_ProdUnallocatedQty: '+ map_ProdUnallocatedQty);
        System.debug('#####map_OrdLnItmAllocations: '+ map_OrdLnItmAllocations);
    }
    
    public void addSelectedAddresses(){
        Boolean blnAllowSave = true;
        Set<String> set_SelectedAddressTypes = new Set<String>();
        List<Account_Order_Address__c> list_ToInsertOrderAddresses = new List<Account_Order_Address__c>(); 
        List<Order_Line_Item_Allocation__c> list_NewOLIAs = new List<Order_Line_Item_Allocation__c>();
        
        for(WrapperAcountAddress wrpAccountAddress : list_AccountAddresses) {
            if(wrpAccountAddress.blnSelected) {
                if(wrpAccountAddress.objAddress.Type__c != 'Ship To') {
                    if(set_OrderAddressTypes.contains(wrpAccountAddress.objAddress.Type__c)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, wrpAccountAddress.objAddress.Type__c + ' address is already added, if you wish to replace then please delete existing one.'));
                        blnAllowSave = false;
                        break;    
                    }
                    if(set_SelectedAddressTypes.contains(wrpAccountAddress.objAddress.Type__c)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, wrpAccountAddress.objAddress.Type__c + ' is selected twice. Please remove one of them and try.'));
                        blnAllowSave = false;
                        break;    
                    }
                    if(wrpAccountAddress.objAddress.Type__c == 'Bill To' && String.isBlank(wrpAccountAddress.strEmail)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide Email for selected Bill To Address'));
                        blnAllowSave = false;   
                        break;             
                    }
                    if(wrpAccountAddress.objAddress.Type__c == 'Activation Email')
                    {
                        if(String.isBlank(wrpAccountAddress.strEmail)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide Email for selected Activation Email'));
                            blnAllowSave = false;   
                            break;
                        }
                        else{
                            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
                            Pattern MyPattern = Pattern.compile(emailRegex);
                            Matcher MyMatcher = MyPattern.matcher(wrpAccountAddress.strEmail);
                            if(!MyMatcher.matches()){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a valid email address.'));
                                blnAllowSave = false;
                                break;
                            }
                        }
                    }
                    /* Added by navaneetha for Order Acknowledgement address mandatory*/
                    if(wrpAccountAddress.objAddress.Type__c == 'Order Acknowledgement')
                    {
                        if(String.isBlank(wrpAccountAddress.strEmail)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide Email for selected Order Acknowledgement'));
                            blnAllowSave = false;   
                            break;
                        }
                        else{
                            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
                            Pattern MyPattern = Pattern.compile(emailRegex);
                            Matcher MyMatcher = MyPattern.matcher(wrpAccountAddress.strEmail);
                            if(!MyMatcher.matches()){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a valid email address.'));
                                blnAllowSave = false;
                                break;
                            }
                        }
                    }
                    set_SelectedAddressTypes.add(wrpAccountAddress.objAddress.Type__c);
                }
                else {             
                    System.debug('$$$$$$$'+set_uniqueShipToAddr);
                    String strAddr = !String.isBlank(wrpAccountAddress.objAddress.Address_Line_1__c) ? wrpAccountAddress.objAddress.Address_Line_1__c.trim().replace(',','').replace('-','') : '';
                    strAddr += !String.isBlank(wrpAccountAddress.objAddress.Zipcode__c) ? wrpAccountAddress.objAddress.Zipcode__c.trim().replace(',','').replace('-','') : '';
                    System.debug('$$$$$$$'+strAddr );            
                    if(set_uniqueShipToAddr.contains(strAddr)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Ship To address already exists. Please add a different address.'));
                        blnAllowSave = false;   
                        break;             
                    }
                    if(wrpAccountAddress.strShippingMethod == strNone || String.isBlank(wrpAccountAddress.strEmail)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide Email and Shipping Method for selected Ship-To Address(es)'));
                        blnAllowSave = false;   
                        break;             
                    }
                }    
                if(blnAllowSave) { 
                    Account_Order_Address__c objNewOrderAddress = new Account_Order_Address__c(Quote__c = objQuote.Id);
                    objNewOrderAddress.Account__c = wrpAccountAddress.objAddress.Account__c;
                    objNewOrderAddress.Address__c = wrpAccountAddress.objAddress.Address_Line_1__c;
                    objNewOrderAddress.Address2__c = wrpAccountAddress.objAddress.Address_Line_2__c;
                    objNewOrderAddress.Address_Type__c = wrpAccountAddress.objAddress.Type__c;
                    objNewOrderAddress.City__c = wrpAccountAddress.objAddress.City__c;
                    objNewOrderAddress.Country__c = wrpAccountAddress.objAddress.Country__c;
                    objNewOrderAddress.State__c = wrpAccountAddress.objAddress.State__c;
                    objNewOrderAddress.Zip_Code__c = wrpAccountAddress.objAddress.Zipcode__c;
                    objNewOrderAddress.Email__c = wrpAccountAddress.strEmail;
                    objNewOrderAddress.Additional_Emails__c = wrpAccountAddress.strAdditionalEmails;
                    objNewOrderAddress.Shipping_Method_Name__c = wrpAccountAddress.strShippingMethod != strNone ? wrpAccountAddress.strShippingMethod : '';
                    list_ToInsertOrderAddresses.add(objNewOrderAddress);              
                }
            }
        }            
        try {    
            if(blnAllowSave && list_ToInsertOrderAddresses.size() > 0) {
                insert list_ToInsertOrderAddresses;
                
                findShippableProducts();                                    
                System.debug('#####list_ShippableProducts'+list_ShippableProducts.size());
                    
                for(Account_Order_Address__c objOrdAddr : list_ToInsertOrderAddresses) {                
                    if(objOrdAddr.Address_Type__c == 'Ship To') { 
                        for(BigMachines__Quote_Product__c objQP : list_ShippableProducts) {
                            Order_Line_Item_Allocation__c objNewOLIA = new Order_Line_Item_Allocation__c();
                            objNewOLIA.Quote_Product__c = objQP.Id;
                            objNewOLIA.Quote__c = objquote.Id;
                            objNewOLIA.Order_Shipping_Location__c = objOrdAddr.Id;
                            objNewOLIA.Quantity__c = 0;
                            list_NewOLIAs.add(objNewOLIA);
                        }
                    }                    
                }
                System.debug('#####list_NewOLIAs'+list_NewOLIAs.size());
                if(list_NewOLIAs.size() > 0) {
                    insert list_NewOLIAs;
                } 
                getAccountAddresses();    
                getOrderAddresses();

                //Mukunth 13-APR-2019
                checkShipToAndSetPrimary();

                buildUnallocatedQty();
                createOLIsForMissingProducts();
                for(WrapperAcountAddress wrpAccountAddress : list_AccountAddresses) {
                    if(wrpAccountAddress.blnSelected) {
                        wrpAccountAddress.blnMakeEditable = false;
                        wrpAccountAddress.blnSelected = false;
                    }
                }
            }    
        }   
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
        }     
    }
    
    public void makeAddressTypeEditable(){
        for(WrapperAcountAddress wrpAccountAddress : list_AccountAddresses) {
            if(wrpAccountAddress.blnSelected) {
                wrpAccountAddress.blnMakeEditable = true;
            }   
            else {
                wrpAccountAddress.blnMakeEditable = false;
            }
        }
    }        
    
    public void createAddress() {        
        Boolean blnAllowSave = true;
        if(objNewAddress.Address_Type__c == 'Activation Email'){
            if(String.isBlank(objNewAddress.Email__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out mandatory fields before proceeding.'));
                blnAllowSave = false;               
            }
            else{
                String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
                Pattern MyPattern = Pattern.compile(emailRegex);
                Matcher MyMatcher = MyPattern.matcher(objNewAddress.Email__c);
                if(!MyMatcher.matches()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a valid email address.'));
                    blnAllowSave = false;
                }
            }
        }
        /* Added by navaneetha for Order Acknowledgement address mandatory*/
        else if(objNewAddress.Address_Type__c == 'Order Acknowledgement'){
            if(String.isBlank(objNewAddress.Email__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out mandatory fields before proceeding.'));
                blnAllowSave = false;               
            }
            else{
                String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
                Pattern MyPattern = Pattern.compile(emailRegex);
                Matcher MyMatcher = MyPattern.matcher(objNewAddress.Email__c);
                if(!MyMatcher.matches()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a valid email address.'));
                    blnAllowSave = false;
                }
            }
             
        }
        
        
        else if(String.isBlank(objNewAddress.Address_Type__c) || String.isBlank(objNewAddress.Address__c) || String.isBlank(objNewAddress.City__c) 
           || String.isBlank(objNewAddress.Country__c) || String.isBlank(objNewAddress.Zip_Code__c) 
           || (objNewAddress.Address_Type__c == 'Ship To' && (String.isBlank(objNewAddress.Email__c) || String.isBlank(objNewAddress.Shipping_Method_Name__c)))
           || (objNewAddress.Address_Type__c == 'Bill To' && String.isBlank(objNewAddress.Email__c))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out mandatory fields before proceeding.'));
            blnAllowSave = false;
        }
        if(objNewAddress.Address_Type__c != 'Ship To') {
            if(selectedAddressId == null  
               && set_OrderAddressTypes.contains(objNewAddress.Address_Type__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, objNewAddress.Address_Type__c + ' address is already added, if you wish to replace then please delete existing one.'));
                blnAllowSave = false;
            }
        }
        else {             
            System.debug('$$$$$$$'+set_uniqueShipToAddr);
            String strAddr = !String.isBlank(objNewAddress.Address__c) ? objNewAddress.Address__c.trim().replace(',','').replace('-','') : '';
            strAddr += !String.isBlank(objNewAddress.Zip_Code__c) ? objNewAddress.Zip_Code__c.trim().replace(',','').replace('-','') : '';
            strAddr += !String.isBlank(objNewAddress.Shipping_Method_Name__c) ? objNewAddress.Shipping_Method_Name__c : '';                
            System.debug('$$$$$$$'+strAddr );            
            if(popUpTitle == 'New Address' && set_uniqueShipToAddr.contains(strAddr)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Ship To address already exists. Please add a different address or change shipping method.'));
                blnAllowSave = false;            
            }
        }
        if(blnAllowSave) {      
            try {
                System.debug('$$$$$$$objNewAddress: '+objNewAddress);
                upsert objNewAddress;
                
                if(popUpTitle == 'New Address' && objNewAddress.Address_Type__c == 'Ship To') {
                    List<Order_Line_Item_Allocation__c> list_NewOLIAs = new List<Order_Line_Item_Allocation__c>();
                    findShippableProducts();                    
                    System.debug('#####list_ShippableProducts'+list_ShippableProducts.size());
                    for(BigMachines__Quote_Product__c objQP : list_ShippableProducts) {
                        Order_Line_Item_Allocation__c objNewOLIA = new Order_Line_Item_Allocation__c();
                        objNewOLIA.Quote_Product__c = objQP.Id;
                        objNewOLIA.Quote__c = objquote.Id;
                        objNewOLIA.Order_Shipping_Location__c = objNewAddress.Id;
                        objNewOLIA.Quantity__c = 0;
                        list_NewOLIAs.add(objNewOLIA);
                    }
                    System.debug('#####list_NewOLIAs'+list_NewOLIAs.size());
                    if(list_NewOLIAs.size() > 0) {
                        insert list_NewOLIAs;
                    }  
                }            
                getAccountAddresses();    
                getOrderAddresses();

                //Mukunth added on 13-APR-2019
                checkShipToAndSetPrimary();

                map_ProdUnallocatedQty = new Map<Id, Integer>();
                buildUnallocatedQty();
                createOLIsForMissingProducts();
                hidePopUp();
            }
            catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
        }
    }
    
    public void deleteAddress(){
        try {
            objNewAddress = new Account_Order_Address__c(Id = selectedAddressId);
            map_ProdUnallocatedQty = new Map<Id, Integer>();
            delete objNewAddress;
            findShippableProducts();
            getOrderAddresses();

            //Mukunth added on 13-APR-2019
            checkShipToAndSetPrimary();

            buildUnallocatedQty();
            createOLIsForMissingProducts();
            hidePopUp();            
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    public void showPopUp() {  
        objNewAddress = new Account_Order_Address__c();
        if(selectedAddressId == null) {
            popUpTitle = 'New Address';
            objNewAddress = new Account_Order_Address__c(Quote__c = objQuote.Id, New__c = true);
        }
        else {
            popUpTitle = 'Edit Address';
            objNewAddress = map_AllOrderAddresses.get(selectedAddressId);
        }
        blnDisplayAddressPopUp = true;
    }
    public void hidePopUp() {   
        objNewAddress = new Account_Order_Address__c();  
        selectedAddressId = null;  
        blnDisplayAddressPopUp = false;
        popUpTitle = 'New Address';
    }
    
    public void updateAllocations() {    
        Boolean blnAllowSave = true;
        blnAllocationSave = true;
        allocationErrorProdId = null;
        Map<Id, Integer> map_CurrentQuantity = new Map<Id, Integer>();
        for(Order_Line_Item_Allocation__c objOLIA : map_OrdLnItmAllocations.values()) {            
            if(map_CurrentQuantity.containsKey(objOLIA.Quote_Product__c)) {
                map_CurrentQuantity.put(objOLIA.Quote_Product__c, map_CurrentQuantity.get(objOLIA.Quote_Product__c) + Integer.valueOf(objOLIA.Quantity__c));
            }
            else if(objOLIA.Quote_Product__c != null) {
                map_CurrentQuantity.put(objOLIA.Quote_Product__c, Integer.valueOf(objOLIA.Quantity__c));
            }
        }
        for(Id qtProdId : map_TotalQuantity.keySet()) {
            if(map_CurrentQuantity.containsKey(qtProdId) 
               && map_CurrentQuantity.get(qtProdId) > map_TotalQuantity.get(qtProdId)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Allocated Quantity cannot exceed the total quantity of a product.')); 
                blnAllocationSave = false; 
                allocationErrorProdId = qtProdId;
                break;
            }
        }
        if(blnAllocationSave) {   
            try {
                System.debug('#####'+map_OrdLnItmAllocations.values());
                upsert map_OrdLnItmAllocations.values();     
                map_ProdUnallocatedQty = new Map<Id, Integer>();           
                buildUnallocatedQty();       
            }
            catch(Exception e) {
                System.debug('#######'+e.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));                
            }
        }
    }
        
    private void initializeVariables() {
        
        selectedAddressId = null;
        allocationErrorProdId = null;
         
        objquote = new BigMachines__Quote__c();
        objNewAddress = new Account_Order_Address__c();
        
        blnAllocationSave = true;
        
        set_OrderAddressTypes = new Set<String>();
        set_uniqueShipToAddr = new Set<String>();
        set_ShipToAddrIdsWithShipMethod = new Set<Id>();
        
        list_OrderAddresses = new List<Account_Order_Address__c>();
        list_AccountAddresses = new List<WrapperAcountAddress>();
        list_ShippableProducts = new List<BigMachines__Quote_Product__c>();
        list_NonShippableProducts = new List<BigMachines__Quote_Product__c>();
        
        map_AllOrderAddresses = new Map<Id, Account_Order_Address__c>();
        map_ShipToAddresses = new Map<Id, Account_Order_Address__c>();
        map_OrdLnItmAllocations = new Map<String, Order_Line_Item_Allocation__c>(); 
        map_ProdUnallocatedQty = new Map<Id, Integer>();
    }
    
    
    // *** Method to return quote object ***
    public BigMachines__Quote__c getQuote(Id quoteId) {
        BigMachines__Quote__c objQuote = (BigMachines__Quote__c) Database.query(prepareQuoteQuery(strQuoteId));
        return objQuote;
    }
    // *** Method to generate query string to query Quote from the DB ***
    public String prepareQuoteQuery(Id quoteId) {
        String strQuoteQuery = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable
        List<Schema.FieldSetMember> list_GridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_On_Premise.getFields();
        for (Schema.FieldSetMember field : list_GridFields)
            strQuoteQuery += field.getFieldPath() + ', ';

        strQuoteQuery += 'End_User_ID__r.Country__r.Name, Initial_Subscription_Term__c, End_User_ID__r.Partner_Tier__c, Quote_Cloned_Revised__r.Name,BigMachines__Opportunity__r.Country_Sub_Region__c,Sold_To_Name__r.Country__r.PSRDP_Region__c,PPU_Rental__c,BigMachines__Opportunity__r.Type,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Direct_Sales__c,BigMachines__Opportunity__r.Country_Region__c,Sold_To_Name__r.Country__r.Name,Deal_Qualification__c,BigMachines__Opportunity__r.Country__c,BigMachines__Opportunity__r.Country__r.Name,';
        strQuoteQuery += 'BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country_DAP__c, BigMachines__Opportunity__r.New_DAP_Region__c, X3rd_Party_Override__c,Sold_To_Name__r.Partner_Tier__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country__r.Old_Price_Book__c, Override_Training_Unit__c, Pass_Through__c,Do_Not_Group_Output_By_Taxonomy_Category__c,';
        strQuoteQuery += 'Support_Owner__c, Comment__c, BigMachines__Opportunity__r.Account.Partner_Tier__c, Require_Separate_Quote_for_Genesys_Care__c, Shipping_Handling__c,Oppty_Lead_Offer__c,Order__c FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
        return strQuoteQuery;
    }
    
    public List<SelectOption> getShippingMethodNames() {
        List<SelectOption> list_Options = new List<SelectOption>();
        Schema.DescribeFieldResult schFieldResult = Account_Order_Address__c.Shipping_Method_Name__c.getDescribe();
        List<Schema.PicklistEntry> list_PLE = schFieldResult.getPicklistValues();            
        list_Options.add(new SelectOption(strNone, strNone ));
        for(Schema.PicklistEntry entry : list_PLE) {
            list_Options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }       
        return list_Options;
    }

    //Mukunth added to set Primary Ship To address on 12-APR-2019 for CCDB req JIRA # CRMBILL-398
    public void changePrimaryShipTo(){
        //integer i=0;
        //if(setTrueOrFalse){
            for(Account_Order_Address__c shipToAddr:map_AllOrderAddresses.values()){
                if(shipToAddr.Address_Type__c == 'Ship To' && shipToAddr.Id != shipToAddrId){
                    shipToAddr.Primary_Ship_To__c = false;
                }
            }
            update map_AllOrderAddresses.values();
    }

    //Mukunth added to on 12-APR-2019 for CCDB req JIRA # CRMBILL-398
    public void checkShipToAndSetPrimary(){
        integer i = 0;
        string shipToMapKey;
        boolean primaryExists;
        for(Account_Order_Address__c shpToRec:map_AllOrderAddresses.values()){
            if(shpToRec.Address_Type__c == 'Ship To'){
                shipToMapKey = shpToRec.Id;
                i++;
            }
        }
        if(i==1){
            map_AllOrderAddresses.get(shipToMapKey).Primary_Ship_To__c = true;
            update map_AllOrderAddresses.get(shipToMapKey);
        }
        //else if(i>0){
        //    for(Account_Order_Address__c eachShipTo:map_AllOrderAddresses.values()){
        //        eachShipTo.Primary_Ship_To__c = false;
        //    }
        //    update map_AllOrderAddresses.values();
        //}
    }
    
    public class WrapperAcountAddress {
        public Boolean blnSelected { get; set; }
        public Boolean blnMakeEditable { get; set; }
        public Address__c objAddress { get; set; }
        public String strEmail { get; set; }
        public String strAdditionalEmails { get; set; }
        public String strShippingMethod { get; set; } 
    }
}