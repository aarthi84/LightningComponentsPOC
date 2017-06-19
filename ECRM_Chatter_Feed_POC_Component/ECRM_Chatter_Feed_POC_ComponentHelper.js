({
	getChatterFeedsForPrimaryTeam : function(component) {
		var action = component.get("c.getShoutOutFeedsBySOQL");
        action.setParams({ 
            "topicName": "Shoutout"
        });
        //Setting the Callback
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();
                if(result.isSuccess)
                {
                    component.set("v.shoutOutFeeds", result.feedLists);
                    component.set("v.tName", result.teamName);
                }                    
                else if(!result.isSuccess)
                {
                    component.set("v.errorMsg", result.errorMsg);                          
                    component.set("v.noFeedMsg", result.msgStr);
                } 
            }
            else if (state === "ERROR") {
                alert('Error in calling server side from shout out component: ' + JSON.stringify(errors));
                console.log(result.getError());
                var errors = result.getError();
                if(errors[0] && errors[0].pageErrors)
                    component.set("v.errorMsg", errors[0].pageErrors[0].message);
            }
        });
       
       
        $A.enqueueAction(action);
	},
    getChatterFeedsForSelectedTeam : function(component)
    {
        var teamName = component.get("v.tName");
         var action = component.get("c.getShoutOutFeeds4Team");
        action.setParams({ 
            "teamNmae": teamName,
            "topic": "Shoutout"
        });
         action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();
                if(result.isSuccess)
                {
                    component.set("v.shoutOutFeeds", result.feedLists);
                    //component.set("v.tName", result.teamName);
                }                    
                else if(!result.isSuccess)
                {
                    component.set("v.errorMsg", result.errorMsg);                          
                    component.set("v.noFeedMsg", result.msgStr);
                } 
            }
            else if (state === "ERROR") {
                alert('Error in calling server side from shout out component: ' + JSON.stringify(errors));
                console.log(result.getError());
                var errors = result.getError();
                if(errors[0] && errors[0].pageErrors)
                    component.set("v.errorMsg", errors[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(action); 	
    }
})