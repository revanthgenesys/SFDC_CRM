//Naresh Kumar  01/12/2016
public without sharing class CloudBillingPhasesAgentReport {
  public List<wrapperLines> records {get;set;}
  public CloudBillingPhasesAgentReport(){
    List<Cloud_Phase_Line_Items__c> cloudPhaseLines;
    AggregateResult[] groupedResults = [SELECT Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__r.Account.Name accName, Product__r.Name pName, Sum(Quantity__c) quantity, SUM(Jan_2016__c) jan2016,
      SUM(Feb_2016__c) feb2016, SUM(March_2016__c) mar2016, SUM(April_2016__c) apr2016, SUM(May_2016__c) may2016, SUM(June_2016__c) june2016, 
      SUM(July_2016__c) july2016, SUM(Aug_2016__c) aug2016, SUM(Sep_2016__c) sep2016, SUM(Oct_2016__c) oct2016, 
      SUM(Nov_2016__c) nov2016, SUM(Dec_2016__c) dec2016 FROM Cloud_Phase_Line_Items__c 
      GROUP BY Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__r.Account.Name, Product__r.Name ORDER BY Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__r.Account.Name];
    records = new List<wrapperLines>();
    for(AggregateResult ar : groupedResults){
      wrapperLines newRecord = new wrapperLines();
      newRecord.accountName = (String)ar.get('accName');
      newRecord.productName = (String)ar.get('pName');
      newRecord.quantity = (Decimal)ar.get('quantity');
      newRecord.jan2016 = (Decimal)ar.get('jan2016');
      newRecord.feb2016 = (Decimal)ar.get('feb2016');
      newRecord.mar2016 = (Decimal)ar.get('mar2016');
      newRecord.apr2016 = (Decimal)ar.get('apr2016');
      newRecord.may2016 = (Decimal)ar.get('may2016');
      newRecord.june2016 = (Decimal)ar.get('june2016');
      newRecord.july2016 = (Decimal)ar.get('july2016');
      newRecord.aug2016 = (Decimal)ar.get('aug2016');
      newRecord.sep2016 = (Decimal)ar.get('sep2016');
      newRecord.oct2016 = (Decimal)ar.get('oct2016');
      newRecord.nov2016 = (Decimal)ar.get('nov2016');
      newRecord.dec2016 = (Decimal)ar.get('dec2016');      
      records.add(newRecord);  
    }
    //SELECT Account__r.Name, Product__r.Name a, SUM(Jan_2016__c) FROM Cloud_Phase_Line_Items__c GROUP BY Account__r.Name, Product__r.Name
  }
  
  public class wrapperLines{
    public transient String accountName {get;set;}
    public transient String productName {get;set;}
    public transient Decimal quantity {get;set;}
    public transient Decimal jan2016 {get;set;}
    public transient Decimal feb2016 {get;set;}
    public transient Decimal mar2016 {get;set;}
    public transient Decimal apr2016 {get;set;}
    public transient Decimal may2016 {get;set;}
    public transient Decimal june2016 {get;set;}
    public transient Decimal july2016 {get;set;}
    public transient Decimal aug2016 {get;set;}
    public transient Decimal sep2016 {get;set;}
    public transient Decimal oct2016 {get;set;}
    public transient Decimal nov2016 {get;set;}
    public transient Decimal dec2016 {get;set;}    
    public transient String headerString {get;set;}
    public transient Boolean isHeader {get;set;}    
  }
}