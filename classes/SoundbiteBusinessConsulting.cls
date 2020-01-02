//Naresh Kumar  06/06/2014
global without sharing class SoundbiteBusinessConsulting {

    webservice static String callSoundBiteBusinessConsulting(String recordId){
        try{
            List<Business_Consulting__c> bussConsulingRecords = [SELECT Contact_Formula_1__c, Contact_Formula_2__c, Contact_Formula_3__c, 
                Contact_Formula_4__c, Contact_5__r.Email, Account__c, Contact_Formula_Name_1__c, Contact_Formula_Name_2__c, Contact_Formula_Name_3__c,
                Contact_Formula_Name_4__c, Contact_5__r.Name, Contact_1__r.Phone, Contact_2__r.Phone, Contact_3__r.Phone,
                Contact_4__r.Phone, Contact_5__r.Phone, Sold_to_Account__r.Name, Primary_Consultant__r.Name,
                Secondary_Consultant__r.Name, End_User_Account__r.Name,
                Contact_1__r.Account.Country__r.Region__c,Contact_2__r.Account.Country__r.Region__c,Contact_3__r.Account.Country__r.Region__c,
                Contact_4__r.Account.Country__r.Region__c,Contact_5__r.Account.Country__r.Region__c,Region__c,
                Status__c                
                FROM Business_Consulting__c WHERE id =: recordId AND Status__c = null];          
            
            if(bussConsulingRecords.isEmpty()){
                return 'Survey already sent.';
            }
            for(Business_Consulting__c eachBC : bussConsulingRecords){ 
                string body = prepareJSON(eachBC);      
                callout(body);
                eachBC.Status__c = 'Pending';
            }
            update bussConsulingRecords;
            return 'OK';
        }
        catch(Exception ex){
            return ex.getMessage();
        }
        return '';
    }
    //@future(callout=true) 
    private static void callout(String json){
        String endPoint = Label.SoundBite_Credentials.split(',')[0];//'https://service3.soundbite.com/site/c/4/CampaignManagementService/createContactBatch';
        String userName = Label.SoundBite_Credentials.split(',')[1];//'API_international@genesys.com';
        String password = Label.SoundBite_Credentials.split(',')[2];//'g3n34pi!!';
        HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('POST');
        
            Blob headerValue = Blob.valueOf(userName + ':' + password);
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            System.debug('NKC debug body [ '+ json + ']');
            req.setBody('payload=' + json);             
            // Create a new http object to send the request object
            // A response object is generated as a result of the request            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('*****'+res.getBody());    
    }

    private static String prepareJSON(Business_Consulting__c bcRecord){
        
        String json = '' +
        '[' +
            '{' +
                '"owner": {'+
                    '"internalId": "3000098363"'+
                '},'+
                '"campaign": {' +
                    '"externalId": "Business_Consulting_Survey"'+
                '},' +
                '"outreachStrategy": {' +                   
                    '"externalId": "Email"'+
                '}'+
            '},'+
            '['+
                '{'+
                    '"externalId":"' + bcRecord.id + '",' +
                    '"devices": ['+
                        '{'+
                            '"externalId": "' + bcRecord.Contact_Formula_1__c + '"'+
                        '},'+
                        '{'+
                            '"externalId": "' + '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '}'+
                    '],'+
                    '"attributes": ['+
                        '{'+
                            '"name": "company",'+
                            '"value": "' + bcRecord.End_User_Account__r.Name + '"'+
                        '},'+
                        '{'+
                            '"name": "other1",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_1__c + '|' + bcRecord.Contact_1__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other2",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_2__c + '|' + bcRecord.Contact_2__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other3",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_3__c + '|' + bcRecord.Contact_3__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other4",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_4__c + '|' + bcRecord.Contact_4__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other5",'+
                            '"value": "' + bcRecord.Contact_5__r.Name + '|' + bcRecord.Contact_5__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other6",'+
                            '"value": "' + bcRecord.Sold_to_Account__r.Name + '"'+
                        '},'+
                        '{'+
                            '"name": "other7",'+
                            '"value": "' + bcRecord.Region__c +'"'+
                        '},'+
                        '{'+
                            '"name": "other8",'+
                            '"value": " '+ bcRecord.Primary_Consultant__r.Name + '|' + bcRecord.Secondary_Consultant__r.Name +' "'+
                        '},'+
                        '{'+
                            '"name": "other9",'+
                            '"value": " https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + bcRecord.id + '"'+
                        '}'+
                    ']'+
                '}';
                if(bcRecord.Contact_2__c != null || bcRecord.Contact_Formula_2__c !=null){
                    json +=
                ',{'+
                    '"externalId": "' + bcRecord.id + '",'+
                    '"devices": ['+
                        '{'+
                            '"externalId": "' + '"'+
                        '},'+
                        '{'+
                            '"externalId": "' + bcRecord.Contact_Formula_2__c + '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '}'+
                    '],'+
                    '"attributes": ['+
                        '{'+
                            '"name": "company",'+
                            '"value": "' + bcRecord.End_User_Account__r.Name + '"'+
                        '},'+
                        '{'+
                            '"name": "other1",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_1__c + '|' + bcRecord.Contact_1__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other2",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_2__c + '|' + bcRecord.Contact_2__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other3",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_3__c + '|' + bcRecord.Contact_3__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other4",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_4__c + '|' + bcRecord.Contact_4__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other5",'+
                            '"value": "' + bcRecord.Contact_5__r.Name + '|' + bcRecord.Contact_5__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other6",'+
                            '"value": "' + bcRecord.Sold_to_Account__r.Name + '"'+
                        '},'+
                        '{'+
                            '"name": "other7",'+
                            '"value": "' + bcRecord.Region__c +'"'+
                        '},'+
                        '{'+
                            '"name": "other8",'+
                            '"value": " '+ bcRecord.Primary_Consultant__r.Name + '|' + bcRecord.Secondary_Consultant__r.Name +' "'+
                        '},'+
                        '{'+
                            '"name": "other9",'+
                            '"value": " https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + bcRecord.id + '"'+
                        '}'+
                    ']'+
                '}';
                 
                    
                 }
                    
                 if(bcRecord.Contact_3__c != null || bcRecord.Contact_Formula_3__c !=null){
                    json +=
                
                ',{'+
                    '"externalId": "' + bcRecord.id + '",'+
                    '"devices": ['+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' + bcRecord.Contact_Formula_3__c + '"'+
                        '},'+
                        '{'+
                            '"externalId": "' + '"'+
                        '},'+
                        '{'+
                            '"externalId": "' + '"'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '}'+
                    '],'+
                    '"attributes": ['+
                        '{'+
                            '"name": "company",'+
                            '"value": "' + bcRecord.End_User_Account__r.Name + '"'+
                        '},'+
                        '{'+
                            '"name": "other1",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_1__c + '|' + bcRecord.Contact_1__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other2",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_2__c + '|' + bcRecord.Contact_2__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other3",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_3__c + '|' + bcRecord.Contact_3__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other4",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_4__c + '|' + bcRecord.Contact_4__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other5",'+
                            '"value": "' + bcRecord.Contact_5__r.Name + '|' + bcRecord.Contact_5__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other6",'+
                            '"value": "' + bcRecord.Sold_to_Account__r.Name + '"'+
                        '},'+
                        '{'+
                            '"name": "other7",'+
                            '"value": "' +  bcRecord.Region__c +'"'+
                        '},'+
                        '{'+
                            '"name": "other8",'+
                            '"value": " '+ bcRecord.Primary_Consultant__r.Name + '|' + bcRecord.Secondary_Consultant__r.Name +' "'+
                        '},'+
                        '{'+
                            '"name": "other9",'+
                            '"value": " https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + bcRecord.id + '"'+
                        '}'+
                    ']'+
                '}';
                }
                if(bcRecord.Contact_4__c != null || bcRecord.Contact_Formula_4__c !=null){
                    json +=
                ',{'+
                    '"externalId": "' + bcRecord.id + '",'+
                    '"devices": ['+
                        '{'+
                            '"externalId": "' + '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' + bcRecord.Contact_Formula_4__c + '"'+
                        '},'+
                        '{'+
                            '"externalId": "' + '"'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '}'+
                    '],'+
                    '"attributes": ['+
                        '{'+
                            '"name": "company",'+
                            '"value": "' + bcRecord.End_User_Account__r.Name+ '"'+
                        '},'+
                        '{'+
                            '"name": "other1",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_1__c + '|' + bcRecord.Contact_1__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other2",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_2__c + '|' + bcRecord.Contact_2__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other3",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_3__c + '|' + bcRecord.Contact_3__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other4",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_4__c + '|' + bcRecord.Contact_4__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other5",'+
                            '"value": "' + bcRecord.Contact_5__r.Name + '|' + bcRecord.Contact_5__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other6",'+
                            '"value": "' + bcRecord.Sold_to_Account__r.Name + '"'+
                        '},'+
                        '{'+
                            '"name": "other7",'+
                            '"value": "' +  bcRecord.Region__c +'"'+
                        '},'+
                        '{'+
                            '"name": "other8",'+
                            '"value": " '+ bcRecord.Primary_Consultant__r.Name + '|' + bcRecord.Secondary_Consultant__r.Name +' "'+
                        '},'+
                        '{'+
                            '"name": "other9",'+
                            '"value": " https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + bcRecord.id + '"'+
                        '}'+
                    ']'+
                '}';
                }
                if(bcRecord.Contact_5__c != null){
                    json +=
                ',{'+
                    '"externalId": "' + bcRecord.id + '",'+
                    '"devices": ['+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' + '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' +  '"'+
                        '},'+
                        '{'+
                            '"externalId": "' + bcRecord.Contact_5__r.Email + '"'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '},'+
                        '{'+
                            '"externalId": ""'+
                        '}'+
                    '],'+
                    '"attributes": ['+
                        '{'+
                            '"name": "company",'+
                            '"value": "' + bcRecord.Account__c + '"'+
                        '},'+
                        '{'+
                            '"name": "other1",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_1__c + '' + bcRecord.Contact_1__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other2",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_2__c + '' + bcRecord.Contact_2__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other3",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_3__c + '' + bcRecord.Contact_3__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other4",'+
                            '"value": "' + bcRecord.Contact_Formula_Name_4__c + '' + bcRecord.Contact_4__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other5",'+
                            '"value": "' + bcRecord.Contact_5__r.Name + '' + bcRecord.Contact_5__r.Phone + '"'+
                        '},'+
                        '{'+
                            '"name": "other6",'+
                            '"value": "' + bcRecord.Sold_to_Account__r.Name + '"'+
                        '},'+
                        '{'+
                            '"name": "other7",'+
                            '"value": "' +  bcRecord.Region__c +'"'+
                        '},'+
                        '{'+
                            '"name": "other8",'+
                            '"value": " '+ bcRecord.Primary_Consultant__r.Name + '|' + bcRecord.Secondary_Consultant__r.Name +' "'+
                        '},'+
                        '{'+
                            '"name": "other9",'+
                            '"value": " https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + bcRecord.id + '"'+
                        '}'+
                    ']'+
                '}';
                }
            json += ']'+
        ']';
        return json.replace('null','');
    }
}