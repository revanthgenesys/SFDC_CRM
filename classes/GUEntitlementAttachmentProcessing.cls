/***************************************************************************************************
* 
*  Class Name      :   GUEntitlementAttachmentProcessing 
*  Description     :   This class is used to process CSV file in Attachment
*  Auther          :   R Systems
* 
****************************************************************************************************/

global class GUEntitlementAttachmentProcessing implements Messaging.InboundEmailHandler 
{ 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        Messaging.InboundEmailResult objResult = new Messaging.InboundEmailResult();    
        try
        {   
            system.debug('#Enter1#');  
            if(email.binaryAttachments != null)
            {
               system.debug('#Enter2#');
               String[] Rows = new String[] {};
               
                for (Messaging.Inboundemail.BinaryAttachment binaryAttach : email.binaryAttachments) 
                {
                    
                    //HttpRequest tmp = new HttpRequest();
                    //tmp.setBodyAsBlob(EncodingUtil.base64Decode(Blob.valueOf(binaryAttach.body)));
                    
                    //string FileData = EncodingUtil.base64Encode(EncodingUtil.base64Decode(binaryAttach.body));
                    system.debug('#Enter3#'+binaryAttach );
                    //string FileData = binaryAttach.body.toString();
                    
                    
                    /****** For Reference *************/
                    /****** https://blog.enree.co/2013/01/salesforce-apex-post-mutipartform-data.html *****/
                    
                    Blob body = binaryAttach.body;
                    HttpRequest tmp = new HttpRequest();
                    tmp.setBodyAsBlob(body);
                    String FileData = tmp.getBody();
                    //System.debug('## Output body:'+bodyString );
                    
                    //string FileData = EncodingUtil.convertToHex(binaryAttach.body);
                    //Blob blobValue = EncodingUtil.convertToHex(binaryAttach.body);
                    //string FileData = string.valueof(blobValue);
                    
                    system.debug('#FileData #######  '+FileData );
                    system.debug('++++binaryAttach.fileName++++'+binaryAttach.fileName);
                    
                    if(binaryAttach.fileName == 'GUEntitlement_InProgress.csv')
                      ProcessFile(FileData,'In Progress'); 
                    if(binaryAttach.fileName == 'GUEntitlement_Completed.csv')
                        ProcessFile(FileData,'Completed');
                    if(binaryAttach.fileName == 'GUEntitlement_Cancelled.csv')  
                        ProcessFile(FileData,'Cancellation');
                }
            }
            objResult.success = true;
        }
        catch(Exception ex)
        {
          objResult.success = false;
          objResult.message = ex.getMessage();
          
          system.debug('#Enter4#'+ex);
          
          /************Send Error Notification ******************/
          EmailNotifications__c objEmail = EmailNotifications__c.getvalues('GU Entitlement Error Notification');
          String[] toAddresses = objEmail.Emails__c.split(';');
          system.debug('Error Occured##-'+ex.getMessage());
          EmailNotification(ex.getMessage(),'GU Entitlement Error Notification',toAddresses,'','' );
        }
        return objResult;
    }

    private void ProcessFile(string sFileData , string FileType)
    {
        String[] GUTraining = new String[] {};
           List<wrapTrainingCourseConsumption>list_WrapperInProgress = new List<wrapTrainingCourseConsumption>();
           
         system.debug('##Enter in ProcessFile##');       
        /************************************************** Get All Rows **********************************************/
            GUTraining = sFileData.split('\n');
            Set<string>set_accountId = new Set<string>();
            
        /***************************Iteration on CSV rows *******************************************/
            Set<string>set_OrderName = new Set<string>();
            Set<id>set_GUEnt = new Set<id>();
            Map<ID,wrapTrainingCourseConsumption>map_GU = new Map<ID,wrapTrainingCourseConsumption>();
            
            for (Integer i = 1; i < GUTraining.size(); i++) {
                
                wrapTrainingCourseConsumption obj = new wrapTrainingCourseConsumption(GUTraining[i]);
                
                /*************** for In-progress records ********************/
                if(obj.GUEntitlementID == null || obj.GUEntitlementID == '')                
                  list_WrapperInProgress.add(obj);
                else /******************* for Completed and Cancellation records *******************/
                {
                    set_GUEnt.add(obj.GUEntitlementID);
                    map_GU.put(obj.GUEntitlementID,obj);
                }

                /************** Get All Order from CSV file ***************************/
                if(!set_OrderName.contains(obj.OrderName))
                  set_OrderName.add(obj.OrderName);
            }
            system.debug('++++set_OrderName++++'+set_OrderName);
            system.debug('++++map_GU++++'+map_GU);
            system.debug('++++set_GUEnt++++'+set_GUEnt);
            
         if(FileType == 'In Progress')
         {           
            
            system.debug('##Enter in InProgress##');
            /************* for In progress records **************/
            if(list_WrapperInProgress != null && list_WrapperInProgress.size() >0)
                readCSVFileInProgress(list_WrapperInProgress,set_OrderName) ;
            
            /************** for Completed and Cancellation records ***************/
             //CompletedAndCancellation(set_GUEnt,map_GU, null);
         }
         if(FileType == 'Completed' || FileType == 'Cancellation')
         {
             CompletedAndCancellation(set_GUEnt,map_GU, FileType);
         }
    }

    private void readCSVFileInProgress(List<wrapTrainingCourseConsumption>list_WrapperInProgress,Set<string>set_OrderName) {
       try{
           
          
          system.debug('##Enter readCSVFile##');
          system.debug('++++list_WrapperInProgress++++'+list_WrapperInProgress);  
          system.debug('++++set_OrderName++++'+set_OrderName);  
            
         /***************************** Get the End Account ************************/
         Map<id,Order__c>map_OrderObj = new  Map<id,Order__c>([Select id,Name,End_User_Name__c from Order__c where name IN : set_OrderName]);
         //Map<id,GCR_Content_Document_Detail__c>map_ServiceContract = new  Map<id,GCR_Content_Document_Detail__c>([Select id,Name,Customer_Name__c from GCR_Content_Document_Detail__c where name IN : set_ServiceContractNumbers]);
         
         system.debug('++++map_OrderObj ++++'+map_OrderObj);
         
         Set<id>set_EndUsers = new Set<id>();
         for(ID scID : map_OrderObj.keyset())
         {
             Order__c objOrder = map_OrderObj.get(scID);
             //GCR_Content_Document_Detail__c objOrder = map_ServiceContract.get(scID);
             
             //if(!set_EndUsers.contains(objOrder.Customer_Name__c))
             //   set_EndUsers.add(objOrder.Customer_Name__c) ; 
             
             if(!set_EndUsers.contains(objOrder.End_User_Name__c ))
                set_EndUsers.add(objOrder.End_User_Name__c ) ; 
   
             system.debug('++++set_EndUsers++++'+set_EndUsers);
            
            /***************Update End User in wrapper class ********************/
             for(wrapTrainingCourseConsumption objW : list_WrapperInProgress)           
             {
                 if(objW.OrderName == objOrder.Name)
                 {
                     //objW.EndUser = objOrder.Customer_Name__c;
                     objW.EndUser = objOrder.End_User_Name__c;
                     objW.OrderId = objOrder.id;
                 } 
             }
         }
         
         /*************************** Check Order Name and End User in Token Allocation *******************************/
         List<Token_Allocations__c>list_TokenAllocation = [select id,Tokens_Available__c,Account__c,Order__c from Token_Allocations__c where Order__r.Name IN : set_OrderName and Account__c IN : set_EndUsers and allocation_type__c = 'GU Training Units'];
         system.debug('++++list_TokenAllocation ++++'+list_TokenAllocation );
         
         /****************************Check CSV file for Tokens ***************************************/
         List<GU_Entitlement__c>list_GU = new List<GU_Entitlement__c>();
         //boolean isError = false;
         
         /***************************** CSV File Columns ***************************/
         string CSVErrorFile = 'EntitlementID' + ',' + 'EndUser' + ',' + 'PartnerName' + ',' + 'EntitlementName' + ',' +  'EntitlementNumber' + ',' +  'EntitlementType' + ',' +  'StudentName' + ',' +  'StudentEmail' + ',' +  'CourseStartDate' + ',' +  'CourseEndDate' + ',' +  'Certified' + ',' +  'CertificationExpiration' + ',' +  'GUVoucherUsed' + ',' +  'OrderName' + ',' +  'OrderId' + ',' +  'Status'  + ',' + 'CancellationDate' + ',' + 'CourseLocation' + ',' + 'EndCustomerName' + ',' + 'Error' + ',' + '\n';  
         
         List<Token_Consumption__c> insertTokenConsumption = new List<Token_Consumption__c>();
         Map<string,Token_Consumption__c>map_TC = new Map<string,Token_Consumption__c>();
         
         for(wrapTrainingCourseConsumption objWrap : list_WrapperInProgress)
         {
             boolean isExist = false;
             boolean isOrder = false;
             boolean isToken = false;
             
             for(Token_Allocations__c objToken : list_TokenAllocation)
             {
                 system.debug('++++objWrap.OrderName ++++  '+objWrap.OrderName);
                 system.debug('++++objToken.Order__c++++  '+objToken.Order__c);
                 
                 system.debug('++++objWrap.EndUser++++  '+objWrap.EndUser);
                 system.debug('++++objToken.Account__c++++  '+objToken.Account__c);
                 
                 system.debug('++++objWrap.GUVoucherUsed++++  '+objWrap.GUVoucherUsed);
                 system.debug('++++objToken.Tokens_Available__c++++  '+objToken.Tokens_Available__c);
                 
                 if(objWrap.OrderId == objToken.Order__c && objWrap.EndUser == objToken.Account__c && objWrap.GUVoucherUsed < objToken.Tokens_Available__c)
                 {
                     isExist = true;
                     
                     //Create token consumption record
                     Token_Consumption__c obj = new Token_Consumption__c();
                     obj.Token_Allocation__c = objToken.Id;
                     obj.Tokens__c = objWrap.GUVoucherUsed;
                     obj.Status__c = 'Consumed';
                     
                     insertTokenConsumption.add(obj);
                     
                     map_TC.put(objWrap.OrderName,obj);
                 }
                 else
                 {
                    if(objWrap.OrderId == objToken.Order__c)
                    {
                      isOrder = true;
                      if(objWrap.GUVoucherUsed < objToken.Tokens_Available__c)
                        isToken = true;
                    }
                 }
             }
             system.debug('++++isExist++++  '+isExist);
             
             /********************** Success records ***************/
             if(isExist)
             {
                 GU_Entitlement__c objGU = new GU_Entitlement__c();
                 //objGU.Certification_Expiration__c = objWrap.CertificationExpiration ;
                 //if(objWrap.Certified != null)
                 //  objGU.Certified__c = objWrap.Certified ;
                 objGU.Course_End_Date__c = objWrap.CourseEndDate ;
                 objGU.Course_Location__c = objWrap.CourseLocation ;
                 objGU.Course_Start_Date__c = objWrap.CourseStartDate ;
                 if(objWrap.EndCustomerName != null && objWrap.EndCustomerName != '')
                   objGU.End_Customer_Name__c = objWrap.EndUser; //objWrap.EndCustomerName.trim() ;
                 objGU.Entitlement_Name__c = objWrap.EntitlementName ;
                 objGU.Entitlement_Number__c = objWrap.EntitlementNumber ;
                 objGU.Entitlement_Type__c = objWrap.EntitlementType ;
                 objGU.GU_Voucher_Used__c = objWrap.GUVoucherUsed ;
                 if(objWrap.PartnerName != null && objWrap.PartnerName != '')
                   objGU.Partner_Name__c = objWrap.PartnerName ;
                 if(objWrap.OrderId != null && objWrap.OrderId != '')
                   objGU.Order__c = objWrap.OrderId;
                 objGU.Order_Name__c = objWrap.OrderName ;
                 
                 //objGU.Status__c = objWrap.Status ;
                 objGU.Status__c = 'In Progress' ;
                 objGU.Student_Email__c = objWrap.StudentEmail ;
                 objGU.Student_Name__c = objWrap.StudentName ;
                 //objGU.Cancellation_Date__c = objWrap.CancellationDate;
                 list_GU.add(objGU);
             }
             else{ /*********************** Error records *******************/
                 string errMsg;
                 if(!isOrder)
                   errMsg = 'Order not found.';
                 if(isOrder && !isToken)
                   errMsg = 'Token not available.';  
                 
                 CSVErrorFile += '' + ',' + objWrap.EndUser + ',' + objWrap.PartnerName+ ',' + objWrap.EntitlementName + ',' + objWrap.EntitlementNumber + ',' +  objWrap.EntitlementType + ',' + objWrap.StudentName + ',' + objWrap.StudentEmail + ',' + objWrap.CourseStartDate + ',' + objWrap.CourseEndDate + ','+ '' + ','+ '' + ','+ objWrap.GUVoucherUsed + ','+ objWrap.OrderName + ',' + objWrap.OrderId + ','+ objWrap.Status + ','+ '' + ',' + objWrap.CourseLocation + ',' + '' + ',' + errMsg + ',' +'\n';  
                 //CSVErrorFile += '' + ',' + objWrap.EndUser + ',' + objWrap.PartnerName+ ',' + objWrap.EntitlementName + ',' + objWrap.EntitlementNumber + ',' +  objWrap.EntitlementType + ',' + objWrap.StudentName + ',' + objWrap.StudentEmail + ',' + objWrap.CourseStartDate + ',' + objWrap.CourseEndDate + ','+ objWrap.Certified + ','+ objWrap.CertificationExpiration + ','+ objWrap.GUVoucherUsed + ','+ objWrap.OrderName + ','+ objWrap.OrderId + ','+ objWrap.Status + ','+ objWrap.CancellationDate + ',' + objWrap.CourseLocation + ',' + '' + ',' + errMsg + ',' +'\n';  
                 //isError = true;
                 
                 system.debug('++++CSVErrorFile ++++  '+CSVErrorFile);
             }
         }
         /**********************insert GU Entitlement ***************/
         insert list_GU;
         
         /************************************* Add success records in CSV File *******************************/
         for(GU_Entitlement__c objG : list_GU)
         {
            CSVErrorFile += objG.id + ',' + objG.End_Customer_Name__c + ',' + '' + ',' + objG.Entitlement_Name__c + ',' + objG.Entitlement_Number__c + ',' +  objG.Entitlement_Type__c + ',' + objG.Student_Name__c + ',' + objG.Student_Email__c + ',' + objG.Course_Start_Date__c.format() + ',' + objG.Course_End_Date__c.format() + ','+ '' + ','+ '' + ','+ objG.GU_Voucher_Used__c + ','+ objG.Order_Name__c + ','+ objG.Order__c + ','+ objG.Status__c + ','+ '' + ',' + objG.Course_Location__c + ',' + objG.End_Customer_Name__c + ',' + '' + ',' +'\n';  
            //CSVErrorFile += objG.id + ',' + objG.End_Customer_Name__c + ',' + objG.Partner_Name__c + ',' + objG.Entitlement_Name__c + ',' + objG.Entitlement_Number__c + ',' +  objG.Entitlement_Type__c + ',' + objG.Student_Name__c + ',' + objG.Student_Email__c + ',' + objG.Course_Start_Date__c + ',' + objG.Course_End_Date__c + ','+ objG.Certified__c + ','+ objG.Certification_Expiration__c + ','+ objG.GU_Voucher_Used__c + ','+ objG.Service_Contract_Number__c + ','+ objG.Service_Contracts_New__c + ','+ objG.Status__c + ','+ objG.Cancellation_Date__c + ',' + objG.Course_Location__c + ',' + objG.End_Customer_Name__c + ',' + '' + ',' +'\n';  
         }
         
         
         /******************** Update GU id in Token Consumption ****************/
         integer i = 0;
         for(Token_Consumption__c tokenObj : insertTokenConsumption){
             tokenObj.GU_Entitlement__c = list_GU.get(i).id;
             i++;
         }
         insert insertTokenConsumption;
         system.debug('++++list_GU++++'+list_GU);

         /***************** send error file *********************/
         //if(isError){  
            string fileName = 'Status_GUEntitlement_InProgress_' + Date.Today();
            
            EmailNotifications__c objEmail = EmailNotifications__c.getvalues('GU Entitlement Notification');
            String[] toAddresses = objEmail.Emails__c.split(';');
            
            system.debug('++++toAddresses ++++'+toAddresses);
            system.debug('++++CSVErrorFile++++'+CSVErrorFile);
            
            system.debug('##Send Error Email##'+ CSVErrorFile);
            
            EmailNotification('','GU Entitlement Notification',toAddresses,CSVErrorFile,fileName );
         //}
       }
       catch(Exception ex)
       {
          system.debug('++++ex++++  '+ex.getMessage());
          system.debug('++++ex.getLineNumber() ++++  '+ex.getLineNumber());
          
          /************Send Error Notification ******************/
          EmailNotifications__c objEmail = EmailNotifications__c.getvalues('GU Entitlement Notification');
          String[] toAddresses = objEmail.Emails__c.split(';');
          EmailNotification(ex.getMessage(),'GU Entitlement Error Notification',toAddresses,'','' );
       }       
     }
     
     private void CompletedAndCancellation(Set<id>set_GU,Map<ID,wrapTrainingCourseConsumption>map_wrap, string FileType)
     {
         Map<ID,GU_Entitlement__c>map_GU = new Map<ID,GU_Entitlement__c>([select id,Status__c,Certified__c,Certification_Expiration__c from GU_Entitlement__c where id IN : set_GU]);
         List<GU_Entitlement__c>list_GUUpdate = new List<GU_Entitlement__c>();
         string CSVErrorFile = 'EntitlementID' + ',' + 'EndUser' + ',' + 'PartnerName' + ',' + 'EntitlementName' + ',' +  'EntitlementNumber' + ',' +  'EntitlementType' + ',' +  'StudentName' + ',' +  'StudentEmail' + ',' +  'CourseStartDate' + ',' +  'CourseEndDate' + ',' +  'Certified' + ',' +  'CertificationExpiration' + ',' +  'GUVoucherUsed' + ',' +  'OrderName' + ',' +  'OrderId' + ',' +  'Status'  + ',' + 'CancellationDate' + ',' + 'CourseLocation' + ',' + 'EndCustomerName' + ',' + 'Error' + ',' + '\n';  
         boolean isError = false;
         
         //Added by JJ
         List<Token_Consumption__c> objTCons = [select id,Status__c,GU_Entitlement__c from Token_Consumption__c where GU_Entitlement__c in : set_GU];
         Map<ID,Token_Consumption__c> mapTCons = new Map<ID, Token_Consumption__c>();
         
         for(Token_Consumption__c obj : objTCons)
             mapTCons.put(obj.GU_Entitlement__c, obj);
             
         system.debug('++++mapTCons +++++   '+mapTCons );    
         
         List<Token_Consumption__c> objUpdateTCons = new List<Token_Consumption__c>();
         
         for(ID guid : set_GU)
         {
             GU_Entitlement__c objGU = map_GU.get(guid);
             wrapTrainingCourseConsumption objWr = map_wrap.get(guid);

             if(objGU != null && objGU.Status__c == 'In Progress')
             {
                /****************** if FileType is null than there is one file with mix status than check status from CSV file************/
                 if(FileType == 'Completed' || (FileType == null && objWr.Status == 'Completed'))
                 {
                     objGU.Status__c = 'Completed';
                     objGU.Certified__c = map_wrap.get(guid).Certified;
                     objGU.Certification_Expiration__c = map_wrap.get(guid).CertificationExpiration ;
                     list_GUUpdate.add(objGU);
                 }   
                 if(FileType == 'Cancellation' || (FileType == null && objWr.Status == 'Cancellation'))
                 {
                     objGU.Status__c = 'Cancelled';
                     objGU.Cancellation_Date__c = map_wrap.get(guid).CancellationDate;
                     list_GUUpdate.add(objGU);
                     
                     //Added by JJ
                     Token_Consumption__c obj = mapTCons.get(guid);
                     obj.Status__c = 'Cancelled';
                     objUpdateTCons.add(obj);
                     
                     
                     
                 }
                               
             }
             else{/****************** error records **************/
                 string errMsg;
                 system.debug('>>>>>>>>>####'+ errMsg);
                 if(objGU == null)
                   errMsg = 'Entitlement id is not valid.';
                 if(objGU != null && objGU.Status__c != 'In Progress')  
                   errMsg = 'status is not In Progress.';

                 wrapTrainingCourseConsumption objWrap = map_wrap.get(guid);
                 CSVErrorFile += objWrap.GUEntitlementID + ',' + objWrap.EndUser + ',' + objWrap.PartnerName+ ',' + objWrap.EntitlementName + ',' + objWrap.EntitlementNumber + ',' +  objWrap.EntitlementType + ',' + objWrap.StudentName + ',' + objWrap.StudentEmail + ',' + objWrap.CourseStartDate + ',' + objWrap.CourseEndDate + ','+ objWrap.Certified + ','+ objWrap.CertificationExpiration + ','+ objWrap.GUVoucherUsed + ','+ objWrap.OrderName + ','+ objWrap.OrderId + ','+ objWrap.Status + ','+ objWrap.CancellationDate + ',' + objWrap.CourseLocation + ',' + '' + ',' + errMsg + ',' + '\n';  
                 isError = true;
             }
         }
         
         /******************* Send Email Notification of error records ***************************/
         if(isError){
             string fileName;
             if(FileType == 'Completed')
               fileName = 'Error_GUEntitlement_Completed_' + Date.Today();
             if(FileType == 'Cancellation')
               fileName = 'Error_GUEntitlement_Cancelled_' + Date.Today();             
             
             //EmailNotification('','Training Course Consumtion','amit.singh@rsystems.com',CSVErrorFile,fileName );
             
            EmailNotifications__c objEmail = EmailNotifications__c.getvalues('GU Entitlement Notification');
            String[] toAddresses = objEmail.Emails__c.split(';');
            EmailNotification('','GU Entitlement Notification',toAddresses,CSVErrorFile,fileName );
         }
         
         update list_GUUpdate;
         
         //Added by JJ
         if(objUpdateTCons != null && objUpdateTCons.size()>0)
          update objUpdateTCons;
         
     }
  
     private void EmailNotification(string mailBody,string mailSubject,String[] Email,string sCSVData,string sFileName){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        system.debug('#########'+sCSVData);
        
        if(sCSVData != '')
        {
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(sCSVData);
            string csvname = sFileName+'.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        }

        
        //String[] toAddresses = new String[]{Email};
        mail.setToAddresses(Email);
        mail.setPlainTextBody(mailBody);
        mail.setHtmlBody(mailBody);
        mail.setSubject(mailSubject);
        
        if(!Test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public class wrapTrainingCourseConsumption
    {
       public string GUEntitlementID{get;set;}
       public string EndCustomerName{get;set;}
       public string PartnerName{get;set;}
       public string EntitlementNumber{get;set;}
       public string EntitlementName{get;set;}
       public string EntitlementType{get;set;}
       public string StudentName{get;set;}
       public date CourseStartDate{get;set;}
       public date CourseEndDate{get;set;}
       public string CourseLocation{get;set;}
       public string StudentEmail{get;set;}
       public integer GUVoucherUsed{get;set;}
       public string OrderName{get;set;}
       public string OrderId{get;set;}
       public string Status{get;set;}
       public boolean Certified{get;set;}
       public date CertificationExpiration{get;set;}
       public string EndUser{get;set;}
       public date CancellationDate{get;set;}

       public wrapTrainingCourseConsumption(String TrainingCourse)
       {
         system.debug('++++TrainingCourse+++++   '+TrainingCourse);
         string[] csvRow = TrainingCourse.split(',');
         
         system.debug('++++csvRow +++++   '+csvRow );
         
         GUEntitlementID = csvRow[0];
         system.debug('++++csvRow[0] +++++   '+csvRow[0] );
         
         EndUser = csvRow[1];
         
         system.debug('++++csvRow[1] +++++   '+csvRow[1] );
         PartnerName = csvRow[2];
         system.debug('++++csvRow[2] +++++   '+csvRow[2] );
         EntitlementName = csvRow[3];
         system.debug('++++csvRow[3] +++++   '+csvRow[3] );
         EntitlementNumber = csvRow[4];
         system.debug('++++csvRow[4] +++++   '+csvRow[4] );
         EntitlementType = csvRow[5];
         StudentName = csvRow[6];
         StudentEmail = csvRow[7];
         system.debug('++++csvRow[8] +++++   '+csvRow[8] );
         CourseStartDate = csvRow[8] != ''? date.parse(csvRow[8]) : null;
         
         system.debug('++++csvRow[9] +++++   '+csvRow[9] );
         CourseEndDate = csvRow[9] != ''? date.parse(csvRow[9]) : null;
         
         system.debug('++++csvRow[10] +++++   '+csvRow[10] );
         Certified = csvRow[10] != ''? boolean.valueof(csvRow[10]) : null;
         
         system.debug('++++csvRow[11] +++++   '+csvRow[11] );
         CertificationExpiration = csvRow[11] != ''?date.parse(csvRow[11]) : null;
         GUVoucherUsed = csvRow[12] != ''? integer.valueof(csvRow[12]) : null;
         OrderName = csvRow[13];
         OrderId = csvRow[14];
         Status = csvRow[15];
         
         system.debug('++++csvRow[16] +++++   '+csvRow[16] );
         CancellationDate = csvRow[16] != ''?date.parse(csvRow[16]) : null;
         
         system.debug('++++CancellationDate+++++   '+CancellationDate );
         CourseLocation = csvRow[17];
         EndCustomerName = csvRow[18];
         
       }
    }
}

/***********Priyank commented the below code and added the new code above**********/
/*******Changes done on 4 April 2019 as discussed with Vinay **********************/
/*global class GUEntitlementAttachmentProcessing implements Messaging.InboundEmailHandler 
{ 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        Messaging.InboundEmailResult objResult = new Messaging.InboundEmailResult();    
        try
        {   
            system.debug('#Enter1#');  
            if(email.binaryAttachments != null)
            {
               system.debug('#Enter2#');
               String[] Rows = new String[] {};
               
                for (Messaging.Inboundemail.BinaryAttachment binaryAttach : email.binaryAttachments) 
                {
                    
                    //HttpRequest tmp = new HttpRequest();
                    //tmp.setBodyAsBlob(EncodingUtil.base64Decode(Blob.valueOf(binaryAttach.body)));
                    
                    //string FileData = EncodingUtil.base64Encode(EncodingUtil.base64Decode(binaryAttach.body));
                    system.debug('#Enter3#'+binaryAttach );
                    //string FileData = binaryAttach.body.toString();
                    
                    
                    /****** For Reference *************/
                    /****** https://blog.enree.co/2013/01/salesforce-apex-post-mutipartform-data.html *****/
                    
                    /*Blob body = binaryAttach.body;
                    HttpRequest tmp = new HttpRequest();
                    tmp.setBodyAsBlob(body);
                    String FileData = tmp.getBody();
                    //System.debug('## Output body:'+bodyString );
                    
                    //string FileData = EncodingUtil.convertToHex(binaryAttach.body);
                    //Blob blobValue = EncodingUtil.convertToHex(binaryAttach.body);
                    //string FileData = string.valueof(blobValue);
                    
                    system.debug('#FileData #######  '+FileData );
                    system.debug('++++binaryAttach.fileName++++'+binaryAttach.fileName);
                    
                    if(binaryAttach.fileName == 'GUEntitlement_InProgress.csv')
                      ProcessFile(FileData,'In Progress'); 
                    if(binaryAttach.fileName == 'GUEntitlement_Completed.csv')
                        ProcessFile(FileData,'Completed');
                    if(binaryAttach.fileName == 'GUEntitlement_Cancelled.csv')  
                        ProcessFile(FileData,'Cancellation');
                }
            }
            objResult.success = true;
        }
        catch(Exception ex)
        {
          objResult.success = false;
          objResult.message = ex.getMessage();
          
          system.debug('#Enter4#'+ex);
          
          /************Send Error Notification ******************/
          /*EmailNotifications__c objEmail = EmailNotifications__c.getvalues('GU Entitlement Error Notification');
          String[] toAddresses = objEmail.Emails__c.split(';');
          system.debug('Error Occured##-'+ex.getMessage());
          EmailNotification(ex.getMessage(),'GU Entitlement Error Notification',toAddresses,'','' );
        }
        return objResult;
    }

    private void ProcessFile(string sFileData , string FileType)
    {
        String[] GUTraining = new String[] {};
           List<wrapTrainingCourseConsumption>list_WrapperInProgress = new List<wrapTrainingCourseConsumption>();
           
         system.debug('##Enter in ProcessFile##');       
        /************************************************** Get All Rows **********************************************/
           /* GUTraining = sFileData.split('\n');
            Set<string>set_accountId = new Set<string>();
            
        /***************************Iteration on CSV rows *******************************************/
           /* Set<string>set_ServiceContractNumbers = new Set<string>();
            Set<id>set_GUEnt = new Set<id>();
            Map<ID,wrapTrainingCourseConsumption>map_GU = new Map<ID,wrapTrainingCourseConsumption>();
            
            for (Integer i = 1; i < GUTraining.size(); i++) {
                
                wrapTrainingCourseConsumption obj = new wrapTrainingCourseConsumption(GUTraining[i]);
                
                /*************** for In-progress records ********************/
                /*if(obj.GUEntitlementID == null || obj.GUEntitlementID == '')                
                  list_WrapperInProgress.add(obj);
                else /******************* for Completed and Cancellation records *******************/
               /* {
                    set_GUEnt.add(obj.GUEntitlementID);
                    map_GU.put(obj.GUEntitlementID,obj);
                }

                /************** Get All Service Contract from CSV file ***************************/
                /*if(!set_ServiceContractNumbers.contains(obj.ServiceContractNumber))
                  set_ServiceContractNumbers.add(obj.ServiceContractNumber);
            }
            system.debug('++++set_ServiceContractNumbers++++'+set_ServiceContractNumbers);
            system.debug('++++map_GU++++'+map_GU);
            system.debug('++++set_GUEnt++++'+set_GUEnt);
            
         if(FileType == 'In Progress')
         {           
            
            system.debug('##Enter in InProgress##');
            /************* for In progress records **************/
            /*if(list_WrapperInProgress != null && list_WrapperInProgress.size() >0)
                readCSVFileInProgress(list_WrapperInProgress,set_ServiceContractNumbers) ;
            
            /************** for Completed and Cancellation records ***************/
             //CompletedAndCancellation(set_GUEnt,map_GU, null);
     /*    }
         if(FileType == 'Completed' || FileType == 'Cancellation')
         {
             CompletedAndCancellation(set_GUEnt,map_GU, FileType);
         }
    }

    private void readCSVFileInProgress(List<wrapTrainingCourseConsumption>list_WrapperInProgress,Set<string>set_ServiceContractNumbers) {
       try{
           
          
          system.debug('##Enter readCSVFile##');
          system.debug('++++list_WrapperInProgress++++'+list_WrapperInProgress);  
          system.debug('++++set_ServiceContractNumbers++++'+set_ServiceContractNumbers);  
            
         /***************************** Get the End Account ************************/
         /*Map<id,ServiceContract>map_ServiceContract = new  Map<id,ServiceContract>([Select id,Name,End_User_Name__c from ServiceContract where name IN : set_ServiceContractNumbers]);
         //Map<id,GCR_Content_Document_Detail__c>map_ServiceContract = new  Map<id,GCR_Content_Document_Detail__c>([Select id,Name,Customer_Name__c from GCR_Content_Document_Detail__c where name IN : set_ServiceContractNumbers]);
         
         system.debug('++++map_ServiceContract ++++'+map_ServiceContract);
         
         Set<id>set_EndUsers = new Set<id>();
         for(ID scID : map_ServiceContract.keyset())
         {
             ServiceContract objSC = map_ServiceContract.get(scID);
             //GCR_Content_Document_Detail__c objSC = map_ServiceContract.get(scID);
             
             //if(!set_EndUsers.contains(objSC.Customer_Name__c))
             //   set_EndUsers.add(objSC.Customer_Name__c) ; 
             
             if(!set_EndUsers.contains(objSC.End_User_Name__c ))
                set_EndUsers.add(objSC.End_User_Name__c ) ; 
   
             system.debug('++++set_EndUsers++++'+set_EndUsers);
            
            /***************Update End User in wrapper class ********************/
            /* for(wrapTrainingCourseConsumption objW : list_WrapperInProgress)           
             {
                 if(objW.ServiceContractNumber == objSC.Name)
                 {
                     //objW.EndUser = objSC.Customer_Name__c;
                     objW.EndUser = objSC.End_User_Name__c;
                     objW.ServiceContract = objSC.id;
                 } 
             }
         }
         
         /*************************** Check Service Contract and End User in Token Allocation *******************************/
       /*  List<Token_Allocations__c>list_TokenAllocation = [select id,Tokens_Available__c,Account__c,Contract_No__c from Token_Allocations__c where Contract_No__c IN : set_ServiceContractNumbers and Account__c IN : set_EndUsers and allocation_type__c = 'GU Training Units'];
         system.debug('++++list_TokenAllocation ++++'+list_TokenAllocation );
         
         /****************************Check CSV file for Tokens ***************************************/
       /*  List<GU_Entitlement__c>list_GU = new List<GU_Entitlement__c>();
         //boolean isError = false;
         
         /***************************** CSV File Columns ***************************/
     /*    string CSVErrorFile = 'EntitlementID' + ',' + 'EndUser' + ',' + 'PartnerName' + ',' + 'EntitlementName' + ',' +  'EntitlementNumber' + ',' +  'EntitlementType' + ',' +  'StudentName' + ',' +  'StudentEmail' + ',' +  'CourseStartDate' + ',' +  'CourseEndDate' + ',' +  'Certified' + ',' +  'CertificationExpiration' + ',' +  'GUVoucherUsed' + ',' +  'ServiceContractNumber' + ',' +  'ServiceContract' + ',' +  'Status'  + ',' + 'CancellationDate' + ',' + 'CourseLocation' + ',' + 'EndCustomerName' + ',' + 'Error' + ',' + '\n';  
         
         List<Token_Consumption__c> insertTokenConsumption = new List<Token_Consumption__c>();
         Map<string,Token_Consumption__c>map_TC = new Map<string,Token_Consumption__c>();
         
         for(wrapTrainingCourseConsumption objWrap : list_WrapperInProgress)
         {
             boolean isExist = false;
             boolean isSC = false;
             boolean isToken = false;
             
             for(Token_Allocations__c objToken : list_TokenAllocation)
             {
                 system.debug('++++objWrap.ServiceContractNumber ++++  '+objWrap.ServiceContractNumber);
                 system.debug('++++objToken.Service_Contract_No__c++++  '+objToken.Contract_No__c);
                 
                 system.debug('++++objWrap.EndUser++++  '+objWrap.EndUser);
                 system.debug('++++objToken.Account__c++++  '+objToken.Account__c);
                 
                 system.debug('++++objWrap.GUVoucherUsed++++  '+objWrap.GUVoucherUsed);
                 system.debug('++++objToken.Tokens_Available__c++++  '+objToken.Tokens_Available__c);
                 
                 if(objWrap.ServiceContractNumber == objToken.Contract_No__c && objWrap.EndUser == objToken.Account__c && objWrap.GUVoucherUsed < objToken.Tokens_Available__c)
                 {
                     isExist = true;
                     
                     //Create token consumption record
                     Token_Consumption__c obj = new Token_Consumption__c();
                     obj.Token_Allocation__c = objToken.Id;
                     obj.Tokens__c = objWrap.GUVoucherUsed;
                     obj.Status__c = 'Consumed';
                     
                     insertTokenConsumption.add(obj);
                     
                     map_TC.put(objWrap.ServiceContractNumber,obj);
                 }
                 else
                 {
                    if(objWrap.ServiceContractNumber == objToken.Contract_No__c)
                    {
                      isSC = true;
                      if(objWrap.GUVoucherUsed < objToken.Tokens_Available__c)
                        isToken = true;
                    }
                 }
             }
             system.debug('++++isExist++++  '+isExist);
             
             /********************** Success records ***************/
         /*    if(isExist)
             {
                 GU_Entitlement__c objGU = new GU_Entitlement__c();
                 //objGU.Certification_Expiration__c = objWrap.CertificationExpiration ;
                 //if(objWrap.Certified != null)
                 //  objGU.Certified__c = objWrap.Certified ;
                 objGU.Course_End_Date__c = objWrap.CourseEndDate ;
                 objGU.Course_Location__c = objWrap.CourseLocation ;
                 objGU.Course_Start_Date__c = objWrap.CourseStartDate ;
                 if(objWrap.EndCustomerName != null && objWrap.EndCustomerName != '')
                   objGU.End_Customer_Name__c = objWrap.EndUser; //objWrap.EndCustomerName.trim() ;
                 objGU.Entitlement_Name__c = objWrap.EntitlementName ;
                 objGU.Entitlement_Number__c = objWrap.EntitlementNumber ;
                 objGU.Entitlement_Type__c = objWrap.EntitlementType ;
                 objGU.GU_Voucher_Used__c = objWrap.GUVoucherUsed ;
                 if(objWrap.PartnerName != null && objWrap.PartnerName != '')
                   objGU.Partner_Name__c = objWrap.PartnerName ;
                 if(objWrap.ServiceContract != null && objWrap.ServiceContract != '')
                   objGU.Service_Contract__c = objWrap.ServiceContract;
                 objGU.Service_Contract_Number__c = objWrap.ServiceContractNumber ;
                 
                 //objGU.Status__c = objWrap.Status ;
                 objGU.Status__c = 'In Progress' ;
                 objGU.Student_Email__c = objWrap.StudentEmail ;
                 objGU.Student_Name__c = objWrap.StudentName ;
                 //objGU.Cancellation_Date__c = objWrap.CancellationDate;
                 list_GU.add(objGU);
             }
             else{ /*********************** Error records *******************/
            /*     string errMsg;
                 if(!isSC)
                   errMsg = 'Service Contract not found.';
                 if(isSC && !isToken)
                   errMsg = 'Token not available.';  
                 
                 CSVErrorFile += '' + ',' + objWrap.EndUser + ',' + objWrap.PartnerName+ ',' + objWrap.EntitlementName + ',' + objWrap.EntitlementNumber + ',' +  objWrap.EntitlementType + ',' + objWrap.StudentName + ',' + objWrap.StudentEmail + ',' + objWrap.CourseStartDate + ',' + objWrap.CourseEndDate + ','+ '' + ','+ '' + ','+ objWrap.GUVoucherUsed + ','+ objWrap.ServiceContractNumber + ',' + objWrap.ServiceContract + ','+ objWrap.Status + ','+ '' + ',' + objWrap.CourseLocation + ',' + '' + ',' + errMsg + ',' +'\n';  
                 //CSVErrorFile += '' + ',' + objWrap.EndUser + ',' + objWrap.PartnerName+ ',' + objWrap.EntitlementName + ',' + objWrap.EntitlementNumber + ',' +  objWrap.EntitlementType + ',' + objWrap.StudentName + ',' + objWrap.StudentEmail + ',' + objWrap.CourseStartDate + ',' + objWrap.CourseEndDate + ','+ objWrap.Certified + ','+ objWrap.CertificationExpiration + ','+ objWrap.GUVoucherUsed + ','+ objWrap.ServiceContractNumber + ','+ objWrap.ServiceContract + ','+ objWrap.Status + ','+ objWrap.CancellationDate + ',' + objWrap.CourseLocation + ',' + '' + ',' + errMsg + ',' +'\n';  
                 //isError = true;
                 
                 system.debug('++++CSVErrorFile ++++  '+CSVErrorFile);
             }
         }
         /**********************insert GU Entitlement ***************/
       /*  insert list_GU;
         
         /************************************* Add success records in CSV File *******************************/
       /*  for(GU_Entitlement__c objG : list_GU)
         {
            CSVErrorFile += objG.id + ',' + objG.End_Customer_Name__c + ',' + '' + ',' + objG.Entitlement_Name__c + ',' + objG.Entitlement_Number__c + ',' +  objG.Entitlement_Type__c + ',' + objG.Student_Name__c + ',' + objG.Student_Email__c + ',' + objG.Course_Start_Date__c.format() + ',' + objG.Course_End_Date__c.format() + ','+ '' + ','+ '' + ','+ objG.GU_Voucher_Used__c + ','+ objG.Service_Contract_Number__c + ','+ objG.Service_Contract__c + ','+ objG.Status__c + ','+ '' + ',' + objG.Course_Location__c + ',' + objG.End_Customer_Name__c + ',' + '' + ',' +'\n';  
            //CSVErrorFile += objG.id + ',' + objG.End_Customer_Name__c + ',' + objG.Partner_Name__c + ',' + objG.Entitlement_Name__c + ',' + objG.Entitlement_Number__c + ',' +  objG.Entitlement_Type__c + ',' + objG.Student_Name__c + ',' + objG.Student_Email__c + ',' + objG.Course_Start_Date__c + ',' + objG.Course_End_Date__c + ','+ objG.Certified__c + ','+ objG.Certification_Expiration__c + ','+ objG.GU_Voucher_Used__c + ','+ objG.Service_Contract_Number__c + ','+ objG.Service_Contracts_New__c + ','+ objG.Status__c + ','+ objG.Cancellation_Date__c + ',' + objG.Course_Location__c + ',' + objG.End_Customer_Name__c + ',' + '' + ',' +'\n';  
         }
         
         
         /******************** Update GU id in Token Consumption ****************/
      /*   for(GU_Entitlement__c obj : list_GU)
         {
            Token_Consumption__c objT = map_TC.get(obj.Service_Contract_Number__c);
            objT.GU_Entitlement__c = obj.id;
         }
         
         insert insertTokenConsumption;
         system.debug('++++list_GU++++'+list_GU);

         /***************** send error file *********************/
         //if(isError){  
         /*   string fileName = 'Status_GUEntitlement_InProgress_' + Date.Today();
            
            EmailNotifications__c objEmail = EmailNotifications__c.getvalues('GU Entitlement Notification');
            String[] toAddresses = objEmail.Emails__c.split(';');
            
            system.debug('++++toAddresses ++++'+toAddresses);
            system.debug('++++CSVErrorFile++++'+CSVErrorFile);
            
            system.debug('##Send Error Email##'+ CSVErrorFile);
            
            EmailNotification('','GU Entitlement Notification',toAddresses,CSVErrorFile,fileName );
         //}
       }
       catch(Exception ex)
       {
          system.debug('++++ex++++  '+ex.getMessage());
          system.debug('++++ex.getLineNumber() ++++  '+ex.getLineNumber());
          
          /************Send Error Notification ******************/
        /*  EmailNotifications__c objEmail = EmailNotifications__c.getvalues('GU Entitlement Notification');
          String[] toAddresses = objEmail.Emails__c.split(';');
          EmailNotification(ex.getMessage(),'GU Entitlement Error Notification',toAddresses,'','' );
       }       
     }
     
     private void CompletedAndCancellation(Set<id>set_GU,Map<ID,wrapTrainingCourseConsumption>map_wrap, string FileType)
     {
         Map<ID,GU_Entitlement__c>map_GU = new Map<ID,GU_Entitlement__c>([select id,Status__c,Certified__c,Certification_Expiration__c from GU_Entitlement__c where id IN : set_GU]);
         List<GU_Entitlement__c>list_GUUpdate = new List<GU_Entitlement__c>();
         string CSVErrorFile = 'EntitlementID' + ',' + 'EndUser' + ',' + 'PartnerName' + ',' + 'EntitlementName' + ',' +  'EntitlementNumber' + ',' +  'EntitlementType' + ',' +  'StudentName' + ',' +  'StudentEmail' + ',' +  'CourseStartDate' + ',' +  'CourseEndDate' + ',' +  'Certified' + ',' +  'CertificationExpiration' + ',' +  'GUVoucherUsed' + ',' +  'ServiceContractNumber' + ',' +  'ServiceContract' + ',' +  'Status'  + ',' + 'CancellationDate' + ',' + 'CourseLocation' + ',' + 'EndCustomerName' + ',' + 'Error' + ',' + '\n';  
         boolean isError = false;
         
         //Added by JJ
         List<Token_Consumption__c> objTCons = [select id,Status__c,GU_Entitlement__c from Token_Consumption__c where GU_Entitlement__c in : set_GU];
         Map<ID,Token_Consumption__c> mapTCons = new Map<ID, Token_Consumption__c>();
         
         for(Token_Consumption__c obj : objTCons)
             mapTCons.put(obj.GU_Entitlement__c, obj);
             
         system.debug('++++mapTCons +++++   '+mapTCons );    
         
         List<Token_Consumption__c> objUpdateTCons = new List<Token_Consumption__c>();
         
         for(ID guid : set_GU)
         {
             GU_Entitlement__c objGU = map_GU.get(guid);
             wrapTrainingCourseConsumption objWr = map_wrap.get(guid);

             if(objGU != null && objGU.Status__c == 'In Progress')
             {
                /****************** if FileType is null than there is one file with mix status than check status from CSV file************/
             /*    if(FileType == 'Completed' || (FileType == null && objWr.Status == 'Completed'))
                 {
                     objGU.Status__c = 'Completed';
                     objGU.Certified__c = map_wrap.get(guid).Certified;
                     objGU.Certification_Expiration__c = map_wrap.get(guid).CertificationExpiration ;
                     list_GUUpdate.add(objGU);
                 }   
                 if(FileType == 'Cancellation' || (FileType == null && objWr.Status == 'Cancellation'))
                 {
                     objGU.Status__c = 'Cancelled';
                     objGU.Cancellation_Date__c = map_wrap.get(guid).CancellationDate;
                     list_GUUpdate.add(objGU);
                     
                     //Added by JJ
                     Token_Consumption__c obj = mapTCons.get(guid);
                     obj.Status__c = 'Cancelled';
                     objUpdateTCons.add(obj);
                     
                     
                     
                 }
                               
             }
             else{/****************** error records **************/
           /*      string errMsg;
                 if(objGU == null)
                   errMsg = 'Entitlement id is not valid.';
                 if(objGU != null && objGU.Status__c != 'In Progress')  
                   errMsg = 'status is not In Progress.';

                 wrapTrainingCourseConsumption objWrap = map_wrap.get(guid);
                 CSVErrorFile += objWrap.GUEntitlementID + ',' + objWrap.EndUser + ',' + objWrap.PartnerName+ ',' + objWrap.EntitlementName + ',' + objWrap.EntitlementNumber + ',' +  objWrap.EntitlementType + ',' + objWrap.StudentName + ',' + objWrap.StudentEmail + ',' + objWrap.CourseStartDate + ',' + objWrap.CourseEndDate + ','+ objWrap.Certified + ','+ objWrap.CertificationExpiration + ','+ objWrap.GUVoucherUsed + ','+ objWrap.ServiceContractNumber + ','+ objWrap.ServiceContract + ','+ objWrap.Status + ','+ objWrap.CancellationDate + ',' + objWrap.CourseLocation + ',' + '' + ',' + errMsg + ',' + '\n';  
                 isError = true;
             }
         }
         
         /******************* Send Email Notification of error records ***************************/
       /*  if(isError){
             string fileName;
             if(FileType == 'Completed')
               fileName = 'Error_GUEntitlement_Completed_' + Date.Today();
             if(FileType == 'Cancellation')
               fileName = 'Error_GUEntitlement_Cancelled_' + Date.Today();             
             
             //EmailNotification('','Training Course Consumtion','amit.singh@rsystems.com',CSVErrorFile,fileName );
             
            EmailNotifications__c objEmail = EmailNotifications__c.getvalues('GU Entitlement Notification');
            String[] toAddresses = objEmail.Emails__c.split(';');
            EmailNotification('','GU Entitlement Notification',toAddresses,CSVErrorFile,fileName );
         }
         
         update list_GUUpdate;
         
         //Added by JJ
         if(objUpdateTCons != null && objUpdateTCons.size()>0)
          update objUpdateTCons;
         
     }
  
     private void EmailNotification(string mailBody,string mailSubject,String[] Email,string sCSVData,string sFileName){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        system.debug('###'+sCSVData);
        
        if(sCSVData != '')
        {
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(sCSVData);
            string csvname = sFileName+'.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        }

        
        //String[] toAddresses = new String[]{Email};
        mail.setToAddresses(Email);
        mail.setPlainTextBody(mailBody);
        mail.setHtmlBody(mailBody);
        mail.setSubject(mailSubject);
        
        if(!Test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public class wrapTrainingCourseConsumption
    {
       public string GUEntitlementID{get;set;}
       public string EndCustomerName{get;set;}
       public string PartnerName{get;set;}
       public string EntitlementNumber{get;set;}
       public string EntitlementName{get;set;}
       public string EntitlementType{get;set;}
       public string StudentName{get;set;}
       public date CourseStartDate{get;set;}
       public date CourseEndDate{get;set;}
       public string CourseLocation{get;set;}
       public string StudentEmail{get;set;}
       public integer GUVoucherUsed{get;set;}
       public string ServiceContractNumber{get;set;}
       public string ServiceContract{get;set;}
       public string Status{get;set;}
       public boolean Certified{get;set;}
       public date CertificationExpiration{get;set;}
       public string EndUser{get;set;}
       public date CancellationDate{get;set;}

       public wrapTrainingCourseConsumption(String TrainingCourse)
       {
         system.debug('++++TrainingCourse+++++   '+TrainingCourse);
         string[] csvRow = TrainingCourse.split(',');
         
         system.debug('++++csvRow +++++   '+csvRow );
         
         GUEntitlementID = csvRow[0];
         system.debug('++++csvRow[0] +++++   '+csvRow[0] );
         
         EndUser = csvRow[1];
         
         system.debug('++++csvRow[1] +++++   '+csvRow[1] );
         PartnerName = csvRow[2];
         system.debug('++++csvRow[2] +++++   '+csvRow[2] );
         EntitlementName = csvRow[3];
         system.debug('++++csvRow[3] +++++   '+csvRow[3] );
         EntitlementNumber = csvRow[4];
         system.debug('++++csvRow[4] +++++   '+csvRow[4] );
         EntitlementType = csvRow[5];
         StudentName = csvRow[6];
         StudentEmail = csvRow[7];
         system.debug('++++csvRow[8] +++++   '+csvRow[8] );
         CourseStartDate = csvRow[8] != ''? date.parse(csvRow[8]) : null;
         
         system.debug('++++csvRow[9] +++++   '+csvRow[9] );
         CourseEndDate = csvRow[9] != ''? date.parse(csvRow[9]) : null;
         
         system.debug('++++csvRow[10] +++++   '+csvRow[10] );
         Certified = csvRow[10] != ''? boolean.valueof(csvRow[10]) : null;
         
         system.debug('++++csvRow[11] +++++   '+csvRow[11] );
         CertificationExpiration = csvRow[11] != ''?date.parse(csvRow[11]) : null;
         GUVoucherUsed = csvRow[12] != ''? integer.valueof(csvRow[12]) : null;
         ServiceContractNumber = csvRow[13];
         ServiceContract = csvRow[14];
         Status = csvRow[15];
         
         system.debug('++++csvRow[16] +++++   '+csvRow[16] );
         CancellationDate = csvRow[16] != ''?date.parse(csvRow[16]) : null;
         
         system.debug('++++CancellationDate+++++   '+CancellationDate );
         CourseLocation = csvRow[17];
         EndCustomerName = csvRow[18];
         
       }
    }
}*/