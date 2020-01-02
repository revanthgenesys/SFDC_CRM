global class BatchUpdateAccountOfferingType implements Database.Batchable<sObject>, Database.Stateful {
    global Set<Id> set_AccountId = new Set<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String recordTypeName = Label.Account_Record_Type;
        Id emgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        String query = 'SELECT Id, Inactive_Purchased_Offerings__c, AccountOfferingTypes__c, Offering_Type__c, '+
                            +'(SELECT Id, AccountId, Agreement_Status__c, Sold_To_Name__c, End_User_Name__c, Offering_Type__c, Service_Contract_Type__c, Platform_Type__c FROM ServiceContracts), '+
                            +'(SELECT Id, Cloud_Platform__c, Offering_Detail__c, Account__c, Support_Status__c, Sold_To_Account__c FROM Account_Deployments__r) '+
                            +'FROM Account WHERE RecordTypeId =: emgRecordTypeId AND Offering_Type__c = null';
        System.debug('recordTypeName----'+recordTypeName+'query ---'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Map<Id, String> map_AccIdActiveString = new Map<Id, String>();
        Map<Id, String> map_AccIdInActiveString = new Map<Id, String>();
        Map<Id, String> map_AccIdOfferingType = new Map<Id, String>();
        List<Account> list_Account = new List<Account>();
        
        for(Account acc : scope){
            list_Account.add(acc);
            if(acc.ServiceContracts.size() > 0){
                for(ServiceContract serviceCon : acc.ServiceContracts){
                
                    String serviceActiveOfferingType;
                    String serviceInactiveOfferingType;
                    boolean isActive = false;
                    
                    if((serviceCon.Agreement_Status__c == 'Active' || serviceCon.Agreement_Status__c == 'Pending' || serviceCon.Agreement_Status__c == 'In Negotiation')
                        && serviceCon.End_User_Name__c != null && serviceCon.Sold_To_Name__c != null && serviceCon.End_User_Name__c != serviceCon.Sold_To_Name__c){
                            serviceActiveOfferingType = createOfferingTypeForServiceContract(serviceCon, 'Indirect');
                            isActive = true;
                    }
                    else {
                        if((serviceCon.Agreement_Status__c == 'Active' || serviceCon.Agreement_Status__c == 'Pending' || serviceCon.Agreement_Status__c == 'In Negotiation')
                            && serviceCon.End_User_Name__c != null && (serviceCon.Sold_To_Name__c == null || serviceCon.End_User_Name__c == serviceCon.Sold_To_Name__c)){
                                serviceActiveOfferingType = createOfferingTypeForServiceContract(serviceCon, 'Direct');
                                isActive = true;
                        }
                        else {
                            if((serviceCon.Agreement_Status__c != 'Active' && serviceCon.Agreement_Status__c != 'Pending' && serviceCon.Agreement_Status__c != 'In Negotiation')
                                && serviceCon.End_User_Name__c != null && serviceCon.Sold_To_Name__c != null && serviceCon.End_User_Name__c != serviceCon.Sold_To_Name__c){
                                    serviceInactiveOfferingType = createOfferingTypeForServiceContract(serviceCon, 'Indirect');
                            }
                            else {
                                if((serviceCon.Agreement_Status__c != 'Active' && serviceCon.Agreement_Status__c != 'Pending' && serviceCon.Agreement_Status__c != 'In Negotiation')
                                    && serviceCon.End_User_Name__c != null && (serviceCon.Sold_To_Name__c == null || serviceCon.End_User_Name__c == serviceCon.Sold_To_Name__c)){
                                        serviceInactiveOfferingType = createOfferingTypeForServiceContract(serviceCon, 'Indirect');
                                }
                            }
                        }           
                    }
                    
                    if(serviceActiveOfferingType != null){
                        if(!map_AccIdActiveString.containsKey(serviceCon.AccountId)){
                            map_AccIdActiveString.put(serviceCon.AccountId, serviceActiveOfferingType);
                        }
                        else{
                            String activeStrTemp = getOffering(map_AccIdActiveString.get(serviceCon.AccountId), serviceActiveOfferingType, '\n');
                            map_AccIdActiveString.put(serviceCon.AccountId, activeStrTemp);
                        }
                    }
                    
                    if(serviceInactiveOfferingType != null){
                        if(!map_AccIdInActiveString.containsKey(serviceCon.AccountId)){
                            map_AccIdInActiveString.put(serviceCon.AccountId, serviceInactiveOfferingType);
                        }
                        else{
                            String activeStrTemp = getOffering(map_AccIdInActiveString.get(serviceCon.AccountId), serviceInactiveOfferingType, '\n');
                            map_AccIdInActiveString.put(serviceCon.AccountId, activeStrTemp);
                        }
                    }
                            
                    
                    String platformType;
                    if(isActive){
                        if((serviceCon.Offering_Type__c == 'PureEngage' || serviceCon.Offering_Type__c == 'PureConnect') && (serviceCon.Platform_Type__c == null || serviceCon.Platform_Type__c == 'Premise'))
                        {
                            platformType = serviceCon.Offering_Type__c + ' Premise';
                        }
                        else if((serviceCon.Offering_Type__c == 'PureEngage' || serviceCon.Offering_Type__c == 'PureConnect') && (serviceCon.Platform_Type__c == null || serviceCon.Platform_Type__c == 'Cloud'))
                        {
                            platformType = serviceCon.Offering_Type__c + ' Cloud';
                        }
                        else if(serviceCon.Offering_Type__c != null){
                            platformType = serviceCon.Offering_Type__c;
                        }
                    }
                    
                    if(platformType != null){
                        if(!map_AccIdOfferingType.containsKey(serviceCon.AccountId)){
                            map_AccIdOfferingType.put(serviceCon.AccountId, platformType);
                        }else{
                            String newOfferingType = getOffering(map_AccIdOfferingType.get(serviceCon.AccountId), platformType, ';');
                            map_AccIdOfferingType.put(serviceCon.AccountId, newOfferingType);
                        }
                    }
                }
            }
            
            if(acc.Account_Deployments__r.size() > 0){
                for(Cloud_Deployment__c cloudDeply : acc.Account_Deployments__r){                    
                    String serviceActiveOfferingType;
                    String serviceInactiveOfferingType;
                    boolean isActive = false;
                    
                    if(cloudDeply.Support_Status__c != 'Inactive' && cloudDeply.Account__c != null && cloudDeply.Sold_To_Account__c != null && cloudDeply.Account__c != cloudDeply.Sold_To_Account__c){
                        serviceActiveOfferingType = createOfferingTypeForCloudDeply(cloudDeply, 'Indirect');
                        isActive = true;
                    }
                    else {
                        if(cloudDeply.Support_Status__c != 'Inactive'&& cloudDeply.Account__c != null && (cloudDeply.Sold_To_Account__c == null || cloudDeply.Account__c == cloudDeply.Sold_To_Account__c)){
                            serviceActiveOfferingType = createOfferingTypeForCloudDeply(cloudDeply, 'Direct');
                            isActive = true;
                        }
                        else {
                            if(cloudDeply.Support_Status__c == 'Inactive'&& cloudDeply.Account__c != null && cloudDeply.Sold_To_Account__c != null && cloudDeply.Account__c != cloudDeply.Sold_To_Account__c){
                                serviceInactiveOfferingType = createOfferingTypeForCloudDeply(cloudDeply, 'Indirect');
                            }
                            else {
                                if(cloudDeply.Support_Status__c == 'Inactive' && cloudDeply.Account__c != null && (cloudDeply.Sold_To_Account__c == null || cloudDeply.Account__c == cloudDeply.Sold_To_Account__c)){
                                    serviceInactiveOfferingType = createOfferingTypeForCloudDeply(cloudDeply, 'Direct');
                                }
                            }
                        }           
                    }
                    
                    String platformType;
                    if(isActive){
                        if(cloudDeply.Cloud_Platform__c == 'PureConnect Subscription')
                            platformType = 'PureConnect Premise';
                        else {
                            if(cloudDeply.Cloud_Platform__c == 'Outbound Engagement')
                                platformType = 'PureEngage Cloud Outbound';
                            else {
                                if(cloudDeply.Cloud_Platform__c == 'PureEngage Subscription')
                                    platformType = 'PureEngage Premise';
                                else {
                                    if(cloudDeply.Cloud_Platform__c == 'SpeechStorm'    || cloudDeply.Cloud_Platform__c == 'Legacy Enterprise Edition')
                                        platformType = 'PureEngage Cloud';
                                    else {
                                        if(cloudDeply.Cloud_Platform__c == 'Premier Edition' || cloudDeply.Cloud_Platform__c == 'PureConnect Cloud' 
                                                || cloudDeply.Cloud_Platform__c == 'PureEngage Cloud' || cloudDeply.Cloud_Platform__c == 'PureCloud')
                                            platformType = cloudDeply.Cloud_Platform__c;
                                    }
                                }
                            }
                        }
                    }
                    
                    if(platformType != null){
                        if(!map_AccIdOfferingType.containsKey(cloudDeply.Account__c)){
                            map_AccIdOfferingType.put(cloudDeply.Account__c, platformType);
                        }else{
                            String newOfferingType = getOffering(map_AccIdOfferingType.get(cloudDeply.Account__c), platformType, ';');
                            map_AccIdOfferingType.put(cloudDeply.Account__c, newOfferingType);
                        }
                    }
                    
                    if(serviceActiveOfferingType != null){
                        if(!map_AccIdActiveString.containsKey(cloudDeply.Account__c)){
                            map_AccIdActiveString.put(cloudDeply.Account__c, serviceActiveOfferingType);
                        }
                        else{
                            String activeStrTemp = getOffering(map_AccIdActiveString.get(cloudDeply.Account__c), serviceActiveOfferingType, '\n');
                            map_AccIdActiveString.put(cloudDeply.Account__c, activeStrTemp);
                        }
                    }
                    
                    if(serviceInactiveOfferingType != null){
                        if(!map_AccIdInActiveString.containsKey(cloudDeply.Account__c)){
                            map_AccIdInActiveString.put(cloudDeply.Account__c, serviceInactiveOfferingType);
                        }
                        else{
                            String activeStrTemp = getOffering(map_AccIdInActiveString.get(cloudDeply.Account__c), serviceInactiveOfferingType, '\n');
                            map_AccIdInActiveString.put(cloudDeply.Account__c, activeStrTemp);
                        }
                    }
                }
            }
        }
        
        for(Account accObj : list_Account){
            if(map_AccIdInActiveString.containsKey(accObj.Id)){
                accObj.Inactive_Purchased_Offerings__c = map_AccIdInActiveString.get(accObj.Id);
            }
            if(map_AccIdActiveString.containsKey(accObj.Id)){
                accObj.AccountOfferingTypes__c = map_AccIdActiveString.get(accObj.Id);
            }
            if(map_AccIdOfferingType.containsKey(accObj.Id)){
                accObj.Offering_Type__c = map_AccIdOfferingType.get(accObj.Id);
                set_AccountId.add(accObj.Id);
            }            
        }        
        update list_Account;
    }
    
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new BatchUpdateContactOfferingType(set_AccountId));
    }
    
    private static String createOfferingTypeForCloudDeply(Cloud_Deployment__c cloudDeployRec, String offeringType){        
        String cloudPltfrm = cloudDeployRec.Cloud_Platform__c == null ? '' : cloudDeployRec.Cloud_Platform__c;
        String offerDetail = cloudDeployRec.Offering_Detail__c ==  null ? '' : cloudDeployRec.Offering_Detail__c;
        String finalStr1 = offeringType + ': Cloud, ' + cloudPltfrm + ', ' + offerDetail;
        finalStr1 = finalStr1.trim();
        return finalStr1;
    }


    private static String createOfferingTypeForServiceContract(ServiceContract serviceCont, String offeringType){
        String offerType = serviceCont.Offering_Type__c == null ? '' : serviceCont.Offering_Type__c;
        String contractType = serviceCont.Service_Contract_Type__c ==  null ? '' : serviceCont.Service_Contract_Type__c;
        String finalStr1 = offeringType + ': Premise, ' + offerType + ', ' + contractType;
        finalStr1 = finalStr1.trim();
        return finalStr1;
    }
    
    
    private static String getOffering(String offeringVal, String finalStr, String seperator){
        if(offeringVal == null){
            offeringVal =  finalStr;
        } else{
            if(!offeringVal.contains(finalStr)){
                offeringVal =  offeringVal + seperator + finalStr;
            }
        }
        return offeringVal;
    }
}