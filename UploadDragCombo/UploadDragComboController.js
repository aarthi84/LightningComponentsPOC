({  
    handleFilesChange : function(component, event, helper) {
        debugger;
        var fileList = component.find("file").get("v.files");
        helper.readFile(component, helper, fileList[0]);
    },
    // Load current profile picture
    onInit: function(component) {
         component.set("v.headerMsg", "Problem Solve");
         component.set("v.pictureSrc", "");
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
    },
    
    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
		event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("You can only upload one profile picture");
        }
        helper.readFile(component, helper, files[0]);
	}
    
})