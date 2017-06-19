({
	myAction : function(component, event, helper) {
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
    getHeader : function(component, event, helper) {
		var action = component.get("c.getHeaderForNonKanbanAccs");
        //Setting the Callback
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();//list of wrapper class
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
	}
})