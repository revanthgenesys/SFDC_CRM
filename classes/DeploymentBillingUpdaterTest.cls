@isTest
private class DeploymentBillingUpdaterTest {

    @istest public static void positiveScenario(){ 
        Cloud_Deployment__c cld = new Cloud_Deployment__c(Name='Test');
        insert cld;
    
        Test.startTest();
            DeploymentBillingUpdater.Result resul = DeploymentBillingUpdater.doUpdate(cld.Id,cld.Id);
            String expectedValue = '{"successMessages":["Deployment has been updated with billing platform id"],"CalloutMessages":[]}';                    
            System.assertEquals(JSON.serialize(Resul), expectedValue);         
        Test.stopTest();    
    }
    
    @istest public static void negativeScenario(){ 
        Id updId, platformId;
        Test.startTest();
            DeploymentBillingUpdater.Result resul = DeploymentBillingUpdater.doUpdate(updId,platformId);
            String expectedValue = '{"successMessages":[],"CalloutMessages":["Update Id cannot be blank"]}';                    
            System.assertEquals(JSON.serialize(Resul), expectedValue);         
        Test.stopTest();    
    }

}