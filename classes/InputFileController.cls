public with sharing class InputFileController {  
   
    public List<Attachment> a{ get; set; }
    String dsrID = ApexPages.currentPage().getParameters().get('dsrid');
    String dsrName = ApexPages.currentPage().getParameters().get('dName');
    public void picture(){
    a = [select id, name, contentType, bodylength  from  Attachment  where parentid=:dsrID];
      }
      
      public Attachment[] pictures {
        get {      
            return [SELECT Id, name FROM Attachment WHERE ParentId=:dsrID ORDER BY CreatedDate ASC];
            
        }
    }
    
}