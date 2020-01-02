@isTest
//Created by : swastika Rajkhowa on 15-Oct-2015
private class Global_Utility_Test { 
    static testMethod void Global_Utility_testMethod(){
        //General setting for Bypass
        TestUtil.setConfigValues();     
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0]; 
        System.runAs(runAsUser[0]) {
            //Insert Global Setting data
            Global_Setting__c objGlobal=new Global_Setting__c ();
            objGlobal.Name='Standard_PriceBook';
            insert objGlobal;
            //Inser Opportunity  
            Opportunity opp=new Opportunity();
            opp.Name='China tourist Hotline 12301 Phase 2';
            opp.amount=10;
            opp.license_amount__c=20;
            opp.Forecasted_Flag__c=false;
            opp.Lines_of_Businesses__c ='Enterprise Edition';       
            //opp.Pricebook2=price.Id
            opp.stageName='1.Recognize Needs';
            opp.CloseDate=Date.valueOf('2015-10-30');            
            opp.Pricebook2Id =objGlobal.ID__c ;
            opp.Lines_of_Businesses__c ='Business Edition';
            insert opp;
            
            Global_Utility.Update_Forecasted_Amt(opp.Id);
        }
        
    }
}