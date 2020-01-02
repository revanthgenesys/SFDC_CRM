public class GenerateFtpGScredentials {

	public static String GenPasswd() {
	
	String PASSWDALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';	
	String PASSWDCHARS = '_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
	Integer PASSWDLENGTH = 10;
    Integer i = 0;
	Integer rand = 0;
	Integer retCode = 0;
	String  pswd = '';

        rand = Math.round( 50 * Math.random() );  
       	pswd = pswd + PASSWDALPHA.substring( rand, rand+1 );
       		
   		for (i=1; i < PASSWDLENGTH; i++)  { 		
       		rand = Math.round( 61 * Math.random() );  
       		pswd = pswd + PASSWDCHARS.substring( rand, rand+1 );       			
   		}
   			    			
   		return pswd;	  			
	}
	
	public static String GenFtpAccount(String csnum) {
		
		if ( csnum == null || csnum == '' )
		     return 'ERROR';

    	Integer ext =  Math.round(Math.random()*(99-10)+10);
    	String  acct = 'ftp' + csnum + '-' + ext;
    	
   		return acct;	  				
	}
}