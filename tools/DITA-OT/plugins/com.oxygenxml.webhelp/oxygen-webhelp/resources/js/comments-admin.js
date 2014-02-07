/*

Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * @description Product Name
 * @type {string}
 */
var productName = $("#oxy_productid").text();

/**
 * @description Product Version
 * @type {string}
 */
var productVersion = $("#oxy_productVersion").text();

/**
 * @description Browser URL including query
 * @type {string|href}
 */
var pageSearch = window.location.href;

/**
 * @description Browser URL without query
 * @type {string}
 */
var pageWSearch = pageSearch.replace(location.search, "");

/**
 * @description Used for internationalization.
 * @param localizationKey
 * @returns translated @localizationKey
 */
function getLocalization(localizationKey) {
	if (localization[localizationKey]){
		return localization[localizationKey];
	}else{
		return localizationKey;
	}
}

/**
 * {Refactored}
 * @description Check if webhelp system is installed
 * @returns {boolean}
 */
function checkConfig(){
	var page=conf.htpath + "oxygen-webhelp/resources/php/checkInstall.php";	
	
	var response={"installPresent":"true","configPresent":"false"};
	$.ajax({
		type : "POST",
		url : page,
		data : "",
    async : false,
		success : function(data_response) {			
				response = eval("("+data_response+")");
		}});	
	return response;
}

/**
 * {Refactored}
 * @description Reset data from forms
 */
function resetData() {
	$('#loginData').hide();
	$('#u_Profile').hide();
	$("#u_Profile input").attr("type", function(arr) {
		var inputType = $(this).attr("type");
		if (inputType == "text" || inputType == "password") {
			$(this).val("");
		}
	});
	
	if ($("#preload").parent().get(0).tagName != "BODY") {
		$("#preload").appendTo("body");
	}
	if ($("#editUser").parent().get(0).tagName != "BODY") {
		$("#editUser").appendTo("body");
	}

	$("#loginResponse").html("");
	$("#loginData input").attr("type", function(arr) {
		var inputType = $(this).attr("type");
		if (inputType == "text" || inputType == "password") {
			$(this).val("");
		}
	});
}

/**
 * @description TRUE if Edit Account dialog is displayed, FALSE otherwise
 * @type {boolean}
 */
var shown = false;

/**
 * @description TRUE if Edit Account dialog is clicked, FALSE otherwise
 * @type {boolean}
 */
var clickInEditDiv = false;

$("body").click(function(e) {
	if (shown && !clickInEditDiv) {
		$("#editUser").css({
			top : e.pageY
		});
	}
});

$("#editUser .bt_close").click(function() {
	$(this).parent().hide();
	shown = false;
});

$("#editUser").click(function() {
	clickInEditDiv = true;
});

/**
 * @description Edit user details
 * @param id - User id
 */
function editUser(id) {
	hideAll();
	if (!shown) {
		$('#editUser').show();
		$('#setVersionDiv').hide();
		clickInEditDiv = false;
		shown = true;
	} else {
		shown = false;
		$('#editUser').hide();
	}

	$("#edit_userId").val(id);

	$('#edit_uName').html($("#u_" + id + " .username").text());
	$('#edit_name').val($("#u_" + id + " .name").text());

	$('#edit_company').val($("#u_" + id + " .company").text());
	$('#edit_email').val($("#u_" + id + " .email").text());
	$('#edit_date').html($("#u_" + id + " .date").text());

	if ($("#u_" + id + " .notifyAll").text() == 'yes') {
		$('#edit_nAll').attr('checked', 'checked');
	} else {
		$('#edit_nAll').removeAttr('checked');
	}
	if ($("#u_" + id + " .notifyPage").text() == 'yes') {
		$('#edit_nPage').attr('checked', 'checked');
	} else {
		$('#edit_nPage').removeAttr('checked');
	}
	if ($("#u_" + id + " .notifyReply").text() == 'yes') {
		$('#edit_nReply').attr('checked', 'checked');
	} else {
		$('#edit_nReply').removeAttr('checked');
	}

	// level
	var currentLevel = $("#u_" + id + " .level").text();
	$("select option#level" + currentLevel).attr('selected', 'selected');

	// status
	var currentStatus = $("#u_" + id + " .status").text();
	$("select option#status" + currentStatus).attr('selected', 'selected');
}

