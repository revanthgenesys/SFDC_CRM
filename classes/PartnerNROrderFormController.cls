public without sharing class PartnerNROrderFormController {
     
        public Order__c newOrder {get; set;}
        public Boolean displayFields {get; set;}
        private List<User> currentUser;
 
        private String err = 'We have encountered an unexpected error. Please contact your sales representative to complete the Order.';
        private String success = 'The Order has been submitted.';
        
        public PartnerNROrderFormController() {
                    String orderId = ApexPages.currentPage().getParameters().get('Id');  
                    if ( orderId != null )
                       loadOrderForEdit(orderId);
                    else
                       processNewOrder();                
                }
                
                private void processNewOrder() {
                            displayFields = true;
                String phone = '';
                String contEmail;
                ID accountId;
                ID ownerId;
                String accountName;
                String emailAddr;
                String region;
                                
                List<RecordType> recType = [SELECT Id, Name FROM RecordType 
                                            WHERE SobjectType = 'Order__c' AND DeveloperName = 'Non_Revenue_Orders'];
                                                                                    
                             currentUser = [SELECT contact.Email, Contact.ContactPhone__c, Contact.Account.Country__r.Region__c,
                                                 Contact.AccountId, Contact.Account.Name, Contact.Account.Owner.Id,
                                                  Contact.Account.Owner.Email, Contact.Account.Owner.Manager.Email                                                  
                                          FROM User WHERE id =: UserInfo.getUserId()];
                                                                      
                if  ( recType.isEmpty() || currentUser[0].Contact.Account.Owner.Id == null ) {
                                 displayAndLogError('Error setting up order record type OR finding an account owner.');      
                                 return;
                }
                
                                if ( !currentUser.isEmpty() ) {
                             phone = currentUser[0].Contact.ContactPhone__c;
                             contEmail = currentUser[0].Contact.Email;
                             accountId = currentUser[0].Contact.AccountId;
                             accountName = currentUser[0].Contact.Account.Name;
                             ownerId = currentUser[0].Contact.Account.Owner.Id;
                             emailAddr = (String)currentUser[0].Contact.Account.Owner.Email;   
                             region = currentUser[0].Contact.Account.Country__r.Region__c;         
                        }
                        
                        accountName = accountName.length() > 30 ? accountName.substring(0, 30) : accountName;
                        
                        //add 3 digit random number to the order name
                        String orderName = 'NRO - ' + accountName + ' ' + (integer)((Math.random() * 999)+100); 
                        String rclEmail = getRclEmail(region);
                                   
                        try {
                                        newOrder = new Order__c ( 
                                                                  Name = orderName,
                                                                  RecordTypeId = recType[0].Id,
                                                                  NRO_Type__c = 'Partner',
                                                                  Source__c = 'Web',
                                                                  Status__c = 'In Progress',
                                                                  Maintenance_End__c = Date.newInstance(Date.today().year()+1, 1, 31), //January 31 next year
                                                                  RCL_Email__c = getRclEmail(region),                                                             
                                                                  OwnerId = ownerId, 
                                                                  Order_Fulfillment_Email_Receipt__c = emailAddr + '; ' + rclEmail, 
                                                                  Bill_To_Name__c = accountId,
                                                                  Ship_To_Name__c = accountId,
                                                                  Sold_To_Name__c = accountId,
                                                                  End_User_Name__c = accountId,                                                
                                                                  Shipping_Contact_Email__c = contEmail,
                                                                  Shipping_Contact_Phone_Number__c = phone                                                                                                        
                                                                );                           
                               }
                               catch (Exception ex ) {
                                    displayAndLogError( ex.getMessage() );  
                                    return;                                            
                               }
                        
                }
        
        public PageReference saveForm() {
                try {
                        upsert newOrder;
                }
                catch (DmlException ex ) { 
                   displayAndLogError( ex.getMessage() );  
                   return null;                        
                }  
           
           displayFields = false;
    
               PageReference pr = new PageReference('/partner/apex/PartnerNROrder');  
           return pr;          
        }
        
        public PageReference cancelForm()  {
           PageReference pr = new PageReference('/partner/apex/PartnerNROrder');  
           return pr;        
        }
        
        public void displayAndLogError (String errLog) {
                ErrorLogUtil.insertLog('Order - Partner NRO Form', 'User Id: [' + 
                                       UserInfo.getUserId() + '],  ' + errLog, 
                                       'PartnerNROrderFormController'); 
                 
                displayFields = false;             
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, err);
                        ApexPages.addMessage(errorMessage);
                        return;                 
        }
        
        private void loadOrderForEdit(String orderId)  {
          displayFields = true;
          if ( orderId != null )  {
                try { 
                                    newOrder = [SELECT Id, Product_Bundles__c, Product_Description__c,CurrencyIsoCode,
                                                       Ship_software_via__c, Delivery_Method__c, Customer_Note__c,
                                                       Shipping_Contact_Phone_Number__c, Shipping_Contact_Email__c
                                                FROM Order__c
                                                WHERE Id = :orderId
                                                AND Status__c = 'In Progress'
                                                AND Order_Completed_by_AE__c = false
                                                AND CreatedBy.Id = : UserInfo.getUserId()][0];  
                                                                                                        
                        }
                        catch (Exception ex ) {}
                }                               
        }
        
        public String getRclEmail (String region)  {
                String emailAddr = '';

                Partner_NRO_Notification_Settings__c notifSettings = Partner_NRO_Notification_Settings__c.getOrgDefaults();
                                                
                if (region == 'APAC')
                                emailAddr = notifSettings.APAC__c;
                else if (region == 'EMEA')      
                            emailAddr = notifSettings.EMEA__c;
                else if (region == 'LATAM')
                            emailAddr = notifSettings.LATAM__c;
                else if (region == 'NA'|| region == 'North America' ) 
                       emailAddr = currentUser[0].Contact.Account.Owner.Manager.Email;
                        
                if ( emailAddr == '' )
                       emailAddr = notifSettings.NA__c;
                
            return emailAddr;  
        }
               
}