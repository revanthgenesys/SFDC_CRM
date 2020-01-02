@isTest(SeeAllData = true)
private class CheckServiceContractAndCloudDeploy_Test
{
    static testmethod void testSC(){
        try{
            //Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            System.runAs(runAsUser[0]) {
                RecordType objRecType = [select id from RecordType where name =: 'EMG - Customer Record Type'];
                objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                objTestAccount.Type = 'Customer';
                objTestAccount.Offering_Type__c = 'PureCloud';
                objTestAccount.RecordTypeid = objRecType.id;
                list_Acc.add(objTestAccount);
                
                insert list_Acc;
                
                objTestAccount.Offering_Type__c = 'PureCloud;PureConnect Cloud;';
                update objTestAccount;
                
                List<Contact>list_Con = TestUtil.createContacts(1,list_Acc[0],true);
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                //objTestOppty.BusinessPartner__c = objSoldTo.id;
                objTestOppty.Primary_Line_of_Business__c = 'Cloud';
                objTestOppty.Lines_of_Businesses__c = 'PureCloud'; 
                //insert objTestOppty;
                
                //objTestOppty.BusinessPartner__c = objSoldTo.id;
                objTestOppty.StageName = '6.Closed' ;
                objTestOppty.Win_Loss_Status__c = 'Won' ;
                objTestOppty.ForecastStatus__c = '0.Booked';
                insert objTestOppty;
                
                List<ServiceContract> list_SC = TestUtil.createServiceContracts2(1,false,list_Acc[0]);
                list_SC[0].Agreement_Status__c = 'Active';//'Closed';
                list_SC[0].Accountid = objTestAccount.id;
                list_SC[0].Override_Platform_Type__c = 'Premise';
                list_SC[0].Override_Offering_Type__c = 'PureEngage';
                Test.startTest();
                insert list_SC;
                
                list_SC[0].Agreement_Status__c = 'Closed';
                update list_SC;
                
                list_SC[0].Service_Contract_Type__c= 'Rental';
                update list_SC;
                
                Cloud_Deployment__c objCD = new Cloud_Deployment__c();
                objCD.Support_Status__c = 'Active';
                objCD.Cloud_Platform__c = 'PureCloud';
                objCD.Account__c = objTestAccount .id;
                insert objCD;
                
                objCD.Support_Status__c = 'Inactive';
                objCD.Cloud_Platform__c = 'PureEngage Cloud';
                update objCD;
                
                objCD.Cloud_Platform__c = 'PureConnect Subscription';
                update objCD;
                
                objCD.Cloud_Platform__c = 'Outbound Engagement';
                update objCD;
                
                objCD.Cloud_Platform__c = 'PureEngage Subscription';
                update objCD;
            
                List<string>lst= new List<string>();
                lst.add('aa@a.com');
                CheckServiceContractAndCloudDeploy.ServiceContractAndCd(objTestAccount);                        
                CheckServiceContractAndCloudDeploy.EmailNotification('aa','aa',lst);
            }
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
    
    
    static testmethod void testCD(){
        try{
            Test.startTest();
            //Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Account objSoldTo;
            
            List<Account>list_Acc = new List<Account>();
            List<Address__c>list_Address = new List<Address__c>();
            Opportunity objTestOppty;
            Cloud_Deployment__c objCD = new Cloud_Deployment__c();
            
            List<User> runAsUser = TestUtil.createUsers(1, false);
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                objTestAccount.Type = 'Customer';
                list_Acc.add(objTestAccount);                
                insert list_Acc;
                
                List<Contact>list_Con = TestUtil.createContacts(1,list_Acc[0],true);
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                objTestOppty.Primary_Line_of_Business__c = 'Cloud';
                objTestOppty.Lines_of_Businesses__c = 'PureCloud'; 
                objTestOppty.StageName = '6.Closed' ;
                objTestOppty.Win_Loss_Status__c = 'Won' ;
                objTestOppty.ForecastStatus__c = '0.Booked';
                insert objTestOppty;
                                
                
                objCD.Support_Status__c = 'Inactive';
                objCD.Account__c = objTestAccount .id;
                insert objCD;
                
                objCD.Support_Status__c = 'Inactive';
                update objCD;
                
                List<ServiceContract> list_SC = TestUtil.createServiceContracts2(1,false,list_Acc[0]);
                list_SC[0].Agreement_Status__c = 'Active';
                list_SC[0].Override_Platform_Type__c = 'Cloud';
                list_SC[0].Override_Offering_Type__c = 'PureEngage';
                insert list_SC;
                
                list_SC[0].Agreement_Status__c = 'Closed';
                update list_SC;
                
                CheckServiceContractAndCloudDeploy.EmailBody(true,'dddd',list_Acc[0]);      
                
                delete objCD;            
            }
            List<string>lst= new List<string>();
            lst.add('aa@a.com');
            CheckServiceContractAndCloudDeploy.EmailNotification('aa','aa',lst);  
            
                    
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
}