public with sharing class cloudRevenueController {

    public Summary[] Summaries { get; set; }
    public Cloud_Billing_Information__c[] revList {get; set; }
    public String main {get; set;}
    public Opportunity[] pendingOpps {get; set;}
    public Integer year {get; set;}
    
    public finalRevenue [] finalRevList {get;set;}     
    Map<Id, Summary> historyMap {get;set;}
     boolean mainFlag = false; 
    public cloudRevenueController() {
        String y = ApexPages.currentPage().getParameters().get('y');
        if(y == null || y.trim() == '')
            year = 2016;
        else 
            year = Integer.valueOf(y);
        AggregateResult[] results;
        if(year == 2016){
            results = [
            SELECT Cloud_Billing_Information__c, Sum(June_2015__c) June,  Sum (Jan_2015__c) Jan, Sum (Feb_2015__c) Feb, 
            Sum (Mar_2015__c) Mar, Sum (Apr_2015__c) Apr, Sum (May_2015__c) May, Sum (Jul_2015__c) Jul, 
            Sum (Aug_2015__c) Aug, Sum (Sep_2015__c) Sep, Sum (Oct_2015__c) Oct, Sum (Nov_2015__c) Nov, Sum (Dec_2015__c) Dec, 
            SUM (Phase_Revenue_One_Time__c) PhaseRevenueOneTime
            FROM Cloud_Billing_Phase__c GROUP BY Cloud_Billing_Information__c order by  Cloud_Billing_Information__c
            ];
        }
        else if(year == 2017){
            results = [
            SELECT Cloud_Billing_Information__c, Sum(June_2017__c) June,  Sum (Jan_2017__c) Jan, Sum (Feb_2017__c) Feb, 
            Sum (Mar_2017__c) Mar, Sum (Apr_2017__c) Apr, Sum (May_2017__c) May, Sum (Jul_2017__c) Jul, 
            Sum (Aug_2017__c) Aug, Sum (Sep_2017__c) Sep, Sum (Oct_2017__c) Oct, Sum (Nov_2017__c) Nov, Sum (Dec_2017__c) Dec, 
            SUM (Phase_Revenue_One_Time__c) PhaseRevenueOneTime
            FROM Cloud_Billing_Phase__c GROUP BY Cloud_Billing_Information__c order by  Cloud_Billing_Information__c
            ];
        }
        else if(year == 2018){
            results = [
            SELECT Cloud_Billing_Information__c, Sum(June_2018__c) June,  Sum (Jan_2018__c) Jan, Sum (Feb_2018__c) Feb, 
            Sum (Mar_2018__c) Mar, Sum (Apr_2018__c) Apr, Sum (May_2018__c) May, Sum (Jul_2018__c) Jul, 
            Sum (Aug_2018__c) Aug, Sum (Sep_2018__c) Sep, Sum (Oct_2018__c) Oct, Sum (Nov_2018__c) Nov, Sum (Dec_2018__c) Dec, 
            SUM (Phase_Revenue_One_Time__c) PhaseRevenueOneTime
            FROM Cloud_Billing_Phase__c GROUP BY Cloud_Billing_Information__c order by  Cloud_Billing_Information__c
            ];
        }
        else 
        
       main = ApexPages.currentPage().getParameters().get('main'); 
       finalRevList = new List <finalRevenue>();
       pendingOpps = new List<Opportunity>();
       
        
       Summaries = new List<Summary>();
       for (AggregateResult ar : results) {
            Summaries.add(new Summary(ar));
       }     

       historyMap = new Map<Id, Summary>();
     
       for(Summary oh : Summaries) {
        historyMap.put(oh.Name, oh);
       }
                
       if(main != null && main =='y')  {
        revList  =  [Select  id,Account_Name__c,Actual_Go_Live_Date__c,SOW_Fully_Delivered_Date_Actual__c,SOW_Execution_Date__c,Discovery_Phase_Complete__c,Design_Phase_Completed__c ,
        Technical_Requirements_Completion_Date__c,Annual_Contract_Value1__c,project_health__c,Opportunity__c,opportunity__r.Name, Opportunity__r.Total_PS_Support__c,Opportunity__r.id,Name,
        main_opportunity__c,Opportunity_Close_Date__c,Opportunity_Main__c, Opportunity__r.Term_Commitment__c, Opportunity__r.Account.New_Logo_2016__c, 
        Opportunity__r.Account.Cloud_Platform_Type__c, One_Time_Revenue__c,PM_Assigned_Status__c, SOW_Status__c,Discovery_status__c,Design_status__c, technical_Status__c,
        Opportunity__r.AccountId, Opportunity__r.OpportunityNumber__c, Opportunity__r.Account.CSM_Account_Owner_Name__c, Forecasted_Go_Live_Date_At_SOW_Signatu__c from  Cloud_Billing_Information__c where (Opportunity_Main__c = true) order by account_name__c asc];
        mainFlag= true; 
       }
       
       else  
       {
       revList  =  [Select  id,Account_Name__c,Actual_Go_Live_Date__c,SOW_Fully_Delivered_Date_Actual__c,SOW_Execution_Date__c,Discovery_Phase_Complete__c,Design_Phase_Completed__c ,
       Technical_Requirements_Completion_Date__c,Annual_Contract_Value1__c,project_health__c,Opportunity__c,opportunity__r.Name, Opportunity__r.Total_PS_Support__c,Opportunity__r.id,Name,
       main_opportunity__c,Opportunity_Close_Date__c,Opportunity_Main__c, Opportunity__r.Term_Commitment__c, Opportunity__r.Account.New_Logo_2016__c, 
       One_Time_Revenue__c, Opportunity__r.Account.Cloud_Platform_Type__c,PM_Assigned_Status__c, SOW_Status__c,Discovery_status__c,Design_status__c, technical_Status__c,
       Opportunity__r.AccountId, Opportunity__r.OpportunityNumber__c, Opportunity__r.Account.CSM_Account_Owner_Name__c, Forecasted_Go_Live_Date_At_SOW_Signatu__c  from  Cloud_Billing_Information__c order by account_name__c asc];
       mainFlag = true;
       }
       
      String pendingQuery = Label.Cloud_Pending_Opps_Query;
     
     if(main != null && main =='y') 
      pendingQuery = pendingQuery + ' and Opportunity_main__c = true';
     else  
      pendingOpps = (List<Opportunity>)Database.query(pendingQuery);
        
       

       
       String oldAccName = '';
       String newAccName = '';         
       Decimal tempRevJune = 1;
       
       Decimal tempRevJan = 1;
       Decimal tempRevFeb = 1;
       Decimal tempRevMar = 1;
       Decimal tempRevApr = 1;
       Decimal tempRevMay = 1;
       Decimal tempRevJul = 1;
       Decimal tempRevAug = 1;
       Decimal tempRevSep = 1;
       Decimal tempRevOct = 1;
       Decimal tempRevNov = 1;
       Decimal tempRevDec = 1;
       
       
       boolean flag = false;
        finalRevenue temp ;
       
       for (Cloud_Billing_Information__c record1 : revList) { 
          
          
                 
           if(historyMap.get(record1.id) != null)  {
              
             //tempRev = historyMap.get(record1.id).June_2015;
             
             newAccName = record1.Account_Name__c;
                         
            // if(oldAccName != newAccName && newAccName != null && mainFlag) {
              
             if(mainFlag) {
              temp = new  finalRevenue(); 
              temp.rec = record1;
             
            // Jan
              temp.Jan = historyMap.get(record1.id).Jan;
              tempRevJan = temp.Jan;
          
           // Feb  
              temp.Feb = historyMap.get(record1.id).Feb;
              tempRevFeb = temp.Feb;
  
            // Mar  
              temp.Mar = historyMap.get(record1.id).Mar;
              tempRevMar = temp.Mar;
 
             // Apr  
              temp.Apr = historyMap.get(record1.id).Apr;
              tempRevApr = temp.Apr;
 
             //  May
              temp.May = historyMap.get(record1.id).May;
              tempRevMay = temp.May;
 
              //  Jul
              temp.Jul = historyMap.get(record1.id).Jul;
              tempRevJul = temp.Jul;
 
              //  Aug
              temp.Aug = historyMap.get(record1.id).Aug;
              tempRevAug = temp.Aug;
 
              //  Sep
              temp.Sep = historyMap.get(record1.id).Sep;
              tempRevSep = temp.Sep;
  
               //  Oct
              temp.Oct = historyMap.get(record1.id).Oct;
              tempRevOct = temp.Oct;
   
              //  Nov
              temp.Nov = historyMap.get(record1.id).Nov;
              tempRevNov = temp.Nov;
  
              //  Dec
              temp.Dec = historyMap.get(record1.id).Dec;
              tempRevDec = temp.Dec;
             
             // June 
              
              temp.June = historyMap.get(record1.id).June;
              tempRevJune = temp.June;
              flag = true;
             }
             else {
              temp.June = tempRevJune + historyMap.get(record1.id).June;
              tempRevJune = temp.June;
             
              temp.Jan = tempRevJan + historyMap.get(record1.id).Jan;
              tempRevJan = temp.Jan;
     
              temp.Feb = tempRevFeb + historyMap.get(record1.id).Feb;
              tempRevFeb = temp.Feb;
         
              temp.Mar = tempRevMar + historyMap.get(record1.id).Mar;
              tempRevMar = temp.Mar;
 
              temp.Apr = tempRevApr + historyMap.get(record1.id).Apr;
              tempRevApr = temp.Apr;
            
              temp.May = tempRevMay + historyMap.get(record1.id).May;
              tempRevMay = temp.May;
            
              temp.Jul = tempRevJul + historyMap.get(record1.id).Jul;
              tempRevJul = temp.Jul;
  
            
              temp.Aug = tempRevAug + historyMap.get(record1.id).Aug;
              tempRevAug = temp.Aug;
 
              temp.Sep = tempRevSep + historyMap.get(record1.id).Sep;
              tempRevSep = temp.Sep;

              temp.Oct = tempRevOct + historyMap.get(record1.id).Oct;
              tempRevOct = temp.Oct;
     
              temp.Nov = tempRevNov + historyMap.get(record1.id).Nov;
              tempRevNov = temp.Nov;
   
              temp.Dec = tempRevDec + historyMap.get(record1.id).Dec;
              tempRevDec= temp.Dec;
      
             
             
             
             
             
             
              flag = false;
             }
             
             
             
             
              if(record1.One_Time_Revenue__c != null)
                temp.total = temp.June +  temp.Jan +  temp.Feb +  temp.Mar +  temp.Apr +  temp.May +  temp.Jul +  temp.Aug + temp.Sep + temp.Oct + temp.Nov + temp.Dec + record1.One_Time_Revenue__c;                     
             else 
                temp.total = temp.June +  temp.Jan +  temp.Feb +  temp.Mar +  temp.Apr +  temp.May +  temp.Jul +  temp.Aug + temp.Sep + temp.Oct + temp.Nov + temp.Dec;                     
             
             
             oldAccName = newAccName;
            
             if(flag)
              finalRevList.add(temp);
             
          }   
       
       
       }       
     }

  // wrapper class to hold aggregate data
   
  public class finalRevenue {
    public Cloud_Billing_Information__c rec {get; set;}
    public Decimal Jan {get; set;}
    public Decimal Feb {get; set;}
    public Decimal Mar {get; set;}
    public Decimal Apr {get; set;}
    public Decimal May {get; set;}
    public Decimal Jul {get; set;}
    public Decimal Aug {get; set;}
    public Decimal Sep {get; set;}
    public Decimal Oct {get; set;}
    public Decimal Nov {get; set;}
    public Decimal Dec {get; set;}
    public Decimal oneTimeRevenue {get; set;}
    
    
    public Decimal June {get; set;}
    
    
    
    public Decimal total {get;set;}
    
  
  }
    
  public class Summary {
    public Decimal June { get; set; }
    public String Name { get; private set; }
    
    public Decimal Jan {get; set;}
    public Decimal Feb {get; set;}
    public Decimal Mar {get; set;}
    public Decimal Apr {get; set;}
    public Decimal May {get; set;}
    public Decimal Jul {get; set;}
    public Decimal Aug {get; set;}
    public Decimal Sep {get; set;}
    public Decimal Oct {get; set;}
    public Decimal Nov {get; set;}
    public Decimal Dec {get; set;}
    
    

    public Summary(AggregateResult ar) {
      June =0;
      June = (Decimal) ar.get('June');
      Jan = (Decimal) ar.get('Jan');
      Feb = (Decimal) ar.get('Feb');
      Mar = (Decimal) ar.get('Mar');
      Apr = (Decimal) ar.get('Apr');
      May = (Decimal) ar.get('May');
      Jul = (Decimal) ar.get('Jul');
      Aug = (Decimal) ar.get('Aug');
      Sep = (Decimal) ar.get('Sep');
      Oct = (Decimal) ar.get('Oct');
      Nov = (Decimal) ar.get('Nov');
      Dec = (Decimal) ar.get('Dec');
      
      
      
      
      
      
      
      
      Name = (String) ar.get('Cloud_Billing_Information__c');
    }
  }

}