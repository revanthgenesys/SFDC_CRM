trigger trgUpdateGoLive on Cloud_Billing_Phase__c (after insert ,after update) {
  //List<Cloud_Billing_Phase__c>list_CBP = [Select id,Cloud_Billing_Information__c,End_Date__c,Phase_Name__c from Cloud_Billing_Phase__c where Cloud_Billing_Information__c =: trigger.new[0].Cloud_Billing_Information__c AND (Phase_Name__c =: 'Go Live' OR Phase_Name__c <> 'Go Live') ORDER BY End_Date__c ASC LIMIT 1];
  List<Cloud_Billing_Phase__c>list_CBP = [Select id,Phase_Classification__c,Cloud_Billing_Information__c,End_Date__c,Phase_Name__c from Cloud_Billing_Phase__c where Cloud_Billing_Information__c =: trigger.new[0].Cloud_Billing_Information__c ORDER BY End_Date__c ASC];
  
  Cloud_Billing_Information__c objCBI = [Select id,Actual_Go_Live_Date__c,SOW_Fully_Delivered_Date_Actual__c from Cloud_Billing_Information__c where id =: trigger.new[0].Cloud_Billing_Information__c ];
  if(list_CBP != null && list_CBP.size() >0)
  {
      boolean isGoLive = false;
      date dtGoLiveDate;
      
      boolean isSteadyState = false;
      date dtSteadyState;
      for(Cloud_Billing_Phase__c objCBP : list_CBP)
      {
        if(objCBP.Phase_Classification__c == 'Go Live')
        {
         isGoLive = true;
         dtGoLiveDate = objCBP.End_Date__c;
        }
        if(objCBP.Phase_Classification__c == 'Steady State')
        {
         isSteadyState = true;
         dtSteadyState = objCBP.End_Date__c;
        }
      }
      
        if(isGoLive)
        {
          objCBI.Actual_Go_Live_Date__c = dtGoLiveDate;
          update objCBI;
        }
        else if(isSteadyState)
        {
          objCBI.SOW_Fully_Delivered_Date_Actual__c = list_CBP[0].End_Date__c;
          update objCBI;
        }
        else
        {
            //Compare Phase date with Go-Live date
            if(list_CBP[0].End_Date__c != objCBI.Actual_Go_Live_Date__c)
            {
              //if date is not same then update Go-Live date from earliest phase date 
              objCBI.Actual_Go_Live_Date__c = list_CBP[0].End_Date__c;
              update objCBI;
            }
        }   
  }
}