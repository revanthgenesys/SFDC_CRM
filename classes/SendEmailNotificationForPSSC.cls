//12/12/2013    Naresh Kumar
//
//18Sep2019    Nik Mills: Added capture and tracking of Rejected Order items as requested by PS CAS team

public with sharing class SendEmailNotificationForPSSC {

    public static void sendEmailAlert(List<ContractLineItem> contractLineItems, Boolean isUpdate){
        /*
        Set<Id> contractLineItemsIds = new Set<Id>();
        Set<Id> scId = new Set<Id>();       
        for(ContractLineItem eachCLI : contractLineItems){
            contractLineItemsIds.add(eachCLI.id);           
        }
        List<ContractLineItem> freshCLIs = [SELECT Upgraded_Product_Name__c, ServiceContract.Name, Product_Description__c, 
            ServiceContract.Region__c, ServiceContract.Renewal_License__c, ServiceContract.Agreement_Status__c,
            Third_Party_Partner__c, Revised_Net_License_value__c, Annualized_Maintenance_Due__c,             
            ServiceContract.PS_Project_ID__c, ServiceContract.Solution_Name__c, PriceBookEntry.product2.Type__c, Previous_Line_Maintenance_Value__c,
            ServiceContract.Opportunity__r.RecordType.DeveloperName, ServiceContract.End_User_Name__r.Name, ServiceContract.Sold_To_Name__r.Name,
            ServiceContract.StartDate, ServiceContract.EndDate, ServiceContract.Maintenance_Amount__c, Current_Maintenance_Rate__c,
            Project_ID__c, Solution_Name__c, App_Support_Rate__c, Sales_Order__c, Original_PO__c,
            ServiceContract.CurrencyIsoCode, ServiceContract.Order__r.Net_Suite_Order__c, ServiceContract.Order__r.PO_Number__c,
            Upd_Project_Id__c,Upd_Solution_Name__c,
            PriceBookEntry.Product2.PS_Contract__c
            FROM ContractLineItem WHERE id IN : contractLineItemsIds AND ServiceContract.Order__r.Status__c = 'Completed'];  
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(ContractLineItem eachCLI : freshCLIs){
            if(eachCLI.PriceBookEntry.product2.Type__c == null || (eachCLI.PriceBookEntry.product2.Type__c != 'PS-Contract' &&
                eachCLI.PriceBookEntry.Product2.PS_Contract__c == false)
                || scId.contains(eachCLI.serviceContractId))
                continue;
            scId.add(eachCLI.serviceContractId);                
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {};
            String region = eachCLI.ServiceContract.Region__c;
            String oppRecordType = eachCLI.ServiceContract.Opportunity__r.RecordType.DeveloperName;
            Integer term = 0;
            if(eachCLI.ServiceContract.StartDate != null && eachCLI.ServiceContract.EndDate != null)
                term = eachCLI.ServiceContract.StartDate.monthsBetween(eachCLI.ServiceContract.EndDate) + 1;
            Double amount = eachCLI.ServiceContract.Maintenance_Amount__c;
            amount = Math.round(amount);
            
            if(region == 'North America'){
                toAddresses.add('PSNAApplicationSupportNotification@genesyslab.com');
            }
            else if(region == 'APAC'){
                toAddresses.add('PSAPACApplicationSupportNotification@genesyslab.com');
            }
            else if(region == 'EMEA'){
                toAddresses.add('PSEMEAApplicationSupportNotification@genesyslab.com');
            }
            else if(region == 'LATAM'){
                toAddresses.add('PSLATAMApplicationSupportNotification@genesyslab.com');
            }
            //toAddresses.clear();
            //toAddresses.add('nareshk.it@gmail.com');
            //toAddresses.add('vikram.sharma@genesyslab.com');          
            mail.setToAddresses(toAddresses);
            if(isUpdate)
                mail.setSubject('Service Contact Updated - ' + eachCLI.ServiceContract.Name);
            else
                mail.setSubject('New Service Contact - ' + eachCLI.ServiceContract.Name);
            
            List<OrgWideEmailAddress> orgAdd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName =: 'Genesys Customer Care' OR DisplayName =: 'Customer Care'];
            if(!orgAdd.isEmpty()){
                mail.setOrgWideEmailAddressId(orgAdd[0].id);
            }   
            String htmlBody = ''; 
            htmlBody += 'Hi, <br/><br/>';
            htmlBody += 'Please find the service contract details below <br/><br/>';
            htmlBody += '<table style="font-family: verdana,arial,sans-serif;font-size:12px;color:#333333;border-width:1px;border-color:#666666;border-collapse: collapse;">';
            htmlBody += '<tr><th colspan="2"  style="border-width:1px;padding:4px;border-style:solid;border-color: #666666;background-color: #dedede;">Service Contract Details</th></tr>';
            htmlBody += '<tr><td width="200px" style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Service Contract </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;"> <a href=\' '+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + eachCLI.ServiceContract.id +'\'>' +  eachCLI.ServiceContract.Name + '</a></td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Product </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachCLI.Product_Description__c + '</td></tr>';          
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Region </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + region + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Project ID </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachCLI.Upd_Project_Id__c == null ? '' : eachCLI.Upd_Project_Id__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Support Type </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (oppRecordType == 'Genesys_Renewal' ? 'Renewal' : 'New') + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Service Contract Status </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachCLI.ServiceContract.Agreement_Status__c + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Customer Name </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachCLI.ServiceContract.Sold_To_Name__r.Name + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">End User </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachCLI.ServiceContract.End_User_Name__r.Name + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Solution Name  </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachCLI.Upd_Solution_Name__c == null ? '' : eachCLI.Upd_Solution_Name__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Third Party Partner </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachCLI.Third_Party_Partner__c == null ? '' : eachCLI.Third_Party_Partner__c) + '</td></tr>';         
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Start Date </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachCLI.ServiceContract.StartDate + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Term Duration </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + term + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">End Date </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachCLI.ServiceContract.EndDate + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Revised Net License Value </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachCLI.Revised_Net_License_value__c == null ? 0.00 : eachCLI.Revised_Net_License_value__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Maintenance Due </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachCLI.Annualized_Maintenance_Due__c == null ? 0.00 : eachCLI.Annualized_Maintenance_Due__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Annualized Maintenance Due </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachCLI.Previous_Line_Maintenance_Value__c == null ? 0.00 : eachCLI.Previous_Line_Maintenance_Value__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Currency </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachCLI.ServiceContract.currencyISOCode + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">App Support Rate </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachCLI.App_support_Rate__c == null ? 0.00 : (eachCLI.App_Support_Rate__c).setScale(2)) + '%</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">SO # </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachCLI.ServiceContract.Order__r.Net_Suite_Order__c == null ? '' : eachCLI.ServiceContract.Order__r.Net_Suite_Order__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">PO #</td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachCLI.ServiceContract.Order__r.PO_Number__c == null ? '' : eachCLI.ServiceContract.Order__r.PO_Number__c) + '</td></tr>';           
            htmlBody += '</table><br/><br/>Thanks';
            mail.setHtmlBody(htmlBody);
            mails.add(mail);
        }
        */
        //Messaging.sendEmail(mails);
    }
    
    public static void sendEmailAlert(List<Order__c> orders, Map<Id, Order__c> oldMap, Boolean isUpdate){
        
        
        Set<Id> orderLineItemsIds = new Set<Id>();
        Set<Id> orderId = new Set<Id>(); 
        Set<Id> rejectedOrderId = new Set<Id>();
        for(Order__c eachOrder : orders){
            if((eachOrder.Status__c == 'Completed' || eachOrder.Status__c == 'Approved') 
                && (oldMap == null || eachOrder.Status__c != oldMap.get(eachOrder.id).Status__c ))
            {
                orderId.add(eachOrder.id);
            }
            if((eachOrder.Status__c == 'Rejected') && (oldMap == null || eachOrder.Status__c != oldMap.get(eachOrder.id).Status__c ))
            {
                rejectedOrderId.add(eachOrder.id);           
            }
        }
        //Anju Sept 2018 Skipping function call if set is empty, as part of handling too many SOQL issue
        if(orderId.size() > 0)
        {
            prepareAndSendEmail(orderId, isUpdate, false);
        }
        if(rejectedOrderId.size() > 0)
        {
            prepareAndSendEmail(rejectedOrderId, isUpdate, true);
        }
    }
    
    public static void prepareAndSendEmail(Set<Id> orderId, Boolean isUpdate, Boolean isRejection){
        List<Order_Line_Item__c> freshOrderLineItems = [SELECT Product_Name__c, Order__r.Name, Product__r.Description__c, 
            Order__r.Region__c, 
            //ServiceContract.Renewal_License__c, ServiceContract.Agreement_Status__c, 
            Third_Party_Partners__c, Revised_Net_License_Value__c, Annualized_Maintenance_Due__c, Project_ID__c,  
            //ServiceContract.PS_Project_ID__c,
            Solution_Names_Covered1__c, App_Support_Rate__c,
            Product__r.Type__c, Order__r.Previous_Line_Maintenance_Value__c,
            Order__r.Opportunity__r.RecordType.DeveloperName, Order__r.End_User_Name__r.Name, Order__r.Sold_To_Name__r.Name,
            Previous_Line_Maintenance_Value_Formula__c, Maintenance_No_of_Months_Formula__c,Maintenance_Due__c,Annualized_Maintenance_Due_Formula__c,Maintenance_Due_formula__C,Maintenance_Start_Date__c, Maintenance_End_Date__c, Order__r.Maintenance_Start__c, Order__r.Maintenance_End__c,
            Order__r.Maintenance_Amount__c, Genesys_Care_Rate__c,Service_Contract_Line_ID__c,Solution_Names_Covered1_Formula__c,Project_ID_Formula__c,Support_Type_Formula__c,
          //Project_ID__c, Solution_Name__c, App_Support_Rate__c, 
            Sales_Order__c, Original_PO__c,
            Order__r.CurrencyIsoCode, Order__r.Net_Suite_Order__c, Order__r.PO_Number__c, Project_Name__c, 
            Order__r.Reject_Reasons__c, Order__r.Reject_Details__c, Order__r.Date_Rejected__c,
            //Upd_Project_Id__c,Upd_Solution_Name__c,
            Product__r.PS_Contract__c, Order__r.status__c,Maintenance_No_of_Months__c, Product__r.APN_Number__c, Contract_Line_Item__r.CX_Platform__c 
            FROM Order_Line_Item__c WHERE Order__c IN : orderId];  
        orderId.clear();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String notifyMessageType;
        if (isRejection)
        {
            notifyMessageType = 'Rejection';
        }
        else
        {
            notifyMessageType = 'New/Renewal';
        }
        
        System.Debug('>>>>NikM: DEBUG: Send Email Notification for PSSC / CAS to address. Got Order Line Details. Message Type is ' + notifyMessageType);
        
        for(Order_Line_Item__c eachOLI : freshOrderLineItems){
            System.Debug('>>>>NikM: DEBUG: Send Email Notification for PSSC / CAS to address. Checking OLI details (Product Type: ' + eachOLI.Product__r.Type__c + ', PS_Contract: ' + eachOLI.Product__r.PS_Contract__c + ', Order Ref: ' + eachOLI.Order__c + ')');

            if(!Test.isRunningTest() && (eachOLI.Product__r.Type__c == null || (eachOLI.Product__r.Type__c != 'PS-Contract' &&
                eachOLI.Product__r.PS_Contract__c == false)
                || orderId.contains(eachOLI.Order__c)))
                continue;
            orderId.add(eachOLI.Order__c);

            System.Debug('>>>>NikM: DEBUG: Send Email Notification for PSSC / CAS to address. Building Message');
                
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {};
            String[] bccAddresses = new String[] {};
            String region = eachOLI.Order__r.Region__c;
            String oppRecordType = eachOLI.Order__r.Opportunity__r.RecordType.DeveloperName;
            Integer term = 0;
            if(eachOLI.Order__r.Maintenance_Start__c != null && eachOLI.Order__r.Maintenance_End__c != null)
                term = eachOLI.Order__r.Maintenance_Start__c.monthsBetween(eachOLI.Order__r.Maintenance_End__c) + 1;
            Double amount = eachOLI.Order__r.Maintenance_Amount__c;
            if(amount != null)
                amount = Math.round(amount);
            
            List<String> bccAddressesLabel = Label.PS_Order_Notification_Recipients_BCC.split(',');
            if (bccAddressesLabel.size() > 0)
            {
                for (Integer count=0; count < bccAddressesLabel.size(); count++)
                {
                    bccAddresses.add(bccAddressesLabel[count]);
                }
                mail.setBccAddresses(bccAddresses);
            }
            
            if (!isRejection)
            {
                List<String> eachEmailAddress = Label.PS_Order_Notification_Recipients.split(',');
                
                if(region == 'North America'){
                    toAddresses.add(eachEmailAddress[0]);
                }
                else if(region == 'APAC'){
                    toAddresses.add(eachEmailAddress[1]);
                }
                else if(region == 'EMEA'){
                    toAddresses.add(eachEmailAddress[2]);
                }
                else if(region == 'LATAM'){
                    toAddresses.add(eachEmailAddress[3]);
                }            

                String subjectLine = region + ' - ' + eachOLI.Order__r.Name + ' ' + eachOLI.Order__r.Status__c + ' for ' + eachOLI.Order__r.Sold_To_Name__r.Name + ' / ' + eachOLI.Order__r.End_User_Name__r.Name + ' (' + eachOLI.Support_Type_Formula__c  + ')';
                mail.setToAddresses(toAddresses);
                if(isUpdate)
                    mail.setSubject('Order Updated - ' + subjectLine);
                else
                    mail.setSubject('New Order - ' + subjectLine);
    
                mail.setOrgWideEmailAddressId(Label.Customer_Care_OrgWideEmailAddressId);
            }
            else
            {
                List<String> eachEmailAddress = Label.PS_CAS_Rejection_Email_Address.split(',');
                
                toAddresses.add(eachEmailAddress[0]);
                if (eachEmailAddress.size() > 1)
                {
                    toAddresses.add(eachEmailAddress[1]);
                }
            
                String subjectLine = region + ' - ' + eachOLI.Order__r.Name + ' ' + eachOLI.Order__r.Status__c + ' for ' + eachOLI.Order__r.Sold_To_Name__r.Name + ' / ' + eachOLI.Order__r.End_User_Name__r.Name + ' (' + eachOLI.Support_Type_Formula__c  + ')';
                mail.setToAddresses(toAddresses);
                mail.setSubject('CAS Order Rejected - ' + subjectLine);
    
                mail.setOrgWideEmailAddressId(Label.Salesforce_NoReply_Email);            
            }
            
            
            String htmlBody = ''; 
            htmlBody += 'Hi, <br/><br/>';
            htmlBody += 'Please find the order details below <br/><br/>';
            htmlBody += '<table style="font-family: verdana,arial,sans-serif;font-size:12px;color:#333333;border-width:1px;border-color:#666666;border-collapse: collapse;">';
            htmlBody += '<tr><th colspan="2"  style="border-width:1px;padding:4px;border-style:solid;border-color: #666666;background-color: #dedede;">Order Details - ' + eachOLI.Order__r.Name + ' </th></tr>';
            htmlBody += '<tr><td width="200px" style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Order  </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;"> <a href=\' '+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + eachOLI.Order__r.id +'\'>' +  eachOLI.Order__r.Name + '</a></td></tr>';
            if (isRejection)
            {
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Rejection Reasons </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Order__r.Reject_Reasons__c + '</td></tr>';          
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Rejection Details </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Order__r.Reject_Details__c + '</td></tr>';
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Rejection Date </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Order__r.Date_Rejected__c + '</td></tr>';            
            }
            if (eachOLI.Contract_Line_Item__r.CX_Platform__c == null || eachOLI.Contract_Line_Item__r.CX_Platform__c.equals(''))
            {
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffe4e1;">CX Platform </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;"></td></tr>';
            }
            else
            {
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">CX Platform </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Contract_Line_Item__r.CX_Platform__c + '</td></tr>';
            }
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Product </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Product__r.Description__c + '</td></tr>';          
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">APN </td> <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Product__r.APN_Number__c + '</td></tr>';
            if(region == null || region.equals(''))
            {
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffe4e1;">Region </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;"></td></tr>';
            }
            else
            {
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Region </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + region + '</td></tr>';
            }
            if(eachOLI.Project_ID_Formula__c == null || eachOLI.Project_ID_Formula__c.equals(''))
            {
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffe4e1;">Project ID </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;"></td></tr>';
            }
            else
            {
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Project ID </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Project_ID_Formula__c + '</td></tr>';
            }
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Support Type </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + ((eachOLI.Support_Type_Formula__c)) + '</td></tr>';
            //htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Service Contract Status </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Order__r.Agreement_Status__c + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Customer Name </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Order__r.Sold_To_Name__r.Name + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">End User </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Order__r.End_User_Name__r.Name + '</td></tr>';
            if(eachOLI.Solution_Names_Covered1_Formula__c == null || eachOLI.Solution_Names_Covered1_Formula__c.equals(''))
            {
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffe4e1;">Solution Name  </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;"></td></tr>';
            }
            else
            {
                htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Solution Name  </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' +  eachOLI.Solution_Names_Covered1_Formula__c + '</td></tr>';
            }
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Third Party Partner </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachOLI.Third_Party_Partners__c == null ? '' : eachOLI.Third_Party_Partners__c) + '</td></tr>';         
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Start Date </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Maintenance_Start_Date__c + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Term Duration </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Maintenance_No_of_Months_Formula__c + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">End Date </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Maintenance_End_Date__c + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Revised Net License Value </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachOLI.Revised_Net_License_value__c == null ? 0.00 : eachOLI.Revised_Net_License_value__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Annualized Maintenance Due </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachOLI.Annualized_Maintenance_Due__c == null ? 0.00 : eachOLI.Annualized_Maintenance_Due_Formula__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Maintenance Due </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachOLI.Maintenance_Due__c == null ? 0.00 : eachOLI.Maintenance_Due_formula__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">Currency </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + eachOLI.Order__r.currencyISOCode + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">App Support Rate </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachOLI.App_support_Rate__c == null ? 0.00 : eachOLI.App_Support_Rate__c) + '%</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">SO # </td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachOLI.Order__r.Net_Suite_Order__c == null ? '' : eachOLI.Order__r.Net_Suite_Order__c) + '</td></tr>';
            htmlBody += '<tr><td style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">PO #</td>  <td  style="border-width: 1px;padding:4px;border-style:solid;border-color: #666666;background-color: #ffffff;">' + (eachOLI.Order__r.PO_Number__c == null ? '' : eachOLI.Order__r.PO_Number__c) + '</td></tr>';           
            htmlBody += '</table><br/><br/>Thanks';
            mail.setHtmlBody(htmlBody);
            mails.add(mail);
        }
        if(!mails.isEmpty())
            Messaging.sendEmail(mails);
    }
}