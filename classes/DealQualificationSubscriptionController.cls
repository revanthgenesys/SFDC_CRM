/************************************************************************************
Purpose :  Controller for the quoting tool page DealQualificationSubscription
Written By :  Naresh Kumar 11/02/2017
Test Classes :  DealQualificationSubscriptionControllerTest
*************************************************************************************/ 
public class DealQualificationSubscriptionController {
    public List<Deal_Qualification__c> dqs;   
    public Deal_Qualification__c dq {get;set;}
    public Deal_Qualification__c dqOld {get;set;}
    public List<Deal_Qualification_Products__c> dealQualProducts {get;set;}
    public List<BigMachines__Quote__c> quotes {get;set;}
    public BigMachines__Quote__c quote {get;set;}
    public Boolean showProducts {get;set;}
    public String oppId {get;set;}
    public Opportunity opp {get;set;}
    public Boolean showGenesysCareFields {get;set;}
    public String genesysCare {get;set;}
    public String dqId {get;set;}
    public String dqProductIdToBeDeleted {get;set;}
    public String sellingNONGAFutureMap {get;set;}
    public Boolean showSellingNONGAFutureMap {get;set;}
    public String professionalServices {get;set;}
    public Boolean showProfessionalServices {get;set;}
    public Boolean isReadOnly {get;set;}
    public Boolean showReviseButton {get;set;}
    public String statusStyle {get;set;}
    public String pricingType {get;set;}
    public Decimal totalDiscount {get;set;}
    public String termDiscountRanges {get;set;}
    public String seatDiscountRanges {get;set;}
    public String newLogoDiscountRanges {get;set;}
    public Opportunity psOpp {get;set;}
    public String offeringType {get;set;}
    public String platformType {get;set;}
    public String offeringDetails {get;set;}
    public List<SelectOption> listOfPureSuccessOffers {get;set;}
    public Boolean blnIsDealFactoryUser {get; private set;}
    public Boolean blnLockDownPricing {get; private set;}
    
    //Mukunth added below variables for INC0416843 - DQ Special Offers Sub-aprpovers
    public boolean showDQSpecApprReadOnly{get;set;}
	public boolean isSpecApprOfferPending{get;set;}
	public boolean isRevSubApprover{get;set;}
	public boolean isOMBSubApprover{get;set;}
	public boolean isCCSubApprover{get;set;}
	public boolean isLegalSubApprover{get;set;}
	public map<string, DQ_Special_Offers__c> dqSpecOffersCS{get;set;}
	public map<string,list<string>> finToAddresses {get;set;}
	public DealQualificationApprovalUtil.DQSpecOfferSubApprWrapper dqSpecOffrWrppr{get;set;}
	public map<string,boolean> sendMailStatus{get;set;}
    public boolean sentRevEmail{get;set;}
    public boolean sentOMEmail{get;set;}
    public boolean sentCCEmail{get;set;}
    public boolean sentLegalEmail{get;set;}
    public string unlockFinFn{get;set;}
    public boolean isSubApprover{get;set;}
    //Mukunth code end - DQ Special Offers
    
