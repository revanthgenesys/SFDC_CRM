public without sharing class HomeController{
    
    public Map<String,User> usrList{get;set;}
    public List<ContentVersion> contentList{get;set;}
    public List<ContentVersion> whatsNewList{get;set;}
    
    public List<ContentVersion> favContentList{get;set;}
    public List<String> headerNameList{get;set;}
    public Boolean blockVideo {get; set;}
    
    public String partnerType{get;set;}
    public String partnerRegion='';
    public Boolean designatedPartner=false;
    public Boolean allowPartnerType=false;
    public string usrAcntName{get;set;}
    public string category{get;set;}
    public string tier{get;set;}
    public string offrtype{get;set;}
    public string pcPartnerTier{get;set;}
    public string sapCode{get;set;}
    
    private list<Partner_Portal_Announcement__c> announcementsList = new list<Partner_Portal_Announcement__c>();
    
   
    public HomeController(){
             
        User usr = [SELECT Id,Name,Email,Phone,MobilePhone,FullPhotoUrl,Title,
                    Contact.Account.OwnerId,Contact.Account.Owner.ManagerId, 
                    Block_Partner_Welcome_Video__c, ContactId 
                    FROM User WHERE Id =: UserInfo.getUserId()];

        blockVideo = usr.Block_Partner_Welcome_Video__c; 
        
        Contact userContact = [Select AccountId,Designated_Partner_Contact__c from Contact where id =:usr.ContactId ];
        
        Account userAcnt = [Select Name,SAP_Code__c,Country__r.Name, PartnerType__c,Country__r.Region__c,Tier__c,Partner_Tier__c,
                            Partner_Category__c,Partner_Offering_Type__c,PureCloud_Partner_Tier__c,SAP_Account_Code__c from Account where id=:userContact.AccountId]; 
                            
        partnerType = userAcnt.PartnerType__c!=null?userAcnt.PartnerType__c:'';
        partnerRegion = userAcnt.Country__r.Region__c!=null?userAcnt.Country__r.Region__c:'';
        designatedPartner = userContact.Designated_Partner_Contact__c;
        usrAcntName = userAcnt.Name!=null?userAcnt.Name:'';
        category = userAcnt.Partner_Category__c!=null?userAcnt.Partner_Category__c:'';
        tier = userAcnt.Partner_Tier__c!=null?userAcnt.Partner_Tier__c:'';
        offrtype = userAcnt.Partner_Offering_Type__c!=null?userAcnt.Partner_Offering_Type__c:'';
        sapCode = userAcnt.SAP_Account_Code__c!=null?userAcnt.SAP_Account_Code__c:'';
        
        if ( offrtype != null && offrtype.contains('PureCloud') )
            pcPartnerTier = userAcnt.PureCloud_Partner_Tier__c;
        
        
        System.debug('partnerType:'+partnerType);
        System.debug('partnerRegion: '+partnerRegion);
        System.debug('designatedPartner: '+designatedPartner);
        
        usrList = new Map<String,User>{'Portal User' => usr};
        
        headerNameList = new List<String>{'Portal User'};
        
        //check Partner Type
        allowPartnerType = checkPartnerType(partnerType);
        
        System.debug(usr.Contact.Account.OwnerId);
       
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Name,Email,Phone,MobilePhone,FullPhotoUrl,Title 
                                                    FROM User WHERE Id =: usr.Contact.Account.OwnerId OR Id =: usr.Contact.Account.Owner.ManagerId]);
        
        if(userAcnt.PartnerType__c != 'Technology Partner' && userMap.containsKey(usr.Contact.Account.OwnerId)){
            usrList.put('Channel Manager',userMap.get(usr.Contact.Account.OwnerId));
            headerNameList.add('Channel Manager');

            ///APAC specific
            if ( partnerRegion == 'APAC' ) {
                try {
                    String apacMgrId = Partner_Regional_Channel_Manager__c.getInstance('APAC').Manager_UserId__c;
                    
                    if ( apacMgrId != null ) {
                        List<User> apacmgr = [SELECT Id,Name,Email,Phone,MobilePhone,FullPhotoUrl,Title FROM User WHERE Id =:apacMgrId];
                        if ( !apacmgr.isEmpty() ) {
                           usrList.put('Regional Channel Manager', apacmgr[0]); 
                           headerNameList.add('Regional Channel Manager');  
                        }
                    }             
                }
                catch(Exception ex) {}              
            }
            else if(userMap.containsKey(usr.Contact.Account.Owner.ManagerId)){
                usrList.put('Regional Channel Manager',userMap.get(usr.Contact.Account.Owner.ManagerId)); 
                headerNameList.add('Regional Channel Manager');   
            }
        }

        PortalHomeDefaults__c pHomeDefaults = PortalHomeDefaults__c.getInstance(UserInfo.getOrganizationId());
        Integer contentListSize =0;
        if(pHomeDefaults.Id == null){
            pHomeDefaults.ContentListSize__c = 10;
            contentListSize = Integer.valueOf(pHomeDefaults.ContentListSize__c);   
        }
        else{ 
            contentListSize = Integer.valueOf(pHomeDefaults.ContentListSize__c);
        }
         
        contentList = [SELECT Id,Content_Type__c,Region__c,Title,Description,ContentModifiedDate FROM ContentVersion WHERE IsLatest = true ORDER BY ContentModifiedDate DESC LIMIT : contentListSize];
       
        whatsNewList = new List<ContentVersion>();
       
        for (ContentVersion cv : contentList) {
            
            System.debug('WhatsNew Content_Type__c : '+ cv.Content_Type__c);
            System.debug('WhatsNew allowPartnerType : '+ allowPartnerType);
            System.debug('WhatsNew designatedPartner : '+ designatedPartner);
            System.debug('WhatsNew Region__c: '+ cv.Region__c);
            
            //Logic added to show only Pricing Guides for specific regions and avoid invalid Partners
            if((cv.Content_Type__c != 'Pricing Guides' && cv.Content_Type__c != 'Program Guide') || (allowPartnerType && (cv.Content_Type__c =='Pricing Guides' || cv.Content_Type__c =='Program Guide') && designatedPartner && (cv.Region__c.containsIgnoreCase(partnerRegion) || cv.Region__c.containsIgnoreCase('Global') ))) {
                    whatsNewList.add(cv);
                    System.debug('Actual WhatsNew Content_Type__c : '+ cv.Content_Type__c);
             }
         
         }
       
        List<Favorite_Content__c> favoriteContentList = [SELECT name,Content_Version_Id__c,User_Id__c,RatingCount__c FROM Favorite_Content__c
                                WHERE User_Id__c =: usr.Id AND RatingCount__c = 'Positive Rating Count' LIMIT : 10]; 
       
        List<String> favoriteId = new List<String>();                     
        for(Favorite_Content__c favCon : favoriteContentList){
            favoriteId.add(favCon.Content_Version_Id__c);
            favContentList = [SELECT Id,Title,Description,ContentModifiedDate FROM ContentVersion Where Id =: favoriteId];            
        }
        
    }
    
    /* Method is used to validate if Account Partner Type is part of allowed Partner Types for which Pricing Guides will be visible.*/
    public boolean checkPartnerType(String partnerType) {
        /*
        Set<String> validPartnerTypes = new Set<String>{'VARs','Specialized Reseller','Cloud Partner','Managed Services Provider','Contract Reseller'};
        
        if(partnerType!=null && partnerType!=''){
            for(String indv : partnerType.split(';')){
                if(validPartnerTypes.contains(indv)){
                    return true;
                }
            }
        }
        return false;
        */
        Boolean isValid = false;
        List<Partner_Portal_Deal_Registration_Config__c> partnerConfig = Partner_Portal_Deal_Registration_Config__c.getall().values();
        for(Partner_Portal_Deal_Registration_Config__c ppdr: partnerConfig){
            if(partnerType.contains(ppdr.Name)){
                isValid = true;
            }
        }
        return isValid;
    }
    
    public list<Partner_Portal_Announcement__c> getannouncementsList(){
        for(Partner_Portal_Announcement__c rec : [Select Id,name,type__c,title__c,description__c,image__c from Partner_Portal_Announcement__c]){
            if(rec.type__c!=null && rec.type__c.equalsIgnoreCase('Banner'))
                announcementsList.add(rec);
        }
        return announcementsList;
    }
    
}