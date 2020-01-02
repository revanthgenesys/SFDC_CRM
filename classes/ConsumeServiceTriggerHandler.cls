/***************************************************************************************************
* 
*  Class Name      :   ConsumeServiceTriggerHandler 
*  Description     :   This class is used to update Service Element status when record is closed
*  Auther          :   R Systems
* 
****************************************************************************************************/
 
public class ConsumeServiceTriggerHandler {
    
    public static void afterStatusClosedUpdatePkgSrv(Map<Id, Consume_Service__C> mapNewCase,  Map<Id, Consume_Service__C> mapOldCase){
    
        // Get set of all case Ids where status is closed and recordtypename  is PureSuccess Services
        Set<Id> setCaseIds = new Set<Id>();
        
        // Map to keep the Case Id to related package Services
        Map<Id, List<Package_Services__c>> mapCaseToPackageServices = new Map<Id, List<Package_Services__c>>();
    
        // Get set of all case Ids where Services are not found
        Set<String> setCaseIdsNotService = new Set<String>();
        
         // List to update the related Service to Consumed
        List<Package_Services__c> lstPackageServicesUpdate  = new List<Package_Services__c>();
        
        List<Consume_Service__C> objCS = new List<Consume_Service__C>();
        //Get the list of Case which has been updated.
        for(Consume_Service__C c : mapNewCase.values()){
            // check the current record Type name
            //String recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordtypeid).getname();
            
            if(c.Status__c != mapOldCase.get(c.Id).Status__c && c.Status__c == 'Closed')
            {
                Consume_Service__C obj = new Consume_Service__C(); 
                setCaseIds.add(c.Id);
                obj.ID = c.ID;
                obj.Closed_Date__C = system.today();
                obj.Closed_By__c = UserInfo.getUserId();
                objCS.add(obj);
            }
        }
        
        System.debug('PP Case Set Id==='+setCaseIds);
        // Get Package Service related to the Case
        
        List<Package_Services__c> lstPackageServices = [Select Id, Case__c,Consume_Service__C, Status__c from Package_Services__c where Consume_Service__C In: setCaseIds];
        
        for(Package_Services__c service : lstPackageServices){
            if(mapCaseToPackageServices.containskey(service.Case__c)){
                List<Package_Services__c> lstPack = mapCaseToPackageServices.get(service.Consume_Service__C);
                lstPack.add(service);
                mapCaseToPackageServices.put(service.Consume_Service__C, lstPack);
            }else{
                List<Package_Services__c> lstPack = new List<Package_Services__c>();
                lstPack.add(service);
                mapCaseToPackageServices.put(service.Consume_Service__C, lstPack);
            }
        }
        
        System.debug('PP  PackageService Id==='+mapCaseToPackageServices);
        
         
        for(Consume_Service__C c : mapNewCase.values()){
            
            
            // Flter the required records
            if(setCaseIds.contains(c.Id)){
                // Check if service found otherwise got to Next step
                if(mapCaseToPackageServices.containskey(c.Id)){
                    for(Package_Services__c pack : mapCaseToPackageServices.get(c.Id)){
                        Package_Services__c  packageService = new Package_Services__c();
                        packageService = pack;
                        packageService.Status__c = 'Consumed';
                        lstPackageServicesUpdate.add(packageService);
                    }
                }else{
                    if(c.Account__c != null){
                        String key = String.valueOf(C.Id).substring(0, 15) + String.valueOf(c.Account__c).substring(0, 15);
                        setCaseIdsNotService.add(key);
                    }
                }
            }
        }
        if(lstPackageServicesUpdate.size() > 0 ){
            update lstPackageServicesUpdate;
        }
        
        if(objCS.size()>0)
            update objCS; 
        
    }
    
    
    public static void updateServiceElementStatus(Map<Id, Consume_Service__C> consumeSerOldMap,  Map<Id, Consume_Service__C> consumeSerNewMap){
     
         
         System.debug('Inside updateServiceElementStatus' + consumeSerNewMap + consumeSerOldMap);
         
         //List of PackageService that will be updated
         List<Package_Services__c> packageSerList;
         
        // if(!consumeSerNewMap.isEmpty() && !consumeSerOldMap.isEmpty()){

             packageSerList = new List<Package_Services__c>();
             
             System.debug('Inside if' + consumeSerNewMap.values());
             
             for(Consume_Service__C conSerRec : consumeSerNewMap.values()){
                
                System.debug('@@conSerRec.Status__c ' + conSerRec.Status__c);
                
                System.debug('@@consumeSerOldMap.get(conSerRec.Id).Status__c ' + consumeSerOldMap.get(conSerRec.Id).Status__c);
                
                System.debug('@@conSerRec.Status__c != consumeSerOldMap.get(conSerRec.Id).Status__c ' + conSerRec.Status__c != consumeSerOldMap.get(conSerRec.Id).Status__c);
                
                
                // check the current record status for Cancelled Status
                if(conSerRec.Status__c != consumeSerOldMap.get(conSerRec.Id).Status__c && conSerRec.Status__c == 'Cancelled')
                {
                    //Updating related Package Service Status to Allocated
                    Package_Services__c packSerObj = new Package_Services__c();
                    
                    packSerObj.id = conSerRec.Service_Element__c;
                    
                    packSerObj.Status__c = 'Allocated';
                    
                    packageSerList.add(packSerObj);
                    
                    
                    System.debug('Inside updateServiceElementStatus packageSerList ' + packageSerList);
                }
            }
            
            
            if(packageSerList.size() > 0){
            
                try{
                
                    update packageSerList;
                
                }catch(DMLException exp){}
            
            
            }
     
       // }     
    }
   
    
}