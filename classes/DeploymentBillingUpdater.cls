/* This class used to update Cloud Deployment with the billing platform Id.  Created by Thiyagaraj Vijayakumar */
@RestResource(urlMapping='/DeploymentBilling/Update')
global with sharing class DeploymentBillingUpdater{

    @HttpPost
    global static Result doUpdate(String updateId, String platformId) {
        Cloud_Deployment__c deployment;
        Result res = new Result(); 
        res.successMessages = new List<string>();
        res.CalloutMessages = new List<String>();
       
        String DEPLOYMENT_NOT_FOUND = 'No Deployment was found with the requested Id.';
        String BLANK_DEPLOYMENT = 'Update Id cannot be blank';
        String BLANK_PLATFORM = 'Platform Id cannot be blank';

        try
        {   
            if(String.isNotBlank(updateId)){         
                deployment = GetDeployment(updateId); 
                System.debug('Deployment Found for Update: ' + deployment);
                
                if(deployment != null)
                {
                    if(string.isNotBlank(platformId))
                    {
                        deployment.Billing_Platform_Id__c = platformId;
                        update deployment;
                        res.successMessages.add('Deployment has been updated with billing platform id');
                    }
                    else
                        res.CalloutMessages.add(BLANK_PLATFORM);
                }
                else
                    res.CalloutMessages.add(DEPLOYMENT_NOT_FOUND);
            }else
                res.CalloutMessages.add(BLANK_DEPLOYMENT);
        }
        catch (Exception e)
        {            
            res.CalloutMessages.add('An Exception was thrown while Updating the Deployment with Message: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());            
        }        
        
        return res;
    }    
    
    public static Cloud_Deployment__c GetDeployment(String updateId)
    {   
        List<Cloud_Deployment__c> deployment = [
            SELECT Id, Billing_Platform_Id__c 
            FROM Cloud_Deployment__c
            WHERE Id =: updateId
        ];
        
        if(deployment.size()>0)
            return deployment[0];
        else
            return null;    
    }   
    
    global class Result
    {
        global string[] successMessages { get; private set; }
        global string[] CalloutMessages { get; private set; }        
    }
}