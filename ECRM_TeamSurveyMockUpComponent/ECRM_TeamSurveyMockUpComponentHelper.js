({
    getPrimaryTeam : function(component) {
        component.set("v.headerMsg", "Team Survey");
		var action = component.get("c.getLoggedInUsersPrimaryCDTGroup");
        //Setting the Callback
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();
                	component.set("v.selectedTeamId", result);
            }
             else if (state === "ERROR") {
                alert('Error in calling server side: ' + JSON.stringify(errors));
                console.log(result.getError());
                var errors = result.getError();
                if(errors[0] && errors[0].pageErrors)
                    alert('error', errors[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(action);
   	},

	getReports : function(component) {
		var teamId = component.get("v.selectedTeamId");
        var action = component.get("c.getTeamReports");
        action.setParams({ 
            "teamId": teamId
        });
         action.setCallback(this, function(response) {
            var state = response.getState();
             var result = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") {
                  component.set("v.myVal", result);                  
                }
        });
        $A.enqueueAction(action);	
	},
    getReportsForNewTeam : function(component) {
       var teamName = component.get("v.selectedTeamName");
        console.log('team name from Tebleau reports' + teamName);
        var action = component.get("c.getTeamReportsForTeamEvent");
        action.setParams({ 
            "teamName": teamName
        });
         action.setCallback(this, function(response) {
            var state = response.getState();
             var result = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") {
                  component.set("v.myVal", result);                  
                }
        });
        $A.enqueueAction(action);
    }
})