public class OnBoardingAndOfferingType {
    public static void OnBoarding(Opportunity newOpp, Opportunity oldOpp, boolean isInsert) {
    Boolean blnExecuteMethod = false;
        //Naresh Kumar  11/14/2017  We need to execute the method code only when opportunity meets below conditions. It is firing unnecessary DMLs and causing 101 SQOL Exception. 
        if(Trigger.isInsert || newOpp.StageName != oldOpp.StageName || newOpp.ForecastStatus__c != oldOpp.ForecastStatus__c  || newOpp.Forecast_Status__c != oldOpp.Forecast_Status__c  || newOpp.Win_Loss_Status__c  != oldOpp.Win_Loss_Status__c ){
          blnExecuteMethod = true;
        }  
        if(!blnExecuteMethod)
          return;
        
        Opportunity objOp = [Select id, name, recordtype.name, ForecastStatus__c, Forecast_Status__c, Lines_of_Businesses__c, Primary_Line_of_Business__c, AccountId, StageName, Win_Loss_Status__c, BusinessPartner__c, Account.Status__c, Account.recordtype.name, Account.type, Offering_Detail__c, Type from Opportunity where id =: newOpp.id];

        Account objSoldTo = new account();
        Account objMainAcc = new Account();

        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMG - Customer Record Type').getRecordTypeId();

        list < Account > lstAcc = [Select id, Status__c, Type, RecordTypeid from Account where id =: objOp.AccountId];
        if (lstAcc.size() > 0)
            objMainAcc = lstAcc[0];
        try {
            if (objOp.BusinessPartner__c != null)
                objSoldTo = [Select id, IsDirect__c, Street1__c, Street2__c, Street3__c, ZipCode__c, City__c, StateProvince__c, Country__r.name from Account where id =: objOp.BusinessPartner__c];
            //else
            //  objSoldTo = [Select id,IsDirect__c,Street1__c,Street2__c,Street3__c,ZipCode__c,City__c,StateProvince__c,Country__r.name from Account where id =: objOp.AccountId];  

            if (Trigger.isInsert || newOpp.StageName != oldOpp.StageName || newOpp.ForecastStatus__c != oldOpp.ForecastStatus__c || newOpp.Forecast_Status__c != oldOpp.Forecast_Status__c || newOpp.Win_Loss_Status__c != oldOpp.Win_Loss_Status__c) {
                //if(objOp.StageName == '6.Closed' && objOp.Win_Loss_Status__c == 'Won' && objOp.Account.Status__c == 'Active' && objOp.Account.recordtype.name == 'EMG - Customer Record Type' && objOp.Account.type == 'Customer' && objSoldTo.IsDirect__c == true)
                //Customer record type should be 'EMG – Customer Record Type' or 'EMG - Prospect Record Type', requested by Jake on 10/18/2017 after PROD Deployment

                //if(objOp.StageName == '6.Closed' && objOp.Win_Loss_Status__c == 'Won' && objOp.ForecastStatus__c == '0.Booked' && (objOp.Account.recordtype.name == 'EMG - Customer Record Type' || objOp.Account.recordtype.name == 'EMG - Prospect Record Type'))
                //Changes requested by Jake on 11/06/2017 to include 1.In Hand as Forecast Status and three Opp Records Types
                //Record Types conditions to proceed further added on 11/09/2017 by Jitendra as Jake sent more conditions
                boolean isProceed = false;
                system.debug('+++objOp.recordtype.name+++' + objOp.recordtype.name);
                system.debug('+++objOp.Forecast_Status__c+++' + objOp.Forecast_Status__c);


                if (objOp.StageName == '6.Closed' && objOp.Win_Loss_Status__c == 'Won' && objOp.recordtype.name == 'PPU Usage Revenue Record Type' && objOp.ForecastStatus__c == '0.Booked')
                    isProceed = true;
                if (objOp.StageName == '5.Purchase Solution' && objOp.recordtype.name == 'PPU Usage Revenue Record Type' && objOp.ForecastStatus__c == '1.In Hand')
                    isProceed = true;
                if (objOp.StageName == '6.Closed' && objOp.Win_Loss_Status__c == 'Won' && objOp.recordtype.name == 'Professional Services' && (objOp.ForecastStatus__c == '0.Booked' || objOp.ForecastStatus__c == '1.In Hand'))
                    isProceed = true;
                if (objOp.recordtype.name == 'Genesys Renewal' && (objOp.Forecast_Status__c == 'Booked/ In Hand' || objOp.Forecast_Status__c == 'Booked In'))
                    isProceed = true;
                if (objOp.StageName == '6.Closed' && objOp.Win_Loss_Status__c == 'Won' && objOp.recordtype.name == 'GEN - Opportunity Record Type' && objOp.ForecastStatus__c == '0.Booked')
                    isProceed = true;
                if (objOp.StageName == '5.Purchase Solution' && objOp.recordtype.name == 'GEN - Opportunity Record Type' && objOp.ForecastStatus__c == '1.In Hand')
                    isProceed = true;


                //Old conditions are commented for reference
                //if(objOp.StageName == '6.Closed' && objOp.Win_Loss_Status__c == 'Won' && (objOp.ForecastStatus__c == '0.Booked' || objOp.ForecastStatus__c == '1.In Hand') && (objOp.Account.recordtype.name == 'EMG - Customer Record Type' || objOp.Account.recordtype.name == 'EMG - Prospect Record Type') && (objOp.recordtype.name == 'Professional Services' || objOp.recordtype.name == 'GEN - Opportunity Record Type'|| objOp.recordtype.name == 'PPU Usage Revenue Record Type'))
                if (isProceed == true && (objOp.Account.recordtype.name == 'EMG - Customer Record Type' || objOp.Account.recordtype.name == 'EMG - Prospect Record Type')) {
                    system.debug('##Enter for processing');
                    system.debug('+++objOp.BusinessPartner__c 66+++' + objOp.BusinessPartner__c);

                    //Update Account
                    objMainAcc.Status__c = 'Active';
                    objMainAcc.Type = 'Customer';
                    objMainAcc.RecordTypeid = RecordTypeId;


                    //Update Account
                    //Type also included as requested by Jake Fuller on 10/12/2017 - Jitendra
                    if (objOp.Offering_Detail__c == 'Pilot/Trial/POC' && objOp.Type == 'New logo')
                        objMainAcc.Status__c = 'New Logo Trial';
                    else
                        objMainAcc.Status__c = 'Active';

                    if (objOp.BusinessPartner__c == null)
                        objMainAcc.IsDirect__c = true;
                    else
                        objMainAcc.IsDirect__c = false;

                    //Add Address record on the basis of SOLD To field of Opportunity
                    if (objOp.BusinessPartner__c == null) {
                        List < Address__c > list_Address = new List < Address__c > ();
                        list_Address = [Select id, Type__c, Address_Type__c, Address_Line_1__c, Address_Line_2__c, Address_line_3__c, City__c, State__c, Province__c, Country__c, Zipcode__c, Addressee__c, Attention__c, Address_Name__c, Active_Status__c, Is_Inactive__c, Is_Primary__c from Address__c where Type__c =: 'Corporate'
                            and Account__c =: objMainAcc.id Order by createddate desc limit 1
                        ];
                        if (list_Address != null && list_Address.size() > 0) {
                            Address__c objAddress = new Address__c();
                            objAddress.Address_Line_1__c = list_Address[0].Address_Line_1__c;
                            objAddress.Address_Line_2__c = list_Address[0].Address_Line_2__c;
                            objAddress.Address_line_3__c = list_Address[0].Address_line_3__c;
                            objAddress.Zipcode__c = list_Address[0].Zipcode__c;
                            objAddress.City__c = list_Address[0].City__c;
                            objAddress.State__c = list_Address[0].State__c;
                            objAddress.Country__c = list_Address[0].Country__c;
                            objAddress.Province__c = list_Address[0].Province__c;
                            objAddress.Addressee__c = list_Address[0].Addressee__c;
                            objAddress.Attention__c = list_Address[0].Attention__c;
                            objAddress.Address_Name__c = list_Address[0].Address_Name__c;
                            objAddress.Type__c = 'Sold To';
                            objAddress.Address_Type__c = 'Sold To';
                            objAddress.Active_Status__c = true;
                            objAddress.Is_Primary__c = true;
                            objAddress.Account__c = objMainAcc.id;
                            insert objAddress;
                        }

                    } else {
                        List < Address__c > list_Address = new List < Address__c > ();
                        list_Address = [Select id, Type__c, Address_Type__c, Address_Line_1__c, Address_Line_2__c, Address_line_3__c, City__c, State__c, Province__c, Country__c, Zipcode__c, Addressee__c, Attention__c, Address_Name__c, Active_Status__c, Is_Inactive__c, Is_Primary__c from Address__c where Type__c =: 'Corporate'
                            and Account__c =: objOp.BusinessPartner__c Order by createddate desc limit 1
                        ];
                        if (list_Address != null && list_Address.size() > 0) {
                            Address__c objAddress = new Address__c();
                            objAddress.Address_Line_1__c = list_Address[0].Address_Line_1__c;
                            objAddress.Address_Line_2__c = list_Address[0].Address_Line_2__c;
                            objAddress.Address_line_3__c = list_Address[0].Address_line_3__c;
                            objAddress.Zipcode__c = list_Address[0].Zipcode__c;
                            objAddress.City__c = list_Address[0].City__c;
                            objAddress.State__c = list_Address[0].State__c;
                            objAddress.Country__c = list_Address[0].Country__c;
                            objAddress.Province__c = list_Address[0].Province__c;
                            objAddress.Addressee__c = list_Address[0].Addressee__c;
                            objAddress.Attention__c = list_Address[0].Attention__c;
                            objAddress.Address_Name__c = list_Address[0].Address_Name__c;
                            objAddress.Type__c = 'End User';
                            objAddress.Address_Type__c = 'End User';
                            objAddress.Active_Status__c = true;
                            objAddress.Is_Primary__c = true;
                            objAddress.Account__c = objMainAcc.id;
                            insert objAddress;
                        }
                    }

                    objMainAcc.IsOnboarding__c = true;
                    objMainAcc.OnboardingDate__c = Date.Today();
                    update objMainAcc;
                    system.debug('+++objMainAcc 44+++' + objMainAcc);
                }
            }

            OfferingType(newOpp, oldOpp, objOp, isInsert);
        } catch (Exception ex) {
            system.debug('+++ex+++' + ex.getMessage());
            objMainAcc.IsErrorOnboarding__c = true;
            objMainAcc.OnboardingDate__c = Date.Today();
            update objMainAcc;

            string BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
            string sEmailBody, sSubject;
            List < string > lstEmail = new List < string > ();
            lstEmail.add('amit.singh@rsystems.com');

            sSubject = 'Error Occurred during Onboarding';
            sEmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5">';
            sEmailBody = sEmailBody + '<tr><td>Opportunity Name</td><td>Opportunity URL</td><td>Error Description</td></tr>';
            sEmailBody = sEmailBody + '<tr><td>' + objOp.name + '</td><td><a href="' + BaseURL + '/' + objOp.id + '">' + BaseURL + '/' + objOp.id + '</a></td><td>' + ex.getMessage() + '</td></tr>';
            sEmailBody = sEmailBody + '</table></body></html>';

            EmailNotification(sEmailBody, sSubject, lstEmail);
        }
    }

