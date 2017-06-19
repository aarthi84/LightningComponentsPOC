({
  		getPrimaryTeam : function(component) {
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
    getHeaders : function(component) {
		var action = component.get("c.getHeaders");
        //Setting the Callback
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();
                	component.set("v.accHeader", result);
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
        console.log('v.accHeader',component.get("v.accHeader"));
	},
  	getMetrics : function(component) {
        var teamId = component.get("v.selectedTeamId");
		var action = component.get("c.getKanbanAndCustomerMetrics");       
        action.setParams({ 
            "teamId": teamId
        });
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();//list of wrapper class
                	component.set("v.kanbanDatas", result);
            }
             else if (state === "ERROR") {
                alert('Error in calling server side for Kanban Metrics: ' + JSON.stringify(errors));
                console.log(result.getError());
                var errors = result.getError();
                if(errors[0] && errors[0].pageErrors)
                    alert('error', errors[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(action);
        console.log('v.kanbanDatas',component.get("v.kanbanDatas"));
	},
    getMetricsForNewTeam : function(component) {
        var teamName = component.get("v.selectedTeamName");
		var action = component.get("c.getKanbanAndCustomerMetricsForTeamEvent");       
        action.setParams({ 
            "teamName": teamName
        });
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();//list of wrapper class
                	component.set("v.kanbanDatas", result);
            }
             else if (state === "ERROR") {
                alert('Error in calling server side for Kanban Metrics: ' + JSON.stringify(errors));
                console.log(result.getError());
                var errors = result.getError();
                if(errors[0] && errors[0].pageErrors)
                    alert('error', errors[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(action);
        console.log('v.kanbanDatas',component.get("v.kanbanDatas"));
	}
    /*,
    getKanbanHeaders : function(component) {
		var action = component.get("c.getHeaderForKanbanAccs");
        //Setting the Callback
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();
                	component.set("v.accHeader", result);
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
        console.log('v.accHeader',component.get("v.accHeader"));
	},
 	getNonKanbanMetrics : function(component) {
		var action = component.get("c.getNonKanbanMetricsForAccs");
        //Setting the Callback
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();//list of wrapper class
                	component.set("v.nonkanbanDatas", result);
            }
             else if (state === "ERROR") {
                alert('Error in calling server side from non kanban metrics: ' + JSON.stringify(errors));
                console.log(result.getError());
                var errors = result.getError();
                if(errors[0] && errors[0].pageErrors)
                    alert('error', errors[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(action);
        console.log('v.nonkanbanDatas',component.get("v.nonkanbanDatas"));
	},
	getNonKanbanHeaders : function(component) {
		var action = component.get("c.getHeaderForNonKanbanAccs");
        //Setting the Callback
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();//list of wrapper class
                	component.set("v.nonaccHeader", result);
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
        console.log('v.nonaccHeader',component.get("v.nonaccHeader"));
	}*/
})