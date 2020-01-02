public class SizeCalReader
 {
public String org{get;set;}
public String url{get;set;}
public String XMLData{get;set;}

public SizeCalReader(){
   url = getSizeCalcInfo();


}

public PageReference redirect(){
        if(url != null){
            PageReference pageRef = new PageReference(url);
            return pageRef;
        }
        else{
            return null;
        }
}

 

public String getSizeCalcInfo(){ 

 User usr = [SELECT Id,Name,Email,Phone,MobilePhone,FullPhotoUrl,Title,
                    Contact.Account.OwnerId,Contact.Account.Owner.ManagerId, 
                    Block_Partner_Welcome_Video__c, ContactId 
                    FROM User WHERE Id =: UserInfo.getUserId()];

 String email = usr.Email; 
 
 Http http = new Http();
 HttpRequest req = new HttpRequest();
 req.setEndpoint(Label.Size_Cal_URL+email+'/SFDC');
 req.setMethod('GET');
 HttpResponse res = http.send(req);
 

// Log the XML content

 String xmlContent=res.getBody();
 System.debug(res.getBody());
 System.debug('#####XmlStreamReader ##11##');

// Generate the HTTP response as an XML stream
 
   XmlStreamReader reader = res.getXmlStreamReader();
   System.debug('##########XML DATA##########'+res.getXmlStreamReader());

   XMLData=XMLParser(res.getBody());
   return XMLData;
}

 

public String XMLParser(String strXml){

System.debug('####Inside XMLParser Method########'+strXml);
String orgInfo='';

if(strXml!=null) {

  Dom.Document doc = new Dom.Document();
  doc.load(strXml);

//Retrieve the root element for this document.

  Dom.XMLNode Envelope = doc.getRootElement();
  orgInfo = Envelope.getText();
 }

return orgInfo;

}

}