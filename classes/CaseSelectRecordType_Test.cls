@isTest
private class CaseSelectRecordType_Test {

    static testMethod void tst() {
    
        CaseSelectRecordType cntr = new CaseSelectRecordType(null);
        cntr.premSupportType();
        cntr.premFRType(); 
        cntr.cloudSupportType();
        cntr.cloudServiceType();
        cntr.cloudIncidentType();
        cntr.cloudFRType(); 
        cntr.adminType();
        cntr.premMacType();
    }
    
}