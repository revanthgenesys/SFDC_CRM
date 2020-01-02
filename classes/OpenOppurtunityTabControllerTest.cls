/*
Purpose: Test class for OpenOppurtunityTabController
*/
@isTEst(seealldata=false)
public class OpenOppurtunityTabControllerTest{
   
   public static void createOpportunities() {
        // Create common test opportunities
         recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
                
       Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
       insert a1;
       
                recordtype rc1 = [select id, Name from recordtype where name = 'GEN - Opportunity Record Type'  limit 1];
        List<opportunity> testopp = new List<opportunity>();
        for(Integer i=0;i<20;i++) {
            testopp.add(new opportunity(Name = 'Testopp'+i,CloseDate  = Date.Today() + 30,StageName = '1.Understand Needs',ForecastStatus__c = '0.Booked',RecordTypeId = rc1.id,Lead_Offer__c ='PureEngage Premise'));
        }
        insert testopp;        
    }

public static testmethod void  unitTest1(){
            createOpportunities();    
            Test.startTest();
            
            User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
            currUser.Bypass_Triggers__c = true;
      //      System.runAs(currUser){
                Test.setCurrentPage(Page.openoppurtunitytab);
                list<opportunity> oppList = [select id,name from opportunity];
                ApexPages.StandardController Std_Opty = new ApexPages.StandardController(oppList[0]);
                ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppList);
                OpenOppurtunityTabController ext = new OpenOppurtunityTabController(Std_Opty);
                SelectOption[] selOptions = ext.getOppurtunityExistingViews();
                ext.getCurrentOpportunityList();
                ext.SortToggle();
                ext.resetFilter();
    			ext.loop();
      //      }
            Test.stopTest();
        } 

}