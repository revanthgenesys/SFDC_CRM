// Approver should not be able to delete category/country in application review
trigger PreventDeleteWhenAppInReview on Partner_Application_Category_and_Country__c (before delete) 
{
    if(!PartnerPortalUtil.blnIgnoreDeleteTrigger)
    {
        for(Partner_Application_Category_and_Country__c objPACC : Trigger.old)
        {
            if(objPACC.Application_Status__c == 'In Review' || objPACC.Application_Status__c == 'Submitted' || objPACC.Application_Status__c == 'Approved')
                objPACC.addError('Cannot delete Category and Country Combination when Application is in review (In review/Submitted/Approved).Please set status to \'Rejected\' if the combination is to be rejected.');
        }
    }
}