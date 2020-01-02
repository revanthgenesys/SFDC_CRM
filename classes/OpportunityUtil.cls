/************************************************************************************
Purpose : Util class for CCDB / Renewal functions
Written By : Ranjith Punneli
Test Classes : OpportunityUtilTest
*************************************************************************************/
public class OpportunityUtil
{
    //Update Legal Deal Review on Subscription when Opportunity changes
    /*
    public static void UpdateLegalDealReviewonOpportuntiy(Map<Id, Opportunity> list_OpportunitiesOld, Map<Id, Opportunity> list_OpportunitiesNew)
    {
        List<Opportunity> list_AmendedOpportunities = new List<Opportunity>();
        
        List<Opportunity> list_NewOpportunities = [SELECT id, Primary_Quote__c, Primary_Quote__r.Offering_Type__c, Override_Legal_Exceptions__c, Primary_Quote__r.Order_Type__c, Primary_Quote__r.Amendment_For__r.Legal_Exceptions__c
                                                   FROM Opportunity
                                                   WHERE id in :list_OpportunitiesNew.keyset()];
        for(Opportunity opp : list_NewOpportunities)
        {
            if(opp.Primary_Quote__c != null && opp.Primary_Quote__c != list_OpportunitiesOld.get(opp.id).Primary_Quote__c && opp.Primary_Quote__r.Offering_Type__c == 'PureCloud' && !opp.Override_Legal_Exceptions__c && opp.Primary_Quote__r.Order_Type__c == 'Amend Subscription')
            {
                opp.Legal_Exceptions__c = opp.Primary_Quote__r.Amendment_For__r.Legal_Exceptions__c;
                list_AmendedOpportunities.add(opp);
            }
        }
        if(list_AmendedOpportunities.size() > 0)
        {
            Util.Bypass_Trigger_Chk = true;
            update list_AmendedOpportunities;
        }
        
    }
    
    //Update Subscription when opportunity changes
    public static void UpdateSubscriptionFromOpportunity(Map<Id, Opportunity> list_OpportunitiesOld, Map<Id, Opportunity> list_OpportunitiesNew)
    {
        List<Subscription__c> list_Subscriptions = new List<Subscription__c>();
        Map<Id, Opportunity> map_OpportunityDealReview = new Map<Id, Opportunity>();
        
        List<Opportunity> list_NewOpportunities = [SELECT id, Legal_Exceptions__c, Primary_Quote__c, Primary_Quote__r.Offering_Type__c, 
                                                   Override_Legal_Exceptions__c, Primary_Quote__r.Order_Type__c, 
                                                   Primary_Quote__r.Amendment_For__r.Legal_Exceptions__c
                                                   FROM Opportunity
                                                   WHERE id in :list_OpportunitiesNew.keyset()];
        for(Opportunity opp : list_NewOpportunities)
        {
            if(opp.Primary_Quote__c != null && opp.Primary_Quote__r.Offering_Type__c == 'PureCloud' && opp.Legal_Exceptions__c != list_OpportunitiesOld.get(opp.id).Legal_Exceptions__c)
            {
                map_OpportunityDealReview.put(opp.id,opp);
            }
        }
        for(Subscription__c objSub : [SELECT id,Opportunity_LookUp__c
                                      FROM Subscription__c 
                                      WHERE Opportunity_LookUp__c in :map_OpportunityDealReview.keyset()
                                      AND Offering_Type__c = 'PureCloud'])
        {
            list_Subscriptions.add(new Subscription__c(id = objSub.id, Legal_Exceptions__c = map_OpportunityDealReview.get(objSub.Opportunity_LookUp__c).Legal_Exceptions__c));
        }
        if(list_Subscriptions.size() > 0)
            update list_Subscriptions;
        
    }
    */
    
     
    //Fetch Matching GSRelationship record for account
    public static Map<String,JBCXM__GSRelationship__c> FetchGSRelationship(Set<Id> set_AccountIds)
    {
        Map<String,JBCXM__GSRelationship__c> map_AccountGSRelationship = new Map<String,JBCXM__GSRelationship__c>();
        for(JBCXM__GSRelationship__c objGSRelationship : [SELECT JBCXM__GSCSM__c,JBCXM__Account__c,Offerings_Type__c,Relationship_Type__c
                                                          FROM JBCXM__GSRelationship__c 
                                                          WHERE JBCXM__Account__c IN :set_AccountIds 
                                                          AND PureEngage_Cloud_Stage__c NOT IN('Will Churn','Churned','Migrated')])
        {
            map_AccountGSRelationship.put(objGSRelationship.JBCXM__Account__c + ':' + objGSRelationship.Relationship_Type__c, objGSRelationship);
        }                                                  
        return map_AccountGSRelationship;  
    }
    
