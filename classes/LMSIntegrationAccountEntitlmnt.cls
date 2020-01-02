@RestResource(urlMapping='/LMSIntegrationAccountEntitlmnt/*')
global class LMSIntegrationAccountEntitlmnt {
	
	@HttpPost
    global static LMSIintegrationService.AccountProductEntlmnt getAccountEntitlmnt (String AccntId ) {
    	   	
      	return new LMSIintegrationService.AccountProductEntlmnt(AccntId);
    }
}