public class NewSolutionDesignControllerClone1{
    public List<DSR_Use_Case_Blueprints__c> lstDsrUseCase{get;set;}
    public List<DSR_Use_Case_Blueprints__c> lstDsrUseCaseInteraction{get;set;}
    public List<DSR_Use_Case_Blueprints__c> lstDsrUseCaseIVR{get;set;}
    public List<DSR_Use_Case_Blueprints__c> lstDsrUseCaseOther{get;set;}
    public List<ProcessInstance> lstApprovalhistory{get;set;}
    public List<EmailMessage> lstSDOCommunication{get;set;}
    public DSR_SCEngagement__c dsrObj{get;set;}
    public New_Solution_Design__c nsdObj{get;set;}
    public string userName{get;set;}
    public string OpportunityOfferingType{get;set;}
    public string cloneId;
    public string designId;
    public string designOffering{get;set;}
    public boolean isVoiceReq {get; set;}
    public boolean isStorageReq {get; set;}
    public boolean isDialerReq {get; set;}
    public boolean isInteractionAnlayticsReq {get; set;}
    public boolean isCondrejReq {get; set;}
    public boolean isPartialReq {get; set;}
    public Solution_Design__c solDesign {get; set;}
    public String designURL {get; set;}
    public string idNsd {get;set;}
    public boolean isEditHide {get; set;}
    public Attachment newAttachment {get; set;}
    public Id attId {get; private set;}
    public NewSolutionDesignControllerClone1(ApexPages.StandardController controller){
        isVoiceReq = false;
        isStorageReq = false;
        isDialerReq = false;
        isInteractionAnlayticsReq = false;
        isCondrejReq = false;
        isPartialReq = false;
        isEditHide = false;
        designURL = '';
        solDesign = new Solution_Design__c();
        lstDsrUseCase = new List<DSR_Use_Case_Blueprints__c>();
        lstDsrUseCaseInteraction = new List<DSR_Use_Case_Blueprints__c>();
        lstDsrUseCaseIVR = new List<DSR_Use_Case_Blueprints__c>();
        lstDsrUseCaseOther = new List<DSR_Use_Case_Blueprints__c>();
        lstApprovalhistory = new List<ProcessInstance>();
        lstSDOCommunication = new List<EmailMessage>();
        nsdObj = new New_Solution_Design__c();
        userName = UserInfo.getName();
        OpportunityOfferingType = '';
        idNsd = ApexPages.CurrentPage().getParameters().get('Id'); // expected New_Solution_Design  
        string idDsr = ApexPages.CurrentPage().getParameters().get('dsrId'); // expected DSR_SCEngagement   
        cloneId = ApexPages.CurrentPage().getParameters().get('cloneId');//Clone id of New_Solution_Design 
        designId =  ApexPages.CurrentPage().getParameters().get('dsrSceId');
        String revisePage =  ApexPages.CurrentPage().getParameters().get('revise');
        List<Attachment> listOfAtts = [SELECT id, Name FROM Attachment WHERE ParentId =: idNsd ORDER BY CreatedDate DESC];
        if(!listOfAtts.isEmpty())
            attId = listOfAtts[0].id;
        newAttachment = new Attachment(ParentId = idNsd);
        
        if(idNsd != null && idNsd != ''){
            List<New_Solution_Design__c> nsdObjList = new List<New_Solution_Design__c>();
            nsdObjList = [select id, Name,SSO__c,ISR__c,Nuance_Recognizer__c,Architecture_Diagram_URL__c,Nuance_Vocalizer__c,Intelligent_Automation_Nuance__c,Voicebot_Google_Dialogflow__c,
                                Voicebot_Google_TTS__c, iTTS__c,Product_Type__c,CRM__c, CurrencyIsoCode, WFM__c, DB_Data_Access__c, Dev_Server__c, Voice_Storage__c,Screen_Storage__c,Dialer__c,Interaction_Analytics__c,Recording_Type__c,Quality_Management__c,of_Interaction_Analytics_Recognizer_Se__c  ,Calculator_attached__c ,Conditionally_Rejected__c,Partial_Saving__c,VS_calls_recorded__c,
                                PureEngage_Cloud_Capabilities_Phase_1__c, PureEngage_Cloud_Capabilities_Phase_2__c, PureEngage_Cloud_Capabilities_Phase_3__c,PureEngage_Cloud_Capabilities_Phase_11__c, 
                                PureEngage_Cloud_Capabilities_Phase_22__c, PureEngage_Cloud_Capabilities_Phase_33__c,VS_Est_storage_size_voice_GBs__c,
                                Customizations_Phase_11__c, Customizations_Phase_22__c, Customizations_Phase_33__c,SS_calls_recorded__c, SS_Est_storage_size_voice_GB__c, SS_Retention_for_call_recs_days__c, 
                                Short_Summary_of_Customer_Business_Needs__c,PureConnect_Cloud_Capabilities_Phase_1__c, PureConnect_Cloud_Capabilities_Phase_2__c, Provider_of_Inter_Region_MPLS_for_Voice__c,
                                VS_Retention_for_call_recs_days__c, Type_of_Client_Script__c, Type_of_Contact_List_Management__c,Advanced_Geo_Redundancy__c, MPLS_Connectivity_with_Customer_Network__c,
                                PureConnect_Cloud_Capabilities_Phase_3__c, Customizations_Phase_1__c, Details_of_Customizations_Requested__c, Customizations_Phase_2__c, Discovery__c , Status__c, OwnerId, 
                                Details_of_Customization_Phase_2__c, Customizations_Phase_3__c, Details_of_Customization_Phase_3__c, CaaS_Region__c, Total_Agents__c, PCI_Environment__c, 
                                Total_Supervisors__c, Deployment_Model__c, Total_Workgroups_ACD_Queue__c, Deploy_initially_with_IO_Internet_Voi__c, Total_Workgroups_General_Non_ACD__c, 
                                Redundancy_Model__c, Total_Telephony_Trunks__c, Network_MPLS_Service__c, Total_Customer_Sites__c, Internet_Egress__c, Total_Business_Users__c, Problem_Statement__c,
                                Customer_s_Goals__c, Compelling_Event__c, Pain_Points__c, Competitors__c, Current_Environment__c, Competition_Notes__c, Additional_Team_Members__c, Chain_of_Command__c, 
                                Next_Steps__c, Is_Genesys_providing_Telecom__c, Required_Phase__c, Is_Customer_providing_Telecom__c, Required_Phase_Customer_Telecom__c, Type_Genesys_Telecom__c, 
                                Does_Customer_want_to_put_the_data_traff__c, Required_Phase_Customer_data_traffic__c, If_customer_provide_their_own_hardware__c, Type_Customer_Telecom__c, 
                                Required_Phase_MPLS__c, Type_Phase_MPLS__c, Is_VPN_required_for_Agent_traffic__c, Required_Phase_Agent_traffic__c, Type_Agent_traffic__c, SC_Engagement__c, 
                                Number_of_Outbound_Campaigns__c,Number_of_Outbound_Basic_Treatments__c, Number_of_Outbound_Lists_automatically_l__c,Total_number_of_call_messaging_flows__c,Number_of_Low_Complexity_Call_Flows__c, 
Number_of_Medium_Complexity_Call_Flows__c,  Number_of_High_Complexity_Call_Flows__c,    Supported_Character_Sets_File_Encoding__c,  
Number_of_OB_calls_max_per_min_per_hour__c, Number_of_OB_calls_avg_day__c,Supported_UI_languages__c,Email_messaging_volume_max_per_min__c,Number_of_SMS_max_per_min__c ,
                                Implementation_Complexity__c, of_Personal_Voicemail_Mailboxes__c, of_Group_Voicemail_Mailboxes__c, of_Pulse_Widgets__c, Specify_Turnaround_Time_Speech_Analyti__c, 
                                Specific_KPI_for_Each_Business_Unit_to_C__c,Number_of_Business_Units_to_Configure__c, Supported_Languages_to_Analyze_Speech__c,Supported_Languages_in_IVR_ASR__c, 
                                of_Organizations_Business_Units_respon__c, Supported_Languages_in_IVR_TTS__c, of_Outbound_Lists_Automatically_Loaded__c, of_Outbound_Basic_Treatments__c, Approved_Rejected_Date__c,
                                of_Outbound_Campaigns__c, of_Genesys_Provided_DIDs_TFNs__c, of_Free_Form_Questions_in_Surveys__c, Total_Lines_of_Business__c, of_DTMF_Questions_in_Surveys__c, 
                                Total_Enterprise_Agents__c, of_Post_Call_Surveys__c, Total_Contact_Center_Agents__c,Blended_Agents__c,Outbound_Agents__c, Number_of_Genesys_provided_Inbound_phone__c, SMS_Delivery_Receipts__c, 
                                Number_of_OB_calls_max_hour__c, Number_of_Outbound_Agents__c, Number_of_OB_calls_avg_hour__c, Number_of_Genesys_provided_agent_dial_in__c,Supported_languages__c, 
                                Number_of_custom_agent_scripts__c, Supported_Countries__c, Email_messaging_volume_max_per_hour__c, Number_of_SMS_max_per_hour__c,PureEngage_Cloud_Submission_date__c,
                                Contracts_signed_MSLA_Service_Order__c, SOW_signed__c, Customer_Project_Kickoff__c, Discovery_Phase_Complete__c, Design_Phase_Completed__c, DSR_SCE_Design__c,
                                Customer_Project_Plan_Committed__c,UAT_start_Phase_1__c, Go_Live_Date_Phase_1__c, Phase_2_Go_Live__c, Phase_3_Go_Live__c,Offering_Type__c,Type_of_Campaigns__c,
                                SC_Engagement__r.Opportunity_ID__r.Region__c, TAM_Service_Element__c, Outbound_Only__c, SC_Engagement__r.Account_ID__c, SC_Engagement__r.Opportunity_ID__c,
                                SC_Engagement__r.OpportunityName__c, SC_Engagement__r.AccountName__c, Owner.Name, Design_Assumptions__c, Speech_Recognition__c,Text_to_Speech__c,
                                CAP_Name__c, 
                                (SELECT Id, Name, Commitment_Progress__c, Priority__c, Commitment_Value__c, Commitment_Delivery_Date__c, Product_Service__c FROM Field_Customer_Commit_Requests__r),
                                (SELECT Id, Name, Application_Name__c, Solution_Description__c, Application_Resource_Guide__c, Customer_Site__c,PureConnect_Cloud_Application_Name__c FROM ININ_Applications__r),
                                (SELECT Id, Name, Site_Agents__c,PCC_DataCenter_Airport_Code__c , Site_Biz_Users__c, Site_Supervisors__c, Country__c,Genesys_Site_Name__c , Customer_Site_Name__c, Phase__c, of_Corporate_Remote_Agents__c, of_Work_From_Home_WFH_Agents__c, 
                                    Location_of_Caller_Inbound_Calls__c, Location_of_Consumers_Outbound_Calls_fr__c, Is_Data_Sovereignty_needed_for_this_loca__c, Additional_Notes__c,Site_Telcom_Trunks__c,
                                    Street__c, City__c, State_Providence__c FROM Sites__r),
                                (SELECT Id, Name, Backup_Circuit__c, Bandwidth_Calculation__r.Name FROM MPLS_RVA_Data_Center_Quote_Requests__r),
                                (SELECT Id, Name, Model__c,Local_Control_Bandwidth_Mbps__c,RC_VOIP_G_711_plus_Apps_Mbps__c,RC_VOIP_G_729_plus_Apps_Mbps__c FROM Bandwidth_Calculations__r),
                                (SELECT Id, Name, Solution_Category__c,RecordTypeid,RecordType.Name, Component_Type__c, Component_Function__c, Model__c, Quantity__c, Providing_Party__c,Providing_Party_Cloud__c,Component_Function_Cloud__c, Customer_Site__r.Name,Customer_Site__r.PCC_DataCenter_Airport_Code__c,Model_Cloud__c, Customer_Site__r.Genesys_Site_Name__c , Customer_Site__r.Customer_Site_Name__c FROM ININ_Solution_Components__r)
                            FROM New_Solution_Design__c where Id =: idNsd];
            
            lstSDOCommunication = [SELECT id,FromAddress, ToAddress, Subject,Deal_Support_Communication_Name__c, RelatedToId, MessageDate, TextBody FROM EmailMessage WHERE RelatedToId =: idNsd order by Deal_Support_Communication_Name__c DESC];
            
            if(nsdObjList.size()> 0){
                nsdObj= nsdObjList[0] ;
                idDsr = nsdObjList[0].SC_Engagement__c;
                designOffering = nsdObjList[0].Offering_Type__c;
            }
            lstApprovalhistory = [SELECT Id, (SELECT Id, CreatedDate, OriginalActor.Name, Actor.Name, StepStatus, Comments FROM StepsAndWorkitems order by ID DESC ) 
                                        FROM ProcessInstance WHERE TargetObjectId = :idNsd order by createdDate DESC];
            
        }
        
        if(cloneId != null && cloneId != ''){
            List<New_Solution_Design__c> nsdObjList = new List<New_Solution_Design__c>();
            nsdObjList = [select Name, Account__c,Product_Type__c,CRM__c,SSO__c,ISR__c,Architecture_Diagram_URL__c,Nuance_Recognizer__c,Nuance_Vocalizer__c,Intelligent_Automation_Nuance__c,Voicebot_Google_Dialogflow__c,
                                Voicebot_Google_TTS__c, iTTS__c,CurrencyIsoCode, WFM__c, DB_Data_Access__c, Dev_Server__c, Voice_Storage__c,Screen_Storage__c,Dialer__c,Interaction_Analytics__c,Recording_Type__c,Quality_Management__c,of_Interaction_Analytics_Recognizer_Se__c  ,Calculator_attached__c ,Conditionally_Rejected__c ,Partial_Saving__c,VS_calls_recorded__c,
                                PureEngage_Cloud_Capabilities_Phase_1__c, PureEngage_Cloud_Capabilities_Phase_2__c, PureEngage_Cloud_Capabilities_Phase_3__c,PureEngage_Cloud_Capabilities_Phase_11__c, 
                                PureEngage_Cloud_Capabilities_Phase_22__c, PureEngage_Cloud_Capabilities_Phase_33__c, VS_Est_storage_size_voice_GBs__c,
                                Customizations_Phase_11__c, Customizations_Phase_22__c, Customizations_Phase_33__c,SS_calls_recorded__c, SS_Est_storage_size_voice_GB__c, SS_Retention_for_call_recs_days__c, 
                                Short_Summary_of_Customer_Business_Needs__c,PureConnect_Cloud_Capabilities_Phase_1__c, PureConnect_Cloud_Capabilities_Phase_2__c,  Provider_of_Inter_Region_MPLS_for_Voice__c,
                                VS_Retention_for_call_recs_days__c, Type_of_Client_Script__c, Type_of_Contact_List_Management__c,Advanced_Geo_Redundancy__c, MPLS_Connectivity_with_Customer_Network__c,
                                PureConnect_Cloud_Capabilities_Phase_3__c, Customizations_Phase_1__c, Details_of_Customizations_Requested__c, Customizations_Phase_2__c, Discovery__c, Status__c, OwnerId,
                                Details_of_Customization_Phase_2__c, Customizations_Phase_3__c, Details_of_Customization_Phase_3__c, CaaS_Region__c, Total_Agents__c, PCI_Environment__c, 
                                Total_Supervisors__c, Deployment_Model__c, Total_Workgroups_ACD_Queue__c, Deploy_initially_with_IO_Internet_Voi__c, Total_Workgroups_General_Non_ACD__c, 
                                Redundancy_Model__c, Total_Telephony_Trunks__c, Network_MPLS_Service__c, Total_Customer_Sites__c, Internet_Egress__c, Total_Business_Users__c, Problem_Statement__c,
                                Customer_s_Goals__c, Compelling_Event__c, Pain_Points__c, Competitors__c, Current_Environment__c, Competition_Notes__c, Additional_Team_Members__c, Chain_of_Command__c, 
                                Next_Steps__c, Is_Genesys_providing_Telecom__c, Required_Phase__c, Is_Customer_providing_Telecom__c, Required_Phase_Customer_Telecom__c, Type_Genesys_Telecom__c, 
                                Does_Customer_want_to_put_the_data_traff__c, Required_Phase_Customer_data_traffic__c, If_customer_provide_their_own_hardware__c, Type_Customer_Telecom__c,  
                                Required_Phase_MPLS__c, Type_Phase_MPLS__c, Is_VPN_required_for_Agent_traffic__c, Required_Phase_Agent_traffic__c, Type_Agent_traffic__c, SC_Engagement__c, 
                                Number_of_Outbound_Campaigns__c,Number_of_Outbound_Basic_Treatments__c, Number_of_Outbound_Lists_automatically_l__c,Total_number_of_call_messaging_flows__c,Number_of_Low_Complexity_Call_Flows__c, 
Number_of_Medium_Complexity_Call_Flows__c,  Number_of_High_Complexity_Call_Flows__c,    Supported_Character_Sets_File_Encoding__c,  
Number_of_OB_calls_max_per_min_per_hour__c, Number_of_OB_calls_avg_day__c,Supported_UI_languages__c,Email_messaging_volume_max_per_min__c,Number_of_SMS_max_per_min__c ,
                                Implementation_Complexity__c, of_Personal_Voicemail_Mailboxes__c, of_Group_Voicemail_Mailboxes__c, of_Pulse_Widgets__c, Specify_Turnaround_Time_Speech_Analyti__c, 
                                Specific_KPI_for_Each_Business_Unit_to_C__c,Number_of_Business_Units_to_Configure__c, Supported_Languages_to_Analyze_Speech__c,Supported_Languages_in_IVR_ASR__c, 
                                of_Organizations_Business_Units_respon__c, Supported_Languages_in_IVR_TTS__c, of_Outbound_Lists_Automatically_Loaded__c, of_Outbound_Basic_Treatments__c, Approved_Rejected_Date__c,
                                of_Outbound_Campaigns__c, of_Genesys_Provided_DIDs_TFNs__c, of_Free_Form_Questions_in_Surveys__c, Total_Lines_of_Business__c, of_DTMF_Questions_in_Surveys__c, 
                                Total_Enterprise_Agents__c, of_Post_Call_Surveys__c, Total_Contact_Center_Agents__c,Blended_Agents__c,Outbound_Agents__c, Number_of_Genesys_provided_Inbound_phone__c, SMS_Delivery_Receipts__c, 
                                Number_of_OB_calls_max_hour__c, Number_of_Outbound_Agents__c, Number_of_OB_calls_avg_hour__c, Number_of_Genesys_provided_agent_dial_in__c,Supported_languages__c, 
                                Number_of_custom_agent_scripts__c, Supported_Countries__c, Email_messaging_volume_max_per_hour__c, Number_of_SMS_max_per_hour__c,PureEngage_Cloud_Submission_date__c,
                                Contracts_signed_MSLA_Service_Order__c, SOW_signed__c, Customer_Project_Kickoff__c, Discovery_Phase_Complete__c, Design_Phase_Completed__c, DSR_SCE_Design__c,
                                Customer_Project_Plan_Committed__c,UAT_start_Phase_1__c, Go_Live_Date_Phase_1__c, Phase_2_Go_Live__c, Phase_3_Go_Live__c,Offering_Type__c,Type_of_Campaigns__c,
                                SC_Engagement__r.Opportunity_ID__r.Region__c, TAM_Service_Element__c, Outbound_Only__c, SC_Engagement__r.Account_ID__c, SC_Engagement__r.Opportunity_ID__c,
                                SC_Engagement__r.OpportunityName__c, SC_Engagement__r.AccountName__c, Owner.Name,CAP_Name__c ,Design_Assumptions__c ,Speech_Recognition__c,Text_to_Speech__c,
                                (SELECT Id, Name, Commitment_Progress__c, Priority__c, Commitment_Value__c, Commitment_Delivery_Date__c, Product_Service__c FROM Field_Customer_Commit_Requests__r),
                                (SELECT Id, Name, Application_Name__c, Solution_Description__c, Application_Resource_Guide__c, Customer_Site__c,PureConnect_Cloud_Application_Name__c  FROM ININ_Applications__r),
                                (SELECT Id, Name, Site_Agents__c,PCC_DataCenter_Airport_Code__c, Site_Biz_Users__c, Site_Supervisors__c, Country__c,Genesys_Site_Name__c , Customer_Site_Name__c, Phase__c, of_Corporate_Remote_Agents__c, of_Work_From_Home_WFH_Agents__c, 
                                    Location_of_Caller_Inbound_Calls__c, Location_of_Consumers_Outbound_Calls_fr__c, Is_Data_Sovereignty_needed_for_this_loca__c, Additional_Notes__c,Site_Telcom_Trunks__c,
                                    Street__c, City__c, State_Providence__c FROM Sites__r),
                                (SELECT Id, Name, Backup_Circuit__c, Bandwidth_Calculation__r.Name FROM MPLS_RVA_Data_Center_Quote_Requests__r),
                                (SELECT Id, Name, Model__c,Local_Control_Bandwidth_Mbps__c,RC_VOIP_G_711_plus_Apps_Mbps__c,RC_VOIP_G_729_plus_Apps_Mbps__c FROM Bandwidth_Calculations__r),
                                (SELECT Id, Name, Solution_Category__c, RecordTypeid,RecordType.Name,Component_Type__c, Component_Function__c, Model__c, Quantity__c, Providing_Party__c, Customer_Site__r.Name ,Customer_Site__r.PCC_DataCenter_Airport_Code__c,Customer_Site__r.Genesys_Site_Name__c , Customer_Site__r.Customer_Site_Name__c ,Providing_Party_Cloud__c FROM ININ_Solution_Components__r)
                             FROM New_Solution_Design__c where Id =: cloneId];
            lstSDOCommunication = [SELECT id,FromAddress, ToAddress, Subject,Deal_Support_Communication_Name__c, RelatedToId, MessageDate FROM EmailMessage WHERE RelatedToId =: cloneId order by Deal_Support_Communication_Name__c DESC];
            
            if(nsdObjList.size()> 0){
                nsdObj= nsdObjList[0];
                nsdObj.Status__c = 'New';
              //  nsdObj.Opportunitylookup__c = nsdObj.SC_Engagement__r.Opportunity_ID__c;
                system.debug('11  '+nsdObj);
                //nsdObj.SC_Engagement__c = dsrObj.Id;
                //system.debug('11q  '+dsrObj.Id);
                //idDsr = nsdObjList[0].SC_Engagement__c;
            }
            lstApprovalhistory = [SELECT Id, (SELECT Id, CreatedDate, OriginalActor.Name, Actor.Name, StepStatus, Comments FROM StepsAndWorkitems order by ID DESC ) 
                                        FROM ProcessInstance WHERE TargetObjectId = :idNsd order by createdDate DESC];
            
        }
        
        if(designId != NULL){
            LIst<DSR_SCE_Design__c> designObj = [SELECT Id, OfferingPlatformType__c FROM DSR_SCE_Design__c WHERE id=:designId];
            designOffering = designObj[0].OfferingPlatformType__c;
            nsdObj.DSR_SCE_Design__c = designObj[0].Id;
        } 
        
        if(idDsr != null && idDsr != ''){
            dsrObj = [SELECT id, OpportunityOfferingType__c, Name, Primary_Design_ID__c,Account_ID__c,OpportunityPlatformType__c, Opportunity_ID__r.Name,
                          Opportunity_ID__c,Opportunity_ID__r.Sales_Region__c,Opportunity_ID__r.Country_Region__c , Opportunity_ID__r.stageName, Opportunity_ID__r.ForecastStatus__c, 
                          Opportunity_ID__r.Type, Primary_Design_ID__r.IsPrimary__c, Opportunity_ID__r.Annual_Contract_Value__c, Opportunity_ID__r.TCV_PS__c,Opportunity_ID__r.owner.email, 
                          CreatedDate, LastModifiedDate, Rejected_Reason__c,SC_Engagement_Status__c 
                          FROM DSR_SCEngagement__c WHERE Id =: idDsr];
            
            OpportunityOfferingType = dsrObj.OpportunityOfferingType__c;
            nsdObj.SC_Engagement__c = dsrObj.Id;
            nsdObj.Account__c = dsrObj.Account_ID__c;
            idDsr = dsrObj.Id;
            
            for(DSR_Use_Case_Blueprints__c usblue : [select id, Name, Name__c, ShortCode__c, DetailedChangeDescription__c, Fit__c, FitCategory__c, 
                                                        ShortChangeDescription__c, VersionUsed__c, Notes__c 
                                                        FROM DSR_Use_Case_Blueprints__c where Type__c = 'Use Case' And DSRSCEDesign__c =: nsdObj.DSR_SCE_Design__c]){
                if(usblue.DetailedChangeDescription__c == null)
                    usblue.DetailedChangeDescription__c='';
                if(usblue.Name__c == null)
                    usblue.Name__c='';
                
                if(!(usblue.Name__c.containsIgnoreCase('IVR')) && usblue.DetailedChangeDescription__c.containsIgnoreCase('interaction'))
                    lstDsrUseCaseInteraction.add(usblue);
                
                else if(usblue.Name__c.containsIgnoreCase('IVR'))
                    lstDsrUseCaseIVR.add(usblue);
                
                else if(usblue.ShortCode__c =='Custom')
                    lstDsrUseCaseOther.add(usblue);
                else
                    lstDsrUseCase.add(usblue);
            }
            
            for(DSR_Use_Case_Blueprints__c usblue : [SELECT Id FROM DSR_Use_Case_Blueprints__c
                                                        WHERE Type__c = 'Blueprint' And DSRSCEDesign__c =: nsdObj.DSR_SCE_Design__c
                                                        AND DSRSCEDesign__r.IsPrimary__c = true]){
                //designURL
            }
        } 
        String solutionId = Label.Solution_Design_Id;
        if(solutionId != null){
            List<Solution_Design__c> sdObjList = new List<Solution_Design__c>([SELECT Id, Name FROM Solution_Design__c WHERE Id =:solutionId]);
            if(sdObjList.size() > 0){
                solDesign = sdObjList.get(0);
            }
        }
        if(nsdObj.Partial_Saving__c ){
            isPartialReq = true;
        }
          if(nsdObj.Dialer__c){
            isDialerReq = true;
        }
        if(nsdObj.Interaction_Analytics__c){
        isInteractionAnlayticsReq= true; }
        if(nsdObj.Conditionally_Rejected__c ){
            isCondrejReq = true;
        }
        if(nsdObj.Screen_Storage__c != '' && nsdObj.Screen_Storage__c != null){
            isStorageReq  = true;
        }
        if(nsdObj.Voice_Storage__c != '' && nsdObj.Voice_Storage__c != null){
            isVoiceReq = true;
        }
        if(revisePage == null && nsdObj.Status__c == 'Submitted for Approval'){
            isEditHide = true;
        }
      nsdObj.Partial_Saving__c = true;
    }
    
