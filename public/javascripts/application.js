// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
    $("a.popup_image").colorbox({maxWidth:'100%', maxHeight:'100%'});

    $(".horizontal").click(function() {
       $(this).toggleClass('horizontal').toggleClass('full');
    });

    $(".vertical").click(function() {
       $(this).toggleClass('vertical').toggleClass('full');
    });
});