({
	myAction : function(component, event, helper) {
        component.set("v.headerMsg", "News");
        var teamName = component.get("v.tName");
        if($A.util.isEmpty(teamName))
        {
            console.log('teamName'+teamName);
            var action = component.get("c.getNewsHuddleContent");
            action.setParams({
             "huddleType": "News"
        	});            
         	action.setCallback(this, function(response) {
             var result = response.getReturnValue();
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.HuddleContents", result.huddleList);
                component.set("v.tName", result.teamName);
                console.log(component.get("v.HuddleContents"));
                }
        });
        $A.enqueueAction(action);	
        }
		 	
	},
 	/*updateEvent : function(component, event, helper) {
    	helper.upsertHuddleCon(component, event.getParam("contents"));
	},
    createHuddle : function(component, event, helper) {
        var newContent = component.find("content").get("v.value");
        var teamNam = component.get("v.tName");
        var action = component.get("c.createHuddleContents4News");
        action.setParams({
             "teamName":teamNam,
            "newContent": newContent
        });
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.newContent", '');
                var HuddleContents = component.get("v.HuddleContents");
        HuddleContents.push(response.getReturnValue());
        component.set("v.HuddleContents", HuddleContents);

                console.log(component.get("v.HuddleContents"));
                }
        });
        $A.enqueueAction(action);	
    },*/
    handleApplicationEvent : function(component, event) {
        component.set("v.tName", "");
        var teamName = event.getParam("teamName");
         component.set("v.tName", teamName);
        var action = component.get("c.getNewsForTeam");
        action.setParams({ 
            "teamName": teamName,
            "huddleType": "News"
        });
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.HuddleContents", response.getReturnValue());
                console.log(component.get("v.HuddleContents"));
                }
        });
        component.set("v.teamNameFromEvent",teamName);
        $A.enqueueAction(action);	
    }
})