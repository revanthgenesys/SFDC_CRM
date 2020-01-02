/**
 * @author Altimetrik
 * @description
 *	started on 10/08/2014
 *	Front Controller for ChatterAnswers migration to Chatter Question Setup
 **/
public with sharing class ca2cq_setupCtr {
	// Constants
	//************************************************************************
	// Properties & data members

	public ca2cq_config__c setupObj{get;set;}

	public list<ca2cq_Zone_community__c>  zonesMap{get;set;}
	/*
	* @description
	*	Returns list of all available communities on the org
	* @return map<Id, Community>
	*/
	public static Map<Id,Community> allCommunities{
		get{
				if (null == allCommunities ) {
					 allCommunities = ca2cq_util.allCommunities();
				}
				return allCommunities;
		}
		private set;
	}


	/*
	* @description
	*	Returns list of all available Networks on the org
	* @return List<Network>
	*/

	public static List<Network> allNetworkList{
		get{
				if (null == allNetworkList ) {
					 allNetworkList = ca2cq_util.allNetworkList();
				}
				return allNetworkList;
		}
		private set;
	}


	/*
	* @description
	*	Returns last log record
	* @return ca2cq_log__c
	*/
	public static ca2cq_log__c lastLog{
		get{
				if (null == lastLog ) {
					 lastLog = ca2cq_logs.getLastLog(true);
				}
				return lastLog;
		}
		private set;
	}


	public static String questionIDPrefix{
		get{
				if (null == questionIDPrefix ) {
					 questionIDPrefix = Question.sObjectType.getDescribe().getKeyPrefix();
				}
				return questionIDPrefix;
		}
		private set;
	}



	/*
	* @description
	*	Returns list with mapping from Data Category API name to Topic label
	* @return list<ca2cq_categories_To_Topic__c>
	*/
	public static list<ca2cq_categories_To_Topic__c> catToTopic {
		get{
				if (null == catToTopic ) {
					catToTopic = ca2cq_util.getDCToToppics();
				}
				return catToTopic;
		}
		private set;
	}

	/*
	* @description
	*	Returns mapping from Data Category API name to Topic label
	* @return Map<String,String>
	*/
	public static Map<String,String> topicsMaps{
		get{
				if (null == topicsMaps ) {
						topicsMaps = new Map<String,String>();
						for (ca2cq_categories_To_Topic__c dc : catToTopic){
							topicsMaps.put(dc.DataCategoryName__c, dc.TopicName__c);
						}
				}
				return topicsMaps;
		}
		private set;
	}

	//************************************************************************
	// Methods

	public ca2cq_setupCtr() {
		setupObj  =  ca2cq_util.getAppSettings();
		zonesMap  = ca2cq_util.getAppCommunityMappings();
	}

	/*
	* @description
	*	Indicates if migration process can be started
	* @return Boolean
	*/
	public Boolean getCanStartProcess(){
		Boolean result = false;
		System.debug('getCanStartProcess setupObj: ' + setupObj);
		if (setupObj != null && String.isNotBlank(setupObj.Id)){
			result = (setupObj.Current_Executing_Level__c == 0 ) ||
					 (setupObj.Current_Executing_Level__c == 5) ||
					 (setupObj.Current_Executing_Level__c == 6);
		}

		System.debug('getCanStartProcess result: ' + result);
		return result;
	}

	/*
	* @description
	*	Indicates if migration process has started
	* @return Boolean
	*/
	public Boolean getIsProcessRunning(){
		System.debug('getIsProcessRunning setupObj: ' + setupObj);
		Boolean result = false;
		if (setupObj != null && String.isNotBlank(setupObj.Id)){
			result = (setupObj.Current_Executing_Level__c > 0 )&&
					( setupObj.Current_Executing_Level__c < 5  );
		}
		System.debug('getIsProcessRunning result: ' + result);
		return result;
	}

	/*
	* @description
	*	Retrieves details from async job execution
	* @return pageReference
	*/
	public void refresh(){
		setupObj  =  ca2cq_util.getAppSettings();
		getIsProcessRunning();
	}

	/*
	* @description
	*	starts migration process, launches questions and replies migration batch
	*
	*/
	public void launchBatch(){

		list<String> cList = ca2cq_util.getCommunitiesToMigrate();

		if (!cList.isEmpty() && ! getIsProcessRunning() ){
			ca2cq_util.updateExecutingLevel(1);
			refresh();

			// create new log
			boolean log = ca2cq_logs.newLog();
			System.debug('log: ' + log);
			if (log) {
				Integer bSize  =  ca2cq_util.getBatchSize();
				Id batchInstanceId = Database.executeBatch(new ca2cq_batch(),bSize);

				setupObj.Last_Batch_Id__c = batchInstanceId;
				setupObj.Last_processed_date__c = null;
				update setupObj;
			} else {
				// Log failed to be created
				ca2cq_util.updateExecutingLevel(6);
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Starting log file could not be created. Please check for storage limit.'));
			}
		}

	}

	/*
	* @description
	*	saves setup page configuration on :
	*					- email notification
	*					- zones to communities mapping
	*					- batch size
	*					- email notification
	* 					- data categories to topics mapping
	*					- all questions/only this id / exclude this ids
	*/
	public void save(){

		//parse zone to community mapping
		String param = Apexpages.currentPage().getParameters().get('zonesMap');
		list<String> tmp;

		//create map with existing ZoneIds and setup object
		 Map<Id, ca2cq_Zone_community__c> zoneIdToConfig = new Map<Id, ca2cq_Zone_community__c>();

		 for(ca2cq_Zone_community__c ca : zonesMap){
			zoneIdToConfig.put(ca.zoneId__c, ca);
		 }
		 ca2cq_Zone_community__c t;
		 Id localId;
		List<Id> allSelectedZones  = new List<Id>();
		 if (String.isNotBlank(param)){
		 	for(String pair : param.split(',')){
		 		if (String.isNotBlank(pair)){
		 			tmp = pair.split(':');
		 			localId = ID.valueOf(tmp[0]);
		 			if (zoneIdToConfig.containsKey(localId ) ){
		 				t = zoneIdToConfig.get(localId);
		 				t.Name = allCommunities.get(localId).Id;
		 				t.Community_Id__c = tmp[1];
		 				t.Active_for_Migration__c = ( tmp[2]== '1' );
						if (t.Active_for_Migration__c)
							allSelectedZones.add(localId);
		 			}
		 		}
		 	}
		 }


		String whichQuestions = Apexpages.currentPage().getParameters().get('whichQuestions');
		//includeAll //includeThis //excludeThis
		String questionIdList = Apexpages.currentPage().getParameters().get('questionIdList');
		if (!String.isNotBlank(whichQuestions))
			whichQuestions = 'includeAll';

		if ( whichQuestions != 'includeAll') {
			list<Id> validIds = new list<Id>() ;
			if ( !String.isNotBlank(questionIdList) ){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify Question record Ids '));
				return;
			}else{
				//validate questionList
				list<String> tmpIds = questionIdList.split(',');
				Map<Id,Question> validQ = new Map<Id,Question>([Select Id from Question where id in:tmpIds and CommunityId in : allSelectedZones]);
				system.debug('\n === VALIDATE IDS : \n tmpIds : '+tmpIds+
							'\n allSelectedZones : '+allSelectedZones+
							'\n validQ : '+validQ.size()+
							'\n tmpIds : '+tmpIds.size());

				if (!validQ.isEmpty()){
					validIds.addAll(validQ.keySet());
				}else
				if (validQ.size() != tmpIds.size()){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ids are invalid or they do not belong to the selected Zones '));
					return;
				}else{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Check that Ids are valid '));
					return;
				}
			}

			setupObj.Migrate_all_Questions__c = false;
			setupObj.Exclude_this_Ids__c = (whichQuestions != 'includeThis');
			setupObj.Include_this_Ids__c = (whichQuestions == 'includeThis');
			setupObj.Question_Ids__c = String.join(validIds,',');

		}else{
			setupObj.Migrate_all_Questions__c = true;
			setupObj.Exclude_this_Ids__c = false;
			setupObj.Include_this_Ids__c = false;
			setupObj.Question_Ids__c = '';

		}

		param = Apexpages.currentPage().getParameters().get('topicsMaps');
		if ( String.isNotBlank(param) ){
			//create map with existing ZoneIds and setup object
			map<String,ca2cq_categories_To_Topic__c> dcMAp = new map<String,ca2cq_categories_To_Topic__c>();
			for(ca2cq_categories_To_Topic__c e : catToTopic){
				dcMAp.put(e.DataCategoryName__c,e);
			}
			ca2cq_categories_To_Topic__c c;
			String dcNAme;
			for(String pair : param.split(',')){
				if (String.isNotBlank(pair) && pair.contains(':')){
					tmp = pair.split(':');
					if (tmp.size() >1){
						dcNAme = String.valueOf(tmp[0]);
						if (dcMAp.containsKey(dcNAme ) ){
							c = dcMAp.get(dcNAme);
							c.TopicName__c = tmp[1];
						}else{
							system.debug('\n=== dcNAme :'+dcNAme +' not in '+dcMAp);
						}
					}
				}
			}
		}

		try{
			upsert setupObj;
			upsert zonesMap;
			upsert catToTopic;
		}catch( Exception e ) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));

		}
		//so the topics are reloaded
		topicsMaps = null;
	}

}