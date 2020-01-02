global class ChecklistIterator implements Iterator<Export_Screening_Checklist__c>
{
   List<Export_Screening_Checklist__c> memList{get; set;}
   Integer i {get; set;}

   public ChecklistIterator()
   {
       memList = [SELECT id,name,Account__c,Checklist_expiration_date__c,owner.email,Account__r.name,Account__r.owner.email FROM Export_Screening_Checklist__c where Checklist_expiration_date__c!=null];
       i = 0;
   }

   global boolean hasNext()
   {
       if(i >= memList.size())
       {
           return false;
       
       } else 
       {
           return true;
       }
   }

   global Export_Screening_Checklist__c next()
   {
       if(i > memList.size())
       {
           return null;
       }
       i++;
       return memList[i-1];
   }
}