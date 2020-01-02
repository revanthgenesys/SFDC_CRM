trigger Checklist_trigger on Export_Screening_Checklist__c (before insert,before update)
 {
       
    Map<ID,boolean> id2Boolean = new Map<ID,boolean>();
    
    List<Export_Screening_Checklist__c> eslist = new List<Export_Screening_Checklist__c>();
    
    Map<Id,Export_Screening_Checklist__c> newESCMap = Trigger.newMap;
    
    Map<Id,Export_Screening_Checklist__c> oldESCMap = Trigger.oldMap;

 if(trigger.isUpdate)
  {
    for(id ESCId:Trigger.newMap.keySet())
      {
        Export_Screening_Checklist__c myNEWESC = newESCMap.get(ESCId);
 
        Export_Screening_Checklist__c myOldESC = oldESCMap.get(ESCId);

        if (myNEWESC.status__c<> myOldESC.status__c && myNEWESC.status__c=='Completed')
         {
           date myDate = date.today();
          
            myNEWESC.Checklist_expiration_date__c= myDate.addYears(1);
           
                myNEWESC.CompletionDate__c= myDate;
               
            }
          id2Boolean.put( myNEWESC.account__c, myNEWESC.screening_checklist_completed__c);
     
        }
      
    }
    if(trigger.isInsert)
      {  
  	    for(Export_Screening_Checklist__c a: Trigger.new)
        { 
      	  if(a.status__c=='Completed')
      	  id2Boolean.put( a.account__c, a.screening_checklist_completed__c);
         }
      }
   List<Account> EscList = [SELECT id, screening_checklist_completed__c FROM Account WHERE id in :id2Boolean.keyset()];
    for(integer i = 0 ; i < EscList.size(); i++)
     {
       EscList[i].screening_checklist_completed__c = id2Boolean.get(EscList[i].id);
   
      }
  
         update EscList;
 
  }