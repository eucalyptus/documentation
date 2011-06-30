var redirectPageTo = parent.location.search.substring(3);

/**
 * Redirects to frames/no frames version of the manual. 
 *
 * @param currentUrl the link of the page that is redirected to the frames version.
 */
function redirectFrames(currentUrl){
  if (parent.window.location.pathname != window.location.pathname){
    //No Frames
    parent.window.location = "http://" + location.hostname + currentUrl;  
  } else {
    //With Frames
    window.location = prefix + "?q=" + currentUrl;
  }
}
  
/**
 * Redirects to the frames version of the manual if a parameter is found in url. 
 *
 * @param toc - if true redirects the page to the frames version 
 */
function redirectToToc(url){  
   var page = url.substr(1);
   var x;
   if (page != ""){
     page = page.split("&");
     for (x in page) {
        if(page[x] == 'toc=true'){
         redirectFrames(window.location.pathname); 
        }
     }
   }
} 

  