var tree = "tree";

/**
 * Marks a link as being selected. 
 *
 * @param parentID the ID of the LI containing the link.
 */
function selectLink(parentID){
    // Clear all the classes from the a elements, and selects the target.
    var aElements = parent.tocwin.document.getElementById(tree).getElementsByTagName("a");
    var j = 0;
    for (j = 0; j < aElements.length; j++){
      if(aElements[j].parentNode.id == parentID){
        // Selected.
        aElements[j].className='selected';
      } else {
        // Unselected.
        aElements[j].className='';
      }
    }    
}

/**
 * Expands and selects a specified topic.
 *
 * @param referringTopicURL The URL of the referring topic, as string.
 * @param href The relative location of the target.
 */
function expandToTopic(referringTopicURL, href) {
  var targetAbsoluteURL = makeAbsolute(getParent(referringTopicURL) +  '/' + href);
  var idsToExpand = findIds(targetAbsoluteURL);
  for (var i = 0; i < idsToExpand.length; i++) {
    selectLink(idsToExpand[i]);
    var id = "#" + idsToExpand[i];
    var root = "#" + tree;    
    
    $(id).parentsUntil(root)
    //Until(root)
    .find(">.hitarea")
    .replaceClass("expandable-hitarea", "collapsable-hitarea")
    .end()
    .replaceClass("collapsable", "expandable")
    // find child lists
    .find(">ul")
    // toggle them
    .heightShow("fast", false);
  }
}

function getParent(url){
  var str = "" + url;
   // Removes the last component from the path.
   url = url.substring(0, url.lastIndexOf('/'));
   return url;
}

/*
Finds all ids of parent elements of "a"'s having their hrefs ending in the target.
*/
function findIds(targetAbsoluteURL) {
  var returnedArray = new Array();  
  var windowLocation = getParent(parent.tocwin.location.href);
  var aElements = parent.tocwin.document.getElementsByTagName("a");
  var nr = aElements.length;
  
  var k = 0;
  for (var i = 0; i < nr; i++) {    
    var linkURL = makeAbsolute(windowLocation + '/' + aElements[i].getAttribute("href"));
    if (targetAbsoluteURL == linkURL) {
      returnedArray[k] = aElements[i].parentNode.id;
      k++;
    }
  }
  return returnedArray;
}

/**
*  Makes absolute the input URL by stripping the .. constructs.
*/
function makeAbsolute(inputURL) {
  var url = inputURL;
  // matches a foo/../ expression
  var reParent = /[\-\w]+\/\.\.\//;
  
  // reduce all 'xyz/../' to just ''
  while (reParent.test(url)) {
    url = url.replace(reParent, "");
  }
  
  return url;
}

/**
 * Opens a page (topic) file and highlights a word from it.
 */
function openAndHighlight(page, words, linkName){
    var links = document.getElementsByTagName('a');
    for (var i = 0 ; i < links.length ; i++){
        if (links[i].id == linkName ){
            document.getElementById(linkName).className = 'otherLink';
        } else if (links[i].id.startsWith('foundLink')) {
            document.getElementById(links[i].id).className = 'foundResult';
        }
    }
    
	parent.termsToHighlight = words;
	parent.frames['contentwin'].location = page;	
}

/**
 * Hide and show div-s
 */
function hideDiv(hiddenDiv,showedDiv){   
    parent.termsToHighlight = Array();
    document.getElementById(hiddenDiv).style.display = "none";
    document.getElementById(showedDiv).style.display = "block";
    
	if (hiddenDiv == 'searchDiv'){
		document.getElementById('divContent').innerHTML = '<font class="normalLink">Content</font>';
		document.getElementById('divSearch').innerHTML = '<a href="javascript:void(0);" class="activeLink" id="searchLink" onclick="hideDiv(\'displayContentDiv\',\'searchDiv\')">Search</a>';
	} else {
		document.getElementById('divContent').innerHTML = '<a href="javascript:void(0);" class="activeLink" id="contentLink" onclick="hideDiv(\'searchDiv\',\'displayContentDiv\')">Content</a>';
		document.getElementById('divSearch').innerHTML = '<font class="normalLink">Search</font>';
	}
    
    $('*', window.parent.frames[1].document).unhighlight();
}