    public DealQualificationSubscriptionController(ApexPages.StandardController stdCtrl){   
        dqId = ApexPages.currentPage().getParameters().get('id'); 
        pricingType = ApexPages.currentPage().getParameters().get('p');     
        if(oppId == null) 
            oppId = ApexPages.currentPage().getParameters().get('oppId');
        platformType = ApexPages.currentPage().getParameters().get('pt');
        offeringType = ApexPages.currentPage().getParameters().get('ot');
        offeringDetails = ApexPages.currentPage().getParameters().get('od');
        init();
        if(dq.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_PENDING || dq.Status__c == DealQualificationApprovalUtil.STATUS_REVISION_PENDING)
            statusStyle = '#FFCC00';
        else if(dq.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_APPROVED)
            statusStyle = '#4DFF4D';
        else
            statusStyle = '#FF6666';
        blnLockDownPricing = DealQualificationController.lockDownPricingAndCare();
    }
    public void init(){     
        showProducts = false;
        showGenesysCareFields = false;
        isReadOnly = false;
        showReviseButton = false;
        totalDiscount = 0;  
        
		//Mukunth added below line for INC0416843 - DQ Special Offers Sub-aprpovers
		showDQSpecApprReadOnly = isSpecApprOfferPending = false;
		isRevSubApprover = isOMBSubApprover = isCCSubApprover = isLegalSubApprover = false;
		sentRevEmail = sentOMEmail = sentCCEmail = sentLegalEmail = isSubApprover = false;
		finToAddresses = new map<string,list<string>>();
		dqSpecOffrWrppr = new DealQualificationApprovalUtil.DQSpecOfferSubApprWrapper();
		sendMailStatus = new map<string,boolean>();
        //Mukunth code end
        
        System.debug('NKC debug oppId [' + oppId + ']');
        System.debug('NKC debug dqId [' + dqId + ']');
        if(dqId != null){
            Deal_Qualification__c dq = [SELECT Opportunity__c, Pricing_Type__c, Platform_Type__c, Offering_Type__c,
                                        Opportunity__r.Primary_Line_of_Business__c FROM Deal_Qualification__c WHERE id =: dqId];
            System.debug('NKC debug dq [' + dq + ']');
            oppId = dq.Opportunity__c;
            pricingType = dq.Pricing_Type__c;
            offeringType = dq.Offering_Type__c; 
            platformType = dq.Platform_Type__c;             
        }
        if(oppId != null){
            opp = [SELECT Name, License_Amount__c, Account.Name, BusinessPartner__r.Name, BusinessPartner__r.Partner_Tier__c, Owner.Name, Country_Region__c, 
                Region_Non_CSM__c,//Mukunth added for DQ SOSA
              Country_Sub_Region__c, Primary_Solution_Category__c, StageName, BusinessPartner__r.FYM_Rate__c, 
              CurrencyIsoCode, Account.FYM_Rate__c, Direct_Sales__c, Competitor__c,NumberofAgents__c, ACV_Subscription_Only__c,
              Total_Annual_Contract_Value__c, Actual_CMRR__c, Annual_Contract_Value__c, Term_Commitment__c, Account.Partner_Tier__c,
              Type, Partner_Opportunity_Source__c, Lines_of_Businesses__c, Sold_To_Country__r.Region__c, Sold_To_Country__r.Name,BusinessPartner__r.PartnerType__c,
              Monthly_Commitment__c, Primary_Line_of_Business__c , PricingType__c, Expiration_Date__c, Direct_Indirect_Sale__c, Offering_Detail__c,
              BusinessPartner__r.SMART_Qualified__c, Sold_To_Country__c, BusinessPartner__r.Subscription_Qualified__c
              FROM Opportunity WHERE id =: oppId];
            if(platformType == null)
                platformType = opp.Primary_Line_of_Business__c ;
            if(offeringType == null){                
                offeringType = opp.Lines_of_Businesses__c + ' ' + 'Subscription';
            }
            if(pricingType == null || (pricingType != 'Old Pricing' && opp.PricingType__c == 'New / Simplified pricing')){
                pricingType = 'New Pricing';   
            }
            dqs = DealQualificationApprovalUtil.getDQ(oppId, pricingType, platformType, offeringType, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
            
            if(dqs.isEmpty()){
                dq = new Deal_Qualification__c(Opportunity__c = oppId, Pricing_Type__c = pricingType, CurrencyIsoCode = opp.CurrencyIsoCode);
                //dq.Contractual_Rate__c = opp.Direct_Sales__c ? opp.Account.FYM_Rate__c : opp.BusinessPartner__r.FYM_Rate__c;
                dq.Contractual_Rate__c =opp.Account.FYM_Rate__c;
                dq.Competitor__c = opp.Competitor__c;                                
                dq.Offering_Type__c = offeringType;                    
                dq.Platform_Type__c = platformType;
                //dq.Overage_Allowance__c = '';
                dq.Billing_Period__c = 'Annually';
                dq.Term_Length__c = 24;           
                dq.Genesys_Care__c = DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD;
                genesysCare = dq.Genesys_Care__c;
                if(opp.License_Amount__c >= 0 && opp.License_Amount__c <= 25000)                   
                    dq.Net_Deal_Value__c = '< 25K';
                if(opp.License_Amount__c > 25000 && opp.License_Amount__c <= 50000)                   
                    dq.Net_Deal_Value__c = '25K - 50K';
                if(opp.License_Amount__c > 50000 && opp.License_Amount__c <= 100000)                   
                    dq.Net_Deal_Value__c = '50K - 100K';
                else if(opp.License_Amount__c > 100000 && opp.License_Amount__c <= 500000)                  
                    dq.Net_Deal_Value__c = '100K - 500K';
                else if(opp.License_Amount__c > 500000 && opp.License_Amount__c <= 1000000)                 
                    dq.Net_Deal_Value__c = '500K - 1M';
                else if(opp.License_Amount__c > 1000000 && opp.License_Amount__c <= 2000000)                    
                    dq.Net_Deal_Value__c = '1M - 2M';
                else if(opp.License_Amount__c > 2000000 && opp.License_Amount__c <= 3000000)                    
                    dq.Net_Deal_Value__c = '2M - 3M';
                else if(opp.License_Amount__c > 3000000 && opp.License_Amount__c <= 10000000)                   
                    dq.Net_Deal_Value__c = '3M - 10M';
                else if(opp.License_Amount__c > 10000000 && opp.License_Amount__c <= 50000000)                   
                    dq.Net_Deal_Value__c = '10M - 50M';     
                
                List<DSR_Use_Case_Blueprints__c> listOfSelectUseCases = DSRUtility.GetFnUseCaseAndBluePrints(oppId, dq.Offering_Type__c);
                if(listOfSelectUseCases.isEmpty())
                    dq.Smart_Use_Case__c = false;
                else
                    dq.Smart_Use_Case__c = true;                
            }
            else{
                dq = dqs[0]; 
                System.debug('NKC debug dq.id ['+dq.id+']');
                dq.Contractual_Rate__c = opp.Direct_Sales__c ? opp.Account.FYM_Rate__c : opp.BusinessPartner__r.FYM_Rate__c;
                dq.Competitor__c = opp.Competitor__c;                             
                dealQualProducts = [SELECT Name, 
                    Discount__c, Product__c, Quantity__c, Product__r.Name, Product__r.Description__c, Product__r.Type__c, Product__r.Third_Party__c,
                    Product__r.Product_Specific_Discount__c, Approval_Reason__c FROM Deal_Qualification_Products__c WHERE Deal_Qualification__c =: dq.id];
                if(!dealQualProducts.isEmpty())
                    showProducts = true;
                    
                genesysCare = dq.Genesys_Care__c;
                sellingNONGAFutureMap = dq.Are_you_selling_Non_GA_Future_Roadmap__c;
                professionalServices = dq.Do_you_require_Professional_Services__c;
                //Read Only
                if(dq.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_PENDING ||
                    dq.Status__c == DealQualificationApprovalUtil.STATUS_APPROVED){
                    isReadOnly = true;
                    showReviseButton = true;
                }                   
            }        
            if(opp.Direct_Indirect_Sale__c == 'Indirect' && (!opp.BusinessPartner__r.SMART_Qualified__c || !opp.BusinessPartner__r.Subscription_Qualified__c))
                dq.Subscription_Smart_Qualified_Approval__c = true;                
            else
                dq.Subscription_Smart_Qualified_Approval__c = false;    
            if(dq.Pricing_Type__c == 'Old Pricing')
                dq.IsOldPricingApproved__c = true;
            if(dqId == null)
                dqId = dq.id;
            genesysCareOnChange();
            sellingGAFRoadMapChange();
            professionalServicesChange();
            
            if(ApexPages.currentPage().getParameters().get('msg') != null && ApexPages.currentPage().getParameters().get('msg') == 'DQ_NOT_APPROVED'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Deal Qualification approval is needed to create a Pricing Estimator/Quote.'));
            }
            
        }
        List<Opportunity> psOpps = [SELECT id, Name, ProjectType__c, OwnerId, Owner.Name, PS_Amount_On_Premise__c, Sold_Margin_PPW__c,
            CurrencyISOcode, StageName, ForecastStatus__c FROM Opportunity 
            WHERE ParentOpportunity__c =: oppId AND RecordType.DeveloperName = 'Professional_Services' 
            ORDER BY CreatedDate DESC];
        System.debug('NKC debug oppId [' + oppId + ']');
        if(!psOpps.isEmpty()){
            psOpp = psOpps[0];
        }
        listOfPureSuccessOffers = new List<SelectOption>();
        if(opp.Direct_Indirect_Sale__c == 'Direct'){            
            listOfPureSuccessOffers.add(new SelectOption('Equip', 'Equip'));
            listOfPureSuccessOffers.add(new SelectOption('Guide', 'Guide'));
            listOfPureSuccessOffers.add(new SelectOption('Drive', 'Drive'));
            if(opp.Type != 'New logo')
                listOfPureSuccessOffers.add(new SelectOption('Business Care', 'Business Care'));
        }
        else{
            listOfPureSuccessOffers.add(new SelectOption('Partner', 'Partner'));
            if(opp.Type != 'New logo')
                listOfPureSuccessOffers.add(new SelectOption('Business Care', 'Business Care'));
        }
        populateQuotes(oppId);
        blnIsDealFactoryUser = false;
        Map<Id, Group> mapIdVsGroup = new Map<Id, Group> ([SELECT id FROM Group WHERE Name IN : Label.Deal_Factory_Queue_Names.split(',')]);
        List<GroupMember> groupMemberRecord = [SELECT id, UserOrGroupId FROM GroupMember WHERE GroupId =: mapIdVsGroup.keyset()];
        for(GroupMember eachMember : groupMemberRecord){
            if(eachMember.UserOrGroupId == Userinfo.getUserId()){
                blnIsDealFactoryUser = true;
                break;  
            }
        }
        
		//Mukunth added below code for INC0416843 - DQ Special Offers Sub-aprpovers
		checkSpecOfferApprPending();
    }
    
    
    public void initDiscount(){
        dq.New_Pricing_Discount__c = 'No Discount';        
    }
    
    public PageReference revise(){
        //if(dq.Status__c != DealQualificationApprovalUtil.QUOTE_STATUS_APPROVED){
        //  Deal_Qualification__c = 
        //}
        dq.Status__c = DealQualificationApprovalUtil.STATUS_REVISION_PENDING;
        update dq;  
        DealQualificationAppAssignmentHelper.cancelDQApprovalsOnRevise(dq.id);
        return getPageRef();
    }
    
    public PageReference reviseOnLoad(){  
        System.debug('NKC debug reviseOnLoad ==');
        // redirects to respective DQ page
        if(ApexPages.currentPage().getParameters().get('NO_REDIRECT') == null 
            && ApexPages.currentPage().getParameters().get('id') != null){
           System.debug('NKC debug reviseOnLoad ==');     
           String pageName = DealQualificationApprovalUtil.getRespectiveDQPageName(dq.Platform_Type__c, dq.Offering_Type__c);
          if(dq.Offering_Type__c != null){                          
              PageReference pRef = new PageReference('/apex/' + pageName  + '?id=' + dq.id + '&p=' + dq.Pricing_Type__c + '&NO_REDIRECT=true');
              pRef.setRedirect(true);
              return pRef; 
          }
          if(dq.Type__c == DealQualificationApprovalUtil.DQ_RECORD_HISTORY){
              PageReference pRef = new PageReference('/apex/' + pageName + '?oppId=' + dq.Opportunity__c + '&p=' + dq.Pricing_Type__c + '&NO_REDIRECT=true');
              pRef.setRedirect(true);
              return pRef; 
          }    
      }
      // revises the DQ
      if(ApexPages.currentPage().getParameters().get('REVISE') != null){
          dq.Status__c = DealQualificationApprovalUtil.STATUS_REVISION_PENDING;          
          update dq;           
          DealQualificationAppAssignmentHelper.cancelDQApprovalsOnRevise(dq.id);
          if(dq.Platform_Type__c != 'Cloud')
            DealQualificationAndQuoteApprovalHelper.resetApprovalsIfNeeded(dq, dq.Pricing_Type__c);
          return getPageRef();
      }
      
      return null;
    }
    
    
    public void genesysCareOnChange(){
        System.debug('NKC debug genesysCare ['+genesysCare+']');
        if(genesysCare == DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD
          || genesysCare == DealQualificationApprovalUtil.GENESYS_CARE_CONTRACTUAL_RATE){
            showGenesysCareFields = true;
        }
        else{
            showGenesysCareFields = false;
            dq.Override_2__c = false;
            dq.Override_by_2__c = false;
            dq.Term_Decrease__c = false;
            dq.Term_Increase__c = false;
            dq.Decline__c = false;
            dq.Require_Separate_Quote_for_Genesys_Care__c = false;  
        }        
    }
    
    public void sellingGAFRoadMapChange(){
        if(sellingNONGAFutureMap == 'Yes')
            showSellingNONGAFutureMap = true;
        else
            showSellingNONGAFutureMap = false;
    }
    
    public void professionalServicesChange(){
        if(professionalServices == 'Yes')
            showProfessionalServices = true;
        else
            showProfessionalServices = false;   
    }
    
    public PageReference save(){      
      if((dq.Justification_for_Discount__c == null && dq.Pricing_Type__c == DealQualificationApprovalUtil.NEW_PRICING 
        && DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c) >= DealQualificationApprovalUtil.NEW_PRICING_LEVEL2_THRESHOLD)
        || (dq.Justification_for_Discount__c == null && dq.Pricing_Type__c == DealQualificationApprovalUtil.OLD_PRICING 
        && DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c) >= DealQualificationApprovalUtil.OLD_PRICING_LEVEL2_THRESHOLD)){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide justification for discount given.'));
            return null;
      }
      /*
      if(dq.Genesys_Care__c == DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD && dq.GC_Override__c == null
        && !dq.Term_Decrease__c && !dq.Term_Increase__c
        && !dq.Decline__c && !dq.Premium_Care__c && !dq.Require_Separate_Quote_for_Genesys_Care__c){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select atleast a non-standard field.'));
          return null;  
      }
           */
      if(!isReadOnly && dq.Opportunity__r.BusinessPartner__c != null && dq.Partner__c == null){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter partner information.'));
          return null;
      }
      if(dq.Genesys_Care__c != DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD){
        dq.GC_Override__c = null;        
        dq.Decline__c = false;        
        dq.Require_Separate_Quote_for_Genesys_Care__c = false;
        if(dq.Genesys_Care__c == DealQualificationApprovalUtil.GENESYS_CARE_STANDARD){
          dq.Term_Decrease__c = false;
          dq.Term_Increase__c = false;
          dq.Premium_Care__c = false;
        }
      }
      if(dq.Compliance_of_the_Request_with_Value_Pri__c != null){
        if(dq.Compliance_of_the_Request_with_Value_Pri__c.contains('Green'))
          dq.Deal_Factory_Recommendation_Status__c = '33CC33';
        else if(dq.Compliance_of_the_Request_with_Value_Pri__c.contains('Yellow'))
          dq.Deal_Factory_Recommendation_Status__c = 'FFFF00';
        else
          dq.Deal_Factory_Recommendation_Status__c = 'FF0000';
      }
      //Updates competitor on Opportunity
      if(dq.Competitor__c != null && opp.Competitor__c != dq.Competitor__c){
        opp.Competitor__c = dq.Competitor__c;
        update opp;
      }
      
