var lastScrollPos = 0;

function sidebarUpdate() {

    var currScrollPos = $(this).scrollTop();

    // Get sidebar location + size
	var padding = 70;
    var sidebarWidth  = $("#sidebar").parent().width();
    var sidebarHeight = $("#sidebar").height();
    var upper  = $("#sidebar").parent().position().top;
    var lower  = upper + sidebarHeight;
    
    // New position
    var windowHeight  = $(window).height() - padding;

    if (currScrollPos > upper) {

        if (currScrollPos > lastScrollPos) {
            // Scrolling down
            var scrolledpos = Math.max(windowHeight - sidebarHeight, $("#sidebar").position().top + (lastScrollPos - currScrollPos));
            var newpos = Math.min(0,scrolledpos);

            //var newpos = Math.min(0, $("#sidebar").position().top + (currScrollPos - lastScrollPos) + sidebarHeight);
        } else {
            // Scrolling up
            var newpos = Math.min(0, $("#sidebar").position().top + (lastScrollPos - currScrollPos));
        }

        $("#sidebar").addClass("sidebar-fixed");
        $("#sidebar").width(sidebarWidth);
        $("#sidebar").css('top', newpos)
    } else {
        $("#sidebar").removeClass("sidebar-fixed");
        $("#sidebar").width("");
    }   


    lastScrollPos = currScrollPos;
}
$(window).scroll(sidebarUpdate);
$(window).resize(sidebarUpdate);
