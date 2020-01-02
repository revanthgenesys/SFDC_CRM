global without sharing class OpportunityNewFromRegistration {
 
     private static String REGISTR_OBJECT = 'OppRegistration';
     private static String LEAD_OBJECT = 'LeadOppRegistration';
     
     private static String errMsg1 = 'No valid object to convert into an Opportunity has been provided.';
     private static String dmlErr='', retMsg='';
     private static Opportunity opp;
    
    public static String createNewOppForPartner(String dealRegId){
        /// set common values
        opp  = new Opportunity();                
        opp.StageName         = '1.Understand Needs';
        opp.ForecastStatus__c = '5.Pipeline';
        opp.Direct_Indirect_Sale__c = 'Indirect';
        opp.Type              = 'Existing Business - Expansion';
        opp.Expiration_Date__c = Date.today().addYears(1);
        oppFromOppRegistr(dealRegId);      
        return opp.id;         
    }
        
     webservice static String newOppFromOppRegistr(String objId, String objType) {
        if (objId == null || objType == null )
            return errMsg1;
        System.debug('objId = ' + objId);
        Boolean err = false;   
        /// set common values
        try {     
            opp  = new Opportunity();        
            opp.RecordTypeId = getRecTypeId('GEN_Opportunity_Record_Type_New');
            opp.StageName         = '1.Understand Needs';
            opp.ForecastStatus__c = '5.Pipeline';
            opp.Direct_Indirect_Sale__c = 'Indirect';
            opp.Type              = 'Existing Business - Expansion';
            opp.Expiration_Date__c = Date.today().addYears(1);
            opp.Forecast_Opportunity__c = true;
        }
        catch (Exception ex) {
            dmlErr = ex.getMessage();
            err = true;
        }   
             
        if (objType == REGISTR_OBJECT && !err ) {
            err = oppFromOppRegistr(objId); 
        }
        else if (objType == LEAD_OBJECT && !err )  {
            err = oppFromLeadRegistr(objId);
        }
     
        if ( opp.Id != null ) 
           retMsg = 'Opportunity [' + opp.Name + '] has been created.';
        else 
           retMsg = 'Unable to create an opportunity due to errors.\n';
           
        if ( err ) {
            retMsg += '\n\n Additional Infornation: \n' + dmlErr;
        }   
      
        return retMsg;  
     }
     
     
     private static Boolean oppFromOppRegistr(String oppRegId)  {
        Boolean err=false;
                
        List<Partner_Portal_Prospect__c> oppReg = [SELECT ID, Name, End_User_Account__c, End_User_Account__r.Owner.Id, End_User_Account__r.Name, Customer_Contact_Country__c,
                                                        Account__c, End_User_Account__r.Country__r.Region__c, End_User_Account__r.Channel_Manager__c, Description__c,
                                                        Number_of_Agents__c, CurrencyIsoCode, Primary_Solution_Category__c, What_is_the_Expected_Close_Date__c,
                                                        Total_Value__c, Platform_Type__c, Offerings_Type__c, Opportunity_Channel_Manager__c, Regions__c, CreatedById, 
                                                        Primary_Contact__c, Status__c, Offering_Details__c, If_Yes__c, Opportunity_Type__c, Campaign_Source__c, End_Date__c,
                                                        License_Amount__c, Account_Executive_at_Genesys__c, Type__c, Products__c, Campaign_ID__c, Genesys_AE__c,Lead_Offer__c,
                                                        Will_this_deal_involve_SMART_Use_Cases__c, Annual_Contract_Value_Amount__c FROM Partner_Portal_Prospect__c WHERE ID = :oppRegId];
        
        if ( oppReg.isEmpty() ) {
           retMsg = errMsg1;
           return true;
        }
        
       /// create opportunity
       String ownerId;
       if ( oppReg[0].End_User_Account__r.Country__r.Region__c != null)
           if(oppReg[0].Regions__c == 'North America' )
           ownerId = oppReg[0].Opportunity_Channel_Manager__c;
       else
           ownerId = oppReg[0].End_User_Account__r.Owner.Id;
                                                                        
       //try {    
            /*  
           if(oppReg[0].Opportunity_Type__c == 'Add On')
              opp.RecordTypeId = getRecTypeId('GEN_Opportunity_Record_Type_New');
           else
              opp.RecordTypeId = getRecTypeId('Partner_Opportunity');
            */
           if(ownerId == null || ownerId == '')
               ownerId = UserInfo.getUserId();
           System.debug('oppReg = ' + oppReg[0]);
           opp.Partner_Opportunity_Registration__c  = oppReg[0].Id;
           system.debug('inside method before rejected code');
           if(oppReg[0].Status__c == 'Rejected'){
                opp.Partner_Opportunity_Source__c = 'Partner Sourced Not Registered';
                opp.Partner_Opportunity_Status__c = 'Submitted';    
                opp.RecordTypeId = getRecTypeId('Partner_Opportunity');
                opp.Forecast_Opportunity__c = false;
                opp.Lead_Offer__c = oppReg[0].Lead_Offer__c;
                System.debug('oppReg lead offer = ' + oppReg[0].Lead_Offer__c);
           }
           else{
               if(oppReg[0].Type__c == 'Existing Business - Expansion')
                    opp.Partner_Opportunity_Source__c = 'Partner Registered Opportunity Expansion';
               else
                    opp.Partner_Opportunity_Source__c = 'Partner Registered Opportunity';
               opp.Partner_Opportunity_Status__c = 'Approved';
               opp.RecordTypeId = getRecTypeId('GEN_Opportunity_Record_Type_New');
               opp.Forecast_Opportunity__c = true;
           }
           opp.CurrencyIsoCode       = oppReg[0].CurrencyIsoCode; 
           opp.Name                  = oppReg[0].Name;
           opp.OwnerId               = ownerId;
           opp.AccountId             = oppReg[0].End_User_Account__c;
           opp.BusinessPartner__c    = oppReg[0].Account__c;
           opp.Country__c            = oppReg[0].Customer_Contact_Country__c;      // End User Country
           opp.Sold_To_Country__c    = oppReg[0].Customer_Contact_Country__c;   // Sold To Country 
           opp.NumberofAgents__c     = oppReg[0].Number_of_Agents__c;
           opp.Primary_Line_of_Business__c   = oppReg[0].Platform_Type__c;
           opp.Lines_of_Businesses__c        = oppReg[0].Offerings_Type__c;
           opp.Primary_Solution__c  = oppReg[0].Primary_Solution_Category__c;
           opp.CloseDate  = oppReg[0].What_is_the_Expected_Close_Date__c;
           //opp.CloseDate  = oppReg[0].End_Date__c;
           opp.Partner_Submitted_Opportunity__c = oppReg[0].CreatedById;
           opp.Description        = oppReg[0].Description__c;
           opp.Offering_Detail__c = oppReg[0].Offering_Details__c;
           opp.CompetitionInfo__c = oppReg[0].If_Yes__c;
           opp.Opportunity_Type__c = (oppReg[0].Opportunity_Type__c == null ? 'New' : oppReg[0].Opportunity_Type__c);
           opp.License_Amount__c = oppReg[0].License_Amount__c;
           opp.ACV_Subscription_Only__c = oppReg[0].Annual_Contract_Value_Amount__c;
           opp.Will_this_deal_involve_SMART_Use_Cases__c = oppReg[0].Will_this_deal_involve_SMART_Use_Cases__c;    
           opp.Account_Executive__c = oppReg[0].Genesys_AE__c;
           opp.AE_Name__c = oppReg[0].Account_Executive_at_Genesys__c;
           opp.Contact__c = (String.isBlank(oppReg[0].Primary_Contact__c) == false) ? oppReg[0].Primary_Contact__c : NULL;                 
           List<Campaign> campaigns = [SELECT id FROM Campaign WHERE Name =: oppReg[0].Campaign_Source__c];
           if(!campaigns.isEmpty())
            opp.Campaign_Source__c = campaigns[0].id;
           opp.Direct_Indirect_Sale__c = 'Indirect';
           opp.Products__c = oppReg[0].Products__c;
           opp.Campaign_ID__c = oppReg[0].Campaign_ID__c;              
           opp.Type = oppReg[0].Type__c;
           insert opp;
           
           OpportunityTeamMember objTM;
           List<OpportunityTeamMember> list_OfTeamMemberToBeInserted = new List<OpportunityTeamMember>();
          
           Map<Id, Contact> map_OfIdVsDesignatedContacts = new Map<Id, Contact>([SELECT id FROM Contact WHERE AccountId =: oppReg[0].Account__c AND Designated_Partner_Contact__c = true]);
           List<User> list_OfContactUsers = [SELECT Id FROM User WHERE ContactId IN :map_OfIdVsDesignatedContacts.keySet() AND id !=: oppReg[0].CreatedById];
           //Adding designated contacts as a team members
           if(!list_OfContactUsers.isEmpty()){
               for(User eachUser : list_OfContactUsers){
                    objTM = new OpportunityTeamMember(OpportunityId = opp.id, UserId = eachUser.id, TeamMemberRole = 'Designated Partner Contact', OpportunityAccessLevel = 'Edit');    
                    list_OfTeamMemberToBeInserted.add(objTM);
               }        
           }
            
           //Adding partner as team member
           objTM = new OpportunityTeamMember(OpportunityId = opp.id, UserId = oppReg[0].CreatedById, TeamMemberRole = 'Sales Rep', OpportunityAccessLevel = 'Edit');
           list_OfTeamMemberToBeInserted.add(objTM);
         
           //Add channel Manager as Opportunity team member
           if(oppReg[0].Opportunity_Channel_Manager__c != null){
               objTM = new OpportunityTeamMember(OpportunityId = opp.id, UserId = oppReg[0].Opportunity_Channel_Manager__c, TeamMemberRole = 'Channel Manager', OpportunityAccessLevel = 'Edit');
               list_OfTeamMemberToBeInserted.add(objTM);
           }
           //Add Account Executive at Genesys
           if(oppReg[0].Account_Executive_at_Genesys__c !=null){
               objTM = new OpportunityTeamMember(OpportunityId = opp.id, UserId = oppReg[0].Account_Executive_at_Genesys__c , TeamMemberRole = 'Sales Rep', OpportunityAccessLevel = 'Edit');
               list_OfTeamMemberToBeInserted.add(objTM);
           }
           insert list_OfTeamMemberToBeInserted;
           
       /*  
       }
       catch (Exception ex) {
          System.debug(ex.getMessage()); 
          dmlErr = ex.getMessage();
          return true;
       }
       */
       /// Line Items
       List<Partner_Opporty_Registr_Product__c> oppRegProds = [SELECT Product__c, Amount_Currency__c
                                                                FROM Partner_Opporty_Registr_Product__c
                                                                WHERE Opporty_Registration__c = :oppRegId]; 
       if ( !oppRegProds.isEmpty() ) {                                                        
           Map<Id, Decimal> oppRegProdItems = new Map<Id, Decimal>();
           
           for (Partner_Opporty_Registr_Product__c regPr : oppRegProds) {
              oppRegProdItems.put(regPr.Product__c, regPr.Amount_Currency__c);
           }
           
           err = addOppLineItems(oppRegProdItems, oppReg[0].CurrencyIsoCode);
       }
       
       ///update Registration even if LineItems failed
       if ( opp.Id != null )  {
           try {
              oppReg[0].Opportunity__c = opp.Id;
              update oppReg[0];
           }
           catch (Exception ex) {
              dmlErr += '\n' + ex.getMessage();
              delete opp;
              err = true;
            }
       } 
                     
       return err;       
     }
     
     private static Boolean addOppLineItems(Map<Id, Decimal> prItems, String currencyCode)  {
       Boolean err = false;
       List<PricebookEntry> prcBkEntr = [SELECT Id, Product2Id
                                         FROM PriceBookEntry 
                                         WHERE PriceBook2.Name LIKE 'Sales PriceBook' 
                                           AND CurrencyIsoCode = :currencyCode 
                                           AND isActive = true AND Product2Id IN : prItems.keySet()];
                                           
       if ( prcBkEntr.isEmpty() ) {
           retMsg += '\n No PriceBook Entries have been found.\n';
           return true;
       }
       
       Map<Id, Id> prcBk = new Map<Id, Id>();
       for (PricebookEntry pb : prcBkEntr)
            prcBk.put(pb.Product2Id, pb.Id);        

       List<OpportunityLineItem> lnItems = new List<OpportunityLineItem>();           
       try {
            for ( Id prItemId : prItems.keySet() )  {
                  lnItems.add( new OpportunityLineItem( OpportunityId = opp.Id,
                                                        PricebookEntryId = prcBk.get(prItemId),
                                                        TotalPrice  = prItems.get(prItemId) ));                       
            }
                          
            insert lnItems;
        }
        catch (Exception ex) {
           dmlErr += '\n' + ex.getMessage();
           err = true;
       } 

       return err;
     }
     
     private static Boolean oppFromLeadRegistr(String ldRegId)  {
        Boolean err=false;
                
        List<Lead_Referral_Registration__c> ldReg = [SELECT ID, Name, End_User_Account__c, End_User_Account__r.Owner.Id, Customer_Contact_Country__c,
                                                        Account__c, End_User_Account__r.Country__r.Region__c, End_User_Account__r.Channel_Manager__c,
                                                        Number_of_Agents__c, Primary_Solution_Category__c, What_is_the_Expected_Close_Date__c, Lead_Offer__c, 
                                                        Platform_Type__c, Offerings_Type__c, Channel_Manager__c, End_User_Account__r.Name, CreatedById, Primary_Contact__c
                                                   FROM Lead_Referral_Registration__c WHERE ID = :ldRegId];
        
        if ( ldReg.isEmpty() ) {
           retMsg = errMsg1;
           return true;
        }
        
       /// create opportunity
       ID ownerId;
       if ( ldReg[0].End_User_Account__r.Country__r.Region__c != null  &&  ldReg[0].End_User_Account__r.Country__r.Region__c == 'North America' )
           ownerId = ldReg[0].Channel_Manager__c;
       else
           ownerId = ldReg[0].End_User_Account__r.Owner.Id;
                                                                        
       try {      
           opp.Lead_Referral_Registration__c  = ldReg[0].Id;
           opp.Partner_Opportunity_Source__c = 'Partner Registered Lead';
           opp.Name                  = ldReg[0].End_User_Account__r.Name + ' - ';
           opp.OwnerId               = ownerId;
           opp.AccountId             = ldReg[0].End_User_Account__c;
           opp.BusinessPartner__c    = ldReg[0].Account__c;
           opp.Country__c            = ldReg[0].Customer_Contact_Country__c;      // End User Country
           opp.Sold_To_Country__c    = ldReg[0].Customer_Contact_Country__c;   // Sold To Country 
           opp.NumberofAgents__c     = ldReg[0].Number_of_Agents__c;
           opp.Primary_Line_of_Business__c   = ldReg[0].Platform_Type__c;
           opp.Lines_of_Businesses__c  = ldReg[0].Offerings_Type__c;
           opp.Primary_Solution__c     = ldReg[0].Primary_Solution_Category__c;
           opp.CloseDate  = ldReg[0].What_is_the_Expected_Close_Date__c;
           opp.Contact__c = ldReg[0].Primary_Contact__c;         
           insert opp;
       }
       catch (Exception ex) {
          dmlErr = ex.getMessage();
          return true;
       }
       
       if ( opp.Id != null )  {
           try {
              ldReg[0].Opportunity__c = opp.Id;
              update ldReg[0];
           }
           catch (Exception ex) {
              dmlErr += '\n' + ex.getMessage();
              delete opp;
              err = true;
            }
       } 
                     
       return err;       
     }
     
     
     private static ID getRecTypeId (String recordTypeName) {
        
        List<RecordType> recTp = [SELECT ID FROM RecordType WHERE 
            DeveloperName =: recordTypeName AND SObjectType = 'Opportunity'];
        
        if ( !recTp.isEmpty() )
           return recTp[0].Id;
        else
           return null;          
     }
}