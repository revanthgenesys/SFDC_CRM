global class DealRegFollowEmailCapture implements Messaging.InboundEmailHandler 
{ 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        Messaging.InboundEmailResult objResult = new Messaging.InboundEmailResult();    
        try
        {     
            String strDealRegId = fetchDealRegId(email.htmlBody);            
            System.debug('<<< DS Id = ' + strDealRegId);
            //List<Deal_Support__c> list_DS = [SELECT Id,Status__c,Requester__r.Email FROM Deal_Support__c WHERE Id = :strDSId];
            if(!String.isBlank(strDealRegId))
            {

                Deal_Registration_Follow_Up_Email__c drEmail = new Deal_Registration_Follow_Up_Email__c();
                drEmail.Email_Body__c = email.htmlBody;
                drEmail.From__c = email.fromAddress;
                drEmail.Partner_Portal_Opportunity_Registration__c = Id.valueOf(strDealRegId);
                drEmail.Subject__c = email.Subject;
                
                for(String strToAddress : email.toAddresses)
                {
                    drEmail.To__c = strToAddress + ';';                   
                }
                drEmail.To__c = drEmail.To__c.substringBeforeLast(';');
                
                if (email.CcAddresses!=null){
                    drEmail.Cc__c='';
                    for(String strToCcAddress : email.CcAddresses) 
                         if(strToCcAddress !=null && !strToCcAddress.startsWithIgnoreCase('dealregapprfollowup'))                  
                            drEmail.Cc__c =drEmail.Cc__c + strToCcAddress.trim() + ';';                                                
                    drEmail.Cc__c = drEmail.Cc__c.substringBeforeLast(';');
                }
                
                insert drEmail;
                
                //List<Attachment> list_Attachments = new List<Attachment>();
                
                // Save attachments, if any
                /*if(email.textAttachments != null)
                {
                    for (Messaging.Inboundemail.TextAttachment txtAttach : email.textAttachments) 
                    {
                        Attachment objAttach = new Attachment();
                        objAttach.Name = txtAttach.fileName;
                        objAttach.Body = Blob.valueOf(txtAttach.body);
                        objAttach.ParentId = objDSC.Id;
                        list_Attachments.add(objAttach);
                    }
                }
                if(email.binaryAttachments != null)
                {
                    for (Messaging.Inboundemail.BinaryAttachment binaryAttach : email.binaryAttachments) 
                    {
                        Attachment objAttach = new Attachment();
                        objAttach.Name = binaryAttach.fileName;
                        objAttach.Body = binaryAttach.body;
                        objAttach.ParentId = objDSC.Id;
                        list_Attachments.add(objAttach);
                    }
                }
                
                if(list_Attachments.size() > 0)
                    insert list_Attachments;*/
            }
            objResult.success = true;
        }
        catch(Exception ex)
        {
            objResult.success = false;
            objResult.message = ex.getMessage();
            System.Debug('Error--->'+ex.getMessage());
            System.Debug('ErrorInLine--->'+ex.getLineNumber());
        }
        return objResult;
    }
    
    private String fetchDealRegId(String strEmailBody)
    {
        integer indx = strEmailBody.indexOf('a4O');
        string strDealId = strEmailBody.substring(indx);
        System.Debug('Id--->'+strDealId);
        return strDealId.left(15);
    } 
}