@isTest
private class PESSRevenueForecastTest {

    private static testMethod void testFirst() {
        
        Offering_Type_Settings__c oType = new Offering_Type_Settings__c();
        oType.Name = 'PureEngage';
        oType.Land_Diff_Amount__c = 100;
        oType.Risk_Threshold_Amount__c = 100;
        oType.Upside_Threshold_Amount__c = 100;
        oType.Subscription__c = 'A - In-Force Subscription;D - In-Force Telco';
        insert oType;
        
        Revenue_Forecast_User_Quarters__c rfu = new Revenue_Forecast_User_Quarters__c();
        rfu.Q1__c = true;
        rfu.Q2__c = true;
        rfu.Q3__c = false;
        rfu.Q4__c = true;
        rfu.SetupOwnerId = UserInfo.getUserId();
        insert rfu;
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'Anshul', 
                         lastName = 'Jain', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
        
        List<Account> lstAnt = TestUtil.createAccounts(2, false);
        lstAnt[0].CSM_Account_Owner__c = uu.id;
        insert lstAnt;
        
        JBCXM__GSRelationship__c gs = new JBCXM__GSRelationship__c();
        gs.JBCXM__Account__c = lstAnt[0].Id;
        gs.Name = 'PureCloud';
        gs.JBCXM__GSCSM__c = uu.id;
        insert gs;
        
        JBCXM__GSRelationship__c gs2 = new JBCXM__GSRelationship__c();
        gs2.JBCXM__Account__c = lstAnt[0].Id;
        gs2.Name = 'PureConnect Cloud';
        gs2.JBCXM__GSCSM__c = uu.id;
        insert gs2;
        
        Cloud_Forecast_Quarter__c cfq = new Cloud_Forecast_Quarter__c();
        cfq.Name = 'New Quarter';
        cfq.Active__c = true;
        cfq.Current_Week__c = true;
        cfq.Start_Date__c = Date.today();
        cfq.End_Date__c = Date.today().adddays(360);
        cfq.Quarter__c = '4-2017';
        insert cfq;
        
        Account_Revenue_Forecast__c arf1 = new Account_Revenue_Forecast__c();
        arf1.Account__c = lstAnt[0].Id;
        arf1.Offering_Type__c = 'PureEngage';
        arf1.Cloud_Forecast_Quarter__c = cfq.Id;
        arf1.GS_Relationship__c = gs2.id;
        arf1.LOB_O__c = 'A - In-Force Subscription';
        insert arf1;
        
        
        Account_Revenue_Forecast__c arf12 = new Account_Revenue_Forecast__c();
        arf12.Account__c = lstAnt[0].Id;
        arf12.Offering_Type__c = 'PureCloud';
        arf12.Cloud_Forecast_Quarter__c = cfq.Id;
        arf12.GS_Relationship__c = gs2.id;
        arf12.LOB_O__c = 'B - In-Force Sub Overage';
        
        insert arf12;
        
        Account_Revenue_Forecast__c arf11 = new Account_Revenue_Forecast__c();
        arf11.Account__c = lstAnt[0].Id;
        arf11.Offering_Type__c = 'PureConnect';
        arf11.GS_Relationship__c = gs2.id;
        arf11.Cloud_Forecast_Quarter__c = cfq.Id;
        arf11.LOB_O__c = 'C - In-Delivery Subscription';
        
        insert arf11;
        
        List<String> lstIds = new List<String>();
        Test.StartTest();
        system.debug('>>>>>>>####### cfq   '+cfq);
        system.debug('>>>>>>>####### arf1   '+arf1);
        system.debug('>>>>>>>####### arf1C    '+arf1.CSM_Account_Owner__c);
            PESSRevenueForecastControllerView pesF = new PESSRevenueForecastControllerView();
            PESSRevenueForecastControllerView.PopulatePeriod('2017');
            PESSRevenueForecastControllerView.populateWeek();
            PESSRevenueForecastControllerView.populateCSMOwner('PureEngage', '2017',cfq.ID);
            PESSRevenueForecastControllerView.checkCSMOwner('PureEngage', '2017',cfq.ID);
            PESSRevenueForecastControllerView.saveARF('[{"Id":"'+ arf1.Id + '"}]', true, false, true, false, '2017');
            PESSRevenueForecastControllerView.getAccoutnId('PureEngage', cfq.Id, 'Test Account');
            PESSRevenueForecastControllerView.getMonthLocking('PureEngage');
            PESSRevenueForecastControllerView.submitForecast(cfq.Id);
            PESSRevenueForecastControllerView.getchangesReport('PureEngage','2017',cfq.ID,cfq.ID,False);
            PESSRevenueForecastControllerView.getCSMSearchRecord('PureEngage', '2017',cfq.ID, 'Anshul Jain', lstIds, false);
            PESSRevenueForecastControllerView.getAccountRevenueRecordForCSM('PureEngage', '2017',cfq.ID, 'Anshul Jain', lstIds, false);
            lstIds.add(lstAnt[0].id);
            PESSRevenueForecastControllerView.getAccountRevenueRecord('PureEngage', '2017',cfq.ID, 'Anshul Jain', lstIds, true); PESSRevenueForecastControllerView.getAccountRevenueRecordForCSM('PureEngage', '2017',cfq.ID, 'Anshul Jain', lstIds, true);
        Test.StopTest();
        
    }
    
