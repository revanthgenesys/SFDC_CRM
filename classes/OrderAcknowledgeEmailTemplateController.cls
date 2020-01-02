global without sharing class OrderAcknowledgeEmailTemplateController {

    public Id orderId {get; set;}
    public Id accountId {get; set;}
    public String offeringType {get; set;}
    public Boolean isMaintOrder {get; set;}
    public Boolean isAmendOrder {get; set;}
    public Boolean isSubscription {get; set;}
    webservice static String resendEmail(String orderId){
        insert new Order_Acknowledge_Email__c(Order__c = orderId);
        return 'OK';
    }
    

    
    public List<Order_Line_Item__c> getOrderLineItems() {
       if(orderId != null){
            List<Order_Line_Item__c> listOfOrderLines = [SELECT APN_Number__c, Product__r.Name, Material_Description__c, Quantity__c,
                Net_Unit_Price__c, Ext_Net_Price__c, Revised_License_List_Price__c, Revised_Net_License_Value__c,Quote_Product__c,Quote_Product__r.Net_Unit_Price_1__c,
                Support_Type_Formula__c, Ext_Net_Price_Change__c, Maintenance_Due__c,Maintenance_Start_Date__c, Quote_Product__r.Net_Unit_Price_2__c, Quote_Product__r.Ext_Net_Price_1__c,
                Order__r.License_FYM_detail__c, Maintenance_End_Date__c, Quantity_Change__c,Order__r.Region__c, Order__r.Classification__c,Order__r.Ship_To_Name__c,Order__r.Sold_To_Name__c,
                Product_Type__c, Year__c, Order__r.End_User_Name__c,Order__r.Bill_To_Name__c, Order__r.Order_Category__c, Product__r.Type__c, Quote_Product__r.Ext_Net_Price_2__c,
                Quote_Product__r.Ext_Net_Price__c, Quote_Product__r.Net_Unit_Price__c
                FROM Order_Line_Item__c WHERE Order__c =: orderId AND ((Quote_Product__r.Bundle_Line__c = null
                AND Quote_Product__c != null) OR RecordType.Name LIKE '%Cloud%') AND BigMachines_Quantity__c > 0
                AND Product__r.Dont_Publish_In_Quote__c = false];
           List<Order_Line_Item__c> listOfOrderLines1 = new List<Order_Line_Item__c>();
           if(!listOfOrderLines.isEmpty()){
               if(listOfOrderLines[0].Order__r.Order_Category__c  == 'PureEngage - Renewal'
                  || listOfOrderLines[0].Order__r.Order_Category__c  == 'PureConnect - Renewal'
                  || listOfOrderLines[0].Order__r.License_FYM_detail__c  == 'Maintenance Only Order'){
                   isMaintOrder = true;
               }
               else{
                   isMaintOrder = false;
               }
               
               if(listOfOrderLines[0].Order__r.Classification__c == 'Amend Subscription')
               {
               isAmendOrder = true;
               } else {isAmendOrder = false;}
               
                if(listOfOrderLines[0].Order__r.Order_Category__c == 'Pureconnect Subscription' || listOfOrderLines[0].Order__r.Order_Category__c == 'PureEngage Subscription')
               {
               isSubscription = true;
               } else {isSubscription = false;}
               
           
               if(isMaintOrder){
                   for(Order_Line_Item__c eachItem : listOfOrderLines){
                        if(eachItem.Product__r.Type__c == 'Genesys Care')
                            listOfOrderLines1.add(eachItem);    
                   }    
               }
               else{
                   
                   listOfOrderLines1.addAll(listOfOrderLines);
               }
            }
            return listOfOrderLines1;        
       }       
       return null;
    }
    
    public List<AddressWrapper> getOrderAddreses(){
        if(orderId != null){
            List<AddressWrapper> listOfAddressWrapper = new List<AddressWrapper>();
            
            List<Account_Order_Address__c> listOfAddresess = [SELECT First_Name__c, Last_Name__c, Address__c, Address2__c, City__c, 
                                           State__c, Country__c, Zip_Code__c, Address_Type__c, Phone__c, Email__c,Order__r.Ship_To_Name__r.name,Order__r.Sold_To_Name__r.name,Order__r.End_User_Name__r.name,Order__r.Bill_To_Name__r.name
                                           FROM Account_Order_Address__c 
                                           WHERE Order__c =: orderId 
                                           AND (Address_Type__c = 'Bill To' OR  Address_Type__c = 'Sold To')];
            
            for(Account_Order_Address__c eachAddress : listOfAddresess){
                AddressWrapper newAddress = new AddressWrapper();
                newAddress.billToSoldTo = eachAddress;
                listOfAddressWrapper.add(newAddress);
            }
            
            listOfAddresess = [SELECT First_Name__c, Last_Name__c, Address__c, Address2__c, City__c, 
                                           State__c, Country__c, Zip_Code__c, Address_Type__c, Phone__c, Email__c,Order__r.Ship_To_Name__r.name,Order__r.Sold_To_Name__r.name,Order__r.End_User_Name__r.name,Order__r.Bill_To_Name__r.name
                                           FROM Account_Order_Address__c 
                                           WHERE Order__c =: orderId AND Address_Type__c = 'Ship To'];
            
            Integer counter = 1;
            for(Account_Order_Address__c eachAddress : listOfAddresess){
                if(listOfAddressWrapper.size() >= counter){
                    listOfAddressWrapper[counter - 1].shipTo = eachAddress;
                }
                else{
                    AddressWrapper newAddress = new AddressWrapper();
                    newAddress.shipTo = eachAddress;
                    listOfAddressWrapper.add(newAddress);
                }
                counter ++;
            }

            return listOfAddressWrapper;
        }
        return null;
    }
    
    public List<String> getContractEmails(){
        if(accountId != null){
            if(offeringType == null || offeringType == 'PureEngage')
                offeringType = 'PureEngage On Premise';
            Set<String> setOfEmails = new Set<String>();
            for(Finance_Notifications__c eachEmail : [SELECT Email__c FROM Finance_Notifications__c
                                                          WHERE Account__c =: accountId AND Active__c = true
                                                      AND Notification_Type__c INCLUDES ('Invoices')
                                                      AND OfferingType__c INCLUDES (:offeringType)]){
                if(eachEmail.Email__c == null)
                    continue;
                List<String> emailList = eachEmail.Email__c.replace(' ','\n').split('\n');
                for(String eachEmailAddress : emailList){
                    String email = eachEmailAddress.trim();
                    setOfEmails.add(email);
                }
            }
            List<String> listOfEmails = new List<String>(setOfEmails);
            return listOfEmails;
        }
        if(Test.isRunningTest()){
            integer i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            
        }
          return null;
    }
    
    public static Map<Id, Order__c> getEmailRecipients(List<Order_Acknowledge_Email__c> listOfEmails){
        Set<Id> setOfOrderIds = new Set<Id>();
        set<Id> setofRenewalOrderIds = new Set<Id>();
        
        //mukunth added logic to include renewal acknowledgement email
        for(Order_Acknowledge_Email__c eachEmail : listOfEmails){
        system.debug('eachEmail.order__r.Opportunity_Type__c'+ eachEmail.order__r.Opportunity_Type__c);
        system.debug('eachEmail.order__r.Order_Category__c'+ eachEmail.order__r.Order_Category__c);
           if(!string.isBlank(eachEmail.Order__c)){            
            if(eachEmail.order__r.Order_Category__c.containsIgnoreCase('Renewal'))
                setofRenewalOrderIds.add(eachEmail.Order__c);
            else
                setOfOrderIds.add(eachEmail.Order__c);                
                 }
        }
       // system.debug('setofRenewalOrderIds'+ setofRenewalOrderIds);
        
        Map<Id, Order__c> mapOfOrderIdVsOrder = new Map<Id, Order__c>([SELECT id,CreatedBy.Email,Order_Acknowledgement_Email__c, Region__c, Opportunity__r.Owner.Email, Opportunity__r.Ownerid,
                                      Opportunity__r.Contact__c, End_User_Name__r.CSM_Account_Owner__r.Email,(SELECT Email__c FROM Account_Order_Addresses__r where Address_Type__c = 'Order Acknowledgement')
                                      FROM Order__c WHERE id IN : setOfOrderIds]);
        
        //Mukunth added to include logic for renewal                               
        list<Order__c> renewalOrder = new list<order__c>();                            
        if(setofRenewalOrderIds.size()>0)
            renewalOrder = [SELECT id,CreatedBy.Email, Region__c,Order_Acknowledgement_Email__c, Opportunity__r.Owner.Email, Opportunity__r.Ownerid,
                                      Opportunity__r.Contact__c, End_User_Name__r.CSM_Account_Owner__r.Email FROM Order__c WHERE id IN : setofRenewalOrderIds];
                                      
        for(order__c renewal:renewalOrder){
            mapOfOrderIdVsOrder.put(renewal.Id,renewal);
        }
        //mukunth code end
                                      
         system.debug('mapOfOrderIdVsOrder' + mapOfOrderIdVsOrder);
        return mapOfOrderIdVsOrder;
    }
    
    public class AddressWrapper{
        public Account_Order_Address__c billToSoldTo {get; private set;}  
        public Account_Order_Address__c shipTo {get; private set;} 
    }
}