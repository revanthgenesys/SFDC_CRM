@isTest
public class PESSRevenueForecastFileUploadCont_Test {

     @testSetup static void setup() {
        
        List<Account> testAccts = new List<Account>();
        
        
        for( Integer i=0; i < 6; i++ ) {
            
            testAccts.add(new Account(Name = 'TestAcct'+i,Status__c = 'Active'));
        }
        
        try{
            
            insert testAccts; 
            
        }catch(DMLException exp){}    
            
        
        System.debug('@Acc '+ testAccts);
        
        
        List<Opportunity> testOpp = new List<Opportunity>();
        
        
        for( Integer i=0; i <2; i++ ) {
            
            testOpp.add(new Opportunity(Name = 'TestOpp'+i,accountId=testAccts[0].id,closeDate = Date.today().addMonths(1),
                        StageName = '1.Recognize Needs',CurrencyIsoCode = 'USD',Lines_of_Businesses__c = 'PureCloud'));
        }
        
        
        System.debug('@Opp '+ testOpp);
        
        for( Integer i=2; i < 4; i++ ) {
            
            testOpp.add(new Opportunity(Name = 'TestOpp'+i,accountId=testAccts[1].id,closeDate = Date.today().addMonths(1),
                        StageName = '1.Recognize Needs',CurrencyIsoCode = 'USD',Lines_of_Businesses__c = 'PureCloud'));
        }
        
        
        System.debug('@Opp '+ testOpp);


        for( Integer i=4; i < 6; i++ ) {
            
            testOpp.add(new Opportunity(Name = 'TestOpp'+i,accountId=testAccts[2].id,closeDate = Date.today().addMonths(1),
                        StageName = '1.Recognize Needs',CurrencyIsoCode = 'USD',Lines_of_Businesses__c = 'PureEngage'));
        }

        
            
        testOpp.add(new Opportunity(Name = 'TestOpp6',accountId=testAccts[3].id,closeDate = Date.parse('02/02/2018'),
                        StageName = '1.Recognize Needs',CurrencyIsoCode = 'USD',Lines_of_Businesses__c = 'PureEngage'));
        
        
        testOpp.add(new Opportunity(Name = 'TestOpp7',accountId=testAccts[3].id,closeDate = Date.parse('02/03/2018'),
                        StageName = '1.Recognize Needs',CurrencyIsoCode = 'USD',Lines_of_Businesses__c = 'PureEngage'));
        
        
        //For NewLogo
        for( Integer i=8; i < 10; i++ ) {
            
            testOpp.add(new Opportunity(Name = 'TestOpp'+i,accountId=testAccts[4].id,closeDate = Date.today().addMonths(1),
                        StageName = '1.Recognize Needs',CurrencyIsoCode = 'USD',Lines_of_Businesses__c = 'PureCloud'));
        }
        
        
        System.debug('@Opp '+ testOpp);
        
        for( Integer i=10; i < 12; i++ ) {
            
            testOpp.add(new Opportunity(Name = 'TestOpp'+i,accountId=testAccts[5].id,closeDate = Date.today().addMonths(1),
                        StageName = '1.Recognize Needs',CurrencyIsoCode = 'USD',Lines_of_Businesses__c = 'PureCloud'));
        }
        
        
        
        
        try{
            insert testOpp; 
        
        }catch(DMLException exp){}
        
        System.debug('@opp '+ testOpp[0].id);
        
        Cloud_Forecast_Quarter__c quarter = new Cloud_Forecast_Quarter__c();
        quarter.Current_Week__c = true;
        insert quarter;
        
        Account_Revenue_Forecast__c accRevForRec = new Account_Revenue_Forecast__c();
        accRevForRec.account__c = testAccts[0].id;
        accRevForRec.LOB_O__c = 'A - In-Force Subscription';
        accRevForRec.Offering_Type__c = 'PureCloud';
        accRevForRec.Cloud_Forecast_Quarter__c = quarter.id;
        accRevForRec.Oct_2018__c = 0.0;
        accRevForRec.Nov_2018__c = 0.0;
        accRevForRec.Dec_2018__c = 0.0;
        
        insert accRevForRec;
        
        System.debug('@accRevForRec '+ accRevForRec);
        Account_Revenue_Forecast__c accRevForRec2 = new Account_Revenue_Forecast__c();
        accRevForRec2.account__c = testAccts[0].id;
        accRevForRec2.LOB_O__c = 'D - In-Force Telco';
        accRevForRec2.Offering_Type__c = 'PureCloud';
        accRevForRec2.Cloud_Forecast_Quarter__c = quarter.id;
        accRevForRec2.Oct_2018__c = 0.0;
        accRevForRec2.Nov_2018__c = 0.0;
        accRevForRec2.Dec_2018__c = 0.0;
        
        insert accRevForRec2;
        
        
        Account_Revenue_Forecast__c accRevForRec3 = new Account_Revenue_Forecast__c();
        accRevForRec3.account__c = testAccts[1].id;
        accRevForRec3.LOB_O__c = 'A - In-Force Subscription';
        accRevForRec3.Offering_Type__c = 'PureCloud';
        accRevForRec3.Cloud_Forecast_Quarter__c = quarter.id;
        accRevForRec3.Oct_2018__c = 0.0;
        accRevForRec3.Nov_2018__c = 0.0;
        accRevForRec3.Dec_2018__c = 0.0;
        
        insert accRevForRec3;
        
        System.debug('@accRevForRec '+ accRevForRec);
        Account_Revenue_Forecast__c accRevForRec4 = new Account_Revenue_Forecast__c();
        accRevForRec4.account__c = testAccts[1].id;
        accRevForRec4.LOB_O__c = 'D - In-Force Telco';
        accRevForRec4.Offering_Type__c = 'PureCloud';
        accRevForRec4.Cloud_Forecast_Quarter__c = quarter.id;
        accRevForRec4.Oct_2018__c = 0.0;
        accRevForRec4.Nov_2018__c = 0.0;
        accRevForRec4.Dec_2018__c = 0.0;
        
        insert accRevForRec4;
        
        Account_Revenue_Forecast__c accRevForRec5 = new Account_Revenue_Forecast__c();
        accRevForRec5.account__c = testAccts[2].id;
        accRevForRec5.LOB_O__c = 'A - In-Force Subscription';
        accRevForRec5.Offering_Type__c = 'PureCloud';
        accRevForRec5.Cloud_Forecast_Quarter__c = quarter.id;
        accRevForRec5.Oct_2018__c = 0.0;
        accRevForRec5.Nov_2018__c = 0.0;
        accRevForRec5.Dec_2018__c = 0.0;
        
        insert accRevForRec5;
        
        
        
        
        
        
    }
    
    
    static String str = 'Account ID,OPP ID,CMRR Value,Telco %' + '\n';

