({
	myAction : function(component, event, helper) {
		var action = component.get("c.getKanbanMetricsForAccs");
        //Setting the Callback
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
     getHeader : function(component, event, helper) {
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
	}
})