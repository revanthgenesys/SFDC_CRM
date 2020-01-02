/************************************************************************************
Purpose :  Send a notification to an alias when an user updated opportunity price of a closed opportunity.
Written By :  Naresh
Test Classes :  OpportunityPriceChangeNotificationHelperTest
*************************************************************************************/
public class OpportunityPriceChangeNotificationHelper {
	
    public static void sendClosedOppNotification(List<Opportunity> listOfOpps, Map<Id, Opportunity> oldMap){
        try{
            Opportunity objNewOpp = listOfOpps[0];
            Opportunity objOldOpp = oldMap.get(objNewOpp.id);
            if(objNewOpp.StageName == '6.Closed' && objOldOpp.StageName == '6.Closed' 
               && (objNewOpp.License_Amount__c != objOldOpp.License_Amount__c
                //|| objNewOpp.Booking__c != objOldOpp.Booking__c
                || objNewOpp.ACV_Subscription_Only__c != objOldOpp.ACV_Subscription_Only__c
                || objNewOpp.Total_Annual_Contract_Value__c != objOldOpp.Total_Annual_Contract_Value__c
                || objNewOpp.Total_PS_Support__c != objOldOpp.Total_PS_Support__c
                || objNewOpp.Monthly_Commitment__c != objOldOpp.Monthly_Commitment__c
                || objNewOpp.Estimated_Usage_Agreements_EUA__c != objOldOpp.Estimated_Usage_Agreements_EUA__c
                || objNewOpp.Lines_of_Businesses__c != objOldOpp.Lines_of_Businesses__c
                || objNewOpp.CloseDate != objOldOpp.CloseDate)){
                    sendNotification(objNewOpp, objOldOpp);	    
            }
        }
        catch(Exception ex){
            System.debug('NKC debug ex [' + ex.getMessage() + ']');
        }
    }
    
