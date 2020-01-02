public class AddQuoteProductsExt 
{
	// Quote Product being added
	public BigMachines__Quote_Product__c objCurrentQP {get; set;}
	// Number of Quote Periods
	public Integer intNumOfPeriods {get; set;}
	// Quote being modified
	public BigMachines__Quote__c objQuote {get; set;}
	// To show/not show added products
	public Boolean blnShowAddedProducts {get; set;}
	// Quote Product being deleted
	public String strQPIndex {get; set;}
	// list of quote products added so far
	public List<BigMachines__Quote_Product__c> list_QuoteProducts {get; set;}
	
	// *** Constructor ***
    public AddQuoteProductsExt(ApexPages.StandardController controller) 
	{
		Id idQuote = controller.getId();
		objCurrentQP = new BigMachines__Quote_Product__c();
		intNumOfPeriods = 0;
		blnShowAddedProducts = false;
		
		List<BigMachines__Quote__c> list_Temp = [SELECT Id,Increase_type__c,BigMachines__Status__c,Maintenance_End_Date__c,
										Sold_To_Name__c,End_User_ID__c,
										(SELECT Id,Start_Date__c,End_Date__c FROM Quote_Periods__r)
										FROM BigMachines__Quote__c WHERE Id = :idQuote];
		if(list_Temp.size() > 0)
		{
			objQuote = list_Temp[0];
			intNumOfPeriods = objQuote.Quote_Periods__r.size();
			fetchQuoteProductsAdded();
			objCurrentQP.Maintenance_End_Date__c = objQuote.Maintenance_End_Date__c;
		}
		else
			objQuote = new BigMachines__Quote__c();
    }
	
	// *** Handler for save button ***
	public void saveBtnHandler()
	{
		if(objCurrentQP.BigMachines__Product__c == null || objCurrentQP.Original_Qty__c == null ||
           objCurrentQP.Current_Qty__c == null || objCurrentQP.Previous_Line_Maintenance_Value__c == null ||
           objCurrentQP.Original_Net_License_Value__c == null || objCurrentQP.Revised_Net_License_Value__c == null ||
           objCurrentQP.Maintenance_Start_Date__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Fill All required Fields.'));
            return;
        }
		List<Product2> list_Product = [SELECT Type__c FROM Product2 WHERE Id = :objCurrentQP.BigMachines__Product__c];
		if(list_Product.size() > 0 && String.isNotBlank(list_Product[0].Type__c))
		{
			List<String> list_Types = Label.Types_Required_Add_Products.split(';');
			for(String strType : list_Types)
			{
				if(list_Product[0].Type__c == strType &&
				(String.isBlank(objCurrentQP.Project_ID__c) || String.isBlank(objCurrentQP.Project_Name__c) ||
					String.isBlank(objCurrentQP.Third_Party_Partners__c) || String.isBlank(objCurrentQP.Third_Party_Applications__c)))
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide all Professional Services related information.'));
					return;
				}
			}
		}
        // To bypass quote product trigger
        Util.Bypass_Trigger_Chk = true;
        objCurrentQP.BigMachines__Quote__c = objQuote.Id;
		objCurrentQP.BigMachines__Sales_Price__c = 1000.0;
		objCurrentQP.BigMachines__Quantity__c = 1;
		
		// Fetching and storing names of accounts selected in the lookups in the text fields on Quote product
		if(objQuote.Sold_To_Name__c != null || objQuote.End_User_ID__c != null)
		{
			Set<Id> set_AccountIds = new Set<Id>();
			if(objQuote.Sold_To_Name__c != null)
				set_AccountIds.add(objQuote.Sold_To_Name__c);
			if(objQuote.End_User_ID__c != null)
				set_AccountIds.add(objQuote.End_User_ID__c);
			
			for(Account objAccount : [SELECT Id,Name FROM Account WHERE Id IN :set_AccountIds])
			{
				if(objAccount.Id == objQuote.Sold_To_Name__c)
					objCurrentQP.Sold_To_Name__c = objAccount.Name;
				if(objAccount.Id == objQuote.End_User_ID__c)
					objCurrentQP.End_User_Name__c = objAccount.Name;
			}
		}
		
		insert objCurrentQP;
		objCurrentQP = new BigMachines__Quote_Product__c();
		fetchQuoteProductsAdded();
	}
	
	// *** Method to get list of quote products added manually by user ***
	public void fetchQuoteProductsAdded()
	{
		list_QuoteProducts = [SELECT Id,Sales_Order__c,Original_PO__c,Product_Description__c,BigMachines__Product__c,
					Current_Qty__c,Maintenance_Start_Date__c,Maintenance_End_Date__c,Original_Net_License_Value__c
					FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = :objQuote.Id AND 
					Service_Contract_Line_ID__c = null AND BigMachines__Product__r.Genesys_Care_Quote__c = false
					AND BigMachines__Product__r.Type__c != 'Flex Care' AND BigMachines__Product__r.Type__c != 'Fees'
					ORDER BY CreatedDate];
		if(list_QuoteProducts.size() > 0)
			blnShowAddedProducts = true;
		else
			blnShowAddedProducts = false;
	}
	
	// *** Handler for removing a Quote product button ***
	public void removeQuotePorduct()
	{
		Integer intRow = Integer.valueOf(strQPIndex);
		BigMachines__Quote_Product__c objDeletedProduct = list_QuoteProducts[intRow];
		//list_QuoteProducts.remove(intRow);
		delete objDeletedProduct;
        fetchQuoteProductsAdded();
	}
	
	// *** Method to return boolean whether record should be locked from editing or not ***
	public Boolean getIsQuoteUnLocked()
	{
		if(objQuote.BigMachines__Status__c == 'Quote Approval Pending' ||
			objQuote.BigMachines__Status__c == 'Quote Approved' ||
			objQuote.BigMachines__Status__c == 'Order Submitted' || 
            objQuote.BigMachines__Status__c == 'Revision Pending' ||
            objQuote.BigMachines__Status__c == 'Order Accepted' || objQuote.BigMachines__Status__c == 'Order Rejected')
			return false;
		return true;
	}
}