    public static String[] csvFileLines;
    public static Blob csvFileBody;
    
    
    
    @isTest static void testMethod1(){
        
        //List<SObject> accRevForList = Test.loadData(Opportunity.sObjectType,'AccountRevForCSVFile');
        //System.debug('accRevForList ' +accRevForList);
        
        /*str =    testAccts[0].id + ',' + testOpp[0].id + ',1050.34,27' +
                        '\n' + testAccts[0].id + ',' + testOpp[0].id + ',1050.34,27' + 
                        '\n' + testAccts[0].id + ',' + testOpp[0].id + ',100.25,27' +
                        '\n' + testAccts[0].id + ',' + testOpp[0].id + ',100.25,27';  
        */
        
        List<Account> accList = [SELECT Id,(Select Id from Opportunities) FROM Account 
                                WHERE 
                                Name in ('TestAcct0','TestAcct1')];

        if(accList.size() > 0){
            
            str =    accList[0].id + ',' + accList[0].Opportunities[0].id + ',1050.34,27' +
                     '\n' + accList[0].id + ',' + accList[0].Opportunities[1].id + ',1050.34,27' + 
                     '\n' + accList[1].id + ',' + accList[1].Opportunities[0].id + ',100.25,27' +
                     '\n' + accList[1].id + ',' + accList[1].Opportunities[1].id + ',100.25,27';  
        
            
            
            
        }
        
        Test.startTest();
        
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        PESSRevenueForecastFileUploadController pessRevForCont = new PESSRevenueForecastFileUploadController();
        pessRevForCont.csvFileBody = csvFileBody;
        pessRevForCont.operationType = 'Addon';
        pessRevForCont.processCSVFile();
        
        Test.stopTest();
        
        
        
        
    }
    
    @isTest static void testMethod2(){
        
        //List<SObject> accRevForList = Test.loadData(Opportunity.sObjectType,'AccountRevForCSVFile');
        //System.debug('accRevForList ' +accRevForList);
        
        List<Account> accList = [SELECT Id,(Select Id from Opportunities) FROM Account 
                                WHERE 
                                Name in ('TestAcct4','TestAcct5')];

        if(accList.size() > 0){
            
            str =    accList[0].id + ',' + accList[0].Opportunities[0].id + ',1050.34,27' +
                     '\n' + accList[0].id + ',' + accList[0].Opportunities[1].id + ',1050.34,27' + 
                     '\n' + accList[1].id + ',' + accList[1].Opportunities[0].id + ',100.25,27' +
                     '\n' + accList[1].id + ',' + accList[1].Opportunities[1].id + ',100.25,27';  
        
            
            
            
        }  
        
        Test.startTest();
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        PESSRevenueForecastFileUploadController pessRevForCont = new PESSRevenueForecastFileUploadController();
        pessRevForCont.csvFileBody = csvFileBody;
        pessRevForCont.operationType = 'NewLogo';
        pessRevForCont.processCSVFile();
        
        Test.stopTest();
        
        
        
        
    }
    
