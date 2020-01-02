//Naresh Kumar	03/05/2014
public with sharing class CloneQuoteForUpgradeDowngradeController {
	public Opportunity opp {get;set;}
	public BigMachines__Quote__c quote {get; set;}
	public List<SelectOption> quotesOptions {get;set;}
	public String selectedQuote {get;set;}
	public String selectedUpgradeType {get;set;}
	private String primaryQuoteId {get;set;}
	public CloneQuoteForUpgradeDowngradeController(){
		init();
	}
	
	public pageReference next(){
		String clonedQuoteId = CloudQuoteUtil.cloneQuoteAndAddLineItemsFromSCLine(selectedQuote, primaryQuoteId, selectedUpgradeType, opp.id);		
		PageReference newPR = new PageReference('/apex/'+getPageName(quote)+'?id=' + clonedQuoteId + '&oppId=' + opp.id + '&upgradeType='+selectedUpgradeType);
		newPR.setRedirect(true);
		return newPR;
	}
	
	private void init(){
		String oppId = ApexPages.currentPage().getParameters().get('oppId');
		selectedUpgradeType = ApexPages.currentPage().getParameters().get('param');
		opp = [SELECT Name, ParentOpportunity__c, Lines_of_Businesses__c FROM Opportunity WHERE id =: oppId];
		quotesOptions = new List<SelectOption>();
		
		
		List<BigMachines__Quote__c> quotes = [SELECT Name, BigMachines__Is_Primary__c FROM BigMachines__Quote__c 
			WHERE BigMachines__Opportunity__c =: opp.ParentOpportunity__c AND Quote_Business_Type__c = 'Cloud'];
		if(!quotes.isEmpty()){
			primaryQuoteId = quotes[0].id;
			selectedQuote = primaryQuoteId;
		}
		for(BigMachines__Quote__c eachQuote : quotes){
			if(eachQuote.BigMachines__Is_Primary__c){
				selectedQuote = eachQuote.id;
				primaryQuoteId = eachQuote.id;
			}
			SelectOption newOption = new SelectOption(eachQuote.id, eachQuote.Name);
			quotesOptions.add(newOption);
		}
		populateQuoteDetails();
	}
	
	public pageReference cloneAndGoToOpty(){
		if(ApexPages.currentPage().getParameters().get('cloneQuote') != null){
			return cloneQuote(ApexPages.currentPage().getParameters().get('quoteId'));
		}
		String oppId = ApexPages.currentPage().getParameters().get('oppId');
		String cloneOpty = ApexPages.currentPage().getParameters().get('cloneOpty');
		String downgrade = ApexPages.currentPage().getParameters().get('downgrade');
		String upgrade = ApexPages.currentPage().getParameters().get('upgrade');
		Opportunity opp = [SELECT Name, Country__c, Original_Sold_To__c, Sold_To_Country__c, AccountId,
			StageName, CloseDate, Direct_Sales__c, BusinessPartner__c, RecordTypeId, Gene_Care_Specialist__c,
			Quote_Mtce_Ops__c, Previous_Maintenance_Rate__c, Lines_of_Businesses__c FROM Opportunity WHERE id =: oppId];					
		if(cloneOpty != null){
			Opportunity oppClone = opp.clone(false, true);	
			List<RecordType> rTypes = [SELECT id FROM RecordType WHERE DeveloperName = 'Upgrade_Downgrade' AND SobjectType = 'Opportunity' LIMIT 1];
			oppClone.StageName = '1.Recognize Needs';
			oppClone.ParentOpportunity__c = oppId;
			if(!rTypes.isEmpty())	
				oppClone.RecordTypeId = rTypes[0].id;				
			if(downgrade != null){
				oppClone.Is_Downgrade__c = true;
				oppClone.Name = 'Downgrade - ' + oppClone.Name;
			}
			else if(upgrade != null){
				oppClone.Is_Upgrade__c = true;
				oppClone.Name = 'Upgrade - ' + oppClone.Name;
			}
							
			insert oppClone;
			PageReference newPR = new PageReference('/' + oppClone.id + '/e?retURL=' + oppClone.id);
			newPR.setRedirect(true);
			return newPR;			
		}
		else{
			//If there is no quote on parent opp, go to new quote screen.
			init();
			String pageName = 'ServiceOrderQuoteTool';
			System.debug('NKC debug opp.Lines_of_Businesses__c ['+opp.Lines_of_Businesses__c+']');
			if(opp.Lines_of_Businesses__c == ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
				pageName = 'ServiceOrderQuoteToolBE';
			System.debug('NKC debug pageName ['+pageName+']');	
			if(quotesOptions.isEmpty()){				
				PageReference newRef = new PageReference('/apex/'+pageName+'?oppId=' + opp.id + '&offeringType=' + opp.Lines_of_Businesses__c);
				newRef.setRedirect(true);
				return newRef;
			}
		}
		return null;
	}
	private String getPageName(BigMachines__Quote__c quote){
		String pageName = 'ServiceOrderQuoteTool';
		if(quote != null && quote.Offering_Type__c != null &&
			quote.Offering_Type__c == ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD){
			pageName = 'ServiceOrderQuoteToolBE';
		}
		return pageName;
	}
	public PageReference cloneQuote(String quoteId){
		BigMachines__Quote__c quote = (BigMachines__Quote__c)Database.query(ServiceOrderQuoteHelper.prepareQuoteQuery((id)quoteId));
		String cloneQuoteId = ServiceOrderQuoteHelper.cloneQuote(quote, false);			
		List<Opportunity> opp = [SELECT Quote_Category__c, Lines_of_Businesses__c, AccountId FROM Opportunity WHERE id =: quote.BigMachines__Opportunity__c];
		if(opp.isEmpty())
			return null;		
		PageReference bigMachinesQuotePage;
		bigMachinesQuotePage = new PageReference('/apex/'+getPageName(quote)+'?id=' + cloneQuoteId + '&offeringType=' + opp[0].Lines_of_Businesses__c );            
        bigMachinesQuotePage.setRedirect(true);
        return bigMachinesQuotePage;
	}
	
	public void populateQuoteDetails(){
		if(selectedQuote != null){
			System.debug('NKC debug selectedQuote ['+selectedQuote+']');
			String query = CloudQuoteUtil.getQuoteForFieldSet('Quote_Summary_Fields','BigMachines__Quote__c');
			query += ' WHERE id = \'' + selectedQuote + '\'';
			quote = (BigMachines__Quote__c)Database.query(query);
		} 
	}
}