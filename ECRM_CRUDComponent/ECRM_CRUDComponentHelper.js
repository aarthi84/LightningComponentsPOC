({
	getCDTTeams : function(component) {		
         component.set("v.messageToUser", "");
         var action = component.get("c.getLoggedInUserCDTTeams");
         action.setCallback(this, function(data) {
             var state = data.getState();
            	if (state === "SUCCESS") //No error from server
                {
                	var result = data.getReturnValue();
                    if(result.noPrimaryTeam)//That means no primary team specified
                    {
                        component.set("v.selectedTeam", result.primaryTeamName);
                        component.set("v.messageToUser", "Please select your Primary team");
                        component.set("v.userCDTTeams", "");
                    }
                    else
                    {
                        var hideComp = component.find('message');
        				$A.util.removeClass(hideComp, 'slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_error');                        
                        component.set("v.userCDTTeams", result.userCDTTeams);
                        component.set("v.selectedTeam", result.primaryTeamName);
                    }
                }
         });
        $A.enqueueAction(action);
	},
    
    getHuddleTypes : function(component) {	
         var initalText = component.get("v.huddleValSel");
         var action = component.get("c.getPickListValuesForCRUDHuddleType");
         action.setParams({ 
            "selectionStr": initalText
        });
         action.setCallback(this, function(data) {
             var state = data.getState();
            	if (state === "SUCCESS") //No error from server
                {
                	var result = data.getReturnValue();
                    component.set("v.huddleTypes", result);                   
                }
         });
        $A.enqueueAction(action);
	},
    createCRUDContents : function(component)
    {
        component.set("v.crudContents",[]);
        var teamName = component.get("v.selectedTeam");
        var huddleType = component.get("v.selectedHuddleType");
        var newContent = component.find("content").get("v.value");
        var action = component.get("c.createAndGetHuddleContents");
        action.setParams({ 
            "teamName": teamName,
            "huddleType":huddleType,
            "newContent":newContent
        });
           action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var result = response.getReturnValue();                
                component.set("v.crudContents", result);
                //console.log('result'+result);
            }
        });
        $A.enqueueAction(action);	
    },
    getCRUDContents : function(cmp)
    {
        cmp.set("v.crudContents",[]);
        var teamName = cmp.get("v.selectedTeam");
        var huddleType = cmp.get("v.selectedHuddleType");
        var action = cmp.get("c.getCRUDContentByTeamAndType");
        action.setParams({ 
            "teamName": teamName,
            "huddleType":huddleType
        });
           action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var result = response.getReturnValue();
                cmp.set("v.crudContents", result);
                console.log('result'+result);
            }
        });
        $A.enqueueAction(action);	
    },
    upsertCRUDCon : function(component, contents, callback) {
        component.set("v.crudContents",[]);
        var teamName = component.get("v.selectedTeam");
        var huddleType = component.get("v.selectedHuddleType");
        var action = component.get("c.upsertCRUDContent");
        action.setParams({
            "teamName":teamName,
            "huddleType":huddleType,
            "contents": contents
        });
        action.setCallback(this,function(response) {
            component.set("v.crudContents", response.getReturnValue());
      	});
        $A.enqueueAction(action);
    }
    
    
})