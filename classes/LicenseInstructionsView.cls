public class LicenseInstructionsView {
	 
	 public Account_Licensing_Instructions__c licInstr {get; set;}
	 public Boolean displayInstr {get; set;}
	 	 
	 public LicenseInstructionsView (ApexPages.StandardController stdController)  {
          ID licRecId = stdController.getId();
          
          displayInstr = false;
          licInstr = new Account_Licensing_Instructions__c();
          
          if ( licRecId != null )  {       	
          	 List<Account_Licensing_Instructions__c> liLst = 
          	      [SELECT Licensing_Instructions__c, Name, Id
          	         FROM Account_Licensing_Instructions__c 
          	        WHERE Account__c IN (SELECT End_User__c FROM License_Request__c WHERE Id = :licRecId)];
          	        
          	  if ( !liLst.isEmpty() ) {
          	      licInstr = liLst[0];
          	      displayInstr = true;
          	  }
          }
          
	 }
}