trigger trigDocuSignStatus on dsfs__DocuSign_Status__c (after update) {
    Map<Id,dsfs__DocuSign_Status__c> mapDocuSignStatus = new Map<Id,dsfs__DocuSign_Status__c>();
 
    for(dsfs__DocuSign_Status__c docSignStatus:trigger.new){
    //Check when status is changed to Completed from Non Completed value 
    
    if(docSignStatus.dsfs__Envelope_Status__c =='Completed' && 
         trigger.OldMap.get(docSignStatus.id).dsfs__Envelope_Status__c != 'Completed'){ 
        mapDocuSignStatus.put(docSignStatus.id,docSignStatus);       
    }
   }
   
   //Check if map is Non-Empty
   if(!mapDocuSignStatus.isEmpty())
       //new ctrlDocuSignHandler().createGCRRequests(mapDocuSignStatus);
       new ctrlDocuSignHandler().insertDocusignAttachments(trigger.new[0].id);


}