//Ravi V - Sales Compliance -  10/16/2013
public class compliance_extension {
    List < Error_log__c > errorLogList = new List < Error_log__c > ();
    public String retURL;
    public Integer count = 0;
    public Integer subcount = 0;
    public Integer mailcount = 0;
    public Integer completed = 0;
    public Integer third = 0;
    public String status = 'No';
    public Export_Screening_Checklist__c getescdisplay() {
        return esc[0];
    }
    public date expirationdate {set;get;}
    public List < complianceWrapper > cw {set; get;} //save
    public List < complianceWrapper > cwupdate {set; get;} //update
    list < Export_Screening_Checklist__c > esc = new list < Export_Screening_Checklist__c > ();
    public Export_Screening_Checklist__c newchecklist{get; set;}
    public date getexpirationdate() {
        return esc[0].Checklist_expiration_date__c;
    }
    public Account retaccount {set;get;}
                                
    public compliance_extension(ApexPages.StandardController controller) {
        date myDate = date.today();
        expirationdate = myDate.addYears(1);
        retURL = ApexPages.currentPage().getParameters().get('retURL');        
        String responseid;
        if (ApexPages.currentPage().getParameters().get('tempid') != null) {
            responseid = ApexPages.currentPage().getParameters().get('tempid');
            System.debug('What is : ' + responseid);
            esc = [select id, name, Checklist_expiration_date__c, Status__c, CreatedDate, account__c, OwnerId, Countries__c from Export_Screening_Checklist__c where id =: responseid limit 1];
            retURL = esc[0].account__c;
        } else if (retURL != null) {
            retURL = retURL.remove('/');
            System.debug('retURL***' + retURL);
            retaccount = [select id, name, owner.firstname, owner.lastname, createddate, owner.email from account where id =: retURL];
            esc = [select id, name, Checklist_expiration_date__c, Status__c, CreatedDate, ownerid, Countries__c  from Export_Screening_Checklist__c where account__c =: retURL limit 1];
        }
        if(esc.isEmpty())
            newchecklist = new Export_Screening_Checklist__c();
        else
            newchecklist = esc[0];
        //new
        List < compliance_question__c > resultquestions = new List < compliance_question__c > ();
        cw = new List < complianceWrapper > ();
        resultquestions = [select name, id, Compliance_Question__c, Question_number__c from compliance_question__c order by Question_number__c];
        for (Integer i = 0; i < resultquestions.size(); i++) {
            complianceWrapper temp = new complianceWrapper(resultquestions[i]);
            cw.add(temp);
        }
        //edit
        String mode = ApexPages.currentPage().getParameters().get('mode');
        if (mode == 'edit') {
            List < compliance_response__c > resultresponses = new List < compliance_response__c > ();
            resultresponses = [select id, Account__c, Compliance_Question__c, Compliance_Question_text__c, Question_number__c, multiselect__c, textarea__c, checkbox__c, question_name__c, Compliance_Question__r.Compliance_Question__c from compliance_response__c where Account__c =: retURL order by Question_number__c];
            cwupdate = new List < complianceWrapper > ();
            for (Integer i = 0; i < resultresponses.size(); i++) {
                complianceWrapper temp = new complianceWrapper(resultresponses[i]);
                cwupdate.add(temp);
            }
        }

    }

