/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

var productName = $("#oxy_productID").text();
var productVersion = $("#oxy_productVersion").text();
var pageSearch = window.location.href;
var pageHash= window.location.hash;
var isModerator=false;
var isAnonymous=false;
var pathName = window.location.pathname;

var pageWSearch = pageSearch.replace(window.location.search,"");
pageWSearch = pageWSearch.replace(window.location.hash,"");

$(".bt_close").click(closeDialog);
$(".bt_cancel").click(function(){
	$(".bt_close").click();
});

$("#l_addNewCmt").click(showNewCommentDialog);
// post or edit comment
//$("#l_bt_submit_nc").click(submitComment);

$("#bt_recover").click(recover);
 
//$("#bt_signUp").click(signUp);

//debug("js 4");
$("#bt_yesDelete").click(deleteComment);
//debug("js 5");
$("#bt_noDelete").click(hideDeleteDialog);
//debug("js 5");

$("#bt_approveAll").click(showApproveAllDialog);
//debug("js 6");
$("#bt_yesApprove").click(approveAllComments);

$("#bt_noApprove").click(hideApproveDialog);


$("#bt_logIn").click(function(){
    $(".anonymous_post_cmt").remove();
    $('#loginResponse').html('');
    showLoggInDialog();
});

$("#bt_profile").click(updateUserProfile);

$("#bt_logOff").click(loggOffUser);

$(document).ready(function(){
    $("#userAccount").hide();

    $(window).on("scroll", function() {
        if((eval($("#bt_new").position().top -$(window).scrollTop()) < $("#comments").height()) && $("#l_addNewCmt").is(":visible")) {
            $("#comments").addClass('float_comments');
        } else {
            $("#comments").removeClass('float_comments');
        }
    });

});

if(checkConfig()) {
    showComments();
}

