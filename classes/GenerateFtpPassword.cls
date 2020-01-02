public class GenerateFtpPassword {
	
	public static String GenPasswd() {
		
	String PASSWDCHARS = '_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
	Integer PASSWDLENGTH = 8;
    Integer i = 0;
	Integer rand = 0;
	Integer retCode = 0;
	String  pswd = '';

   		for (i=0; i < PASSWDLENGTH; i++)  {
  		
       		rand = Math.round( 61 * Math.random() );  
       		pswd = pswd + PASSWDCHARS.substring( rand, rand+1 );       			
   		}
   			    			
   		return pswd;	  			
	}
	
	static testMethod void testFtpPassw()  {
		
		String pw = GenerateFtpPassword.GenPasswd();		
		System.assertNotEquals(null, pw);	
	}
}