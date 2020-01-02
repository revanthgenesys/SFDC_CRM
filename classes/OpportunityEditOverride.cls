public with sharing class OpportunityEditOverride {

  private Opportunity opp;

  public OpportunityEditOverride(Apexpages.Standardcontroller con){
    opp = (Opportunity) con.getRecord();
  }

  public Pagereference init(){
    try{
      opp=[select id,StageName,BusinessPartner__c,Direct_Sales__c from Opportunity where id =:opp.Id];
      Pagereference newPage;
            
      if(Integer.valueOf(opp.StageName.substring(0,1))>3 && opp.BusinessPartner__c==null && opp.Direct_Sales__c==false)
      {
        newPage=Page.VF07_PrimaryBusinessPartner;
        newPage.getParameters().put('edit', '1');
      }
      else
      {
        newPage = new PageReference('/' + opp.id + '/e');
        newPage.getParameters().put('nooverride', '1');
        newPage.getParameters().put('retURL', '/'+opp.Id);
      }
      newPage.getParameters().put('id', opp.id);
      return newPage;
    }
    catch(Exception err)
    {
      Apexpages.addMessages(err);
      return null;
    }
  }
  
  static testMethod void myTest() {
    Opportunity opp = [select id from opportunity limit 1];
    Apexpages.Standardcontroller con = new Apexpages.Standardcontroller(opp); 
    OpportunityEditOverride oppOv = new OpportunityEditOverride(con);
    oppOv.init();
  }
  static testMethod void myTest2() {
    Opportunity opp = new Opportunity() ;
    Apexpages.Standardcontroller con = new Apexpages.Standardcontroller(opp); 
    OpportunityEditOverride oppOv = new OpportunityEditOverride(con);
    oppOv.init();
  }
  
}