    public pageReference savequestions() {
        count = 0;
        subcount = 0;
        mailcount = 0;
        completed = 0;
        status = 'No';
        third = 0;
        String st = '/' + retURL;
        PageReference pageRef = new PageReference(st);
        List < Compliance_Response__c > response = new List < Compliance_Response__c > ();
        
        Export_Screening_Checklist__c tempesc1;
        if (retaccount.name != null && retaccount.name.length() > 75)
            retaccount.name = retaccount.name.substring(0, 74);
        newchecklist.name = retaccount.name + '- ESC';
        newchecklist.account__c = retURL;
        SavePoint sp = Database.setSavePoint();
        insert newchecklist;
        try {
            for (integer i = 0; i < cw.size(); i++) {
                Compliance_Response__c temp = new Compliance_Response__c();
                if (cw[i].checkbox == null || cw[i].checkbox == '')
                    count++;
                if (cw[i].checkbox == 'No' && cw[i].Questionnumber == '3.00')
                    third++;
                if (cw[i].multiselect == 'false')
                    subcount++;
                if (cw[i].Questionnumber == '7.00' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '8.00' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '9.00' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '10.00' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.01' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.02' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.03' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.04' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.05' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.06' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.07' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.08' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.09' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.10' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.11' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.12' && cw[i].checkbox == 'Yes') mailcount++;
                if (cw[i].Questionnumber == '11.13' && cw[i].checkbox == 'Yes') mailcount++;
                if ((cw[i].Textarea == null || cw[i].Textarea == '') && cw[i].Questionnumber == '1.00')
                    count++;
                if (cw[i].checkbox == 'Yes' && cw[i].Questionnumber == '5.00')
                    status = 'Yes';
                if ((cw[i].checkbox == 'No') && (cw[i].Questionnumber == '5.00'))
                    completed++;
                temp.Account__c = retURL;
                temp.Compliance_Question__c = cw[i].QuestionID;
                temp.Compliance_Question_text__c = cw[i].ComplianceQuestion;
                temp.checkbox__c = cw[i].checkbox;
                temp.Question_number__c = Double.valueof(cw[i].Questionnumber);
                temp.Textarea__c = cw[i].Textarea;
                temp.multiselect__c = cw[i].multiselect;
                temp.Export_Screening_Checklist__c = newchecklist.id;
                temp.question_name__c = cw[i].questionname;
                response.add(temp);
            }
            System.debug('Count: ' + count + ':subcount:' + subcount);
            if ((count > 12 && count < 35) || (subcount == 9 && third == 0)) {
                Database.rollback(sp);
                newchecklist = new Export_Screening_Checklist__c();
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Note: All questions are mandatory. Please make sure to answer all questions.');
                ApexPages.addMessage(myMsg);
                pageRef = ApexPages.currentPage();
                return pageRef;
            } else if (response.size() > 0 && !response.isEmpty()) {
                Insert response;
                if (mailcount == 0 && status == 'No') {
                    Export_Screening_Checklist__c tempesc = new Export_Screening_Checklist__c(id = newchecklist.id);
                    tempesc.status__c = 'Completed';
                    date myDate = date.today();
                    expirationdate = myDate.addYears(1);
                    tempesc.checklist_expiration_date__c = expirationdate;
                    tempesc.CompletionDate__c = myDate;
                    update tempesc;
                    Account acc = new Account(id = retURL);
                    acc.screening_checklist_completed__c = true;
                    update acc;
                } else if (mailcount > 0 && status == 'No') {
                    Export_Screening_Checklist__c tempesc = new Export_Screening_Checklist__c(id = newchecklist.id);
                    tempesc.status__c = 'Under legal review';
                    update tempesc;
                } else if (status == 'Yes') {
                    Export_Screening_Checklist__c tempesc = new Export_Screening_Checklist__c(id = newchecklist.id);
                    tempesc.status__c = 'Prohibited';
                    update tempesc;
                }
            }
        } catch (Exception e) {
            errorLogList.add(new Error_log__c(Error_Level__c = 'High',
                Code_Type__c = 'Class',
                Snippet_Name__c = 'compliance_extension',
                User_Name__c = UserInfo.getUserName(),
                Object_Name__c = 'Compliance_Response__c',
                Error_Description__c = e.getMessage()
            ));
        } finally {
            if (errorLogList.size() > 0)
                Insert errorLogList;
        }
        return pageRef;
    }

    //editing 

