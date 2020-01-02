public class FCST_Home_AC 
{

 Public My_Forecast__c myForecast; 
 Public My_Forecast__c myForecast1;
 Public String DCurrQuarter;
 AggregateResult[] groupedResults;
 Integer CommitAmount;
 Integer UpsideAmount;
 Integer InHandAmount;
 Integer BookedAmount;
 String StrQuarter;
 String QuarterText;

/*----------------------------- Get the current Quarter number from the Period Object-------------------------------------*/      
 Period PQuarter = [Select p.Number, p.StartDate From Period p Where p.type = 'Quarter' and p.StartDate = THIS_FISCAL_QUARTER];
 Integer Quarter;
 String CurrQuarter = 'Q'+ String.Valueof(PQuarter.Number);
 Integer CurrentYear = PQuarter.StartDate.Year();
     
/*--- To display 'Current Quarter' Label on the VFP when it displays details for Current Quarter otherwise display 'Quarter'---*/      
 public string getQuarterText() 
 { 
   If (myForecast1.Quarter__c == 'Q'+ String.Valueof(PQuarter.Number))
       QuarterText = 'Current Quarter';
   Else 
       QuarterText =  'Quarter';
   return QuarterText;
 }

/*--------------------------------------------------------------------------------------------------------------------
  When "FCST_Home_VFP" VFP is loaded on Home Page, the MY_FORECAST__c object will be updated/inserted with the data 
  taken from the Opportunity for all the opportunities which are owned by the current login user and with the 
  ForecastStatus '2.Commit' and '3.Upside' and for all current and following quarters of the current year. 
 --------------------------------------------------------------------------------------------------------------------*/
     
 public  PageReference dmlOperation() 
 {
   Quarter = PQuarter.Number; 
   For (; Quarter<5; Quarter++)
   {
   groupedResults  =  [Select ForecastStatus__c, Sum(Amount) from Opportunity where CloseDate = THIS_YEAR and  
                       FiscalQuarter = :Quarter and ForecastStatus__c in('3.Upside','2.Commit','0.Booked','1.In Hand') and 
                       OwnerId = :UserInfo.getUserId() group by   ForecastStatus__c];

   StrQuarter = 'Q' + String.Valueof(Quarter);
   CommitAmount = 0;
   UpsideAmount = 0;                 
   BookedAmount = 0;
   InHandAmount = 0;                
   for (AggregateResult ar :groupedResults)  
    {
     If (ar.get('ForecastStatus__c') == '2.Commit')
      {
        CommitAmount = Integer.Valueof(ar.get('expr0'));
      }
          Else If (ar.get('ForecastStatus__c') == '3.Upside')
      {
        UpsideAmount = Integer.Valueof(ar.get('expr0'));
      }    
          Else If (ar.get('ForecastStatus__c') == '0.Booked')
      {
        BookedAmount = Integer.Valueof(ar.get('expr0'));
      }    
          Else If (ar.get('ForecastStatus__c') == '1.In Hand')
      {
        InHandAmount = Integer.Valueof(ar.get('expr0'));
      }    
    
    }
    Integer RecCount = [Select Count() from My_Forecast__c  where Current_Year__c= :CurrentYear and  
                        OwnerId = :UserInfo.getUserId() and Quarter__c= :StrQuarter];

    If (RecCount > 0)
     {
        myForecast = [Select Id, Total_Upside__c, Total_Commit__c, Total_Booked__c, Total_In_Hand__c from My_Forecast__c  where Current_Year__c=:CurrentYear 
                      and OwnerId = :UserInfo.getUserId()  and Quarter__c= :StrQuarter];
        myForecast.Total_Upside__c = UpsideAmount;
        myForecast.Total_Commit__c = CommitAmount;                
        myForecast.Total_Booked__c = BookedAmount;
        myForecast.Total_In_Hand__c = InHandAmount;          
        Update myForecast;
     }
    Else
     {
        myForecast = new My_Forecast__c (Quarter__c = StrQuarter,Current_Year__c = CurrentYear,
                     UserID__c = UserInfo.getUserId(), Total_Commit__c=CommitAmount, Total_Upside__c=UpsideAmount,
                     Total_Booked__c=BookedAmount, Total_In_Hand__c=InHandAmount, My_Land_Forecast__c=0);
         Insert myForecast;
     }
  
  }
  return null;
 }

/*--------------------------------------------------------------------------------------------------------------------
  MyForecast1 - instance variable will have data taken from the MY_FORECAST__c object for the 
  current year and the selected Quarter and return it to the VFP.
 --------------------------------------------------------------------------------------------------------------------*/

 public My_Forecast__c  getMyForecast1() 
  {
    myForecast1 = [Select Id, Total_Upside__c, Total_Commit__c, Total_Booked__c, Total_In_Hand__c, Current_Year__c,  
                   My_Land_Forecast__c, Quarter__c from My_Forecast__c  where Current_Year__c=:CurrentYear and 
                   OwnerId = :UserInfo.getUserId() and Quarter__c= :CurrQuarter];

    return MyForecast1;
  }  
    
 public My_Forecast__c  setMyForecast1() 
  {
    return myForecast1;    
  }  
   
 /*--------------------------------------------------------------------------------------------------------------------
  For the selected quarter on VFP, record is selected from MY_FORECAST__c object for the current year.
 --------------------------------------------------------------------------------------------------------------------*/  
 public PageReference Fetchdata()
  {
    string OptQuarter = myforecast1.Quarter__c;
    CurrQuarter = OptQuarter;
    myForecast1 = [Select Id, Total_Upside__c, Total_Commit__c,  Total_Booked__c, Total_In_Hand__c, Current_Year__c,  
                   My_Land_Forecast__c,Quarter__c from My_Forecast__c  where Current_Year__c=:CurrentYear and  
                   OwnerId = :UserInfo.getUserId() and Quarter__c= :OptQuarter];
     return Null;
  }

 /*--------------------------------------------------------------------------------------------------------------------
  When the refresh button is clicked, MY_FORECAST__c object will be updated from the data taken from Opportunity object.
 --------------------------------------------------------------------------------------------------------------------*/  
 public PageReference Refresh()
  {
   Quarter = PQuarter.Number; 
   For (; Quarter<5; Quarter++)
   {
   groupedResults  =  [Select ForecastStatus__c, Sum(Amount) from Opportunity where CloseDate = THIS_YEAR and  
                       FiscalQuarter = :Quarter and ForecastStatus__c in('3.Upside','2.Commit','1.In Hand','0.Booked') and 
                       OwnerId = :UserInfo.getUserId() group by   ForecastStatus__c];

   StrQuarter = 'Q' + String.Valueof(Quarter);
   CommitAmount = 0;
   UpsideAmount = 0;
   BookedAmount = 0;
   InHandAmount = 0; 
   for (AggregateResult ar :groupedResults)  
    {
     If (ar.get('ForecastStatus__c') == '2.Commit')
      {
        CommitAmount = Integer.Valueof(ar.get('expr0'));
      }
          Else If (ar.get('ForecastStatus__c') == '3.Upside')
      {
        UpsideAmount = Integer.Valueof(ar.get('expr0'));
      }    
          Else If (ar.get('ForecastStatus__c') == '0.Booked')
      {
        BookedAmount = Integer.Valueof(ar.get('expr0'));
      }    
          Else If (ar.get('ForecastStatus__c') == '1.In Hand')
      {
        InHandAmount = Integer.Valueof(ar.get('expr0'));
      }    
    
    }
    Integer RecCount = [Select Count() from My_Forecast__c  where Current_Year__c= :CurrentYear and  
                        OwnerId = :UserInfo.getUserId() and Quarter__c= :StrQuarter];

    If (RecCount > 0)
     {
        myForecast = [Select Id, Total_Upside__c, Total_Commit__c, Total_Booked__c, Total_In_Hand__c from My_Forecast__c  where Current_Year__c=:CurrentYear 
                      and OwnerId = :UserInfo.getUserId()  and Quarter__c= :StrQuarter];
        myForecast.Total_Upside__c = UpsideAmount;
        myForecast.Total_Commit__c = CommitAmount;                
        myForecast.Total_Booked__c = BookedAmount;
        myForecast.Total_In_Hand__c = InHandAmount;          
        Update myForecast;
     }
    Else
     {
        myForecast = new My_Forecast__c (Quarter__c = StrQuarter,Current_Year__c = CurrentYear,
                     UserID__c = UserInfo.getUserId(), Total_Commit__c=CommitAmount, Total_Upside__c=UpsideAmount,
                     Total_Booked__c=BookedAmount, Total_In_Hand__c=InHandAmount, My_Land_Forecast__c=0);
         Insert myForecast;
     }
  
  }
  return null;                           
 }
 
 /*--------------------------------------------------------------------------------------------------------------------
  When the save button is clicked, MY_FORECAST__c object will be updated with modified data done on VFP using InlineEdit.
 --------------------------------------------------------------------------------------------------------------------*/ 
 public PageReference save()
 {
  try
  {
      
    update myForecast1;
  }
    catch(System.DMLException e)
    {
      return null;
    }
  return null;
 }
      
}