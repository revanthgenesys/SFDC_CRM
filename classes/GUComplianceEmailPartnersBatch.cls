global class GUComplianceEmailPartnersBatch implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC){
        AggregateResult[] groupedResults = [SELECT Account__c, COUNT(Name) certCount FROM Partner_Certifications__c 
                                                  WHERE Account__c != NULL AND Pass_Fail__c = 'P' AND Expiry_Date__c = NEXT_N_DAYS:90
                                                  GROUP BY Account__c];
        Set<String> accountIds = new Set<String>();
        for(AggregateResult ar : groupedResults){
            accountIds.add((String)ar.get('Account__c'));
        }
    	return Database.getQueryLocator([SELECT id, Name, 
                                         (SELECT id, Name, Email FROM Contacts WHERE Designated_Partner_Contact__c = True), 
                                         (SELECT id, Name, Test_Name__c, Genesys_Test_Code__c, First_Name__c, Last_Name__c, Email__c, Test_Date__c, Expiry_Date__c FROM Partner_Certifications__r WHERE Pass_Fail__c = 'P' AND Expiry_Date__c = NEXT_N_DAYS:90) 
                                         FROM Account WHERE Id IN :accountIds]);
		
        /*
    	return Database.getQueryLocator([SELECT id, Name, 
                                         (SELECT id, Name, Email FROM Contacts WHERE Designated_Partner_Contact__c = True), 
                                         (SELECT id, Name, Test_Name__c, Genesys_Test_Code__c, First_Name__c, Last_Name__c, Email__c, Test_Date__c, Expiry_Date__c FROM Partner_Certifications__r WHERE Pass_Fail__c = 'P' AND Expiry_Date__c = NEXT_N_DAYS:90) 
                                         FROM Account WHERE Id = '001U0000007Os0N']);
       	*/ 
	}
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Partner_Certifications__c> certsExpiringIn90Days;
        List<Partner_Certifications__c> certsExpiringIn60Days;
        List<Partner_Certifications__c> certsExpiringIn30Days;
        List<String> toAddresses;
        String subject;
        String message;
        
        Date todaysDate = Date.today();
        for(sObject so : scope){
            certsExpiringIn90Days = new List<Partner_Certifications__c>();
            certsExpiringIn60Days = new List<Partner_Certifications__c>();
            certsExpiringIn30Days = new List<Partner_Certifications__c>();
            
            Account a = (Account)so;
            
            for(Partner_Certifications__c pc : a.Partner_Certifications__r){
                if(todaysDate.daysBetween(pc.Expiry_Date__c) > 60){
                    certsExpiringIn90Days.add(pc);
                } else if(todaysDate.daysBetween(pc.Expiry_Date__c) > 30){
                    certsExpiringIn60Days.add(pc);
                } else {
                    certsExpiringIn30Days.add(pc);
                }  
            }
            
            toAddresses = new List<String>();
            for(Contact c : a.Contacts){
               toAddresses.add(c.email);
            }
            subject = 'Genesys Partner Compliance Notification: '+ a.Name +' has certifications expiring in 90 Days';
            message = 'Dear Partner, <br /><br />';
            
			if(certsExpiringIn30Days.size() > 0){
                message += 'The following Certifications are expiring in next 30 Days: <br /><br />';
				message += '<table border="1">';
                message += '<TR><TH>Test Name</TH><TH>Genesys Test Code</TH><TH>Contact Name</TH><TH>Email</TH><TH>Test Date</TH><TH>Expiry Date</TH></TR>';                
                for(Partner_Certifications__c pcert : certsExpiringIn30Days){
                    message += '<TR>';
                	message += '	<TD>'+pcert.Test_Name__c+'</TD>';
                	message += '	<TD>'+pcert.Genesys_Test_Code__c+'</TD>';
                	message += '	<TD>'+pcert.First_Name__c +' '+pcert.Last_Name__c+'</TD>';
                	message += '	<TD>'+pcert.Email__c+'</TD>';
                	message += '	<TD>'+pcert.Test_Date__c.year()+'-'+pcert.Test_Date__c.month()+'-'+pcert.Test_Date__c.day()+'</TD>';
                	message += '	<TD>'+pcert.Expiry_Date__c.year()+'-'+pcert.Expiry_Date__c.month()+'-'+pcert.Expiry_Date__c.day()+'</TD>';
            		message += '</TR>';
                }
                message += '</table> <br /><br />';
            }

			if(certsExpiringIn60Days.size() > 0){
                message += 'The following Certifications are expiring in next 60 Days: <br /><br />';
				message += '<table border="1">';
                message += '<TR><TH>Test Name</TH><TH>Genesys Test Code</TH><TH>Contact Name</TH><TH>Email</TH><TH>Test Date</TH><TH>Expiry Date</TH></TR>';                
                for(Partner_Certifications__c pcert : certsExpiringIn60Days){
                    message += '<TR>';
                	message += '	<TD>'+pcert.Test_Name__c+'</TD>';
                	message += '	<TD>'+pcert.Genesys_Test_Code__c+'</TD>';
                	message += '	<TD>'+pcert.First_Name__c +' '+pcert.Last_Name__c+'</TD>';
                	message += '	<TD>'+pcert.Email__c+'</TD>';
                	message += '	<TD>'+pcert.Test_Date__c.year()+'-'+pcert.Test_Date__c.month()+'-'+pcert.Test_Date__c.day()+'</TD>';
                	message += '	<TD>'+pcert.Expiry_Date__c.year()+'-'+pcert.Expiry_Date__c.month()+'-'+pcert.Expiry_Date__c.day()+'</TD>';
            		message += '</TR>';
                }
                message += '</table> <br /><br />';
            }
            
            if(certsExpiringIn90Days.size() > 0){
                message += 'The following Certifications are expiring in next 90 Days: <br /><br />';
				message += '<table border="1">';
                message += '<TR><TH>Test Name</TH><TH>Genesys Test Code</TH><TH>Contact Name</TH><TH>Email</TH><TH>Test Date</TH><TH>Expiry Date</TH></TR>';                
                for(Partner_Certifications__c pcert : certsExpiringIn90Days){
                    message += '<TR>';
                	message += '	<TD>'+pcert.Test_Name__c+'</TD>';
                	message += '	<TD>'+pcert.Genesys_Test_Code__c+'</TD>';
                	message += '	<TD>'+pcert.First_Name__c +' '+pcert.Last_Name__c+'</TD>';
                	message += '	<TD>'+pcert.Email__c+'</TD>';
                	message += '	<TD>'+pcert.Test_Date__c.year()+'-'+pcert.Test_Date__c.month()+'-'+pcert.Test_Date__c.day()+'</TD>';
                	message += '	<TD>'+pcert.Expiry_Date__c.year()+'-'+pcert.Expiry_Date__c.month()+'-'+pcert.Expiry_Date__c.day()+'</TD>';
            		message += '</TR>';
                }
                message += '</table> <br /><br />';
            }
            
            message += 'Sincerely <br /><br /> The Genesys Partner Network Program Team';
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setToAddresses(toAddresses);
			// email.setToAddresses(new List<String> {'ntumma@gmail.com', 'narasimha@dasincusa.com'});
			email.setSubject(subject);
            email.setHtmlBody(message);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // Nothing at this point of time
    }
}