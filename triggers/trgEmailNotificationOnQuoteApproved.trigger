trigger trgEmailNotificationOnQuoteApproved on BigMachines__Quote__c (after update) {

    // Collect Quote Ids in to Set
    Set<String> quoteIds = new Set<String>();
    
    for(Integer i=0; i< Trigger.New.size(); i++){
        if(Trigger.new[i].Opportunity_Type__c == 'Genesys_Renewal' && Trigger.old[i].BigMachines__Status__c != 'Quote Approved' && Trigger.new[i].BigMachines__Status__c == 'Quote Approved' && QuoteAndOrderNotificationsUtil.quoteTriggerfirstRun){
            quoteIds.add(Trigger.new[i].id);
        }
    }
    
    if(quoteIds.isEmpty())
        return;
  
    // Prepare to Addesses list
    Group grp = [SELECT Id FROM Group WHERE Name='Quote Approved Notification Group' LIMIT 1]; 
    List<GroupMember> groupMemList = [SELECT UserOrGroupId From GroupMember where GroupId =:grp.id];
    List<id> userIdList = new List<id>();
    for(GroupMember i : groupMemList) {
        userIdList.add(i.UserOrGroupId);
    }
    
    // While running tests In case if the list does not contain any users 
    if(Test.isRunningTest() && userIdList.size() <=0){
        userIdList.add(UserInfo.getUserId());
    }
    
    if(quoteIds.size() > 0 && userIdList.size() >0) {    
        List<User> userList = [SELECT id, email FROM User WHERE id IN :userIdList];
        List<String> toAddesses = new List<String>();
        for(User u : userList) {
            toAddesses.add(u.email);
        }

        // Collecting Quote Id with status as a Set in Map
        Map<String, Set<String>> QuoteProductStatus  = new Map<String,Set<String>>();
        for( BigMachines__Quote_Product__c quoteProd : [SELECT id, BigMachines__Quote__c, Contract_Line_Update_Status__c 
                                                        FROM BigMachines__Quote_Product__c 
                                                        WHERE BigMachines__Quote__c IN :quoteIds 
                                                        AND Contract_Line_Update_Status__c IN ('Drop', 'Downsize', 'Reinstate')]) 
        {
            if(!QuoteProductStatus.containsKey(quoteProd.BigMachines__Quote__c)) {
                QuoteProductStatus.put(quoteProd.BigMachines__Quote__c, new Set<String>());
            }
            QuoteProductStatus.get(quoteProd.BigMachines__Quote__c).add(quoteProd.Contract_Line_Update_Status__c);
        }
        
        // Required Quote Info to process the Email
        Map<id,BigMachines__Quote__c> QuoteMap = new  Map<id,BigMachines__Quote__c>([SELECT id, Name, End_User_ID__r.Name, Sold_To_Region__c 
                                                  FROM BigMachines__Quote__c
                                                  WHERE ID IN :QuoteProductStatus.keySet()]);
        
        
        // Email Body and Subject Creation and Collecting in List.
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for(String qouteId : QuoteProductStatus.keySet()){
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            String dropDownSizeReinCon = '';
            for(String status : QuoteProductStatus.get(qouteId)){
                dropDownSizeReinCon += status+ '/ ';
            }
            dropDownSizeReinCon = dropDownSizeReinCon.substring(0, dropDownSizeReinCon.lastIndexOf('/ '));
            String quoteURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+qouteId;
    
            String emailSubject = 'Approval for '+ dropDownSizeReinCon + ' in Quote '+QuoteMap.get(qouteId).Name +' for Account '+ QuoteMap.get(qouteId).End_User_ID__r.Name + ' in '+ QuoteMap.get(qouteId).Sold_To_Region__c ;
            String emailBody = '<HTML>'
                + '<Body>'
                + '<TABLE WIDTH="100%"  BORDER="0">' 
                + '    <tr><td>Hello Licensing Team, </td></tr>'
                + '    <tr><td>&nbsp;</td></tr>'
                + '    <tr><td>A '+ dropDownSizeReinCon + ' has been approved in Quote <a href= "'+ quoteURL +'">'+ QuoteMap.get(qouteId).Name +' </a> for Account '+ QuoteMap.get(qouteId).End_User_ID__r.Name + ' in '+ QuoteMap.get(qouteId).Sold_To_Region__c + '.</td></tr>'
                + '    <tr><td>&nbsp;</td></tr>'
                + '    <tr><td>You may access the quote via the Quote link and review. Please inform Genesys Care of any potential licensing issues.</td></tr>'
                + '    <tr><td>&nbsp;</td></tr>'
                + '    <tr><td>&nbsp;</td></tr>'
                + '    <tr><td>Thank You!</td></tr>'
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
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
    }
    QuoteAndOrderNotificationsUtil.quoteTriggerfirstRun = false;
}