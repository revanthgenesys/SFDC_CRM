/***************************************************************************************************
* 
*  Class Name      :   OrderTriggerHandler
*  Description     :   This class is used to define the method for OrderTrigger.trigger.
*  Auther          :   R Systems
* 
****************************************************************************************************/

public with sharing class OrderTriggerHandler {
    
    public static void afterInsertUpdate(Map<Id, Order__c> newMapOrder, Map<Id, Order__c> oldMapOrder){
        try{
            // Set of Opportunity Account Ids
            Set<Id> oppAccountIds = new Set<Id>();
            // Map to maintain the Account and Order
            Map<Id, Order__c> accountToOrder = new Map<Id, Order__c>();
            // Map to maintain the Source Account to Account
            Map<Id, List<SourceAccounts__c>> mapAccountToSourceAccount = new Map<Id, List<SourceAccounts__c>>();
            // set of Order Ids where Order is submitted
            Set<Id> orderID = new Set<Id>();
            // List of Source Account to be insert
            List<SourceAccounts__c> lstInsertSA = new List<SourceAccounts__c>();
            
            System.debug('It is inside OrderTrigger Handler Class');
            
            for(Order__c ord : newMapOrder.values()){
                System.debug('PP Value of Order need to be updated '+ ord.status__c);
                if(oldMapOrder != null){
                    if(ord.Status__c != oldMapOrder.get(ord.id).status__c && ord.Status__c == 'Approved' && ord.Opportunity__c != null){
                        orderID.add(ord.Id);
                    }
                }
                else if(ord.status__c == 'Approved' && ord.Opportunity__c != null){
                    System.debug('PP1 Value of Order need to be updated '+ ord);
                    orderID.add(ord.Id);
                }
                 if(oldMapOrder != null){
                    if((ord.Status__c != oldMapOrder.get(ord.id).status__c) && ord.Status__c == 'Completed' && ord.NRO_Type__c == 'Service Element Use')
                    {
                        UpdatePackageServiceStatus(String.valueOf(ord.Id));
                    }
                }
            }
            
            
            if(orderID.size() > 0){
            
                Map<Id, Order__c> mapOrder = new Map<Id, Order__c>([Select  Id, 
                                                                            Status__c, Opportunity__c, 
                                                                            Opportunity__r.Account.Id, 
                                                                            Opportunity__r.Account.Name, 
                                                                            Opportunity__r.Lines_of_Businesses__c, 
                                                                            Opportunity__r.Offering_Detail__c, 
                                                                            Opportunity__r.Primary_Line_of_Business__c, 
                                                                            Opportunity__r.Sold_To_Country__c
                                                                            from Order__c
                                                                            where Id In: OrderId]);
                for(Order__c ord :mapOrder.Values()){
                    OppAccountIds.add(ord.Opportunity__r.Account.Id);
                    accountToOrder.put(ord.Opportunity__r.Account.Id, ord);
                }
                system.debug('11111  '+ accountToOrder);
                // Get all the Source Acocunt where Opportunity Account is related to Source Account
                if(OppAccountIds.size() > 0){
                    List<SourceAccounts__c> lstSourceAccount = [Select Id, Account__c, Type__c, Offering_detail__c, Trial_Status__c from SourceAccounts__c where Account__c In: OppAccountIds];
                    
                    // If found multiple Account with Source Account then hanlded the Map accourdingly
                    for(SourceAccounts__c sourceAccount : lstSourceAccount){
                        if(mapAccountToSourceAccount.containsKey(sourceAccount.Account__c)){
                            List<SourceAccounts__c> lstSA = mapAccountToSourceAccount.get(sourceAccount.Account__c);
                            lstSA.add(sourceAccount);
                            mapAccountToSourceAccount.put(sourceAccount.Account__c, lstSA);
                        }else{
                            List<SourceAccounts__c> lstSA = new List<SourceAccounts__c>();
                            lstSA.add(sourceAccount);
                            mapAccountToSourceAccount.put(sourceAccount.Account__c, lstSA);
                        }
                    }
                }
                system.debug('22222  '+ mapAccountToSourceAccount);
                for(Order__c ord : mapOrder.values()){
                    if(mapAccountToSourceAccount.containsKey(ord.Opportunity__r.Account.Id)){
                        List<SourceAccounts__c> lstsa = mapAccountToSourceAccount.get(ord.Opportunity__r.Account.Id);
                        Boolean isCreate = false;
                        for(SourceAccounts__c sa : lstsa){
                            if(sa.Type__c == ord.Opportunity__r.Lines_of_Businesses__c && sa.Offering_detail__c == ord.Opportunity__r.Offering_Detail__c && sa.Trial_Status__c == 'Active' && ord.Opportunity__r.Offering_Detail__c == 'Pilot/Trial/POC'){
                                isCreate = true;
                                system.debug('33333  Found = '+ ord.Id);
                            }
                            else if(sa.Type__c == ord.Opportunity__r.Lines_of_Businesses__c && sa.Offering_detail__c == ord.Opportunity__r.Offering_Detail__c && ord.Opportunity__r.Offering_Detail__c != 'Pilot/Trial/POC'){
                                isCreate = true;
                                system.debug('33333  Found = '+ ord.Id);
                            }

                        }
                        if(!isCreate){
                             // Create Source Account Record
                            if(newMapOrder.containsKey(ord.Id)){
                                system.debug('44444  Create due to status  = ');
                                lstInsertSA.add(createSourceAccount(newMapOrder.get(ord.Id), ord.Opportunity__r.Lines_of_Businesses__c,  ord.Opportunity__r.Offering_Detail__c, ord.Opportunity__r.Account.Name, ord.Opportunity__r.Primary_Line_of_Business__c,ord.Opportunity__r.Sold_To_Country__c,ord.Opportunity__c));
                            }
                        }
                    }else{
                        // Create Source Account Record
                        if(newMapOrder.containsKey(ord.Id)){
                            system.debug('44444  Create No record  = ');
                            lstInsertSA.add(createSourceAccount(newMapOrder.get(ord.Id), ord.Opportunity__r.Lines_of_Businesses__c,  ord.Opportunity__r.Offering_Detail__c, ord.Opportunity__r.Account.Name,ord.Opportunity__r.Primary_Line_of_Business__c,ord.Opportunity__r.Sold_To_Country__c,ord.Opportunity__c));    
                        }
                    }
                }
                
                if(lstInsertSA.size() > 0){
                    insert lstInsertSA;
                }
            }
        }catch(Exception ex){
            system.debug('Exception Occured ' + ex);
        }
    }
    
    /**
    *   Method Name :   updateopportunityclosedate()
    *   Description :   This method used to update the opportunity close date
    **/
    
    public static void updateopportunityclosedate(List <Order__c > neworder1,Map < Id, Order__c > newMap ){
         try{
             List<Opportunity> opplist = new List<Opportunity>();
            Map<String, String > oppid = new Map<String , String>();
            for(Order__C ordr : neworder1 )
            {
                oppid.put(ordr.Opportunity__c, ordr.id); 
                
            }   
            system.debug('oppid123'+ oppid);
            opplist = [Select id,stagename, ForecastStatus__c,CloseDate,Country_Region__c, AccountId from opportunity where  id in: oppid.keySet() and recordtype.name = 'GEN - Opportunity Record Type'];
            system.debug('opplist  ' + opplist);
            system.debug('Oldmap123  ' +newMap);
            for(Opportunity oppty : opplist ){
                oppty.CloseDate = newMap.get(oppid.get(oppty.id)).CreatedDate.date();
            }
            system.debug('TEstnavanee'+ opplist);
            update opplist;          
            }   
        catch(Exception ex){
            system.debug('Exception Occured ' + ex);
            system.debug('Exception Occured ' + ex.getlinenumber());
        }
    }
    
    
    /**
    *   Method Name :   createSourceAccount()
    *   Description :   This method used to create the Source Account Record
    **/
    
    public static SourceAccounts__c  createSourceAccount(Order__c Ord, String offerType,String Offeringdetail, String accountName, String platformtype, String soldtocountry, String OpportunityID){
        system.debug('#Order#'+Ord);
        SourceAccounts__c sourceAccount = new SourceAccounts__c();
        sourceAccount.Account__c = ord.Opportunity_Account__c;
        sourceAccount.Type__c = offerType;
        sourceAccount.Offering_Detail__c = Offeringdetail;
        sourceAccount.Platform_Type__c = platformtype; //Ord.Opportunity__r.Primary_Line_of_Business__c;
        sourceAccount.Sold_to_Country__c = soldtocountry; //Ord.Opportunity__r.Sold_To_Country__c;
        //Added as per discussion of Ankit and Kip on 12/12/2017
        sourceAccount.Opportunity__c = OpportunityID;
        
        sourceAccount.Name = accountName ;
        
        
        if(Offeringdetail == 'Pilot/Trial/POC')
        {
            sourceAccount.Trial_Status__c = 'Active';
            sourceAccount.Trial_Start_Date__c = date.today(); //Date.valueOf(ord.Date_Submitted__c);
            //As per Kips request no need to set the deactivation date
            //sourceAccount.Trial_Deactivation_Date__c = sourceAccount.Trial_Start_Date__c.adddays(30);
            //Now trial details will be shown on same layout so no need to assign new record type
            //sourceAccount.recordTypeId = getRecordTypeId('Trial Source Account', 'SourceAccounts__c');
        }
        
        //if(offerType != null && Offeringdetail != 'Pilot/Trial/POC'){
        if(offerType != null){
            String recordTypeName = getRecordTypeName(offerType);
            if(recordTypeName != null){
                sourceAccount.recordTypeId = getRecordTypeId(recordTypeName , 'SourceAccounts__c');
            }
        }
        
        return sourceAccount;
    }
    
    /**
    *   Method Name :   getRecordTypeName()
    *   Description :   This method used to get the record Type name from Custom setting 
    *   Parameters  :   relationshipType => Relationship Type from GS Relationship
    **/
    
    public Static String getRecordTypeName(String offerType){
        
        if(offerType != null){
            
            Order_Source_Account__c   gsSetting  = Order_Source_Account__c.getInstance(offerType);
            String recordTypeName = gsSetting.Record_Type_Name__c;
            
            return recordTypeName;
        }
        return null;
    }
    
    /**
    *   Method Name :   getRecordTypeId()
    *   Description :   This method used to get the record Type Id based on the Record Type Name 
    *   Parameters  :   recordTypeName => Record Type Name, sobj => Object Name
    **/
    
    public Static Id getRecordTypeId(String recordTypeName, String sobj){
        
        if(recordTypeName != null && sobj != null){
            
            Id SoureAccountRecordTypeId = Schema.getGlobalDescribe().get(sobj).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            
            return SoureAccountRecordTypeId;
        }
        
        return null;
    }
    
    /**
    *   Method Name :   UpdatePackageServiceStatus(Íd OrderId)
    *   Description :   This method used to Update the Status of Package Service
    *   Parameters  :   Order Id
    *   Author      :   Rsystems Inc         
    **/
    public static void UpdatePackageServiceStatus(String OrderId)
    {
        System.debug('Inside Update Pkg Srv');
        List<Package_Services__c> pkgSrv = new List<Package_Services__c>();
        
        for(Package_Services__c pkgSrvL : [Select ID, Status__c,Order__c,Product_Group_Item__r.Remove_from_Package__c from Package_services__c Where Order__c =: OrderId]){
            if(pkgSrvL != null){
                
                if(pkgSrvL.Product_Group_Item__r.Remove_from_Package__c)
                    pkgSrvL.Status__c = 'Consumed';
                else
                    pkgSrvL.Status__c = 'Allocated';
                pkgSrv.add(pkgSrvL);
            }
        }
        
        if(pkgSrv.size()>0)
        {
            update pkgSrv;
        }
        
        /*
        List<Token_Allocations__c> tknAll = new List<Token_Allocations__c>();
        for(Token_Allocations__c tkn : [Select ID,Token_Status__c, Order__c from Token_Allocations__c Where Order__c =: OrderId])
        {
            if(tkn != null){
                tkn.Token_Status__c = 'Consumed';
                tknAll.add(tkn);
            }
        }
        List<Token_Allocations__c> lstInsertTokenAllocations = new List<Token_Allocations__c>();
        String SrcContractName;
        List<ServiceContract> serviceContract = new List<ServiceContract>([Select ID, Name,Agreement_Number__c, Order__r.Id from ServiceContract Where Order__r.Id =: OrderId]);
        if(serviceContract != null && serviceContract.size()>0)
        {
        
            SrcContractName = serviceContract[0].Agreement_Number__c;
        }
        */
        /*
        for(Package_Services__c pkgsrv1 : [Select ID,Order__c,Order__r.End_User_Name__c, Order__r.Sold_To_Name__c,Token_Value__c,Product_group_item__c,Product_group_item__r.Allocation_type__c from Package_Services__c Where Order__c =: OrderId AND Token_Value__c > 0 ])
        {
            System.debug('::: Token Allocation Record Created===='+ pkgsrv1);
            if(pkgsrv1 != null){
                Token_Allocations__c objInsertTokenAllocation = new Token_Allocations__c();
                 if(pkgsrv1.Order__r.End_User_Name__c == pkgsrv1.Order__r.Sold_To_Name__c)
                    objInsertTokenAllocation.Account__c = pkgsrv1.Order__r.End_User_Name__c;
                    else
                    objInsertTokenAllocation.Account__c = pkgsrv1.Order__r.Sold_To_Name__c;
                    
                    objInsertTokenAllocation.Allocation_Type__c = pkgsrv1.Product_group_item__r.Allocation_type__c;
                    objInsertTokenAllocation.Contract_No__c = SrcContractName;
                    objInsertTokenAllocation.Order__c = pkgsrv1.Order__c;
                    objInsertTokenAllocation.Tokens__c = pkgsrv1.Token_Value__c;
                    objInsertTokenAllocation.Token_Status__c = 'Allocated';
                    lstInsertTokenAllocations.add(objInsertTokenAllocation);
            }
        }
        */
        /*
        System.debug('===Insert token allocation ===='+lstInsertTokenAllocations);
        if(tknAll.size()>0 && tknAll != null)
        {
            update tknAll;
        }
        if(lstInsertTokenAllocations != null && lstInsertTokenAllocations.size() > 0)
        {
            insert lstInsertTokenAllocations;
        }
        */
    }
    
    
}