public without sharing class OrderAddressPureCloudController {
    
    //Initialize variables
    public List<Account_Order_Address__c> orderAddressOnOrder { get; set; }
    public List<WrapperAcountAddress> accountAddresses { get; set; }
    public Account_Order_Address__c newAddress { get; set; }
    public Boolean showOrderAddress { get; set; }
    public Boolean showCreateNewPopupFlag { get; set; }  
    public Boolean showAccountAddress { get; set; }  
    public Id addressId { get; set; }
    public String popupTitle { get; set; }
    public List<SelectOption> addressTypes { get; set; }
          
    public Set<String> orderAddressTypes;
    private Set<String> uniqueAddresses;
    private String quoteId;
    
    //*** Constructor method to initiate varaibles ***
    public OrderAddressPureCloudController(){        
        init(); 
    }
    
    //*** Constructor method to initiate varaibles and pull required addresses ***
    private void init() {
        Set<Id> accountIds = new Set<Id>();
        addressTypes = getAddressTypes();
        
        accountAddresses = new List<WrapperAcountAddress>();
        showOrderAddress = false;       
        showAccountAddress = false;
        
        quoteId = Apexpages.currentPage().getParameters().get('id');
        zqu__Quote__c quote = [SELECT zqu__Account__c, zqu__Opportunity__r.BusinessPartner__c
                               FROM zqu__Quote__c 
                               WHERE Id =: quoteId];        
        accountIds.add(quote.zqu__Account__c);    
        if(quote.zqu__Opportunity__r.BusinessPartner__c != null) {
            accountIds.add(quote.zqu__Opportunity__r.BusinessPartner__c);
        }       
            
        populateAddresses();
        
        for(Address__c eachAddress :[SELECT Account__c, Address_Line_1__c, Address_Line_2__c, Address_Name__c, Type__c, City__c, 
                                            State__c, Country__c, Account__r.Name, Zipcode__c, Address_Type__c 
                                     FROM Address__c 
                                     WHERE Account__c IN: accountIds]){
            WrapperAcountAddress accountAddress = new WrapperAcountAddress();
            accountAddress.address = eachAddress;
            accountAddress.check = false;
            accountAddress.isEditable = false;
            accountAddress.recordId = eachAddress.id;
            accountAddresses.add(accountAddress);
        }
        if(!accountAddresses.isEmpty())
            showAccountAddress = true;
        //Also add new addresses which user created to available addresses list
        for(Account_Order_Address__c eachAddress : [SELECT Address_Type__c, Address__c, Address2__c, City__c,
                                                           State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c 
                                                    FROM Account_Order_Address__c 
                                                    WHERE Zuora_Quote__c =: quoteId 
                                                      AND New__c = true 
                                                    ORDER BY Address_Type__c]){
            //Creating temp account record
            Address__c newAddress = new Address__c();
            newAddress.Type__c = eachAddress.Address_Type__c;
            newAddress.Address_Type__c = eachAddress.Address_Type__c;
            newAddress.Address_Line_1__c = eachAddress.Address__c;
            newAddress.Address_Line_2__c = eachAddress.Address2__c;
            newAddress.City__c = eachAddress.City__c;
            newAddress.State__c = eachAddress.State__c;                        
            newAddress.Country__c = eachAddress.Country__c;
            newAddress.Zipcode__c = eachAddress.Zip_Code__c;

            WrapperAcountAddress accountAddress = new WrapperAcountAddress();
            accountAddress.address = newAddress;
            accountAddress.check = false;
            accountAddress.isEditable = false;
            accountAddress.recordId = eachAddress.id;
            accountAddresses.add(accountAddress);            
        }
    }
    
    //*** Method to add selected address to account order addresses
    public void addSelected() {
        try {
            Boolean throwValidation = false;         
            List<Account_Order_Address__c> orderAddressesToBeInserted = new List<Account_Order_Address__c>(); 
            for(WrapperAcountAddress eachAccountAddress : accountAddresses){
                if(eachAccountAddress.check) {
                    if(eachAccountAddress.address.Type__c != 'Ship To' && orderAddressTypes.contains(eachAccountAddress.address.Type__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, eachAccountAddress.address.Type__c + ' address is already added, if you wish to replace then please delete existing one.'));
                        throwValidation = true;
                        break;                      
                    }
                    Account_Order_Address__c newAddress = new Account_Order_Address__c(Zuora_Quote__c = quoteId);
                    newAddress.Account__c = eachAccountAddress.address.Account__c;
                    newAddress.Address__c = eachAccountAddress.address.Address_Line_1__c;
                    newAddress.Address2__c = eachAccountAddress.address.Address_Line_2__c;
                    newAddress.Address_Type__c = eachAccountAddress.address.Type__c;
                    newAddress.City__c = eachAccountAddress.address.City__c;
                    newAddress.Country__c = eachAccountAddress.address.Country__c;
                    newAddress.State__c = eachAccountAddress.address.State__c;
                    newAddress.Zip_Code__c = eachAccountAddress.address.Zipcode__c;
                    orderAddressesToBeInserted.add(newAddress);
                    eachAccountAddress.isEditable = false;
                    eachAccountAddress.check = false;
                }
            }
            if(!throwValidation) {
                insert orderAddressesToBeInserted;
                populateAddresses();
            }   
        }   
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
        }
    }
    //*** Method to save account order address ***
    public void save() {
        try {
            update orderAddressOnOrder;
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        init();
    }
    //*** Method to edit account order address ***
    public void editAddress() {      
        popupTitle = 'Edit Address';
        newAddress = [SELECT Address_Type__c, Address__c, Address2__c, City__c,
                             State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c 
                      FROM Account_Order_Address__c 
                      WHERE Id =: addressId LIMIT 1]; 
        showCreateNewPopupFlag = true;
    }
    //*** Method to delete account order address ***
    public void deleteAddress() {
        try {
            newAddress = new Account_Order_Address__c(Id = addressId);
            delete newAddress;
            populateAddresses();
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    //*** Method to populate account order addresses ***
    private void populateAddresses() {
        orderAddressTypes = new Set<String>();
        uniqueAddresses = new Set<String>();
        orderAddressOnOrder = [SELECT Address_Type__c, Address__c, Address2__c, City__c,
                                      State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c 
                               FROM Account_Order_Address__c 
                               WHERE Zuora_Quote__c =: quoteId 
                                 AND Order__r.Original_Parent_Order1__c = null
                               ORDER BY Address_Type__c];
        for(Account_Order_Address__c eachAddress : orderAddressOnOrder){
            orderAddressTypes.add(eachAddress.Address_Type__c);
            String key = (eachAddress.Address__c == null ? '' : eachAddress.Address__c) + (eachAddress.Zip_Code__c == null ? '' : eachAddress.Zip_Code__c);
            key = key.replace(' ', '').replace(',','').toLowerCase();
            uniqueAddresses.add(key);
        }
        if(!orderAddressOnOrder.isEmpty())
            showOrderAddress = true;    
    }
    //*** Method to show pop up for creating new address ***
    public void showCreateNewPopup() {   
        addressId = null;
        popupTitle = 'New Address';     
        showCreateNewPopupFlag = true;
        newAddress = new Account_Order_Address__c(Zuora_Quote__c = quoteId, New__c = true);
    }
    //*** Method to hide pop up for creating new address ***
    public void hideCreateNewPopup() {       
        showCreateNewPopupFlag = false;
    }
    //*** Method to create new address ***
    public void createNewAddress() {
        try {
            String key = (newAddress.Address__c == null ? '' : newAddress.Address__c) + (newAddress.Zip_Code__c == null ? '' : newAddress.Zip_Code__c);
            key = key.replace(' ', '').replace(',','').toLowerCase();
            if(addressId == null && newAddress.Address_Type__c != 'Ship To' && orderAddressTypes.contains(newAddress.Address_Type__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, newAddress.Address_Type__c + ' address is already added, if you wish to replace then please delete existing one.'));
            }
            /*else if(addressId == null && uniqueAddresses.contains(key)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not enter duplicate address.'));
            }*/
            else {
                upsert newAddress;
                init();
            }
            showCreateNewPopupFlag = false;         
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        } 
    }
    //*** Method to change address type field into editable mode ***
    public void makeAddressTypeEditable() {
        for(WrapperAcountAddress eachAccountAddress : accountAddresses) {
            if(eachAccountAddress.check) {
                eachAccountAddress.isEditable = true;
            }   
            else {
                eachAccountAddress.isEditable = false;
            }
        }
    }
    
  /*  Commented by Ranjith on May 12
      public static void populateAddressOnOrder(Id quoteId, Id orderId){
        
        List<Account_Order_Address__c> quoteAddressOnOrder = [SELECT Address_Type__c, Address__c, Address2__c, City__c,
                State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c FROM Account_Order_Address__c 
                WHERE Zuora_Quote__c =: quoteId ORDER BY Address_Type__c];
        List<Account_Order_Address__c> orderAddressToBeInserted = new List<Account_Order_Address__c>(); 
        for(Account_Order_Address__c eachAddress : quoteAddressOnOrder){
            Account_Order_Address__c newAddress = new Account_Order_Address__c(Order__c = orderId);
            newAddress.Address_Type__c = eachAddress.Address_Type__c;
            newAddress.Address__c = eachAddress.Address__c;
            newAddress.Address2__c = eachAddress.Address2__c;
            newAddress.City__c = eachAddress.City__c;
            newAddress.State__c = eachAddress.State__c;
            newAddress.Country__c = eachAddress.Country__c;
            newAddress.Zip_Code__c = eachAddress.Zip_Code__c;
            newAddress.Phone__c = eachAddress.Phone__c;
            newAddress.Fax__c = eachAddress.Fax__c;
            newAddress.Email__c = eachAddress.Email__c;
            orderAddressToBeInserted.add(newAddress);
        }       
        if(!orderAddressToBeInserted.isEmpty())
            insert orderAddressToBeInserted;
    }*/
    //*** Method to validate addresses before submitting order ***
    public static String validateOrderSubmission(Id quoteId) {
        List<Account_Order_Address__c> orderAddressOnOrder = [SELECT Address_Type__c 
                                                              FROM Account_Order_Address__c 
                                                              WHERE Zuora_Quote__c =: quoteId 
                                                                AND Order__r.Original_Parent_Order1__c = null 
                                                              ORDER BY Address_Type__c];
        Integer intShippableProductsCount = [SELECT count()  
                                             FROM zqu__QuoteChargeDetail__c
                                             WHERE zqu__Quote__c =: quoteId
                                               AND zqu__ProductRatePlan__r.zqu__Product__r.ProductShippable__c='Yes'];
        
        String returnStr = 'OK';   
        Set<String> addressTypes = new Set<String>();
        for(Account_Order_Address__c eachAOA : orderAddressOnOrder) {
            addressTypes.add(eachAOA.Address_Type__c);
        }   
        String missingAddressTypes = '';
        if(!addressTypes.contains('Bill To')) {
            missingAddressTypes += 'Bill To, ';
        }
        if(!addressTypes.contains('End User')){
            missingAddressTypes += 'End User, ';
        }
        if(intShippableProductsCount > 0 && !addressTypes.contains('Ship To')) {
            missingAddressTypes += 'Ship To, ';
        }
        if(!addressTypes.contains('Sold To')) {
            missingAddressTypes += 'Sold To, ';
        }  
        if(!String.isBlank(missingAddressTypes)) {   
            missingAddressTypes = missingAddressTypes.substring(0, missingAddressTypes.lastIndexOf(','));
            String es = '';
            if(missingAddressTypes.indexOf(',') != -1) {             
                String str = missingAddressTypes.substring(missingAddressTypes.lastIndexOf(','), missingAddressTypes.length());
                str = str.replace(',', 'and');
                missingAddressTypes = missingAddressTypes.substring(0, missingAddressTypes.lastIndexOf(','));
                missingAddressTypes += ' ' + str;
                es = 'es';              
            }
            returnStr = 'Please add ' + missingAddressTypes + ' address' + es + '.';
        }
        return returnStr;
    }
    
    private List<SelectOption> getAddressTypes() {
        List<SelectOption> options = new List<SelectOption>();            
        Schema.DescribeFieldResult fieldResult = Account_Order_Address__c.Address_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            if(f.getLabel() == 'Bill To' || f.getLabel() == 'Sold To' || f.getLabel() == 'End User')
                options.add(new SelectOption(f.getLabel(), f.getValue()));            
        }       
        return options;    
    }
    
    //*** Wrapper class to store account address ***
    public class WrapperAcountAddress{
        public Boolean check { get; set; }
        public Id recordId { get; set; }
        public Boolean isEditable { get; set; }
        public Address__c address { get; set; }       
    }
}