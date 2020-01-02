@isTest(SeeAllData = true)
public class DSRDesignOverviewCtlr_Test {
    static testmethod void test1()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;

            DSR_Attachments_Definition__c objDataDef_Attch = new DSR_Attachments_Definition__c();
            objDataDef_Attch.Active__c = true;
            objDataDef_Attch.AttachmentType__c = 'aa';
            objDataDef_Attch.ObjectType__c = 'Technical Design';
            objDataDef_Attch.URLRequired__c = false;
            insert objDataDef_Attch;
            
            DSR_Attachments_Definition__c objDataDef_Attch2 = new DSR_Attachments_Definition__c();
            objDataDef_Attch2.Active__c = true;
            objDataDef_Attch2.AttachmentType__c = 'aa';
            objDataDef_Attch2.ObjectType__c = 'Business Design';
            objDataDef_Attch2.URLRequired__c = false;
            insert objDataDef_Attch2;
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Brazil' LIMIT 1].Id;
            insert objTestAccount;
            
            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
            objTestOppty.CloseDate = Date.today().addMonths(1);
            objTestOppty.StageName = '1.Recognize Needs';     
            objTestOppty.CurrencyIsoCode = 'BRL';
            objTestOppty.Previous_Maintenance_Rate__c = 0;
            objTestOppty.BusinessPartner__c = objTestAccount.Id;
            objTestOppty.Gene_Care_Specialist__c = UserInfo.getUserId();
            objTestOppty.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' 
                                        AND DeveloperName = 'Genesys_Renewal'].Id;
            insert objTestOppty;
            
            DSR_SCEngagement__c objSCE = new DSR_SCEngagement__c();
            objSCE.Account_ID__c = objTestAccount.id;
            objSCE.Opportunity_ID__c = objTestOppty.id;
            objSCE.SC_Engagement_Status__c = 'Open and Not Assigned';
            objSCE.Design_Start_Date__c = Date.Today().addDays(-10);
            objSCE.Design_End_Date__c = Date.Today().addDays(10);
            insert objSCE;
           
            DSR_SCE_Design__c objSCDesign = new DSR_SCE_Design__c();
            objSCDesign.DSR_SCEngagement__c = objSCE.id;
            //objSCDesign.OfferPlatformType__c = 'aa';
            //objSCDesign.PlatformType__c = 'aa';
            objSCDesign.HAType__c = 'aa';
            objSCDesign.DataCenters__c = 'aa';
            insert objSCDesign ;
            
            
            for(integer i=1;i<3;i++)
            {
                integer iFit = 60;
                
                /*DSR_Activity__c objActTech = new DSR_Activity__c();
                objActTech.SCEID__c = objSCE.id;
                objActTech.Module__c = 'Design';
                objActTech.SubModule__c = 'Technical Design';
                objActTech.Access__c = 'aa';
                objActTech.Source__c = 'aa';
                objActTech.Header__c = string.valueOf(iFit);
                objActTech.Description__c ='aa';
                objActTech.ActivityDate__c = Date.Today();
                objActTech.DSRSCEDesign__c = objSCDesign.id;
                list_Activity.add(objActTech);
                
                DSR_Activity__c objActBusi = new DSR_Activity__c();
                objActBusi.SCEID__c = objSCE.id;
                objActBusi.Module__c = 'Design';
                objActBusi.SubModule__c = 'Business Design';
                objActBusi.Access__c = 'aa';
                objActBusi.Source__c = 'aa';
                objActBusi.Header__c = string.valueOf(iFit);
                objActBusi.Description__c ='aa';
                objActBusi.ActivityDate__c = Date.Today();
                objActBusi.DSRSCEDesign__c = objSCDesign.id;
                list_Activity.add(objActBusi);*/
                
                DSR_Attachments__c objActivity1 = new DSR_Attachments__c();
                objActivity1.DSRSCEDesign__c = objSCDesign.id;
                objActivity1.DSRSCEngagement__c = objSCE.id;
                objActivity1.ObjectType__c = 'Technical Design';
                objActivity1.AttachmentType__c = 'aa';
                objActivity1.Description__c ='aa';
                objActivity1.DateofAttachment__c = Date.Today();
                insert objActivity1;
                
                DSR_Attachments__c objActivity2 = new DSR_Attachments__c();
                objActivity2.DSRSCEDesign__c = objSCDesign.id;
                objActivity2.DSRSCEngagement__c = objSCE.id;
                objActivity2.ObjectType__c = 'Business Design';
                objActivity2.AttachmentType__c = 'aa';
                objActivity2.Description__c ='aa';
                objActivity2.DateofAttachment__c = Date.Today();
                insert objActivity2;
                
                iFit += 10;
            }
            
            
            Test.startTest();
            
            /*For Design controller*/
            Test.setCurrentPageReference(new PageReference('/apex/SC_Engagement_Design_Overview?id=' + objSCDesign.Id));
            DSRDesignOverviewCtlr objDesign = new DSRDesignOverviewCtlr();
            objDesign.BusinessPage();
            objDesign.TechnicalPage();
            
            Test.stopTest();
        }
        catch(CalloutException ex)
        {}
    }
   
}