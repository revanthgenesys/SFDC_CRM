public class PartnerKPI1ComponentController {

    public List<SelectOption> kpi1Periods {get; set;}
    public String selectedKPI1Period {get; set;}
    public List<PartnerKPI1> kpi1List {get; set;}
    public String accountId {get; set;}
    public String platformTemp {get; set;}
    /*public String platform {
        get; 
        set{
            platform = value;
            if(platformTemp <> value){
                init(); 
            }
            
            platformTemp = value;
        }
    }*/
    
    
    public PartnerKPI1ComponentController(){
        User user = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(user.Contact.AccountId != NULL){
           accountId = user.Contact.AccountId;   
        }
        init();
        // Hard coding for testing 
        // accountId = '001U000000YdHMS';
     }
   
    public void init(){
         loadKpi1Periods();
         if(kpi1Periods.size() > 0)
          selectedKPI1Period = kpi1Periods.get(0).getValue();
        else 
          selectedKPI1Period = '';  
        loadKpi1List();
    }
    
    public void loadKpi1Periods(){
        Set<String> existingPeriods = new Set<String>();
        //for(Partner_Quarterly_KPI__c pKPI : [SELECT Id, Period__c FROM Partner_Quarterly_KPI__c WHERE Account__c = :accountId AND Platform__c = :platform]){
        for(Partner_Quarterly_KPI__c pKPI : [SELECT Id, Period__c FROM Partner_Quarterly_KPI__c WHERE Account__c = :accountId]){
      existingPeriods.add(pKPI.Period__c);              
        }
        
        kpi1Periods = new List<SelectOption>();
        for(Partner_KPI_Periods__c kpiPeriodCS :  [SELECT Id, Name, Period__c, Start_Date__c, End_Date__c, Year__c, Quarter__c,
                                                         Active__c, Current_Quarter__c, Date_Opened__c, Order__c  
                                                         FROM Partner_KPI_Periods__c 
                                                         WHERE Active__c = true 
                                                         ORDER BY Year__c DESC, Quarter__c DESC]) {
          if(existingPeriods.contains(kpiPeriodCS.Period__c))
        kpi1Periods.add(new SelectOption(kpiPeriodCS.Period__c, kpiPeriodCS.Period__c));       
        }
    }
    
    public void loadKpi1List(){
         kpi1List = new  List<PartnerKPI1>();

        List<Partner_Quarterly_KPI__c> kpi1Header = [SELECT Id, Period__c, Closure_Assessment__c, Closure_Assessment_YTD__c, 
                                                            Training_Assessment__c, Training_Assessment_YTD__c,
                                                            Quality_Assessment__c, Quality_Assessment_YTD__c,
                                                            Cases_Closed_by_Default__c, Cases_Closed_by_Default_YTD__c,
                                                            Total_KPI_Score__c, Total_YTD_KPI_Score__c 
                                                            FROM Partner_Quarterly_KPI__c
                                                            WHERE Account__c = :accountId 
                                                            AND Period__c = :selectedKPI1Period];
                                                        //AND Platform__c = :platform];
        
        if(!kpi1Header.isEmpty()){
           kpi1List.add(new PartnerKPI1('Total YTD Score','100%',50,kpi1Header[0].Total_YTD_KPI_Score__c,kpi1Header[0].Id));
            kpi1List.add(new PartnerKPI1('Quality Assessment','30%', kpi1Header[0].Quality_Assessment__c, kpi1Header[0].Quality_Assessment_YTD__c, kpi1Header[0].Id));
            kpi1List.add(new PartnerKPI1('Closure Assessment','30%', kpi1Header[0].Closure_Assessment__c, kpi1Header[0].Closure_Assessment_YTD__c, kpi1Header[0].Id));
            kpi1List.add(new PartnerKPI1('Genesys University Certified Designated Contacts','20%',kpi1Header[0].Training_Assessment__c,kpi1Header[0].Training_Assessment_YTD__c,kpi1Header[0].id));
            kpi1List.add(new PartnerKPI1('Cases Closed by Default','20%',kpi1Header[0].Cases_Closed_by_Default__c,kpi1Header[0].Cases_Closed_by_Default_YTD__c,kpi1Header[0].Id));
            kpi1List.add(new PartnerKPI1('KPI Score (%)','100%',kpi1Header[0].Total_KPI_Score__c,kpi1Header[0].Total_YTD_KPI_Score__c,kpi1Header[0].Id));   
        }
    }
    
    public class PartnerKPI1 {  
        public String type {get; set;}   
        public String weight{ get; set; }
        public Decimal kpi { 
            get{
              return kpi != NULL ? kpi : 0;
          } set; }
        public Decimal ytd { get{
              return ytd != NULL ? ytd : 0;
          } set; } 
        public Id kpi1Id { get; set; } 
        
        public PartnerKPI1(String type, String weight, Decimal kpi, Decimal ytd, Id kpi1Id){ 
            this.type = type; 
            this.weight = weight;
            this.kpi = kpi;
            this.ytd = ytd;
            this.kpi1Id = kpi1Id;
        }  
    }
}