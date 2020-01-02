/***********************************************************************************************
 * Class Name   : RESTAPICallstoCloudConnect
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : This class has all the REST API calls to Cloud connect instances: 1)to authenticate, 2)to push data
 **********************************************************************************************/
 
public without sharing class RESTAPICallsToCloudConnect 
{
    static Cloud_Connect_Configuration__c cc = Cloud_Connect_Configuration__c.getOrgDefaults();
    
    static String authResult;
    
    static String ClientId = cc.Client_Id__c;
    
    static String secret = cc.Secret_Key__c;
    
    static String username = cc.User_Name__c;
    
    static String password = cc.Password__c;
    
    static String endpointUrl = cc.Endpoint_URL__c;
    
    static String instanceUrl;
    
    static String accessToken;
    
    public static Integer authenticate()
    {
        http h = new http();
        httprequest req = new httprequest();
        httpResponse res;
        JSONParser parser;
        Integer statusCode;
        
        req.setEndpoint(endpointUrl+'?grant_type=password&client_id=' + clientId + '&client_secret=' + secret + '&username=' + username + '&password=' + password);
        req.setMethod('POST');
        req.setHeader('X-PrettyPrint','1');
        
        res = h.send(req);
        
        System.debug('Authorization Code -----> '+res.getbody());
        
        statusCode = res.getStatuscode();
        
        if(statusCode==200)
        {
            authResult = res.getbody();
            
            parser = JSON.createParser(authResult);
            while (parser.nextToken() != null) 
            {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'instance_url')) 
                {
                    parser.nextToken();
                    instanceUrl = parser.getText();
                }
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) 
                {
                    parser.nextToken();
                    accessToken = parser.getText();
                }
            }
        }
        
        return statusCode;
    }
    
    public static List<Database.UpsertResult> upsertCall(String requestStr,String restURL)
    {
        http h = new http();
        httprequest req = new httprequest();
        httpResponse res;
        JSONParser parser;
        List<Database.UpsertResult> upsertResult;
        
        req.setEndpoint(instanceUrl+restURL);
        req.setMethod('POST');
        req.setHeader('X-PrettyPrint','1');
        req.setHeader('Authorization','OAuth '+accessToken);
        req.setHeader('Content-Type','application/json');
        req.setBody(requestStr);
        
        res = h.send(req);
        
        System.debug('Upsert Response -----> '+res.getbody());
        
        String str = res.getbody();
        str = str.unescapeEcmaScript();
        str = str.unescapecsv();
        System.debug('====='+str);
        
        upsertResult = (List<Database.UpsertResult>) JSON.deserialize(str, List<Database.UpsertResult>.class);
        System.debug('----->De-Serialized Result: '+upsertResult);
        return upsertResult;
    }
}