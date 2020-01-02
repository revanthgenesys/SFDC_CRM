global class Zuora_ZQuote_DefaultValues extends zqu.CreateQuoteController.PopulateDefaultFieldValuePlugin{ 
   global override void populateDefaultFieldValue
      (SObject record, zqu.PropertyComponentController.ParentController pcc)
   {   
       super.populateDefaultFieldValue(record, pcc);   
       integer InitialTerm = 1;
       integer RenewalTerm = 1;
       string PaymentMethod = 'ACH';
       Integer ValidUntil = 30;
       Integer StartDays = 90;
       String initialStatus = 'Quote In Progress';
       Zuora_Custom_Settings__c obj  = Zuora_Custom_Settings__c.getAll().get('ZuoraInitialTerm');        
       if (obj != null)        
           InitialTerm =  Integer.valueOf(obj.Value__c); 
       obj  = Zuora_Custom_Settings__c.getAll().get('ZuoraRenewalTerm');        
       if (obj != null)        
           RenewalTerm = Integer.valueOf(obj.Value__c); 
       obj  = Zuora_Custom_Settings__c.getAll().get('ZuoraPaymentMethod');        
       if (obj != null)        
           PaymentMethod = obj.Value__c; 
       obj  = Zuora_Custom_Settings__c.getAll().get('ZuoraValidUntilDays');        
       if (obj != null)        
           ValidUntil = Integer.valueOf(obj.Value__c); 
       obj  = Zuora_Custom_Settings__c.getAll().get('ZuoraStartDateDays');        
       if (obj != null)        
           StartDays = Integer.valueOf(obj.Value__c);
       obj = Zuora_Custom_Settings__c.getAll().get('ZuoraInitialStatus');
       if (obj != null)
           initialStatus = obj.Value__c;
       
       Map<String, Object> fieldsToValues = record.getPopulatedFieldsAsMap();
       if (fieldsToValues.containsKey('zqu__Hidden_Subscription_Name__c') && string.isNotBlank((string)fieldsToValues.get('zqu__Hidden_Subscription_Name__c')))
       {            
           string sn = (string)fieldsToValues.get('zqu__Hidden_Subscription_Name__c');
           List<zuora__Subscription__c> lstSubscriptions = [SELECT id, name, Zuora__Status__c, zuora__InitialTerm__c, zuora__RenewalTerm__c                                                         
                                                            from zuora__Subscription__c 
                                                            where name =: sn ];
           if (lstSubscriptions.size() > 0)
           {            
               zuora__subscription__c subscription = lstSubscriptions[0];  
               if (String.isNotBlank(subscription.zuora__InitialTerm__c))
               {
                   string it  = subscription.zuora__InitialTerm__c.split(' ')[0];
                   if (it.isNumeric())
                   {
                       InitialTerm = Integer.valueOf(it);
                   }
                   string rt = subscription.zuora__RenewalTerm__c.split(' ')[0];
                   if (rt.isNumeric())
                   {
                       RenewalTerm = Integer.valueOf(rt);
                   }
               }
           }            
       }     
       
       record.put('zqu__InitialTerm__c', InitialTerm);   
       record.put('zqu__RenewalTerm__c', RenewalTerm);   
       record.put('zqu__ValidUntil__c', Date.today().addDays(ValidUntil));   
       record.put('zqu__StartDate__c', Date.today().addDays(StartDays));   
       record.put('zqu__PaymentMethod__c', PaymentMethod); 
       record.put('zqu__ApprovalStatus__c', initialStatus);
   }
}