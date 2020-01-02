public class FutureCallOuts {

	@Future(callout=true)
	public static void callMoveFtpDir( ID n_eu, 
									   String cs_num, 
									   ID n_st, 
								       ID o_eu, 
								       ID o_st) { 
								       	
      Account ac_oeu;
      Account ac_neu;
      Account ac_ost;
      Account ac_nst; 								       	
		
	  try {						
      		ac_oeu = [Select SAP_Account_Code__c From Account where ID= :o_eu];
      		ac_neu = [Select SAP_Account_Code__c From Account where ID= :n_eu];
      		ac_ost = [Select SAP_Account_Code__c From Account where ID= :o_st];
      		ac_nst = [Select SAP_Account_Code__c From Account where ID= :n_st];
	  }
	  catch (Exception e) {
	  		return;
	  } 
	  	  	  
	  String new_euSap = ac_neu.SAP_Account_Code__c;
      String old_euSap = ac_oeu.SAP_Account_Code__c;
      String new_stSap = ac_nst.SAP_Account_Code__c;
      String old_stSap = ac_ost.SAP_Account_Code__c;  
      
	  FTP_Setting__c ftpus = FTP_Setting__c.getInstance('User');
	  String user = ftpus.Value__c;      	
      FTP_Setting__c ftpp = FTP_Setting__c.getInstance('Pwd');
      String pwd = ftpp.Value__c;

	  ftp.FTPFolderPort stub = new ftp.FTPFolderPort();
				
	  stub.Security = new ftp.Security_element();
	  stub.Security.UsernameToken = new ftp.UsernameToken_element();
	  stub.Security.UsernameToken.Username = user;
	  stub.Security.UsernameToken.Password = pwd;
	
	
	   ftp.CreateFTPFolder_Move_Output_element retcode = stub.Move( new_euSap,
                   	  								 				cs_num,
                   	  								 				new_stSap,
                   	  								 				old_euSap,
                   	  								 				old_stSap);	  
	}

}