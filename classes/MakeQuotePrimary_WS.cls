//Naresh Kumar  02/01/2014
global without sharing class MakeQuotePrimary_WS {
    static Boolean updatePlateformType = true;
    webservice static String CorrectTotalCloud(String quoteId){
        BigMachines__Quote__c selectedQuote = [SELECT id, BigMachines__Opportunity__c, Cloud_Total__c,BigMachines__Opportunity__r.RecordType.Name,PureCloud_Monthly_Minimum__c,
                                               Annual_Contract_Value__c, Quote_Business_Type__c, Offering_Type__c, Order_Type__c,Billing_Category__c,
                                               Monthly_Commitment__c, Period__c, Initial_Subscription_Term__c, Genesys_University_Training_Total__c,
                                               Cloud_Term_Commitment__c,Total_Contract_Value__c, CPS_Total__c, Support_Total__c,Total_Hardware__c, 
                                               Total_Education__c, Shipping_Handling__c, CMRR__c, BigMachines__Total__c, Total_Services__c,
                                               CMRR_Change__c, Annual_Contract_Value_Change__c, Total_Contract_Value_Change__c,
                                               Services_Change__c, Total_Education_Change__c, Total_Hardware_Change__c,Max_Seat_Count__c,
                                               Total_Software__c, Product_Tier__c, Product_Version__c, License_Amount__c, 
                                               No_Of_Months__c, PPU_Rental__c, A_La_Carte_PureSuccess_Services_Amount__c, Non_Recurring_Fees__c,
                                               PureSuccess_Offer_Subscription_Amount__c, Annual_Contract_Value_2__c, Deal_Score__c,
                                               Annual_Contract_Value_1__c, PureSuccess__c,TAM_Amount__c,TAM_Duration_Months__c
                                               FROM BigMachines__Quote__c WHERE id=:quoteId];
        Opportunity opp = new Opportunity(id = selectedQuote.BigMachines__Opportunity__c);
        
        //Resetting Subscription fields
        opp.A_La_Carte_PureSuccess_Services_Amount__c = 0;
        opp.PureSuccess_Offer_Amount__c = 0;
        opp.ACV_Year_2__c = 0;
        if(selectedQuote.BigMachines__Opportunity__r.RecordType.Name != 'Cloud Renewal'){opp.ACV_Subscription_Only__c = 0;}
        opp.Total_Annual_Contract_Value__c = 0;
        opp.PureSuccess_Offer__c = null;
        opp.Hardware_Total__c  = selectedQuote.Total_Hardware__c;// Commented by navaneetha on hardware total  04-Sep-2019.
         
        opp.Incremental_Agent_Seat_Count__c = selectedQuote.Max_Seat_Count__c;
        if(selectedQuote.PPU_Rental__c && selectedQuote.Offering_Type__c != 'Cloud Partner (PPU)' && selectedQuote.Offering_Type__c != 'PureConnect Subscription' && selectedQuote.Offering_Type__c != 'PureEngage Subscription'){
            opp.Quote_Amount__c = 0;
            opp.Total_PS_Support__c = 0;
           // opp.Hardware_Total__c = 0;
           opp.Hardware_Total__c  = selectedQuote.Total_Hardware__c; // Added by navaneetha for hardware totalfix
            opp.Shipping_Handling__c = 0;
            opp.Education_Amount__c = 0;     
            opp.License_Amount__c = 0;     
            //Resetting cloud totals
            opp.Total_PS_Support__c = 0;     
            opp.ACV_Subscription_Only__c = 0;     
            opp.Annual_Contract_Value_Subscription__c = 0;     
            opp.Total_PS_Support__c = 0;     
            opp.ACV_Subscription_Only__c = 0;     
            opp.Annual_Contract_Value_Subscription__c = 0;     
            opp.Shipping_Handling__c = 0;     
            opp.Education_Amount__c = 0;     
            opp.Total_Annual_Contract_Value__c = 0;
            opp.Monthly_Commitment__c = 0;
            opp.Term_License__c = 0;
        }
        else if(selectedQuote.Quote_Business_Type__c == 'Cloud')
        {
            opp.Term_Commitment__c = selectedQuote.Initial_Subscription_Term__c;
            opp.Frequency_Term__c = selectedQuote.Period__c;
            if(selectedQuote.CPS_Total__c == null)
                selectedQuote.CPS_Total__c = 0;
            if(selectedQuote.Support_Total__c == null)
                selectedQuote.Support_Total__c = 0;         
            if(selectedQuote.Cloud_Total__c == null)
                selectedQuote.Cloud_Total__c = 0;           
            if(selectedQuote.Annual_Contract_Value__c == null)
                selectedQuote.Annual_Contract_Value__c = 0; 
            opp.Total_PS_Support__c = selectedQuote.CPS_Total__c;           
            opp.Annual_Contract_Value_new__c = selectedQuote.Annual_Contract_Value__c + opp.Total_PS_Support__c;
            if(selectedQuote.BigMachines__Opportunity__r.RecordType.Name != 'Cloud Renewal'){opp.ACV_Subscription_Only__c = opp.Annual_Contract_Value_new__c - opp.Total_PS_Support__c;}
            //Anju May 2018 foe BE ACV shoul include TAM
            if(selectedQuote.Offering_Type__c == 'Business Edition')
                opp.ACV_Subscription_Only__c = (opp.ACV_Subscription_Only__c == null ? 0 : opp.ACV_Subscription_Only__c) + (selectedQuote.TAM_amount__c == null ? 0 : selectedQuote.TAM_amount__c);
            opp.Total_Annual_Contract_Value__c = selectedQuote.Cloud_Total__c;          
            opp.Annual_Contract_Value_Subscription__c = selectedQuote.Cloud_Total__c - opp.Total_PS_Support__c;         
            // Ticket 31610 : Write CMRR from quote to Opportunity.
            //opp.Monthly_Commitment__c = selectedQuote.Monthly_Commitment__c;
            opp.Monthly_Commitment__c = selectedQuote.CMRR__c; 
            // Resetting License Amount Field
            opp.License_Amount__c = 0;
            //Sep 14 Anju adding education amount starts
            if(selectedQuote.Genesys_University_Training_Total__c != null)
                opp.Education_Amount__c = selectedQuote.Genesys_University_Training_Total__c;
            if(selectedQuote.Total_Education__c != null)
                opp.Education_Amount__c = selectedQuote.Total_Education__c ;
            //Sep 14 Anju adding education amount ends
            //PureSuccess total Anju Jan 2018
            opp.A_La_Carte_PureSuccess_Services_Amount__c = selectedQuote.A_La_Carte_PureSuccess_Services_Amount__c;
            opp.PureSuccess_Offer_Amount__c = selectedQuote.PureSuccess_Offer_Subscription_Amount__c;
            opp.PureSuccess_Offer__c =  selectedQuote.PureSuccess__c; 
            //Anju June 1 TAM
            opp.TAM_Services_Amount__c = selectedQuote.TAM_Amount__c;
            opp.TAM_Duration_Months__c = selectedQuote.TAM_Duration_Months__c;
            //Added By Ranjith on Nov 21, 2017 -- Starts   
            if(selectedQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || selectedQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || selectedQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC) {             
                opp.Total_PS_Support__c = selectedQuote.Order_Type__c == Label.Amend_Subscription ? selectedQuote.Services_Change__c : selectedQuote.Total_Services__c;
                opp.Education_Amount__c = selectedQuote.Order_Type__c == Label.Amend_Subscription ? selectedQuote.Total_Education_Change__c : selectedQuote.Total_Education__c;
               //Hardware total for cloud 
               opp.Hardware_Total__c = selectedQuote.Order_Type__c == Label.Amend_Subscription ? selectedQuote.Total_Hardware_Change__c : selectedQuote.Total_Hardware__c;
                
                opp.Monthly_Commitment__c = selectedQuote.Order_Type__c == Label.Amend_Subscription ? selectedQuote.CMRR_Change__c :((selectedQuote.Billing_Category__c == 'M2M' && selectedQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)?selectedQuote.PureCloud_Monthly_Minimum__c:selectedQuote.CMRR__c); 
                opp.CMRR_Change__c = selectedQuote.CMRR_Change__c;  
                opp.Subscription_CMRR__c = selectedQuote.Order_Type__c == Label.Amend_Subscription ? selectedQuote.CMRR_Change__c : selectedQuote.CMRR__c;
                opp.Subscription_CMRR_Change__c = selectedQuote.CMRR_Change__c;  
                opp.Annual_Contract_Value_new__c = selectedQuote.Order_Type__c == Label.Amend_Subscription ? selectedQuote.Annual_Contract_Value_Change__c : selectedQuote.Annual_Contract_Value__c;
                if(selectedQuote.BigMachines__Opportunity__r.RecordType.Name != 'Cloud Renewal'){opp.ACV_Subscription_Only__c = selectedQuote.Order_Type__c == Label.Amend_Subscription ? selectedQuote.Annual_Contract_Value_Change__c :  ((selectedQuote.Billing_Category__c == 'M2M' && selectedQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)?(selectedQuote.PureCloud_Monthly_Minimum__c*12):selectedQuote.Annual_Contract_Value__c);}                   
                opp.Annual_Contract_Value_Change__c = selectedQuote.Annual_Contract_Value_Change__c;
                System.debug('Opp'+opp.Total_PS_Support__c+'\n'+'Quote'+selectedQuote.Total_Contract_Value__c);
                opp.Total_Annual_Contract_Value__c = (selectedQuote.Billing_Category__c == 'M2M' && selectedQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)?selectedQuote.PureCloud_Monthly_Minimum__c:selectedQuote.Total_Contract_Value__c - opp.Total_PS_Support__c;
                opp.Total_Contract_Value_Change__c = selectedQuote.Total_Contract_Value_Change__c - opp.Total_PS_Support__c;
                if(selectedQuote.Order_Type__c == Label.Amend_Subscription) {
                    opp.Total_Annual_Contract_Value__c = selectedQuote.Total_Contract_Value_Change__c;
                   // opp.Offering_Detail__c = selectedQuote.Total_Contract_Value_Change__c >= 0 ? 'Amendment – Upgrade' : 'Amendment – Downgrade'; 
                  // Dec 04 2019 -- Ankaiah -- The below code has been added as per the INC0437617
                    String strAU = 'Amendment – Upgrade';
                    strAU = strAU.replaceAll('a-zA-Z0-9\\s+','');
                       system.debug('====>'+ strAU);
                
                    String strAD = 'Amendment – Downgrade';
                    strAD = strAD.replaceAll('a-zA-Z0-9\\s+','');
                       system.debug('====>'+ strAD); 
                    opp.Offering_Detail__c = selectedQuote.Total_Contract_Value_Change__c >= 0 ? strAU : strAD ; 
                
                }                
            }             
            //Added By Ranjith on Nov 21, 2017 -- Ends
        }
        else if(selectedQuote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC){
            opp.Quote_Amount__c = selectedQuote.BigMachines__Total__c;
            opp.Total_PS_Support__c = selectedQuote.Total_Services__c;
              opp.Hardware_Total__c = selectedQuote.Total_Hardware__c;  // Added by navaneetha on hardware total  04-Sep-2019.
         
           
            opp.Shipping_Handling__c = selectedQuote.Shipping_Handling__c;
            opp.Education_Amount__c = selectedQuote.Total_Education__c;     
            if(selectedQuote.License_Amount__c != null)
                opp.License_Amount__c = selectedQuote.License_Amount__c;
            //Resetting cloud totals
            opp.Total_PS_Support__c = opp.Annual_Contract_Value_new__c = 
                opp.ACV_Subscription_Only__c = opp.Total_Annual_Contract_Value__c =
                opp.Annual_Contract_Value_Subscription__c = opp.Monthly_Commitment__c = 0;
        }        
        else if(selectedQuote.Offering_Type__c == 'PureEngage Subscription' || selectedQuote.Offering_Type__c == 'PureConnect Subscription'){
            opp.Total_PS_Support__c = opp.Annual_Contract_Value_new__c = 
                opp.Total_Annual_Contract_Value__c =
                opp.Annual_Contract_Value_Subscription__c = opp.Monthly_Commitment__c = 0;
            opp.Shipping_Handling__c = selectedQuote.Shipping_Handling__c = 0;
            opp.Education_Amount__c = selectedQuote.Total_Education__c = 0;
            opp.Term_License__c = selectedQuote.Annual_Contract_Value__c;
            opp.A_La_Carte_PureSuccess_Services_Amount__c = selectedQuote.A_La_Carte_PureSuccess_Services_Amount__c;
            opp.PureSuccess_Offer_Amount__c = selectedQuote.PureSuccess_Offer_Subscription_Amount__c;
            opp.ACV_Year_2__c = selectedQuote.Annual_Contract_Value_2__c;
            opp.ACV_Subscription_Only__c = selectedQuote.Annual_Contract_Value_1__c;
            
            opp.Hardware_Total__c = selectedQuote.Total_Hardware__c; // Added by navaneetha for hardware totalfix
            
            opp.Total_Annual_Contract_Value__c = selectedQuote.Cloud_Total__c;
            opp.PureSuccess_Offer__c = selectedQuote.PureSuccess__c;
            opp.Offering_Detail__c = 'Subscription';
            if(selectedQuote.No_Of_Months__c != null){
                Integer intYear = Integer.valueOf(selectedQuote.No_Of_Months__c / 12);
                if(intYear > 1)
                    opp.Term_Commitment__c = intYear + ' Years';
                else
                    opp.Term_Commitment__c = intYear + ' Year';
            }
            
        }
        else{
            opp.Total_PS_Support__c = opp.Annual_Contract_Value_new__c = 
                opp.ACV_Subscription_Only__c = opp.Total_Annual_Contract_Value__c =
                opp.Annual_Contract_Value_Subscription__c = opp.Monthly_Commitment__c = 0;
            opp.Shipping_Handling__c = selectedQuote.Shipping_Handling__c;
            opp.Education_Amount__c = selectedQuote.Total_Education__c;
            opp.Hardware_Total__c = selectedQuote.Total_Hardware__c; // Added by navaneetha for hardware totalfix
            if(selectedQuote.License_Amount__c != null)
                opp.License_Amount__c = selectedQuote.License_Amount__c;
        }
        if(!updatePlateformType){
            List<BigMachines__Quote_Product__c> quoteProducts = [SELECT BigMachines__Product__r.Type__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId];
            Set<String> setOfferingType = new Set<String>();
            for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
                //if(eachQuoteProduct.BigMachines__Product__r.Type__c == 'Cloud' || eachQuoteProduct.BigMachines__Product__r.Type__c == 'Product')
                setOfferingType.add(eachQuoteProduct.BigMachines__Product__r.Type__c);
            }
            String plateformType;
            /*
List<String> listProductType = new List<String>();
listProductType.addAll(setOfferingType); 
if(listProductType.size() == 1){
plateformType = listProductType[0]; 
}
else if(listProductType.size() == 2){
plateformType = listProductType[0] + ';' + listProductType[1]; 
}
*/
            if(setOfferingType.contains('Cloud'))
                plateformType = 'Cloud';        
            if(setOfferingType.size() > 1 || (!setOfferingType.contains('Cloud') && setOfferingType.size() == 1)){
                plateformType += ';On Premise';
            }
            //plateformType = plateformType.replace('Product', 'On Premise');
            opp.Primary_Line_of_Business__c= plateformType;            
        }
        else 
            opp.Primary_Line_of_Business__c= selectedQuote.Quote_Business_Type__c;
        //Naresh Kumar  08/08/2017  Populating Offering type from Primary Quote to Opportunity
        if(selectedQuote.Offering_Type__c != null){                            
            if(selectedQuote.Offering_Type__c == 'Premier Edition'){
                opp.Lines_of_Businesses__c = 'PureEngage';                
                opp.Primary_Line_of_Business__c = 'Cloud';
                opp.Lead_Offer__c = 'Premier Edition Cloud';   
                opp.Offering_Detail__c = null;
            }         
            else if(selectedQuote.Offering_Type__c == 'Business Edition'){
                opp.Lines_of_Businesses__c = 'PureEngage';                
                opp.Primary_Line_of_Business__c = 'Cloud';
                opp.Lead_Offer__c = 'PureEngage Cloud';    
                opp.Offering_Detail__c = null;    
            }
            else if(selectedQuote.Offering_Type__c == 'Outbound Engagement'){
                opp.Lines_of_Businesses__c = 'PureEngage';                
                opp.Primary_Line_of_Business__c = 'Cloud';
                opp.Lead_Offer__c = 'Outbound Engagement Cloud';  
                opp.Offering_Detail__c = null;
            }
            else if(selectedQuote.Offering_Type__c == 'PureConnect On Premise' && selectedQuote.PPU_Rental__c != true){
                opp.Lines_of_Businesses__c = 'PureConnect';                
                opp.Primary_Line_of_Business__c = 'On Premise';
                opp.Lead_Offer__c = 'PureConnect Premise';  
                opp.Offering_Detail__c = null;
            }
            else if(selectedQuote.Offering_Type__c == 'PureConnect Cloud'){
                opp.Lines_of_Businesses__c = 'PureConnect';                
                opp.Primary_Line_of_Business__c = 'Cloud';
                opp.Lead_Offer__c = 'PureConnect Cloud';  
                opp.Offering_Detail__c = null;
            }
            else if(selectedQuote.Offering_Type__c == 'PureConnect On Premise' && selectedQuote.PPU_Rental__c == true){
                opp.Lines_of_Businesses__c = 'PureConnect';                
                opp.Primary_Line_of_Business__c = 'On Premise';
                opp.Lead_Offer__c = 'PureConnect Premise Rental';  
                opp.Offering_Detail__c = null;
            }
            else if(selectedQuote.Offering_Type__c == 'PureEngage Cloud'){
                opp.Lines_of_Businesses__c = 'PureEngage';                
                opp.Primary_Line_of_Business__c = 'Cloud';
                opp.Lead_Offer__c = 'PureEngage Cloud';  
                opp.Offering_Detail__c = null;
            }                          
            else if(selectedQuote.Offering_Type__c == 'Cloud Partner (PPU)' && opp.Primary_Line_of_Business__c == 'Cloud'){
                opp.Lines_of_Businesses__c = 'PureEngage';
                opp.Offering_Detail__c = 'Cloud Partner (PPU)';
                opp.Primary_Line_of_Business__c = 'Cloud';
                opp.Lead_Offer__c = 'PureEngage Cloud Partner PPU'; 
            }           
            else if(selectedQuote.Offering_Type__c == 'PureConnect Subscription'){
                opp.Lines_of_Businesses__c = 'PureConnect';                
                opp.Primary_Line_of_Business__c = 'On Premise';
                opp.Lead_Offer__c = 'PureConnect Premise Subscription';  
                opp.Offering_Detail__c = 'Subscription';
            }           
            else if(selectedQuote.Offering_Type__c == 'PureEngage Subscription'){
                opp.Lines_of_Businesses__c = 'PureEngage';                
                opp.Primary_Line_of_Business__c = 'On Premise';
                opp.Lead_Offer__c = 'PureEngage Premise Subscription';    
                opp.Offering_Detail__c = 'Subscription';
            }   
            else if(selectedQuote.Offering_Type__c == 'Cloud Partner (PPU)' && selectedQuote.PPU_Rental__c == true){                    
                opp.Lead_Offer__c = 'PureEngage Cloud Partner PPU';    
            }                      
            //Added By Ranjith on Nov 21, 2017 -- Starts    
            else if(selectedQuote.Offering_Type__c.contains('PureCloud')){
                opp.Lines_of_Businesses__c = 'PureCloud';
                opp.Lead_Offer__c = 'PureCloud'; 
                //Added By Ranjith on Nov 21, 2017 -- Ends
            }
            else
                opp.Lines_of_Businesses__c = 'PureEngage';
        }
        else if((String.isEmpty(selectedQuote.Offering_Type__c) || selectedQuote.Offering_Type__c == 'PureEngage On Premise') && selectedQuote.PPU_Rental__c == true ){
                opp.Lead_Offer__c = 'PureEngage Premise Rental';  
            }
        else{
            opp.Lines_of_Businesses__c = 'PureEngage';
            opp.Lead_Offer__c = 'PureEngage Premise'; 
        }
        opp.Deal_Score__c = selectedQuote.Deal_Score__c;
        opp.Product_Tier__c = selectedQuote.Product_Tier__c;            
        opp.Product_Version__c = selectedQuote.Product_Version__c;
        opp.Primary_Quote__c = selectedQuote.id;        
        //Inserted by Ankit on 7/19
        //Setting up the flag to skip pricing change validation
        opp.Skip_Validation__c = true;
        update opp;
        //Resetting the flag and bypassing all triggers
        Util.Bypass_Trigger_Chk = true;
        opp.Skip_Validation__c = false;
        update opp;
        Util.Bypass_Trigger_Chk = false;       
        update opp;        
        return '';
    }
    
    webservice static String makeQuotePlateformPrimary(List<String> quoteIds, String quoteType){
        List<BigMachines__Quote__c> selectedQuotes = [SELECT id, Is_Business_Primary__c, BigMachines__Opportunity__c,
                                                      Annual_Contract_Value__c,Quote_Business_Type__c,
                                                      Monthly_Commitment__c,Total_Contract_Value__c,
                                                      Cloud_Term_Commitment__c 
                                                      FROM BigMachines__Quote__c WHERE id IN : quoteIds AND Quote_Business_Type__c =: quoteType];
        if(selectedQuotes.size() == 0)
            return 'Please select an On Premise quote to set as On Premise primary.';
        if(selectedQuotes.size() > 1)
            return 'Please select only one quote of type ' + quoteType + ' to set as primary.';
        
        selectedQuotes[0].Is_Business_Primary__c = true;
        
        List<BigMachines__Quote__c> quoteToBeUpdated = [SELECT Is_Business_Primary__c FROM BigMachines__Quote__c 
                                                        WHERE BigMachines__Opportunity__c =: selectedQuotes[0].BigMachines__Opportunity__c AND 
                                                        Quote_Business_Type__c =: quoteType AND Is_Business_Primary__c = true AND id !=: selectedQuotes[0].id];
        for(BigMachines__Quote__c eachQuote : quoteToBeUpdated){
            eachQuote.Is_Business_Primary__c = false;
        }
        quoteToBeUpdated.add(selectedQuotes[0]);
        update quoteToBeUpdated;
        updatePlateformType = false;
        if(quoteType == 'Cloud'){
            CorrectTotalCloud(selectedQuotes[0].id);
        }                
        return '';
    }
    webservice static String getQuoteType(String quoteId){
        List<BigMachines__Quote__c> quote = [SELECT Quote_Business_Type__c FROM BigMachines__Quote__c WHERE id =: quoteId];
        if(!quote.isEmpty()){
            return quote[0].Quote_Business_Type__c;
        }
        return '';
    }
    webservice static String checkForDQStatus(String strOppId, String strQuoteId, Decimal decDiscount, String strTerm, String acv){
        return quoteUtil.checkForDQStatus(strOppId, strQuoteId, decDiscount, strTerm, acv);
    }
}