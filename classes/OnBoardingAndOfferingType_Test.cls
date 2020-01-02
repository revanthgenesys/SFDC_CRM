@isTest(SeeAllData = true)
private class OnBoardingAndOfferingType_Test
{
    static testmethod void testOnBoarding()
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
            
            List<string>list_Rec = new List<string>();
            list_Rec.add('EMG - Customer Record Type');
            list_Rec.add('GEN - Opportunity Record Type');
            Map<id,RecordType>map_rec = new Map<id,RecordType>([select id,name from RecordType where name IN : list_Rec]);
            //RecordType objRecType_Opp = [select id,name from RecordType where name =: 'GEN - Opportunity Record Type'];
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                //objTestAccount.MAC_Address__c = 'aa';
                //objTestAccount.Machine_Name__c = 'aa';
                
                for(string s: map_rec.keySet())
                {
                  if(map_rec.get(s).name == 'EMG - Customer Record Type')
                   objTestAccount.RecordTypeId = s;
                }
                //insert objTestAccount;
                list_Acc.add(objTestAccount);
                
                objSoldTo = new Account( Name='Test Account2', Status__c = 'Active' );
                objSoldTo.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                //insert objSoldTo;
                //objSoldTo.MAC_Address__c = 'aa';
                //objSoldTo.Machine_Name__c = 'aa';
                list_Acc.add(objSoldTo);
                insert list_Acc;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                objTestOppty.BusinessPartner__c = objSoldTo.id;
                objTestOppty.Primary_Line_of_Business__c = 'Cloud';
                objTestOppty.Lines_of_Businesses__c = 'PureCloud'; 
                //objTestOppty.RecordTypeId = objRecType_Opp.id;
                for(string s: map_rec.keySet())
                {
                  if(map_rec.get(s).name == 'GEN - Opportunity Record Type')
                   objTestOppty.RecordTypeId = s;
                }
                insert objTestOppty;
                
             
             
              Address__c objAddress = new Address__c();
              objAddress.Type__c = 'Corporate';
              objAddress.Address_Type__c = 'Sold To';
              objAddress.Active_Status__c = true;
              objAddress.Is_Primary__c = true;
              objAddress.Account__c = objSoldTo.id; 
              //insert objAddress;
              list_Address.add(objAddress);
              
              Address__c objAddress2 = new Address__c();
              objAddress2.Type__c = 'Corporate';
              objAddress2.Address_Type__c = 'Sold To';
              objAddress2.Active_Status__c = true;
              objAddress2.Is_Primary__c = true;
              objAddress2.Account__c = objTestAccount.id; 
              //insert objAddress2;
              list_Address.add(objAddress2);
              
              insert list_Address;
              
                //objTestOppty.BusinessPartner__c = objSoldTo.id;
                objTestOppty.StageName = '6.Closed' ;
                objTestOppty.Win_Loss_Status__c = 'Won' ;
                objTestOppty.ForecastStatus__c = '0.Booked';
                update objTestOppty;
                
            
                List<string>lst= new List<string>();
                lst.add('aa@a.com');
                OnBoardingAndOfferingType.EmailNotification('aa','aa',lst);
                //OnBoardingAndOfferingType.OnBoarding(objTestOppty,objTestOppty,false);
            }
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
    
   static testmethod void testOnBoarding2()
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
            //List<Address__c>list_Address = new List<Address__c>();
            RecordType objRecType = [select id,name from RecordType where name =: 'EMG - Customer Record Type'];
            RecordType objRecType_Opp = [select id,name from RecordType where name =: 'GEN - Opportunity Record Type'];
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                //insert objTestAccount;
                //objTestAccount.MAC_Address__c = 'aa';
                //objTestAccount.Machine_Name__c = 'aa';
                objTestAccount.RecordTypeId = objRecType.id;
                list_Acc.add(objTestAccount);
                
                objSoldTo = new Account( Name='Test Account2', Status__c = 'Active' );
                objSoldTo.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                //insert objSoldTo;
                //objSoldTo.MAC_Address__c = 'aa';
                //objSoldTo.Machine_Name__c = 'aa';
                list_Acc.add(objSoldTo);
                
                insert list_Acc;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                objTestOppty.RecordTypeId = objRecType_Opp.id;
                //objTestOppty.BusinessPartner__c = objSoldTo.id;
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
                
                //OnBoardingAndOfferingType.OnBoarding(objTestOppty,objTestOppty,false);
            }
            
            
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
    
    static testmethod void testOnBoarding3()
    {
        try
        {
            Test.startTest();
            
            
            //Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            
            List<Account>list_Acc = new List<Account>();
            
            List<User> runAsUser = TestUtil.createUsers(1, false);
            
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account', Status__c = 'Expired Maintenance' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                //insert objTestAccount;
                //objTestAccount.MAC_Address__c = 'aa';
                //objTestAccount.Machine_Name__c = 'aa';
                objTestAccount.Date_of_Offboard__c = Date.today().addyears(-4);
                list_Acc.add(objTestAccount);
                insert list_Acc;
                
                 ExpiredMaintenanceAccount  obj = new ExpiredMaintenanceAccount();
                 Database.executebatch(obj,200);
            }
            Test.stopTest();
        }
        catch(CalloutException e){}
    }     
}