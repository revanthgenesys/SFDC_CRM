public with sharing class cloudRevenueControllerAgent {

    public Summary[] Summaries { get; set; }
    public Cloud_Billing_Information__c[] revList {get; set; }
    public String main {get; set;}
    
    public finalRevenue [] finalRevList {get;set;}     
    Map<Id, Summary> historyMap {get;set;}
     boolean mainFlag = false; 
    public cloudRevenueControllerAgent() {
        AggregateResult[] results = [
            SELECT Cloud_Billing_Information__c, Sum(Jun_2015_Count__c) June_2015 ,  Sum (Jan_2015_Count__c) Jan_2015 , Sum (Feb_2015_Count__c) Feb_2015 , 
            Sum (Mar_2015_Count__c) Mar_2015 , Sum (Apr_2015_Count__c) Apr_2015 , Sum (May_2015_Count__c) May_2015 , Sum (Jul_2015_Count__c) Jul_2015 , 
            Sum (Aug_2015_Count__c) Aug_2015 , Sum (Sep_2015_Count__c) Sep_2015 , Sum (Oct_2015_Count__c) Oct_2015 , Sum (Nov_2015_Count__c) Nov_2015 , Sum (Dec_2015_Count__c) Dec_2015 
            
            FROM Cloud_Billing_Phase__c GROUP BY Cloud_Billing_Information__c order by  Cloud_Billing_Information__c
        ];
        
       main = ApexPages.currentPage().getParameters().get('main'); 
       finalRevList = new List <finalRevenue>();
        
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
        Technical_Requirements_Completion_Date__c,Annual_Contract_Value1__c,project_health__c,Opportunity__c,opportunity__r.Name,Opportunity__r.id,Name,main_opportunity__c,Opportunity_Close_Date__c,Opportunity_Main__c from  Cloud_Billing_Information__c where (Opportunity_Main__c = true) order by account_name__c asc];
        mainFlag= true; 
       }
       
       else  
       {
       revList  =  [Select  id,Account_Name__c,Actual_Go_Live_Date__c,SOW_Fully_Delivered_Date_Actual__c,SOW_Execution_Date__c,Discovery_Phase_Complete__c,Design_Phase_Completed__c ,
       Technical_Requirements_Completion_Date__c,Annual_Contract_Value1__c,project_health__c,Opportunity__c,opportunity__r.Name,Opportunity__r.id,Name,main_opportunity__c,Opportunity_Close_Date__c,Opportunity_Main__c from  Cloud_Billing_Information__c order by account_name__c asc];
       mainFlag = true;
       }
       
      
       

       
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
              temp.Jan_2015 = historyMap.get(record1.id).Jan_2015;
              tempRevJan = temp.Jan_2015;
          
           // Feb  
              temp.Feb_2015 = historyMap.get(record1.id).Feb_2015;
              tempRevFeb = temp.Feb_2015;
  
            // Mar  
              temp.Mar_2015 = historyMap.get(record1.id).Mar_2015;
              tempRevMar = temp.Mar_2015;
 
             // Apr  
              temp.Apr_2015 = historyMap.get(record1.id).Apr_2015;
              tempRevApr = temp.Apr_2015;
 
             //  May
              temp.May_2015 = historyMap.get(record1.id).May_2015;
              tempRevMay = temp.May_2015;
 
              //  Jul
              temp.Jul_2015 = historyMap.get(record1.id).Jul_2015;
              tempRevJul = temp.Jul_2015;
 
              //  Aug
              temp.Aug_2015 = historyMap.get(record1.id).Aug_2015;
              tempRevAug = temp.Aug_2015;
 
              //  Sep
              temp.Sep_2015 = historyMap.get(record1.id).Sep_2015;
              tempRevSep = temp.Sep_2015;
  
               //  Oct
              temp.Oct_2015 = historyMap.get(record1.id).Oct_2015;
              tempRevOct = temp.Oct_2015;
   
              //  Nov
              temp.Nov_2015 = historyMap.get(record1.id).Nov_2015;
              tempRevNov = temp.Nov_2015;
  
              //  Dec
              temp.Dec_2015 = historyMap.get(record1.id).Dec_2015;
              tempRevDec = temp.Dec_2015;
             
             // June 
              
              temp.June_2015 = historyMap.get(record1.id).June_2015;
              tempRevJune = temp.June_2015;
              flag = true;
             }
             else {
              temp.June_2015 = tempRevJune + historyMap.get(record1.id).June_2015;
              tempRevJune = temp.June_2015;
             
              temp.Jan_2015 = tempRevJan + historyMap.get(record1.id).Jan_2015;
              tempRevJan = temp.Jan_2015;
     
              temp.Feb_2015 = tempRevFeb + historyMap.get(record1.id).Feb_2015;
              tempRevFeb = temp.Feb_2015;
         
              temp.Mar_2015 = tempRevMar + historyMap.get(record1.id).Mar_2015;
              tempRevMar = temp.Mar_2015;
 
              temp.Apr_2015 = tempRevApr + historyMap.get(record1.id).Apr_2015;
              tempRevApr = temp.Apr_2015;
            
              temp.May_2015 = tempRevMay + historyMap.get(record1.id).May_2015;
              tempRevMay = temp.May_2015;
            
              temp.Jul_2015 = tempRevJul + historyMap.get(record1.id).Jul_2015;
              tempRevJul = temp.Jul_2015;
  
            
              temp.Aug_2015 = tempRevAug + historyMap.get(record1.id).Aug_2015;
              tempRevAug = temp.Aug_2015;
 
              temp.Sep_2015 = tempRevSep + historyMap.get(record1.id).Sep_2015;
              tempRevSep = temp.Sep_2015;

              temp.Oct_2015 = tempRevOct + historyMap.get(record1.id).Oct_2015;
              tempRevOct = temp.Oct_2015;
     
              temp.Nov_2015 = tempRevNov + historyMap.get(record1.id).Nov_2015;
              tempRevNov = temp.Nov_2015;
   
              temp.Dec_2015 = tempRevDec + historyMap.get(record1.id).Dec_2015;
              tempRevDec= temp.Dec_2015;
      
             
             
             
             
             
             
              flag = false;
             }
             
             
             
             
             
             
             temp.total = temp.June_2015 +  temp.Jan_2015 +  temp.Feb_2015 +  temp.Mar_2015 +  temp.Apr_2015 +  temp.May_2015 +  temp.Jul_2015 +  temp.Aug_2015 + temp.Sep_2015 + temp.Oct_2015 + temp.Nov_2015 + temp.Dec_2015;
                   
             
             
             oldAccName = newAccName;
            
             if(flag)
              finalRevList.add(temp);
             
          }   
       
       
       }       
     }

  // wrapper class to hold aggregate data
   
  public class finalRevenue {
    public Cloud_Billing_Information__c rec {get; set;}
    public Decimal Jan_2015 {get; set;}
    public Decimal Feb_2015 {get; set;}
    public Decimal Mar_2015 {get; set;}
    public Decimal Apr_2015 {get; set;}
    public Decimal May_2015 {get; set;}
    public Decimal Jul_2015 {get; set;}
    public Decimal Aug_2015 {get; set;}
    public Decimal Sep_2015 {get; set;}
    public Decimal Oct_2015 {get; set;}
    public Decimal Nov_2015 {get; set;}
    public Decimal Dec_2015 {get; set;}
    
    
    
    public Decimal June_2015 {get; set;}
    
    
    
    public Decimal total {get;set;}
    
  
  }
    
  public class Summary {
    public Decimal June_2015 { get; set; }
    public String Name { get; private set; }
    
    public Decimal Jan_2015 {get; set;}
    public Decimal Feb_2015 {get; set;}
    public Decimal Mar_2015 {get; set;}
    public Decimal Apr_2015 {get; set;}
    public Decimal May_2015 {get; set;}
    public Decimal Jul_2015 {get; set;}
    public Decimal Aug_2015 {get; set;}
    public Decimal Sep_2015 {get; set;}
    public Decimal Oct_2015 {get; set;}
    public Decimal Nov_2015 {get; set;}
    public Decimal Dec_2015 {get; set;}
    
    

    public Summary(AggregateResult ar) {
      June_2015 =0;
      June_2015 = (Decimal) ar.get('June_2015');
      Jan_2015 = (Decimal) ar.get('Jan_2015');
      Feb_2015 = (Decimal) ar.get('Feb_2015');
      Mar_2015 = (Decimal) ar.get('Mar_2015');
      Apr_2015 = (Decimal) ar.get('Apr_2015');
      May_2015 = (Decimal) ar.get('May_2015');
      Jul_2015 = (Decimal) ar.get('Jul_2015');
      Aug_2015 = (Decimal) ar.get('Aug_2015');
      Sep_2015 = (Decimal) ar.get('Sep_2015');
      Oct_2015 = (Decimal) ar.get('Oct_2015');
      Nov_2015 = (Decimal) ar.get('Nov_2015');
      Dec_2015 = (Decimal) ar.get('Dec_2015');
      
      
      
      
      
      
      
      
      Name = (String) ar.get('Cloud_Billing_Information__c');
    }
  }

}