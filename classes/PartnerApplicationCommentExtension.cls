//Naresh Kumar  01/28/2014
public without sharing class PartnerApplicationCommentExtension 
{
    public List<Comment__c> comments {get;set;}
    public String pageMode {get;set;}
    public Boolean hasComments {get;set;}
    public Comment__c newComment {get;set;}
    public String applicationId {get;set;}
    public Partner_Application__c partnerApplication {get;set;}
    public PartnerApplicationCommentExtension(ApexPages.StandardController stdController){
        applicationId = ApexPages.currentPage().getParameters().get('id');      
        pageMode = 'list';
        if( ApexPages.currentPage().getParameters().get('pageMode') != null )
            pageMode = ApexPages.currentPage().getParameters().get('pageMode');
        if( pageMode.equals('list') ){
            populateComments(applicationId);
        }
        else{
            initializeNewComment();
        }
    }
    
    private void initializeNewComment(){
        applicationId = ApexPages.currentPage().getParameters().get('appId');
        partnerApplication = [SELECT Name, Owner.Email FROM Partner_Application__c WHERE id =: applicationId];
        newComment = new Comment__c();
        newComment.Partner_Application__c = applicationId;
        newComment.Public__c = true;
        if( ApexPages.currentPage().getParameters().get('replyTo') != null  ){
            newComment.Requester_Email__c = ApexPages.currentPage().getParameters().get('replyTo');         
        }
        else{
            newComment.Requester_Email__c = partnerApplication.Owner.Email;
        }
    }
    private void populateComments(String applicationId){
        hasComments = true;
        comments = [SELECT id, Name, Comments__c FROM Comment__c
            WHERE Public__c = true AND Partner_Application__c =: applicationId];
        if(comments.isEmpty())
            hasComments = false;
    }
    
    public PageReference save(){
        insert newComment;
        return new PageReference('/' + applicationId);
    }
    
    public PageReference cancel(){
        return new PageReference('/' + applicationId);
    }
    
    public PageReference newComment(){
        return new PageReference('/Partner/NewPartnerApplicationComment?id=' + applicationId);
    }
}