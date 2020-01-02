global class CaseUpdateInboundEmail implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
 
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
  
    String myPlainText= '';
    
    // Add the email plain text into the local variable 
    myPlainText = email.plainTextBody;
   
    // New Task object to be created
    Genesys_Case_Updates__c[] caseUpdate = new Genesys_Case_Updates__c[0];

    Case caseRecord = [Select Id from Case where CaseNumber='00409518' LIMIT 1];
   
    try {
      
      // Add a new Caese Update Record.
      caseUpdate.add(new Genesys_Case_Updates__c(Communication_Details__c =  myPlainText,
           Description__c = myPlainText,
           Case__c = caseRecord.Id));
     
     // Insert the new CaseUpdate 
     insert caseUpdate;    
     
     System.debug('New Case Update Object: ' + caseRecord );   
    }

   catch (QueryException e) {
       System.debug('Query Issue: ' + e);
   }
   
   // Set the result to true. No need to send an email back to the user 
   // with an error message
   result.success = true;
   
   // Return the result for the Apex Email Service
   return result;
  }
}