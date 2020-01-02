@isTest (SeeAllData = False)
public class DRExpiryExtensionApprovalTest{

    static testmethod void extendExpiry(){
        
        Test.startTest();

            List<String> stats = new List<String>{'1.Understand Needs','2.Define Requirements','3.Evaluate Options','4.Build Consensus'};
            
            recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
            
            Account acc = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
            insert acc;

            //Opportunity opty = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today(), StageName = '1.Understand Needs',CurrencyIsoCode = 'USD', OwnerId = UserInfo.getUserId());
            //insert opty;
        
            partner_portal_prospect__c testRec = new partner_portal_prospect__c();
            testRec.Account__c = acc.id;
            testRec.Regions__c='North America';
            testRec.name='test-Opty';
            testRec.Opportunity_Channel_Manager__c = UserInfo.getUserId();
            testRec.end_date__c = system.Today();
            testRec.Status__c = 'Request Submitted';
            //testRec.opportunity__c = opty.id;
           // insert testRec;
            
            //Account optyAcc = new Account(name=testRec.name,Lead_Development_Rep__c=UserInfo.getUserId());
            //insert optyAcc;

        /*}
            
            partner_portal_prospect__c testRec = [Select Id,Account__c,end_date__c,proposed_end_date__c,status__c,Opportunity_Channel_Manager__c,Opportunity__c,Opportunity_Stage__c 
                                            from partner_portal_prospect__c 
                                            where status__c <>'Expired' and opportunity__c<>NULL and Opportunity_Stage__c in: stats and end_date__c <>NULL LIMIT 1];

    //Date proposal2 = testRec.end_date_c.addDays(220);*/
            testRec.Proposed_End_Date__c = testRec.end_date__c.addDays(120);
            testRec.What_is_the_Expected_Close_Date__c = testRec.end_date__c.addDays(12);
            testRec.End_User_Account__c = acc.id;
            insert testRec;
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testRec);
            extendExpiryController ex = new extendExpiryController(sc);


            PageReference pageRef = Page.DealExpiryExtensionPopup;
            pageRef.getParameters().put('id', String.valueOf(testRec.id));
            Test.setCurrentPage(pageRef);
            
            
            ex.save();
        Test.stopTest();
    }

    static testmethod void testexpiry(){
        
        Test.startTest();
            recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
            
            Account acc = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
            insert acc;
            
            Opportunity opty = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today(), StageName = '1.Understand Needs',CurrencyIsoCode = 'USD', OwnerId = UserInfo.getUserId());
            insert opty;
            
            partner_portal_prospect__c testRec = new partner_portal_prospect__c();
            testRec.Account__c = acc.id;
            testRec.Regions__c='North America';
            testRec.name='test-Opty';
            testRec.Opportunity_Channel_Manager__c = UserInfo.getUserId();
            testRec.end_date__c = system.Today();
            testRec.Status__c = 'Approved';
            testRec.opportunity__c = opty.id;
            testRec.Proposed_End_Date__c = testRec.end_date__c.addDays(120);
            testRec.What_is_the_Expected_Close_Date__c = testRec.end_date__c.addDays(12);
            testRec.End_User_Account__c = acc.id;
            insert testRec;
            
            testRec.Status__c = 'Expired';
            update testRec;
            
        Test.stopTest();
    }

}