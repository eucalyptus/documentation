$(document).ready(function(){
    var childTOC = $( ".wh-toc-selected" );
    var x = $(childTOC).parent();
    if (x.children().length > 1) {
        x.removeClass("toc-collapsed").addClass("toc-expanded");
        x.children().css('display','block');
    }
});
