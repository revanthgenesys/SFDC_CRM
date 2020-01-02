@isTest
public class testriskupsideCalc {
public static  set<id>accids;
public static  list<Account_Revenue_Forecast_Comment__c> lstup1;
static Account testAccount;
static Account_Revenue_Forecast__c testARF; 
    static void init(){         
      insertData();
        PESSRevenueForecastCommentsController objController = new PESSRevenueForecastCommentsController();
        objController.save();
        objController.search();     
        accids =  new set<id>();       
        lstup1 = new list<Account_Revenue_Forecast_Comment__c>();        
    }  
    
    static testMethod void testWithExistingforecast() {
      init();
      Test.startTest();     
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '1-2017', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '2-2017', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '3-2017', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '4-2017', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '1-2018', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '2-2018', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '3-2018', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '4-2018', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '1-2019', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '2-2019', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '3-2019', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '4-2019', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '1-2020', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '2-2020', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '3-2020', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '4-2020', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '1-2021', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '2-2021', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '3-2021', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Risk', Quarter__c = '4-2021', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '1-2017', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '2-2017', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '3-2017', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '4-2017', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '1-2018', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '2-2018', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '3-2018', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '4-2018', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '1-2019', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '2-2019', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '3-2019', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '4-2019', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '1-2020', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '2-2020', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '3-2020', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '4-2020', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '1-2021', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '2-2021', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '3-2021', Account_Revenue_Forecast__c = testARF.id ));
        lstup1.add(new Account_Revenue_Forecast_Comment__c(Amount__c = 100 , Reason__c = 'Upside', Quarter__c = '4-2021', Account_Revenue_Forecast__c = testARF.id ));
        insert lstup1;
    }    
    //This is the method to inset the Account_Revenue_Forecast__c and account object from existing test class
    private static void insertData(){
      testAccount = TestUtil.createAccounts(1, false)[0];
      testAccount.PE_SS_Flag__c = true;
      insert testAccount;
      testARF = new Account_Revenue_Forecast__c();
      testARF.Account__c = testAccount.id;
      testARF.PE_SS_Flag__c = true;
      testARF.Comment_Validation__c = true;
      insert testARF;
    }
}