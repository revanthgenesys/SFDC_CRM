public class Debook_Order_process {


  @InvocableMethod(label='Terminate Opportunity & Entitlements' description='Terminates Entitlement & opportunities')

  public static void Terminate_Opp_Ent(List<ID> ids) {//order ids

    
	
     List<id> scid_lst = new List<id>();
	

    for (ServiceContract SC : [SELECT id FROM ServiceContract WHERE Order__c in :ids]) {
	  scid_lst.add(SC.id);
    }  
      
      
    List<id> oppid_lst = new List<id>();
	List<opportunity> Opp_update = new list<opportunity>();

    for (ServiceContract SC : [SELECT id,Renewal_Opportunity__c,Status FROM ServiceContract WHERE Id in :scid_lst]) {
	  oppid_lst.add(SC.Renewal_Opportunity__c);
    }
	
      for(id oppid :  oppid_lst){
          Opportunity opp = new opportunity(id=oppid);
          opp.StageName = 'Cancelled';
          opp.Forecast_Status__c = 'Cancelled';
          opp.Opportunity_Status__c = 'Credit';
          opp.Reason_Code__c = 'Credit/Rebill';
          opp.Cancelled_Date__c = system.today();
          Opp_update.add(opp);
          
      }
   		update Opp_update;
	
      List<Entitlement> et_update = new list<Entitlement>();
      for (Entitlement et : [select id from Entitlement where ServiceContractid in:scid_lst]){
     	et.enddate = system.today()-1;
		et.startdate = system.today()-1;
          et_update.add(et);         
      }
      update et_update;
  }

}