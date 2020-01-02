global class CaseEmailPublisherLoader  implements QuickAction.QuickActionDefaultsHandler {

/* This class is specific to case feed Email action. Set as an option on Case -> Support Settings

*/
 
    global CaseEmailPublisherLoader() {}
   
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
       
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
       
        for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && 
               defaults.get(j).getTargetSObject().getSObjectType() == EmailMessage.sObjectType && 
               defaults.get(j).getActionName().equals('Case.Email') && defaults.get(j).getActionType().equals('Email')) {
               	
                   sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                   break;
            }
        }
        
        if (sendEmailDefaults != null) {
        	
        	 EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();    
             ID caseId;
             
             try {
	             caseId = sendEmailDefaults.getContextId();
	             if ( caseId != null )  {
	             	List<Case> csl = [SELECT CaseNumber, Subject FROM Case WHERE id = :caseId];
	             	if ( !csl.isEmpty() )
	             	   emailMessage.Subject = 'Case# ' + csl[0].CaseNumber + ' - ' + csl[0].Subject;
	             }
	             
	             CaseMgmtEmailingService.CaseEmailRecipient emServ = new CaseMgmtEmailingService.CaseEmailRecipient(caseId);
	             
	             List<String> toaddrs = new List<String>();
	             if ( emServ.ContactAddr.size() > 0 )
	                 toaddrs.add(emServ.ContactAddr[0]);
	                 
	             if (  emServ.ExternalDistrAddrList.size() > 0 )
	                toaddrs.addAll(emServ.ExternalDistrAddrList);
	                
	             emailMessage.ToAddress = toaddrs.size() > 0 ? String.join(toaddrs, ', ') : '';
	             
	          //   emailMessage.ToAddress = emServ.ContactAddr.size() > 0 ?  emServ.ContactAddr[0] : '';
	            
	           //  emailMessage.CcAddress = emServ.ExternalDistrAddrList.size() > 0 ?  String.join(emServ.ExternalDistrAddrList, ', ') : '';
	             	           
	             emailMessage.BccAddress = emServ.InternalDistribAddrList.size() > 0 ?  String.join(emServ.InternalDistribAddrList, ', ') : '';	             	             
	             
             }
             catch (Exception e) {
                 ErrorLogUtil.insertLog('CaseEmailPublisherLoader', 'Error setting up Email recipients for case Id <>' +  caseId +
			                       '>.  ' + e.getMessage(),  'CaseMgmtEmailingService.processEmailRequest');    
             }
        }
    }
}