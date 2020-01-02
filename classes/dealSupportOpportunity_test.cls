@IsTest(SeeAllData=true)
public class dealSupportOpportunity_test {
  private static deal_support__c deals;
  private static Account acc;
  public static DSR_Opportunity_Detail__c dsropty;
  private static opportunity oppty;
  private static user currentuser = [select id,Bypass_Triggers__c from user where id =: userinfo.getUserId()];  
  
  static testMethod void testMethod_1() {
      
        system.RunAs(currentuser){
            Test.startTest();
            acc = new Account (Name='test',Description='test',Active__c=true);
            insert acc;
            deals = new deal_support__c(Account__c=acc.id, Support_Area__c='Transactional Help' ,Subject__c='test',Description__C='test',Request_Type__c = 'Create a Quote');
            insert deals;
            RecordType objRecType = [Select id,name from RecordType where name = 'GEN - Opportunity Record Type' AND SObjectType = 'opportunity' ] ;
            string recid = objRecType.id;
            
            dsropty = new DSR_Opportunity_Detail__c( Name='test',Stage__c='1.Understand Needs', Account__c=acc.id,Close_Date__c= Date.today() ,Deal_Support__c=deals.id,Direct_Indirect_Sale__c = 'Direct',Lead_Offer__c='Purecloud',Opportunity_Currency__c='usd',Opportunity_Source__c ='Partner Registered Lead' );
            insert dsropty;
            
            string oppidd ;
            oppidd = dsropty.id;
			
          //  oppty = new opportunity(CloseDate= Date.today(),RecordTypeid= recid ,StageName = '1.Understand Needs',Accountid=acc.id, Name='test',Direct_Indirect_Sale__c='Direct',Transactional_Help__c = true);
            dealSupportOpportunity controller = new dealSupportOpportunity();  
            dealSupportOpportunity.createopty(oppidd);
            
            Test.stopTest();
        }
  }

}