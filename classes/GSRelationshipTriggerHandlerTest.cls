@isTest(seealldata=true)
private class GSRelationshipTriggerHandlerTest {

    private static testMethod void GSRelationshipMethod() {
        
        Test.startTest();
            
            
        //Util.Bypass_Trigger_Chk = true;
        Account objTestAccount;
        Account objSoldTo;
        
        List<Account>list_Acc = new List<Account>();
        List<Address__c>list_Address = new List<Address__c>();
        Opportunity objTestOppty;
        List<User> runAsUser = TestUtil.createUsers(1, false);
        System.runAs(runAsUser[0]) {
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
            objTestOppty.BusinessPartner__c = objSoldTo.id;
            objTestOppty.Primary_Line_of_Business__c = 'Cloud';
            objTestOppty.Lines_of_Businesses__c = 'PureCloud'; 
            insert objTestOppty;
            //get User
            LIST<User> lstUsr= [Select Id From User WHERE Profile.Name='System Administrator' LIMIT 2];
            
            JBCXM__GSRelationshipType__c relationshiptype = new JBCXM__GSRelationshipType__c();
            relationshiptype.JBCXM__Active__c = true;
            relationshiptype.Name = 'Premier Edition';
            relationshiptype.JBCXM__Description__c = 'Customers with the Premier Edition offering.';
            insert relationshiptype;
            
            JBCXM__GSRelationship__c gsRel= new JBCXM__GSRelationship__c();
            gsRel.JBCXM__Account__c = objTestAccount.Id;
            gsRel.JBCXM__RelationshipType__c = relationshiptype.Id;
            //gsRel.Offerings_Type__c = 'PureConnect';
           // gsRel.Offerings_Detail__c = 'Subscription';
            gsRel.Name = 'Premier Edition';
            insert gsRel;
        }
        Test.stoptest();
    }

}