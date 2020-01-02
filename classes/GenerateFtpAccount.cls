public class GenerateFtpAccount {
	
	public static String GenFtpAccount() {
		
		String  acct = '';

    	FTP_Setting__c sequ = FTP_Setting__c.getInstance('AccountSequence');
    	String nextnum = sequ.Value__c;   
       		
    	String strnum = '00000' + nextnum;    
    	acct = 'se' + strnum.substring( strnum.length() - 6 );
  
    	sequ.Value__c = String.valueOf( Integer.valueOf(strnum) + 1 );   
    	update sequ;
    	
   		return acct;	  				
	}
	
	@isTest (SeeAllData=true)	
	static void testFtpAccount()  {
		
		String acc = GenerateFtpAccount.GenFtpAccount();		
		System.assertNotEquals(null, acc);	
	}
}