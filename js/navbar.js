var lastScrollPos = 0;

function navUpdate() {

    var currScrollPos = $(this).scrollTop();

    if (currScrollPos < lastScrollPos || $(this).scrollTop() == 0) {
        // Scrolling up
        $("#floatingfoot").addClass("floatingfoot-fixed");
        
    } else {
        // Scrolling down
        //console.log("Scrolling down");        
        $("#floatingfoot").removeClass("floatingfoot-fixed");
    }


    lastScrollPos = currScrollPos;
}
$(window).scroll(navUpdate);
$(window).resize(navUpdate);
