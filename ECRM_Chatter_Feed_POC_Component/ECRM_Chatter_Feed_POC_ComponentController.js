({
	myAction : function(component, event, helper) {
        component.set("v.headerMsg", "Shout Outs");
        var tName = component.get("v.tName");
        var primaryTeam = component.get("v.primaryTeamName");
        if($A.util.isEmpty(primaryTeam))
        {
            helper.getChatterFeedsForPrimaryTeam(component);
            //execute getChatterFeedsForPrimaryTeam() again after 5 sec each
        	/*window.setInterval(
            	$A.getCallback(function() { 
                	helper.getChatterFeedsForPrimaryTeam(component);
            	}), 5000
        	);*/
        }
        if(!$A.util.isEmpty(tName))
        {
            helper.getChatterFeedsForSelectedTeam(component);
           window.setInterval(
            	$A.getCallback(function() { 
                	helper.getChatterFeedsForSelectedTeam(component);
            	}), 5000
        	);
        }
        
    },
     handleApplicationEvent : function(component, event) {
        //component.set("v.tName", "");        
         component.set("v.shoutOutFeeds","" );
         component.set("v.noFeedMsg","");
         component.set("v.errorMsg","");
        var teamName = event.getParam("teamName");
         console.log('teamName='+teamName);
            component.set("v.tName", teamName);
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
             console.log('result'+component.get("v.shoutOutFeeds"));
        });
        $A.enqueueAction(action); 	
    }
        
})