({
showModal : function(component, event, helper) {
    
        document.getElementById("newClientSectionId").style.display = "block";
     document.getElementById("backGroundSectionId").style.display = "block";
    return false;
    },
    
    hideModal : function(component,event, helper){
    
       document.getElementById("newClientSectionId").style.display = "none" ;
       document.getElementById("backGroundSectionId").style.display = "none";
   }
    })