    Public Pagereference uploadAttachment(){
        Attachment newAtt = new Attachment(parentId = idNsd, Name = newAttachment.name, body = newAttachment.body);
        insert newAtt;
       newAttachment = new Attachment(ParentId = idNsd);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Attachment uploaded successfully!'));
        return new PageReference('/apex/NewSolutionDesignVFClone1?id='+idNsd);
    }   
    public void refresh(){}
    public NewSolutionDesignControllerClone1(){
        lstDsrUseCase = new List<DSR_Use_Case_Blueprints__c>();
        lstDsrUseCaseInteraction = new List<DSR_Use_Case_Blueprints__c>();
        lstDsrUseCaseIVR = new List<DSR_Use_Case_Blueprints__c>();
        lstDsrUseCaseOther = new List<DSR_Use_Case_Blueprints__c>();
        idNsd = ApexPages.CurrentPage().getParameters().get('Id'); // expected New_Solution_Design 
        string idDsr = ApexPages.CurrentPage().getParameters().get('dsrId'); // expected DSR_SCEngagement  
        if(idNsd != null && idNsd != ''){
            List<New_Solution_Design__c> nsdObjList = new List<New_Solution_Design__c>();
            nsdObjList = [select id, Name,Account__c, Product_Type__c,CRM__c,SSO__c,ISR__c,Architecture_Diagram_URL__c,Nuance_Recognizer__c,Nuance_Vocalizer__c,Intelligent_Automation_Nuance__c,Voicebot_Google_Dialogflow__c,
                                Voicebot_Google_TTS__c, iTTS__c, CurrencyIsoCode, WFM__c, DB_Data_Access__c, Dev_Server__c, Voice_Storage__c,Screen_Storage__c,Dialer__c,Interaction_Analytics__c,Recording_Type__c,Quality_Management__c,of_Interaction_Analytics_Recognizer_Se__c ,Calculator_attached__c ,Conditionally_Rejected__c ,VS_calls_recorded__c,
                                PureEngage_Cloud_Capabilities_Phase_1__c, PureEngage_Cloud_Capabilities_Phase_2__c, PureEngage_Cloud_Capabilities_Phase_3__c,PureEngage_Cloud_Capabilities_Phase_11__c, 
                                PureEngage_Cloud_Capabilities_Phase_22__c, PureEngage_Cloud_Capabilities_Phase_33__c, VS_Est_storage_size_voice_GBs__c,
                                Customizations_Phase_11__c, Customizations_Phase_22__c, Customizations_Phase_33__c,SS_calls_recorded__c, SS_Est_storage_size_voice_GB__c, SS_Retention_for_call_recs_days__c, 
                                Short_Summary_of_Customer_Business_Needs__c,PureConnect_Cloud_Capabilities_Phase_1__c, PureConnect_Cloud_Capabilities_Phase_2__c, Provider_of_Inter_Region_MPLS_for_Voice__c,
                                VS_Retention_for_call_recs_days__c, Type_of_Client_Script__c, Type_of_Contact_List_Management__c,Advanced_Geo_Redundancy__c, MPLS_Connectivity_with_Customer_Network__c,
                                PureConnect_Cloud_Capabilities_Phase_3__c, Customizations_Phase_1__c, Details_of_Customizations_Requested__c, Customizations_Phase_2__c, Discovery__c , Status__c, OwnerId, 
                                Details_of_Customization_Phase_2__c, Customizations_Phase_3__c, Details_of_Customization_Phase_3__c, CaaS_Region__c, Total_Agents__c, PCI_Environment__c, 
                                Number_of_Outbound_Campaigns__c,Number_of_Outbound_Basic_Treatments__c, Number_of_Outbound_Lists_automatically_l__c,Total_number_of_call_messaging_flows__c,Number_of_Low_Complexity_Call_Flows__c, 
                                Number_of_Medium_Complexity_Call_Flows__c,  Number_of_High_Complexity_Call_Flows__c,    Supported_Character_Sets_File_Encoding__c,  
                                Number_of_OB_calls_max_per_min_per_hour__c, Number_of_OB_calls_avg_day__c,Supported_UI_languages__c,Email_messaging_volume_max_per_min__c,Number_of_SMS_max_per_min__c ,
                                Total_Supervisors__c, Deployment_Model__c, Total_Workgroups_ACD_Queue__c, Deploy_initially_with_IO_Internet_Voi__c, Total_Workgroups_General_Non_ACD__c, 
                                Redundancy_Model__c, Total_Telephony_Trunks__c, Network_MPLS_Service__c, Total_Customer_Sites__c, Internet_Egress__c, Total_Business_Users__c, Problem_Statement__c,
                                Customer_s_Goals__c, Compelling_Event__c, Pain_Points__c, Competitors__c, Current_Environment__c, Competition_Notes__c, Additional_Team_Members__c, Chain_of_Command__c, 
                                Next_Steps__c, Is_Genesys_providing_Telecom__c, Required_Phase__c, Is_Customer_providing_Telecom__c, Required_Phase_Customer_Telecom__c, Type_Genesys_Telecom__c,
                                Does_Customer_want_to_put_the_data_traff__c, Required_Phase_Customer_data_traffic__c, If_customer_provide_their_own_hardware__c, Type_Customer_Telecom__c, 
                                Required_Phase_MPLS__c, Type_Phase_MPLS__c, Is_VPN_required_for_Agent_traffic__c, Required_Phase_Agent_traffic__c, Type_Agent_traffic__c, SC_Engagement__c, 
                                Implementation_Complexity__c, of_Personal_Voicemail_Mailboxes__c, of_Group_Voicemail_Mailboxes__c, of_Pulse_Widgets__c, Specify_Turnaround_Time_Speech_Analyti__c, 
                                Specific_KPI_for_Each_Business_Unit_to_C__c,Number_of_Business_Units_to_Configure__c, Supported_Languages_to_Analyze_Speech__c,Supported_Languages_in_IVR_ASR__c, 
                                of_Organizations_Business_Units_respon__c, Supported_Languages_in_IVR_TTS__c, of_Outbound_Lists_Automatically_Loaded__c, of_Outbound_Basic_Treatments__c, 
                                of_Outbound_Campaigns__c, of_Genesys_Provided_DIDs_TFNs__c, of_Free_Form_Questions_in_Surveys__c, Total_Lines_of_Business__c, of_DTMF_Questions_in_Surveys__c, 
                                Total_Enterprise_Agents__c, of_Post_Call_Surveys__c, Total_Contact_Center_Agents__c,Blended_Agents__c,Outbound_Agents__c, Number_of_Genesys_provided_Inbound_phone__c, SMS_Delivery_Receipts__c, 
                                Number_of_OB_calls_max_hour__c, Number_of_Outbound_Agents__c, Number_of_OB_calls_avg_hour__c, Number_of_Genesys_provided_agent_dial_in__c,Supported_languages__c, 
                                Number_of_custom_agent_scripts__c, Supported_Countries__c, Email_messaging_volume_max_per_hour__c, Number_of_SMS_max_per_hour__c,PureEngage_Cloud_Submission_date__c,
                                Contracts_signed_MSLA_Service_Order__c, SOW_signed__c, Customer_Project_Kickoff__c, Discovery_Phase_Complete__c, Design_Phase_Completed__c, DSR_SCE_Design__c,
                                Customer_Project_Plan_Committed__c,UAT_start_Phase_1__c, Go_Live_Date_Phase_1__c, Phase_2_Go_Live__c, Phase_3_Go_Live__c,Offering_Type__c,Type_of_Campaigns__c,
                                SC_Engagement__r.Opportunity_ID__r.Region__c, TAM_Service_Element__c, Outbound_Only__c, SC_Engagement__r.Account_ID__c, SC_Engagement__r.Opportunity_ID__c,
                                SC_Engagement__r.OpportunityName__c, SC_Engagement__r.AccountName__c, Owner.Name,CAP_Name__c ,Design_Assumptions__c ,Speech_Recognition__c,Text_to_Speech__c,Approved_Rejected_Date__c,
                                (SELECT Id, Name, Commitment_Progress__c, Priority__c, Commitment_Value__c, Commitment_Delivery_Date__c, Product_Service__c FROM Field_Customer_Commit_Requests__r),
                                (SELECT Id, Name, Application_Name__c, Solution_Description__c, Application_Resource_Guide__c, Customer_Site__c,PureConnect_Cloud_Application_Name__c  FROM ININ_Applications__r),
                                (SELECT Id, Name, Site_Agents__c,PCC_DataCenter_Airport_Code__c, Site_Biz_Users__c, Site_Supervisors__c, Country__c, Customer_Site_Name__c, Phase__c, of_Corporate_Remote_Agents__c, of_Work_From_Home_WFH_Agents__c, 
                                    Location_of_Caller_Inbound_Calls__c, Location_of_Consumers_Outbound_Calls_fr__c, Is_Data_Sovereignty_needed_for_this_loca__c, Additional_Notes__c,Site_Telcom_Trunks__c,
                                    Street__c, City__c, State_Providence__c FROM Sites__r),
                                (SELECT Id, Name, Backup_Circuit__c, Bandwidth_Calculation__r.Name FROM MPLS_RVA_Data_Center_Quote_Requests__r),
                                (SELECT Id, Name, Model__c,Local_Control_Bandwidth_Mbps__c,RC_VOIP_G_711_plus_Apps_Mbps__c,RC_VOIP_G_729_plus_Apps_Mbps__c FROM Bandwidth_Calculations__r),
                                (SELECT Id, Name, Solution_Category__c, RecordTypeid,RecordType.Name,Component_Type__c, Component_Function__c, Model__c, Quantity__c, Providing_Party__c,Component_Function_Cloud__c, Customer_Site__r.Name ,Customer_Site__r.PCC_DataCenter_Airport_Code__c,Customer_Site__r.Genesys_Site_Name__c , Customer_Site__r.Customer_Site_Name__c ,Providing_Party_Cloud__c FROM ININ_Solution_Components__r)
                            FROM New_Solution_Design__c where Id =: idNsd];
            
            lstSDOCommunication = [SELECT id,FromAddress, ToAddress, Subject,Deal_Support_Communication_Name__c, RelatedToId, MessageDate, TextBody FROM EmailMessage WHERE RelatedToId =: idNsd order by Deal_Support_Communication_Name__c DESC];
            
            if(nsdObjList.size()> 0){
                nsdObj= nsdObjList[0] ;
                idDsr = nsdObjList[0].SC_Engagement__c;
                designOffering = nsdObjList[0].Offering_Type__c;
            }
        }
        
        if(idDsr != null && idDsr != ''){
            dsrObj = [SELECT id, OpportunityOfferingType__c, Name, Primary_Design_ID__c,Account_ID__c,OpportunityPlatformType__c, Opportunity_ID__r.Name,
                          Opportunity_ID__c,Opportunity_ID__r.Sales_Region__c,Opportunity_ID__r.Country_Region__c , Opportunity_ID__r.stageName, Opportunity_ID__r.ForecastStatus__c, 
                          Opportunity_ID__r.Type, Primary_Design_ID__r.IsPrimary__c, Opportunity_ID__r.Annual_Contract_Value__c, Opportunity_ID__r.TCV_PS__c, 
                          CreatedDate, LastModifiedDate, Rejected_Reason__c,SC_Engagement_Status__c 
                          FROM DSR_SCEngagement__c WHERE Id =: idDsr];
            
            OpportunityOfferingType = dsrObj.OpportunityOfferingType__c;
            nsdObj.SC_Engagement__c = dsrObj.Id;
            idDsr = dsrObj.Id;
            
            for(DSR_Use_Case_Blueprints__c usblue : [select id, Name, Name__c, ShortCode__c, DetailedChangeDescription__c, Fit__c, FitCategory__c, 
                                                        ShortChangeDescription__c, VersionUsed__c, Notes__c 
                                                        FROM DSR_Use_Case_Blueprints__c where Type__c = 'Use Case' And DSRSCEDesign__c =: nsdObj.DSR_SCE_Design__c]){
                if(usblue.DetailedChangeDescription__c == null)
                    usblue.DetailedChangeDescription__c='';
                if(usblue.Name__c == null)
                    usblue.Name__c='';
                
                if(!(usblue.Name__c.containsIgnoreCase('IVR')) && usblue.DetailedChangeDescription__c.containsIgnoreCase('interaction'))
                    lstDsrUseCaseInteraction.add(usblue);
                
                else if(usblue.Name__c.containsIgnoreCase('IVR'))
                    lstDsrUseCaseIVR.add(usblue);
                
                else if(usblue.ShortCode__c =='Custom')
                    lstDsrUseCaseOther.add(usblue);
                else
                    lstDsrUseCase.add(usblue);
            }
            
            for(DSR_Use_Case_Blueprints__c usblue : [SELECT Id FROM DSR_Use_Case_Blueprints__c
                                                        WHERE Type__c = 'Blueprint' And DSRSCEDesign__c =: nsdObj.DSR_SCE_Design__c
                                                        AND DSRSCEDesign__r.IsPrimary__c = true]){
                //designURL
            }
        } 
        String solutionId = Label.Solution_Design_Id;
        if(solutionId != null){
            List<Solution_Design__c> sdObjList = new List<Solution_Design__c>([SELECT Id, Name FROM Solution_Design__c WHERE Id =:solutionId]);
            if(sdObjList.size() > 0){
                solDesign = sdObjList.get(0);
            }
        } 
    }
    
