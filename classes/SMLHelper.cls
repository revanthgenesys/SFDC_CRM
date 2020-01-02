//Naresh Kumar  10/01/2015
public with sharing class SMLHelper {
    public static final String NA = 'na';
    public static final String ACTIVE = 'Active';
    public static final String BLOCKED = 'Blocked';
    public static final String SOLD = 'Sold';
    public static final String NEXT_BEXT_ACTION = 'Next Best Action';
    public static final String PLANNING_UNDERWAY = 'Planning Underway';
    public static final String POSITIVE = 'POSITIVE';
    public static final String NEGATIVE = 'NEGATIVE';
    public static final String ACTIVEANDSOLD = 'Sold/Active';
    public static final String WHITESPACE = 'Whitespace';
    public static final String SOLD_NO_MAINTENANCE = 'Sold no Maintenance';    
    public static final String SML_ACTIVITY_STATUS_OPENED_SML = 'Opened SML';
    public static final String SML_ACTIVITY_STATUS_CLICKED_CELL = 'Clicked Cell';
    public static final String whileInitData = 'While Initialzing Data';
    public static final String whileRemovingDeletedReference = 'While Remvoing Deleted References';
    public static final String whileUpdatingSMLDataFromQuotes = 'While Updating SML Data from Quotes';
    public static final String whileUpdatingSMLDataFromOpps = 'While Updating SML Data from Opportunities';
    public static final String whileUpdatingSMLDataFromOrders = 'While Updating SML Data from Orders';
    public static final String whileUpdatingCompetitorInfo = 'While Updating competitor info';
    public static final String whileCalculatingEngagementScore = 'While Calculating engagement score';
    public static final String whileRunningBatch = 'While running batch';
    public static final String whileUpdatingUnderMaint = 'While updating under maintenance';
    public static final String whileUpdatingActiveOpps = 'While updating active opportunities';
    public static final String whileMakingFinalUpdateWS = 'While making final update for white space cells';
    public static final String whileMakingFinalUpdateNWS = 'While making final update for non white space cells';
    public static final String OPP_STAGE_CLOSED = '6.Closed';
    public static final String ORDER_STATUS_COMPLETED = 'Completed';
    public static final String ORDER_STATUS_APPROVED = 'Approved';
    public static final String ORDER_STATUS_SEND_TO_ERP = 'Send to ERP';
    
    public static String updateCategoryToMultiline(String category){
        if(category == 'Mobile Engagement')
            return 'Mobile<br/>Engagement';
        if(category == 'Proactive Notification')
            return 'Proactive<br/>Notification';
        if(category == 'Interaction Analytics')
            return 'Interaction<br/>Analytics';
        if(category == 'Proactive Notification')
            return 'Proactive<br/>Notification';
        if(category == 'Proactive Notification')
            return 'Proactive<br/>Notification';
        if(category == 'Proactive Notification')
            return 'Proactive<br/>Notification';
        if(category == 'Interaction Recording')
            return 'Interaction<br/>Recording'; 
        if(category == 'Quality Management')
            return 'Quality<br/>Management';
        if(category == 'Conversation Manager')
            return 'Conversation<br/>Manager';
        return category;
    }
    
    public static String updateCategoryToSingleline(String category){
        if(category == 'Mobile<br/>Engagement')
            return 'Mobile Engagement';
        if(category == 'Proactive<br/>Notification')
            return 'Proactive Notification';
        if(category == 'Interaction<br/>Analytics')
            return 'Interaction Analytics';
        if(category == 'Proactive<br/>Notification')
            return 'Proactive Notification';
        if(category == 'Proactive<br/>Notification')
            return 'Proactive Notification';
        if(category == 'Proactive<br/>Notification')
            return 'Proactive Notification';
        if(category == 'Interaction<br/>Recording')
            return 'Interaction Recording'; 
        if(category == 'Quality<br/>Management')
            return 'Quality Management';
        if(category == 'Conversation<br/>Manager')
            return 'Conversation Manager';
        return category;
    }
    
    
    
    public static Map<String, Integer> getSolutionCategoryEngagementScore(Map<String, List<SML_Data__c>> smlCategoryVsData, Integer totalSize, Set<String> solutionCategories1, Map<String, String> mapCategoryVsScoreColor){
        Map<String, Integer> mapCategoryVsScores = new Map<String, Integer>();        
        Integer counter = 0;
        Integer colorIndex = 0;
        //Looping over each category
        for(String eachCategory : solutionCategories1){
            //Fill the blanks
            if(smlCategoryVsData.get(eachCategory) == null){
                SML_Data__c newSMLData = new SML_Data__c();
                List<SML_Data__c> newList = new List<SML_Data__c>();
                newList.add(newSMLData);
                smlCategoryVsData.put(eachCategory, newList);
            }
            System.debug('NKC debug eachCategory [' + eachCategory + ']');
            String category = updateCategoryToMultiline(eachCategory);
            List<SML_Data__c> smlData = smlCategoryVsData.get(category);
            counter ++;
            Integer noOfNA = 0, noOfActive = 0, noOfBlocked = 0, noOfSold = 0, noOfWhiteSpace = 0, noOfSoldActive = 0, noPlanningUnderway = 0;
            //Looping over each reocrd
            for(SML_Data__c eachData : smlData){
                System.debug('NKC debug eachData.Status__c [' + eachData.Status__c + ']');
                System.debug('NKC debug smlData [' + smlData + ']');
                if(eachData.Status__c == NA)
                    noOfNA ++;
                else if(eachData.Status__c == ACTIVE)
                    noOfActive ++;
                else if(eachData .Status__c == SOLD)
                    noOfSold ++;
                else if(eachData .Status__c == BLOCKED)
                    noOfBlocked ++;
                else if(eachData.Status__c == ACTIVEANDSOLD)                    
                    noOfSoldActive ++;                
                else if(eachData.Status__c == SMLHelper.PLANNING_UNDERWAY) 
                        noPlanningUnderway ++;
                //else 
                //    noOfWhiteSpace ++;              
            }                    
            //According to formula given by pushpa
            Decimal b = totalSize - (noOfNA + noOfBlocked);
            Decimal c = noOfActive + noOfSold + noOfSoldActive + ( noPlanningUnderway == 0 ? 0 : (noPlanningUnderway * 0.5)); 
            Decimal engagementScoreD = 0;
            Integer whiteSpaceScore = 0;
            if(b > 0){
                engagementScoreD = (c * 100) / b;
                //whiteSpaceScore = (whiteSpaceScore * 100) / b;
            }
            //System.debug('NKC debug whiteSpaceScore [' + whiteSpaceScore + ']');
            Integer engagementScore = Integer.valueOf(engagementScoreD.round(System.RoundingMode.HALF_UP));
            //List<Integer> scores = new List<Integer>();
            //scores.add(engagementScore);
            //scores.add(whiteSpaceScore);
            mapCategoryVsScores.put(eachCategory, engagementScore);      
            String color = 'red';
            if(engagementScore >= 50)
                color = 'orange';
            if(engagementScore >= 70)
                color = 'green';
            mapCategoryVsScoreColor.put(eachCategory, color);    
        } 
        return mapCategoryVsScores;
    }
    
    public static List<Integer> getAccountEngagementScore(Map<String, SML_Data__c> smlCategoryVsData){
        List<SML_Data__c> smlData = smlCategoryVsData.values();
        //Total # of categories
        Integer totalSize = smlData.size();
        Integer noOfNA = 0, noOfActive = 0, noOfBlocked = 0, noOfSold = 0, noOfWhiteSpace = 0, noOfSoldActive = 0;
        //Looping over each reocrd
        for(SML_Data__c eachData : smlData){
            if(eachData.Status__c == NA)
                noOfNA ++;
            else if(eachData.Status__c == ACTIVE)
                noOfActive ++;
            else if(eachData.Status__c == SOLD)
                noOfSold ++;
            else if(eachData.Status__c == BLOCKED)
                noOfBlocked ++;
            else if(eachData.Status__c == ACTIVEANDSOLD) 
                noOfSoldActive ++;
            else
                noOfWhiteSpace ++;              
        }
               
        //According to formula given by pushpa
        Integer b = totalSize - (noOfNA + noOfBlocked);
        Integer c = noOfActive + noOfSold + noOfSoldActive; 
        Integer engagementScore = 0;
        Integer whiteSpaceScore = 0;
        if(b > 0){
            engagementScore = (c * 100) / b;
            whiteSpaceScore = (whiteSpaceScore * 100) / b;
        }
        /*
        System.debug('NKC debug b [' + b + ']');
        System.debug('NKC debug c [' + c + ']');
        System.debug('NKC debug engagementScore [' + engagementScore  + ']');
        System.debug('NKC debug whiteSpaceScore [' + whiteSpaceScore + ']');
        */
        List<Integer> scores = new List<Integer>();
        scores.add(engagementScore);
        scores.add(whiteSpaceScore);
        return scores;        
    }
    
    public static List<SelectOption> populateAccountFilters(Boolean isNonManager ){
        Boolean isViewAdmin = false;
        List<String> viewAdminIds = Label.SML_View_Admins.split(';');
        List<User> viewAdmins = [SELECT id FROM User WHERE id =: UserInfo.getUserId() AND (id IN : viewAdminIds OR profileId =: viewAdminIds)];
        if(!viewAdmins.isEmpty()){
            isViewAdmin = true;    
        }
        List<SelectOption> optionList = new List<SelectOption>();
        List<String> hideMyAccountForUsers = Label.SML_Exclude_My_Accounts_For_User_Profiles.split(';');
        List<User> hideMyAccountUser = [SELECT id FROM User WHERE id =: UserInfo.getUserId() AND (id IN : hideMyAccountForUsers OR profileId =: hideMyAccountForUsers)];
        SelectOption newOption;
        if(hideMyAccountUser.isEmpty()){
            newOption = new SelectOption('My Accounts', 'My Accounts');
            optionList.add(newOption);
        }       
        else{
            newOption = new SelectOption('Customer Crosssell', 'Customer Crosssell');
            optionList.add(newOption);
        } 
        if(!isNonManager){
            newOption = new SelectOption('My Team', 'My Team');
            optionList.add(newOption);
        }
        if(isViewAdmin){
            newOption = new SelectOption('All Accounts', 'All Accounts');
            optionList.add(newOption);
        }
        List<SML_Search_View__c> smlSearchViews = [SELECT id, Name FROM SML_Search_View__c WHERE ownerId =: UserInfo.getUserId() ORDER BY CreatedDate DESC];
        for(SML_Search_View__c eachView : smlSearchViews){
            newOption = new SelectOption(eachView.id, eachView.Name);
            optionList.add(newOption);    
        }
        return optionList;
    }
    
    public static List<SelectOption> populateCountries(){
        List<SelectOption> countries = new List<SelectOption>();
        SelectOption newOption = new SelectOption('', '--Select--');
        countries.add(newOption);
        for(Country__c eachCountry : [SELECT id, Name FROM Country__c ORDER BY Name]){
            newOption = new SelectOption(eachCountry.id, eachCountry.Name);
            countries.add(newOption);
        }
        return countries;
    }
    //08/26/2016 Naresh Kumar   Checks whether the current user belongs to be skipped admin group
    public static Boolean isCurrentUserAdminToBeSkipped(){
        List<String> toBeSkippedAdmins = Label.SML_Admins_To_Be_Skipped.split(';');
        List<User> toBeSkippedAdminsUsers = [SELECT id FROM User WHERE id =: UserInfo.getUserId() AND (id IN : toBeSkippedAdmins OR profileId =: toBeSkippedAdmins)];
        if(toBeSkippedAdminsUsers.isEmpty())
            return false;
        else
            return true;            
    }
}