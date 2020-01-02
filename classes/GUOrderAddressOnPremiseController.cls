//Naresh Kumar  08/15/2014
public without sharing class GUOrderAddressOnPremiseController {
    public  List<Account_Order_Address__c> orderAddressOnOrder {get;set;}
    public  List<Account_Order_Address__c> orderAddressOnOrder1 {get;set;}
    public  List<Account_Order_Address__c> orderAddressOnOrder2 {get;set;}
    public Boolean showOrderAddress {get;set;}
    public integer index {get;set;}
    public Boolean showCreateNewPopupFlag {get;set;}
    public Account_Order_Address__c newAddress {get;set;}
    public Id addressId {get;set;}
    public String popupTitle {get;set;}
    public Boolean showAccountAddress {get;set;}
    public List<wrapperAcountAddress> accountAddresses {get;set;}  
    public wrapperAcountAddress objAccountAddress {get;set;}
    public Address__c accountAdd {get;set;}
    public BigMachines__Quote__c quote {get;set;}  
    public Set<String> orderAddressTypes;
    private Set<String> uniqueAddresses;
    private String quoteId;
    public List<AddresWrap> addressWrap {get;set;}
    public addressWrapperCls.Results  addressResult {get;set;}
    public List<addressWrapperCls.ResultDataSet> resData {get;set;}
    public Boolean showCreateNewPopupFlag1 {get;set;}
    public string selectedValue {get;set;}
    public string statusCode {get;set;}
    public string selType {get;set;}
    public GUOrderAddressOnPremiseController(){        
        init();
    }
    
    private void init(){
        selectedValue='';
        objAccountAddress = new wrapperAcountAddress();
        accountAdd = new Address__c();
        //accountAdd.Account__c = 
        addressWrap = new List<AddresWrap>();
        //Account_Order_Address__c. nd =newAddress nd = 
        quoteId = Apexpages.currentPage().getParameters().get('id');
        quote = [SELECT Bill_To_Name__c, End_User_ID__c, Sold_To_Name__c,BigMachines__Opportunity__r.Contact__c,End_User_ID__r.Name,Sold_To_Name__r.Name, System_Integrator__c, Support_Owner__c, Offering_Type__c  
                 FROM BigMachines__Quote__c WHERE id =: quoteId];
        //accountAdd.Account__c = quote.BigMachines__Quote__c;
        Set<Id> accountIds = new Set<Id>();     
       // if(quote.Bill_To_Name__c != null)       
         //   accountIds.add(quote.Bill_To_Name__c);
        if(quote.End_User_ID__c != null)
            accountIds.add(quote.End_User_ID__c);
        if(quote.Sold_To_Name__c != null)
            accountIds.add(quote.Sold_To_Name__c);
       // if(quote.System_Integrator__c != null)
         //   accountIds.add(quote.System_Integrator__c);
       // if(quote.Support_Owner__c != null)
         //   accountIds.add(quote.Support_Owner__c);     
        showOrderAddress = false;       
        showAccountAddress = false;     
        populateAddresses();
        accountAddresses = new List<wrapperAcountAddress>();
        for(Address__c eachAddress :[SELECT Account__c, Address_Line_1__c,Address_line_3__c, Address_Line_2__c, Address_Name__c, Type__c, City__c, Country__c, 
                                     State__c, Account__r.Name, Zipcode__c, Address_Type__c
                                     FROM Address__c WHERE Account__c IN: accountIds]){
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
        for(Account_Order_Address__c eachAddress : [SELECT Address_Type__c,Address_Line_1__c, Address__c, Address2__c, City__c,
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
                    system.debug('eachAccountAddress***'+eachAccountAddress.address.Type__c);
                    if(eachAccountAddress.address.Type__c != 'Ship To' && orderAddressTypes.contains(eachAccountAddress.address.Type__c)){
                    //if(orderAddressTypes.contains(selType)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, eachAccountAddress.address.Type__c + ' address is already added, if you wish to replace then please delete existing one.'));
                        thowValidation = true;
                        break;                      
                    }
                    Account_Order_Address__c newAddress = new Account_Order_Address__c(Quote__c = quoteId);
                    newAddress.Account__c = eachAccountAddress.address.Account__c;
                    newAddress.Address_Line_1__c = eachAccountAddress.address.Address_Line_1__c;
                    newAddress.Address2__c = eachAccountAddress.address.Address_Line_2__c;
                    newAddress.Address_Type__c = eachAccountAddress.address.Type__c;
                    //newAddress.Address_Type__c = selType;
                    newAddress.City__c = eachAccountAddress.address.City__c;
                    newAddress.Country__c = eachAccountAddress.address.Country__c;
                    newAddress.State__c = eachAccountAddress.address.State__c;
                    newAddress.Zip_Code__c = eachAccountAddress.address.Zipcode__c;
                    //newAddress.AccountId__c = eachAccountAddress.address.Zipcode__c;
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
    public void saveAddINFO(){
        showCreateNewPopupFlag1 = false;
        if(newAddress.Id !=null){
            Update newAddress;
            init();
        }
    }
    public void editAddress(){      
        popupTitle = 'Edit Address';
        system.debug('addressId**** '+addressId);
        newAddress = [SELECT Address_Type__c,Address_Line_1__c ,Shipping_Method_Name__c,Shipping_Instructions__c , Address__c, Address2__c, City__c,
                      State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c 
                      FROM Account_Order_Address__c WHERE id =: addressId LIMIT 1]; 
        showCreateNewPopupFlag1 = true;
        
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
        orderAddressOnOrder = [SELECT Address_Type__c,Address_Line_1__c , Address__c, Address2__c, City__c,
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
        showCreateNewPopupFlag1 = false;
    }
    public pageReference reflectSelAddress(){
        //system.debug('index is **'+index);
        integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('index')); 
        system.debug('index is **'+indexVal);
        for(integer i=0; i < addressWrap.size(); i++){
            if(i == indexVal - 1){
                addressWrap[i].isSelect = true;
                system.debug('addressWrap[i] **'+addressWrap[i]);
            }
            else{
                addressWrap[i].isSelect = false;
            }
        }
        for(AddresWrap   AWs  : addressWrap ){             
            if(Aws.isSelect){
                system.debug('AW****'+Aws.isSelect);
                accountAdd = new Address__c();
                accountAdd.Address_Line_1__c = AWs.Wrapaddress.Address_Line_1__c ;
                accountAdd.Address_Line_2__c =   AWs.Wrapaddress.Address_Line_2__c ;
                accountAdd.City__c = AWs.Wrapaddress.City__c; 
                accountAdd.State__c = AWs.Wrapaddress.State__c ;
                accountAdd.Country__c = AWs.Wrapaddress.Country__c; 
                accountAdd.Zipcode__c  =  AWs.Wrapaddress.Zipcode__c ;
                //accountAdd.Validity_Status__c='Valid';
            }
        }
        system.debug('accountAdd****'+accountAdd);
        return null;
    }
    public  void getAddress(){
        
        string strAddressLine1 =accountAdd.Address_Line_1__c;
        strAddressLine1 =EncodingUtil.urlEncode(strAddressLine1, 'UTF-8').replace('+', '%20') ;
        
        string strAddressLine2=accountAdd.Address_Line_2__c;
        strAddressLine2 =EncodingUtil.urlEncode(strAddressLine2, 'UTF-8').replace('+', '%20') ;
        
        string strCity=accountAdd.City__c;
        strCity =EncodingUtil.urlEncode(strCity, 'UTF-8').replace('+', '%20') ;
        
        string strState=accountAdd.State__c;
        strState =EncodingUtil.urlEncode(strState, 'UTF-8').replace('+', '%20') ;
        
        string strcountry=accountAdd.Country__c;
        strcountry =EncodingUtil.urlEncode(strcountry, 'UTF-8').replace('+', '%20') ;
        
        string strPostalCode =accountAdd.Zipcode__c;
        //strPostalCode =EncodingUtil.urlEncode(strPostalCode, 'UTF-8'); 
        //strPostalCode =EncodingUtil.urlEncode(strPostalCode, 'UTF-8').replace('-', '%2D') ;
        
        
        
        //AddressLine -1= DeliveryAddressLine1
        //Address Line -2= strSubBuilding
        //City= Locality
        //State	 = Province
        //Zip= PostalCode
        //country = country
        string endPoint = 'https://rest-adcloud.informaticadaas.com/adcloud/verifyaddress?login=166534&password=Digital504&processmode=FASTCOMPLETION&'
            +'&Street='+strAddressLine1+
            +'&SubBuilding='+strAddressLine2+
            +'&Locality='+strCity+
            +'&Province='+strState+
            +'&country='+strcountry+
            +'&PostalCode='+strPostalCode;
        try{
        HttpRequest req1 = new HttpRequest();
        HttpResponse res1 = new HttpResponse();
        Http http1 = new Http();
        req1.setMethod('GET');
        req1.setHeader('Content-Type', 'application/json;');
        req1.setEndpoint(endPoint);
        //req1.setCompressed(true);
        res1 = http1.send(req1);
        system.debug('result*****'+res1.getStatusCode());
        if (res1.getStatusCode() == 200) {
            addressWrap = new List<AddresWrap>();
            addressResult  = new addressWrapperCls.Results ();
            List<addressWrapperCls.ResultDataSet> resData = new List<addressWrapperCls.ResultDataSet>();
            
            addressWrapperCls objAddress = (addressWrapperCls)JSON.deserialize(res1.getbody(), addressWrapperCls.Class);
            system.debug('objAddress** '+objAddress);
            if(objAddress != null){
                addressResult = objAddress.Results[0];
                system.debug('addressResult** '+addressResult.ResultDataSet);
                if(addressResult.ResultDataSet !=null){ 
                    resData = addressResult.ResultDataSet;
					statusCode = objAddress.Results[0].ProcessStatus;
                    if(statusCode =='Q0' || statusCode =='N1'){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,+ ' No address found with the given details.Please redefine your search'));
                        return; 
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,+ ' No address found with the given details.Please redefine your search'));
                    return; 
                }
                system.debug('resData** '+resData);
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,+ 'No address found with the given details.Please redefine your search'));
				return;
            }
            
            for(addressWrapperCls.ResultDataSet  AWR : resData ){
                AddresWrap addWrap = new AddresWrap();                
                addWrap.isSelect = false;
                addWrap.Wrapaddress.Address_Line_1__c  = AWR.Address.DeliveryAddressLines[0];
                addWrap.Wrapaddress.Address_Line_2__c  = AWR.Address.SubBuilding[0];
                addWrap.Wrapaddress.City__c  = AWR.Address.Locality[0];
                addWrap.Wrapaddress.State__c  = AWR.Address.Province[0];
                addWrap.Wrapaddress.Country__c  = AWR.Address.Country[0];
                addWrap.Wrapaddress.Zipcode__c  = AWR.Address.PostalCode[0];
                addressWrap.add(addWrap);
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+ ' An error occured.Please try again later'));

        }
        }
        catch(Exception ex){
            system.debug('exce in fetching **'+ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+ ' Please provide valid information to fetch the address details'));
			AddresWrap addWrap = new AddresWrap();
        }
    }
    public void createNewAddress(){
      /*  try{
            String key = (accountAddress.Address_Line_1__c == null ? '' : accountAddress.Address_Line_1__c) + (accountAddress.Zipcode__c  == null ? '' : accountAddress.Zipcode__c);
            key = key.replace(' ', '').replace(',','').toLowerCase();
            if(addressId == null && accountAddress.Type__c != 'Ship To' && orderAddressTypes.contains(accountAddress.Type__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, accountAddress.Type__c + ' address is already added, if you wish to replace then please delete existing one.'));
            }
            else if(addressId == null && uniqueAddresses.contains(key)){
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not enter duplicate address.'));
}
            else{
                if(accountAddress.Type__c == 'Order Acknowledgement' && accountAddress.Address_Line_1__c == null){
                    newAddress.Address__c = 'N/A';
                }
                upsert accountAddress;
                init();
            }
            showCreateNewPopupFlag = false;         
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }*/
        system.debug('createNewAddress ** '+selectedValue);
        if(string.isBlank(selectedValue)){
            showCreateNewPopupFlag = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ' Please select either End User or Sold To to save the address'));
			//return;
        }else{
        system.debug('createNewAddress ** '+selectedValue);
        boolean isAddressAvailable = false;
        for(wrapperAcountAddress eachAccountAddress : accountAddresses){
            //Address__c objAddress = new Address__c();
            if(accountAdd.Address_Line_1__c  == eachAccountAddress.address.Address_Line_1__c && 
               accountAdd.Address_Line_2__c  == eachAccountAddress.address.Address_Line_2__c && 
               accountAdd.City__c  == eachAccountAddress.address.City__c && 
               accountAdd.State__c  == eachAccountAddress.address.State__c && 
               accountAdd.Country__c  == eachAccountAddress.address.Country__c && 
               accountAdd.Zipcode__c  == eachAccountAddress.address.Zipcode__c && 
               accountAdd.Type__c  == eachAccountAddress.address.Type__c){
                   isAddressAvailable = true;
                   break;
            }
        } 
        if(isAddressAvailable){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, accountAdd.Type__c + ' address is already added, Please refer to available addresses.'));
        }
        else{            
            if(selectedValue =='Enduser'){
                accountAdd.Account__c=quote.End_User_ID__c;
            }else if(selectedValue =='SoldTo'){
                accountAdd.Account__c=quote.Sold_To_Name__c;
            }
            if(string.isNotBlank(statusCode)){
                if(statusCode =='Q0' || statusCode =='Q1' || statusCode =='Q2'){
                    accountAdd.Validity_Status__c = 'Not Valid';
                }
                else{
                    accountAdd.Validity_Status__c = 'Valid';
                } 
            }else{
                accountAdd.Validity_Status__c = 'Not Valid';
            }
            for(AddresWrap   AWs  : addressWrap ){             
                if(Aws.isSelect){
                    if(accountAdd.Address_Line_1__c != AWs.Wrapaddress.Address_Line_1__c ||
                       accountAdd.Address_Line_2__c !=   AWs.Wrapaddress.Address_Line_2__c ||
                       accountAdd.City__c != AWs.Wrapaddress.City__c || 
                       accountAdd.State__c != AWs.Wrapaddress.State__c  ||
                       accountAdd.Country__c != AWs.Wrapaddress.Country__c || 
                       accountAdd.Zipcode__c  !=  AWs.Wrapaddress.Zipcode__c ){
                           accountAdd.Validity_Status__c = 'User Updated';
                       }
                    //accountAdd.Validity_Status__c='Valid';
                }
            }
            accountAdd.Informatica_Status_Code__c=statusCode;
            INSERT accountAdd;
            showCreateNewPopupFlag = false;
            system.debug('going for init');
            init();
        }
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
        
        List<Account_Order_Address__c> quoteAddressOnOrder = [SELECT Address_Type__c,Address_Line_1__c , Address__c, Address2__c, City__c,
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
        public boolean isSelected {get;set;}
        
        public wrapperAcountAddress(){
            if(address ==null) address = new Address__c(); 
        }
    }
    
    public class AddresWrap{
        public boolean isSelect {get;set;}
        public  Address__c Wrapaddress {get;set;}
        public AddresWrap(){
            if(Wrapaddress ==null) Wrapaddress = new Address__c(); 
        }
        
    }
    
}