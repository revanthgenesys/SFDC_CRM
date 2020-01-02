@isTest
public class CalendarExample_Controller_Test {

    public static testmethod void testEvents(){
        List<Marketing_Activity__c> recList = new List<Marketing_Activity__c>();
        for(Integer i=0;i<10;i++){
        	Marketing_Activity__c mRec = new Marketing_Activity__c();
            mRec.Name = 'Test Event' + i;
            mRec.Start_Event_Date__c = Date.today().addDays(i);
            mRec.Partner_Event_Start_Date__c = Date.today().addDays(i);
            mRec.End_Date__c = Date.today().addDays(i+3);
            mRec.Description__c = 'Description Items that needs to be more than 50 characters otherwise it will show custom validation error'+i;
            mRec.Synopsis__c = mRec.Description__c;
            mRec.Activity_Link__c= 'www.test.com';
            mRec.Genesys_Involvement_in_Event__c = 'Partner Presence';
            if(Math.mod(i,5)==0){
                mRec.Region__c = 'Global';
                mRec.Activity_Link__c = 'https://www.genesys.com/events';
            }
            else if(Math.mod(i,5)==1){
                mRec.Region__c = 'North America';
                mRec.Activity_Link__c = 'http://www.genesys.com/events';
            }
            else if(Math.mod(i,5)==2){
                mRec.Region__c = 'APAC';
                mRec.Activity_Link__c = 'www.genesys.com/events';
            }
            else if(Math.mod(i,5)==3){
                mRec.Region__c = 'EMEA';
            }
            else if(Math.mod(i,5)==4){
                mRec.Region__c = 'LATAM';
            }
            mRec.Sub_Region__c = 'Test Sub';
            mRec.Send_to_Nurture_Reason__c  = 'test';
            mRec.Publish_to_Partner_Portal_New__c = 'Yes';
            recList.add(mRec);
        }
        insert recList;
        
        //Call constructor
        CalendarExample_Controller con = new CalendarExample_Controller();
        con.pageLoad();
        
    }
}