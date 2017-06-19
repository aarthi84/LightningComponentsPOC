({
	updatePicEvent : function(cmp, event) {
        var picSrcString = event.getParam("picSrc");
		console.log(picSrcString);
        cmp.set("v.pictureSrc",picSrcString);
        // set the handler attributes based on event data
        cmp.set("v.updatedpicSrc", "updated pic");
    }
})