    /*
    //Update run rate on opportunity based on Account Revenue forecast
    
    public static void UpdateRunRate(Set<Id> set_OppIds)
    {
        
        String strobjName = 'Opportunity';
        String strWhereCondition = 'id  in :set_OppIds';
        System.debug('Query'+CloneUtility.getCreatableFieldsSOQL(strObjName,strWhereCondition));
        List<Opportunity> list_Opportunities= Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName,strWhereCondition));
        //Create Account - opportunity map
        Map<Id,List<Opportunity>> map_AccountOpportunity = new Map<Id,List<Opportunity>>();        
        for(Opportunity objOpp : list_Opportunities)
        {
            if(map_AccountOpportunity.containskey(objOpp.accountId))
                map_AccountOpportunity.get(objOpp.accountId).add(objOpp);
            else
            {
                map_AccountOpportunity.put(objOpp.accountId, new List<Opportunity> { objOpp }); 
            }
        }
        
        //Find out run rate for account from forecast
        Set<Id> set_AccountIds = new Set<Id>();
        set_AccountIds.addall(map_AccountOpportunity.keyset());
        String strQuery = 'SELECT Id,';
        List<Schema.FieldSetMember> gridFields = SObjectType.Account_Revenue_Forecast__c.FieldSets.Cloud_Renewal_Fields.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuery += field.getFieldPath() + ', ';
        strQuery = strQuery.removeEnd(', ');
        strQuery += ' FROM Account_Revenue_Forecast__c WHERE Account__c in :set_AccountIds AND Cloud_Forecast_Quarter__r.Current_Week__c = True AND Cloud_Forecast_Quarter__r.Active__c = True AND LOB__c = \'A - In-Force Subscription\'';
        system.debug(strQuery);
        
        Map<Integer,String> map_MonthField = new Map<Integer,String>{
        1 => 'Sept_LASTYEAR;Oct_LASTYEAR;Nov_LASTYEAR',
        2 => 'Oct_LASTYEAR;Nov_LASTYEAR;Dec_LASTYEAR',
        3 => 'Nov_LASTYEAR;Dec_LASTYEAR;Jan_THISYEAR',
        4 => 'Dec_LASTYEAR;Jan_THISYEAR;Feb_THISYEAR',
        5 => 'Jan_THISYEAR;Feb_THISYEAR;Mar_THISYEAR', 
        6 => 'Feb_THISYEAR;Mar_THISYEAR;Apr_THISYEAR',
        7 => 'Mar_THISYEAR;Apr_THISYEAR;May_THISYEAR',
        8 => 'Apr_THISYEAR;May_THISYEAR;june_THISYEAR',
        9 => 'May_THISYEAR;june_THISYEAR;Jul_THISYEAR',
        10 => 'june_THISYEAR;Jul_THISYEAR;Aug_THISYEAR',
        11 => 'Jul_THISYEAR;Aug_THISYEAR;Sep_THISYEAR',
        12 => 'Aug_THISYEAR;Sep_THISYEAR;Oct_THISYEAR'
        };
        
        for(Account_Revenue_Forecast__c objForecast : Database.query(strQuery))
        {
            for(Opportunity objOpp : map_AccountOpportunity.get(objForecast.Account__c))
            {
                if(objForecast.Offering_Type__c == objOpp.Lines_of_Businesses__c)
                {
                    DateTime dtOppCreatedDate = objOpp.createddate;
                    Integer intMonth = dtOppCreatedDate.month();
                    String strMonth1 = map_MonthField.get(intMonth).split(';')[0].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                    String strMonth2 = map_MonthField.get(intMonth).split(';')[1].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                    String strMonth3 = map_MonthField.get(intMonth).split(';')[2].replace('LASTYEAR',String.valueof(dtOppCreatedDate.Year() -1)).replace('THISYEAR',String.valueof(dtOppCreatedDate.Year()));
                    
                    Decimal decForecastSum = (Decimal)objForecast.get(strMonth1 +'__c') + (Decimal)objForecast.get(strMonth2 +'__c') + (Decimal)objForecast.get(strMonth3 +'__c'); 
                    objOpp.Run_Rate_USD__c= 4 * decForecastSum;
                    
                    Map<String, Decimal> map_Currencies = new Map<String, Decimal>();
                    map_Currencies = QuoteUtil.buildConversionRatesMap();
                    system.debug(objOpp.ACV_Subscription_Only__c);
                    objOpp.ACV_Change_v_Run_Rate_USD__c = ((objOpp.ACV_Subscription_Only__c / map_Currencies.get(objOpp.CurrencyIsoCode)) - objOpp.Run_Rate_USD__c) > 0 ? 
                                                                (objOpp.ACV_Subscription_Only__c / map_Currencies.get(objOpp.CurrencyIsoCode)) - objOpp.Run_Rate_USD__c : 0;
                    objOpp.Annual_Contract_Value_ACV_Renewal__c = objOpp.ACV_Subscription_Only__c;
                    system.debug(objOpp.ACV_Change_v_Run_Rate_USD__c);
                }
            }
        }
       Update  list_Opportunities;   
    }
    */
    
