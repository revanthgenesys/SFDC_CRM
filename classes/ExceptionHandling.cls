public class ExceptionHandling {
    
    public static string ExceptionHandling(Exception objException){
        //ErrorLogUtil.insertLog('SubscriptionAutoRenewal', 'Error from method SubscriptionAutoRenewal: ' +  e.getMessage()+'\n'+e.getStackTraceString(), 'SubscriptionAutoRenewal.SubscriptionAutoRenewal()'); 
        String strmessage = 'Error has occurred during execution of code.The error message returned by the program is ' + objException.getMessage()+'\n'+ objException.getStackTraceString();
        System.debug('Exception Type:'+objException.getTypeName());
        if(objException.getTypeName() == 'System.DmlException'){
            strmessage +='\nThe exception was a DML Error.The Detials are:';
            for(Integer i = 0;i < objException.getNumDml(); i++){
                strmessage += '\nCause: ' +objException.getCause();
                strmessage += '\nLineNumber: ' +objException.getLineNumber();
                strmessage += '\nMessage: ' +objException.getMessage();
                strmessage += '\nStackTraceString: ' +objException.getStackTraceString();
                strmessage += '\nTypeName: ' +objException.getTypeName();
                strmessage += '\nDmlFieldNames: ' +objException.getDmlFieldNames(i);
                strmessage += '\nDmlFields: ' +objException.getDmlFields(i);
                strmessage += '\nDmlIndex: ' +objException.getDmlIndex(i);
                strmessage += '\nDmlMessage: ' +objException.getDmlMessage(i);
                strmessage += '\nDmlStatusCode: ' +objException.getDmlStatusCode(i);
                strmessage += '\nDmlType: ' + objException.getDmlType(i);
                strmessage += '\nNumDml: ' +objException.getNumDml()+'\n';
            }
            
            
        }
   return strmessage;}
   
}