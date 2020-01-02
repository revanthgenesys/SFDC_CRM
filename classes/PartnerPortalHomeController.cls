public with sharing class PartnerPortalHomeController {

    public List<HotContentWrapper> hotContentLinks { get; set; }
    public Account newAccount {get;set;}
    
    public List<HotContentWrapper> eventContentLinks { get; set; }
    public List<Partner_Portal_Events__c> events{get;set;}

    // we use the HotContentWrapper to manage the list of hot content links
    public class HotContentWrapper {
        Partner_Portal_Hot_Content__c link;
        ContentDocument doc;
        Partner_Portal_Events_Webinars__c EventLink;
        
        public String title { get; set; }
        public String url { get; set; }
        
        public HotContentWrapper(Partner_Portal_Hot_Content__c hc) {
            link = hc;
            String docid = link.Content_Id__c;
            List<ContentDocument> docs = [ SELECT Title 
                                             FROM ContentDocument 
                                            WHERE Id = :docid ];
            if (docs.size()>0) {
                doc = docs[0];
                title = doc.Title;
            } else {
                List<ContentVersion> docVersions = [ SELECT  c.ContentDocumentId,c.ContentDocument.title From ContentVersion c  WHERE Id = :docid ];
                
                if (docVersions.size()>0) {
                    doc = docVersions[0].ContentDocument;
                    title = doc.title;
                } else {
                    title = '[[ content not found ]]';
                }
            }
            url = Site.getCurrentSiteUrl() + docid;
        }
        
        
        public HotContentWrapper(Partner_Portal_Events_Webinars__c hc) {
            EventLink = hc;
            String docid = EventLink.Event_Id__c;
            List<ContentDocument> docs = [ SELECT Title 
                                             FROM ContentDocument 
                                            WHERE Id = :docid ];
                                            
            if (docs.size()>0) {
                doc = docs[0];
                title = doc.Title;
            } else {
                List<ContentVersion> docVersions = [ SELECT  c.ContentDocumentId,c.ContentDocument.title From ContentVersion c  WHERE Id = :docid ];
                
                if (docVersions.size()>0) {
                    doc = docVersions[0].ContentDocument;
                    title = doc.title;
                } else {
                    title = '[[ content not found ]]';
                }
            }
            url = Site.getCurrentSiteUrl() + docid;
        }
        
    }
    
    private void updateHotContentLinks() {
        List<Partner_Portal_Hot_Content__c> settings = [ SELECT Content_Id__c, Order__c 
                                                           FROM Partner_Portal_Hot_Content__c 
                                                                ORDER BY Order__c ASC NULLS LAST ];
                  
        Integer upperBound = settings.size()<5 ? settings.size() : 5;
        hotContentLinks = new List<HotContentWrapper>();
        for (Integer i=0; i<upperBound && i<settings.size(); i++) {
            // skip those that are not found by incrementing upper bound, we won't exceed size so that works
            HotContentWrapper hc = new HotContentWrapper(settings[i]);
            if (hc.title != '[[ content not found ]]') {
                hotContentLinks.add(hc);
            } else {
                upperBound++;
            }
        }
                
    }   
    
    
    
    private void updateEventContentLinks() {
        List<Partner_Portal_Events_Webinars__c> settings = [ SELECT Event_Id__c, Order__c 
                                                               FROM Partner_Portal_Events_Webinars__c 
                                                                ORDER BY Order__c ASC NULLS LAST ];
                                                                
        Integer upperBound = settings.size()<5 ? settings.size() : 5;
        eventContentLinks = new List<HotContentWrapper>();
        for (Integer i=0; i<upperBound && i<settings.size(); i++) {
            // skip those that are not found by incrementing upper bound, we won't exceed size so that works
            HotContentWrapper hc = new HotContentWrapper(settings[i]);
            if (hc.title != '[[ content not found ]]') {
                eventContentLinks.add(hc);
            } else {
                upperBound++;
            }
        }
    }
    
    ////// END:   HOT CONTENT COMPONENT DATA


    /*public List<EventWebinarWrapper> eventLinks { get; set; }
    
    // we use the EventWebinarWrapper to manage the list of event/webinar links
    public class EventWebinarWrapper {
        Partner_Portal_Events_Webinars__c link;
        Event ev;
        
        public String title { get; set; }
        public String location { get; set; }
        public String description { get; set; }
        public String eventtype { get; set; }
        public String startdate { get; set; }
        public String url { get; set; }
        
        public EventWebinarWrapper(Partner_Portal_Events_Webinars__c ew) {
            link = ew;
            String eventid = link.Event_Id__c;
            List<Event> events = [ SELECT Subject, StartDateTime, Location, Description, Activity_Type__c 
                                      FROM Event 
                                     WHERE Id = :eventid ];
            if (events.size()>0) {
                ev = events[0];
                title = ev.Subject;
                location = ev.location;
                description = ev.Description;
                eventtype = ev.Activity_Type__c;
                startdate = String.valueOf(ev.StartDateTime);
            } else {
                title = '[[ event not found ]]';
                location = '';
                description = '';
                eventtype = '';
                startdate = '';
            }
            url = Site.getCurrentSiteUrl() + eventid;
        }
        
    }*/
    
    /*private void updateEventWebinarLinks() {
        List<Partner_Portal_Events_Webinars__c> settings = [ SELECT Event_Id__c, Order__c 
                                                               FROM Partner_Portal_Events_Webinars__c 
                                                                ORDER BY Order__c ASC NULLS LAST ];
        Integer upperBound = settings.size()<5 ? settings.size() : 5;
        eventLinks = new List<EventWebinarWrapper>();
        for (Integer i=0; i<upperBound && i<settings.size(); i++) {
            EventWebinarWrapper ew = new EventWebinarWrapper(settings[i]);
            // skip those that are not found by incrementing upper bound, we won't exceed size so that works
            if (ew.title != '[[ event not found ]]') {
                eventLinks.add(ew);
            } else {
                upperBound++;
            }
        }
    }*/

    ////// END:   EVENT/WEBINAR LINKS COMPONENT DATA
    
    ////// START: get a Blog post
    public Blog_Post__c selected_blog_post {get; set;}
    //// Get blog prefix
    public String blog_obj_prefix {get;set;}
        
    private void updateBlogPost() {
        blog_obj_prefix = (String)Blog_Post__c.SObjectType.getDescribe().getKeyPrefix();
        Blog_Post__c post;
        List<Blog_Post__c> blogpost = [ SELECT Id, Name, Blog_Content__c, Publication_Date__c, Expiration_Date__c, OwnerId 
                                        FROM Blog_Post__c 
                                        WHERE Home_Page_Flag__c=true ];
        if (blogpost.size()>0) {
            post = blogpost[0];
        } else {
            post=null;
        }
        if(post!=null){
            //TODO: find better way to get an excerpt i.e. there may be an image(s) inside the content
            // for example on all the sample posts an img tag takes up the first ~80 chars
            // images for the excerpt are hidden by css in the blog block on the partner portal home page
            String excerpt = getExcerpt(post.Blog_Content__c);
            post.Blog_Content__c = excerpt;
            selected_blog_post = post;
        }else{
            selected_blog_post = new Blog_Post__c();
            selected_blog_post.Name = '[[ blog post not found ]]';
            selected_blog_post.Blog_Content__c = '';
        }
    }
    //// END Blog Post Component Code
    
    //// START Video Component
    public Partner_Portal_Video__c spotlight_video {get;set;}
    //// Get Video Prefix
    public String video_obj_prefix {get;set;}
    private void updateVideo(){
        List<Partner_Portal_Video__c> videoSpotlight = [ SELECT Id, Video_Link__c, Title__c,Video_Type__c  
                                        FROM Partner_Portal_Video__c 
                                        WHERE Home_Page_Flag__c=true
                                         ];
        if (videoSpotlight.size()>0) {
            spotlight_video = videoSpotlight[0];
        }else{
            spotlight_video = new Partner_Portal_Video__c();
            spotlight_video.Title__c = 'No Videos Please click Link to go to Video Page';
            spotlight_video.Video_Link__c = '';
        }
        video_obj_prefix = (String)Partner_Portal_Video__c.SObjectType.getDescribe().getKeyPrefix();
    }
    
        
    private static String getExcerpt(String fullTest){
        if(fullTest == null) return '';
        String returnedExcerpt = fullTest.trim();
        
        if(returnedExcerpt.length() > 380){
            returnedExcerpt = returnedExcerpt.substring(0,380).trim();
        }
        
        return returnedExcerpt +'&hellip;' ;
    }
        
    //// END Video Component
    
    // CONTROLLER CONSTRUCTOR
 
    public PartnerPortalHomeController() {
        
        updateHotContentLinks();
        updateEventContentLinks();
        //updateEventWebinarLinks();
        updateBlogPost();
        updateVideo();
        
         events =  new List<Partner_Portal_Events__c>();
         events = [Select id,Name,Description__c,Header__c from Partner_Portal_Events__c where Active__c = true  order by Order__c];

    }
    

}