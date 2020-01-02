trigger Update_Quote_Status on Order__c (before update){
      System.debug('Vikram 0');
    System.debug('Trigger.new>>>'+Trigger.new);
     if(Util.Bypass_Trigger_Chk)return;
     
     //if(trigger.new[0].License_FYM_detail__c == 'PS Orders')
     //return;
     
     if(trigger.new[0].License_FYM_Detail__c == 'PS Orders' && trigger.new[0].recordtypeId==Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('PS Orders').getRecordTypeId())
     return;
     
     //Commented By Pushpendra on Dec 10, 2019 
     //Incident INC0393823 - For CRM team: THe NRO submitted against a PPU Termsheet is completed but does not change forecast Status to Booked
     //removing non revenue order from condition so that forecast status field updates to Booked as per above incident requirement.
     //Skipping revenue orders
     //if(OrderUtil.isNonRevenueOrder(Trigger.new) && trigger.new[0].RecordTypeId !=Label.PPU_Order_RecordTypeId)
      //return;
     
     if(Trigger.new[0].PO_Number__c != Trigger.old[0].PO_Number__c && 
         Trigger.new[0].PO_Number__c !=null && 
         Trigger.new[0].status__c == 'Pending FYM PO')
     {
         Trigger.new[0].status__c = 'Submitted';
     }
     
    //Code Added By Pushpendra on Dec 11, 2019 
    //Incident INC0393823 - For CRM team: THe NRO submitted against a PPU Termsheet is completed but does not change forecast Status to Booked
    //As per chat with Pushpa Ramachandran - "the NRO (non revenue order) should have a PPU type and an opportunity on it and when it is Completed, and if the Opp is not booked, change to booked"
    if(OrderUtil.isNonRevenueOrder(Trigger.new) && Trigger.new[0].NRO_Type__c == 'Pay Per Use' 
       && trigger.new[0].Opportunity__c != null && Trigger.new[0].Status__c == 'Completed' 
       && Trigger.old[0].Status__c != 'Completed' )
    {
        System.debug('Test 0');
        Opportunity oppNew;
        oppNew = new Opportunity(id=trigger.new[0].Opportunity__c);
        oppNew = [Select id,StageName,ForecastStatus__c from opportunity where id=: oppNew.id];
        
        if(oppNew.ForecastStatus__c != null && !oppNew.ForecastStatus__c.equals('0.Booked') && !oppNew.StageName.equals('6.Closed') ){
            OrderTriggerHelperFuture.updateOpportunityBookingStatus(oppNew.id, Trigger.new[0].order_number__c);
        }
        System.debug('Test 1');
    }
    
    System.debug('Test 2');
    
     Opportunity opp;
     // Exclude Cloud Monthly Billing Orders from Opportunity Update logic
     System.debug('Vikram 1');
     if(Trigger.new[0].Status__c == 'Completed' && Trigger.old[0].Status__c != 'Completed' 
        && trigger.new[0].Opportunity__c != null && trigger.new[0].RecordTypeId != Label.Cloud_Monthly_Order_RecordTypeId)
     {
         opp = new Opportunity(id=trigger.new[0].Opportunity__c);
         opp = [Select id,stagename, ForecastStatus__c,recordtype.developername,Win_Loss_Status__c, 
                Country_Region__c, AccountId, Account.Support_Option__c, SAPRevenueOrderNo__c from opportunity where id=: opp.id];
          System.debug('Vikram 2'); 
         //old code commented and new code added below by Pushpendra on Dec 11, 2019
         //if(opp.recordtype.Developername == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && opp.ForecastStatus__c != null && !opp.ForecastStatus__c.equals('0.Booked') && !opp.Country_Region__c.equals('LATAM'))
         //{
         //System.debug('testtttttt');
         //OrderTriggerHelperFuture.updateOpportunityBookingStatus(opp.id, Trigger.new[0].order_number__c);
         //}
         //New code added by Pushpendra on Dec 11, 2019
         //to remove null point error for Country_Region__c field - Incident INC0393823 
         if(opp.recordtype.Developername == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && opp.ForecastStatus__c != null && !opp.ForecastStatus__c.equals('0.Booked'))
         {
             System.debug('testtttttt000');
             if((opp.Country_Region__c == null) || (opp.Country_Region__c != null && !opp.Country_Region__c.equals('LATAM'))){
                 System.debug('testtttttt11');
                 OrderTriggerHelperFuture.updateOpportunityBookingStatus(opp.id, Trigger.new[0].order_number__c);
             }
             
         }
         //Naresh Kumar 03/21/2018
         if(trigger.new[0].Quote__c != null && trigger.new[0].Order_Category__c == 'PureConnect - On Premise'){
             List<BigMachines__Quote__c> objQuote = [SELECT Support_Options__c FROM BigMachines__Quote__c WHERE id =: trigger.new[0].Quote__c];
             if(!objQuote.isEmpty() && opp.Account.Support_Option__c != objQuote[0].Support_Options__c){
                System.debug('NKC debug opp.AccountId [' + opp.AccountId + ']');
                OrderTriggerHelperFuture.updateAccountSupportOption(opp.AccountId, objQuote[0].Support_Options__c);
             }
         }   
        // CreateNROWithFreeParts.createNRO(Trigger.new[0].id);
        // Creating NRO with Queueable class
        ID jobID = System.enqueueJob(new CreateNROWithFreeParts(Trigger.new[0].id));

    }
    System.debug('NKC debug Trigger.old[0].Status__c ['+Trigger.old[0].Status__c+']');
    System.debug('NKC debug Trigger.new[0].Status__c ['+Trigger.new[0].Status__c+']');
    
    // Exclude Cloud Monthly Billing Orders from logic
    if(Trigger.old[0].Status__c == 'Approved' && Trigger.new[0].Status__c != 'Approved' 
            && trigger.new[0].RecordTypeId != Label.Cloud_Monthly_Order_RecordTypeId)
    {
        if(!(trigger.new[0].Status__c == 'Order Submitted' || trigger.new[0].Status__c == 'Send To ERP'||
             trigger.new[0].Order_Number__c != trigger.old[0].Order_Number__c||
             trigger.new[0].Order_Date__c != trigger.old[0].Order_Date__c ||
             trigger.new[0].Invoiced__c != trigger.old[0].Invoiced__c  ||
             trigger.new[0].Invoice_Date__c != trigger.old[0].Invoice_Date__c ||
              trigger.new[0].Invoice_Number__c != trigger.old[0].Invoice_Number__c ||  
              trigger.new[0].Maintenance_Start__c!= trigger.old[0].Maintenance_Start__c||
              trigger.new[0].Maintenance_End__c!= trigger.old[0].Maintenance_End__c||
              trigger.new[0].Rep_Email__c != trigger.old[0].Rep_Email__c)){
                    //trigger.new[0].adderror('Please note this record could not be edited as it is already approved');
                    return;    
            }            
     }
        
     if(Trigger.new[0].status__c == 'Rejected' && Trigger.new[0].status__c != Trigger.old[0].status__c ){
         Trigger.new[0].Date_Rejected__c = Datetime.now();
     }

     if(Trigger.new[0].status__c == 'Submitted'  && Trigger.new[0].status__c != Trigger.old[0].status__c ){
         Trigger.new[0].Date_Submitted__c = Datetime.now();
     }
     
     // Commeted out by Vikram on 4/12/2013 throwing error on Validation cannot use In hand status
    //Uncommented by Ankit for bug 128 on 4/26/2013
     if(Trigger.new[0].status__c == 'Approved'  &&  Trigger.new[0].status__c != Trigger.old[0].status__c)
     {
         Trigger.new[0].Date_Accepted__c = Datetime.now();
         // Exclude Cloud Monthly Billing Orders from logic
         //Oct 12 - Added conditions to filter out PC records - Anju
         if(trigger.new[0].RecordTypeId != Label.Cloud_Monthly_Order_RecordTypeId && trigger.new[0].Offering_Type__c != 'PureCloud' && trigger.new[0].Opportunity__c != null)
         {
             opp = new Opportunity(id=trigger.new[0].Opportunity__c);
             opp = [Select id,stagename, ForecastStatus__c,recordtype.developername,Win_Loss_Status__c, Country_Region__c from opportunity where id=: opp.id];
             if(opp.recordtype.Developername == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && opp != null && 
                opp.ForecastStatus__c != null && !opp.ForecastStatus__c.equals('1.In Hand') && !opp.ForecastStatus__c.equals('0.Booked') && opp.recordtype.Developername == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME )
                 opp.ForecastStatus__c='1.In Hand';
             opp.SAPRevenueOrderNo__c = Trigger.new[0].order_number__c;
             update opp;
            
         }
     }
     
     if(Trigger.new[0].status__c == 'Re-Submitted'  && Trigger.new[0].status__c != Trigger.old[0].status__c ){
         Trigger.new[0].Date_Re_Submitted__c = Datetime.now();
     }
    
    //Commented By Ranjith on Jun 12, 20161 -- Starts
    //Logic is been handled in Process Flow: Update Order & Quote to Rejected if Child Order is Rejected
    // Exclude Cloud Monthly Billing Orders from logic
    //Naresh Kumar  08/04/2017  Uncommenting it as to fix P1 on production.
    if(Trigger.new[0].Quote__c != null && trigger.new[0].RecordTypeId != Label.Cloud_Monthly_Order_RecordTypeId && Trigger.new[0].status__c == 'Rejected')
    {
        BigMachines__Quote__c bmq = new BigMachines__Quote__c(id=Trigger.new[0].Quote__c);
        bmq.BigMachines__Status__c = 'Order Rejected';
        bmq.rejected_flag__c = true;    
        update bmq;        
    }
    //Commented By Ranjith on Jun 12, 20161 -- Ends
    
    // Exclude Cloud Monthly Billing Orders from logic
    if(Trigger.new[0].Quote__c != null && trigger.new[0].RecordTypeId != Label.Cloud_Monthly_Order_RecordTypeId 
        && trigger.new[0].RecordTypeId != Label.AppFoundry_RecordTypeID
        && Trigger.new[0].status__c == 'Approved' && Trigger.new[0].status__c != Trigger.old[0].status__c)
    {
        BigMachines__Quote__c bmq = [SELECT Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Phone__c, Ship_To_Last_Name__c, Ship_To_First_Name__c, 
                            Ship_To_Fax__c, Ship_To_E_Mail__c, Ship_To_Country__c, Ship_To_Company_Name__c, Ship_To_Company_Name_2__c, 
                            Ship_To_City__c, Ship_To_Address__c, Ship_To_Address_2__c, Bill_To_Zip_Code__c, Bill_To_State__c, Bill_To_Phone__c, 
                            Bill_To_Last_Name__c, Bill_To_First_Name__c, Bill_To_Fax__c, Bill_To_E_Mail__c, Bill_To_Country__c, Bill_To_Company_Name__c, 
                            Bill_To_Company_Name_2__c, Bill_To_City__c, Bill_To_Address__c, Bill_To_Address_2__c, End_User_Zip_Code__c, 
                            End_User_State__c, End_User_Phone__c, End_User_Last_Name__c, End_User_First_Name__c, End_User_Fax__c, End_User_E_Mail__c, 
                            End_User_Country__c, End_User_Company_Name__c, End_User_Company_Name_2__c, End_User_City__c, End_User_Address__c, 
                            End_User_Address_2__c,Support_Owner_Zip_Code__c, Support_Owner_State__c, Support_Owner_Phone__c, 
                            Support_Owner_Last_Name__c, Support_Owner_First_Name__c, Support_Owner_Fax__c, Support_Owner_EMail__c, 
                            Support_Owner_Country__c, Support_Owner_Company_Name__c, Support_Owner_Company_Name2__c, Support_Owner_City__c, 
                            Support_Owner_Address__c, Support_Owner_Address2__c, SI_Zip_Code__c, SI_State__c, SI_Phone__c, SI_Last_Name__c, 
                            SI_First_Name__c, SI_Fax__c, SI_EMail__c, SI_Country__c, SI_Company_Name__c, SI_Company_Name2__c, SI_City__c, 
                            SI_Address__c, SI_Address2__c,BigMachines__Opportunity__c, BigMachines__Opportunity__r.accountid,
                            BigMachines__Opportunity__r.Direct_Sales__c, BigMachines__Opportunity__r.BusinessPartner__c
                            FROM BigMachines__Quote__c WHERE id=:Trigger.new[0].Quote__c];
        
        //prospect to customer conversion
        boolean isaccountupdaterequired=false;
        
        if(Trigger.new[0].End_User_Name__c != null)
        {
             account accrtype = [select IsDirect__c,recordtypeid,status__c from Account where id =: Trigger.new[0].End_User_Name__c];
             Id ProspectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMG - Prospect Record Type').getRecordTypeId();
             Id CustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMG - Customer Record Type').getRecordTypeId();         
         
            if(accrtype.recordtypeid == ProspectRecTypeId || accrtype.recordtypeid == CustomerRecTypeId)
            {
                Account acc = new account(id=Trigger.new[0].End_User_Name__c);
                if(accrtype.recordtypeid == ProspectRecTypeId || accrtype.status__c == 'Inactive')
                {
                    acc.recordtypeid = CustomerRecTypeId; 
                    //acc.Type = 'Customer';
                    //Naresh Kumar  03/08/2016  itrack : 21160
                    //acc.New_Logo_Opportunity__c = bmq.BigMachines__Opportunity__c;
                     AccountStatusHelper.populateAccountOppDetails(acc, bmq.BigMachines__Opportunity__c);
                    isaccountupdaterequired = true;
                }
                if(Trigger.new[0].Sold_To_Name__c == Trigger.new[0].End_User_Name__c &&  Trigger.new[0].End_User_Name__c != null && accrtype.IsDirect__c==false)
                {
                    acc.IsDirect__c=true;
                    isaccountupdaterequired = true;
                }
                if(isaccountupdaterequired)
                    update acc;
            }
        }
        ///////-------------------------------------
        
        bmq.BigMachines__Status__c = 'Order Accepted';
        update bmq;        
        
         list<Account_Order_Address__c> aoa_lst = new list<Account_Order_Address__c>();
         aoa_lst = [Select id from Account_Order_Address__c where Order__c =: Trigger.new[0].id];
         
         id enduserid;
         id soldToid;
         enduserid = bmq.BigMachines__Opportunity__r.accountid;
         
         if(bmq.BigMachines__Opportunity__r.Direct_Sales__c==false){
            soldToid = bmq.BigMachines__Opportunity__r.BusinessPartner__c;
         }
         
        if(aoa_lst.size()>0)
            update aoa_lst;

    }
}