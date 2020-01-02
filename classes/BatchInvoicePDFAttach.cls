global class BatchInvoicePDFAttach implements Database.Batchable<SObject>,Database.Stateful,Database.AllowsCallouts
    {
        // Session Id of Running User
        //public final String strSessionId;
        // Month for which Invoices are to be processed
        public final String strMonth;
        // Year for which Invoices are to be processed
        public final String strYear;
        // Contract Id (Optional) : To specify individual contract for which invoice needs to be processed
        public final String strContractId;
        // Name of subsidiary chosen to run job by subsidiary
        public final String strSubsidiary;
        // iTracks 22567
        // Run particular region option in Admin Tab
        public String strRegion {get; set;}
        // iTracks 29871
        // // Run particular Edition option in Admin Tab
        public String strEdition {get; set;}
        // Log Record for this job
        public Cloud_Billing_Log__c objJobLog;
        // iTracks 29871
        // Only used for calling the debug method
        private CloudBillingData objInfo;
    
        // List of invoices to update with billing address email ids
        List<Invoice__c> list_InvoicesToUpdate = new List<Invoice__c>();
        
        // *** constructor ***
        // iTracks 29871
        public BatchInvoicePDFAttach(CloudBillingData info) {
            strMonth = info.month;
            strYear = info.year;
            strSubsidiary = info.subsidiary;
            strContractId = info.contractId;
            strRegion = info.region;
            strEdition = info.edition;
            objInfo = info;
        }
    
        // *** Start Method : Querying Invoice records with 'Invoice Attached' status  and Order Status 'Completed' for Cloud billing Orders of specified month/year ***
        global Database.QueryLocator start(Database.BatchableContext BC) 
        {
            if(objJobLog == null) {
                System.Debug('Create New Job Log');
                objJobLog = CloudBillingUtil.createNewCloudBillingLog('Monthly Invoice Creation', 'Submitted');
            } else {
                System.Debug('Existing Job Log ' + objJobLog);
            }
    
            String strSOQL = 'SELECT Id,Order__c,Order__r.End_User_Name__r.Name,Order__r.Month__c,Order__r.Year__c,Order__r.Contract_Lookup__c'

                            + ' FROM Invoice__c WHERE Status__c = null AND Order__r.Status__c = \'Completed\' AND Order__r.Month__c = :strMonth '
                            + 'AND  Order__r.Year__c = :strYear AND Order__r.RecordTypeId = \'' + Label.Cloud_Monthly_Order_RecordTypeId + '\'';
            
            if(String.isNotBlank(strContractId))
                strSOQL += ' AND Order__r.Contract_Lookup__c = :strContractId';
            
            if(String.isNotBlank(strSubsidiary) && strSubsidiary != 'All')
                strSOQL += ' AND Order__r.Subsidaries__r.Name = :strSubsidiary';
    
            if(String.isNotBlank(strRegion) && strRegion != 'All')
                strSOQL += ' AND Order__r.Contract_Lookup__r.Account_Name__r.Country__r.Region__c = :strRegion';
    
            if(String.isNotBlank(strEdition) && strEdition != 'All')
            {
                strSOQL += ' AND (Order__r.Contract_Lookup__r.Product_Group__c = :strEdition';

                if(strEdition == 'PureCloud' || strEdition == 'PureConnect')
                    strSOQL += ' OR Order__r.Sales_Org__c = :strEdition)';
                else
                    strSOQL += ')';
            }           
            System.debug('strSOQL ' + strSOQL);
            return Database.getQueryLocator(strSOQL);
        }
    
        // *** Execute Method : Processing invoice records to automatically attach invoice pdf files to them and 
        //      populate billing address emails (default batch size = 200) ***
        global void execute(Database.BatchableContext BC,List<SObject> sObjects)
        {
            objInfo.debug();
            // Storing Invoice records to be processed in current batch
            List<Invoice__c> list_BatchInvoices = (List<Invoice__c>)sObjects;
            // Set of Order Ids from Invoices in current batch
            Set<Id> set_OrderIds = new Set<Id>();
            // Set of Contract Ids from Invoices in current batch
            Set<Id> set_ContractIds = new Set<Id>();
            // Map of Order Id To Billing Address
            Map<Id,Account_Order_Address__c> map_OrderIdToBillingAddress = new Map<Id,Account_Order_Address__c>();
            // Map of Contract Id To Billing Address
            //Map<Id,Account_Order_Address__c> map_ContractIdToBillingAddress = new Map<Id,Account_Order_Address__c>();
            
            list_InvoicesToUpdate.addAll(list_BatchInvoices);
                
            // Populating set of Order Ids
            for(Invoice__c objInvoice : list_BatchInvoices){
                set_OrderIds.add(objInvoice.Order__c);
                set_ContractIds.add(objInvoice.Order__r.Contract_Lookup__c);
            }
                   
            // Populating map of Order Id To Billing Address
            // iTracks 26037
            for(Account_Order_Address__c objBillingAddress : [SELECT Id, Order__c,Email__c,Additional_Emails__c,GCR_Content_Document_Detail__c FROM Account_Order_Address__c 
                                                              WHERE Order__c IN :set_OrderIds AND Address_Type__c = 'Bill To']) {
                                                                  System.Debug('Put Address ' + objBillingAddress);
                                                                  map_OrderIdToBillingAddress.put(objBillingAddress.Order__c,objBillingAddress);
                                                                  //map_ContractIdToBillingAddress.put(objBillingAddress.GCR_Content_Document_Detail__c,objBillingAddress);
                                                              }
            
            // Populating Emails ids from Billing Address into Invoice
            for(Invoice__c objInvoice : list_BatchInvoices)
            {
                if(map_OrderIdToBillingAddress.containsKey(objInvoice.Order__c))
                //if(map_ContractIdToBillingAddress.containsKey(objInvoice.Order__r.Contract_Lookup__c))
                {
                    Account_Order_Address__c objBillingAddress = map_OrderIdToBillingAddress.get(objInvoice.Order__c);
                    //Account_Order_Address__c objBillingAddress = map_ContractIdToBillingAddress.get(objInvoice.Order__r.Contract_Lookup__c);
                    // String of email ids separated with semi colons ';'
                    String strEmails = '';
                    
                    if(String.isNotBlank(objBillingAddress.Email__c))
                        strEmails += objBillingAddress.Email__c + ';';
                    
                    if(String.isNotBlank(objBillingAddress.Additional_Emails__c))
                        strEmails += objBillingAddress.Additional_Emails__c;
    
                    System.Debug('Add all emails ' + strEmails);                
                    // Populating email ids on email fields
                    if(String.isNotBlank(strEmails))
                    {
                        List<String> list_EmailIds = strEmails.split(';');
                        for( Integer i=0 ; i < 10 && i < list_EmailIds.size() ; i++)
                            objInvoice.put('Email' + String.valueOf(i+1) + '__c',list_EmailIds[i]);
                    }
                }
               
                // Generating pdf using visualforce : passing invoice id to page
                PageReference pdfPage;

                if(strEdition == 'PureCloud')
                    pdfPage = new PageReference('/apex/CloudInvoicePdfTemp');
                else if (strEdition == 'PureConnect')
                    pdfPage = new PageReference('/apex/CloudInvoicePdfPCC');
                else
                    pdfPage = new PageReference('/apex/CloudInvoicePdf');
    


                pdfPage.getParameters().put('id',objInvoice.Id);
                
                Attachment objPDF = new Attachment();
                objPDF.Name = objInvoice.Order__r.End_User_Name__r.Name + '-' + objInvoice.Order__r.Month__c + '-' + objInvoice.Order__r.Year__c + '.pdf';
                objPDF.ParentId = objInvoice.Id;
                // Added by Vijay  - 31st Jul 2017 - Start 
                // Reference - Test Won't support getContent methods. So, added logic to skip getContentAsPDF()
                if(Test.isRunningTest()){
                    objPDF.Body = Blob.toPdf('Test Content'); 
                }else{
                    objPDF.Body = pdfPage.getContentAsPdf();
                }
                // Added by Vijay  - 31st Jul 2017 - End
                objPDF.Description = 'Monthly Billing Sales Order';
                objPDF.ContentType  = 'application/pdf'; 
                // Insert PDF attachment        
                insert objPDF;
                
                // Update Invoice status to indicate that pdf has been attached
                objInvoice.Status__c = 'Invoice Attached';
            }
            
            /* Obsolete code : getContentAsPdf() will be treated as a callout    
            // Invoke invoice pdf generation and attachment rest service
            for(Invoice__c objInvoice : list_BatchInvoices)
                AttachInvoicePDFService.attachPdfToInvoice(objInvoice.Id,strSessionId);*/
        }
    
        // *** Finish Method : Exception notifications and other final code ***
        global void finish(Database.BatchableContext bc)
        {
            // Insert/Update Log record
            if(objJobLog != null) {
                objJobLog.Status__c = 'Completed';
                upsert objJobLog;
            }

            Set<Id> setInvoicesToDeleteAttachments = new Set<Id>();
            // Updating Invoices
            Boolean blnErrorOccurred = false;
            if(!list_InvoicesToUpdate.isEmpty()) {
                List<Invoice__c> list_FailedInvoices = new List<Invoice__c>();
                String strExceptions = '';
                //update list_InvoicesToUpdate;
                Database.saveResult[] saveResults = Database.update(list_InvoicesToUpdate,false);
                for(Integer i = 0; i < saveResults.size(); i++)
                {
                    //get the save result
                    Database.saveResult sr = saveResults[i];
                    if(!sr.isSuccess())// if the save was not successfull
                    {
                        Invoice__c objInvoice = list_InvoicesToUpdate[i];
                        setInvoicesToDeleteAttachments.add(objInvoice.Id);
                        strExceptions += 'Order ' + objInvoice.Order__c;
						Boolean blnFirstMessageThisError = true;
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error' + err.getStatusCode() + ': ' + err.getMessage());
                            if (!blnFirstMessageThisError) {
                                strExceptions += ',';
                            }
                            strExceptions += ' ' + err.getMessage();
                            blnFirstMessageThisError = false;
                        }
                        if (blnErrorOccurred) {
                            objJobLog.Exceptions__c += '; ' + strExceptions;
                        } else {
                        	objJobLog.Exceptions__c = strExceptions;
                        }
                        blnErrorOccurred = true;
                    }
                }
                if (blnErrorOccurred) {
                    System.Debug('Attempt to find attachments for invoices for parents ' + setInvoicesToDeleteAttachments);
                    List<Attachment> listAttachmentsToDelete = [select Id, Name from Attachment where ParentId in :setInvoicesToDeleteAttachments];
                    for (Attachment objAttachment : listAttachmentsToDelete) {
                        System.Debug('Deleting Attachment to Invoice ' + objAttachment);
                    }
                    delete listAttachmentsToDelete;
                    objJobLog.Status__c = 'Failure';
                    upsert objJobLog;
                }
            }
            
            // Process End Notifications etc.
        }
    }