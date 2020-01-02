@isTest(SeeAllData=false)
public class updateofferplatformtypehandler_test {
      static testMethod void oldMapNull() {
     
          Test.startTest(); 
            list<partner_portal_prospect__c> delReg = new list<partner_portal_prospect__c>();
            integer i = 0;
            User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
            currUser.Bypass_Triggers__c = true;
            //System.runAs(currUser){
                recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
                
                Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
                insert a1;
                
                Schema.DescribeFieldResult fieldResult = partner_portal_prospect__c.Lead_Offer__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
                for( Schema.PicklistEntry val : ple)
                    {
                        partner_portal_prospect__c ppp = new partner_portal_prospect__c();
                        ppp.Name = 'TestRec';
                        ppp.Status__c = 'Request Submitted';
                        ppp.End_User_Account__c = a1.Id;
                        ppp.What_is_the_Expected_Close_Date__c = Date.Today() + 30;
                        ppp.Opportunity_Channel_Manager__c = currUser.Id;
                        ppp.Lead_Offer__c = val.getValue();
                        System.Debug('--->'+ppp.Lead_Offer__c+';;val--->'+val);
                        delReg.add(ppp);
                    }   

                updateofferplatformtypehandler.updateOfferingPlatformType(delReg,null);
          Test.stopTest(); 
      }
      
      static testMethod void oldMapNotNull() {
     
          Test.startTest(); 
            list<partner_portal_prospect__c> delReg = new list<partner_portal_prospect__c>();
            list<partner_portal_prospect__c> delReg2 = new list<partner_portal_prospect__c>();
            map<Id,partner_portal_prospect__c> dealRegMap = new map<Id,partner_portal_prospect__c>();
            integer i = 0;
            User currUser = [Select Id, Name, Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
            currUser.Bypass_Triggers__c = true;
            //System.runAs(currUser){
                recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
                
                Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
                insert a1;
                
        
                Schema.DescribeFieldResult fieldResult = partner_portal_prospect__c.Lead_Offer__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry val : ple)
                    {
                        partner_portal_prospect__c ppp = new partner_portal_prospect__c();
                        ppp.Name = 'TestRec';
                        ppp.Status__c = 'Request Submitted';
                        ppp.End_User_Account__c = a1.Id;
                        ppp.What_is_the_Expected_Close_Date__c = Date.Today() + 30;
                        ppp.Opportunity_Channel_Manager__c = currUser.Id;
                        ppp.Lead_Offer__c = val.getValue();
                        System.Debug('--->'+ppp.Lead_Offer__c+';;val--->'+val);
                        delReg.add(ppp);
                        
                    }
                    
                 insert delReg;
                 for(partner_portal_prospect__c ppp2:delReg){
                     dealRegMap.put(ppp2.Id,ppp2);
                 }
                updateofferplatformtypehandler.updateOfferingPlatformType(delReg,dealRegMap);
          Test.stopTest(); 
      }

}