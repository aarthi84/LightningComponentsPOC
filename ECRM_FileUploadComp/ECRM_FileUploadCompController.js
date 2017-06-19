{ 
    // Load current picture during initiate
    doInit : function(component, event, helper) {
        helper.getCDTTeams(component);
        helper.getHuddleTypes(component);
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
            component.set("v.pictureSrc","");
            component.set("v.message","");
            var oURL = component.find("oURL");
       							 oURL.set("v.value", "");
       							 oURL.set("v.label", "");
            component.set("v.isNoHuddleTypeSele",false);
            helper.getPictureFromAttachment(component);
        }
        else if(huddleType==initialText)
            component.set("v.isNoHuddleTypeSele",true);
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
            component.set("v.pictureSrc","");
            component.set("v.message","");
            var oURL = component.find("oURL");
       							 oURL.set("v.value", "");
       							 oURL.set("v.label", "");
            component.set("v.isNoHuddleTypeSele",false);
			helper.getPictureFromAttachment(component);            
        }
        else if(huddleType==initialText)
            component.set("v.isNoHuddleTypeSele",true);        
    },
       onFilesChange : function(component, event, helper) {
        //debugger;
           component.set("v.pictureSrc","");
           var oURL = component.find("oURL");
       							 oURL.set("v.value", "");
       							 oURL.set("v.label", "");
           var initialText = component.get("v.huddleValSel");
           var huddleType = component.get("v.selectedHuddleType");
           if(huddleType==initialText)
            component.set("v.isNoHuddleTypeSele",true);
           else
           {
               component.set("v.message","");
               var fileList = component.find("file").get("v.files");
        
                for(var x = 0; x < fileList.length; x++)
                {
                    var file = fileList[x];
                    var fr = new FileReader();
                    fr.readAsDataURL(file);
                }
                  fr.onload = function() 
                  {
                     //debugger;
                        var fileContents = fr.result;
                        var base64Mark = 'base64,';
                        var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                        fileContents = fileContents.substring(dataStart);
                        helper.upload(component, file, fileContents);				
                  };
             }
        }
                
}