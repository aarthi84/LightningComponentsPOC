/* fileUploadController2.js is identical */
({  
    save : function(component, event, helper) {
        helper.save(component);
    },
    myAction : function(component, event, helper) {
        component.set("v.headerMsg", "Priority and capacity");
        var action = component.get("c.getImageFromAttachments"); 
        action.setParams({
            imageType:'Problem Solve'
        });
        action.setCallback(this, function(a) {
            var attachment = a.getReturnValue();
            console.log(attachment);
            if (attachment && attachment.Id) {
	            component.set('v.pictureSrc', '/servlet/servlet.FileDownload?file=' 
                                                  + attachment.Id);
            }
        });
        $A.enqueueAction(action); 
    }//,
   /* waiting: function(component, event, helper) {
    	$A.util.addClass(component.find("uploading").getElement(), "uploading");
    	$A.util.removeClass(component.find("uploading").getElement(), "notUploading");
    },
    
    doneWaiting: function(component, event, helper) {
    	$A.util.removeClass(component.find("uploading").getElement(), "uploading");
    	$A.util.addClass(component.find("uploading").getElement(), "notUploading");
    }*/
})