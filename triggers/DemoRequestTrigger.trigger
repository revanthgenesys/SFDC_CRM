trigger DemoRequestTrigger on Demo_Request__c (after update) {
    if(Trigger.IsAfter){
        if(Trigger.IsUpdate){
            DemoRequestClass.AfterReqUpdate(Trigger.new);
        }
    }

}