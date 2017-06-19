{
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
                        //component.set("v.selectedTeam", result.primaryTeamName);
                        component.set("v.messageToUser", "Please select your Primary team");
                        component.set("v.userCDTTeams", "");
                    }
                    else
                    {
                        var hideComp = component.find('messagediv');
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
         var action = component.get("c.getPickListValuesForUploadHuddleType");
         action.setParams({ 
            "selectionStr": initalText
        });
         action.setCallback(this, function(data) {
             var state = data.getState();
            	if (state === "SUCCESS") //No error from server
                {
                	var result = data.getReturnValue();
                    component.set("v.huddleTypes", result); 
                    component.set("v.selectedHuddleType", component.get("v.huddleValSel"));
                }
         });
        $A.enqueueAction(action);
	}, 
        getPictureFromAttachment : function(component)
    {
        var teamName = component.get("v.selectedTeam");
        var huddleType = component.get("v.selectedHuddleType");
        component.set("v.pictureSrc", "");
        var action = component.get("c.getAttachment4Team"); 
        action.setParams({
            teamName:teamName,
            huddleType:huddleType
        });
        action.setCallback(this, function(a) {
             var state = a.getState();
            	if (state === "SUCCESS") //No error from server
                {
         			var result = a.getReturnValue();
         			var attachment = result.attachment;
            			//console.log(attachment);
            		if (attachment && attachment.Id) {
	            	component.set('v.pictureSrc', '/servlet/servlet.FileDownload?file=' 
                                                  + attachment.Id);
                        var attachmentURL = result.attachmentURL;
                    attachmentURL = attachmentURL+'/servlet/servlet.FileDownload?file='+attachment.Id;
                    //component.set("v.attachmentURL",attachmentURL);
                        var oURL = component.find("oURL");
       							 oURL.set("v.value", attachmentURL);
       							 oURL.set("v.label", attachmentURL);
            	}
                }
                 	
        });          	
        $A.enqueueAction(action); 
    },
    upload: function(component,file, fileContents ) {
        //debugger;
        var teamName = component.get("v.selectedTeam");
        var huddleType = component.get("v.selectedHuddleType");
 		var action = component.get("c.uploadAttachments");
        action.setParams({
            teamName: teamName,
            huddleType: huddleType,
            fileName: file.name,
            base64Data: fileContents, 
            contentType: file.type
        }); 
        action.setCallback(this, function(response) {
             debugger;
             var state = response.getState();
             if (state === 'SUCCESS') {
                 component.set("v.message", "Image uploaded");
                 var result = response.getReturnValue();
                 var attachment = result.attachment;
            	if (attachment && attachment.Id) 
                {
                    //console.log(attachment);
	            	component.set('v.pictureSrc', '/servlet/servlet.FileDownload?file=' 
                                                  + attachment.Id);
                    var attachmentURL = result.attachmentURL;
                    attachmentURL = attachmentURL+'/servlet/servlet.FileDownload?file='+attachment.Id;
                    //component.set("v.attachmentURL",attachmentURL);
                    var oURL = component.find("oURL");
       							 oURL.set("v.value", attachmentURL);
       							 oURL.set("v.label", attachmentURL);                    
            	}
                 else
                 {
                     component.set("v.message", "Image did not get to upload. Please contact system administrator");
                 }
                                  
             }
             
        	});
            component.set("v.message", "Image will be uploaded asynchronously");
            $A.enqueueAction(action); 
    }
}