/*
Purpose: Created for inserting Partner Directory record. Controller behind PartnerDirectoryinsert VF page
Created By: Navaneetha Krishnan/Mukunthan K
Created On: 04-FEB-2018
*/

public class PartnerDirectoryinsert {

        public String  AccountName{get;set;} 
        public String id{get;set;}
        public string accId;
        
        public boolean isPDAvailable{get;set;}
        public string lat{get;set;}
        public string lng{get;set;}
        public boolean isInApproval{get;set;}
        public string partnerId{get;set;}
        
        public Partner_Directory_Staging__c partnerdir{get;set;}
        public Account acc{get;set;}
        public List<Partner_Directory_Staging__c> partnerDirList{get;set;}
        public List<Account> accList {get;set;}
        
        public PartnerDirectoryinsert() {
          
            accId = ApexPages.currentPage().getParameters().get('accid');
            isPDAvailable = false;
            partnerdir = new Partner_Directory_Staging__c();
            acc = new Account();
            partnerDirList = new List<Partner_Directory_Staging__c>();
            accList = new List<Account>();
            //fetchCountryFromPA(accId);
            fetchAccount(accId);
            partnerId = partnerDirList.size()>0?partnerDirList[0].Account__r.Id:accList[0].id;
            System.Debug('partId--->'+partnerId);
            isInApproval = partnerDirList.size()>0?Approval.isLocked(partnerDirList[0].Id):False;
            
        }
        
        //Save Button action
        public PageReference save() {     
         
            try{
                if(!isPDAvailable){
                    partnerdir.Account__c = acc.id;
                    partnerdir.Approval_Status__c = 'draft';
                    partnerdir.Longitude__c=lng;
                    partnerdir.Latitude__c=lat;
                    partnerdir.channel_Manager__c =  acc.OwnerId ;
                    partnerdir.Current_Requester__c = UserInfo.getUserId();
                    insert partnerdir;
                }
                else{
                    partnerdir.Approval_Status__c = 'draft';
                    partnerdir.Longitude__c=lng;
                    partnerdir.Latitude__c=lat;  
                    partnerdir.channel_Manager__c = partnerdir.Account__r.OwnerId;   
                    partnerdir.Current_Requester__c = UserInfo.getUserId();             
                    update partnerdir;
                }
                pageReference detPg = new pageReference('/apex/PartnerDirectoryinsert?accid='+partnerId);
                detPg.setRedirect(true);
                if(!string.isBlank(partnerId))
                    return detPg;
                else
                    return null;
                
            }
            catch(exception e){
                System.Debug('Error--->'+e.getMessage());
                System.Debug('LineNum--->'+e.getLineNumber());
                return null;
            }
        } 
         
        public void fetchAccount(string accountId){
            try{
                set<string> countryIds = new set<string>();
                partnerDirList = [Select Account__r.Name,Account__r.OwnerId , Account__r.SMART_Qualified__c,Partner_Country__c ,Account__r.Country__c,Account__r.PartnerType__c,Account__r.Partner_Tier__c,Account__r.Region__c,Latitude__c,Longitude__c ,Country_Territory__c,
                                    HQ_Address__c,Phone__c,Website__c,Company_Description__c,Region__c,   channel_Manager__c
                                    from Partner_Directory_Staging__c where Account__c=:accountId Limit 1];
                if(partnerDirList.size() == 0){
                    accList = [Select Name,SMART_Qualified__c,PartnerType__c,Country__c,Partner_Tier__c,Region__c,OwnerId from Account where Id=:accountId];
                    if(accList.size()>0){
                        acc = accList[0];
                       // partnerdir.Region1__c = acc.Region__c;
                    }
                }
                else{
                    partnerdir = partnerDirList[0];
                    isPDAvailable = true;
                }
                if(accountId != null){
                    List<Partner_Application__c> pApp = [Select Id,(select country__c from Partner_App_Categories_and_Countries__r LIMIT 75) from Partner_Application__c where Account__c =:accountId];
                    for(Partner_Application__c p:pApp){
                        for(Partner_Application_Category_and_Country__c pacc:p.Partner_App_Categories_and_Countries__r){
                            countryIds.Add(pacc.Country__c);
                        }
                    }
                    system.debug('CountryId--->'+countryIds);
                    if(partnerDirList.size()>0 && partnerDirList[0].Account__r.Country__c!=null){
                        countryIds.add(partnerDirList[0].Account__r.Country__c);
                    }
                    else if(accList.size()>0 && accList[0].Country__c!=null){
                        countryIds.add(accList[0].Country__c);
                    }
                    system.debug('CountryId--->'+countryIds);
                    set<string> dedupeCountries = new set<string>();
                    for(country__c c:[Select Name from Country__c where Id in:countryIds]){
                        dedupeCountries.add(c.Name);
                    }
                    
                   /*System.Debug('dedupeCountries--->'+dedupeCountries.size());
                    list<string> partnerCountries = new list<string>();
                    System.Debug('partnerdir--->'+partnerdir);
                    string test = 'India;Cuba';
                    partnerCountries = partnerdir.Country_Territory__c == null?new list<string>():partnerdir.Country_Territory__c.split(';');
                    dedupeCountries.addAll(partnerCountries);
                    partnerdir.Country_Territory__c = null;*/
                    //Commented
                    for(string cntry:dedupeCountries){
                        if(partnerdir.Partner_Country__c == null){
                        partnerdir.Partner_Country__c = cntry;}
                        else{
                            if(!partnerdir.Partner_Country__c.contains(cntry))
                            {
                            partnerdir.Partner_Country__c += ';' + cntry;
                            }
                        }
                    }
                    //System.debug('selectCountry--->'+partnerdir.Country_Territory__c);
                }
            }
            catch(exception e){
                System.Debug('Error--->'+e.getMessage());
                System.Debug('LineNum--->'+e.getLineNumber());
            }
                
        }

        public List<SelectOption> getCountryList(){
            List<SelectOption> countryLst = new List<SelectOption>();
                       
            Schema.DescribeFieldResult fieldResult = Partner_Directory_Staging__c.Country_Territory__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
            for( Schema.PicklistEntry f : ple){
                countryLst.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
            return countryLst;
        }
        
        public PageReference cancelAction(){
            PageReference pg = new PageReference('/partner/Home');
            return pg;
        }
    }