    public PageReference saveRecord(){
        try{
            nsdObj.Name = nsdObj.CAP_Name__c;
            if(cloneId != null){
                nsdObj.Id = null;
                insert nsdObj;  
                
             List<Customer_Site__c> CustomerSite = new List<Customer_Site__c>();
                for (Customer_Site__c cSite  : [SELECT Id, Name, Site_Agents__c,Account__c,Account_Site__c,Customer_Site_Name__c,Genesys_Site_Name__c, RecordTypeid,
                   City__c,Location_Type__c,State_Providence__c,Street__c,Zip__c,Site_Biz_Users__c,Site_Supervisors__c,Site_Telcom_Trunks__c,SiteAddress__c,Site_Address__c,
                   Country__c,of_Work_From_Home_WFH_Agents__c,of_Corporate_Remote_Agents__c,New_Solution_Design__c,Solution_Design__c FROM Customer_Site__c where New_Solution_Design__c =: cloneId]) {
                    
                    Customer_Site__c newcSite = cSite.clone(false,true);
                    newcSite.New_Solution_Design__c = nsdObj.id;
                    newcSite.Site_Agents__c = cSite.Site_Agents__c;
                    newcSite.Account__c = cSite.Account__c;
                    newcSite.Account_Site__c= cSite.Account_Site__c;
                    newcSite.Customer_Site_Name__c= cSite.Customer_Site_Name__c;
                    newcSite.Genesys_Site_Name__c= cSite.Genesys_Site_Name__c;
                    newcSite.Solution_Design__c = cSite.Solution_Design__c;
                    newcSite.RecordTypeid = cSite.RecordTypeid;
                    newcSite.City__c = cSite.City__c ; 
                    newcSite.Location_Type__c = cSite.Location_Type__c ;
                    newcSite.State_Providence__c = cSite.State_Providence__c ;
                    newcSite.Street__c = cSite.Street__c ;
                    newcSite.Zip__c = cSite.Zip__c ;
                    newcSite.Site_Biz_Users__c = cSite.Site_Biz_Users__c ;
                    newcSite.Site_Supervisors__c = cSite.Site_Supervisors__c ;
                    newcSite.Site_Telcom_Trunks__c = cSite.Site_Telcom_Trunks__c ;
                    newcSite.SiteAddress__c = cSite.SiteAddress__c ;
                    newcSite.Site_Address__c = cSite.Site_Address__c ;
                    newcSite.Country__c = cSite.Country__c ;
                    newcSite.of_Work_From_Home_WFH_Agents__c = cSite.of_Work_From_Home_WFH_Agents__c ;
                    newcSite.of_Corporate_Remote_Agents__c = cSite.of_Corporate_Remote_Agents__c ;
                   // newcSite. = cSite. ;
                    CustomerSite.add(newcSite);
                    system.debug('CustomerSite2'  );
                } 
                if(CustomerSite.Size()>0){
                insert CustomerSite; }
                
                List<ININ_Applications__c> applicationinin = new List<ININ_Applications__c>();
                for (ININ_Applications__c capplication  : [SELECT Id, Name ,Application_Name__c,Application_Resource_Guide__c ,Customer_Site__c,LegacyId__c,New_Solution_Design__c,
                PC_Solution__c,PureCloud_Applications__c,PureConnect_Cloud_Application_Name__c,Solution_Description__c,Solution_Design__c,
                Source__c,Synchronization__c FROM ININ_Applications__c where New_Solution_Design__c =: cloneId]) {
                    
                    ININ_Applications__c newApplication = capplication.clone(false,true);
                    newApplication.New_Solution_Design__c = nsdObj.id;
                    newApplication.Application_Name__c = capplication.Application_Name__c;
                    newApplication.PC_Solution__c = capplication.PC_Solution__c ;
                    newApplication.Application_Resource_Guide__c = capplication.Application_Resource_Guide__c ;
                    newApplication.Customer_Site__c = capplication.Customer_Site__c ;
                    newApplication.LegacyId__c = capplication.LegacyId__c ;
                    newApplication.PureCloud_Applications__c = capplication.PureCloud_Applications__c ;
                    newApplication.PureConnect_Cloud_Application_Name__c = capplication.PureConnect_Cloud_Application_Name__c ;
                    newApplication.Solution_Description__c = capplication.Solution_Description__c ;
                    newApplication.Solution_Design__c = capplication.Solution_Design__c ;
                   
                   // newcSite. = cSite. ;
                    applicationinin.add(newApplication);
                    
                } 
                if(applicationinin.Size()>0){
                insert applicationinin; }
                
                List<ININ_Solution_Components__c> solComp = new List<ININ_Solution_Components__c>();
                for (ININ_Solution_Components__c sComponent  : [SELECT Id, Name ,Component_Function_Cloud__c,Component_Function__c,Component_Type__c,Customer_Site__c,
                Legacy_Id__c, Model__c, Model_Cloud__c, New_Solution_Design__c, Notes__c, Providing_Party__c, Providing_Party_Cloud__c, Quantity__c, Solution_Category__c, Solution_Design__c,
                Specifications__c,RecordTypeid,RecordType.Name FROM ININ_Solution_Components__c where New_Solution_Design__c =: cloneId]) {
                    
                    ININ_Solution_Components__c newSolComponent =  sComponent.clone(false,true);
                    newSolComponent.New_Solution_Design__c = nsdObj.id;
                    newSolComponent.Component_Function_Cloud__c = sComponent.Component_Function_Cloud__c;
                    newSolComponent.Component_Function__c = sComponent.Component_Function__c;
                    newSolComponent.Component_Type__c = sComponent.Component_Type__c;
                    newSolComponent.Legacy_Id__c = sComponent.Legacy_Id__c;
                    newSolComponent.Model__c = sComponent.Model__c;
                    newSolComponent.Model_Cloud__c = sComponent.Model_Cloud__c;
                    newSolComponent.Notes__c = sComponent.Notes__c;
                    newSolComponent.Providing_Party__c = sComponent.Providing_Party__c;
                    newSolComponent.Providing_Party_Cloud__c = sComponent.Providing_Party_Cloud__c;
                    newSolComponent.Quantity__c = sComponent.Quantity__c;
                    newSolComponent.Solution_Category__c = sComponent.Solution_Category__c;
                    newSolComponent.Specifications__c = sComponent.Specifications__c;
                    newSolComponent.RecordTypeid = sComponent.RecordTypeid;
                   // newcSite. = cSite. ;
                    solComp.add(newSolComponent);
                    
                } 
                if(solComp.Size()>0){
                insert solComp; }

                
            }else{
                nsdObj.SC_Engagement__c = dsrObj.Id;
              //  system.debug('dsrObj.Opportunity_ID__r.Owner.email' + dsrObj.Opportunity_ID__r.Owner.email);
                nsdObj.Opportunity_Owner_Email__c = dsrObj.Opportunity_ID__r.Owner.email;
                nsdObj.Account__c = dsrObj.Account_ID__c;
                upsert nsdObj;
            }
            PageReference PageRef = new PageReference('/apex/NewSolutionDesignView?Id='+nsdObj.Id);
            PageRef.setRedirect(true);
            return PageRef;
        }catch(Exception ex){
            System.debug('----err0r----'+ex);
            return null;
        }
    }
    
