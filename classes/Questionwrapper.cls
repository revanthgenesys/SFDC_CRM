public class Questionwrapper
  {//Declaring 
         public ID OpportunityID{get;set;}
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
        
   public Questionwrapper(Sales_Aid_Question__c SAQ)  
       {
        QuestionID=SAQ.id;
        Question=SAQ.Questions__c;
        category=SAQ.category__c;
        SequenceNumber=SAQ.Sequence_Number__c;
        stage=String.valueOf(SAQ.stage__c);
        }
  }