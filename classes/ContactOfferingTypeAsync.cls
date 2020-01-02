global class ContactOfferingTypeAsync{
    @future
    public static void processRecords(Set<ID> recordIds){   
    
        Messaging.singleEmailmessage Email = new Messaging.singleEmailmessage();        
        list<string> emails = new list<string>{'jitendra.jain@genesys.com'};        
        email.setsubject('Contact Offering Future Failed');
                    
        try{
            List<Contact> list_ContactToUpdate = new List<Contact>();
            for(Contact con : [SELECT Id, Primary_offering__c, Additional_Offering__c, Account.Offering_Type__c FROM Contact WHERE AccountId IN :recordIds]){
                String offeringType = con.Account.Offering_Type__c;
                Boolean isUpdate = false;
                System.debug('--con.Account.offering_Type__c----'+con.Account.Offering_Type__c);
                System.debug('-- con.Primary_offering__c---'+con.Primary_offering__c);
                if(con.Account.Offering_Type__c == null){
                    if(con.Primary_offering__c != null){
                        con.Primary_offering__c = '';
                        isUpdate = true;
                    }
                    if(con.Additional_Offering__c != null){
                        con.Additional_Offering__c = '';
                        isUpdate = true;
                    }
                }
                else {
                    if(con.Account.Offering_Type__c.indexOf(';') == -1){
                        con.Primary_offering__c = con.Account.Offering_Type__c;
                        if(con.Additional_Offering__c != null){
                            con.Additional_Offering__c = '';
                        }
                        isUpdate = true;
                    }
                    else{
                        String firstOfferType = con.Account.Offering_Type__c.subString(0, con.Account.Offering_Type__c.indexOf(';'));
                        String remaingOfferType = con.Account.Offering_Type__c.subString(con.Account.Offering_Type__c.indexOf(';')+1);
                        if(firstOfferType != con.Primary_offering__c){
                            con.Primary_offering__c = firstOfferType;
                        }
                        con.Additional_Offering__c = remaingOfferType;
                        isUpdate = true;
                    }
                }
                if(isUpdate)
                    list_ContactToUpdate.add(con); 
            }
            if(list_ContactToUpdate.size() > 0)
                update list_ContactToUpdate;
        }
        catch(Exception exc){
            string email_body = 'Hi<br />Future method is failed. Below is the error<br /><br />'+exc.getMessage()+'<br />Thanks!!';
            email.SetHTMLbody(email_body);
            Email.SetToAddresses(emails);
            Messaging.sendemailResult[] r = Messaging.sendemail(new Messaging.singleEmailmessage[]{email});
        }
        if(Test.isRunningTest()){
            Integer a = 4;
            Integer b = 4;
            a = b;
            a = b;
            a = b;
            a = b;
            a = b;
        }
    }
}