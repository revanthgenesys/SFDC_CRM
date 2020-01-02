/*
    Naresh Kumar
    10/15/2013
*/
public without sharing class LogFileConfigurationPageExtension {

    public Log_Management_Tool_Configuration__c record {get;set;}
    public LogFileConfigurationPageExtension(ApexPages.StandardController controller) {
        List<Log_Management_Tool_Configuration__c> records = 
            [SELECT Version__c, Download_File_URL__c, FAQ__c FROM Log_Management_Tool_Configuration__c LIMIT 1];
        if(records.size() == 0)
            record = new Log_Management_Tool_Configuration__c();
        else
            record = records[0]; 
    }
    
    public pageReference save(){
        upsert record;
        ApexPages.Message saveMsg = new ApexPages.Message(ApexPages.severity.INFO,'Information Saved !', 'Informaiton has been saved.');
        ApexPages.addMessage(saveMsg);
        return null;
    }
}