    private static testMethod void testSecond() {
        
        Offering_Type_Settings__c oType = new Offering_Type_Settings__c();
        oType.Name = 'PureEngage';
        oType.Land_Diff_Amount__c = 100;
        oType.Risk_Threshold_Amount__c = 100;
        oType.Upside_Threshold_Amount__c = 100;
        oType.Risk_Upside__c = false;
        oType.Subscription__c = 'A - In-Force Subscription;D - In-Force Telco';
        insert oType;
        
        List<Account> lstAnt = TestUtil.createAccounts(2, true);
        lstAnt[0].CSM_Account_Owner__c = Userinfo.getUserId();
        
        Cloud_Forecast_Quarter__c cfq = new Cloud_Forecast_Quarter__c();
        cfq.Name = 'New Quarter';
        cfq.Active__c = true;
        cfq.Current_Week__c = true;
        cfq.Start_Date__c = Date.today();
        cfq.End_Date__c = Date.today().adddays(360);
        cfq.Quarter__c = '1-2017';
        insert cfq;
        
        Account_Revenue_Forecast__c arf1 = new Account_Revenue_Forecast__c();
        arf1.Account__c = lstAnt[0].Id;
        arf1.Q1_2017_Low__c = 12000;
        arf1.Q2_2017_Low__c = 12000;
        arf1.Q3_2017_Low__c = 12000;
        arf1.Q4_2017_Low__c = 12000;
        
        arf1.Q1_2017_Best__c = 12000;
        arf1.Q2_2017_Best__c = 12000;
        arf1.Q3_2017_Best__c = 12000;
        arf1.Q4_2017_Best__c = 12000;
        
        arf1.Offering_Type__c = 'PureEngage';
        arf1.Cloud_Forecast_Quarter__c = cfq.Id;
        insert arf1;
        
        
        Account_Revenue_Forecast_Comment__c arfc =  new Account_Revenue_Forecast_Comment__c();
        arfc.Account_Revenue_Forecast__c = arf1.Id;
        arfc.Amount__c = 15000;
        arfc.Quarter__c = '1-2017';
        arfc.Reason__c = 'Risk';
        arfc.By_When__c = date.today();
        arfc.Quarter_Upside_Risk__c = 'Risk - Q1 - 2017';
        arfc.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc;
        
        
        Account_Revenue_Forecast_Comment__c arfc11 =  new Account_Revenue_Forecast_Comment__c();
        arfc11.Account_Revenue_Forecast__c = arf1.Id;
        arfc11.Amount__c = 15000;
        arfc11.Quarter__c = '2-2017';
        arfc11.Reason__c = 'Risk';
        arfc11.By_When__c = date.today();
        arfc11.Quarter_Upside_Risk__c = 'Risk - Q2 - 2017';
        arfc11.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc11;
        
        Account_Revenue_Forecast_Comment__c arfc22 =  new Account_Revenue_Forecast_Comment__c();
        arfc22.Account_Revenue_Forecast__c = arf1.Id;
        arfc22.Amount__c = 15000;
        arfc22.Quarter__c = '3-2017';
        arfc22.Reason__c = 'Risk';
        arfc22.By_When__c = date.today();
        arfc22.Quarter_Upside_Risk__c = 'Risk - Q3 - 2017';
        arfc22.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc22;
        
        Account_Revenue_Forecast_Comment__c arfc33 =  new Account_Revenue_Forecast_Comment__c();
        arfc33.Account_Revenue_Forecast__c = arf1.Id;
        arfc33.Amount__c = 15000;
        arfc33.Quarter__c = '4-2017';
        arfc33.Reason__c = 'Risk';
        arfc33.By_When__c = date.today();
        arfc33.Quarter_Upside_Risk__c = 'Risk - Q4 - 2017';
        arfc33.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc33;
        
        Account_Revenue_Forecast_Comment__c arfc1 =  new Account_Revenue_Forecast_Comment__c();
        arfc1.Account_Revenue_Forecast__c = arf1.Id;
        arfc1.Amount__c = 15000;
        arfc1.Quarter__c = '1-2017';
        arfc1.Reason__c = 'Upside';
        arfc1.By_When__c = date.today();
        arfc1.Quarter_Upside_Risk__c = 'Upside - Q1 - 2017';
        arfc1.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc1;
        
        Account_Revenue_Forecast_Comment__c arfc2 =  new Account_Revenue_Forecast_Comment__c();
        arfc2.Account_Revenue_Forecast__c = arf1.Id;
        arfc2.Amount__c = 15000;
        arfc2.Quarter__c = '2-2017';
        arfc2.Reason__c = 'Upside';
        arfc2.By_When__c = date.today();
        arfc2.Quarter_Upside_Risk__c = 'Upside - Q2 - 2017';
        arfc2.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc2;
        
        Account_Revenue_Forecast_Comment__c arfc3 =  new Account_Revenue_Forecast_Comment__c();
        arfc3.Account_Revenue_Forecast__c = arf1.Id;
        arfc3.Amount__c = 15000;
        arfc3.Quarter__c = '3-2017';
        arfc3.Reason__c = 'Upside';
        arfc3.By_When__c = date.today();
        arfc3.Quarter_Upside_Risk__c = 'Upside - Q3 - 2017';
        arfc3.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc3;
        
        Account_Revenue_Forecast_Comment__c arfc4 =  new Account_Revenue_Forecast_Comment__c();
        arfc4.Account_Revenue_Forecast__c = arf1.Id;
        arfc4.Amount__c = 15000;
        arfc4.Quarter__c = '4-2017';
        arfc4.Reason__c = 'Upside';
        arfc4.By_When__c = date.today();
        arfc4.Quarter_Upside_Risk__c = 'Upside - Q4 - 2017';
        arfc4.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc4;
        Test.StartTest();
            Apexpages.currentPage().getParameters().put('year', '2017');
            Apexpages.currentPage().getParameters().put('OfferingType','PureEngage');
            Apexpages.currentPage().getParameters().put('week', cfq.Id);
            
            Apexpages.currentPage().getParameters().put('selectedYear', '2017');
            Apexpages.currentPage().getParameters().put('selectedOfferingType','PureEngage');
            Apexpages.currentPage().getParameters().put('selectedWeek', cfq.Id);

            PESSRevenueForecastCtlrView pesF = new PESSRevenueForecastCtlrView();
            PESSRevenueForecastCtlrView.PopulatePeriod('2017', 'PureEngage');
            PESSRevenueForecastCtlrView.populateWeek();
            PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','1-2017', cfq.Id, null, null);
            PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','2-2017', cfq.Id, null, null);
            PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','3-2017', cfq.Id, null, null);
            PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','4-2017', cfq.Id, null, null);
            
            PESSRevenueForecastCtlrView.saveARF('[{"byWhen":"'+ String.valueOf(arfc.By_When__c) + '","arfId":"' + arf1.Id + '","arfcoId":"' + arfc.Id +  '","arfcId":"' + arfc.Id + '-' + arf1.Id + '"}]' , '['+ arfc.Id + '-' + arf1.Id+ ']');
            String newInsert = 'Need this Cloned:Dan:12/22/2017:When can we get this Cloned:30000:20:'+ arf1.Id + ':1-2017:Risk:Risk - Q1 - 2017';
            String oldInsert = 'Need this:Dan:12/22/2017:When can we get this:30000:20:'+arfc1.Id;
            PESSRevenueForecastCtlrView.SavePopup(newInsert, oldInsert);
            PESSRevenueForecastCtlrView.Removerecord(arfc1.Id);
            PESSRevenueForecastControllerView.saveARF('[{"Id":"'+ arf1.Id + '" , "Q1_2017_Low__c" : 12000, "Q2_2017_Low__c" : 12000 , "Q3_2017_Low__c" : 12000, "Q4_2017_Low__c" : 12000, "Q1_2017_Best__c" : 12000, "Q2_2017_Best__c" : 12000, "Q3_2017_Best__c" : 12000, "Q4_2017_Best__c" : 12000 }]', true, false, true, false, '2017');
        Test.StopTest();
    }
    
