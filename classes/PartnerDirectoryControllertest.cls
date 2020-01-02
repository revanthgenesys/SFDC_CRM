@isTest

public class PartnerDirectoryControllertest {
    
    static testmethod void init(){
        test.startTest();        
       
        
        
        country__c country = new country__C(Name='United States',
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
        list<String> region = new list<string>();
        region.add(country.Region__c);
        
   recordtype recTp = [Select Id,DeveloperName from recordtype where DeveloperName = 'EMGBusinessPartnerRecordType'];
    Global_Setting__c setting = new Global_Setting__c();
        setting.Name = 'United States';
        setting.ID__c = 'a24U00000004XlJ';
        setting.Type__c = 'Subsidary';
        setting.Information__c = '8100 United States';
        insert setting;
       
        
    account testaccount = new Account(Name='Test Account',Subsidary__c = setting.ID__c,Country__c = country.id,Partner_Tier__c = 'gold',SMART_Qualified__c = true,Screening_Checklist_Completed__c=true, isDirect__c= true, PartnerType__c = 'VAR',recordtypeid=recTp.Id );
    insert testaccount;
  
        list<String> ptypes = new list<string>();
        ptypes.add(testaccount.PartnerType__c);    
        list<String> ptiers = new list<string>();
        ptiers.add(testaccount.Partner_Tier__c);
    
    Partner_Directory_Staging__c  testpartnerdirectoryadmin = new Partner_Directory_Staging__c (Account__C = testaccount.id, Approval_Status__c = 'Published', 
                                                                                           HQ_Address__c = 'Colonia 968, 11100 Montevideo Montevideo Department, Uruguay',Latitude__c = '-34.90541109999999',
                                                                                           Longitude__c = '56.19571840000003', Phone__c = '123123123123', Website__c = 'www.google.com',
                                                                                           Company_Description__c = 'test');
  insert testpartnerdirectoryadmin;
        
  Partner_Directory_Approved__c testpartnerdirapproved = new Partner_Directory_Approved__c(Account__C = testaccount.id, Approval_Status__c = 'Published', 
                                                                                           HQ_Address__c = 'Colonia 968, 11100 Montevideo Montevideo Department, Uruguay',Latitude__c = '-34.90541109999999',
                                                                                           Longitude__c = '56.19571840000003', Phone__c = '123123123123', Website__c = 'www.google.com',Offering_Type__c = 'PureCloud', Specialization__c = 'PureEngage Core',  TierSupport__c = 'Gold',
                                                                                           Company_Description__c = 'test', Partner_Directory_Staging__c = testpartnerdirectoryadmin.id); 
        
     insert  testpartnerdirapproved;  
        
        list<String> poffer = new list<string>();
        poffer.add(testpartnerdirapproved.Offering_Type__c);
        list<String> pspecial = new list<string>();
        pspecial.add(testpartnerdirapproved.Specialization__c);
        
        PartnerDirectoryController pdc = new PartnerDirectoryController(new ApexPages.StandardController(testpartnerdirapproved));
     PageReference pageRef = Page.Finderloc; 
     Test.setCurrentPage(pageRef);          
    pageRef.getParameters().put('pid', testpartnerdirapproved.id); 
         pdc.searchPartner();
        pdc.filteraction();
     pageRef.getParameters().put('partnerName', testaccount.Name);    
     pageRef.getParameters().put('selectedRegion',  country.Region__c);
      
     
        pdc.init();        
        pdc.clearall();      
        pdc.specficpartnerlink();
        pdc.partnerName =  testaccount.Name;
        pdc.smartQualifieds = true;     
        pdc.selectedRegion = region;
        pdc.selectedPartnerType1 = ptypes;
        pdc.selectedPartnerTiers = ptiers;          
        pdc.selectedOfferingType = poffer;
        pdc.selectedSpecialization = pspecial;      
        pdc.getCloudoff();
        pdc.getOnPremiseoff();
        pdc.getPCloud();
        pdc.getPEngage();
        pdc.getPCSA();    
        pdc.searchPartner();
        pdc.filteraction();
    }
}