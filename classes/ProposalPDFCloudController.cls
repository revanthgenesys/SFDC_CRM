public class ProposalPDFCloudController 
{
    String strQuoteId;
    public BigMachines__Quote__c objQuote {get; private set;}
    public List<Service_Order_Product_Group__c> list_ProductGroups {get; private set;}
    public Map<String,List<BigMachines__Quote_Product__c>> map_ProductGroupToQuoteProducts {get; private set;}
    public Map<String,Boolean> map_ProductGroupsToShow {get; private set;}
        
    //Anju Jan 2018 PureSuccess starts
    public Map<String,Boolean> map_PureSuccessProductGroupsToShow {get; private set;}
    public Map<String,List<Product_Group_Item__c>> map_PureSuccesGroupItems {get; private set;}
    public List<BigMachines__Quote_Product__c> list_AlacItems {get; private set;}
    //Anju Jan 2018 PureSuccess ends
    
    public Boolean blnHasRecurring {get; private set;}
    public Boolean blnHasNonRecurring {get; private set;}
    public Boolean blnHasNonTrainingOrPS {get; private set;}
    
    // *** For Premier Edition ***
    public Boolean blnHasIVR {get; private set;}
    public Boolean blnHasTelco {get; private set;}
    public Boolean blnHasAgentSeats {get; private set;}
    
    //PEC new sub totals
    public Decimal Network_Access_Fees {get; private set;}
    public Decimal Platform_Access_Fees {get; private set;}
    public Decimal Outbound_Fees {get; private set;}
    
    //Anju August 2018 new changes on output
    public Boolean blnHas3GP104566ABAA {get; private set;}
    public Boolean blnHas3GP107415ABAA {get; private set;}
	public Boolean blnHasPredictiveRoutingProd{get;private set;}
    public Decimal decPricefor3GP104566ABAA {get; private set;} 
    public Decimal decOriginalPricefor3GP104566ABAA {get; private set;}
    public Boolean blnHasPureSuccess {get; private set;}
    public Boolean blnHasSocialMediaProducts{get; private set;}
    
    // *** Constructor ***
    public ProposalPDFCloudController()
    {
        Network_Access_Fees = Platform_Access_Fees = Outbound_Fees = 0;
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        blnHasRecurring = blnHasNonRecurring = blnHasNonTrainingOrPS = blnHasIVR = blnHasTelco = blnHasAgentSeats = blnHas3GP104566ABAA = blnHasPureSuccess = blnHas3GP107415ABAA = blnHasPredictiveRoutingProd = blnHasSocialMediaProducts = false;
        list_AlacItems = new List<BigMachines__Quote_Product__c>();
        fetchQuote();
        initializeProductGroups();
        fetchQuoteProducts();
        
    }
    
    // *** Method to query Quote ***
    void fetchQuote()
    {
        objQuote = [SELECT Id,Name,Selling_Entity__c,Sold_To_Name__r.Name,Sold_To_Address__c,Sold_To_City__c,Sold_To_State__c,End_User_ID__r.Name,
                    Sold_To_Zip_Code__c,Sold_To_Country__c,Expiration_Date__c,Quote_Created_Date_Formula__c,Owner.Name,Contact__r.Name,
                    Contact__r.ContactPhone__c,Contact__r.Email,Initial_Subscription_Term__c,No_Of_Months__c,Renewal_Subscription_Term__c
                    ,CurrencyIsoCode,Minimum_Fees_Period__c,Period__c,Order_Payment_Terms__c,Billing_Period__c,Pricing_Model__c,
                    Is_IVR_And_Media_Ports__c,Is_Add_Ons_And_Enabled_Inbound_Agents__c,Is_Communication_Circuits_Phone_Numbers__c,
                    Include_Special_Offer_in_Output__c,Special_Offer_Terms__c,Additional_Legal_Terms__c,Legal_Terms__c,
                    SOW_Link__c,MSA_Link__c,Annual_Contract_Value__c,Setup_Provisioning_Charges__c,CPS_Total__c,Total_Contract_Value__c,
                    Offering_Type__c,Is_All_In_One_Per_Seat_Selected__c,Is_Standard_Per_Seat_Selected__c,Opp_Sold_To_Country__c,
                    Is_All_In_One_Per_Minute_Selected__c,Is_Standard_Per_Minute_Selected__c,Hide_Discount__c,Hide_Totals__c,Treat_SO_as_PO__c,
                    Genesys_University_Training_Total__c,Cloud_Care_Total__c,Proposal_Date__c,Has_Usage_Based_Fees__c,Non_Recurring_Fees__c,
                    Token_Value__c,PureSuccess_Offer_Subscription_Amount__c,A_La_Carte_PureSuccess_Services_Amount__c,PureSuccess__c 
                    FROM BigMachines__Quote__c WHERE Id = :strQuoteId];
    }
    
    // *** Method to query Quote Products ***
    void fetchQuoteProducts()
    {
        for(BigMachines__Quote_Product__c objQP : Database.query(createQuoteProductQueryString()))
        {
            if(map_ProductGroupToQuoteProducts.containsKey(objQP.Product_Group__c))
                map_ProductGroupToQuoteProducts.get(objQP.Product_Group__c).add(objQP);
            else
            {
                map_ProductGroupToQuoteProducts.put(objQP.Product_Group__c,new List<BigMachines__Quote_Product__c>{objQP});
                map_ProductGroupsToShow.put(objQP.Product_Group__c,true);
            }
            
            // [SM 2/16/2017] Access Fees is not included in CMRR but is still recurring
            if(objQP.Product_Group__c != 'Per Message/Per Minute')
            {
                if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c || objQP.Product_Group__c == 'Access Fees')
                    blnHasRecurring = true;
                else
                    blnHasNonRecurring = true;
            }
            
            if(objQP.Product_Group__c != 'Genesys University Training' && objQP.Product_Group__c != 'Professional Services Implementation')
                blnHasNonTrainingOrPS = true;
            
            if(objQuote.Offering_Type__c == 'Premier Edition')
            {
                if(objQP.Product_Group__c == 'Self-Service/IVR' || objQP.Product_Group__c == 'Self-Service/IVR Options' ||
                   objQP.Product_Group__c == 'Self-Service/IVR Integrations' || objQP.Product_Group__c == 'Outbound Campaign Manager')
                    blnHasIVR = true;
                
                else if(objQP.Product_Group__c == 'Telecommunications Options' || objQP.Product_Group__c == 'Connectivity Options')
                    blnHasTelco = true;
                
                else if(objQP.Product_Group__c == 'Per Seat Pricing' || objQP.Product_Group__c == 'Inbound Seat Add-On Options' ||
                  objQP.Product_Group__c == 'End User End Points' || objQP.Product_Group__c == 'Adapter Service Options')
                    blnHasAgentSeats = true;
            }
            
            //Oct 12 new pec fields anju
            if(objQuote.Offering_Type__c == 'Business Edition')
            {
                if(objQP.Product_Group__c == 'Telco Cross Connect')
                    Network_Access_Fees += objQP.Extended_Price_Per_Month__c;
                if(objQP.Product_Group__c == 'Access Fees')
                    Platform_Access_Fees += objQP.Extended_Price_Per_Month__c;
                if(objQP.Product_Group__c == 'Short/Long Code Non Recurring Fees' || objQP.Product_Group__c == 'SW/Platform Implementation')
                    Outbound_Fees += objQP.Extended_Price_Per_Month__c;
            }
            
            //Anju Jan 2018 PureSuccess starts
            if(map_PureSuccessProductGroupsToShow.containskey(objQP.BigMachines__Product__c))
            {
                map_PureSuccessProductGroupsToShow.put(objQP.BigMachines__Product__c,true);
                blnHasPureSuccess = true;
            }
            
            if(objQP.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.Product_Group__c == 'PureSuccess Indirect A-la-Carte')
            {
                list_AlacItems.add(objQP);
                blnHasPureSuccess = true;
            }
            //Anju Jan 2018 PureSuccess ends
            
            //Anju August 2018 New changes on output
            if(objQP.BigMachines__Product__r.apn_number__c == '3GP104566ABAA')
            {
                blnHas3GP104566ABAA = true;
                decPricefor3GP104566ABAA = objQP.Net_Unit_Price__c;
            }
            if(objQP.BigMachines__Product__r.apn_number__c == '3GP107415ABAA')
            {
                blnHas3GP107415ABAA = true;
                
            }
              if(objQP.BigMachines__Product__r.apn_number__c == '3GP110507ABAA' || objQP.BigMachines__Product__r.apn_number__c == '3GP110508ABAA' )
            {
                blnHasPredictiveRoutingProd = true;
                
            }
			
              if(objQP.BigMachines__Product__r.apn_number__c == '3GP109231ABAA' || objQP.BigMachines__Product__r.apn_number__c == '3GP109315ABAA' || objQP.BigMachines__Product__r.apn_number__c == '3GP109232ABAA' || objQP.BigMachines__Product__r.apn_number__c == '3GP109233ABAA')
            {
                blnHasSocialMediaProducts =  true;
            } 
        }
        
        //Anju Sep 17 change for Cloud storage
        List<Product2> list_CloudStorageProducts = new List<Product2>();
        list_CloudStorageProducts = [SELECT id, List_Price__c, List_Price_AUD__c, List_Price_CAD__c, List_Price_EUR__c, List_Price_GBP__c
                                     FROM Product2
                                     WHERE APN_Number__c = '3GP104566ABAA'];
        if(list_CloudStorageProducts.size() > 0)
        {
            if(objQuote.CurrencyIsoCode == 'GBP')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price_GBP__c;
            else if(objQuote.CurrencyIsoCode == 'EUR')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price_EUR__c;
            else if(objQuote.CurrencyIsoCode == 'CAD')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price_CAD__c;
            else if(objQuote.CurrencyIsoCode == 'AUD')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price_AUD__c;
            else if(objQuote.CurrencyIsoCode == 'USD')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price__c;
        }
    }
    
    // *** Method to create query string to query Quote Products ***
    String createQuoteProductQueryString()
    {
        String strQuery = 'SELECT ';
        
        //Getting fields from Service Order Output field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> list_QuoteProductFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Service_Order_Output.getFields();
        for(Schema.FieldSetMember field : list_QuoteProductFields)
            strQuery += field.getFieldPath() + ', ';
        
        strQuery += 'Unit_of_Measure__c,BigMachines__Product__r.description,BigMachines__Product__r.description__c,BigMachines__Quantity__c,BigMachines__Quote__r.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + 
                        objQuote.Id + '\' ORDER BY BigMachines__Product__r.Sort_Order__c,Name';
        
        return strQuery;
    }
    
    // *** Method to initialize Product Groups from custom settings ***
    void initializeProductGroups()
    {
        map_ProductGroupToQuoteProducts = new Map<String,List<BigMachines__Quote_Product__c>>();
        map_ProductGroupsToShow = new Map<String,Boolean>();
        map_PureSuccessProductGroupsToShow = new Map<String,Boolean>();
        map_PureSuccesGroupItems = new Map<String,List<Product_Group_Item__c>>();
        
        String strEdition = 'Non BE';
        if(objQuote.Offering_Type__c == 'Business Edition')
            strEdition = 'BE';
        else if(objQuote.Offering_Type__c == 'Outbound Engagement')
            strEdition = 'OBE';
        else if(objQuote.Offering_Type__c == 'Premier Edition')
            strEdition = 'PE';
        
        list_ProductGroups = [SELECT Group_Name__c,Header_Text__c FROM Service_Order_Product_Group__c 
                              WHERE Edition__c = :strEdition ORDER BY Name];
        
        for(Service_Order_Product_Group__c objProductGroup : list_ProductGroups)
            map_ProductGroupsToShow.put(objProductGroup.Group_Name__c,false);
        
        //Anju Jan 2018 PureSuccess starts
        for(Product_Group__c pG : [Select id,Product__c,(Select id,name,Quantity__c,Product__c,Product__r.name,Product__r.description,Product__r.description__c,Product__r.Unit_of_Measure__c from Product_Group_Items__r where Product__r.APN_Number__c != :Label.Token_APN_Number) from Product_Group__c where Offering_Type__c includes ('PureEngage Cloud')]){
            map_PureSuccessProductGroupsToShow.put(pG.Product__c,false);
            map_PureSuccesGroupItems.put(pG.Product__c,pG.Product_Group_Items__r);
        }
        //Anju Jan 2018 PureSuccess ends
    
    }
}