@isTest
private class PureCloudMapping_test {
 private static testMethod void doTest() {

        Test.startTest();
     try{
          List<Account> lstAcc=TestUtil.createAccounts(1,true);
          //Create opportunity
            Opportunity ObjOpp=new Opportunity();
            ObjOpp.Name='Test';
            ObjOpp.CurrencyIsoCode='USD';
            ObjOpp.StageName='Test Stage';
            //ObjOpp.Owner=objUser;
            ObjOpp.Primary_Line_of_Business__c='Cloud';
            ObjOpp.Account=lstAcc[0];
            ObjOpp.BusinessPartner__c=lstAcc[0].Id;
            ObjOpp.Primary_Solution_Category__c='Analytics';
            ObjOpp.CloseDate=date.today();
            ObjOpp.CurrencyISOCode='USD';
            //ObjOpp.Country__c=objCountry.Id;
            
            ObjOpp.Key_Business_Objective__c = 'Add on Seats';
            ObjOpp.Annual_Contract_Value_new__c = 11;
            ObjOpp.Monthly_Commitment__c = 11;
            ObjOpp.Estimated_Usage_Agreements_EUA__c = 11;
            ObjOpp.Hardware_Total__c = 11;
            ObjOpp.License_Amount__c = 11;
            ObjOpp.Total_PS_Support__c = 11;
            ObjOpp.Term_License__c = 11;
           
            ObjOpp.Total_Annual_Contract_Value__c = 11;
            ObjOpp.Lines_of_Businesses__c ='PureConnect';
            
            insert ObjOpp;
        
            PureCloud_Trial__c objPCPrj = new PureCloud_Trial__c();
            objPCPrj.Opportunity__c = ObjOpp.id;
            insert objPCPrj;
            
            SourceOpportunities__c objPCEnb = new SourceOpportunities__c();
            objPCEnb.Opportunity__c = ObjOpp.id;
     		
            insert objPCEnb;
          	
            List<id>list_Enb = new List<id>();
            list_Enb.add(objPCEnb.id);
            
            List<id>list_prj = new List<id>();
            list_Prj.add(objPCPrj.id);
          
            PureCloudMapping.OnCreationPureCloudEnablement(list_Enb);
            PureCloudMapping.OnCreationPureCloudEnablement(list_Prj);
          
        Test.stopTest();
     }
     catch(Exception ex){}
    }
   
}