@isTest(SeeAllData = true)
private class LeadReferralRegistration_Utility_Test
{
    static testmethod void testLeadRef()
    {
        try
        {
            Test.startTest();
            //Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            Country__c objContry = [select id from Country__c limit 1];
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                objTestAccount.Type = 'Customer';
                list_Acc.add(objTestAccount);
                insert list_Acc;
                
                List<Contact>list_Con = TestUtil.createContacts(1,list_Acc[0],true);
                
                /*objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                //objTestOppty.BusinessPartner__c = objSoldTo.id;
                objTestOppty.Primary_Line_of_Business__c = 'Cloud';
                objTestOppty.Lines_of_Businesses__c = 'PureCloud'; 
                objTestOppty.StageName = '6.Closed' ;
                objTestOppty.Win_Loss_Status__c = 'Won' ;
                objTestOppty.ForecastStatus__c = '0.Booked';
                insert objTestOppty;*/
                
               Lead_Referral_Registration__c objLead = new Lead_Referral_Registration__c();
                
               objLead.End_User_Account__c = objTestAccount.id;
               objLead.Account__c = objTestAccount.id;
               objLead.Customer_Contact_Country__c = objContry.id;      // End User Country
               
               objLead.Number_of_Agents__c = '1-5';
               objLead.Offerings_Type__c = 'PureCloud';
               objLead.Primary_Solution_Category__c = 'Digital';
               objLead.What_is_the_Expected_Close_Date__c = Date.Today();
               
               objLead.Description__c ='fgsdfs';
               objLead.If_Yes__c='sdsf';
               objLead.License_Amount__c=22;
               objLead.Annual_Contract_Value_Amount__c=77;
               objLead.Genesys_AE__c='Test';
               objLead.Primary_Contact__c = list_Con[0].id;      
               //objLead.Campaign_ID__c;
               insert objLead;
               objLead.Status__c = 'Approved';
               update objLead;            
              LeadReferralRegistration_Utility.newOppFromOppRegistr(objLead.id,'OppRegistration');
               
            Test.stopTest();
          }  
        }
        catch(CalloutException e){}
    }
}