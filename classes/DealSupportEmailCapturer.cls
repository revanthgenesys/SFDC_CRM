global class DealSupportEmailCapturer implements Messaging.InboundEmailHandler 
{ 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        Messaging.InboundEmailResult objResult = new Messaging.InboundEmailResult();    
        try
        {     
            String strDSId = fetchDSId(email.htmlBody);            
            System.debug('<<< DS Id = ' + strDSId);
            List<Deal_Support__c> list_DS = [SELECT Id,Status__c,Requester__r.Email FROM Deal_Support__c WHERE Id = :strDSId];
            if(list_DS.size() > 0)
            {
                Deal_Support__c objDealSupport = list_DS[0];
                Deal_Support_Communication__c objDSC = new Deal_Support_Communication__c();
                objDSC.Deal_Support__c = objDealSupport.Id;
                objDSC.Subject__c = email.Subject;
                objDSC.Email_Body__c = email.htmlBody;
                objDSC.From__c = email.fromAddress; 
                for(String strToAddress : email.toAddresses)
                {
                    objDSC.To__c = strToAddress + ';';                   
                }
                objDSC.To__c = objDSC.To__c.substringBeforeLast(';');
                
                if (email.CcAddresses!=null){
                    objDSC.Cc__c='';
                    for(String strToCcAddress : email.CcAddresses) 
                         if(strToCcAddress !=null)                  
                            objDSC.Cc__c =objDSC.Cc__c + strToCcAddress.trim() + ';';                                                
                    objDSC.Cc__c = objDSC.Cc__c.substringBeforeLast(';');
                }
                
                insert objDSC;
                
                if(objDealSupport.Status__c == 'New' && objDSC.From__c != objDealSupport.Requester__r.Email)
                {
                    objDealSupport.Status__c = 'In Progress';
                    update objDealSupport;
                }
                
                List<Attachment> list_Attachments = new List<Attachment>();
                
                // Save attachments, if any
                if(email.textAttachments != null)
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
    
    private String fetchDSId(String strEmailBody)
    {
        Integer intStartIndex = strEmailBody.indexOf('ref:') + 4;    
        Integer intLastIndex = strEmailBody.lastIndexOf(':ref');    
        String strDSId = '';
        if(intStartIndex >0 && intLastIndex > 0 )
            strDSId = strEmailBody.substring(intStartIndex, intLastIndex);
        
        return strDSId;
    } 
}