//Naresh Kumar    10/19/2016
@isTest (seeAllData = true)
private class OpportunityHistorySnapshotsTest {
      static testMethod void OpportunityHistorySnapshots() {
          Test.StartTest();
          Opportunity opp = TestUtil.createOpportunities(1, false)[0];
          insert opp;
          
          opp.Amount = 1000;
          opp.CloseDate = System.today().addDays(121);
          opp.Description = 'Test';
          opp.ForecastStatus__c = '5.Pipeline';
          opp.License_Amount__c = 2000;
          opp.Maintenance_Amount__c = 3000;
          opp.Lines_of_Businesses__c = 'Enterprise Edition';
          opp.Opportunity_Status__c = 'In Progress';
          opp.Primary_Line_of_Business__c = 'On Premise';
          opp.Competitor__c = 'None - Genesys Customer (add-on)';          
          update opp;

          opp.Amount = 2000;
          opp.CloseDate = System.today().addDays(111);
          opp.Description = 'Test 1';
          opp.ForecastStatus__c = '6.Omitted';
          opp.License_Amount__c = 3000;
          opp.Maintenance_Amount__c = 4000;
          opp.Lines_of_Businesses__c = 'Business Edition';
          opp.Opportunity_Status__c = 'Quoted';
          opp.Primary_Line_of_Business__c = 'On Premise';
          opp.Competitor__c = 'None';
          update opp;
          OpportunityHistorySnapshots.createSnapshotDataForOpportunity(opp.id, true);
          OpportunityHistorySnapshots.createSnapshotDataForOpportunity(opp.id, false); 
          Test.StopTest();
      }
      
      static testMethod void OpportunityHistorySnapshotsBatch() {
          Opportunity opp = TestUtil.createOpportunities(1, false)[0];
          opp.Amount = 1000;
          opp.CloseDate = System.today().addDays(121);
          opp.Description = 'Test';
          opp.ForecastStatus__c = '5.Pipeline';
          opp.License_Amount__c = 2000;
          opp.Maintenance_Amount__c = 3000;
          opp.Lines_of_Businesses__c = 'Enterprise Edition';
          opp.Opportunity_Status__c = 'In Progress';
          opp.Primary_Line_of_Business__c = 'On Premise';
          opp.Competitor__c = 'None - Genesys Customer (add-on)';          
          insert opp;
          
          opp.Amount = 2000;
          opp.CloseDate = System.today().addDays(111);
          opp.Description = 'Test 1';
          opp.ForecastStatus__c = '6.Omitted';
          opp.License_Amount__c = 3000;
          opp.Maintenance_Amount__c = 4000;
          opp.Lines_of_Businesses__c = 'Business Edition';
          opp.Opportunity_Status__c = 'Quoted';
          opp.Primary_Line_of_Business__c = 'On Premise';
          opp.Competitor__c = 'None';
          update opp;
          Test.startTest();
          String batjobId = Database.executeBatch(new OpportunityHistorySnapshotsBatch('SELECT id FROM Opportunity WHERE id = \'' +opp.id  + '\' ', true),10);
          Test.stopTest();
      }
        
    static testMethod void createNewSnapshotTest() {
        //Opportunity_History_Snapshot__c createNewSnapshot(Opportunity_History_Snapshot__c snapshot)   
        Opportunity_History_Snapshot__c snapshot = new Opportunity_History_Snapshot__c();
        snapshot.Account__c = null;
        snapshot.Amount__c = null;
        snapshot.Close_Date__c = null;
        snapshot.Country__c = null;
        snapshot.Description__c = null;
        snapshot.Forecast_Status__c = null;
        snapshot.License_Amount__c = null;
        snapshot.Maintenance_Amount__c = null;
        snapshot.ACV_Subscription_Only__c = null;
        snapshot.Offerings_Type__c = null;
        snapshot.Opportunity__c = null;
        snapshot.Opportunity_Status__c = null;
        snapshot.Owner__c = null;
        snapshot.Platform_Type__c = null;
        snapshot.Primary_Competitor__c = null;
        snapshot.Primary_Won_Lost_Reason__c = null;
        snapshot.Sold_To_Business_Partner__c = null;
        snapshot.Sold_To_Country__c = null;
        snapshot.StageName__c = null;
        snapshot.Type__c = null;
        snapshot.Win_Loss_Status__c = null;
        
        Opportunity_History_Snapshot__c newSnapshot = OpportunityHistorySnapshots.createNewSnapshot(snapshot);
    }
}