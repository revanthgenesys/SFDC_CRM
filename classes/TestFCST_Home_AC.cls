@isTest
private class TestFCST_Home_AC{


static testMethod void testFCST_Home() 
 { 
  /*-----------------------------------------------------------------------------------------------------
 Select the Current quarter number from the period object.
 -------------------------------------------------------------------------------------------------------*/
 Period PQuarter = [Select p.Number, p.StartDate, p.EndDate From Period p Where p.type = 'Quarter' and p.StartDate = THIS_FISCAL_QUARTER];
 Integer Quarter;
 String CurrQuarter = 'Q'+ String.Valueof(PQuarter.Number);
 Integer CurrentYear = PQuarter.StartDate.Year();
 /*-----------------------------------------------------------------------------------------------------
 Select Id for the required Country
 -------------------------------------------------------------------------------------------------------*/
 Country__c TestCountry = [select Id, Name from Country__c where Name = 'Mexico'];
 /*-----------------------------------------------------------------------------------------------------
 1. Select Id for the required record type 'EMG - Customer Record Type' to use in Account object,
 2. Insert a record in to an account object
 -------------------------------------------------------------------------------------------------------*/
 RecordType RT = [select Id,  Name from RecordType where  Name = 'EMG - Customer Record Type'];

    Account[] Acc = new Account[]{
    new Account( RecordTypeId = RT.Id 
          ,Name = 'TestAccount'
          ,Street1__c = 'Test Street'
          ,ZipCode__c = '90001'
          , City__c = 'Test City'
          ,Country__c = TestCountry.Id
          ,Industry  = 'EDUCATION'
          ,Industry__c = 'Technical and Trade Schools'
          ,AccountClassification__c =  'Small'
          ,Type = 'Customer'
          ,CurrencyIsoCode =  'USD'
          )
          };
          
   insert Acc; 
   
      Contact con = new Contact();
        con.AccountId = Acc[0].Id;
        con.LastName = 'Test Contact';
        con.Email = 'test@test.com';        
        insert con;
     
 /*-----------------------------------------------------------------------------------------------------
 1. Select Id for the required record type 'GEN - Opportunity Record Type' to use in Opportunity object,
 2. Insert a record in to an Opportunity object
 -------------------------------------------------------------------------------------------------------*/
   RecordType RT1 = [select Id,  Name from RecordType where  Name = 'GEN - Opportunity Record Type'];

   Opportunity[] Oppo = new Opportunity[]{
   new Opportunity( RecordTypeId = RT1.Id 
          ,Name = 'TestOpportunity1'
          ,Type = 'New logo'
          ,AccountId =  Acc[0].Id
          ,Direct_Sales__c = true
         // ,Direct_Opportunity_Source__c='LinkedIn'         
          ,CurrencyIsoCode= 'USD'
          , CloseDate=  PQuarter.EndDate
          ,StageName = '7-Final negotiations'
          ,ForeCaststatus__c = '0.Booked'
          ,NumberofAgents__c = '1-5'
          ,Competitor__c ='Cisco'
          ,contact__c = con.id        
          )
          };    
          
   insert Oppo; 
 /*-----------------------------------------------------------------------------------------------------
 1. Select Id for the required record type 'EMG - Product Record Type' to use in Product2 object,
 2. Insert a Product record in to the Product2 object
 -------------------------------------------------------------------------------------------------------*/
   RecordType RT2 = [select Id,  Name from RecordType where  Name = 'EMG - Product Record Type'];

   Product2[] Prod2 = new Product2[]{
   new Product2( RecordTypeId = RT2.Id 
          , Name = 'TestProd2'
          ,IsActive = True
          ,ProductLine__c = 'DATA -Network'
          , Family='3rd Party Products'
          ,ProductSubFamily__c= '3rd Party Products'
          ,Forecasted__c= True
          ,X2011_Growth_Model__c = 'Gain'
          )
          };    
          
   insert Prod2 ; 
 /*-----------------------------------------------------------------------------------------------------
 Select the standard price book id from the Pricebook2 object and
 Add an entry using this id to the pricebookentry object
 -------------------------------------------------------------------------------------------------------*/

   Pricebook2 Pb2 = [Select Id from Pricebook2 where IsStandard=True];

   PricebookEntry[] Pbentry = new PricebookEntry[]{
   new PricebookEntry(  
          Product2Id = Prod2[0].Id
          ,Pricebook2Id = Pb2.Id
          ,CurrencyIsoCode= 'USD'
          ,IsActive = True
          ,UnitPrice=4400
          )
          };    
          
   insert  Pbentry ; 
 /*-----------------------------------------------------------------------------------------------------
  Add an entry using Oppurtunity id andPricebookentryid to the opportunityLineItem object
 -------------------------------------------------------------------------------------------------------*/
    opportunityLineitem[] OppLi = new opportunityLineitem[]{
    new opportunityLineitem(  
           OpportunityId = Oppo[0].Id
          ,PricebookEntryId= Pbentry[0].Id
          ,Quantity = 2
          ,Quantity__c=2 
          ,TotalPrice=8888
          )
          };    
          
   insert  OppLi ;         
   

   Test.startTest();       
 /*------------------------------------------- Set VFP page as a currentpage. -----------------------------------*/                
     PageReference pageRef = Page.FCST_Home_VFP;            
        Test.setCurrentPage(pageRef);
 /*-------------------------------------- Create an Instance for the controller ---------------------------------*/                     
        FCST_Home_AC  controller = new FCST_Home_AC();
 /*----------------------------------------------------------------------------------------------------------------
  Invoke the dmloperation method in which all the updates/inserts will be done on the MY_Forecast__c object.
 -----------------------------------------------------------------------------------------------------------------*/
        pageRef = controller.dmlOperation();  
 /*----------------------------------------------------------------------------------------------------------------
 Check on the Refresh Method by comparing the value of Total_commit__c from My_Forcast object before
 and after updates on the Opportunity amount.       
 -----------------------------------------------------------------------------------------------------------------*/
        My_Forecast__c  myForecast = [Select Id, Total_Upside__c, Total_Commit__c from My_Forecast__c  where 
                        Current_Year__c= :CurrentYear and OwnerId = :UserInfo.getUserId()  and Quarter__c= :CurrQuarter];
        Decimal OldTotalCommit =   myForecast.Total_Commit__c;          
        system.debug('OldTotalCommit......' + OldTotalCommit);
        system.debug('Oppo[0].Amount......' + Oppo[0].Amount);
        Opportunity OppTest = [Select Id, Amount,forecaststatus__c from Opportunity where Id = :Oppo[0].Id];
         system.debug('OppTest......' + OppTest);
        
        opportunityLineitem OppLi1 = [Select TotalPrice, Id from opportunityLineitem where Id=:OppLi[0].Id];
        OppLi1.TotalPrice = 13131;
        Update OppLi1;
        pageRef = controller.Refresh();
        myForecast = [Select Id, Total_Upside__c, Total_Commit__c from My_Forecast__c  where 
                        Current_Year__c= :CurrentYear and OwnerId = :UserInfo.getUserId()  and Quarter__c= :CurrQuarter];
        Decimal NewTotalCommit =   myForecast.Total_Commit__c;                          
        system.debug('(NewTotalCommit - OldTotalCommit)......' + (NewTotalCommit - OldTotalCommit));        
           
       // system.assert((NewTotalCommit - OldTotalCommit) == 4243);

 /*----------------------------------------------------------------------------------------------------------------
 Check on the Save Method by comparing the value of My_Land_Forecast__c from My_Forcast object before
 and after updates.       
 -----------------------------------------------------------------------------------------------------------------*/
        controller = new FCST_Home_AC(); 
          
        My_Forecast__c pmyForecast = controller.getMyForecast1();
        My_Forecast__c pmyForecast1 = controller.setMyForecast1();
        pmyForecast.My_Land_Forecast__c = 10000;
        pageRef = controller.save();  
        myForecast = [Select Id, My_Land_Forecast__c from My_Forecast__c  where 
                      Current_Year__c= :CurrentYear and OwnerId = :UserInfo.getUserId()  and Quarter__c= :CurrQuarter];
        system.assert(myForecast.My_Land_Forecast__c  == 10000);
        
 /*----------------------------------------------------------------------------------------------------------------
    Check on the getQuarterText method to display 'Current Quarter'/'Quarter' 
 -----------------------------------------------------------------------------------------------------------------*/
        String str = controller.getQuarterText();         
        system.assert(str == 'Current Quarter');
        pageRef = controller.dmlOperation();  
        pageRef = controller.Fetchdata();  
        Test.stopTest();   
  
   }
 }