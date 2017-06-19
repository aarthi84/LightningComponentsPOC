/* May 2015: This My Tasks lightning component is created for Salesforce Lab competition by Kashi Ahmed http://www.kashifahmed.com */
/* July 2016: Updated after Summer 16 rel to fix bugs -  Kashi Ahmed http://www.kashifahmed.com */
 ({
    doInit : function(component) {
        var action = component.get("c.MyTask");   

        // get the value for Label field, if empty then default it to 'My Tasks'
        var isEmptyHeading = $A.util.isEmpty(component.get("v.heading"));
        if (isEmptyHeading) {
            component.set("v.heading","My Tasks");
         }

        action.setCallback(this, function(a) {
            console.log(a.getReturnValue());
            component.set("v.tasks", a.getReturnValue());
         });
        $A.enqueueAction(action);
    },
    
    newTask : function(component, event, helper) {
      var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName":  "Task"
        });
    	createRecordEvent.fire();
    },
    changeFilter:function(component,event){
        var action = component.get("c.TaskByFilter");
        var selectCmp = component.find("selection");
        var selectVal = selectCmp.get("v.value");
        console.log('Selected Value '+selectVal);
        action.setParams({
          "fltr": selectVal
          
        });
        action.setCallback(this, function(a) {
            console.log(a.getReturnValue());
            component.set("v.tasks", a.getReturnValue());
        });
        $A.enqueueAction(action);
        
    }
    
})