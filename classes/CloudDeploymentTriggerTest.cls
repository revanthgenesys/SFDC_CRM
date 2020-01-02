@isTest(SeeAllData = true)
private class CloudDeploymentTriggerTest{
      static testmethod void testOnBoarding2() {
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
            //List<Address__c>list_Address = new List<Address__c>();
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                //insert objTestAccount;
                list_Acc.add(objTestAccount);
                
                objSoldTo = new Account( Name='Test Account2', Status__c = 'Active' );
                objSoldTo.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                //insert objSoldTo;
                list_Acc.add(objSoldTo);
                
                insert list_Acc;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                //objTestOppty.BusinessPartner__c = null;
                objTestOppty.Primary_Line_of_Business__c = 'Cloud';
                objTestOppty.Lines_of_Businesses__c = 'PureCloud'; 
                insert objTestOppty;
                
              Address__c objAddress = new Address__c();
              
              objAddress.Type__c = 'Corporate';
              objAddress.Address_Type__c = 'Sold To';
              objAddress.Active_Status__c = true;
              objAddress.Is_Primary__c = true;
              objAddress.Account__c = objTestAccount.id; 
              //insert objAddress;
              list_Address.add(objAddress);
              
              Address__c objAddress2 = new Address__c();

              objAddress2.Type__c = 'Corporate';
              objAddress2.Address_Type__c = 'Sold To';
              objAddress2.Active_Status__c = true;
              objAddress2.Is_Primary__c = true;
              objAddress2.Account__c = objSoldTo.id; 
              //insert objAddress2;
              list_Address.add(objAddress2);
              insert list_Address;
              
                //objTestOppty.BusinessPartner__c = objSoldTo.id;
                objTestOppty.StageName = '6.Closed' ;
                objTestOppty.Win_Loss_Status__c = 'Won' ;
                objTestOppty.ForecastStatus__c = '0.Booked';
                update objTestOppty;
               
               Cloud_Deployment__c cloud = new Cloud_Deployment__c();
               cloud.Name = 'Test Cloud';
               cloud.Account__c = list_Acc[0].Id;
               cloud.Cloud_Platform__c = 'Business/Enterprise Edition';
               cloud.Status__c = 'Deployment';
               cloud.Support_Status__c = 'Active';    
               cloud.Care_Level__c = 'Business Care for Cloud';
               cloud.CSM_Owner__c = userinfo.getuseriD();
               cloud.Sold_To_Account__c = list_Acc[0].Id;
               insert cloud;
               
               Cloud_Deployment__c cloud1 = new Cloud_Deployment__c();
               cloud1.Name = 'Test Cloud 1';
               cloud1.Account__c = list_Acc[0].Id;
               cloud1.Support_Status__c  = 'Billing Only';
               cloud1.Id= cloud.Id;
               update cloud1;
                
            }
            
            
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
}