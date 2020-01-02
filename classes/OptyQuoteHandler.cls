//Naresh Kumar  Updated 03/09/2017. Restructure of whole class as per new requirements.
// History
// Added PEC changes by Kartik 22-07-2019
/* code updated on line no 2161 --> objProduct.PPU_Product_Specific_Discount__c replaced with   objProduct.Product_Specific_Discount__c on 11-28-2019  for INC0437456 
 line 2286 i have added the field in query.Product__r.Product_Specific_Discount__c, 
*/

// TestClass : OptyQuoteHandler_Test
public without sharing class OptyQuoteHandler {    
    // stores opportunity record
    public Opportunity objOpty {get;set;}
    // list of options for pricing picklist
    public List<SelectOption> pricingOptions {get; set;}
    // list of options for quote type picklist
    public List<SelectOption> quoteTypeOptions {get; set;}
    // dummy object to expose on vf page, we are not exposing objOpty to vf page
    public Admin_Dummy__c objOppQuoteCategory {get;set;}
    // stores the user type 
    public Boolean blnIsPartnerUser {get;set;}
    // redirect to DQ?
    public Boolean blnRedirectToDQ {get;set;}
    // stores opportunity id
    public String strOppId {get;set;}
    // hold whether the new quote is primary or not
    private Boolean blnIsPrimaryQuote {get;set;}
    // disables Quote Type field
    public Boolean blnDisableQuoteType {get;set;}
    public Boolean blnIsAdmin {get;set;}
    public String strBaseURL {get;set;}    
    public String strSelectedOrderType {get;set;}
    public String strSubscrSubType {get;set;}
    public String selectedSubscrToAmend {get;set;}
    public Map<Id, Subscription__c> map_Subscriptions {get;set;}
    public Integer intSubscrSize {get;set;}
    public Integer pageStep {get; private set;}
    public List<Product_Group__c> listOfBasePackages {get; set;}
    public List<Product_Group__c> listOfPureSuccessPackages {get; set;}
    public List<Product_Group__c> listOfUseCases {get; set;}
    public Boolean blnShowBaseAndPureSuccessPackage {get; set;}
    public Boolean blnShowOnlyUseCases {get; private set;}    
    public Boolean blnShowOfferingDetails {get; private set;}
    public Boolean blnShowOfferingDetailsValidation {get; private set;}
    public Boolean blnOrderTypeRequired{get; private set;}
    
    //Anju Juny 2018 Cloud changes for Puresuccess
    public String strExistingPureSuccessCustomer {get; set;}
    public String strIsNewInstanceforLeadOffer {get; set;}
    
    public List<SelectOption> list_PlayOfferType {get; set;}
    public List<SelectOption> list_PlayOffer {get; set;}
    public String selectedPlayOfferType {get; set;}
    public String selectedPlayOffer {get; set;}
    public Boolean isSmallMediumCenter {get; set;}
    public Boolean showOfferingFeature {get; set;}
    public Map<String, List<PlayOfferWrapper>> map_PlayCategoryListPlayOffer {get; set;}
    public Map<String, String> map_PlayCategoryError {get; set;}
    public boolean isChecked {get; set;}
    public List<String> list_PlayCategory {get; set;}
    public boolean isAlreadySelect;
    public boolean isOfferRequired {get; set;}
    public set<Id> ProductId_set {get; set;}
    public Set<Id> set_InsertedProductIds{get;set;}
    public static final String PRIMARY_PLAY = Label.Top_Play.split(';')[0];
    public static final Decimal PRIMARY_PLAY_DISCOUNT = Decimal.valueOf(Label.Top_Play.split(';')[1]);
    public static final Integer PRIMARY_PLAY_MONTHS = Integer.valueOf(Label.Top_Play.split(';')[2]);
    public final String PCSUBSCR_SMALL_MED = 'PureConnect Small Medium';
    public integer intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
    //Rony Joseph- July 1st 2019 -PureBridge Project
    public boolean blnPureBridgeOpportunity {get;set;}
    public map<string,boolean> map_leverSelection {get;set;}
    //  public map<string,string> map_leverNames {get;set;}
    public list<string> list_lever {get;set;}
    public List<PBLever> pbLevers {get; set;}
    public Boolean showPbLevers {get; set;}
    
    // custom controller constructor
    public OptyQuoteHandler() {
        // initializing few things
        objOpty = new Opportunity();
        ProductId_set = new set<Id>();
        blnShowBaseAndPureSuccessPackage = true;
        blnShowOnlyUseCases = false;
        blnOrderTypeRequired = true;
        isOfferRequired = false;
        isSmallMediumCenter = false;
        showOfferingFeature = false;
        showPbLevers = false;
        pageStep = 1;
        intLineNumber = 0;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
        objOppQuoteCategory = new Admin_Dummy__c();
        pricingOptions = new List < SelectOption > ();
        blnIsPartnerUser = UserInfo.getUserType() == 'PowerPartner' ? true : false;
        blnIsPrimaryQuote = false;
        blnDisableQuoteType = false;
        strBaseURL = UserInfo.getUserType() == 'PowerPartner' ? '/partner/PartnerPortalOptyDetail?Id=' : '/';        
        selectedSubscrToAmend = null;
        intSubscrSize = 0;
        selectedPlayOfferType = '';
        selectedPlayOffer = '';
        pageStep = 1;
        isChecked = false;
        list_PlayCategory = new List<String>();        
        map_Subscriptions = new Map<Id, Subscription__c>();
        set_InsertedProductIds = new Set<Id>();
        listOfUseCases = new List<Product_Group__c>();
        list_PlayOffer = new List<SelectOption>{new SelectOption('', '--None--')};
            list_PlayOfferType = new List<SelectOption>{new SelectOption('', '--None--')};
                isAlreadySelect = false;
        // gets the opportunity id from patameter in url
        strOppId = ApexPages.CurrentPage().getParameters().get('oppId');
        // populating whether it's DQ redirection or not
        blnRedirectToDQ = (ApexPages.CurrentPage().getParameters().get('redirectTo') != null);
        System.debug('NKC debug strOppId ['+ strOppId +']');
        //temporary
        //blnIsAdmin = (ApexPages.CurrentPage().getParameters().get('isAdmin') == null ? false : true);
        blnIsAdmin = true;
        blnShowOfferingDetailsValidation = false;
        if(blnIsPartnerUser)
            blnShowOfferingDetails = false;
        else
            blnShowOfferingDetails = true;
        // querying information from query  
        objOpty = [SELECT id, Name, AccountId, Sold_To_Country__r.Name, Offering_Detail__c, Lead_Offer__c,MSA_Link__c,MSA_Link_Type__c,     
                   Sold_To_Country__r.RU__c, Quote_Category__c, Lines_of_Businesses__c, Type, RecordType.Name,
                   Primary_Line_of_Business__c , CurrencyIsoCode, BusinessPartner__c, Support_Owner__c,
                   System_Integrator__c, Direct_Sales__c, Account.Country__r.New_Price_Book__c, Country_Sub_Region__c,
                   BusinessPartner__r.Country__r.New_Price_Book__c, Account.Country__r.Old_Price_Book__c,
                   BusinessPartner__r.Country__r.Old_Price_Book__c, Sold_To_Country__r.New_Price_Book__c,Lever__c,Avaya_Contract_Expiration__c,
                   Sold_To_Country__r.Old_Price_Book__c, Country_Selling_Entity__c, SOW_Url__c, Product_Version__c,
                   Contractual_Obligation__c, PricingType__c, Direct_Indirect_Sale__c,Primary_Solution__c, Quote_Type1__c,
                   Account.RecordType.DeveloperName, Indirect_Partner_PureCloud_Approved__c,
                   BusinessPartner__r.Approved_for_PureCloud_Billing__c, BusinessPartner__r.SMART_Qualified__c, BusinessPartner__r.Subscription_Qualified__c,
                   Account.Pricesheet_Permission__c,BusinessPartner__r.Pricesheet_Permission__c, BusinessPartner__r.Partner_Offering_Type__c,
                   Cloud_Renewal__c, Pricebook2Id 
                   FROM Opportunity WHERE id =: strOppId];
        strSelectedOrderType = '';
        
        //set PureBridgeLevers
        getLevers();    
        
        strSubscrSubType = objOpty.Lines_of_Businesses__c == 'PureCloud' ? 'New PureCloud Org & Subscription' : '';
        if(objOpty.Direct_Indirect_Sale__c == null)
            objOpty.Direct_Indirect_Sale__c = 'Direct';
        
        if(objOpty.Direct_Indirect_Sale__c == 'Indirect' && objOpty.BusinessPartner__c != null 
           && (!objOpty.BusinessPartner__r.SMART_Qualified__c || !objOpty.BusinessPartner__r.Subscription_Qualified__c)){
               blnShowOfferingDetailsValidation = true;
           }        
        // populating dummy object to show the information vf page        
        objOppQuoteCategory.Name = objOpty.Name;
        objOppQuoteCategory.Product_Version__c = objOpty.Product_Version__c;
        /*
if(blnIsAdmin)
objOppQuoteCategory.Offering_Type__c = objOpty.Lines_of_Businesses__c;
else
objOppQuoteCategory.Offering_Type__c = 'PureEngage';
objOppQuoteCategory.Platform_Type__c = objOpty.Primary_Line_of_Business__c ;
objOppQuoteCategory.Quote_Type__c = objOpty.Quote_Type1__c;
*/
        objOppQuoteCategory.Product_Version__c = objOpty.Product_Version__c;        
        // default the values (CIC Quoting) if it's a portal/community user
        if(blnIsPartnerUser){
            objOppQuoteCategory.Lead_Offer__c = 'PureConnect Premise';
            //objOppQuoteCategory.Quote_Type__c = QuoteUtil.OFFERING_TYPE_CIC;
        }
        if(objOpty.RecordType.Name == 'Cloud Renewal'){
            objOppQuoteCategory.Lead_Offer__c = objOpty.Lead_Offer__c;
        }        
        // populating pricing picklist options
        SelectOption newPricing;// = new SelectOption('', '--Select--');
        //pricingOptions.add(newPricing);
        newPricing = new SelectOption('New Pricing', 'New Pricing');
        pricingOptions.add(newPricing);
        if ((objOpty.Type != 'New logo' || objOpty.Lines_of_Businesses__c == 'Cloud Partner (PPU)')){
            newPricing = new SelectOption('Old Pricing', 'Old Pricing');
            pricingOptions.add(newPricing);
        }
        
        blnDisableQuoteType = true;
        populatePlatformAndOfferingType();
    }
    
    public void populatePlatformAndOfferingType(){
        objOppQuoteCategory.Offering_Type__c = null;
        objOppQuoteCategory.Platform_Type__c = null;
        objOppQuoteCategory.Offering_Details__c = null;         
        objOppQuoteCategory.Quote_Type__c = null;
        objOppQuoteCategory.Product_Tier__c = 'Enterprise';
        objOppQuoteCategory.Product_Version__c = null;
        objOppQuoteCategory.Order_Type__c = null;
        objOppQuoteCategory.Pricing_Model__c = null;
        objOppQuoteCategory.Pricing__c = null;
        objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c = null;
        strSelectedOrderType = null;
        strSubscrSubType = null;
        blnDisableQuoteType = true; 
        isSmallMediumCenter = false;
        showOfferingFeature = false;
        //Anju July 2018 Cloud puresuccess changes
        strExistingPureSuccessCustomer = null;
        strIsNewInstanceforLeadOffer = null;
        //Added By Ranjith on Apr 19, 2019 -- Starts -- Reason for new sub 
        objOppQuoteCategory.Reason_for_New_when_Sub_s_Already_Exist__c = null;
        //Added By Ranjith on Apr 19, 2019 -- Starts -- Reason for new sub
        
        if(objOppQuoteCategory.Lead_Offer__c == 'PureConnect Cloud'){
            objOppQuoteCategory.Offering_Type__c = 'PureConnect';
            objOppQuoteCategory.Platform_Type__c = 'Cloud';
            objOppQuoteCategory.Quote_Type__c = 'PureConnect Cloud';
        }
        else if(objOppQuoteCategory.Lead_Offer__c == 'PureConnect Premise'){
            objOppQuoteCategory.Offering_Type__c = 'PureConnect';
            objOppQuoteCategory.Platform_Type__c = 'On Premise';
            objOppQuoteCategory.Quote_Type__c = 'PureConnect On Premise';
        }
        else if(objOppQuoteCategory.Lead_Offer__c == 'PureConnect Premise Subscription'){
            objOppQuoteCategory.Offering_Type__c = 'PureConnect';
            objOppQuoteCategory.Platform_Type__c = 'On Premise';
            objOppQuoteCategory.Offering_Details__c = 'Subscription';            
            objOppQuoteCategory.Quote_Type__c = 'PureConnect On Premise';
            showOfferingFeature = (objOpty.BusinessPartner__r.Partner_Offering_Type__c != null && (objOpty.BusinessPartner__r.Partner_Offering_Type__c).contains(PCSUBSCR_SMALL_MED)) ? true : false;           
        }
        else if(objOppQuoteCategory.Lead_Offer__c == 'PureConnect Premise Rental'){
            objOppQuoteCategory.Offering_Type__c = 'PureConnect';
            objOppQuoteCategory.Platform_Type__c = 'On Premise';            
            objOppQuoteCategory.Offering_Details__c = 'Rental';
            objOppQuoteCategory.Quote_Type__c = 'PureConnect On Premise';
        }
        else if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud'){
            objOppQuoteCategory.Offering_Type__c = 'PureEngage';
            objOppQuoteCategory.Platform_Type__c = 'Cloud';
            // ECD PEC Quote July 2019
            objOppQuoteCategory.Quote_Type__c = 'PureEngage Cloud'; 
            quoteTypeOptions = new List<SelectOption>();
            if(!blnRedirectToDQ){
                //quoteTypeOptions.add(new SelectOption('Outbound Engagement Cloud','Outbound Engagement Cloud'));
                quoteTypeOptions.add(new SelectOption('','--None--'));
                quoteTypeOptions.add(new SelectOption('Self Service','Self Service'));
            }            
            quoteTypeOptions.add(new SelectOption('Business Edition','Business Edition'));            
            //quoteTypeOptions.add(new SelectOption('Premier Edition Cloud','Premier Edition Cloud'));
            //commented by kartik to disable blnDisableQuoteType
            // blnDisableQuoteType = false;
        }        
        else if(objOppQuoteCategory.Lead_Offer__c == 'Premier Edition Cloud'){
            objOppQuoteCategory.Offering_Type__c = 'PureEngage';
            objOppQuoteCategory.Platform_Type__c = 'Cloud';           
            objOppQuoteCategory.Quote_Type__c = 'Premier Edition';
        }
        else if(objOppQuoteCategory.Lead_Offer__c == 'Outbound Engagement Cloud'){
            objOppQuoteCategory.Offering_Type__c = 'PureEngage';
            objOppQuoteCategory.Platform_Type__c = 'Cloud';           
            objOppQuoteCategory.Quote_Type__c = 'Outbound Engagement';
        }        
        else if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Premise'){
            objOppQuoteCategory.Offering_Type__c = 'PureEngage';
            objOppQuoteCategory.Platform_Type__c = 'On Premise';
            objOppQuoteCategory.Quote_Type__c = 'PureEngage On Premise';
        }
        else if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Premise Subscription'){
            objOppQuoteCategory.Offering_Type__c = 'PureEngage';
            objOppQuoteCategory.Platform_Type__c = 'On Premise';            
            objOppQuoteCategory.Offering_Details__c = 'Subscription';
            objOppQuoteCategory.Quote_Type__c = 'PureEngage On Premise';
        }
        else if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Premise Rental'){
            objOppQuoteCategory.Offering_Type__c = 'PureEngage';
            objOppQuoteCategory.Platform_Type__c = 'On Premise';            
            objOppQuoteCategory.Offering_Details__c = 'Rental';
            objOppQuoteCategory.Quote_Type__c = 'PureEngage On Premise';
        }
        else if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud Partner PPU'){
            objOppQuoteCategory.Offering_Type__c = 'PureEngage';
            objOppQuoteCategory.Platform_Type__c = 'Cloud';
            objOppQuoteCategory.Quote_Type__c = 'Cloud Partner (PPU)';
            refresh();
        }
        else if(objOppQuoteCategory.Lead_Offer__c == 'PureCloud'){
            objOppQuoteCategory.Offering_Type__c = 'PureCloud';
            objOppQuoteCategory.Platform_Type__c = 'Cloud';           
            objOppQuoteCategory.Quote_Type__c = 'PureCloud';
            objOppQuoteCategory.Offering_Details__c = objOpty.Offering_Detail__c;   
        }
        
        System.debug('######objOppQuoteCategory.Offering_Type__c'+ objOppQuoteCategory.Offering_Type__c);
        System.debug('######objOpty.AccountId'+ objOpty.AccountId);
        if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Premise Subscription' 
           || objOppQuoteCategory.Lead_Offer__c == 'PureConnect Premise Subscription'){
               map_Subscriptions = SubscriptionUtil.getSubscriptionInfoWithoutBundleLines(objOpty.AccountId, 
                                                                                          objOppQuoteCategory.Offering_Details__c == 'Subscription' ? objOppQuoteCategory.Offering_Type__c + ' Subscription' : objOppQuoteCategory.Offering_Type__c);
           }
        else{
            //Anju July 2018 PCC Subscriptions
            System.Debug('####OfferingDetial:'+objOppQuoteCategory.Offering_Details__c);
            String strOfferingType = (objOppQuoteCategory.Offering_Details__c == 'Subscription' && objOppQuoteCategory.Lead_Offer__c != 'PureCloud')? objOppQuoteCategory.Offering_Type__c + ' Subscription' : objOppQuoteCategory.Offering_Type__c;
            if(objOppQuoteCategory.Offering_Type__c == 'PureConnect' && objOppQuoteCategory.Platform_Type__c == 'Cloud')
                strOfferingType = 'PureConnect Cloud';
            // ECD PEC Quote July 2019
            if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud')
                strOfferingType = 'PureEngage Cloud';
            map_Subscriptions = SubscriptionUtil.getSubscriptionInfo(objOpty.AccountId, strOfferingType);
            System.Debug('####strOfferingType:'+strOfferingType+' ###map_Subscriptions'+map_Subscriptions);
            
        }
        
        //map_Subscriptions = SubscriptionUtil.getSubscriptionInfo(objOpty.AccountId, 
        //objOppQuoteCategory.Offering_Details__c == 'Subscription' ? objOppQuoteCategory.Offering_Type__c + ' Subscription' : objOppQuoteCategory.Offering_Type__c);
        intSubscrSize = map_Subscriptions.size();
        system.debug(objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c);
        
        getLevers();
    }
    
    public void goToStep2(){        
        list_PlayOfferType.clear();
        //list_PlayOfferType.add(new SelectOption('', '--None--'));
        map_PlayCategoryError = new Map<String, String>();
        
        for(Play_Offer__mdt playOffer : [SELECT Offering_Type__c, Plat_Category__c, Play_O__c, HelpMessage__c FROM Play_Offer__mdt WHERE Offering_Type__c =: objOppQuoteCategory.Lead_Offer__c AND Plat_Category__c =: selectedPlayOffer]){            
            list_PlayOfferType.add(new SelectOption(playOffer.Play_O__c, playOffer.Play_O__c));
            if(playOffer.HelpMessage__c != null)
                map_PlayCategoryError.put(playOffer.Play_O__c, playOffer.HelpMessage__c);
            else
                map_PlayCategoryError.put(playOffer.Play_O__c, '');
        }  
        if(list_PlayOfferType.size() > 0){
            isOfferRequired = true;
        }else{
            isOfferRequired = false;
        }
        System.debug('--string list_PlayOfferType type--'+list_PlayOfferType); 
    }
    
    public pageReference nextStep1(){   
        System.debug('--selectedPlayOffer --'+selectedPlayOffer +'  selectedPlayOfferType  --'+selectedPlayOfferType+'  Order_Type__c  '+objOppQuoteCategory.Order_Type__c+'  strSelectedOrderType '+strSelectedOrderType); 
        System.debug('--objOppQuoteCategory.Offering_Details__c --'+objOppQuoteCategory.Offering_Details__c +'  Quote_Type__c  '+objOppQuoteCategory.Quote_Type__c); 
        If(objOppQuoteCategory.Offering_Details__c == 'Free Trial')
            return createQuoteAndGoToQuote();
        if((!String.isBlank(objOppQuoteCategory.Order_Type__c) || strSelectedOrderType == 'New'  || strSelectedOrderType == 'Amend' || objOppQuoteCategory.Quote_Type__c == 'Self Service' || objOppQuoteCategory.Quote_Type__c == 'Business Edition')
           && objOppQuoteCategory.Offering_Details__c != 'Rental' && objOppQuoteCategory.Quote_Type__c != 'Cloud Partner (PPU)' && objOppQuoteCategory.Quote_Type__c != 'Outbound Engagement' 
           && objOppQuoteCategory.Quote_Type__c != 'Premier Edition' && UserInfo.getUserType() != 'PowerPartner' && !isSmallMediumCenter)
        {
            if((selectedPlayOffer == '' || selectedPlayOffer == null)&& objOppQuoteCategory.Offering_Details__c != 'Free Trial') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select primary play.'));
                return null;
            }
            if((selectedPlayOffer != '' && selectedPlayOffer != 'None' && selectedPlayOfferType == '[]') && objOppQuoteCategory.Offering_Details__c != 'Free Trial'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select play offer type.'));
                return null;
            }
            
        }
        
        //Anju Dec 18 usecases : removing cloud check && objOppQuoteCategory.Platform_Type__c != 'Cloud'  and adding purecloud
        system.debug('Inside next'+objOppQuoteCategory.Offering_Type__c);
        System.debug(strSelectedOrderType);
        System.debug(objOppQuoteCategory.Platform_Type__c);
        if((objOppQuoteCategory.Offering_Type__c == 'PureEngage' || objOppQuoteCategory.Offering_Type__c == 'PureConnect' || objOppQuoteCategory.Offering_Type__c == 'PureCloud') 
           && strSelectedOrderType != 'Amend' && strSelectedOrderType != 'Subscription'
           //Anju Dec 18 usecases : adding cloud
           && (objOppQuoteCategory.Offering_Details__c == 'Subscription' || objOppQuoteCategory.Platform_Type__c == 'On Premise' || objOppQuoteCategory.Platform_Type__c == 'Cloud') 
          ){
              if(blnShowOfferingDetailsValidation && objOppQuoteCategory.Offering_Details__c == 'Subscription'){                
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The sold/to business partner account on this opportunity is not Subscription & SMART Qualified. Please submit a Subscription DSR to the Partner team for assistance.'));
                  return null;
              }
              
              pageStep = 2;             
              System.debug('---objOpty.Type  '+objOpty.Type+'  objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c---  '+objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c);
              // if((objOpty.Type == 'Existing Business - Cross Sell' || objOpty.Type == 'Existing Business - Expansion') && !objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c)
              if((objOpty.Type == 'Existing Business - Cross Sell' || objOpty.Type == 'Existing Business - Expansion' ) && !objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c)
                  blnShowBaseAndPureSuccessPackage = false;
              else
                  blnShowBaseAndPureSuccessPackage = true;     
              System.debug(objOppQuoteCategory);
              //Anju Dec 18 usecases : adding cloud
              if((objOppQuoteCategory.Platform_Type__c == 'On Premise' || objOppQuoteCategory.Platform_Type__c == 'Cloud') && (objOppQuoteCategory.Offering_Details__c != 'Subscription' || objOppQuoteCategory.Quote_Type__c == 'PureCloud') && objOppQuoteCategory.Quote_Type__c != 'PureConnect Cloud' && objOppQuoteCategory.Quote_Type__c != 'PureEngage Cloud'){
                  blnShowOnlyUseCases = true;       
              }
              System.debug('---blnShowOnlyUseCases-- '+blnShowOnlyUseCases+'  ---blnShowBaseAndPureSuccessPackage---  '+blnShowBaseAndPureSuccessPackage);
              If(objOppQuoteCategory.Offering_Details__c != 'Free Trial'){populatePackages();}
              return null;
          }
        
        else{            
            if(selectedSubscrToAmend == null || selectedSubscrToAmend == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select an existing subscription to amend before proceeding.'));
                return null;
            }
            
            if ( !showPbLevers )
                pbLevers = new List<PBLever>();
            
            blnShowBaseAndPureSuccessPackage = false;
            blnShowOnlyUseCases = true;
            If(objOppQuoteCategory.Offering_Details__c != 'Free Trial'){ populatePackages();}
            pageStep = 2;
            return null;
            /*
if(objOppQuoteCategory.Quote_Type__c == 'PureConnect Cloud' && objOppQuoteCategory.Product_Tier__c == null){
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select Product Tier.'));
return null;
}
*/
            // return createQuoteAndGoToQuote();
            
        }
    }
    
    public void backStep2(){
        pageStep = 1;
    }
    
    private void populatePackages(){ 
        listOfBasePackages = new List<Product_Group__c>();
        listOfPureSuccessPackages = new List<Product_Group__c>();
        List<String> listOfGroupTypes = new List<String>();
        listOfGroupTypes.add('Base Package'); 
        listOfGroupTypes.add('PureSuccess');
        listOfGroupTypes.add('Use Case');
        String strOfferingType = objOppQuoteCategory.Offering_Type__c;
        
        if(objOppQuoteCategory.Offering_Details__c == 'Subscription')
            strOfferingType += ' Subscription';
        else
            strOfferingType += ' On Premise';
        
        //Anju Dec 18 usecases      
        if(objOppQuoteCategory.Offering_Type__c == 'PureConnect' && objOppQuoteCategory.Platform_Type__c == 'Cloud')
            strOfferingType = 'PureConnect Cloud';
        if(objOppQuoteCategory.Offering_Type__c == 'PureCloud' && objOppQuoteCategory.Platform_Type__c == 'Cloud')
            strOfferingType = 'PureCloud';
        if(objOppQuoteCategory.Offering_Type__c == 'PureEngage' && objOppQuoteCategory.Platform_Type__c == 'Cloud')
            strOfferingType = 'PureEngage Cloud';
        if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud Partner PPU')             
            strOfferingType = 'PureEngage Cloud Partner PPU';
        
        
        System.debug('NKC debug strOfferingType [' + strOfferingType + ']');
        Set<String> setOfCategory = new Set<String>();
        Set<String> setOfDSRUseCases = new Set<String>();
        //Looping over each DSR Use cases    
        
        for(DSR_Use_Case_Blueprints__c eachUseCase : DSRUtility.GetFnUseCaseAndBluePrints(objOpty.id, strOfferingType)){
            if(eachUseCase.ShortCode__c != null)
                setOfDSRUseCases.add(eachUseCase.ShortCode__c);
        }   
        
        //MS
        String offtypes = isSmallMediumCenter ? PCSUBSCR_SMALL_MED : strOfferingType;
        system.debug('offtypes'+offtypes);
        List<Product_Group__c> listOfProductGroups = getProductGroup(listOfGroupTypes, offtypes, QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode));
        //List<Product_Group__c> listOfProductGroups = getProductGroup(listOfGroupTypes, strOfferingType, QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode));
        //Lopoping over each product group item
        system.debug('blnShowBaseAndPureSuccessPackage'+blnShowBaseAndPureSuccessPackage);
        for(Product_Group__c eachGroup : listOfProductGroups){
            
            if(eachGroup.Group_Type__c == 'Base Package' && blnShowBaseAndPureSuccessPackage 
               && (eachGroup.Pricing_Model__c == 'User') && (objOppQuoteCategory.Quote_Type__c == 'PureEngage Cloud' || objOppQuoteCategory.Quote_Type__c == 'PureConnect Cloud'  || objOppQuoteCategory.Offering_Details__c == 'Subscription')){
                   eachGroup.Selected__c = true;
                   listOfBasePackages.add(eachGroup);
               }
            else if(eachGroup.Group_Type__c == 'PureSuccess' && blnShowBaseAndPureSuccessPackage 
                    && (objOppQuoteCategory.Quote_Type__c == 'PureConnect Cloud' ||objOppQuoteCategory.Quote_Type__c == 'PureEngage Cloud' || objOppQuoteCategory.Offering_Details__c == 'Subscription')){
                        if((objOpty.Direct_Indirect_Sale__c == 'Indirect' && eachGroup.Type__c == 'EQUIP') 
                           || ((objOpty.Direct_Indirect_Sale__c == 'Direct' && eachGroup.Type__c == 'Partner PureSuccess')))
                            continue;
                        if(eachGroup.Type__c == 'EQUIP' || eachGroup.Type__c == 'Partner PureSuccess'){
                            if(eachGroup.Type__c == 'Partner PureSuccess')
                                eachGroup.Selected__c = true;    
                            if(!listOfPureSuccessPackages.isEmpty())
                                listOfPureSuccessPackages.add(0, eachGroup);
                            else
                                listOfPureSuccessPackages.add(eachGroup);
                        }
                        else if(objOpty.Direct_Indirect_Sale__c == 'Direct')
                            listOfPureSuccessPackages.add(eachGroup);
                    }
            else if(eachGroup.Group_Type__c == 'Use Case'){
                if(!setOfCategory.contains(eachGroup.Category__c)){
                    System.debug('NKC debug setOfCategory [' + setOfCategory + ']');
                    Product_Group__c objHeaderGroup = new Product_Group__c();
                    objHeaderGroup.Category__c = eachGroup.Category__c;
                    objHeaderGroup.Type__c = 'background-color:#dbedfc;';
                    listOfUseCases.add(objHeaderGroup);
                    setOfCategory.add(eachGroup.Category__c);
                    System.debug('NKC debug eachGroup.Category__c ['+eachGroup.Category__c+']');
                }
                eachGroup.Category__c = null;
                if(eachGroup.Name != null && setOfDSRUseCases.contains(eachGroup.Name)){
                    eachGroup.Selected__c = true;    
                }
                listOfUseCases.add(eachGroup);
            }
        }
        
        String playOfferCondition = '';
        System.debug('---selectedPlayOfferType---'+selectedPlayOfferType);
        selectedPlayOfferType = selectedPlayOfferType.remove('[');
        selectedPlayOfferType = selectedPlayOfferType.remove(']');
        for(String playOffr : selectedPlayOfferType.split(',')){
            playOffr = playOffr.trim();
            playOfferCondition = playOfferCondition + 'Play_Offer__c INCLUDES (\'' + playOffr + '\') OR ';
            list_PlayCategory.add(playOffr);
        }
        System.debug('---playOfferCondition---'+playOfferCondition);
        map_PlayCategoryListPlayOffer = new Map<String, List<PlayOfferWrapper>>();
        
        if(playOfferCondition != ''){
            
            playOfferCondition = playOfferCondition.removeEnd('OR ');
            List<String> list_Temp = new List<String>();
            List<Product_Group__c> list_PG = getProductGroup(listOfGroupTypes, strOfferingType, QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode), playOfferCondition);
            System.debug('---list_PG---'+list_PG);
            for(String playOffer : list_PlayCategory){
                for(Product_Group__c prodGrp : list_PG){
                    if(prodGrp.Play_Offer__c != null && prodGrp.Play_Offer__c.contains(playOffer)){
                        if(!map_PlayCategoryListPlayOffer.containsKey(playOffer)){
                            map_PlayCategoryListPlayOffer.put(playOffer, new List<PlayOfferWrapper>());
                            list_Temp.add(playOffer);
                        }
                        map_PlayCategoryListPlayOffer.get(playOffer).add(new PlayOfferWrapper(prodGrp));                      
                    }
                }
            }
            list_PlayCategory.clear();
            list_PlayCategory.addAll(list_Temp);
        }
    }
    
    private List<Product_Group__c> getProductGroup(List<String> listOfGroupTypes, String strOfferingType, String strPricebookFieldName){
        strPricebookFieldName = strPricebookFieldName + '_Price__c';
        String strBundleQuery = 'SELECT Id, Name, Category__c, Play_Offer__c, Group_Type__c, Offering_Type__c, Active__c, Pricing_Model__c, Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c,Selected__c';
        strBundleQuery += ' ,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,(SELECT Product__r.Name, Product__r.Quantity__c, Product__r.Description, Quantity__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,Product__r.Pricing_Model__c, Product_Group__c, Product__r.Product_Group__c ';
        strBundleQuery += ' FROM Product_Group_Items__r) FROM Product_Group__c WHERE Group_Type__c IN: listOfGroupTypes AND Play_Offer__c = null AND Active__c = true AND Offering_Type__c INCLUDES (\'' + strOfferingType + '\')';
        system.debug('strOfferingType'+strOfferingType);
        /*     if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud' && objOppQuoteCategory.Quote_Type__c != null){
system.debug('objOppQuoteCategory.Quote_Type__c'+objOppQuoteCategory.Quote_Type__c);
strBundleQuery += ' AND Quote_Type__c = \'' + objOppQuoteCategory.Quote_Type__c + '\'';
} */
        strBundleQuery += ' ORDER BY Name, Order__c';
        system.debug('objOppQuoteCategory.Quote_Type__c'+objOppQuoteCategory.Quote_Type__c);
        System.Debug('OptyQuoteHandler.getProductGroup strBundleQuery ' + strBundleQuery);
        System.Debug('OptyQuoteHandler.getProductGroup listOfGroupTypes ' + listOfGroupTypes);
        List<Product_Group__c> listOfProductGroup = (List<Product_Group__c>)Database.query(strBundleQuery);
        system.debug('listOfProductGroup'+listOfProductGroup);
        return listOfProductGroup;
    }
    
    private List<Product_Group__c> getProductGroup(List<String> listOfGroupTypes, String strOfferingType, String strPricebookFieldName, String playOfferCondition){
        strPricebookFieldName = strPricebookFieldName + '_Price__c';
        String strBundleQuery = 'SELECT Id, Name, Category__c, Play_Offer__c, Group_Type__c, Offering_Type__c, Active__c, Pricing_Model__c, Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c,Selected__c';
        strBundleQuery += ' ,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,(SELECT Product__r.Name, Product__r.Quantity__c, Product__r.Description, Quantity__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,Product__r.Pricing_Model__c, Product_Group__c, Product__r.Product_Group__c ';
        strBundleQuery += ' FROM Product_Group_Items__r) FROM Product_Group__c WHERE Group_Type__c IN: listOfGroupTypes AND Active__c = true AND Offering_Type__c INCLUDES (\'' + strOfferingType + '\') AND ( ' + playOfferCondition + ' )';
        if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud' && objOppQuoteCategory.Quote_Type__c != null){
            strBundleQuery += ' AND Quote_Type__c = \'' + objOppQuoteCategory.Quote_Type__c + '\'';
        }
        strBundleQuery += ' ORDER BY Name, Order__c';
        System.debug('--strBundleQuery---'+strBundleQuery);
        List<Product_Group__c> listOfProductGroup = (List<Product_Group__c>)Database.query(strBundleQuery);
        return listOfProductGroup;
    }
    
    public List<SelectOption> getProductVersion(){
        System.debug('objOpty.Account.Pricesheet_Permission__c' + objOpty.Account.Pricesheet_Permission__c);
        System.debug('objOpty.BusinessPartner__r.Pricesheet_Permission__c' + objOpty.BusinessPartner__r.Pricesheet_Permission__c);
        System.debug('UserInfo.getUserType()' + UserInfo.getUserType());
        List<SelectOption> options = new List<SelectOption>();            
        if(objOppQuoteCategory.Offering_Details__c == 'Subscription'){
            options.add(new SelectOption('CIC 4.0', 'CIC 4.0'));    
        }
        else{
            Schema.DescribeFieldResult fieldResult = Admin_Dummy__c.Product_Version__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple){
                if(!f.getLabel().contains('Benelux') 
                   || (f.getLabel().contains('Benelux') && objOpty.Account.Pricesheet_Permission__c != null
                       && objOpty.Account.Pricesheet_Permission__c.toLowerCase().contains('benelux'))
                   || (f.getLabel().contains('Benelux') && objOpty.BusinessPartner__r.Pricesheet_Permission__c != null
                       && objOpty.BusinessPartner__r.Pricesheet_Permission__c.toLowerCase().contains('benelux')) 
                   || UserInfo.getUserType() != 'PowerPartner'
                  )
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                
            }       
        }
        return options;    
    }
    
    //Anju June 2018 PCC product tier 
    public List<SelectOption> getproductTier(){
        List<SelectOption> options = new List<SelectOption>();            
        Schema.DescribeFieldResult fieldResult = Admin_Dummy__c.Product_Tier__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry f : ple){
            if(((objOpty.Type == 'New logo' || objOpty.Cloud_Renewal__c) && f.getLabel() == 'Enterprise') || (objOpty.Type != 'New logo' && !objOpty.Cloud_Renewal__c))
                options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        
        return options;    
    }
    
    // creates quote and redirects to respective quote page
    public PageReference createQuoteAndGoToQuote(){        
        isAlreadySelect = false;
        //selectedSubscrToAmend = ApexPages.CurrentPage().getParameters().get('subscrId');
        System.debug('selectedSubscrToAmend... '+selectedSubscrToAmend);
        Set<Id> setOfUseCaseIds = new Set<Id>();
        if(listOfUseCases != null && listOfUseCases.size() > 0){
            for(Product_Group__c eachPG : listOfUseCases){
                if(eachPG.Selected__c){
                    setOfUseCaseIds.add(eachPG.id);
                }    
            }
        }
        if(map_PlayCategoryListPlayOffer != null && map_PlayCategoryListPlayOffer.size() > 0){
            System.debug('-map_PlayCategoryListPlayOffer--'+map_PlayCategoryListPlayOffer);
            for(String key : map_PlayCategoryListPlayOffer.keySet()){
                for(PlayOfferWrapper eachPG : map_PlayCategoryListPlayOffer.get(key)){
                    System.debug('-setOfUseCaseIds--'+setOfUseCaseIds);
                    System.debug('--eachPG-'+eachPG);
                    if(eachPG.isSelected){
                        System.debug('--eachPG.Selected__c-');
                        if(!setOfUseCaseIds.contains(eachPG.prdGrp.Id)){
                            setOfUseCaseIds.add(eachPG.prdGrp.id);
                        }else{
                            isAlreadySelect = true;
                        }
                    }    
                }
            }
        }
        
        if(isAlreadySelect){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Use Cases can only be selected once, please remove any duplicate selections.'));
            return null;
        }
        
        // populating opportunities field value from dummy object 
        objOpty.Lines_of_Businesses__c = objOppQuoteCategory.Offering_Type__c;
        objOpty.Primary_Line_of_Business__c = objOppQuoteCategory.Platform_Type__c;
        objOpty.Quote_Type1__c = objOppQuoteCategory.Quote_Type__c;
        objOpty.Product_Version__c = objOppQuoteCategory.Product_Version__c;
        objOpty.Product_Tier__c = objOppQuoteCategory.Product_Tier__c;
        objOpty.Offering_Detail__c = objOppQuoteCategory.Offering_Details__c;
        // setting up page reference as null by default
        PageReference bigMachinesQuotePage = null;
        
        // opportunity validations
        if (objOpty.Lines_of_Businesses__c == null || objOpty.Primary_Line_of_Business__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select both Offering and Platform Type.'));
            return null;
        } 
        else {
            // country validation
            if (objOpty.Primary_Line_of_Business__c == 'Cloud' 
                //Added By Ranjith on Jun 12, 2017 -- Starts
                && objOpty.Lines_of_Businesses__c != 'PureConnect' 
                //Added By Ranjith on Jun 12, 2017 -- Ends
                && objOpty.Quote_Type1__c == 'Business Edition') {
                    if (objOpty.Sold_To_Country__r.name != 'United States' &&
                        objOpty.Sold_To_Country__r.name != 'Ireland' &&
                        objOpty.Sold_To_Country__r.name != 'United Kingdom' &&
                        objOpty.Sold_To_Country__r.name != 'Canada' &&
                        objOpty.Sold_To_Country__r.RU__c != 'ANZ') {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please note Cloud quoting is only enabled for United States,Canada,Ireland,United Kingdom and the ANZ region.'));
                            return null;
                        }
                }
            // UKI validation            
            if (objOpty.Primary_Line_of_Business__c == 'Cloud' 
                //Added By Ranjith on Jun 12, 2017 -- Starts. 
                //Naresh 07/06/2017 - Changing condition to == "PureEngage" as it wouldn't let create PureCloud Quote for UKI opp.
                //&& objOpty.Lines_of_Businesses__c != 'PureConnect' 
                && objOpty.Lines_of_Businesses__c == 'PureEngage' 
                //Added By Ranjith on Jun 12, 2017 -- Ends
                && (objOpty.currencyIsoCode == 'GBP' || objOpty.currencyIsoCode == 'Euro') 
                && objOpty.Quote_Type1__c != 'Enterprise Edition' 
                && objOpty.Quote_Type1__c != 'Social Analytics'
                && objOpty.Quote_Type1__c != 'Cloud Partner (PPU)'
                && objOppQuoteCategory.Quote_Type__c != 'PureEngage Cloud' ) { 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You can only select Premier/Business Edition with UKI.'));
                    return null;
                }
            // enterprise edition validation
            if (objOpty.Lines_of_Businesses__c == 'PureEngage' && objOpty.Primary_Line_of_Business__c == 'Cloud' && objOpty.Quote_Type1__c == 'Enterprise Edition') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Enterprise Edition is currently unavailable for quoting for Cloud. Please select Business Edition instead.'));
                return null;
            }
            
            System.debug('@Inside createQuoteAndGoToQuote ' + blnShowBaseAndPureSuccessPackage);
            
            //Validating the selection of puresuccess package.
            if(blnShowBaseAndPureSuccessPackage && listOfPureSuccessPackages != null && !listOfPureSuccessPackages.isEmpty()){
                
                System.debug('@Inside createQuoteAndGoToQuote ' + listOfPureSuccessPackages);
                
                Boolean blnPureSuccessPackageSelected = false;
                for(Product_Group__c eachPG : listOfPureSuccessPackages){
                    System.debug('NKC debug eachPG [' + eachPG + ']');
                    if(eachPG.Selected__c){
                        blnPureSuccessPackageSelected = true;
                        break;
                    }                
                }
                if(!blnPureSuccessPackageSelected && objOppQuoteCategory.Quote_Type__c != 'PureCloud'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select PureSuccess Package.'));
                    return null;    
                }
            }
            
            System.debug('NKC debug objOpty.Lines_of_Businesses__c [' + objOpty.Lines_of_Businesses__c + ']');
            System.debug('NKC debug objOpty.Primary_Line_of_Business__c [' + objOpty.Primary_Line_of_Business__c + ']');       
            System.debug('NKC debug objOpty.Offering_Detail__c [' + objOpty.Offering_Detail__c + ']');
            // Check if the curreny quote 
            //Subscription Quoting
            if (objOpty.Lines_of_Businesses__c == 'PureEngage' && objOpty.Primary_Line_of_Business__c == 'On Premise' && objOpty.Offering_Detail__c == 'Subscription'){
                if(strSelectedOrderType == 'Amend' || strSelectedOrderType == 'Subscription') {
                    System.debug('######selectedSubscrToAmend: ' + map_Subscriptions);
                    System.debug('######selectedSubscrToAmend: ' + selectedSubscrToAmend);
                    if(selectedSubscrToAmend != null) {
                        System.debug('######selectedSubscrToAmend: ' + selectedSubscrToAmend);
                        bigMachinesQuotePage = createAmendPureEngageOrPureConnectSubscriptionQuote();
                    }
                    else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select an existing subscription to amend before proceeding.'));
                        return null;
                    }
                }
                else {                    
                    bigMachinesQuotePage = createPureEngageSubscriptionQuote();
                }
            }
            else if (objOpty.Lines_of_Businesses__c == 'PureConnect' && objOpty.Primary_Line_of_Business__c == 'On Premise' && objOpty.Offering_Detail__c == 'Subscription'){
                if(strSelectedOrderType == 'Amend' || strSelectedOrderType == 'Subscription') {
                    System.debug('######selectedSubscrToAmend: ' + selectedSubscrToAmend);
                    if(selectedSubscrToAmend != null) {
                        System.debug('######selectedSubscrToAmend: ' + selectedSubscrToAmend);
                        bigMachinesQuotePage = createAmendPureEngageOrPureConnectSubscriptionQuote();
                    }
                    else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select an existing subscription to amend before proceeding.'));
                        return null;
                    }
                }
                else {                    
                    bigMachinesQuotePage = createPureConnectSubscriptionQuote();                        
                }                
            }                
            // PPU Quote
            else if (objOpty.Lines_of_Businesses__c == 'PureEngage' && objOpty.Primary_Line_of_Business__c == 'Cloud' && objOpty.Quote_Type1__c == 'Cloud Partner (PPU)')
                bigMachinesQuotePage = createPPUQuote();
            // Cloud Quote
            else if (objOpty.Lines_of_Businesses__c == 'PureEngage' && objOpty.Primary_Line_of_Business__c == 'Cloud' && objOpty.Quote_Type1__c != 'PureEngage Cloud')
                bigMachinesQuotePage = createCloudQuote(); 
            // PureConnect CIC Quote
            else if (objOpty.Lines_of_Businesses__c == 'PureConnect' && objOpty.Quote_Type1__c == QuoteUtil.OFFERING_TYPE_CIC)
                bigMachinesQuotePage = createCICQuote();            
            // PureConnect CaaS Quote Anju july 2018 commented for PCC subscriptions
            //else if (objOpty.Lines_of_Businesses__c == 'PureConnect' && objOpty.Quote_Type1__c == QuoteUtil.OFFERING_TYPE_CAAS)
            //bigMachinesQuotePage = createCaaSOrPureCloudQuote(); 
            // On Premise Quote
            else if (objOpty.Lines_of_Businesses__c == 'PureEngage' && objOpty.Primary_Line_of_Business__c == 'On Premise' && objOpty.Quote_Type1__c == QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE)
                bigMachinesQuotePage = createOnPremiseQuote();
            // PureCloud Quote
            //Anju  July 2018 PCC subscriptions added PCC condition
            // objOpty.Quote_Type1__c == 'PureEngage Cloud'
            // ECD PEC Quote July 2019
            else if ((objOpty.Quote_Type1__c == 'PureEngage Cloud') || objOpty.Lines_of_Businesses__c == 'PureCloud' || (objOpty.Lines_of_Businesses__c == 'PureConnect' && objOpty.Quote_Type1__c == QuoteUtil.OFFERING_TYPE_CAAS))
                //bigMachinesQuotePage = new PageReference('/apex/zqu__QuoteOption?Id=' + objOpty.id);
                if(strSelectedOrderType == 'Amend') {
                    System.debug('######selectedSubscrToAmend: ' + selectedSubscrToAmend);
                    if(selectedSubscrToAmend != null) {
                        if(strSubscrSubType != 'Replace Existing Subscription') {                            
                            bigMachinesQuotePage = createAmendPureCloudQuote();
                        }
                        else {
                            bigMachinesQuotePage = createCaaSOrPureCloudQuote();
                        }
                    }
                    else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select an existing subscription to amend before proceeding.'));
                        return null;
                    }
                }
            else {              
                bigMachinesQuotePage = createCaaSOrPureCloudQuote(); 
            }
            // Redirects the page
            if (bigMachinesQuotePage != null)
                bigMachinesQuotePage.setRedirect(true);
        }
        if(blnIsPrimaryQuote){
            update objOpty;
        }
        return bigMachinesQuotePage;
    }
    // creates quote and redirects to respective deal qualification page
    public PageReference redirectToRespectiveDQ() {  
        // default pricing type to New Pricing
        if(objOppQuoteCategory.Pricing__c == null)
            objOppQuoteCategory.Pricing__c = 'New Pricing';
        String offeringType = objOppQuoteCategory.Offering_Type__c;
        if(objOppQuoteCategory.Offering_Details__c == 'Subscription' && (offeringType == 'PureEngage' || offeringType == 'PureConnect')){
            offeringType = offeringType + ' Subscription';    
        }
        else
            offeringType = objOppQuoteCategory.Quote_Type__c;        
        System.debug('NKC debug offeringType [' + offeringType + ']');
        System.debug('NKC debug objOppQuoteCategory.Offering_Type__c [' + objOppQuoteCategory.Offering_Type__c + ']');
        System.debug('NKC debug objOppQuoteCategory.Quote_Type__c [' + objOppQuoteCategory.Quote_Type__c + ']');
        
        // redirect to standard deal qualification page which will further redirect accordingly
        String pageName = DealQualificationApprovalUtil.getRespectiveDQPageName(objOppQuoteCategory.Platform_Type__c, offeringType);
        PageReference DQPageRef = new PageReference('/apex/' + pageName  + '?oppId=' + objOpty.id 
                                                    + '&pt=' + objOppQuoteCategory.Platform_Type__c  
                                                    + '&ot=' + offeringType 
                                                    + '&od=' + objOppQuoteCategory.Offering_Details__c                                                     
                                                    + '&p=' + objOppQuoteCategory.Pricing__c 
                                                    + '&NO_REDIRECT=true');
        System.debug('NKC debug pageName [' + pageName + ']');        
        DQPageRef.setRedirect(true);
        return DQPageRef;
    }
    // handles up/down-grade opportunity
    public pageReference goToCloneQuoteIfOppIsDownUpGrade() {
        String optyId = ApexPages.CurrentPage().getParameters().get('oppId');
        Opportunity opp = [SELECT Is_Downgrade__c, Is_Upgrade__c FROM Opportunity WHERE id =: optyId];
        if (opp.Is_Downgrade__c || opp.Is_Upgrade__c) {
            String param;
            if (opp.Is_Downgrade__c)
                param = 'Downgrade';
            else
                param = 'Upgrade';
            PageReference newPR = new PageReference('/apex/CloneQuoteForUpgradeDowngrade?oppId=' + optyId + '&param=' + param);
            newPR.setRedirect(true);
            return newPR;
        } 
        return null;
    }
    
    public pageReference repopulateQuoteType() {return null;}
    
    // method to create On Premise Quote and return it's page reference
    public pageReference createOnPremiseQuote() {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.BigMachines__Opportunity__c = objOpty.Id;
        objQuote.Quote_Created_Date__c = System.today();
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.Grid_Group_By__c = 'Categories';
        objQuote.Service_Level__c = 'Business';         
        objQuote.Pricing_Model__c = 'Enabled'; 
        objQuote.Offering_Type__c = null;//objOpty.Quote_Type1__c;
        objQuote.Conversion_Quote__c = objOppQuoteCategory.Conversion_Quote__c;
        objQuote.Order_Type__c=objOppQuoteCategory.Order_Type__c;
        if(objQuote.Conversion_Quote__c == 'Enabled to Concurrent')
            objQuote.Pricing_Model__c = 'Concurrent';
        else
            objQuote.Pricing_Model__c = 'Enabled';
        //if (objOpty.PricingType__c == 'Old / Legacy Pricing')
        if(objOppQuoteCategory.Pricing__c== 'Old Pricing')
            objQuote.Quote_Opportunity_Type__c = 'Old Pricing';
        else
            objQuote.Quote_Opportunity_Type__c = 'New Pricing';
        
        objQuote.Order_Numb_of_Maint_Months__c = 12;
        objQuote.Duration_Unit__c = 'Months';
        
        // Added by Ashish (25/01)
        objQuote.Top_Play__c = selectedPlayOffer;
        objQuote.Offer__c = selectedPlayOfferType;
        
        if(objOppQuoteCategory.Offering_Details__c == 'Rental'){
            system.debug('navanee1');
            objQuote.PPU_Rental__c = true;
        }
        
        if ([SELECT count() FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: objOpty.id] == 0) {
            objQuote.Is_Business_Primary__c = true; 
            objQuote.BigMachines__Is_Primary__c = true;
            blnIsPrimaryQuote = true;
            if(objQuote.PPU_Rental__c == true)
                updateLeadOfferOnOpportunity('PureEngage Premise Rental');
            else
                updateLeadOfferOnOpportunity('PureEngage Premise');
            
        }
        // PureBridge Lever Populate
        map_leverSelection = new map<string,boolean>();
        if(pbLevers.size() > 0){
            String strLever = '';
            for(PBLever objLever : pbLevers ){
                if(objLever.isSelected){
                    map_leverSelection.put(objLever.lever,true);
                    strLever = strLever + objLever.lever + ';';
                }   
                System.debug('###strLever'+strLever);
            }
            if(objQuote.Order_type__c=='New')
                objQuote.Lever__C = strLever;
        }
        if(objQuote.Lever__c!=null && objQuote.Lever__C.contains( 'Lever 5' ) && objQuote.Duration_Unit__c == 'Months')
            objQuote.Order_Numb_of_Maint_Months__c = 18;
        
        /**/
        // Example : Basic Care-New(End User)
        String strGCProdName = objQuote.Service_Level__c + ' Care-New';
        
        if (objOpty.AccountId != null) {
            objQuote.End_User_ID__c = objOpty.AccountId;
            objQuote.BigMachines__Account__c = objOpty.AccountId;
        }
        
        if (objOpty.BusinessPartner__c != null)
            objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c;
        else
            objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
        
        if (objOpty.Sold_To_Country__c != null) {
            //if(selectedPricingOption == 'New Pricing')
            //if (objOpty.PricingType__c == 'New / Simplified pricing')
            if(objOppQuoteCategory.Pricing__c!= 'Old Pricing')
                objQuote.New_Price_Book__c = objOpty.Sold_To_Country__r.New_Price_Book__c;
            else
                objQuote.New_Price_Book__c = objOpty.Sold_To_Country__r.Old_Price_Book__c;
        } else {
            if (objOpty.BusinessPartner__c != null) {
                objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c;
                //if(selectedPricingOption == 'New Pricing')
                //if (objOpty.PricingType__c == 'New / Simplified pricing')
                if(objOppQuoteCategory.Pricing__c!= 'Old Pricing')
                    objQuote.New_Price_Book__c = objOpty.BusinessPartner__r.Country__r.New_Price_Book__c;
                else
                    objQuote.New_Price_Book__c = objOpty.BusinessPartner__r.Country__r.Old_Price_Book__c;
            }
        }
        // If Direct sale, pre-populate sold to with end user info
        if (objOpty.Direct_Sales__c) {
            objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
            strGCProdName += '(End User)';
        } else
            strGCProdName += '(Partner)';
        
        if (objOpty.Support_Owner__c != null)
            objQuote.Support_Owner__c = objOpty.Support_Owner__c;
        
        if (objOpty.System_Integrator__c != null)
            objQuote.System_Integrator__c = objOpty.System_Integrator__c;
        
        objQuote.CurrencyISOCode = objOpty.CurrencyISOCode;
        objQuote.Quote_Business_Type__c = 'On Premise';
        
        // Default quote expiration after 90 days
        objQuote.Expiration_Date__c = Date.today().addDays(90);
        if(objQuote.Top_Play__c == PRIMARY_PLAY)
            objQuote.Order_Numb_of_Maint_Months__c = PRIMARY_PLAY_MONTHS;
        BigMachines__Quote_Product__c objServiceLevel = null;
        List < Product2 > list_Temp1 = [SELECT Id, Name, Unit_of_Measure__c
                                        FROM Product2 WHERE Description =: strGCProdName AND
                                        Genesys_Care_Quote__c = true AND IsActive = true
                                       ];
        if (list_Temp1.size() > 0) {
            objServiceLevel = new BigMachines__Quote_Product__c(BigMachines__Quantity__c = 1,
                                                                BigMachines__Sales_Price__c = 0);
            objServiceLevel.Name = list_Temp1[0].Name;
            objServiceLevel.Unit_of_Measure__c = list_Temp1[0].Unit_of_Measure__c;
            objServiceLevel.BigMachines__Product__c = list_Temp1[0].Id;
            objServiceLevel.Line_Number__c = ++intLineNumber;//-Navaneetha - Nov 28th 2019 - Used to track the line number for the quote product level-
            if(objQuote.Top_Play__c == PRIMARY_PLAY){
                objServiceLevel.Disc__c = PRIMARY_PLAY_DISCOUNT;
            }
        }
        
        try {
            insert objQuote;
            
            /** PureBridge Lever 2 Change for Engage Premise)**/ 
            System.debug('@@Lever'+objOpty.Lever__c);
            if(objQuote.Lever__c !=null && objQuote.Lever__c.contains('Lever 2') && objOpty.Avaya_Contract_Expiration__c !=null  ){
                objQuote = QuoteUtil.updateLeverDetials(objQuote,objOpty);
            }
            /** PureBridge END**/
            objQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: objQuote.id].Quote_Number__c;
            update objQuote;
            
            if (objServiceLevel != null) {
                objServiceLevel.BigMachines__Quote__c = objQuote.Id;
                insert objServiceLevel;
            }
            //Below line added by Ankit on 5/31/2017
            if(blnIsPrimaryQuote)
                objOpty.Primary_Quote__c = objQuote.id;
            //Adding use cases
            addUseCases(objQuote);
            return (new PageReference('/apex/CreateQuoteOnPremise1?id=' + objQuote.Id));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }
        return null;
    }
    
    // method to create On Premise PureConnect CIC Quote and return it's page reference
    public pageReference createCICQuote() {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.BigMachines__Opportunity__c = objOpty.Id;
        objQuote.Quote_Created_Date__c = System.today();
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.Grid_Group_By__c = 'Categories';
        objQuote.Service_Level__c = 'Business';    
        objQuote.Pricing_Model__c = 'Enabled';
        objQuote.Offering_Type__c = objOpty.Quote_Type1__c;
        objQuote.Quote_Business_Type__c = objOpty.Primary_Line_of_Business__c ;
        objQuote.Product_Version__c = objOpty.Product_Version__c;
        objQuote.Order_Type__c = objOppQuoteCategory.Order_Type__c;
        objQuote.Top_Play__c = selectedPlayOffer;
        objQuote.Offer__c = selectedPlayOfferType;
        objQuote.Conversion_Quote__c = objOppQuoteCategory.Conversion_Quote__c;
        if(objQuote.Conversion_Quote__c == 'Enabled to Concurrent')
            objQuote.Pricing_Model__c = 'Concurrent';
        else
            objQuote.Pricing_Model__c = 'Enabled';
        //if(selectedPricingOption == 'New Pricing')
        if (objOpty.PricingType__c == 'Old / Legacy Pricing')
            objQuote.Quote_Opportunity_Type__c = 'Old Pricing';
        else
            objQuote.Quote_Opportunity_Type__c = 'New Pricing';
        
        objQuote.Order_Numb_of_Maint_Months__c = 12;       
        objQuote.Duration_Unit__c = 'Months';
        
        if(objOppQuoteCategory.Offering_Details__c == 'Rental'){
            system.debug('navanee2');
            objQuote.PPU_Rental__c = true;
        }
        if ([SELECT count() FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: objOpty.id] == 0) {
            objQuote.Is_Business_Primary__c = true;
            objQuote.BigMachines__Is_Primary__c = true;            
            blnIsPrimaryQuote = true;
            if(objQuote.PPU_Rental__c == true)
                updateLeadOfferOnOpportunity('PureConnect Premise Rental');
            else
                updateLeadOfferOnOpportunity('PureConnect Premise');
        }
        
        // PureBridge Lever Populate
        map_leverSelection = new map<string,boolean>();
        if(pbLevers.size() > 0){
            String strLever = '';
            for(PBLever objLever : pbLevers ){
                if(objLever.isSelected){
                    map_leverSelection.put(objLever.lever,true);
                    strLever += objLever.lever + ';';
                }   
                System.debug('###strLever'+strLever);
            }
            if(objQuote.Order_Type__c=='New')
                objQuote.Lever__C = strLever;
        }
        
        if(objQuote.Lever__c!=null && objQuote.Lever__C.contains( 'Lever 5' ) && objQuote.Duration_Unit__c == 'Months')
            objQuote.Order_Numb_of_Maint_Months__c = 18;
        
        /***/
        // Example : Basic Care-New(End User)
        String strGCProdName = 'Standard Support';
        Decimal maintenanceDiscount = 0;
        Decimal genesysCareRate = 0;
        if (objOpty.AccountId != null) {
            String strAccountId = objopty.BusinessPartner__c;
            if(strAccountId == null)
                strAccountId = objOpty.AccountId;
            objQuote.End_User_ID__c = objOpty.AccountId;
            objQuote.BigMachines__Account__c = objOpty.AccountId;
            // populating support options from end user account
            Account endUserAccount = [SELECT Support_Option__c, Maintenance_Discount_Pct__c, Maintenance_Discount_Effective_Date__c,
                                      Maintenance_Discount_Expiration_Date__c, Country__r.Standard_Support__c,
                                      Country__r.Priority_Support__c, Country__r.VIP_Priority_Support__c FROM Account WHERE id=: strAccountId];
            
            if(endUserAccount.Support_Option__c == null || (endUserAccount.Support_Option__c != 'Priority Support' 
                                                            && endUserAccount.Support_Option__c != 'VIP Priority Support')){
                                                                endUserAccount.Support_Option__c = 'Standard Support';
                                                            }            
            objQuote.Support_Options__c = endUserAccount.Support_Option__c;
            
            if(endUserAccount.Maintenance_Discount_Effective_Date__c <= System.today() 
               && endUserAccount.Maintenance_Discount_Expiration_Date__c > System.today()){
                   maintenanceDiscount = endUserAccount.Maintenance_Discount_Pct__c;
               }
            
            if(endUserAccount.Support_Option__c != null)
                strGCProdName = endUserAccount.Support_Option__c;
            if(strGCProdName == 'Standard Support')
                genesysCareRate = endUserAccount.Country__r.Standard_Support__c;
            else if(strGCProdName == 'Priority Support')
                genesysCareRate = endUserAccount.Country__r.Priority_Support__c;
            else if(strGCProdName == 'VIP Priority Support')
                genesysCareRate = endUserAccount.Country__r.VIP_Priority_Support__c;            
            if(genesysCareRate == null)
                genesysCareRate = 0;
        }
        
        if (objOpty.BusinessPartner__c != null)
            objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c;
        else
            objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
        
        objQuote.New_Price_Book__c = QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode);
        
        if (objOpty.BusinessPartner__c != null) {
            objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c;            
        }
        
        if (objOpty.Support_Owner__c != null)
            objQuote.Support_Owner__c = objOpty.Support_Owner__c;
        
        if (objOpty.System_Integrator__c != null)
            objQuote.System_Integrator__c = objOpty.System_Integrator__c;
        
        objQuote.CurrencyISOCode = objOpty.CurrencyISOCode;
        
        // Default quote expiration after 30 days
        objQuote.Expiration_Date__c = Date.today().addDays(30);
        
        // If Direct sale, pre-populate sold to with end user info
        if (objOpty.Direct_Sales__c) {
            objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
            strGCProdName += ' - New (End User)';
        } else
            strGCProdName += ' - New (Partner)';        
        System.debug('NKC debug strGCProdName [' + strGCProdName +']');
        if(objQuote.Top_Play__c == PRIMARY_PLAY)
            objQuote.Order_Numb_of_Maint_Months__c = PRIMARY_PLAY_MONTHS;
        BigMachines__Quote_Product__c objServiceLevel = null;
        List < Product2 > listOfProducts = [SELECT Id, Name, Unit_of_Measure__c, Genesys_Care_Rate__c
                                            FROM Product2 WHERE Product_Type__c =: strGCProdName AND Genesys_Care_Quote__c = true AND IsActive = true];
        if (!listOfProducts.isEmpty()) {
            objServiceLevel = new BigMachines__Quote_Product__c(BigMachines__Quantity__c = 1,
                                                                BigMachines__Sales_Price__c = 0);
            objServiceLevel.Name = listOfProducts[0].Name;
            objServiceLevel.Unit_of_Measure__c = listOfProducts[0].Unit_of_Measure__c;
            objServiceLevel.BigMachines__Product__c = listOfProducts[0].Id;
            objServiceLevel.Line_Number__c = ++intLineNumber;//-Navaneetha - Nov 28th 2019 - Used to track the line number for the quote product level-
            if(objQuote.Top_Play__c == PRIMARY_PLAY){
                objServiceLevel.Disc__c = PRIMARY_PLAY_DISCOUNT;
            }
            //if(listOfProducts[0].Genesys_Care_Rate__c != null)
            //  genesysCareRate = listOfProducts[0].Genesys_Care_Rate__c;
            if(genesysCareRate > 0 && maintenanceDiscount > 0){
                genesysCareRate -= genesysCareRate * maintenanceDiscount / 100;
            }
            objQuote.Genesys_Care_Rate__c = genesysCareRate;
            if(objQuote.PPU_Rental__c){
                objQuote.Genesys_Care_Default_Pricing_Percentage__c = 0;
                objQuote.Genesys_Care_Rate__c = 0;
            }
            else
                objQuote.Genesys_Care_Default_Pricing_Percentage__c = genesysCareRate;
        }
        try {
            insert objQuote;
            /** PureBridge Lever 2 Change for CIC Premise)**/ 
            System.debug('@@Lever'+objOpty.Lever__c);
            if(objQuote.Lever__c !=null && objQuote.Lever__c.contains('Lever 2') && objOpty.Avaya_Contract_Expiration__c !=null ){
                objQuote = QuoteUtil.updateLeverDetials(objQuote,objOpty);
            }
            /** PureBridge END**/
            objQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: objQuote.id].Quote_Number__c;
            update objQuote;
            
            if (objServiceLevel != null) {
                objServiceLevel.BigMachines__Quote__c = objQuote.Id;
                insert objServiceLevel;
            }
            
            //Below line added by Ankit on 5/31/2017
            if(blnIsPrimaryQuote)
                objOpty.Primary_Quote__c = objQuote.id;
            //Adding use cases
            addUseCases(objQuote);
            return (new PageReference('/apex/CreateQuoteCIC?id=' + objQuote.Id));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }
        return null;
    }
    
    //Added By Ranjith on Oct 24, 2017 -- Starts
    // method to create PureConnect Cloud or PureCloud Quote and return it's page reference
    public pageReference createAmendPureCloudQuote() {   
        BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c();
        Set<Id> set_ProductIds = new Set<Id>();
        List<BigMachines__Quote__c> list_Quotes = new List<BigMachines__Quote__c>();      
        Map<String, RecordType> map_QuoteRecTypes = QuoteCloudUtil.getRecordTypes('BigMachines__Quote__c');
        
        System.debug('######selectedSubscrToAmend: '+selectedSubscrToAmend);
        Subscription__c objSubscription = map_Subscriptions.get(selectedSubscrToAmend);
        Id selectedSubscrQuoteId = map_Subscriptions.get(selectedSubscrToAmend).Quote__c;
        System.debug('######selectedSubscrQuoteId: '+selectedSubscrQuoteId);
        
        String strQuoteQuery = 'SELECT ';
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuoteQuery += field.getFieldPath() + ', ';
        strQuoteQuery += 'BigMachines__Opportunity__r.Account.Partner_Tier__c FROM BigMachines__Quote__c WHERE Id = \'' + selectedSubscrQuoteId + '\'';
        if(selectedSubscrQuoteId != null) {    
            list_Quotes = (List<BigMachines__Quote__c>)Database.query(strQuoteQuery);
        }
        if(list_Quotes.size() > 0) {
            objNewQuote = list_Quotes[0].clone(false, true, false, false);
            objNewQuote = SubscriptionUtil.buildQuoteFromSubscr(objSubscription, objNewQuote);
        }
        else {
            objNewQuote = SubscriptionUtil.buildQuoteFromSubscr(objSubscription, null);
            objNewQuote.RecordTypeId = map_QuoteRecTypes.get('Cloud Quote').Id;
            objNewQuote.Quote_Created_Date__c = System.today();
            objNewQuote.Grid_Group_By__c = 'Recurring/Non-Recurring';
            objNewQuote.Group_Product_By__c = 'Standard View';
            objNewQuote.Pricing_Model__c = 'Named';
            objNewQuote.Renewal_Subscription_Term__c = 'Automatic Monthly';
            objNewQuote.Delivery_Method__c = 'Electronic';
            objNewQuote.Payment_Method__c = 'ACH';
            objNewQuote.Expiration_Date__c = Date.today().addMonths(1);
            objNewQuote.Quote_Business_Type__c = 'Cloud';
            objNewQuote.Selling_Entity__c = objOpty.Country_Selling_Entity__c;
            objNewQuote.MSA_Link__c = getMSALink(objNewQuote.Offering_Type__c); 
            objNewQuote.Quote_Opportunity_Type__c = 'New Pricing';           
        }
        System.debug('######objNewQuote: '+objNewQuote);
        //Anju June CCDB
        objNewQuote.Renewal_Subscription_Term__c = 'Automatic Monthly';
        objNewQuote.Contract_Signature_Date__c = null;
        objNewQuote.Order__c = null;
        objNewQuote.Order_Date_Submitted__c = null;
        objNewQuote.BigMachines__Opportunity__c = objOpty.Id;
        objNewQuote.BigMachines__Is_Primary__c = false;
        objNewQuote.Is_Business_Primary__c = false;
        objNewQuote.BigMachines__Status__c = 'Quote In Progress';
        objNewQuote.Amendment_For__c = selectedSubscrToAmend;
        objNewQuote.Include_Special_Offer_in_Output__c = false;
        objNewQuote.Special_Offer_Terms__c = objSubscription.Order_Special_Offer__c;//Added by Dekshant for CCDB
        objNewQuote.Incentive_Rebate__c = null;
        objNewQuote.Order_PO_Number__c = '';
        objNewQuote.Order_PO_Date__c = null;
        objNewQuote.Order_Special_Instructions__c = '';
        objNewQuote.Order_PO_Received_Date__c = null;
        objNewQuote.Sale_Type__C = objOpty.Direct_Indirect_Sale__c;
        objNewQuote.Expiration_Date__c = Date.today().addMonths(1);//Rony Joseph -Added to Standardise Expiry date calculation
        if(strSubscrSubType == 'Renew Existing Subscription') {
            objNewQuote.Order_Type__c = Label.Renew_Subscription;
            objNewQuote.MSA_Link_Type__c = (objOpty.MSA_Link_Type__c == 'Custom') ? 'Custom' : 'Standard';
            objNewQuote.MSA_Link__c = objOpty.MSA_Link_Type__c == 'Custom' ? objOpty.MSA_Link__c : getMSALink(objNewQuote.Offering_Type__c);
            objNewQuote.Renewal_Subscription_Term__c = 'Automatic Monthly';
            objNewQuote.Billing_Start_Date__c = objNewQuote.Subscription_End_Date__c + 1;
            objNewQuote.Subscription_Start_Date__c = objNewQuote.Subscription_End_Date__c + 1;
            objNewQuote.Subscription_End_Date__c = objNewQuote.Subscription_Start_Date__c.addMonths(Integer.valueOf(objNewQuote.No_Of_Months__c))-1;
            objNewQuote.Ramp_Period__c = '0';
            objNewQuote.Keep_the_existing_estate_on_Perpetual__c = objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC ? True : False;
            objNewQuote.Overage_Allowance__c ='20%';
        }
        else {
            objNewQuote.Order_Type__c = Label.Amend_Subscription;
            objNewQuote.MSA_Link_Type__c = ((objOpty.MSA_Link_Type__c == 'Custom')|| (objSubscription.MSA_Link_Type__c == 'Custom')) ? 'Custom' : 'Standard';
            objNewQuote.MSA_Link__c = objOpty.MSA_Link_Type__c == 'Custom' ? objOpty.MSA_Link__c : (objSubscription.MSA_Link_Type__c == 'Custom' ? objSubscription.MSA_Link__c : getMSALink(objNewQuote.Offering_Type__c));        
                objNewQuote.Subscription_Amend_Date__c = Date.today();
            if(objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC &&  objNewQuote.PureSuccess__c != null)
                objNewQuote.Does_customer_currently_have_PureSuccess__c = True;          
        }        
        objNewQuote.No_Of_Months__c = objNewQuote.Subscription_Start_Date__c.monthsBetween(objNewQuote.Subscription_End_Date__c);
        //Anju : PCC if original CCDB is M2M, change to Annual prepay
        if(objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC && objNewQuote.Billing_Category__c == 'M2M')
        {
            objNewQuote.No_Of_Months__c = 12;
            objNewQuote.Initial_Subscription_Term__c = '1 Year';
            objNewQuote.Billing_Category__c = 'Annual Pre-Pay';
            objNewQuote.Billing_Period__c = 'Annually';
            objNewQuote.Subscription_End_Date__c = objNewQuote.Subscription_Start_Date__c.addMonths(Integer.valueOf(objNewQuote.No_Of_Months__c))-1;
        }
        if([SELECT count() FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :objOpty.Id] == 0) {
            objNewQuote.Is_Business_Primary__c = true;
            objNewQuote.BigMachines__Is_Primary__c = true;
            blnIsPrimaryQuote = true;
            updateLeadOfferOnOpportunity(objNewQuote.Offering_Type__c);
        }
        if(strSelectedOrderType == 'Amend'){
            objNewQuote.Top_Play__c = selectedPlayOffer;
            objNewQuote.Offer__c = selectedPlayOfferType;
        }
        if(objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC && strSubscrSubType == 'Renew Existing Subscription'){//Added to flip MSA Link type to Standard for PEC Renewal Quotes
            objNewQuote.MSA_Link_Type__c = 'Standard';
            objNewQuote.MSA_Link__c =  getMSALink(objNewQuote.Offering_Type__c);
        }
        Savepoint objSP = Database.setSavepoint();    
        try {
            insert objNewQuote;
            
            //objNewQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE Id =: objNewQuote.Id].Quote_Number__c;
            objNewQuote = QuoteCloudUtil.prepareQuotes(objNewQuote.Id);
            objNewQuote.Name = objNewQuote.Quote_Number__c;
            update objNewQuote;
            
            if(objNewQuote.Order_Type__c == Label.Amend_Subscription)
                QuoteCloudUtil.buildQuoteProductsForAmend(selectedSubscrToAmend, objNewQuote);
            else if(objNewQuote.Order_Type__c == Label.Renew_Subscription) {
                Util.Bypass_Trigger_Chk = true;
                QuoteCloudUtil.buildQuoteProductsForRenewal(selectedSubscrToAmend, objNewQuote);            
                List<BigMachines__Quote_Product__c> list_QuoteProducts = QuoteCloudUtil.prepareQuoteProducts(objNewQuote.Id);
                for(BigMachines__Quote_Product__c objQP : list_QuoteProducts ) {
                    set_ProductIds.add(objQP.BigMachines__Product__c);
                    set_InsertedProductIds.add(objQP.BigMachines__Product__c);
                }
                OpportunityCloudUtil.updateRunRate(new Set<Id> { objNewQuote.BigMachines__Opportunity__c });
                QuoteCloudUtil.updateQuoteTotalsForRenewal(objNewQuote, list_QuoteProducts);
                QuoteCloudUtil.updateOpportunityTotals(objNewQuote);            
                QuoteCloudUtil.createOpportunityLineItems(objNewQuote, list_QuoteProducts, set_ProductIds);
                Util.Bypass_Trigger_Chk = false;
            }
            addUseCases(objNewQuote);
            //Pull account order address and differentiate between ship to and other addresses
            if(selectedSubscrQuoteId != null) {   
                QuoteCloudUtil.cloneAccountOrderAddresses(selectedSubscrQuoteId, objNewQuote.Id);
            }
            String strReturnPage = objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ? '/apex/CreateQuoteCloudPC?id=' : objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC ? '/apex/CreateQuoteCloud?id=' : '/apex/CreateQuoteCloudPEC?id=';
            
            return (new PageReference(strReturnPage + objNewQuote.Id));
        } 
        catch(Exception e) {
            System.debug('###Exception has occured: '+ '\n'+e.getMessage()+'\n'+e.getStackTraceString() );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            Database.rollback(objSP);
        }
        return null;
    }
    //Added By Ranjith on Oct 24, 2017 -- Ends   
    
    //Naresh Kumar  11/12/2017
    // method to create PureEngage or PureConnect Subscription amended quote and return it's page reference
    public pageReference createAmendPureEngageOrPureConnectSubscriptionQuote() 
    {         
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        System.debug('######selectedSubscrToAmend: '+selectedSubscrToAmend);
        Id selectedSubscrQuoteId;
        Subscription__c objSubscription = map_Subscriptions.get(selectedSubscrToAmend);
        if(map_Subscriptions.get(selectedSubscrToAmend) != null)
            selectedSubscrQuoteId = map_Subscriptions.get(selectedSubscrToAmend).Quote__c;
        
        if(selectedSubscrQuoteId == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Quote details is missing on the subscription record. Please contact your system administrator.'));    
            return null;
        }
        System.debug('######selectedSubscrQuoteId: '+selectedSubscrQuoteId);
        
        String strQuoteQuery = 'SELECT ';
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuoteQuery += field.getFieldPath() + ', ';
        strQuoteQuery += 'BigMachines__Opportunity__r.Account.Partner_Tier__c FROM BigMachines__Quote__c WHERE Id = \'' + selectedSubscrQuoteId + '\'';
        BigMachines__Quote__c objNewQuote = (BigMachines__Quote__c)Database.query(strQuoteQuery)[0].clone(false, true, false, false);
        objNewQuote.Order__c = null;
        objNewQuote.BigMachines__Is_Primary__c = false;
        objNewQuote.Is_Business_Primary__c = false;
        objNewQuote.BigMachines__Status__c = 'Quote In Progress';
        objNewQuote.Amendment_For__c = selectedSubscrToAmend;
        objNewQuote.Order_Type__c = 'Amend';  
        objNewQuote.Offering_Feature__c = isSmallMediumCenter ? PCSUBSCR_SMALL_MED : null;      
        objNewQuote.Subscription_Amend_Date__c = Date.today().addMonths(3);
        objNewQuote.BigMachines__Opportunity__c = objOpty.id;
        System.debug('....'+objSubscription);
        System.debug('....'+objNewQuote);
        objNewQuote = SubscriptionUtil.buildQuoteFromSubscr(objSubscription, objNewQuote);
        //Reset quote order fields
        objNewQuote.Order_PO_Number__c = null;
        objNewQuote.Order_PO_Date__c = null;
        objNewQuote.Order_Special_Instructions__c = null;
        objNewQuote.Order_Ship_Software_Via__c = null;
        objNewQuote.Generate_Revpro_Order__c = false;
        objNewQuote.Server_OS__c = null;
        objNewQuote.PBX__c = null;
        objNewQuote.Database__c = null;
        objNewQuote.IVR__c = null;
        objNewQuote.Add_Language__c = null;
        objNewQuote.Ship_To_Name__c = null;
        objNewQuote.Shipping_Contact__c = null;
        objNewQuote.Shipping_Contact_Phone_Number__c = null;
        objNewQuote.Shipping_Instructions__c = null;
        objNewQuote.Order_Fulfillment_Email_Receipt__c = null;
        objNewQuote.Shipping_Contact_Email__c = null;
        objNewQuote.Delivery_Method__c = null;
        objNewQuote.Order_Date_Submitted__c = null;
        //MS
        objNewQuote.Deal_Score__c = null;
        objNewQuote.Deal_Score_Cutoffs__c = null;
        
        //Ashish (Feb 05, 2019): To populate currency on Quote
        objNewQuote.New_Price_Book__c = QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode);
        
        if(strSelectedOrderType == 'Amend'){
            objNewQuote.Top_Play__c = selectedPlayOffer;
            objNewQuote.Offer__c = selectedPlayOfferType;
        }
        try {
            insert objNewQuote;
            
             //Bursting
            Map<Id, Id> oldToNewBurstTerm = SubscriptionBurstTerm.addTermToAmend (selectedSubscrToAmend, objNewQuote.Id);
            List<Subscription_Product__c> list_SubscriptionProds = SubscriptionUtil.getSubscriptionProducts(selectedSubscrToAmend);
            
            for(Subscription_Product__c objSubscrProd : list_SubscriptionProds) {
                if(objSubscrProd.Product__r.Third_Party__c == 'TRUE' || objSubscrProd.Product__r.Type__c == 'Product - Hardware' ||
                   objSubscrProd.Quote_Product__r.Bundle__r.Type__c == 'Partner PureSuccess' )     
                    continue;    
                
                BigMachines__Quote_Product__c objNewQuoteProduct = SubscriptionUtil.buildQuoteProdFromSubscrProd(objNewQuote.Id, objSubscrProd);               
                
                //Bursting
                if (objNewQuoteProduct.Subscription_Burst_Term__c != null && oldToNewBurstTerm.containsKey(objNewQuoteProduct.Subscription_Burst_Term__c)) {
                    objNewQuoteProduct.Subscription_Burst_Term__c = oldToNewBurstTerm.get(objNewQuoteProduct.Subscription_Burst_Term__c);
                    objNewQuoteProduct.Name = objNewQuoteProduct.Name + '-BURST';
                }

                list_NewQuoteProducts.add(objNewQuoteProduct);                    
            }

            if(!list_NewQuoteProducts.isEmpty()) {                    
                insert list_NewQuoteProducts;
            }
            
            //Populating Bundle Info on quote products
            Map<Id, Id> map_OfSubscriptionProductVsQuoteProduct = new Map<Id, Id>();                    
            
            for(BigMachines__Quote_Product__c eachProduct : list_NewQuoteProducts){
                map_OfSubscriptionProductVsQuoteProduct.put(eachProduct.Subscription_Product__c, eachProduct.id);               
            }
            
            //Querying subscription products with quote product bundle info
            Map<Id, BigMachines__Quote_Product__c> map_OfIdVsQuoteProducts = new Map<id, BigMachines__Quote_Product__c>([SELECT id, Subscription_Product__c,BigMachines__Product__c,
                                                                                                                         Subscription_Product__r.Bundle__c, BigMachines__Product__r.Third_Party__c, BigMachines__Product__r.Type__c,
                                                                                                                         Bundle__r.Type__c FROM BigMachines__Quote_Product__c WHERE id IN : map_OfSubscriptionProductVsQuoteProduct.values()]);
            
            list_NewQuoteProducts.clear();
            for(BigMachines__Quote_Product__c eachProduct : map_OfIdVsQuoteProducts.values()){
                ProductId_set.add(eachProduct.BigMachines__Product__c);
                Id bundleLineSPId = eachProduct.Subscription_Product__r.Bundle__c;
                eachProduct.Bundle_Line__c = map_OfSubscriptionProductVsQuoteProduct.get(bundleLineSPId);
                if(eachProduct.Bundle_Line__c == null)
                    continue;
                list_NewQuoteProducts.add(eachProduct);
            }      
            if(!list_NewQuoteProducts.isEmpty())
                update list_NewQuoteProducts;
            
            // Added By Ashish
            addUseCases(objNewQuote);
            
            objNewQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: objNewQuote.Id].Quote_Number__c;
            update objNewQuote;
            
            //Pull account order address and differentiate between ship to and other addresses
            List<Account_Order_Address__c> list_NewAOAs = new List<Account_Order_Address__c>();            
            for(Account_Order_Address__c objAOA : [SELECT Id, Address__c, Address2__c, Attention_To__c, Shipping_Method_Name__c, Address_Type__c,
                                                   City__c, Company__c, Country__c, Email__c, Account__c, Fax__c, Need_By_Date__c, 
                                                   Order__c, Phone__c, Shipping_Instructions__c, Sold_To_Business_Partner__c, 
                                                   Sort_Order__c, State__c, Zip_Code__c, Quote__c 
                                                   FROM Account_Order_Address__c
                                                   WHERE Quote__c = :selectedSubscrQuoteId
                                                   AND Address_Type__c != 'Ship To']) {
                                                       Account_Order_Address__c  objNewAOA = objAOA.clone(false, true, false, false);
                                                       objNewAOA.Quote__c = objNewQuote.Id;
                                                       list_NewAOAs.add(objNewAOA);
                                                   }
            System.debug('######list_NewAOAs: '+list_NewAOAs);
            if(list_NewAOAs.size() > 0) {
                insert list_NewAOAs;
            }
            return (new PageReference('/apex/CreateQuoteSubscription?id=' + objNewQuote.Id));
        } 
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
        return null;
    }

    // method to create PureConnect Cloud or PureCloud Quote and return it's page reference
    public pageReference createCaaSOrPureCloudQuote() 
    { 
        Map<String, RecordType> map_QuoteRecTypes = QuoteUtil.getRecordTypes('BigMachines__Quote__c');
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.RecordTypeId = map_QuoteRecTypes.get('Cloud Quote').Id;
        objQuote.BigMachines__Opportunity__c = objOpty.Id;
        objQuote.Offering_Type__c = objOpty.Quote_Type1__c;
        objQuote.Order_Type__c = Label.New_Subscription;
        objQuote.End_User_ID__c = objOpty.AccountId;
        objQuote.BigMachines__Account__c = objOpty.AccountId;
        objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c != null ? objOpty.BusinessPartner__c : objQuote.End_User_ID__c;
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC){
            List < Account > list_SoldTo = [SELECT Street1__c, Street2__c, Street3__c, ZipCode__c, City__c, StateProvince__c,
                                            Business_Country__c, Phone FROM Account WHERE Id =: objQuote.Sold_To_Name__c
                                           ];
            if (!list_SoldTo.isEmpty()) {
                objQuote.Sold_To_Address__c = list_SoldTo[0].Street1__c;
                objQuote.Sold_To_Zip_Code__c = list_SoldTo[0].ZipCode__c;
                objQuote.Sold_To_State__c = list_SoldTo[0].StateProvince__c;
                objQuote.Sold_To_Country__c = list_SoldTo[0].Business_Country__c;
                objQuote.Sold_To_City__c = list_SoldTo[0].City__c;
                objQuote.Sold_To_Phone__c = list_SoldTo[0].Phone;
            }
        }
        objQuote.Quote_Created_Date__c = Date.today();
        objQuote.Expiration_Date__c = Date.today().addMonths(1);
        objQuote.CurrencyISOCode = objOpty.CurrencyISOCode;        
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.PureCloud_Monthly_Minimum__c = objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ? getPCMonthlyMinimum() : 0;
        // objQuote.Ramp_Period__c = objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC ? '180' : objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC ? '0' : '90';
        objQuote.Ramp_Period__c = (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC) ? '180' : '90';
        // objQuote.Ramp_Period__c = (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) ? '180' : '90';
        system.debug('Ramp_Period__c'+objQuote.Ramp_Period__c);
        objQuote.Grid_Group_By__c = 'Recurring/Non-Recurring';
        objQuote.Group_Product_By__c = 'Standard View';
        objQuote.Pricing_Model__c = 'Named';        
        objQuote.Quote_Business_Type__c = objOpty.Primary_Line_of_Business__c ;
        objQuote.Product_Tier__c = objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC ? objOpty.Product_Tier__c : '';
        objQuote.Order_Payment_Terms__c = 'Net 30';
        objQuote.MSA_Link_Type__c = (objOpty.MSA_Link_Type__c == 'Custom') ? 'Custom' : 'Standard';
        objQuote.MSA_Link__c = objOpty.MSA_Link_Type__c == 'Custom' ? objOpty.MSA_Link__c : getMSALink(objQuote.Offering_Type__c);
        objQuote.Selling_Entity__c = objOpty.Country_Selling_Entity__c;
        objQuote.Initial_Subscription_Term__c = '1 Year';
        objQuote.Billing_Period__c = 'Annually';  
        objQuote.Billing_Category__c = 'Annual Pre-Pay';
        objQuote.No_Of_Months__c = 12;
        objQuote.Renewal_Subscription_Term__c = 'Automatic Monthly';
        objQuote.Delivery_Method__c = 'Electronic';
        objQuote.Payment_Method__c = 'ACH'; 
        objQuote.Hide_Discount__c = false;
        objQuote.Hide_Totals__c = false;
        objQuote.Hide_List_Price__c = true;   
        objQuote.Deployment_Model__c = objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC ? 'Local Control' : '';     
        objQuote.Support_Owner__c = objOpty.Support_Owner__c != null ? objOpty.Support_Owner__c : null;
        objQuote.System_Integrator__c = objOpty.System_Integrator__c != null ? objOpty.System_Integrator__c : null;
        objQuote.New_Price_Book__c = QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode);        
        objQuote.Keep_the_existing_estate_on_Perpetual__c = (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC) ? True : False;
        //Anju July 2018 Cloud puresuccess changes
        system.debug(strExistingPureSuccessCustomer);
        objQuote.Does_customer_currently_have_PureSuccess__c = strExistingPureSuccessCustomer == Null ? false : Boolean.valueOf(strExistingPureSuccessCustomer);
        objQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objQuote.Top_Play__c = selectedPlayOffer;
        objQuote.Offer__c = selectedPlayOfferType;
        objQuote.Sale_Type__C = objOpty.Direct_Indirect_Sale__c;
        
        //Added by Kartik 
        objQuote.SOW_Link__c = objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC ? objOpty.SOW_Url__c : '';
        //Added By Ranjith on Apr 19, 2019 -- Starts -- Reason for new sub 
        objQuote.Reason_for_New_when_Sub_s_Already_Exist__c = objOppQuoteCategory.Reason_for_New_when_Sub_s_Already_Exist__c;
        //Added By Ranjith on Apr 19, 2019 -- Starts -- Reason for new sub
        
        
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
            objQuote.Overage_Allowance__c = '20%';
        List<RecordType> list_CloudRT = [SELECT Id FROM RecordType WHERE SobjectType = 'BigMachines__Quote__c' AND Name = 'Cloud Quote'];
        if (!list_CloudRT.isEmpty())
            objQuote.RecordTypeId = list_CloudRT[0].Id;
        
        map_leverSelection = new map<string,boolean>();
        if(pbLevers.size() > 0){
            // pbLevers.sort();
            String strLever = '';
            for(PBLever objLever : pbLevers ){
                if(objLever.isSelected){
                    map_leverSelection.put(objLever.lever,true);
                    strLever =strLever + objLever.lever + ';';
                }   
                System.debug('###strLever'+strLever);
            }
            objQuote.Lever__C = strLever;
        }
        
        if([SELECT count() FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :objOpty.Id] == 0) {
            objQuote.Is_Business_Primary__c = true;
            objQuote.BigMachines__Is_Primary__c = true;
            blnIsPrimaryQuote = true;
            System.debug('######objQuote.Offering_Type__c'+objQuote.Offering_Type__c);
            updateLeadOfferOnOpportunity(objQuote.Offering_Type__c);
        }
        
        if(objOpty.Offering_Detail__c == 'Pilot/POC' ||objOpty.Offering_Detail__c == 'Free Trial' ) {
            objQuote.PureCloud_Monthly_Minimum__c = 0;
            objQuote.Ramp_Period__c = '0';
            objQuote.Billing_Period__c = 'Monthly';
            objQuote.Initial_Subscription_Term__c = '1 Month';
            objQuote.Billing_Category__c = 'M2M';
            objQuote.No_Of_Months__c = 1;
            if(objOpty.Offering_Detail__c == 'Free Trial')
            {
                objQuote.Treat_SO_as_PO__c = true;
                objQuote.Hide_Totals__c = true;
                objQuote.Hide_Discount__c = true;
                objQuote.Hide_List_Price__c = true;
                
            }
        }
        if(strSubscrSubType == 'Replace Existing Subscription') {
            objQuote.Order_Type__c = Label.Replace_Subscription;
            objQuote.Order__c = null;
            objQuote.Ramp_Period__c = '0';
            objQuote.BigMachines__Opportunity__c = objOpty.Id;
            objQuote.Amendment_For__c = selectedSubscrToAmend;
        }
        if(objOpty.Lever__c !=null && objOpty.Avaya_Contract_Expiration__c !=null && !map_leverSelection.containsKey('Lever 2') ){
            objQuote = QuoteCloudUtil.updateLeverDetials(objQuote,objOpty,map_leverSelection);
        }
        String strRampPeriod =  (objQuote.Ramp_Period__c == '1 Year'?'365':objQuote.Ramp_Period__c);
        objQuote.Subscription_Start_Date__c = Date.today().addMonths(Integer.valueOf(strRampPeriod)/30);
        objQuote.Subscription_End_Date__c = objQuote.Subscription_Start_Date__c.addMonths(Integer.valueOf(objQuote.No_Of_Months__c))-1;
        System.debug(objOpty);
        
        try {
            insert objQuote;
            
            objQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE Id =: objQuote.Id].Quote_Number__c;
            if(objOpty.Lever__c !=null && ((map_leverSelection.containsKey('Lever 2')) || (map_leverSelection.containsKey('Lever 4'))) && objOpty.Avaya_Contract_Expiration__c !=null){
                objQuote = QuoteCloudUtil.updateLeverDetials(objQuote,objOpty,map_leverSelection);
            }           
            update objQuote;
            
            if(objQuote.Offering_Type__c == 'PureCloud') {  
                createIVRDataStorageParts(objQuote);
            }
            if(blnIsPrimaryQuote) {
                objOpty.Primary_Quote__c = objQuote.Id;
                // update objOpty;
                changePriceBook();
            }
            system.debug('cominginside goto method');
            addBundleToQuote(objQuote);
            system.debug('comingoustide goto method');
            //kartik
            // if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC){addUseCases(objQuote);}
            //Anju Dec 18 usecases : add selected use cases
            if( objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC && objOppQuoteCategory.Offering_Details__c != 'Free Trial') {addUseCases(objQuote);}
            String strReturnPage = objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ? '/apex/CreateQuoteCloudPC?id=' : objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC ? '/apex/CreateQuoteCloud?id=' : '/apex/CreateQuoteCloudPEC?id=';
            return (new PageReference(strReturnPage + objQuote.Id));
        } 
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            System.debug('An exception has occurred:'+ex.getMessage()+'\n'+ex.getStackTraceString());
        }        
        return null;
    }
    
    // method to create PPU Quote and return it's page reference
    public pageReference createPureEngageSubscriptionQuote() {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.BigMachines__Opportunity__c = objOpty.Id;
        objQuote.Quote_Created_Date__c = System.today();
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.Grid_Group_By__c = 'Use Cases';
        objQuote.Service_Level__c = 'Business';
        system.debug('navanee3');
        objQuote.PPU_Rental__c = true;
        objQuote.Pricing_Model__c = 'Enabled';
        objQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objQuote.Quote_Business_Type__c = 'On Premise';
        objQuote.Offering_Type__c = 'PureEngage Subscription';
        objQuote.Order_Numb_of_Maint_Months__c = 12;
        objQuote.Duration_Unit__c = 'Months';
        objQuote.Order_Type__c = 'New';  
        if(strSelectedOrderType == 'Migration')
            objQuote.Order_Type__c = strSelectedOrderType;
        objQuote.PureSuccess__c = objOppQuoteCategory.PureSuccess__c;        
        objQuote.Keep_the_existing_estate_on_Perpetual__c = objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c;
        objQuote.Overage_Allowance__c = '25%';
        objQuote.Overage_Price_Premium__c = 30;
        objQuote.No_Of_Months__c = 24;
        objQuote.Billing_Period__c = 'Annually';
        objQuote.Price_Escalation__c = '5%';
        objQuote.Optional_extended_term_length_Months__c = '12';
        objQuote.Subscription_Start_Date__c = System.today();
        objQuote.Billing_Start_Date__c = System.today();
        objQuote.Order_Payment_Terms__c = 'Net 30';
        objQuote.MSA_Link_Type__c = 'Standard';
        objQuote.MSA_Link__c = Label.MSA_Links.split(';;')[3].trim();
        
        // Added by Ashish to populate Play and Offer
        objQuote.Top_Play__c = selectedPlayOffer;
        objQuote.Offer__c = selectedPlayOfferType;
        
        //objQuote.MSA_Link_Type__c = (objOpTy.MSA_Link_Type__c == 'Custom')?'Custom':'Standard';
        //objQuote.MSA_Link__c = (objOpTy.MSA_Link_Type__c == 'Standard' || (objOpTy.MSA_Link_Type__c == '' || objOpTy.MSA_Link_Type__c == null))?getMSALink(objQuote.Offering_Type__c):objOpTy.MSA_Link__c;
        //objQuote.MSA_Link__c = Label.MSA_Links.split(';;')[3].trim();
        objQuote.Subscription_Addendum_Type__c = 'Standard';    
        if(objOpty.Direct_Indirect_Sale__c == 'Indirect')
            objQuote.Multi_Year_Quote__c = true;
        if ([SELECT count() FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: objOpty.id] == 0) {
            objQuote.Is_Business_Primary__c = true;
            objQuote.BigMachines__Is_Primary__c = true;
            updateLeadOfferOnOpportunity('PureEngage Premise Subscription');
        }
        
        if (objOpty.AccountId != null) {
            objQuote.End_User_ID__c = objOpty.AccountId;
            objQuote.BigMachines__Account__c = objOpty.AccountId;
        }
        
        if (objOpty.BusinessPartner__c != null)
            objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c;
        else
            objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
        
        if (objOpty.Support_Owner__c != null)
            objQuote.Support_Owner__c = objOpty.Support_Owner__c;
        
        if (objOpty.System_Integrator__c != null)
            objQuote.System_Integrator__c = objOpty.System_Integrator__c;
        
        if (objOpty.Sold_To_Country__c != null) {
            if(objOppQuoteCategory.Pricing__c != 'Old Pricing')
                objQuote.New_Price_Book__c = objOpty.Sold_To_Country__r.New_Price_Book__c;
            else
                objQuote.New_Price_Book__c = objOpty.Sold_To_Country__r.Old_Price_Book__c;
        } 
        else {
            if (objOpty.BusinessPartner__c != null) {
                objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c;
                if(objOppQuoteCategory.Pricing__c!= 'Old Pricing')
                    objQuote.New_Price_Book__c = objOpty.BusinessPartner__r.Country__r.New_Price_Book__c;
                else
                    objQuote.New_Price_Book__c = objOpty.BusinessPartner__r.Country__r.Old_Price_Book__c;
            }
        }
        
        objQuote.CurrencyISOCode = objOpty.CurrencyISOCode;
        objQuote.Expiration_Date__c = Date.today().addMonths(1);
        //objQuote.New_Price_Book__c = QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode);
        BigMachines__Quote_Product__c objServiceLevel = null;
        System.debug('NKC debug blnShowBaseAndPureSuccessPackage [' + blnShowBaseAndPureSuccessPackage + ']');
        if(!blnShowBaseAndPureSuccessPackage){
            String strGCProdName = objQuote.Service_Level__c + ' Care-New';
            // If Direct sale, pre-populate sold to with end user info
            if (objOpty.Direct_Sales__c) {
                objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
                strGCProdName += '(End User)';
            } else
                strGCProdName += '(Partner)';
            System.debug('NKC debug strGCProdName [' + strGCProdName + ']');
            
            List<Product2> list_Temp1 = [SELECT Id, Name, Unit_of_Measure__c FROM Product2 WHERE Description =: strGCProdName AND
                                         Genesys_Care_Quote__c = true AND IsActive = true];
            if (list_Temp1.size() > 0) {
                objServiceLevel = new BigMachines__Quote_Product__c(BigMachines__Quantity__c = 1,
                                                                    BigMachines__Sales_Price__c = 0);
                objServiceLevel.Name = list_Temp1[0].Name;
                objServiceLevel.Unit_of_Measure__c = list_Temp1[0].Unit_of_Measure__c;
                objServiceLevel.BigMachines__Product__c = list_Temp1[0].Id;
            }
        }
        
        //PureBridge
        if (objQuote.Order_Type__c == 'New') {
            String levers='';
            for (PBLever lv : pbLevers) 
                levers += lv.isSelected ? lv.Lever + ';' : '';
            
            objQuote.Lever__c = levers != null ? levers.removeEnd(';') : null;
            if ( levers.contains('Lever 1'))
                objQuote.Ramp_Period__c = CreateQuoteSubscriptionController.getPureBridgeRampPeriod(objOpty.Avaya_Contract_Expiration__c);
        }
        
       try {
            insert objQuote;
            
            objQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: objQuote.id].Quote_Number__c;
            update objQuote;
            
            if (objServiceLevel != null) {
                objServiceLevel.BigMachines__Quote__c = objQuote.Id;
                insert objServiceLevel;
            }
            //Below line added by Ankit on 5/31/2017
            if(blnIsPrimaryQuote)
                objOpty.Primary_Quote__c = objQuote.id;            
            changePriceBook();
            addBundleToQuote(objQuote);
            
            //PureBridge
            if ( objQuote.Lever__c != null && objQuote.Lever__c.contains('Lever 2'))
                QuoteUtil.createGUPassports(objQuote);
            
            return (new PageReference('/apex/CreateQuoteSubscription?id=' + objQuote.Id));
        } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        } 
        return null;
    }        
    // method to create PPU Quote and return it's page reference
    public pageReference createPureConnectSubscriptionQuote() {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.BigMachines__Opportunity__c = objOpty.Id;
        objQuote.Quote_Created_Date__c = System.today();
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.Grid_Group_By__c = 'Use Cases';
        objQuote.Service_Level__c = 'Business';
        objQuote.Pricing_Model__c = isSmallMediumCenter ? 'Named Licenses' : 'Enabled';
        //MS
        objQuote.Offering_Feature__c = isSmallMediumCenter ? PCSUBSCR_SMALL_MED : null;
        objQuote.PPU_Rental__c = true;
        objQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objQuote.Quote_Business_Type__c = 'On Premise';
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        objQuote.Order_Numb_of_Maint_Months__c = 12;
        objQuote.Duration_Unit__c = 'Months';
        objQuote.Order_Type__c = 'New';
        if(strSelectedOrderType == 'Migration')
            objQuote.Order_Type__c = strSelectedOrderType;
        objQuote.PureSuccess__c = objOppQuoteCategory.PureSuccess__c;    
        objQuote.Keep_the_existing_estate_on_Perpetual__c = objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c;
        objQuote.Overage_Allowance__c = '25%';
        objQuote.Overage_Price_Premium__c = 30;
        objQuote.No_Of_Months__c = 24;
        objQuote.Price_Escalation__c = '5%';
        objQuote.Billing_Period__c = 'Annually';
        objQuote.Optional_extended_term_length_Months__c = '12';
        objQuote.Subscription_Start_Date__c = System.today();
        objQuote.Billing_Start_Date__c = System.today();
        objQuote.Order_Payment_Terms__c = 'Net 30';
        objQuote.MSA_Link_Type__c = 'Standard';
        objQuote.MSA_Link__c = Label.MSA_Links.split(';;')[3].trim();
        objQuote.Subscription_Addendum_Type__c = 'Standard';   
        objQuote.Product_Version__c = objOpty.Product_Version__c;
        
        // Added by Ashish to populate Play and Offer
        objQuote.Top_Play__c = selectedPlayOffer;
        objQuote.Offer__c = selectedPlayOfferType;
        
        if(objOpty.Direct_Indirect_Sale__c == 'Indirect')
            objQuote.Multi_Year_Quote__c = true;
        if ([SELECT count() FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: objOpty.id] == 0) {
            objQuote.Is_Business_Primary__c = true;
            objQuote.BigMachines__Is_Primary__c = true;
            blnIsPrimaryQuote = true;
            updateLeadOfferOnOpportunity('PureConnect Premise Subscription');
        }
        objQuote.New_Price_Book__c = QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode);
        
        if (objOpty.AccountId != null) {
            objQuote.End_User_ID__c = objOpty.AccountId;
            objQuote.BigMachines__Account__c = objOpty.AccountId;
        }
        
        if (objOpty.BusinessPartner__c != null)
            objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c;
        else
            objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
        
        if (objOpty.Support_Owner__c != null)
            objQuote.Support_Owner__c = objOpty.Support_Owner__c;
        
        if (objOpty.System_Integrator__c != null)
            objQuote.System_Integrator__c = objOpty.System_Integrator__c;
        
        objQuote.CurrencyISOCode = objOpty.CurrencyISOCode;
        objQuote.Expiration_Date__c = Date.today().addMonths(1);
        
        // Example : Basic Care-New(End User)
        String strGCProdName = 'Standard Support';
        Decimal maintenanceDiscount = 0;
        Decimal genesysCareRate = 0;
        if (objOpty.AccountId != null) {
            String strAccountId = objopty.BusinessPartner__c;
            if(strAccountId == null)
                strAccountId = objOpty.AccountId;
            objQuote.End_User_ID__c = objOpty.AccountId;
            objQuote.BigMachines__Account__c = objOpty.AccountId;
            // populating support options from end user account
            Account endUserAccount = [SELECT Support_Option__c, Maintenance_Discount_Pct__c, Maintenance_Discount_Effective_Date__c,
                                      Maintenance_Discount_Expiration_Date__c, Country__r.Standard_Support__c,
                                      Country__r.Priority_Support__c, Country__r.VIP_Priority_Support__c FROM Account WHERE id=: strAccountId];
            
            if(endUserAccount.Support_Option__c == null || (endUserAccount.Support_Option__c != 'Priority Support' 
                                                            && endUserAccount.Support_Option__c != 'VIP Priority Support')){
                                                                endUserAccount.Support_Option__c = 'Standard Support';
                                                            }            
            objQuote.Support_Options__c = endUserAccount.Support_Option__c;
            
            if(endUserAccount.Maintenance_Discount_Effective_Date__c <= System.today() 
               && endUserAccount.Maintenance_Discount_Expiration_Date__c > System.today()){
                   maintenanceDiscount = endUserAccount.Maintenance_Discount_Pct__c;
               }
            
            if(endUserAccount.Support_Option__c != null)
                strGCProdName = endUserAccount.Support_Option__c;
            if(strGCProdName == 'Standard Support')
                genesysCareRate = endUserAccount.Country__r.Standard_Support__c;
            else if(strGCProdName == 'Priority Support')
                genesysCareRate = endUserAccount.Country__r.Priority_Support__c;
            else if(strGCProdName == 'VIP Priority Support')
                genesysCareRate = endUserAccount.Country__r.VIP_Priority_Support__c;            
            if(genesysCareRate == null)
                genesysCareRate = 0;
        }
        BigMachines__Quote_Product__c objServiceLevel = null;
        //MS   if(!blnShowBaseAndPureSuccessPackage){
        if( !blnShowBaseAndPureSuccessPackage || isSmallMediumCenter )   {
            // If Direct sale, pre-populate sold to with end user info
            if (objOpty.Direct_Sales__c) {
                objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
                strGCProdName += ' - New (End User)';
            } else
                strGCProdName += ' - New (Partner)';        
            System.debug('NKC debug strGCProdName [' + strGCProdName +']');            
            List < Product2 > listOfProducts = [SELECT Id, Name, Unit_of_Measure__c, Genesys_Care_Rate__c
                                                FROM Product2 WHERE Product_Type__c =: strGCProdName AND Genesys_Care_Quote__c = true AND IsActive = true];
            if (!listOfProducts.isEmpty()) {
                objServiceLevel = new BigMachines__Quote_Product__c(BigMachines__Quantity__c = 1,
                                                                    Quantity__c = 1, //MS added
                                                                    BigMachines__Sales_Price__c = 0);
                objServiceLevel.Name = listOfProducts[0].Name;
                objServiceLevel.Unit_of_Measure__c = listOfProducts[0].Unit_of_Measure__c;
                objServiceLevel.BigMachines__Product__c = listOfProducts[0].Id;
                //if(listOfProducts[0].Genesys_Care_Rate__c != null)
                //  genesysCareRate = listOfProducts[0].Genesys_Care_Rate__c;
                if(genesysCareRate > 0 && maintenanceDiscount > 0){
                    genesysCareRate -= genesysCareRate * maintenanceDiscount / 100;
                }
                objQuote.Genesys_Care_Rate__c = genesysCareRate;
                objQuote.Genesys_Care_Default_Pricing_Percentage__c = genesysCareRate;  
            }            
        }
        
        //PureBridge
        if (  objQuote.Order_Type__c == 'New' ) {
            String levers='';
            for (PBLever lv : pbLevers) 
                levers += lv.isSelected ? lv.Lever + ';' : '';
            
            objQuote.Lever__c = levers != null ? levers.removeEnd(';') : null;
        }
        
        try {
            insert objQuote;
            
            objQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: objQuote.id].Quote_Number__c;
            update objQuote;
            
            if (objServiceLevel != null) {
                objServiceLevel.BigMachines__Quote__c = objQuote.Id;
                insert objServiceLevel;
            }
            //Below line added by Ankit on 5/31/2017
            if(blnIsPrimaryQuote)
                objOpty.Primary_Quote__c = objQuote.id;            
            changePriceBook();
            addBundleToQuote(objQuote);
            
            //PureBridge
            if ( objQuote.Lever__c != null && objQuote.Lever__c.contains('Lever 2'))
                QuoteUtil.createGUPassports(objQuote);
            
            return (new PageReference('/apex/CreateQuoteSubscription?id=' + objQuote.Id));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }
        return null;
    }
    
    @TestVisible
    private void addBundleToQuote(BigMachines__Quote__c objQuote) { 
        system.debug('cominginsidekartik');
        //MS 6/26/19
        String strOfferType = isSmallMediumCenter ? objQuote.Offering_Feature__c : objQuote.Offering_Type__c;
        /*
Map<id, Product_Group__c> listOfProductGroups = new Map<id, Product_Group__c>([SELECT id FROM Product_Group__c WHERE Offering_Type__c INCLUDES (:objQuote.Offering_Type__c)
AND Group_Type__c = 'Base Package' AND Active__c = true AND Pricing_Model__c = 'User']);
*/
        Map<id, Product_Group__c> listOfProductGroups = new Map<id, Product_Group__c>([SELECT id FROM Product_Group__c WHERE Offering_Type__c INCLUDES (:strOfferType)
                                                                                       AND Group_Type__c = 'Base Package' AND Active__c = true AND Pricing_Model__c = 'User']);
        //kartik
        if(objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PEC){
            if(listOfProductGroups.values().isEmpty())
                return;   
        }
        List<String> listOfPureSuccessPackagesStr = new List<String>();        
        String strPureSuccess;
        for(Product_Group__c eachPG : listOfPureSuccessPackages){
            System.debug('NKC debug eachPG [' + eachPG + ']');
            if(eachPG.Selected__c){
                strPureSuccess = eachPG.Type__c;
                break;
            }                
        }
        system.debug('kartiktest'+strPureSuccess);
        system.debug('kartiktestpures'+listOfPureSuccessPackages.size());
        listOfPureSuccessPackagesStr.add(strPureSuccess);
        
        //Adding subscription tool base bundle
        if(blnShowBaseAndPureSuccessPackage)
            addBundleWithLinesToQuote(objQuote, listOfProductGroups.keyset(), 'Base Package', strPureSuccess);
        
        
        System.debug('NKC debug strPureSuccess [' + strPureSuccess + ']');        
        System.debug('NKC debug listOfPureSuccessPackagesStr [' + listOfPureSuccessPackagesStr + ']');
        for(String eachPackage : listOfPureSuccessPackagesStr){
            //Querying PureSuccess Bundles
            /* MS 
listOfProductGroups = new Map<Id, Product_Group__c>([SELECT id FROM Product_Group__c WHERE Type__c = : 
eachPackage AND Group_Type__c = 'PureSuccess' 
AND Offering_Type__c INCLUDES (:objQuote.Offering_Type__c) AND Active__c = true]);
*/
            listOfProductGroups = new Map<Id, Product_Group__c>([SELECT id FROM Product_Group__c WHERE Type__c = : 
                                                                 eachPackage AND Group_Type__c = 'PureSuccess' 
                                                                 AND Offering_Type__c INCLUDES (:strOfferType) AND Active__c = true]);
            
            if(listOfProductGroups.values().isEmpty())
                continue; 
            
            //Adding PureSuccess base bundle
            addBundleWithLinesToQuote(objQuote, listOfProductGroups.keyset(), 'PureSuccess', strPureSuccess);        
        }
        //Adding use cases
        If(objOppQuoteCategory.Offering_Details__c != 'Free Trial') { addUseCases(objQuote);}
    }
    
    @testVisible  private void addUseCases(BigMachines__Quote__c objQuote) {
        Set<Id> setOfUseCaseIds = new Set<Id>();    
        for(Product_Group__c eachPG : listOfUseCases){
            if(eachPG.Selected__c){
                setOfUseCaseIds.add(eachPG.id);
            }    
        }       
        if(map_PlayCategoryListPlayOffer != null && map_PlayCategoryListPlayOffer.size() > 0){
            for(String key : map_PlayCategoryListPlayOffer.keySet()){
                for(PlayOfferWrapper eachPG : map_PlayCategoryListPlayOffer.get(key)){
                    System.debug('--eachPG-'+eachPG);
                    if(eachPG.isSelected){
                        setOfUseCaseIds.add(eachPG.prdGrp.id);
                    }    
                }
            }
        }       
        if(setOfUseCaseIds.isEmpty())
            return;
        String strPriceBookField = '';
        if (objOpty.Lines_of_Businesses__c == 'PureEngage' && objOpty.Primary_Line_of_Business__c == 'Cloud' && objOppQuoteCategory.Lead_Offer__c != 'PureEngage Cloud Partner PPU'){
            if(objQuote.Offering_Type__C == 'PureEngage Cloud'){
                strPriceBookField = objQuote.New_Price_Book__c + '_Price__c';
                    }
            else{
                if(objQuote.New_Price_Book__c.contains('USD')){
                    strPriceBookField = 'List_Price__c';
                }
                else if(objQuote.New_Price_Book__c.contains('AUD')){
                    strPriceBookField = 'List_Price_AUD__c';
                }
                else if(objQuote.New_Price_Book__c.contains('CAD')){
                    strPriceBookField = 'List_Price_CAD__c';
                }
                else if(objQuote.New_Price_Book__c.contains('EUR')){
                    strPriceBookField = 'List_Price_EUR__c';
                }
                else if(objQuote.New_Price_Book__c.contains('GBP')){
                    strPriceBookField = 'List_Price_GBP__c';
                }
            }      
        }
        else{
            strPriceBookField = objQuote.New_Price_Book__c + '_Price__c';
        }
        List<Product_Group__c> listOfProductGroups = getProductGroupQuery(setOfUseCaseIds, strPriceBookField);
        List<BigMachines__Quote_Product__c> listOfBundlesToBeInserted = new List<BigMachines__Quote_Product__c>();
        // List<BigMachines__Quote_Product__c> listOfQuoteProductsToBeInserted = new List<BigMachines__Quote_Product__c>();
        Set<Id> setOfProductIds = new Set<Id>();
        List<List<BigMachines__Quote_Product__c>> listOfRelatedSellableItemLines = new List<List<BigMachines__Quote_Product__c>>(); 
        //Querying and adding Base Package products do dedup the use case lines.
        for(BigMachines__Quote_Product__c eachQP : [SELECT BigMachines__Product__c FROM BigMachines__Quote_Product__c
                                                    WHERE BigMachines__Quote__c =:objQuote.id AND Bundle__r.Group_Type__c = 'Base Package']){
                                                        setOfProductIds.add(eachQP.BigMachines__Product__c);                                                
                                                    }
        
        if(listOfProductGroups.size() > 0){
            //BigMachines__Quote__c objQuote2 = new BigMachines__Quote__c(Id = objQuote.Id, Grid_Group_By__c = 'Use Cases');
            //update objQuote2;
        }
        
        // Added By Ashish (Feb 05, 2019), To emove the duplicacy for Amendment scenario
        Set<Id> set_ExistingUseCase = new Set<Id>();
        for(BigMachines__Quote_Product__c qtProd : [SELECT Bundle__c FROM BigMachines__Quote_Product__c 
                                                    WHERE BigMachines__Quote__c =:objQuote.id AND Bundle__c != null AND Bundle__r.Group_Type__c = 'Use Case'] ){
                                                        set_ExistingUseCase.add(qtProd.Bundle__c);
                                                    }
        for(BigMachines__Quote_Product__c qtProd : [SELECT BigMachines__Product__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =:objQuote.id AND BigMachines__Product__c != null] ){
            ProductId_set.add(qtProd.BigMachines__Product__c);
        }
        
        for(Product_Group__c eachBundle : listOfProductGroups){
            // Added By Ashish (Feb 05, 2019), To emove the duplicacy for Amendment scenario
            if(!set_ExistingUseCase.contains(eachBundle.Id) ){        
                BigMachines__Quote_Product__c objBundleQP = new BigMachines__Quote_Product__c();
                objBundleQP.Name = eachBundle.Name;
                objBundleQP.BigMachines__Quote__c = objQuote.Id;
                objBundleQP.BigMachines__Product__c = eachBundle.Product__c;
                objBundleQP.Unit_of_Measure__c = eachBundle.Product__r.Unit_of_Measure__c;
                objBundleQP.Quantity__c = (eachBundle.Quantity__c == null ? 1 : eachBundle.Quantity__c);
                objBundleQP.BigMachines__Quantity__c = objBundleQP.Quantity__c;
                //objBundleQP.List_Price__c = eachBundle.Price__c;
                objBundleQP.BigMachines__Sales_Price__c = 0;
                objBundleQP.or_Amount__c = '%';
                objBundleQP.Disc__c = eachBundle.Additional_Discount__c;
                objBundleQP.Bundle_Discount__c = eachBundle.Discount__c;
                objBundleQP.Bundle__c = eachBundle.Id;
                objBundleQP.List_Price__c = 0;
                //objBundleQP.Line_Number__c = (objOpty.Primary_Line_of_Business__c == 'Cloud')?++intLineNumber:0;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                 objBundleQP.Line_Number__c = ++intLineNumber;//-Navaneetha - Nov 28th 2019 - Used to track the line number for the quote product level- 
                System.debug('####Name:'+objBundleQP.Name+' '+'Line Number:'+intLineNumber);
                // Added on the request of Ranjith (01/11/2019)
                objBundleQP.APN_Number__c = eachBundle.Product__r.APN_Number__c;
                objBundleQP.Hide_Record__c = true;
                objBundleQP.Play__c = selectedPlayOffer;
                objBundleQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                if(eachBundle.Play_Offer__c != null){
                    objBundleQP.Offer__c = selectedPlayOfferType;
                }
                //End
                
                Product2 objBaseProduct;
                if(eachBundle.Product__c != null){
                    String strProductId = eachBundle.Product__c;
                    String strQuery = 'SELECT ' + strPriceBookField + ' FROM Product2 WHERE id =: strProductId';
                    List<Product2> listOfProducts = (List<Product2>) Database.query(strQuery);
                    objBaseProduct = listOfProducts[0];
                    objBundleQP.List_Price__c = (Decimal)objBaseProduct.get(strPriceBookField);
                }
                listOfBundlesToBeInserted.add(objBundleQP);
                List<BigMachines__Quote_Product__c> listOfQuoteProductsToBeInserted = new List<BigMachines__Quote_Product__c>();
                for (Product_Group_Item__c objGroupItem : eachBundle.Product_Group_Items__r) { 
                    if(objOppQuoteCategory.Platform_Type__c != 'Cloud' || (objOppQuoteCategory.Platform_Type__c == 'Cloud' && objGroupItem.Product_Type__c == 'Mandatory') || objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud') {
                        Product2 objProduct = (Product2)objGroupItem.Product__r;
                        if(setOfProductIds.contains(objProduct.id) || set_InsertedProductIds.contains(objProduct.id))
                            continue;
                        setOfProductIds.add(objProduct.id);
                        Decimal decPrice;
                        decPrice = (Decimal) objProduct.get(strPriceBookField);
                        
                        if(decPrice == null)
                            decPrice = 0;
                        if (decPrice != null && decPrice != -1 && !ProductId_set.contains(objGroupItem.Product__c)) {
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objProduct.Name;
                           // objQP.Line_Number__c = (objOppQuoteCategory.Platform_Type__c == 'Cloud')?++intLineNumber:100;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level-;
                           objQP.Line_Number__c =  ++intLineNumber;//-Navaneetha - Nov 28th 2019 - Used to track the line number for the quote product level- 
                            System.debug('####Name:'+objQP.Name+' '+'Line Number:'+intLineNumber);
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.BigMachines__Product__c = objGroupItem.Product__c;
                            objQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                            if (objOpty.Lines_of_Businesses__c == 'PureEngage' && objOpty.Primary_Line_of_Business__c == 'Cloud'){
                                objQP.Product__c = objProduct.Name;
                                
                            }else{
                                objQP.Product__c = objProduct.Id;
                            }
                            //objQP.Product__c = objProduct.Description;
                            objQP.APN_Number__c = objProduct.APN_Number__c;
                           // objQP.Product_Specific_Discount__c = objProduct.PPU_Product_Specific_Discount__c; // Commented for INC0437456 on 11-28-2019
                            objQP.Product_Specific_Discount__c = objProduct.Product_Specific_Discount__c; // Added on 11-28-2019  for INC0437456 
                            
                            objQP.Pm_Approver__c = objProduct.Product_Manager_Approval_Group__r.Name;
                            objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
                            objQP.Metric__c = objProduct.Unit_of_Measure__c;
                            objQP.Third_Party__c = objProduct.Third_Party__c;
                            //objQP.Metric__c = objProduct.Third_Party__c;
                            objQP.Third_Party_GC__c = objProduct.Third_Party_GC__c;
                            objQP.Original_Third_Party_GC__c = objProduct.Third_Party_GC__c;
                            objGroupItem.Quantity__c = objGroupItem.Quantity__c == null ? 1 : objGroupItem.Quantity__c;
                            // Committed Quantity stores the quantity of the product in the bundle
                            objQP.Committed_Quantity__c = (objGroupItem.Quantity__c != null ? objGroupItem.Quantity__c : 1);
                            // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                            objQP.Quantity__c = 1;
                            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                            objQP.List_Price__c = decPrice;
                            objQP.Partner_Price__c = decPrice;                    
                            objQP.BigMachines__Sales_Price__c = 0;
                            objQP.or_Amount__c = '%';
                            objQP.Disc__c = eachBundle.Additional_Discount__c;
                            objQP.Bundle_Discount__c = eachBundle.Discount__c;
                            objQP.Bundle__c = eachBundle.Id;
                            objQP.Play__c = selectedPlayOffer;
                            if(eachBundle.Play_Offer__c != null){
                                objQP.Offer__c = selectedPlayOfferType;
                            }
                            if(objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud'){
                                objQP.Product_Group__c = objGroupItem.Product__r.Product_Group__c;
                            }
                            listOfQuoteProductsToBeInserted.add(objQP);
                            ProductId_set.add(objGroupItem.Product__c);
                        }
                    }  
                }      
                listOfRelatedSellableItemLines.add(listOfQuoteProductsToBeInserted);
            }
        }
        /*
if(!listOfBundlesToBeInserted.isEmpty()){
insert listOfBundlesToBeInserted;
}
if(!listOfQuoteProductsToBeInserted.isEmpty()){
insert listOfQuoteProductsToBeInserted;
}

//Anju Dec 18 usecases
if(objOppQuoteCategory.Platform_Type__c == 'Cloud')
QuoteCloudUtil.createDependentAndOverages(listOfQuoteProductsToBeInserted, objQuote);

*/
        if(!listOfBundlesToBeInserted.isEmpty()){
            insert listOfBundlesToBeInserted;
            List<BigMachines__Quote_Product__c> listOfQuoteProductsToBeInserted = new List<BigMachines__Quote_Product__c>();
            
            
            for(Integer i=0; i < listOfBundlesToBeInserted.size(); i++){
                for(BigMachines__Quote_Product__c objQP : listOfRelatedSellableItemLines[i]){
                    //Ankit on 2/13/2019   
                    if(objOppQuoteCategory.Platform_Type__c == 'Cloud'){
                        objQP.Bundle_Line__c = listOfBundlesToBeInserted[i].Id;
                    }
                    listOfQuoteProductsToBeInserted.add(objQP);
                }
            }            
            
            if(!listOfQuoteProductsToBeInserted.isEmpty()){
                insert listOfQuoteProductsToBeInserted;
                
                //Anju Dec 18 usecases
                if(objOppQuoteCategory.Platform_Type__c == 'Cloud')
                    intLineNumber =     QuoteCloudUtil.createDependentAndOverages(listOfQuoteProductsToBeInserted, objQuote,intLineNumber);
            }
        }
        
        /*
//Looping over each Product Group and adding quote products
for(Product_Group__c eachPG : listOfProductGroups){         
for (Product_Group_Item__c objGroupItem : eachPG.Product_Group_Items__r) {                
Product2 objProduct = (Product2)objGroupItem.Product__r;
if(setOfProductIds.contains(objProduct.id))
continue;
setOfProductIds.add(objProduct.id);
System.debug('++++++objProduct' + objProduct);
Decimal decPrice;
decPrice = (Decimal) objProduct.get(strPriceBookField);

if(decPrice == null)
decPrice = 0;
if (decPrice != null && decPrice != -1) {
BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
objQP.Name = objProduct.Name;
objQP.Line_Number__c = 100;
objQP.BigMachines__Quote__c = objQuote.Id;
objQP.BigMachines__Product__c = objGroupItem.Product__c;
objQP.Product__c = objProduct.Description;
objQP.APN_Number__c = objProduct.APN_Number__c;
objQP.Product_Specific_Discount__c = objProduct.PPU_Product_Specific_Discount__c;
objQP.Pm_Approver__c = objProduct.Product_Manager_Approval_Group__r.Name;
objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
objQP.Third_Party__c = objProduct.Third_Party__c;
objQP.Third_Party_GC__c = objProduct.Third_Party_GC__c;
objQP.Original_Third_Party_GC__c = objProduct.Third_Party_GC__c;
objGroupItem.Quantity__c = objGroupItem.Quantity__c == null ? 1 : objGroupItem.Quantity__c;
// Committed Quantity stores the quantity of the product in the bundle
objQP.Committed_Quantity__c = (objGroupItem.Quantity__c != null ? objGroupItem.Quantity__c : 1);
// Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
objQP.Quantity__c = 1;
objQP.BigMachines__Quantity__c = objQP.Quantity__c;
objQP.List_Price__c = decPrice;
objQP.Partner_Price__c = decPrice;                    
objQP.BigMachines__Sales_Price__c = 0;
objQP.or_Amount__c = '%';
objQP.Disc__c = eachPG.Additional_Discount__c;
objQP.Bundle_Discount__c = eachPG.Discount__c;
objQP.Bundle__c = eachPG.Id;
listOfQuoteProductsToBeInserted.add(objQP);
}
}        
}
if(!listOfQuoteProductsToBeInserted.isEmpty())
insert listOfQuoteProductsToBeInserted;
*/
    }
    
    public List<Product_Group__c> getProductGroupQuery(Set<Id> setOfBundleIds, String strPriceBookField){
        String strQuery = 'SELECT Id, Name, Play_Offer__c, Description__c, Type__c, Quantity__c, Discount__c, Additional_Discount__c, Price__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c, Product__r.Product_Group__c, Offering_Type__c , Product__r.' + strPriceBookField + ','
            + ' (SELECT Quantity__c, Product__r.Building_Block__c, Product__r.APN_Number__c, Product__r.NG1_PPU_USD__c, Product__r.Pricing_Model__c,Price_Weightage__c,'
            + ' Product__r.Name, Product__r.Description, Product__r.PPU_Product_Specific_Discount__c, Product__r.Product_Specific_Discount__c, Product__r.Product_Manager_Approval_Group__r.Name,'
            + ' Product__r.Product_Group__c, Product__r.' + strPriceBookField + ','
            + ' Product__r.Unit_of_Measure__c, Product__r.Third_Party__c, Product__r.Third_Party_GC__c, Product_Type__c FROM Product_Group_Items__r)'            
            + ' FROM Product_Group__c WHERE id IN: setOfBundleIds';
        List<Product_Group__c> listOfProductGroups = (List<Product_Group__c>) Database.query(strQuery);            
        return listOfProductGroups;
    }
    
    public void addBundleWithLinesToQuote(BigMachines__Quote__c objQuote, Set<Id> setOfBundleIds, String Type, String PureSuccess){
        String strPriceBookField = objQuote.New_Price_Book__c + '_Price__c';
        Decimal decPricingMultiplier = 1;
        List<Product_Group__c> listOfProductGroups = getProductGroupQuery(setOfBundleIds, strPriceBookField);       
        System.debug(selectedPlayOffer+selectedPlayOfferType);
        System.debug(listOfProductGroups);
        List<List<BigMachines__Quote_Product__c>> listOfRelatedSellableItemLines = new List<List<BigMachines__Quote_Product__c>>();                      
        List<BigMachines__Quote_Product__c> listOfBundlesToBeInserted = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> listOfBundlesItemsToBeInserted = new List<BigMachines__Quote_Product__c>();
        //Getting Base Package license amount.
        Decimal decPackagePercentage = 100;
        if(Type == 'Base Package'){
            decPackagePercentage = QuoteUtil.getPackagePricingPercentage(objQuote.Offering_Type__c, PureSuccess, 'License');
            System.debug('NKC debug decPackagePercentage [' + decPackagePercentage + ']');
        }
        for (Product_Group__c eachBundle : listOfProductGroups) {  
            System.debug('NKC debug eachBundle [' + eachBundle + ']');
            BigMachines__Quote_Product__c objBundleQP = new BigMachines__Quote_Product__c();
            objBundleQP.CurrencyISOCode = objQuote.CurrencyISOCode;
            objBundleQP.Name = eachBundle.Name;
            objBundleQP.BigMachines__Quote__c = objQuote.Id;
            objBundleQP.BigMachines__Product__c = eachBundle.Product__c;
            objBundleQP.Unit_of_Measure__c = eachBundle.Product__r.Unit_of_Measure__c;
            objBundleQP.Quantity__c = (eachBundle.Quantity__c == null ? 1 : eachBundle.Quantity__c);
            objBundleQP.BigMachines__Quantity__c = objBundleQP.Quantity__c;
            //objBundleQP.List_Price__c = eachBundle.Price__c;
            objBundleQP.BigMachines__Sales_Price__c = 0;
            objBundleQP.or_Amount__c = '%';
            objBundleQP.Disc__c = eachBundle.Additional_Discount__c;
            objBundleQP.Bundle_Discount__c = eachBundle.Discount__c;
            objBundleQP.Bundle__c = eachBundle.Id;
            objBundleQP.List_Price__c = 0;
            //Rony Joseph-June 5 2019-Trial Automation - Start
            objBundleQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
            objBundleQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
            objBundleQP.Billing_Category__c = objQuote.Billing_Category__c;           
            objBundleQP.Type_of_Product__c  = 'Ordinary';
            //Rony Joseph-June 5 2019-Trial Automation -End
            if(Type == 'PureSuccess')
                //objBundleQP.Line_Number__c = (objOppQuoteCategory.Platform_Type__c == 'Cloud')?++intLineNumber:9999;
               objBundleQP.Line_Number__c = ++intLineNumber;
                //-Navaneetha - Nov 28th 2019 - Used to track the line number for the quote product level- 
            else
               //objBundleQP.Line_Number__c = (objOppQuoteCategory.Platform_Type__c == 'Cloud')?++intLineNumber:0;
                objBundleQP.Line_Number__c = ++intLineNumber;
                //-Navaneetha - Nov 28th 2019 - Used to track the line number for the quote product level- 
            System.debug('####Name:'+objBundleQP.Name+' '+'Line Number:'+intLineNumber); 
            listOfBundlesToBeInserted.add(objBundleQP);
            
            // Added by Ashish on the request of Ranjith (01/22/2019)
            objBundleQP.APN_Number__c = eachBundle.Product__r.APN_Number__c;
            
            if(Type == 'Base Package' && eachBundle.Product__r.Product_Group__c == 'Use Case' && eachBundle.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) //commented By Ankit on 2/1/2019
                objBundleQP.Hide_Record__c = true;
            
            objBundleQP.Play__c = selectedPlayOffer;
            //objBundleQP.Offer__c = selectedPlayOfferType;
            
            Product2 objBaseProduct;
            if(eachBundle.Product__c != null){
                String strProductId = eachBundle.Product__c;
                String strQuery = 'SELECT ' + strPriceBookField + ' FROM Product2 WHERE id =: strProductId';
                List<Product2> listOfProducts = (List<Product2>) Database.query(strQuery);
                objBaseProduct = listOfProducts[0];
                objBundleQP.List_Price__c = (Decimal)objBaseProduct.get(strPriceBookField);
            }
            List<BigMachines__Quote_Product__c> list_SellableItemLines = new List<BigMachines__Quote_Product__c>();
            for (Product_Group_Item__c objGroupItem: eachBundle.Product_Group_Items__r) {
                Product2 objProduct = (Product2)objGroupItem.Product__r;
                if(objProduct == null)
                    continue;
                System.debug('++++++objProduct' + objProduct);
                Decimal decPrice ;
                if(Type == 'Base Package' && objBaseProduct != null){
                    System.debug('strPriceBookField = ' + strPriceBookField); System.debug('decPackagePercentage = ' + decPackagePercentage);
                    //Base Package Price be determined by the Base Package Product Line and weightage on each group item
                    decPrice = (Decimal) objBaseProduct.get(strPriceBookField);                    
                    System.debug('NKC debug decPrice [' + decPrice + ']');
                    decPrice = (decPrice * decPackagePercentage) / 100;
                    System.debug('NKC debug decPrice [' + decPrice + ']');
                    if(decPrice != null && objGroupItem.Price_Weightage__c != null){
                        decPrice = (decPrice * objGroupItem.Price_Weightage__c) / 100 ;
                        System.debug('NKC debug decPrice [' + decPrice + ']');
                    }                    
                }
                else{
                    decPrice = (Decimal) objProduct.get(strPriceBookField);
                }
                System.debug('NKC debug decPrice [' + decPrice + ']');
                if(decPrice == null || (eachBundle.Type__c != null && (eachBundle.Type__c.equalsIgnoreCase('EQUIP') || eachBundle.Type__c.equalsIgnoreCase('Partner PureSuccess'))))
                    decPrice = 0;
                if (decPrice != null && decPrice != -1) {
                    BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                    objQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                    objQP.Weightage__c = objGroupItem.Price_Weightage__c;
                    objQP.Name = objProduct.Name;
                    objQP.BigMachines__Quote__c = objQuote.Id;
                    objQP.BigMachines__Product__c = objGroupItem.Product__c;
                    ProductId_set.add(objGroupItem.Product__c);
                    objQP.Product__c = objProduct.Description;
                    objQP.APN_Number__c = objProduct.APN_Number__c;
                    objQP.Product_Specific_Discount__c = objProduct.PPU_Product_Specific_Discount__c;
                    objQP.Pm_Approver__c = objProduct.Product_Manager_Approval_Group__r.Name;
                    objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
                    objQP.Third_Party__c = objProduct.Third_Party__c;
                    objQP.Third_Party_GC__c = objProduct.Third_Party_GC__c;
                    objQP.Original_Third_Party_GC__c = objProduct.Third_Party_GC__c;
                    //Rony Joseph-June 5 2019-Trial Automation - Start
                    objQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                    objQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                    objQP.Billing_Category__c = objQuote.Billing_Category__c;                
                    objQP.Type_of_Product__c  = 'Ordinary';
                    //Rony Joseph-June 5 2019-Trial Automation -End
                    objGroupItem.Quantity__c = objGroupItem.Quantity__c == null ? 1 : objGroupItem.Quantity__c;
                    // Committed Quantity stores the quantity of the product in the bundle
                    objQP.Committed_Quantity__c = (objGroupItem.Quantity__c != null ? objGroupItem.Quantity__c : 1);
                    // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                    objQP.Quantity__c = 1;
                    objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                    objQP.List_Price__c = decPrice;
                    if(Type == 'PureSuccess')
                        objQP.Hide_Record__c = true;
                    
                    // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                    if (objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objProduct.Pricing_Model__c) &&
                        objProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                        objQP.List_Price__c *= decPricingMultiplier;
                    //objBundleQP.List_Price__c += objQP.List_Price__c;
                    objQP.BigMachines__Sales_Price__c = 0;
                    objQP.or_Amount__c = '%';
                    objQP.Disc__c = eachBundle.Additional_Discount__c;
                    objQP.Bundle_Discount__c = eachBundle.Discount__c;
                    objQP.Bundle__c = eachBundle.Id;
                    objQP.Play__c = selectedPlayOffer;
                    objQP.Line_Number__c =(Type != 'PureSuccess')?++intLineNumber:0;
                    System.debug('####Name:'+objQP.Name+' '+'Line Number:'+intLineNumber);//  objQP.Offer__c = selectedPlayOfferType;
                    listOfBundlesItemsToBeInserted.add(objQP);
                }
            }            
            listOfRelatedSellableItemLines.add(listOfBundlesItemsToBeInserted);
        }
        // Skip Triggers
        Util.Bypass_Trigger_Chk = true;
        if(!listOfBundlesToBeInserted.isEmpty()){
            insert listOfBundlesToBeInserted;
            
            for(Integer i=0; i < listOfBundlesToBeInserted.size(); i++){
                for(BigMachines__Quote_Product__c objQP : listOfRelatedSellableItemLines[i]){
                    objQP.Bundle_Line__c = listOfBundlesToBeInserted[i].Id;
                }
            }
            
            if(!listOfBundlesItemsToBeInserted.isEmpty())
                insert listOfBundlesItemsToBeInserted;
            //Anju Dec 18 usecases
            if(objOppQuoteCategory.Platform_Type__c == 'Cloud')
                intLineNumber = QuoteCloudUtil.createDependentAndOverages(listOfBundlesItemsToBeInserted, objQuote , intLineNumber);
        }
        Util.Bypass_Trigger_Chk = false;
    }
    
    
    // method to create PPU Quote and return it's page reference
    public pageReference createPPUQuote() {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.BigMachines__Opportunity__c = objOpty.Id;
        objQuote.Quote_Created_Date__c = System.today();
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.Grid_Group_By__c = 'Categories';
        objQuote.Service_Level__c = 'Business';
        objQuote.Pricing_Model__c = 'PPU';
        system.debug('navanee5');
        objQuote.PPU_Rental__c = true;
        objQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objQuote.Offering_Type__c = objOpty.Quote_Type1__c;
        objQuote.Order_Numb_of_Maint_Months__c = 12;
        objQuote.Duration_Unit__c = 'Months';
        
        if ([SELECT count() FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: objOpty.id] == 0) {
            objQuote.Is_Business_Primary__c = true;
            objQuote.BigMachines__Is_Primary__c = true;
            blnIsPrimaryQuote = true;
            updateLeadOfferOnOpportunity('PureEngage Cloud Partner PPU');
        }
        
        // Example : Basic Care-New(End User)
        String strGCProdName = objQuote.Service_Level__c + ' Care-New';
        
        if (objOpty.AccountId != null) {
            objQuote.End_User_ID__c = objOpty.AccountId;
            objQuote.BigMachines__Account__c = objOpty.AccountId;
        }
        
        if (objOpty.BusinessPartner__c != null)
            objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c;
        else
            objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
        
        strGCProdName += ' (Partner)';
        
        if (objOpty.Support_Owner__c != null)
            objQuote.Support_Owner__c = objOpty.Support_Owner__c;
        
        if (objOpty.System_Integrator__c != null)
            objQuote.System_Integrator__c = objOpty.System_Integrator__c;
        
        objQuote.CurrencyISOCode = objOpty.CurrencyISOCode;
        objQuote.Quote_Business_Type__c = 'Cloud';
        
        // Default quote expiration after 90 days
        objQuote.Expiration_Date__c = Date.today().addDays(90);
        
        //Ashish Mar 26, 2019: To populate currency/Play on Quote               
        objQuote.New_Price_Book__c = QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode);        
        objQuote.Top_Play__c = selectedPlayOffer;
        objQuote.Offer__c = selectedPlayOfferType;
        
        BigMachines__Quote_Product__c objServiceLevel = null;
        List < Product2 > list_Temp1 = [SELECT Id, Name, Unit_of_Measure__c
                                        FROM Product2 WHERE Description =: strGCProdName AND
                                        Genesys_Care_Quote__c = true AND IsActive = true
                                       ];
        if (list_Temp1.size() > 0) {
            objServiceLevel = new BigMachines__Quote_Product__c(BigMachines__Quantity__c = 1,
                                                                BigMachines__Sales_Price__c = 0);
            objServiceLevel.Name = list_Temp1[0].Name;
            objServiceLevel.Unit_of_Measure__c = list_Temp1[0].Unit_of_Measure__c;
            objServiceLevel.BigMachines__Product__c = list_Temp1[0].Id;
        }
        
        try {
            insert objQuote;
            
            objQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: objQuote.id].Quote_Number__c;
            update objQuote;
            
            if (objServiceLevel != null) {
                objServiceLevel.BigMachines__Quote__c = objQuote.Id;
                insert objServiceLevel;
            }
            //Below line added by Ankit on 5/31/2017
            if(blnIsPrimaryQuote)
                objOpty.Primary_Quote__c = objQuote.id;
            
            //Ashish Mar 26, 2019 usecases : add selected use cases     
            addUseCases(objQuote);
            
            return (new PageReference('/apex/CreateQuotePPU?id=' + objQuote.Id));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }
        return null;
    }
    
    // method to create Cloud Quote and return it's page reference
    public pageReference createCloudQuote() {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
        objQuote.BigMachines__Opportunity__c = objOpty.Id;
        objQuote.Quote_Created_Date__c = System.today();
        objQuote.BigMachines__Status__c = 'Quote In Progress';
        objQuote.CurrencyISOCode = objOpty.CurrencyISOCode;
        objQuote.Quote_Business_Type__c = 'Cloud';
        objQuote.End_User_ID__c = objOpty.AccountId;
        objQuote.Initial_Subscription_Term__c = '1 Year';
        objQuote.Renewal_Subscription_Term__c = 'Automatic Annual';
        objQuote.Period__c = 'Monthly';
        objQuote.Billing_Period__c = 'Monthly';
        objQuote.Order_Payment_Terms__c = 'Net 30';
        objQuote.Offering_Type__c = objOpty.Quote_Type1__c;        
        objQuote.Pricing_Model__c = objOppQuoteCategory.Pricing_Model__c;
        objQuote.Selling_Entity__c = objOpty.Country_Selling_Entity__c;
        objQuote.Expiration_Date__c = Date.today() + 90;
        objQuote.SOW_Link__c = objOpty.SOW_Url__c;
        objQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objQuote.MSA_Link_Type__c = 'Standard';
        objQuote.Keep_the_existing_estate_on_Perpetual__c = strIsNewInstanceforLeadOffer == Null ? false : Boolean.valueOf(strIsNewInstanceforLeadOffer);
        objQuote.Does_customer_currently_have_PureSuccess__c = strExistingPureSuccessCustomer == Null ? false : Boolean.valueOf(strExistingPureSuccessCustomer);
        
        //Ashish Jan 18, 2019: To populate currency/Play on Quote
        objQuote.New_Price_Book__c = QuoteUtil.getPriceBookForCICCaas(objOpty.CurrencyIsoCode);
        objQuote.Top_Play__c = selectedPlayOffer;
        objQuote.Offer__c = selectedPlayOfferType;
        
        if (objQuote.Offering_Type__c == 'Business Edition' || objQuote.Offering_Type__c == 'Enterprise Edition')
            objQuote.MSA_Link__c = getMSALink(objQuote.Offering_Type__c);
        else if (objQuote.Offering_Type__c == 'Premier Edition' || objQuote.Offering_Type__c == 'Self Service')
            objQuote.MSA_Link__c = Label.MSA_Links.split(';;')[1].trim();
        else
            objQuote.MSA_Link__c = Label.MSA_Links.split(';;')[2].trim();
        
        List < RecordType > list_CloudRT = [SELECT Id FROM RecordType WHERE SobjectType = 'BigMachines__Quote__c'
                                            AND Name = 'Cloud Quote'
                                            LIMIT 1
                                           ];
        if (!list_CloudRT.isEmpty())
            objQuote.RecordTypeId = list_CloudRT[0].Id;
        
        if ([SELECT count() FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c =: objOpty.id] == 0) {
            objQuote.Is_Business_Primary__c = true;
            objQuote.BigMachines__Is_Primary__c = true;
            blnIsPrimaryQuote = true;
            if(objQuote.Offering_Type__c == 'Premier Edition')
                updateLeadOfferOnOpportunity('Premier Edition Cloud');
            else if(objQuote.Offering_Type__c == 'Outbound Engagement')
                updateLeadOfferOnOpportunity('Outbound Engagement Cloud');
            else
                updateLeadOfferOnOpportunity('PureEngage Cloud');
        }
        
        if (objOpty.Direct_Sales__c)
            objQuote.Sold_To_Name__c = objQuote.End_User_ID__c;
        else
            objQuote.Sold_To_Name__c = objOpty.BusinessPartner__c;
        
        List < Account > list_SoldTo = [SELECT Street1__c, Street2__c, Street3__c, ZipCode__c, City__c, StateProvince__c,
                                        Business_Country__c, Phone FROM Account WHERE Id =: objQuote.Sold_To_Name__c
                                       ];
        if (!list_SoldTo.isEmpty()) {
            objQuote.Sold_To_Address__c = list_SoldTo[0].Street1__c;
            objQuote.Sold_To_Zip_Code__c = list_SoldTo[0].ZipCode__c;
            objQuote.Sold_To_State__c = list_SoldTo[0].StateProvince__c;
            objQuote.Sold_To_Country__c = list_SoldTo[0].Business_Country__c;
            objQuote.Sold_To_City__c = list_SoldTo[0].City__c;
            objQuote.Sold_To_Phone__c = list_SoldTo[0].Phone;
        }
        try {
            insert objQuote;
            
            objQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE Id =: objQuote.Id].Quote_Number__c;
            if(objOpty.Lever__c !=null && objOpty.Avaya_Contract_Expiration__c !=null){
                objQuote = QuoteCloudUtil.updateLeverDetials(objQuote,objOpty,map_LeverSelection);
            }
            update objQuote;
            
            //Below line added by Ankit on 5/31/2017
            if(blnIsPrimaryQuote)
                objOpty.Primary_Quote__c = objQuote.id;
            
            //Ashish Jan 17, 2019 usecases : add selected use cases
            addUseCases(objQuote);
            
            if (objQuote.Offering_Type__c == 'Business Edition' || objQuote.Offering_Type__c == 'Enterprise Edition')
                return (new PageReference('/apex/ServiceOrderQuoteToolBE?id=' + objQuote.Id));
            else if (objQuote.Offering_Type__c == 'Premier Edition')
                return (new PageReference('/apex/ServiceOrderQuoteToolPE?id=' + objQuote.Id));
            else
                return (new PageReference('/apex/ServiceOrderQuoteTool?id=' + objQuote.Id));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }
        
        return null;
    }
    
    //Change Opp Pricebook to standard pricebook Anju Oct 9 Starts
    public void changePriceBook(){         
        if(objOpty.Pricebook2Id != Label.Standard_Pricebook_Id){
            List<Opportunitylineitem> toDelete = new List<opportunitylineitem>();
            todelete = [Select id from opportunitylineitem where opportunityid = :objOpty.id];
            if(todelete.size() > 0)
                delete toDelete;
            system.debug(objOpty.Pricebook2Id);
            objOpty.Pricebook2Id = Label.Standard_Pricebook_Id;
            update objOpty;
        }        
    }
    //Change Opp Pricebook to standard pricebook Anju Oct 9 Ends
    
    public void onSelectSmallMedOffer() {
        if ( isSmallMediumCenter ) {            
            refresh();
            selectedPlayOffer = 'None';
            selectedPlayOfferType = '';
        }
    }
    
    public void refresh(){
        list_PlayOffer.clear();
        list_PlayOffer.add(new SelectOption('', '--None--'));
        list_PlayOffer.add( new SelectOption('None', 'None'));
        list_PlayOfferType = new List<SelectOption>{new SelectOption('', '--None--')};      
            Set<String> set_Unique = new Set<String>();
        
        if(objOppQuoteCategory.Lead_Offer__c != '' && (objOppQuoteCategory.Order_Type__c != '' || strSelectedOrderType == 'New' || objOppQuoteCategory.Quote_Type__c == 'Self Service' || objOppQuoteCategory.Quote_Type__c == 'Business Edition' || objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud Partner PPU')){
            for(Play_Offer__mdt playOffer : [SELECT Offering_Type__c, Plat_Category__c, Play_O__c, HelpMessage__c FROM Play_Offer__mdt WHERE Offering_Type__c =: objOppQuoteCategory.Lead_Offer__c]){
                if(!set_Unique.contains(playOffer.Plat_Category__c)){
                    list_PlayOffer.add(new SelectOption(playOffer.Plat_Category__c, playOffer.Plat_Category__c));
                    set_Unique.add(playOffer.Plat_Category__c);                 
                }            
            }
        }
        System.debug('###showPbLevers'+showPbLevers);
        System.debug('###strSelectedOrderType'+strSelectedOrderType);
        
        if ( (objOppQuoteCategory.Lead_Offer__c == 'PureConnect Premise Subscription' || objOppQuoteCategory.Lead_Offer__c == 'PureCloud' || objOppQuoteCategory.Lead_Offer__c == 'PureEngage Cloud'|| 
              objOppQuoteCategory.Lead_Offer__c == 'PureConnect Cloud' || objOppQuoteCategory.Lead_Offer__c == 'PureEngage Premise Subscription' || objOppQuoteCategory.Lead_Offer__c == 'PureEngage Premise' || 
              objOppQuoteCategory.Lead_Offer__c == 'PureConnect Premise' ) &&
            (strSelectedOrderType != null && strSelectedOrderType != '' && strSelectedOrderType.startsWith('New')) && pbLevers.size() > 0 && !isSmallMediumCenter)
            showPbLevers = true;
        else 
            showPbLevers = false;
    }   
    
    //Added By Ranjith on Oct 23, 2017 -- Starts
    public List<SelectOption> getOrderTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        if(objOpty.RecordType.Name != 'Cloud Renewal') {options.add(new SelectOption('New','New'));}
        if (intSubscrSize > 0 && objOppQuoteCategory.Offering_Details__c != 'Free Trial' ) {                 
            options.add(new SelectOption('Amend','Amend'));
            //Naresh 10/17/2018 'Subscription' should not show in order type
            /*
if(objOppQuoteCategory.Offering_Type__c != 'PureCloud' && objOppQuoteCategory.Lead_Offer__c != 'PureConnect Cloud') {
options.add(new SelectOption('Subscription','Subscription'));
}
*/
        }
        if(objOppQuoteCategory.Lead_Offer__c == 'PureConnect Premise Subscription' 
           || objOppQuoteCategory.Lead_Offer__c == 'PureEngage Premise Subscription'){          
               options.add(new SelectOption('Migration','Migration'));       
           }
        return options;
    }
    public List<SelectOption> getSubscrSubTypes() {
        List<SelectOption> options = new List<SelectOption>();  
        if(strSelectedOrderType == Label.Order_Type_Amend) {      
            options.add(new SelectOption('Amend Existing Subscription','Amend Existing Subscription'));
            if(objOppQuoteCategory.Quote_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ||objOppQuoteCategory.Quote_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) 
                options.add(new SelectOption('Replace Existing Subscription','Replace Existing Subscription'));
            if(objOpty.RecordType.Name == 'Cloud Renewal')  // Added By Ranjith on Oct 9th, 2018
                options.add(new SelectOption('Renew Existing Subscription','Renew Existing Subscription'));            
        } 
        else {
            options.add(new SelectOption('New PureCloud Org & Subscription','New PureCloud Org & Subscription'));
        }
        return options;
    }
    //Added By Ranjith on Oct 23, 2017 -- Ends
    
    //Added By Ranjith on Dec 15, 2017 -- Starts
    @testvisible
    private void createIVRDataStorageParts(BigMachines__Quote__c objQuote) {
        Set<String> set_IVRDataStrgPartNos = new Set<String>();
        String[] arr_IVRDataStrgPartNos = Label.IVR_Data_Storage_Parts.split(';');
        System.debug('####arr_IVRDataStrgPartNos: '+arr_IVRDataStrgPartNos);
        List<BigMachines__Quote_Product__c> list_IVRDataStorageParts = new List<BigMachines__Quote_Product__c>();
        for(Integer i=0; i<arr_IVRDataStrgPartNos.size(); i++) {
            set_IVRDataStrgPartNos.add(arr_IVRDataStrgPartNos[i]);
        }
        System.debug('####set_IVRDataStrgPartNos: '+set_IVRDataStrgPartNos);
        for(Product2 objProd : [SELECT Id, Name, APN_Number__c, NG1_APAC_ANZ_AUD_Price__c, NG2_BRAZIL_BRL_Price__c, 
                                NG5_NZD_Price__c, NG3_EMEA_GBP_Price__c, NG4_APAC_JAPAN_YEN_Price__c, 
                                NG3_EMEA_EUR_Price__c, NG5_NA_CAD_Price__c, NG5_ZAR_Price__c, NG5_NA_USD_Price__c
                                FROM Product2 
                                WHERE APN_Number__c IN :set_IVRDataStrgPartNos]) {
                                    BigMachines__Quote_Product__c objNewQP = new BigMachines__Quote_Product__c();
                                    objNewQP.BigMachines__Quote__c = objQuote.Id;
                                    objNewQP.Name = objProd.Name;
                                    objNewQP.APN_Number__c = objProd.APN_Number__c;
                                    objNewQP.BigMachines__Product__c = objProd.Id;            
                                    objNewQP.BigMachines__Quantity__c = objNewQP.Quantity__c = 0;            
                                    objNewQP.List_Price__c = (Decimal)objProd.get(objQuote.New_Price_Book__c + '_Price__c') != null ? (Decimal)objProd.get(objQuote.New_Price_Book__c + '_Price__c') : 0;
                                    //objNewQP.Partner_Price__c = ;
                                    //objNewQP.Net_Unit_Price__c = ;
                                    objNewQP.BigMachines__Sales_Price__c = objNewQP.Net_Unit_Price__c != null ? objNewQP.Net_Unit_Price__c : 0;
                                    objNewQP.Ext_List__c = 0;
                                    objNewQP.Ext_Net_Price__c = 0;
                                    objNewQP.Hide_Record__c = true;
                                    objNewQP.Is_Overage__c = true;
                                    objNewQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                                    //Rony Joseph-June 5 2019-Trial Automation - Start
                                    objNewQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                                    objNewQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                                    objNewQP.Billing_Category__c = objQuote.Billing_Category__c;                                   
                                    objNewQP.Type_of_Product__c  = 'Ordinary';
                                    //Rony Joseph-June 5 2019-Trial Automation -End
                                    objNewQP.Line_Number__c  = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                                    System.debug('####Name:'+objNewQP.Name+' '+'Line Number:'+intLineNumber);
                                    System.debug('####objNewQP'+objNewQP);
                                    list_IVRDataStorageParts.add(objNewQP);
                                }
        insert list_IVRDataStorageParts;
        System.debug('####list_IVRDataStorageParts'+list_IVRDataStorageParts);
    }
    private String getMSALink(String strOfferingType) {
        String strURL = '';
        for(Links__mdt objMSALink : [SELECT Country__c, Link_Type__c, Offering_Type__c, URL__c 
                                     FROM Links__mdt 
                                     WHERE Offering_Type__c =: strOfferingType
                                     AND Link_Type__c = 'MSA'
                                     AND (Country__c =: objOpty.Sold_To_Country__r.Name OR Country__c = 'Default') LIMIT 2]) {
                                         strURL = objMSALink.URL__c;
                                         if(objMSALink.Country__c == objOpty.Sold_To_Country__r.Name) {
                                             break;
                                         }
                                     }   
        return strURL;
    }
    
    
    @testvisible
    private Decimal getPCMonthlyMinimum() {
        Decimal decPCMnthlyMin = 2000;
        Decimal decConversionRate = 1;
        Map<String, Decimal> map_ConversionRates = QuoteUtil.buildConversionRatesMap();
        if(objOpty.Country_Sub_Region__c == 'Velocity') {
            decPCMnthlyMin = 1500;
        }
        else if(objOpty.BusinessPartner__c != null) {
            decPCMnthlyMin = 1000;
            if(objOpty.Direct_Indirect_Sale__c == 'Indirect' && objOpty.BusinessPartner__r.Approved_for_PureCloud_Billing__c) {
                decPCMnthlyMin = 750;
            }
        }
        
        //decConversionRate = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode =: objOpty.CurrencyIsoCode AND IsActive = true].ConversionRate;
        if(map_ConversionRates.containsKey(objOpty.CurrencyIsoCode)) {
            decConversionRate = map_ConversionRates.get(objOpty.CurrencyIsoCode);
        }
        return (decPCMnthlyMin * decConversionRate).setScale(2);
    }
    //Added By Ranjith on Dec 15, 2017 -- Ends
    
    private void updateLeadOfferOnOpportunity(String strLeadOffer){
        System.debug('NKC debug strLeadOffer [' + strLeadOffer + ']');
        objOpty.Lead_Offer__c = strLeadOffer;
    }
    
    public void getLevers() {
        pbLevers = new List<PBLever>();
        List<String> opptlever = new List<String>();
        Map<String, List<String>> leversByType = new  Map<String, List<String>>{
            'PureConnect Premise Subscription' => new List<String>{'Lever 2', 'Lever 3'},
                'PureEngage Premise Subscription' => new List<String>{'Lever 1', 'Lever 2', 'Lever 3'},
                    'PureCloud' => new List<String>{'Lever 1', 'Lever 2', 'Lever 3'}, 
                        'PureConnect Cloud' => new List<String>{'Lever 2','Lever 3'}, 
                            'PureEngage Cloud' => new List<String>{'Lever 1', 'Lever 2', 'Lever 3', 'Lever 4'},
                                'PureConnect Premise' => new List<String> {'Lever 2', 'Lever 3','Lever 5'}, 
                                    'PureEngage Premise' => new List<String>{'Lever 2', 'Lever 3','Lever 5'} 
        };
            
            if ( objOpty.Lever__c != null )
            opptlever = objOpty.Lever__c.split(';');
        opptlever.sort();
        for (String ol : opptlever ) {
            if ( objOppQuoteCategory.Lead_Offer__c != null && leversByType.containsKey(objOppQuoteCategory.Lead_Offer__c) )
                if ( leversByType.get(objOppQuoteCategory.Lead_Offer__c).contains(ol) )
                pbLevers.add(new PBLever(ol));
        }
        
        //showPbLevers = pbLevers.size() > 0 && !isSmallMediumCenter ? true : false;
    }
    
    public class PBLever {
        public Boolean isSelected {get; set;}
        public String lever {get; set;}
        
        public PBLever(String lvr) {
            this.lever = lvr;
            this.isSelected = true;
        }
    }
    
    public class PlayOfferWrapper {
        public boolean isSelected {get; set;}
        public Product_Group__c prdGrp {get; set;}
        
        public PlayOfferWrapper(Product_Group__c prdGrp){
            this.prdGrp = prdGrp;
            this.isSelected = true;
        }
    }
}