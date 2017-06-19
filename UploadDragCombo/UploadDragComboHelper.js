({
    MAX_FILE_SIZE: 750 000, /* 1 000 000 * 3/4 to account for base64 */
    
    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
  			return alert('Image file not supported');
		}
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            console.log(dataURL);
            component.set("v.pictureSrc", dataURL);
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
	},
    
    upload: function(component, file, base64Data) {
        var action = component.get("c.saveHuddleRec"); 
        action.setParams({
            huddleType: 'Problem Solve',
            fileName: file.name,
            base64Data: base64Data, 
            contentType: file.type
        });
        action.setCallback(this, function(a) {
            component.set("v.message", "Image uploaded");
        });
        component.set("v.message", "Uploading...");
        $A.enqueueAction(action); 
    }

})