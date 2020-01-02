trigger Validate_Opportunity on Opportunity(before update, before insert)  {
    opportunity opp = trigger.new[0];

    if (Util.Bypass_Trigger_Chk) 
        return;
        
    if(Trigger.isinsert){

        if (opp.RecordTypeId != Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('GEN - Opportunity Record Type').RecordTypeId || 
            opp.Name.contains('Talker') || opp.Name.contains('talker')) 
            return;
    
        if (((opp.StageName == '4.Build Consensus' || opp.StageName == '5.Purchase Solution' || opp.StageName == '6.Closed' || opp.StageName == '8.Renewal'))
              && opp.Win_Loss_Status__c != 'Lost' && opp.Win_Loss_Status__c != 'Merged/Dup Opp'  && opp.Primary_Line_of_Business__c != null && opp.Primary_Line_of_Business__c.contains('Premise') && opp.Lines_of_Businesses__c !=null && !opp.Lines_of_Businesses__c.contains('PureCloud') && !opp.Lines_of_Businesses__c.contains('PureConnect')) {
            integer dq_count = [select count() from Deal_Qualification__c where opportunity__c =: opp.id and status__c = 'Approved'];
            if (dq_count == 0) {
                integer quot_count = [select count() from BigMachines__Quote__c where BigMachines__Opportunity__c =: opp.id and BigMachines__Is_Primary__c = true]; //and  BigMachines__Status__c!='Quote In Progress' and  BigMachines__Status__c!= 'Revision Pending'
                if (quot_count == 0 && (opp.ININ_ID__c == null || opp.ININ_ID__c == ''))
                    opp.ForecastStatus__c.addError('Deal qualification or Quote should be Approved for Forecast status of Upside, Expected or Commit');
                return;
            }
    
    
        }
    }
    
    if(opp.Primary_Line_of_Business__c == 'Cloud' && (opp.ForecastStatus__c == '1.In Hand' || opp.ForecastStatus__c == '0.Booked') &&
       (Trigger.isInsert || opp.ForecastStatus__c != Trigger.oldMap.get(opp.Id).ForecastStatus__c))
    {
        List<SetupEntityAccess> list_Permission = new List<SetupEntityAccess>();
        
        list_Permission = [SELECT SetupEntityId
                         FROM SetupEntityAccess
                         WHERE SetupEntityId = :[Select id from CustomPermission where DeveloperName = 'Oppty_Forecast_Status_Validation_Skip' limit 1][0].id AND
                         ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment
                         WHERE AssigneeId = :UserInfo.getUserId())];
        
        if(list_Permission.isEmpty())                    
            opp.ForecastStatus__c.adderror(Label.PC_In_hand_validation_message);
    }

}