/*
Purpose: Test Class for PartnerDirectoryinsert class
Created By: Mukunthan K
Created On: 07-MAR-2018
*/

@isTest
public class PartnerDirectoryinsertTest{

    static testmethod void noPartnerRec(){
        test.startTest();
        recordtype recTp = [Select Id,DeveloperName from recordtype where DeveloperName = 'EMGBusinessPartnerRecordType'];
        account testBizPartner = new Account(Name='TestBizAccount',recordtypeid=recTp.Id);
        insert testBizPartner;
        
        Partner_Application__c pa = new Partner_Application__c();
        pa.Company_Name__c = 'Test Company';
        pa.Status__c = 'In Progress';
        pa.Account__c = TestUtil.createAccounts(1, true)[0].id;
        pa.AnnualSalesRevenue_PL__c = 'No';
        pa.Ownership_PL__c = 'No';
        pa.RightToAppointOrDismiss_PL__c = 'No';
        pa.AppointOrDismissMD_PL__c = 'No';
        pa.Government_Veto_PL__c = 'No';
        pa.PublicInternationalOrg_PL__c = 'No';
        pa.Convicted_Executive_PL__c = 'No';
        pa.BannedEmployee_PL__c = 'No';
        pa.ExportEnforcementActivity_PL__c = 'No';
        pa.CountryCurrentlyUnderUS_PL__c = 'No';
        pa.Conflict_of_Interest_PL__c = 'No';
        pa.Current_or_Former_Genesys_Employee_PL__c = 'No';
        pa.Account__c=testBizPartner.Id;
        insert pa;

        country__c country = new country__C(Name=' United States',
                                              RU__c = 'North America', 
                                              SubRegion__c = 'AMERICAS',
                                              SubRU__c='USA', 
                                              Region__c='North America',
                                              PSRDP_Region__c='NA',
                                              Country__c ='United States1',
                                              ISO_Code__c='911' , 
                                              LegacyId__c = 'test',
                                              Legacy_EMG_Id__c = 'test' );
        insert country;
        
        Partner_Application_Category_and_Country__c pappCatCountry = new Partner_Application_Category_and_Country__c(Partner_Application__c=pa.Id,
                                                                                                                    Country__c=country.Id);
        insert pappCatCountry;
        
        PageReference tstpg = Page.PartnerDirectoryInsert;
        Test.setCurrentPage(tstpg);
        tstpg.getParameters().put('accId',testBizPartner.Id);                                                                                                                            
        PartnerDirectoryinsert pdi = new PartnerDirectoryinsert();
        pdi.getCountryList();
        pdi.cancelAction();
        pdi.save();
        Test.StopTest();
    }
    static testmethod void withPartnerRec(){
        test.startTest();
        recordtype recTp = [Select Id,DeveloperName from recordtype where DeveloperName = 'EMGBusinessPartnerRecordType'];
        account testBizPartner = new Account(Name='TestBizAccount',recordtypeid=recTp.Id);
        insert testBizPartner;
        
        Partner_Application__c pa = new Partner_Application__c();
        pa.Company_Name__c = 'Test Company';
        pa.Status__c = 'In Progress';
        pa.Account__c = TestUtil.createAccounts(1, true)[0].id;
        pa.AnnualSalesRevenue_PL__c = 'No';
        pa.Ownership_PL__c = 'No';
        pa.RightToAppointOrDismiss_PL__c = 'No';
        pa.AppointOrDismissMD_PL__c = 'No';
        pa.Government_Veto_PL__c = 'No';
        pa.PublicInternationalOrg_PL__c = 'No';
        pa.Convicted_Executive_PL__c = 'No';
        pa.BannedEmployee_PL__c = 'No';
        pa.ExportEnforcementActivity_PL__c = 'No';
        pa.CountryCurrentlyUnderUS_PL__c = 'No';
        pa.Conflict_of_Interest_PL__c = 'No';
        pa.Current_or_Former_Genesys_Employee_PL__c = 'No';
        pa.Account__c=testBizPartner.Id;
        insert pa;

        country__c country = new country__C(Name=' United States',
                                              RU__c = 'North America', 
                                              SubRegion__c = 'AMERICAS',
                                              SubRU__c='USA', 
                                              Region__c='North America',
                                              PSRDP_Region__c='NA',
                                              Country__c ='United States1',
                                              ISO_Code__c='911' , 
                                              LegacyId__c = 'test',
                                              Legacy_EMG_Id__c = 'test' );
        insert country;
        
        Partner_Application_Category_and_Country__c pappCatCountry = new Partner_Application_Category_and_Country__c(Partner_Application__c=pa.Id,
                                                                                                                    Country__c=country.Id);
        insert pappCatCountry;
        
        Partner_Directory_Staging__c pd = new Partner_Directory_Staging__c(Account__c=testBizPartner.Id);
        insert pd;
        
        PageReference tstpg = Page.PartnerDirectoryInsert;
        Test.setCurrentPage(tstpg);
        tstpg.getParameters().put('accId',testBizPartner.Id);                                                                                                                            
        PartnerDirectoryinsert pdi = new PartnerDirectoryinsert();
        pdi.getCountryList();
        pdi.cancelAction();
        pdi.save();
        pd.Approval_Status__c = 'Published';
        update pd;
        Test.StopTest();
    }    
}