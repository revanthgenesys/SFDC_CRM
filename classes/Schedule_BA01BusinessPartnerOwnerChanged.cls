global class Schedule_BA01BusinessPartnerOwnerChanged implements Schedulable{

    	
//EXECUTE
global void execute(SchedulableContext sc) {
	Util.myLog('START Schedule_BA01BusinessPartnerOwnerChanged.execute()');
     //set Query
	List<Account> BA01Accounts = new List<Account>();
	BA01Accounts = [select a.Id, a.Name From Account a where a.ToBeTreatedByBA001__c = True];
		
	if(BA01Accounts.size() > 0)
	{
	    BA01BusinessPartnerOwnerChanged batchBPTest = new BA01BusinessPartnerOwnerChanged('BATCH_FROM_BA001_ACCOUNT__BUSINESS_PARTNER_CHANGE_OWNER',BA01Accounts);
		//execute Batch
	  	Id batchIdBA01 = Database.executeBatch(batchBPTest, Integer.valueOf(System.Label.BA01_QueryLocatorMaxSize));
	}
	//NO BP TO TREAT
	else
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		//Prepare Corps de l'email
		 String emailMessage = '';
		 emailMessage += '<br /> Task started:' + DateTime.Now();
	     emailMessage += '<br /> Task ended:' + DateTime.Now(); 
	 	 emailMessage += '<br /> Result : \n 0 Jobs';
	 	 emailMessage +=' <br />';
		 emailMessage += '<br /> Aucun Business Partner à traiter (Tous les comptes ont le champ "ToBeTreatedByBA001__c" non cochés)';
		//Prepare destinataires
		User currentUser = [Select Id, Email from User where Id =: UserInfo.getUserId() limit 1];
		String[] toAddresses = new String[] {currentUser.Email};
	    if(System.Label.BA01_EmailDest != '' && System.Label.BA01_EmailDest != null)
	     	toAddresses.add(System.Label.BA01_EmailDest);
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setBccSender(false);
		mail.setUseSignature(false);
		// Specify the address used when the recipients reply to the email. 

		mail.setSenderDisplayName('Batch Job Summary');
		mail.setSubject('BA01BusinessPartnerOwnerChanged Report [BATCH_FROM_BA001_ACCOUNT__BUSINESS_PARTNER_CHANGE_OWNER]');
		
		mail.setPlainTextBody(emailMessage);
		mail.setHtmlBody(emailMessage.replace('\\n', '<br />'));
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
  	Util.myLog('END Schedule_BA01BusinessPartnerOwnerChanged.execute()'); 
} 
}