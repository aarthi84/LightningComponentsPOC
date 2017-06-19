({
	ToggleCollapseHandler : function(component, event) {  
        var existingText = component.get("v.collpaseText"); 
        var container = component.find("containerCollapsable") ;
        
        if(existingText === "[ - ]"){
             component.set("v.collpaseText","[ + ]");
            $A.util.addClass(container, 'hide');
        }else{
            component.set("v.collpaseText","[ - ]");
            $A.util.removeClass(container, 'hide'); 
        }  
	}
})