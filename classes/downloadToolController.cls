/*
    Naresh Kumar    08/19/2013
*/

public with sharing class downloadToolController {
    public String pageType {get; set;}
    public String prevVers {get; set;}
    public Boolean termsAccepted {get;set;}
    public Log_Management_Tool_Configuration__c record {get;set;}
    public String wbenchCodeInpt {get; set;}
    public Boolean canDwnload {get; set;}
    private String dlType;
    private Boolean isPrev;
    private String wbenchCodes;
    
    public downloadToolController() {
        pageType = ApexPages.currentPage().getParameters().get('pageType');
        prevVers = ApexPages.currentPage().getParameters().get('prv');
        termsAccepted = false;
        wbenchCodes = null;
        canDwnload = false;
        wbenchCodeInpt = null;
        
        if ( pageType.startsWith('Log') )
             dlType = 'Log';
        else if ( pageType.startsWith('Alarm') )
             dlType = 'Alarm';
        else if  ( pageType.startsWith('Work') )  {
             dlType = 'Workbench';
             wbenchCodes = Label.CustCareWbenchVerificationCodes;
        }
        else if ( pageType.startsWith('MaskUtil') )
             dlType = 'MaskUtil';
        else if ( pageType.startsWith('GdprUtil') )
             dlType = 'GdprUtil';
             
        isPrev = prevVers != null && prevVers == '1' ? true : false; 
        
        List<Log_Management_Tool_Configuration__c> records = [SELECT Version__c, Download_File_URL__c, FAQ__c FROM Log_Management_Tool_Configuration__c 
                                                              WHERE Type__c = :dlType AND PreviousVersion__c = :isPrev LIMIT 1];
            
        if ( !records.isEmpty() )
            record = records[0];
        else
           ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Error on the page.'));
    }
    
    public pageReference download()   {
 
        if ( dlType == 'Workbench' )  {  
                    canDwnload = false;       
                if ( !termsAccepted && String.isBlank(wbenchCodeInpt) )  {              
                         ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 
                             'Your 6-digit Workbench Download Code must be entered and you must accept our Customer Care Tools Terms by selecting the box before you can download.'));
                    return null;
                }                
                else if ( !termsAccepted && (String.isBlank(wbenchCodeInpt ) ||
                          ( String.isNotBlank(wbenchCodeInpt ) && 
                                (wbenchCodeInpt.length() != 6 || !wbenchCodes.contains(wbenchCodeInpt.toUpperCase()))) ) )  {                   
                         ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 
                            'A valid 6-digit Workbench Download Code must be entered and you must accept our Customer Care Tools Terms by selecting the box before you can download.'));
                    return null;
                }
                else if ( !termsAccepted )  {                   
                         ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 
                            'You must accept our Customer Care Tools Terms and Conditions before you can download. Please insure the box is selected.'));
                    return null;
                }
                else if ( termsAccepted && (String.isBlank(wbenchCodeInpt ) ||
                          ( String.isNotBlank(wbenchCodeInpt ) && 
                                (wbenchCodeInpt.length() != 6 || !wbenchCodes.contains(wbenchCodeInpt.toUpperCase()))) ) )  {                              
                    ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 
                             'This is not a valid code. Please re-enter your 6-digit download code.'));
                    return null;
                }
                else
                     canDwnload = true;                                        
        }           
        else if ( !termsAccepted )  {       
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 
                 'You must accept our Customer Care Tools Terms and Conditions before you can download. Please insure the box is selected.'));
            return null;
        }
              
        Download_Log__c newLog = new Download_Log__c();
        newLog.Downloaded_By__c = UserInfo.getUserId();
        newLog.Type__c = dlType;
        newLog.Version__c = record == null ? '' : record.Version__c;
        insert newLog;
        return null;
    }
    
}