/**
 * @description Edit user account from admin panel
 * @returns {boolean} Return FALSE
 */
function persistEdit() {
    var level = $("select#edit_level option:selected").val();
    var status = $("select#edit_status option:selected").val();
    var notifyAll = ($('#edit_nAll').attr('checked') ? 'yes' : 'no');
    var notifyPage = ($('#edit_nPage').attr('checked') ? 'yes' : 'no');
    var notifyReply = ($('#edit_nReply').attr('checked') ? 'yes' : 'no');
    var name = $('#edit_name').val();
    var email = $('#edit_email').val();
    var userId = $("#edit_userId").val();
    var company = $('#edit_company').val();
    var postData = 'update=true&product=' + productName + '&version='
            + productVersion + "&name=" + name + "&email=" + email
            + "&notifyPage=" + notifyPage + "&notifyAll=" + notifyAll
            + "&notifyReply=" + notifyReply + "&userId=" + userId + "&level="
            + level + "&company=" + company + "&status=" + status;

    $("#preload").show();

    $.ajax({
        type : "POST",
        url : conf.htpath + "oxygen-webhelp/resources/php/profile.php",
        dataType : "html",
        data : postData,
        success : function(data_response) {
            // display all users
            var response = eval('('+data_response+')');
            if (response.updated!='true'){
                $('#msgInfo').html(response.msg);
            }
            if ($("#preload").parent().get(0).tagName != "BODY") {
                $("#preload").appendTo("body");
            }
            $("#preload").hide();
            $('#editUser').hide();
            $('#editUserBck').hide();
            $("#edit_userId").val('');
            shown = false;
            showAdmin();
        },
        error : function(xhr, ajaxOptions, thrownError) {
            if ($("#preload").parent().get(0).tagName != "BODY") {
                $("#preload").appendTo("body");
            }
            $("#preload").hide();
            $('#msgInfo').html("...");
        }
    });

    return false;
}

/**
 * @description In Admin Panel, show administrators only when user is logged as administrator
 */
function showAdmin() {
	var postData = 'select=true&product=' + productName + '&version='	+ productVersion;
	$("#preload").show();
    $('#adminUsers').hide();
	$.ajax({
		type : "POST",
		url : conf.htpath + "oxygen-webhelp/resources/php/adminShowUsers.php",
		data : postData,
		success : function(data_response) {
			// display all users
			if ($("#preload").parent().get(0).tagName != "BODY") {
				$("#preload").appendTo("body");
			}
			$("#preload").hide();      
			if (data_response != "0") {
      	        $('#adminUsers #list').html(data_response);
				$('#adminUsers').show();
			}
			if (window.location.search != "") {
				var s = window.location.search;
				var substr = s.split('=');
				$('input#id_search').val(substr[1]);
				$('input#id_search').attr('value', substr[1]).trigger('keyup');
				// $('input#id_search').trigger('submit');
			}

		},
		error : function(data_response) {
			if ($("#preload").parent().get(0).tagName != "BODY") {
				$("#preload").appendTo("body");
			}
			$("#preload").hide();
		}
	});

	displayUserAccount();

	if (getParam('a') != '') {		
		$("#loginResponse").html(getLocalization('label.logAdmin'));
		showLoggInDialog();
	}
}

/**
 * @description Retrieve specified parameter from current URL
 * @param name Required parameter
 * @returns {*} Value of required parameter
 */
function getParam(name) {
	var results = new RegExp('[\\?&]' + name + '=([^&#]*)')
			.exec(window.location.href);
	if (results != null && results.length > 1) {
		return results[1];
	} else {
		return "";
	}
}

/**
 * @description Display user account information
 */
function displayUserAccount() {
	$.ajax({
		type : "POST",
		url : conf.htpath + "oxygen-webhelp/resources/php/checkUser.php",
		data : "check=true&productName=" + productName + "&productVersion=" + productVersion + "&delimiter=|",
		success : function(data_response) {
			// Logged In|name|userName|level
			// var info = data_response.split("|");
			var response = eval('(' + data_response + ')');

			if (response.loggedIn == 'true') {
				loggedUser(response);
			} else {
					$("#accountInfo").html(getLocalization("label.welcome") + " " + getLocalization("label.guest"));
					$('#userAccount #show_profile').hide();
					$('#userAccount #bt_logIn').show();
					$('#userAccount #bt_signUp').show();
			}
		}
	});
}

