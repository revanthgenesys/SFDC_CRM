public class OrderAddressCloudController 
{
    // Addresses Selected by Users
    public  List<Account_Order_Address__c> list_AddressesSelected {get; set;}
    // To indicate if there are addresses already selected or not
    public Boolean blnShowAddress {get; set;}
    // To indicate that new address UI needs to be shown
    public Boolean blnShowCreateNewPopupFlag {get; set;}
    // To indicate whether the quote is an ANZ quote or not
    public Boolean blnIsANZQuote {get; private set;}
    // To show new/edit address in the UI for user entry
    public Account_Order_Address__c objNewOrEditAddress {get; set;}
    // Id of address being edited or deleted
    public Id addressId {get; set;}
    // To indicate if there are existing addresses on Accounts or not
    public Boolean blnShowAccountAddress {get; set;}
    // To indicate if edit and delete option should be shown on selected billing address
    //public Boolean blnShowEditDelete {get; set;}
    // List of addresses available on related accounts
    public List<AcountAddressWrapper> list_AccountAddresses {get; set;}   
    // Id of Quote
    private String strQuoteId;
    // Stores account ids of accounts related to the quote
    Set<Id> set_AccountIds = new Set<Id>();
    
    // Wrapper for Address object
    public class AcountAddressWrapper
    {
        public Boolean blnIsChecked {get; set;}
        public Boolean blnIsEditable {get; set;}
        public Address__c objAddress {get; set;}      
    }
    
    // *** Constructor ***
    public OrderAddressCloudController()
    {       
        strQuoteId = Apexpages.currentPage().getParameters().get('id');
        blnIsANZQuote = false;
        //blnShowEditDelete = true;
        BigMachines__Quote__c objQuote;
        
        
        List<BigMachines__Quote__c> list_Quote = [SELECT BigMachines__Status__c,End_User_ID__c, Sold_To_Name__c,BigMachines__Opportunity__r.Sold_To_Country__r.RU__c
                                                  FROM BigMachines__Quote__c WHERE Id = :strQuoteId];
        if(!list_Quote.isEmpty())
        {
           objQuote = list_Quote[0];
           //Anju April 24 - commenting below part as BE tool now available for APAC
           //blnIsANZQuote = objQuote.BigMachines__Opportunity__r.Sold_To_Country__r.RU__c == 'ANZ' ? true:false;
        }  
        else
            return;
            
        if(objQuote.End_User_ID__c != null)
            set_AccountIds.add(objQuote.End_User_ID__c);
        
        if(objQuote.Sold_To_Name__c != null)
            set_AccountIds.add(objQuote.Sold_To_Name__c);
        
        /*if(objQuote.BigMachines__Status__c == 'Order Submitted')
            blnShowEditDelete = false;*/
    
        // populate addresses already selected on quote
        populateSelectedAddresses();
        
        // populate all related account addresses
        populateAccountAddresses();      
    }
    
    public Boolean getBlnShowEditDelete()
    {
        String strQuoteStatus = [SELECT BigMachines__Status__c FROM BigMachines__Quote__c WHERE Id = :strQuoteId].BigMachines__Status__c;
        if(strQuoteStatus == 'Order Submitted')
            return false;
        return true;
    }
    
    // *** Method to populate addresses already selected on quote ***
    private void populateSelectedAddresses()
    {
        blnShowAddress = false;
        list_AddressesSelected = [SELECT Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c,
                        Zip_Code__c, Phone__c, Fax__c, Email__c, Additional_Emails__c,Attention_To__c FROM Account_Order_Address__c WHERE Quote__c = :strQuoteId];

        if(!list_AddressesSelected.isEmpty())
            blnShowAddress = true;    
    }
    
    // *** Method to populate addresses available on related Accounts ***
    private void populateAccountAddresses()
    {
        blnShowAccountAddress = false;
        list_AccountAddresses = new List<AcountAddressWrapper>();
        for(Address__c objAddress :[SELECT Account__c, Address_Line_1__c, Address_Line_2__c, Address_Name__c, 
                                    Type__c, City__c, Country__c, State__c, Account__r.Name, Zipcode__c,Address_Type__c 
                                    FROM Address__c 
                                    WHERE Account__c IN :set_AccountIds
                                    ORDER BY CreatedDate Desc Limit 200])
        {
            AcountAddressWrapper objAccountAddress = new AcountAddressWrapper();
            objAccountAddress.objAddress = objAddress;
            objAccountAddress.blnIsChecked = false;
            objAccountAddress.blnIsEditable = false;
            list_AccountAddresses.add(objAccountAddress);
        }
        if(!list_AccountAddresses.isEmpty())
            blnShowAccountAddress = true;    
    }
    
    // *** Method to add address to quote : Handler for 'Add Selected' button ***
    public void addSelected()
    {
        try
        {
            
            //Anju Jan 2018 -- Ship to added for PureSuccess
            Set<String> setExistingtypes = new Set<String>();
            for(Account_Order_Address__c address : list_AddressesSelected)
            {
                setExistingtypes.add(address.Address_Type__c);
                
            }
            /*if(!list_AddressesSelected.isEmpty())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Billing Address is already added, if you wish to replace then please delete existing one.'));
                return;
            }
            */
            
            Integer intNumberOfSelected = 0;       
            List<Account_Order_Address__c> list_OrderAddressesToBeInserted = new List<Account_Order_Address__c>(); 
            for(AcountAddressWrapper objAccountAddress : list_AccountAddresses)
            {
                if(objAccountAddress.blnIsChecked)
                {
                    intNumberOfSelected++;
                    
                    /*if(intNumberOfSelected > 2)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select only two address.'));
                        return;
                    }*/
                    
                    if(setExistingtypes.contains(objAccountAddress.objAddress.Address_Type__c)){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, objAccountAddress.objAddress.Address_Type__c + ' address is already added, if you wish to replace then please delete existing one.'));
                            return;                     
                    }
                    
                    Account_Order_Address__c objNewAddress = new Account_Order_Address__c(Quote__c = strQuoteId);
                    objNewAddress.Account__c = objAccountAddress.objAddress.Account__c;
                    objNewAddress.Address__c = objAccountAddress.objAddress.Address_Line_1__c;
                    objNewAddress.Address2__c = objAccountAddress.objAddress.Address_Line_2__c;
                    objNewAddress.Address_Type__c = objAccountAddress.objAddress.Address_Type__c;
                    objNewAddress.City__c = objAccountAddress.objAddress.City__c;
                    objNewAddress.Country__c = objAccountAddress.objAddress.Country__c;
                    objNewAddress.State__c = objAccountAddress.objAddress.State__c;
                    objNewAddress.Zip_Code__c = objAccountAddress.objAddress.Zipcode__c;
                    list_OrderAddressesToBeInserted.add(objNewAddress);
                    objAccountAddress.blnIsEditable = objAccountAddress.blnIsChecked = false;
                }
            }
            if(intNumberOfSelected == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select an address.'));
                return;
            }
            insert list_OrderAddressesToBeInserted;
            populateSelectedAddresses();
            populateAccountAddresses();
        }   
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));  
        }
    }
    
    // *** Method to update selected addresses : Handler for 'Save' button ***
    public void save()
    {
        try
        {
            update list_AddressesSelected;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    // *** Handler for 'Edit' button for selected address ***
    public void editAddress()
    {      
        objNewOrEditAddress = [SELECT Id,Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, 
                            Email__c,Additional_Emails__c,Attention_To__c FROM Account_Order_Address__c WHERE id =: addressId LIMIT 1]; 
        blnShowCreateNewPopupFlag = true;
    }
    
    // *** Handler for 'Delete' button for selected address ***
    public void deleteAddress()
    {
        try
        {
            objNewOrEditAddress = new Account_Order_Address__c(id = addressId);
            delete objNewOrEditAddress;
            populateSelectedAddresses();
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    // *** Handler for 'Create New Address' button ***
    public void showCreateNewPopup()
    {   
        addressId = null; 
        blnShowCreateNewPopupFlag = true;
        objNewOrEditAddress = new Account_Order_Address__c(Quote__c = strQuoteId,Address_Type__c = 'Bill To');
    }
    
    // *** Handler for 'Cancel' button on new/edit address ***
    public void hideCreateNewPopup()
    {       
        blnShowCreateNewPopupFlag = false;
    }
    
    // *** Handler for 'Save' button on new/edit address pop-up. ***
    public void createNewAddress()
    {
        try
        {
            if(!list_AddressesSelected.isEmpty() && objNewOrEditAddress.Id == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Billing Address is already added, if you wish to replace then please delete existing one.'));
                return;
            }
            upsert objNewOrEditAddress;
            populateSelectedAddresses();
            blnShowCreateNewPopupFlag = false;         
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    // *** Method to make Address Type selectable when an address is selected. ***
    public void makeAddressTypeEditable()
    {
        for(AcountAddressWrapper objAccountAddress : list_AccountAddresses)
        {
            if(objAccountAddress.blnIsChecked)
                objAccountAddress.blnIsEditable = true; 
            else
                objAccountAddress.blnIsEditable = false;
        }
    }
    
    // *** Method to validate whether bill To address has been added or not. ***
    public static String validateOrderSubmission(BigMachines__Quote__c Quote)
    {
        List<Account_Order_Address__c> list_QuoteAddresses = [SELECT Address_Type__c FROM Account_Order_Address__c WHERE Quote__c = :Quote.id];
        String returnStr = 'OK';
        Set<String> setAllTypes = new Set<String>();
        
        for(Account_Order_Address__c address : list_QuoteAddresses)
        {
            setAllTypes.add(address.Address_Type__c);         
        
        }
        String missingAddressTypes = '';
        if(!setAllTypes.contains('Bill To'))
            missingAddressTypes += 'Bill To, ';          
        
        if(quote.Offering_Type__c == 'Business Edition' && (quote.PureSuccess__c != null || (quote.Does_customer_currently_have_PureSuccess__c && quote.A_La_Carte_PureSuccess_Services_Amount__c > 0)))
        {
            if(!setAllTypes.contains('End User'))
                missingAddressTypes += 'End User, ';
            if(!setAllTypes.contains('Ship To'))
                missingAddressTypes += 'Ship To, ';
            if(!setAllTypes.contains('Sold To'))
                missingAddressTypes += 'Sold To, ';
            
        }
        if(!String.isBlank(missingAddressTypes)) {   
            missingAddressTypes = missingAddressTypes.substring(0, missingAddressTypes.lastIndexOf(','));
            String es = '';
            if(missingAddressTypes.indexOf(',') != -1){             
                String str = missingAddressTypes.substring(missingAddressTypes.lastIndexOf(','), missingAddressTypes.length());
                str = str.replace(',', 'and');
                missingAddressTypes = missingAddressTypes.substring(0, missingAddressTypes.lastIndexOf(','));
                missingAddressTypes += ' ' + str;
                es = 'es';              
            }
            returnStr = 'Please add ' + missingAddressTypes + ' address' + es + '.';
                       
        }
        //PureSuccess Anju Jan 2018 ends
        
        return returnStr;
    }
}