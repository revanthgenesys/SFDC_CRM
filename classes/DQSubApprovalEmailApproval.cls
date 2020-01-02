/*Created By: Mukunthan Koothan
  Created For: DQ Special Offers Sub Approval. Referred in Email Services
*/

global class DQSubApprovalEmailApproval implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        
        Messaging.InboundEmailResult objResult = new Messaging.InboundEmailResult();
        try{
            string emailBody = email.htmlBody;
            string emailSubject = email.Subject;
            string approvalStatus;
            string finFn;
            string dqId = fetchDQId(emailBody);
            string userName = fetchUserName(email.fromAddress);
            System.debug('<<< dqId = ' + dqId);
            if(!String.isBlank(dqId)){
                if(emailBody.containsIgnoreCase('Approved')){
                    approvalStatus = 'Approved';
                }
                else if(emailBody.containsIgnoreCase('Rejected')){
                    approvalStatus = 'Rejected';
                }
                
                if(emailSubject.containsIgnoreCase('Revenue'))
                    finFn = 'Revenue';
                if(emailSubject.containsIgnoreCase('Legal'))
                    finFn = 'Legal';
                if(emailSubject.containsIgnoreCase('Credit') && emailSubject.containsIgnoreCase('Collection'))
                    finFn = 'CreditCollection';
                if(emailSubject.containsIgnoreCase('Order') && emailSubject.containsIgnoreCase('Management') && emailSubject.containsIgnoreCase('Billing'))
                    finFn = 'OrderMgmt';
                    
                updateDQ(dqId,approvalStatus,finFn,email.fromAddress,userName);
            }
        }
        catch(exception ex){
            objResult.success = false;
            objResult.message = ex.getMessage();
            System.Debug('Error--->'+ex.getMessage());
            System.Debug('ErrorInLine--->'+ex.getLineNumber());
        }
        
        return objResult;
    }
    
    private void updateDQ(string dqId,string apprStatus,string finFn,string usrEmail,string userName){
        Deal_Qualification__c dqRec = [Select Id,Req_Credit_Collections_approval__c,Req_Legal_approval__c,Req_Order_Mgmt_Billing_approval__c,Req_Revenue_Approval__c,
                                        Credit_and_Collections_approval__c,Credit_Collections_Comments__c,Legal_approval__c,Legal_Comments__c,
                                        Order_Mgmt_Billing_approval__c,Order_Management_Billing_Comments__c,Revenue_approval__c,Revenue_Comments__c,Status__c 
                                        from Deal_Qualification__c where Id=:dqId];
        system.debug('dqRec--->'+dqRec);
        
        if(dqRec != null){
            if(finFn == 'Revenue' && dqRec.Req_Revenue_Approval__c && dqRec.Revenue_approval__c == 'Pending'){
                dqRec.Revenue_approval__c = apprStatus;
                dqRec.Revenue_Comments__c = string.isBlank(dqRec.Revenue_Comments__c)?apprStatus+' by '+userName+'('+usrEmail+')':
                                                                                    dqRec.Revenue_Comments__c+'; '+apprStatus+' by '+userName+'('+usrEmail+')';
            }
            else if(finFn == 'Legal' && dqRec.Req_Legal_approval__c && dqRec.Legal_approval__c == 'Pending'){
                dqRec.Legal_approval__c = apprStatus;
                dqRec.Legal_Comments__c = string.isBlank(dqRec.Legal_Comments__c)?apprStatus+' by '+userName+'('+usrEmail+')':
                                                                                    dqRec.Legal_Comments__c+'; '+apprStatus+' by '+userName+'('+usrEmail+')';
            }
            else if(finFn == 'CreditCollection' && dqRec.Req_Credit_Collections_approval__c && dqRec.Credit_and_Collections_approval__c == 'Pending'){
                dqRec.Credit_and_Collections_approval__c = apprStatus;
                dqRec.Credit_Collections_Comments__c = string.isBlank(dqRec.Credit_Collections_Comments__c)?apprStatus+' by '+userName+'('+usrEmail+')':
                                                                                    dqRec.Credit_Collections_Comments__c+'; '+apprStatus+' by '+userName+'('+usrEmail+')';
            }
            else if(finFn == 'OrderMgmt' && dqRec.Req_Order_Mgmt_Billing_approval__c && dqRec.Order_Mgmt_Billing_approval__c == 'Pending'){
                dqRec.Order_Mgmt_Billing_approval__c = apprStatus;
                dqRec.Order_Management_Billing_Comments__c = string.isBlank(dqRec.Order_Management_Billing_Comments__c)?apprStatus+' by '+userName+'('+usrEmail+')':
                                                                                    dqRec.Order_Management_Billing_Comments__c+'; '+apprStatus+' by '+userName+'('+usrEmail+')';
            }
            
            update dqRec;
        }
        
    }
    
    private string fetchDQId(String strEmailBody){
        integer indx = strEmailBody.indexOf('a8R');
        string strDealId = strEmailBody.substring(indx);
        System.Debug('Id--->'+strDealId);
        return strDealId.left(15);
    }
    
    private string fetchUserName(string usrEmail){
        string userName = '';
        for(user usr:[select id,firstname,lastname from user where isactive=true AND email=:usrEmail limit 1]){
            userName = usr.firstname + ' ' + usr.lastname;
        }
        return userName;
    }
}