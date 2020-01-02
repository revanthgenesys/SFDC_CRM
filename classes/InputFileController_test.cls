@isTest(SeeAllData = true)
public class InputFileController_test {
    
    static testmethod void Testdealattach(){
       Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            insert runAsUser;
        
        System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account12345678', Status__c = 'Active',Street1__c = 'test',City__c = 'test',Industry__c='test',Phone='1234456788',Type_of_Commerce__c= 'test',ZipCode__c = '123345');
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                insert objTestAccount;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                
                insert objTestOppty;
            
            Id idDSR;
            Deal_Support__c objTestDS = new Deal_Support__c();
            objTestDS.Opportunity__c = objTestOppty.Id;
            objTestDS.Support_Area__c = 'Business Consulting';
            objTestDS.Request_Type__c = 'Business Consulting Inquiry';
            objTestDS.Subject__c = 'test';
            objTestDS.Description__c = 'test';
            objTestDS.Org_ID__c = 'test';
            objTestDS.Primary_Churn_Reason__c = 'Platform';
            objTestDS.Notification_Date__c = system.today();
            objTestDS.Official_Cancelation_Date__c = system.today();    
            insert objTestDS; 
            Attachment objAtt=new Attachment();
            objAtt.Description='Discovery Plan';
            objAtt.Name='Test';
            objAtt.ParentId=objTestDS.Id;
            objAtt.Body=Blob.valueOf('Test');
            insert objAtt; 
            Attachment objAtt1=new Attachment();
            objAtt1.Description='Discovery Plan';
            objAtt1.Name='Test';
            objAtt1.ParentId=objTestDS.Id;
            objAtt1.Body=Blob.valueOf('Test');
            insert objAtt1; 
           
             List<Attachment> acc = new   List<Attachment> ();
                acc.add(objAtt);
          
            ApexPages.currentPage().getParameters().put('dsrID', objTestDS.Id);
            ApexPages.currentPage().getParameters().put('dName', 'objTestDS.Name');  
            InputFileController objDSQCtrl1 = new InputFileController();   
            objDSQCtrl1.picture();
                
             Attachment[] attachments = objDSQCtrl1.pictures; 
                //[select id, name from Attachment where parent.id=:objTestDS.Id];
                
              //  pictures [] assp = new pictures ();  
           // System.assertEquals(0, attachments.size());
        
               
             
                 
        }
             
    }

}