/**
 * @description Go to last page stored in cookie
 */
function goLastPage() {
	var link = readCookie('backLink');
	if (link != '') {
		window.location = link;
	} else {
		parent.window.location = conf.htpath;
    }
}

/**
 * @description Show login dialog
 * @returns {boolean} Return FALSE
 */
function showLoggInDialog() {
	var encoded = readCookie("oxyAuth");
	var pss = Base64.decode(encoded);
	var auth = pss.split("|");
	
	$('#myUserName').val(auth[0]);
	$('#myPassword').val(auth[1]);	
	$("#myRemember").attr('checked', (readCookie("oxyAuth")!=""));
	document.getElementById('loginData').style.top=$(document).scrollTop()+$(window).height()/2+'px';
	$('#loginData').show();	

	return false;
}

/**
 * @description Show information about logged user
 * @param response Response of AJAX request. This contain information about logged user
 */
function loggedUser(response) {
	$("#accountInfo").html(getLocalization("label.welcome") + " " + response.name + " [" + response.userName + "]");
	if (response.level == "admin" || response.level == "moderator") {
		$("#accountInfo").append(" <span class='level'>"+ getLocalization('label.' + response.level) + "</span>");
		$('#adminMenu #bt_setVersion').show();
		$('#adminMenu #bt_export').show();
		$('#adminMenu #bt_viewPosts').show();
		//$('#adminUsers').show();
	}
	$("#accountInfo").append(" <input type='button' class='bt_toolbar' onclick='goLastPage()' value='" + getLocalization('label.back') + "' /> ");

	$('#userAccount #show_profile').show();
	$('#userAccount #bt_logIn').hide();
	$('#userAccount #bt_signUp').hide();
}

$("#bt_logIn").click(function() {
	// process form
	var encoded = readCookie("oxyAuth");
	var pss = Base64.decode(encoded);
	var auth = pss.split("|");
	
	$('#myUserName').val(auth[0]);
	$('#myPassword').val(auth[1]);	
	$("#myRemember").attr('checked', (readCookie("oxyAuth")!=""));
	
	
	showLoggInDialog();
	$("#u_Profile").hide();
	
	return false;
});

// login form execute
//$("#logIn").click(logIn);

$(".bt_close").click(closeDialog($(this).parent()));

// logoff form execute
$("#bt_logOff").click(logOff);

/**
 * @description Close dialog of clicked button
 * @returns {boolean} return FALSE
 */
function closeDialog() {
	$(this).parent().hide();
	return false;
};

/**
 * @description Submit formName form
 * @param formName Name of form that will be submitted
 */
function submitForm(formName) {
	document.forms[formName].submit();
}

/**
 * @description Process login form
 * @returns {boolean} return FALSE
 */
function logInAdmin() {
	// process form
	var userName = $("#myUserName").val();
	var password = $("#myPassword").val();
	var rememberMe = "no";
	if ($("#myRemember").is(':checked')) {
		rememberMe = "yes";
	}

	var dataString = '&userName=' + userName + '&password=' + password + "&productName=" + productName + "&productVersion=" + productVersion;

	var processLogin = conf.htpath + "oxygen-webhelp/resources/php/checkUser.php";
	if (userName != '' && password != '') {
		$('#preload').show();
		$('#loginData').hide();
		$.ajax({
			type : "POST",
			url : processLogin,
			data : dataString,
			success : function(data_response) {
				var response = eval('(' + data_response + ')');
				if (window.location.href != pageWSearch) {
					if (response.authenticated == 'false') {
						showLoggInDialog();
						if (response.error) {
							var msg = getLocalization('checkUser.loginError');
							msg = msg + "<!--" + response.error + " -->";
							$('#loginResponse').html(msg).show();
						} else {
							if (rememberMe == "yes") {
								var pss = Base64.encode(userName + "|" + password);
								setCookie("oxyAuth", pss, 14);
							}else{
								eraseCookie("oxyAuth");
							}
							$('#loginResponse').html(getLocalization('checkUser.loginError')).show();
						}
					} else {
						$('#loginResponse').html("").hide();
						window.location.href = pageWSearch;
					}
				} else {
					$('#preload').hide();
					if (response.authenticated == 'true') {
						$('#loginResponse').hide();
						$('#userAccount #show_profile').show();
						$('#userAccount #bt_logIn').hide();
						$('#userAccount #bt_signUp').hide();
						if (rememberMe == "yes") {
							var pss = Base64.encode(userName + "|" + password);
							setCookie("oxyAuth", pss, 14);
						}else{
							eraseCookie("oxyAuth");
						}
					} else {
						showLoggInDialog();
						if (response.error) {
							var msg = getLocalization('checkUser.loginError');
							msg = msg + "<!-- " + response.error + " -->";
							$('#loginResponse').html(msg).show();
						} else {
							$('#loginResponse').html(getLocalization('checkUser.loginError')).show();
						}
					}
				}
				showAdmin();
			},
			error : function(data_response) {
				if ($("#preload").parent().get(0).tagName != "BODY") {
					$("#preload").appendTo("body");

				}
				$("#preload").hide();
			}
		});
	}
	return false; //or the form will post your data to login.php
}

