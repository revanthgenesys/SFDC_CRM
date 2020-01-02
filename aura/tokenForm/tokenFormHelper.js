({
	validateForm : function(component) {
		var valid = true;
        
        var orderDateField = component.find("orderDate");
        var orderDate = orderDateField.get("v.value");
        
        if($A.util.isEmpty(orderDate)){
            valid = false;
            orderDateField.set("v.errors", [{message:"Date of Order is required"}]);
        } else {
            orderDateField.set("v.errors", null);
        }
        
        var purchaserNameField = component.find("purchaserName");
        var purchaserName = purchaserNameField.get("v.value");
        
        if($A.util.isEmpty(purchaserName)){
            valid = false;
            purchaserNameField.set("v.errors", [{message:"Full Name is required"}]);
        } else {
            purchaserNameField.set("v.errors", null);
        }
        
        var purchaserCompanyField = component.find("purchaserCompany");
        var purchaserCompany = purchaserCompanyField.get("v.value");
        
        if($A.util.isEmpty(purchaserCompany)){
            valid = false;
            purchaserCompanyField.set("v.errors", [{message:"Company is required"}]);
        } else {
        	purchaserCompanyField.set("v.errors", null);  
        }
        
        
        var purchaserEmailField = component.find("purchaserEmail");
        var purchaserEmail = purchaserEmailField.get("v.value");
        
        if($A.util.isEmpty(purchaserEmail)){
            valid = false;
            purchaserEmailField.set("v.errors", [{message: "Email is required"}]);
        } else {
            purchaserEmailField.set("v.errors", null);
        }
        
        var purchaserPhoneField = component.find("purchaserPhone");
        var purchaserPhone = purchaserPhoneField.get("v.value");
        
        if($A.util.isEmpty(purchaserPhone)){
            valid = false;
            purchaserPhoneField.set("v.errors", [{message: "Phone is required"}])
        } else {
            purchaserPhoneField.set("v.errors", null);
        }
        
        return (valid);
	},
    resetForm : function(component){
        
        var tokenForm = new Object();
        tokenForm.orderDate = new Date().toISOString().slice(0, 10);
  
        tokenForm.purchaserName = '';
        tokenForm.purchaserCompany = '';
        tokenForm.purchaserEmail = '';
        tokenForm.purchaserPhone = '';
        tokenForm.contactName = '';
        tokenForm.contactCompany = '';
        tokenForm.contactEmail = '';
        tokenForm.contactPhone = '';
        tokenForm.projectNumber = '';
        
        tokenForm.ppl001Quantity = null;
        tokenForm.ppl001Notes = '';
    
        tokenForm.loc001Quantity = null;
        tokenForm.loc001Notes = '';     
        
        tokenForm.cfr001Quantity = null;
        tokenForm.cfr001Notes = ''; 
        
        tokenForm.cfr002Quantity = null;
        tokenForm.cfr002Notes = ''; 
        
        tokenForm.cfr003Quantity = null;
        tokenForm.cfr003Notes = ''; 
        
        tokenForm.cfr004Quantity = null;
        tokenForm.cfr004Notes = '';
        
        tokenForm.cfr005Quantity = null;
        tokenForm.cfr005Notes = '';
        
        tokenForm.cfr006Quantity = null;
        tokenForm.cfr006Notes = '';
        
        tokenForm.cfr007Quantity = null;
        tokenForm.cfr007Notes = '';
        
        tokenForm.cfr008Quantity = null;
        tokenForm.cfr008Notes = '';

        tokenForm.cfr009Quantity = null;
        tokenForm.cfr009Notes = '';
        
        tokenForm.dia001Quantity = null; 
        tokenForm.dia001Notes = '';
        
        tokenForm.qua001Quantity = null; 
        tokenForm.qua001Notes = ''; 
        
        tokenForm.scr001Quantity = null; 
        tokenForm.scr001Notes = ''; 
        
        tokenForm.dat001Quantity = null; 
        tokenForm.dat001Notes = '';
        
        tokenForm.dat002Quantity = null; 
        tokenForm.dat002Notes = '';
        
        tokenForm.dat003Quantity = null; 
        tokenForm.dat003Notes = '';
        
        tokenForm.dat004Quantity = null; 
        tokenForm.dat004Notes = '';
        
        tokenForm.dat005Quantity = null; 
        tokenForm.dat005Notes = '';
        
        tokenForm.dat006Quantity = null; 
        tokenForm.dat006Notes = '';
        
        tokenForm.dat007Quantity = null; 
        tokenForm.dat007Notes = '';

        tokenForm.dat008Quantity = null; 
        tokenForm.dat008Notes = '';
        
        tokenForm.sup001Quantity = null; 
        tokenForm.sup001Notes = ''; 
        
        tokenForm.sup002Quantity = null;
        tokenForm.sup002Notes = '';
        
        tokenForm.sup003Quantity = null; 
        tokenForm.sup003Notes = ''; 
        
        tokenForm.sup004Quantity = null; 
        tokenForm.sup004Notes = '';
        
        tokenForm.con001Quantity = null; 
        tokenForm.con001Notes = ''; 
        
        tokenForm.con002Quantity = null; 
        tokenForm.con002Notes = '';		        

        tokenForm.con003Quantity = null; 
        tokenForm.con003Notes = '';		        

        tokenForm.con004Quantity = null; 
        tokenForm.con004Notes = '';		        

        tokenForm.con005Quantity = null; 
        tokenForm.con005Notes = '';
        
        component.set("v.tokenForm", tokenForm);	
    },
    submitForm : function(component, tokenForm){
        var action = component.get("c.submitForm");
        action.setParams({
            "tf": JSON.stringify(tokenForm)
        });
                
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){                
                this.resetForm(component);
                
                $A.createComponent(
                    "ui:message",
                    {
                        "title":"Submitted",
                        "severity": "confirm",
                        "closable": true,
                        "body": "Thank you for submitting your request for service with us!  Your request has been received, and a member from the team should be contacting you shortly to get started.  We look forward to working with you, and thank you for doing business with Genesys!"
                    },
                    function(newMessage, status, errorMessage){
                        if(status === "SUCCESS"){
                            var div1 = component.find("div1");
                            div1.set("v.body", newMessage);
                        }   
                    }
                );
            }            
        });
        
        $A.enqueueAction(action);
    }
})