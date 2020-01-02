public class DownloadsControllerExtension {
   
    public String siteDest {get;set;}   
    public String swHistId {get;set;}
    public String tokenValue {get;set;}
    public String tokenStatus {get;set;}   
    public String swdLoadId {get;set;}
    public String urlToDl {get; set;}
    public String errMsg {get; set;}
    
    private Customer_SW_Download_History__c cdh;
    private String userIp;
    private String trueClientIP;
    private String xSalesforceSip;
    private String dlSite;
    private String privatePort;
    private String publicPort;
    private String fileName;
    private DownloadsController dc;
    private Software_Download__c sfd;
        
    public DownloadsControllerExtension (DownloadsController dlcon) {
           dc = dlcon;
    }

    public Pagereference gtDload(){  
        
      if(dc.acceptTnc){  
            
          errMsg = '';
          urlToDl = '';
                         
          cdh  = new  Customer_SW_Download_History__c();
          cdh.Contact__c = dc.conId;
          cdh.User__c = UserInfo.getUserId();
          cdh.End_User_Account__c = dc.endUserAccId;
          cdh.Sold_To_Account__c = dc.soldToAccId;
          
          sfd =   [SELECT s.Version__c, s.Operating_Systam__c, s.Name, 
                                           s.Major_Release__c, s.Localization__c,
                                           s.Product__c, s.Product_Component__c, 
                                           s.File_Size_KBs__c, s.File_Name__c, s.Download_Type__c
                                    FROM Software_Download__c s WHERE ID= :swdLoadId];
          fileName = sfd.Name;
          cdh.DL_Site__c = dlSite;
          cdh.File_Name__c = sfd.Name;
          cdh.File_Size__c = sfd.File_Size_KBs__c;
          cdh.Component__c = sfd.Product_Component__c;
          cdh.Product__c = sfd.Product__c;
          cdh.Version__c = sfd.Version__c;
          cdh.OS__c       = sfd.Operating_Systam__c;
          cdh.Download_Type__c = sfd.Download_Type__c;
          cdh.Language__c     = sfd.Localization__c;
          cdh.Major_Release__c = sfd.Major_Release__c;  
       
         /// get download site
          if ( !sdSite() && !Test.isRunningTest() ) {
                  errMsg = 'ERROR: Embargo';
                  return null;
            } 
            /// get user IP
            userIPAddress();
            cdh.User_IP__c = userIp;
                
            /// get security token
             if ( !getSecurityToken() ) {
             	   if ( tokenStatus == '100' )
             	      errMsg = 'ERROR: Not Found';
             	   else
                  	 errMsg = 'ERROR: Service';
                  	 
                   return null;
             }
                
             ///insert swdl history
             if ( !logHistory() ) {
                   errMsg = 'ERROR: Log';
                   return null;
             }
              
              //// download URL  
               urlToDl = siteDest + ':' + publicPort +
                  //  '/FileDownload/GENESYSLAB/servlet/DownloadFile?token=' +
                    '/swdl/download_2.php?token=' + tokenValue + '&swHistId=' +  swHistId;     
        }
        else
              dc.showNTNC();
                
        return null;
    }
        
    private void userIPAddress() {
          
       trueClientIP = ApexPages.currentPage().getHeaders().get('True-Client-IP');       
        // get IP address when no caching (sandbox, dev, secure urls)                       
       xSalesforceSip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
             
        if (trueClientIP == null) 
             userIp = xSalesforceSip;
        else
             userIp = trueClientIP;
    }
    
    @TestVisible
    private Boolean sdSite() {          
        Country__c cntr;
        siteDest = '';

        try {
                cntr = [SELECT c.SW_Download_Site__c FROM Country__c c WHERE Id in 
                        (SELECT Country__c FROM Account WHERE Id= :dc.endUserAccId)];
            
              System.debug('>>> sdSite ' + cntr.SW_Download_Site__c + ' <<<<<');                         
        }
        catch (Exception e) {
                return false;                   
        }                                  
        if ( cntr.SW_Download_Site__c == null )
            return false;
        else {               
                /// custom setting SW Download  
                dlSite = cntr.SW_Download_Site__c;                 
                SW_Download__c site = SW_Download__c.getInstance(dlSite);
                siteDest = site.Value__c; 
                  
                SW_Download__c prPort = SW_Download__c.getInstance('PrivatePort');
                privatePort = prPort.Value__c;
                
                SW_Download__c pblPort = SW_Download__c.getInstance('PublicPort');
                publicPort = pblPort.Value__c;  
        }
                
        if ( siteDest =='' )  
                return false;
        else
             return true;
    }
    
    @TestVisible
    private Boolean logHistory() {             
        insert cdh;  
             
        cdh = [SELECT SWDL_Id__c FROM Customer_SW_Download_History__c WHERE ID= :cdh.Id];
        swHistId = cdh.SWDL_Id__c;
        
        if ( swHistId != null && swHistId != '' )
              return true;
        else
              return false;
    }
    
    @TestVisible
    private Boolean getSecurityToken() {
        
     try {
        // Build and send HTTP request for the one-time token
        String inputBody = '';
        tokenValue = '';
        tokenStatus = '';

        String urlString = siteDest + ':' + privatePort
                + '/FileDownload/GENESYSLAB/servlet/GenerateToken?' + '&requestedFilename=' + sfd.Name + '&trueClientIp=' + trueClientIP
                + '&xSalesforceSip=' + xSalesforceSip;
        
        System.debug('<<<<< urlString >>> ' + urlString );
                
        Http http = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(urlString);
        req.setMethod('GET');
        req.setTimeout(2000);

        HttpResponse res = http.send(req);
        inputBody = res.getBody(); 
        
        Integer firstIndex = 0;
        Integer secondIndex = 0;
        String tagString = null;
        tagString = 'name="token" value="';
        firstIndex = inputBody.indexOf(tagString) + tagString.length();
        secondIndex = inputBody.substring(firstIndex).indexOf('"');
        tokenValue = inputBody.substring(firstIndex, firstIndex + secondIndex);
        tagString = 'name="status" value="';
        firstIndex = inputBody.indexOf(tagString) + tagString.length();
        secondIndex = inputBody.substring(firstIndex).indexOf('"');
        tokenStatus = inputBody.substring(firstIndex, firstIndex + secondIndex);
        
        System.debug('<<<< TOKEN >>' + tokenValue);
        System.debug('<<<< tokenStatus >>' + tokenStatus);
        
        if ( tokenStatus != '0' )
                return false;
        else 
                return true;
     }
     catch (CalloutException ex) {
                return false;
     }  
   }
}