    //Naresh Kumar  06/07/2018  Populating Platform Type, Offering Type and Offering Details on Opportunity from Lead Offer.
    public static void updatePlatformAndOfferingType(List<Opportunity> listOfOpps, Map<Id, Opportunity> oldMap){
        
        //Looping over each opportunity record
        for(Opportunity eachOpp : listOfOpps){
            if(oldMap == null || eachOpp.Lead_Offer__c != oldMap.get(eachOpp.id).Lead_Offer__c || eachOpp.Primary_Solution__c != oldMap.get(eachOpp.id).Primary_Solution__c ){
                updateOpportunityWithOfferingAndPlatformType(eachOpp);    
            }       
        }
    } 
    
    //Added By navaneetha
    @InvocableMethod 
    public static void updateaccountp2p(List<id> oppid)
    {
     
     List<Account> lstaccount = new List<Account>();
     for (Opportunity iopp : [Select id, Accountid,P2P_Destination_Migration_Platform__c from opportunity where id in: oppid]){
     
     Account Accp2p = new Account();
     Accp2p.id = iopp.Accountid;
     Accp2p.P2P_Migration_Candidate_Destination_Plat__c = iopp.P2P_Destination_Migration_Platform__c;     
     lstaccount.add(Accp2p);
     
     }
     if(lstaccount.Size()>0){
     
     update lstaccount;
     
     }
        
    }
//Added By navaneetha. 
    
