/*Pankaj    12/13/2017  Created 
Description   : This trigger update the SourceAccounts Trial Deactivation Date based on the Trial Status.
*/

trigger SourceAccountMain on SourceAccounts__c (after insert, after update) {

    if(trigger.isUpdate)
        clsSourceAccountTriggerHelper.UpdateTrialDate(trigger.newMap, trigger.oldMap);

}