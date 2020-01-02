//Naresh Kumar  08/15/2014
public without sharing class OrderAddressOnPremiseController {
    public  List<Account_Order_Address__c> orderAddressOnOrder {get;set;}
    public Boolean showOrderAddress {get;set;}
    public Boolean showCreateNewPopupFlag {get;set;}
    public Account_Order_Address__c newAddress {get;set;}
    public Id addressId {get;set;}
    public String popupTitle {get;set;}
    public Boolean showAccountAddress {get;set;}
    public List<wrapperAcountAddress> accountAddresses {get;set;}   
    public BigMachines__Quote__c quote {get;set;}  
    public Set<String> orderAddressTypes;
    private Set<String> uniqueAddresses;
    private String quoteId;
    public OrderAddressOnPremiseController(){        
        init();
    }
    
    private void init(){
      quoteId = Apexpages.currentPage().getParameters().get('id');
        quote = [SELECT Bill_To_Name__c, End_User_ID__c, Sold_To_Name__c, System_Integrator__c, Support_Owner__c, Offering_Type__c  
            FROM BigMachines__Quote__c WHERE id =: quoteId];
        Set<Id> accountIds = new Set<Id>();     
        if(quote.Bill_To_Name__c != null)       
            accountIds.add(quote.Bill_To_Name__c);
        if(quote.End_User_ID__c != null)
            accountIds.add(quote.End_User_ID__c);
        if(quote.Sold_To_Name__c != null)
            accountIds.add(quote.Sold_To_Name__c);
        if(quote.System_Integrator__c != null)
            accountIds.add(quote.System_Integrator__c);
        if(quote.Support_Owner__c != null)
            accountIds.add(quote.Support_Owner__c);     
        showOrderAddress = false;       
        showAccountAddress = false;     
        populateAddresses();
      accountAddresses = new List<wrapperAcountAddress>();
        for(Address__c eachAddress :[SELECT Account__c, Address_Line_1__c, Address_Line_2__c, Address_Name__c, Type__c, City__c, Country__c, 
            State__c, Account__r.Name, Zipcode__c, Address_Type__c FROM Address__c WHERE Account__c IN: accountIds]){
            wrapperAcountAddress accountAddress = new wrapperAcountAddress();
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
            State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c FROM Account_Order_Address__c 
            WHERE Quote__c =: quoteId AND New__c = true ORDER BY Address_Type__c]){
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

            wrapperAcountAddress accountAddress = new wrapperAcountAddress();
            accountAddress.address = newAddress;
            accountAddress.check = false;
            accountAddress.isEditable = false;
            accountAddress.recordId = eachAddress.id;
            accountAddresses.add(accountAddress);            
        }
    }
    
    public void addSelected(){
        try{
            Boolean thowValidation = false;         
            List<Account_Order_Address__c> orderAddressesToBeInserted = new List<Account_Order_Address__c>(); 
            for(wrapperAcountAddress eachAccountAddress : accountAddresses){
                if(eachAccountAddress.check){
                    if(eachAccountAddress.address.Type__c != 'Ship To' && orderAddressTypes.contains(eachAccountAddress.address.Type__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, eachAccountAddress.address.Type__c + ' address is already added, if you wish to replace then please delete existing one.'));
                        thowValidation = true;
                        break;                      
                    }
                    Account_Order_Address__c newAddress = new Account_Order_Address__c(Quote__c = quoteId);
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
            if(!thowValidation){
                insert orderAddressesToBeInserted;
                populateAddresses();
            }   
        }   
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));  
        }
    }
    
    public void save(){
        try{
            Database.update(orderAddressOnOrder, false);
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        init();
    }
    
    public void editAddress(){      
        popupTitle = 'Edit Address';
        newAddress = [SELECT Address_Type__c, Address__c, Address2__c, City__c,
                State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c FROM Account_Order_Address__c WHERE id =: addressId LIMIT 1]; 
        showCreateNewPopupFlag = true;
    }
    
    public void deleteAddress(){
        try{
            newAddress = new Account_Order_Address__c(id = addressId);
            delete newAddress;
            populateAddresses();
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    private void populateAddresses(){
        orderAddressTypes = new Set<String>();
        uniqueAddresses = new Set<String>();
        orderAddressOnOrder = [SELECT Address_Type__c, Address__c, Address2__c, City__c,
                State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c FROM Account_Order_Address__c 
                WHERE Quote__c =: quoteId ORDER BY Address_Type__c];
        for(Account_Order_Address__c eachAddress : orderAddressOnOrder){
            orderAddressTypes.add(eachAddress.Address_Type__c);
            String key = (eachAddress.Address__c == null ? '' : eachAddress.Address__c) + (eachAddress.Zip_Code__c == null ? '' : eachAddress.Zip_Code__c);
            key = key.replace(' ', '').replace(',','').toLowerCase();
            uniqueAddresses.add(key);
        }
        if(!orderAddressOnOrder.isEmpty())
            showOrderAddress = true;    
    }
    
    public void showCreateNewPopup(){   
        addressId = null;
        popupTitle = 'New Address';     
        showCreateNewPopupFlag = true;
        newAddress = new Account_Order_Address__c(Quote__c = quoteId, New__c = true);
    }
    public void hideCreateNewPopup(){       
        showCreateNewPopupFlag = false;
    }
    
    public void createNewAddress(){
        try{
            String key = (newAddress.Address__c == null ? '' : newAddress.Address__c) + (newAddress.Zip_Code__c == null ? '' : newAddress.Zip_Code__c);
            key = key.replace(' ', '').replace(',','').toLowerCase();
            if(addressId == null && newAddress.Address_Type__c != 'Ship To' && orderAddressTypes.contains(newAddress.Address_Type__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, newAddress.Address_Type__c + ' address is already added, if you wish to replace then please delete existing one.'));
            }
            /*else if(addressId == null && uniqueAddresses.contains(key)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not enter duplicate address.'));
            }*/
            else{
            if(newAddress.Address_Type__c == 'Order Acknowledgement' && newAddress.Address__c == null){
            newAddress.Address__c = 'N/A';
            }
                upsert newAddress;
                init();
            }
            showCreateNewPopupFlag = false;         
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    public void makeAddressTypeEditable(){
        for(wrapperAcountAddress eachAccountAddress : accountAddresses){
            if(eachAccountAddress.check){
                eachAccountAddress.isEditable = true;
            }   
            else{
                eachAccountAddress.isEditable = false;
            }
        }
    }
    
    public static void populateAddressOnOrder(Id quoteId, id orderId){
        
        List<Account_Order_Address__c> quoteAddressOnOrder = [SELECT Address_Type__c, Address__c, Address2__c, City__c,
                State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c, Hardware_Address__c, Need_By_Date__c,
                Shipping_Instructions__c, Shipping_Method_Name__c, Copied_From__c FROM Account_Order_Address__c 
                WHERE Quote__c =: quoteId ORDER BY Address_Type__c];
        List<Account_Order_Address__c> orderAddressToBeInserted = new List<Account_Order_Address__c>(); 
        for(Account_Order_Address__c eachAddress : quoteAddressOnOrder){
            Account_Order_Address__c newAddress = new Account_Order_Address__c(Order__c = orderId, Copied_From__c = eachAddress.id);
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
            newAddress.Hardware_Address__c = eachAddress.Hardware_Address__c;
            newAddress.Need_By_Date__c = eachAddress.Need_By_Date__c;
            newAddress.Shipping_Instructions__c = eachAddress.Shipping_Instructions__c;
            newAddress.Shipping_Method_Name__c = eachAddress.Shipping_Method_Name__c;
            orderAddressToBeInserted.add(newAddress);
        }       
        if(!orderAddressToBeInserted.isEmpty())
            insert orderAddressToBeInserted;
    }
    
    public static String validateOrderSubmission(Id quoteId){
        List<Account_Order_Address__c> orderAddressOnOrder = [SELECT Address_Type__c 
                                                              FROM Account_Order_Address__c 
                                                              WHERE Quote__c =: quoteId ORDER BY Address_Type__c];
        Integer intShippableProductsCount = [SELECT count() 
                                             FROM BigMachines__Quote_Product__c 
                                             WHERE BigMachines__Quote__c =: quoteId
                                               AND BigMachines__Product__r.ProductShippable__c='Yes'];
        String returnStr = 'OK';
        //if(orderAddressOnOrder.size() < 4){     
        Set<String> addressTypes = new Set<String>();
        for(Account_Order_Address__c eachAOA : orderAddressOnOrder){
            addressTypes.add(eachAOA.Address_Type__c);
        }   
        String missingAddressTypes = '';
        if(!addressTypes.contains('Bill To')){
            missingAddressTypes += 'Bill To, ';
        }
        if(!addressTypes.contains('End User')){
            missingAddressTypes += 'End User, ';
        }
        if(intShippableProductsCount > 0 && !addressTypes.contains('Ship To')){
            missingAddressTypes += 'Ship To, ';
        }
        if(!addressTypes.contains('Sold To')){
            missingAddressTypes += 'Sold To, ';
        }  
         //Navaneetha added below validation for Order Acknowledgement as part of Order Acknowledgement Enhancement.
        if(!addressTypes.contains('Order Acknowledgement')){
            missingAddressTypes += 'Order Acknowledgement, ';
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
            //}            
        }
        return returnStr;
    }
    
    public class wrapperAcountAddress{
        public Boolean check {get;set;}
        public Id recordId {get;set;}
        public Boolean isEditable {get;set;}
        public  Address__c address {get;set;}       
    }
}