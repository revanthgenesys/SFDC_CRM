public class TokenForm {
    @AuraEnabled public String orderDate {get;set;}
    @AuraEnabled public String purchaserName {get;set;}
    @AuraEnabled public String purchaserCompany {get;set;}
    @AuraEnabled public String purchaserEmail {get;set;}
    @AuraEnabled public String purchaserPhone {get;set;}
    @AuraEnabled public String contactName {get;set;}
    @AuraEnabled public String contactCompany {get;set;}
    @AuraEnabled public String contactEmail {get;set;}
    @AuraEnabled public String contactPhone {get;set;}
    @AuraEnabled public String projectNumber {get;set;}
           
    @AuraEnabled public Integer ppl001Quantity {get;set;}
    @AuraEnabled public String ppl001Notes {get;set;}
    private Integer ppl001Price;
    
    @AuraEnabled public Integer loc001Quantity {get;set;}
    @AuraEnabled public String loc001Notes {get;set;}
    private Integer loc001Price;    
    
    @AuraEnabled public Integer cfr001Quantity {get;set;}
    @AuraEnabled public String cfr001Notes {get;set;}
    private Integer cfr001Price;
    
    @AuraEnabled public Integer cfr002Quantity {get;set;}
    @AuraEnabled public String cfr002Notes {get;set;}
    private Integer cfr002Price;
    
    @AuraEnabled public Integer cfr003Quantity {get;set;}
    @AuraEnabled public String cfr003Notes {get;set;}
    private Integer cfr003Price;
    
    @AuraEnabled public Integer cfr004Quantity {get;set;}
    @AuraEnabled public String cfr004Notes {get;set;}
    private Integer cfr004Price;
    
    @AuraEnabled public Integer dia001Quantity {get;set;}
    @AuraEnabled public String dia001Notes {get;set;}
    private Integer dia001Price;
    
    @AuraEnabled public Integer qua001Quantity {get;set;}
    @AuraEnabled public String qua001Notes {get;set;}
    private Integer qua001Price;
    
    @AuraEnabled public Integer scr001Quantity {get;set;}
    @AuraEnabled public String scr001Notes {get;set;}
    private Integer scr001Price;
    
    @AuraEnabled public Integer dat001Quantity {get;set;}
    @AuraEnabled public String dat001Notes {get;set;}
    private Integer dat001Price;
    
    @AuraEnabled public Integer sup001Quantity {get;set;}
    @AuraEnabled public String sup001Notes {get;set;}
    private Integer sup001Price;
    
    @AuraEnabled public Integer sup002Quantity {get;set;}
    @AuraEnabled public String sup002Notes {get;set;}
    private Integer sup002Price;
    
    @AuraEnabled public Integer sup003Quantity {get;set;}
    @AuraEnabled public String sup003Notes {get;set;}
    private Integer sup003Price;
    
    @AuraEnabled public Integer sup004Quantity {get;set;}
    @AuraEnabled public String sup004Notes {get;set;}
    private Integer sup004Price;
    
    @AuraEnabled public Integer con001Quantity {get;set;}
    @AuraEnabled public String con001Notes {get;set;}
    private Integer con001Price;
    
    @AuraEnabled public Integer con002Quantity {get;set;}
    @AuraEnabled public String con002Notes {get;set;}
    private Integer con002Price;
    
    // NikM: 16-Feb-2018: New items added for PureSuccess changes as requested by the business (Sam Brooks)
    @AuraEnabled public Integer cfr005Quantity {get;set;}
    @AuraEnabled public String cfr005Notes {get;set;}
    private Integer cfr005Price;
    
    @AuraEnabled public Integer cfr006Quantity {get;set;}
    @AuraEnabled public String cfr006Notes {get;set;}
    private Integer cfr006Price;
    
    @AuraEnabled public Integer cfr007Quantity {get;set;}
    @AuraEnabled public String cfr007Notes {get;set;}
    private Integer cfr007Price;
    
    @AuraEnabled public Integer cfr008Quantity {get;set;}
    @AuraEnabled public String cfr008Notes {get;set;}
    private Integer cfr008Price;
    
    @AuraEnabled public Integer dat002Quantity {get;set;}
    @AuraEnabled public String dat002Notes {get;set;}
    private Integer dat002Price;
    
    @AuraEnabled public Integer dat003Quantity {get;set;}
    @AuraEnabled public String dat003Notes {get;set;}
    private Integer dat003Price;
    
    @AuraEnabled public Integer dat004Quantity {get;set;}
    @AuraEnabled public String dat004Notes {get;set;}
    private Integer dat004Price;
    
    @AuraEnabled public Integer dat005Quantity {get;set;}
    @AuraEnabled public String dat005Notes {get;set;}
    private Integer dat005Price;
    
    @AuraEnabled public Integer dat006Quantity {get;set;}
    @AuraEnabled public String dat006Notes {get;set;}
    private Integer dat006Price;
    
    @AuraEnabled public Integer dat007Quantity {get;set;}
    @AuraEnabled public String dat007Notes {get;set;}
    private Integer dat007Price;
    
    // NikM: 14-Aug-2018: Modified sup005 to con005 as requested by the business (R.J. Smith)
    @AuraEnabled public Integer con005Quantity {get;set;}
    @AuraEnabled public String con005Notes {get;set;}
    private Integer con005Price;            
    
    // NikM: 14-Aug-2018: New items added for PureSuccess changes as requested by the business (R.J. Smith / Sam Brooks)
    @AuraEnabled public Integer cfr009Quantity {get;set;}
    @AuraEnabled public String cfr009Notes {get;set;}
    private Integer cfr009Price;

    @AuraEnabled public Integer con003Quantity {get;set;}
    @AuraEnabled public String con003Notes {get;set;}
    private Integer con003Price;

    @AuraEnabled public Integer con004Quantity {get;set;}
    @AuraEnabled public String con004Notes {get;set;}
    private Integer con004Price;

    @AuraEnabled public Integer dat008Quantity {get;set;}
    @AuraEnabled public String dat008Notes {get;set;}
    private Integer dat008Price;

    
    public static TokenForm getFromString(String tf){
                    
        TokenForm t = (TokenForm)JSON.deserialize(tf, TokenForm.class);
        t.setDefaultValues();
        
        return t;
    }
    
    public void setDefaultValues(){        
        if(ppl001Quantity == null) ppl001Quantity = 0;        
        if(loc001Quantity == null) loc001Quantity = 0;
        if(cfr001Quantity == null) cfr001Quantity = 0;
        if(cfr002Quantity == null) cfr002Quantity = 0;
        if(cfr003Quantity == null) cfr003Quantity = 0;
        if(cfr004Quantity == null) cfr004Quantity = 0;
        if(cfr005Quantity == null) cfr005Quantity = 0;
        if(cfr006Quantity == null) cfr006Quantity = 0;
        if(cfr007Quantity == null) cfr007Quantity = 0;
        if(cfr008Quantity == null) cfr008Quantity = 0;
        if(cfr009Quantity == null) cfr009Quantity = 0;
        if(dia001Quantity == null) dia001Quantity = 0;
        if(qua001Quantity == null) qua001Quantity = 0;
        if(scr001Quantity == null) scr001Quantity = 0;
        if(dat001Quantity == null) dat001Quantity = 0;       
        if(dat002Quantity == null) dat002Quantity = 0;
        if(dat003Quantity == null) dat003Quantity = 0;
        if(dat004Quantity == null) dat004Quantity = 0;
        if(dat005Quantity == null) dat005Quantity = 0;
        if(dat006Quantity == null) dat006Quantity = 0;
        if(dat007Quantity == null) dat007Quantity = 0;
        if(dat008Quantity == null) dat008Quantity = 0;
        if(sup001Quantity == null) sup001Quantity = 0;
        if(sup002Quantity == null) sup002Quantity = 0; 
        if(sup003Quantity == null) sup003Quantity = 0; 
        if(sup004Quantity == null) sup004Quantity = 0;
        if(con001Quantity == null) con001Quantity = 0; 
        if(con002Quantity == null) con002Quantity = 0;
        if(con003Quantity == null) con003Quantity = 0;
        if(con004Quantity == null) con004Quantity = 0;
        if(con005Quantity == null) con005Quantity = 0; 

        
        ppl001Price = 20;
        loc001Price = 10;
        cfr001Price = 10;
        cfr002Price = 10;
        cfr003Price = 10;
        cfr004Price = 10;
        cfr005Price = 10;
        cfr006Price = 5;
        cfr007Price = 5;
        cfr008Price = 5;
        cfr009Price = 10;
        dia001Price = 40;
        qua001Price = 10;
        scr001Price = 10;
        dat001Price = 20;
        dat002Price = 20;
        dat003Price = 20;
        dat004Price = 20;
        dat005Price = 20;
        dat006Price = 20;
        dat007Price = 20;
        dat008Price = 20;
        sup001Price = 25;
        sup002Price = 25;
        sup003Price = 25;
        sup004Price = 25;
        con001Price = 10;
        con002Price = 10;    
        con003Price = 10;
        con004Price = 10;
        con005Price = 10;
    }
    
    public Boolean isValid(){
        
        if(String.isEmpty(this.orderDate)){
            return false;
        }
        
        if(String.isEmpty(this.purchaserName)){
            return false;
        }
        
        if(String.isEmpty(purchaserCompany)){
            return false;
        }        
        
        if(String.isEmpty(purchaserEmail)){
            return false;
        }
        
        if(String.isEmpty(purchaserPhone)){
            return false;
        }        
        
        return true;
    }
        
    public String getEmailBody(){
        
        String body = '<html><head><style type="text/css">';
        
        body += 'body {font-family: Arial; font-size: 11pt;} '; 
        body += 'table {border-collapse: collapse;} ';
        body += 'table, th, td {border: 1px solid black;} ';
        body += '.center {text-align: center;} ';
        body += '.alnright {text-align: right;} ';
        body += '.noborder {border: none;} ';
        body += 'th, td {padding: 4px;} ';        
        body += '</style></head><body>';
        
        //body += '<p>Thank you for submitting your request for service with us! Your request for the following services has been received, and a member from the team should be contacting you shortly to get started:</p>';
        //body += '<p>Please use the below breakdown of Service Catalog items to add PureCloud Deliverables to the appropriate customer project via PCR.</p>';
        body += '<p>Thank you for your token order request. A confirmation email will be sent to you when your tokens are added to your Professional Services Project. If you have additional questions, please reach out to your Professional Services Project team.</p>';
        
        body += '<p><strong>Date of Order:</strong> ' + orderDate + '</p>';
        body += '<p><strong>Project Number:</strong> ' + projectNumber + '</p>';
        
        body += '<table><tbody>';
        
        body += '<tr><td></td><td><strong>Purchaser</strong></td><td><strong>Contact</strong></td></tr>';
        body += '<tr><td><strong>Name</strong></td><td>' + purchaserName  + '</td><td>' + contactName+ '</td></tr>';
        body += '<tr><td><strong>Company</strong></td><td>' + purchaserCompany  + '</td><td>' + contactCompany + '</td></tr>';
        body += '<tr><td><strong>Email</strong></td><td>' + purchaserEmail  + '</td><td>' + contactEmail + '</td></tr>';
        body += '<tr><td><strong>Phone</strong></td><td>' + purchaserPhone  + '</td><td>' + contactPhone + '</td></tr>';
                
        body += '</tbody></table><br />';       

        body += '<table><thead><tr><th><strong>Service Item</strong></th><th class="center"><strong>Unit Price (Tokens)</strong></th><th><strong>Quantity</strong></th><th><strong>Notes</strong></th><th><strong>Total (Tokens)</strong></th></tr></thead><tbody>';
        
        body += getServiceItemRow('People and Workspaces', ppl001Price, ppl001Quantity, ppl001Notes);
        body += getServiceItemRow('Locations', loc001Price, loc001Quantity, loc001Notes);
        body += getServiceItemRow('Routing - CallFlow Inbound', cfr001Price, cfr001Quantity, cfr001Notes);
        body += getServiceItemRow('Routing - CallFlow Inqueue', cfr002Price, cfr002Quantity, cfr002Notes);
        body += getServiceItemRow('Routing - CallFlow Outbound', cfr003Price, cfr003Quantity, cfr003Notes);
        body += getServiceItemRow('Routing - CallFlow Email', cfr004Price, cfr004Quantity, cfr004Notes);
        body += getServiceItemRow('Routing - CallFlow Secure', cfr005Price, cfr005Quantity, cfr005Notes);
        body += getServiceItemRow('Routing - IVR Schedule', cfr006Price, cfr006Quantity, cfr006Notes);
        body += getServiceItemRow('Routing - Queues', cfr007Price, cfr007Quantity, cfr007Notes);
        body += getServiceItemRow('Routing - Media', cfr008Price, cfr008Quantity, cfr008Notes);
        body += getServiceItemRow('Call Flow - Inbound Message', cfr009Price, cfr009Quantity, cfr009Notes);        
        body += getServiceItemRow('Dialer Campaign',dia001Price, dia001Quantity, dia001Notes);
        body += getServiceItemRow('Quality', qua001Price, qua001Quantity, qua001Notes);
        body += getServiceItemRow('Scripts', scr001Price, scr001Quantity, scr001Notes);
        body += getServiceItemRow('Basic Integration - Cloud Data Action', dat001Price, dat001Quantity, dat001Notes);
        body += getServiceItemRow('Basic Integration - SSO', dat002Price, dat002Quantity, dat002Notes);
        body += getServiceItemRow('Basic Integration - Bridge Service Installation Support', dat003Price, dat003Quantity, dat003Notes);
        body += getServiceItemRow('Basic Integration - Bridge DataSync', dat004Price, dat004Quantity, dat004Notes);
        body += getServiceItemRow('Web Services Data Action - Configurable Data Action', dat005Price, dat005Quantity, dat005Notes);
        body += getServiceItemRow('Web Services Data Action - Configurable Salesforce Data Action', dat006Price, dat006Quantity, dat006Notes);
        body += getServiceItemRow('Web Services Data Action - Bridge Web Services Data Dip', dat007Price, dat007Quantity, dat007Notes);
        body += getServiceItemRow('Basic Integration - Amazon Lex Chatbot', dat008Price, dat008Quantity, dat008Notes);
        body += getServiceItemRow('Implementation Support - Discovery &amp; Design', sup001Price, sup001Quantity, sup001Notes);
        body += getServiceItemRow('Implementation Support - UAT Planning &amp; Support', sup002Price, sup002Quantity, sup002Notes);
        body += getServiceItemRow('Implementation Support - Go-Live Planning &amp; Support', sup003Price, sup003Quantity, sup003Notes);
        body += getServiceItemRow('Implementation Support - Training', sup004Price, sup004Quantity, sup004Notes);
        body += getServiceItemRow('API Consulting', con001Price, con001Quantity, con001Notes);
        body += getServiceItemRow('Data Consulting', con002Price, con002Quantity, con002Notes);
        body += getServiceItemRow('Digital Media Channels API Consulting', con003Price, con003Quantity, con003Notes);
        body += getServiceItemRow('Introductory Workforce Management Consulting', con004Price, con004Quantity, con004Notes);
        body += getServiceItemRow('Network and SIP Consulting', con005Price, con005Quantity, con005Notes);
        
        body += '<tr><td class="noborder"></td><td class="noborder"></td><td class="noborder"></td><td class="noborder alnright" align="right">Grand Total:</td><td class="center">' + getTotal() + '</td></tr>';   
        body += '</tbody></table>';
        
        
        //body += '<p>As a representative of ' + purchaserCompany + ', you acknowledge that you are authorized to request delivery of the above services. If anything changes concerning this service request or if you have any issues or concerns, please contact your Service Account Manager or Project Manager. Please respond within 48 hours of receiving this notification if you did not request these services. Lack of notification to your Service Account Manager or Project Manager will serve as confirmation of the service request, and will result in consumption of the total token amount presented.</p>';
        //body += '<p>We look forward to working with you, and thank you for doing business with Genesys!</p>';
           
        body += '</body></html>';
        
        return body;        
    }
    
    public String getEmailSubject(){
      return 'PSS Service Order - [' + purchaserCompany  + '] - [' + orderDate +']';
    }
    
    private static String getServiceItemRow(String name, Integer price, Integer quantity, String notes){

        if(quantity < 1){
            return '';
        }
        
        Integer subtotal = getSubtotal(quantity, price);
                
        String quantityString = (quantity > 0) ? String.valueOf(quantity) : '';
        String notesString = (notes != null) ? notes : '';
        String subtotalString = (subtotal > 0) ? String.valueOf(subtotal) : '';
        
        
        String row = String.format(
            '<tr><td>{0}</td><td class="center">{1}</td><td class="center">{2}</td><td>{3}</td><td class="center">{4}</td></tr>', 
            new String[] {
                name, 
                String.valueOf(price), 
                quantityString, 
                notesString, 
                subtotalString
             });
        
        return row;
    }
    
    private Integer getTotal(){
        
        Integer total = 0;
        
        total += getSubtotal(ppl001Quantity, ppl001Price);      
        total += getSubtotal(loc001Quantity, loc001Price);
        total += getSubtotal(cfr001Quantity, cfr001Price);
        total += getSubtotal(cfr002Quantity, cfr002Price);
        total += getSubtotal(cfr003Quantity, cfr003Price);
        total += getSubtotal(cfr004Quantity, cfr004Price);
        total += getSubtotal(cfr005Quantity, cfr005Price);
        total += getSubtotal(cfr006Quantity, cfr006Price);
        total += getSubtotal(cfr007Quantity, cfr007Price);
        total += getSubtotal(cfr008Quantity, cfr008Price);
        total += getSubtotal(cfr009Quantity, cfr009Price);        
        total += getSubtotal(dia001Quantity, dia001Price);
        total += getSubtotal(qua001Quantity, qua001Price);
        total += getSubtotal(scr001Quantity, scr001Price);
        total += getSubtotal(dat001Quantity, dat001Price);
        total += getSubtotal(dat002Quantity, dat002Price);
        total += getSubtotal(dat003Quantity, dat003Price);
        total += getSubtotal(dat004Quantity, dat004Price);
        total += getSubtotal(dat005Quantity, dat005Price);
        total += getSubtotal(dat006Quantity, dat006Price);
        total += getSubtotal(dat007Quantity, dat007Price);
        total += getSubtotal(dat008Quantity, dat008Price);
        total += getSubtotal(sup001Quantity, sup001Price);
        total += getSubtotal(sup002Quantity, sup002Price);
        total += getSubtotal(sup003Quantity, sup003Price);
        total += getSubtotal(sup004Quantity, sup004Price);
        total += getSubtotal(con001Quantity, con001Price);
        total += getSubtotal(con002Quantity, con002Price);
        total += getSubtotal(con003Quantity, con003Price);
        total += getSubtotal(con004Quantity, con004Price);
        total += getSubtotal(con005Quantity, con005Price);
        
        return total;        
    }
    
    private static Integer getSubtotal(Integer quantity, Integer price){
      // NOTE: getting mysterious 'Internal Server Error' when multiplying integers.
       // Convert to double then back to integer to work around error.
        Integer subtotal = (Double.valueOf(quantity) * Double.valueOf(price)).intValue();
        
        return subtotal;
    }        
}