    public string getNeworedit() {
        String returnURL;
        String responseid = ApexPages.currentPage().getParameters().get('id');
        if (esc.isEmpty())
            returnURL = 'apex/compliance_new?retURL=/' + retURL + '&sfdc.override=1&mode=new';
        else
            returnURL = 'apex/compliance_edit?retURL=/' + retURL + '&sfdc.override=1&mode=edit';
        return returnURL;
    }
    public pageReference updatequestions() {
        List < Compliance_Response__c > response = new List < Compliance_Response__c > ();
        mailcount = 0;
        status = 'No';
        count = 0;
        subcount = 0;
        status = 'No';
        String st = '/' + retURL;
        PageReference pageRef = new PageReference(st);
        SavePoint sp = Database.setSavePoint();
        try {
            Export_Screening_Checklist__c updateesc = new Export_Screening_Checklist__c(id = esc[0].id);
            updateesc.Countries__c = newchecklist.Countries__c;
            for (integer i = 0; i < cwupdate.size(); i++) {
                if ((cwupdate[i].checkbox == 'Yes') && (cwupdate[i].Questionnumber == '5')) {
                    updateesc.status__c = 'Prohibited';
                    status = 'Yes';
                }
                if (cwupdate[i].checkbox == 'No' && cwupdate[i].Questionnumber == '3')
                    subcount--;
                if ((cwupdate[i].Textarea == '' || cwupdate[i].Textarea == null) && (cwupdate[i].Questionnumber == '1'))
                    count++;
                if ((cwupdate[i].multiselect == 'false') && (cwupdate[i].Questionnumber == '4.01' || cwupdate[i].Questionnumber == '4.02' || cwupdate[i].Questionnumber == '4.03' || cwupdate[i].Questionnumber == '4.04' || cwupdate[i].Questionnumber == '4.05' || cwupdate[i].Questionnumber == '4.06' || cwupdate[i].Questionnumber == '4.07' || cwupdate[i].Questionnumber == '4.08' || cwupdate[i].Questionnumber == '4.09'))
                    subcount++;
                if ((cwupdate[i].checkbox == 'Yes') && (cwupdate[i].Questionnumber == '5')) {
                    if (cwupdate[i].Questionnumber == '5') {
                        updateesc.status__c = 'Prohibited';
                        status = 'Yes';
                    }
                }
                if (cwupdate[i].Questionnumber == '7' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '8' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '9' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '10' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.01' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.02' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.03' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.04' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.05' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.06' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.07' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.08' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.09' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.1' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.11' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.12' && cwupdate[i].checkbox == 'Yes') mailcount++;
                if (cwupdate[i].Questionnumber == '11.13' && cwupdate[i].checkbox == 'Yes') mailcount++;
                Compliance_Response__c temp = new Compliance_Response__c(id = cwupdate[i].responseid);
                if (cwupdate[i].checkbox == 'Yes')
                    temp.checkbox__c = cwupdate[i].checkbox;
                else
                    temp.checkbox__c = 'No';
                temp.Textarea__c = cwupdate[i].Textarea;
                temp.multiselect__c = cwupdate[i].multiselect;
                response.add(temp);
            }
            if (subcount == 9 || count == 1) {
                Database.rollback(sp);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Note: All questions are mandatory. Please make sure to answer all questions.');
                ApexPages.addMessage(myMsg);
                pageRef = ApexPages.currentPage();
                return pageRef;
            } else if (response.size() > 0) {
                if (status == 'No' && mailcount == 0) {
                    date myDate = date.today();
                    expirationdate = myDate.addYears(1);
                    updateesc.status__c = 'Completed';
                    updateesc.checklist_expiration_date__c = expirationdate;
                    updateesc.CompletionDate__c = myDate;
                    Account acc = new Account(id = retURL);
                    acc.screening_checklist_completed__c = true;
                    update acc;
                } else if (status == 'No' && mailcount > 0)
                    updateesc.status__c = 'Under legal review';
                else if (status == 'Yes')
                    updateesc.status__c = 'Prohibited';
                update response;
            }
            update updateesc;
        } catch (Exception e) {
            errorLogList.add(new Error_log__c(Error_Level__c = 'High',
                Code_Type__c = 'Class',
                Snippet_Name__c = 'compliance_extension',
                User_Name__c = UserInfo.getUserName(),
                Object_Name__c = 'Compliance_Response__c',
                Error_Description__c = e.getMessage()));
        } finally {
            if (errorLogList.size() > 0)
                Insert errorLogList;
        }
        return pageRef;
    }
}