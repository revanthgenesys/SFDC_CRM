public with sharing class TokenFormController {
        
  @AuraEnabled
    public static void submitForm(String tf){
                
        try{
            // NOTE: SF model binding is bugged. Use JSON strings to pass in data.
            System.Debug('Nik>> tf value is :' + tf);
            TokenForm t = TokenForm.getFromString(tf);
            
            if(t.isValid()){        
                TokenFormHelper tfh = new TokenFormHelper();
                tfh.buildAndSendEmail(t);
            }
        } catch(Exception e) { 
            System.debug(e); 
        }
    }
}