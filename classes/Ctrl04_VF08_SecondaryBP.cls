public with sharing class Ctrl04_VF08_SecondaryBP {

	private BPStorage__c newBP {get; set;}

	public Ctrl04_VF08_SecondaryBP(ApexPages.StandardController stdController){
        Util.MyLog('###Ctrl04_VF08_SecondaryBP Start');
        this.newBP = (BPStorage__c)stdController.getRecord();
    }
    
    public PageReference init(){
    	if(newBP.Id==null && Apexpages.currentPage().getParameters().get('sec')==null)
    	{
    		Pagereference p =Page.VF07_PrimaryBusinessPartner;
    		p.getParameters().put('id',newBP.OpportunityAssociated__c);
    		p.getParameters().put('sec','1');
    		return p;
    	}
    	else if(Apexpages.currentPage().getParameters().get('sec')!=null)
    	{
    		newBP.BPAssociated__c = Apexpages.currentPage().getParameters().get('sec');
    		newBP.OpportunityAssociated__c = Apexpages.currentPage().getParameters().get('oppId');
    		return null;	
    	}
    	else 
    		return null;
    }

	public PageReference SaveBPStorage(){
		upsert this.newBP;
		//Return User to Opportunity Associated view page
		Opportunity opp = new Opportunity(id=this.newBP.OpportunityAssociated__c);
	    ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	    Util.MyLog('###SaveBPStorage End');
	    return sc.view();
	}

	////////////////////////////////////////////////////////////////////////
	/////////////////////                 TEST             /////////////////
	////////////////////////////////////////////////////////////////////////
	
	static  testMethod void TestCtrl04_VF08_SecondaryBP()
	{
		User use = TestCommon.createUser('testmlg', 'Mmichael.legrand@emg.alcatel-lucent.com.emgdev', 'MyTestLastName','MyTestFirstName',Config.PROFIL_ADMIN_ID);

		Account myAccount = TestCommon.createAccount(true);
		Account myAccountBP = TestCommon.createAccountBP(true);
		
		Opportunity o = TestCommon.createOpportunity(myAccount.Id);
		o.BusinessPartner__c = myAccountBP.id;
		update o;
		
		BPStorage__c bpsto = new BPStorage__c(role__c = 'Business Partner');
		ApexPages.StandardController sc = new ApexPages.StandardController(bpsto);
		Ctrl04_VF08_SecondaryBP Ctrl04 = new Ctrl04_VF08_SecondaryBP(sc);
		Ctrl04.SaveBPStorage();
	}
}