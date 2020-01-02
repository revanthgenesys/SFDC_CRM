public class ExecInitiativeController {
    public String StatusColor;
    private String UpdatesData;
    private String DeadlinesData;
    private String DeadlineSuffix;
    
    public ExecInitiativeController() {
    
    }
    
    public String getExecGroupNameAndOwner() {
        String ExecGroupId = ApexPages.currentPage().getParameters().get('id');
        String NameAndOwner='';
        List<ExecInitiativeGroup__c> listExecGroups=[SELECT Name, Group_Manager__r.Name FROM ExecInitiativeGroup__c WHERE Id = :ExecGroupId];
        if (listExecGroups != null) {
            NameAndOwner = listExecGroups[0].Name + '-' + listExecGroups[0].Group_Manager__r.Name;
        }
        return NameAndOwner;
    }
    
    public String getExecGroupAdditionalInfo() {
        String ExecGroupId = ApexPages.currentPage().getParameters().get('id');
        String AdditionalInfo='';
        List<ExecInitiativeGroup__c> listExecGroups=[SELECT Exec_Group_Additional_Information__c FROM ExecInitiativeGroup__c WHERE Id = :ExecGroupId];
        if (listExecGroups != null) {
            AdditionalInfo = listExecGroups[0].Exec_Group_Additional_Information__c;
        }
        return AdditionalInfo;
    }
        
    public List<Initiative__c> getInitiatives() {
        String ExecGroupId = ApexPages.currentPage().getParameters().get('id');
        String CurrYear = String.valueOf(system.today().year());
        List<Initiative__c> listInitiative=[SELECT Id, Name, Initiative_Name__c, Initiative_Owner__r.Name, Status__c, Overall_Status_Summary__c, ObjectivesSummary__c, DeadlinesSummary__c FROM Initiative__c WHERE Executive_Group__r.Id =:ExecGroupId AND Applicable_Year__c = :CurrYear ORDER BY Initiative_Rank__c];
        for (Initiative__c i : listInitiative) {
            if(i.Status__c=='On-Track')
                i.Status__c='green'; 
            if(i.Status__c=='Attention Required')
                i.Status__c='orange'; 
            if(i.Status__c=='Major Deviation')
                i.Status__c='red';
            if(i.Status__c=='Complete')
                i.Status__c='blue';
         
            // get the latest updates from the Objectives
            //UpdatesData = '<b>Accomplishments this past month</b>';
            UpdatesData = '';

            date d = system.today().addDays(-30);
            List<Initiative_Objective__c> listObjectives=[SELECT Id, Name, Objective_Name__c FROM Initiative_Objective__c WHERE Initiative__r.Id = :i.Id];
            for (Initiative_Objective__c eIO : listObjectives) {
                UpdatesData += '<li>' + eIO.Objective_Name__c + '</li>';
                UpdatesData += '<ul>';
                List<Task> tasks=[select subject, description from Task where (status='Completed' or status='Done') and lastModifiedDate >= :d and WhatId = :eIO.Id];
                for (Task t : tasks) {
                    if (t.description != null) {
                        UpdatesData += '<li type="Square">' + t.subject + ':(' + t.description + ')</li>';
                    } else {
                        UpdatesData += '<li type="Square">' + t.subject + '</li>';
                    }
                }   
                UpdatesData += '</ul>';
            }             
        
            // get the overall status if available
            if(i.Overall_Status_Summary__c != null) {
                // Substitute the new line characters for html breaks for output in the VF dashboards
                String OSS = i.Overall_Status_Summary__c;
                OSS = OSS.replaceAll('\n', '<br/>');
                UpdatesData += '<br><br><b>Overall Status</b><br>' + OSS;
                }
                
                
            // get the deadline information from the Deadlines related object
            //DeadlinesData = '<b>Initiative Deadlines</b>';
            DeadlinesData = '';
            List<Initiative_Deadline__c> listDeadlines=[SELECT Id, Name, Deadline_Name__c, Due_Date__c, Deadline_completed__c, Is_Overdue__c FROM Initiative_Deadline__c WHERE Initiative__r.Id = :i.Id ORDER BY Due_Date__c];
            for (Initiative_Deadline__c eID : listDeadlines) {
                DeadlineSuffix = '';
                if (eID.Deadline_completed__c == true)
                {
                    DeadlineSuffix = '<span style="color:green"> <b> (completed)</b></span>';
                }
                else
                {
                    if (eID.Is_Overdue__c == true)
                    {
                        DeadlineSuffix = '<span style="color:red"> <b>(overdue)</b></span>';
                    }
                }
                
                DeadlinesData += '<li>' + eID.Due_Date__c.format() + '&nbsp-' + eID.Deadline_Name__c + DeadlineSuffix +'</li>';
            }             
            
            i.ObjectivesSummary__c = UpdatesData;
            i.DeadlinesSummary__c = DeadlinesData;
        }
        return listInitiative;
    }    

}