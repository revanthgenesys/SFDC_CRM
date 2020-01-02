public class LMSLicenseViewController {
    public License_Request_Log__c licenseRequest {get; set;}
    public List<String> hostIds {get; set;}
    public List<String> machineNames {get; set;}
    public List<String> features {get; set;}
    public List<String> licenses {get; set;}
    public List<String> products {get; set;}
    public String description {get; set;}
    public String bundle {get; set;}
    
    public boolean sipLicense {get; set;}
    public String sipType {get;set;}
    public String urlPrefix {get; set;}

    public LMSLicenseViewController(){
        urlPrefix = Site.getPathPrefix() != NULL ? Site.getPathPrefix() : '';
        sipLicense = false;
        String licenseRequestLogId = ApexPages.currentPage().getParameters().get('id');
        licenseRequest = [SELECT Id, Name, Requested_By__c, Requested_By__r.Name, Generation_Date__c, Expiration_Date__c, SystemType1__c, 
                                        Product_Type__c, MailConnector1__c, License_Type__c, License_Text__c, Active__c,
                                        Machine_Name__c, MAC_Address__c, End_User__c, End_User__r.Name, Sold_To__c, Deactivated_By__c, Deactivated_Date__c,
                                        Install_Site__r.Name, Product_Line__c, Product_Line__r.SIP_Product__c,Product_Line__r.SIPType__c 
                                    FROM License_Request_Log__c  
                                    WHERE id = :licenseRequestLogId];
        try{
            if(licenseRequest.Product_Line__r.SIP_Product__c){
                sipLicense = true;
                if(licenseRequest.Product_Line__r.SIPType__c!=NULL)
                    sipType = licenseRequest.Product_Line__r.SIPType__c;   
            }
            
            hostIds = licenseRequest.MAC_Address__c.replace('|',',').split(',');
            machineNames = licenseRequest.Machine_Name__c.replace('|',',').split(',');
            
            Dom.Document doc = new Dom.Document();
            doc.load(licenseRequest.License_Text__c);
            features = new List<String>();
            licenses = new List<String>();
            products = new List<String>();
            //Retrieve the root element for this document.
            Dom.XMLNode rootNode = doc.getRootElement();
            
            // Case 1: Root Element = LicenseFile
            if(rootNode.getName() == 'LicenseFile'){
                parseNode(rootNode);
                for(Dom.XMLNode child : rootNode.getChildElements()) {
                    if(child.getName() == 'Servers'){
                        parseNode(child);
                        for(Dom.XMLNode innerChild : child.getChildElements()) {
                            if(innerChild.getName() == 'Server'){
                                parseNode(innerChild);
                            }
                        }
                    }
                }               
            }
            
            // Case 2: Root Element = LicenseFiles; First Child = LicenseFile ; Inner Child = Server 
            if(rootNode.getName() == 'LicenseFiles'){
                Dom.XMLNode LicenseFileNode = rootNode.getChildElement('LicenseFile', null);
                bundle = LicenseFileNode.getAttributeValue('bundle', '');
                parseNode(LicenseFileNode);
            }
                     
        }   
        catch(XmlException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'XML Parsing error: '+e.getMessage())); 
        }          
    }
    
    public void parseNode(Dom.XMLNode xmlNode){
        for(Dom.XMLNode child : xmlNode.getChildElements()) {
            if(child.getName() == 'Features'){
                for(Dom.XMLNode featureNode : child.getChildElements()) {
                    String feature = featureNode.getAttributeValue('name','') != NULL ? featureNode.getAttributeValue('name','') : featureNode.getAttributeValue('Name','');
                    if(feature != NULL)
                        features.add(feature);  
                }
            }
            if(child.getName() == 'Licenses'){
                for(Dom.XMLNode licenseNode : child.getChildElements()) {
                    // licenses.add(licenseNode.getAttributeValue('name',''));  
                    licenses.add(buildLicenseString(licenseNode)); 
                }
            }
            if(child.getName() == 'Feature'){
                // features.add(child.getAttributeValue('name',''));
                String feature = child.getAttributeValue('name','') != NULL ? child.getAttributeValue('name','') : child.getAttributeValue('Name','');
                if(feature != NULL)
                    features.add(feature);  
            }
            if(child.getName() == 'License'){
                // licenses.add(child.getAttributeValue('name','') + ' (' + child.getAttributeValue('value','') + ')'); 
                licenses.add(buildLicenseString(child)); 
            }
            
            if(child.getName() == 'ITEMS'){
                for(Dom.XMLNode item : child.getChildElements()) {
                    if(item != NULL)
                        products.add(item.getAttributeValue('id','') + ' ' + item.getAttributeValue('name','') +  ' (' + item.getAttributeValue('quantity','') + ')');
                }
            } 
            if(child.getName() == 'DESC'){
                description = child.getText();
            }                                      
        }
    }
    
    public String buildLicenseString(Dom.XMLNode xmlNode){
        String licenseLabel = xmlNode.getAttributeValue('name','');
        String assigned = xmlNode.getAttributeValue('assigned','');
        String pooled = xmlNode.getAttributeValue('pooled','');
        String value = xmlNode.getAttributeValue('value','');
        String additionLabel = '';
        if(String.isNotBlank(assigned) && String.isNotBlank(pooled)){
            additionLabel = ' (' + assigned + ' assigned, ' +  pooled + ' pooled' + ')';
        } else if(String.isNotBlank(assigned)){
            additionLabel = ' (' + assigned + ' assigned'  + ')';
        } else if(String.isNotBlank(pooled)){
            additionLabel = ' (' + pooled + ' pooled'  + ')';
        } else if(String.isNotBlank(value)){
            additionLabel = ' (' + value + ')';
        }
        return licenseLabel + additionLabel;    
    } 
    
    /*
            
            
            
            if(sipLicense){
                Dom.XMLNode ServersNode = rootNode.getChildElement('Servers', null);
                if(ServersNode != NULL){
                    Dom.XMLNode ServerNode = ServersNode.getChildElement('Server', null); 
                    
                    for(Dom.XMLNode child : ServerNode.getChildElements()) {
                        if(child.getName() == 'Feature'){
                            features.add(child.getAttributeValue('name',''));   
                        }
                        if(child.getName() == 'License'){
                            licenses.add(child.getAttributeValue('name','') + ' (' + child.getAttributeValue('value','') + ')');    
                        }
                        if(child.getName() == 'DESC'){
                            description = child.getText();
                        }
                        if(child.getName() == 'ITEMS'){
                            for(Dom.XMLNode innerChild : child.getChildElements()) {
                                if(innerChild != NULL)
                                    products.add(innerChild.getAttributeValue('id','') + ' ' + innerChild.getAttributeValue('name','') +  ' (' + innerChild.getAttributeValue('quantity','') + ')');
                            }
                        }       
                    }
                }
            }
            if( sipLicense == false || (sipLicense == true && rootNode.getChildElement('Servers', null) == NULL)){
                Dom.XMLNode licensefileNode = rootNode.getChildElement('LicenseFile', null);
                
                if(licensefileNode != NULL){
                        bundle = licensefileNode.getAttributeValue('bundle', '');
                        Dom.XMLNode featuresNode  = licensefileNode.getChildElement('Features', null);
                        if(featuresNode != NULL){
                            for(Dom.XMLNode child : featuresNode.getChildElements()) {
                                if(child != NULL)
                                    features.add(child.getAttributeValue('name',''));
                            }              
                        }
                        Dom.XMLNode licensesNode = licensefileNode.getChildElement('Licenses', null);
                        if(licensesNode != NULL){
                            for(Dom.XMLNode child : licensesNode.getChildElements()) {
                                if(child != NULL){
                                    String licenseLabel = child.getAttributeValue('name','');
                                    String assigned = child.getAttributeValue('assigned','');
                                    String pooled = child.getAttributeValue('pooled','');
                                    String value = child.getAttributeValue('value','');
                                    String additionLabel = '';
                                    if(String.isNotBlank(assigned) && String.isNotBlank(pooled)){
                                        additionLabel = ' (' + assigned + ' assigned, ' +  pooled + ' pooled' + ')';
                                    } else if(String.isNotBlank(assigned)){
                                        additionLabel = ' (' + assigned + ' assigned'  + ')';
                                    } else if(String.isNotBlank(pooled)){
                                        additionLabel = ' (' + pooled + ' pooled'  + ')';
                                    } else if(String.isNotBlank(value)){
                                        additionLabel = ' (' + value + ')';
                                    }
                                    licenses.add(licenseLabel + additionLabel);                         
                                }
                            }
                        }
                        Dom.XMLNode DESCNode = licensefileNode.getChildElement('DESC', null);
                        if(DESCNode != NULL){
                            description = DESCNode.getText();
                            description = description.replace('Re-registration is to ensure that license keys are not being duplicated on multiple machines.', '');
                        }
                }
                
                Dom.XMLNode ServersNode = rootNode.getChildElement('Servers', null);
                if(ServersNode != NULL){
                    Dom.XMLNode ServerNode = ServersNode.getChildElement('Server', null);  
                    Dom.XMLNode featuresNode  = ServerNode.getChildElement('Features', null);
                    if(featuresNode != NULL){
                        for(Dom.XMLNode child : featuresNode.getChildElements()) {
                            if(child != NULL)
                                features.add(child.getAttributeValue('name',''));
                        }              
                    }
                    Dom.XMLNode licensesNode = ServerNode.getChildElement('Licenses', null);
                    if(licensesNode != NULL){
                        for(Dom.XMLNode child : licensesNode.getChildElements()) {
                            if(child != NULL){
                                String licenseLabel = child.getAttributeValue('name','');
                                String assigned = child.getAttributeValue('assigned','');
                                String pooled = child.getAttributeValue('pooled','');
                                String value = child.getAttributeValue('value','');
                                String additionLabel = '';
                                if(String.isNotBlank(assigned) && String.isNotBlank(pooled)){
                                    additionLabel = ' (' + assigned + ' assigned, ' +  pooled + ' pooled' + ')';
                                } else if(String.isNotBlank(assigned)){
                                    additionLabel = ' (' + assigned + ' assigned'  + ')';
                                } else if(String.isNotBlank(pooled)){
                                    additionLabel = ' (' + pooled + ' pooled'  + ')';
                                } else if(String.isNotBlank(value)){
                                    additionLabel = ' (' + value + ')';
                                }
                                
                                licenses.add(licenseLabel + additionLabel);
                            }
                        }
                    }
                    Dom.XMLNode DESCNode = ServersNode.getChildElement('DESC', null);
                    if(DESCNode != NULL){
                        description = DESCNode.getText();
                        description = description.replace('Re-registration is to ensure that license keys are not being duplicated on multiple machines.', '');
                    }
                }
                for(License_Usage__c lu : [SELECT id, Product__c, Product__r.APN_Number__c, Product__r.Description,  Quantity_Used__c 
                                               FROM License_Usage__c WHERE License_Request_Log__c = :licenseRequestLogId])
                {
                    if(lu.Product__c != NULL)
                        products.add(lu.Product__r.APN_Number__c + '  ' + lu.Product__r.Description + ' ( ' + lu.Quantity_Used__c.intValue() + ' )');                                  
                } 
            } 
            */ 
}