    public static void OfferingType(Opportunity newOpp, Opportunity oldOpp, Opportunity objOp, boolean isInsert) {
        try {
            // Offering,Platform Type and Offering Details implementation
            // Opportunity objOp = [Select id,Lines_of_Businesses__c,Primary_Line_of_Business__c,AccountId,StageName,Win_Loss_Status__c,BusinessPartner__c,Account.Status__c,Account.recordtype.name,Account.type,Offering_Detail__c  from Opportunity where id =: newOpp.id];
            //if(objOp.StageName == '6.Closed' && objOp.Win_Loss_Status__c == 'Won')
            if (isInsert || newOpp.StageName != oldOpp.StageName) {

                if (objOp.StageName == '6.Closed' && objOp.Win_Loss_Status__c == 'Won') {
                    system.debug('+++objOp.Lines_of_Businesses__c 99+++' + objOp.Lines_of_Businesses__c);

                    //Account objAcc = [select id,AccountOfferingType__c,AccountPlatformType__c,AccountOfferingTypes__c from Account where id=:objOp.AccountId];
                    Account objAcc = [select id from Account where id =: objOp.AccountId]; //, AccountOfferingTypes__c
                    set < string > list_AllCombination = new set < string > ();

                    string[] arrAccOfferingTypes = new string[] {};
                    /*if (objAcc.AccountOfferingTypes__c != null) {
                        arrAccOfferingTypes = objAcc.AccountOfferingTypes__c.split(',');
                    }*/
                    if (arrAccOfferingTypes.size() > 0) {
                        for (integer k = 0; k < arrAccOfferingTypes.size(); k++) {
                            list_AllCombination.add(arrAccOfferingTypes[k]);
                        }
                    }
                    system.debug('++++arrAccOfferingTypes ++++  ' + arrAccOfferingTypes);


                    //string[]arrOfferType;
                    //string sOfferType,sOfferingDetail;
                    string[] arrPlatformType = new string[] {};

                    string sAllCombination = '';


                    if (objOp.Primary_Line_of_Business__c != null) {
                        arrPlatformType = objOp.Primary_Line_of_Business__c.split(';');
                    }
                    /*if(objOp.Lines_of_Businesses__c != null)
                    {
                      //arrOfferType = objOp.Lines_of_Businesses__c.split(';');
                      sOfferType = objOp.Lines_of_Businesses__c;
                    }
                    if(objOp.Offering_Detail__c != null)
                    {
                       sOfferingDetail= objOp.Offering_Detail__c;
                    }*/
                    system.debug('++++arrPlatformType ++++  ' + arrPlatformType);


                    if (arrPlatformType != null) {
                        system.debug('++++arrPlatformType in stat++++  ');
                        system.debug('++++arrPlatformType.size()++++  ' + arrPlatformType.size());

                        for (integer i = 0; i < arrPlatformType.size(); i++) {

                            if (arrAccOfferingTypes.size() <= 0) {
                                if (sAllCombination == '')
                                    sAllCombination = arrPlatformType[i] + '-' + objOp.Lines_of_Businesses__c + '-' + (objOp.Offering_Detail__c != null ? objOp.Offering_Detail__c : 'None');
                                else
                                    sAllCombination = sAllCombination + ',' + arrPlatformType[i] + '-' + objOp.Lines_of_Businesses__c + '-' + (objOp.Offering_Detail__c != null ? objOp.Offering_Detail__c : 'None');
                            } else {
                                system.debug('++++arrAccOfferingTypes.size()++++  ' + arrAccOfferingTypes.size());

                                for (integer j = 0; j < arrAccOfferingTypes.size(); j++) {
                                    if (!list_AllCombination.contains(arrPlatformType[i] + '-' + objOp.Lines_of_Businesses__c + '-' + (objOp.Offering_Detail__c != null ? objOp.Offering_Detail__c : 'None'))) {
                                        if (sAllCombination == '')
                                            sAllCombination = arrPlatformType[i] + '-' + objOp.Lines_of_Businesses__c + '-' + (objOp.Offering_Detail__c != null ? objOp.Offering_Detail__c : 'None');
                                        else
                                            sAllCombination = sAllCombination + ',' + arrPlatformType[i] + '-' + objOp.Lines_of_Businesses__c + '-' + (objOp.Offering_Detail__c != null ? objOp.Offering_Detail__c : 'None');

                                        //list_AllCombination.add(arrPlatformType[i] + '-' + objOp.Lines_of_Businesses__c +  '-' + objOp.Offering_Detail__c); 
                                    }
                                }
                            }
                        }

                    }
                    system.debug('++++sAllCombination++++  ' + sAllCombination);
                    if (sAllCombination != '' && sAllCombination != null) {
                        /*if (objAcc.AccountOfferingTypes__c != null)
                            objAcc.AccountOfferingTypes__c += ',' + sAllCombination;
                        else
                            objAcc.AccountOfferingTypes__c = sAllCombination;*/
                        update objAcc;
                    }
                }
            }
        } catch (Exception ex) {

        }
    }


    public static void EmailNotification(string mailBody, string mailSubject, List < string > lstEmail) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = new String[lstEmail.size()];
        for (integer i = 0; i < lstEmail.size(); i++) {
            toAddresses[i] = lstEmail[i];
        }
        mail.setToAddresses(toAddresses);
        mail.setPlainTextBody(mailBody);
        mail.setHtmlBody(mailBody);
        mail.setSubject(mailSubject);
        if (!Test.isRunningTest())
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
            });
    }
}