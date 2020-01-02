public with sharing class QuoteRevenueMonthForecastController {
    public String selectedQuarter {get;set;}
    public List<lineItemsWrapper> lineItems {get;set;}
    public List<forecastWrapper> forecasts {get;set;}
    public Boolean showAccountSummary {get;set;}
    public Boolean showAccountDetails {get;set;}
    public String accountDetailTitle {get;set;}
    public String selectedAccountId {get;set;}
    public String selectedAccountName {get;set;}
    public String selectedCs{get;set;}
    public List<SelectOption> weeks {get;set;}
    public List<SelectOption> cs{get;set;}
   
   
    public String selectedWeek {get;set;}
    public QuoteRevenueMonthForecastController(){
        selectedQuarter = '1-' + Date.today().year();    
        showAccountDetails = false;    
        populateLines();
        accountDetailTitle = 'Account Details';
        
        selectedWeek = '2015-01-08';
        Integer currentMnt =Date.today().month();
        Integer currentQ =((currentMnt-1)/3) + 1;    
        selectedQuarter =currentQ +'-' + Date.today().year();    
        weeks = QuoteRevenueMonthForecastContHelper.getWeeksForQuarter(selectedQuarter);
         cs = QuoteRevenueMonthForecastContHelper.getCSM();     
        Date sdate = Date.today();        
                
        List <Cloud_Forecast_Quarter__c> currentWeek = [Select id from Cloud_Forecast_Quarter__c where start_date__c <=: sdate 
        and end_date__c >=: sdate];
        
        for(Cloud_Forecast_Quarter__c eachWeek: currentWeek) 
         selectedWeek = eachWeek.id;
        
         
        
       
        showAccountDetails = false;    
      
        //selectedQuarter ='2-2015';
       
        if(ApexPages.currentPage().getParameters().get('q') != null){
          selectedQuarter = ApexPages.currentPage().getParameters().get('q');
            
               
            populateWeeks();
            
           if(selectedQuarter != null && selectedQuarter.equals('2-2016') && selectedWeek != null) 
            selectedWeek = Label.Revenue_Week_Q2;
        
           if(selectedQuarter != null && selectedQuarter.equals('3-2016') && selectedWeek != null) 
            selectedWeek = Label.Revenue_Week_Q3;
   
          if(selectedQuarter != null && selectedQuarter.equals('4-2016') && selectedWeek != null) 
            selectedWeek = Label.Revenue_Week_Q4;
     
           if(selectedQuarter != null && selectedQuarter.equals('1-2016') && selectedWeek != null) 
            selectedWeek = Label.Revenue_Week_Q1;
   
   
        
        }
       populateLines();
  
    }
    
    public void populateWeeks(){
        System.debug('NKC debug selectedQuarter [' + selectedQuarter + ']');
        weeks.clear();  
        weeks = QuoteRevenueMonthForecastContHelper.getWeeksForQuarter(selectedQuarter);        
        
    }
    
       public void getCSM(){
        System.debug('NKC debug selectedQuarter [' + selectedQuarter + ']');
        
       cs = QuoteRevenueMonthForecastContHelper.getCSM();     
        
    } 
    
    
    public void populateLines(){
       lineItems = QuoteRevenueMonthForecastContHelper.getAccountSummary(selectedQuarter, selectedWeek,selectedCs);
        if(lineItems.isEmpty())
            showAccountSummary = false;
        else
            showAccountSummary = true;
    }
    public void populateForecast(){
        accountDetailTitle = selectedAccountName;
        forecasts = QuoteRevenueMonthForecastContHelper.populateAccountPhaseLine(selectedAccountId, selectedQuarter, selectedWeek);        
        if(forecasts.isEmpty())
            showAccountDetails = false;
        else
            showAccountDetails = true;
    }
    
    public void save(){
        QuoteRevenueMonthForecastContHelper.save(lineItems, selectedWeek);
      lineItems = QuoteRevenueMonthForecastContHelper.getAccountSummary(selectedQuarter, selectedWeek,selectedCs);
    }
    
    public class lineItemsWrapper{
        public Boolean selected {get;set;}
        public String account {get;set;}
        public String accountId {get;set;}        
        public String status {get;set;}        
        public Double revenue {get;set;}
        public Double commitQuantity {get;set;}
        public Double landQuantity {get;set;}
        public Double bestQuantity {get;set;} 
        public Double previousLandQuantity {get;set;}  
        public Double previousBestQuantity {get;set;}  
        public Double previousLowQuantity {get;set;}
        public Double changeLandQuantity {get;set;}  
        public Double changeBestQuantity {get;set;}  
        public Double changeLowQuantity {get;set;}  
        
        public Double subscriptionLand {get;set;}
        public Double psLand {get;set;}
        public Double totalLand {get;set;}
        public Double psLow {get;set;}
        public Double subscriptionLow {get;set;}
        public Double totalLow {get;set;}
        public Double psBest {get;set;}
        public Double subscriptionBest {get;set;}
        public Double totalBest {get;set;}
        public Double quota {get;set;}
        public Double lastWeekLand {get;set;}
        public Double change {get;set;}
       
        public String rowStyle {get;set;}   
        public String textStyle {get;set;}      
        public Boolean isTotal {get;set;}
        public Integer counter {get;set;}
        public Account_Revenue_Forecast__c record {get;set;}
        public String csmOwner {get;set;}
        public lineItemsWrapper(){
            this.selected = false;
        }
   
    }
    public class forecastWrapper{
        transient public String phase {get;set;}
        transient public String product {get;set;}
        transient public String status {get;set;}
        transient public Double quantity {get;set;}
        transient public Double revenue {get;set;}
        transient public String notes {get;set;}
        transient public Date forecast {get;set;}
        public Cloud_Phase_Line_Items__c phaseLine {get;set;}
    }
}