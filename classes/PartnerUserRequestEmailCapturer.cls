global class PartnerUserRequestEmailCapturer implements Messaging.InboundEmailHandler 
{ 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        Messaging.InboundEmailResult objResult = new Messaging.InboundEmailResult();    
        try
        {     
            String strPartnerUserId = fetchPartnerUserId(email.htmlBody);    
            //List<Partner_User_Request__c > list_PartnerUser = [SELECT Id,Status__c,Requester__r.Email FROM Partner_User_Request__c WHERE Id = :strPartnerUserId];
            //if(list_PartnerUser.size() > 0)
            if(strPartnerUserId != null && strPartnerUserId != '')
            {
                //Partner_User_Request__c objPartnerUser = list_PartnerUser[0];
                Communication__c objComm = new Communication__c();
                objComm.Partner_User_Request__c  = strPartnerUserId;//objPartnerUser.Id;
                objComm.Subject__c = email.Subject;
                objComm.Email_Body__c = email.htmlBody;
                objComm.From__c = email.fromAddress; 
                for(String strToAddress : email.toAddresses)
                {
                    objComm.To__c = strToAddress + ';';                   
                }
                objComm.To__c = objComm.To__c.substringBeforeLast(';');
                
                if (email.CcAddresses!=null){
                    objComm.Cc__c='';
                    for(String strToCcAddress : email.CcAddresses) 
                         if(strToCcAddress !=null)                  
                            objComm.Cc__c =objComm.Cc__c + strToCcAddress.trim() + ';';                                                
                    objComm.Cc__c = objComm.Cc__c.substringBeforeLast(';');
                }
                
                insert objComm;                
                                
                List<Attachment> list_Attachments = new List<Attachment>();
                
                // Save attachments, if any
                if(email.textAttachments != null)
                {
                    for (Messaging.Inboundemail.TextAttachment txtAttach : email.textAttachments) 
                    {
                        Attachment objAttach = new Attachment();
                        objAttach.Name = txtAttach.fileName;
                        objAttach.Body = Blob.valueOf(txtAttach.body);
                        objAttach.ParentId = strPartnerUserId;//objPartnerUser.Id;
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
                        objAttach.ParentId = strPartnerUserId;//objPartnerUser.Id;
                        list_Attachments.add(objAttach);
                    }
                }
                
                if(list_Attachments.size() > 0)
                    insert list_Attachments;
            }
            objResult.success = true;
        }
        catch(Exception ex)
        {
            objResult.success = false;
            objResult.message = ex.getMessage();
        }
        return objResult;
    }
    
    private String fetchPartnerUserId(String strEmailBody)
    {
        Integer intStartIndex = strEmailBody.indexOf('ref:') + 4;    
        Integer intLastIndex = strEmailBody.lastIndexOf(':ref');    
        String strPartnerUserId = strEmailBody.substring(intStartIndex, intLastIndex);
        return strPartnerUserId;
    } 
}