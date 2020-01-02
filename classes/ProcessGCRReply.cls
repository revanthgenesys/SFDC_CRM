global class ProcessGCRReply implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    	Messaging.InboundEnvelope envelope) {
    	Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
	    String subToCompare = 'Legal Request -';
	    if(email.subject.contains(subToCompare)){
	        System.debug('Testing' + email.subject.indexOf(subToCompare));
	        Integer index = email.subject.indexOf(subToCompare);
	        String GCRName = email.subject.substring(index);	        
	        List<GCR__c> GCRobjList = [Select id from GCR__c where name =: GCRName LIMIT 1];        
        	if(GCRobjList.size() == 1){
        		if(email.plainTextBody != '' && email.plainTextBody != null){
	                Note newnote = new Note();
	                newnote.body = email.plainTextBody;
	                newnote.ParentId = GCRobjList[0].id;
	                newnote.title = 'Email Comment';
	                try{
	                    insert newnote;
	                    GCR__c gcrToBeUpdated = new GCR__c (id = GCRobjList[0].id);
	                    gcrToBeUpdated.New_Action__c = true;
	                    update gcrToBeUpdated;
	                }
	                catch(Exception e){
	                    System.debug('The exception is' + e);
	                }
	            }
    		}
  		}
  		else{
  			String htmlBody = 'Your email was not submitted successfully. Please check format of the subject.';
  			SendEmail.sendSingleEmail(email.fromAddress , 'Error ' + email.subject, htmlBody);
  		}
	    result.success = true;
        return result;
    }
}