    private static testMethod void testSecond1() {
        
        Offering_Type_Settings__c oType1 = new Offering_Type_Settings__c();
        oType1.Name = 'PureEngage';
        oType1.Land_Diff_Amount__c = 0;
        oType1.Risk_Threshold_Amount__c = 0;
        oType1.Upside_Threshold_Amount__c = 0;
        oType1.Risk_Upside__c = false;
        oType1.Subscription__c = 'A - In-Force Subscription;D - In-Force Telco';
        insert oType1;
        
        List<Account> lstAnt = TestUtil.createAccounts(2, true);
        lstAnt[0].CSM_Account_Owner__c = Userinfo.getUserId();
        
        Cloud_Forecast_Quarter__c cfq = new Cloud_Forecast_Quarter__c();
        cfq.Name = 'New Quarter';
        cfq.Active__c = true;
        cfq.Current_Week__c = true;
        cfq.Start_Date__c = Date.today();
        cfq.End_Date__c = Date.today().adddays(360);
        cfq.Quarter__c = '1-2017';
        insert cfq;
        
        Account_Revenue_Forecast__c arf1 = new Account_Revenue_Forecast__c();
        arf1.Account__c = lstAnt[0].Id;
        arf1.Q1_2017_Low__c = 12000;
        arf1.Q2_2017_Low__c = 12000;
        arf1.Q3_2017_Low__c = 12000;
        arf1.Q4_2017_Low__c = 12000;
        
        arf1.Q1_2017_Best__c = 12000;
        arf1.Q2_2017_Best__c = 12000;
        arf1.Q3_2017_Best__c = 12000;
        arf1.Q4_2017_Best__c = 12000;
        
        arf1.Offering_Type__c = 'PureEngage';
        arf1.Cloud_Forecast_Quarter__c = cfq.Id;
        insert arf1;
        
        Test.StartTest();
        Apexpages.currentPage().getParameters().put('year', '2017');
        Apexpages.currentPage().getParameters().put('OfferingType','PureEngage');
        Apexpages.currentPage().getParameters().put('week', cfq.Id);
        
        Apexpages.currentPage().getParameters().put('selectedYear', '2017');
        Apexpages.currentPage().getParameters().put('selectedOfferingType','PureEngage');
        Apexpages.currentPage().getParameters().put('selectedWeek', cfq.Id);

        PESSRevenueForecastCtlrView pesF = new PESSRevenueForecastCtlrView();
        PESSRevenueForecastCtlrView.PopulatePeriod('2017', 'PureEngage');
        PESSRevenueForecastCtlrView.populateWeek();
        PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','1-2017', cfq.Id, null, null);
        PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','2-2017', cfq.Id, null, null);
        PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','3-2017', cfq.Id, null, null);
        PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','4-2017', cfq.Id, null, null);
        Test.StopTest();
    }
    
