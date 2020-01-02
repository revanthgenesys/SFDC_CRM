/* @Class Name   : RFPReportController 
 * @Description  : This is a controller class for preparing the Vf template which needs to be sent as RFP weekly support table.
 * @Created On   : 26/11/2014 
 */
public without sharing class RFPReportController {  
    // sfdc URL of the instance
    public String sfdcURL {get;set;}
    public String virtualTeamMemberName {get;set;}
    public string reportRegion{get;set;}
    
    /**    
    * @Description: Getter method to populate the records from RFP records as per the report. This is used to prepare the data table 
    * @Param: none
    * @Return: List<wrapperResult>
    */
    public List<wrapperResult> getRFPRecords(){
        sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String query;
        System.Debug('reportRegion--->'+reportRegion);
        if(reportRegion == 'Global'){
            query = Label.RFP_Support_Req_Weekly_Query + Label.RFP_Query_Second;
        }
        else if(reportRegion == 'APAC'){
            query = Label.RFP_Support_Req_Weekly_Query + Label.RFP_Query_Second_APAC;
        }
        else if(reportRegion == 'LATAM'){
            query = Label.RFP_Support_Req_Weekly_Query + Label.RFP_Query_Second_LATAM;
        }
        else if(reportRegion == 'EMEA'){
            query = Label.RFP_Support_Req_Weekly_Query + Label.RFP_Query_Second_EMEA;
        }
        else if(reportRegion == 'NA'){
            query = Label.RFP_Support_Req_Weekly_Query + Label.RFP_Query_Second_NA;
        }
        
        /*'SELECT Id,Name,Extension_Due_Date__c,Due_Date__c, Proposal_Outcome_1__c,'+
                       'Opportunity__r.AccountId, Opportunity__r.Account.Name, Document_Type__c,'+
                       'Proposal_Manager__c, Opportunity__r.OwnerId, Opportunity__r.Owner.Name,'+
                       'Solution_Engineer_Name__c, Direct_Sales__c, Total_Score__c, Total_Amount__c,'+
                       'Opportunity__r.License_Amount__c, Solution_Type__c, Sold_To_Business_Partner__r.Name,'+
                       'Opportunity__r.Country_Sub_Region__c,Proposal_Status__c, Sold_To_Business_Partner__r.Id'+
                       ' FROM RFP_Support_Request__c'+
                       ' WHERE Proposal_Status__c =\'Response Complete\' ORDER BY Opportunity__r.Country_Sub_Region__c ASC';*/
                       
        
        List<RFP_Support_Request__c> rfpRecords = (List<RFP_Support_Request__c>)Database.query(query);
        List<wrapperResult> wrapperResults = new List<wrapperResult>();     
        Set<String> setOfSubRegions = new Set<String>();
        Set<String> setOfRegions = new Set<String>();
        
        //Below Code Added by Priyank
        Set<String> oppId = new Set<String>();
        for(RFP_Support_Request__c eachRec : rfpRecords){
            oppId.add(eachRec.Opportunity__c);  
        }
        Map<String,String> mapOppUserName = new Map<String,String>();
        for(DSR_Virtual_Team__c dsrName : [SELECT Virtual_Team_Member_Name__r.Name, SCE_ID__r.Opportunity_ID__c FROM DSR_Virtual_Team__c
                        WHERE Virtual_User_Role__c = 'Virtual Team' AND IsPrimary__c = TRUE 
                        AND Virtual_User_type__c = 'Solution Consultant' AND SCE_ID__r.Opportunity_ID__c IN: oppId AND SCE_ID__r.SC_Engagement_Status__c != 'Rejected']){
            mapOppUserName.put(dsrName.SCE_ID__r.Opportunity_ID__c, dsrName.Virtual_Team_Member_Name__r.Name);                   
        }
        //Priyank Code Ended
        //Looping over each record
        for(RFP_Support_Request__c eachRec : rfpRecords){
           
           if(!setOfRegions.contains(eachRec.Opportunity__r.Country_Region__c)){
                wrapperResult headerRecord = new wrapperResult();
                headerRecord.isHeader= true;
                headerRecord.isHeaderRecord = false;
                headerRecord.headerName = eachRec.Opportunity__r.Country_Region__c;
                wrapperResults.add(headerRecord);
                setOfRegions.add(eachRec.Opportunity__r.Country_Region__c);
            }   
          
            if(!setOfSubRegions.contains(eachRec.Opportunity__r.Country_Sub_Region__c)){
                wrapperResult headerRecord = new wrapperResult();
                headerRecord.isHeaderRecord = true;
                 headerRecord.isHeader= false;
                
                headerRecord.headerName = eachRec.Opportunity__r.Country_Sub_Region__c;
                wrapperResults.add(headerRecord);
                setOfSubRegions.add(eachRec.Opportunity__r.Country_Sub_Region__c);
            }
                       
              
            wrapperResult newRecord = new wrapperResult();
            //Below Code Added by Priyank
            if(mapOppUserName.containsKey(eachRec.Opportunity__c)){
                newRecord.solutionConsultant = mapOppUserName.get(eachRec.Opportunity__c);
            }
            else if(!string.isBlank(eachRec.Solution_Engineer_Name__c)){
                newRecord.solutionConsultant = eachRec.Solution_Engineer_Name__c;
            }
            else{
                newRecord.solutionConsultant = '';
            }
            //Priyank Code Ended
            newRecord.record = eachRec;
            newRecord.isHeaderRecord = false;
            newRecord.isHeader= false;
            wrapperResults.add(newRecord);         
             
        }
        if(wrapperResults.isEmpty()){
            wrapperResult headerRecord = new wrapperResult();
            headerRecord.isHeaderRecord = true;
            headerRecord.isHeader = true;
            headerRecord.headerName = 'No RFP Support Requests found.'; // Use Custom Label
            wrapperResults.add(headerRecord);
        }
        return wrapperResults;
    }
    
    /**    
    * @Description: wrapper class to display the records in a format that will be sent in email
    
    */
    public class wrapperResult{
        public RFP_Support_Request__c record {get;set;}
        public String headerName {get;set;}
        public String solutionConsultant {get;set;}
        public Boolean isHeaderRecord {get;set;}
        public Boolean isHeader {get;set;}
    
    }
}