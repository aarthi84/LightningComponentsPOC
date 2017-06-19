({
	doInit : function(component, event, helper) {
        var action = component.get("c.getLoggedInUserCDTTeams");
         action.setCallback(this, function(a) {
            //console.log(a.getReturnValue());
            var result = a.getReturnValue();
            component.set("v.cdtGrpList", result.userCDTTeams);
            var appEvent = $A.get("e.c:TeamNameEvt");
            appEvent.setParams({
            "teamName" : result.primaryTeamName });
        	appEvent.fire();
         });
        $A.enqueueAction(action);
		
	},
    changeFilter:function(component,event){
        var selectCmp = component.find("selection");
        var selectVal = selectCmp.get("v.value");
        var appEvent = $A.get("e.c:TeamNameEvt");
        appEvent.setParams({
            "teamName" : selectVal });
        appEvent.fire();
        console.log('Selected Value '+selectVal);        
        //component.set("v.selectedHuddle", selectVal);
        
        
    }
})