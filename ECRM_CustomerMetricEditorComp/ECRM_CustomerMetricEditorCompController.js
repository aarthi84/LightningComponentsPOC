{
    doInit : function(component, event, helper) {
        helper.getCDTTeams(component);
        helper.getAccountLists(component);
        helper.getFields(component);
	},
        changeFilter : function(component,event,helper)
    {
        var selectCmp = component.find("selection");
        var selectVal = selectCmp.get("v.value");
        component.set("v.selectedTeam", selectVal);
        var initialText = component.get("v.huddleValSel");
        var huddleType = component.get("v.selectedHuddleType");
        if(huddleType!=initialText)
        {
            component.set("v.isSuccess",false);
            component.set("v.isNoHuddleTypeSele",false);
            component.set("v.isNoContent",false);
        }
        if(huddleType=='News')
        {
            component.set("v.richTextContent","");
            component.set("v.isCRUD",true);
            helper.getCRUDContents(component);
        }
        else
        {
            component.set("v.isCRUD",false);
            helper.getRichTextContent(component);
        }
        
    },
        changeFilterForHuddle :function(component,event,helper)
    {
        var initialText = component.get("v.huddleValSel");
        var selectCmp = component.find("selectHuddle");
        var selectVal = selectCmp.get("v.value");
        component.set("v.selectedHuddleType", selectVal);
        var huddleType = component.get("v.selectedHuddleType");
        if(huddleType!=initialText)
        {
            component.set("v.isSuccess",false);
            component.set("v.isNoHuddleTypeSele",false);
            component.set("v.isNoContent",false);
        }
        var teamName = component.get("v.selectedTeam");
        if(huddleType=='News')
        {
            component.set("v.richTextContent","");
            component.set("v.isCRUD",true);
            helper.getCRUDContents(component);
        }
        else
        {
            component.set("v.isCRUD",false);
            helper.getRichTextContent(component);
        }
             
    },
       /*           
   		handleComponentEvent : function(cmp, event, helper) {
        cmp.set("v.isSuccess", false);
        var initialText = cmp.get("v.huddleValSel");
        var selectedTeam = event.getParam("teamNameUpdate");
        var selectedHuddleType = event.getParam("huddleTypeUpdate");
        if(selectedHuddleType==initialText)
        {
            cmp.set("v.isNoContent",false);
            cmp.set("v.richTextContent","");
            cmp.set("v.isNoHuddleTypeSele",true);
            //cmp.set("v.messageToUser",'Please select huddle type to display the content');                        
        }            
        else if((!$A.util.isEmpty(selectedHuddleType))&& (selectedHuddleType!=initialText)){
            cmp.set("v.isNoHuddleTypeSele",false); 
            cmp.set("v.isNoContent",false);
        	if(!$A.util.isEmpty(selectedTeam))
          		cmp.set("v.selectedTeam", selectedTeam);
        	else  if(!$A.util.isEmpty(selectedHuddleType))//if the selected huddle type is not please select, pass team name and huddle type to pull the values and assign it o rich text editor
            	cmp.set("v.selectedHuddleType", selectedHuddleType);        
       		helper.getRichTextContent(cmp);  
        }
		//console.log(cmp.get("v.selectedTeam"));        
    },*/
    
        upsertHuddle : function(component,event,helper)
    	{
            component.set("v.isSuccess", false);
            var initialText = component.get("v.huddleValSel");
            var teamName = component.get("v.selectedTeam");
        	var huddleType = component.get("v.selectedHuddleType");
            var content = component.find("richText").get("v.value");
            if((huddleType==initialText) && ($A.util.isEmpty(content)))
               {
               		component.set("v.isNoHuddleTypeSele",true);
            		component.set("v.isNoContent",true);
               }
            else if(huddleType==initialText)
                    {
                    	component.set("v.isNoHuddleTypeSele",true);
    					component.set("v.isNoContent",false);
                    }
            	
    		else if($A.util.isEmpty(content))
                    {
                    	component.set("v.isNoHuddleTypeSele",false);
                    	component.set("v.isNoContent",true);                    
                    }
            else if((huddleType!=initialText)&&(!$A.util.isEmpty(content)))
             {
                    component.set("v.isNoHuddleTypeSele",false);
            		component.set("v.isNoContent",false);
                 	if(huddleType=='News')
                    {
                        helper.createCRUDContents(component);
                    }
                 else{
						var action = component.get("c.saveRichTextHuddleContent");
                    action.setParams({ 
                    "teamName": teamName,
                    "huddleType":huddleType,
                    "content":content
                    });
                    action.setCallback(this, function(response) {
                    var state = response.getState();
                        if (state === "SUCCESS") 
                        {
                            component.set("v.isSuccess", true);
                        }
                    });            
                     $A.enqueueAction(action);                     
                 }
                    
             }
    	},
          /*  createHuddle : function(component, event, helper) {
        var newContent = component.find("content").get("v.value");
         if($A.util.isEmpty(newContent))
             component.set("v.isNoContentTyped",true);
         else if(!$A.util.isEmpty(newContent))
         {
             component.set("v.isNoContentTyped",false);
             helper.createCRUDContents(component);
         }
             
     },*/
    updateEvent : function(component, event, helper) {
    	helper.upsertCRUDCon(component, event.getParam("contents"));
	}
    
}