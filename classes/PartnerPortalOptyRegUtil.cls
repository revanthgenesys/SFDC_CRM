public class PartnerPortalOptyRegUtil{
    
    //private list<ProcessInstance> dealRegList{get;set;}
    public list<string> salesLeadIDs = new list<string>();
    //public list<string> getsalesLeadIDs(){return salesLeadIDs;}

    @InvocableMethod
    public static list<string> fetchSalesLead(list<string> dealRegId){
        System.Debug('dealRegId--->'+dealRegId);
        try{
            map<string,string> salesLeadIDs = new map<string,string>();
            if(dealRegId.size()>0){
                
                List<ProcessInstance> dealRegList = new List<ProcessInstance>();
                dealRegList = [SELECT Id,TargetObjectId,ProcessDefinition.DeveloperName,(SELECT ID, ProcessNodeId,
                                 StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending
                                ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,
                                OriginalActor.Name , ProcessNode.DeveloperName FROM StepsAndWorkitems order by CreatedDate DESC ) 
                                FROM ProcessInstance where TargetObjectId =:dealRegId AND ProcessDefinition.DeveloperName <> 'Above_6_Months_Expiration_Extension' 
                                AND ProcessDefinition.DeveloperName <> 'Below_6_Months_Expiration_Extension' order by CreatedDate];
                System.Debug('dealRegList--->'+dealRegList);
                for(string str:dealRegId){
                    for(ProcessInstance deal:dealRegList){
                            if(deal.ProcessDefinition.DeveloperName=='Partner_Portal_Opportunity_3_steps' && deal.TargetObjectId==Id.valueOf(str)){
                                for(ProcessInstanceHistory ps:deal.StepsAndWorkitems){
                                    System.Debug('ps--->'+str+';;'+ps);
                                    System.Debug('ps.ProcessInstance.ProcessDefinition.DeveloperName--->'+deal.ProcessDefinition.DeveloperName+'||'+ps.ProcessNode.DeveloperName);
                                    if(ps.StepStatus=='Pending' && ps.ProcessNode.DeveloperName=='Sales_Leader'){
                                        System.Debug('--->'+deal.TargetObjectId+','+ps.OriginalActorId);
                                        salesLeadIDs.put(deal.TargetObjectId,ps.OriginalActorId);
                                    }
                                }
                            }
                    }
                }
            }
            updateSalesLeadOnDealReg(salesLeadIDs);
        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }
        return null;
    }
    
    //@future
    public static void updateSalesLeadOnDealReg(map<string,string> dealRegMap){
        try{
            if(dealRegMap.size()>0){
                list<partner_portal_prospect__c> dealReg = [Select Id,Sales_Leader__c from partner_portal_prospect__c where Id IN:dealRegMap.keyset()];
                for(partner_portal_prospect__c pp:dealReg){
                    pp.Sales_Leader__c = dealRegMap.get(pp.Id);
                }
                update dealReg;
            }
        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }
    }
    
     //Added by navaneeth for opportunity team member.    
    public static void updateopportunityteammember(List < Opportunity > triggernew , map<id,Opportunity> oldMap, string valuen){
        List<OpportunityTeamMember> Oppteammember = new List<OpportunityTeamMember>();
        try{            
            
        for(Opportunity optty:triggernew)
        {   System.debug('valuen' + valuen);
            if(valuen == 'insert')
            {
            OpportunityTeamMember oppteam = new OpportunityTeamMember(OpportunityId = optty.id,UserId = optty.Ownerid , OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner');
            if(optty.RecordTypeid  == global_setting__c.getinstance('Cloud Renewal Opty recordtype').id__C){ 
             //System.debug('optty.Account.Ownerid'+ optty.Account.Ownerid);
            Account accow = [select Ownerid from Account where id =: optty.Accountid];
            Oppteammember.add(new OpportunityTeamMember(OpportunityId = optty.id,UserId = optty.CSM_GA_Opportunity_Owner__c, OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));
            Oppteammember.add(new OpportunityTeamMember(OpportunityId = optty.id,UserId = accow.Ownerid , OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));
            //added by kartik 
            Oppteammember.add(new OpportunityTeamMember(OpportunityId = optty.id,UserId = optty.Quote_Mtce_Ops__c , OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));
            Oppteammember.add(new OpportunityTeamMember(OpportunityId = optty.id,UserId = optty.Gene_Care_Specialist__c , OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));   
            }
            
            Oppteammember.add(oppteam); 
            
            }
            else{
            System.debug('Oppteammember11');
            if(optty.Ownerid != oldMap.get(optty.id).Ownerid || optty.CSM_GA_Opportunity_Owner__c != oldMap.get(optty.id).CSM_GA_Opportunity_Owner__c)
            {
            System.debug('Oppteammember1');
                OpportunityTeamMember oppteam = new OpportunityTeamMember(OpportunityId = optty.id,UserId = optty.Ownerid , OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner');
                if(optty.RecordTypeid  == global_setting__c.getinstance('Cloud Renewal Opty recordtype').id__C){ 
                Oppteammember.add(new OpportunityTeamMember(OpportunityId = optty.id,UserId = optty.CSM_GA_Opportunity_Owner__c, OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));
                }
                Oppteammember.add(oppteam);
            }
            //added by kartik
            if(optty.RecordTypeid  == global_setting__c.getinstance('Cloud Renewal Opty recordtype').id__C){     
                if(optty.Quote_Mtce_Ops__c!= oldMap.get(optty.id).Quote_Mtce_Ops__c){Oppteammember.add(new OpportunityTeamMember(OpportunityId = optty.id,UserId = optty.Quote_Mtce_Ops__c , OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner'));}
                if(optty.Gene_Care_Specialist__c!= oldMap.get(optty.id).Gene_Care_Specialist__c){Oppteammember.add(new OpportunityTeamMember(OpportunityId = optty.id,UserId = optty.Gene_Care_Specialist__c , OpportunityAccessLevel = 'Edit', TeamMemberRole = 'Opportunity Owner')); }   
            }
            
            }           
        }
        System.debug('Oppteammember2'+ Oppteammember);
        insert Oppteammember;  
        }
        catch(exception e){
            system.debug('Error-->'+ e.getMessage());
            system.debug('Error-->'+ e.getLineNumber());
        }
    }
    //Code ended.
    
    //Added by navaneetha  
  /* public static void updateopportunityclosedate(List < Opportunity > newOpp1, Map < Id, Opportunity > oldMap ){
        
        try{

            system.debug('Testnavaneethar345');
            list <String> ooId =  new List<String> ();

        for(Opportunity opps : newOpp1){        
        system.debug('recordtype123id' + oldMap.get(opps.Id).RecordTypeid);
        system.debug('recordtype123id' + oldMap.get(opps.Id).RecordType.Name);
        RecordType objRecType = [Select id,name from RecordType where id =: oldMap.get(opps.Id).RecordTypeid ] ;
         system.debug('recordtype123Name' +objRecType.Name);
        if(opps.ForecastStatus__c == '1.In Hand'  && opps.ForecastStatus__c != oldMap.get(opps.Id).ForecastStatus__c && objRecType.Name == 'GEN - Opportunity Record Type')
        {
            ooId.add(opps.id);
            system.debug('ooId' + ooId);
        }

        }

        if(ooId.isEmpty())
            return;
        List<Opportunity> opplist = new List<Opportunity>();

        opplist = [Select Id,CloseDate, (Select id ,name ,CreatedDate  FROM Orders__r order by CreatedDate desc limit 1) ,RecordType.Name from Opportunity where id in: ooId ];  
        System.debug('orderlistRecordType.Name' + opplist[0].RecordType.Name );

        for(Opportunity opps1 : opplist){
            for(Order__C ordr: opps1.Orders__r ){

                if(oldMap.get(opps1.id).CloseDate != ordr.CreatedDate.date())
                {
                    for(Opportunity oppslist : newOpp1){
                        if(oppslist.id == opps1.id){
                            oppslist.CloseDate = ordr.CreatedDate.date();
                        }
                    }

                }
            }

        }
        update opplist;

        } 
        catch(exception e){
            System.debug('Error message:'+ e.getmessage());
            System.debug('Error message:'+ e.getlinenumber());
        }
            
    } */
    
}