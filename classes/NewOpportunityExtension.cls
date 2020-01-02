//Naresh Kumar  06/21/2017 Overrides standard new opportunity button
public without sharing class NewOpportunityExtension {
    //whether it's partner portal or not
    public Boolean blnIsPartner {get; private set;}
    //opportunity record
    public Opportunity objOpp {get; set;}
    //hold list of end user account options
    public List<SelectOption> list_OfEndUsers {get; set;}
    //whether to show end user account opttions or not
    public Boolean showEndUserAccount {get; private set;}
    //constructor
    public NewOpportunityExtension(ApexPages.StandardController stdCtrl){ 
        blnIsPartner = UserInfo.getUserType() == 'PowerPartner';
        objOpp = new Opportunity(StageName = '1.Understand Needs', ForecastStatus__c = '5.Pipeline');                       
        showEndUserAccount = false;
    }
    
    public pageReference next1(){
        List<Contact> objContact = [SELECT AccountId, Account.Country__c FROM Contact WHERE id IN 
                                    (SELECT ContactId FROM User WHERE id =: System.UserInfo.getUserId())];        
        if(!objContact.isEmpty()){            
            if(objOpp.Type != 'New logo'){
                list_OfEndUsers = new List<SelectOption>();                
                List<Order__c> list_ofOrders = [SELECT End_User_Name__c, End_User_Name__r.Name FROM Order__c 
                    WHERE Sold_To_Name__c =: objContact[0].AccountId AND Status__c = 'Completed' order by End_User_Name__r.Name ASC];                
                //List<Opportunity> list_OfOpps = [SELECT AccountId, Account.Name FROM Opportunity WHERE BusinessPartner__c =: objContact[0].AccountId and StageName = '6.Closed' and Win_Loss_Status__c = 'Won'  ORDER BY Account.Name];
                Set<Id> set_OfAccountIds = new Set<Id>();
                for(Order__c eachOrder : list_ofOrders){
                    if(eachOrder.End_User_Name__c != null && !set_OfAccountIds.contains(eachOrder.End_User_Name__c)){
                        SelectOption newOption = new SelectOption(eachOrder.End_User_Name__c, eachOrder.End_User_Name__r.Name);   
                        list_OfEndUsers.add(newOption);
                        set_OfAccountIds.add(eachOrder.End_User_Name__c);
                    }
                }
                if(!list_ofOrders.isEmpty()){
                    showEndUserAccount = true;
                    return null;
                }
                else{
                    objOpp.Type = 'New logo';
                    return next2();
                }
            }
            else{
                return next2();
            }
        }
        return null;
    }
    
    public pageReference next2(){
        if(objOpp.Type == 'New logo')
            objOpp.RecordTypeId = getRecTypeId('Partner_Opportunity');
        else{
            objOpp.RecordTypeId = getRecTypeId('GEN_Opportunity_Record_Type_New');
            objOpp.Partner_Opportunity_Status__c = 'Approved';
            objOpp.Forecast_Opportunity__c = true;
        }
        List<Contact> objContact = [SELECT AccountId, Account.Country__c, Account.Country__r.Region__c, Account.ownerId FROM Contact WHERE id IN 
                                    (SELECT ContactId FROM User WHERE id =: System.UserInfo.getUserId())];
        if(!objContact.isEmpty()){
            objOpp.BusinessPartner__c = objContact[0].AccountId;
            objOpp.Sold_To_Country__c = objContact[0].Account.Country__c;
            if(objContact[0].Account.Country__r.Region__c == 'North America'){
                objOpp.OwnerId = objContact[0].Account.OwnerId;
            }
        }
        
        if(objOpp.AccountId != null){
            Account endUserAccount = [SELECT OwnerId, Name FROM Account WHERE id =: objOpp.AccountId];
            objOpp.OwnerId = endUserAccount.ownerId;
        }
        objOpp.Direct_Indirect_Sale__c = 'Indirect';
        objOpp.Partner_Opportunity_Source__c = 'Partner Sourced not registered';
        insert objOpp;
        List<OpportunityTeamMember> list_OfTeamMemberToBeInserted = new List<OpportunityTeamMember>();
        //Sharing opportunity with designated partner contacts
        List<Contact> contact = [SELECT AccountId FROM Contact WHERE id IN (SELECT ContactId FROM User WHERE id =: UserInfo.getUserId())];
        if(!contact.isEmpty()){
            Map<Id, Contact> map_OfIdVsDesignatedContacts = new Map<Id, Contact>([SELECT id FROM Contact WHERE AccountId =: contact[0].AccountId AND Designated_Partner_Contact__c = true]);
            List<User> list_OfContactUsers = [SELECT Id FROM User WHERE ContactId IN :map_OfIdVsDesignatedContacts.keySet()];// AND id !=: oppReg[0].CreatedById];
            //Adding designated contacts as a team members
            if(!list_OfContactUsers.isEmpty()){
                for(User eachUser : list_OfContactUsers){
                    OpportunityTeamMember objTM = new OpportunityTeamMember(OpportunityId = objOpp.id, UserId = eachUser.id, TeamMemberRole = 'Designated Partner Contact', OpportunityAccessLevel = 'Edit');    
                    list_OfTeamMemberToBeInserted.add(objTM);
               }        
            }
        }
        if(!list_OfTeamMemberToBeInserted.isEmpty())
            Database.insert(list_OfTeamMemberToBeInserted, false);
        
        //return new PageReference('/partner/' + objOpp.id + '/e?retURL=/'+objOpp.id);
        return new PageReference('/partner/apex/PartnerPortalOptyEdit?Id=' + objOpp.id);
    }
    
    private static ID getRecTypeId (String recordTypeName){        
        List<RecordType> recTp = [SELECT ID FROM RecordType WHERE 
            DeveloperName =: recordTypeName AND SObjectType = 'Opportunity'];        
        if ( !recTp.isEmpty() )
           return recTp[0].Id;
        else
           return null;          
     }
}