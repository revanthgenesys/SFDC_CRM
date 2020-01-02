/*
   Mariya Steason - November 14, 2018
   Class to handle inbound emails sent to the Guru Mentoring team
   Test: GuruMentoringEmailService_Test
*/
global class GuruMentoringEmailService implements Messaging.InboundEmailHandler {
	
    private String TEXT_TO_LONG = ' [The message is too long to display. To view full version please open this message in outlook.] ';
	
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        try  {

              Guru_Mentoring__c guru = new Guru_Mentoring__c();

              String embody = String.isBlank(email.plainTextBody) ? email.htmlBody : email.plainTextBody;
              String stLRId = getReId(embody);
                     
              Boolean GuruNotfound = false;
              if ( String.isNotBlank(stLRId) ) {
                     List<Guru_Mentoring__c> guruLst = [SELECT id, Status__c, Sub_Status__c, Contact_Email__c   
                                                        FROM Guru_Mentoring__c WHERE id =: stLRId];
                     if ( !guruLst.isEmpty() )  {                     
                           updateLR(guruLst[0]);
                           addInboundMessage( stLRId, email);
                     }
                     else
                         GuruNotfound = true;
              }
              
              if ( String.isBlank(stLRId) || GuruNotfound ) {                   	
                    Guru_Mentoring__c gm = insertNewGuruRec(email);                     
                    if ( gm != null )
                         addInboundMessage( gm.Id, email);
              }                   
        }
        catch (Exception ex)  {
           ErrorLogUtil.insertLog('GuruMentoringEmailService', 'Subject: ' +  email.Subject + '  ' +  ex.getMessage(), 'GuruMentoringEmailService.handleInboundEmail');     
           result.success = true;  /// no need to bounce back to sender
        }
               
        return result;
    }
    
  private void updateLR(Guru_Mentoring__c guru )  {   

      guru.Status__c = 'Open';
      guru.Sub_Status__c = 'Update Received';     
     
       update guru; 
      return;
  }
  
  private Guru_Mentoring__c insertNewGuruRec (Messaging.InboundEmail email) {
  	
  	Guru_Mentoring__c guru = new Guru_Mentoring__c();
 
  	guru.Status__c = 'Open';
  	guru.Sub_Status__c = 'New';
  	guru.Subject__c = email.Subject.length() > 253 ? email.Subject.substring(0,253) : email.Subject;
  	
  	if ( email.plainTextBody != null )
      		guru.Description__c = email.plainTextBody.length() > 100000 ? TEXT_TO_LONG + email.plainTextBody.substring(0,100000) + TEXT_TO_LONG : email.plainTextBody;
    else if ( email.htmlBody != null )
      		guru.Description__c = email.htmlBody.length() > 100000 ?  + TEXT_TO_LONG + email.htmlBody.substring(0,100000) + TEXT_TO_LONG : email.htmlBody;

  	guru.Contact_Email__c = email.fromAddress;
  	guru.Contact_Name__c = email.fromName;
 
  	try {
  		insert guru;
  	}
  	catch (Exception ex) {
  		ErrorLogUtil.insertLog('GuruMentoringEmailService', 'Subject: ' +  email.Subject + '  ' + ex.getMessage(), 'GuruMentoringEmailService.insertEmailTypeRequest'); 
  		return null;
  	}
  	
  	return guru;
  }
       
  private String getReId(String strEmailBody) {
  	  	
  	    if ( String.isBlank(strEmailBody) )
  	        return null;
  	        
  	    String strDSId = '';
        Integer intStartIndex = strEmailBody.indexOf('refer:');            
        Integer intLastIndex = intStartIndex >= 0 ? strEmailBody.lastIndexOf(':ref', intStartIndex + 25) : 0;  
        
        if ( intStartIndex >= 0 && intLastIndex > 0 )  
      		 strDSId = strEmailBody.substring(intStartIndex + 6, intLastIndex);
      		  
        if ( strDSId.length() == 18 )
             return strDSId;
        else
            return null;
  } 
  
  private void addInboundMessage (string guruRid, Messaging.InboundEmail email) { 
  	    ///Bypass trigger set for processing Email-To-Case
  	    Util.Bypass_Trigger_Chk = true;
  	    
        EmailMessage inbMsg = new EmailMessage();
        inbMsg.RelatedToId = guruRid;
        inbMsg.Subject = email.Subject.length() > 253 ? email.Subject.substring(0,253) : email.Subject;
 
        if ( email.plainTextBody != null )  
      		  inbMsg.TextBody = email.plainTextBody.length() > 100000 ? TEXT_TO_LONG + email.plainTextBody.substring(0,100000) + TEXT_TO_LONG : email.plainTextBody;
        if ( email.htmlBody != null ) 
      		  inbMsg.HtmlBody = email.htmlBody.length() > 100000 ? TEXT_TO_LONG + email.htmlBody.substring(0,100000) + TEXT_TO_LONG : email.htmlBody;

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
	  		ErrorLogUtil.insertLog('GuruMentoringEmailService', 'GURU ID: ' + guruRid + '  ' + ex.getMessage(), 'GuruMentoringEmailService.addInboundMessage'); 
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
		  		ErrorLogUtil.insertLog('GuruMentoringEmailService', ex.getMessage(), 'GuruMentoringEmailService.addInboundMessage Attachments'); 
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