//Ravi V - Sales Compliance -  10/16/2013
public class complianceWrapper 
 {
  //Defining
   public String Questionnumber{set;get;}
   public String Questionname{set;get;}
   public String ComplianceQuestion{set;get;}
   public String QuestionID{set;get;}
   public String checkbox{set;get;}
   public String multiselect{set;get;}
   public String Textarea{set;get;}
   public ID responseid{set;get;}
   public List<SelectOption> getOptionsall()
    {
     List<SelectOption> options1 = new List<SelectOption>(); 
     options1.add(new SelectOption('Yes','Yes')); 
     options1.add(new SelectOption('No','No')); 
     return options1; 
    }
       
   public complianceWrapper(compliance_question__c CQ)  //save
    {
     QuestionID=CQ.id;
     Questionname=CQ.name;
     ComplianceQuestion=CQ.Compliance_Question__c;
     Questionnumber=String.valueof(CQ.Question_number__c);      
    }
  public complianceWrapper(compliance_response__c CR)//edit
  {
    QuestionID=CR.Compliance_Question__c;
    ComplianceQuestion=CR.Compliance_Question__r.Compliance_Question__c;
    Questionnumber=String.valueof(CR.Question_number__c); 
    Questionname=CR.question_name__c;
    checkbox=CR.checkbox__c;
    Textarea=CR.Textarea__c;
    multiselect=CR.multiselect__c;
    responseid=CR.id;
   } 
   
 }