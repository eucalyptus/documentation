/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

// Controls the transitions between main tabs.
// Should be no effect there.
 $(document).bind('pageinit', function(){     
    $("a[data-role=tab]").each(function () {
        var anchor = $(this);
        anchor.bind("click", function () {
            $.mobile.changePage(anchor.attr("href"), {
                transition: "none",
                changeHash: true
            });
            return false;
        });
    }); 
    
    // Controls the swipe distance.
    var swipeDistance = screen.width * 2/5;
		$.event.special.swipe.horizontalDistanceThreshold = swipeDistance;
 });

// Avoid presenting the error twice.
var chromeErrorShown = false;
// Check if is Google Chrome with local files
var notLocalChrome = true;
var addressBar = window.location.href;
if ( window.chrome && addressBar.indexOf('file://') === 0 ){
    notLocalChrome = false;
}

$(document).bind('pageshow', function() {
    
    // Focus the first input in the page.
    $($('.ui-page-active form :input:visible')[0]).focus();

    // Display an error message, for Google Chrome for local files.
    if ( !notLocalChrome && !chromeErrorShown){
        $.mobile.showPageLoadingMsg( 
            $.mobile.pageLoadErrorMessageTheme, 
            "Please move the generated WebHelp output to a web server, "+
            "or use another browser. Google Chrome does not handle this " + 
            "kind of output stored locally on the file system.", true);
        chromeErrorShown = true;
    }
});

// Declare the function for open and highlight, but disable it.
function openAndHighlight(){
    return true;    
}