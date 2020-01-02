/**
 * @author Altimetrik
 * @description
 *    started on 10/08/2014
 *    utility methods
 **/
public without sharing class ca2cq_util {
    // Constants

    public static String CONFIG_NAME = 'default';
	public static Integer BATCH_SIZE = 200;

    /*
	  params : none
	  return ca2cq_config__c
		Returns the custom setting
	*/
    public static ca2cq_config__c  getAppSettings(){

        ca2cq_config__c res = ca2cq_config__c.getInstance(CONFIG_NAME);

        if (res == null){
            res = new ca2cq_config__c();
            res.Name = CONFIG_NAME;
			res.Current_Executing_Level__c = 0;
			res.Batch_size__c = BATCH_SIZE;
        }

        return res;

    }

    /*
	  params : none
	  return String list
		Returns the communities selected for migration
	*/
    public static List<String> getCommunitiesToMigrate(){
        list<String> result = new list<String>();
        list<ca2cq_Zone_community__c> mapps = ca2cq_Zone_community__c.getAll().values();

        // Create map with existing ZoneIds and setup object
        for(ca2cq_Zone_community__c ca : mapps){
            if (ca.Active_for_Migration__c)
                result.add(ca.zoneId__c);
        }
        return result;
    }

    /*
	  params : none
	  return Map of Communities with its Point Rules
		Get community reputation point rule if reputation is enabled.
	*/
    public static Map<Id, Map<String, Integer>> getCommunitiesPointRules(){
        Set<Id> auxSet = new Set<Id>();
        List<Id> auxList = new List<Id>();
        List<Id> communities = new List<Id>();

        //Get all communities that will receive the migrated questions
        List<ca2cq_Zone_community__c> allCommunities = ca2cq_Zone_community__c.getAll().values();

        Map<Id, Map<String, Integer>> result = new Map<Id, Map<String, Integer>>();

        for (ca2cq_Zone_community__c so : allCommunities){
            if (so.Active_for_Migration__c == True){
                if (!so.Community_Id__c.equals('null')){
                    auxList.add(so.Community_Id__c);
                }
            }
        }

        // If there are communities with reputation enabled
        if(auxList.size() > 0) {
            // Add results to a set to remove duplicates
            auxSet.addAll(auxList);
            // Add them back to a List
            communities.addAll(auxSet);

            // Get map of communities' OptionsReputationEnabled field
            Map<Id, Network> reputationEnabled = new Map<Id, Network>([SELECT OptionsReputationEnabled FROM Network WHERE Status ='Live']);

            for (Id comId : communities){
                Network nw = reputationEnabled.get(comId);

                if (nw != null && nw.OptionsReputationEnabled == True){
                    Map<String, Integer> typeToPoints = new Map<String, Integer>();
                    List<ReputationPointsRule> communityReputation = [SELECT Type, Points FROM ReputationPointsRule WHERE ParentId =: comId];
                    for (ReputationPointsRule rpR : communityReputation){
                        typeToPoints.put(rpR.Type, rpR.Points);
                    }

                    result.put(comId, typeToPoints);
                }
            }
        }
        return result;
    }

    /*
	  params : none
	  return Set of String with users in a community
		Get community users where reputation is enabled.
	*/
    public static Set<String> getUsersPerCommunity(){
        // Get communities with reputation enabled
        List<Network> repEnabled =  new List<Network>([SELECT Id FROM Network WHERE OptionsReputationEnabled = TRUE AND  Status ='Live']);

         Set<String> currentMembers = new Set<String>();

        for(NetworkMember nm : [SELECT Id, MemberId, NetworkId, ReputationPoints FROM NetworkMember WHERE NetworkId IN :repEnabled]){
            currentMembers.add(nm.NetworkId+'-'+nm.MemberId);
        }

        return currentMembers;
    }

    /*
	  params : none
	  return Map of communities, with user and their points
		Get community reputation point rule if reputation is enabled.
	*/
    public static Map<Id, Map<Id, Double>> getUserPointsPerCommunity() {
        // Map<CommunityId, Map<UserId, Points>>
        Map<Id, Map<Id, Double>> result = new Map<Id, Map<Id, Double>>();
        // Get communities with reputation enabled
        List<Network> repEnabled =  new List<Network>([SELECT Id FROM Network WHERE OptionsReputationEnabled = TRUE AND Status ='Live']);

        //Get reputation points from communities
        Map<Id, NetworkMember> communityPoints = new Map<Id, NetworkMember>([SELECT MemberId, NetworkId, ReputationPoints FROM NetworkMember WHERE NetworkId IN :repEnabled]);

        // For each community
        for (Network community : repEnabled) {

            // Map<UserId, Points>>
            Map<Id, Double> userPoints = new Map<Id, Double>();

            // For each community in networkMember map
            for (Id comKey : communityPoints.keySet()) {
                // Get user from map
                NetworkMember member = communityPoints.get(comKey);

                if (community.Id == member.NetworkId) {
                    userPoints.put(member.MemberId, member.ReputationPoints);
                }
            }

            // Put all member points in the current community
            result.put(community.Id, userPoints);
        }

        return result;
    }

    /*
	  params : none
	  return Map of Chatter Zones Ids to Network
	*/
    public static map<String,String> chatterZoneToNetwork() {
        map<String,String> result = new map<String,String>();
        list<ca2cq_Zone_community__c> mapps = ca2cq_Zone_community__c.getAll().values();

        // Create map with existing ZoneIds and setup object
        Map<Id, ca2cq_Zone_community__c> zoneIdToConfig = new Map<Id, ca2cq_Zone_community__c>();

        for(ca2cq_Zone_community__c ca : mapps){
            if (ca.Community_Id__c =='null')
                result.put(ca.zoneId__c, null );
            else
                result.put(ca.zoneId__c, ca.Community_Id__c );
        }
        return result;
    }

    /*
      params : none
      return Map of dataCategory to Topics
    */
    public static  Map<String, String> getDCToToppicsMap() {
        Map<String, String> result = new Map<String, String>();
        list<ca2cq_categories_To_Topic__c> mapps = ca2cq_categories_To_Topic__c.getAll().values();

        // Create map with existing ZoneIds and setup object
        set<String> dataCategorySet = new set<String>();
        for(ca2cq_categories_To_Topic__c e : mapps){
            result.put(e.DataCategoryName__c,e.TopicName__c);
        }
        return result;
    }

    /*
      params : none
      return List of ca2cq_categories_To_Topic__c
    */
    public static list<ca2cq_categories_To_Topic__c> getDCToToppics() {
        list<ca2cq_categories_To_Topic__c> mapps = ca2cq_categories_To_Topic__c.getAll().values();

        Map<String, String> dataCategoryMap =  getDCToToppicsMap();
        // build result list adding any datacategory not registered
        for (QuestionDataCategorySelection dc : [SELECT DataCategoryName FROM QuestionDataCategorySelection limit 10000]){
            if (!dataCategoryMap.containsKey(dc.DataCategoryName)){
                dataCategoryMap.put(dc.DataCategoryName,'');
                mapps.add(new ca2cq_categories_To_Topic__c(
                            Name = dc.DataCategoryName,
                            DataCategoryName__c = dc.DataCategoryName,
                            TopicName__c = dc.DataCategoryName.replaceAll('_',' ')
                        )
                );
            }

        }

        system.debug('\n=====[getDCToToppics] : '+mapps);

        return mapps;
    }

    /*
	  params : none
	  return List of ca2cq_Zone_community__c
		Get list of zones to communities
	*/
    public static list<ca2cq_Zone_community__c>  getAppCommunityMappings() {
        list<ca2cq_Zone_community__c> mapps = ca2cq_Zone_community__c.getAll().values();
		Map<Id,Id> mapRecordToZoneId = new Map<Id,Id>();


        // Create map with existing ZoneIds and setup object
        Map<Id, ca2cq_Zone_community__c> zoneIdToConfig = new Map<Id, ca2cq_Zone_community__c>();
        for(ca2cq_Zone_community__c ca : mapps){
            zoneIdToConfig.put(ca.zoneId__c, ca);
        }

        // Build result list adding any Zone not registered
        Map<Id,Community> allC = allCommunities();
        if ( mapps.isEmpty() || mapps.size() != allC.size() ){
            ca2cq_Zone_community__c tmp ;

            for(Id i : allC.keySet()){
                if (! zoneIdToConfig.containsKey(i)){
                    tmp = new ca2cq_Zone_community__c();
                    tmp.name = allC.get(i).Id;
                    tmp.zoneId__c = i;
                    tmp.Active_for_Migration__c = false;
                    mapps.add(tmp);
					//add new Zone to map
					zoneIdToConfig.put(tmp.zoneId__c, tmp);
                }
            }
        }

		// Sort
		List<Id> sortedIds = new List<Id>();
		List<Id> unSortedIds = new List<Id>();
		unSortedIds.addAll(zoneIdToConfig.keySet());
		for(Community zc :[	SELECT Id,Name,NetworkId
							FROM Community where id in:unSortedIds
							order by name asc ]){
			sortedIds.add(zc.Id);
		}

		list<ca2cq_Zone_community__c> sortedList = new list<ca2cq_Zone_community__c> ();
		for(Id thisId : sortedIds){
			if (zoneIdToConfig.containsKey(thisId)){
				sortedList.add(zoneIdToConfig.get(thisId));
			}
		}
        return sortedList;
    }

    /*
	  params : none
	  return List of ca2cq_Zone_community__c
		Get list of zones to communities
	*/
    public static Map<Id,Community> allCommunities() {
        Integer limitValue = (  Limits.getLimitDMLRows() - Limits.getDMLRows() );

        return  new Map<Id,Community>([SELECT CreatedById,CreatedDate,Description,Id,IsActive,
                        LastModifiedById,LastModifiedDate,Name,NetworkId,SystemModstamp
                FROM Community
                ORDER BY Name ASC
                LIMIT  :limitValue ]) ;

    }

    /*
	  params : none
	  return List of Network
		Get list of all active Networks
	*/
	public static List<Network> allNetworkList() {
		Integer limitValue = (  Limits.getLimitDMLRows() - Limits.getDMLRows() );
		return  [ SELECT Description,Id,Name,Status
				FROM Network
				WHERE Status ='Live'
				order by Name asc
				LIMIT  :limitValue];

	}

    /*
	  params : none
	  return Map of Topics name - Network Id to Topic Id
		Gets a Map of all Topics from Networks
	*/
    public static Map<String, Id> allTopics() {
        Map<String, Id> topicMap = new Map<String, Id>();
        for (Topic t : [select Id, name, NetworkId from Topic limit 10000]) {
            topicMap.put(t.name + ':&:' + t.NetworkId, t.Id);
        }

        return topicMap;

    }

    /*
	  params : List of Topic
	  return
		Creates Chatter Navigational Topics from a List of Topics
	*/
    public static void createNavigationalTopics(List<Topic> topics){
        Map<Id, List<Topic> > listTopics = new Map<Id, List<Topic> >();
        List<Topic> topicElements;

        //group topics by community
        for(Topic t : topics){

            if (listTopics.containsKey(t.NetworkId)){
                topicElements = listTopics.get(t.NetworkId);
            }else{
                topicElements = new List<Topic>();
            }
            topicElements.add(t);
            listTopics.put(t.NetworkId,topicElements);

        }

        for (Id community : listTopics.keySet()){
            if(community != null){
                ConnectApi.ManagedTopicCollection mt = ConnectApi.ManagedTopics.getManagedTopics(community, ConnectApi.ManagedTopicType.Navigational);
                List<Topic> lt = listTopics.get(community);

                for(Integer a = mt.managedTopics.size(); a < 25 && a < lt.size(); a++){
                    try {
                        if(!System.Test.isRunningTest())
                            ConnectApi.ManagedTopics.createManagedTopic(community, lt[a].Id, ConnectApi.ManagedTopicType.Navigational);
                    } catch (Exception e) {
            			System.debug('Exception: ' + e);
            		}
                }
            }
        }
    }

    /*
	  params : Map of bestAnswers
	  return None
		Inserts a best answer given a map of FeedComments
	*/
    public static void insertQuestionsToMigrate(Map<String, FeedComment> bestAnswersMap ){

        // custom object that with best answers info
        List<ca2cq_best_answer_to_migrate__c> bestAnswers = new List<ca2cq_best_answer_to_migrate__c>();

        for (String key : bestAnswersMap.keySet()) {
            FeedComment fc = bestAnswersMap.get(key);
            if (String.isNotBlank(fc.Id)){

                    List<String> parts = key.split(':&:');

                    bestAnswers.add(new ca2cq_best_answer_to_migrate__c(
							Feed_Item_Id__c = parts[0],
							Network_Id__c = parts[1],
							Feed_Comment_Id__c = fc.Id,
							Feed_Comment_CreatedById__c = fc.CreatedById,
							Feed_Comment_SelectedById__c = parts[2]));

            }
        }

        insert bestAnswers;

    }

    /*
	  params : String with the body of a question, NetworkId
	  return String with the converted body
		Replaces unused/non legal tags with the ones supported in chatter, if applicable
	*/
    public static string convertBody(String body,String netId){
        // Convert all tags that can be replaced
        body = convertTags(body);
        system.debug('-----Converting tags------');

        // Count the link tag occurrences
        Integer occurrences = body.countMatches('<a');
        Integer counter = 0;

        // Substitute the link tag with the plain url for each occurrence
        while (counter < occurrences){
            if (body.contains('(<a')){
                String tag = body.substringBetween('(<a', '</a>)');
                String fullTag = '(<a' + tag + '</a>)';
                String startTag = fullTag.substringBetween('(<a', '>');
                String insideBody = fullTag.substringBetween('(<a' + startTag + '>', '</a>)');
                // Check if tag contains an email
                if (fullTag.contains('(<a href="mailto:')) {
                    String emailReceptor = fullTag.substringBetween('mailto:', '?');
                    if (String.isBlank(emailReceptor))
                        emailReceptor = fullTag.substringBetween('mailto:', '"');

                    // Remove extra characters from subject
                    String emailSubject = fullTag.substringBetween('subject=', '&amp;body');
                    if (!String.isBlank(emailSubject))
                        emailSubject = convertEmail(emailSubject);

                    // Remove extra characters from body
                    String emailBody = fullTag.substringBetween('body=', '"');
                    if (!String.isBlank(emailBody))
                        emailBody = convertEmail(emailBody);

                    if (insideBody.contains('</')) {
                        if (emailSubject != NULL && emailBody != NULL)
                  	        body = body.replace(fullTag, '(To: ' + emailReceptor + ' - Subject: ' + emailSubject + ' - Body: ' + emailBody + ') '+ insideBody);
                        else {
                            body = body.replace(fullTag, '(To: ' + emailReceptor + ') '+ insideBody);
                        }
                    }
                    else {
                        insideBody = convertEmail(insideBody);
                        if (emailSubject != NULL && emailBody != NULL && emailBody != NULL)
                            body = body.replace('(<a' + tag + '</a>)', '(To: ' + emailReceptor + ' - Subject: ' + emailSubject + ' - Body: ' + emailBody + ') ');
                        else {
                            if (insideBody.equals(emailReceptor) || emailReceptor == NULL)
                                body = body.replace(fullTag, '(' + insideBody + ') ');
                            else
                                body = body.replace(fullTag, '(To: ' + emailReceptor + ') '+ insideBody);
                        }
                    }
                } else {
                    // If the link has the news:// protocol
                    if (fullTag.contains('news:')) {
                        String aTag = fullTag.substringBetween('(<a', '>');
                        String url = fullTag.substringBetween('<a' + aTag + '>', '</a>)');
                        body = body.replace(fullTag, url+' ');
                    } else {
                        if(fullTag.contains('href=')) {
                            String url = fullTag.substringBetween('href="', '"');
                            // If url and inside body are the same
                            if (url.equals(insideBody))
                                body = body.replace('(<a' + tag + '</a>)', '(' + url + ') ');
                            else
                                body = body.replace('(<a' + tag + '</a>)', '(' + url + ') ' + insideBody + ' ');
                        } else {
                            String content = fullTag.substringBetween('>', '</a>)');
                            body = body.replace('(<a' + tag + '</a>)', content + ' ');
                        }
                    }
                }
            }

            else if (body.contains('<a')){
                String tag = body.substringBetween('<a', '</a>');
                String fullTag = '<a' + tag + '</a>';
                String startTag = fullTag.substringBetween('<a', '>');
                String insideBody = fullTag.substringBetween('<a' + startTag + '>', '</a>');
                // Check if tag contains an email
                if (fullTag.contains('<a href="mailto:')) {
                    String emailReceptor = fullTag.substringBetween('mailto:', '?');
                    if (String.isBlank(emailReceptor))
                        emailReceptor = fullTag.substringBetween('mailto:', '"');

                    String emailSubject = fullTag.substringBetween('subject=', '&amp;body');
                    if (!String.isBlank(emailSubject))
                        emailSubject = convertEmail(emailSubject);

                    String emailBody = fullTag.substringBetween('body=', '"');
                    if (!String.isBlank(emailBody))
                        emailBody = convertEmail(emailBody);

                    if (insideBody.contains('</')) {
                        if (emailSubject != NULL && emailBody != NULL) {
                            body = body.replace(fullTag, '(To: ' + emailReceptor + ' - Subject: ' + emailSubject + ' - Body: ' + emailBody + ') '+ insideBody);
                        } else {
                            body = body.replace(fullTag, '(To: ' + emailReceptor + ') '+ insideBody);
                        }
                    }
                    else {
                        insideBody = convertEmail(insideBody);
                        if (emailSubject != NULL && emailBody != NULL && emailReceptor != NULL)
                            body = body.replace(fullTag, '(To: ' + emailReceptor + ' - Subject: ' + emailSubject + ' - Body: ' + emailBody + ') ');
                        else {
                            if (insideBody.equals(emailReceptor) || emailReceptor == NULL)
                                body = body.replace(fullTag, '(' + insideBody + ') ');
                            else
                                body = body.replace(fullTag, '(To: ' + emailReceptor + ') '+ insideBody);
                        }
                    }
                } else {
                    // If the link has the news:// protocol
                    if (fullTag.contains('news:')) {
                        String aTag = fullTag.substringBetween('<a', '>');
                        String url = fullTag.substringBetween('<a' + aTag + '>', '</a>');
                        body = body.replace(fullTag, url+' ');
                    } else {
                        if(fullTag.contains('href=')) {
                            String url = fullTag.substringBetween('href="', '"');
                            // If url and inside body are the same
                            if (url.equals(insideBody) && url != null) {
                                body = body.replace('<a' + tag + '</a>', url);
                            } else {
                                if (String.isEmpty(url))
                                    body = body.replace('<a' + tag + '</a>', insideBody);
                                else
                                    body = body.replace('<a' + tag + '</a>', '(' + url + ') ' + insideBody + ' ');
                            }
                        } else {
                            String content = fullTag.substringBetween('>', '</a>');
                            body = body.replace('<a' + tag + '</a>', content + ' ');
                        }
                    }
                }
            }

            counter++;
        }


        // Count the img tag occurrences
        occurrences = body.countMatches('<img');
        counter = 0;
        String replacementBody = body;

        System.debug('Img tag occurrences: ' + occurrences);
        // Search body for img with external urls.
        while (counter < occurrences){
            System.debug('counter: ' + counter);
            String image = replacementBody.substringBetween('<img', '></img>');
            System.debug('replacementBody : ' + replacementBody);
            System.debug('></img> Image tag: ' + image);

            if (image != null) {
                String url = image.substringBetween('src="','"');
                String fullTag = '<img' + image + '></img>';

                System.debug('fullTag tag: ' + fullTag);
                System.debug('url tag: ' + url);

                if (!url.contains('rtaImage?eid')) {
                    System.debug('Does not contain ORG image');
                    body = body.replace(fullTag, url + ' ');
                    replacementBody = replacementBody.replace(fullTag, '');
                } else {
                    System.debug('contains rtaImage?eid ');
                    replacementBody = replacementBody.replace(fullTag, '');
                    body = body.replace(fullTag, '_img_' + image + '_/_img_');

                    if (fullTag.contains('height="')) {
                        System.debug('url.contains.height ');
                        String heightAtr = fullTag.substringBetween('height="', '"');
                        body = body.replace('height="' + heightAtr + '"', '');
                    }

                    if (fullTag.contains('width="')) {
                        System.debug('url.contains.width ');
                        String widthAtr = fullTag.substringBetween('width="', '"');
                        body = body.replace('width="' + widthAtr + '"', '');
                    }
                }

                if (replacementBody.equals('')) {
                    System.debug('replacementBody is null.');
                    body = body.replace('<img', '_img_');
                    body = body.replace('></img>', '_/_img_');
                }

                System.debug('replacementBody changed.');
            }

            counter++;
        }


        //  Count if there are code snippets
        occurrences = body.countMatches('<code>');
        counter = 0;
        replacementBody = body;

        // Substitute the content of the code tag with escaped characters
        while (counter < occurrences){
            String code = replacementBody.substringBetween('<code>','</code>');

            if (code != null) {
                String escapedCode = code.replace('<', '&lt;');
                escapedCode = escapedCode.replace('>', '&gt;');
                // Remove first blank character
                escapedCode = escapedCode.replaceFirst('\\s+', '');

                body = body.replace('<code>' + code + '</code>', '<code>' + escapedCode + '</code>');
                replacementBody = replacementBody.replace('<code>' + code + '</code>', '');
            }
            counter++;
        }


        // Count the div style with margin occurrences
        occurrences = body.countMatches('<div style="margin-left:');
        counter = 0;

        // Substitute the div with the content inside of it
        while (counter < occurrences){
            if (body.contains('<div style="margin-left:')){
                String indent = body.substringBetween('<div style="margin-left:', '>');
                body = body.replace('<div style="margin-left:'+ indent + '>', '');
            }

            counter++;
        }


        //  Check if there are remaining style divs
        occurrences = body.countMatches('style=');
        counter = 0;

        while (counter < occurrences){
            if (body.contains('style=')){
              // Remove style attribute
              String style = body.substringBetween('style="','"');
              body = body.replaceFirst('style="'+ style + '"', '');
            }

            counter++;
        }


        // Search body for h tags
        occurrences = body.countMatches('<h');
        counter = 0;
        replacementBody = body;

        // Remove h tags if found
        while (counter < occurrences){
            String tag = replacementBody.substringBetween('<h', '>');
            String endTag = replacementBody.substringBetween('</h', '>');

            if (tag != null){
            	  body = body.replace('<h' + tag + '>', '');
                body = body.replace('</h' + endTag + '>', ' ');
                replacementBody = replacementBody.replace('<h' + tag + '>', '');
                replacementBody = replacementBody.replace('</h' + endTag + '>', '');
            }
        	counter++;
        }


        // Search body for strong tags.
        occurrences = body.countMatches('<strong');
        counter = 0;
        replacementBody = body;

        // Remove strong tags if found
        while (counter < occurrences){
            String tag = replacementBody.substringBetween('<strong', '>');

            if (tag != null){
            	body = body.replace('<strong' + tag + '>', '');
                body = body.replace('</strong>', ' ');
          	    replacementBody = replacementBody.replace('<strong' + tag + '>', '');
                replacementBody = replacementBody.replace('</strong>', '');
            }
        	counter++;
        }


        // Search body for span tags.
        occurrences = body.countMatches('<span');
        counter = 0;

        // Remove span tags if found
        while (counter < occurrences){
            String startTag = body.substringBetween('<span', '>');

            body = body.replace('<span' + startTag + '>', ' ');
            body = body.replace('</span>', ' ');

      	    counter++;
        }

        // Search body for font tags.
        occurrences = body.countMatches('<font');
        counter = 0;

        // Remove font tags if found
        while (counter < occurrences){
            String startTag = body.substringBetween('<font', '>');

            body = body.replace('<font' + startTag + '>', ' ');
            body = body.replace('</font>', ' ');

      	    counter++;
        }

        // Search body for em tags.
        occurrences = body.countMatches('<em');
        counter = 0;

        // Remove em tags if found
        while (counter < occurrences){
            String startTag = body.substringBetween('<em', '>');

            body = body.replace('<em' + startTag + '>', ' ');
            body = body.replace('</em>', ' ');

      	    counter++;
        }

        // Search body for br tags.
        occurrences = body.countMatches('<br');
        counter = 0;

        // Remove br tags if found
        while (counter < occurrences){
            String startTag = body.substringBetween('<br', '>');

            body = body.replace('<br' + startTag + '>', '<p>&nbsp</p>');
            body = body.replace('</br>', ' ');

      	    counter++;
        }

        occurrences = body.countMatches('<table');
        counter = 0;

        // Substitute the whole table tag with its content
        while (counter < occurrences){
            Integer tdOccurrences = body.countMatches('<td');
            Integer tdCounter = 0;

            List<String> tdContent = new List<String>();

            String mainTag = body.substringBetween('<table', '</table>');
            String mainFullTag = '<table' + mainTag + '</table>';

            String rawBody = body;

            while (tdCounter < tdOccurrences){
                String tag = rawBody.substringBetween('<td', '</td>');
                String fullTag = '<td' + tag + '</td>';
                String startTag = fullTag.substringBetween('<td', '>');
                String insideBody = fullTag.substringBetween('<td' + startTag + '>', '</td>');

                rawBody = rawBody.replace(fullTag, '');

                tdContent.add(insideBody);

                tdCounter++;
            }

         	  String tableContent = String.join(tdContent, '\n');
            body = body.replace(mainFullTag, tableContent);
            counter++;
        }

        occurrences = body.countMatches('class="');
        counter = 0;

        // Substitute class attribute an all tags.
        while (counter < occurrences){
            String classAtr = body.substringBetween('class="','"');
            body = body.replace('class="' + classAtr + '"', '');
            counter++;
        }

        occurrences = body.countMatches('style="');
        counter = 0;

        // Substitute style attribute an all tags.
        while (counter < occurrences){
            String styleAtr = body.substringBetween('style="','"');
            body = body.replace('style="' + styleAtr + '"', '');
            counter++;
        }

        // Replace all remaining divs (if any left)
        body = body.replaceAll('<div>','');
        body = body.replaceAll('<div >','');
        body = body.replaceAll('</div>','');

        // Replace first blank space on code snippets (if any)
        body = body.replaceAll('<code> ','<code>');
        system.debug('Result: ' + body);
        return body;
    }

    /*
	  params : String with a question body
	  return String with converted body
		Replaces all tags from the Q&A version to Chatter supported ones
	*/
    public static string convertTags(String body){
        String finalBody = body;

        // Replace codeblock tag with space on first column
        finalBody = finalBody.replaceAll('<pre class="ckeditor_codeblock"> ','<code>');
        finalBody = finalBody.replaceAll('</pre>','</code>');

        // Replace common codeblock tag
        finalBody = finalBody.replaceAll('<pre class="ckeditor_codeblock">','<code>');
        finalBody = finalBody.replaceAll('</pre>','</code>');

        // Replace common codeblock tag
        finalBody = finalBody.replaceAll('<pre>','<code>');
        finalBody = finalBody.replaceAll('</pre>','</code>');

        // Replace strikethrough tag
        finalBody = finalBody.replaceAll('<strike>','<s>');
        finalBody = finalBody.replaceAll('</strike>','</s>');

        // Replace div tag
        finalBody = finalBody.replaceAll('<div>','');
        finalBody = finalBody.replaceAll('</div>','');

        // Replace div align center tag
        finalBody = finalBody.replaceAll('<div style="text-align: center;">','');

        // Replace div align righ tag
        finalBody = finalBody.replaceAll('<div style="text-align: right;">','');

        // If there are two br tags next to each other replace them with a sole br tag.
        // This prevents the chatter feed from having too many spaces.
        finalBody = finalBody.replaceAll('<br><br>','<br>');

        // Replace br tag
        finalBody = finalBody.replaceAll('<br>','<p>&nbsp</p>');

        return finalBody;
    }

    /*
	  params : String with body of email
	  return Converted string of body
		Unescapes characters in an email body
	*/
    public static string convertEmail(String emailText) {
        // Convert all encoded text
        emailText = emailText.replace('%20', ' ');
        emailText = emailText.replace('%0A', ' ');
        emailText = emailText.replace('\'', '&quot;');
        emailText = emailText.replace('%2F', '/');
        emailText = emailText.replace('%2C', ',');
        emailText = emailText.replace('%3B', ';');
        emailText = emailText.replace('%5C', '/');
        emailText = emailText.replace('%5B', '&#91;');
        emailText = emailText.replace('%5D', '&#93;');
        emailText = emailText.replace('%3D', '=');
        emailText = emailText.replace('%60', '&quot;');
        emailText = emailText.replace('%40', '@');
        emailText = emailText.replace('%23', '#');
        emailText = emailText.replace('%24', '$');
        emailText = emailText.replace('%25', '%');
        emailText = emailText.replace('%5E', '^');
        emailText = emailText.replace('%2B', '+');
        emailText = emailText.replace('%7B', '&#123;');
        emailText = emailText.replace('%7D', '&#125;');
        emailText = emailText.replace('%3A', ':');
        emailText = emailText.replace('%22', '&quot;');
        emailText = emailText.replace('%3C', '&lt;');
        emailText = emailText.replace('%3E', '&gt;');
        emailText = emailText.replace('%3F', '?');
        emailText = emailText.replace('%26', '&amp;');

        return emailText;
    }

    /*
	  params : Map with urls of imgs to index, Map of index to Network
	  return Map with converted items
		Converts all the urls from an img chat and creates a contentDocument supported in chatter
	*/
	public static Map<Integer,List<ContentVersion>> convertToContent (Map<String,Integer> urlsToIndex, Map<Integer,Id> indexToNetworkId){
		 Map<Integer,List<ContentVersion>> result = new Map<Integer,List<ContentVersion>>();
        List<ContentVersion> indexResult;
        list<ContentVersion> cList = new List<ContentVersion>();
        String dbug ='';
        for(String url : urlsToIndex.keySet() ){
            Integer thisIndex = urlsToIndex.get(url);

        dbug +='\n [convertToContent urls]:'+url;
            PageReference pageRef = new PageReference(url.replace('amp;',''));

            ContentVersion v = new ContentVersion();
			if (!System.Test.isRunningTest()){
				v.versionData = pageRef.getContent();
	            v.pathOnClient = url;
			}else{
				v.pathOnClient=url;
				v.versionData =  Blob.valueOf('el blob');
			}
            v.title = 'qa';
            v.Description = 'qa migration';
            v.NetworkId = indexToNetworkId.get(thisIndex);

            cList.add(v);
        }

        insert cList;
        list<Id> ids = new List<Id>();
        for(ContentVersion c : CList){
            ids.add(c.Id);
            dbug +='\n [c.Id]:'+c.Id;
        }

        for(ContentVersion c : [    select ContentDocumentId,pathOnClient
                                    from ContentVersion
                                    where id in:ids]){
            if (urlsToIndex.containsKey(c.pathOnClient)) {
                Integer tmpIndex = urlsToIndex.get(c.pathOnClient);
                if (result.containsKey(tmpIndex)){
                    indexResult = result.get(tmpIndex);
                } else {
                    indexResult = new List<ContentVersion>();
                }
                indexResult.add(c);
                result.put(tmpIndex, indexResult);
                  dbug +='\n [convertToContent]:'+tmpIndex+','+indexResult;
            } else {
				if (System.Test.isRunningTest()) {
					indexResult = new List<ContentVersion>{c};
					result.put(0, indexResult);
				}
			}
        }

       System.debug(dbug);
       return result;
	}

    /*
	  params : None
	  return String with query
		Gets the query for batch execution of question migration
	*/
	public static String resolveQuestionMigrationQuery(){
		String q;
		list<String> cList = ca2cq_util.getCommunitiesToMigrate();
		ca2cq_config__c setupObj  =  getAppSettings();

        if ( !cList.isEmpty() ) {
            q = ' Select Id, CommunityId, Title,Body, CreatedDate,  CreatedById ,NumReplies, UpVotes, BestReplyId, '+
				' BestReplySelectedById,'+
				' (select id, ParentId , CreatedById, CreatedDate from votes)'+
				' from Question '+
                        ' where CommunityId in (\''+ String.join(cList,'\',\'')+'\')';

                if(! setupObj.Migrate_all_Questions__c && String.isNotBlank(setupObj.Question_Ids__c)){
                    list<String> tmpIDs = setupObj.Question_Ids__c.split(',');
                    if (setupObj.Exclude_this_Ids__c)
                        q += ' and Id not in (\''+ String.join(tmpIDs,'\',\'')+'\')';
                    else
                        q += ' and Id in (\''+ String.join(tmpIDs,'\',\'')+'\')';
                }
        }
		return q;
	}

    /*
	  params : String with level
	  return None
		Updates the 'level' of a batch for log details
	*/
	public static void updateExecutingLevel(Integer newLevel){
		ca2cq_config__c setupObj  =  getAppSettings();
		setupObj.Current_Executing_Level__c = newLevel;
		update setupObj;
		system.debug('\n ==updateExecutingLevel to [' +newLevel+']== \n setupObj.Current_Executing_Level__c:'+setupObj.Current_Executing_Level__c);

	}

    /*
	  params : None
	  return String with level
		Gets the current 'level' of a batch
	*/
	public static Integer getExecutingLevel(){
		ca2cq_config__c setupObj  =  getAppSettings();

		return  Integer.valueOf(setupObj.Current_Executing_Level__c);
	}

    /*
	  params : None
	  return Integer with batch size
		DEPRECATED. Returns the total size of each batch execution. Configuration now hidden on migration setup
	*/
	public static Integer getBatchSize(){
		Integer result = 200;
		ca2cq_config__c setupObj  =  getAppSettings();
		if (setupObj != null){
			result = Integer.valueOf(setupObj.Batch_size__c);
		}
		return  result;
	}


	public static Map<String, Integer > urltoFeedIndex = new Map<String, Integer >();
	public static Map<Integer, Id > indexToNetworkId = new Map<Integer, Id >();
	public static Map<Integer,Id > indexToallFeedItems = new Map<Integer,Id >();

    /*
	  params : List of Content Migration
	  return None
		Inserts content as contentDocument
	*/
	public static void processContent(List<Content_Migration__c> allContent){

		String dbug = 'processContent of ['+allContent.size()+'] elements ';
		for(Content_Migration__c t : allContent){
			dbug +='\n '+t.Content_Reference_Url__c+' feed'+t.Feed_Record_Id__c;
		}
		List<Id> feedItemsIds = new List<Id>();
		List<Id> feedCommentsIds = new List<Id>();
		Id itemId;
		Integer cntIndex = 0;
		for(Content_Migration__c cM : allContent){
			//classify Feeds by type
			itemId = cM.Feed_Record_Id__c;
			if (Schema.FeedItem.SObjectType == itemId.getSobjectType()){
				feedItemsIds.add(itemId);
			}else{
				feedCommentsIds.add(itemId);
			}

			urltoFeedIndex.put(cM.Content_Reference_Url__c,cntIndex);
            indexToNetworkId.put(cntIndex,cM.Network_Scope__c);
            indexToallFeedItems.put(cntIndex,itemId);
            cntIndex++;
		}

		dbug +='\n=== urltoFeedIndex:'+urltoFeedIndex.size();

		//process rta
		if (!urltoFeedIndex.isEmpty()){

			Map<Id,FeedItem> feedItemsToUpdate = new Map<Id,FeedItem>([Select Id, Body from FeedItem where id in:feedItemsIds ]);
			Map<Id,FeedComment> feedCommentsToUpdate = new Map<Id,FeedComment>([Select Id, CommentBody from FeedComment where id in:feedCommentsIds ]);

			Map<Integer,List<ContentVersion>> indexToContent = ca2cq_util.convertToContent (urltoFeedIndex,  indexToNetworkId);

			FeedItem feedQ;
			FeedComment feedC;
            dbug +='\n=================\n================\n';
			for(String cUrl : urltoFeedIndex.keySet()){

				dbug +='\n [cURL]:'+cUrl;

				Integer feedIndex = urltoFeedIndex.get(cUrl);

				List<ContentVersion> indexContents = indexToContent.get(feedIndex);
                System.debug(	'\n feedIndex '+feedIndex+
 				'\n indexToContent '+indexToContent.size()+
				'\n indexContents '+indexContents);
				if (indexToallFeedItems.containsKey(feedIndex)){
					//update FeedItem Body
					Id feedId = indexToallFeedItems.get(feedIndex);
					if (Schema.FeedItem.SObjectType== feedId.getSobjectType()){
						feedQ = feedItemsToUpdate.get(feedId);
							dbug +='\n[feedItem body]:\n'+feedQ.Body;
							system.debug(dbug);
							system.debug('\n indexContents :'+indexContents);
						for(ContentVersion newContent : indexContents){

							String newUrl =  'sfdc://'+newContent.ContentDocumentId;

								dbug +='\n=================\n [rta url ]:'+newContent.pathOnClient+'\n [sfdc url ]:'+newUrl;
							feedQ.Body = feedQ.Body.replace(newContent.pathOnClient,newUrl);

							feedQ.Body = feedQ.Body.replace('_/_img_','></img>');
							feedQ.Body = feedQ.Body.replace('_img_','<img');
							feedQ.Body = feedQ.Body.replaceAll('&quot;','"');
						}
						dbug +='\n [POST ]:'+feedQ.Body+'\n\n\n';
					}else{
						//update FeedComment Body
						feedC = feedCommentsToUpdate.get(feedId);
						dbug +='\n [feed comment body ]:'+feedC.CommentBody;
						for(ContentVersion newContent : indexContents){

							//---- Added as test by mcarrey ----
							feedC.CommentBody = feedC.CommentBody.replace('amp;','');
                            //----------------------------------
							String newUrl =  'sfdc://'+newContent.ContentDocumentId;
                            String auxPath = newContent.pathOnClient.replace('amp;','');
							feedC.CommentBody = feedC.CommentBody.replace(auxPath,newUrl);

                 dbug +='\n=================\n [rta url ]:'+newContent.pathOnClient+'\n [sfdc url ]:'+newUrl;

							feedC.CommentBody = feedC.CommentBody.replace('_/_img_','></img>');
							feedC.CommentBody = feedC.CommentBody.replace('_img_','<img');
							feedC.CommentBody = feedC.CommentBody.replaceAll('&quot;','"');

						}
						dbug +='\n [POST ]:'+feedC.CommentBody;
					}
				}
			}
			ca2cq_log__c thisLog = ca2cq_logs.getCurrentLog ();
			list<String> logString = new list<String>();
			List<SObject> sourceData;
			Map<String,list<String>> postsResultsToProcess = new Map<String,list<String>> ();
			list<String> tmpList;
			if (!feedItemsToUpdate.isEmpty()){
				//upsert feedItemsToUpdate.values();
				Database.UpsertResult[] updateResults =  Database.upsert(feedItemsToUpdate.values(), false);
				sourceData = ((List<SObject>)feedItemsToUpdate.values());
				postsResultsToProcess = processDbUpsertResults(updateResults,sourceData);
				tmpList = postsResultsToProcess.get('Success');
				logString.add('Content Migration over Questions:' + '\n Success : '+ tmpList.size()+ ' of '+feedItemsToUpdate.size());
				tmpList = postsResultsToProcess.get('Errors');
				logString.add('\n Errors : '+ tmpList.size()+ ' of '+feedItemsToUpdate.size());
			}
			Map<String,list<String>> commentsResultsToProcess = new Map<String,list<String>>();
			if (!feedCommentsToUpdate.isEmpty()){
				//upsert feedCommentsToUpdate.values();
				Database.UpsertResult[] updateResults =  Database.upsert(feedCommentsToUpdate.values(), false);
				sourceData = ((List<SObject>)feedCommentsToUpdate.values());
				commentsResultsToProcess = processDbUpsertResults(updateResults,sourceData);
				//logString += 'Content Migration over Replies:'+processDbUpsertResults(updateResults,sourceData);
				tmpList = commentsResultsToProcess.get('Success');
				logString.add('Content Migration over Replies:' + '\n Success : '+ tmpList.size()+ ' of '+feedCommentsToUpdate.size());
				tmpList = commentsResultsToProcess.get('Errors');
				logString.add('\n Errors : '+ tmpList.size()+ ' of '+feedCommentsToUpdate.size());
			}

			ID nLogId = ca2cq_logs.newLogDetail(thisLog.Id,'Content migration', thisLog.Id, 'Content migration results', String.join(logString,'\n') );


			//logs on success Questions content
			if (!postsResultsToProcess.isEmpty()){
				if (postsResultsToProcess.containsKey('Success'))
					ca2cq_logs.convertListToTxt(nLogId, 'FeedItemsWithContentUpdateOK', postsResultsToProcess.get('Success'));
				if (postsResultsToProcess.containsKey('Errors'))
					ca2cq_logs.convertListToTxt(nLogId, 'FeedItemsWithContentUpdateError', postsResultsToProcess.get('Errors'));
			}
			//logs on success Questions content
			if (!commentsResultsToProcess.isEmpty()){
				if (commentsResultsToProcess.containsKey('Success'))
					ca2cq_logs.convertListToTxt(nLogId, 'FeedCommentsWithContentUpdateOK', commentsResultsToProcess.get('Success'));
				if (commentsResultsToProcess.containsKey('Errors'))
					ca2cq_logs.convertListToTxt(nLogId, 'FeedCommentsWithContentUpdateError', commentsResultsToProcess.get('Errors'));
			}
		}
		ca2cq_logs.logIt(' Content migration: '+dbug);
	}

    /*
	  params : List of UpserResults, List of Objects
	  return Map with a Json
		Creates a JSON with details of a migration
	*/
	public static Map<String,list<String>> processDbUpsertResults(Database.UpsertResult[] results,List<SObject> sourceData){
		Map<String,list<String>> result = new Map<String,list<String>>();
		list<String> ls_succes = new list<String>();
		list<String> ls_error = new list<String>();
		Integer index=0;
		Map<String,Object> record ;
		for (Database.UpsertResult res : results) {
			if (res.isSuccess()) {
				if (!res.isCreated()) {
					ls_succes.add(res.getId() );
				}
			}
			else {
				record = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sourceData.get(index)));

				if (res.getErrors().size() > 0) {
					String errorId = String.valueOf(record.get('Id'));
					ls_error.add(errorId+ ' reason: '+res.getErrors()[0].getMessage() );
				}
			}
			index++;
		}


		result.put('Success',ls_succes);
		result.put('Errors',ls_error);
		return result;
	}

    /*
	  params : Job id
	  return String with step
		Gets the current step of an apex job
	*/
	public static String getJobStep(String asyncJobId){
		String result = '';
		List<AsyncApexJob> a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
								TotalJobItems, CreatedBy.Email
								FROM AsyncApexJob
								WHERE Id =:asyncJobId];
		if (!a.isEmpty()){
			result = ( a.get(0).JobItemsProcessed + 1 ) +' of '+a.get(0).TotalJobItems + ' - ';
		}

		return result;
	}

    /*
	  params : List of Question
	  return Map with Id of Question and the QuestionReportAbuse object
		Given a list of Question, it returns all the flagged ones
	*/
    public static Map<Id, QuestionReportAbuse> getFlaggedQuestions(List<Question> allQuestions) {
        Map<Id, QuestionReportAbuse> flaggedQuestions = new Map<Id, QuestionReportAbuse>();
        List<Id> questionsIds = new List<Id>();

        for (Question q : allQuestions) {
                questionsIds.add(q.Id);
        }

        List<QuestionReportAbuse> reportedQuestions = [SELECT Name, Reason, QuestionId
                                                       FROM QuestionReportAbuse
                                                       WHERE QuestionId IN : questionsIds];

        for (QuestionReportAbuse qrA : reportedQuestions) {
            flaggedQuestions.put(qrA.QuestionId, qrA);
        }

        return flaggedQuestions;
    }

    /*
	  params : List of Reply
	  return Map with Id of Reply and the ReplyReportAbuse object
		Given a list of Reply, it returns all the flagged ones
	*/
    public static Map<Id, ReplyReportAbuse> getFlaggedReplies(List<Reply> allReplies) {
        Map<Id, ReplyReportAbuse> flaggedReplies = new Map<Id, ReplyReportAbuse>();
        List<Id> repliesIds = new List<Id>();

        for (Reply r : allReplies) {
                repliesIds.add(r.Id);
        }

        List<ReplyReportAbuse> reportedReplies = [SELECT Name, Reason, ReplyId
                                                  FROM ReplyReportAbuse
                                                  WHERE ReplyId IN : repliesIds];

        for (ReplyReportAbuse rrA : reportedReplies) {
            flaggedReplies.put(rrA.ReplyId, rrA);
        }

        return flaggedReplies;
    }

    /*
	  params : Map of Question to its FeedItem, Map of QuestionId to QuestionReportAbuse
	  return List of NetworkModeration
		For each Flagged Question it returns a NetworkModeration object to be inserted
	*/
    public static List<NetworkModeration> setFlaggedFeedItems(Map<Id, FeedItem> questionToFeedItem, Map<Id, QuestionReportAbuse> flaggedQuestions) {
        List<NetworkModeration> allNM = new List<NetworkModeration>();

        for (Id questionKey : questionToFeedItem.keySet()) {
            if (flaggedQuestions.containsKey(questionKey)) {
                FeedItem fi = questionToFeedItem.get(questionKey);
                //QuestionReportAbuse qrA= flaggedQuestions.get(questionKey);

                if (fi.NetworkScope != NULL) {
                    NetworkModeration nm = new NetworkModeration(EntityId = fi.Id, NetworkId = fi.NetworkScope);

                    allNM.add(nm);
                }
            }
        }

        return allNM;
    }

    /*
	  params : Map of Reply to its FeedComment, Map of ReplyId to ReplyReportAbuse
	  return List of NetworkModeration
		For each Flagged Reply it returns a NetworkModeration object to be inserted
	*/
    public static List<NetworkModeration> setFlaggedFeedComments(Map<Id, FeedComment> replyToFeedComment, Map<Id, ReplyReportAbuse> flaggedReplies, List<FeedItem> successfulFeedItems) {
        List<NetworkModeration> allNM = new List<NetworkModeration>();

        Map<Id, FeedItem> allFeedItems = new Map<Id, FeedItem>();

        for (FeedItem fi : successfulFeedItems) {
            allFeedItems.put(fi.Id, fi);
        }

        for (Id replyKey : replyToFeedComment.keySet()) {
            if (flaggedReplies.containsKey(replyKey)) {
                FeedComment fc = replyToFeedComment.get(replyKey);
                FeedItem fi = allFeedItems.get(fc.FeedItemId);
                //ReplyReportAbuse rrA= flaggedReplies.get(replyKey);

                if (fi.NetworkScope != NULL) {
                    NetworkModeration nm = new NetworkModeration(EntityId = fc.Id, NetworkId = fi.NetworkScope);

                    allNM.add(nm);
                }
            }
        }

        return allNM;
    }
}