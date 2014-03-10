/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

$(document).bind("mobileinit", function() {
  $.mobile.defaultPageTransition = "slide";
  $.mobile.transitionFallbacks.slideout = "none";
});


/**
 * Callback for page init.
 */
$(document).bind("pageinit", function(){

    
    $(document).unbind("swiperight");
    $(document).bind("swiperight", function(){
        var anchor = $("a.prevPage:last").attr("href");
        
        $.mobile.changePage(anchor, {
            transition: "slide",
            reverse: true
        });
     });
     
    $(document).unbind("swipeleft");
    $(document).bind("swipeleft", function(){
        var anchor = $("a.nextPage:last").attr("href");
        
        $.mobile.changePage(anchor, {
            transition: "slide",
            reverse: false
        });
     });
     

    // Change the header text width depending on the orientation.
    // Classes defined in topic.css
    checkOrientation();
   
    // Listen for orientation changes 
    $(window).on("orientationchange", function(event) {
        changeOrientation(event.orientation);
    });
    
    // Scroll to the fragment.
    setTimeout(function(){
      var id = window.location.hash;
      if (id){    
        $(function(){     
              $('html, body').animate({
                scrollTop: $(id).offset().top
              }, 300);      
          });
      }      
    }, 600);
});


function checkOrientation(){
   var orientation = "";
   if(window.innerHeight > window.innerWidth){
        // Portrait
        orientation = "portrait";
  } else {
        // Landscape
        orientation = "landscape";
  }
  changeOrientation(orientation);
}

function changeOrientation(orientation){
   if(orientation === "portrait"){
        // Portrait
        $("h1.pageHeader").removeClass("orientation-landscape");
        $("h1.pageHeader").addClass("orientation-portrait");
  } else {
        // Landscape
        $("h1.pageHeader").removeClass("orientation-portrait");
        $("h1.pageHeader").addClass("orientation-landscape");
  }
}