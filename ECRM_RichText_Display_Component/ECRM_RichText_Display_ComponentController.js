({
    myAction : function(component, event, helper) {
        component.set("v.headerMsg", "Parking Lot");
        var action = component.get("c.getFocusOfTheWeekHuddleContent");
        action.setParams({ 
            "huddleType": "Parking Lot"
        });
         action.setCallback(this, function(response) {
            var state = response.getState();             
            if (component.isValid() && state === "SUCCESS") {
                	var result = response.getReturnValue();
                  component.set("v.myVal", result.fotwText);
                  console.log('test'+ component.get("v.myVal")); 
				  component.set("v.tName", result.teamName);
                  component.set("v.huddleId",result.hudId);
                }
        });
        $A.enqueueAction(action);	
    },
    handleApplicationEvent : function(component, event) {
         component.set("v.myVal", "");
        component.set("v.tName", "");
        var teamName = event.getParam("teamName");
         component.set("v.tName", teamName);
        var action = component.get("c.getFocusOfTheWeekForTeam");
        action.setParams({ 
            "teamName": teamName,
            "huddleType": "Parking Lot"
        });
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
               var result = response.getReturnValue();
                  component.set("v.myVal", result.fotwText);
                  console.log('test'+ component.get("v.myVal")); 
                component.set("v.huddleId",result.hudId);
                }
        });
        $A.enqueueAction(action);		
    }/*,
    
    createHuddle : function(component, event, helper) {
        var fotwContent = component.find("getValue").get("v.value");
        var hudType = "Focus of the Week";
        var teamNam = component.get("v.tName");
        var action = component.get("c.saveFOTW");
        component.set("v.myVal", " ");
        action.setParams({
            "teamName":teamNam,
            "content": fotwContent,
            "huddleType":hudType 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //var valuevar = component.get("v.myVal");
               // valuevar.push(response.getReturnValue());
                  component.set("v.myVal", response.getReturnValue());
                  console.log('test'+ component.get("v.myVal")); 

                }
        });
        $A.enqueueAction(action);	
        
    }*/
})