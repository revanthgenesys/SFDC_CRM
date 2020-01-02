/*
 * Class			: UpdateCasesForGUCertifiedContact2
 * Description		: This Batch Class updates Cases info about whether the case has been logged by GU Certified Contact or not
 * 					  by querying the info from Partner Certifications (Partner_Certifications__c). 
 * 				      Please note that this batch should be executed after UpdateCasesForGUCertifiedContact1 for better performance.
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: May 26, 2016 
 * Test Class		: 
 * 	
 */
global class UpdateCasesForGUCertifiedContact2 implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC){
        DateTime yearStartDate = DateTime.newInstanceGmt(2014, 1, 1, 0, 0, 1);
        String supportRecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Support').getRecordTypeId();
        String queryStr = 'SELECT Id, CaseNumber, ContactId, Contact.ViewCentral_ID__c, CreatedDate, GU_Certified_Contact__c, Case_Logged_by_GU_Certified_Contact__c ' 
            			+' FROM Case WHERE RecordTypeId = :supportRecordTypeId '
            			+' AND Sold_To_Account__r.Type = \'Partner\' AND Sold_To_Account__r.Status__c = \'Active\'';
        if(Test.isRunningTest()){
            queryStr = queryStr + ' AND ClosedDate >= :yearStartDate LIMIT 10';
        } else {
			queryStr = queryStr + ' AND GU_Certified_Contact__c = NULL';
        }
        return Database.getQueryLocator(queryStr);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Set<String> contactViewCentralIDs = new Set<String>();
        for(sObject so : scope){
            Case c = (Case)so;
            if(!String.isBlank(c.Contact.ViewCentral_ID__c))
                contactViewCentralIDs.add(c.Contact.ViewCentral_ID__c);
        }
            
        Map<String, List<Partner_Certifications__c>> contactCertifications = new Map<String, List<Partner_Certifications__c>>();
        
        for(Partner_Certifications__c pc : [SELECT id, ViewCentral_Contact_ID__c, Test_Date__c, Expiry_Date__c FROM Partner_Certifications__c 
                                            WHERE ViewCentral_Contact_ID__c IN :contactViewCentralIDs])
        {
            if(contactCertifications.containsKey(pc.ViewCentral_Contact_ID__c)){
                contactCertifications.get(pc.ViewCentral_Contact_ID__c).add(pc);
            } else {
                contactCertifications.put(pc.ViewCentral_Contact_ID__c, new List<Partner_Certifications__c>{pc});
            }                                                     
        }
        
        for(sObject so : scope){
            Case c = (Case)so;
            if(String.isBlank(c.Contact.ViewCentral_ID__c)){
                c.GU_Certified_Contact__c = 'No';
                c.Case_Logged_by_GU_Certified_Contact__c = 'No'; 
            } else {
                List<Partner_Certifications__c> partnerCerts = contactCertifications.get(c.Contact.ViewCentral_ID__c);
                if(partnerCerts != NULL && partnerCerts.size() > 0){
                    
                    Boolean activeCert = false;
                    for(Partner_Certifications__c pc: partnerCerts){
                        if(c.CreatedDate >= pc.Test_Date__c && c.CreatedDate <= pc.Expiry_Date__c ){
                            activeCert = true;
                        }
                    }
                    if(activeCert){
                        c.GU_Certified_Contact__c = 'Yes';
                        // c.Case_Logged_by_GU_Certified_Contact__c = 'Yes'; 
                    } else {
                        c.GU_Certified_Contact__c = 'No';
                        // c.Case_Logged_by_GU_Certified_Contact__c = 'No'; 
                    } 
                } else {
                    c.GU_Certified_Contact__c = 'No';
                    // c.Case_Logged_by_GU_Certified_Contact__c = 'No'; 
                }
            }
        }
        Database.update(scope, false);
	}
	global void finish(Database.BatchableContext BC){
    }
}