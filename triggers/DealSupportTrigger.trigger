// Code is not bulkified with the assumption being that bulkification is not a practical requirement here
trigger DealSupportTrigger on Deal_Support__c (after insert,before update, after update) 
{
//Adding for incident INC0439133 by Malavika on 13-12-2019 This logic is working on insert but not on update, so implementing the logic on update as well
    if(trigger.isBefore && Trigger.isUpdate){
        for(Deal_Support__c ds : trigger.new){
            if(ds.Support_Area__c == 'Sales Ops'){
                if (ds.Official_Cancelation_Date__c  != null && Trigger.oldMap.get(ds.id).Official_Cancelation_Date__c != ds.Official_Cancelation_Date__c){
                    if(ds.Offering_Type__c == 'Pure Cloud' && ds.Trial_Evaluation__c == 'No' && ds.Request_Type__c == 'Data Management' && ds.Focus_Area__c== 'Account' && ds.Requested_Action__c == 'Inactivate Line of Business'){
                        ds.Product_Cancellation_Date__c = ds.Official_Cancelation_Date__c.addDays(30);
                    }else {
                        ds.Product_Cancellation_Date__c = ds.Official_Cancelation_Date__c;
                    }
                 }
             }
          } 
     }

    // Navaneetha added 
            if(Trigger.isAfter) {
                if(Trigger.isUpdate){
                    Set<String> dSroppID = new Set<String>();
                    for (deal_support__C dSo : Trigger.new){
                        if(dSo.Request_Type__c == 'PureBridge' || dSo.Request_Type__c == 'Cloud Migration Assistance'){
                            dSroppID.add(dSo.Opportunity__c);
                        }
                    }
                        //List<Opportunity> opp = [SELECT Id, Lever__c  FROM Opportunity WHERE Id = : dSroppID];
                        //List<Deal_Support__c> l_co = [SELECT Id, Lever__c FROM Deal_Support__c WHERE Opportunity__c = : dSroppID and (dSo.Request_Type__c = 'PureBridge' OR dSo.Request_Type__c = 'PureBridge Trial') ];
                        Map<id,opportunity> mapdsropp = new Map<id,opportunity>();
                        map<id,Opportunity> OppMap = new map<id,opportunity>();
                        for(Deal_Support__c dsd :[SELECT Id, Lever__c,Opportunity__c,Request_Type__c,Owner_Approval__c,Request_Deal_Incentives__c,Avaya_Contract_Expiration__c FROM Deal_Support__c WHERE Opportunity__c = : dSroppID])
                        {
                            if(dsd.Request_Type__c == 'PureBridge' || dsd.Request_Type__c == 'Cloud Migration Assistance'){
                            if(mapdsropp.containskey(dsd.Opportunity__c))
                                                       {
                            string level;
                                system.debug('test navaneetha 12'+ dsd.Lever__c);
                                List<string> levlList = new List<string>(); 
                                    if(dsd.Lever__c != null && dsd.Request_Type__c == 'PureBridge')                                    
                                        mapdsropp.get(dsd.Opportunity__c).Lever__c = mapdsropp.get(dsd.Opportunity__c).Lever__c !=null ?mapdsropp.get(dsd.Opportunity__c).Lever__c+';'+ dsd.Lever__c: dsd.Lever__c;
                                                                 
                                                                
                                   if(dsd.Request_Type__c == 'Cloud Migration Assistance' && dsd.Owner_Approval__c=='Approved')   {                                   
                                           system.debug('Navaneethawwwww'+ mapdsropp);                      
                                    mapdsropp.put(dsd.Opportunity__c,new opportunity(id=dsd.Opportunity__c,Deal_Incentive__c='Cloud Migration – Incentive 2'));
                                        system.debug('mapdsropp'+ mapdsropp);
                                
                            }                                 

                            }
                            else
                            {
                                    mapdsropp.put(dsd.Opportunity__c,new opportunity(id=dsd.Opportunity__c,Lever__c = dsd.Lever__c, Avaya_Contract_Expiration__c= dsd.Avaya_Contract_Expiration__c));
                                    //mapdsropp.put(dsd.Opportunity__c,new opportunity(id=dsd.Opportunity__c,Avaya_Contract_Expiration__c= dsd.Avaya_Contract_Expiration__c));
                            } 
                            }
                            
                        }
                        system.debug('test navaneetha 123'+ mapdsropp.values());
                        update mapdsropp.values();
                }
                
            }
            
    if(Trigger.isBefore && Trigger.isUpdate) {
        for(Deal_Support__c objDS : Trigger.new)
        {
            if(objDS.Support_Area__c != Trigger.oldMap.get(objDS.Id).Support_Area__c)
            {
                objDS.Status__c = 'New';
                objDS.Support_Email__c = objDS.Support_Email2__c = null;
                if(objDS.Support_Area__c == 'Product Management')
                {
                    // Unable_To_Determine : Unable to determine Solution or Product Manager contact
                    // below code has commented because solution category and product fields are no more in use confirmed by debi.
                   /* if((String.isBlank(objDS.Solution_Category__c) || String.isBlank(objDS.Product__c)) &&
                        objDS.Request_Type__c != 'End of Life information' && 
                       objDS.Request_Type__c != Label.Unable_To_Determine)
                    {
                            objDS.addError('Please select Solution category and product.');
                            return;
                    }*/
                    if(objDS.Request_Type__c == 'End of Life information' || objDS.Request_Type__c == Label.Unable_To_Determine)
                    {
                        objDS.Support_Email__c = Deal_Support_Email_Ids__c.getInstance('Release Management Team').NA__c;
                        return;
                    }
                    else
                    {
                        List<PM_Email_Ids__c> list_PMEmail = [SELECT Email__c FROM PM_Email_Ids__c WHERE Product__c = :objDS.Product__c LIMIT 1];
                        if(list_PMEmail.size() > 0)
                        {
                            objDS.Support_Email__c = list_PMEmail[0].Email__c;
                            return;
                        }  
                        else
                        {
                            objDS.Product__c.addError('Product not supported.');
                            return;
                        }
                    }
                }
                objDS.Solution_Category__c = objDS.Product__c = null;
                Deal_Support_Email_Ids__c objDSEmail;
                if(objDS.Support_Area__c == 'Finance')
                    objDSEmail = Deal_Support_Email_Ids__c.getInstance('##' + objDS.Request_Type__c);
                else if(objDS.Support_Area__c == 'Pricing')
                    objDSEmail = Deal_Support_Email_Ids__c.getInstance('$$' + (objDS.Request_Type__c.length() > 32 ? objDS.Request_Type__c.mid(0,32).trim() : objDS.Request_Type__c));
                else if(objDS.Support_Area__c == 'Business Consulting')
                    objDSEmail = Deal_Support_Email_Ids__c.getInstance('@@' + (objDS.Request_Type__c.length() > 32 ? objDS.Request_Type__c.mid(0,32).trim() : objDS.Request_Type__c));
                else if(objDS.Support_Area__c == 'Customer Care')
                    objDSEmail = Deal_Support_Email_Ids__c.getInstance('%%' + (objDS.Request_Type__c.length() > 30 ? objDS.Request_Type__c.mid(0,30).trim() : objDS.Request_Type__c));
                else if(objDS.Support_Area__c == 'Play Support' && objDS.Request_Type__c =='Play Assistance' && objDS.Primary_Play__c == null ){
                    objDS.Primary_Play__c.addError('Required - Primary Play'); 
                 }
                else if(objDS.Support_Area__c == 'Play Support' && objDS.Request_Type__c =='Play Assistance' && objDS.Primary_Play__c != null ) /**********change request shared by Trevor and Debora Lane to get Email ids using Offering Type ******/
                 {
                     if(objDS.Primary_Play__c != null ){
                     if(objDS.Primary_Play__c == '2019 Play 3 Digital Service'){  
                     objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 3 Assistance');
                     if(objDS.P2P_Region__c == 'EMEA')
                     fetchSupportEmails(objDS,(String)objDSEmail.EMEA__C);
                     if(objDS.P2P_Region__c == 'APAC')
                     fetchSupportEmails(objDS,(String)objDSEmail.APAC__C);
                     if(objDS.P2P_Region__c == 'LATAM')
                     fetchSupportEmails(objDS,(String)objDSEmail.LATAM__C);
                    if(objDS.P2P_Region__c == 'NA')
                     fetchSupportEmails(objDS,(String)objDSEmail.NA__C);
                    }
                    
                    else if(objDS.Primary_Play__c == '2019 Play 4 Digital Sales'){
                        objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 4 Assistance');
                            if(objDS.P2P_Region__c == 'EMEA')
                            fetchSupportEmails(objDS,(String)objDSEmail.EMEA__C);
                            if(objDS.P2P_Region__c == 'APAC')
                            fetchSupportEmails(objDS,(String)objDSEmail.APAC__C);
                            if(objDS.P2P_Region__c == 'LATAM')
                            fetchSupportEmails(objDS,(String)objDSEmail.LATAM__C);
                            if(objDS.P2P_Region__c == 'NA')
                            fetchSupportEmails(objDS,(String)objDSEmail.NA__C);
                        
                    }
                    else if(objDS.Primary_Play__c == '2019 Play 5 Automation at Work'){
                         objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 5 Assistance');
                            if(objDS.P2P_Region__c == 'EMEA')
                            objDSEmail = Deal_Support_Email_Ids__c.getInstance('Play 5 Assistance');
                            if(objDS.P2P_Region__c == 'EMEA')
                            fetchSupportEmails(objDS,(String)objDSEmail.EMEA__C);
                            if(objDS.P2P_Region__c == 'APAC')
                            fetchSupportEmails(objDS,(String)objDSEmail.APAC__C);
                            if(objDS.P2P_Region__c == 'LATAM')
                            fetchSupportEmails(objDS,(String)objDSEmail.LATAM__C);
                            if(objDS.P2P_Region__c == 'NA')
                            fetchSupportEmails(objDS,(String)objDSEmail.NA__C);
                        
                    }
                     }
                     else{
                          objDS.Primary_Play__c .addError('Required - Primary Play');
                     }
                     
                 }
                
                 
                  else if(objDS.Support_Area__c == 'Play Support' && objDS.Request_Type__c =='Migrations Assistance') /**********p2p*/
                 { objDSEmail = Deal_Support_Email_Ids__c.getInstance('P2P Migrations Assistance');
                     if(objDS.P2P_Region__c == 'EMEA')
                     fetchSupportEmails(objDS,(String)objDSEmail.EMEA__C);
                     if(objDS.P2P_Region__c == 'APAC')
                     fetchSupportEmails(objDS,(String)objDSEmail.APAC__C);
                     if(objDS.P2P_Region__c =='LATAM')
                     fetchSupportEmails(objDS,(String)objDSEmail.LATAM__C);
                  if(objDS.P2P_Region__c == 'NA')
                     fetchSupportEmails(objDS,(String)objDSEmail.NA__C);
                 }
                else
                    objDSEmail = Deal_Support_Email_Ids__c.getInstance(objDS.Support_Area__c);
                
                if(objDSEmail != null)
                {
                    if(objDS.Support_Area__c == 'Finance' && objDS.Country_Name__c == 'Brazil')
                        fetchSupportEmails(objDS,(String)objDSEmail.BRAZIL__c);
                    else if(objDS.Support_Area__c == 'Deal Factory' && objDS.Country_Name__c == 'United States')
                        fetchSupportEmails(objDS,(String)objDSEmail.US__c);
                    else
                        fetchSupportEmails(objDS,(String)objDSEmail.get(objDS.Region__c + '__c'));
                }
                else
                    objDS.Support_Area__c.addError('Support Area not supported.');
            }
            
        }        
        if(trigger.isUpdate)
        {
          if(trigger.old[0].Status__c != trigger.new[0].Status__c)
            trigger.new[0].Previous_Updated_Date__c = trigger.old[0].lastmodifieddate;
         
         if(trigger.new[0].Support_Area__c == 'Sales Ops' && trigger.new[0].Request_Type__c == 'Data Management' && trigger.new[0].Focus_Area__c == 'Account' )
            {
               list<Account> accnt1 = new list<Account>();
                accnt1 = [Select id, Name, Ownerid,CSM_Account_Owner__c,SAP_Account_Code__c,Owner.Email,Owner.IsActive,Owner.Manager.Email, CSM_Account_Owner__r.Email,CSM_Account_Owner__r.IsActive, CSM_Account_Owner__r.Manager.Email from Account where id =: trigger.new[0].Account__C];
               if(accnt1.size()>0){
                trigger.new[0].Genesys_Advisor_Account_Email__c = accnt1[0].CSM_Account_Owner__r.Email ; 
                trigger.new[0].Genesys_Advisors_manager_email__c = accnt1[0].CSM_Account_Owner__r.Manager.Email; }
            }
            
        if(trigger.new[0].Request_Type__c == 'Cloud Migration Assistance' && trigger.new[0].Owner_Approval__c == 'Approved')    
        trigger.new[0].Request_Deal_Incentives__c = 'Incentive 2';    
                                    
        
        }
        
        
        
    }
    @testVisible
    void fetchSupportEmails(Deal_Support__c objDS,String strEmailIds)
    {
        if(String.isNotBlank(strEmailIds))
        {
            List<String> list_EmailIds = strEmailIds.split(';');            
            objDS.Support_Email__c =list_EmailIds[0]; 
            if(list_EmailIds.size() > 1)
                objDS.Support_Email2__c = list_EmailIds[1]; 
        }
    }
    
    integer  i ;
     
        
}