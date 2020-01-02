trigger trgEmailNotificationOnOrderCompleted  on Order__c (after update) {
    
    //Anju Sept 24 skip for Cloud
    if(trigger.new[0].Order_Category__c != null && (trigger.new[0].Order_Category__c.contains('PureConnect Cloud') || trigger.new[0].Order_Category__c.contains('PureConnect-Cloud') || 
       trigger.new[0].Order_Category__c.contains('PureCloud') || 
       trigger.new[0].Order_Category__c.contains('PureEngage-Cloud') || trigger.new[0].Order_Category__c.contains('PureEngage Cloud')))
        return;
        
    // Collect Order Ids in to Set
    Set<String> orderIds = new Set<String>();
    
    for(Integer i=0; i< Trigger.New.size(); i++){
        if(Trigger.old[i].status__c != 'Completed' && Trigger.new[i].status__c == 'Completed' && QuoteAndOrderNotificationsUtil.orderTriggerfirstRun){
            orderIds.add(Trigger.new[i].id);
        }
    }

    if(orderIds.size() > 0)
    {
        List<String> toAddesses = new List<String>();
        for(User objUser : [SELECT Email FROM User WHERE Id IN 
                            (SELECT UserOrGroupId From GroupMember where Group.Name = 'Order Completed Notification Group')])
            toAddesses.add(objUser.Email);
        
        // While running tests In case if the list does not contain any users 
        if(Test.isRunningTest() && toAddesses.isEmpty())
            toAddesses.add(UserInfo.getUserEmail());
        
        // Collecting Order Id with status as a Set in Map
        Map<String, Set<String>> orderLineItemStatusMap  = new Map<String,Set<String>>();
        for( Order_Line_Item__c orderLineItem : [SELECT id, Order__c, Contract_Line_Update_Status__c 
                                                 FROM Order_Line_Item__c 
                                                 WHERE Order__c IN :orderIds 
                                                 AND Contract_Line_Update_Status__c IN ('Drop', 'Downsize', 'Reinstate')]) 
        {
            if(!orderLineItemStatusMap.containsKey(orderLineItem.Order__c)) {
                orderLineItemStatusMap.put(orderLineItem.Order__c, new Set<String>());
            }
            orderLineItemStatusMap.get(orderLineItem.Order__c).add(orderLineItem.Contract_Line_Update_Status__c);
        }

        // Required Quote and Order Info to process the Email
        List<BigMachines__Quote__c> quoteList = new  List<BigMachines__Quote__c>([SELECT id, Name, Order__c, Order__r.Name, End_User_ID__r.Name, Sold_To_Region__c 
                                                                                  FROM BigMachines__Quote__c
                                                                                  WHERE Order__c IN :orderLineItemStatusMap.keySet()]);
        Map<String,BigMachines__Quote__c> orderQuoteMap = new Map<String,BigMachines__Quote__c>();
        for(BigMachines__Quote__c quote : quoteList) {
            if(!orderQuoteMap.containsKey(quote.Order__c)) {
                orderQuoteMap.put(quote.Order__c, quote);
            }
        }
        
        // Email Body and Subject Creation and Collecting in List.
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for(String orderId : orderLineItemStatusMap.keySet()){
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            String dropDownSizeReinCon = '';
            for(String status : orderLineItemStatusMap.get(orderId)){
                dropDownSizeReinCon += status+ '/ ';
            }
            dropDownSizeReinCon = dropDownSizeReinCon.substring(0, dropDownSizeReinCon.lastIndexOf('/ '));
            String quoteURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderQuoteMap.get(orderId).id;
            String orderURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderId;
            String emailSubject = orderQuoteMap.get(orderId).Order__r.Name +' Completed with '+ dropDownSizeReinCon +' in Quote ' +orderQuoteMap.get(orderId).Name +' for Account '+ orderQuoteMap.get(orderId).End_User_ID__r.Name +' in '+orderQuoteMap.get(orderId).Sold_To_Region__c;
            String emailBody = '<HTML>'
                + '<Body>'
                + '<TABLE WIDTH="100%" BORDER="0">' 
                + '     <tr><td>Hello Licensing Team, </td></tr>'
                + '     <tr><td>&nbsp;</td></tr>'
                + '     <tr><td>A Renewal <a href= "'+orderURL+'">'+ orderQuoteMap.get(orderId).Order__r.Name +'</a> containing a '+ dropDownSizeReinCon +' of '
                + '             products has been completed in Salesforce for Account '+ orderQuoteMap.get(orderId).End_User_ID__r.Name +' in '+orderQuoteMap.get(orderId).Sold_To_Region__c +'. The Quote associated'
                + '             with this order is Quote <a href= "'+ quoteURL +'">'+ orderQuoteMap.get(orderId).Name +' </a>.</td></tr>'
                + '     <tr><td>&nbsp;</td></tr>'
                + '     <tr><td>Please access the quote or order using the links above to review and provide new license files should they be required.</td></tr>'
                + '     <tr><td>&nbsp;</td></tr>'
                + '     <tr><td>&nbsp;</td></tr>'
                + '     <tr><td>Thank You!</td></tr>'
                + '</TABLE>' 
                + '</Body>'
                + '</HTML>' ;
            
            msg.setSubject(emailSubject);
            msg.setHtmlBody(emailBody);
            msg.setToAddresses(toAddesses);
            emailsToSend.add(msg);
        }
        
        // Processing the Email.
        if(!Test.isRunningTest())
        system.debug('emailsToSend'+ emailsToSend);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
    }
    
    QuoteAndOrderNotificationsUtil.orderTriggerfirstRun = false ;
    
}