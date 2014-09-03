$(document).ready(function(event){
    $('.dropdown-toggle').dropdown();

    // Resize content-body div to fill the vertical space between the header
    // and footer.
    var resizeContentBody = function(event) {
	var content_body_height = $(window).height() -
	    ($("header").outerHeight() + $("footer").outerHeight());
	$("#content-body").css("min-height", content_body_height + "px");
    };

    resizeContentBody();
    $(window).resize(function(event) {
	resizeContentBody();
    });
});