/**
 * @description Process Logoff
 * @returns {boolean} return FALSE
 */
function logOff() {
	// process form
	var dataString = "&logOff=true&productName=" + productName + "&productVersion=" + productVersion;
	var processLogin = conf.htpath + "oxygen-webhelp/resources/php/checkUser.php";
	$.ajax({
		type : "POST",
		url : processLogin,
		data : dataString,
		success : function(data_response) {
			displayUserAccount();
			$("#adminUsers").hide();
		}
	});
	resetData();
	goLastPage();
	return false;
}

/**
 * @description Read cookie information
 * @param a Cookie that will be retrieved
 * @returns {string} Value of retrieved cookie
 */
function readCookie(a) {
	var b = "";
	a = a + "=";
	if (document.cookie.length > 0) {
		offset = document.cookie.indexOf(a);
		if (offset != -1) {
			offset += a.length;
			end = document.cookie.indexOf(";", offset);
			if (end == -1)
				end = document.cookie.length;
			b = unescape(document.cookie.substring(offset, end));
		}
	}
	return b;
}

/**
 * @description Set cookie
 * @param c_name Cookie name
 * @param value Cookie value
 * @param exdays Cookie will expire after exdays
 */
function setCookie(c_name, value, exdays) {
	var exdate = new Date();
	exdate.setDate(exdate.getDate() + exdays);
	var c_value = escape(value) + ((exdays == null) ? "" : "; expires=" + exdate.toUTCString());
	document.cookie = c_name + "=" + c_value + "; path=/";
}

/**
 * @description Delete specified Cookie
 * @param name Cookie name
 */
function eraseCookie(name) {
	setCookie(name,"",-1);
}

$(".bt_close").click(closeDialog);

/**
 * @description Show dialog with all available versions.
 * @returns {boolean} return FALSE
 */
function showVersion() {
	hideAll();
	var dataString = "productName=" + productName + "&productVersion=" + productVersion + "&qVersion=true";

	var setVersionPath = conf.htpath + "oxygen-webhelp/resources/php/comment.php";
	$('#setVersionDiv').hide();
	$('#v_preload').show();
	$.ajax({
		type : "POST",
		url : setVersionPath,
		data : dataString,
		success : function(data_response) {
			$('#v_preload').hide();
			$('#editUser').hide();
			shown = false;			
			var response = eval('(' + data_response + ')');
			if (response.versions==""){
				$('#setVersionInfo').html(getLocalization("info.noComments"));
				$('#versions').html("");
			}else{
				$('#setVersionInfo').html(getLocalization('label.versionInfo'));
				$('#setVersionInfo').append(response.minVersion);
				$('#versions').html(response.versions);
			}
			
		}
	});

	$('#setVersionDiv').show();

	return false;
}

/**
 * @description Set visible version
 * @param minVersion Version that will be visible
 * @returns {boolean} return FALSE
 */
function setVersion(minVersion) {
	var dataString = "productName=" + productName + "&productVersion=" + productVersion + "&minVersion=" + minVersion;
	var setVersionPath = conf.htpath + "oxygen-webhelp/resources/php/comment.php";
	// $('#setVersionDiv').hide();
	$('#v_preload').show();
	$.ajax({
		type : "POST",
		url : setVersionPath,
		data : dataString,
		success : function(data_response) {
			$('#v_preload').hide();
			if (data_response != "Success") {
				$('#setVersionDiv').show();
			} else {
				showVersion();
			}
		}
	});
	return false;
}