    private static void sendNotification(Opportunity objNewOpp, Opportunity objOldOpp){
        Opportunity objOpp = [SELECT LastModifiedBy.Name, RecordType.DeveloperName FROM Opportunity WHERE id =: objNewOpp.id];
        if(objOpp.RecordType.DeveloperName != 'GEN_Opportunity_Record_Type_New'){
            return;
        }
        String htmlBody = 'Hi, <br/><br/>The following opportunity\'s price has been updated by <b>' + objOpp.LastModifiedBy.Name + '.</b><br/><br/>';
        htmlBody += '<table style="font-family: verdana,arial,sans-serif;font-size:12px;color:#333333;border-width:1px;border-color:#666666;border-collapse: collapse;">';
        htmlBody += '<tr><th colspan="4"  style="border-width:1px;padding:4px;border-style:solid;border-color: #666666;background-color: #dedede;">Opportunity <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + objNewOpp.id + '"> [' + objNewOpp.Name + '] </a> Price updated.</th></tr>';
        htmlBody += '<tr><th style="border-width:1px;padding:4px;border-style:solid;border-color: #666666;background-color: #dedede;text-align:left;">Field Name</th><th style="border-width:1px;padding:4px;border-style:solid;border-color: #666666;background-color: #dedede;text-align:right;">Old Value</th><th style="border-width:1px;padding:4px;border-style:solid;border-color: #666666;background-color: #dedede;text-align:right;">New Value</th><th style="border-width:1px;padding:4px;border-style:solid;border-color: #666666;background-color: #dedede;text-align:right;">Difference</th></tr>';
        Decimal decDifference = 0;
        if((objNewOpp.Lines_of_Businesses__c != objOldOpp.Lines_of_Businesses__c)){
        	htmlBody += '<tr><td width="200px" style="text-align:left;border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Offering Type  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + (objOldOpp.Lines_of_Businesses__c == null ? 'Blank' : objOldOpp.Lines_of_Businesses__c) +  '</td><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + (objNewOpp.Lines_of_Businesses__c == null ? '' : objNewOpp.Lines_of_Businesses__c) + '</td><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;"><td/></tr>';                
        }
        if((objNewOpp.CloseDate != objOldOpp.CloseDate)){
        	htmlBody += '<tr><td width="200px" style="text-align:left;border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Closed Date  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + String.valueOf((objOldOpp.CloseDate == null ? Date.newInstance(2000,1,1) : objOldOpp.CloseDate)) +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + String.valueOf((objNewOpp.CloseDate == null ? Date.newInstance(2000,1,1) : objNewOpp.CloseDate)) +  '</td><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;"><td/></tr>';                
        }
        if((objNewOpp.License_Amount__c != objOldOpp.License_Amount__c)){
            decDifference = (objNewOpp.License_Amount__c == null ? 0 : objNewOpp.License_Amount__c) - (objOldOpp.License_Amount__c == null ? 0 : objOldOpp.License_Amount__c);
        	htmlBody += '<tr><td width="200px" style="text-align:left;border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">License Amount  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objOldOpp.License_Amount__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objNewOpp.License_Amount__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + decDifference +  '</td></tr>';                
        }
        /*
        if((objNewOpp.Booking__c != objOldOpp.Booking__c)){
            decDifference = (objNewOpp.Booking__c == null ? 0 : objNewOpp.Booking__c) - (objOldOpp.Booking__c == null ? 0 : objOldOpp.Booking__c);
        	htmlBody += '<tr><td width="200px" style="text-align:left;border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Booking  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objOldOpp.Booking__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objNewOpp.Booking__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + decDifference +  '</td></tr>';                             
        }
		*/
        if((objNewOpp.ACV_Subscription_Only__c != objOldOpp.ACV_Subscription_Only__c)){
            decDifference = (objNewOpp.ACV_Subscription_Only__c == null ? 0 : objNewOpp.ACV_Subscription_Only__c) - (objOldOpp.ACV_Subscription_Only__c == null ? 0 : objOldOpp.ACV_Subscription_Only__c);
        	htmlBody += '<tr><td width="200px" style="text-align:left;border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Annual Contract Value (ACV)  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objOldOpp.ACV_Subscription_Only__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objNewOpp.ACV_Subscription_Only__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + decDifference +  '</td></tr>';                            
        }
        if((objNewOpp.Total_Annual_Contract_Value__c != objOldOpp.Total_Annual_Contract_Value__c)){
            decDifference = (objNewOpp.Total_Annual_Contract_Value__c == null ? 0 : objNewOpp.Total_Annual_Contract_Value__c) - (objOldOpp.Total_Annual_Contract_Value__c == null ? 0 : objOldOpp.Total_Annual_Contract_Value__c);
        	htmlBody += '<tr><td width="200px" style="text-align:left;border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Total Contract Value (TCV)  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objOldOpp.Total_Annual_Contract_Value__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objNewOpp.Total_Annual_Contract_Value__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + decDifference +  '</td></tr>';                                
        }
        if((objNewOpp.Total_PS_Support__c != objOldOpp.Total_PS_Support__c)){
            decDifference = (objNewOpp.Total_PS_Support__c == null ? 0 : objNewOpp.Total_PS_Support__c) - (objOldOpp.Total_PS_Support__c == null ? 0 : objOldOpp.Total_PS_Support__c);
        	htmlBody += '<tr><td width="200px" style="text-align:left;border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Professional Services-Cloud  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objOldOpp.Total_PS_Support__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objNewOpp.Total_PS_Support__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + decDifference +  '</td></tr>';
        }
        if((objNewOpp.Monthly_Commitment__c != objOldOpp.Monthly_Commitment__c)){
            decDifference = (objNewOpp.Monthly_Commitment__c == null ? 0 : objNewOpp.Monthly_Commitment__c) - (objOldOpp.Monthly_Commitment__c == null ? 0 : objOldOpp.Monthly_Commitment__c);
        	htmlBody += '<tr><td width="200px" style="text-align:left;border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Committed Monthly Recurring Rev (CMRR)  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objOldOpp.Monthly_Commitment__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objNewOpp.Monthly_Commitment__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + decDifference +  '</td></tr>';                               
        }
        if((objNewOpp.Estimated_Usage_Agreements_EUA__c != objOldOpp.Estimated_Usage_Agreements_EUA__c)){
            decDifference = (objNewOpp.Estimated_Usage_Agreements_EUA__c == null ? 0 : objNewOpp.Estimated_Usage_Agreements_EUA__c) - (objOldOpp.Estimated_Usage_Agreements_EUA__c == null ? 0 : objOldOpp.Estimated_Usage_Agreements_EUA__c);
        	htmlBody += '<tr><td width="200px" style="text-align:left;border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Estimated Usage Agreements (EUA)  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objOldOpp.Estimated_Usage_Agreements_EUA__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + objNewOpp.Estimated_Usage_Agreements_EUA__c +  '</td><td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;text-align:right;">' + decDifference +  '</td></tr>';                                
        }        
        htmlBody += '</table><br/><br/>Thanks';
        
        String strRecipientEmail = OpportunityBookingChangeNotifications__c.getAll().get(objNewOpp.Country_Region__c).Email_Ids__c;
        //strRecipientEmail = strRecipientEmail + ',nareshk.it@gmail.com'; 
        System.debug('NKC debug objNewOpp.Country_Region__c [' + objNewOpp.Country_Region__c + ']');
        System.debug('NKC debug strRecipientEmail [' + strRecipientEmail + ']');
        
        SendEmail.sendSingleEmail(strRecipientEmail, 'Closed Opportunity [' + objNewOpp.Name + '] price updated.', htmlBody);
    }
}