public without sharing class DealQualificationCloudController 
{  
    // Current DQ record
    public Deal_Qualification__c objDQ {get; set;}
    // Primary/Main BE Cloud Quote Info being shown on UI
    public BigMachines__Quote__c objQuote {get; set;}
    // Zuora Quote Object
    public zqu__Quote__c zQuote {get; set;}
    // Opportunity related to DQ
    public Opportunity objOppty {get; private set;}
    // Child PS Opportunity related to Main Opportunity
    public Opportunity objChildPSOppty {get; private set;}
    
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
    
    //Opportunity Id
    public String oppId {get; set;}
    // Deal Qualification Id
    public String dqId {get; set;}
    // Zuora quote id 
    private String strZuoraQuoteId;
    // Whether to trigger special offer approval or not
    private Boolean blnIsSpecialOffer;
    // To indicate whether DQ is in Read Only Mode
    public Boolean blnIsReadOnly {get; private set;}
    // To indicate whether current user is a Deal Factory User
    public Boolean blnIsDealFactoryUser {get; private set;}
    // To indicate if DQ functionality should be hidden if a BE/PureEngage quote does not exist fo rthe Opportunity
    public Boolean blnHideDQ {get; private set;}
    // To store offering type of the DQ coming as a parameter
    public String strOfferingType {get; private set;}
    // To store platform type of the DQ coming as a parameter
    public String strPlatformType {get; private set;}
    // To display offering type on page
    public String strOfferingTypeToDisplay {get; private set;}
    // Pricing Type (New/Old) : Not relevant to Cloud
    String pricingType;
    // Zuora Quote Map
    private Map<Id, zqu__Quote__c> zQuoteMap;
    public Id zQuoteId { get; set; }
    private final Static String PURECLOUD_MRR_EXCEPTION = 'MRR less than 2K USD';
    private String strDiscount {get; private set;}
    //Anju June 2018
    public Boolean blnIsFinanceUser {get; private set;}

    public Map<String, Decimal> isoToExchangeRate
    {
        get
        {
            if(isoToExchangeRate == null)
            {
                isoToExchangeRate = new Map<String, Decimal>();
                for(CurrencyType c : [SELECT IsoCode, ConversionRate FROM CurrencyType WHERE IsActive = True])
                {
                    isoToExchangeRate.put(c.IsoCode, c.ConversionRate);
                }
            }
            return isoToExchangeRate;
        }
        private set;
    }
    
    // *** Constructor ***
    public DealQualificationCloudController(ApexPages.StandardController stdCtrl) 
    {
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        dqId = ApexPages.currentPage().getParameters().get('id');
        strOfferingType = ApexPages.currentPage().getParameters().get('ot');
        strPlatformType = ApexPages.currentPage().getParameters().get('pt');    
        strDiscount = ApexPages.currentPage().getParameters().get('disc'); 
        strZuoraQuoteId = ApexPages.currentPage().getParameters().get('zQuote'); 
        blnIsSpecialOffer = false;
        blnIsSpecialOffer = (ApexPages.currentPage().getParameters().get('specialOffer') == 'true' ? true : false);
        initializeData();
    }
    
    //*** Method to initialize data for the page ***
    public void initializeData() 
    {
        // Initializing Flags
        blnIsReadOnly = blnHideDQ = false;
        
        //Mukunth added below line for INC0416843 - DQ Special Offers Sub-aprpovers
        showDQSpecApprReadOnly = isSpecApprOfferPending = false;
        isRevSubApprover = isOMBSubApprover = isCCSubApprover = isLegalSubApprover = false;
        sentRevEmail = sentOMEmail = sentCCEmail = sentLegalEmail = isSubApprover = false;
        finToAddresses = new map<string,list<string>>();
        dqSpecOffrWrppr = new DealQualificationApprovalUtil.DQSpecOfferSubApprWrapper();
        sendMailStatus = new map<string,boolean>();
        //Mukunth code end
        
        pricingType = DealQualificationApprovalUtil.NEW_PRICING;
        
        // Getting DQ information
        // Is this duplicated by DealQualificationApprovalUtil.getDQ? - JLH
        // Naresh: We need below part for few things, please keep it here. It's not duplicate, we need it to get oppId and offering type before we query the opportuinty.
        if(dqId != null)
        {
            List <Deal_Qualification__c > dq = [SELECT Opportunity__c, Offering_Type__c FROM Deal_Qualification__c WHERE id = :dqId];
            if(!dq.isEmpty())
            {
                oppId = dq[0].Opportunity__c;
                strOfferingType = dq[0].Offering_Type__c;
            }
        }
        //if patameter null, make offering type as Business Edition
        if(strOfferingType == 'Business Edition')
        {
            strOfferingTypeToDisplay = 'PureEngage';
        }
        else if(strOfferingType == QuoteUtil.OFFERING_TYPE_CAAS)
        {
            strOfferingTypeToDisplay = 'PureConnect';
        }
        else
        {
            strOfferingTypeToDisplay = strOfferingType;
        }
        System.Debug('oppId--->'+oppId);
        // Getting Opportunity Information (also fetching Child PS Opportunity info and POR Deal Support records)
        objOppty = [SELECT Id, Name, AccountId, BusinessPartner__c, Owner.Name, Owner.Segment__c, Country_Region__c, Country_Sub_Region__c, Primary_Solution__c,
            Region_Non_CSM__c,//Mukunth added for DQ SOSA
            StageName, Offering_Detail__c, CurrencyIsoCode, Sold_To_Country__c, Total_Annual_Contract_Value__c, Actual_CMRR__c, Annual_Contract_Value__c, Term_Commitment__c,
            Lines_of_Businesses__c, Quote_Category__c,Type,Competitor__c, Direct_Indirect_Sale__c, ACV_Subscription_Only__c ,
            (SELECT Name, OwnerId, PS_Amount_On_Premise__c, ProjectType__c, Sold_Margin_PPW__c, CurrencyISOCode FROM Opportunities__r WHERE RecordType.Name = 'Professional Services'
                ORDER BY CreatedDate DESC LIMIT 1),
            (SELECT Id, Request_Type__c, POR_Type__c, SC_Engagement_Form__c, Key_Team_Members__c, Date_Time_Completed__c,
                POR_Lead__c, POR_Schedule_Date__c, POR_Disposition__c, CreatedDate, Name, CTO_Comments__c  
                FROM Deal_Support__r WHERE Support_Area__c = 'POR Review' ORDER BY CreatedDate DESC),
            (SELECT Id, Name, BigMachines__Status__c, BigMachines__Is_Primary__c, CreatedDate, Annual_Contract_Value__c, Total_Contract_Value__c, 
                Initial_Subscription_Term__c, No_Of_Months__c, Discount__c, Include_Special_Offer_in_Output__c, Special_Offer_Terms__c, Editable_List_Price_Approval_Required__c
                FROM BigMachines__BigMachines_Quotes__r WHERE Quote_Business_Type__c = 'Cloud' AND Offering_Type__c =: strOfferingType 
                ORDER BY BigMachines__Is_Primary__c DESC, CreatedDate DESC),
            (SELECT Id, Name, Approval_Status__c, zqu__Currency__c, zqu__Previewed_MRR__c, zqu__InitialTerm__c, zqu__Previewed_Discount__c, zqu__Primary__c, 
                zqu__Previewed_Total__c, zqu__InitialTermPeriodType__c, zqu__Previewed_TCV__c, CreatedDate, zqu__ApprovalStatus__c
                FROM zqu__Quotes__r)
            FROM Opportunity WHERE id =: oppId];
        System.debug('NKC debug oppId [' + oppId + ']');
        System.debug('NKC debug pricingType [' + pricingType + ']');
        System.debug('NKC debug strOfferingType [' + strOfferingType + ']');

        zQuoteMap = new Map<Id, zqu__Quote__c>(objOppty.zqu__Quotes__r);
        
        // TODO: Get actual DQ record when there is a DQ ID.  Right now the first one from the list is assigned which may not match the ID that is passed to the controller.
        List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(oppId, pricingType, 'Cloud', strOfferingType, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL, dqId);
        // Deal Qualification already exists
        if(!dqs.isEmpty())
        {
            dqId = dqs[0].id;
            objDQ = dqs[0];
            strOfferingType = objDQ.Offering_Type__c;
            
        }
        // Initializing new DQ if it does not already exist
        else
        {
            objDQ = new Deal_Qualification__c(Offering_Type__c = strOfferingType, Platform_Type__c = 'Cloud',
                Status__c = 'In Progress', Genesys_Care__c = 'Included with PureEngage',CurrencyIsoCode = objOppty.CurrencyIsoCode,
                Opportunity__c = objOppty.id);
        }
        //Populating Discount from PureCloud Quote if any
        if(strDiscount != null && strDiscount != '' 
           && (objDQ.Discount_On_Quote__c == null || Decimal.valueOf(strDiscount) > objDQ.Discount_On_Quote__c)){
            objDQ.Discount_On_Quote__c = Decimal.valueOf(strDiscount);
        }
        
        //PC Trial
        if(strOfferingType == 'PureCloud'){
            if(objOppty.Offering_Detail__c != null && objOppty.Offering_Detail__c.contains('Pilot/Trial/POC'))
                objDQ.PureCloud_Trial__c = true;
            else
                objDQ.PureCloud_Trial__c = false;
        
        } 
        
        //DQ is in Read Only mode
        if(objDQ.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_PENDING || objDQ.Status__c == DealQualificationApprovalUtil.STATUS_APPROVED)
            blnIsReadOnly = true;
        if(blnIsSpecialOffer)
            objDQ.Special_Offer_Terms__c = true;
        // If there is no existing BE Cloud quote then show error that BE Cloud DQ cannot be created
        if(strOfferingType == 'Business Edition')
        {
            if(objOppty.BigMachines__BigMachines_Quotes__r.isEmpty())
            {
                blnHideDQ = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'A PureEngage Cloud quote is needed to initiate Deal Qualification for PureEngage Cloud.'));
                return;
            }
            // Populate info from quote only if DQ is not created yet and user is coming form opporutnity.
            else if(objDQ.id == null)
            {
                // Main Quote to show info on DQ page
                objQuote = objOppty.BigMachines__BigMachines_Quotes__r[0];
                
                if(String.isNotBlank(objQuote.Initial_Subscription_Term__c) && objQuote.Initial_Subscription_Term__c.containsIgnoreCase(' Year'))
                {
                    objQuote.No_Of_Months__c = Integer.ValueOf(objQuote.Initial_Subscription_Term__c.substringBefore(' Year')) * 12;
                    objDQ.Initial_Subscription_Term_Months__c = objQuote.No_Of_Months__c;
                }
                /* Existing BE Cloud Quote Discount info is prepopulated on DQ if a DQ record hasn't been created yet. Flags populated as long as DQ is editable.
                   Approvals Driven by (Discount value/Special Offer flag/Editable List Price Flag)*/
                if(!blnIsReadOnly)
                {
                    if(objQuote.Discount__c != null && (objDQ.Id == null || objDQ.Discount_On_Quote__c == null || objDQ.Discount_On_Quote__c == 0))
                        objDQ.Discount_On_Quote__c = objQuote.Discount__c.round();
                    
                    objDQ.Special_Offer_Terms__c = objQuote.Include_Special_Offer_in_Output__c;
                    objDQ.Special_Offers_Business_Exceptions__c = objQuote.Special_Offer_Terms__c;
                    objDQ.Editable_List_Price_Approval_Required__c = objQuote.Editable_List_Price_Approval_Required__c; 
                }
            }
        }
        else if(strOfferingType == QuoteUtil.OFFERING_TYPE_CAAS && !objOppty.BigMachines__BigMachines_Quotes__r.isEmpty())
        {
            // Main Quote to show info on DQ page
            objQuote = objOppty.BigMachines__BigMachines_Quotes__r[0];                
            if(objQuote.No_Of_Months__c != null)
            {
                objDQ.Initial_Subscription_Term_Months__c = objQuote.No_Of_Months__c;
            }
        }
        /*
        else if(strOfferingType == 'PureCloud' && objOppty.zqu__Quotes__r.isEmpty())
        {
            blnHideDQ = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'A PureCloud quote is needed to initiate Deal Qualification for PureCloud.'));
            return;            
        }
        */
        // Setting Child PS Opportunity Property object
        if(!objOppty.Opportunities__r.isEmpty())
            objChildPSOppty = objOppty.Opportunities__r[0];

        // Check whether running user is a Deal Factory User
        checkDealFactoryUser();
        checkFinanceUser();
        
        //Mukunth added below code for INC0416843 - DQ Special Offers Sub-aprpovers
        checkSpecOfferApprPending();
    
    }
    
    //*** Method to check whether current user is a Deal Factory User ***
    private void checkDealFactoryUser() 
    {
        blnIsDealFactoryUser = [SELECT COUNT() FROM GroupMember WHERE Group.Name IN: Label.Deal_Factory_Queue_Names.split(',') 
                                    AND UserOrGroupId = :UserInfo.getUserId() LIMIT 1] > 0 ? true : false;
    }
    
    //*** Method to check whether current user is a Finance User ***
    private void checkFinanceUser() 
    {
        blnIsFinanceUser = [SELECT COUNT() FROM GroupMember WHERE Group.Name like '%Finance%' 
                                    AND UserOrGroupId = :UserInfo.getUserId() LIMIT 1] > 0 ? true : false;
    }
    
    //*** Method to refresh the page ***
    public void overageToggleHandler(){}
    public void refresh(){}
    //*** Method fired on change of 'Is Telco Included' dropdown to blank out other values is Telco is not included ***
    public void telcoIncludedToggleHandler() 
    {
        if(objDQ.Is_Telco_Included__c == 'No') 
        {
            objDQ.Is_Telco_Quoted_At_Standard_Rates__c = objDQ.Is_MPLS_included__c = objDQ.Has_MPLS_been_approved__c = 
            objDQ.Has_MPLS_questionnaire_been_submitted__c = objDQ.Is_Inbound_Voice_included__c = objDQ.Data_Center_Region__c = null;
        }
    }
    
    //*** Handler/Method for Revise functionality ***
    public PageReference revise() 
    {
        objDQ.Status__c = DealQualificationApprovalUtil.STATUS_REVISION_PENDING;
        update objDQ;
        DealQualificationAppAssignmentHelper.cancelDQApprovalsOnRevise(objDQ.id);
        return getPageRef();
    }
    
    //*** Method called on page load to revise a DQ on Load if needed (for example if quote discount is greater than approved ranges) ***
    public PageReference reviseOnLoad(){  
        System.debug('NKC debug reviseOnLoad ==');
        // redirects to respective DQ page
        if(ApexPages.currentPage().getParameters().get('NO_REDIRECT') == null 
            && ApexPages.currentPage().getParameters().get('id') != null){
           System.debug('NKC debug reviseOnLoad ==');     
           String pageName = DealQualificationApprovalUtil.getRespectiveDQPageName(objDQ.Platform_Type__c, objDQ.Offering_Type__c);
          if(objDQ.Offering_Type__c != null){                          
              PageReference pRef = new PageReference('/apex/' + pageName  + '?id=' + objDQ.id + '&p=' + objDQ.Pricing_Type__c + '&NO_REDIRECT=true');
              pRef.setRedirect(true);
              return pRef; 
          }
          if(objDQ.Type__c == DealQualificationApprovalUtil.DQ_RECORD_HISTORY){
              PageReference pRef = new PageReference('/apex/' + pageName + '?oppId=' + objDQ.Opportunity__c + '&p=' + objDQ.Pricing_Type__c + '&NO_REDIRECT=true');
              pRef.setRedirect(true);
              return pRef; 
          }    
      }
      // revises the DQ
      if(ApexPages.currentPage().getParameters().get('REVISE') != null){
          objDQ.Status__c = DealQualificationApprovalUtil.STATUS_REVISION_PENDING;          
          update objDQ; 
          DealQualificationAppAssignmentHelper.cancelDQApprovalsOnRevise(objDQ.id);
          //Naresh Kumar    06/18/2017  Disabling approval reset for cloud offerings.
          //DealQualificationAndQuoteApprovalHelper.resetApprovalsIfNeeded(objDQ, objDQ.Pricing_Type__c);
          return getPageRef();
      }
      
      return null;
    }
    
    //*** Handler/Method for Save functionality ***
    public PageReference save() 
    {
        if(checkValidationRules())
            return null;
        
        //Updates Competitor on Opportunity
        if(objDQ.Competitor__c != null && objOppty.Competitor__c != objDQ.Competitor__c) 
        {
            objOppty.Competitor__c = objDQ.Competitor__c;
            update objOppty;
        }
        
        if(objDQ.Discount_On_Quote__c != null && objDQ.Discount_On_Quote__c > 0)
            objDQ.New_Pricing_Discount__c = '< ' + objDQ.Discount_On_Quote__c + '%';
        else
            objDQ.New_Pricing_Discount__c = 'No Discount';
            
        //DQ Changes Sep 2017 - Anju starts
        /*Update DQ with finance approval check based on new fields like Payment terms, Comments etc
        if(objDQ.Offering_Type__c == 'PureCloud'){
            //if payment terms beyond 30, finance approval requited
            objDQ.Special_Offer_Terms__c = False;
            
            if(blnIsSpecialOffer || (objDQ.Payment_Terms__c != null && Integer.valueof(objDQ.Payment_Terms__c.right(2)) > 30) || objDQ.Other_Non_Standard_Finance_Exceptions__c != null)
                objDQ.Special_Offer_Terms__c = True;
            
        }
        */
        //DQ Changes Sep 2017 - Anju ends
        
        
        if(objDQ.id == null) 
        {
            if(strZuoraQuoteId != null)
                objDQ.ZQuote__c = strZuoraQuoteId;
            if(blnIsSpecialOffer)
                objDQ.Special_Offer_Terms__c = true;
            insert objDQ;
            return getPageRef();
        } 
        else
            update objDQ;
        
        return null;
    }
    
    //*** Method to get the Page Reference/URL for Cloud DQ ***
    private pageReference getPageRef() 
    {
        PageReference pRef = new PageReference('/apex/DealQualificationCloud?id=' + objDQ.id + '&oppId=' + oppId + '&p=' + objDQ.Pricing_Type__c);
        pRef.setRedirect(true);
        return pRef;
    }
    
    //*** Handler/Method for Submitting DQ for Approval functionality ***
    public pageReference submitForApproval() 
    {
        if(checkValidationRules())
            return null;
        
        String dqId = objDQ.id;
        save();
        
        if(dqId == null)
            objDQ = DealQualificationApprovalUtil.getDQFromId(objDQ.id);
  
        String strResult = DealQualificationApprovalAssignment.submitDQToApproval(objDQ);
        if(strResult != 'OK') 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strResult));
            return null;
        }
        
        return getPageRef();
    }
    
    // *** To check whether all validations are met ***
    Boolean checkValidationRules()
    {
        Boolean blnHasValidationError = false;
        
        // Justification for Discount is required if any Discount is provided
        if(objDQ.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CAAS && String.isBlank(objDQ.Justification_for_Discount__c) 
           && ((objDQ.Business_Users_Add_On__c != null && objDQ.Business_Users_Add_On__c > 0)
               || (objDQ.Base_Agent_Discount__c != null && objDQ.Base_Agent_Discount__c > 0)
               || (objDQ.Business_Users_Provisioning_Discount__c != null && objDQ.Business_Users_Provisioning_Discount__c > 0)
               || (objDQ.Data_Center_Provisioning_Discount__c != null && objDQ.Data_Center_Provisioning_Discount__c > 0)
               || (objDQ.Hardware_Discount__c != null && objDQ.Hardware_Discount__c > 0)))
        {
            objDQ.Justification_for_Discount__c.addError('Required as discount has been given !');
            blnHasValidationError = true;
        }        
        
        // Justification for Discount is required if any Discount is provided
        if((objDQ.Offering_Type__c == 'PureCloud' || objDQ.Offering_Type__c == 'Business Edition') && String.isBlank(objDQ.Justification_for_Discount__c) && objDQ.Discount_On_Quote__c != null && objDQ.Discount_On_Quote__c > 0)  
        {
            objDQ.Justification_for_Discount__c.addError('Required as discount has been given !');
            blnHasValidationError = true;
        }
        
        // Explanation needed if Telco Pricing is not standard
        if(String.isBlank(objDQ.Explanation_for_Telco_Pricing__c) && objDQ.Is_Telco_Quoted_At_Standard_Rates__c == 'No')  
        {
            objDQ.Explanation_for_Telco_Pricing__c.addError('Explanation needed for non standard Telco Pricing !');
            blnHasValidationError = true;
        }
        
        //Explanation needed If there is overage
        if(objDQ.Any_Overage_over_20_for_any_month__c && String.isBlank(objDQ.Explanation_for_Overage__c))
        {
            objDQ.Explanation_for_Overage__c.addError('Explanation required for overages !');
        }
        
        // Partner is required on DQ if Business Partner is specified on related Opportunity
        if(!blnIsReadOnly && objDQ.Opportunity__r.BusinessPartner__c != null && objDQ.Partner__c == null) 
        {
            objDQ.Partner__c.addError('Required !');
            blnHasValidationError = true;
        }
        
        //Other values for Ramp period and Initial terms
        if(!blnIsReadOnly && objDQ.Initial_Subscription_Term_Months_PC__c == 'Other' && objDQ.If_Other_Term_Months_Requested__c == null) 
        {
            objDQ.If_Other_Term_Months_Requested__c.addError('Required !');
            blnHasValidationError = true;
        }
        
        if(!blnIsReadOnly && objDQ.If_Other_Ramp_Period_Requested_Days__c == null && objDQ.Ramp_Period_Days__c == 'Other') 
        {
            objDQ.If_Other_Ramp_Period_Requested_Days__c.addError('Required !');
            blnHasValidationError = true;
        }
        
        if(!blnIsReadOnly && objDQ.If_Other_PureCloud_Monthly_Minimum_Req__c == null && objDQ.PureCloud_Monthly_Minimum__c == 'Other') 
        {
            objDQ.If_Other_PureCloud_Monthly_Minimum_Req__c.addError('Required !');
            blnHasValidationError = true;
        }
        
        if(!blnIsReadOnly && objDQ.Estimated_Monthly_Recurring_Revenue__c == null && objDQ.Monthly_Recurring_Revenue_less_than_14K__c == 'Yes') 
        {
            objDQ.Estimated_Monthly_Recurring_Revenue__c.addError('Required !');
            blnHasValidationError = true;
        }
        
        if(!blnIsReadOnly && objDQ.Estimated_Number_of_Business_Users__c == null && objDQ.More_than_5_000_Business_Users__c == 'Yes') 
        {
            objDQ.Estimated_Number_of_Business_Users__c.addError('Required !');
            blnHasValidationError = true;
        }
        
        if(!blnIsReadOnly && objDQ.Estimated_Number_of_Agents__c == null && objDQ.Less_than_100_Agents__c == 'Yes') 
        {
            objDQ.Estimated_Number_of_Agents__c.addError('Required !');
            blnHasValidationError = true;
        }
        
        //DQ Changes Sep 2017 - Anju ends
        
        return blnHasValidationError;
    }

    // Get list of ZQuotes to populate drop-down
    public List<SelectOption> getZQuotes()
    {
        List<SelectOption> quotes = new List<SelectOption>();
        if(zQuoteMap == null)
        {
            quotes.add(new SelectOption('', '--None--'));
        }
        else
        {
            quotes.add(new SelectOption('', '--Select--'));
            for(zqu__Quote__c q : zQuoteMap.values())
            {
                quotes.add(new SelectOption(q.Id, q.Name));
            }
        }

        return quotes;
    }

    // Set the quote object based on user selection
    public void setZQuote()
    {
        if(zQuoteMap != null && zQuoteMap.get(zQuoteId) != null)
        {
            this.zQuote = zQuoteMap.get(zQuoteId);
        }
    }

    // Set the PureCloud DQ information based on quote selected
    public PageReference onQuoteChange()
    {
        setZQuote();

        if(this.zQuote == null) return null;        
        
        /* Existing BE Cloud Quote Discount info is prepopulated on DQ if a DQ record hasn't been created yet. Flags populated as long as DQ is editable.
            Approvals Driven by (Discount value/Special Offer flag/Editable List Price Flag)*/
        if(!blnIsReadOnly)
        {
            if(zQuote.zqu__Previewed_Discount__c != null && (objDQ.Id == null || objDQ.Discount_On_Quote__c == null || objDQ.Discount_On_Quote__c == 0))
            {
                objDQ.Discount_On_Quote__c = zQuote.zqu__Previewed_Discount__c;
                //objDQ.PureCloud_Discount__c = (zQuote.zqu__Previewed_Discount__c > 0 ? true : false);
            }

            Set<String> financeExceptions = new Set<String>();
            if(objDQ.Finance_Exception__c == null)
            {
                objDQ.Finance_Exception__c = '';
            }
            else
            {
                financeExceptions.addAll(objDQ.Finance_Exception__c.split(';'));
            }

            if(zQuote.zqu__Currency__c != null
                && zQuote.zqu__Previewed_MRR__c != null
                && convertToUSD(zQuote.zqu__Previewed_MRR__c, zQuote.zqu__Currency__c) < 2000)
            {
                if(!financeExceptions.contains(PURECLOUD_MRR_EXCEPTION))
                {
                    objDQ.Finance_Exception__c += (';' + PURECLOUD_MRR_EXCEPTION);   
                }             
            }
            else if(convertToUSD(zQuote.zqu__Previewed_MRR__c, zQuote.zqu__Currency__c) > 2000)
            {
                if(financeExceptions.contains(PURECLOUD_MRR_EXCEPTION))
                {
                    objDQ.Finance_Exception__c = '';
                    financeExceptions.remove(PURECLOUD_MRR_EXCEPTION);
                    for(String s : financeExceptions)
                    {
                        objDQ.Finance_Exception__c += (s + ';');
                    }
                    objDQ.Finance_Exception__c = objDQ.Finance_Exception__c.removeEnd(';');
                }                
            }
            
            //objDQ.Special_Offer_Terms__c = objQuote.Include_Special_Offer_in_Output__c;
            //objDQ.Special_Offers_Business_Exceptions__c = objQuote.Special_Offer_Terms__c;
            //objDQ.Editable_List_Price_Approval_Required__c = objQuote.Editable_List_Price_Approval_Required__c; 
        }

        return null;
    }

    private Decimal convertToUSD(Decimal valueToConvert, String isoCode)
    {
        //if(isoToExchangeRate == null) return valueToConvert;      
        if(this.isoToExchangeRate.containsKey(isoCode) && isoToExchangeRate.get(isoCode) != null)
        {
            return valueToConvert / this.isoToExchangeRate.get(isoCode);
        }
        else
        {
            return valueToConvert;
        }
    }
    
    //Mukunth added below code for INC0416843 - DQ Special Offers Sub-aprpovers
    public void requestSpecOfferSubApproval(){

        checkSpecApprovalReadOnly();

        DealQualificationApprovalUtil.sendSpecOfferSubApprEmails(objDQ,finToAddresses,string.valueof(objOppty.Region_Non_CSM__c),sentRevEmail,sentOMEmail,sentCCEmail,sentLegalEmail);
        
        if(objDQ.Req_Revenue_Approval__c){
            sentRevEmail = true;
        }
        if(objDQ.Req_Order_Mgmt_Billing_approval__c){
            sentOMEmail = true;
        }
        if(objDQ.Req_Credit_Collections_approval__c){
            sentCCEmail = true;
        }
        if(objDQ.Req_Legal_approval__c){
            sentLegalEmail = true;
        }
            
        update objDQ;
    }
    
    public void checkSpecApprovalReadOnly(){
        if(objDQ.Status__c == 'Approved')
            showDQSpecApprReadOnly = true;
            
        if(objDQ.Req_Revenue_Approval__c && (finToAddresses.get('Revenue_'+objOppty.Region_Non_CSM__c)).contains(UserInfo.getUserEmail())){
            isRevSubApprover = true;
        }
        if(objDQ.Req_Order_Mgmt_Billing_approval__c && (finToAddresses.get('OrderMgmt_'+objOppty.Region_Non_CSM__c)).contains(UserInfo.getUserEmail())){
            isOMBSubApprover = true;
        }
        if(objDQ.Req_Credit_Collections_approval__c && (finToAddresses.get('CreditCollect_'+objOppty.Region_Non_CSM__c)).contains(UserInfo.getUserEmail())){
            isCCSubApprover = true;
        }
        if(objDQ.Req_Legal_approval__c && (finToAddresses.get('Legal_'+objOppty.Region_Non_CSM__c)).contains(UserInfo.getUserEmail())){
            isLegalSubApprover = true;
        }
        
    }
    
    public void checkSpecOfferApprPending(){
 
        dqSpecOffrWrppr = DealQualificationApprovalUtil.checkSpecOfferApprPending(objDQ);
        System.Debug('dqSpecOffrWrppr--->'+dqSpecOffrWrppr);
        System.Debug('finToAddresses--->'+dqSpecOffrWrppr.finToAddresses);
        System.Debug('isSpecApprOfferPending--->'+dqSpecOffrWrppr.isSpecApprOfferPending);
        System.Debug('isSubApprover--->'+dqSpecOffrWrppr.isSubApprover);
        
        isSpecApprOfferPending = dqSpecOffrWrppr.isSpecApprOfferPending;
        finToAddresses = dqSpecOffrWrppr.finToAddresses;
        isSubApprover = dqSpecOffrWrppr.isSubApprover;
        
        checkSpecApprovalReadOnly();
        
    }
    
    public void saveFinanceApproval(){
        update objDQ;
    }
    
	public void unlockSubApprSection(){
	    
	    System.Debug('finFunc--->'+unlockFinFn);
	    
	    if(unlockFinFn == 'revenue'){
	        objDQ.Req_Revenue_Approval__c = false;
	        objDQ.Revenue_approval__c = null;
	        objDQ.Revenue_Comments__c = null;
	    }
	    else if(unlockFinFn == 'orderMgmt'){
            objDQ.Req_Order_Mgmt_Billing_approval__c = false;
            objDQ.Order_Mgmt_Billing_approval__c = null;
            objDQ.Order_Management_Billing_Comments__c = null;

	    }
	    else if(unlockFinFn == 'creditCol'){
	        objDQ.Req_Credit_Collections_approval__c = false;
	        objDQ.Credit_and_Collections_approval__c = null;
	        objDQ.Credit_Collections_Comments__c = null;
	    }
	    else if(unlockFinFn == 'legal'){
	        objDQ.Req_Legal_approval__c = false;
	        objDQ.Legal_approval__c = null;
	        objDQ.Legal_Comments__c = null;
	    }
	    
	    update objDQ;
	}
    
    //Mukunth code end - DQ Special Offers

}