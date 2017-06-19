({
	myAction : function(component, event, helper) {
        component.set("v.headerMsg", "Escalations");
        var action = component.get("c.getEscalationsBySOQL");
        //Setting the Callback
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();
                if(result.isSuccess)
                {
                    component.set("v.escalationsFeeds", result.feedLists);
                }                    
                else if(!result.isSuccess)
                {
                    component.set("v.errorMsg", result.errorMsg);                          
                    component.set("v.noFeedMsg", result.msgStr);
                } 
            }
            else if (state === "ERROR") {
                alert('Error in calling server side from escalations: ' + JSON.stringify(errors));
                console.log(result.getError());
                var errors = result.getError();
                if(errors[0] && errors[0].pageErrors)
                    component.set("v.errorMsg", errors[0].pageErrors[0].message);
            }
        });
       
       
        $A.enqueueAction(action);
    }
})