public with sharing class ContentDisplayController {
    public List<ContentVersion > searchResults {get;set;}
    
    public  ContentDisplayController(){
         searchResults=[SELECT Id,Title, FileType,ContentSize,ContentDocumentId,Owner.Name From ContentVersion c limit 1000];
    } 
    
}