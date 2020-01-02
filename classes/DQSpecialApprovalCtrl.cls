public class DQSpecialApprovalCtrl {
    public String Id {get;set;}
    public String ResponseCode {get;set;}
    public String Field {get;set;}
    public DQSpecialApprovalCtrl () {
        Id = ApexPages.currentPage().getParameters().get('id');     
        ResponseCode = ApexPages.currentPage().getParameters().get('ResponseCode');
        Field = ApexPages.currentPage().getParameters().get('Field');
  
    }
    public PageReference InitPage() {
        List<Deal_Qualification__c> stat = [SELECT Id,Name,Order_Mgmt_Billing_approval__c,Req_Order_Mgmt_Billing_approval__c,Status__c,Req_Legal_approval__c,
                                            Legal_approval__c,Req_Credit_Collections_approval__c,Credit_and_Collections_approval__c,
                                                Req_Revenue_Approval__c,Revenue_approval__c FROM Deal_Qualification__c WHERE Id=:Id LIMIT 1];
        if(Field=='Order'){
            if(!stat.IsEmpty()){
                if((stat[0].Req_Order_Mgmt_Billing_approval__c==true )&&(stat[0].Status__c=='Approval Pending'))
                {
                    if(stat[0].Order_Mgmt_Billing_approval__c != null && stat[0].Order_Mgmt_Billing_approval__c != 'Pending'){
                        string str = stat[0].Order_Mgmt_Billing_approval__c == 'Approved'?'Order Management/Billing team has already approved Special Offers for Deal Qualification '+stat[0].Name:
                                                            'Order Management/Billing team has already rejected Special Offers for Deal Qualification '+stat[0].Name;
                        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,str);
                        ApexPages.addmessage(msg);
                    }
                    else{
                        stat[0].Order_Mgmt_Billing_approval__c= ResponseCode;
                        update stat;
                        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.info,'Thank You for your response. The Deal Qualification ' +stat[0].Name+ ' Special Offers Sub Approval has been ' + ResponseCode);
                        ApexPages.addmessage(msg);
                    }
                }    
                else{
                 ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'The Deal Qualification cannot be approve/reject at this stage');
                 ApexPages.addmessage(msg);
                
                }
            }
        }
        if(Field=='Revenue'){
            if(!stat.IsEmpty()){
                if((stat[0].Req_Revenue_Approval__c==true )&&(stat[0].Status__c=='Approval Pending'))
                {
                    if(stat[0].Revenue_approval__c != null && stat[0].Revenue_approval__c != 'Pending'){
                        string str = stat[0].Revenue_approval__c == 'Approved'?'Revenue team has already approved Special Offers for Deal Qualification '+stat[0].Name:
                                                            'Revenue team has already rejected Special Offers for Deal Qualification '+stat[0].Name;
                        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,str);
                        ApexPages.addmessage(msg);
                    }
                    else{
                        stat[0].Revenue_approval__c= ResponseCode;
                        update stat;
                        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.info,'Thank You for your response. The Deal Qualification ' +stat[0].Name+ ' Special Offers Sub Approval has been ' + ResponseCode);
                        ApexPages.addmessage(msg);
                    }
                }    
                else{
                     ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'The Deal Qualification cannot be approve/reject at this stage');
                     ApexPages.addmessage(msg);
                
                }
            }
        }
        if(Field=='Credit'){
            if(!stat.IsEmpty()){
                if((stat[0].Req_Credit_Collections_approval__c=true )&&(stat[0].Status__c=='Approval Pending'))
                {
                    if(stat[0].Credit_and_Collections_approval__c != null && stat[0].Credit_and_Collections_approval__c != 'Pending'){
                        string str = stat[0].Credit_and_Collections_approval__c == 'Approved'?'Credit and Collections team has already approved Special Offers for Deal Qualification '+stat[0].Name:
                                                            'Credit and Collections team has already rejected Special Offers for Deal Qualification '+stat[0].Name;
                        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,str);
                        ApexPages.addmessage(msg);
                    }
                    else{
                        stat[0].Credit_and_Collections_approval__c= ResponseCode;
                        update stat;
                        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.info,'Thank You for your response. The Deal Qualification ' +stat[0].Name+ ' Special Offers Sub Approval has been ' + ResponseCode);
                        ApexPages.addmessage(msg);
                    }
                }    
                else{
                 ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'The Deal Qualification cannot be approve/reject at this stage');
                 ApexPages.addmessage(msg);
                
                }
            }
        }
        if(Field=='Legal'){
            if(!stat.IsEmpty()){
                if((stat[0].Req_Legal_approval__c=true )&&(stat[0].Status__c=='Approval Pending'))
                {
                    if(stat[0].Legal_approval__c != null && stat[0].Legal_approval__c != 'Pending'){
                        string str = stat[0].Legal_approval__c == 'Approved'?'Legal team has already approved Special Offers for Deal Qualification '+stat[0].Name:
                                                            'Legal team has already rejected Special Offers for Deal Qualification '+stat[0].Name;
                        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,str);
                        ApexPages.addmessage(msg);
                    }
                    else{
                        stat[0].Legal_approval__c= ResponseCode;
                        update stat;
                        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.info,'Thank You for your response. The Deal Qualification ' +stat[0].Name+ ' Special Offers Sub Approval has been ' + ResponseCode);
                        ApexPages.addmessage(msg);
                    }                   
                }    
                else{
                 ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'The Deal Qualification cannot be approve/reject at this stage');
                 ApexPages.addmessage(msg);
                
                }
            }
        }
        return null;
    }
}