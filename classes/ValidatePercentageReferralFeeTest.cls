@isTest(seeAllData=true)
public class ValidatePercentageReferralFeeTest {
    public static testmethod void testMethods(){    
        List<Lead_Referral_Registration__c> lrrRecords = [SELECT id, Name, Channel_Manager__c, Status__C, Percentage_Referral_Fee__c 
                                                            FROM Lead_Referral_Registration__c 
                                                            WHERE Channel_Manager__r.isActive = true and End_User_Account__c <> null
                                                             and Channel_Manager__r.Profile.Name <> 'System Administrator' LIMIT 1];
                                                             
        Approval.unlock(lrrRecords);
        
        lrrRecords[0].Status__C = 'Request Pending'; 
        //update lrrRecords[0];
        
        lrrRecords[0].Percentage_Referral_Fee__c = 0.15;
        update lrrRecords[0];
        
        List<User> users = [SELECT id, Name from User WHERE Id =:lrrRecords[0].Channel_Manager__c limit 1];
        
        System.runAs(users[0]){
            try{
                lrrRecords[0].Percentage_Referral_Fee__c = 0.25;
                update lrrRecords[0];
            } catch(Exception e){}
        }
        
        //lrrRecords[0].Status__C = 'Approved';
        //update lrrRecords[0];
        
        /*System.runAs(users[0]){
             try{
                lrrRecords[0].Percentage_Referral_Fee__c = 0.35;
                update lrrRecords[0];
             } catch(Exception e){}
        }*/
    }
}