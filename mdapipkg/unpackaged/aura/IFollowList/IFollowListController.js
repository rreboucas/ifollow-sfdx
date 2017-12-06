({
	
	doInit : function(component, event, helper) {
        
        console.log("IFollowListController.doInit: entered");
        
        var rowsLimitValue = component.get("v.limitRows");
        console.log("rowsLimitValue: " + rowsLimitValue);  
        if (rowsLimitValue > 0 && rowsLimitValue < 13) {
            component.set("v.validRange", true);
            helper.getListByObject(component);
        	helper.getObjectsList(component);
        }
        else {
            component.set("v.validRange", false);
        }

        console.log("IFollowListController.doInit: exit");
        
	},
 
    //This is the event handler to update a record
    onSelectChange : function(component, event, helper) {
        
        console.log("expenseListController.onSelectChange: entered");
        var selected = component.find("lstobjects").get("v.value");
        console.log("selected: " + selected);
        component.set("v.selectedObj", selected);
        
        var attributeValue = component.get("v.selectedObj");
        console.log("attributeValue: " + attributeValue);        

        //Call the helper's update function.
        helper.getListByObject(component);
 
        
        console.log("expenseListController.onSelectChange: exit");
    },
})