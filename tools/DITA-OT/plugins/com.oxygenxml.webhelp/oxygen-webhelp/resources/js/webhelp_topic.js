/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * @description Get location used for "Link to this page"
 * @param currentUrl URL of current loaded page (frame)
 * @returns {string|*}
 */
function getPath(currentUrl) {
    //With Frames
    if (/MSIE (\d+\.\d+);/.test(navigator.userAgent) && location.hostname == '' && currentUrl.search("/") == '0') {
        currentUrl = currentUrl.substr(1);
    }
    path = prefix + "?q=" + currentUrl;
    return path;
}

/**
 * @description Highlight searched words
 * @param words {array} words to be highlighted
 */
function highlightSearchTerm(words) {
    if (top==self) {
        if (words != null) {
            // highlight each term in the content view
            $('#frm').contents().find('body').removeHighlight();
            for (i = 0; i < words.length; i++) {
                debug('highlight(' + words[i] + ');');
                $('#frm').contents().find('body').highlight(words[i]);
            }
        }
    } else {
        // For index with frames
        if (parent.termsToHighlight != null) {
            // highlight each term in the content view
            for (i = 0; i < parent.termsToHighlight.length; i++) {
                $('*', window.parent.contentwin.document).highlight(parent.termsToHighlight[i]);
            }
        }
    }
}

function feedback(){
	if (window.location.href.indexOf("/eucalyptus/")  > -1   ) {
		var topic=document.getElementsByTagName("title")[0].innerHTML ;
		var tmp=topic.replace(/<[^>]*>/, "");
		var topic=tmp.replace(/<\/[^>]*>/, "");
		document.getElementById("feedback").innerHTML = "<a href=\"mailto:heliondocs@hpe.com&subject=Eucalyptus%20Documentation%20Feedback%20on%20'"+topic+"'&body=Thank%20you%20for%20providing%20the%20Helion%20Eucalyptus%20Documentation%20Team%20with%20feedback%20about%20this%20topic!%20%20Please%20replace%20this%20text%20with%20your%20feedback.%0D%0A%20%0D%0ALeave%20the%20title%20unchanged,%20because%20this%20will%20make%20it%20clear%20to%20us%20what%20topic%20you%20are%20providing%20feedback%20about.%20%20If%20you%20need%20support,%20please%20contact%20your%20HPE%20Support%20representative.%0D%0A%20%0D%0AThanks%20for%20helping%20us%20improve%20the%20documentation!\">Feedback%20to%20the%20Helion%20Eucalyptus%20Docs%20Team</a>  ";
	}else {
		document.getElementById("feedback").style.display = "none";
	}
}

 
$(document).ready(function () {
    $('#permalink').show();
    if ($('#permalink').length > 0) {
        if (window.top !== window.self) {
            if (window.parent.location.protocol != 'file:' && typeof window.parent.location.protocol != 'undefined') {
                $('#permalink>a').attr('href', window.parent.location.pathname + '?q=' + window.location.pathname);
                $('#permalink>a').attr('target', '_blank');
            } else {
                $('#permalink').hide();
            }
        } else {
            $("<div class='frames'><div class='wFrames'><a href=" + getPath(location.pathname) + ">With Frames</a></div></div>").prependTo('.navheader');							        
            $('#permalink').hide();
        }
    }
    
    // Expand toc in case there are frames.
    if (top !== self && window.parent.tocwin) {
        if (typeof window.parent.tocwin.markSelectItem === 'function') {
            window.parent.tocwin.markSelectItem(window.location.href);
        }
    }
});