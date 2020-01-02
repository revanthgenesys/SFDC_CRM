public class CaseAutoFollowUpNotificationFactory {

	public CaseAutoFollowUpNotification createCaseAutoFollowUpNotification(Case caseToSend) {
		Integer daysPast = daysBetween(caseToSend.Auto_Follow_up_Start_Date__c);
		
		/// Status = Awaiting Info applicable to non-FR cases, Sub Status = Info Required from Customer is applicable to FRs only
		if ( caseToSend.Status == 'Awaiting Info' || caseToSend.Sub_Status__c == 'Info Required From Customer' ) {
			 			 
		    if  ( daysPast == 2 ) 
			   return new CaseAutoFollowUpNotification.CaseAFAwInfoFirst(caseToSend);
			   
			else if  ( daysPast == 5 ) 
			   return new CaseAutoFollowUpNotification.CaseAFAwInfoSecond(caseToSend);
			   
			else if  ( daysPast == 10 ) 
			   return new CaseAutoFollowUpNotification.CaseAFAwInfoThird(caseToSend);
			   
			else
			    return null;			
		}
		else if ( caseToSend.Status == 'Solution Proposed' || caseToSend.Status == 'Replied' ||
		          (caseToSend.Sub_Status__c == 'Solution Proposed' &&  caseToSend.Status == 'Open - Customer Care') ) {
			
			if  ( daysPast == 2 ) 					         
				return new CaseAutoFollowUpNotification.CaseAFSolPrpFirst(caseToSend);
			
			else if  ( daysPast == 5 ) 					         
				return new CaseAutoFollowUpNotification.CaseAFSolPrpSecond(caseToSend);
				
			else if  ( daysPast == 10 ) 					         
				return new CaseAutoFollowUpNotification.CaseAFSolPrpThird(caseToSend);
				
		    else
		        return null;
		}
	
		else		
			return null;
		
	}
	
    Integer daysBetween(Datetime startDate) {	    
	    Datetime endDate = datetime.now();    
	    Integer i = 0;
	    
	    if ( startDate == null)
	        return 0;
	        
	    startDate = startDate.addDays(1);  ///skip day 1	    
   	    while ( startDate < endDate && !startDate.isSameDay(endDate) ) {
 	    	
   	    	if (startDate.format('EEE') != 'Sat' && startDate.format('EEE') != 'Sun') {
            	 i++;
        	}       	
        	startDate = startDate.addDays(1);
    	}
    	return i;
	}
}