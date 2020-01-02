global class LicenseRequestEmailService implements Messaging.InboundEmailHandler 
{
	private String TEXT_TO_LONG = ' [The message is too long to display. To view full version please open this message in outlook.] ';
	
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        try  {

              License_Request__c objLic = new License_Request__c();

              String embody = String.isBlank(email.plainTextBody) ? email.htmlBody : email.plainTextBody;
              String stLRId = getReId(embody);
                     
              Boolean lrNotfound = false;
              if ( String.isNotBlank(stLRId) ) {
                     List<License_Request__c> objLicLst = [SELECT id, Status__c, Sub_Status__c, Corporate_Email__c   
                                                           FROM License_Request__c WHERE id =: stLRId];
                     if ( !objLicLst.isEmpty() )  {                     
                           updateLR(objLicLst[0]);
                           addInboundMessage( stLRId, email);
                     }
                     else
                         lrNotfound = true;
              }
              
              if ( String.isBlank(stLRId) || lrNotfound ) {                   	
                          License_Request__c lr = insertEmailTypeRequest(email);                     
                          if ( lr != null )
                             addInboundMessage( lr.Id, email);
              }                   
        }
        catch (Exception ex)  {
           ErrorLogUtil.insertLog('LicenseRequestEmailService', 'Subject: ' +  email.Subject + '  ' +  ex.getMessage(), 'LicenseRequestEmailService.handleInboundEmail');     
           result.success = true;  /// no need to bounce back to sender
        }
               
        return result;
    }
    
  private void updateLR(License_Request__c licRec )  {   
  	  List<RecordType> rtypeLst = [SELECT Id FROM RecordType WHERE SobjectType = 'License_Request__c' AND DeveloperName = 'Editable'];
  	  if ( !rtypeLst.isEmpty() )
  	     licRec.RecordTypeId = rtypeLst[0].Id;
  	          
      licRec.Status__c = 'Open';
      licRec.Sub_Status__c = 'Update Received';     
     
       update licRec; 
      return;
  }
  
  private License_Request__c insertEmailTypeRequest (Messaging.InboundEmail email) {
  	
  	License_Request__c licRec = new License_Request__c();
  	List<RecordType> rtypeLst = [SELECT Id FROM RecordType WHERE SobjectType = 'License_Request__c' AND DeveloperName = 'Email_to_LicenseRequest'];
  	
  	licRec.Status__c = 'Open';
  	licRec.Sub_Status__c = 'New';
  	licRec.Subject__c = email.Subject.length() > 90 ? email.Subject.substring(0,90) : email.Subject;
  	
  	if ( email.plainTextBody != null )
      		licRec.Description__c = email.plainTextBody.length() > 31990 ? TEXT_TO_LONG + email.plainTextBody.substring(0,10000) + TEXT_TO_LONG : email.plainTextBody;
    else if ( email.htmlBody != null )
      		licRec.Description__c = email.htmlBody.length() > 31990 ?  + TEXT_TO_LONG + email.htmlBody.substring(0,10000) + TEXT_TO_LONG : email.htmlBody;

  	licRec.Corporate_Email__c = email.fromAddress;
  	licRec.Last_Name__c = email.fromName;
  	licRec.Source__c = 'Email';
  	if ( !rtypeLst.isEmpty() )
  	   licRec.RecordTypeId = rtypeLst[0].Id;
 
  	try {
  		insert licRec;
  	}
  	catch (Exception ex) {
  		ErrorLogUtil.insertLog('LicenseRequestEmailService', 'Subject: ' +  email.Subject + '  ' + ex.getMessage(), 'LicenseRequestEmailService.insertEmailTypeRequest'); 
  		return null;
  	}
  	
  	return licRec;
  }
       
  private String getReId(String strEmailBody) {
  	  	
  	    if ( String.isBlank(strEmailBody) )
  	        return null;
  	        
  	    String strDSId = '';
        Integer intStartIndex = strEmailBody.indexOf('refer:');    
        Integer intLastIndex = strEmailBody.lastIndexOf(':ref');  
        
        if ( intStartIndex >= 0 && intLastIndex > 0 )  
      		 strDSId = strEmailBody.substring(intStartIndex + 6, intLastIndex);
      		  
        if ( strDSId.length() == 18 )
             return strDSId;
        else
            return null;
  } 
  
  private void addInboundMessage (string sLRid, Messaging.InboundEmail email) { 
  	    ///Bypass trigger set for processing Email-To-Case
  	    Util.Bypass_Trigger_Chk = true;
  	    
        EmailMessage inbMsg = new EmailMessage();
        inbMsg.RelatedToId = sLRid;
        inbMsg.Subject = email.Subject.length() > 90 ? email.Subject.substring(0,90) : email.Subject;
 
        if ( email.plainTextBody != null )  
      		  inbMsg.TextBody = email.plainTextBody.length() > 31990 ? TEXT_TO_LONG + email.plainTextBody.substring(0,10000) + TEXT_TO_LONG : email.plainTextBody;
        if ( email.htmlBody != null ) 
      		  inbMsg.HtmlBody = email.htmlBody.length() > 31990 ? TEXT_TO_LONG + email.htmlBody.substring(0,10000) + TEXT_TO_LONG : email.htmlBody;

        inbMsg.Incoming = true;
        inbMsg.Status = '1';
        inbMsg.FromName = email.fromName;
        inbMsg.FromAddress = email.fromAddress;
        inbMsg.CcAddress = parseAddrLst(email.ccAddresses);
        inbMsg.ToAddress = parseAddrLst(email.toAddresses);

        try {
  			insert inbMsg;
	  	}
	  	catch (Exception ex) {
	  		ErrorLogUtil.insertLog('LicenseRequestEmailService', 'AFR ID: ' + sLRid + '  ' + ex.getMessage(), 'LicenseRequestEmailService.addInboundMessage'); 
	  		return;
	  	}
                
       List<Attachment> attList = new List<Attachment>(); 
       if ( email.binaryAttachments != null )  {
           for ( Messaging.Inboundemail.binaryAttachment file : email.binaryAttachments ) {
                    Attachment attachment = new Attachment();         
                  	attachment.Name = file.fileName;
                    attachment.Body = file.body;
                    attachment.ParentId = inbMsg.id;
                    attList.add(attachment);
            }
       }
       if( email.textAttachments != null )  {
            for ( Messaging.Inboundemail.TextAttachment file : email.textAttachments ) {
                    Attachment attachment = new Attachment();
                    
                    if ( file.fileName != null && file.fileName.startswith('Attachment_') && file.fileName.substringAfter('_').isNumeric() )
                         attachment.Name = file.fileName + '.htm';
                    else                    
                   		 attachment.Name = file.fileName;
                    attachment.Body = Blob.valueOf(file.body);
                    attachment.ParentId = inbMsg.id;
                    attList.add(attachment);                 
            }
        }
                     
      if ( attList.size() > 0 ) {           
	        try {
	  			 insert attList;
		  	}
		  	catch (Exception ex) {
		  		ErrorLogUtil.insertLog('LicenseRequestEmailService', ex.getMessage(), 'LicenseRequestEmailService.addInboundMessage Attachments'); 
		  		return;
		  	}  
      }     
      return;
  }
  
  private String parseAddrLst(List<String> inAddrLst)  {
  	   List<String> cleanAddrLst  = new List<String>();
  	   String retAddrStr = '';
  	   
  	   if ( inAddrLst != null )  {
        	for ( String addr : inAddrLst ) {
        		if ( !addr.endsWithIgnoreCase('salesforce.com') )
        		   cleanAddrLst.add(addr);
        	}
        	if ( !cleanAddrLst.isEmpty() ) {
               String fullStr = String.join(cleanAddrLst, ' ');
               retAddrStr = fullStr.length() > 3990 ? fullStr.substring(0, 3990) : fullStr;
        	}       	
        }
        
        return retAddrStr; 	   
  }
                  
}