    private static testMethod void testThree() {
        
        Offering_Type_Settings__c oType = new Offering_Type_Settings__c();
        oType.Name = 'PureEngage';
        oType.Land_Diff_Amount__c = 100;
        oType.Quarter_Selection__c = false;
        oType.Risk_Threshold_Amount__c = 100;
        oType.Risk_Upside__c = true;
        
        oType.Upside_Threshold_Amount__c = 100;
        oType.Subscription__c = 'A - In-Force Subscription';
        insert oType;
        
        List<Account> lstAnt = TestUtil.createAccounts(2, true);
        lstAnt[0].CSM_Account_Owner__c = Userinfo.getUserId();
        
        Cloud_Forecast_Quarter__c cfq = new Cloud_Forecast_Quarter__c();
        cfq.Name = '12/18/2017 Week 3';
        cfq.Active__c = true;
        cfq.Current_Week__c = true;
        cfq.Start_Date__c = Date.today();
        cfq.End_Date__c = Date.today().adddays(360);
        cfq.Quarter__c = '1-2017';
        insert cfq;
        
        
        Cloud_Forecast_Quarter__c cfq1 = new Cloud_Forecast_Quarter__c();
        cfq1.Name = '12/18/2017 Week 3';
        cfq1.Active__c = true;
        cfq1.Current_Week__c = true;
        cfq1.Start_Date__c = Date.today();
        cfq1.End_Date__c = Date.today().adddays(360);
        cfq1.Previous_Week__c = cfq.Id;
        cfq1.Quarter__c = '1-2017';
        insert cfq1;
        
        Account_Revenue_Forecast__c arf1 = new Account_Revenue_Forecast__c();
        arf1.Account__c = lstAnt[0].Id;
        arf1.Q1_2017_Low__c = 12000;
        arf1.Jan_2017__c = 12000;
        arf1.Apr_2017__c = 12000;
        arf1.Q2_2017_Low__c = 12000;
        arf1.Q3_2017_Low__c = 12000;
        arf1.Q4_2017_Low__c = 12000;
        
        arf1.Q1_2017_Best__c = 12000;
        arf1.Q2_2017_Best__c = 12000;
        arf1.Q3_2017_Best__c = 12000;
        arf1.Q4_2017_Best__c = 12000;
        
        arf1.Offering_Type__c = 'PureEngage';
        arf1.Cloud_Forecast_Quarter__c = cfq.Id;
        arf1.LOB__c = 'A - In-Force Subscription';
        insert arf1;
        
        Account_Revenue_Forecast__c arf2 = new Account_Revenue_Forecast__c();
        arf2.Account__c = lstAnt[0].Id;
        arf2.Q1_2017_Low__c = 12000;
        arf2.Jan_2017__c = 500;
        arf2.Apr_2017__c = 500;
        arf2.Q2_2017_Low__c = 12000;
        arf2.Q3_2017_Low__c = 12000;
        arf2.Q4_2017_Low__c = 12000;
        
        arf2.Q1_2017_Best__c = 12000;
        arf2.Q2_2017_Best__c = 12000;
        arf2.Q3_2017_Best__c = 12000;
        arf2.Q4_2017_Best__c = 12000;
        arf2.Previous_Week__c = arf1.Id;
        arf2.Offering_Type__c = 'PureEngage';
        arf2.Cloud_Forecast_Quarter__c = cfq1.Id;
        arf2.LOB__c = 'A - In-Force Subscription';
        insert arf2;
        
        
        Account_Revenue_Forecast_Comment__c arfc1 =  new Account_Revenue_Forecast_Comment__c();
        arfc1.Account_Revenue_Forecast__c = arf1.Id;
        arfc1.Amount__c = 15000;
        arfc1.Quarter__c = '1-2017';
        arfc1.Reason__c = 'Change';
        arfc1.By_When__c = date.today();
        arfc1.Quarter_Upside_Risk__c = 'Change - '+ 'Q1 - 2017';
        arfc1.Account_Revenue_Forecast__c = arf2.Id;
        
        insert arfc1;
        
        Apexpages.currentPage().getParameters().put('year', '2017');
        Apexpages.currentPage().getParameters().put('OfferingType','PureEngage');
        Apexpages.currentPage().getParameters().put('week', cfq.Id);
        Test.StartTest();
        
            PESSRevenueForecastChangesCtlr pesF = new PESSRevenueForecastChangesCtlr();
            PESSRevenueForecastChangesCtlr.PopulatePeriod('2017');
            PESSRevenueForecastChangesCtlr.populateWeek();
            PESSRevenueForecastChangesCtlr.getAccountRevenueRecordCompare('PureEngage', '2017', cfq1.Id, null, false, cfq.Id);
            String grid = '[{"acntCSM":"John Moriarty","acntName":"AAA Washington","acntRType":"A - In-Force Subscription","amnt":-810969,"arfcId":"000-0-'+ arf2.Id + '","arfcoId":"0000","arfId":"'+ arf2.Id + '"}]';
            String setId = '[000-0-'+ arf2.Id + ']';
            PESSRevenueForecastChangesCtlr.saveARF(grid, setId);
            PESSRevenueForecastControllerView.getchangesReport('PureEngage', '2017',cfq1.ID,cfq.Id, false);
            
            PESSRevenueForecastCtlrView pesFf = new PESSRevenueForecastCtlrView();
            PESSRevenueForecastCtlrView.PopulatePeriod('2017', 'PureEngage');
            PESSRevenueForecastCtlrView.populateWeek();
            
            PESSRevenueForecastCtlrView.populateCSMOwner('PureEngage', '2017',cfq.ID);
            PESSRevenueForecastCtlrView.checkCSMOwner('PureEngage', '2017',cfq.ID);
            
        Test.StopTest();
    }
    
