@isTest(SeeAllData = true)
private class clsOpportunityTriggerHelper_Test
{
    static testmethod void testCloudDeployment()
    {
        try
        {
            Test.startTest();
            
            Account objTestAccount;
            Account objSoldTo;
            
            User usr;
            
            List<Account>list_Acc = new List<Account>();
            List<Cloud_Deployment__c> list_CloudDeployment = new List<Cloud_Deployment__c>();
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            
            List<string>list_Rec = new List<string>();
            list_Rec.add('GEN - Opportunity Record Type');
            Map<id,RecordType>map_rec = new Map<id,RecordType>([select id,name from RecordType where name IN : list_Rec]);
            Map<ID, Opportunity> opplst = new Map<ID, Opportunity>();
            Map<ID, Opportunity> map_opplst = new Map<ID, Opportunity>();
            System.runAs(runAsUser[0]) 
            {
                //usr = new User(Email = 'test@test.com', FirstName = 'Test', IsActive=True);
                objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                
                for(string s: map_rec.keySet())
                {
                  if(map_rec.get(s).name == 'EMG - Customer Record Type')
                   objTestAccount.RecordTypeId = s;
                }
                insert objTestAccount;
                list_Acc.add(objTestAccount);
                
                objSoldTo = new Account( Name='Test Account2', Status__c = 'Active' );
                objSoldTo.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                list_Acc.add(objSoldTo);
                //insert list_Acc;
                
                //Map<Id, Account> mapacct = new Map<Id, Account>([Select ID, Name,OwnerId, CSM_Account_Owner__c, CSM_Account_Owner__r.Email from Account where Id =: list_Acc[0].OwnerId]);
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '6.Closed';
                objTestOppty.BusinessPartner__c = objSoldTo.id;
                objTestOppty.Primary_Line_of_Business__c = 'Cloud';
                objTestOppty.Lines_of_Businesses__c = 'PureCloud'; 
                objTestOppty.Win_Loss_Status__c = 'Loss';
                objTestOppty.ForecastStatus__c = '0.Booked';
                
                for(string s: map_rec.keySet())
                {
                  if(map_rec.get(s).name == 'GEN - Opportunity Record Type')
                   objTestOppty.RecordTypeId = s;
                }
                insert objTestOppty;
                 
                Opportunity objTestOppty1 = new Opportunity(Name = 'Test Opp1', AccountId = objTestAccount.Id);
                objTestOppty1.CloseDate = Date.today().addMonths(1);
                objTestOppty1.StageName = '6.Closed';
                objTestOppty1.BusinessPartner__c = objSoldTo.id;
                objTestOppty1.Primary_Line_of_Business__c = 'Cloud';
                objTestOppty1.Lines_of_Businesses__c = 'PureCloud'; 
                objTestOppty1.Win_Loss_Status__c = 'Loss';
                objTestOppty1.ForecastStatus__c = '0.Booked';
                objTestOppty1.Offering_Detail__c = 'Pilot/Trial/POC';
                for(string s: map_rec.keySet())
                {
                  if(map_rec.get(s).name == 'GEN - Opportunity Record Type')
                   objTestOppty1.RecordTypeId = s;
                }
                insert objTestOppty1;
                map_opplst = new Map<Id,Opportunity>([Select ID,Name,Primary_Line_of_Business__c,Lines_of_Businesses__c,AccountId, StageName, Win_Loss_Status__c, ForecastStatus__c From Opportunity Where Id =: objTestOppty.Id ]);
                map_opplst.put(objTestOppty1.id,objTestOppty1);
                //objTestOppty.BusinessPartner__c = objSoldTo.id;
                objTestOppty.StageName = '6.Closed' ;
                objTestOppty.Win_Loss_Status__c = 'Won' ;
                objTestOppty.ForecastStatus__c = '0.Booked';
                update objTestOppty;
                objTestOppty1.StageName = '6.Closed' ;
                objTestOppty1.Win_Loss_Status__c = 'Won' ;
                objTestOppty1.ForecastStatus__c = '0.Booked';
                update objTestOppty1;
                Cloud_Deployment__c cDeploy = new Cloud_Deployment__c(Name = 'Testing');
                
                cDeploy.Cloud_Offering__c = objTestOppty.Primary_Line_of_Business__c;        
                cDeploy.Cloud_Platform__c = objTestOppty.Lines_of_Businesses__c;
                cDeploy.Status__c = 'Production';
                cDeploy.Support_status__c = 'Order Processing';
                cDeploy.Account__c = objTestOppty.AccountId;
                cDeploy.Care_level__c = 'PureCloud Standard';
                
                cDeploy.Sold_to_Account__c = objTestOppty.AccountId;
                cDeploy.Opportunity__c = objTestOppty.Id;
                cDeploy.Email_Alias__c = 'test@test.com';
                
                insert cDeploy;
                
                
                //Contact contObj = new Contact(FirstName = 'testF', lastName = 'tL21', email='test@test.com');
                //insert contObj;
                
                //opplst.set(ID, objTestOppty);
                //update opplst;
                opplst = new Map<Id,Opportunity>([Select ID,Name,Primary_Line_of_Business__c,Lines_of_Businesses__c,AccountId, StageName, Win_Loss_Status__c, ForecastStatus__c From Opportunity Where Id =: objTestOppty.Id ]);
                opplst.put(objTestOppty1.id,objTestOppty1); 
                clsOpportunityTriggerHelper.CreateCloudDeployment( map_opplst,opplst);
                
            }
            Test.stopTest();
        }
        catch(CalloutException e){}
    }
    
}