    //Having error records
    @isTest static void testMethod3(){
        
        //List<SObject> accRevForList = Test.loadData(Opportunity.sObjectType,'AccountRevForCSVFile');
        //System.debug('accRevForList ' +accRevForList);
        
        List<Account> accList = [SELECT Id,(Select Id from Opportunities) FROM Account 
                                WHERE 
                                Name in ('TestAcct0','TestAcct1')];

        if(accList.size() > 0){
            
            str =    accList[0].id + ',' + accList[0].Opportunities[0].id + ',dfgg,27' +
                     '\n' + accList[0].id + ',' + accList[0].Opportunities[1].id + ',1050.34,27' + 
                     '\n' + accList[1].id + ',' + accList[1].Opportunities[0].id + ',100.25,27' +
                     '\n' + '123' + ',' + accList[1].Opportunities[1].id + ',100.25,27';  
        
            
            
            
        }  
        
        Test.startTest();
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        PESSRevenueForecastFileUploadController pessRevForCont = new PESSRevenueForecastFileUploadController();
        pessRevForCont.csvFileBody = csvFileBody;
        pessRevForCont.operationType = 'NewLogo';
        pessRevForCont.processCSVFile();
        
        Test.stopTest();
        
        
        
        
    }
    
     //Pure Engage + Un equal close date
     @isTest static void testMethod4(){
        
        //List<SObject> accRevForList = Test.loadData(Opportunity.sObjectType,'AccountRevForCSVFile');
        //System.debug('accRevForList ' +accRevForList);
        
        List<Account> accList = [SELECT Id,(Select Id from Opportunities) FROM Account 
                                WHERE 
                                Name in ('TestAcct2','TestAcct3')];

        if(accList.size() > 0){
            
            str =    accList[0].id + ',' + accList[0].Opportunities[0].id + ',1050.34,27' +
                     '\n' + accList[0].id + ',' + accList[0].Opportunities[1].id + ',1050.34,27' + 
                     '\n' + accList[1].id + ',' + accList[1].Opportunities[0].id + ',100.25,27' +
                     '\n' + accList[1].id + ',' + accList[1].Opportunities[1].id + ',100.25,27';  
        
            
            
            
        }  
        
        Test.startTest();
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        PESSRevenueForecastFileUploadController pessRevForCont = new PESSRevenueForecastFileUploadController();
        pessRevForCont.csvFileBody = csvFileBody;
        pessRevForCont.operationType = 'Addon';
        pessRevForCont.processCSVFile();
        
        Test.stopTest();
        
        
        
        
    }
     
    //Invalid Account Id
     @isTest static void testMethod5(){
        
        //List<SObject> accRevForList = Test.loadData(Opportunity.sObjectType,'AccountRevForCSVFile');
        //System.debug('accRevForList ' +accRevForList);
        
        List<Account> accList = [SELECT Id,(Select Id from Opportunities) FROM Account 
                                WHERE 
                                Name in ('TestAcct2','TestAcct3')];

        if(accList.size() > 0){
            
            str =    '0010B00001pz3lK' + ',' + accList[0].Opportunities[0].id + ',1050.34,27' +
                     '\n' + '0010B00001pz3lK' + ',' + accList[0].Opportunities[1].id + ',1050.34,27' + 
                     '\n' + '001U0000007Ory1IAC' + ',' + accList[1].Opportunities[0].id + ',100.25,27' +
                     '\n' + '001U0000007Ory1IAC' + ',' + accList[1].Opportunities[1].id + ',100.25,27';  
        
            
            
            
        }  
        
        Test.startTest();
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        PESSRevenueForecastFileUploadController pessRevForCont = new PESSRevenueForecastFileUploadController();
        pessRevForCont.csvFileBody = csvFileBody;
        pessRevForCont.operationType = 'Addon';
        pessRevForCont.processCSVFile();
        
        Test.stopTest();
        
        
        
        
    }
    
    
    //Invalid Opp Id
     @isTest static void testMethod6(){
        
        //List<SObject> accRevForList = Test.loadData(Opportunity.sObjectType,'AccountRevForCSVFile');
        //System.debug('accRevForList ' +accRevForList);
        
        List<Account> accList = [SELECT Id,(Select Id from Opportunities) FROM Account 
                                WHERE 
                                Name in ('TestAcct2','TestAcct3')];

        if(accList.size() > 0){
            
            str =    accList[0].id + ',' + '0060B00000curac' + ',1050.34,27' +
                     '\n' + accList[0].id + ',' + '0061D000003CnaQ' + ',1050.34,27' + 
                     '\n' + accList[1].id + ',' + '0060B00000cJqCn' + ',100.25,27' +
                     '\n' + accList[1].id + ',' + '006U000000OsaQ8' + ',100.25,27';  
        
            
            
            
        }  
        
        Test.startTest();
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        PESSRevenueForecastFileUploadController pessRevForCont = new PESSRevenueForecastFileUploadController();
        pessRevForCont.csvFileBody = csvFileBody;
        pessRevForCont.operationType = 'Addon';
        pessRevForCont.processCSVFile();
        
        Test.stopTest();
        
        
        
        
    }


}