/************************************************************************************
Purpose : Class used to generate Renewal Opps and Quotes for M2M Subs
Written By : Rony Joseph
Test Classes :CreateRenewalOppAndQuoteforM2MSubsTest
*************************************************************************************/
global class CreateRenewalOppAndQuoteforM2MSubs {
    
    Webservice Static Id createRenewalOppandQuote(Id objSubId){
        String strWhereCondition = 'where id = \''+String.valueof(objSubId)+'\'';
        Subscription__c objsubs = Database.Query(SubscriptionUtil.buildQryForRenewOppAndQuoteFromSubscrs(strWhereCondition));
        BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c();    
        Set<Id> set_ProductIds = new Set<Id>();
        List<Opportunity> list_SourceOpps = new List<Opportunity>();
        List<BigMachines__Quote__c> list_SourceQts = new List<BigMachines__Quote__c>();
        Map<String, RecordType> map_QuoteRecTypes = QuoteUtil.getRecordTypes('BigMachines__Quote__c');
        Savepoint objSP = Database.setSavepoint();    
      try {  
            Util.Bypass_Trigger_Chk = true; 
            User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c FROM User WHERE Id =: userinfo.getUserId()];
            objuser.BypassValidationRules__c = true;
            objuser.Bypass_Triggers__c = true;
            update objUser;            
            
 Opportunity objClonedOpportunity = OpportunityCloudUtil.createRenewalOpportunity(objSubs, 'true');
            System.debug(objClonedOpportunity); 
            if(objClonedOpportunity != null){
            insert objClonedOpportunity;
           // System.debug('objClonedOpportunity' + objClonedOpportunity); 
           /* Added for opportunity teammember 
           System.debug('objClonedOpportunityid' + objClonedOpportunity.id); 
           System.debug('objClonedOpportunity owner' + objClonedOpportunity.OwnerId); 
            System.debug('objClonedOpportunity csmowner' + objClonedOpportunity.CSM_GA_Opportunity_Owner__c); 
            system.debug('objClonedOpportunity accountowner' + objClonedOpportunity.Accountid);*/
           Account accow = [select Ownerid from Account where id =: objClonedOpportunity.Accountid];
            List<OpportunityTeamMember> Oppteammember = new List<OpportunityTeamMember>();
            Oppteammember.add(new OpportunityTeamMember(OpportunityId = objClonedOpportunity.id,UserId = objClonedOpportunity.OwnerId , OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));
            Oppteammember.add(new OpportunityTeamMember(OpportunityId = objClonedOpportunity.id,UserId = objClonedOpportunity.CSM_GA_Opportunity_Owner__c, OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));
            Oppteammember.add(new OpportunityTeamMember(OpportunityId = objClonedOpportunity.id,UserId = accow.Ownerid , OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));
                if(objClonedOpportunity.Quote_Mtce_Ops__c!=null){Oppteammember.add(new OpportunityTeamMember(OpportunityId = objClonedOpportunity.id,UserId = objClonedOpportunity.Quote_Mtce_Ops__c, OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));}
                if(objClonedOpportunity.Gene_Care_Specialist__c!=null){Oppteammember.add(new OpportunityTeamMember(OpportunityId = objClonedOpportunity.id,UserId = objClonedOpportunity.Gene_Care_Specialist__c, OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));}
            insert Oppteammember;  
            //End for opportunity teammember
            //Cloning and Insertion of the Quote from the Subscription  
            system.debug('Oppteammember'+ Oppteammember);
            objNewQuote = QuoteCloudUtil.createRenewalQuotes(objSubs,objClonedOpportunity);
            System.debug(objNewQuote);
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
                      
            objuser.BypassValidationRules__c = false;
            objuser.Bypass_Triggers__c = false;
            update objuser;
            Util.Bypass_Trigger_Chk = false;
            return objClonedOpportunity.Id;
            }
             else{
                 return null;
             }
        }
        catch(Dmlexception e) {
            System.debug('Exception has occurred:'+e.getMessage()+'\n'+e.getTypeName()+'\nStacktrace:'+e.getStackTraceString()+'\n'+e.getDmlFields(0));
            Database.rollback(objSP);return null;
        }    
    }
     
}