/**
 * @description Show Export Comments dialog
 * @returns {boolean} return FALSE
 */
function showExportComments() {
	hideAll();
	
	var dataString = "productName=" + productName + "&productVersion=" + productVersion + "&qInfo=true";
	$('#ll_viewAll_tit').html(getLocalization('label.allPosts'));
//	$('#ex_val_version').html("");
	$('#exProductVersion').val("");
//	$('#ex_val_product').html("");
	$('#exFrmProductName').val("");
	$("#bt_do_export").addClass('bt_inactiv');
	$("#bt_do_export").removeClass('btn');
	$("#bt_do_export").attr('disabled','disabled');
	var setVersionPath = conf.htpath + "oxygen-webhelp/resources/php/commentInfo.php";
	$('#exportDiv').hide();
	$('#preload').show();
	$.ajax({
		type : "POST",
		url : setVersionPath,
		data : dataString,
		success : function(data_response) {
			$('#editUser').hide();
			shown = false;
			if (data_response==""){
				$('#ex_prod_val').html("<div class='product'>"+getLocalization("info.noComments")+"</div>");				
			}else{
				$('#ex_prod_val').html(data_response);
			}
			$('#ex_prod_val').append("<div id='empty_versions'>&nbsp;</div>");
			$('#preload').hide();
			$('#exportDiv').show();
		}
	});

	return false;
}

/**
 * @description Add specific class to selected version from Export Comments dialog
 * @param selected Clicked item
 * @param version Value of clicked (selected) item
 */
function setExpVersion(selected,version) {
	
	$('.selectable').removeClass('selectedItem');
	$(selected).addClass('selectedItem');
	
//	$('#ex_val_version').html(version);
	$('#exProductVersion').val(version);
  $("#bt_do_export").removeClass('bt_inactiv');
  $("#bt_do_export").addClass('btn');
  $("#bt_do_export").removeAttr('disabled');
	$("#bt_do_export").show();
}

/**
 * @description Show available versions for selected product
 * @param idx Item ID from available versions
 * @param product Product name
 * @returns {boolean} return FALSE
 */
function showVersions(idx,product) {		
	$('#empty_versions').hide();
	$('.versions').show();
	$('.selectable').removeClass('selectedItem');
	var productStr = "#p_" + idx;
	$('.p_selectable').removeClass('selectedItem');
	$(productStr).addClass('selectedItem');
	
//	$('#ex_val_product').html(product);
	$('#exFrmProductName').val(product);
//	$('#ex_val_version').html("");
	$("#bt_do_export").addClass('bt_inactiv');
	$("#bt_do_export").removeClass('btn');
	$("#bt_do_export").attr('disabled','disabled');
	$('.product_Versions').hide();
	var productStr = "#v_" + idx;
	$(productStr).show();
	$('.product_Versions').parent().removeClass('selected');
	$(productStr).parent().addClass('selected');
	return false;
}

/**
 * @description Process export form
 * @returns {boolean} return FALSE
 */
function doExport() {
	$('#fl_ProductName').val(productName);
	$('#fl_ProductVersion').val(productVersion);
	submitForm('exportCmts');
	return false;
}

/**
 * @description Hide DIVs listed (setVersionDiv, exportDiv, loginData, editUser, inlineViewDiv, msgInfo)
 */
function hideAll() {
	$("#setVersionDiv").hide();
	$("#exportDiv").hide();
	$("#loginData").hide();
	$("#editUser").hide();
	$('#inlineViewDiv').hide();
	$('#msgInfo').html('');
}

/**
 * @description Export comments in XML format.
 * @returns {boolean} return FALSE
 */
