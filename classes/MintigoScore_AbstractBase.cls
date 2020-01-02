public abstract class MintigoScore_AbstractBase {
    
    public String nullToEmpty(String value) {
        if (value == null) {
            return '';
        }
        
        return value;
    }
    
    public Object getEnrichedValue(Dom.XmlNode xmlRootNode, String name, Type valueType, Boolean returnDefault) {
        Dom.XmlNode childNode = xmlRootNode.getChildElement(name, null);
        string value = null;
        if (childNode != null) {
            value = childNode.getText();
        }
        
        if (valueType == String.Class) {
            if (returnDefault && value == null) {
                return '';
            }
            return value;
        }
        
        if (valueType == Boolean.Class) {
            if (value == null) {
                if (returnDefault)
                {
                    return false;
                }
                return null;
            }
            return Boolean.valueOf(value);
        }
        
        if (valueType == Integer.Class) {
            if (value == null || String.isBlank(value)) {
                if (returnDefault)
                {
                    return 0;
                }
                return null;
            }
            return Integer.valueOf(value);
        }
        
        if (valueType == Double.Class) {
            if (value == null || String.isBlank(value)) {
                if (returnDefault)
                {
                    return 0.0;
                }
                return null;
            }
            return Double.valueOf(value);
        }
        
        return value;
    }
    
    public Object getEnrichedValue(Dom.XmlNode xmlRootNode, String name, Type valueType) {
        return getEnrichedValue(xmlRootNode, name, valueType, false);
    }
    
    public String makeJSON(Map<String, Object> data) {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        
        for (String key : data.keySet()) {
            Object value = data.get(key);
            
            gen.writeObjectField(key, value == null ? '' : value);
        }
        
        gen.writeEndObject();
        
        return gen.getAsString();
    }
    
    public Dom.XMLNode getEnrichedData(Map<String, Object> data, String server, String marketUUID, Boolean https) {
        String jsonData = makeJSON(data);
        System.debug(jsonData);
        
        String url = 'http' + (https ? 's' : '') + '://' + server + '/api/v1.0/enrich_salesforce/' + marketUUID + '/';
        System.debug('url');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(jsonData);
        req.setTimeout(60000);
        System.Http http = new Http();
        System.HttpResponse response = http.send(req);
        
        System.debug(response.getBody());
        
        Dom.XMLNode root = response.getBodyDocument().getRootElement();
        
        return root;
    }    
    
}