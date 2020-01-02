/***************************************************************************************************
* 
*  Class Name      :   CaseTriggerHandler
*  Description     :   This class is used to define the method for CaseTrigger.trigger.
*  Auther          :   R Systems
* 
****************************************************************************************************/
 
public with sharing class CaseTriggerHandler {
    
    // To avoid recursion of Trigger Excucation
    public static Boolean stopRecursion = true;
    /**
    *   Method Name :   afterInsert()
    *   Description :   This method used to insert Source Account record based on the GS Relationship record.
    *   Parameters  :   mapNewCase => Map of New inserted records.
    **/
    public static void afterCaseUpdateupdatePkgSrv(Map<Id, Case> mapNewCase,  Map<Id, Case> mapOldCase){
    
        // Get set of all case Ids where status is closed and recordtypename  is PureSuccess Services
        Set<Id> setCaseIds = new Set<Id>();
        
        // Map to keep the Case Id to related package Services
        Map<Id, List<Package_Services__c>> mapCaseToPackageServices = new Map<Id, List<Package_Services__c>>();
    
        // Get set of all case Ids where Services are not found
        Set<String> setCaseIdsNotService = new Set<String>();
        
         // List to update the related Service to Consumed
        List<Package_Services__c> lstPackageServicesUpdate  = new List<Package_Services__c>();
        
        
        //Get the list of Case which has been updated.
        for(Case c : mapNewCase.values()){
            // check the current record Type name
            String recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordtypeid).getname();
            
            if(recordtypename == 'PureSuccess Services' && c.Status != mapOldCase.get(c.Id).Status && c.Status == 'Closed'){
                setCaseIds.add(c.Id);
            }
        }
        
        System.debug('PP Case Set Id==='+setCaseIds);
        // Get Package Service related to the Case
        
        List<Package_Services__c> lstPackageServices = [Select Id, Case__c, Status__c from Package_Services__c where Case__c In: setCaseIds];
        
        for(Package_Services__c service : lstPackageServices){
            if(mapCaseToPackageServices.containskey(service.Case__c)){
                List<Package_Services__c> lstPack = mapCaseToPackageServices.get(service.Case__c);
                lstPack.add(service);
                mapCaseToPackageServices.put(service.Case__c, lstPack);
            }else{
                List<Package_Services__c> lstPack = new List<Package_Services__c>();
                lstPack.add(service);
                mapCaseToPackageServices.put(service.Case__c, lstPack);
            }
        }
        
        System.debug('PP  PackageService Id==='+mapCaseToPackageServices);
        for(Case c : mapNewCase.values()){
            
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
                    if(c.AccountID != null){
                        String key = String.valueOf(C.Id).substring(0, 15) + String.valueOf(c.AccountID).substring(0, 15);
                        setCaseIdsNotService.add(key);
                    }
                }
            }
        }
        if(lstPackageServicesUpdate.size() > 0 ){
            update lstPackageServicesUpdate;
        }
        
    }
    
    
    
   /* public static void afterUpdate(Map<Id, Case> mapNewCase,  Map<Id, Case> mapOldCase){
        
        // Get set of all case Ids where status is closed and recordtypename  is PureSuccess Services
        Set<Id> setCaseIds = new Set<Id>();
        
        // Get set of all case Ids where Services are not found
        Set<String> setCaseIdsNotService = new Set<String>();
        
        // Get set of all Token Ids
        Set<String> setProductGroupIds  = new Set<String>();
        
        // Get set of Package Services
        Set<Id> setPackageIds  = new Set<Id>();
        
        // Map to keep the Case Id to related package Services
        Map<Id, List<Package_Services__c>> mapCaseToPackageServices = new Map<Id, List<Package_Services__c>>();
        
        // Map to keep the Product Group To Package
        Map<String, List<Pure_Success_Package__c>> mapProductGrouptoPackage = new Map<String, List<Pure_Success_Package__c>>();
        
        // List to update the related Service to Consumed
        List<Package_Services__c> lstPackageServicesUpdate  = new List<Package_Services__c>();
        
        // List to Package Service to be Insert
        List<Package_Services__c> lstPackageServicesInsert  = new List<Package_Services__c>();
        
        // List to Package Service to be Insert
        List<Pure_Success_Package__c> lstPackageInsert  = new List<Pure_Success_Package__c>();
        
        
        for(Case c : mapNewCase.values()){
            // check the current record Type name
            String recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordtypeid).getname();
            
            if(recordtypename == 'PureSuccess Services' && c.Status != mapOldCase.get(c.Id).Status && c.Status == 'Closed'){
                setCaseIds.add(c.Id);
            }
            else
            {
                return;
            }
        }
        
        // Get Package Service related to the Case
        
        List<Package_Services__c> lstPackageServices = [Select Id, Case__c, Status__c from Package_Services__c where Case__c In: setCaseIds];
        
        for(Package_Services__c service : lstPackageServices){
            if(mapCaseToPackageServices.containskey(service.Case__c)){
                List<Package_Services__c> lstPack = mapCaseToPackageServices.get(service.Case__c);
                lstPack.add(service);
                mapCaseToPackageServices.put(service.Case__c, lstPack);
            }else{
                List<Package_Services__c> lstPack = new List<Package_Services__c>();
                lstPack.add(service);
                mapCaseToPackageServices.put(service.Case__c, lstPack);
            }
        }
        
        
        for(Case c : mapNewCase.values()){
            
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
                    if(c.AccountID != null){
                        String key = String.valueOf(C.Id).substring(0, 15) + String.valueOf(c.AccountID).substring(0, 15);
                        setCaseIdsNotService.add(key);
                    }
                }
            }
        }
        if(lstPackageServicesUpdate.size() > 0 ){
            update lstPackageServicesUpdate;
        }
        // If no Services found then go to next step
        if(setCaseIdsNotService.size() > 0){
            
            // Get Token Allocations
            List<Token_Allocations__c> lstTokenAllocation = [Select Id, Account__c, Case__c, CaseAccount__c, Product__c, Product_Group__c, Product_Group_Item__r.Product__c, Product_Group_Item__r.Product__r.Name, Product_Group_Item__c from Token_Allocations__c where CaseAccount__c In: setCaseIdsNotService];
            for(Token_Allocations__c token : lstTokenAllocation){
                if(token.Product_Group__c != null && token.Account__c != null){
                    String key = String.valueOf(token.Product_Group__c).substring(0, 15) + String.valueOf(token.Account__c).substring(0, 15);
                    setProductGroupIds.add(key);
                }
            }
            //  Get Pure success Packages  related to Token Allocations 
            List<Pure_Success_Package__c> lstPureSuccessPackage = [Select Id, Account__c, Product_Group__c, Product_Group_Item__r.Product__c,Product_Group_To_Account__c from Pure_Success_Package__c where Product_Group_To_Account__c In :setProductGroupIds];
            
           
            for(Pure_Success_Package__c packs : lstPureSuccessPackage){
               
                if(mapProductGrouptoPackage.containskey(packs.Product_Group_To_Account__c)){
                    List<Pure_Success_Package__c> lstPack = mapProductGrouptoPackage.get(packs.Product_Group_To_Account__c);
                    lstPack.add(packs);
                    mapProductGrouptoPackage.put(packs.Product_Group_To_Account__c, lstPack);
                }else{
                    List<Pure_Success_Package__c> lstPack = new List<Pure_Success_Package__c>();
                    lstPack.add(packs);
                    mapProductGrouptoPackage.put(packs.Product_Group_To_Account__c, lstPack);
                }
            }
             // Check for the Package record related to Token Allocations
            
            for(Token_Allocations__c token : lstTokenAllocation){
                String key = String.valueOf(token.Product_Group__c).substring(0, 15) + String.valueOf(token.Account__c).substring(0, 15);
                // If Package is available then do not create the Package other wise create the Package
                if(mapProductGrouptoPackage.containskey(key)){
                    for(Pure_Success_Package__c packS : mapProductGrouptoPackage.get(key)){
                        Package_Services__c  packageService = new Package_Services__c();
                        packageService.PureSuccess_Package__c = packS.Id;
                        packageService.Status__c = 'Allocated';
                        packageService.Name = token.Product_Group_Item__r.Product__r.Name;
                        packageService.Product__c = token.Product_Group_Item__r.Product__c;
                        packageService.Product_Group__c = token.Product_Group__c;
                        lstPackageServicesInsert.add(packageService);
                    }
                }else{
                    // Create Success Package record
                    Pure_Success_Package__c successPackage = new Pure_Success_Package__c();
                    successPackage.Account__c = token.Account__c;
                    successPackage.Product__c = token.Product_Group_Item__r.Product__c;
                    successPackage.Product_Group__c = token.Product_Group__c;
                    successPackage.Token_Status__c = 'Allocated';
                    lstPackageInsert.add(successPackage);
                }
            }
            if(lstPackageInsert.size() > 0){
                insert lstPackageInsert;
                for(Pure_Success_Package__c packs : lstPackageInsert){
                    setPackageIds.add(packs.Id);
                }
             }
            
            if(setPackageIds.size() > 0){
                // Create for Pure Success Services  for newly created Pure Success Packages
                for(Pure_Success_Package__c packS : [Select Id, Product__c, Product_Group__c, Product__r.Name from Pure_Success_Package__c where ID in : setPackageIds]){
                    Package_Services__c  packageService = new Package_Services__c();
                    packageService.PureSuccess_Package__c = packS.Id;
                    packageService.Status__c = 'Allocated';
                    packageService.Name = packS.Product__r.Name;
                    packageService.Product__c = packS.Product__c;
                    packageService.Product_Group__c = packS.Product_Group__c;
                    lstPackageServicesInsert.add(packageService);
                }
            }
            
            if(lstPackageServicesInsert.size() > 0 ){
                insert lstPackageServicesInsert;
            }
         }
         stopRecursion = false;
    }*/
    
}