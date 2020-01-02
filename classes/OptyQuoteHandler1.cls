public with sharing class OptyQuoteHandler1 {

    public Opportunity opty {get;set;}
    public Id optyId; 
    public Id acountId; 
    public List<SelectOption> pricingOptions {get;set;}
    public String selectedPricingOption {get;set;}
    public String selectedPricingModel {get;set;}
    // Boolean to indicate whether it's a simulated quote (Pricing Simulator)
    public Boolean blnIsSimulation {get; private set;}
    
    public OptyQuoteHandler1(ApexPages.StandardController controller) 
    {
        opty = new Opportunity();
        System.debug('Id is: ' +ApexPages.CurrentPage().getParameters().get('oppId'));
        optyId = ApexPages.CurrentPage().getParameters().get('oppId');
        blnIsSimulation = false;
        if(ApexPages.CurrentPage().getParameters().get('simulator') == '1')
            blnIsSimulation = true;
            
        opty = [select id, Name, AccountId,Sold_To_Country__r.name, Quote_Category__c, Lines_of_Businesses__c,Type,
                        Primary_Line_of_Business__c,currencyIsoCode,BusinessPartner__c,Support_Owner__c,
                        System_Integrator__c,Direct_Sales__c,Account.Country__r.New_Price_Book__c,
                        BusinessPartner__r.Country__r.New_Price_Book__c,Account.Country__r.Old_Price_Book__c,
                        BusinessPartner__r.Country__r.Old_Price_Book__c
                        from Opportunity where id = : optyId ];
                        

        
        if(opty.Primary_Line_of_Business__c != null && opty.Primary_Line_of_Business__c != ''){
            if(opty.Primary_Line_of_Business__c.contains('Cloud') && !opty.Primary_Line_of_Business__c.contains('On Premise'))
                opty.Quote_Category__c = 'Cloud';           
            else if(opty.Primary_Line_of_Business__c.contains('On Premise') && !opty.Primary_Line_of_Business__c.contains('Cloud'))
                opty.Quote_Category__c = 'On Premise';
            else if(opty.Primary_Line_of_Business__c.contains('Cloud') && opty.Primary_Line_of_Business__c.contains('On Premise'))
                opty.Quote_Category__c = null;
        }
        
            pricingOptions = new List<SelectOption>();
            SelectOption newPricing = new SelectOption('', '--Select--');
            pricingOptions.add(newPricing);
            newPricing = new SelectOption('New Pricing', 'New Pricing');
            pricingOptions.add(newPricing);
            newPricing = new SelectOption('Old Pricing', 'Old Pricing');
            pricingOptions.add(newPricing);  
 
            acountId = opty.AccountId; 
    }
    
    public PageReference retrieveQuoteCategory() {
        PageReference bigMachinesQuotePage = null;
        if(opty.Quote_Category__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select a quote category!'));
            return null;  
        } 
        else{
                   
            
            opportunity opp = new opportunity(id = optyId);
            opp.Quote_Category__c = opty.Quote_Category__c;
            opp.Lines_of_Businesses__c = opty.Lines_of_Businesses__c;
            update opp;
            if(opty.Quote_Category__c  == 'Cloud' && Opty.Lines_of_Businesses__c== 'Business Edition'){
                if(opty.Sold_To_Country__r.name != 'United States' &&
                    opty.Sold_To_Country__r.name != 'Ireland'&&
                    opty.Sold_To_Country__r.name != 'United Kingdom'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please note Cloud quoting is only enable for United States,Ireland and United Kingdom'));
                    return null;
                }
            }

            
            if(opty.Quote_Category__c  == 'Cloud' && opty.currencyIsoCode == 'GBP' && opty.Lines_of_Businesses__c != 'Premier Edition' && opty.Lines_of_Businesses__c != 'Business Edition'
                && opty.Lines_of_Businesses__c != 'Social Analytics'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ' You can only select Premeir Edition with UKI. '));
                return null;    
            }
            
            //Cloud Flow
            if(opty.Quote_Category__c == 'Cloud' && Opty.Lines_of_Businesses__c == 'Business Edition'  && opty.CurrencyIsoCode != 'USD'){
                bigMachinesQuotePage = new PageReference('/apex/BigMachines__QuoteEdit?oppId=' + optyId + '&actId=' + acountId + '&qCat='+opty.Quote_Category__c);
                }
            else if(opty.Quote_Category__c == 'Cloud' && (Opty.Lines_of_Businesses__c == 'Business Edition' || Opty.Lines_of_Businesses__c == 'Enterprise Edition')){
                bigMachinesQuotePage = new PageReference('/apex/ServiceOrderQuoteToolBE?oppId=' + optyId + '&actId=' + acountId + '&qCat='+opty.Quote_Category__c + '&offeringType=Business Edition' + '&pricingModel=' + selectedPricingModel );
            }            
            else if(opty.Quote_Category__c == 'Cloud')
                bigMachinesQuotePage = new PageReference('/apex/ServiceOrderQuoteTool?oppId=' + optyId + '&actId=' + acountId + '&qCat='+opty.Quote_Category__c + '&offeringType=' + Opty.Lines_of_Businesses__c );
   
            
          /*//Direct sales on premise flow   
          if(opty.Quote_Category__c == 'On Premise' && opty.Direct_Sales__c){
                if(selectedPricingOption == 'New Pricing')
                    bigMachinesQuotePage = createOnPremiseQuote();                  
                
                if(selectedPricingOption == 'Old Pricing')
                  bigMachinesQuotePage = new PageReference('/apex/BigMachines__QuoteEdit?oppId=' + optyId + '&actId=' + acountId + '&qCat='+opty.Quote_Category__c);
            
           }     
           
           //In Direct Sales On Premise flow
           if(opty.Quote_Category__c == 'On Premise' && !opty.Direct_Sales__c){
                            bigMachinesQuotePage = new PageReference('/apex/BigMachines__QuoteEdit?oppId=' + optyId + '&actId=' + acountId + '&qCat='+opty.Quote_Category__c);
           }*/
           if(opty.Quote_Category__c == 'On Premise'){
           		/*
           		List<Deal_Qualification__c> list_DQ = [SELECT Status__c FROM Deal_Qualification__c 
                                               WHERE Opportunity__c = :optyId AND Type__c =: DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL LIMIT 1];
		        if(!(list_DQ.size() > 0 && list_DQ[0].Status__c == DealQualificationApprovalUtil.STATUS_APPROVED)){
		            PageReference newPR = new PageReference('/apex/DealQualification?oppId=' + optyId + '&msg=DQ_NOT_APPROVED');
		            newPR.setRedirect(true);
		            return newPR;
		        }
		        */		        
                bigMachinesQuotePage = createOnPremiseQuote();           
           		bigMachinesQuotePage.setRedirect(true);
           }
        }
        return bigMachinesQuotePage;
    }
    
    public pageReference goToCloneQuoteIfOppIsDownUpGrade(){
        optyId = ApexPages.CurrentPage().getParameters().get('oppId');
        Opportunity opp = [SELECT Is_Downgrade__c, Is_Upgrade__c FROM Opportunity WHERE id =: optyId];
        if(opp.Is_Downgrade__c || opp.Is_Upgrade__c){
                String param;
                if(opp.Is_Downgrade__c)
                        param = 'Downgrade';
                else
                        param = 'Upgrade';
                PageReference newPR = new PageReference('/apex/CloneQuoteForUpgradeDowngrade?oppId=' + optyId + '&param=' + param);
                newPR.setRedirect(true);
                return newPR;
        }
        
        return null;
    }
    
    public pageReference refresh(){
        return null;
    }
    
    // *** Method to create On Premise Quote and return it's page reference ***
    public pageReference createOnPremiseQuote()
    {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.BigMachines__Opportunity__c = opty.Id;
        objQuote.Quote_Created_Date__c = System.today();
        
        if(blnIsSimulation)
            objQuote.BigMachines__Status__c = 'Simulated Quote';
        else
            objQuote.BigMachines__Status__c = 'Quote In Progress';
        
        objQuote.Grid_Group_By__c = 'Categories';
        objQuote.Service_Level__c = 'Business';
        objQuote.Pricing_Model__c = 'Enabled';
        
        if(selectedPricingOption == 'New Pricing')
            objQuote.Quote_Opportunity_Type__c = 'New Pricing';
        else
            objQuote.Quote_Opportunity_Type__c = 'Old Pricing';
            
        objQuote.Order_Numb_of_Maint_Months__c = 12;
        objQuote.Duration_Unit__c = 'Months';
        
        // Example : Basic Care-New(End User)
        String strGCProdName = objQuote.Service_Level__c + ' Care-New';
        
        if(opty.AccountId != null)
        {
            objQuote.End_User_ID__c = opty.AccountId;
            objQuote.BigMachines__Account__c = opty.AccountId;
        }
        if(opty.BusinessPartner__c != null)
        {
            objQuote.Sold_To_Name__c = opty.BusinessPartner__c;
            
            if(selectedPricingOption == 'New Pricing')
                objQuote.New_Price_Book__c = opty.BusinessPartner__r.Country__r.New_Price_Book__c;
            else
                objQuote.New_Price_Book__c = opty.BusinessPartner__r.Country__r.Old_Price_Book__c;
        }
            
        // If Direct sale, pre-populate sold to with end user info
        if(opty.Direct_Sales__c)
        {
            objQuote.Sold_To_Name__c = objQuote.End_User_ID__c; 
            
            if(selectedPricingOption == 'New Pricing')
                objQuote.New_Price_Book__c = opty.Account.Country__r.New_Price_Book__c;
            else
                objQuote.New_Price_Book__c = opty.Account.Country__r.Old_Price_Book__c;
                
            strGCProdName += '(End User)';
        }
        else
            strGCProdName += '(Partner)';
            
        if(opty.Support_Owner__c != null)
            objQuote.Support_Owner__c = opty.Support_Owner__c;
            
        if(opty.System_Integrator__c != null)
            objQuote.System_Integrator__c = opty.System_Integrator__c;
        
        objQuote.CurrencyISOCode = opty.CurrencyISOCode;
        objQuote.Quote_Business_Type__c = 'On Premise';
        
        // Default quote expiration after 90 days
        objQuote.Expiration_Date__c = Date.today().addDays(90);
        
        BigMachines__Quote_Product__c objServiceLevel = null;
        List<Product2> list_Temp1 = [SELECT Id,Name,Unit_of_Measure__c
                            FROM Product2 WHERE Description = :strGCProdName AND 
                            Genesys_Care_Quote__c = true AND IsActive = true];
        if(list_Temp1.size() > 0)
        {
            objServiceLevel = new BigMachines__Quote_Product__c(BigMachines__Quantity__c = 1,
                                BigMachines__Sales_Price__c = 0);
            objServiceLevel.Name = list_Temp1[0].Name;
            objServiceLevel.Unit_of_Measure__c = list_Temp1[0].Unit_of_Measure__c;
            objServiceLevel.BigMachines__Product__c = list_Temp1[0].Id;
        }
        
        try
        {
            insert objQuote;
                        
            objQuote.Name = (blnIsSimulation ? 'SIM-':'') + ([SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: objQuote.id].Quote_Number__c);
            update objQuote;
                        
            if(objServiceLevel != null)
            {
                objServiceLevel.BigMachines__Quote__c = objQuote.Id;
                insert objServiceLevel;
            }
            
            return (new PageReference('/apex/CreateQuoteOnPremise1?id=' + objQuote.Id));
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
        return null;
    }
}