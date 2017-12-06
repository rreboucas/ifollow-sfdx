({
    doInit : function(cmp, event) {
        
        console.log("IFollowRecordCardController.doInit: entered");
        
        var crecord = cmp.get("v.followedrecord");
        console.log("crecord.s1Url: " + crecord.s1Url); 
        cmp.set("v.class", crecord.s1Url + ' roreblciflw3IFollowRecordCard');

        console.log("IFollowRecordCardController.doInit: exit");
        
	},
    
	linkToRecord : function(component, event, helper) {
        
        console.log("IFollowRecordCardController.handleClick: entered");
        //debugger;
        var crecord = component.get("v.followedrecord");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": crecord.recordID,
          "slideDevName": "related"
        });
        navEvt.fire();
        
        console.log("IFollowRecordCardController.handleClick: exit");
        

	},
})