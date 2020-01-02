//Naresh Kumar  09/20/2016
public without sharing class SMLNBABatchHelper {

    public static void populateNBAStatus(Id accountId){
        List<SML_Data__c> smlData = [SELECT Solution_Category__c, Solution_Category__r.Name, Status__c FROM SML_Data__c 
            WHERE Account__c =: accountId AND Solution_Category__r.Name NOT IN ('Knowledge Center', 'Nuance', 
            'Proactive Notification', 'SMS', 'Speechstorm', 'Virtual Hold', 'Web Callback', 'Web Engagement', 'Video Gateway')];  
        
        Map<String, SML_Data__c> mapOfCategoryIdVsSMLData = new Map<String, SML_Data__c>();
        Map<String, String> mapOfCategoryNameVsStatus = new Map<String, String>();
        Map<String, SML_Data__c> mapOfCategoryIdVsSMLDataWNBAOnly = new Map<String, SML_Data__c>();
        
        //Looping over sml data and creating set of available categories.
        for(SML_Data__c eachSMLData : smlData){
            System.debug('NKC debug eachSMLData [' + eachSMLData + ']');
            mapOfCategoryIdVsSMLData.put(eachSMLData.Solution_Category__c, eachSMLData);
            mapOfCategoryNameVsStatus.put(eachSMLData.Solution_Category__r.Name, eachSMLData.Status__c);
            if(eachSMLData.Status__c == 'Whitespace' || eachSMLData.Status__c == 'Next Best Action'){
                mapOfCategoryIdVsSMLDataWNBAOnly.put(eachSMLData.Solution_Category__c, eachSMLData);                
            }
        }
         
        Map<Id, Solution_Category__c> mapOfIdVsProductCategories = new Map<Id, Solution_Category__c>([SELECT id, Name FROM 
            Solution_Category__c WHERE Active__c = true AND ID IN : mapOfCategoryIdVsSMLData.keyset()]);
        System.debug('NKC debug mapOfIdVsProductCategories [' + mapOfIdVsProductCategories + ']');
        
        List<ContractLineItem> contractLineItems = [SELECT ServiceContract.AccountId, PricebookEntry.Product2.Solution_Category1__c,
            PricebookEntry.Product2.Environment__c, Quantity, PricebookEntry.Product2.Solution_Category__c,
            PricebookEntry.Product2.Solution_Category1__r.Name FROM ContractLineItem 
            WHERE ServiceContract.Agreement_Status__c = 'Active' AND ServiceContract.AccountId =: accountId
            AND PricebookEntry.Product2.Solution_Category1__c IN : mapOfCategoryIdVsSMLData.keyset()];
        
        System.debug('NKC debug contractLineItems [' + contractLineItems + ']');
        
        Map<String, List<ContractLineItem>> mapOfProductCategoryVsCLIs = new Map<String, List<ContractLineItem>>();
        Map<String, List<ContractLineItem>> mapOfSolutionCategoryVsCLIs = new Map<String, List<ContractLineItem>>();
        Decimal seatsInAllCategoriesExceptIWD = 0;
        Decimal seatsInInboundVoice = 0;
        Decimal seatsInOutboundVoice = 0;
        Decimal seatsInDigitalSolutionCategory = 0;     
        Boolean hasMobileEngagementAgent = false;   
        
        //Looping over each contract line
        for(ContractLineItem eachCLI : contractLineItems){
            //Skip line item if contains any keyword
            if(SMLBatchHelper.doExcludeProduct(eachCLI.PricebookEntry.Product2.Environment__c))
                continue;           

            //Product category
            String productCategory = eachCLI.PricebookEntry.Product2.Solution_Category1__r.Name;
            if(mapOfProductCategoryVsCLIs.get(productCategory) == null){
                List<ContractLineItem> newList = new List<ContractLineItem>();
                newList.add(eachCLI);
                mapOfProductCategoryVsCLIs.put(productCategory, newList);
            }
            else{
                mapOfProductCategoryVsCLIs.get(productCategory).add(eachCLI);
            }
            //Solution category
            String solutionCategory = eachCLI.PricebookEntry.Product2.Solution_Category__c;
            if(mapOfsolutionCategoryVsCLIs.get(solutionCategory) == null){
                List<ContractLineItem> newList = new List<ContractLineItem>();
                newList.add(eachCLI);
                mapOfsolutionCategoryVsCLIs.put(solutionCategory, newList);
            }
            else{
                mapOfsolutionCategoryVsCLIs.get(solutionCategory).add(eachCLI);
            }
            //Seats in all categories except iWD
            if(eachCLI.PricebookEntry.Product2.Solution_Category1__r.Name != 'iWD'){
                //seatsInAllCategoriesExceptIWD += (eachCLI.Quantity == null ? 0 : eachCLI.Quantity);
                Decimal quantity = (eachCLI.Quantity == null ? 0 : eachCLI.Quantity);
                if(seatsInAllCategoriesExceptIWD < quantity){
                    seatsInAllCategoriesExceptIWD = quantity;
                }     
            }
            //Seats in Inbound Voice
            if(eachCLI.PricebookEntry.Product2.Solution_Category1__r.Name == 'Inbound Voice'){
                seatsInInboundVoice += (eachCLI.Quantity == null ? 0 : eachCLI.Quantity);     
            }
            //Seats in Outbound Voice
            if(eachCLI.PricebookEntry.Product2.Solution_Category1__r.Name == 'Outbound Voice'){
                seatsInOutboundVoice += (eachCLI.Quantity == null ? 0 : eachCLI.Quantity);     
            }            
            //If Account has Mobile Engagement - Agent
            if(eachCLI.PricebookEntry.Product2 != null &&
                String.valueOf(eachCLI.PricebookEntry.Product2).contains(Label.SML_NBA_Logic_Products.split(';')[0])){
                hasMobileEngagementAgent = true;    
            }
            //
            if(eachCLI.PricebookEntry.Product2.Solution_Category__c == 'Digital'){
                seatsInDigitalSolutionCategory += (eachCLI.Quantity == null ? 0 : eachCLI.Quantity);     
            }
        }
        
        Boolean hasChat = false;
        Boolean hasEmail = false;
        Boolean hasDesktop = false;
        Boolean hasMobileEngagement = false;
        Boolean hasConversationManager = false;
        Boolean hasOmnichannelAnalytics = false;
        Boolean hasSIP = false;
        Boolean hasOutboundVoice = false;
        Boolean hasCIM = false;
        Boolean hasInfoMart = false;
        Boolean hasFramework = false;
        Boolean hasSocial = false;
        Boolean hasInteractionRecording = false;
        Boolean hasRecordingConnectors = false;
        Boolean hasInboundVoice = false;
        Boolean hasGVP = false;
        Boolean hasDigital = false;
        Boolean hasIWD = false;        
        Boolean hasInteractiveInsights = false;
        
        System.debug('NKC debug ' + mapOfCategoryNameVsStatus.get('Desktop'));
        System.debug('NKC debug ' + mapOfCategoryNameVsStatus);
        
        if(mapOfProductCategoryVsCLIs.get('Chat') != null && mapOfCategoryNameVsStatus.get('Chat') != 'Blocked')
            hasChat = true;
        if(mapOfProductCategoryVsCLIs.get('Email') != null && mapOfCategoryNameVsStatus.get('Email') != 'Blocked')
            hasEmail = true;
        if(mapOfProductCategoryVsCLIs.get('Desktop') != null && mapOfCategoryNameVsStatus.get('Desktop') != 'Blocked')
            hasDesktop = true;
        if(mapOfProductCategoryVsCLIs.get('Mobile Engagement') != null && mapOfCategoryNameVsStatus.get('Mobile Engagement') != 'Blocked')
            hasMobileEngagement = true;
        if(mapOfProductCategoryVsCLIs.get('Conversation Manager') != null && mapOfCategoryNameVsStatus.get('Conversation Manager') != 'Blocked')
            hasConversationManager = true;
        if(mapOfProductCategoryVsCLIs.get('Omnichannel Analytics') != null && mapOfCategoryNameVsStatus.get('Omnichannel Analytics') != 'Blocked')
            hasOmnichannelAnalytics = true;
        if(mapOfProductCategoryVsCLIs.get('SIP') != null && mapOfCategoryNameVsStatus.get('SIP') != 'Blocked')
            hasSIP = true;
        if(mapOfProductCategoryVsCLIs.get('Outbound Voice') != null && mapOfCategoryNameVsStatus.get('Outbound Voice') != 'Blocked')
            hasOutboundVoice = true;
        if(mapOfProductCategoryVsCLIs.get('CIM') != null && mapOfCategoryNameVsStatus.get('CIM') != 'Blocked')
            hasCIM = true;
        if(mapOfProductCategoryVsCLIs.get('InfoMart') != null && mapOfCategoryNameVsStatus.get('InfoMart') != 'Blocked')
            hasInfoMart = true;
        if(mapOfProductCategoryVsCLIs.get('Framework') != null && mapOfCategoryNameVsStatus.get('Framework') != 'Blocked')
            hasFramework = true;
        if(mapOfProductCategoryVsCLIs.get('Social') != null && mapOfCategoryNameVsStatus.get('Social') != 'Blocked')
            hasSocial = true;
        if(mapOfProductCategoryVsCLIs.get('Interaction Recording') != null && mapOfCategoryNameVsStatus.get('Interaction Recording') != 'Blocked')
            hasInteractionRecording = true;
        if(mapOfProductCategoryVsCLIs.get('Recording Connectors') != null && mapOfCategoryNameVsStatus.get('Recording Connectors') != 'Blocked')
            hasRecordingConnectors = true;
        if(mapOfProductCategoryVsCLIs.get('Inbound Voice') != null && mapOfCategoryNameVsStatus.get('Inbound Voice') != 'Blocked')
            hasInboundVoice = true;
        if(mapOfProductCategoryVsCLIs.get('GVP') != null && mapOfCategoryNameVsStatus.get('GVP') != 'Blocked')
            hasGVP = true;
        if(mapOfSolutionCategoryVsCLIs.get('Digital') != null && mapOfCategoryNameVsStatus.get('Digital') != 'Blocked')
            hasDigital = true;
        if(mapOfSolutionCategoryVsCLIs.get('iWD') != null && mapOfCategoryNameVsStatus.get('iWD') != 'Blocked')
            hasIWD = true;
        if(mapOfSolutionCategoryVsCLIs.get('Interactive Insights') != null && mapOfCategoryNameVsStatus.get('Interactive Insights') != 'Blocked')
            hasInteractiveInsights = true;
        
        System.debug('NKC debug hasChat [' + hasChat + ']');
        System.debug('NKC debug hasEmail [' + hasEmail + ']');
        System.debug('NKC debug hasDesktop [' + hasDesktop + ']');
        System.debug('NKC debug hasMobileEngagement [' + hasMobileEngagement + ']');
        System.debug('NKC debug hasConversationManager [' + hasConversationManager + ']');
        System.debug('NKC debug hasOmnichannelAnalytics [' + hasOmnichannelAnalytics + ']');
        System.debug('NKC debug hasSIP [' + hasSIP + ']');
        System.debug('NKC debug hasOutboundVoice [' + hasOutboundVoice + ']');
        System.debug('NKC debug hasCIM [' + hasCIM + ']');
        System.debug('NKC debug hasInfoMart [' + hasInfoMart + ']');
        System.debug('NKC debug hasFramework [' + hasFramework + ']');
        System.debug('NKC debug hasSocial [' + hasSocial + ']');
        System.debug('NKC debug hasInteractionRecording [' + hasInteractionRecording + ']');
        System.debug('NKC debug hasInboundVoice [' + hasInboundVoice + ']');
        System.debug('NKC debug hasGVP [' + hasGVP + ']');
        System.debug('NKC debug hasDigital [' + hasDigital + ']');
        System.debug('NKC debug hasIWD [' + hasIWD + ']');
        System.debug('NKC debug hasCIM [' + hasCIM + ']');
        System.debug('NKC debug hasInteractiveInsights [' + hasInteractiveInsights + ']');
        System.debug('NKC debug hasMobileEngagementAgent [' + hasMobileEngagementAgent + ']');
        System.debug('NKC debug seatsInAllCategoriesExceptIWD [' + seatsInAllCategoriesExceptIWD + ']');
        
        List<SML_Data__c> listOfSMLDataToBeUpdated = new List<SML_Data__c>();
        
        //Looping over each category 
        
        for(Id eachCategoryId : mapOfCategoryIdVsSMLDataWNBAOnly.keyset()){         
            Solution_Category__c eachCategory = mapOfIdVsProductCategories.get(eachCategoryId);
            System.debug('NKC debug eachCategory.Name [' + eachCategory.Name + ']');
            //iWD - if (Account has any other product category > 200 seats)
            if(eachCategory.Name == 'iWD' && seatsInAllCategoriesExceptIWD > 200){
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);               
            }
            //Chat
            /*
            if (Account has Email) OR (Account has Desktop) 
            OR ((Account has Product where Product.Solution Category = "Digital") AND (Account does not have Chat) 
            AND (Account does not have Email) AND (Account does not have Mobile Engagement) 
            AND (Account does not have Conversation Manager))
            */
            else if(eachCategory.Name == 'Chat' && (hasEmail || hasDesktop) || (hasDigital && !hasChat 
                && !hasEmail && !hasMobileEngagement && !hasConversationManager )){
                System.debug('NKC debug INSIDE CHAT '); 
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Email
            /*
            if (Account has Omnichannel Analytics) OR (Account has Chat) OR 
            ((Account has Desktop) AND ((Account has SIP) OR (Account has Outbound Voice) OR (Account has Other Miscellaneous))
            */
            else if(eachCategory.Name == 'Email'
                && (hasOmnichannelAnalytics || hasChat || (hasDesktop && (hasSIP || hasOutboundVoice 
                || mapOfProductCategoryVsCLIs.get('Other Miscellaneous') != null)))){
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }   
            //GVP
            /*
            if (Account has Email) OR (Account has Chat) OR (Account has SIP)
            */
            else if(eachCategory.Name == 'GVP' && (hasEmail || hasChat || hasSIP )){
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }   
            //Mobile Engagement
            //If (Account has CIM) AND (Account does not have Chat)
            else if(eachCategory.Name == 'Mobile Engagement' && (hasCIM && !hasChat)){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Outbound Voice
            /*
            If (((Account has CIM) OR (Account has InfoMart)) AND Inbound Voice > 200 seats)) OR (Account has Email) OR (Account has Chat)
            */
            else if(eachCategory.Name == 'Outbound Voice' && ((((hasCIM || hasInfoMart)  && seatsInInboundVoice > 200) || hasEmail || hasChat ) 
                || hasEmail || hasChat)){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Social
            //If (Account has Chat) OR (Account has E-Mail) OR (Account has Mobile Engagement - Agent)
            else if(eachCategory.Name == 'Social' && (hasChat || hasEmail || hasMobileEngagementAgent)){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Web Collaboration
            //If (Account has Chat)
            else if(eachCategory.Name == 'Web Collaboration' && (hasChat)){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Interaction Analytics
            //If (Account has Interaction Recording)
            else if(eachCategory.Name == 'Interaction Analytics' && (hasInteractionRecording)){ 
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Interaction Recording
            //if ((Account has SIP) AND (Account has Desktop))
            else if(eachCategory.Name == 'Interaction Recording' && hasSIP && hasDesktop){                               
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Quality Management
            //If (Account has Interaction Recording)
            else if(eachCategory.Name == 'Quality Management' && hasInteractionRecording){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //WFM
            /*
            if (Account has Inbound Voice> 200 seats) OR (Account has Product where Product.Solution Category = "Digital" > 200 seats) 
            OR (Account has Outbound Voice > 200 seats) OR (Account has Inbound Voice AND has  is) 
            OR ((Account has Product where Product.Solution Category = "Digital") AND Workforce Management Adapters)) 
            OR (Account has Outbound Voice AND Workforce Management Adapters)
            */
            else if(eachCategory.Name == 'WFM' && (seatsInInboundVoice > 200 || seatsInDigitalSolutionCategory > 200 || seatsInOutboundVoice > 200
                || (hasInboundVoice /* && Workforce Management Adapters*/) || (hasOutboundVoice /* && Workforce Management Adapters*/))){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //SIP
            /*
            If (Account has Inbound Voice) OR (Account has Outbound Voice) OR (Account has CIM) OR (Account has GVP) 
            OR ((Account has Product where Product.Solution Category = "Digital") OR (Account has iWD))
            */
            else if(eachCategory.Name == 'SIP' && (hasInboundVoice || hasOutboundVoice || hasCIM || hasGVP || (hasDigital || hasIWD ))){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //InfoMart
            //If (Account has Interactive Insights) OR (Account has Email) OR (Account has Desktop) OR ((Account has Chat) AND (Account has Inbound Voice OR Outbound Voice))
            else if(eachCategory.Name == 'InfoMart' && 
                (hasInteractiveInsights || hasEmail || hasDesktop || ( hasChat && ( hasInboundVoice || hasOutboundVoice)))){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Conversation Manager
            //(Account has Inbound Voice OR Account has Outbound Voice) AND has (Account has Product where Product.Solution Category = "Digital")
            else if(eachCategory.Name == 'Conversation Manager' 
                && (hasInboundVoice || hasOutboundVoice) && hasDigital){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Desktop
            //If (Account has CIM)
            else if(eachCategory.Name == 'Desktop' && hasCIM){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            //Interactive Insights
            //If (Account has Infomart)
            else if(eachCategory.Name == 'Interactive Insights' && hasInfoMart){                
                listOfSMLDataToBeUpdated = addSMLDataRecordToListToBeUpdated(listOfSMLDataToBeUpdated, mapOfCategoryIdVsSMLData.get(eachCategory.id).id);    
            }
            else{
                System.debug('NKC debug eachCategory.Name [' + eachCategory.Name + '] == WHITESPACE ');
                SML_Data__c smlDataToBeUpdated = new SML_Data__c(id = mapOfCategoryIdVsSMLData.get(eachCategory.id).id);
                smlDataToBeUpdated.Status__c = 'Whitespace';
                listOfSMLDataToBeUpdated.add(smlDataToBeUpdated);
            }
        } 
        if(!listOfSMLDataToBeUpdated.isEmpty())
            update listOfSMLDataToBeUpdated;      
    }
    
    private static List<SML_Data__c> addSMLDataRecordToListToBeUpdated(List<SML_Data__c> listOfSMLDataToBeUpdated, Id smlDataId){
        System.debug('NKC debug smlDataId [' + smlDataId + ']');
        SML_Data__c smlDataToBeUpdated = new SML_Data__c(id = smlDataId);
        smlDataToBeUpdated.Status__c = 'Next Best Action';
        listOfSMLDataToBeUpdated.add(smlDataToBeUpdated);
        return listOfSMLDataToBeUpdated;
    }
    
}