    //Naresh Kumar  06/09/2018  Updates opportunity's lead offer field
    @testvisible
    private static void updateOpportunityWithOfferingAndPlatformType(Opportunity objOpp){

        if(objOpp.Lead_Offer__c == 'PureCloud'){
            objOpp.Lines_of_Businesses__c = 'PureCloud';
            objOpp.Primary_Line_of_Business__c = 'Cloud';             
            objOpp.Gainsight_Relationship_Type__c = 'PureCloud';
           //objOpp.Offering_Detail__c = null;            
        }       
         else if(objOpp.Lead_Offer__c == 'PureConnect Premise'){
            objOpp.Lines_of_Businesses__c = 'PureConnect';
            objOpp.Primary_Line_of_Business__c = 'On Premise';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureConnect Premise';           
        }        
        else if(objOpp.Lead_Offer__c == 'PureConnect Cloud'){
            objOpp.Lines_of_Businesses__c = 'PureConnect';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureConnect Cloud';           
        }        
        else if(objOpp.Lead_Offer__c == 'PureConnect Cloud Partner PPU'){
            objOpp.Lines_of_Businesses__c = 'PureConnect';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = 'Cloud Partner (PPU)';
            objOpp.Gainsight_Relationship_Type__c = 'PureConnect Cloud';            
        }
        else if(objOpp.Lead_Offer__c == 'PureConnect Premise Subscription'){
            objOpp.Lines_of_Businesses__c = 'PureConnect';
            objOpp.Primary_Line_of_Business__c = 'On Premise';
           // objOpp.Offering_Detail__c = 'Subscription';  
           objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureConnect Premise';            
        } 
        else if(objOpp.Lead_Offer__c == 'PureConnect Premise Rental'){
            objOpp.Lines_of_Businesses__c = 'PureConnect';
            objOpp.Primary_Line_of_Business__c = 'On Premise';            
            //objOpp.Offering_Detail__c = 'Rental';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureConnect Premise';           
        }
        else if(objOpp.Lead_Offer__c == 'PureEngage Premise'){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'On Premise';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Premise';           
        }
        //else if(objOpp.Lead_Offer__c == 'PureEngage Cloud'&& objOpp.Primary_Solution__c != null)
        else if(objOpp.Lead_Offer__c == 'PureEngage Cloud') // Dec - 05- 2018 -->Ankaiah --> changed the condition as per INC0405536
        {
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
           // objOpp.Offering_Detail__c = null;             // Dec - 05- 2018 -->Ankaiah --> changed the condition as per INC0405536  
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud';            
        }
        else if(objOpp.Lead_Offer__c == 'PureEngage Cloud' && objOpp.Primary_Solution__c != null && !objOpp.Primary_Solution__c.Contains('Outbound')){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud';            
        }
        else if(objOpp.Lead_Offer__c == 'PureEngage Cloud' && objOpp.Primary_Solution__c != null && objOpp.Primary_Solution__c.Contains('Outbound')){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud Outbound';
            system.debug('Navanee26'+  objOpp.Gainsight_Relationship_Type__c );
        }
        else if(objOpp.Lead_Offer__c == 'PureEngage Cloud Partner PPU' && objOpp.Primary_Solution__c == null){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = 'Cloud Partner (PPU)';
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud';            
        } 
        else if(objOpp.Lead_Offer__c == 'PureEngage Cloud Partner PPU' && objOpp.Primary_Solution__c != null && !objOpp.Primary_Solution__c.Contains('Outbound')){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = 'Cloud Partner (PPU)';
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud';            
        }        
        else if(objOpp.Lead_Offer__c == 'PureEngage Cloud Partner PPU' && objOpp.Primary_Solution__c != null  && objOpp.Primary_Solution__c.Contains('Outbound')){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = 'Cloud Partner (PPU)';
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud Outbound';            
        }
        else if(objOpp.Lead_Offer__c == 'PureEngage Premise Subscription'){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'On Premise';            
            //objOpp.Offering_Detail__c = 'Subscription';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Premise';
        }
        else if(objOpp.Lead_Offer__c == 'PureEngage Premise Rental'){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'On Premise';            
            //objOpp.Offering_Detail__c = 'Rental';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Premise';
        }
        else if(objOpp.Lead_Offer__c == 'Premier Edition Cloud'){
            objOpp.Lines_of_Businesses__c = 'Premier Edition';
            objOpp.Primary_Line_of_Business__c = 'Cloud';            
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'Premier Edition';
        }  
        else if(objOpp.Lead_Offer__c == 'Outbound Engagement Cloud'){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = null;
            objOpp.Primary_Solution__c ='Outbound';
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud Outbound';
        }           
       /* else if(objOpp.Lead_Offer__c == 'Outbound Engagement Cloud' && objOpp.Primary_Solution__c != null && !objOpp.Primary_Solution__c.Contains('Outbound')){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud';
        }        
        else if(objOpp.Lead_Offer__c == 'Outbound Engagement Cloud' && objOpp.Primary_Solution__c != null && objOpp.Primary_Solution__c.Contains('Outbound')){
            objOpp.Lines_of_Businesses__c = 'PureEngage';
            objOpp.Primary_Line_of_Business__c = 'Cloud';
            objOpp.Offering_Detail__c = null;
            objOpp.Gainsight_Relationship_Type__c = 'PureEngage Cloud Outbound';
        }*/
        
    }
}