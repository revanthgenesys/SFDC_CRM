public class Responsewrapper
  {      //Response field mappings declaration
         public String ResponseID{get;set;} 
         public String Question{get;set;}  
         public String category{get;set;}
         public Decimal SequenceNumber{get;set;}
         public String Comments{get;set;}
         public boolean Competitor{get;set;}
         public boolean genesys{get;set;}
         public boolean neither{get;set;}
         public boolean Partner{get;set;}
         public String optionstest{get;set;}
         public ID QuestionID{get;set;}
         public String stage{get;set;}
         
public List<SelectOption> getOptionsall()
          {
           List<SelectOption> options1 = new List<SelectOption>(); 
           options1.add(new SelectOption('Yes','Yes')); 
           options1.add(new SelectOption('No','No')); 
           return options1; 
          }
public Responsewrapper(sales_aid_response__c SAQR)  
         {  
           ResponseID = SAQR.id; 
           Question=SAQR.Sales_Aid_Question_txt__c;
           Category=SAQR.category__c;
           SequenceNumber=SAQR.Question_number__c;
           Competitor=SAQR.Competitor__c;
           genesys=SAQR.Genesys__c;
           neither=SAQR.Neither__c;
           Partner=SAQR.Partner__c;
           optionstest=SAQR.Response__c;
           Comments=SAQR.comments__c;
           stage=SAQR.stage__c;
          }
  }