function viewAllPosts(){
	hideAll();		
	toDelete="-1";
	
	var productV = $('#exProductVersion').val();	
	var productN = $('#exFrmProductName').val();
	
	var dataString = "productName=" + productName + "&productVersion=" + productVersion + "&inPage=true&productN=" +productN + "&productV="+ productV;
	var setVersionPath = conf.htpath + "oxygen-webhelp/resources/php/exportComments.php";

	$('#preload').show();
    $('#ex_inline').html('');
	$('#bt_cleanUsr').hide();
	$('#bt_cleanCmts').hide();
	$('#bt_deleteCmts').show();
    $('#inlineViewDiv #v_preload').show();

	$.ajax({
		type : "POST",
		url : setVersionPath,
		data : dataString,
		success : function(data_response) {
			$('#preload').hide();
			$('#editUser').hide();
			shown = false;
			$('#ll_viewAll_tit_info').html("&nbsp;&nbsp;&nbsp;"+getLocalization('label.product')+": "+productN+"&nbsp;&nbsp;&nbsp;"+getLocalization('label.version')+": "+productV+" ");
            $('#inlineViewDiv #v_preload').hide();
			$('#ex_inline').html(data_response);
		}
	});
	$('#preload').hide();
	$('#inlineViewDiv').show();

	return false;
}

/**
 * @description Last message displayed in preload DIV
 * @type {string}
 */
var lastPreloadMessage="";

/**
 * @description Display preload message
 * @param text Message that will be displayed in preload
 */
function showPreload(text){	
	document.getElementById('preload').style.top=$(document).scrollTop()+$(window).height()/2+'px';	
	if (text){
		lastPreloadMessage=$('#l_plsWait').html();
		$('#l_plsWait').html(text);
	}
	$('#preload').show();
}

/**
 * @description Hide preload message
 */
function hidePreload(){
	$('#preload').hide();
	if (lastPreloadMessage){
		$('#l_plsWait').html(lastPreloadMessage);
	}
}

/**
 * @description ID of comment that will be deleted
 * @type {string}
 */
var toDelete="-1";

/**
 * @description Add comment (ID) to list of comments that will be deleted
 * @param id ID of comment
 */
function addToDelete(id){
	var toAdd=","+id;
	var found=toDelete.search(toAdd);
	if (found>0){		
		toDelete=toDelete.substr(0,found)+toDelete.substr(found+toAdd.length);
	}else{	
		toDelete=toDelete+toAdd;
	}
}

/**
 * @description Delete comments
 * @returns {boolean} return FALSE
 */
function deleteCmts(){
	showPreload();
	$.ajax({
		type : "POST",
		url : conf.htpath+"oxygen-webhelp/resources/php/moderate.php",
		data : "ids=" + toDelete + '&product=' + productName + '&version=' + productVersion,
		success : function(data_response) {
			$('#editUser').hide();
			hidePreload();
			shown = false;
			if (data_response == "true") {				
				toDelete="-1";
				$('#inlineViewDiv').hide();
			}
			viewAllPosts();
		}
	});
	return false;
}

/**
 * @description Delete comments associated with a topic that doesn't exist anymore
 * @returns {boolean} return FALSE
 */
function cleanDeleteCmts(){
	showPreload();
	$.ajax({
		type : "POST",
		url : conf.htpath+"oxygen-webhelp/resources/php/moderate.php",
		data : "ids=" + toDelete + '&product=' + productName + '&version=' + productVersion,
		success : function(data_response) {
			$('#editUser').hide();
			hidePreload();
			shown = false;
			if (data_response == "true") {				
				toDelete="-1";
				$('#inlineViewDiv').hide();
			}
			cleanCommentsDb();
		}
	});
	return false;
}

/**
 * @description Delete users older than 7 days and unconfirmed
 * @returns {boolean} return FALSE
 */
function cleanDeleteUsr(){
	showPreload();
	$.ajax({
		type : "POST",
		url : conf.htpath+"oxygen-webhelp/resources/php/deleteUsers.php",
		data : "ids=" + toDelete + '&productName=' + productName + '&productVersion=' + productVersion,
		success : function(data_response) {
			$('#editUser').hide();
			hidePreload();
			shown = false;
			if (data_response == "true") {
				toDelete="-1";
				$('#inlineViewDiv').hide();
			}
			cleanUsersDb();
		}
	});
	return false;
}

/**
 * @description Extract from DB users older than 7 days and unconfirmed
 * @returns {boolean}
 */
