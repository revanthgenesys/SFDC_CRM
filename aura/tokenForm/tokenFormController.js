({
	doInit: function(component, event, helper) {
        helper.resetForm(component);	
    },
	submit : function(component, event, helper) {
        
        if(helper.validateForm(component)){
            var tokenForm = component.get("v.tokenForm");
            helper.submitForm(component, tokenForm);
        }
        
	},
})