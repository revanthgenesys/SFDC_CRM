public class ININDebugLog {

    List<ININ_Debug_Log__c> logQueue;
    
    public ININDebugLog()
    {
        logQueue = new List<ININ_Debug_Log__c>();
    }
    
    static public void LogNow(string source, string message)
    {
        ININ_Debug_Log__c log = new ININ_Debug_Log__c();
        log.Source__c = source;
        log.Message__c = message;
        
        insert log;
    }

    public void AddToQueue(string source, string message)
    {
        ININ_Debug_Log__c log = new ININ_Debug_Log__c();
        log.Source__c = source;
        log.Message__c = message;
        
        logQueue.add(log);
    }
    
    public void FlushQueue()
    {
        if (logQueue.size() > 0)
        {
            insert logQueue;
        }
    }
    
}