      //Updating other and uptick fields
      List<BigMachines__Quote__c> listOfQuotesToBeUpdated = [SELECT id, Name, Revision_No__c, BigMachines__Status__c, BigMachines__Total__c, BigMachines__Is_Primary__c, CreatedDate, 
        Special_Offer_Terms__c, Overage_Allowance_Other__c, Annual_Price_Escalation_Other__c, Payment_Terms_Price_Uptick__c, Overage_Allowance_Price_Uptick__c
        FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: oppId AND Offering_Type__c =: dq.Offering_Type__c];
        
      for(BigMachines__Quote__c eachQuote : listOfQuotesToBeUpdated){
        //Updating Other and Price Upticks values to primary quote
        eachQuote.Overage_Allowance_Other__c = dq.Overage_Allowance_Other__c;
        eachQuote.Annual_Price_Escalation_Other__c = dq.Annual_Price_Escalation_Other__c;
        eachQuote.Payment_Terms_Price_Uptick__c = dq.Payment_Terms_Price_Uptick__c;
        eachQuote.Overage_Allowance_Price_Uptick__c = dq.Burst_Allowance_Price_Uptick__c;        
      }
      util.Bypass_Trigger_Chk = true;
      //update listOfQuotesToBeUpdated;
      util.Bypass_Trigger_Chk = false;
      if(dq.id == null){
          dq.currencyIsoCode = opp.currencyIsoCode;
            insert dq;
            return getPageRef();
        }
        else{
            update dq;
        }
        
        
        return null;
    }
    
    public pageReference deleteDQProduct(){
        System.debug('NKC debug dqProductIdToBeDeleted ['+dqProductIdToBeDeleted+']');
        Deal_Qualification_Products__c dqProduct = new Deal_Qualification_Products__c(id = dqProductIdToBeDeleted);
        delete dqProduct;
        return getPageRef();
    }
    
    private pageReference getPageRef(){      
        String pageName = dq.DQ_Page_Name__c;
        if(pageName == null)
            pageName = DealQualificationApprovalUtil.getRespectiveDQPageName(dq.Platform_Type__c, dq.Offering_Type__c);
        PageReference pRef = new PageReference('/apex/'+ pageName +'?id=' + dq.id + '&oppId='+oppId+'&p='+dq.Pricing_Type__c);
        pRef.setRedirect(true);
        return pRef;     
    }
    
    private void populateQuotes(String oppId){
        quotes = [SELECT id, Name, Revision_No__c, BigMachines__Status__c, BigMachines__Total__c, BigMachines__Is_Primary__c, CreatedDate, Special_Offer_Terms__c,
        Total_Discount_Genesys_Products_Only__c, Total_List_Price__c  
        FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: oppId ORDER BY CreatedDate DESC];
        quote = new BigMachines__Quote__c();
        BigMachines__Quote__c primaryQuote;
        for(BigMachines__Quote__c eachQuote : quotes){
            if(eachQuote.BigMachines__Is_Primary__c){
                primaryQuote = eachQuote;                
            }
            if(dq.Quote__c == eachQuote.id){
                quote = eachQuote;        
                break;
            }
        }  
        if(quote.id == null)
            quote = primaryQuote;
    }
    
    public void refresh(){
        
    }
    
    public pageReference submitForApproval(){
      String dqId = dq.id;
      if((dq.Justification_for_Discount__c == null && dq.Pricing_Type__c == DealQualificationApprovalUtil.NEW_PRICING 
        && DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c) >= DealQualificationApprovalUtil.NEW_PRICING_LEVEL2_THRESHOLD)
        || (dq.Justification_for_Discount__c == null && dq.Pricing_Type__c == DealQualificationApprovalUtil.OLD_PRICING 
        && DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c) >= DealQualificationApprovalUtil.OLD_PRICING_LEVEL2_THRESHOLD)){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide justification for discount given.'));
            return null;
      }
      /*
      if(dq.Genesys_Care__c == DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD && dq.GC_Override__c == null
        && !dq.Term_Decrease__c && !dq.Term_Increase__c
        && !dq.Decline__c && !dq.Premium_Care__c && !dq.Require_Separate_Quote_for_Genesys_Care__c){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select atleast a non-standard field.'));
              return null;  
      }
      */
      if(!isReadOnly && dq.Opportunity__r.BusinessPartner__c != null && dq.Partner__c == null){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter partner information.'));
          return null;
      }
      
      save();
      if(dqId == null)
        dq = DealQualificationApprovalUtil.getDQFromId(dq.id); 
           
        
        String strResult = DealQualificationApprovalAssignment.submitDQToApproval(dq);
        if(strResult != 'OK'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strResult));
            return null;
        }                       
        else{
            return getPageRef();
        }
    }
    
    //Mukunth added below code for INC0416843 - DQ Special Offers Sub-aprpovers
    public void requestSpecOfferSubApproval(){

        checkSpecApprovalReadOnly();

        DealQualificationApprovalUtil.sendSpecOfferSubApprEmails(dq,finToAddresses,string.valueof(opp.Region_Non_CSM__c),sentRevEmail,sentOMEmail,sentCCEmail,sentLegalEmail);
        
        if(dq.Req_Revenue_Approval__c){
            sentRevEmail = true;
        }
        if(dq.Req_Order_Mgmt_Billing_approval__c){
            sentOMEmail = true;
        }
        if(dq.Req_Credit_Collections_approval__c){
            sentCCEmail = true;
        }
        if(dq.Req_Legal_approval__c){
            sentLegalEmail = true;
        }
            
        update dq;
    }
	
	public void checkSpecApprovalReadOnly(){
		if(dq.Status__c == 'Approved')
			showDQSpecApprReadOnly = true;
			
        if(dq.Req_Revenue_Approval__c && (finToAddresses.get('Revenue_'+opp.Region_Non_CSM__c)).contains(UserInfo.getUserEmail())){
            isRevSubApprover = true;
        }
        if(dq.Req_Order_Mgmt_Billing_approval__c && (finToAddresses.get('OrderMgmt_'+opp.Region_Non_CSM__c)).contains(UserInfo.getUserEmail())){
            isOMBSubApprover = true;
        }
        if(dq.Req_Credit_Collections_approval__c && (finToAddresses.get('CreditCollect_'+opp.Region_Non_CSM__c)).contains(UserInfo.getUserEmail())){
            isCCSubApprover = true;
        }
        if(dq.Req_Legal_approval__c && (finToAddresses.get('Legal_'+opp.Region_Non_CSM__c)).contains(UserInfo.getUserEmail())){
            isLegalSubApprover = true;
        }

	}
	
	public void checkSpecOfferApprPending(){
 
        dqSpecOffrWrppr = DealQualificationApprovalUtil.checkSpecOfferApprPending(dq);
        System.Debug('dqSpecOffrWrppr--->'+dqSpecOffrWrppr);
        System.Debug('finToAddresses--->'+dqSpecOffrWrppr.finToAddresses);
        System.Debug('isSpecApprOfferPending--->'+dqSpecOffrWrppr.isSpecApprOfferPending);
        
        isSpecApprOfferPending = dqSpecOffrWrppr.isSpecApprOfferPending;
        finToAddresses = dqSpecOffrWrppr.finToAddresses;
        isSubApprover = dqSpecOffrWrppr.isSubApprover;
        
	    checkSpecApprovalReadOnly();
	}
	
	public void saveFinanceApproval(){
	    update dq;
	}
	
	public void unlockSubApprSection(){
	    
	    System.Debug('finFunc--->'+unlockFinFn);
	    
	    if(unlockFinFn == 'revenue'){
	        dq.Req_Revenue_Approval__c = false;
	        dq.Revenue_approval__c = null;
	        dq.Revenue_Comments__c = null;
	    }
	    else if(unlockFinFn == 'orderMgmt'){
            dq.Req_Order_Mgmt_Billing_approval__c = false;
            dq.Order_Mgmt_Billing_approval__c = null;
            dq.Order_Management_Billing_Comments__c = null;

	    }
	    else if(unlockFinFn == 'creditCol'){
	        dq.Req_Credit_Collections_approval__c = false;
	        dq.Credit_and_Collections_approval__c = null;
	        dq.Credit_Collections_Comments__c = null;
	    }
	    else if(unlockFinFn == 'legal'){
	        dq.Req_Legal_approval__c = false;
	        dq.Legal_approval__c = null;
	        dq.Legal_Comments__c = null;
	    }
	    
	    update dq;
	}
	
    //Mukunth code end - DQ Special Offers
    
}