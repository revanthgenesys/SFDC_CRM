trigger MintigoAccountTrigger_Genesys on Account (after insert, after update) {
    System.debug('Accounts trigger fired!!!');
    if(System.isFuture() || System.isBatch()) {
        System.debug('Accounts trigger fired from FUTURE, leaving!!!');
        return;
    }
    if(Mintigo_TriggerHandler.isFirstTime) {
        Mintigo_TriggerHandler.isFirstTime = false;
        if (!MintigoScore_Genesys.is_running) {
            Set<Id> accountIDs = new Set<Id>();
            for(Account a : Trigger.new) {
                accountIDs.add(a.Id);
            }
            System.debug('Accounts trigger running!!!');
            MintigoScore_Genesys.enrichAccounts(accountIDs);
        }
     } else {
         System.debug('Another Mintigo trigger is already running in the same context');
     }
}