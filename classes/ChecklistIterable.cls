//Ravi V - Sales Compliance -  10/16/2013
global class ChecklistIterable implements iterable<Export_Screening_Checklist__c>
{
   global Iterator<Export_Screening_Checklist__c> Iterator()
   {
      return new ChecklistIterator();
   }
}