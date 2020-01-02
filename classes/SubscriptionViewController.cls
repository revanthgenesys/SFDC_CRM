public with sharing class SubscriptionViewController {
    public Subscription_Request_Log__c licenseRequest {get; set;}
    public List<String> hostIds {get; set;}
    public List<String> machineNames {get; set;}
    public List<String> features {get; set;}
    public List<String> licenses {get; set;}
    public Set<String> products {get; set;}
    public String description {get; set;}
    public String bundle {get; set;}
    public String urlPrefix {get; set;}
    
    public SubscriptionViewController() {
        urlPrefix = Site.getPathPrefix() != NULL ? Site.getPathPrefix() : '';
        
        String licenseRequestLogId = ApexPages.currentPage().getParameters().get('id');
        licenseRequest = [SELECT Id, Name,Requested_By__c,Requested_By__r.Name,Generation_Date__c, Expiration_Date__c, System_Type__c,
                        Product_Type__c, Product_Line__c, Mail_Connector__c, License_Type__c, License_Type__r.Name, Machine_Name__c, MAC_Address__c,
                        End_User__c, End_User__r.Name, Sold_To__c, Sold_To__r.Name,License_Text__c,Notes__c,
                        IsActive__c FROM Subscription_Request_Log__c  
                        WHERE id = :licenseRequestLogId];
        system.debug('yyy here: '+licenseRequestLogId+licenseRequest.Product_Line__c);

     try {
            hostIds = licenseRequest.MAC_Address__c.replace('|',',').split(',');
            machineNames = licenseRequest.Machine_Name__c.replace('|',',').split(',');
            
            Dom.Document doc = new Dom.Document();
            doc.load(licenseRequest.License_Text__c);
            features = new List<String>();
            licenses = new List<String>();
            products = new Set<String>();
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
            system.debug(child.getName());
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
                    if(item != NULL){
                        products.add(item.getAttributeValue('id','') + ' ' + item.getAttributeValue('name','') +  ' (' + item.getAttributeValue('quantity','') + ')');
                    }
                }
            }
            
            if(child.getName() == 'Servers'){ 
                for(Dom.XMLNode childEle : child.getChildElements()) {
                   if(childEle.getName().equalsIgnoreCase('server')){  
                      for(Dom.XMLNode items : childEle.getChildElements())  { 
                      if(items.getName().equalsIgnoreCase('items'))
                      for(Dom.XMLNode item : items.getChildElements())
                      if(item != NULL)
                        products.add(item.getAttributeValue('id','') + ' ' + item.getAttributeValue('name','') +  ' (' + item.getAttributeValue('quantity','') + ')');
                      }
                    }
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
}