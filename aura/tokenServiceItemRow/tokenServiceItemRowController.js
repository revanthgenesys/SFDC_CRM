({
	handleQuantityChange : function(component, event, helper) {
		
        var quantity = component.get("v.quantity");
        
        var total = component.get("v.total");
		var oldSubtotal = component.get("v.subtotal");        
        
        if(quantity == null || quantity == 0){
            
            if(oldSubtotal != null && oldSubtotal > 0){
                component.set("v.total", total - oldSubtotal);
            }
            
            component.set("v.subtotal", null);
        } else {
            
            var price = component.get("v.price");
            var subtotal = price * quantity;
            
            if(oldSubtotal != null && oldSubtotal > 0){
            	component.set("v.total", total - oldSubtotal);
                total = component.get("v.total");
        	}
            
            component.set("v.total", total + subtotal);
            component.set("v.subtotal", subtotal);
        }
	}
})