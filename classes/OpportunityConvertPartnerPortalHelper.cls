/*created by :Swastika 
Created on: June/26/2017
Fuction: uses the class in trigger trgOpportunityConvert when automatically convert the partner portal registration to opportuntiy
*/

public without sharing class OpportunityConvertPartnerPortalHelper{
     private static String REGISTR_OBJECT = 'OppRegistration';    
     
     private static String errMsg1 = 'No valid object to convert into an Opportunity has been provided.';
     private static String dmlErr='', retMsg='';
     private static Opportunity opp;
     private static string ChannelManagerUserId='',AEEUserId='',strEmailIds ='';
     
    public static String newOppFromOppRegistr(String objId, String objType) {
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
            dmlErr = 'Exception: ' + ex.getTypeName() + ': ' + ex.getMessage() + ' -- ' + ex.getCause()+'---'+ex.getLineNumber();
            system.Debug('dmlErr-->'+dmlErr);
            err = true;
        }  
             
        if (objType == REGISTR_OBJECT && !err ) {
            err = oppFromOppRegistr(objId); 
        }        
     
        if ( opp.Id != null ) 
        {
           retMsg = 'Opportunity [' + opp.Name + '] has been created.';
           //Naresh Kumar   06/29   Commenting below line as it is giving bulk email error.
           //send mail to Channel manager and AE of Genesys about the opportunity
           //SendEmail.sendSingleEmail(strEmailIds,'Opportunity [' + opp.Name + '] created.','Opportunity [' + opp.Name + '] has been created.','Genesys');
         }
        else 
           retMsg = 'Unable to create an opportunity due to errors.\n';     
           system.Debug('err--->'+err);   
           
        if ( err ) {
            retMsg += '\n\n Additional Infornation: \n' + dmlErr;
           //send mail to Channel manager and AE of Genesys about the error
           System.debug('Error occured in opp creation'+strEmailIds);
           SendEmail.sendSingleEmail(strEmailIds,'Error -while converting to Opportunity','Please find the error detail:' +retMsg  ,'Genesys');
           system.Debug('mail triggered');
                   }   
        System.debug('Opportunity Created & Id = ' + opp.Id);
          
        return retMsg;  
     }
     
     private static Boolean oppFromOppRegistr(String oppRegId)  {
        Boolean err=false;
                
        List<Partner_Portal_Prospect__c> oppReg = [SELECT ID, Name,for_workflow__c , End_User_Account__c, End_User_Account__r.Owner.Id, End_User_Account__r.Name, Customer_Contact_Country__c,
                                                        Account__c, End_User_Account__r.Country__r.Region__c, End_User_Account__r.Channel_Manager__c, Description__c,
                                                        Number_of_Agents__c, CurrencyIsoCode, Primary_Solution_Category__c, What_is_the_Expected_Close_Date__c,
                                                        Total_Value__c, Platform_Type__c, Offerings_Type__c, Opportunity_Channel_Manager__c, Regions__c, CreatedById, 
                                                        Primary_Contact__c, Status__c, Offering_Details__c, If_Yes__c, Opportunity_Type__c, Campaign_Source__c, 
                                                        License_Amount__c, Account_Executive_at_Genesys__c,Type__c, Products__c, Campaign_ID__c, Genesys_AE__c, Vendor_in_Place__c,
                                                        Will_this_deal_involve_SMART_Use_Cases__c, Annual_Contract_Value_Amount__c, Lead_Offer__c,Promotional_Offer__c FROM Partner_Portal_Prospect__c WHERE ID = :oppRegId LIMIT 1];
        
        if ( oppReg.isEmpty() ) {
           retMsg = errMsg1;
           return true;
        }
       ChannelManagerUserId =  oppReg[0].Opportunity_Channel_Manager__c;
       AEEUserId = oppReg[0].Account_Executive_at_Genesys__c;
       //Find the email ids
       //strEmailIds = getEmailIds(ChannelManagerUserId,AEEUserId);
      strEmailIds='mukunthan.koothan@genesys.com';
      //Debora.Lane@genesys.com,Roland.Mari@genesys.com
       /// create opportunity
       String ownerId;
       //Commented/Added by Swastika on Aug/08/2017 for Issue #UAT436 Release 2<start>
       /*if ( oppReg[0].End_User_Account__r.Country__r.Region__c != null)
           if(oppReg[0].Regions__c == 'North America' )  */ 
        if(oppReg[0].Regions__c == 'North America' && oppReg[0].Type__c == 'New Logo' )   
       //Commented/Added by Swastika on Aug/08/2017 for Issue #UAT436 Release 2<end>    
           ownerId = oppReg[0].Opportunity_Channel_Manager__c;
       else
           ownerId = oppReg[0].End_User_Account__r.Owner.Id;
                                                                        
       try {      
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
           if(oppReg[0].Status__c == 'Rejected'){
                opp.Partner_Opportunity_Source__c = 'Partner Source Opportunity';
                opp.Partner_Opportunity_Status__c = 'Submitted';    
                opp.RecordTypeId = getRecTypeId('Partner_Opportunity');
                opp.Forecast_Opportunity__c = false;
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
           opp.Lead_Offer__c = oppReg[0].Lead_Offer__c;
           opp.CurrencyIsoCode       = oppReg[0].CurrencyIsoCode; 
           opp.Name                  = oppReg[0].Name;
           opp.OwnerId               = ownerId;
           opp.AccountId             = oppReg[0].End_User_Account__c;
           opp.BusinessPartner__c    = oppReg[0].Account__c;
           opp.Country__c            = oppReg[0].Customer_Contact_Country__c;      // End User Country
           opp.Sold_To_Country__c    = oppReg[0].Customer_Contact_Country__c;   // Sold To Country 
           opp.NumberofAgents__c     = oppReg[0].Number_of_Agents__c;
           opp.Primary_Line_of_Business__c = oppReg[0].Platform_Type__c;
           opp.Lines_of_Businesses__c        = oppReg[0].Offerings_Type__c;
           opp.Primary_Solution__c  = oppReg[0].Primary_Solution_Category__c;
           opp.CloseDate  = oppReg[0].What_is_the_Expected_Close_Date__c;
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
           opp.Who_did_Genesys_Replace__c = oppReg[0].Vendor_in_Place__c;    
           List<Campaign> campaigns = [SELECT id FROM Campaign WHERE Name =: oppReg[0].Campaign_Source__c];
           if(!campaigns.isEmpty())
                opp.Campaign_Source__c = campaigns[0].id;               
           opp.Direct_Indirect_Sale__c = 'Indirect';
           opp.Type = oppReg[0].Type__c;
           opp.Products__c = oppReg[0].Products__c;
           opp.Campaign_ID__c = oppReg[0].Campaign_ID__c;   
           opp.Promotional_Offer__c = oppReg[0].Promotional_Offer__c;
           insert opp;
           
           System.debug('opp= ' + opp);
           
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
           objTM = new OpportunityTeamMember(OpportunityId = opp.id, UserId = oppReg[0].Opportunity_Channel_Manager__c, TeamMemberRole = 'Channel Manager', OpportunityAccessLevel = 'Edit');
           list_OfTeamMemberToBeInserted.add(objTM);
           
           //Add Account Executive at Genesys
           if(oppReg[0].Account_Executive_at_Genesys__c !=null){
               objTM = new OpportunityTeamMember(OpportunityId = opp.id, UserId = oppReg[0].Account_Executive_at_Genesys__c , TeamMemberRole = 'Sales Rep', OpportunityAccessLevel = 'Edit');
               list_OfTeamMemberToBeInserted.add(objTM);
           }
           insert list_OfTeamMemberToBeInserted;
           
        
       }
       catch (Exception ex) {
          System.debug(ex.getMessage()); 
          dmlErr = 'Exception: ' + ex.getTypeName() + ': ' + ex.getMessage() + ' -- ' + ex.getCause()+'---'+ex.getLineNumber();
          return true;
       }
       
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
       
       ///update End User Account Owner by Account executive of Genesys
          err = UpdateEndUserAccount(OppReg[0].End_User_Account__c,OppReg[0].Account_Executive_at_Genesys__c);
      
       ///update Registration even if LineItems failed
       if (opp.Id != null )  {
           try {
              oppReg[0].Opportunity__c = opp.Id;
              update oppReg[0];
           }
           catch (Exception ex) {
            dmlErr = 'Exception: ' + ex.getTypeName() + ': ' + ex.getMessage() + ' -- ' + ex.getCause()+'---'+ex.getLineNumber();
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
            dmlErr = 'Exception: ' + ex.getTypeName() + ': ' + ex.getMessage() + ' -- ' + ex.getCause()+'---'+ex.getLineNumber();
           err = true;
       } 

       return err;
     }
     
     private static Boolean UpdateEndUserAccount(Id accountId,id AEId){
         Boolean err = false;
         if(accountId == null)
            return err;
         account obAcc=[SELECT Id, OwnerId FROM Account Where Id=:accountId LIMIT 1];
         try {
         if (obAcc!=null){
             obAcc.OwnerId= AEId;
             update obAcc;
             }
           }
        catch (Exception ex) {
            dmlErr = 'Exception: ' + ex.getTypeName() + ': ' + ex.getMessage() + ' -- ' + ex.getCause()+'---'+ex.getLineNumber();
           err = true;
       } 

       return err;      
     }
   /*  private static string getEmailIds(string channelManager, string AE)
     {
     string strEmails='';
     list<user> list_users= [SELECT Id, Email FROM user where (id =:channelManager OR id=:AE)];
         if(list_users!=null){
           for(user objUser: list_users) 
               if(strEmails =='') 
                   strEmails= objUser.Email;
               else
                  strEmails+= ','+objUser.Email;     
         }
         return strEmails;
     }*/
}