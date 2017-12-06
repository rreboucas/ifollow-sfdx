({
    getObjectsList : function(component) {
        console.log("IFollowListHelper.getObjectsList: entered");
        
        var action = component.get("c.getObjects");
        
        // Setup the CallBack
        var self = this;
        action.setCallback(this, function(actionResult)
        {
        	//Reset the value of the component list attribute with the records returned
			//debugger;
            var retvals = actionResult.getReturnValue();
            console.log("Returned Values: " + actionResult.getReturnValue()); 
            
        	component.set("v.lstObjects", actionResult.getReturnValue());                   
        });
        
        //Enqueue the action      
        $A.enqueueAction(action);
        
        console.log("IFollowListHelper.getObjectsList: exited");
		
	},
    getListByObject : function(component, callback) {
        console.log("IFollowListHelper.getListByObject: entered");
        var attributeValue = component.get("v.selectedObj");
        var rowsLimitValue = component.get("v.limitRows");
        console.log("attributeValue: " + attributeValue);

            var action = component.get("c.getFollowedRecordsByObjLimitInt");
            

            action.setParams({
                "reqObjName": attributeValue,
                "rowsLimit": rowsLimitValue
            });
            // Setup the CallBack
            var self = this;
            action.setCallback(this, function(actionResult)
            {
                //Reset the value of the component list attribute with the records returned
                //debugger;
                var retvals = actionResult.getReturnValue();
                console.log("Returned Values: " + actionResult.getReturnValue()); 
                
                component.set("v.lstFlwRecords", actionResult.getReturnValue());                   
            });
            
            //Enqueue the action      
            $A.enqueueAction(action);
            
            console.log("IFollowListHelper.getListByObject: exited");
		//}
	}
})