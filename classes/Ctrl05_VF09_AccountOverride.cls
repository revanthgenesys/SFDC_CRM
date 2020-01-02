public with sharing class Ctrl05_VF09_AccountOverride {
	public Account acc{get;set;}
	public String retURL {get; set;}
	public String saveNewURL {get; set;}
	public String rType {get; set;}
	public String cancelURL {get; set;}
	public String ent {get; set;}
	public String confirmationToken {get; set;}
	public String accountID {get; set;}
	public String contactID {get; set;}
	public Ctrl05_VF09_AccountOverride(ApexPages.StandardController con){
		acc  = (Account)con.getRecord();
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		rType = ApexPages.currentPage().getParameters().get('RecordType');
		cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
		ent = ApexPages.currentPage().getParameters().get('ent');
		confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
		saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');	
	}
	public Pagereference init()
	{
		PageReference returnURL;
		if(acc.RecordTypeId==Config.EMG_BUSINESS_PARTNER_RECORDTYPE)
		{
			returnURL= Page.VF09_BPAccountDetails;
			returnURL.getParameters().put('id',acc.id);
			
		}
		else
		{
			returnURL  = new PageReference('/' + acc.id + '/d');
            returnURL.getParameters().put('nooverride', '1');
		}
		returnURL.getParameters().put('retURL', retURL);
		returnURL.getParameters().put('RecordType', rType);
		returnURL.getParameters().put('cancelURL', cancelURL);
		returnURL.getParameters().put('ent', ent);
		returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
		returnURL.getParameters().put('save_new_url', saveNewURL);
		returnURL.getParameters().put('nooverride', '1');
		returnURL.setRedirect(true);
		return returnURL;
	}
}