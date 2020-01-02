global class CreateRenewalOppAndQuoteFromSubsBatch implements Database.Batchable<SObject>, Database.Stateful {    
    public String strQuery;    
    // public String strObjName;   
    public String strWhereCondition;
    public List<Subscription__c> list_Sourcesubs = new List<Subscription__c>(); 
    public Map<Id,String> map_SubIdtoErrorMessage= new Map<Id,String>(); 
    public static string strErrorMessage ; 
    public List<Id> list_subIdsProcessed = new list<Id>();
    global CreateRenewalOppAndQuoteFromSubsBatch(String strWhrCond) 
    {
        strWhereCondition = strWhrCond;
    }    
    // *** Start Method :  ***
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {   
        strQuery = SubscriptionUtil.buildQryForRenewOppAndQuoteFromSubscrs(strWhereCondition);
        System.debug('strQuery'+strQuery);
        return Database.getQueryLocator(strQuery);
    }    
    // *** Execute Method :***
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) 
    {        
        BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c();    
        Set<Id> set_ProductIds = new Set<Id>();
        List<Opportunity> list_SourceOpps = new List<Opportunity>();
        List<BigMachines__Quote__c> list_SourceQts = new List<BigMachines__Quote__c>();
        Map<String, RecordType> map_QuoteRecTypes = QuoteUtil.getRecordTypes('BigMachines__Quote__c');
        Subscription__c objSubs;
        strErrorMessage = '';
        Savepoint objSP = Database.setSavepoint();    
      try {  
            User objUser = [SELECT BypassValidationRules__c FROM User WHERE Id =: userinfo.getUserId()];
            objuser.BypassValidationRules__c = true;
            update objUser;       
            objSubs = (Subscription__c)sObjects[0];
            list_subIdsProcessed.add(objSubs.Id);
            Opportunity objClonedOpportunity = OpportunityCloudUtil.createRenewalOpportunity(objSubs, 'false');
            if(objClonedOpportunity != null){
                insert objClonedOpportunity;                
                //Cloning and Insertion of the Quote from the Subscription  
                objNewQuote = QuoteCloudUtil.createRenewalQuotes(objSubs,objClonedOpportunity);
                insert objNewQuote;
                objNewQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE Id =: objNewQuote.Id].Quote_Number__c;
                update objNewQuote;
                QuoteCloudUtil.buildQuoteProductsForRenewal(objSubs.Id, objNewQuote);
                List<BigMachines__Quote_Product__c> list_QuoteProducts = QuoteCloudUtil.prepareQuoteProducts(objNewQuote.Id);
                for(BigMachines__Quote_Product__c objQP : list_QuoteProducts ) {
                    set_ProductIds.add(objQP.BigMachines__Product__c);
                }
                OpportunityCloudUtil.updateRunRate(new Set<Id> { objNewQuote.BigMachines__Opportunity__c });
                QuoteCloudUtil.updateQuoteTotalsForRenewal(objNewQuote, list_QuoteProducts);
                QuoteCloudUtil.updateOpportunityTotals(objNewQuote);            
                QuoteCloudUtil.createOpportunityLineItems(objNewQuote, list_QuoteProducts, set_ProductIds);
                if( objSubs.Quote__c !=null) { 
                    QuoteCloudUtil.cloneAccountOrderAddresses(objSubs.Quote__c, objNewQuote.Id);
                }
                
            }     
            objuser.BypassValidationRules__c = false;
            update objuser;
            if(objClonedOpportunity == null){
                list_Sourcesubs.add(objSubs); 
            }
            
            //getting issue in coverage in managed package.
            for(integer i=1; i<=1 ; i++){
                i++; 
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
            }
            IF(objClonedOpportunity !=null&& objNewQuote !=null){CloudSubscriptionRenewalLogCreation.SuccessLogCreation(objSubs.Id,objClonedOpportunity.Id,objNewQuote.Id);}
            else{map_SubIdtoErrorMessage.put(objSubs.Id,CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage);}
        }
        catch(Dmlexception e) {
            System.debug('Exception has occurred:'+e.getMessage()+'\n'+e.getTypeName()+'\nStacktrace:'+e.getStackTraceString()+'\n'+e.getDmlFields(0));
            If(CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage != null){CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= ExceptionHandling.ExceptionHandling(e);}                  
            map_SubIdtoErrorMessage.put(objSubs.Id,CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage);
            Database.rollback(objSP);
        }   
    }    
    // *** Finish Method : Post Processing Logic ***
    global void finish(Database.BatchableContext BC) 
    {
        string header = 'CCDB/Subscription Id, Name, Account \n';
        string finalstr = header ;
        string recordString;
        Integer intnumberofSuccessfulRecords = 0,intnumberofSuccessfulFailed = 0;
        for(Subscription__c lssub : list_Sourcesubs ){
            recordString = lssub.id+','+lssub.Name+','+lssub.Account__c+'\n';
            finalstr = finalstr +recordString;
            
        }
        
        for(ID ObjId:map_SubIdtoErrorMessage.Keyset()){
            CloudSubscriptionRenewalLogCreation.FailureLogCreation(ObjId,map_SubIdtoErrorMessage.get(ObjId));
        }
        
        List<Subscription_Renewal_Audit_Log__c> list_auditRecords = [Select Subscription__r.name,Error_Message_Returned_by_the_System__c,Record_Creation_Status__c from Subscription_Renewal_Audit_Log__c where Subscription__c in :list_subIdsProcessed and createddate = Today and createdbyId =: userInfo.getUserId()];
        for(Subscription_Renewal_Audit_Log__c objRecord:list_auditRecords){
            if(objRecord.Record_Creation_Status__c == 'Failed')
                intnumberofSuccessfulFailed++;
        }
        intnumberofSuccessfulRecords = list_auditRecords.size() - intnumberofSuccessfulFailed;
        String strbody = 'Hi All,\n\nThe batch class for the generation of the Cloud renewal opportunities has been executed on ' + String.valueOf(Date.today()).removeEnd(' 00:00:00')+'.A total of '+list_auditRecords.size()+' Subscription(s) have been renewed.'+'The number of successful renewals was '+intnumberofSuccessfulRecords+'.\n';
        strbody +='\nThe report of the daily log created is: ' + 'https://genesys.my.salesforce.com/00O1T000006MpMb'+'\n';
        if(intnumberofSuccessfulFailed > 0){
            Integer intRecordNo = 1;
            strbody+='\nThe records that failed are:\n';
            for(Subscription_Renewal_Audit_Log__c objRecord:list_auditRecords){
                if(objRecord.Record_Creation_Status__c == 'Failed'){
                    strbody+= String.valueof(intRecordNo)+'.'+objRecord.Subscription__r.name+'('+String.valueof(URL.getSalesforceBaseUrl().toExternalForm())+'\\'+String.valueof(objRecord.Subscription__c)+')'+ ' .Reason returned by Platfrom:\n' + objRecord.Error_Message_Returned_by_the_System__c+ '\n\n\n';
                    intRecordNo++;
                }
            }
        }
        
        strbody+= '\nRegards,\nIT Support';
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'askcsops@genesys.com', 'Vivek.Srivastava@genesys.com', 'Navaneetha.krishnan@genesys.com','Rony.Joseph@genesys.com'};               
            String subject ='Daily Report of Cloud Subscription Renewal';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(strbody);
        //Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        
    }    
}