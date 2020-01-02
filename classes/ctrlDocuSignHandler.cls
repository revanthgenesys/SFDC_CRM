/***************************************************************************************
 *  Description: Handler class for trigDocuSignStatus trigger on DocuSignStatus object
 *               when docuSignStatus records have envelope status as Completed    
 *  Revision History:
 *  Date                 Modification Details
 *  Nov 02,2014          Created.
 ***************************************************************************************/
 
   public class ctrlDocuSignHandler{
    SET<String> GCRAccountIds = new SET<String>();
   
   /************************************************************
   * Name             : createGCRRequests
   * Description      : creates GCR__c records for the docusign status 
   *                    records which have envelope status as Completed.        
   * Input Parameters : Map<Id,dsfs__DocuSign_Status__c> 
   * Return           : void
   ************************************************************/    
   public void createGCRRequests(Map<Id,dsfs__DocuSign_Status__c> mapDocSignStatus){
     //Variables declaration
     List<GCR__c> GCRList =  new List<GCR__c>();  
     SET<String> oppIds = new SET<String>();  
     try{ 
     //Store the unique opportunity ids of the docusingstatus records in a SET
     for(dsfs__DocuSign_Status__c d: mapDocSignStatus.values()){
       oppIds.add(d.dsfs__Company__c);
     }
     
     //Get all the unique opportunity details for the docuSignStatus records updated
     Map<Id,Account> mapAcc = new Map<Id,Account>([SELECT Id,Name,OwnerId from Account 
                                                             WHERE ID IN :oppIds]);      
       
     //Create GCR__c records for each docuSignStatus record being updated as completed
     for(dsfs__DocuSign_Status__c d: mapDocSignStatus.values()){
        GCR__c g = new GCR__c(Request_Type__c ='Sales',Priority__c ='Medium',Requester__c = mapAcc.get(d.dsfs__Company__c).OwnerId,
                            Description__c = 'Cloud Contract',Status__c = '10-Completed',Synopsis__c = mapAcc.get(d.dsfs__Company__c).Name,
                            Account__c = mapAcc.get(d.dsfs__Company__c).Id);
        GCRList.add(g);
        GCRAccountIds.add(mapAcc.get(d.dsfs__Company__c).Id);  
     }
     insert GCRList;
     
    }catch(Exception e){    //Exception Handling
        System.debug('Exception occurred:'+e.getMessage());
    }
     createGCRContentDocFolder(GCRList,mapDocSignStatus);    //Call this method to create GCRContentDocument related records
   } 
   
   /************************************************************
    * Name             : createGCRContentDocFolder
    * Description      : creates  GCR_Content_Document_Detail__c and GCR_Content_Document_Folder__c
    *                    records for the GCR records inserted.        
    * Input Parameters : List<GCR__c> 
    * Return           : void
    ************************************************************/
   public void createGCRContentDocFolder(List<GCR__c> gcrInserted,Map<Id,dsfs__DocuSign_Status__c> mapDoc){ 
    List<GCR_Content_Document_Folder__c> gcrFolders =  new List<GCR_Content_Document_Folder__c>();
    List<String> accids = new List<String>();
    try{
    Map<Id,GCR_Content_Document_Folder__c> GCRCntnDocFolderMap = 
                                               new Map<Id,GCR_Content_Document_Folder__c>([SELECT Id from GCR_Content_Document_Folder__c 
                                                        WHERE Name ='Master Contract' AND Account__c IN : GCRAccountIds]);
                                                        
    if(GCRCntnDocFolderMap.size()==0){  
     //Map<Id,GCR_Content_Document_Folder__c> mapTemp = new Map<Id,GCR_Content_Document_Folder__c>([SELECT id from GCR_Content_Document_Folder__c 
     //                                                                        WHERE Name = 'Master Contract' AND Account__c IN : GCRAccountIds]); 
     accids.addAll(GCRAccountIds);
     GCR_Content_Document_Folder__c gcrFolderInsrted = new GCR_Content_Document_Folder__c(Name = 'Master Contract',Account__c = accids[0],Active__c= true);
     gcrFolders.add(gcrFolderInsrted); 
     if(!gcrFolders.isEmpty())
       insert gcrFolders;        
    }
    else{
      gcrFolders.add(GCRCntnDocFolderMap.values()[0]);
    }
       
    GCR_Content_Document_Detail__c gcrCntnDocDetail = new GCR_Content_Document_Detail__c(Docu_Sign_Status__c ='Completed',
                                                                                    Account_Name__c =gcrInserted[0].Account__c,
                                                                                    Folder__c = gcrFolders[0].id,
                                                                                    GCR__c = gcrInserted[0].id,
                                                                                    Active__c = true,
                                                                                    document_name__c='Contract');
     insert gcrCntnDocDetail;                                              
     List<Attachment> attachmentsToInsert = new List<Attachment>();
     List<Attachment> attachmentsToDelete = new List<Attachment>();
     Attachment tempAtt;
      
      SET<String> docIds = new SET<String>();  
      for(dsfs__DocuSign_Status__c d: mapDoc.values()){ 
        docIds.add(d.id);
      
       }

        for(Attachment attachment: [Select SystemModstamp, ParentId, OwnerId, Name,LastModifiedDate, LastModifiedById, isPrivate, IsDeleted, Id, Description, CreatedDate, CreatedById, ContentType, BodyLength, Body From Attachment where parentId=:docIds])
         {
            tempAtt=attachment.clone(false,false);
            tempAtt.parentId = gcrCntnDocDetail.Id;
            attachmentstoInsert.add(tempAtt);
            attachmentsToDelete.add(attachment);
         }

            insert attachmentsToInsert;
          //delete attachmentsToDelete;
   
   
   
   }
    catch(Exception e){ //Exception Handling
       System.debug('-Exception :'+e.getMessage());
    }
  }    //End of Method


  public void insertDocusignAttachments(String id) {  
    dsfs__DocuSign_Status__c docusignStatus = [Select GCR_Content_Document__c from dsfs__DocuSign_Status__c where id = :id ];        
    List<Attachment> attachmentsToInsert = new List<Attachment>();
    Attachment tempAtt;       
    GCR_Content_Document_Detail__c gcd; 
    List <GCR__c> gcdList = new List <GCR__c>();
         
    if(docuSignStatus != null) {
        if(docusignStatus.GCR_Content_Document__c != null)
        gcd = [Select id,   GCR__c from GCR_Content_Document_Detail__c where id = :docusignStatus.GCR_Content_Document__c];
        //
        //for(Attachment attachment: [Select SystemModstamp, ParentId, OwnerId, Name,LastModifiedDate, LastModifiedById, isPrivate, IsDeleted, Id, Description, CreatedDate, CreatedById, ContentType, BodyLength, Body From Attachment where parentId =:id]){
        //    tempAtt = attachment.clone(false,false);
        //    tempAtt.parentId = docusignStatus.GCR_Content_Document__c;
        //    attachmentstoInsert.add(tempAtt);
       // }
       // insert attachmentsToInsert;
       // 
    } 
  
        
   //for(Attachment eachAtt: attachmentsToInsert) {
       if(gcd!=null && gcd.GCR__c !=null)
       {
        GCR__c updGcd = new GCR__c();
        //updGcd.Final_Attachment_Id__c  = eachAtt.id;
        updGcd.status__c = '11-Completed';
        updGcd.id = gcd.GCR__c;
        gcdList.add(updGcd);
       }
   //} 
   
   if(!gcdList.isEmpty())
    update gcdList; 
    
  
  
  }
  
   }