    public PageReference editRecord(){
        PageReference PageRef = new PageReference('/apex/NewSolutionDesignVFClone1?Id='+nsdObj.Id);
        PageRef.setRedirect(true);
        return PageRef;
    }
    
    
    public PageReference reviseRecord(){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Auto rejected by the system');
        req.setAction('Reject');
        Id workItemId = getWorkItemId(nsdObj.id); 
        if(workItemId == null){
            //opp.addError('Error Occured in Trigger');
        }
        else{
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(req);
        }
        
        nsdObj.Status__c = 'Revision Pending';
        update nsdObj;
        
        PageReference PageRef = new PageReference('/apex/NewSolutionDesignVFClone1?Id='+nsdObj.Id+'&revise=revise');
        PageRef.setRedirect(true);
        return PageRef;
    }
    
    public Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
                                                    where p.ProcessInstance.TargetObjectId =: targetObjectId]){
            retVal  =  workItem.Id;
        }
        return retVal;
    }
        
    public PageReference SubmitApproval(){
        boolean iFlag = false;
        string strPickValue1 = Label.Planned_Capability;
        string strPickValue2 = Label.PM_Controlled;
        List<String> pickValueList = strPickValue1.split(';'); 
        List<String> pickValueList1 = strPickValue2.split(';');
        //Navaneetha Added
        List<Customer_Site__c> csSite = new List<Customer_Site__c>();
        csSite = [Select id,name,New_Solution_Design__c  from Customer_Site__c where New_Solution_Design__c  =: idNsd];
        system.debug('csSite' + csSite);
        system.debug('idNsd' + idNsd);
        if(nsdObj.Partial_Saving__c ==true)
        {
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please uncheck the Partial Saving checkbox and fill all the required fields to submit for approval');
         ApexPages.addMessage(myMsg);
         return null;
        }
        if(csSite.Size() > 0){
        if(nsdObj.Status__c != 'Submitted for Approval'){
        system.debug('Test Navanee1');
            if(nsdObj != null && nsdObj.Id != null){
                try{
                 system.debug('Test Navanee2');
                    List<FR_Commitment__c> list_FCCR = new List<FR_Commitment__c>([SELECT Id FROM FR_Commitment__c 
                                                                                        WHERE New_Solution_Design__c =: nsdObj.Id 
                                                                                        AND Commitment_Progress__c = 'Accepted']);
                    if(nsdObj.PureEngage_Cloud_Capabilities_Phase_1__c != NULL){
                        for(string objPECC : nsdObj.PureEngage_Cloud_Capabilities_Phase_1__c.split(';')){
                            if(pickValueList.contains(objPECC) || pickValueList1.contains(objPECC)){
                                iFlag = true;
                                 system.debug('Test Navanee3');
                            }                    
                        }
                    }
                    
                    if(nsdObj.PureEngage_Cloud_Capabilities_Phase_2__c != NULL){
                        for(string objPECC : nsdObj.PureEngage_Cloud_Capabilities_Phase_2__c.split(';')){
                            if(pickValueList.contains(objPECC) || pickValueList1.contains(objPECC)){
                                iFlag = true;
                                 system.debug('Test Navanee4');
                            }                    
                        }
                    }
                    
                    if(nsdObj.PureEngage_Cloud_Capabilities_Phase_3__c != NULL){
                        for(string objPECC : nsdObj.PureEngage_Cloud_Capabilities_Phase_3__c.split(';')){
                            if(pickValueList.contains(objPECC) || pickValueList1.contains(objPECC)){
                                iFlag = true;
                                 system.debug('Test Navanee5');
                            }                
                        }
                    }
                    
                    if((nsdObj.Offering_Type__c == 'PureEngage Cloud' && (nsdObj.Field_Customer_Commit_Requests__r.size() == 0 
                        || list_FCCR.size() > 0) && !iFlag) 
                        || (nsdObj.Offering_Type__c == 'PureConnect Cloud' && !iFlag)
                        || (nsdObj.Offering_Type__c == 'PureEngage Cloud' && list_FCCR.size()>0 && iFlag)){
                         system.debug('Test Navanee6');
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setComments('Submitting request for approval.');
                        req1.setObjectId(nsdObj.Id);
                        req1.setSubmitterId(UserInfo.getUserId()); 
                        
                        if(nsdObj.Offering_Type__c == 'PureEngage Cloud'){
                            if(nsdObj.SC_Engagement__r.Opportunity_ID__r.Region__c == 'NA'){
                                req1.setProcessDefinitionNameOrId('New_Solution_Design_Approval_NA');
                            }
                            else if(nsdObj.SC_Engagement__r.Opportunity_ID__r.Region__c == 'APAC'){
                                req1.setProcessDefinitionNameOrId('New_Solution_Design_Approval_APAC');
                            }
                            else if(nsdObj.SC_Engagement__r.Opportunity_ID__r.Region__c == 'EMEA'){
                                req1.setProcessDefinitionNameOrId('New_Solution_Design_Approval_EMEA');
                            }
                            else {
                                req1.setProcessDefinitionNameOrId('New_Solution_Design_Approval_GEN');
                            }
                        }
                        else {
                            req1.setProcessDefinitionNameOrId('New_Solution_Design_Approval_PCC');
                        }
                        req1.setSkipEntryCriteria(true);
                        Approval.ProcessResult result = Approval.process(req1);     
                        if(result.isSuccess()){
                            lstApprovalhistory = [SELECT Id, (SELECT Id, CreatedDate, OriginalActor.Name, Actor.Name, StepStatus, Comments FROM StepsAndWorkitems order by ID DESC ) 
                                                        FROM ProcessInstance WHERE TargetObjectId = :nsdObj.Id order by createdDate DESC];
                        }
                    }
                    else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There is no accepted FCCR record. Therefore, record cannot be submitted for approval.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }catch(Exception ex){
                    System.debug('----err0r----'+ex);
                    return null;
                }
            }
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Record is already submitted for approval. Therefore, you cannot re-submit for approval.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        PageReference PageRef = new PageReference('/apex/NewSolutionDesignView?Id='+nsdObj.Id);
        PageRef.setRedirect(true);
        return PageRef;
        
        }
    else{
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter the customer site value for Solution design');
         ApexPages.addMessage(myMsg);
        return null;
    }
    }
    
    
    
    public pagereference backToPage(){
        PageReference myVFPage = new PageReference('/apex/SC_Engagement_Design_Technical?id='+nsdObj.DSR_SCE_Design__c);
        myVFPage.setRedirect(true);
        return myVFPage;
    }
    
    
    public PageReference backToView(){
        PageReference pg = new PageReference('/apex/NewSolutionDesignView?Id='+nsdObj.Id);
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference redirectToClonePage(){
        PageReference pg = new PageReference('/apex/NewSolutionDesignVFClone1?cloneId='+nsdObj.Id+'&dsrId='+nsdObj.SC_Engagement__c);
        pg.setRedirect(true);
        return pg;
    }
    
    public void relaodVoiceSection(){        
        if(nsdObj.Voice_Storage__c != '' && nsdObj.Voice_Storage__c != null){
            isVoiceReq = true;
        }
        else{
            isVoiceReq = false;
        }
    }
        
    
    public void relaodStorageSection(){
        if(nsdObj.Screen_Storage__c != '' && nsdObj.Screen_Storage__c != null){
            isStorageReq  = true;
        }
        else{
            isStorageReq = false;
        }
    }    
    
    
    public void relaodDialerSection(){
        if(nsdObj.Dialer__c){
            isDialerReq = true;
        }
        else{
            isDialerReq = false;
        }
    }
     public void relaodInteractionAnalyticsSection(){
        if(nsdObj.Interaction_Analytics__c){
            isInteractionAnlayticsReq = true;
        }
        else{
            isInteractionAnlayticsReq = false;
        }
    }
    
    public void sendSoWRequest(){
        String baseURLStr = URL.getSalesforceBaseUrl().toExternalForm();

        String emailBody = 'Cloud Approval Process ' + nsdObj.Name + ' ( <a href="' + baseURLStr + '/' + nsdObj.Id + '">' + baseURLStr + '/' + nsdObj.Id + ' </a>)  is in an Approved Status and a SOW has been requested.<br/><br/>';
        emailBody += 'Owner: ' + nsdObj.Owner.Name + ' ( <a href="' + baseURLStr + '/' + nsdObj.OwnerId + ' ">' + baseURLStr + '/' + nsdObj.OwnerId + ' </a>) <br/>';
        emailBody += 'Account: ' + nsdObj.SC_Engagement__r.AccountName__c + ' ( <a href="' + baseURLStr + '/' + nsdObj.SC_Engagement__r.Account_ID__c + ' ">' + baseURLStr + '/' + nsdObj.SC_Engagement__r.Account_ID__c + ' </a>) <br/>';
        emailBody += 'Opportunity: ' + nsdObj.SC_Engagement__r.OpportunityName__c + ' ( <a href="' + baseURLStr + '/' + nsdObj.SC_Engagement__r.Opportunity_ID__c + ' ">' + baseURLStr + '/' + nsdObj.SC_Engagement__r.Opportunity_ID__c + ' </a>) <br/>';
        emailBody += 'Design Offer/Platform: ' + nsdObj.Offering_Type__c + ' <br/>';
        
        String queueName = '';
        if(nsdObj.Outbound_Only__c){
            queueName = '00G56000001qNSB';
        }
        else if(nsdObj.Offering_Type__c == 'PureEngage Cloud' && nsdObj.SC_Engagement__r.Opportunity_ID__r.Region__c == 'NA'){
            queueName = '00G56000001qNSV';
        }
        else if(nsdObj.Offering_Type__c == 'PureEngage Cloud' && nsdObj.SC_Engagement__r.Opportunity_ID__r.Region__c == 'APAC'){
            queueName = '00G56000001qNSk';
        }
        else if(nsdObj.Offering_Type__c == 'PureEngage Cloud' && nsdObj.SC_Engagement__r.Opportunity_ID__r.Region__c == 'EMEA'){
            queueName = '00G56000001qNSf';
        }
        else if(nsdObj.Offering_Type__c == 'PureConnect Cloud'){
            queueName = '00G56000001qNSz';
        }
        
        List<Messaging.SingleEmailMessage> list_EmailMessage = new List<Messaging.SingleEmailMessage>();
        if(queueName != ''){
            for(GroupMember grpMem : [select UserOrGroupId From GroupMember WHERE GroupId =: queueName]){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setSubject('SOW requested for '+ nsdObj.Name);
                message.setHtmlBody(emailBody);
                message.setTargetObjectId(grpMem.UserOrGroupId);
                message.saveAsActivity = false;
                list_EmailMessage.add(message);
            }
            Messaging.SendEmail(list_EmailMessage);
        }
        
    }
}