    private static testMethod void testFour() {
        
       Offering_Type_Settings__c oType = new Offering_Type_Settings__c();
        oType.Name = 'PureEngage';
        oType.Land_Diff_Amount__c = 100;
        oType.Risk_Threshold_Amount__c = 100;
        oType.Upside_Threshold_Amount__c = 100;
        oType.Risk_Upside__c = true;
        
        oType.Subscription__c = 'A - In-Force Subscription;D - In-Force Telco';
        insert oType;
        
        List<Account> lstAnt = TestUtil.createAccounts(2, true);
        lstAnt[0].CSM_Account_Owner__c = Userinfo.getUserId();
        
        Cloud_Forecast_Quarter__c cfq = new Cloud_Forecast_Quarter__c();
        cfq.Name = 'New Quarter';
        cfq.Active__c = true;
        cfq.Current_Week__c = true;
        cfq.Start_Date__c = Date.today();
        cfq.End_Date__c = Date.today().adddays(360);
        cfq.Quarter__c = '1-2017';
        insert cfq;
        
        Account_Revenue_Forecast__c arf1 = new Account_Revenue_Forecast__c();
        arf1.Account__c = lstAnt[0].Id;
        arf1.Q1_2017_Low__c = 12000;
        arf1.Q2_2017_Low__c = 12000;
        arf1.Q3_2017_Low__c = 12000;
        arf1.Q4_2017_Low__c = 12000;
        
        arf1.Q1_2017_Best__c = 12000;
        arf1.Q2_2017_Best__c = 12000;
        arf1.Q3_2017_Best__c = 12000;
        arf1.Q4_2017_Best__c = 12000;
        
        arf1.Offering_Type__c = 'PureEngage';
        arf1.Cloud_Forecast_Quarter__c = cfq.Id;
        insert arf1;
        
        
        Account_Revenue_Forecast_Comment__c arfc =  new Account_Revenue_Forecast_Comment__c();
        arfc.Account_Revenue_Forecast__c = arf1.Id;
        arfc.Amount__c = 15000;
        arfc.Quarter__c = '1-2017';
        arfc.Reason__c = 'Risk';
        arfc.By_When__c = date.today();
        arfc.Quarter_Upside_Risk__c = 'Risk - Q1 - 2017';
        arfc.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc;
        
        Account_Revenue_Forecast_Comment__c arfc11 =  new Account_Revenue_Forecast_Comment__c();
        arfc11.Account_Revenue_Forecast__c = arf1.Id;
        arfc11.Amount__c = 15000;
        arfc11.Quarter__c = '2-2017';
        arfc11.Reason__c = 'Risk';
        arfc11.By_When__c = date.today();
        arfc11.Quarter_Upside_Risk__c = 'Risk - Q2 - 2017';
        arfc11.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc11;
        
        Account_Revenue_Forecast_Comment__c arfc22 =  new Account_Revenue_Forecast_Comment__c();
        arfc22.Account_Revenue_Forecast__c = arf1.Id;
        arfc22.Amount__c = 15000;
        arfc22.Quarter__c = '3-2017';
        arfc22.Reason__c = 'Risk';
        arfc22.By_When__c = date.today();
        arfc22.Quarter_Upside_Risk__c = 'Risk - Q3 - 2017';
        arfc22.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc22;
        
        Account_Revenue_Forecast_Comment__c arfc33 =  new Account_Revenue_Forecast_Comment__c();
        arfc33.Account_Revenue_Forecast__c = arf1.Id;
        arfc33.Amount__c = 15000;
        arfc33.Quarter__c = '4-2017';
        arfc33.Reason__c = 'Risk';
        arfc33.By_When__c = date.today();
        arfc33.Quarter_Upside_Risk__c = 'Risk - Q4 - 2017';
        arfc33.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc33;
        
        Account_Revenue_Forecast_Comment__c arfc1 =  new Account_Revenue_Forecast_Comment__c();
        arfc1.Account_Revenue_Forecast__c = arf1.Id;
        arfc1.Amount__c = 15000;
        arfc1.Quarter__c = '1-2017';
        arfc1.Reason__c = 'Upside';
        arfc1.By_When__c = date.today();
        arfc1.Quarter_Upside_Risk__c = 'Upside - Q1 - 2017';
        arfc1.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc1;
        
        Account_Revenue_Forecast_Comment__c arfc2 =  new Account_Revenue_Forecast_Comment__c();
        arfc2.Account_Revenue_Forecast__c = arf1.Id;
        arfc2.Amount__c = 15000;
        arfc2.Quarter__c = '2-2017';
        arfc2.Reason__c = 'Upside';
        arfc2.By_When__c = date.today();
        arfc2.Quarter_Upside_Risk__c = 'Upside - Q2 - 2017';
        arfc2.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc2;
        
        Account_Revenue_Forecast_Comment__c arfc3 =  new Account_Revenue_Forecast_Comment__c();
        arfc3.Account_Revenue_Forecast__c = arf1.Id;
        arfc3.Amount__c = 15000;
        arfc3.Quarter__c = '3-2017';
        arfc3.Reason__c = 'Upside';
        arfc3.By_When__c = date.today();
        arfc3.Quarter_Upside_Risk__c = 'Upside - Q3 - 2017';
        arfc3.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc3;
        
        Account_Revenue_Forecast_Comment__c arfc4 =  new Account_Revenue_Forecast_Comment__c();
        arfc4.Account_Revenue_Forecast__c = arf1.Id;
        arfc4.Amount__c = 15000;
        arfc4.Quarter__c = '4-2017';
        arfc4.Reason__c = 'Upside';
        arfc4.By_When__c = date.today();
        arfc4.Quarter_Upside_Risk__c = 'Upside - Q4 - 2017';
        arfc4.Account_Revenue_Forecast__c = arf1.Id;
        insert arfc4;
        
        Test.StartTest();
        
            Apexpages.currentPage().getParameters().put('year', '2017');
            Apexpages.currentPage().getParameters().put('OfferingType','PureEngage');
            Apexpages.currentPage().getParameters().put('week', cfq.Id);
            
            PESSRevenueForecastCtlrView pesF = new PESSRevenueForecastCtlrView();
            PESSRevenueForecastCtlrView.PopulatePeriod('2017', 'PureEngage');
            PESSRevenueForecastCtlrView.populateWeek();
            PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','1-2017', cfq.Id, null, null);
            PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','2-2017', cfq.Id, null, null);
            PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','3-2017', cfq.Id, null, null);
            PESSRevenueForecastCtlrView.getAccountRevenueRecord('PureEngage', '2017','4-2017', cfq.Id, null, null);
        Test.StopTest();
    }

}