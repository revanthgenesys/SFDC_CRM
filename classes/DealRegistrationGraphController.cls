public with sharing class DealRegistrationGraphController {
       
    public List<partner_portal_prospect__c> opptyList;
    public List<partner_portal_prospect__c> opptyAllList {get;set;}
    
    public List<PipelineDetailData> pipelineList;
    public List<PipelineDetailData> pipelineAllList {get; set;}
    
    public List<Lead_Referral_Registration__c> leadList;
    public List<Lead_Referral_Registration__c> leadAllList {get;set;}
        
    @TestVisible
    private Map<String,List<partner_portal_prospect__c>> partnerOpptyMap{get;set;}
    @TestVisible
    private Map<String,List<Lead_Referral_Registration__c>> partnerLeadMap{get;set;}
    @TestVisible
    private Map<String, List<PipelineDetailData>> partnerPipelineMap {get; set;}
   
    public String selectedOpptyYear {get;set;}
    public String selectedLeadYear {get;set;}
    public String selectedPipelineYear {get;set;}
    
    public String selectedOpptyQ {get;set;}
    public String selectedLeadQ {get;set;}
    public String selectedPipelineQ {get;set;}
    
    @TestVisible
    private String exportYear;
    @TestVisible
    private String exportType='';
    @TestVisible
    private String exportQtr='';
    @TestVisible
    private Boolean exportDt = false;
    
    public Id acctId {get; private set;}
    
    public AggregateResult[] opptyYearResults;
    public AggregateResult[] leadYearResults;
    public AggregateResult[] pipelineYearResults;
    
    public Map<String,String> mapLeadData = new map<String,String>();
    public Map<String,String> mapOppData = new map<String,String>();
    public Map<String,String> mapPipeLnData = new map<String,String>();
    
    public Boolean showOppData {get;set;}
    public Boolean showLeadData {get;set;}
    public Boolean showPipelineData {get; set;}
    public set<String> quarterSet = new set<String>{'Q1','Q2','Q3','Q4'};

    public boolean isOpportunityReferralPartner {get;set;}
    public boolean isLeadReferralPartner {get;set;}     
    public String dealRegId {get;set;}
    //Constructor
    public DealRegistrationGraphController(){
        User currentUser;
        showOppData = false; 
        showLeadData=false; 
        showPipelineData = false;
        isOpportunityReferralPartner = false;
        isLeadReferralPartner = false;
        
        if(ApexPages.currentPage().getParameters().get('runAs') == null){
            currentUser = [SELECT ContactId,email FROM User where id =:Userinfo.getUserId()];
        } else {
            currentUser = [SELECT ContactId,email FROM User where id = :ApexPages.currentPage().getParameters().get('runAs')];
        }
        // Alex Hostetler
        //currentUser = [SELECT ContactId,email FROM User where id = '0050B000006l4tJ'];
        // Robert Church
        //currentUser = [SELECT ContactId,email FROM User where id = '005U0000001v33q'];
        
        if(ApexPages.currentPage().getParameters().get('Id') != null){
            acctId = ApexPages.currentPage().getParameters().get('Id');
        } 
        
        List<Contact> userContact = [Select AccountId, Account.Name, Account.PartnerType__c, Designated_Partner_Contact__c,
                                     Designated_Contact__c  from Contact where id =:currentUser.ContactId Limit 1]; 
        acctId = (userContact != null && userContact.size() > 0) ? userContact[0].AccountId : null;
        
        if( userContact!=null && userContact.size()>0 && userContact[0].Account.PartnerType__c != null) {
            // Check whether the Current Partner is allowed to register Opportunities
            String partnerType = userContact[0].Account.PartnerType__c;
            List<Partner_Portal_Deal_Registration_Config__c> dealRegistrationConfig = Partner_Portal_Deal_Registration_Config__c.getall().values();
            for(Partner_Portal_Deal_Registration_Config__c ppdr: dealRegistrationConfig){
                if(partnerType.contains(ppdr.Name)){
                    if(ppdr.Opportunity_Registration__c)
                        isOpportunityReferralPartner = true;
                    if(ppdr.Lead_Referral__c)
                        isLeadReferralPartner = true;
                }
            }
        }
       
        if ( ApexPages.currentPage().getParameters().get('exp') == 'true')   {
            exportDt = true;
            exportYear = ApexPages.currentPage().getParameters().get('yr');
            exportQtr = ApexPages.currentPage().getParameters().get('qtr');
            exportType = ApexPages.currentPage().getParameters().get('type');
                  
        } 

        opptyYearResults = [select CALENDAR_YEAR(CreatedDate) from partner_portal_prospect__c where Account__c =: acctId group by CALENDAR_YEAR(CreatedDate) ORDER BY CALENDAR_YEAR(CreatedDate) DESC];
        leadYearResults = [select CALENDAR_YEAR(CreatedDate) from Lead_Referral_Registration__c where Account__c =: acctId group by CALENDAR_YEAR(CreatedDate) ORDER BY CALENDAR_YEAR(CreatedDate) DESC];

        partnerOpptyMap = new Map<String, List<partner_portal_prospect__c>>();
        partnerLeadMap = new Map<String, List<Lead_Referral_Registration__c>>();
        partnerPipelineMap = new Map<String, List<PipelineDetailData>>();
                
        pipelineYearResults = [SELECT CALENDAR_YEAR(CreatedDate) FROM Opportunity WHERE Partner_Opportunity_Registration__c IN 
                                                             (SELECT Id FROM partner_portal_prospect__c WHERE Account__c =: acctId)
                               GROUP BY CALENDAR_YEAR(CreatedDate)];
       
        /// get data lists ready but they are not displaied until Show Details invoked                     
        for (AggregateResult ar : opptyYearResults)  {
            selectedOpptyYear = String.valueOf(ar.get('expr0'));
              
            partnerOpptyMap.put(selectedOpptyYear, partnerOpptyReg(selectedOpptyYear));
        }
                
        for (AggregateResult ar : leadYearResults)  {
            selectedLeadYear = String.valueOf(ar.get('expr0'));
  
            partnerLeadMap.put(selectedLeadYear, partnerLeadReg(selectedLeadYear));
        }
       
        for (AggregateResult ar : pipelineYearResults)  {
            selectedPipelineYear = String.valueOf(ar.get('expr0'));
  
            partnerPipelineMap.put(selectedPipelineYear, pipeline(selectedPipelineYear));
        }
        
        //Set Current year
        selectedOpptyYear = opptyYearResults.size() > 0 ? String.valueOf(opptyYearResults[0].get('expr0')) : String.valueof(Date.Today().Year());
        selectedPipelineYear = pipelineYearResults.size() > 0 ? String.valueOf(pipelineYearResults[0].get('expr0')) : String.valueof(Date.Today().Year());
        selectedLeadYear = leadYearResults.size() > 0 ? String.valueOf(leadYearResults[0].get('expr0')) : String.valueof(Date.Today().Year());
    }
    
     public List<SelectOption> getQtrs() {                
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        options.add(new SelectOption('Q1', 'Q1'));
        options.add(new SelectOption('Q2', 'Q2'));
        options.add(new SelectOption('Q3', 'Q3'));
        options.add(new SelectOption('Q4', 'Q4'));       
        return options;
    }
    
    //values fot the Year dropdown by the object
    public List<SelectOption> getOpptyYears() {
                
        List<SelectOption> options = new List<SelectOption>();
        
        for (AggregateResult ar : opptyYearResults)  {
            String year = String.valueOf(ar.get('expr0'));
            options.add(new SelectOption(year,year));
        }
        if(options.size() == 0){
           options.add(new SelectOption(String.valueof(Date.Today().Year()),String.valueof(Date.Today().Year()))); 
        }
        return options;
    }
            
   public List<SelectOption> getLeadYears() {
                
        List<SelectOption> options = new List<SelectOption>();
        
        for (AggregateResult ar : leadYearResults)  {
            String year = String.valueOf(ar.get('expr0'));
            options.add(new SelectOption(year,year));
        }
        if(options.size() == 0){
           options.add(new SelectOption(String.valueof(Date.Today().Year()),String.valueof(Date.Today().Year()))); 
        }
        return options;
    }
    
   public List<SelectOption> getPpLnYears() {
                
        List<SelectOption> options = new List<SelectOption>();
        
        for (AggregateResult ar : pipelineYearResults)  {
            String year = String.valueOf(ar.get('expr0'));
            options.add(new SelectOption(year,year));
        }
        if(options.size() == 0){
           options.add(new SelectOption(String.valueof(Date.Today().Year()),String.valueof(Date.Today().Year()))); 
        }
        return options;
    }
    
    /// Data for the Show Details lists by the object  
    public List<partner_portal_prospect__c> partnerOpptyReg(String selectedOpptyYear) {
        
       opptyList = new List<partner_portal_prospect__c>();
       opptyAllList = new List<partner_portal_prospect__c>();
       
        //prepare the list of Partner Portal Opportunity Registration
        List<partner_portal_prospect__c> pPortalOpps =  [SELECT Id, Name, Status__c, Amount__c, End_Date__c, CreatedDate, Opportunity__c 
                                                             FROM partner_portal_prospect__c 
                                                             WHERE Account__c =: acctId 
                                                             AND CALENDAR_YEAR(CreatedDate) = :Integer.valueOf(selectedOpptyYear)
                                                             AND Status__c IN ('Awaiting Approval','Request Submitted','Approved','Rejected')
                                                             Order BY CreatedDate desc];
                                                                               
        for(partner_portal_prospect__c pPortalOpp : pPortalOpps ) {
                opptyList.add(pPortalOpp);
                opptyAllList.add(pPortalOpp);
        }
 
        return opptyList;
    }    
    
    public List<Lead_Referral_Registration__c> partnerLeadReg(String selectedLeadYear) {
       
       leadList = new List<Lead_Referral_Registration__c>();
       leadAllList = new List<Lead_Referral_Registration__c>();
       //prepare the list of Partner Portal Lead Referral Registration
       List<Lead_Referral_Registration__c> pPortalLeads =  [SELECT Id, Name, Status__c, CreatedDate, Percentage_Referral_Fee__c,End_Date__c
                                                                 FROM Lead_Referral_Registration__c 
                                                                 WHERE Account__c =: acctId 
                                                                  AND CALENDAR_YEAR(CreatedDate) = :Integer.valueOf(selectedLeadYear)
                                                                  AND Status__c IN ('Request Pending','Approved','Rejected','Expired')
                                                                  Order BY CreatedDate desc] ;         
        
        for(Lead_Referral_Registration__c pPortalLead : pPortalLeads )  {
                leadList.add(pPortalLead);
                leadAllList.add(pPortalLead);
        }
        
        System.Debug('leadList--->'+leadList);        
        return leadList;       
    }
    
    public List<PipelineDetailData> pipeline(String selectedPipelineYear) {
       
       pipelineList = new List<PipelineDetailData>();
       pipelineAllList = new List<PipelineDetailData>();
                    
        List<Opportunity> oppLstYr = [SELECT Id, Name, ForecastStatus__c, Win_Loss_Status__c, StageName, Account.Name, CreatedDate,
                                             Expiration_Date__c, Amount, CurrencyISOCode
                                       FROM Opportunity 
                                      WHERE Partner_Opportunity_Registration__c IN 
                                                 (SELECT Id FROM partner_portal_prospect__c WHERE Account__c =: acctId)                                           
                                       AND CALENDAR_YEAR(CreatedDate) = :Integer.valueOf(selectedPipelineYear)
                                       Order BY CreatedDate desc];
 
        for ( Opportunity opp : oppLstYr )  {
                pipelineList.add(new PipelineDetailData(opp));
                pipelineAllList.add(new PipelineDetailData(opp));
        }
        
        return pipelineList;       
    }
   
   // wrapper for Opportunity - we do not want to extend visibility to the Opportunities to partners 
    public class PipelineDetailData {
        public ID id {get; private set;}
        public String name {get; set;}
        public String forecastStatus {get; set;}
        public String winloss {get; set;}
        public String stage {get; set;}
        public String account {get; set;}
        public Datetime createdate {get; set;}
        public Datetime expdate {get; set;}
        public Decimal amount {get; set;}
        public String currn {get; set;}
        
        public PipelineDetailData (Opportunity opp) {
                if ( opp != null )  {
                        this.id = opp.id;
                        this.name = opp.Name;
                        this.forecastStatus = opp.ForecastStatus__c;
                        this.winloss = opp.Win_Loss_Status__c;
                        this.stage = opp.StageName;
                        this.account = opp.Account.Name;
                        this.createdate = opp.CreatedDate;
                        this.expdate = opp.Expiration_Date__c;
                        this.amount = opp.Amount;
                        this.currn = opp.CurrencyISOCode;
                }                               
        }
    }
    
    // return Datat Lists per the selected year/quarter by the Object,
    // for both, page and exports to excel. Export parameter are sent on URL
    public List<partner_portal_prospect__c> getOpptyReg() {

        if ( exportDt == true && exportType == 'oppreg' ) {
                selectedOpptyYear = exportYear;
                selectedOpptyQ = exportQtr;
        }
               
        if (partnerOpptyMap.get(selectedOpptyYear) == null || partnerOpptyMap.get(selectedOpptyYear).size() < 1)
            return new List<partner_portal_prospect__c>();
       
        List<partner_portal_prospect__c> oppYearLst = partnerOpptyMap.get(selectedOpptyYear);
        List<partner_portal_prospect__c> returnLst = new List<partner_portal_prospect__c>(); 

        if ( selectedOpptyQ == 'Q1')  {
            for (partner_portal_prospect__c pr : oppYearLst) {
                if (pr.CreatedDate.month() <= 3)
                    returnLst.add(pr);
            }
        } 
        else  if ( selectedOpptyQ == 'Q2')  {
            for (partner_portal_prospect__c pr : oppYearLst) {
                if ( pr.CreatedDate.month() > 3 && pr.CreatedDate.month() <=6 )
                    returnLst.add(pr);
            }
        }
        else  if ( selectedOpptyQ == 'Q3')  {
            for (partner_portal_prospect__c pr : oppYearLst) {
                if ( pr.CreatedDate.month() > 6 && pr.CreatedDate.month() <=9 )
                    returnLst.add(pr);
            }
        } 
        else  if ( selectedOpptyQ == 'Q4')  {  
                 for (partner_portal_prospect__c pr : oppYearLst) {
                if ( pr.CreatedDate.month() > 9 )
                    returnLst.add(pr);
            }       
        }
        else
            returnLst = oppYearLst;  
        return returnLst; 
    }
        
    public List<Lead_Referral_Registration__c> getLeadReg() {
        
        if ( exportDt == true && exportType == 'ldreg' )  {
            selectedLeadYear = exportYear;
            selectedLeadQ = exportQtr;
        }
        
        if ( partnerLeadMap.get(selectedLeadYear) == null || partnerLeadMap.get(selectedLeadYear).size() < 1 )
          return new List<Lead_Referral_Registration__c>();  
          
        List<Lead_Referral_Registration__c> ldYearLst = partnerLeadMap.get(selectedLeadYear);
        List<Lead_Referral_Registration__c> returnLst = new List<Lead_Referral_Registration__c>(); 
               
         if ( selectedLeadQ == 'Q1')  {
            for (Lead_Referral_Registration__c ld : ldYearLst) {
                if (ld.CreatedDate.month() <= 3)
                    returnLst.add(ld);
            }
        } 
        else if ( selectedLeadQ == 'Q2')  {
            for (Lead_Referral_Registration__c ld : ldYearLst) {
                if (ld.CreatedDate.month() > 3 && ld.CreatedDate.month() <= 6 )
                    returnLst.add(ld);
            }
        }
        else if ( selectedLeadQ == 'Q3')  {
            for (Lead_Referral_Registration__c ld : ldYearLst) {
                if (ld.CreatedDate.month() > 6 && ld.CreatedDate.month() <= 9 )
                    returnLst.add(ld);
            }
        }
        else if ( selectedLeadQ == 'Q4')  {
            for (Lead_Referral_Registration__c ld : ldYearLst) {
                if (ld.CreatedDate.month() > 9 )
                    returnLst.add(ld);
            }
       }        
       else
           returnLst = ldYearLst;
            System.Debug('partnerLeadMap--->'+partnerLeadMap);
            System.Debug('returnLst--->'+returnLst);
         return returnLst;
    }
    
    public List<PipelineDetailData> getPipeline() {  
        
        if ( exportDt == true && exportType == 'ppln' )  {
             selectedPipelineYear = exportYear;
             selectedPipelineQ = exportQtr;
        }
        
        if ( partnerPipelineMap.get(selectedPipelineYear) == null || partnerPipelineMap.get(selectedPipelineYear).size() < 1 )
          return new List<PipelineDetailData>();
        
        List<PipelineDetailData> pplnYearLst = partnerPipelineMap.get(selectedPipelineYear);
        List<PipelineDetailData> returnLst = new List<PipelineDetailData>(); 
        
        if ( selectedPipelineQ == 'Q1')  {
            for (PipelineDetailData pl : pplnYearLst) {
                if (pl.createdate.month() <=3)
                    returnLst.add(pl);
            }
        } 
        else  if ( selectedPipelineQ == 'Q2')  {
            for (PipelineDetailData pl : pplnYearLst) {
                if ( pl.createdate.month() >3 && pl.createdate.month() <=6 )
                    returnLst.add(pl);
            }
        }
        else  if ( selectedPipelineQ == 'Q3')  {
            for (PipelineDetailData pl : pplnYearLst) {
                if ( pl.createdate.month() >6 && pl.createdate.month() <=9 )
                    returnLst.add(pl);
            }
        } 
        else  if ( selectedPipelineQ == 'Q4')  {                
                for (PipelineDetailData pl : pplnYearLst) {
                if ( pl.createdate.month() > 9 )
                    returnLst.add(pl);
            }       
        }
        else
            returnLst = pplnYearLst;  
        
        return returnLst; 
    }
    
   /// calculate counters for the charts for the Opp and Lead Registrations
    public void populateDataList(sObject objRec, String quarterValue, String recType){
        Integer approve=0,pending=0,rejected=0;
        
        if(recType.equalsIgnoreCase('Lead')){
            Lead_Referral_Registration__c leadRec = (Lead_Referral_Registration__c)objRec;
            if(leadRec.Status__c.equalsIgnoreCase('Approved'))
                approve++;
            else if(leadRec.Status__c.equalsIgnoreCase('Request Pending'))
                pending++;
            else
                rejected++;
                
            if(!mapLeadData.containsKey(quarterValue)){
                mapLeadData.put(quarterValue,String.valueOf(approve)+';'+String.valueOf(pending)+';'+String.valueOf(rejected));
            }
            else{
                List<String> data = mapLeadData.get(quarterValue).split(';');
                mapLeadData.put(quarterValue,String.valueOf(Integer.valueOf(data[0])+approve)+';'+String.valueOf(Integer.valueOf(data[1])+pending)+';'+String.valueOf(Integer.valueOf(data[2])+rejected));
            }
        }
        else if (recType.equalsIgnoreCase('Opp')) {
            partner_portal_prospect__c oppRec = (partner_portal_prospect__c)objRec;
            
            if(oppRec.Status__c.equalsIgnoreCase('Approved'))
                approve++;
            else if(oppRec.Status__c.equalsIgnoreCase('Request Submitted') || oppRec.Status__c.equalsIgnoreCase('Request Pending') || oppRec.Status__c.equalsIgnoreCase('Awaiting Approval'))
                pending++;
            else if(oppRec.Status__c.equalsIgnoreCase('Rejected'))
                rejected++;
            if(!mapOppData.containsKey(quarterValue)){
                mapOppData.put(quarterValue,String.valueOf(approve)+';'+String.valueOf(pending)+';'+String.valueOf(rejected));
            }
            else{
                List<String> data = mapOppData.get(quarterValue).split(';');
                mapOppData.put(quarterValue,String.valueOf(Integer.valueOf(data[0])+approve)+';'+String.valueOf(Integer.valueOf(data[1])+pending)+';'+String.valueOf(Integer.valueOf(data[2])+rejected));
            }
        }

    }
        
    public List<Data> getLeadChartData() {
        List<Data> data = new List<Data>();
        mapLeadData = new map<String,String>();
        
        for(Lead_Referral_Registration__c pPortalLead : getLeadReg()){
            if(pPortalLead.CreatedDate.month()<=3){
                populateDataList(pPortalLead,'Q1','Lead');
            }
            else if(pPortalLead.CreatedDate.month()>3 && pPortalLead.CreatedDate.month()<=6){
                populateDataList(pPortalLead,'Q2','Lead');
            }
            else if(pPortalLead.CreatedDate.month()>6 && pPortalLead.CreatedDate.month()<=9){
                populateDataList(pPortalLead,'Q3','Lead');
            }
            else
                populateDataList(pPortalLead,'Q4','Lead');
        }
        
        for(String q : quarterSet){
            if(!mapLeadData.keyset().contains(q)){
                mapLeadData.put(q,'0;0;0');
            }
        }
 
        for(String key : getSortedKeyset(mapLeadData)){
            List<String> leadData = mapLeadData.get(key).split(';');
            data.add(new Data(key,Integer.valueOf(leadData[0]),Integer.valueOf(leadData[1]),Integer.valueOf(leadData[2])));
        }
        /*
        data.add(new Data('Q1', 74, 28, 85));
        data.add(new Data('Q2', 23, 15, 45));
        data.add(new Data('Q3', 25, 32, 75));
        data.add(new Data('Q4', 30, 90, 55));
        */
        return data;
    }
     
    public List<Data> getChartData() {
        List<Data> data = new List<Data>();
        mapOppData = new map<String,String>();      
        
        for(partner_portal_prospect__c pPortalOpp : getOpptyReg()){
            if(pPortalOpp.CreatedDate.month()<=3){
                populateDataList(pPortalOpp,'Q1','Opp');
            }
            else if(pPortalOpp.CreatedDate.month()>3 && pPortalOpp.CreatedDate.month()<=6){
                populateDataList(pPortalOpp,'Q2','Opp');
            }
            else if(pPortalOpp.CreatedDate.month()>6 && pPortalOpp.CreatedDate.month()<=9){
                populateDataList(pPortalOpp,'Q3','Opp');
            }
            else
                populateDataList(pPortalOpp,'Q4','Opp');
        }
                
        
        for(String q : quarterSet){
            if(!mapOppData.keyset().contains(q)){
                mapOppData.put(q,'0;0;0');
            }
        }

        for(String key : getSortedKeyset(mapOppData)){
            List<String> oppData = mapOppData.get(key).split(';');
            data.add(new Data(key, Integer.valueOf(oppData[0]),
                                   Integer.valueOf(oppData[1]),
                                   Integer.valueOf(oppData[2]) ));
        }
        /*data.add(new Data('Q1', 30, 90, 55));
        data.add(new Data('Q2', 67, 15, 34));
        data.add(new Data('Q3', 25, 32, 75));
        data.add(new Data('Q4', 74, 28, 85));
        */
        return data;
    }
    
    /// chart data for the Pipeline (Opportunity object)    
    public List<PipelineChartData> getPipeLnChartData() {
        List<PipelineChartData> data = new List<PipelineChartData>();
        mapPipeLnData = new map<String,String>();      

        for( PipelineDetailData ppLn : getPipeline() ) {
                
            if( ppLn.createdate.month() <= 3 ) {
                
                populatePipeLnDataList(ppLn,'Q1');
            }
            else if( ppLn.createdate.month() > 3 && ppLn.createdate.month() <= 6 ) {
                populatePipeLnDataList(ppLn,'Q2');
            }
            else if( ppLn.createdate.month() > 6 && ppLn.createdate.month() <= 9 ){
                populatePipeLnDataList(ppLn,'Q3');
            }
            else
                populatePipeLnDataList(ppLn,'Q4');
        }
                        
        for (String q : quarterSet) {
            if ( !mapPipeLnData.keyset().contains(q) ) {
                mapPipeLnData.put(q,'0;0;0;0;0;0;0');
            }
        }

        for ( String key : getSortedKeyset(mapPipeLnData) ) {
                
            List<String> oppData = mapPipeLnData.get(key).split(';');
            
            data.add(new PipelineChartData(key, Integer.valueOf(oppData[0]), 
                                           Integer.valueOf(oppData[1]),
                                           Integer.valueOf(oppData[2]),
                                           Integer.valueOf(oppData[3]),
                                           Integer.valueOf(oppData[4]),
                                           Integer.valueOf(oppData[5]),
                                           Integer.valueOf(oppData[6])
                                       ));
        }
        /*data.add(new Data('Q1', 30, 90, 55));
        data.add(new Data('Q2', 67, 15, 34));
        data.add(new Data('Q3', 25, 32, 75));
        data.add(new Data('Q4', 74, 28, 85));
        */
        return data;
    }
    
     public void populatePipeLnDataList(PipelineDetailData ppLnRec, String quarterValue) {

           if ( ppLnRec.forecastStatus == null )
                 return;
                 
            Integer booked=0, inhand=0, committed=0, expected=0, upside=0, pipeline=0, omitted=0;
            
            if (ppLnRec.forecastStatus.equalsIgnoreCase('0.Booked'))
                booked++;
            else if (ppLnRec.forecastStatus.equalsIgnoreCase('1.In Hand'))
                inhand++;
            else if(ppLnRec.forecastStatus.equalsIgnoreCase('2.Commit'))
                committed++;
            else if(ppLnRec.forecastStatus.equalsIgnoreCase('3.Expected'))
                expected++;   
            else if(ppLnRec.forecastStatus.equalsIgnoreCase('4.Upside'))
                upside++;
            else if(ppLnRec.forecastStatus.equalsIgnoreCase('5.Pipeline'))
                pipeline++;
            else if(ppLnRec.forecastStatus.equalsIgnoreCase('6.Omitted'))
                omitted++;    
                                             
            if( !mapPipeLnData.containsKey(quarterValue) ) {            
                mapPipeLnData.put(quarterValue,
                       String.valueOf(booked)+';'+String.valueOf(inhand)+';'+String.valueOf(committed) +';'+
                       String.valueOf(expected)+';'+String.valueOf(upside)+';'+String.valueOf(pipeline) +';'+
                       String.valueOf(omitted));
            }
            else {                      
                List<String> data = mapPipeLnData.get(quarterValue).split(';');
                mapPipeLnData.put(quarterValue,
                   String.valueOf(Integer.valueOf(data[0]) + booked)+';'+String.valueOf(Integer.valueOf(data[1]) + inhand)+';'+
                   String.valueOf(Integer.valueOf(data[2]) + committed)+';'+ String.valueOf(Integer.valueOf(data[3]) + expected)+';'+ 
                   String.valueOf(Integer.valueOf(data[4]) + upside)+';'+ String.valueOf(Integer.valueOf(data[5]) + pipeline)+';'+
                   String.valueOf(Integer.valueOf(data[6]) + omitted));
            }
     }
           
    
    // Utility method to sort a map on key values
    public  List<String> getSortedKeyset(Map<String, String> dataMap) {
        List<String> keySetList = new List<String>();
        keySetList.addAll(dataMap.keySet());
        keySetList.sort();
        return keySetList;
    }
    
    // Method to show Opportunity results on Vf Page
    public void showOppData(){
        showOppData = true;
    }
  
    // Method to show Opportunity results on Vf Page
    public pageReference hideOppData(){
        showOppData = false;
        return null;
    }
   
    // Method to show Lead results on Vf Page
    public void showLeadData(){
        showLeadData = true;
    }
    
    // Method to show Lead results on Vf Page
    public void hideLeadData(){
        showLeadData = false;
    }
    
    // Method to show Lead results on Vf Page
    public void showPipelnData() {
        showPipelineData = true;     
    }
    
    // Method to show Lead results on Vf Page
    public void hidePipeLnData(){
        showPipelineData = false;       
    }
    
    public pageReference createOpportunity(){
        String oppId = OpportunityNewFromRegistration.createNewOppForPartner(dealRegId);        
        return new PageReference('/partner/PartnerPortalOptyDetail?Id='+ oppId);
    }
    
    // Wrapper class for Lead and Opp Registrations Charts
    public class Data {
        public String name { get; set; }
        public Integer oppApproved { get; set; }
        public Integer oppPending { get; set; }
        public Integer oppRejected { get; set; }
        
        public Data(String name, Integer oppApprove, Integer oppPending, Integer oppReject) {
            this.name = name;
            this.oppApproved = oppApprove;
            this.oppPending = oppPending;
            this.oppRejected = oppReject;
        }

    }
    
    // wrapper for Pipline (Opportunity object) Chart
    public class PipelineChartData {
        public String name { get; set; }
        public Integer booked { get; set; }
        public Integer inhand { get; set; }
        public Integer committed { get; set; }
        public Integer expected { get; set; }
        public Integer upside { get; set; }
        public Integer pipeline { get; set; }
        public Integer omitted { get; set; }
        
        public PipelineChartData(String name, Integer booked, Integer inhand, Integer committed, Integer expected,
                                 Integer upside, Integer pipeline, Integer omitted) {
            this.name = name;
            this.booked = booked;
            this.inhand = inhand;
            this.committed = committed;
            this.expected = expected;
            this.upside = upside;
            this.pipeline = pipeline;
            this.omitted = omitted;
        }
    }
}