global class WorkspaceConnectorBAController {
   
    @RemoteAction
    global static Case findCaseFromNumber(String num)
    {
        system.debug('[WSC] findCaseFromNumber using  ' + num);       
        try {
           List<Case> cases = [SELECT CaseNumber FROM Case WHERE CaseNumber= :num];            
           if(!cases.isEmpty()) {
               // return the first case found (should only be one)                            
               for (Case c : cases) {
                   return c;
               } 
           }
        } catch(QueryException e){
            return null; 
        }
        return null; 
    }
 

    
    @RemoteAction
    global static Support_Product__c getProductFromName(String product)
    {
        system.debug('[WSC] getProducFromId using  ' + product);       
        try {
           List<Support_Product__c> products = [SELECT Id FROM Support_Product__c WHERE Name= :product];            
           if(!products.isEmpty()) {
               // return the first product found (should only be one)                            
               for (Support_Product__c p : products) {
                   return p;
               } 
           }
        } catch(QueryException e){
            return null; 
        }
        return null; 
    }
    


    @RemoteAction
    global static Object findObjectFromANI(String ANI)
    {
        system.debug('*** findObjectFromANIfor '+ANI);       
        try{
            List<Account> objects = [SELECT Id, Name, Phone FROM Account WHERE Phone = :ANI];
            if (!objects.isEmpty()){
              for (Account obj : objects){
                    system.debug('*** findObjectFromANI account = '+ obj.Id);
                    return obj;
              } 
            }                
            
            //try{
            List<Contact> cobjects = [SELECT Id, Name, Phone FROM Contact WHERE Phone = :ANI OR MobilePhone = :ANI];
            if (!cobjects.isEmpty()){
              for (Contact cobj : cobjects){
                    system.debug('*** findObjectFromANI contact = '+ cobj.Id);
                    return cobj;
              } 
            }                
            return null; 
            //}
            //catch(QueryException e){
            //    return null; 
            //}
        }
        catch(QueryException e){
            return null; 
        }        
    }
 

    @RemoteAction
    global static String getWorkspaceConnectorInfo(){
        system.debug('*** getWorkspaceConnectorInfo: '); 
        return 'not found';
    }    
    


    @RemoteAction global static String createActivity(Map<String,String> activityMap){
        system.debug('*** createActivity' );
        return 'not implemented';
     }   
 }