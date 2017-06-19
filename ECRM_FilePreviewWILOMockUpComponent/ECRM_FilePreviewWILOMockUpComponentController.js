({
    myAction : function(component, event, helper) {
        component.set("v.headerMsg", "WILO");
        component.set("v.pictureSrc", "");
        var action = component.get("c.getAttachment4PrimaryTeam"); 
        action.setParams({
            huddleType:'WILO'
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
    handleApplicationEvent : function(component, event) {
        component.set("v.tName", "");
        var teamName = event.getParam("teamName");
        component.set("v.tName", teamName);
        component.set("v.pictureSrc", "");
        var oURL = component.find("oURL");
       							 oURL.set("v.value", "");
       							 oURL.set("v.label", "");
        var action = component.get("c.getAttachment4Team"); 
        action.setParams({
            teamName:teamName,
            huddleType:'WILO'
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
    }
})