function cleanUsersDb(){
	hideAll();		
	toDelete="-1";
	$('#exProductVersion').val(productVersion);	
	$('#exFrmProductName').val(productName);

	$('#bt_cleanUsr').show();
	$('#bt_cleanCmts').hide();
	$('#bt_deleteCmts').hide();
	
	var dataString = "productName=" + productName + "&productVersion=" + productVersion 
		+ "&inPage=true&clean=true&productN=" +productName + "&productV="+ productVersion;
	var setVersionPath = conf.htpath + "oxygen-webhelp/resources/php/exportUsers.php";
		
	$('#ll_viewAll_tit').html(getLocalization('label.unconfirmedUsers'));
	$('#ll_viewAll_tit_info').html("&nbsp;&nbsp;&nbsp;"+getLocalization('label.product')+": "
			+productName+"&nbsp;&nbsp;&nbsp;"+getLocalization('label.version')+": "+productVersion+" ");
	$('#preload').show();
	$.ajax({
		type : "POST",
		url : setVersionPath,
		data : dataString,
		success : function(data_response) {
			$('#preload').hide();
			$('#editUser').hide();
			shown = false;			
			
			$('#ex_inline').html(data_response);
			if ($('#ex_inline').html()!=""){
				$('#inlineViewDiv').show();			
			}
		}
	});
	$('#preload').hide();

	return false;	
}

/**
 * @description Extract from DB comments associated with a topic that doesn't exist anymore
 * @returns {boolean} return FALSE
 */
function cleanCommentsDb(){

	hideAll();		
	toDelete="-1";
	$('#exProductVersion').val(productVersion);	
	$('#exFrmProductName').val(productName);
	
	$('#bt_cleanUsr').hide();
	$('#bt_cleanCmts').show();
	$('#bt_deleteCmts').hide();
	
	var dataString = "productName=" + productName + "&productVersion=" + productVersion 
		+ "&inPage=true&clean=true&productN=" +productName + "&productV="+ productVersion;
	var setVersionPath = conf.htpath + "oxygen-webhelp/resources/php/exportComments.php";
		
	$('#ll_viewAll_tit').html(getLocalization('label.invalidPosts'));
	$('#ll_viewAll_tit_info').html("&nbsp;&nbsp;&nbsp;"+getLocalization('label.product')+": "
			+productName+"&nbsp;&nbsp;&nbsp;"+getLocalization('label.version')+": "+productVersion+" ");
	$('#preload').show();
	$.ajax({
		type : "POST",
		url : setVersionPath,
		data : dataString,
		success : function(data_response) {
			$('#preload').hide();
			$('#editUser').hide();
			shown = false;			
			
			$('#ex_inline').html(data_response);
			if ($('#ex_inline').html()!=""){
				$('#inlineViewDiv').show();			
			}
		}
	});
	$('#preload').hide();

	return false;
}

$("#bt_setVersion").click(showVersion);
$("#bt_viewPosts").click(function(){
	$("#bt_do_export").click(function() {
		return false;
	});
	$("#bt_do_export").off('click');
	$('#bt_do_export').click(viewAllPosts);
	$('#ll_exp_tit').html(getLocalization('label.forView'));	
	showExportComments();
});

$("#bt_export").click(function(){
	$("#bt_do_export").click(function() {
		return false;
	});
	$("#bt_do_export").off('click');
	$('#bt_do_export').click(doExport);
	$('#ll_exp_tit').html(getLocalization('label.forExport'));	
	showExportComments();
});

$("#bt_do_export").addClass('bt_inactiv');
$("#bt_do_export").removeClass('btn');
$("#bt_do_export").attr('disabled','disabled');
$(".ex_close").click(closeDialog);

$(".bt_cancel").click(function(){
	$(".bt_close").click();
});
$("#l_cancelEdit").click(function(){
    $(".bt_close").click();
});

/**
 * @description TRUE if webhelp system is installed, FALSE otherwise
 * @type {boolean}
 */
var config=checkConfig();

if (config.installPresent=="true" && config.configPresent=="true"){
	window.location.href=conf.baseUrl+"oxygen-webhelp/resources/removeInstallDir.html";
}else if (config.configPresent=="true"){
showAdmin();
}else{
	$('#cm_title').append(' - '+getLocalization('configInvalid'));
	window.parent.location.href=conf.htpath +"install/";
}

$("#cleanDbBtn").click(cleanCommentsDb);
$("#cleanDbUsrBtn").click(cleanUsersDb);

$('#checkAll').click(function() {	  
  $('.cb-element').each(function(index) {
  	if ($(this).attr('checked')){
  		$(this).removeAttr('checked');
  	}else{
  		$(this).attr('checked', true);
  	}
  	
  	var id=$(this).attr('value');
    addToDelete(id);
  	
  });
});
