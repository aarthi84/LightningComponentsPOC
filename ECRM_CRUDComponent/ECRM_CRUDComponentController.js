({
	myAction : function(component, event, helper) {
        helper.getCDTTeams(component);
        helper.getHuddleTypes(component);
        component.set("v.crudContents",[]);         	
	},
    handleComponentEvent : function(cmp, event, helper) {
        //cmp.set("v.isSuccess", false);
        var initialText = cmp.get("v.huddleValSel");
        var selectedTeam = event.getParam("teamNameUpdate");
        var selectedHuddleType = event.getParam("huddleTypeUpdate");
        if(selectedHuddleType==initialText)
        {
            cmp.set("v.isNoHuddleTypeSele",true);
            cmp.set("v.crudContents",[]);
            //cmp.set("v.messageToUser",'Please select huddle type to display the content');
        }            
        else if(selectedHuddleType!=initialText){
            cmp.set("v.isNoHuddleTypeSele",false);       
        	if(!$A.util.isEmpty(selectedTeam))
          		cmp.set("v.selectedTeam", selectedTeam);
        	else  if(!$A.util.isEmpty(selectedHuddleType))//if the selected huddle type is not please select, pass team name and huddle type to pull the values and assign it o rich text editor
            	cmp.set("v.selectedHuddleType", selectedHuddleType);        
       		helper.getCRUDContents(cmp);  
        }
		//console.log(cmp.get("v.selectedTeam"));        
    },
     createHuddle : function(component, event, helper) {
        var newContent = component.find("content").get("v.value");
         if($A.util.isEmpty(newContent))
             component.set("v.isNoContentTyped",true);
         else if(!$A.util.isEmpty(newContent))
         {
             component.set("v.isNoContentTyped",false);
             helper.createCRUDContents(component);
         }
             
     },
    updateEvent : function(component, event, helper) {
    	helper.upsertCRUDCon(component, event.getParam("contents"));
	}
             
})