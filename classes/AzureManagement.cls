public class AzureManagement {
    private string storageKey;
    private string storageName;
    private string storageContainer;
    private string storageUrl;
    private Integer batchSize;
    
    private final string DATEFORMAT = 'EEE, dd MMM yyyy HH:mm:ss z';
    private final string MESSAGEFORMAT = '<QueueMessage><MessageText>{0}</MessageText></QueueMessage>';
    
    public AzureManagement(string key, string name, string container, string url)
    {
        this(key, name, container, url, 100);
    }
    
    public AzureManagement(string key, string name, string container, string url, Integer batch)
    {
        System.debug(LoggingLevel.INFO, 'AzureManagement setting up...');
        System.debug(LoggingLevel.INFO, 'storageKey = ' + key);
        System.debug(LoggingLevel.INFO, 'storageName = ' + name);
        System.debug(LoggingLevel.INFO, 'storageContainer = ' + container);
        System.debug(LoggingLevel.INFO, 'storageUrl = ' + url);
        System.debug(LoggingLevel.INFO, 'batchSize = ' + batch);

        storageKey = key;
        storageName = name;
        storageContainer = container;
        storageUrl = url;
        batchSize = batch;
    }
    
    public boolean sendMessageToQueue(string message)
    {
        boolean success = true;
        
        System.debug(LoggingLevel.INFO, 'Sending message to queue: ' + message);

        try
        {
            sendMessage(MESSAGEFORMAT.replace('{0}', EncodingUtil.base64Encode(Blob.valueOf(message))));
        }
        catch (system.CalloutException ce)
        {
            System.debug(LoggingLevel.ERROR, ce);
            success = false;
        } 
        
        return success;
    }
    
    public boolean sendMultipleMessagesToQueue(List<string> messages)
    {
        boolean success = true;
        
        Integer passes = messages.size() / batchSize;
        if ((Math.mod(messages.size(), batchSize)) > 0 )
        {
            passes++;
        }
        system.debug(messages.size());
        system.debug(passes);
        for (Integer p = 0; p < passes; p++)
        {
            string finalMessage = '{ command: "batch", list: [';
            
            for (Integer i = 0; (i < batchSize) && (i + (batchSize * p) < messages.size()); i++)
            {
                finalMessage += messages.get(i + (batchSize * p));
                if (i < (batchSize - 1))
                {
                    finalMessage += ', ';
                }
            }
            
            finalMessage += '] }';
            
            try
            {
                sendMessage(MESSAGEFORMAT.replace('{0}', EncodingUtil.base64Encode(Blob.valueOf(finalMessage))));
                
            }
            catch (system.CalloutException ce)
            {
                system.debug(ce);
                success = false;
            }
        }
        
        return success;
    }
    
    private void sendMessage(string message)
    {        
        // Create HTTP POST request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/xml');
        
        string formattedDate = getFormattedDate();
        req.setHeader('x-ms-date', formattedDate);
        
        // Create authorization header per Azure rules
        string signature = getSignatureForQueue(formattedDate);
        string authHeader = 'SharedKey ' + storageName + ':' + signature;
        req.setHeader('Authorization', authHeader);
        
        req.setEndpoint(storageUrl);
        
        // Add message to body
        req.setBody(message);
                
        Http http = new Http();
        HTTPResponse res;
        
        // only do this if not running in a test method
        if(!Test.isRunningTest())
        {
            System.debug(LoggingLevel.INFO, 'Sending the message to Azure');
            res = http.send(req);                
            System.debug(LoggingLevel.INFO, 'http.send result status: ' + res.getStatus());
        }
        else
        {
            System.debug(LoggingLevel.INFO, 'Running in a test so not sending the message to Azure');
        }
    }
    
    private string getSignatureForQueue(string formattedDate)
    {
        // build signature string based on Azure documentation
        string stringToSign = 'POST\n\napplication/xml\n\nx-ms-date:' + formattedDate + '\n/' + storageName + '/' + storageContainer + '/messages';
    
        // create signature by encoding and then encrypting string and then encoding again
        Blob temp = EncodingUtil.base64Decode(storageKey);
        Blob hmac = Crypto.generateMac('HMacSHA256', Blob.valueOf(stringToSign), temp);
        
        return EncodingUtil.base64Encode(hmac);
    }
    
    private string getFormattedDate()
    {
        // Format as such: Sun, 11 Oct 2009 19:52:39 GMT
        Datetime dt = Datetime.now().addMinutes(-5);
        return dt.formatGMT(DATEFORMAT);
    }
}